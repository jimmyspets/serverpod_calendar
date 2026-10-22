part of 'calendar_module.dart';

CalendarAvailabilityContent _validatedAvailability(
  CalendarAvailabilityContent v,
) {
  try {
    return validateAvailabilityContent(v);
  } on AvailabilityLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  }
}

T _availabilityValue<T>(T Function() value) {
  try {
    return value();
  } on AvailabilityLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  }
}

final class _Availability {
  _Availability(this.identity, this.data, this.parent) {
    try {
      data.content = validateAvailabilityContent(data.content);
      data.timingOverrides = validateAvailabilityEdits(
        data.content,
        data.timingOverrides,
      );
      data.protocolState = validateAvailabilityProtocolState(
        data.protocolState ??
            availabilityProtocolBaseline(
              data.content,
              data.createdAt,
              data.updatedAt,
              legacy: true,
            ),
        data.content,
        edits: data.timingOverrides,
      );
      validateAvailabilityUid(data.protocolUid);
      if (data.calendarId != identity.calendarId ||
          data.uidDigest != availabilityUidDigest(data.protocolUid)) {
        throw StateError('Invalid active protocol identity');
      }
      if (data.content.openings.any(
        (o) => o.uid == null || o.protocolUid == null,
      )) {
        throw StateError('Persisted opening lacks identity');
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
  final CalendarAvailabilityRecord identity;
  final CalendarAvailabilityDataRecord data;
  final _Active parent;
  CalendarAvailabilityPolicySnapshot get snapshot =>
      CalendarAvailabilityPolicySnapshot(
        identity.id!,
        identity.calendarId,
        identity.revision,
        data.content,
        data.protocolUid,
        data.updatedAt,
        timingOverrides: data.timingOverrides,
        protocolState: data.protocolState!,
      );
  CalendarAvailabilityView get view => CalendarAvailabilityView(
    id: identity.id!,
    calendarId: identity.calendarId,
    revision: identity.revision,
    protocolUid: data.protocolUid,
    lastModified: data.protocolState!.lastModified,
    protocolState: data.protocolState!,
    content: data.content,
    timingOverrides: data.timingOverrides,
  );
}

extension CalendarAvailabilityOperations on CalendarService {
  CalendarAuthorizationRequest _ar(
    _Active parent,
    CalendarPermission operation, {
    _Availability? rule,
    CalendarAvailabilityContent? proposed,
    CalendarFreeBusyQuery? query,
    CalendarAvailabilitySearchQuery? search,
    CalendarAvailabilityTarget? target,
    CalendarAvailabilityOccurrenceChange? change,
    CalendarAvailabilityOccurrenceQuery? occurrenceQuery,
    List<CalendarAvailabilityOpeningEdits>? edits,
    String? category,
    CalendarAvailabilityProtocolState? protocol,
  }) => CalendarAuthorizationRequest(
    key: '${operation.name}:${rule?.identity.id ?? parent.identity.id}',
    operation: operation,
    calendarId: parent.identity.id,
    current: parent.snapshot,
    availabilityId: rule?.identity.id,
    currentAvailability: rule?.snapshot,
    proposedAvailability: proposed,
    freeBusyQuery: query,
    availabilitySearchQuery: search,
    availabilityTarget: target,
    availabilityOccurrenceChange: change,
    availabilityOccurrenceQuery: occurrenceQuery,
    proposedAvailabilityEdits: edits,
    proposedAvailabilityProtocolState: protocol,
    availabilityCategoryFilter: category,
  );

  Future<_Availability> _availability(
    CalendarHostContext c,
    UuidValue id,
    Transaction tx, {
    _Active? parent,
    CalendarAvailabilityRecord? identity,
  }) async {
    identity ??= await CalendarAvailabilityRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (identity == null || identity.deletedAt != null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    parent ??= await _active(c, identity.calendarId, tx);
    final data = await CalendarAvailabilityDataRecord.db.findFirstRow(
      _session,
      where: (t) => t.availabilityId.equals(id),
      transaction: tx,
    );
    if (data == null) throw _failure(CalendarFailureCode.unavailable);
    return _Availability(identity, data, parent);
  }

  CalendarAvailabilityReceipt? _availabilityReceipt(
    _Availability rule,
    Iterable<CalendarAuthorizationDecision> decisions, {
    bool deleted = false,
  }) => decisions.every((d) => d.discloseMutationReceipt)
      ? CalendarAvailabilityReceipt(
          availabilityId: rule.identity.id!,
          calendarId: rule.identity.calendarId,
          revision: rule.identity.revision,
          deleted: deleted,
        )
      : null;

  void _availabilityRevision(_Availability rule, int expected) {
    if (expected < 1 || expected > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (expected != rule.identity.revision) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (expected == CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  CalendarAvailabilityContent _openingIdentities(
    CalendarAvailabilityContent v, {
    CalendarAvailabilityContent? previous,
  }) {
    final existing = {
      for (final o in previous?.openings ?? <CalendarAvailabilityOpening>[])
        o.uid,
    };
    for (final o in v.openings) {
      if (o.uid != null && !existing.contains(o.uid)) {
        throw _failure(CalendarFailureCode.validation);
      }
    }
    List<CalendarAvailabilityText>? retainContacts(
      List<CalendarAvailabilityText>? proposed,
      List<CalendarAvailabilityText>? current,
    ) {
      if (proposed != null &&
          jsonEncode(proposed.map((v) => v.toJson()).toList()) !=
              jsonEncode(
                (current ?? <CalendarAvailabilityText>[])
                    .map((v) => v.toJson())
                    .toList(),
              )) {
        throw _failure(CalendarFailureCode.validation);
      }
      return current;
    }

    List<CalendarAvailabilityCategoryGroup>? retainGroups(
      List<CalendarAvailabilityCategoryGroup>? proposed,
      List<String>? nativeCategories,
      CalendarAvailabilityTextParameters? parameters,
      List<CalendarAvailabilityCategoryGroup>? current,
    ) {
      if (proposed != null || current == null) return proposed;
      if ((nativeCategories?.isNotEmpty ?? false) ||
          parameters?.categoryLanguage != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      return current;
    }

    return _validatedAvailability(
      v.copyWith(
        categoryGroups: retainGroups(
          v.categoryGroups,
          v.categories,
          v.textParameters,
          previous?.categoryGroups,
        ),
        contacts: retainContacts(v.contacts, previous?.contacts),
        openings: List.unmodifiable([
          for (final o in v.openings)
            (() {
              final old = previous?.openings
                  .where((v) => v.uid == o.uid)
                  .firstOrNull;
              if (o.protocolUid != null && o.protocolUid != old?.protocolUid) {
                throw _failure(CalendarFailureCode.validation);
              }
              final id = o.uid ?? const Uuid().v4obj();
              return o.copyWith(
                uid: id,
                protocolUid: old?.protocolUid ?? id.toString(),
                contacts: retainContacts(o.contacts, old?.contacts),
                categoryGroups: retainGroups(
                  o.categoryGroups,
                  o.categories,
                  o.textParameters,
                  old?.categoryGroups,
                ),
                periods: o.periods ?? old?.periods,
              );
            })(),
        ]),
      ),
    );
  }

  Future<void> _approveAvailabilityMetadata(
    CalendarHostContext c,
    CalendarAuthorizationRequest request,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final proposed = request.proposedAvailability!;
    for (final source in [
      (CalendarAvailabilityExtensionContext.definition, proposed.extensions),
      for (final o in proposed.openings)
        (CalendarAvailabilityExtensionContext.opening, o.extensions),
    ]) {
      for (final value in source.$2 ?? <CalendarAvailabilityExtension>[]) {
        final registration =
            _runtime.availabilityExtensions[value.name.toUpperCase()];
        if (registration == null ||
            !registration.contexts.contains(source.$1)) {
          throw _failure(CalendarFailureCode.validation);
        }
        final valid = await _bounded(
          () async => registration.validate(value.value),
        );
        if (!valid) throw _failure(CalendarFailureCode.validation);
      }
    }
    if (proposed.organizer != null ||
        request.currentAvailability?.content.organizer != null) {
      final verdict = await _bounded(
        () => _runtime.policy.approveAvailabilityOrganizer(
          _session,
          c,
          request,
          tx,
          phase,
        ),
      );
      if (verdict != CalendarAuthorizationVerdict.allow) {
        throw _failure(
          verdict == CalendarAuthorizationVerdict.deny
              ? CalendarFailureCode.accessDenied
              : CalendarFailureCode.unavailable,
        );
      }
    }
    if (phase == CalendarAuthorizationPhase.finalWrite) await _verifyContext(c);
  }

  Future<CalendarAvailabilityReceipt?> createAvailability(
    CalendarAvailabilityCreateRequest input,
  ) async {
    final proposed = _openingIdentities(input.content);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final request = _ar(
        parent,
        CalendarPermission.createAvailability,
        proposed: proposed,
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (await CalendarAvailabilityRecord.db.count(
            _session,
            where: (t) =>
                t.calendarId.equals(input.calendarId) &
                t.deletedAt.equals(null),
            transaction: tx,
            limit: availabilityMaxDefinitions,
          ) >=
          availabilityMaxDefinitions) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      await _approveAvailabilityMetadata(
        c,
        request,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final now = await _revisionTime(tx);
      final protocol = availabilityProtocolBaseline(proposed, now, now);
      final finalRequest = _ar(
        parent,
        CalendarPermission.createAvailability,
        proposed: proposed,
        protocol: protocol,
      );
      final decisions = await _final(c, [finalRequest], tx);
      await _approveAvailabilityMetadata(
        c,
        finalRequest,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final identity = await CalendarAvailabilityRecord.db.insertRow(
        _session,
        CalendarAvailabilityRecord(calendarId: input.calendarId, revision: 1),
        transaction: tx,
      );
      final uid = const Uuid().v4();
      final digest = availabilityUidDigest(uid);
      final candidates = await CalendarAvailabilityDataRecord.db.find(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) & t.uidDigest.equals(digest),
        transaction: tx,
        limit: availabilityMaxDefinitions + 1,
      );
      if (candidates.length > availabilityMaxDefinitions) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (availabilityUidConflicts(uid, candidates.map((v) => v.protocolUid))) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      final data = await CalendarAvailabilityDataRecord.db.insertRow(
        _session,
        CalendarAvailabilityDataRecord(
          availabilityId: identity.id!,
          calendarId: input.calendarId,
          protocolUid: uid,
          uidDigest: digest,
          content: proposed,
          protocolState: protocol,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await _bump(scope, tx);
      return _availabilityReceipt(
        _Availability(identity, data, parent),
        decisions.values,
      );
    });
  }

  Future<CalendarAvailabilityView> getAvailability(UuidValue id) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final rule = await _availability(c, id, tx);
      await _decide(
        c,
        [_ar(rule.parent, CalendarPermission.readAvailability, rule: rule)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _verifyContext(c);
      return rule.view;
    });
  }

  /// A bounded configuration list, not a source of calculation coverage.
  /// Per-object denied rules are omitted; unavailable policy fails the request.
  Future<List<CalendarAvailabilityView>> listAvailability(
    UuidValue calendarId, {
    String? category,
  }) async {
    if (category != null) _availabilityValue(() => IcalendarCategory(category));
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _active(c, calendarId, tx);
      await _decide(
        c,
        [_ar(parent, CalendarPermission.listAvailability, category: category)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final rows = await CalendarAvailabilityRecord.db.find(
        _session,
        where: (t) =>
            t.calendarId.equals(calendarId) & t.deletedAt.equals(null),
        orderBy: (t) => t.id,
        limit: availabilityMaxDefinitions + 1,
        transaction: tx,
      );
      if (rows.length > availabilityMaxDefinitions) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final result = <CalendarAvailabilityView>[];
      for (final row in rows) {
        final rule = await _availability(
          c,
          row.id!,
          tx,
          parent: parent,
          identity: row,
        );
        try {
          await _decide(
            c,
            [
              _ar(
                parent,
                CalendarPermission.readAvailability,
                rule: rule,
                category: category,
              ),
            ],
            tx,
            CalendarAuthorizationPhase.read,
          );
          if (category == null ||
              rule.data.content.categories!.contains(category) ||
              (rule.data.content.categoryGroups?.any(
                    (g) => g.values.contains(category),
                  ) ??
                  false) ||
              rule.data.content.openings.any(
                (o) =>
                    o.categories!.contains(category) ||
                    (o.categoryGroups?.any(
                          (g) => g.values.contains(category),
                        ) ??
                        false),
              )) {
            result.add(rule.view);
          }
        } on CalendarException catch (e) {
          if (e.code != CalendarFailureCode.accessDenied) rethrow;
        }
      }
      await _verifyContext(c);
      return List.unmodifiable(result);
    });
  }

  Future<CalendarAvailabilityReceipt?> updateAvailability(
    CalendarAvailabilityUpdateRequest input,
  ) => _updateAvailability(input);
  Future<CalendarAvailabilityReceipt?> updateAvailabilityMetadata(
    CalendarAvailabilityUpdateRequest input,
  ) => _updateAvailability(input, metadataOnly: true);
  Future<CalendarAvailabilityReceipt?> _updateAvailability(
    CalendarAvailabilityUpdateRequest input, {
    bool metadataOnly = false,
  }) async {
    final value = input.content;
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final rule = await _availability(c, input.availabilityId, tx);
      final readonlyEcho =
          value.contacts != null ||
          value.openings.any(
            (o) => o.contacts != null || o.protocolUid != null,
          );
      if (readonlyEcho) {
        // Equality checks on source-only fields must not be a detail oracle.
        await _decide(
          c,
          [_ar(rule.parent, CalendarPermission.readAvailability, rule: rule)],
          tx,
          CalendarAuthorizationPhase.read,
        );
      }
      final proposed = _openingIdentities(value, previous: rule.data.content);
      final requests = [
        _ar(
          rule.parent,
          metadataOnly
              ? CalendarPermission.updateAvailabilityMetadata
              : CalendarPermission.updateAvailability,
          rule: rule,
          proposed: proposed,
          edits: rule.data.timingOverrides,
        ),
        if (!metadataOnly &&
            jsonEncode(availabilityMetadata(rule.data.content)) !=
                jsonEncode(availabilityMetadata(proposed)))
          _ar(
            rule.parent,
            CalendarPermission.updateAvailabilityMetadata,
            rule: rule,
            proposed: proposed,
            edits: rule.data.timingOverrides,
          ),
        if (readonlyEcho)
          _ar(
            rule.parent,
            CalendarPermission.readAvailability,
            rule: rule,
            proposed: proposed,
            edits: rule.data.timingOverrides,
          ),
      ];
      await _decide(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _availabilityRevision(rule, input.expectedRevision);
      if (metadataOnly &&
          jsonEncode(availabilityStructure(proposed)) !=
              jsonEncode(availabilityStructure(rule.data.content))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final retained = rule.data.timingOverrides
          ?.where(
            (entry) => proposed.openings.any((o) => o.uid == entry.openingUid),
          )
          .toList();
      final edits = _availabilityValue(
        () => validateAvailabilityEdits(proposed, retained),
      );
      final now = await _revisionTime(tx, previous: rule.data.updatedAt);
      final protocol = _availabilityValue(
        () => advanceAvailabilityProtocol(
          rule.data.protocolState!,
          rule.data.content,
          rule.data.timingOverrides,
          proposed,
          edits,
          now,
        ),
      );
      final finalRequests = [
        for (final request in requests)
          _ar(
            rule.parent,
            request.operation,
            rule: rule,
            proposed: proposed,
            edits: edits,
            protocol: protocol,
          ),
      ];
      await _approveAvailabilityMetadata(
        c,
        finalRequests.first,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, finalRequests, tx);
      await _approveAvailabilityMetadata(
        c,
        finalRequests.first,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      rule.data.timingOverrides = edits;
      rule.data.content = proposed;
      rule.data.protocolState = protocol;
      rule.data.updatedAt = now;
      rule.identity.revision++;
      await CalendarAvailabilityDataRecord.db.updateRow(
        _session,
        rule.data,
        transaction: tx,
      );
      await CalendarAvailabilityRecord.db.updateRow(
        _session,
        rule.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _availabilityReceipt(rule, [
        for (final request in requests)
          if (request.operation != CalendarPermission.readAvailability)
            decisions[request.key]!,
      ]);
    });
  }

  Future<CalendarAvailabilityReceipt?> changeAvailabilityOccurrence(
    CalendarAvailabilityOccurrenceChange input,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final rule = await _availability(c, input.availabilityId, tx);
      CalendarAuthorizationRequest request(
        List<CalendarAvailabilityOpeningEdits>? edits, [
        CalendarAvailabilityProtocolState? protocol,
      ]) => _ar(
        rule.parent,
        CalendarPermission.changeAvailabilityOccurrence,
        rule: rule,
        change: input,
        edits: edits,
        protocol: protocol,
      );
      await _decide(
        c,
        [request(null)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _availabilityRevision(rule, input.expectedRevision);
      final edits = _availabilityValue(
        () => changeAvailabilityEdits(
          rule.data.content,
          rule.data.timingOverrides,
          input,
        ),
      );
      final now = await _revisionTime(tx, previous: rule.data.updatedAt);
      final protocol = _availabilityValue(
        () => advanceAvailabilityProtocol(
          rule.data.protocolState!,
          rule.data.content,
          rule.data.timingOverrides,
          rule.data.content,
          edits,
          now,
        ),
      );
      final decisions = await _final(c, [request(edits, protocol)], tx);
      rule.data.timingOverrides = edits;
      rule.data.protocolState = protocol;
      rule.data.updatedAt = now;
      rule.identity.revision++;
      await CalendarAvailabilityDataRecord.db.updateRow(
        _session,
        rule.data,
        transaction: tx,
      );
      await CalendarAvailabilityRecord.db.updateRow(
        _session,
        rule.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _availabilityReceipt(rule, decisions.values);
    });
  }

  Future<CalendarAvailabilityOccurrencePreview> previewAvailabilityOccurrences(
    CalendarAvailabilityOccurrenceQuery input,
  ) async {
    final window = _busyWindow(input.fromUtc, input.untilUtc);
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final rule = await _availability(c, input.availabilityId, tx);
      await _decide(
        c,
        [
          _ar(
            rule.parent,
            CalendarPermission.readAvailability,
            rule: rule,
            occurrenceQuery: input,
          ),
          _ar(
            rule.parent,
            CalendarPermission.previewAvailabilityOccurrences,
            rule: rule,
            occurrenceQuery: input,
          ),
        ],
        tx,
        CalendarAuthorizationPhase.read,
      );
      if (input.expectedRevision != rule.identity.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final preview = _availabilityValue(() {
        final opening = rule.data.content.openings.singleWhere(
          (o) => o.uid == input.openingUid,
          orElse: () => throw ArgumentError('Unknown opening'),
        );
        return previewEventOccurrences(
          openingEvent(opening),
          CalendarEventOccurrenceQuery(
            eventId: rule.identity.id!,
            expectedRevision: input.expectedRevision,
            fromUtc: window.start,
            untilUtc: window.end,
          ),
          overrides: openingEdits(rule.data.timingOverrides, input.openingUid),
          periods: opening.periods,
        );
      });
      await _verifyContext(c);
      return CalendarAvailabilityOccurrencePreview(
        availabilityId: rule.identity.id!,
        openingUid: input.openingUid,
        revision: rule.identity.revision,
        kind: preview.kind,
        zoneId: preview.zoneId,
        occurrences: preview.occurrences,
      );
    });
  }

  Future<CalendarAvailabilityReceipt?> deleteAvailability(
    UuidValue id,
    int expectedRevision,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final rule = await _availability(c, id, tx);
      final request = _ar(
        rule.parent,
        CalendarPermission.deleteAvailability,
        rule: rule,
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _availabilityRevision(rule, expectedRevision);
      final decisions = await _final(c, [request], tx);
      await CalendarAvailabilityDataRecord.db.deleteRow(
        _session,
        rule.data,
        transaction: tx,
      );
      rule.identity.revision++;
      rule.identity.deletedAt = await _revisionTime(tx);
      await CalendarAvailabilityRecord.db.updateRow(
        _session,
        rule.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _availabilityReceipt(rule, decisions.values, deleted: true);
    });
  }
}
