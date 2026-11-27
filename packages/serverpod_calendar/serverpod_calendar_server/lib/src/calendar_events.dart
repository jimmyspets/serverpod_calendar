part of 'calendar_module.dart';

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

final class _Event {
  _Event(this.identity, this.data, this.parent) {
    try {
      data.content = validateEventContent(data.content);
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
    CalendarEventOccurrenceQuery? query,
    Set<CalendarEventFieldGroup> groups = const {},
  }) => CalendarAuthorizationRequest(
    key: '${op.name}:${event?.identity.id ?? parent.identity.id}',
    operation: op,
    calendarId: parent.identity.id,
    current: parent.snapshot,
    eventId: event?.identity.id,
    currentEvent: event?.snapshot,
    proposedEvent: proposed,
    occurrenceQuery: query,
    eventGroups: groups,
  );

  Future<_Event> _event(
    CalendarHostContext c,
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
    if (identity == null || identity.deletedAt != null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    parent ??= await _active(c, identity.calendarId, tx);
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

  Future<CalendarEventReceipt?> createEvent(
    CalendarEventCreateRequest input,
  ) async {
    final content = _validatedEvent(input.content);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final requests = [
        _er(parent, CalendarPermission.createEvent, proposed: content),
        if (content.status == CalendarEventStatus.cancelled)
          _er(parent, CalendarPermission.changeEventStatus, proposed: content),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, requests, tx);
      final now = await _revisionTime(tx);
      final identity = await CalendarEventRecord.db.insertRow(
        _session,
        CalendarEventRecord(calendarId: input.calendarId, revision: 1),
        transaction: tx,
      );
      final data = await CalendarEventDataRecord.db.insertRow(
        _session,
        CalendarEventDataRecord(
          eventId: identity.id!,
          content: content,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await _bump(scope, tx);
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
      value = _validatedEvent(value);
      final requests = [
        if (content != null)
          _er(
            e.parent,
            CalendarPermission.updateEvent,
            event: e,
            proposed: value,
          ),
        if (status != null || value.status != e.data.content.status)
          _er(
            e.parent,
            CalendarPermission.changeEventStatus,
            event: e,
            proposed: value,
          ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _eventRevision(e, expected);
      final decisions = await _final(c, requests, tx);
      e.data.content = value;
      e.data.updatedAt = await _revisionTime(tx, previous: e.data.updatedAt);
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
      await _bump(scope, tx);
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
      await _bump(scope, tx);
      return _eventReceipt(e, decisions.values, deleted: true);
    });
  }

  Future<CalendarEventOccurrencePreview> previewOccurrences(
    CalendarEventOccurrenceQuery query,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final e = await _event(c, query.eventId, tx);
      const groups = {CalendarEventFieldGroup.timing};
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
        (d) => !d.eventDisclosedGroups.contains(CalendarEventFieldGroup.timing),
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
        result = previewEventOccurrences(e.data.content, query);
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
