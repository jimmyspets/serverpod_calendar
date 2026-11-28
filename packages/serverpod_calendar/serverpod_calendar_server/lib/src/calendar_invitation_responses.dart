part of 'calendar_module.dart';

extension CalendarInvitationResponseOperations on CalendarService {
  CalendarInvitationResponseRuntime get _irRuntime =>
      _invitations.responses ??
      (throw _failure(CalendarFailureCode.unavailable));
  CalendarInvitationResponseOptions get _irOptions => _irRuntime.options;
  void _irGuarantee() {
    _invGuarantee();
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _irRuntime.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<void> _irAuthorize(
    CalendarInvitationResponsePolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    _irGuarantee();
    final verdict = await _bounded(
      () => _irRuntime.host.authorize(_session, context, tx, phase),
    );
    _irGuarantee();
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  CalendarInvitationResponseView _irView(
    CalendarInvitationRecord entry,
    CalendarInvitationResponseStateRecord? state,
  ) => CalendarInvitationResponseView(
    invitationId: entry.id!,
    revision: state?.revision ?? 0,
    responseId: state?.latestResponseId,
    choice: state?.choice,
    stamp: state?.lastStamp,
    sourceId: state?.sourceId,
    sourceRevision: state?.sourceRevision,
    sourceSequence: state?.sourceSequence,
    sourceStamp: state?.sourceStamp,
    appliesToCurrentSource:
        state != null &&
        state.sourceId == entry.currentSourceId &&
        entry.kind == CalendarInvitationSourceKind.request,
    deliveryState: state?.outcome,
  );
  Future<CalendarInvitationResponseStateRecord?> _irState(
    CalendarInvitationRecipient recipient,
    UuidValue entryId,
    Transaction tx,
  ) async {
    final rows = await CalendarInvitationResponseStateRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.entryId.equals(entryId),
      limit: 2,
      transaction: tx,
    );
    if (rows.length > 1) throw _failure(CalendarFailureCode.unavailable);
    final state = rows.firstOrNull;
    if (state != null &&
        (state.id == null ||
            state.revision < 1 ||
            state.revision > CalendarService._maxRevision ||
            !state.lastStamp.isUtc ||
            state.lastStamp.microsecond != 0 ||
            state.lastStamp.millisecond != 0 ||
            !RegExp(r'^[a-f0-9]{64}$').hasMatch(state.sourceDigest))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return state;
  }

  Future<CalendarInvitationSourceRecord> _irSource(
    UuidValue id,
    CalendarInvitationRecord entry,
    Transaction tx,
  ) async {
    final source = await CalendarInvitationSourceRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (source == null || source.entryId != entry.id) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    try {
      _invStored(source, entry);
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return source;
  }

  Future<void> _irSourceRead(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    CalendarInvitationRecord entry,
    CalendarInvitationSourceRecord? source,
    Transaction tx, {
    bool retry = false,
    CalendarAuthorizationPhase phase = CalendarAuthorizationPhase.read,
  }) async {
    await _invAuthorize(
      CalendarInvitationPolicyContext(
        operation: CalendarInvitationOperation.readSource,
        actor: actor,
        recipient: recipient,
        current: await _invView(entry, tx),
        entryId: entry.id,
        sourceId: source?.id,
        message: source == null ? null : _invStored(source, entry),
        normalizedSource: source?.normalizedSource,
        sourceDigest: source?.digest,
        isRetry: retry,
      ),
      tx,
      phase,
    );
  }

  CalendarInvitationResponsePolicyContext _irContext({
    required CalendarInvitationResponseOperation operation,
    required CalendarInvitationRecipient recipient,
    required CalendarInvitationView invitation,
    required CalendarInvitationResponseView current,
    CalendarHostContext? actor,
    CalendarInvitationSourceRecord? source,
    int? sourceRevision,
    CalendarInvitationResponseView? proposed,
    CalendarInvitationResponseRequest? request,
    CalendarInvitationResponseReceipt? receipt,
    IcalendarSchedulingMessage? sourceMessage,
    IcalendarSchedulingMessage? outgoing,
    String? digest,
    CalendarInvitationResponseAuthority? authority,
    bool retry = false,
  }) => CalendarInvitationResponsePolicyContext(
    operation: operation,
    recipient: recipient,
    invitation: invitation,
    currentState: current,
    actor: actor,
    sourceId: source?.id,
    sourceRevision: sourceRevision,
    sourceDigest: source?.digest,
    sourceMessage: sourceMessage,
    proposedState: proposed,
    request: request,
    receipt: receipt,
    outgoingMessage: outgoing,
    payloadDigest: digest,
    authority: authority,
    isRetry: retry,
  );

  CalendarInvitationResponseAuthority _irAuthority(
    CalendarInvitationResponseAuthority authority,
    CalendarInvitationRecipient recipient,
    IcalendarSchedulingMessage source,
  ) {
    for (final value in [
      authority.authorityRef,
      authority.organizer.routeRef,
    ]) {
      _schedulingValue(
        () => validateCalendarOpaqueText(value, maxUtf8Bytes: 512),
      );
    }
    final event = source.events.single;
    if (authority.attendeeAddress != recipient.calendarAddress ||
        event.participants.organizer?.address != authority.organizer.address ||
        event.participants.attendees
                .where((a) => a.address == authority.attendeeAddress)
                .length !=
            1) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return authority;
  }

  String _irPayload(
    IcalendarSchedulingMessage source,
    CalendarInvitationResponseChoice choice,
    CalendarInvitationResponseAuthority authority,
    DateTime stamp,
  ) {
    if (stamp.year < 1970 || stamp.year >= 2100) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${stamp.year.toString().padLeft(4, '0')}${two(stamp.month)}${two(stamp.day)}T${two(stamp.hour)}${two(stamp.minute)}${two(stamp.second)}Z';
    final event = source.events.single;
    final bytes = serializeIcalendarSyntax(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty(
            'PRODID',
            '-//Serverpod calendar attendee response//EN',
          ),
          IcalendarSyntaxProperty('METHOD', 'REPLY'),
          IcalendarSyntaxComponent('VEVENT', [
            IcalendarSyntaxProperty('UID', encodeIcalendarText(event.uid)),
            IcalendarSyntaxProperty('DTSTAMP', date),
            if (event.sequence != null)
              IcalendarSyntaxProperty('SEQUENCE', '${event.sequence}'),
            IcalendarSyntaxProperty('ORGANIZER', authority.organizer.address),
            IcalendarSyntaxProperty(
              'ATTENDEE',
              authority.attendeeAddress,
              parameters: [
                IcalendarSyntaxParameter('PARTSTAT', [
                  choice.name.toUpperCase(),
                ]),
              ],
            ),
          ]),
        ]),
      ]),
    );
    if (bytes.length > 32768) throw _failure(CalendarFailureCode.limitExceeded);
    _irParse(bytes);
    return utf8.decode(bytes);
  }

  IcalendarSchedulingMessage _irParse(List<int> bytes) {
    try {
      return parseImipCalendarPart(
        ImipDecodedPart(
          mediaType: 'text/calendar',
          parameters: const [
            ImipParameter('method', 'REPLY'),
            ImipParameter('charset', 'UTF-8'),
            ImipParameter('component', 'VEVENT'),
          ],
          body: bytes,
          protection: ImipProtection.none,
          limits: const ImipPartLimits(maxDecodedBytes: 32768),
        ),
        limits: const ImipPartLimits(maxDecodedBytes: 32768),
      ).eventMessage!;
    } on ImipPartException catch (e) {
      throw _failure(
        e.kind == ImipPartError.limitExceeded
            ? CalendarFailureCode.limitExceeded
            : CalendarFailureCode.validation,
      );
    }
  }

  Future<List<CalendarInvitationResponseRecord>> _irRows(
    String scope,
    Transaction tx,
  ) async {
    final rows = await CalendarInvitationResponseRecord.db.find(
      _session,
      where: (t) => t.scopeKey.equals(scope),
      limit: 4097,
      transaction: tx,
    );
    if (rows.length > 4096 ||
        rows.fold<int>(0, (n, r) => n + r.byteCount) > 67108864 ||
        rows.any(
          (r) =>
              r.byteCount < 1 ||
              r.byteCount > 32768 ||
              r.id == null ||
              r.generation < 1 ||
              r.generation > CalendarService._maxRevision ||
              r.attemptCount < 0 ||
              r.attemptCount > 32 ||
              r.leaseFence < 0 ||
              r.leaseFence > CalendarService._maxRevision ||
              r.byteCount != utf8.encode(r.payload).length ||
              sha256.convert(utf8.encode(r.payload)).toString() !=
                  r.payloadDigest,
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return rows;
  }

  Future<void> _irStop(
    CalendarInvitationResponseRecord row,
    Transaction tx,
    DateTime now,
    CalendarInvitationResponseDeliveryState outcome,
    String code,
  ) async {
    row.state = outcome;
    row.terminalAt = now;
    row.resultCode = code;
    row.leaseOwner = null;
    row.leaseToken = null;
    row.leaseUntil = null;
    await CalendarInvitationResponseRecord.db.updateRow(
      _session,
      row,
      transaction: tx,
    );
    final unfinished = await CalendarInvitationResponseAttemptRecord.db.find(
      _session,
      where: (t) => t.responseId.equals(row.id!) & t.finishedAt.equals(null),
      limit: 33,
      transaction: tx,
    );
    if (unfinished.length > 32) throw _failure(CalendarFailureCode.unavailable);
    for (final attempt in unfinished) {
      attempt.finishedAt = now;
      attempt.outcome = 'uncertain';
      attempt.resultCode = code;
      await CalendarInvitationResponseAttemptRecord.db.updateRow(
        _session,
        attempt,
        transaction: tx,
      );
    }
    final state = await CalendarInvitationResponseStateRecord.db.findById(
      _session,
      row.stateId,
      transaction: tx,
    );
    if (state == null ||
        state.scopeKey != row.scopeKey ||
        state.recipientKey != row.recipientKey ||
        state.entryId != row.entryId) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (state.latestResponseId == row.id && state.revision == row.generation) {
      state.outcome = outcome;
      state.updatedAt = now.isBefore(state.updatedAt) ? state.updatedAt : now;
      await CalendarInvitationResponseStateRecord.db.updateRow(
        _session,
        state,
        transaction: tx,
      );
    }
  }

  Future<void> _irCleanup(String scope, Transaction tx, DateTime now) async {
    final rows = await _irRows(scope, tx),
        cutoff = now.subtract(_irOptions.retention);
    for (final row
        in rows
            .where(
              (r) => r.terminalAt != null && !r.terminalAt!.isAfter(cutoff),
            )
            .take(_irOptions.batchSize)) {
      if (row.leaseOwner != null ||
          row.leaseToken != null ||
          row.leaseUntil != null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await CalendarInvitationResponseAttemptRecord.db.deleteWhere(
        _session,
        where: (t) => t.responseId.equals(row.id!),
        transaction: tx,
      );
      await CalendarInvitationResponseRecord.db.deleteRow(
        _session,
        row,
        transaction: tx,
      );
    }
  }

  void _irRecord(
    CalendarInvitationResponseRecord row,
    CalendarInvitationResponseStateRecord state,
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry,
  ) {
    try {
      _irRecordUnchecked(row, state, source, entry);
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  void _irRecordUnchecked(
    CalendarInvitationResponseRecord row,
    CalendarInvitationResponseStateRecord state,
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry,
  ) {
    if (row.scopeKey != state.scopeKey ||
        row.recipientKey != state.recipientKey ||
        row.entryId != entry.id ||
        row.stateId != state.id ||
        row.request.invitationId != row.entryId ||
        row.request.sourceId != source.id ||
        row.sourceId != source.id ||
        row.sourceDigest != source.digest ||
        row.sourceSequence != source.sequence ||
        row.sourceStamp != source.stamp ||
        row.sourceRevision != row.request.expectedInvitationRevision ||
        row.generation != row.request.expectedResponseRevision + 1 ||
        row.choice != row.request.choice ||
        row.commandId != row.request.commandId ||
        row.criteriaDigest !=
            _invitationHash([jsonEncode(row.request.toJson())]) ||
        row.receipt.id != row.id ||
        row.receipt.invitationId != row.entryId ||
        row.receipt.sourceId != row.sourceId ||
        row.receipt.stateRevision != row.generation ||
        row.receipt.choice != row.choice ||
        row.receipt.stamp != row.stamp ||
        row.receipt.queuedAt != row.createdAt ||
        row.byteCount != utf8.encode(row.payload).length ||
        row.byteCount > 32768 ||
        sha256.convert(utf8.encode(row.payload)).toString() !=
            row.payloadDigest ||
        !row.stamp.isUtc ||
        row.stamp.microsecond != 0 ||
        row.stamp.millisecond != 0 ||
        row.expiresAt.isBefore(row.createdAt)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final parsed = _irParse(utf8.encode(row.payload));
    if (parsed.events.length != 1) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final event = parsed.events.single;
    final basis = _invStored(source, entry);
    final expected = _irPayload(
      basis,
      row.choice,
      CalendarInvitationResponseAuthority(
        attendeeAddress: row.recipientAddress,
        authorityRef: row.authorityRef,
        organizer: CalendarSchedulingRoute(row.organizerAddress, row.routeRef),
      ),
      row.stamp,
    );
    if (parsed.method != IcalendarSchedulingMethod.reply ||
        parsed.events.length != 1 ||
        event.uid != entry.uid ||
        event.sequence != source.sequence ||
        event.stamp != row.stamp ||
        event.participants.organizer?.address != entry.organizer ||
        event.participants.attendees.single.address != row.recipientAddress ||
        event.participants.attendees.single.participationStatus !=
            row.choice.name.toUpperCase() ||
        row.payload != expected) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<CalendarInvitationResponseView> invitationResponse(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        _irGuarantee();
        final entry = await _invEntry(id, recipient, tx);
        await _irSourceRead(actor, recipient, entry, null, tx);
        final state = await _irState(recipient, id, tx);
        final source = entry.currentSourceId == null
            ? null
            : await _irSource(entry.currentSourceId!, entry, tx);
        await _irSourceRead(actor, recipient, entry, source, tx);
        final view = _irView(entry, state),
            context = _irContext(
              operation: CalendarInvitationResponseOperation.read,
              recipient: recipient,
              invitation: await _invView(entry, tx),
              current: view,
              actor: actor,
              source: source,
              sourceRevision: source == null ? null : entry.revision,
              sourceMessage: source == null ? null : _invStored(source, entry),
            );
        await _irAuthorize(context, tx, CalendarAuthorizationPhase.read);
        return view;
      });
  Future<List<CalendarInvitationResponseActivityView>>
  invitationResponseActivity(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invEntry(id, recipient, tx);
        await _irSourceRead(actor, recipient, entry, null, tx);
        final state = await _irState(recipient, id, tx);
        final source = entry.currentSourceId == null
            ? null
            : await _irSource(entry.currentSourceId!, entry, tx);
        await _irSourceRead(actor, recipient, entry, source, tx);
        final context = _irContext(
          operation: CalendarInvitationResponseOperation.read,
          recipient: recipient,
          invitation: await _invView(entry, tx),
          current: _irView(entry, state),
          actor: actor,
          source: source,
          sourceRevision: entry.revision,
          sourceMessage: source == null ? null : _invStored(source, entry),
        );
        await _irAuthorize(context, tx, CalendarAuthorizationPhase.read);
        final rows = await CalendarInvitationResponseRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(recipient.scopeKey) &
              t.recipientKey.equals(recipient.key) &
              t.entryId.equals(id),
          orderBy: (t) => t.stamp.desc(),
          limit: 33,
          transaction: tx,
        );
        if (rows.length > 32) throw _failure(CalendarFailureCode.unavailable);
        final result = <CalendarInvitationResponseActivityView>[];
        for (final row in rows) {
          if (state == null) throw _failure(CalendarFailureCode.unavailable);
          final basis = await _irSource(row.sourceId, entry, tx);
          _irRecord(row, state, basis, entry);
          result.add(
            CalendarInvitationResponseActivityView(
              id: row.id!,
              stateRevision: row.generation,
              choice: row.choice,
              sourceId: row.sourceId,
              sourceRevision: row.sourceRevision,
              sourceSequence: row.sourceSequence,
              sourceStamp: row.sourceStamp,
              stamp: row.stamp,
              deliveryState: row.state,
              attemptCount: row.attemptCount,
              queuedAt: row.createdAt,
              expiresAt: row.expiresAt,
              terminalAt: row.terminalAt,
              resultCode: row.resultCode,
            ),
          );
        }
        await _irAuthorize(context, tx, CalendarAuthorizationPhase.read);
        return List.unmodifiable(result);
      });

  Future<CalendarInvitationResponseReceipt> sendInvitationResponse(
    CalendarInvitationResponseRequest request,
  ) {
    if (request.expectedInvitationRevision < 1 ||
        request.expectedInvitationRevision > CalendarService._maxRevision ||
        request.expectedResponseRevision < 0 ||
        request.expectedResponseRevision >= CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    return _invNative((actor, recipient, tx) async {
      _irGuarantee();
      final entry = await _invEntry(request.invitationId, recipient, tx);
      await _irSourceRead(actor, recipient, entry, null, tx);
      var state = await _irState(recipient, request.invitationId, tx);
      await _irAuthorize(
        _irContext(
          operation: CalendarInvitationResponseOperation.read,
          recipient: recipient,
          invitation: await _invView(entry, tx),
          current: _irView(entry, state),
          actor: actor,
        ),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final existing = await CalendarInvitationResponseRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key) &
            t.commandId.equals(request.commandId),
        transaction: tx,
      );
      final criteria = _invitationHash([jsonEncode(request.toJson())]);
      if (existing != null &&
          (existing.entryId != entry.id ||
              existing.criteriaDigest != criteria)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final source = await _irSource(
        existing?.sourceId ?? request.sourceId,
        entry,
        tx,
      );
      await _irSourceRead(
        actor,
        recipient,
        entry,
        source,
        tx,
        retry: existing != null,
      );
      final basis = _invStored(source, entry),
          current = _irView(entry, state),
          invitation = await _invView(entry, tx);
      final read = _irContext(
        operation: CalendarInvitationResponseOperation.read,
        recipient: recipient,
        invitation: invitation,
        current: current,
        actor: actor,
        source: source,
        sourceRevision: existing?.sourceRevision ?? entry.revision,
        sourceMessage: basis,
        retry: existing != null,
      );
      await _irAuthorize(read, tx, CalendarAuthorizationPhase.preliminaryWrite);
      if (existing != null) {
        if (state == null) throw _failure(CalendarFailureCode.unavailable);
        _irRecord(existing, state, source, entry);
        final authority = _irAuthority(
          CalendarInvitationResponseAuthority(
            attendeeAddress: existing.recipientAddress,
            authorityRef: existing.authorityRef,
            organizer: CalendarSchedulingRoute(
              existing.organizerAddress,
              existing.routeRef,
            ),
          ),
          recipient,
          basis,
        );
        final context = _irContext(
          operation: CalendarInvitationResponseOperation.send,
          recipient: recipient,
          invitation: invitation,
          current: current,
          actor: actor,
          source: source,
          sourceRevision: existing.sourceRevision,
          sourceMessage: basis,
          request: request,
          receipt: existing.receipt,
          outgoing: _irParse(utf8.encode(existing.payload)),
          digest: existing.payloadDigest,
          authority: authority,
          retry: true,
        );
        await _irAuthorize(
          context,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        await _irSourceRead(
          actor,
          recipient,
          entry,
          source,
          tx,
          retry: true,
          phase: CalendarAuthorizationPhase.finalWrite,
        );
        await _irAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
        return existing.receipt;
      }
      if (entry.revision != request.expectedInvitationRevision ||
          entry.currentSourceId != request.sourceId ||
          current.revision != request.expectedResponseRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (entry.kind != CalendarInvitationSourceKind.request ||
          basis.method != IcalendarSchedulingMethod.request ||
          basis.events.single.status == IcalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.validation);
      }
      final now = await _revisionTime(tx);
      final stamp = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
      if (state != null && !stamp.isAfter(state.lastStamp)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final authority = _irAuthority(
        await _bounded(() => _irRuntime.host.resolve(_session, read, tx)),
        recipient,
        basis,
      );
      final payload = _irPayload(basis, request.choice, authority, stamp),
          digest = sha256.convert(utf8.encode(payload)).toString();
      await _irCleanup(recipient.scopeKey, tx, now);
      final rows = await _irRows(recipient.scopeKey, tx),
          own = rows.where((r) => r.recipientKey == recipient.key).toList();
      final inState = own.where((r) => r.entryId == entry.id).toList();
      final states = await CalendarInvitationResponseStateRecord.db.find(
        _session,
        where: (t) => t.scopeKey.equals(recipient.scopeKey),
        limit: 4097,
        transaction: tx,
      );
      if (states.length > 4096 ||
          own.length > 512 ||
          inState.length > 32 ||
          states.where((s) => s.recipientKey == recipient.key).length > 128) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final o = _irOptions, bytes = utf8.encode(payload).length;
      if (bytes > o.maxPayloadBytes) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (state == null &&
              (states.length >= o.maxStatesPerScope ||
                  states.where((s) => s.recipientKey == recipient.key).length >=
                      o.maxStatesPerRecipient) ||
          rows.length >= o.maxResponsesPerScope ||
          own.length >= o.maxResponsesPerRecipient ||
          inState.length >= o.maxResponsesPerState ||
          own
                  .where((r) => r.terminalAt == null && r.entryId != entry.id)
                  .length >=
              o.maxPendingPerRecipient ||
          own.fold<int>(bytes, (n, r) => n + r.byteCount) >
              o.maxRecipientPayloadBytes ||
          rows.fold<int>(bytes, (n, r) => n + r.byteCount) >
              o.maxScopePayloadBytes) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final id = const Uuid().v4obj(), revision = current.revision + 1;
      final receipt = CalendarInvitationResponseReceipt(
        id: id,
        invitationId: entry.id!,
        sourceId: source.id!,
        stateRevision: revision,
        choice: request.choice,
        stamp: stamp,
        queuedAt: now,
      );
      final proposed = CalendarInvitationResponseView(
        invitationId: entry.id!,
        revision: revision,
        responseId: id,
        choice: request.choice,
        stamp: stamp,
        sourceId: source.id,
        sourceRevision: entry.revision,
        sourceSequence: source.sequence,
        sourceStamp: source.stamp,
        appliesToCurrentSource: true,
        deliveryState: CalendarInvitationResponseDeliveryState.queued,
      );
      final context = _irContext(
        operation: CalendarInvitationResponseOperation.send,
        recipient: recipient,
        invitation: invitation,
        current: current,
        actor: actor,
        source: source,
        sourceRevision: entry.revision,
        sourceMessage: basis,
        proposed: proposed,
        request: request,
        receipt: receipt,
        outgoing: _irParse(utf8.encode(payload)),
        digest: digest,
        authority: authority,
      );
      await _irAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      for (final old in inState.where((r) => r.terminalAt == null)) {
        await _irStop(
          old,
          tx,
          now,
          CalendarInvitationResponseDeliveryState.withdrawn,
          'superseded',
        );
      }
      if (state == null) {
        state = await CalendarInvitationResponseStateRecord.db.insertRow(
          _session,
          CalendarInvitationResponseStateRecord(
            scopeKey: recipient.scopeKey,
            recipientKey: recipient.key,
            entryId: entry.id!,
            recipientAddress: recipient.calendarAddress,
            revision: revision,
            latestResponseId: id,
            lastStamp: stamp,
            choice: request.choice,
            sourceId: source.id!,
            sourceRevision: entry.revision,
            sourceDigest: source.digest,
            sourceSequence: source.sequence,
            sourceStamp: source.stamp,
            outcome: CalendarInvitationResponseDeliveryState.queued,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
      } else {
        state.recipientAddress = recipient.calendarAddress;
        state.revision = revision;
        state.latestResponseId = id;
        state.lastStamp = stamp;
        state.choice = request.choice;
        state.sourceId = source.id!;
        state.sourceRevision = entry.revision;
        state.sourceDigest = source.digest;
        state.sourceSequence = source.sequence;
        state.sourceStamp = source.stamp;
        state.outcome = CalendarInvitationResponseDeliveryState.queued;
        state.updatedAt = now.isBefore(state.updatedAt) ? state.updatedAt : now;
        await CalendarInvitationResponseStateRecord.db.updateRow(
          _session,
          state,
          transaction: tx,
        );
      }
      await CalendarInvitationResponseRecord.db.insertRow(
        _session,
        CalendarInvitationResponseRecord(
          id: id,
          scopeKey: recipient.scopeKey,
          recipientKey: recipient.key,
          stateId: state.id!,
          entryId: entry.id!,
          commandId: request.commandId,
          criteriaDigest: criteria,
          request: request,
          receipt: receipt,
          sourceId: source.id!,
          sourceRevision: entry.revision,
          sourceDigest: source.digest,
          sourceSequence: source.sequence,
          sourceStamp: source.stamp,
          recipientAddress: recipient.calendarAddress,
          organizerAddress: authority.organizer.address,
          authorityRef: authority.authorityRef,
          routeRef: authority.organizer.routeRef,
          generation: revision,
          choice: request.choice,
          stamp: stamp,
          payload: payload,
          payloadDigest: digest,
          byteCount: bytes,
          createdAt: now,
          expiresAt: now.add(o.expiry),
          nextAttemptAt: now,
        ),
        transaction: tx,
      );
      await _irSourceRead(
        actor,
        recipient,
        entry,
        source,
        tx,
        phase: CalendarAuthorizationPhase.finalWrite,
      );
      await _irAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
      return receipt;
    });
  }
}
