part of 'calendar_module.dart';

extension CalendarEventImportOperations on CalendarService {
  /// Authenticated create-only import; no scheduling or publication side effects.
  Future<CalendarEventImportResult> importEvents(
    CalendarEventImportRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    CalendarAuthorizationRequest batchRequest(
      _Active parent, [
      CalendarEventImportIntent? intent,
    ]) => CalendarAuthorizationRequest(
      key: 'importEvents:${parent.identity.id}',
      operation: CalendarPermission.importEvents,
      calendarId: parent.identity.id,
      current: parent.snapshot,
      eventImport: intent,
    );
    void revision(_Active parent) {
      if (input.expectedRevision < 1 ||
          input.expectedRevision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (input.expectedRevision != parent.identity.revision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
    }

    await _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [batchRequest(parent)],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      revision(parent);
    });
    late final CalendarEventImportIntent intent;
    try {
      final parsed = parseIcalendarEventCalendar(bytes);
      intent = CalendarEventImportIntent([
        for (final source in parsed.series)
          (() {
            final proposal = eventStorageProposal(source);
            return CalendarEventImportMember(
              eventId: const Uuid().v4obj(),
              protocolUid: proposal.protocolUid,
              content: proposal.content,
              protocolState: proposal.protocolState,
              timingOverrides: proposal.edits,
            );
          })(),
      ]);
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
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final batch = batchRequest(parent, intent);
      CalendarAuthorizationRequest memberRequest(
        CalendarEventImportMember m,
        CalendarPermission operation,
      ) => CalendarAuthorizationRequest(
        key: '${operation.name}:${m.eventId}',
        operation: operation,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        eventId: m.eventId,
        proposedEvent: m.content,
        proposedTimingOverrides: m.timingOverrides,
        proposedEventProtocolState: m.protocolState,
        eventImport: intent,
      );
      final requests = <UuidValue, List<CalendarAuthorizationRequest>>{
        for (final m in intent.members)
          m.eventId: [
            memberRequest(m, CalendarPermission.createEvent),
            if (m.requiresLifecycle)
              memberRequest(m, CalendarPermission.changeEventStatus),
          ],
      };
      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        CalendarAuthorizationPhase phase,
      ) async {
        final decisions = <String, CalendarAuthorizationDecision>{};
        final all = [batch, ...requests.values.expand((v) => v)];
        for (var i = 0; i < all.length; i += _options.policyBatchSize) {
          final chunk = all.sublist(
            i,
            min(i + _options.policyBatchSize, all.length),
          );
          decisions.addAll(
            phase == CalendarAuthorizationPhase.finalWrite
                ? await _final(c, chunk, tx)
                : await _decide(c, chunk, tx, phase),
          );
        }
        return decisions;
      }

      await authorize(CalendarAuthorizationPhase.preliminaryWrite);
      revision(parent);
      // Bound destination work without exposing its hidden object count.
      final count = await CalendarEventRecord.db.count(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) & t.deletedAt.equals(null),
        transaction: tx,
        limit: _options.maxScannedEvents + 1,
      );
      if (count + intent.members.length > _options.maxScannedEvents) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final seen = <String>{};
      for (final m in intent.members) {
        if (!seen.add(m.protocolUid)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        final candidates = await CalendarEventDataRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(input.calendarId) &
              t.uidDigest.equals(eventUidDigest(m.protocolUid)),
          transaction: tx,
          limit: _options.maxScannedEvents + 1,
        );
        if (candidates.length > _options.maxScannedEvents) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (eventUidConflicts(
          m.protocolUid,
          candidates.map((v) => v.protocolUid),
        )) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      final decisions = await authorize(CalendarAuthorizationPhase.finalWrite);
      await _verifyContext(c);
      final now = await _revisionTime(tx);
      final receipts = <CalendarEventReceipt>[];
      for (final m in intent.members) {
        final identity = await CalendarEventRecord.db.insertRow(
          _session,
          CalendarEventRecord(
            id: m.eventId,
            calendarId: input.calendarId,
            revision: 1,
          ),
          transaction: tx,
        );
        final data = await CalendarEventDataRecord.db.insertRow(
          _session,
          CalendarEventDataRecord(
            eventId: m.eventId,
            calendarId: input.calendarId,
            origin: CalendarEventOrigin.imported,
            protocolUid: m.protocolUid,
            uidDigest: eventUidDigest(m.protocolUid),
            content: m.content,
            timingOverrides: m.timingOverrides,
            protocolState: m.protocolState,
            importBaseline: _eventProtocolValue(
              () => eventImportBaseline(
                m.protocolUid,
                m.content,
                m.timingOverrides,
                m.protocolState,
              ),
            ),
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
        final receipt = _eventReceipt(_Event(identity, data, parent), [
          decisions[batch.key]!,
          for (final r in requests[m.eventId]!) decisions[r.key]!,
        ]);
        if (receipt != null) {
          receipts.add(receipt);
        }
      }
      await _bump(scope, tx, publishedEventCalendar: input.calendarId);
      return CalendarEventImportResult(receipts: List.unmodifiable(receipts));
    });
  }
}
