part of 'calendar_module.dart';

T _eventReplacementValue<T>(T Function() body) {
  try {
    return body();
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
  } on IcalendarValueException {
    throw _failure(CalendarFailureCode.validation);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
}

extension CalendarEventReplacementOperations on CalendarService {
  Future<CalendarEventReplaceResult> replaceEventsFromImport(
    CalendarEventReplaceRequest input,
  ) async {
    if (input.bytes.lengthInBytes > const IcalendarSyntaxLimits().maxBytes ||
        input.selection.isEmpty ||
        input.selection.length > const IcalendarComponentLimits().maxEvents) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarEventExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.eventId).toSet().length != selection.length ||
        [
          input.expectedRevision,
          ...selection.map((s) => s.expectedRevision),
        ].any((r) => r < 1 || r > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final bytes = Uint8List.fromList(
      input.bytes.buffer.asUint8List(
        input.bytes.offsetInBytes,
        input.bytes.lengthInBytes,
      ),
    );
    final c = await _context();
    await _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      await _decide(
        c,
        [
          _er(parent, CalendarPermission.importEvents),
          _er(parent, CalendarPermission.replaceEventsFromImport),
        ],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (parent.identity.revision != input.expectedRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
    });
    // The same strict pure adapter and limit mapping as authenticated import.
    final parsed = _eventReplacementValue(
      () => parseIcalendarEventCalendar(bytes),
    );
    final proposals = _eventReplacementValue(
      () => {
        for (final s in parsed.series) s.master.uid: eventStorageProposal(s),
      },
    );
    return _transaction(c, (tx, scope) async {
      final parent = await _active(c, input.calendarId, tx);
      final events = <_Event>[];
      for (final target in selection) {
        final event = await _event(c, target.eventId, tx);
        if (event.identity.calendarId != input.calendarId) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        events.add(event);
      }
      CalendarEventReplacementIntent? batch;
      CalendarAuthorizationRequest request(
        CalendarPermission op, [
        _Event? event,
      ]) {
        final proposed = event == null
            ? null
            : proposals[event.data.protocolUid];
        return CalendarAuthorizationRequest(
          key: '${op.name}:${event?.identity.id ?? parent.identity.id}',
          operation: op,
          calendarId: input.calendarId,
          current: parent.snapshot,
          eventId: event?.identity.id,
          currentEvent: event?.snapshot,
          proposedEvent: proposed?.content,
          proposedTimingOverrides: proposed?.edits,
          proposedEventProtocolState: proposed?.protocolState,
          itemTextMetadataPatch:
              op == CalendarPermission.updateEventTextMetadata &&
                  event != null &&
                  proposed != null
              ? itemTextChanges(
                  eventTextState(
                    event.data.protocolState!,
                    event.data.timingOverrides,
                  ),
                  eventTextState(proposed.protocolState, proposed.edits),
                )
              : null,
          eventReplacement: batch,
          eventGroups: CalendarEventFieldGroup.values,
        );
      }

      Future<Map<String, CalendarAuthorizationDecision>> authorize(
        List<CalendarAuthorizationRequest> requests,
        CalendarAuthorizationPhase phase,
      ) async {
        final decisions = <String, CalendarAuthorizationDecision>{};
        await _verifyContext(c);
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          final chunk = requests.sublist(
            i,
            min(i + _options.policyBatchSize, requests.length),
          );
          final result = phase == CalendarAuthorizationPhase.finalWrite
              ? await _final(c, chunk, tx)
              : await _decide(c, chunk, tx, phase);
          for (final r in chunk.where(
            (r) => r.operation == CalendarPermission.readEvent,
          )) {
            if (!result[r.key]!.eventDisclosedGroups.containsAll(
              CalendarEventFieldGroup.values,
            )) {
              throw _failure(CalendarFailureCode.accessDenied);
            }
          }
          decisions.addAll(result);
        }
        await _verifyContext(c);
        return decisions;
      }

      List<CalendarAuthorizationRequest> baseRequests() => [
        request(CalendarPermission.importEvents),
        request(CalendarPermission.replaceEventsFromImport),
        for (final event in events) ...[
          request(CalendarPermission.importEvents, event),
          request(CalendarPermission.replaceEventsFromImport, event),
          request(CalendarPermission.readEvent, event),
          request(CalendarPermission.readEventSource, event),
        ],
      ];
      await authorize(
        baseRequests(),
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      // Enforce on every host, independently of optional invitation ingress.
      for (final event in events) {
        if (await CalendarInvitationLinkRecord.db.findFirstRow(
              _session,
              where: (t) => t.eventId.equals(event.identity.id!),
              transaction: tx,
            ) !=
            null) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      for (final event in events) {
        await _rejectSchedulingBinding(event.identity.id!, tx);
      }
      if (parent.identity.revision != input.expectedRevision ||
          events.any(
            (e) =>
                e.identity.revision !=
                selection
                    .singleWhere((s) => s.eventId == e.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (parsed.series.length != events.length ||
          proposals.length != events.length ||
          events.any((e) => !proposals.containsKey(e.data.protocolUid))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final members = [
        for (final event in events)
          (() {
            final p = proposals[event.data.protocolUid]!;
            return CalendarEventImportMember(
              eventId: event.identity.id!,
              protocolUid: p.protocolUid,
              content: p.content,
              protocolState: p.protocolState,
              timingOverrides: p.edits,
            );
          })(),
      ];
      final changed = <bool>[], local = <bool>[];
      CalendarEventReplacementIntent intent(bool classified) =>
          CalendarEventReplacementIntent([
            for (var i = 0; i < events.length; i++)
              CalendarEventReplacementMember(
                current: events[i].snapshot,
                proposed: members[i],
                baselineProfile: events[i].data.importBaseline?.profile,
                baselineSequence: events[i].data.importBaseline?.sourceSequence,
                changed: classified ? changed[i] : null,
                localChanges: classified ? local[i] : null,
              ),
          ]);
      batch = intent(false);
      await authorize(
        baseRequests(),
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      for (final event in events) {
        final baseline = event.data.importBaseline;
        if (baseline == null) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        try {
          validateEventImportBaseline(baseline, event.data.protocolUid);
        } catch (_) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final proposal = proposals[event.data.protocolUid]!;
        final current = _eventProtocolValue(
          () => eventImportBaseline(
            event.data.protocolUid,
            event.data.content,
            event.data.timingOverrides,
            event.data.protocolState!,
          ),
        );
        final isChanged =
            current.canonicalValue != proposal.importBaseline.canonicalValue;
        final isLocal = current.canonicalValue != baseline.canonicalValue;
        if ((proposal.protocolState.version.sequence ?? 0) <
                (baseline.sourceSequence ?? 0) ||
            (isChanged && isLocal)) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        if (isChanged &&
            event.identity.revision == CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        changed.add(isChanged);
        local.add(isLocal);
      }
      bool lifecycle(_Event event, CalendarEventImportMember proposed) {
        if (event.data.content.status != proposed.content.status) return true;
        final current = {
          for (final o
              in event.data.timingOverrides?.singles ??
                  <CalendarEventSingleOverride>[])
            if (o.cancelled) o.originalStart,
        };
        final next = {
          for (final o
              in proposed.timingOverrides?.singles ??
                  <CalendarEventSingleOverride>[])
            if (o.cancelled) o.originalStart,
        };
        return current.length != next.length || !current.containsAll(next);
      }

      batch = intent(true);
      final requests = [
        ...baseRequests(),
        for (var i = 0; i < events.length; i++)
          if (changed[i]) ...[
            request(CalendarPermission.updateEvent, events[i]),
            if (itemTextChanges(
                  eventTextState(
                    events[i].data.protocolState!,
                    events[i].data.timingOverrides,
                  ),
                  eventTextState(
                    proposals[events[i].data.protocolUid]!.protocolState,
                    proposals[events[i].data.protocolUid]!.edits,
                  ),
                ) !=
                null)
              request(CalendarPermission.updateEventTextMetadata, events[i]),
            if (eventDescriptiveState(
                  events[i].data.protocolState!.sourceMetadata,
                  events[i].data.timingOverrides,
                ) !=
                eventDescriptiveState(
                  proposals[events[i].data.protocolUid]!
                      .protocolState
                      .sourceMetadata,
                  proposals[events[i].data.protocolUid]!.edits,
                ))
              request(
                CalendarPermission.updateEventDescriptiveMetadata,
                events[i],
              ),
            if (lifecycle(events[i], members[i]))
              request(CalendarPermission.changeEventStatus, events[i]),
          ],
      ];
      await authorize(requests, CalendarAuthorizationPhase.preliminaryWrite);
      final decisions = await authorize(
        requests,
        CalendarAuthorizationPhase.finalWrite,
      );
      final now = changed.any((v) => v) ? await _revisionTime(tx) : null;
      final receipts = <CalendarEventReplaceReceipt>[];
      for (var i = 0; i < events.length; i++) {
        final event = events[i], proposal = proposals[event.data.protocolUid]!;
        if (changed[i]) {
          event.data.content = proposal.content;
          event.data.timingOverrides = proposal.edits;
          event.data.protocolState = proposal.protocolState;
          event.data.importBaseline = proposal.importBaseline;
          event.data.updatedAt = now!.isBefore(event.data.updatedAt)
              ? event.data.updatedAt
              : now;
          event.identity.revision++;
          await CalendarEventDataRecord.db.updateRow(
            _session,
            event.data,
            transaction: tx,
          );
          await CalendarEventRecord.db.updateRow(
            _session,
            event.identity,
            transaction: tx,
          );
        }
        final receipt = _eventReceipt(event, [
          for (final r in requests.where(
            (r) =>
                r.operation != CalendarPermission.readEvent &&
                (r.eventId == null || r.eventId == event.identity.id),
          ))
            decisions[r.key]!,
        ]);
        if (receipt != null) {
          receipts.add(
            CalendarEventReplaceReceipt(receipt: receipt, changed: changed[i]),
          );
        }
      }
      if (changed.any((v) => v)) {
        await _bump(scope, tx, publishedEventCalendar: input.calendarId);
      }
      return CalendarEventReplaceResult(receipts: List.unmodifiable(receipts));
    });
  }
}
