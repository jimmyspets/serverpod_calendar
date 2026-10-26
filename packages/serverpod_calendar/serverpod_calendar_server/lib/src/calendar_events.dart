part of 'calendar_module.dart';

T _eventProtocolValue<T>(T Function() action) {
  try {
    return action();
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  }
}

CalendarEventContent _validatedEvent(CalendarEventContent input) {
  try {
    return validateEventContent(input);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  }
}

CalendarEventTimingOverrides? _validatedOverrides(
  CalendarEventContent c,
  CalendarEventTimingOverrides? v,
) {
  try {
    return validateEventOverrides(c, v);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  }
}

final class _Event {
  _Event(this.identity, this.data, this.parent) {
    try {
      validateEventUid(data.protocolUid);
      if (data.calendarId != identity.calendarId) {
        throw ArgumentError('Wrong active parent');
      }
      data.content = validateEventContent(data.content);
      data.timingOverrides = validateEventOverrides(
        data.content,
        data.timingOverrides,
      );
      data.protocolState = validateEventProtocolState(
        data.protocolState ??
            eventProtocolBaseline(
              data.content,
              data.timingOverrides,
              data.createdAt,
              data.updatedAt,
              legacy: true,
            ),
        data.content,
        data.timingOverrides,
      );
      if (data.importBaseline != null) {
        validateEventImportBaseline(data.importBaseline!, data.protocolUid);
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
  final CalendarEventRecord identity;
  final CalendarEventDataRecord data;
  final _Active parent;
  CalendarEventPolicySnapshot get snapshot => CalendarEventPolicySnapshot(
    identity.id!,
    identity.calendarId,
    identity.revision,
    data.content,
    data.protocolUid.toString(),
    data.updatedAt,
    origin: data.origin,
    timingOverrides: data.timingOverrides,
    protocolState: data.protocolState,
  );
}

extension CalendarEventOperations on CalendarService {
  Set<CalendarEventFieldGroup> _egroups(List<CalendarEventFieldGroup> groups) {
    if (groups.length > CalendarEventFieldGroup.values.length) {
      throw _failure(CalendarFailureCode.validation);
    }
    return Set.unmodifiable(groups);
  }

  CalendarAuthorizationRequest _er(
    _Active parent,
    CalendarPermission op, {
    _Event? event,
    CalendarEventContent? proposed,
    CalendarEventProtocolState? proposedState,
    CalendarEventOccurrenceQuery? query,
    CalendarFreeBusyQuery? freeBusy,
    CalendarAvailabilitySearchQuery? search,
    CalendarAvailabilityTarget? target,
    CalendarEventOccurrenceChange? change,
    CalendarEventOccurrenceContentRequest? contentChange,
    CalendarEventTimingOverrides? proposedOverrides,
    Set<CalendarEventFieldGroup> groups = const {},
  }) => CalendarAuthorizationRequest(
    key: '${op.name}:${event?.identity.id ?? parent.identity.id}',
    operation: op,
    calendarId: parent.identity.id,
    current: parent.snapshot,
    eventId: event?.identity.id,
    currentEvent: event?.snapshot,
    proposedEvent: proposed,
    proposedEventProtocolState: proposedState,
    occurrenceQuery: query,
    freeBusyQuery: freeBusy,
    availabilitySearchQuery: search,
    availabilityTarget: target,
    occurrenceChange: change,
    eventOccurrenceContentChange: contentChange,
    proposedTimingOverrides: proposedOverrides,
    eventGroups: groups,
  );

  Future<_Event> _event(
    CalendarHostContext c,
    UuidValue id,
    Transaction tx, {
    CalendarEventRecord? identity,
    _Active? parent,
  }) => _eventInScope(c.scopeKey, id, tx, identity: identity, parent: parent);
  Future<_Event> _eventInScope(
    String scopeKey,
    UuidValue id,
    Transaction tx, {
    CalendarEventRecord? identity,
    _Active? parent,
  }) async {
    identity ??= await CalendarEventRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (identity == null || identity.id != id || identity.deletedAt != null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    parent ??= await _activeInScope(scopeKey, identity.calendarId, tx);
    if (parent.identity.scopeKey != scopeKey ||
        parent.identity.id != identity.calendarId) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final data = await CalendarEventDataRecord.db.findFirstRow(
      _session,
      where: (t) => t.eventId.equals(id),
      transaction: tx,
    );
    if (data == null) throw _failure(CalendarFailureCode.unavailable);
    return _Event(identity, data, parent);
  }

  void _eventRevision(_Event e, int expected) {
    if (expected < 1 || expected > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (e.identity.revision != expected) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (expected == CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  CalendarEventReceipt? _eventReceipt(
    _Event e,
    Iterable<CalendarAuthorizationDecision> decisions, {
    bool deleted = false,
  }) => decisions.every((d) => d.discloseMutationReceipt)
      ? CalendarEventReceipt(
          eventId: e.identity.id!,
          calendarId: e.identity.calendarId,
          revision: e.identity.revision,
          deleted: deleted,
        )
      : null;
  CalendarEventView _eventView(
    _Event e,
    Set<CalendarEventFieldGroup> requested,
    CalendarAuthorizationDecision decision,
  ) {
    final groups =
        requested.intersection(decision.eventDisclosedGroups).toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    bool has(CalendarEventFieldGroup g) => groups.contains(g);
    final v = e.data.content;
    final filteredOverrides = eventDisclosedOverrides(
      e.data.timingOverrides,
      groups.toSet(),
    );
    final visibleComponents = {
      for (final s
          in filteredOverrides?.singles ?? <CalendarEventSingleOverride>[])
        eventComponentKey(s.originalStart, false),
      for (final s
          in filteredOverrides?.future ?? <CalendarEventFutureOverride>[])
        eventComponentKey(s.originalStart, true),
    };
    final time = e.data.updatedAt.toUtc();
    return CalendarEventView(
      id: e.identity.id!,
      calendarId: e.identity.calendarId,
      revision: e.identity.revision,
      disclosedGroups: groups,
      summary: has(CalendarEventFieldGroup.summary) ? v.summary : null,
      description: has(CalendarEventFieldGroup.description)
          ? v.description
          : null,
      location: has(CalendarEventFieldGroup.location) ? v.location : null,
      timing: has(CalendarEventFieldGroup.timing) ? v.timing : null,
      recurrence: has(CalendarEventFieldGroup.timing) ? v.recurrence : null,
      timingOverrides: has(CalendarEventFieldGroup.timing)
          ? filteredOverrides
          : null,
      periods: has(CalendarEventFieldGroup.timing) ? v.periods : null,
      textParameters:
          has(CalendarEventFieldGroup.summary) ||
              has(CalendarEventFieldGroup.description) ||
              has(CalendarEventFieldGroup.location)
          ? CalendarEventTextParameters(
              summary: has(CalendarEventFieldGroup.summary)
                  ? v.textParameters?.summary
                  : null,
              description: has(CalendarEventFieldGroup.description)
                  ? v.textParameters?.description
                  : null,
              location: has(CalendarEventFieldGroup.location)
                  ? v.textParameters?.location
                  : null,
            )
          : null,
      statusPresent: has(CalendarEventFieldGroup.state)
          ? e.data.protocolState!.statusPresent
          : null,
      transparencyPresent: has(CalendarEventFieldGroup.state)
          ? e.data.protocolState!.transparencyPresent
          : null,
      protocolVersion: has(CalendarEventFieldGroup.protocolIdentity)
          ? e.data.protocolState!.version
          : null,
      occurrenceProtocolVersions:
          has(CalendarEventFieldGroup.protocolIdentity) &&
              has(CalendarEventFieldGroup.timing)
          ? [
              for (final p in e.data.protocolState!.overrides)
                if (visibleComponents.contains(
                  eventComponentKey(p.originalStart, p.isThisAndFuture),
                ))
                  CalendarEventOccurrenceProtocolVersion(
                    originalStart: p.originalStart,
                    isThisAndFuture: p.isThisAndFuture,
                    version: p.version,
                  ),
            ]
          : null,
      status: has(CalendarEventFieldGroup.state) ? v.status : null,
      transparency: has(CalendarEventFieldGroup.state) ? v.transparency : null,
      protocolUid: has(CalendarEventFieldGroup.protocolIdentity)
          ? e.data.protocolUid.toString()
          : null,
      lastModified: has(CalendarEventFieldGroup.protocolIdentity)
          ? DateTime.utc(
              time.year,
              time.month,
              time.day,
              time.hour,
              time.minute,
              time.second,
            )
          : null,
    );
  }

  Future<String> _newEventUid(UuidValue calendar, Transaction tx) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      final uid = const Uuid().v4();
      final candidates = await CalendarEventDataRecord.db.find(
        _session,
        where: (t) =>
            t.calendarId.equals(calendar) &
            t.uidDigest.equals(eventUidDigest(uid)),
        limit: _options.maxScannedEvents + 1,
        transaction: tx,
      );
      if (candidates.length > _options.maxScannedEvents) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (!eventUidConflicts(uid, candidates.map((v) => v.protocolUid))) {
        return uid;
      }
    }
    throw _failure(CalendarFailureCode.unavailable);
  }

  Future<CalendarEventReceipt?> createEvent(
    CalendarEventCreateRequest input,
  ) async {
    final content = _validatedEvent(input.content);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final now = await _revisionTime(tx);
      final state = eventProtocolBaseline(content, null, now, now);
      final protocolUid = await _newEventUid(input.calendarId, tx);
      final requests = [
        _er(
          parent,
          CalendarPermission.createEvent,
          proposed: content,
          proposedState: state,
        ),
        if (content.status == CalendarEventStatus.cancelled)
          _er(
            parent,
            CalendarPermission.changeEventStatus,
            proposed: content,
            proposedState: state,
          ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, requests, tx);
      final identity = await CalendarEventRecord.db.insertRow(
        _session,
        CalendarEventRecord(calendarId: input.calendarId, revision: 1),
        transaction: tx,
      );
      final data = await CalendarEventDataRecord.db.insertRow(
        _session,
        CalendarEventDataRecord(
          eventId: identity.id!,
          calendarId: input.calendarId,
          origin: CalendarEventOrigin.native,
          protocolUid: protocolUid,
          uidDigest: eventUidDigest(protocolUid),
          protocolState: state,
          content: content,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await _bump(scope, tx, publishedEventCalendar: input.calendarId);
      return _eventReceipt(_Event(identity, data, parent), decisions.values);
    });
  }

  Future<CalendarEventView> getEvent(
    UuidValue id,
    List<CalendarEventFieldGroup> requested,
  ) async {
    final groups = _egroups(requested);
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final e = await _event(c, id, tx);
      final request = _er(
        e.parent,
        CalendarPermission.readEvent,
        event: e,
        groups: groups,
      );
      final decisions = await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _verifyContext(c);
      return _eventView(e, groups, decisions[request.key]!);
    });
  }

  Future<CalendarEventReceipt?> updateEvent(
    CalendarEventUpdateRequest input,
  ) async {
    return _changeEvent(
      input.eventId,
      input.expectedRevision,
      content: input.content,
      replaceRecurrenceDates: input.replaceRecurrenceDates,
      replacePeriods: input.replacePeriods,
      replaceTextParameters: input.replaceTextParameters,
    );
  }

  Future<CalendarEventReceipt?> changeEventStatus(
    CalendarEventStatusRequest input,
  ) =>
      _changeEvent(input.eventId, input.expectedRevision, status: input.status);
  Future<CalendarEventReceipt?> _changeEvent(
    UuidValue id,
    int expected, {
    CalendarEventContent? content,
    CalendarEventStatus? status,
    bool replaceRecurrenceDates = false,
    bool replacePeriods = false,
    bool replaceTextParameters = false,
  }) async {
    if (content != null) content = _validatedEvent(content);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, id, tx);
      var value = content ?? e.data.content.copyWith(status: status);
      if (content != null && !replaceRecurrenceDates) {
        final old = e.data.content.recurrence;
        // Pattern-only edits cannot discard explicit dates. Explicit replacement
        // is opt-in; the complete merged proposal is validated and authorized.
        if (old != null &&
            (old.inclusions.isNotEmpty || old.exclusions.isNotEmpty)) {
          final supplied = content.recurrence;
          bool same(List<CalendarEventTiming> a, List<CalendarEventTiming> b) =>
              jsonEncode(a.map((v) => v.toJson()).toList()) ==
              jsonEncode(b.map((v) => v.toJson()).toList());
          if (supplied != null &&
              ((supplied.inclusions.isNotEmpty &&
                      !same(supplied.inclusions, old.inclusions)) ||
                  (supplied.exclusions.isNotEmpty &&
                      !same(supplied.exclusions, old.exclusions)))) {
            throw _failure(CalendarFailureCode.validation);
          }
          value = content.copyWith(
            recurrence: CalendarEventRecurrence(
              rule: supplied?.rule,
              inclusions: old.inclusions,
              exclusions: old.exclusions,
            ),
          );
        }
      }
      if (content != null) {
        if (!replacePeriods) {
          if (content.periods != null &&
              jsonEncode(content.periods!.map((p) => p.toJson()).toList()) !=
                  jsonEncode(
                    e.data.content.periods?.map((p) => p.toJson()).toList(),
                  )) {
            throw _failure(CalendarFailureCode.validation);
          }
          value = value.copyWith(periods: e.data.content.periods);
        }
        if (!replaceTextParameters) {
          if (content.textParameters != null &&
              jsonEncode(content.textParameters?.toJson()) !=
                  jsonEncode(e.data.content.textParameters?.toJson())) {
            throw _failure(CalendarFailureCode.validation);
          }
          value = value.copyWith(textParameters: e.data.content.textParameters);
        }
      }
      value = _validatedEvent(value);
      List<CalendarAuthorizationRequest> requests([
        CalendarEventProtocolState? state,
      ]) => [
        if (content != null)
          _er(
            e.parent,
            CalendarPermission.updateEvent,
            event: e,
            proposed: value,
            proposedState: state,
            proposedOverrides: e.data.timingOverrides,
          ),
        if (status != null || value.status != e.data.content.status)
          _er(
            e.parent,
            CalendarPermission.changeEventStatus,
            event: e,
            proposed: value,
            proposedState: state,
            proposedOverrides: e.data.timingOverrides,
          ),
      ];
      await _decide(
        c,
        requests(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, expected);
      if (value.recurrence != null) {
        await _rejectSchedulingBinding(e.identity.id!, tx);
      }
      final overrides = _validatedOverrides(value, e.data.timingOverrides);
      final now = await _revisionTime(tx, previous: e.data.updatedAt);
      final state = _eventProtocolValue(
        () => advanceEventProtocol(
          e.data.protocolState!,
          e.data.content,
          e.data.timingOverrides,
          value,
          overrides,
          now,
        ),
      );
      await _decide(
        c,
        requests(state),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, requests(state), tx);
      final publicationChanged =
          jsonEncode(e.data.protocolState!.toJson()) !=
          jsonEncode(state.toJson());
      e.data.protocolState = state;
      e.data.timingOverrides = overrides;
      e.data.content = value;
      e.data.updatedAt = now;
      e.identity.revision++;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        e.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(
        scope,
        tx,
        publishedEventCalendar: publicationChanged
            ? e.identity.calendarId
            : null,
      );
      return _eventReceipt(e, decisions.values);
    });
  }

  Future<CalendarEventReceipt?> changeOccurrence(
    CalendarEventOccurrenceChange input,
  ) async {
    // Nested request values have scalar immutable fields, no caller-owned lists.
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, input.eventId, tx);
      final lifecycle =
          input.action == CalendarEventOccurrenceAction.cancelSingle ||
          input.action == CalendarEventOccurrenceAction.restoreSingle;
      final operation = lifecycle
          ? CalendarPermission.changeEventStatus
          : CalendarPermission.updateEvent;
      CalendarAuthorizationRequest request(
        CalendarEventTimingOverrides? proposed, [
        CalendarEventProtocolState? state,
      ]) => _er(
        e.parent,
        operation,
        event: e,
        change: input,
        proposedOverrides: proposed,
        proposedState: state,
      );
      await _decide(
        c,
        [request(null)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, input.expectedRevision);
      late final CalendarEventTimingOverrides? proposed;
      try {
        proposed = changeEventOverrides(
          e.data.content,
          e.data.timingOverrides,
          input,
        );
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      } on ArgumentError {
        throw _failure(CalendarFailureCode.validation);
      } on ZoneCoverageException {
        throw _failure(CalendarFailureCode.validation);
      }
      final now = await _revisionTime(tx, previous: e.data.updatedAt);
      final state = _eventProtocolValue(
        () => advanceEventProtocol(
          e.data.protocolState!,
          e.data.content,
          e.data.timingOverrides,
          e.data.content,
          proposed,
          now,
        ),
      );
      await _decide(
        c,
        [request(proposed, state)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request(proposed, state)], tx);
      final publicationChanged =
          jsonEncode(e.data.protocolState!.toJson()) !=
          jsonEncode(state.toJson());
      e.data.protocolState = state;
      e.data.timingOverrides = proposed;
      e.data.updatedAt = now;
      e.identity.revision++;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        e.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(
        scope,
        tx,
        publishedEventCalendar: publicationChanged
            ? e.identity.calendarId
            : null,
      );
      return _eventReceipt(e, decisions.values);
    });
  }

