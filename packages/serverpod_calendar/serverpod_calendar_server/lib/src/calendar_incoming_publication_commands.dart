part of 'calendar_module.dart';

extension CalendarIncomingPublicationCommands on CalendarService {
  CalendarEventImportMember _incomingMember(
    IcalendarSchedulingMessage message,
    UuidValue id,
  ) {
    final p = _schedulingMasterProposal(message);
    return CalendarEventImportMember(
      eventId: id,
      protocolUid: p.protocolUid,
      content: p.content,
      protocolState: p.protocolState,
      timingOverrides: p.edits,
    );
  }

  String _incomingBaselineDigest(CalendarEventImportBaseline b) =>
      _schedulingDigest(jsonEncode(b.toJson()));
  String _incomingMemberDigest(CalendarEventImportMember m) =>
      _incomingBaselineDigest(
        eventImportBaseline(
          m.protocolUid,
          m.content,
          m.timingOverrides,
          m.protocolState,
        ),
      );
  String _incomingEventDigest(_Event e) => _incomingBaselineDigest(
    eventImportBaseline(
      e.data.protocolUid,
      e.data.content,
      e.data.timingOverrides,
      e.data.protocolState!,
    ),
  );
  CalendarIncomingPublicationCommandReceipt _incomingReceipt(
    String encoded,
    CalendarIncomingPublicationLinkRecord link,
  ) {
    try {
      if (utf8.encode(encoded).length > 16384) {
        throw StateError('Oversized receipt');
      }
      final value = CalendarIncomingPublicationCommandReceipt.fromJson(
        jsonDecode(encoded) as Map<String, dynamic>,
      );
      if (value.linkId != link.id ||
          value.entryId != link.entryId ||
          value.eventId != link.eventId ||
          value.calendarId != link.calendarId ||
          value.eventRevision < 1 ||
          value.entryRevision < 1 ||
          value.eventRevision > CalendarService._maxRevision ||
          value.entryRevision > CalendarService._maxRevision ||
          value.unchanged) {
        throw StateError('Invalid receipt identity');
      }
      return value;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<_Event> _incomingLinkedEvent(
    CalendarIncomingPublicationLinkRecord link,
    CalendarIncomingPublicationRecord entry,
    Transaction tx,
  ) async {
    if (link.deletedAt != null ||
        link.scopeKey != entry.scopeKey ||
        link.recipientKey != entry.recipientKey ||
        link.entryId != entry.id ||
        link.correlationDigest != entry.correlationDigest) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    final e = await _eventInScope(link.scopeKey, link.eventId, tx);
    if (e.identity.calendarId != link.calendarId ||
        e.data.origin != CalendarEventOrigin.imported ||
        e.data.protocolUid != entry.uid ||
        e.data.importBaseline == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    _incomingReceipt(link.creationReceipt, link);
    if (link.lastReceipt != null) _incomingReceipt(link.lastReceipt!, link);
    return e;
  }

  Future<CalendarEventImportMember> _incomingExpected(
    CalendarIncomingPublicationLinkRecord link,
    CalendarIncomingPublicationRecord entry,
    _Event e,
    Transaction tx,
  ) async {
    if (link.acceptedSourceId == null ||
        link.basisSourceId == null ||
        link.creationSourceId == null ||
        link.baselineDigest == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final basisSource = await _incomingSourceRow(
      entry,
      link.basisSourceId!,
      tx,
    );
    final basis = _incomingStored(entry, basisSource);
    if (basis.method != IcalendarSchedulingMethod.publish) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final proposal = _schedulingMasterProposal(basis);
    if (_incomingBaselineDigest(proposal.importBaseline) !=
            link.baselineDigest ||
        _incomingBaselineDigest(e.data.importBaseline!) !=
            link.baselineDigest) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final original = await _incomingSourceRow(
      entry,
      link.creationSourceId!,
      tx,
    );
    if (_incomingStored(entry, original).method !=
            IcalendarSchedulingMethod.publish ||
        _incomingReceipt(link.creationReceipt, link).sourceId != original.id) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final accepted = await _incomingSourceRow(
      entry,
      link.acceptedSourceId!,
      tx,
    );
    final message = _incomingStored(entry, accepted);
    if (message.method == IcalendarSchedulingMethod.publish) {
      if (link.acceptedSourceId != link.basisSourceId) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      return _incomingMember(message, e.identity.id!);
    }
    await _incomingSourceBasis(entry, accepted, tx);
    return _invCancellationMember(
      message,
      e,
      masterBaseline: proposal.importBaseline,
    );
  }

  Future<void> _incomingNative(
    CalendarHostContext actor,
    _Active parent,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    _Event? current,
    CalendarEventImportMember? proposed,
    bool creating = false,
    bool writing = false,
  }) async {
    final lifecycle =
        proposed != null &&
        (proposed.requiresLifecycle ||
            current != null &&
                proposed.content.status != current.data.content.status);
    final requests = [
      for (final op in [
        if (creating) CalendarPermission.importEvents,
        if (creating) CalendarPermission.createEvent,
        if (writing && !creating) CalendarPermission.updateEvent,
        if (lifecycle && writing) CalendarPermission.changeEventStatus,
        CalendarPermission.readEvent,
        CalendarPermission.readEventSource,
      ])
        CalendarAuthorizationRequest(
          key:
              'incoming:${op.name}:${current?.identity.id ?? proposed?.eventId}',
          operation: op,
          calendarId: parent.identity.id,
          current: parent.snapshot,
          eventId: current?.identity.id ?? proposed?.eventId,
          currentEvent: current?.snapshot,
          proposedEvent: proposed?.content,
          proposedTimingOverrides: proposed?.timingOverrides,
          proposedEventProtocolState: proposed?.protocolState,
          eventImport: proposed == null
              ? null
              : CalendarEventImportIntent([proposed]),
          eventGroups: CalendarEventFieldGroup.values,
        ),
    ];
    for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
      final batch = requests.sublist(
        i,
        min(i + _options.policyBatchSize, requests.length),
      );
      final decisions = phase == CalendarAuthorizationPhase.finalWrite
          ? await _final(actor, batch, tx)
          : await _decide(actor, batch, tx, phase);
      for (final r in batch) {
        final answer = decisions[r.key]!;
        if (r.operation == CalendarPermission.readEvent &&
                !answer.eventDisclosedGroups.containsAll(
                  CalendarEventFieldGroup.values,
                ) ||
            phase == CalendarAuthorizationPhase.finalWrite &&
                {
                  CalendarPermission.createEvent,
                  CalendarPermission.updateEvent,
                }.contains(r.operation) &&
                !answer.discloseMutationReceipt) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      }
    }
  }

  Future<void> _incomingCommandHost(
    CalendarIncomingPublicationOperation operation,
    CalendarHostContext actor,
    CalendarIncomingPublicationRecipient r,
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationSourceRecord? source,
    IcalendarSchedulingMessage? message,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    _Active? parent,
    _Event? current,
    CalendarEventPolicySnapshot? proposed,
    IcalendarSchedulingMessage? basis,
    bool retry = false,
    CalendarIncomingPublicationLinkRecord? link,
  }) async {
    final sourceBasis = source == null
        ? null
        : await _incomingSourceBasis(entry, source, tx);
    CalendarIncomingPublicationPolicyContext context(
      CalendarIncomingPublicationOperation op,
    ) => CalendarIncomingPublicationPolicyContext(
      operation: op,
      recipient: r,
      actor: actor,
      entry: _incomingView(entry),
      source: message,
      sourceId: source?.id,
      sourceDigest: source?.digest,
      acceptedBasis: basis,
      sourceBasis: sourceBasis,
      calendar: parent?.snapshot,
      currentEvent: current?.snapshot,
      proposedEvent: proposed,
      targetCalendarId:
          link?.calendarId ??
          current?.identity.calendarId ??
          proposed?.calendarId,
      targetEventId: link?.eventId ?? current?.identity.id ?? proposed?.eventId,
      targetDeleted: link?.deletedAt != null,
      isRetry: retry,
    );
    await _incomingAuthorize(context(operation), tx, phase);
    if (link?.deletedAt != null) {
      await _incomingAuthorize(
        context(CalendarIncomingPublicationOperation.readLink),
        tx,
        phase,
      );
    }
    if (source != null) {
      await _incomingAuthorize(
        context(CalendarIncomingPublicationOperation.readSource),
        tx,
        phase,
      );
      final proofLink =
          link ??
          await CalendarIncomingPublicationLinkRecord.db.findFirstRow(
            _session,
            where: (t) =>
                t.entryId.equals(entry.id!) &
                t.scopeKey.equals(r.scopeKey) &
                t.recipientKey.equals(r.key),
            transaction: tx,
          );
      // Each retained proof has its own actual source identity. Approval of the
      // proposed source alone must not grant access to an older private basis.
      final proofIds = <UuidValue>{
        if (source.basisSourceId != null) source.basisSourceId!,
        if (proofLink?.creationSourceId != null) proofLink!.creationSourceId!,
        if (proofLink?.acceptedSourceId != null) proofLink!.acceptedSourceId!,
        if (proofLink?.basisSourceId != null) proofLink!.basisSourceId!,
      }..remove(source.id);
      for (final proofId in proofIds) {
        final proof = await _incomingSourceRow(entry, proofId, tx);
        await _incomingAuthorize(
          CalendarIncomingPublicationPolicyContext(
            operation: CalendarIncomingPublicationOperation.readSource,
            recipient: r,
            actor: actor,
            entry: _incomingView(entry),
            source: _incomingStored(entry, proof),
            sourceId: proof.id,
            sourceDigest: proof.digest,
            sourceBasis: await _incomingSourceBasis(entry, proof, tx),
            acceptedBasis: basis,
            calendar: parent?.snapshot,
            currentEvent: current?.snapshot,
            proposedEvent: proposed,
            targetCalendarId: proofLink?.calendarId ?? parent?.identity.id,
            targetEventId: proofLink?.eventId ?? proposed?.eventId,
            targetDeleted: proofLink?.deletedAt != null,
            isRetry: retry,
          ),
          tx,
          phase,
        );
      }
    }
    if (operation == CalendarIncomingPublicationOperation.applyUpdate &&
            proposed?.content.status == CalendarEventStatus.cancelled ||
        operation == CalendarIncomingPublicationOperation.adopt &&
            proposed?.content.status == CalendarEventStatus.cancelled) {
      await _incomingAuthorize(
        context(CalendarIncomingPublicationOperation.applyCancellation),
        tx,
        phase,
      );
    }
    if (operation == CalendarIncomingPublicationOperation.applyUpdate &&
        current?.data.content.status == CalendarEventStatus.cancelled &&
        proposed?.content.status != CalendarEventStatus.cancelled) {
      await _incomingAuthorize(
        context(CalendarIncomingPublicationOperation.reopen),
        tx,
        phase,
      );
    }
  }

  Future<void> _incomingLinkCapacity(
    CalendarIncomingPublicationLinkRecord link,
    _Event e,
    Transaction tx,
  ) async {
    var bytes =
        utf8.encode(link.creationReceipt).length +
        utf8.encode(link.lastReceipt ?? '').length +
        utf8.encode(jsonEncode(e.data.importBaseline!.toJson())).length;
    final ids = {
      link.creationSourceId,
      link.acceptedSourceId,
      link.basisSourceId,
    }..remove(null);
    for (final id in ids.toList()) {
      final source = await CalendarIncomingPublicationSourceRecord.db.findById(
        _session,
        id!,
        transaction: tx,
      );
      if (source?.basisSourceId != null) ids.add(source!.basisSourceId);
    }
    for (final id in ids) {
      final row = await CalendarIncomingPublicationSourceRecord.db.findById(
        _session,
        id!,
        transaction: tx,
      );
      if (row?.normalizedSource == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      bytes += utf8.encode(row!.normalizedSource!).length;
    }
    if (bytes > _incomingOptions.maxLinkBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  Future<CalendarIncomingPublicationLinkView?> _incomingLinkView(
    UuidValue id,
  ) => _incomingScoped((actor, r, tx, _) async {
    final entry = await _incomingEntry(id, r, tx);
    final link = await _incomingFindLink(entry, tx);
    await _incomingAuthorize(
      CalendarIncomingPublicationPolicyContext(
        operation: CalendarIncomingPublicationOperation.readLink,
        recipient: r,
        actor: actor,
        entry: _incomingView(entry),
      ),
      tx,
      CalendarAuthorizationPhase.read,
    );
    if (link == null) return null;
    final creation = _incomingReceipt(link.creationReceipt, link),
        latest = link.lastReceipt == null
            ? null
            : _incomingReceipt(link.lastReceipt!, link);
    if (link.deletedAt != null) {
      final marker = await CalendarEventRecord.db.findById(
        _session,
        link.eventId,
        transaction: tx,
      );
      if (marker == null ||
          marker.deletedAt == null ||
          marker.calendarId != link.calendarId) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      return CalendarIncomingPublicationLinkView(
        id: link.id!,
        entryId: entry.id!,
        calendarId: link.calendarId,
        eventId: link.eventId,
        eventRevision: marker.revision,
        entryRevision: entry.revision,
        deleted: true,
        hasLocalChanges: false,
        creationReceipt: creation,
        latestApplyReceipt: latest,
      );
    }
    final e = await _incomingLinkedEvent(link, entry, tx);
    await _incomingNative(
      actor,
      e.parent,
      tx,
      CalendarAuthorizationPhase.read,
      current: e,
    );
    final expected = await _incomingExpected(link, entry, e, tx);
    final accepted = await _incomingSourceRow(
      entry,
      link.acceptedSourceId!,
      tx,
    );
    return CalendarIncomingPublicationLinkView(
      id: link.id!,
      entryId: entry.id!,
      calendarId: link.calendarId,
      eventId: link.eventId,
      eventRevision: e.identity.revision,
      entryRevision: entry.revision,
      deleted: false,
      hasLocalChanges:
          _incomingEventDigest(e) != _incomingMemberDigest(expected),
      acceptedSourceId: accepted.id,
      acceptedKind: accepted.kind,
      acceptedSequence: accepted.sequence,
      acceptedStamp: accepted.stamp,
      creationReceipt: creation,
      latestApplyReceipt: latest,
    );
  });

  Future<CalendarIncomingPublicationCommandReceipt> _incomingAdd(
    CalendarIncomingPublicationAddRequest input,
  ) => _incomingScoped((actor, r, tx, scope) async {
    final entry = await _incomingEntry(input.entryId, r, tx);
    final existing = await _incomingFindLink(entry, tx);
    final digest = _invitationHash([
      'publication-add-v1',
      actor.principalId,
      input.entryId.toString(),
      input.sourceId.toString(),
      '${input.expectedRevision}',
      input.calendarId.toString(),
      '${input.expectedCalendarRevision}',
    ]);
    final previous = await CalendarIncomingPublicationLinkRecord.db
        .findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(r.scopeKey) &
              t.recipientKey.equals(r.key) &
              (t.creationCommandId.equals(input.commandId) |
                  t.lastCommandId.equals(input.commandId)),
          transaction: tx,
        );
    if (previous != null &&
        (previous.id != existing?.id ||
            previous.creationCommandId != input.commandId ||
            previous.creationActorId != actor.principalId ||
            previous.creationDigest != digest)) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (existing != null && previous == null) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    if (previous != null && previous.deletedAt != null) {
      final retained = _incomingReceipt(previous.creationReceipt, previous);
      if (retained.sourceId != input.sourceId) {
        throw _failure(CalendarFailureCode.validation);
      }
      await _incomingCommandHost(
        CalendarIncomingPublicationOperation.adopt,
        actor,
        r,
        entry,
        null,
        null,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        retry: true,
        link: previous,
      );
      await _incomingCommandHost(
        CalendarIncomingPublicationOperation.adopt,
        actor,
        r,
        entry,
        null,
        null,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        retry: true,
        link: previous,
      );
      return retained.copyWith(unchanged: true);
    }
    final source = await _incomingSourceRow(entry, input.sourceId, tx);
    final message =
        source.normalizedSource == null && existing?.deletedAt != null
        ? null
        : _incomingStored(entry, source);
    if (previous != null) {
      final e = previous.deletedAt == null
          ? await _incomingLinkedEvent(previous, entry, tx)
          : null;
      if (e != null) {
        await _incomingExpected(previous, entry, e, tx);
        await _incomingNative(
          actor,
          e.parent,
          tx,
          CalendarAuthorizationPhase.read,
          current: e,
        );
      }
      await _incomingCommandHost(
        CalendarIncomingPublicationOperation.adopt,
        actor,
        r,
        entry,
        source,
        message,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        parent: e?.parent,
        current: e,
        retry: true,
      );
      await _incomingCommandHost(
        CalendarIncomingPublicationOperation.adopt,
        actor,
        r,
        entry,
        source,
        message,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        parent: e?.parent,
        current: e,
        retry: true,
      );
      return _incomingReceipt(
        previous.creationReceipt,
        previous,
      ).copyWith(unchanged: true);
    }
    final parent = await _active(actor, input.calendarId, tx);
    if (message == null ||
        message.method != IcalendarSchedulingMethod.publish) {
      throw _failure(CalendarFailureCode.validation);
    }
    final id = const Uuid().v4obj(), linkId = const Uuid().v4obj();
    final member = _incomingMember(message, id);
    final now = await _revisionTime(tx);
    final proposed = CalendarEventPolicySnapshot(
      id,
      parent.identity.id!,
      1,
      member.content,
      member.protocolUid,
      now,
      origin: CalendarEventOrigin.imported,
      protocolState: member.protocolState,
      timingOverrides: member.timingOverrides,
    );
    await _incomingCommandHost(
      CalendarIncomingPublicationOperation.adopt,
      actor,
      r,
      entry,
      source,
      message,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
      parent: parent,
      proposed: proposed,
    );
    await _incomingNative(
      actor,
      parent,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
      proposed: member,
      creating: true,
      writing: true,
    );
    _incomingRevision(entry, input.expectedRevision);
    if (entry.currentSourceId != source.id ||
        entry.dismissedAt != null ||
        input.expectedCalendarRevision != parent.identity.revision) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (input.expectedCalendarRevision < 1 ||
        input.expectedCalendarRevision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    final count = await CalendarEventRecord.db.count(
      _session,
      where: (t) =>
          t.calendarId.equals(parent.identity.id!) & t.deletedAt.equals(null),
      transaction: tx,
      limit: _options.maxScannedEvents + 1,
    );
    if (count >= _options.maxScannedEvents) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final candidates = await CalendarEventDataRecord.db.find(
      _session,
      where: (t) =>
          t.calendarId.equals(parent.identity.id!) &
          t.uidDigest.equals(eventUidDigest(member.protocolUid)),
      transaction: tx,
      limit: _options.maxScannedEvents + 1,
    );
    if (candidates.length > _options.maxScannedEvents) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    if (eventUidConflicts(
      member.protocolUid,
      candidates.map((v) => v.protocolUid),
    )) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    if (entry.revision >= CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final receipt = CalendarIncomingPublicationCommandReceipt(
      linkId: linkId,
      entryId: entry.id!,
      sourceId: source.id!,
      calendarId: parent.identity.id!,
      eventId: id,
      eventRevision: 1,
      entryRevision: entry.revision + 1,
      kind: source.kind,
      recordedAt: now,
    );
    final e = await _insertImportedEvent(member, parent, tx, now);
    final link = await CalendarIncomingPublicationLinkRecord.db.insertRow(
      _session,
      CalendarIncomingPublicationLinkRecord(
        id: linkId,
        scopeKey: r.scopeKey,
        recipientKey: r.key,
        entryId: entry.id!,
        correlationDigest: entry.correlationDigest,
        calendarId: parent.identity.id!,
        eventId: id,
        creationSourceId: source.id,
        creationActorId: actor.principalId,
        creationCommandId: input.commandId,
        creationDigest: digest,
        creationReceipt: jsonEncode(receipt.toJson()),
        acceptedSourceId: source.id,
        basisSourceId: source.id,
        baselineDigest: _incomingBaselineDigest(e.data.importBaseline!),
        acceptedAt: now,
      ),
      transaction: tx,
    );
    entry.revision++;
    entry.dismissedAt = now;
    await CalendarIncomingPublicationRecord.db.updateRow(
      _session,
      entry,
      transaction: tx,
    );
    await _incomingLinkCapacity(link, e, tx);
    await _incomingCapacity(r, tx, entry: entry);
    await _incomingCommandHost(
      CalendarIncomingPublicationOperation.adopt,
      actor,
      r,
      entry,
      source,
      message,
      tx,
      CalendarAuthorizationPhase.finalWrite,
      parent: parent,
      proposed: proposed,
    );
    await _incomingNative(
      actor,
      parent,
      tx,
      CalendarAuthorizationPhase.finalWrite,
      proposed: member,
      creating: true,
      writing: true,
    );
    await _bump(scope, tx, publishedEventCalendar: parent.identity.id!);
    return receipt;
  });

  Future<CalendarIncomingPublicationCommandReceipt> _incomingApply(
    CalendarIncomingPublicationApplyRequest input,
  ) => _incomingScoped((actor, r, tx, scope) async {
    final entry = await _incomingEntry(input.entryId, r, tx);
    final link = await _incomingFindLink(entry, tx);
    if (link == null) throw _failure(CalendarFailureCode.dependencyConflict);
    final digest = _invitationHash([
      'publication-apply-v1',
      actor.principalId,
      input.entryId.toString(),
      input.sourceId.toString(),
      '${input.expectedRevision}',
      '${input.expectedEventRevision}',
    ]);
    if (link.creationCommandId == input.commandId) {
      throw _failure(CalendarFailureCode.validation);
    }
    final commandOwner = await CalendarIncomingPublicationLinkRecord.db
        .findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(r.scopeKey) &
              t.recipientKey.equals(r.key) &
              (t.creationCommandId.equals(input.commandId) |
                  t.lastCommandId.equals(input.commandId)),
          transaction: tx,
        );
    if (commandOwner != null &&
        (commandOwner.id != link.id ||
            commandOwner.creationCommandId == input.commandId)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final retry = link.lastCommandId == input.commandId;
    if (retry &&
        (link.lastActorId != actor.principalId ||
            link.lastCommandDigest != digest ||
            link.lastReceipt == null)) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (retry && link.deletedAt != null) {
      final retained = _incomingReceipt(link.lastReceipt!, link);
      if (retained.sourceId != input.sourceId) {
        throw _failure(CalendarFailureCode.validation);
      }
      final op = retained.kind == CalendarIncomingPublicationKind.cancellation
          ? CalendarIncomingPublicationOperation.applyCancellation
          : CalendarIncomingPublicationOperation.applyUpdate;
      await _incomingCommandHost(
        op,
        actor,
        r,
        entry,
        null,
        null,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        retry: true,
        link: link,
      );
      await _incomingCommandHost(
        op,
        actor,
        r,
        entry,
        null,
        null,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        retry: true,
        link: link,
      );
      return retained.copyWith(unchanged: true);
    }
    final source = await _incomingSourceRow(entry, input.sourceId, tx);
    final message = _incomingStored(entry, source);
    final operation =
        source.kind == CalendarIncomingPublicationKind.cancellation
        ? CalendarIncomingPublicationOperation.applyCancellation
        : CalendarIncomingPublicationOperation.applyUpdate;
    final e = await _incomingLinkedEvent(link, entry, tx), before = e.snapshot;
    final expected = await _incomingExpected(link, entry, e, tx);
    final basis = await _incomingBasis(entry, link, tx);
    final member = message.method == IcalendarSchedulingMethod.publish
        ? _incomingMember(message, e.identity.id!)
        : _invCancellationMember(message, e);
    if (message.method == IcalendarSchedulingMethod.cancel) {
      await _incomingSourceBasis(entry, source, tx);
    }
    final now = await _revisionTime(tx, previous: e.data.updatedAt);
    final proposed = CalendarEventPolicySnapshot(
      e.identity.id!,
      e.identity.calendarId,
      e.identity.revision + 1,
      member.content,
      member.protocolUid,
      now,
      origin: CalendarEventOrigin.imported,
      protocolState: member.protocolState,
      timingOverrides: member.timingOverrides,
    );
    await _incomingCommandHost(
      operation,
      actor,
      r,
      entry,
      source,
      message,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
      parent: e.parent,
      current: e,
      proposed: proposed,
      basis: basis,
      retry: retry,
    );
    await _incomingNative(
      actor,
      e.parent,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
      current: e,
      proposed: member,
      writing: !retry,
    );
    if (retry) {
      await _incomingCommandHost(
        operation,
        actor,
        r,
        entry,
        source,
        message,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        parent: e.parent,
        current: e,
        proposed: before,
        basis: basis,
        retry: true,
      );
      await _incomingNative(
        actor,
        e.parent,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        current: e,
      );
      return _incomingReceipt(
        link.lastReceipt!,
        link,
      ).copyWith(unchanged: true);
    }
    _incomingRevision(entry, input.expectedRevision);
    _eventRevision(e, input.expectedEventRevision);
    if (source.id != entry.currentSourceId) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (_incomingEventDigest(e) != _incomingMemberDigest(expected)) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    if (source.id == link.acceptedSourceId) {
      await _incomingCommandHost(
        operation,
        actor,
        r,
        entry,
        source,
        message,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        parent: e.parent,
        current: e,
        proposed: before,
        basis: basis,
      );
      await _incomingNative(
        actor,
        e.parent,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        current: e,
      );
      return _incomingReceipt(
        link.lastReceipt ?? link.creationReceipt,
        link,
      ).copyWith(unchanged: true);
    }
    final accepted = await _incomingSourceRow(
      entry,
      link.acceptedSourceId!,
      tx,
    );
    if (_incomingVersion(
          source.sequence,
          source.stamp,
          accepted.sequence,
          accepted.stamp,
        ) <=
        0) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    if (entry.revision >= CalendarService._maxRevision ||
        e.identity.revision >= CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final baseline = message.method == IcalendarSchedulingMethod.publish
        ? eventImportBaseline(
            member.protocolUid,
            member.content,
            member.timingOverrides,
            member.protocolState,
          )
        : e.data.importBaseline!;
    final receipt = CalendarIncomingPublicationCommandReceipt(
      linkId: link.id!,
      entryId: entry.id!,
      sourceId: source.id!,
      calendarId: link.calendarId,
      eventId: link.eventId,
      eventRevision: e.identity.revision + 1,
      entryRevision: entry.revision + 1,
      kind: source.kind,
      recordedAt: now,
    );
    await _incomingCommandHost(
      operation,
      actor,
      r,
      entry,
      source,
      message,
      tx,
      CalendarAuthorizationPhase.finalWrite,
      parent: e.parent,
      current: e,
      proposed: proposed,
      basis: basis,
    );
    await _incomingNative(
      actor,
      e.parent,
      tx,
      CalendarAuthorizationPhase.finalWrite,
      current: e,
      proposed: member,
      writing: true,
    );
    e.data.content = member.content;
    e.data.timingOverrides = member.timingOverrides;
    e.data.protocolState = member.protocolState;
    e.data.importBaseline = baseline;
    e.data.updatedAt = now;
    e.identity.revision++;
    await CalendarEventDataRecord.db.updateRow(
      _session,
      e.data,
      transaction: tx,
    );
    await CalendarEventRecord.db.updateRow(
      _session,
      e.identity,
      transaction: tx,
    );
    link.acceptedSourceId = source.id;
    if (message.method == IcalendarSchedulingMethod.publish) {
      link.basisSourceId = source.id;
    }
    link.baselineDigest = _incomingBaselineDigest(baseline);
    link.acceptedAt = now;
    link.lastActorId = actor.principalId;
    link.lastCommandId = input.commandId;
    link.lastCommandDigest = digest;
    link.lastReceipt = jsonEncode(receipt.toJson());
    await CalendarIncomingPublicationLinkRecord.db.updateRow(
      _session,
      link,
      transaction: tx,
    );
    entry.revision++;
    entry.dismissedAt = now;
    await CalendarIncomingPublicationRecord.db.updateRow(
      _session,
      entry,
      transaction: tx,
    );
    await _incomingLinkCapacity(link, e, tx);
    await _incomingCapacity(r, tx, entry: entry);
    await _bump(scope, tx, publishedEventCalendar: e.identity.calendarId);
    return receipt;
  });
  Future<void> _incomingEventDeleted(_Event e, Transaction tx) async {
    final link = await CalendarIncomingPublicationLinkRecord.db.findFirstRow(
      _session,
      where: (t) => t.eventId.equals(e.identity.id!),
      transaction: tx,
    );
    if (link == null) return;
    if (link.scopeKey != e.parent.identity.scopeKey ||
        link.calendarId != e.identity.calendarId) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    link.creationSourceId = null;
    link.acceptedSourceId = null;
    link.basisSourceId = null;
    link.baselineDigest = null;
    link.acceptedAt = null;
    link.deletedAt = await _revisionTime(tx);
    await CalendarIncomingPublicationLinkRecord.db.updateRow(
      _session,
      link,
      transaction: tx,
    );
  }
}
