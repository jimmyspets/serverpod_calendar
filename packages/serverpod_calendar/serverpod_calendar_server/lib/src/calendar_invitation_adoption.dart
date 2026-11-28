part of 'calendar_module.dart';

extension CalendarInvitationAdoptionOperations on CalendarService {
  CalendarInvitationAdoptionReceipt _invLinkReceipt(
    CalendarInvitationLinkRecord r,
  ) => CalendarInvitationAdoptionReceipt(
    id: r.id!,
    invitationId: r.invitationId,
    sourceId: r.sourceId,
    calendarId: r.calendarId,
    eventId: r.eventId,
    eventRevision: r.eventRevision,
    invitationRevision: r.invitationRevision,
    adoptedAt: r.adoptedAt,
  );

  CalendarInvitationLinkSource _invLinkSource(CalendarInvitationLinkRecord r) =>
      CalendarInvitationLinkSource(
        invitationId: r.invitationId,
        sourceId: r.sourceId,
        uid: r.uid,
        organizer: r.organizer,
        digest: r.sourceDigest,
        sequence: r.sequence,
        stamp: r.stamp,
      );

  Future<CalendarInvitationRecord?> _invOptionalEntry(
    UuidValue id,
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final row = await CalendarInvitationRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    return row == null ? null : _invEntry(id, recipient, tx);
  }

  Future<CalendarInvitationLinkRecord?> _invFindLink(
    UuidValue id,
    CalendarInvitationRecord? entry,
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final original = await CalendarInvitationLinkRecord.db.findFirstRow(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.invitationId.equals(id),
      transaction: tx,
    );
    final link =
        original ??
        (entry == null
            ? null
            : await CalendarInvitationLinkRecord.db.findFirstRow(
                _session,
                where: (t) =>
                    t.scopeKey.equals(recipient.scopeKey) &
                    t.recipientKey.equals(recipient.key) &
                    t.correlationDigest.equals(entry.correlationDigest),
                transaction: tx,
              ));
    if (link != null &&
        (link.scopeKey != recipient.scopeKey ||
            link.recipientKey != recipient.key ||
            link.correlationDigest !=
                _invitationHash([link.uid, link.organizer]) ||
            (entry != null &&
                (link.uid != entry.uid || link.organizer != entry.organizer)) ||
            link.eventRevision != 1 ||
            link.invitationRevision < 2 ||
            link.invitationRevision > CalendarService._maxRevision ||
            !RegExp(r'^[0-9a-f]{64}$').hasMatch(link.requestDigest) ||
            !RegExp(r'^[0-9a-f]{64}$').hasMatch(link.sourceDigest))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return link;
  }

  Future<_Event> _invLinkedEvent(
    CalendarInvitationLinkRecord link,
    CalendarHostContext actor,
    Transaction tx,
  ) async {
    final identity = await CalendarEventRecord.db.findById(
      _session,
      link.eventId,
      transaction: tx,
    );
    if (identity == null ||
        identity.deletedAt != null ||
        identity.revision < 1 ||
        identity.revision > CalendarService._maxRevision ||
        identity.calendarId != link.calendarId) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final event = await _event(actor, link.eventId, tx, identity: identity);
    if (event.data.origin != CalendarEventOrigin.imported ||
        event.data.protocolUid != link.uid ||
        event.data.importBaseline == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _invCheckpoint(link, event, tx);
    return event;
  }

  CalendarEventImportMember _invImportMember(
    IcalendarSchedulingMessage message,
    UuidValue id,
  ) => _eventReplacementValue(() {
    final envelope = message.source.components.single;
    final document = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(
        envelope.name,
        envelope.entries.where(
          (e) => e is! IcalendarSyntaxProperty || e.canonicalName != 'METHOD',
        ),
      ),
    ]);
    final parsed = parseIcalendarEventCalendar(
      serializeIcalendarSyntax(document),
    );
    if (parsed.series.length != 1) {
      throw _failure(CalendarFailureCode.validation);
    }
    final proposal = eventStorageProposal(parsed.series.single);
    return CalendarEventImportMember(
      eventId: id,
      protocolUid: proposal.protocolUid,
      content: proposal.content,
      protocolState: proposal.protocolState,
      timingOverrides: proposal.edits,
    );
  });

