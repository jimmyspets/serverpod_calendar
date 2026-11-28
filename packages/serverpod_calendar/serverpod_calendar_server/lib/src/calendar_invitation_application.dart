part of 'calendar_module.dart';

int _invSourceOrder(
  int? sequence,
  DateTime stamp,
  int? previousSequence,
  DateTime previousStamp,
) {
  final order = (sequence ?? 0).compareTo(previousSequence ?? 0);
  return order == 0 ? stamp.compareTo(previousStamp) : order;
}

extension CalendarInvitationApplicationOperations on CalendarService {
  String _invCreationDigest(CalendarInvitationLinkRecord r) => _invitationHash([
    r.id.toString(),
    r.scopeKey,
    r.recipientKey,
    r.uid,
    r.organizer,
    r.correlationDigest,
    r.invitationId.toString(),
    r.sourceId.toString(),
    r.sourceDigest,
    '${r.sequence}',
    r.stamp.toUtc().toIso8601String(),
    r.calendarId.toString(),
    r.eventId.toString(),
    r.requestDigest,
    '${r.eventRevision}',
    '${r.invitationRevision}',
    r.adoptedAt.toUtc().toIso8601String(),
  ]);
  String _invBaselineDigest(CalendarEventImportBaseline b) =>
      _invitationHash([b.profile, b.canonicalValue]);
  bool _invLocalChanges(_Event e) => _eventProtocolValue(
    () =>
        eventImportBaseline(
          e.data.protocolUid,
          e.data.content,
          e.data.timingOverrides,
          e.data.protocolState!,
        ).canonicalValue !=
        e.data.importBaseline!.canonicalValue,
  );

