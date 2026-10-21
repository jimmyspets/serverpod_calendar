part of 'calendar_module.dart';

String _targetKey(CalendarAvailabilityTarget t) =>
    jsonEncode([t.namespace, t.kind, t.externalId]);

bool _unknownSearchError(Object e) =>
    e is AvailabilityLimitException ||
    e is RecurrenceLimitException ||
    e is ZoneCoverageException ||
    e is ArgumentError ||
    (e is CalendarException &&
        [
          CalendarFailureCode.accessDenied,
          CalendarFailureCode.unavailable,
          CalendarFailureCode.limitExceeded,
        ].contains(e.code));

extension CalendarAvailabilitySearchOperations on CalendarService {
  CalendarAvailabilitySearchQuery _searchQuery(
    CalendarAvailabilitySearchQuery q,
  ) {
    if (q.targets.isEmpty ||
        q.targets.length > 32 ||
        q.minimumSeconds < 1 ||
        q.minimumSeconds > 2678400) {
      throw _failure(CalendarFailureCode.validation);
    }
    final targets = <String, CalendarAvailabilityTarget>{};
    for (final t in q.targets) {
      _opaque(t.namespace, maxUtf8Bytes: 128);
      _opaque(t.kind, maxUtf8Bytes: 64);
      _opaque(t.externalId, maxUtf8Bytes: 512);
      targets.putIfAbsent(_targetKey(t), () => t);
    }
    if (targets.length > 8) throw _failure(CalendarFailureCode.limitExceeded);
    return q.copyWith(targets: List.unmodifiable(targets.values));
  }

  CalendarAuthorizationRequest _sr(
    CalendarAvailabilitySearchQuery query,
    CalendarAvailabilityTarget target,
  ) => CalendarAuthorizationRequest(
    key: 'readSubjectAvailability:${_targetKey(target)}',
    operation: CalendarPermission.readSubjectAvailability,
    availabilitySearchQuery: query,
    availabilityTarget: target,
  );