  Future<void> _invEventAuthority(
    CalendarHostContext actor,
    _Active parent,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    _Event? event,
    CalendarEventImportMember? proposed,
    bool lifecycle = false,
    bool creating = false,
  }) async {
    final intent = proposed == null
        ? null
        : CalendarEventImportIntent([proposed]);
    final requests = [
      for (final operation in [
        if (creating) CalendarPermission.importEvents,
        if (creating) CalendarPermission.createEvent,
        if (creating && lifecycle) CalendarPermission.changeEventStatus,
        CalendarPermission.readEvent,
        CalendarPermission.readEventSource,
      ])
        CalendarAuthorizationRequest(
          key: '${operation.name}:${event?.identity.id ?? proposed?.eventId}',
          operation: operation,
          calendarId: parent.identity.id,
          current: parent.snapshot,
          eventId: event?.identity.id ?? proposed?.eventId,
          currentEvent: proposed == null ? event?.snapshot : null,
          proposedEvent: proposed?.content,
          proposedTimingOverrides: proposed?.timingOverrides,
          proposedEventProtocolState: proposed?.protocolState,
          eventImport: intent,
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
      if (creating && phase == CalendarAuthorizationPhase.finalWrite) {
        for (final request in chunk.where(
          (r) => {
            CalendarPermission.importEvents,
            CalendarPermission.createEvent,
            CalendarPermission.changeEventStatus,
          }.contains(r.operation),
        )) {
          if (!decisions[request.key]!.discloseMutationReceipt) {
            throw _failure(CalendarFailureCode.accessDenied);
          }
        }
      }
      for (final request in chunk.where(
        (r) => r.operation == CalendarPermission.readEvent,
      )) {
        if (!decisions[request.key]!.eventDisclosedGroups.containsAll(
          CalendarEventFieldGroup.values,
        )) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      }
    }
  }

  Future<void> _invAdoptionAuthority(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase,
    CalendarInvitationOperation operation, {
    CalendarInvitationRecord? entry,
    CalendarInvitationSourceRecord? source,
    IcalendarSchedulingMessage? message,
    CalendarInvitationAdoptionRequest? input,
    CalendarInvitationAdoptionReceipt? receipt,
    CalendarInvitationLinkSource? linkSource,
    _Active? parent,
    _Event? event,
    CalendarEventPolicySnapshot? proposed,
    bool? historicalUnavailable,
    bool retry = false,
    UuidValue? lookupId,
  }) async {
    final view = entry == null ? null : await _invView(entry, tx);
    CalendarInvitationApplicationState? application;
    if (event != null && receipt != null) {
      final actualLink = await CalendarInvitationLinkRecord.db.findById(
        _session,
        receipt.id,
        transaction: tx,
      );
      if (actualLink == null) throw _failure(CalendarFailureCode.unavailable);
      application = _invApplicationState(
        actualLink,
        event,
        await _invCheckpoint(actualLink, event, tx),
      );
    }
    for (final op in [
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      operation,
    ]) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: op,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId:
              input?.invitationId ??
              entry?.id ??
              receipt?.invitationId ??
              lookupId,
          sourceId: source?.id ?? input?.sourceId ?? receipt?.sourceId,
          message: message,
          normalizedSource: source?.normalizedSource,
          sourceDigest: source?.digest ?? linkSource?.digest,
          adoptionRequest: input,
          currentApplication: application,
          link: receipt,
          linkSource: linkSource,
          calendar: parent?.snapshot,
          currentEvent: event?.snapshot,
          proposedEvent: proposed,
          historicalSourceUnavailable:
              historicalUnavailable ?? (message == null ? null : false),
          proposedRevision:
              operation == CalendarInvitationOperation.adopt && !retry
              ? receipt?.invitationRevision
              : null,
          proposedDismissed:
              operation == CalendarInvitationOperation.adopt && !retry
              ? true
              : null,
          isRetry: retry,
        ),
        tx,
        phase,
      );
    }
  }

  Future<CalendarInvitationAdoptionReceipt?> invitationLink(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invOptionalEntry(id, recipient, tx);
        await _invAdoptionAuthority(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.read,
          CalendarInvitationOperation.readLink,
          entry: entry,
          lookupId: id,
        );
        final link = await _invFindLink(id, entry, recipient, tx);
        if (link == null) {
          if (entry == null) throw _failure(CalendarFailureCode.accessDenied);
          return null;
        }
        final event = await _invLinkedEvent(link, actor, tx),
            receipt = _invLinkReceipt(link);
        final source = await CalendarInvitationSourceRecord.db.findById(
          _session,
          link.sourceId,
          transaction: tx,
        );
        final originalEntry = await _invOptionalEntry(
          link.invitationId,
          recipient,
          tx,
        );
        final message = source == null || originalEntry == null
            ? null
            : _invStored(source, originalEntry);
        if (source != null &&
            (message == null ||
                source.digest != link.sourceDigest ||
                source.sequence != link.sequence ||
                source.stamp != link.stamp)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        await _invEventAuthority(
          actor,
          event.parent,
          tx,
          CalendarAuthorizationPhase.read,
          event: event,
        );
        await _invAdoptionAuthority(
          actor,
          recipient,
          tx,
          CalendarAuthorizationPhase.read,
          CalendarInvitationOperation.readLink,
          entry: entry,
          source: source,
          message: message,
          receipt: receipt,
          linkSource: _invLinkSource(link),
          parent: event.parent,
          event: event,
          historicalUnavailable: source == null,
        );
        return receipt;
      });

  Future<CalendarInvitationAdoptionReceipt> adoptInvitation(
    CalendarInvitationAdoptionRequest input,
  ) {
    // Generated immutable request freezes body identity before the first await.
    if ([
      input.expectedRevision,
      input.expectedCalendarRevision,
    ].any((v) => v < 1 || v > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final requestDigest = _invitationHash([
      input.invitationId.toString(),
      '${input.expectedRevision}',
      input.sourceId.toString(),
      input.calendarId.toString(),
      '${input.expectedCalendarRevision}',
    ]);
    return _invNativeScoped((actor, recipient, tx, scope) async {
      final entry = await _invOptionalEntry(input.invitationId, recipient, tx);
      await _invAdoptionAuthority(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        CalendarInvitationOperation.adopt,
        entry: entry,
        input: input,
      );
      final existing = await _invFindLink(
        input.invitationId,
        entry,
        recipient,
        tx,
      );
      if (existing != null) {
        final event = await _invLinkedEvent(existing, actor, tx),
            receipt = _invLinkReceipt(existing);
        final source = await CalendarInvitationSourceRecord.db.findById(
          _session,
          existing.sourceId,
          transaction: tx,
        );
        final originalEntry = await _invOptionalEntry(
          existing.invitationId,
          recipient,
          tx,
        );
        final message = source == null || originalEntry == null
            ? null
            : _invStored(source, originalEntry);
        if (source != null &&
            (message == null ||
                source.digest != existing.sourceDigest ||
                source.sequence != existing.sequence ||
                source.stamp != existing.stamp)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        // The immutable import baseline retains the original lifecycle signal even
        // after inbox expiry/local edits; never reconstruct an old source body.
        final baseline = jsonDecode(
          event.data.importBaseline!.canonicalValue,
        ) as Map<String, dynamic>;
        final lifecycle =
            (baseline['content'] as Map<String, dynamic>)['status'] ==
            'cancelled';
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _invEventAuthority(
            actor,
            event.parent,
            tx,
            phase,
            event: event,
            lifecycle: lifecycle,
            creating: true,
          );
          await _invAdoptionAuthority(
            actor,
            recipient,
            tx,
            phase,
            CalendarInvitationOperation.adopt,
            entry: entry,
            source: source,
            message: message,
            input: input,
            receipt: receipt,
            linkSource: _invLinkSource(existing),
            parent: event.parent,
            event: event,
            historicalUnavailable: source == null,
            retry: true,
          );
          if (existing.requestDigest != requestDigest ||
              existing.invitationId != input.invitationId ||
              existing.sourceId != input.sourceId ||
              existing.calendarId != input.calendarId) {
            throw _failure(CalendarFailureCode.dependencyConflict);
          }
        }
        return receipt;
      }
      if (entry == null) throw _failure(CalendarFailureCode.accessDenied);
      final parent = await _active(actor, input.calendarId, tx);
      final source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        input.sourceId,
        transaction: tx,
      );
      if (source == null || source.entryId != entry.id) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final message = _invStored(source, entry),
          member = _invImportMember(message, const Uuid().v4obj());
      final revision = entry.revision + 1,
          now = await _revisionTime(tx, previous: entry.updatedAt);
      final intentSnapshot = CalendarEventPolicySnapshot(
        member.eventId,
        input.calendarId,
        1,
        member.content,
        member.protocolUid,
        now,
        origin: CalendarEventOrigin.imported,
        timingOverrides: member.timingOverrides,
        protocolState: member.protocolState,
      );
      final link = CalendarInvitationLinkRecord(
        id: const Uuid().v4obj(),
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        uid: entry.uid,
        organizer: entry.organizer,
        correlationDigest: entry.correlationDigest,
        invitationId: input.invitationId,
        sourceId: input.sourceId,
        sourceDigest: source.digest,
        sequence: source.sequence,
        stamp: source.stamp,
        calendarId: input.calendarId,
        eventId: member.eventId,
        requestDigest: requestDigest,
        eventRevision: 1,
        invitationRevision: revision,
        adoptedAt: now,
      );
      final receipt = _invLinkReceipt(link);
      await _invAdoptionAuthority(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        CalendarInvitationOperation.adopt,
        entry: entry,
        source: source,
        message: message,
        input: input,
        receipt: receipt,
        linkSource: _invLinkSource(link),
        parent: parent,
        proposed: intentSnapshot,
      );
      await _invEventAuthority(
        actor,
        parent,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        proposed: member,
        lifecycle: member.requiresLifecycle,
        creating: true,
      );
      if (entry.revision != input.expectedRevision ||
          parent.identity.revision != input.expectedCalendarRevision ||
          entry.currentSourceId != input.sourceId ||
          entry.dismissedAt != null) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (revision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final count = await CalendarInvitationLinkRecord.db.count(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key),
        limit: _invOptions.maxLinks + 1,
        transaction: tx,
      );
      if (count >= _invOptions.maxLinks) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final events = await CalendarEventRecord.db.count(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) & t.deletedAt.equals(null),
        limit: _options.maxScannedEvents + 1,
        transaction: tx,
      );
      if (events >= _options.maxScannedEvents) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final candidates = await CalendarEventDataRecord.db.find(
        _session,
        where: (t) =>
            t.calendarId.equals(input.calendarId) &
            t.uidDigest.equals(eventUidDigest(member.protocolUid)),
        transaction: tx,
        limit: _options.maxScannedEvents + 1,
      );
      if (candidates.length > _options.maxScannedEvents) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (eventUidConflicts(
        member.protocolUid,
        candidates.map((e) => e.protocolUid),
      )) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      await _invCleanup(recipient, tx, now);
      final entries = await _invEntries(recipient, tx);
      if (entries.where((e) => e.dismissedAt != null).length >=
          _invOptions.maxDismissed) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final event = await _insertImportedEvent(member, parent, tx, now);
      await CalendarInvitationLinkRecord.db.insertRow(
        _session,
        link,
        transaction: tx,
      );
      entry.dismissedAt = now;
      entry.updatedAt = now;
      entry.revision = revision;
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
      await _bump(scope, tx, publishedEventCalendar: input.calendarId);
      await _invEventAuthority(
        actor,
        parent,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        event: event,
        proposed: member,
        lifecycle: member.requiresLifecycle,
        creating: true,
      );
      // Keep current queue state distinct from the proposed committed revision.
      final prior = entry.copyWith(
        revision: input.expectedRevision,
        dismissedAt: null,
      );
      await _invAdoptionAuthority(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        CalendarInvitationOperation.adopt,
        entry: prior,
        source: source,
        message: message,
        input: input,
        receipt: receipt,
        linkSource: _invLinkSource(link),
        parent: parent,
        proposed: event.snapshot,
      );
      return receipt;
    });
  }
}
