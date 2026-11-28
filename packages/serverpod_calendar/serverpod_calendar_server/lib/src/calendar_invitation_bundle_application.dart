part of 'calendar_module.dart';

extension CalendarInvitationBundleOperations on CalendarService {
  CalendarInvitationBundleState _bundleState(
    _Event event, {
    RecurrenceWorkBudget? work,
  }) => _eventProtocolValue(
    () => invitationBundleBaseline(
      event.data.importBaseline!,
      protocolUid: event.data.protocolUid,
      sharedWorkBudget: work,
    ),
  );

  void _bundleValidateCheckpoint(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationApplicationRecord? row,
  ) {
    final state = _bundleState(event);
    final master = state.versions.singleWhere((v) => v.originalStart == null);
    if (!link.bundledRequest ||
        master.sequence != (row == null ? link.sequence : row.sequence) ||
        master.stamp != (row?.stamp ?? link.stamp)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (row != null &&
        (row.kind != CalendarInvitationSourceKind.requestBundle ||
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
    if (!link.bundledRequest ||
        entry != null &&
            entry.kind != CalendarInvitationSourceKind.requestBundle) {
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
    if (body.$2 != null) {
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
      if (operation == CalendarInvitationOperation.applyBundleUpdate) operation,
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
    final event = await _invLinkedEvent(link, actor, tx);
    await _invApplicationNative(
      actor,
      event,
      tx,
      CalendarAuthorizationPhase.read,
    );
    final row = await _invCheckpoint(link, event, tx);
    final accepted = await _invApplicationState(link, event, row, tx);
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final old = _bundleState(event, work: work);
    final body = await _bundleBody(accepted, link, recipient, event, tx, work);
    final dirty = _invLocalChanges(event);
    CalendarInvitationSourceRecord? source;
    IcalendarSchedulingMessage? message;
    EventStorageProposal? proposal;
    CalendarInvitationBundleState? incoming;
    var advance = false;
    if (entry?.currentSourceId != null && entry?.dismissedAt == null) {
      source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        entry!.currentSourceId!,
        transaction: tx,
      );
      if (source == null) throw _failure(CalendarFailureCode.unavailable);
      message = _invStored(source, entry, sharedWorkBudget: work);
      proposal = _bundleProposal(message, work);
      incoming = _bundleProposalState(proposal, work);
      advance = _schedulingValue(
        () => validateInvitationBundleAdvance(
          old,
          incoming!,
          sharedWorkBudget: work,
        ),
      );
    }
    final evidence = CalendarInvitationBundleEvidence(
      accepted: old.versions,
      incoming: incoming?.versions ?? [],
    );
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
        );
        await _bundleHost(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.read,
          operation: CalendarInvitationOperation.applyBundleUpdate,
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
      incomingComponents: incoming?.versions,
      canApply: canApply,
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
    CalendarAuthorizationPhase phase,
  ) async {
    await _invApplicationNative(actor, event, tx, phase, writing: true);
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
  ) {
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
      'bundle-update-v1',
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
        operation: CalendarInvitationOperation.applyBundleUpdate,
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
      final event = await _invLinkedEvent(link, actor, tx);
      final before = event.snapshot;
      final row = await _invCheckpoint(link, event, tx);
      final accepted = await _invApplicationState(link, event, row, tx);
      await _bundleRetryNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
      final old = _bundleState(event, work: work);
      final dirty = _invLocalChanges(event);
      final body = await _bundleBody(
        accepted,
        link,
        recipient,
        event,
        tx,
        work,
      );
      if (row?.requestDigest == digest) {
        if (row!.eventRevision != input.expectedEventRevision + 1 ||
            row.invitationRevision != input.expectedInvitationRevision + 1 ||
            row.revision != input.expectedApplicationRevision + 1 ||
            row.invitationId != input.invitationId ||
            row.sourceId != input.sourceId) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final receipt = _invApplyReceipt(link, row);
        final evidence = CalendarInvitationBundleEvidence(
          accepted: old.versions,
          incoming: old.versions,
        );
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _bundleRetryNative(actor, event, tx, phase);
          await _bundleHost(
            actor,
            recipient,
            tx,
            phase,
            operation: CalendarInvitationOperation.applyBundleUpdate,
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
          entry.kind != CalendarInvitationSourceKind.requestBundle ||
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
      final proposal = _bundleProposal(message, work);
      final incoming = _bundleProposalState(proposal, work);
      final advance = _schedulingValue(
        () => validateInvitationBundleAdvance(
          old,
          incoming,
          sharedWorkBudget: work,
        ),
      );
      final evidence = CalendarInvitationBundleEvidence(
        accepted: old.versions,
        incoming: incoming.versions,
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
        kind: CalendarInvitationSourceKind.requestBundle,
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
        operation: CalendarInvitationOperation.applyBundleUpdate,
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
        before: before,
      );
      await _bundleHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        operation: CalendarInvitationOperation.applyBundleUpdate,
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
