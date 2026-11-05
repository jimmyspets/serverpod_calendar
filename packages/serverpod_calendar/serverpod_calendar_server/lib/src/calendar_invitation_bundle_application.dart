part of 'calendar_module.dart';

T _bundleStoredValue<T>(T Function() action) {
  try {
    return action();
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.unavailable);
  } on StateError {
    throw _failure(CalendarFailureCode.unavailable);
  } on FormatException {
    throw _failure(CalendarFailureCode.unavailable);
  } on TypeError {
    throw _failure(CalendarFailureCode.unavailable);
  }
}

typedef _BundleCandidate = ({
  String protocolUid,
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState protocolState,
  CalendarEventImportBaseline importBaseline,
});

extension CalendarInvitationBundleOperations on CalendarService {
  CalendarInvitationBundleComponentVersion? _bundleCancellationVersion(
    CalendarInvitationApplicationState accepted,
  ) => accepted.kind == CalendarInvitationSourceKind.bundleCancellation
      ? CalendarInvitationBundleComponentVersion(
          sequence: accepted.sequence,
          stamp: accepted.stamp,
        )
      : null;

  _BundleCandidate _bundleCancelled(
    _Event event,
    int? sequence,
    DateTime stamp,
  ) {
    final base = _occAccepted(event.data.importBaseline!);
    final content = validateEventContent(
      base.content.copyWith(status: CalendarEventStatus.cancelled),
    );
    final protocol = validateEventProtocolState(
      base.protocol.copyWith(
        statusPresent: true,
        version: CalendarEventProtocolVersion(sequence: sequence, stamp: stamp),
      ),
      content,
      base.edits,
    );
    return (
      protocolUid: event.data.protocolUid,
      content: content,
      edits: base.edits,
      protocolState: protocol,
      importBaseline: event.data.importBaseline!,
    );
  }

  _BundleCandidate _bundleCandidate(
    IcalendarSchedulingMessage message,
    _Event event,
    RecurrenceWorkBudget work,
  ) {
    if (message.method == IcalendarSchedulingMethod.cancel) {
      return _bundleCancelled(
        event,
        message.events.single.sequence,
        message.events.single.stamp,
      );
    }
    final value = _bundleProposal(message, work);
    return (
      protocolUid: value.protocolUid,
      content: value.content,
      edits: value.edits,
      protocolState: value.protocolState,
      importBaseline: value.importBaseline,
    );
  }

  bool _bundleDirty(
    _Event event,
    CalendarInvitationApplicationState accepted,
    RecurrenceWorkBudget work,
  ) {
    if (accepted.kind != CalendarInvitationSourceKind.bundleCancellation) {
      return _invLocalChanges(event);
    }
    final expected = _bundleCancelled(event, accepted.sequence, accepted.stamp);
    return eventImportBaseline(
          event.data.protocolUid,
          event.data.content,
          event.data.timingOverrides,
          event.data.protocolState!,
          sharedWorkBudget: work,
        ).canonicalValue !=
        eventImportBaseline(
          event.data.protocolUid,
          expected.content,
          expected.edits,
          expected.protocolState,
          sharedWorkBudget: work,
        ).canonicalValue;
  }

