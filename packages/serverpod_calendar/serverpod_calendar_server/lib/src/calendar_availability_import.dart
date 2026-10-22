part of 'calendar_module.dart';

extension CalendarAvailabilityImportOperations on CalendarService {
  /// Create-only, full-file atomic import. No publication or scheduling effects.
  Future<CalendarAvailabilityImportResult> importAvailability(
    CalendarAvailabilityImportRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    // Own the bounded bytes before awaiting host code; a direct caller cannot
    // change the file between validation and commit.
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    CalendarAuthorizationRequest batchRequest(
      _Active parent, [
      CalendarAvailabilityImportIntent? intent,
    ]) => CalendarAuthorizationRequest(
      key: 'importAvailability:${parent.identity.id}',
      operation: CalendarPermission.importAvailability,
      calendarId: parent.identity.id,
      current: parent.snapshot,
      availabilityImport: intent,
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
    late final CalendarAvailabilityImportIntent intent;
    try {
      final parsed = parseIcalendarAvailabilityCalendar(
        bytes,
        extensions: IcalendarAvailabilityExtensionRegistry([
          for (final registration in _runtime.availabilityExtensions.values)
            IcalendarAvailabilityExtensionRegistration(
              name: registration.name,
              contexts: registration.contexts.map(
                (v) => switch (v) {
                  CalendarAvailabilityExtensionContext.definition =>
                    IcalendarAvailabilityExtensionContext.definition,
                  CalendarAvailabilityExtensionContext.opening =>
                    IcalendarAvailabilityExtensionContext.opening,
                },
              ),
              // Current host validation runs with bounded policy handling below,
              // at both write phases. Here only installed name/context is used.
              validateText: (_) => true,
            ),
        ]),
      );
      intent = CalendarAvailabilityImportIntent([
        for (final definition in parsed.definitions)
          (() {
            final proposal = availabilityStorageProposal(definition);
            return CalendarAvailabilityImportMember(
              availabilityId: const Uuid().v4obj(),
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
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    } on AvailabilityLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final batch = batchRequest(parent, intent);
      CalendarAuthorizationRequest memberRequest(
        CalendarAvailabilityImportMember m,
      ) => CalendarAuthorizationRequest(
        key: 'createAvailability:${m.availabilityId}',
        operation: CalendarPermission.createAvailability,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        availabilityId: m.availabilityId,
        proposedAvailability: m.content,
        proposedAvailabilityEdits: m.timingOverrides,
        proposedAvailabilityProtocolState: m.protocolState,
        availabilityImport: intent,
      );
      final requests = [
        for (final member in intent.members) memberRequest(member),
      ];
      // Each chunk respects host policy batch size; no partial commit follows
      // even when the last chunk/member denies the complete file.
      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        CalendarAuthorizationPhase phase,
      ) async {
        final decisions = <String, CalendarAuthorizationDecision>{};
        final all = [batch, ...requests];
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
        for (final request in requests) {
          await _approveAvailabilityMetadata(c, request, tx, phase);
        }
        return decisions;
      }

      await authorize(CalendarAuthorizationPhase.preliminaryWrite);
      revision(parent);
      final count = await CalendarAvailabilityRecord.db.count(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) & t.deletedAt.equals(null),
        transaction: tx,
        limit: availabilityMaxDefinitions + 1,
      );
      if (count + intent.members.length > availabilityMaxDefinitions) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final seen = <String>{};
      for (final member in intent.members) {
        if (!seen.add(member.protocolUid)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        final candidates = await CalendarAvailabilityDataRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(input.calendarId) &
              t.uidDigest.equals(availabilityUidDigest(member.protocolUid)),
          transaction: tx,
          limit: availabilityMaxDefinitions + 1,
        );
        if (candidates.length > availabilityMaxDefinitions) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (availabilityUidConflicts(
          member.protocolUid,
          candidates.map((v) => v.protocolUid),
        )) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      final decisions = await authorize(CalendarAuthorizationPhase.finalWrite);
      await _verifyContext(c);
      final now = await _revisionTime(tx);
      final receipts = <CalendarAvailabilityReceipt>[];
      for (var i = 0; i < intent.members.length; i++) {
        final m = intent.members[i];
        final identity = await CalendarAvailabilityRecord.db.insertRow(
          _session,
          CalendarAvailabilityRecord(
            id: m.availabilityId,
            calendarId: input.calendarId,
            revision: 1,
          ),
          transaction: tx,
        );
        final data = await CalendarAvailabilityDataRecord.db.insertRow(
          _session,
          CalendarAvailabilityDataRecord(
            availabilityId: identity.id!,
            calendarId: input.calendarId,
            protocolUid: m.protocolUid,
            uidDigest: availabilityUidDigest(m.protocolUid),
            content: m.content,
            timingOverrides: m.timingOverrides,
            protocolState: m.protocolState,
            importBaseline: _availabilityValue(
              () => availabilityImportBaseline(
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
        final receipt = _availabilityReceipt(
          _Availability(identity, data, parent),
          [decisions[batch.key]!, decisions[requests[i].key]!],
        );
        if (receipt != null) receipts.add(receipt);
      }
      await _bump(scope, tx);
      return CalendarAvailabilityImportResult(
        receipts: List.unmodifiable(receipts),
      );
    });
  }
}
