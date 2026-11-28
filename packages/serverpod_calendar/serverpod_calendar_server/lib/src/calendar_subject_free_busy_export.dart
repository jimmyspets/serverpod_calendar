part of 'calendar_module.dart';

extension CalendarSubjectFreeBusyExportOperations on CalendarService {
  Future<ByteData> exportSubjectFreeBusy(
    CalendarSubjectFreeBusyExportRequest input,
  ) async {
    // Freeze and normalize before the first host callback. This export has no
    // duration filter: even short free intervals belong to its full partition.
    final query = _searchQuery(
      CalendarAvailabilitySearchQuery(
        targets: input.targets,
        fromUtc: input.fromUtc,
        untilUtc: input.untilUtc,
        mode: input.mode,
        minimumSeconds: 1,
      ),
    );
    final window = _busyWindow(query.fromUtc, query.untilUtc);
    final guarantee = _runtime.policy.guarantee;
    void verifyGuarantee() {
      if (guarantee == CalendarAuthorizationGuarantee.coordinated &&
          _runtime.policy.guarantee !=
              CalendarAuthorizationGuarantee.coordinated) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }

    final actor = await _context();
    verifyGuarantee();
    return _transaction(actor, (tx, _) async {
      final checks = <List<CalendarAuthorizationRequest>>[];
      final resolutions = <String, CalendarSubjectResolution>{};
      final partitions = <List<AvailabilityInterval>>[];
      final budget = _BusyBudget();
      var calendars = 0;
      Future<void> decide(List<CalendarAuthorizationRequest> batch) async {
        verifyGuarantee();
        await _decide(actor, batch, tx, CalendarAuthorizationPhase.read);
        await _verifyContext(actor);
        verifyGuarantee();
      }

      Future<void> authorize(
        List<CalendarAuthorizationRequest> requests,
      ) async {
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          final batch = List<CalendarAuthorizationRequest>.unmodifiable(
            requests.sublist(
              i,
              min(i + _options.policyBatchSize, requests.length),
            ),
          );
          await decide(batch);
          // Separate batches retain target context when contributors overlap;
          // request keys must never collapse distinct subjects into one check.
          checks.add(batch);
        }
      }

      try {
        for (final target in query.targets) {
          await authorize([
            _sr(query, target),
            CalendarAuthorizationRequest(
              key: 'exportSubjectFreeBusy:${_targetKey(target)}',
              operation: CalendarPermission.exportSubjectFreeBusy,
              availabilitySearchQuery: query,
              availabilityTarget: target,
            ),
          ]);
          final resolution = await _resolveAvailability(actor, target, tx);
          resolutions[_targetKey(target)] = resolution;
          final sources = <List<AvailabilityInterval>>[];
          for (final id in resolution.calendarIds) {
            if (++calendars > 16) {
              throw _failure(CalendarFailureCode.limitExceeded);
            }
            final parent = await _active(actor, id, tx);
            final calendarQuery = CalendarFreeBusyQuery(
              calendarId: id,
              fromUtc: window.start,
              untilUtc: window.end,
            );
            await authorize([
              _er(
                parent,
                CalendarPermission.projectCalendarAvailability,
                freeBusy: calendarQuery,
                search: query,
                target: target,
              ),
            ]);
            final busy = await _calendarBusyAuthorized(
              parent,
              calendarQuery,
              window,
              tx,
              budget,
              search: query,
              target: target,
              authorize: authorize,
            );
            if (busy.coverage != CalendarFreeBusyCoverage.complete) {
              throw _failure(CalendarFailureCode.unavailable);
            }
            sources.add(_partition(busy.periods));
          }
          partitions.add(
            combineCompleteAvailability(
              window: window,
              sources: sources,
              maxSources: 8,
              maxInputIntervals: 8000,
              maxOutputIntervals: 1000,
            ),
          );
        }
        final output = query.mode == CalendarAvailabilitySearchMode.commonFree
            ? [
                combineCompleteAvailability(
                  window: window,
                  sources: partitions,
                  maxSources: 8,
                  maxInputIntervals: 8000,
                  maxOutputIntervals: 1000,
                ),
              ]
            : partitions;
        final bytes = serializeSubjectFreeBusySnapshots(
          uids: [for (final _ in output) const Uuid().v4()],
          stamp: availabilityProtocolInstant(await _revisionTime(tx)),
          window: window,
          partitions: output,
        );
        // Nothing is returned until every actual projection and export gate is
        // checked again, followed by exact trusted contributor-set revisions.
        for (final batch in checks) {
          await decide(batch);
        }
        for (final target in query.targets) {
          final current = await _resolveAvailability(actor, target, tx);
          final original = resolutions[_targetKey(target)]!;
          if (current.revision != original.revision ||
              jsonEncode(
                    current.calendarIds.map((id) => id.toString()).toList(),
                  ) !=
                  jsonEncode(
                    original.calendarIds.map((id) => id.toString()).toList(),
                  )) {
            throw _failure(CalendarFailureCode.unavailable);
          }
        }
        await _verifyContext(actor);
        verifyGuarantee();
        return ByteData.sublistView(bytes);
      } on IcalendarComponentException catch (e) {
        throw _failure(
          e.kind == IcalendarComponentError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on IcalendarSyntaxException catch (e) {
        throw _failure(
          e.kind == IcalendarSyntaxError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on AvailabilityLimitException {
        throw _failure(CalendarFailureCode.unavailable);
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.unavailable);
      } on ZoneCoverageException {
        throw _failure(CalendarFailureCode.unavailable);
      }
    });
  }
}