  bool _bundleAdmission(
    CalendarInvitationBundleState old,
    CalendarInvitationApplicationState accepted,
    IcalendarSchedulingMessage message,
    String digest,
    CalendarInvitationRecipient recipient,
    RecurrenceWorkBudget work, {
    IcalendarSchedulingMessage? pending,
    String? pendingDigest,
  }) {
    final cancellation = _bundleCancellationVersion(accepted);
    CalendarInvitationBundleState? pendingState;
    if (pending?.method == IcalendarSchedulingMethod.request) {
      pendingState = _bundleProposalState(
        _bundleProposal(pending!, work),
        work,
      );
    }
    if (message.method == IcalendarSchedulingMethod.cancel) {
      final sameAccepted = cancellation != null && digest == accepted.digest;
      final samePending =
          pending?.method == IcalendarSchedulingMethod.cancel &&
          digest == pendingDigest;
      final floors = [
        if (!sameAccepted && cancellation != null) cancellation,
        if (pending?.method == IcalendarSchedulingMethod.cancel && !samePending)
          CalendarInvitationBundleComponentVersion(
            sequence: pending!.events.single.sequence,
            stamp: pending.events.single.stamp,
          ),
      ]..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
      final previous = floors.lastOrNull;
      _schedulingValue(
        () => validateInvitationBundleCancellation(
          accepted: old,
          incoming: message,
          recipientAddress: recipient.calendarAddress,
          pending: pendingState,
          previousCancellation: previous,
          sharedWorkBudget: work,
        ),
      );
      return !sameAccepted && !samePending;
    }
    final incoming = _bundleProposalState(_bundleProposal(message, work), work);
    var advance = _schedulingValue(
      () => cancellation == null
          ? validateInvitationBundleAdvance(
              old,
              incoming,
              sharedWorkBudget: work,
            )
          : validateInvitationBundleReopening(
              accepted: old,
              incoming: incoming,
              cancellation: cancellation,
              sharedWorkBudget: work,
            ),
    );
    if (pending?.method == IcalendarSchedulingMethod.cancel) {
      _schedulingValue(
        () => validateInvitationBundleReopening(
          accepted: old,
          incoming: incoming,
          cancellation: CalendarInvitationBundleComponentVersion(
            sequence: pending!.events.single.sequence,
            stamp: pending.events.single.stamp,
          ),
          sharedWorkBudget: work,
        ),
      );
    } else if (pendingState != null) {
      advance = _schedulingValue(
        () => validateInvitationBundleAdvance(
          pendingState!,
          incoming,
          sharedWorkBudget: work,
        ),
      );
    }
    return advance;
  }

  List<CalendarInvitationBundleComponentVersion> _bundleIncomingVersions(
    IcalendarSchedulingMessage message,
    _BundleCandidate candidate,
    RecurrenceWorkBudget work,
  ) => message.method == IcalendarSchedulingMethod.cancel
      ? [
          CalendarInvitationBundleComponentVersion(
            sequence: message.events.single.sequence,
            stamp: message.events.single.stamp,
          ),
        ]
      : _schedulingValue(
          () => invitationBundleBaseline(
            candidate.importBaseline,
            protocolUid: candidate.protocolUid,
            sharedWorkBudget: work,
          ),
        ).versions;

  CalendarInvitationBundleState _bundleState(
    _Event event, {
    RecurrenceWorkBudget? work,
  }) => _bundleStoredValue(
    () => invitationBundleBaseline(
      event.data.importBaseline!,
      protocolUid: event.data.protocolUid,
      sharedWorkBudget: work,
    ),
  );