  Future<CalendarEventReceipt?> deleteEvent(UuidValue id, int expected) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, id, tx);
      final requests = [
        _er(e.parent, CalendarPermission.deleteEvent, event: e),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, expected);
      final decisions = await _final(c, requests, tx);
      await _rejectSchedulingBinding(id, tx);
      await _deleteParentAlarms(
        c.scopeKey,
        CalendarAlarmParentKind.event,
        id,
        tx,
      );
      await CalendarEventDataRecord.db.deleteRow(
        _session,
        e.data,
        transaction: tx,
      );
      e.identity.revision++;
      e.identity.deletedAt = await _revisionTime(tx);
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(scope, tx, publishedEventCalendar: e.identity.calendarId);
      return _eventReceipt(e, decisions.values, deleted: true);
    });
  }

  Future<CalendarEventOccurrencePreview> previewOccurrences(
    CalendarEventOccurrenceQuery query,
  ) async {
    final extra = List<CalendarEventFieldGroup>.unmodifiable(
      query.fieldGroups ?? const <CalendarEventFieldGroup>[],
    );
    if (extra.length > 3 || !eventOccurrenceContentGroups.containsAll(extra)) {
      throw _failure(CalendarFailureCode.validation);
    }
    query = query.copyWith(fieldGroups: List.unmodifiable(extra));
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final e = await _event(c, query.eventId, tx);
      final groups = {CalendarEventFieldGroup.timing, ...extra};
      final requests = [
        _er(
          e.parent,
          CalendarPermission.readEvent,
          event: e,
          groups: groups,
          query: query,
        ),
        _er(
          e.parent,
          CalendarPermission.previewEventOccurrences,
          event: e,
          groups: groups,
          query: query,
        ),
      ];
      final decisions = await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.read,
      );
      if (decisions.values.any(
        (d) => !d.eventDisclosedGroups.containsAll(groups),
      )) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      if (query.expectedRevision < 1 ||
          query.expectedRevision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (query.expectedRevision != e.identity.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      late final CalendarEventOccurrencePreview result;
      try {
        result = previewEventOccurrences(
          e.data.content,
          query,
          overrides: e.data.timingOverrides,
        );
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      } on ArgumentError {
        throw _failure(CalendarFailureCode.validation);
      } on ZoneCoverageException {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _verifyContext(c);
      return result;
    });
  }

  Future<CalendarEventPage> listEvents(
    UuidValue calendarId, {
    required int pageSize,
    required List<CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) async {
    final groups = _egroups(fieldGroups);
    if (pageSize < 1 || pageSize > _options.maxPageSize) {
      throw _failure(CalendarFailureCode.validation);
    }
    final canonical = groups.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, calendarId, tx);
      await _decide(
        c,
        [_er(parent, CalendarPermission.listEvents, groups: groups)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final plan = await _bounded(
        () => _runtime.policy.planEventQuery(
          _session,
          c,
          parent.snapshot,
          groups,
        ),
      );
      if ((plan.eventIds?.length ?? 0) > _options.maxScannedEvents) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      UuidValue? after;
      if (cursor != null) {
        if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        final saved = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (t) => t.token.equals(cursor),
          transaction: tx,
        );
        if (saved == null ||
            saved.alarmActivityId != null ||
            saved.alarmActivityKind != null ||
            saved.taskHistoryTaskId != null ||
            saved.taskHistoryOriginalKey != null ||
            saved.taskHistoryAfterRevision != null ||
            saved.taskCalendarId != null ||
            saved.taskFieldGroups != null ||
            saved.eventCalendarId != calendarId ||
            saved.scopeKey != c.scopeKey ||
            saved.principalId != c.principalId ||
            saved.policyRevision != c.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != pageSize ||
            !saved.expiresAt.isAfter(DateTime.now().toUtc()) ||
            saved.eventFieldGroups == null ||
            saved.eventFieldGroups!.length != canonical.length ||
            !Iterable<int>.generate(canonical.length)
                .every((i) => saved.eventFieldGroups![i] == canonical[i])) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final visible = <CalendarEventView>[];
      var scanned = 0;
      while (visible.length <= pageSize) {
        final rows = await CalendarEventRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(calendarId) &
              t.deletedAt.equals(null) &
              (after == null ? Constant.bool(true) : t.id > after),
          orderBy: (t) => t.id,
          limit: _options.policyBatchSize,
          transaction: tx,
        );
        if (rows.isEmpty) break;
        final active = <_Event>[];
        for (final row in rows) {
          if (++scanned > _options.maxScannedEvents) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          if (plan.eventIds != null && !plan.eventIds!.contains(row.id)) {
            continue;
          }
          active.add(
            await _event(c, row.id!, tx, identity: row, parent: parent),
          );
        }
        if (active.isNotEmpty) {
          final requests = [
            for (final e in active)
              _er(
                parent,
                CalendarPermission.readEvent,
                event: e,
                groups: groups,
              ),
          ];
          final decisions = await _decide(
            c,
            requests,
            tx,
            CalendarAuthorizationPhase.read,
            filterDenied: true,
          );
          for (final e in active) {
            final key = '${CalendarPermission.readEvent.name}:${e.identity.id}';
            final decision = decisions[key]!;
            if (decision.verdict == CalendarAuthorizationVerdict.allow) {
              visible.add(_eventView(e, groups, decision));
            }
            if (visible.length > pageSize) break;
          }
        }
        after = rows.last.id;
      }
      await _verifyContext(c);
      String? continuation;
      if (visible.length > pageSize) {
        final expired = await CalendarCursorRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(c.scopeKey) &
              (t.expiresAt < DateTime.now().toUtc()),
          limit: _options.maxCursorsPerScope,
          transaction: tx,
        );
        if (expired.isNotEmpty) {
          await CalendarCursorRecord.db.delete(
            _session,
            expired,
            transaction: tx,
          );
        }
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(c.scopeKey),
              transaction: tx,
              limit: _options.maxCursorsPerScope,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final random = Random.secure();
        continuation = base64UrlEncode(
          List.generate(32, (_) => random.nextInt(256)),
        ).replaceAll('=', '');
        await CalendarCursorRecord.db.insertRow(
          _session,
          CalendarCursorRecord(
            token: continuation,
            scopeKey: c.scopeKey,
            principalId: c.principalId,
            policyRevision: c.policyRevision,
            dataRevision: scope.revision,
            afterId: visible[pageSize - 1].id,
            pageSize: pageSize,
            fieldGroups: [],
            eventCalendarId: calendarId,
            eventFieldGroups: canonical,
            expiresAt: DateTime.now().toUtc().add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return CalendarEventPage(
        events: visible.take(pageSize).toList(),
        nextCursor: continuation,
      );
    });
  }
}