  Future<CalendarInvitationApplicationRecord?> _invCheckpoint(
    CalendarInvitationLinkRecord link,
    _Event event,
    Transaction tx,
  ) async {
    final row = await CalendarInvitationApplicationRecord.db.findFirstRow(
      _session,
      where: (t) => t.linkId.equals(link.id!),
      transaction: tx,
    );
    final baseline = event.data.importBaseline!;
    final decoded = jsonDecode(baseline.canonicalValue) as Map<String, dynamic>;
    final protocol = decoded['protocol'] as Map<String, dynamic>;
    final version = protocol['version'] as Map<String, dynamic>;
    final organizer =
        (protocol['sourceMetadata'] as Map<String, dynamic>?)?['organizer']
            as Map<String, dynamic>?;
    // Preserve an omitted accepted sequence instead of falling back to creation.
    final sequence = row == null ? link.sequence : row.sequence;
    final stamp = row?.stamp ?? link.stamp;
    final kind = row?.kind ?? CalendarInvitationSourceKind.request;
    final content = decoded['content'] as Map<String, dynamic>;
    if ((kind == CalendarInvitationSourceKind.meetingCancellation &&
            (content['status'] != 'cancelled' ||
                protocol['statusPresent'] != true ||
                sequence == null ||
                content['recurrence'] != null)) ||
        (kind == CalendarInvitationSourceKind.request &&
            content['status'] == 'cancelled') ||
        version['sequence'] != sequence ||
        DateTime.tryParse(version['stamp'] as String? ?? '') != stamp ||
        organizer?['address'] != link.organizer) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (row != null &&
        (row.scopeKey != link.scopeKey ||
            row.recipientKey != link.recipientKey ||
            row.revision < 1 ||
            row.revision > CalendarService._maxRevision ||
            row.eventRevision < 2 ||
            row.eventRevision > event.identity.revision ||
            row.invitationRevision < 2 ||
            row.invitationRevision > CalendarService._maxRevision ||
            row.creationDigest != _invCreationDigest(link) ||
            row.baselineDigest != _invBaselineDigest(baseline) ||
            _invSourceOrder(
                  row.sequence,
                  row.stamp,
                  link.sequence,
                  link.stamp,
                ) <=
                0 ||
            [
              row.digest,
              row.requestDigest,
            ].any((s) => !RegExp(r'^[0-9a-f]{64}$').hasMatch(s)))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return row;
  }

  CalendarInvitationApplyReceipt _invApplyReceipt(
    CalendarInvitationLinkRecord link,
    CalendarInvitationApplicationRecord r,
  ) => CalendarInvitationApplyReceipt(
    kind: r.kind,
    id: r.resultId,
    linkId: link.id!,
    invitationId: r.invitationId,
    sourceId: r.sourceId,
    calendarId: link.calendarId,
    eventId: link.eventId,
    applicationRevision: r.revision,
    eventRevision: r.eventRevision,
    invitationRevision: r.invitationRevision,
    appliedAt: r.appliedAt,
  );

  CalendarInvitationApplicationState _invApplicationState(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationApplicationRecord? r,
  ) => CalendarInvitationApplicationState(
    kind: r?.kind ?? CalendarInvitationSourceKind.request,
    linkId: link.id!,
    revision: r?.revision ?? 0,
    invitationId: r?.invitationId ?? link.invitationId,
    sourceId: r?.sourceId ?? link.sourceId,
    digest: r?.digest ?? link.sourceDigest,
    sequence: r == null ? link.sequence : r.sequence,
    stamp: r?.stamp ?? link.stamp,
    baselineDigest:
        r?.baselineDigest ?? _invBaselineDigest(event.data.importBaseline!),
    eventRevision: r?.eventRevision ?? link.eventRevision,
    invitationRevision: r?.invitationRevision ?? link.invitationRevision,
    appliedAt: r?.appliedAt ?? link.adoptedAt,
    latestResult: r == null ? null : _invApplyReceipt(link, r),
  );

  Future<void> _invApplicationHost(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    required CalendarInvitationOperation operation,
    CalendarInvitationView? view,
    CalendarInvitationLinkRecord? link,
    _Active? parent,
    CalendarEventPolicySnapshot? current,
    CalendarEventPolicySnapshot? proposed,
    CalendarInvitationSourceRecord? source,
    IcalendarSchedulingMessage? message,
    CalendarInvitationApplicationState? accepted,
    CalendarInvitationApplicationState? next,
    CalendarInvitationApplyRequest? input,
    CalendarInvitationApplyReceipt? receipt,
    CalendarEventImportBaseline? baseline,
    bool? dirty,
    bool retry = false,
    UuidValue? lookupId,
    bool? historicalUnavailable,
  }) async {
    for (final op in [
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readLink,
      CalendarInvitationOperation.readApplication,
      if ({
        CalendarInvitationOperation.apply,
        CalendarInvitationOperation.applyCancellation,
      }.contains(operation))
        operation,
    ]) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: op,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: input?.invitationId ?? view?.id ?? lookupId,
          sourceId: source?.id ?? input?.sourceId ?? accepted?.sourceId,
          message: message,
          normalizedSource: source?.normalizedSource,
          sourceDigest: source?.digest ?? accepted?.digest,
          link: link == null ? null : _invLinkReceipt(link),
          linkSource: link == null ? null : _invLinkSource(link),
          calendar: parent?.snapshot,
          currentEvent: current,
          proposedEvent: proposed,
          applyRequest: input,
          currentApplication: accepted,
          proposedApplication: next,
          applicationReceipt: receipt,
          proposedBaseline: baseline,
          localChanges: dirty,
          isRetry: retry,
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

  Future<void> _invApplicationNative(
    CalendarHostContext actor,
    _Event event,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    bool writing = false,
    bool cancellation = false,
    CalendarEventImportMember? member,
    CalendarEventPolicySnapshot? before,
  }) async {
    final current = before ?? event.snapshot;
    final oldMetadata = current.protocolState!;
    final intent = member == null
        ? null
        : CalendarEventReplacementIntent([
            CalendarEventReplacementMember(
              current: current,
              proposed: member,
              baselineProfile: event.data.importBaseline!.profile,
              baselineSequence: oldMetadata.version.sequence,
              changed: true,
              localChanges: false,
            ),
          ]);
    final operations = [
      if (writing) ...[
        CalendarPermission.importEvents,
        CalendarPermission.replaceEventsFromImport,
      ],
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      if (writing && cancellation) CalendarPermission.changeEventStatus,
      if (member != null || writing && cancellation)
        CalendarPermission.updateEvent,
      if (member != null) ...[
        if (itemTextChanges(
              eventTextState(oldMetadata, current.timingOverrides),
              eventTextState(member.protocolState, member.timingOverrides),
            ) !=
            null)
          CalendarPermission.updateEventTextMetadata,
        if (eventDescriptiveState(
              oldMetadata.sourceMetadata,
              current.timingOverrides,
            ) !=
            eventDescriptiveState(
              member.protocolState.sourceMetadata,
              member.timingOverrides,
            ))
          CalendarPermission.updateEventDescriptiveMetadata,
        if (!cancellation && current.content.status != member.content.status)
          CalendarPermission.changeEventStatus,
      ],
    ];
    final requests = [
      for (final op in operations)
        CalendarAuthorizationRequest(
          key: '${op.name}:${event.identity.id}',
          operation: op,
          calendarId: event.parent.identity.id,
          current: event.parent.snapshot,
          eventId: event.identity.id,
          currentEvent: current,
          proposedEvent: member?.content,
          proposedEventProtocolState: member?.protocolState,
          proposedTimingOverrides: member?.timingOverrides,
          eventReplacement: intent,
          eventGroups: CalendarEventFieldGroup.values,
        ),
    ];
    for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
      final chunk = requests.sublist(
        i,
        min(i + _options.policyBatchSize, requests.length),
      );
      final decisions = phase == CalendarAuthorizationPhase.finalWrite
          ? await _final(actor, chunk, tx)
          : await _decide(actor, chunk, tx, phase);
      for (final request in chunk) {
        final d = decisions[request.key]!;
        if (request.operation == CalendarPermission.readEvent &&
            !d.eventDisclosedGroups.containsAll(
              CalendarEventFieldGroup.values,
            )) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        if (writing &&
            phase == CalendarAuthorizationPhase.finalWrite &&
            request.operation != CalendarPermission.readEvent &&
            request.operation != CalendarPermission.readEventSource &&
            !d.discloseMutationReceipt) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      }
    }
  }

  Future<(CalendarInvitationSourceRecord?, IcalendarSchedulingMessage?)>
  _invAcceptedBody(
    CalendarInvitationApplicationState state,
    CalendarInvitationLinkRecord link,
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final source = await CalendarInvitationSourceRecord.db.findById(
      _session,
      state.sourceId,
      transaction: tx,
    );
    if (source == null) return (null, null);
    final entry = await _invOptionalEntry(state.invitationId, recipient, tx);
    if (entry == null ||
        entry.uid != link.uid ||
        entry.organizer != link.organizer ||
        source.digest != state.digest ||
        source.sequence != state.sequence ||
        source.stamp != state.stamp) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final message = _invStored(source, entry);
    if (_invKind(message) != state.kind) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return (source, message);
  }

  Future<CalendarInvitationApplicationView> invitationApplication(
    UuidValue id,
  ) => _invNative((actor, recipient, tx) async {
    final entry = await _invOptionalEntry(id, recipient, tx),
        view = entry == null ? null : await _invView(entry, tx);
    await _invApplicationHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readApplication,
      view: view,
      lookupId: id,
    );
    final link = await _invFindLink(id, entry, recipient, tx);
    if (link == null) throw _failure(CalendarFailureCode.accessDenied);
    final event = await _invLinkedEvent(link, actor, tx);
    final accepted = _invApplicationState(
      link,
      event,
      await _invCheckpoint(link, event, tx),
    );
    await _invApplicationNative(
      actor,
      event,
      tx,
      CalendarAuthorizationPhase.read,
    );
    final dirty = _invLocalChanges(event);
    CalendarInvitationSourceRecord? source;
    IcalendarSchedulingMessage? message;
    CalendarEventImportMember? incoming;
    if (entry?.currentSourceId != null) {
      source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        entry!.currentSourceId!,
        transaction: tx,
      );
      if (source == null) throw _failure(CalendarFailureCode.unavailable);
      message = _invStored(source, entry);
      if (message.method == IcalendarSchedulingMethod.request) {
        incoming = _invImportMember(message, link.eventId);
      }
    } else {
      (source, message) = await _invAcceptedBody(accepted, link, recipient, tx);
    }
    await _invApplicationHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readApplication,
      view: view,
      link: link,
      parent: event.parent,
      current: event.snapshot,
      source: source,
      message: message,
      accepted: accepted,
      dirty: dirty,
      lookupId: id,
      historicalUnavailable: source == null,
    );
    return CalendarInvitationApplicationView(
      linkId: link.id!,
      invitationId: id,
      calendarId: link.calendarId,
      eventId: link.eventId,
      calendarRevision: event.parent.identity.revision,
      eventRevision: event.identity.revision,
      applicationRevision: accepted.revision,
      acceptedKind: accepted.kind,
      acceptedInvitationId: accepted.invitationId,
      acceptedSourceId: accepted.sourceId,
      acceptedSequence: accepted.sequence,
      acceptedStamp: accepted.stamp,
      acceptedAt: accepted.appliedAt,
      hasLocalChanges: dirty,
      currentContent: event.data.content,
      currentVersion: event.data.protocolState!.version,
      incomingKind: entry?.currentSourceId == null || message == null
          ? null
          : _invKind(message),
      incomingSourceId: entry?.currentSourceId == null ? null : source?.id,
      invitationRevision: entry?.revision,
      incomingContent: incoming?.content,
      incomingSourceText: entry?.currentSourceId == null
          ? null
          : source?.normalizedSource,
      canApplyCancellation:
          entry?.currentSourceId != null &&
          message?.method == IcalendarSchedulingMethod.cancel &&
          entry!.dismissedAt == null &&
          !dirty &&
          event.data.content.recurrence == null &&
          _invSourceOrder(
                source!.sequence,
                source.stamp,
                accepted.sequence,
                accepted.stamp,
              ) >
              0 &&
          (accepted.kind == CalendarInvitationSourceKind.meetingCancellation ||
              (source.sequence ?? 0) > (accepted.sequence ?? 0)),
      canApply:
          incoming != null &&
          entry!.dismissedAt == null &&
          !dirty &&
          _invSourceOrder(
                source!.sequence,
                source.stamp,
                accepted.sequence,
                accepted.stamp,
              ) >
              0,
      latestResult: accepted.latestResult,
    );
  });

  CalendarEventImportMember _invCancellationMember(
    IcalendarSchedulingMessage message,
    _Event event,
  ) => _eventProtocolValue(() {
    if (message.method != IcalendarSchedulingMethod.cancel ||
        event.data.content.recurrence != null ||
        message.events.single.status != IcalendarEventStatus.cancelled) {
      throw _failure(CalendarFailureCode.validation);
    }
    final source = message.events.single;
    final content = validateEventContent(
      event.data.content.copyWith(status: CalendarEventStatus.cancelled),
    );
    final state = validateEventProtocolState(
      event.data.protocolState!.copyWith(
        statusPresent: true,
        version: CalendarEventProtocolVersion(
          sequence: source.sequence,
          stamp: source.stamp,
          created: source.created,
          lastModified: source.lastModified,
        ),
      ),
      content,
      event.data.timingOverrides,
    );
    return CalendarEventImportMember(
      eventId: event.identity.id!,
      protocolUid: event.data.protocolUid,
      content: content,
      protocolState: state,
      timingOverrides: event.data.timingOverrides,
    );
  });

  Future<CalendarInvitationApplyReceipt> applyInvitationUpdate(
    CalendarInvitationApplyRequest input,
  ) => _applyInvitationSource(input, cancellation: false);
  Future<CalendarInvitationApplyReceipt> applyInvitationCancellation(
    CalendarInvitationApplyRequest input,
  ) => _applyInvitationSource(input, cancellation: true);
  Future<CalendarInvitationApplyReceipt> _applyInvitationSource(
    CalendarInvitationApplyRequest input, {
    required bool cancellation,
  }) {
    final kind = cancellation
        ? CalendarInvitationSourceKind.meetingCancellation
        : CalendarInvitationSourceKind.request;
    final operation = cancellation
        ? CalendarInvitationOperation.applyCancellation
        : CalendarInvitationOperation.apply;
    if ([
          input.expectedInvitationRevision,
          input.expectedEventRevision,
          input.expectedCalendarRevision,
        ].any((r) => r < 1 || r > CalendarService._maxRevision) ||
        input.expectedApplicationRevision < 0 ||
        input.expectedApplicationRevision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    final requestDigest = _invitationHash([
      if (cancellation) 'apply-cancellation-v1',
      input.invitationId.toString(),
      input.sourceId.toString(),
      '${input.expectedInvitationRevision}',
      input.linkId.toString(),
      '${input.expectedEventRevision}',
      '${input.expectedCalendarRevision}',
      '${input.expectedApplicationRevision}',
    ]);
    return _invNativeScoped((actor, recipient, tx, scope) async {
      final entry = await _invOptionalEntry(input.invitationId, recipient, tx),
          view = entry == null ? null : await _invView(entry, tx);
      await _invApplicationHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        input: input,
      );
      var link = await _invFindLink(input.invitationId, entry, recipient, tx);
      if (link == null && entry == null) {
        // A retained latest command carries the durable link even when a
        // later inbox epoch has been pruned. It must still pass full authority
        // and exact digest checks; no new write may use a missing entry.
        final candidate = await CalendarInvitationLinkRecord.db.findById(
          _session,
          input.linkId,
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
          );
        }
      }
      if (link == null || link.id != input.linkId) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final event = await _invLinkedEvent(link, actor, tx),
          before = event.snapshot;
      final checkpoint = await _invCheckpoint(link, event, tx),
          accepted = _invApplicationState(link, event, checkpoint);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation,
      );
      final dirty = _invLocalChanges(event);
      if (checkpoint != null && checkpoint.requestDigest == requestDigest) {
        if (checkpoint.kind != kind) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final (source, message) = await _invAcceptedBody(
          accepted,
          link,
          recipient,
          tx,
        );
        final receipt = _invApplyReceipt(link, checkpoint);
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _invApplicationNative(
            actor,
            event,
            tx,
            phase,
            writing: true,
            cancellation: cancellation,
          );
          await _invApplicationHost(
            actor,
            recipient,
            tx,
            phase,
            operation: operation,
            view: view,
            link: link,
            parent: event.parent,
            current: before,
            source: source,
            message: message,
            accepted: accepted,
            input: input,
            receipt: receipt,
            dirty: dirty,
            retry: true,
            historicalUnavailable: source == null,
          );
        }
        return receipt;
      }
      await _invApplicationHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        parent: event.parent,
        current: before,
        accepted: accepted,
        input: input,
      );
      if (entry == null ||
          entry.revision != input.expectedInvitationRevision ||
          entry.currentSourceId != input.sourceId ||
          entry.dismissedAt != null ||
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
      final message = _invStored(source, entry);
      if (_invKind(message) != kind ||
          message.uid != link.uid ||
          message.events.single.participants.organizer?.address !=
              link.organizer) {
        throw _failure(CalendarFailureCode.validation);
      }
      final member = cancellation
          ? _invCancellationMember(message, event)
          : _invImportMember(message, event.identity.id!);
      if (member.protocolUid != link.uid ||
          member.protocolState.sourceMetadata?.organizer?.address !=
              link.organizer) {
        throw _failure(CalendarFailureCode.validation);
      }
      final baseline = _eventProtocolValue(
        () => eventImportBaseline(
          member.protocolUid,
          member.content,
          member.timingOverrides,
          member.protocolState,
        ),
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
        id: checkpoint?.id ?? const Uuid().v4obj(),
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        linkId: link.id!,
        revision: accepted.revision + 1,
        invitationId: entry.id!,
        sourceId: source.id!,
        digest: source.digest,
        sequence: source.sequence,
        stamp: source.stamp,
        baselineDigest: _invBaselineDigest(baseline),
        creationDigest: _invCreationDigest(link),
        eventRevision: event.identity.revision + 1,
        invitationRevision: entry.revision + 1,
        appliedAt: now,
        requestDigest: requestDigest,
        resultId: const Uuid().v4obj(),
      );
      final receipt = _invApplyReceipt(link, next);
      final proposed = CalendarEventPolicySnapshot(
        event.identity.id!,
        link.calendarId,
        next.eventRevision,
        member.content,
        member.protocolUid,
        now,
        origin: CalendarEventOrigin.imported,
        timingOverrides: member.timingOverrides,
        protocolState: member.protocolState,
      );
      final nextState = CalendarInvitationApplicationState(
        kind: kind,
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
      await _invApplicationHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        parent: event.parent,
        current: before,
        proposed: proposed,
        source: source,
        message: message,
        accepted: accepted,
        next: nextState,
        input: input,
        receipt: receipt,
        baseline: baseline,
        dirty: dirty,
      );
      if (dirty ||
          (cancellation &&
              accepted.kind == CalendarInvitationSourceKind.request &&
              (source.sequence ?? 0) <= (accepted.sequence ?? 0)) ||
          _invSourceOrder(
                source.sequence,
                source.stamp,
                accepted.sequence,
                accepted.stamp,
              ) <=
              0) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation,
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
      event.data.importBaseline = baseline;
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
      if (checkpoint == null) {
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
        cancellation: cancellation,
        member: member,
        before: before,
      );
      await _invApplicationHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        operation: operation,
        view: view,
        link: link,
        parent: event.parent,
        current: before,
        proposed: proposed,
        source: source,
        message: message,
        accepted: accepted,
        next: nextState,
        input: input,
        receipt: receipt,
        baseline: baseline,
        dirty: false,
      );
      return receipt;
    });
  }
}
