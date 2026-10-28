part of 'calendar_module.dart';

/// Server-only policy input. Source data and addresses never grant authority.
final class CalendarPublicationSource {
  const CalendarPublicationSource(this.calendar, [this.event]);
  final CalendarPolicySnapshot calendar;
  final CalendarEventPolicySnapshot? event;
}

final class CalendarPublicationRequest {
  CalendarPublicationRequest({
    required this.scopeKey,
    required this.authorityReference,
    required this.selecting,
    required Iterable<CalendarPublicationSource> sources,
  }) : sources = List.unmodifiable(sources);
  final String scopeKey, authorityReference;
  final bool selecting;

  /// Every event field in the complete feed projection must be publishable.
  /// This includes location/GEO, priority and descriptive resources; approval
  /// is independent of whether an authenticated detail query would expose them.
  Set<CalendarEventFieldGroup> get requiredEventGroups =>
      Set.unmodifiable(CalendarEventFieldGroup.values);
  final List<CalendarPublicationSource> sources;
}

/// Hosts approve the complete publication projection, including source metadata.
/// For selecting requests, also validate the authenticated management actor.
/// For reads, resolve current authority from the opaque stored reference.
abstract interface class CalendarPublicationPolicy {
  CalendarAuthorizationGuarantee get guarantee;
  Future<bool> authorizePublication(
    Session session,
    CalendarPublicationRequest request,
    Transaction transaction, {
    required bool finalCheck,
  });
}

/// Optional modules track actual event changes in the same locked transaction.
/// Implement together with CalendarDependencyProvider and register once.
abstract interface class CalendarPublicationChangeObserver {
  Future<void> eventsChanged(
    Session session,
    String scopeKey,
    UuidValue calendarId,
    Transaction transaction,
  );
}

/// Valid only during the callback supplied to the server-only transaction port.
/// The exposed transaction is for optional-module storage, never core tables.
final class CalendarPublicationTransaction {
  CalendarPublicationTransaction._(this._service, this._scopeKey, this._tx);
  final CalendarService _service;
  final String _scopeKey;
  final Transaction _tx;
  final _checks = <CalendarPublicationRequest>[];
  bool _open = true;

  Transaction get transaction {
    if (!_open) throw StateError('Publication transaction is closed');
    return _tx;
  }

  Future<DateTime> databaseTime() => _service._revisionTime(transaction);

  Future<void> _authorize(
    CalendarPublicationRequest request, {
    required bool finalCheck,
  }) async {
    final policy = _service._runtime.publicationPolicy;
    if (policy == null ||
        !await _service._bounded(
          () => policy.authorizePublication(
            _service._session,
            request,
            transaction,
            finalCheck: finalCheck,
          ),
        )) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
  }

  Future<List<_Active>> _calendars(List<UuidValue> ids) async {
    if (ids.isEmpty || ids.length > 16 || ids.toSet().length != ids.length) {
      throw _failure(CalendarFailureCode.validation);
    }
    final result = <_Active>[];
    for (final id in ids) {
      result.add(await _service._activeInScope(_scopeKey, id, transaction));
    }
    return result;
  }

  Future<void> requireSelection(
    List<UuidValue> calendarIds,
    String authorityReference,
  ) async {
    if (_service._session.authenticated == null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    _service._opaque(authorityReference);
    final calendars = await _calendars(calendarIds);
    final request = CalendarPublicationRequest(
      scopeKey: _scopeKey,
      authorityReference: authorityReference,
      selecting: true,
      sources: calendars.map((c) => CalendarPublicationSource(c.snapshot)),
    );
    await _authorize(request, finalCheck: false);
    _checks.add(request);
  }

  Future<Uint8List> eventBytes(
    List<UuidValue> calendarIds,
    String authorityReference,
  ) async {
    _service._opaque(authorityReference);
    final calendars = await _calendars(calendarIds);
    final calendarSources = calendars
        .map((c) => CalendarPublicationSource(c.snapshot))
        .toList();
    final calendarRequest = CalendarPublicationRequest(
      scopeKey: _scopeKey,
      authorityReference: authorityReference,
      selecting: false,
      sources: calendarSources,
    );
    await _authorize(calendarRequest, finalCheck: false);
    final events = <CalendarEventPolicySnapshot>[];
    final sources = [...calendarSources];
    for (final calendar in calendars) {
      final remaining = _service._options.maxScannedEvents - events.length;
      final identities = await CalendarEventRecord.db.find(
        _service._session,
        where: (t) =>
            t.calendarId.equals(calendar.identity.id!) &
            t.deletedAt.equals(null),
        limit: remaining + 1,
        transaction: transaction,
      );
      if (identities.length > remaining) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      for (final identity in identities) {
        final event = await _service._eventInScope(
          _scopeKey,
          identity.id!,
          transaction,
          identity: identity,
          parent: calendar,
        );
        events.add(event.snapshot);
        sources.add(
          CalendarPublicationSource(calendar.snapshot, event.snapshot),
        );
      }
    }
    final request = CalendarPublicationRequest(
      scopeKey: _scopeKey,
      authorityReference: authorityReference,
      selecting: false,
      sources: sources,
    );
    await _authorize(request, finalCheck: false);
    _checks.add(request);
    try {
      return eventPublicationBytes(events);
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } on IcalendarSyntaxException catch (e) {
      throw _failure(
        e.kind == IcalendarSyntaxError.limitExceeded
            ? CalendarFailureCode.limitExceeded
            : CalendarFailureCode.validation,
      );
    } on IcalendarComponentException catch (e) {
      throw _failure(
        e.kind == IcalendarComponentError.limitExceeded
            ? CalendarFailureCode.limitExceeded
            : CalendarFailureCode.validation,
      );
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
  }
}