  void _bundleValidateCheckpoint(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationApplicationRecord? row, {
    RecurrenceWorkBudget? work,
  }) {
    final state = _bundleState(event, work: work);
    if (row != null) {
      _bundleStoredValue(
        () => validateEventProtocolVersion(
          CalendarEventProtocolVersion(
            sequence: row.sequence,
            stamp: row.stamp,
          ),
        ),
      );
    }
    final master = state.versions.singleWhere((v) => v.originalStart == null);
    if (!link.bundledRequest ||
        _invSourceOrder(
              master.sequence,
              master.stamp,
              link.sequence,
              link.stamp,
            ) <
            0 ||
        (row?.kind == CalendarInvitationSourceKind.bundleCancellation
            ? row!.sequence == null ||
                  state.versions.any((v) => row.sequence! <= (v.sequence ?? 0))
            : master.sequence != (row == null ? link.sequence : row.sequence) ||
                  master.stamp != (row?.stamp ?? link.stamp))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (row != null &&
        (!_invBundleKind(row.kind) ||
            row.linkId != link.id ||
            row.scopeKey != link.scopeKey ||
            row.recipientKey != link.recipientKey ||
            row.revision < 1 ||
            row.revision > CalendarService._maxRevision ||
            row.eventRevision < 2 ||
            row.eventRevision > event.identity.revision ||
            row.invitationRevision < 2 ||
            row.invitationRevision > CalendarService._maxRevision ||
            row.creationDigest != _invCreationDigest(link) ||
            row.baselineDigest !=
                _invBaselineDigest(event.data.importBaseline!) ||
            _invSourceOrder(
                  row.sequence,
                  row.stamp,
                  link.sequence,
                  link.stamp,
                ) <
                0 ||
            [
              row.digest,
              row.requestDigest,
            ].any((s) => !RegExp(r'^[a-f0-9]{64}$').hasMatch(s)))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<CalendarInvitationLinkRecord> _bundleLink(
    UuidValue id,
    CalendarInvitationRecord? entry,
    CalendarInvitationRecipient recipient,
    Transaction tx, {
    UuidValue? retryLinkId,
  }) async {
    var link = await _invFindLink(id, entry, recipient, tx, allowBundle: true);
    if (link == null && entry == null) {
      final previous =
          retryLinkId ??
          (await CalendarInvitationApplicationRecord.db.findFirstRow(
            _session,
            where: (t) =>
                t.invitationId.equals(id) &
                t.scopeKey.equals(recipient.scopeKey) &
                t.recipientKey.equals(recipient.key),
            transaction: tx,
          ))?.linkId;
      if (previous != null) {
        final candidate = await CalendarInvitationLinkRecord.db.findById(
          _session,
          previous,
          transaction: tx,
        );
        if (candidate != null &&
            candidate.scopeKey == recipient.scopeKey &&
            candidate.recipientKey == recipient.key) {
          link = await _invFindLink(
            candidate.invitationId,
            null,
            recipient,
            tx,
            allowBundle: true,
          );
        }
      }
    }
    if (link == null) throw _failure(CalendarFailureCode.accessDenied);
    if (!link.bundledRequest || entry != null && !_invBundleKind(entry.kind)) {
      throw _failure(CalendarFailureCode.validation);
    }
    return link;
  }

  EventStorageProposal _bundleProposal(
    IcalendarSchedulingMessage message,
    RecurrenceWorkBudget work,
  ) => _schedulingValue(
    () => invitationRequestBundleProposal(
      message,
      maxBytes: _invOptions.maxSourceBytes,
      sharedWorkBudget: work,
    ),
  );

  CalendarInvitationBundleState _bundleProposalState(
    EventStorageProposal proposal,
    RecurrenceWorkBudget work,
  ) => _schedulingValue(
    () => invitationBundleBaseline(
      proposal.importBaseline,
      protocolUid: proposal.protocolUid,
      sharedWorkBudget: work,
    ),
  );

  Future<(CalendarInvitationSourceRecord?, IcalendarSchedulingMessage?)>
  _bundleBody(
    CalendarInvitationApplicationState accepted,
    CalendarInvitationLinkRecord link,
    CalendarInvitationRecipient recipient,
    _Event event,
    Transaction tx,
    RecurrenceWorkBudget work,
  ) async {
    final body = await _invAcceptedBody(
      accepted,
      link,
      recipient,
      tx,
      sharedWorkBudget: work,
    );
    if (body.$2 != null &&
        accepted.kind == CalendarInvitationSourceKind.bundleCancellation) {
      _schedulingValue(
        () => validateInvitationBundleCancellation(
          accepted: _bundleState(event, work: work),
          incoming: body.$2!,
          recipientAddress: recipient.calendarAddress,
          sharedWorkBudget: work,
        ),
      );
    } else if (body.$2 != null) {
      final proposal = _schedulingValue(
        () => invitationRequestBundleProposal(body.$2!, sharedWorkBudget: work),
      );
      if (proposal.importBaseline.canonicalValue !=
          event.data.importBaseline!.canonicalValue) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }
    return body;
  }

  Future<void> _bundleHost(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    required CalendarInvitationOperation operation,
    CalendarInvitationRecord? entry,
    CalendarInvitationLinkRecord? link,
    _Event? event,
    CalendarInvitationApplicationState? accepted,
    CalendarInvitationApplicationState? next,
    CalendarInvitationSourceRecord? source,
    IcalendarSchedulingMessage? message,
    CalendarEventPolicySnapshot? before,
    CalendarInvitationView? previousEntry,
    CalendarEventPolicySnapshot? proposed,
    CalendarInvitationApplyRequest? input,
    CalendarInvitationApplyReceipt? receipt,
    CalendarEventImportBaseline? baseline,
    CalendarInvitationBundleApplicationView? view,
    CalendarInvitationBundleEvidence? evidence,
    UuidValue? lookupId,
    bool retry = false,
    bool? historicalUnavailable,
    bool? dirty,
  }) async {
    final current =
        previousEntry ?? (entry == null ? null : await _invView(entry, tx));
    for (final op in [
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readLink,
      CalendarInvitationOperation.readBundleApplication,
      if (operation == CalendarInvitationOperation.applyBundleUpdate ||
          operation == CalendarInvitationOperation.applyBundleCancellation ||
          operation == CalendarInvitationOperation.reopenBundle)
        operation,
      if (operation == CalendarInvitationOperation.reopenBundle)
        CalendarInvitationOperation.applyBundleUpdate,
    ]) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: op,
          recipient: recipient,
          actor: actor,
          current: current,
          entryId: input?.invitationId ?? entry?.id ?? lookupId,
          link: link == null ? null : _invLinkReceipt(link),
          linkSource: link == null ? null : _invLinkSource(link),
          calendar: event?.parent.snapshot,
          currentEvent: before ?? event?.snapshot,
          proposedEvent: proposed,
          currentApplication: accepted,
          proposedApplication: next,
          applyRequest: input,
          applicationReceipt: receipt,
          proposedBaseline: baseline,
          localChanges: dirty,
          isRetry: retry,
          sourceId: source?.id ?? input?.sourceId ?? accepted?.sourceId,
          message: message,
          normalizedSource: source?.normalizedSource,
          sourceDigest: source?.digest ?? accepted?.digest,
          bundleApplication: view,
          bundleEvidence: evidence,
          historicalSourceUnavailable:
              historicalUnavailable ?? (message == null ? null : false),
          proposedRevision: next?.invitationRevision,
          proposedDismissed: next == null ? null : true,
        ),
        tx,
        phase,
      );
    }
  }

  Future<CalendarInvitationBundleApplicationView> invitationBundleApplication(
    UuidValue id,
  ) => _invNativeScoped((actor, recipient, tx, scope) async {
    final entry = await _invOptionalEntry(id, recipient, tx);
    await _bundleHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readBundleApplication,
      entry: entry,
      lookupId: id,
    );
    final link = await _bundleLink(id, entry, recipient, tx);
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final event = await _invLinkedEvent(
      link,
      actor,
      tx,
      sharedWorkBudget: work,
    );
    await _invApplicationNative(
      actor,
      event,
      tx,
      CalendarAuthorizationPhase.read,
    );
    final row = await _invCheckpoint(link, event, tx, sharedWorkBudget: work);
    final accepted = await _invApplicationState(link, event, row, tx);
    final old = _bundleState(event, work: work);
    final body = await _bundleBody(accepted, link, recipient, event, tx, work);
    final dirty = _bundleDirty(event, accepted, work);
    CalendarInvitationSourceRecord? source;
    IcalendarSchedulingMessage? message;
    _BundleCandidate? proposal;
    List<CalendarInvitationBundleComponentVersion>? incoming;
    var advance = false;
    if (entry?.currentSourceId != null && entry?.dismissedAt == null) {
      source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        entry!.currentSourceId!,
        transaction: tx,
      );
      if (source == null) throw _failure(CalendarFailureCode.unavailable);
      message = _invStored(source, entry, sharedWorkBudget: work);
      proposal = _bundleCandidate(message, event, work);
      incoming = _bundleIncomingVersions(message, proposal, work);
      advance = _bundleAdmission(
        old,
        accepted,
        message,
        source.digest,
        recipient,
        work,
      );
    }
    final evidence = CalendarInvitationBundleEvidence(
      accepted: old.versions,
      incoming: incoming ?? [],
    );
    final cancellation = message?.method == IcalendarSchedulingMethod.cancel;
    final reopening =
        accepted.kind == CalendarInvitationSourceKind.bundleCancellation &&
        !cancellation;
    final operation = cancellation
        ? CalendarInvitationOperation.applyBundleCancellation
        : reopening
        ? CalendarInvitationOperation.reopenBundle
        : CalendarInvitationOperation.applyBundleUpdate;
    var canApply = !dirty && advance;
    if (canApply) {
      final member = CalendarEventImportMember(
        eventId: event.identity.id!,
        protocolUid: proposal!.protocolUid,
        content: proposal.content,
        timingOverrides: proposal.edits,
        protocolState: proposal.protocolState,
      );
      try {
        await _invApplicationNative(
          actor,
          event,
          tx,
          CalendarAuthorizationPhase.read,
          writing: true,
          member: member,
          cancellation: cancellation || reopening,
        );
        await _bundleHost(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.read,
          operation: operation,
          entry: entry,
          link: link,
          event: event,
          accepted: accepted,
          source: source,
          message: message,
          evidence: evidence,
          dirty: dirty,
          proposed: _bundleSnapshot(
            event,
            member,
            event.identity.revision + 1,
            event.data.updatedAt,
          ),
        );
      } on CalendarException catch (e) {
        if (e.code != CalendarFailureCode.accessDenied) rethrow;
        canApply = false;
      }
    }
    final view = CalendarInvitationBundleApplicationView(
      linkId: link.id!,
      invitationId: id,
      calendarId: link.calendarId,
      eventId: link.eventId,
      calendarRevision: event.parent.identity.revision,
      eventRevision: event.identity.revision,
      applicationRevision: accepted.revision,
      acceptedInvitationId: accepted.invitationId,
      acceptedSourceId: accepted.sourceId,
      acceptedAt: accepted.appliedAt,
      acceptedKind: accepted.kind,
      acceptedCancellationVersion: _bundleCancellationVersion(accepted),
      incomingKind: message == null
          ? null
          : _invKind(message, bundleProfile: true),
      canApplyCancellation: canApply && cancellation,
      canReopen: canApply && reopening,
      acceptedComponents: old.versions,
      acceptedSourceUnavailable: body.$1 == null,
      currentContent: event.data.content,
      currentOverrides: event.data.timingOverrides,
      hasLocalChanges: dirty,
      incomingSourceId: source?.id,
      invitationRevision: entry?.revision,
      incomingContent: proposal?.content,
      incomingOverrides: proposal?.edits,
      incomingSourceText: source?.normalizedSource,
      incomingComponents: incoming,
      canApply: canApply && !cancellation && !reopening,
      latestResult: accepted.latestResult,
    );
    await _bundleHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readBundleApplication,
      entry: entry,
      link: link,
      event: event,
      accepted: accepted,
      source: source ?? body.$1,
      message: message ?? body.$2,
      evidence: evidence,
      view: view,
      historicalUnavailable: body.$1 == null,
      dirty: dirty,
      lookupId: id,
    );
    return view;
  });

  CalendarEventPolicySnapshot _bundleSnapshot(
    _Event event,
    CalendarEventImportMember member,
    int revision,
    DateTime time,
  ) => CalendarEventPolicySnapshot(
    event.identity.id!,
    event.parent.identity.id!,
    revision,
    member.content,
    member.protocolUid,
    time,
    origin: CalendarEventOrigin.imported,
    timingOverrides: member.timingOverrides,
    protocolState: member.protocolState,
  );

  Future<void> _bundleRetryNative(
    CalendarHostContext actor,
    _Event event,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    bool lifecycle = false,
  }) async {
    await _invApplicationNative(
      actor,
      event,
      tx,
      phase,
      writing: true,
      cancellation: lifecycle,
    );
    final request = CalendarAuthorizationRequest(
      key: 'bundle-update:${event.identity.id}',
      operation: CalendarPermission.updateEvent,
      calendarId: event.parent.identity.id,
      current: event.parent.snapshot,
      eventId: event.identity.id,
      currentEvent: event.snapshot,
      eventGroups: CalendarEventFieldGroup.values,
    );
    final decisions = phase == CalendarAuthorizationPhase.finalWrite
        ? await _final(actor, [request], tx)
        : await _decide(actor, [request], tx, phase);
    if (phase == CalendarAuthorizationPhase.finalWrite &&
        !decisions[request.key]!.discloseMutationReceipt) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
  }

  Future<CalendarInvitationApplyReceipt> applyInvitationBundleUpdate(
    CalendarInvitationApplyRequest input,
  ) => _applyInvitationBundle(input);
  Future<CalendarInvitationApplyReceipt> applyInvitationBundleCancellation(
    CalendarInvitationApplyRequest input,
  ) => _applyInvitationBundle(input, cancellation: true);
  Future<CalendarInvitationApplyReceipt> applyInvitationBundleReopening(
    CalendarInvitationApplyRequest input,
  ) => _applyInvitationBundle(input, reopening: true);

  Future<CalendarInvitationApplyReceipt> _applyInvitationBundle(
    CalendarInvitationApplyRequest input, {
    bool cancellation = false,
    bool reopening = false,
  }) {
    final operation = cancellation
        ? CalendarInvitationOperation.applyBundleCancellation
        : reopening
        ? CalendarInvitationOperation.reopenBundle
        : CalendarInvitationOperation.applyBundleUpdate;
    final kind = cancellation
        ? CalendarInvitationSourceKind.bundleCancellation
        : CalendarInvitationSourceKind.requestBundle;
    if (input.expectedOccurrenceRevision != 0 ||
        [
          input.expectedInvitationRevision,
          input.expectedEventRevision,
          input.expectedCalendarRevision,
        ].any((v) => v < 1 || v > CalendarService._maxRevision) ||
        input.expectedApplicationRevision < 0 ||
        input.expectedApplicationRevision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    final digest = _invitationHash([
      cancellation
          ? 'bundle-cancel-v1'
          : reopening
          ? 'bundle-reopen-v1'
          : 'bundle-update-v1',
      input.invitationId.toString(),
      input.sourceId.toString(),
      '${input.expectedInvitationRevision}',
      input.linkId.toString(),
      '${input.expectedEventRevision}',
      '${input.expectedCalendarRevision}',
      '${input.expectedApplicationRevision}',
    ]);
    return _invNativeScoped((actor, recipient, tx, scope) async {
      final entry = await _invOptionalEntry(input.invitationId, recipient, tx);
      await _bundleHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        entry: entry,
        input: input,
      );
      final link = await _bundleLink(
        input.invitationId,
        entry,
        recipient,
        tx,
        retryLinkId: input.linkId,
      );
      if (link.id != input.linkId) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
      final event = await _invLinkedEvent(
        link,
        actor,
        tx,
        sharedWorkBudget: work,
      );
      final before = event.snapshot;
      final row = await _invCheckpoint(link, event, tx, sharedWorkBudget: work);
      final accepted = await _invApplicationState(link, event, row, tx);
      await _bundleRetryNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        lifecycle: cancellation || reopening,
      );
      final old = _bundleState(event, work: work);
      final dirty = _bundleDirty(event, accepted, work);
      final body = await _bundleBody(
        accepted,
        link,
        recipient,
        event,
        tx,
        work,
      );
      if (row?.requestDigest == digest) {
        if (row!.kind != kind ||
            row.eventRevision != input.expectedEventRevision + 1 ||
            row.invitationRevision != input.expectedInvitationRevision + 1 ||
            row.revision != input.expectedApplicationRevision + 1 ||
            row.invitationId != input.invitationId ||
            row.sourceId != input.sourceId) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final receipt = _invApplyReceipt(link, row);
        final evidence = CalendarInvitationBundleEvidence(
          accepted: old.versions,
          incoming: cancellation
              ? [_bundleCancellationVersion(accepted)!]
              : old.versions,
        );
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _bundleRetryNative(
            actor,
            event,
            tx,
            phase,
            lifecycle: cancellation || reopening,
          );
          await _bundleHost(
            actor,
            recipient,
            tx,
            phase,
            operation: operation,
            entry: entry,
            link: link,
            event: event,
            accepted: accepted,
            input: input,
            receipt: receipt,
            source: body.$1,
            message: body.$2,
            historicalUnavailable: body.$1 == null,
            retry: true,
            evidence: evidence,
            dirty: dirty,
          );
        }
        return receipt;
      }
      if (entry == null ||
          entry.kind != kind ||
          entry.dismissedAt != null ||
          entry.currentSourceId != input.sourceId ||
          entry.revision != input.expectedInvitationRevision ||
          event.identity.revision != input.expectedEventRevision ||
          event.parent.identity.revision != input.expectedCalendarRevision ||
          accepted.revision != input.expectedApplicationRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        input.sourceId,
        transaction: tx,
      );
      if (source == null || source.entryId != entry.id) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final message = _invStored(source, entry, sharedWorkBudget: work);
      if ((accepted.kind == CalendarInvitationSourceKind.bundleCancellation) !=
              reopening &&
          !cancellation) {
        throw _failure(CalendarFailureCode.validation);
      }
      final proposal = _bundleCandidate(message, event, work);
      final advance = _bundleAdmission(
        old,
        accepted,
        message,
        source.digest,
        recipient,
        work,
      );
      final evidence = CalendarInvitationBundleEvidence(
        accepted: old.versions,
        incoming: _bundleIncomingVersions(message, proposal, work),
      );
      final member = CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: proposal.protocolUid,
        content: proposal.content,
        timingOverrides: proposal.edits,
        protocolState: proposal.protocolState,
      );
      if (event.identity.revision == CalendarService._maxRevision ||
          entry.revision == CalendarService._maxRevision ||
          accepted.revision == CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final previous = event.data.updatedAt.isAfter(entry.updatedAt)
          ? event.data.updatedAt
          : entry.updatedAt;
      final now = await _revisionTime(tx, previous: previous);
      final next = CalendarInvitationApplicationRecord(
        kind: kind,
        id: row?.id ?? const Uuid().v4obj(),
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        linkId: link.id!,
        revision: accepted.revision + 1,
        invitationId: entry.id!,
        sourceId: source.id!,
        digest: source.digest,
        sequence: source.sequence,
        stamp: source.stamp,
        baselineDigest: _invBaselineDigest(proposal.importBaseline),
        creationDigest: _invCreationDigest(link),
        eventRevision: event.identity.revision + 1,
        invitationRevision: entry.revision + 1,
        appliedAt: now,
        requestDigest: digest,
        resultId: const Uuid().v4obj(),
      );
      final receipt = _invApplyReceipt(link, next);
      final proposed = _bundleSnapshot(event, member, next.eventRevision, now);
      final previousEntry = await _invView(entry, tx);
      final nextState = CalendarInvitationApplicationState(
        kind: next.kind,
        linkId: link.id!,
        revision: next.revision,
        invitationId: next.invitationId,
        sourceId: next.sourceId,
        digest: next.digest,
        sequence: next.sequence,
        stamp: next.stamp,
        baselineDigest: next.baselineDigest,
        eventRevision: next.eventRevision,
        invitationRevision: next.invitationRevision,
        appliedAt: now,
        latestResult: receipt,
      );
      await _bundleHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        entry: entry,
        link: link,
        event: event,
        accepted: accepted,
        next: nextState,
        input: input,
        receipt: receipt,
        source: source,
        message: message,
        evidence: evidence,
        dirty: dirty,
        proposed: proposed,
        before: before,
        previousEntry: previousEntry,
        baseline: proposal.importBaseline,
        historicalUnavailable: body.$1 == null,
      );
      if (dirty || !advance) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        member: member,
        cancellation: cancellation || reopening,
        before: before,
      );
      await _invCleanup(recipient, tx, now);
      if ((await _invEntries(
            recipient,
            tx,
          )).where((e) => e.dismissedAt != null).length >=
          _invOptions.maxDismissed) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      event.data.content = member.content;
      event.data.timingOverrides = member.timingOverrides;
      event.data.protocolState = member.protocolState;
      event.data.importBaseline = proposal.importBaseline;
      event.data.updatedAt = now;
      event.identity.revision = next.eventRevision;
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
      if (row == null) {
        await CalendarInvitationApplicationRecord.db.insertRow(
          _session,
          next,
          transaction: tx,
        );
      } else {
        await CalendarInvitationApplicationRecord.db.updateRow(
          _session,
          next,
          transaction: tx,
        );
      }
      entry.revision = next.invitationRevision;
      entry.dismissedAt = now;
      entry.updatedAt = now;
      source.inactiveAt = now;
      await CalendarInvitationRecord.db.updateRow(
        _session,
        entry,
        transaction: tx,
      );
      await CalendarInvitationSourceRecord.db.updateRow(
        _session,
        source,
        transaction: tx,
      );
      await _bump(scope, tx, publishedEventCalendar: link.calendarId);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        writing: true,
        member: member,
        cancellation: cancellation || reopening,
        before: before,
      );
      await _bundleHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        operation: operation,
        entry: entry,
        link: link,
        event: event,
        accepted: accepted,
        next: nextState,
        input: input,
        receipt: receipt,
        source: source,
        message: message,
        evidence: evidence,
        dirty: dirty,
        proposed: proposed,
        before: before,
        previousEntry: previousEntry,
        baseline: proposal.importBaseline,
        historicalUnavailable: body.$1 == null,
      );
      return receipt;
    });
  }
}