  Future<CalendarSubjectResolution> _resolveAvailability(
    CalendarHostContext c,
    CalendarAvailabilityTarget target,
    Transaction tx,
  ) async {
    final resolved = await _bounded(
      () => _runtime.policy.resolveAvailabilitySubject(_session, c, target, tx),
    );
    // Reject raw over-limit input before deduplication.
    if (!resolved.complete ||
        resolved.calendarIds.isEmpty ||
        resolved.calendarIds.length > 8) {
      throw const AvailabilityLimitException(
        'incompleteOrOverLimitContributors',
      );
    }
    try {
      validateCalendarOpaqueText(resolved.revision, maxUtf8Bytes: 512);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final ids = resolved.calendarIds.toSet().toList()
      ..sort((a, b) => a.toString().compareTo(b.toString()));
    return CalendarSubjectResolution(
      complete: true,
      revision: resolved.revision,
      calendarIds: ids,
    );
  }

  List<CalendarAvailabilitySlot> _slots(
    List<AvailabilityInterval> partition,
    int seconds,
  ) => [
    for (final w in freeAvailabilityWindows(partition, minimumSeconds: seconds))
      CalendarAvailabilitySlot(startUtc: w.start, endUtc: w.end),
  ];
  List<AvailabilityInterval> _partition(List<CalendarFreeBusyPeriod> periods) =>
      [
        for (final p in periods)
          AvailabilityInterval(
            window: UtcWindow(start: p.startUtc, end: p.endUtc),
            kind: AvailabilityKind.values.byName(p.kind.name),
          ),
      ];
  CalendarSubjectAvailability _unknownTarget(
    CalendarAvailabilityTarget target,
  ) => CalendarSubjectAvailability(
    target: target,
    coverage: CalendarFreeBusyCoverage.unknown,
    periods: [],
    freeSlots: [],
  );

  Future<CalendarAvailabilitySearchView> searchAvailability(
    CalendarAvailabilitySearchQuery input,
  ) async {
    final query = _searchQuery(input);
    final window = _busyWindow(query.fromUtc, query.untilUtc);
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final budget = _BusyBudget();
      var calendars = 0;
      final resolutions = <String, CalendarSubjectResolution>{};
      final results = <CalendarSubjectAvailability>[];
      for (final target in query.targets) {
        try {
          await _decide(
            c,
            [_sr(query, target)],
            tx,
            CalendarAuthorizationPhase.read,
          );
          final resolution = await _resolveAvailability(c, target, tx);
          resolutions[_targetKey(target)] = resolution;
          final sources = <List<AvailabilityInterval>>[];
          for (final id in resolution.calendarIds) {
            if (++calendars > 16) {
              throw const AvailabilityLimitException('calendarEvaluations');
            }
            final parent = await _active(c, id, tx);
            final calendarQuery = CalendarFreeBusyQuery(
              calendarId: id,
              fromUtc: window.start,
              untilUtc: window.end,
            );
            await _decide(
              c,
              [
                _er(
                  parent,
                  CalendarPermission.projectCalendarAvailability,
                  freeBusy: calendarQuery,
                  search: query,
                  target: target,
                ),
              ],
              tx,
              CalendarAuthorizationPhase.read,
            );
            final busy = await _calendarBusy(
              c,
              parent,
              calendarQuery,
              window,
              tx,
              budget,
              search: query,
              target: target,
            );
            if (busy.coverage != CalendarFreeBusyCoverage.complete) {
              throw const AvailabilityLimitException('incompleteContributor');
            }
            sources.add(_partition(busy.periods));
          }
          final combined = combineCompleteAvailability(
            window: window,
            sources: sources,
            maxSources: 8,
            maxInputIntervals: 8000,
            maxOutputIntervals: 1000,
          );
          results.add(
            CalendarSubjectAvailability(
              target: target,
              coverage: CalendarFreeBusyCoverage.complete,
              periods: [
                for (final p in combined)
                  CalendarFreeBusyPeriod(
                    startUtc: p.window.start,
                    endUtc: p.window.end,
                    kind: CalendarFreeBusyKind.values.byName(p.kind.name),
                  ),
              ],
              freeSlots: _slots(combined, query.minimumSeconds),
            ),
          );
        } catch (e) {
          if (!_unknownSearchError(e)) rethrow;
          results.add(_unknownTarget(target));
        }
      }
      // Recheck all successful summaries after the entire calculation. Host
      // revisions/sets remain private. External after-check races stay declared.
      for (var i = 0; i < results.length; i++) {
        if (results[i].coverage != CalendarFreeBusyCoverage.complete) continue;
        final target = results[i].target;
        try {
          await _decide(
            c,
            [_sr(query, target)],
            tx,
            CalendarAuthorizationPhase.read,
          );
          final finalResolution = await _resolveAvailability(c, target, tx);
          final initial = resolutions[_targetKey(target)]!;
          if (initial.revision != finalResolution.revision ||
              jsonEncode(
                    initial.calendarIds.map((id) => id.toString()).toList(),
                  ) !=
                  jsonEncode(
                    finalResolution.calendarIds
                        .map((id) => id.toString())
                        .toList(),
                  )) {
            results[i] = _unknownTarget(target);
          }
        } catch (e) {
          if (!_unknownSearchError(e)) rethrow;
          results[i] = _unknownTarget(target);
        }
      }
      CalendarFreeBusyCoverage? commonCoverage;
      var commonSlots = <CalendarAvailabilitySlot>[];
      if (query.mode == CalendarAvailabilitySearchMode.commonFree) {
        commonCoverage = CalendarFreeBusyCoverage.unknown;
        if (results.every(
          (r) => r.coverage == CalendarFreeBusyCoverage.complete,
        )) {
          try {
            final combined = combineCompleteAvailability(
              window: window,
              sources: [for (final r in results) _partition(r.periods)],
              maxSources: 8,
              maxInputIntervals: 8000,
              maxOutputIntervals: 1000,
            );
            commonSlots = _slots(combined, query.minimumSeconds);
            commonCoverage = CalendarFreeBusyCoverage.complete;
          } catch (e) {
            if (!_unknownSearchError(e)) rethrow;
          }
        }
      }
      await _verifyContext(c);
      final now = await _revisionTime(tx);
      return CalendarAvailabilitySearchView(
        snapshotId: const Uuid().v4obj(),
        calculatedAtUtc: DateTime.utc(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute,
          now.second,
        ),
        fromUtc: window.start,
        untilUtc: window.end,
        mode: query.mode,
        minimumSeconds: query.minimumSeconds,
        results: List.unmodifiable(results),
        commonCoverage: commonCoverage,
        commonSlots: commonSlots,
      );
    });
  }
}
