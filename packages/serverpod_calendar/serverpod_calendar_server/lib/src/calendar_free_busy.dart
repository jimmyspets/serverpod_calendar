part of 'calendar_module.dart';

extension CalendarFreeBusyOperations on CalendarService {
  Future<CalendarFreeBusyView> freeBusy(CalendarFreeBusyQuery query) async {
    late final UtcWindow window;
    try {
      TimedValue.utc(query.fromUtc);
      TimedValue.utcEnd(query.untilUtc);
      window = UtcWindow(start: query.fromUtc, end: query.untilUtc);
      if (window.duration > const Duration(days: 31)) {
        throw ArgumentError('Free/busy query exceeds 31 days');
      }
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _active(c, query.calendarId, tx);
      await _decide(
        c,
        [_er(parent, CalendarPermission.readFreeBusy, freeBusy: query)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      CalendarFreeBusyView response(
        CalendarFreeBusyCoverage coverage,
        List<CalendarFreeBusyPeriod> periods,
      ) => CalendarFreeBusyView(
        calendarId: parent.identity.id!,
        fromUtc: window.start,
        untilUtc: window.end,
        coverage: coverage,
        periods: periods,
      );
      late final CalendarFreeBusyView result;
      try {
        final scanCap = _options.maxScannedEvents < 256
            ? _options.maxScannedEvents
            : 256;
        final rows = await CalendarEventRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(parent.identity.id!) &
              t.deletedAt.equals(null),
          orderBy: (t) => t.id,
          limit: scanCap + 1,
          transaction: tx,
        );
        if (rows.length > scanCap) {
          throw const AvailabilityLimitException('maxScannedEvents');
        }
        final events = <_Event>[];
        for (final row in rows) {
          events.add(
            await _event(c, row.id!, tx, identity: row, parent: parent),
          );
        }
        // Never use the privacy-filtered detail candidate plan for coverage.
        for (
          var offset = 0;
          offset < events.length;
          offset += _options.policyBatchSize
        ) {
          final end = (offset + _options.policyBatchSize).clamp(
            0,
            events.length,
          );
          await _decide(
            c,
            [
              for (final e in events.sublist(offset, end))
                _er(
                  parent,
                  CalendarPermission.projectEventBusy,
                  event: e,
                  freeBusy: query,
                ),
            ],
            tx,
            CalendarAuthorizationPhase.read,
          );
        }
        final bookings = <AvailabilityInterval>[];
        for (final e in events) {
          final kind = e.data.content.status == CalendarEventStatus.tentative
              ? AvailabilityKind.tentative
              : AvailabilityKind.busy;
          for (final occupied in eventOccupiedWindows(
            e.data.content,
            e.data.timingOverrides,
            window,
            dateZone: parent.data.availabilityZoneId,
          )) {
            if (bookings.length >= 5000) {
              throw const AvailabilityLimitException('maxProjectedIntervals');
            }
            bookings.add(AvailabilityInterval(window: occupied, kind: kind));
          }
        }
        final ruleRows = await CalendarAvailabilityRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(parent.identity.id!) &
              t.deletedAt.equals(null),
          orderBy: (t) => t.id,
          limit: availabilityMaxDefinitions + 1,
          transaction: tx,
        );
        if (ruleRows.length > availabilityMaxDefinitions) {
          throw const AvailabilityLimitException('maxDefinitions');
        }
        final definitions = <AvailabilityDefinition>[];
        var openingCount = 0;
        var sourceOpenings = 0;
        // Calculation never uses the permission-filtered management list.
        for (final row in ruleRows) {
          final rule = await _availability(
            c,
            row.id!,
            tx,
            parent: parent,
            identity: row,
          );
          await _decide(
            c,
            [
              _ar(
                parent,
                CalendarPermission.projectAvailability,
                rule: rule,
                query: query,
              ),
            ],
            tx,
            CalendarAuthorizationPhase.read,
          );
          sourceOpenings += rule.data.content.openings.length;
          if (sourceOpenings > 64) {
            throw const AvailabilityLimitException('maxSourceOpenings');
          }
          final evaluated = evaluateAvailability(rule.data.content, window);
          openingCount += evaluated.openings.length;
          if (openingCount > 5000) {
            throw const AvailabilityLimitException('maxProjectedOpenings');
          }
          definitions.add(evaluated);
        }
        final background = composeAvailability(
          window: window,
          definitions: definitions,
          fallbackUnavailable:
              parent.data.noRuleFallback == CalendarNoRuleFallback.unavailable,
          maxDefinitions: availabilityMaxDefinitions,
          maxOpenings: 5000,
          maxOutputIntervals: 1000,
        );
        bookings.addAll(
          background.where((p) => p.kind != AvailabilityKind.free),
        );
        final partition = partitionFreeBusy(
          window: window,
          bookings: bookings,
          fallbackUnavailable: false,
          maxInputIntervals: 6000,
          maxOutputIntervals: 1000,
        );
        result = response(CalendarFreeBusyCoverage.complete, [
          for (final p in partition)
            CalendarFreeBusyPeriod(
              startUtc: p.window.start,
              endUtc: p.window.end,
              kind: CalendarFreeBusyKind.values.byName(p.kind.name),
            ),
        ]);
      } on CalendarException catch (e) {
        if (e.code != CalendarFailureCode.accessDenied &&
            e.code != CalendarFailureCode.unavailable &&
            e.code != CalendarFailureCode.limitExceeded) {
          rethrow;
        }
        result = response(CalendarFreeBusyCoverage.unknown, []);
      } on RecurrenceLimitException {
        result = response(CalendarFreeBusyCoverage.unknown, []);
      } on AvailabilityLimitException {
        result = response(CalendarFreeBusyCoverage.unknown, []);
      } on ZoneCoverageException {
        result = response(CalendarFreeBusyCoverage.unknown, []);
      } on ArgumentError {
        result = response(CalendarFreeBusyCoverage.unknown, []);
      }
      await _verifyContext(c);
      return result;
    });
  }
}
