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

final class _Availability {
  _Availability(this.identity, this.data, this.parent) {
    try {
      data.content = validateAvailabilityContent(data.content);
      if (data.content.openings.any((o) => o.uid == null)) {
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
      );
  CalendarAvailabilityView get view => CalendarAvailabilityView(
    id: identity.id!,
    calendarId: identity.calendarId,
    revision: identity.revision,
    protocolUid: data.protocolUid,
    lastModified: DateTime.fromMillisecondsSinceEpoch(
      (data.updatedAt.millisecondsSinceEpoch ~/ 1000) * 1000,
      isUtc: true,
    ),
    content: data.content,
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
    return v.copyWith(
      openings: List.unmodifiable([
        for (final o in v.openings)
          o.uid == null ? o.copyWith(uid: const Uuid().v4obj()) : o,
      ]),
    );
  }

  Future<CalendarAvailabilityReceipt?> createAvailability(
    CalendarAvailabilityCreateRequest input,
  ) async {
    final proposed = _openingIdentities(_validatedAvailability(input.content));
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
      final decisions = await _final(c, [request], tx);
      final now = await _revisionTime(tx);
      final identity = await CalendarAvailabilityRecord.db.insertRow(
        _session,
        CalendarAvailabilityRecord(calendarId: input.calendarId, revision: 1),
        transaction: tx,
      );
      final data = await CalendarAvailabilityDataRecord.db.insertRow(
        _session,
        CalendarAvailabilityDataRecord(
          availabilityId: identity.id!,
          content: proposed,
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
    UuidValue calendarId,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _active(c, calendarId, tx);
      await _decide(
        c,
        [_ar(parent, CalendarPermission.listAvailability)],
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
            [_ar(parent, CalendarPermission.readAvailability, rule: rule)],
            tx,
            CalendarAuthorizationPhase.read,
          );
          result.add(rule.view);
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
  ) async {
    final value = _validatedAvailability(input.content);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final rule = await _availability(c, input.availabilityId, tx);
      final proposed = _openingIdentities(value, previous: rule.data.content);
      final request = _ar(
        rule.parent,
        CalendarPermission.updateAvailability,
        rule: rule,
        proposed: proposed,
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _availabilityRevision(rule, input.expectedRevision);
      final decisions = await _final(c, [request], tx);
      rule.data.content = proposed;
      rule.data.updatedAt = await _revisionTime(
        tx,
        previous: rule.data.updatedAt,
      );
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
