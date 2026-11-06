part of 'calendar_module.dart';

extension CalendarInvitationResponseOperations on CalendarService {
  bool _irRequestKind(CalendarInvitationSourceKind kind) => {
    CalendarInvitationSourceKind.request,
    CalendarInvitationSourceKind.requestBundle,
  }.contains(kind);
  void _irProfile(CalendarInvitationRecord entry, {bool bundleMaster = false}) {
    if (!bundleMaster) {
      _invNonRange(entry);
      return;
    }
    _invTargetValid(entry);
    if (!_invBundleKind(entry.kind) ||
        entry.originalStart != null ||
        !entry.recurring) {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  String _irTargetKey(CalendarEventTiming? original) => original == null
      ? 'entry'
      : _schedulingValue(() => invitationBundleResponseTargetKey(original));
  void _irStoredTarget(String key, CalendarEventTiming? original) {
    try {
      if (key !=
          (key.startsWith('recurring-occurrence-v1:') && original != null
              ? _rrKey(original)
              : _irTargetKey(original))) {
        throw StateError('Invalid response target');
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarInvitationBundleResponseTarget _irBundleTarget(
    IcalendarSchedulingMessage source,
    CalendarEventTiming original,
    RecurrenceWorkBudget? work,
  ) => _schedulingValue(
    () => resolveInvitationBundleResponseTarget(
      source,
      original,
      sharedWorkBudget: work,
    ),
  );
  String _irCriteria(
    CalendarInvitationResponseRequest request,
    bool bundleMaster, [
    CalendarEventTiming? original,
  ]) => _invitationHash([
    if (original != null) ...[
      'bundle-occurrence-response-v1',
      _irTargetKey(original),
      jsonEncode(original.toJson()),
    ] else if (bundleMaster)
      'bundle-master-response-v1',
    jsonEncode(request.toJson()),
  ]);

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
    CalendarAuthorizationPhase phase, {
    RecurrenceWorkBudget? work,
  }) async {
    _irGuarantee();
    final evidence = await _irEvidence(context, tx, work: work);
    final current = evidence.context;
    final extra = current.invitation.originalStart == null
        ? null
        : switch (current.operation) {
            CalendarInvitationResponseOperation.send =>
              CalendarInvitationResponseOperation.sendOccurrence,
            CalendarInvitationResponseOperation.dispatch =>
              CalendarInvitationResponseOperation.dispatchOccurrence,
            _ => null,
          };
    final bundle =
        _invBundleKind(current.invitation.kind) ||
        (current.sourceMessage != null && _invBundle(current.sourceMessage!));
    final bundleOperation = !bundle
        ? null
        : current.responseOriginalStart != null
        ? switch (current.operation) {
            CalendarInvitationResponseOperation.read =>
              CalendarInvitationResponseOperation.readBundleOccurrence,
            CalendarInvitationResponseOperation.send =>
              CalendarInvitationResponseOperation.sendBundleOccurrence,
            CalendarInvitationResponseOperation.dispatch =>
              CalendarInvitationResponseOperation.dispatchBundleOccurrence,
            _ => null,
          }
        : switch (current.operation) {
            CalendarInvitationResponseOperation.read =>
              CalendarInvitationResponseOperation.readBundleMaster,
            CalendarInvitationResponseOperation.send =>
              CalendarInvitationResponseOperation.sendBundleMaster,
            CalendarInvitationResponseOperation.dispatch =>
              CalendarInvitationResponseOperation.dispatchBundleMaster,
            _ => null,
          };
    final recurringOperation = current.recurringSelection == null
        ? null
        : switch (current.operation) {
            CalendarInvitationResponseOperation.read =>
              CalendarInvitationResponseOperation.readRecurringOccurrence,
            CalendarInvitationResponseOperation.send =>
              CalendarInvitationResponseOperation.sendRecurringOccurrence,
            CalendarInvitationResponseOperation.dispatch =>
              CalendarInvitationResponseOperation.dispatchRecurringOccurrence,
            _ => null,
          };
    for (final op in [
      current.operation,
      ?extra,
      ?bundleOperation,
      ?recurringOperation,
    ]) {
      final candidate = current.withOccurrence(
        basis: current.occurrenceBasis,
        unavailable: current.occurrenceBasisUnavailable,
        state: current.currentState,
        operation: op,
        responseComponentVersion: current.responseComponentVersion,
      );
      final verdict = await _bounded(
        () => _irRuntime.host.authorize(_session, candidate, tx, phase),
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
    if (evidence.error != null &&
        (current.operation == CalendarInvitationResponseOperation.dispatch ||
            current.operation == CalendarInvitationResponseOperation.send &&
                !current.isRetry)) {
      throw _failure(evidence.error!);
    }
  }

  CalendarInvitationResponseView _irView(
    CalendarInvitationRecord entry,
    CalendarInvitationResponseStateRecord? state, {
    CalendarEventTiming? responseOriginal,
  }) => CalendarInvitationResponseView(
    invitationId: entry.id!,
    originalStart: responseOriginal ?? entry.originalStart,
    canSend: _irRequestKind(entry.kind) && entry.currentSourceId != null,
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
        _irRequestKind(entry.kind),
    deliveryState: state?.outcome,
  );
  Future<CalendarInvitationResponseStateRecord?> _irState(
    CalendarInvitationRecipient recipient,
    UuidValue entryId,
    Transaction tx, {
    String targetKey = 'entry',
  }) async {
    final rows = await CalendarInvitationResponseStateRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.entryId.equals(entryId) &
          t.targetKey.equals(targetKey),
      limit: 2,
      transaction: tx,
    );
    if (rows.length > 1) throw _failure(CalendarFailureCode.unavailable);
    final state = rows.firstOrNull;
    if (state != null) {
      _irStoredTarget(state.targetKey, state.responseOriginalStart);
    }
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
    Transaction tx, {
    RecurrenceWorkBudget? work,
  }) async {
    final source = await CalendarInvitationSourceRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (source == null || source.entryId != entry.id) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    try {
      _invStored(source, entry, sharedWorkBudget: work);
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
    RecurrenceWorkBudget? work,
    CalendarAuthorizationPhase phase = CalendarAuthorizationPhase.read,
  }) async {
    await _invAuthorize(
      CalendarInvitationPolicyContext(
        operation: CalendarInvitationOperation.readSource,
        actor: actor,
        recipient: recipient,
        current: await _invView(entry, tx, sharedWorkBudget: work),
        entryId: entry.id,
        sourceId: source?.id,
        message: source == null
            ? null
            : _invStored(source, entry, sharedWorkBudget: work),
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
    CalendarEventTiming? responseOriginal,
    CalendarRecurringResponseEvidence? recurring,
    CalendarInvitationView? recurringOpened,
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
    request: request?.copyWith(),
    receipt: receipt?.copyWith(),
    outgoingMessage: outgoing,
    payloadDigest: digest,
    authority: authority,
    isRetry: retry,
    responseOriginalStart: responseOriginal,
    recurringSelection: recurring,
    recurringOpenedInvitation: recurringOpened,
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
    final event = _invHead(source);
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
    DateTime stamp, {
    CalendarEventTiming? responseOriginal,
    CalendarInvitationBundleComponentVersion? componentVersion,
  }) {
    if (stamp.year < 1970 || stamp.year >= 2100) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${stamp.year.toString().padLeft(4, '0')}${two(stamp.month)}${two(stamp.day)}T${two(stamp.hour)}${two(stamp.minute)}${two(stamp.second)}Z';
    final event = _invHead(source);
    final original = responseOriginal ?? _replyOriginal(event);
    if (responseOriginal != null && componentVersion == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final sequence = componentVersion == null
        ? event.sequence
        : componentVersion.sequence;
    final bytes = serializeIcalendarSyntax(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty(
            'PRODID',
            '-//Serverpod calendar attendee response//EN',
          ),
          IcalendarSyntaxProperty('METHOD', 'REPLY'),
          if (original?.zoneId != null)
            createIcalendarTimeZone(original!.zoneId!),
          IcalendarSyntaxComponent('VEVENT', [
            IcalendarSyntaxProperty('UID', encodeIcalendarText(event.uid)),
            IcalendarSyntaxProperty('DTSTAMP', date),
            if (original != null)
              EventComponentWriter().time('RECURRENCE-ID', original),
            if (sequence != null)
              IcalendarSyntaxProperty('SEQUENCE', '$sequence'),
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

  Future<void> _irRecord(
    CalendarInvitationResponseRecord row,
    CalendarInvitationResponseStateRecord state,
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry,
    Transaction tx, {
    RecurrenceWorkBudget? work,
  }) async {
    try {
      final recurring = row.selectionEvidenceId == null
          ? null
          : await _rrLoad(
              CalendarInvitationRecipient(
                scopeKey: row.scopeKey,
                key: row.recipientKey,
                calendarAddress: row.recipientAddress,
              ),
              row.selectionEvidenceId!,
              tx,
              work ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
            );
      if (recurring != null &&
          (recurring.head.masterEntryId != entry.id ||
              recurring.membership.id != source.id ||
              !recurring.entries.containsKey(row.receipt.invitationId))) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (recurring != null) {
        final opened = recurring.entries[row.receipt.invitationId]!;
        final original = row.responseOriginalStart;
        if (original == null ||
            (opened.originalStart != null &&
                (!_invRange(opened)
                    ? eventComponentKey(opened.originalStart!, false) !=
                          eventComponentKey(original, false)
                    : recurringResponseOrder(original, opened.originalStart!) <
                          0))) {
          throw _failure(CalendarFailureCode.unavailable);
        }
      }
      _irRecordUnchecked(
        row,
        state,
        source,
        entry,
        work: work,
        recurring: recurring,
      );
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  void _irRecordUnchecked(
    CalendarInvitationResponseRecord row,
    CalendarInvitationResponseStateRecord state,
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry, {
    RecurrenceWorkBudget? work,
    _RecurringSelection? recurring,
  }) {
    final basis = _invStored(source, entry, sharedWorkBudget: work);
    _irStoredTarget(row.targetKey, row.responseOriginalStart);
    _irStoredTarget(state.targetKey, state.responseOriginalStart);
    if (row.targetKey != state.targetKey ||
        _irTargetKey(row.responseOriginalStart) !=
            _irTargetKey(state.responseOriginalStart)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final recurringTarget = recurring == null
        ? null
        : _rrTarget(
            recurring.proof,
            row.responseOriginalStart!,
            row.recipientAddress,
            work ?? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
          );
    if (recurringTarget?.cancelled ?? false) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final component =
        recurringTarget?.componentVersion ??
        (row.responseOriginalStart == null
            ? null
            : _irBundleTarget(
                basis,
                row.responseOriginalStart!,
                work,
              ).componentVersion);
    final sourceSequence = component == null
        ? source.sequence
        : component.sequence;
    final sourceStamp = component?.stamp ?? source.stamp;
    _irProfile(entry, bundleMaster: _invBundle(basis));
    if (row.scopeKey != state.scopeKey ||
        row.recipientKey != state.recipientKey ||
        row.entryId != entry.id ||
        row.stateId != state.id ||
        row.request.invitationId != row.entryId ||
        row.request.sourceId != source.id ||
        row.sourceId != source.id ||
        row.sourceDigest != source.digest ||
        row.sourceSequence != sourceSequence ||
        row.sourceStamp != sourceStamp ||
        row.sourceRevision != row.request.expectedInvitationRevision ||
        row.generation != row.request.expectedResponseRevision + 1 ||
        row.choice != row.request.choice ||
        row.commandId != row.request.commandId ||
        row.criteriaDigest !=
            (recurring == null
                ? _irCriteria(
                    row.request,
                    _invBundle(basis),
                    row.responseOriginalStart,
                  )
                : _rrCriteria(
                    row.request,
                    row.responseOriginalStart!,
                    row.receipt.invitationId,
                    recurring.proof,
                  )) ||
        row.receipt.id != row.id ||
        (recurring == null && row.receipt.invitationId != row.entryId) ||
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
    final expected = _irPayload(
      basis,
      row.choice,
      CalendarInvitationResponseAuthority(
        attendeeAddress: row.recipientAddress,
        authorityRef: row.authorityRef,
        organizer: CalendarSchedulingRoute(row.organizerAddress, row.routeRef),
      ),
      row.stamp,
      responseOriginal: row.responseOriginalStart,
      componentVersion: component,
    );
    if (parsed.method != IcalendarSchedulingMethod.reply ||
        parsed.events.length != 1 ||
        event.uid != entry.uid ||
        event.sequence != sourceSequence ||
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
      _invitationResponse(id);
  Future<CalendarInvitationResponseView> invitationBundleResponse(
    UuidValue id,
  ) => _invitationResponse(id, bundleMaster: true);
  Future<CalendarInvitationResponseView> _invitationResponse(
    UuidValue id, {
    bool bundleMaster = false,
  }) async => (await _invitationResponseEnvelope(
    id,
    bundleMaster: bundleMaster,
  )).response;
  Future<CalendarInvitationBundleOccurrenceResponseView>
  invitationBundleOccurrenceResponse(
    UuidValue id,
    CalendarEventTiming original,
  ) => _invitationResponseEnvelope(
    id,
    bundleMaster: true,
    responseOriginal: original,
  );
  Future<CalendarInvitationBundleOccurrenceResponseView>
  _invitationResponseEnvelope(
    UuidValue id, {
    bool bundleMaster = false,
    CalendarEventTiming? responseOriginal,
  }) {
    final original = responseOriginal?.copyWith();
    final targetKey = _irTargetKey(original);
    return _invNative((actor, recipient, tx) async {
      final responseOriginal = original;
      final work = bundleMaster
          ? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork)
          : null;
      final entry = await _invEntry(id, recipient, tx);
      await _irSourceRead(actor, recipient, entry, null, tx, work: work);
      if (!bundleMaster &&
          entry.originalStart != null &&
          !_invRange(entry) &&
          await _rrHead(recipient, entry.correlationDigest, tx) != null) {
        final value = await _rrRead(
          actor,
          recipient,
          id,
          entry.originalStart!,
          tx,
        );
        return CalendarInvitationBundleOccurrenceResponseView(
          response: value.response.copyWith(canSend: false),
          invitationRevision: value.masterInvitationRevision,
          currentSourceId: value.membershipSourceId,
          componentVersion: value.componentVersion,
        );
      }
      _irProfile(entry, bundleMaster: bundleMaster);
      _irGuarantee();
      final state = await _irState(recipient, id, tx, targetKey: targetKey);
      final source = entry.currentSourceId == null
          ? null
          : await _irSource(entry.currentSourceId!, entry, tx, work: work);
      await _irSourceRead(actor, recipient, entry, source, tx, work: work);
      final view = _irView(entry, state, responseOriginal: responseOriginal),
          context = _irContext(
            operation: CalendarInvitationResponseOperation.read,
            recipient: recipient,
            invitation: await _invView(entry, tx, sharedWorkBudget: work),
            current: view,
            actor: actor,
            responseOriginal: responseOriginal,
            source: source,
            sourceRevision: source == null ? null : entry.revision,
            sourceMessage: source == null
                ? null
                : _invStored(source, entry, sharedWorkBudget: work),
          );
      await _irAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.read,
        work: work,
      );
      final evidence = await _irEvidence(context, tx, work: work);
      if (responseOriginal != null && state == null && evidence.error != null) {
        throw _failure(evidence.error!);
      }
      return CalendarInvitationBundleOccurrenceResponseView(
        response: evidence.context.currentState,
        invitationRevision: entry.revision,
        currentSourceId: entry.currentSourceId,
        componentVersion: evidence.context.responseComponentVersion,
      );
    });
  }

  Future<List<CalendarInvitationResponseActivityView>>
  invitationResponseActivity(UuidValue id) => _invitationResponseActivity(id);
  Future<List<CalendarInvitationResponseActivityView>>
  invitationBundleResponseActivity(UuidValue id) =>
      _invitationResponseActivity(id, bundleMaster: true);
  Future<List<CalendarInvitationResponseActivityView>>
  invitationBundleOccurrenceResponseActivity(
    UuidValue id,
    CalendarEventTiming original,
  ) => _invitationResponseActivity(
    id,
    bundleMaster: true,
    responseOriginal: original.copyWith(),
  );
  Future<List<CalendarInvitationResponseActivityView>>
  _invitationResponseActivity(
    UuidValue id, {
    bool bundleMaster = false,
    CalendarEventTiming? responseOriginal,
  }) => _invNative((actor, recipient, tx) async {
    final work = bundleMaster
        ? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork)
        : null;
    final entry = await _invEntry(id, recipient, tx);
    await _irSourceRead(actor, recipient, entry, null, tx, work: work);
    if (!bundleMaster &&
        entry.originalStart != null &&
        !_invRange(entry) &&
        await _rrHead(recipient, entry.correlationDigest, tx) != null) {
      return _rrActivity(actor, recipient, id, entry.originalStart!, tx);
    }
    _irProfile(entry, bundleMaster: bundleMaster);
    final state = await _irState(
      recipient,
      id,
      tx,
      targetKey: _irTargetKey(responseOriginal),
    );
    final source = entry.currentSourceId == null
        ? null
        : await _irSource(entry.currentSourceId!, entry, tx, work: work);
    await _irSourceRead(actor, recipient, entry, source, tx, work: work);
    final context = _irContext(
      operation: CalendarInvitationResponseOperation.read,
      recipient: recipient,
      invitation: await _invView(entry, tx, sharedWorkBudget: work),
      current: _irView(entry, state, responseOriginal: responseOriginal),
      actor: actor,
      responseOriginal: responseOriginal,
      source: source,
      sourceRevision: entry.revision,
      sourceMessage: source == null
          ? null
          : _invStored(source, entry, sharedWorkBudget: work),
    );
    await _irAuthorize(
      context,
      tx,
      CalendarAuthorizationPhase.read,
      work: work,
    );
    final evidence = await _irEvidence(context, tx, work: work);
    if (responseOriginal != null && state == null && evidence.error != null) {
      throw _failure(evidence.error!);
    }
    final rows = await CalendarInvitationResponseRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.entryId.equals(id) &
          t.targetKey.equals(_irTargetKey(responseOriginal)),
      orderBy: (t) => t.stamp.desc(),
      limit: 33,
      transaction: tx,
    );
    if (rows.length > 32) throw _failure(CalendarFailureCode.unavailable);
    final result = <CalendarInvitationResponseActivityView>[];
    for (final row in rows) {
      if (state == null) throw _failure(CalendarFailureCode.unavailable);
      final basis = await _irSource(row.sourceId, entry, tx, work: work);
      await _irRecord(row, state, basis, entry, tx, work: work);
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
    await _irAuthorize(
      context,
      tx,
      CalendarAuthorizationPhase.read,
      work: work,
    );
    return List.unmodifiable(result);
  });

  Future<CalendarInvitationResponseReceipt> sendInvitationResponse(
    CalendarInvitationResponseRequest request,
  ) => _sendInvitationResponse(request);
  Future<CalendarInvitationResponseReceipt> sendInvitationBundleResponse(
    CalendarInvitationResponseRequest request,
  ) => _sendInvitationResponse(request, bundleMaster: true);
  Future<CalendarInvitationResponseReceipt>
  sendInvitationBundleOccurrenceResponse(
    CalendarInvitationBundleOccurrenceResponseRequest input,
  ) => _sendInvitationResponse(
    input.request,
    bundleMaster: true,
    responseOriginal: input.originalStart,
  );
  Future<CalendarInvitationResponseReceipt> _sendInvitationResponse(
    CalendarInvitationResponseRequest input, {
    bool bundleMaster = false,
    CalendarEventTiming? responseOriginal,
    CalendarInvitationRecurringOccurrenceResponseRequest? recurringRequest,
  }) {
    final request = input.copyWith();
    final original = responseOriginal?.copyWith();
    final recurringInput = recurringRequest?.copyWith(
      request: request,
      originalStart: original,
    );
    final targetKey = recurringInput == null
        ? _irTargetKey(original)
        : _rrKey(original!);
    if (request.expectedInvitationRevision < 1 ||
        request.expectedInvitationRevision > CalendarService._maxRevision ||
        request.expectedResponseRevision < 0 ||
        request.expectedResponseRevision >= CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    return _invNative((actor, recipient, tx) async {
      final responseOriginal = original;
      final work = bundleMaster || recurringInput != null
          ? RecurrenceWorkBudget(maxWork: eventMaxCandidateWork)
          : null;
      final entry = await _invEntry(request.invitationId, recipient, tx);
      await _irSourceRead(actor, recipient, entry, null, tx, work: work);
      _irProfile(entry, bundleMaster: bundleMaster);
      _irGuarantee();
      final recurringRoute = recurringInput == null
          ? null
          : await _rrRoute(
              actor,
              recipient,
              recurringInput.openedInvitationId,
              original!,
              tx,
              work!,
              evidenceId: recurringInput.selectionEvidenceId,
              retry: true,
            );
      final recurring = recurringRoute?.selection;
      final recurringOpened = recurringRoute == null
          ? null
          : await _invView(recurringRoute.opened, tx, sharedWorkBudget: work);
      if (recurringInput != null &&
          (recurring!.master.id != entry.id ||
              recurring.head.id != recurringInput.selectionHeadId ||
              recurring.row.revision !=
                  recurringInput.expectedSelectionRevision ||
              recurring.row.digest != recurringInput.selectionDigest ||
              recurring.membership.id != request.sourceId)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (recurringInput == null &&
          entry.originalStart != null &&
          !_invRange(entry) &&
          await _rrHead(recipient, entry.correlationDigest, tx) != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      var state = await _irState(
        recipient,
        request.invitationId,
        tx,
        targetKey: targetKey,
      );
      await _irAuthorize(
        _irContext(
          operation: CalendarInvitationResponseOperation.read,
          recipient: recipient,
          invitation: await _invView(entry, tx, sharedWorkBudget: work),
          current: _irView(entry, state, responseOriginal: responseOriginal),
          actor: actor,
          responseOriginal: responseOriginal,
          recurring: recurring?.proof,
          recurringOpened: recurringOpened,
        ),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        work: work,
      );
      final existing = await CalendarInvitationResponseRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key) &
            t.commandId.equals(request.commandId),
        transaction: tx,
      );
      final criteria = recurring == null
          ? _irCriteria(request, bundleMaster, responseOriginal)
          : _rrCriteria(
              request,
              original!,
              recurringInput!.openedInvitationId,
              recurring.proof,
            );
      if (existing != null &&
          (existing.entryId != entry.id || existing.targetKey != targetKey)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final source = await _irSource(
        existing?.sourceId ?? request.sourceId,
        entry,
        tx,
        work: work,
      );
      await _irSourceRead(
        actor,
        recipient,
        entry,
        source,
        tx,
        work: work,
        retry: existing != null,
      );
      final basis = _invStored(source, entry, sharedWorkBudget: work),
          target = recurring != null
              ? _rrTarget(
                  recurring.proof,
                  original!,
                  recipient.calendarAddress,
                  work!,
                )
              : responseOriginal == null
              ? null
              : _irBundleTarget(
                  _invStored(source, entry, sharedWorkBudget: work),
                  responseOriginal,
                  work,
                ),
          sourceSequence = target == null
              ? source.sequence
              : target.componentVersion.sequence,
          sourceStamp = target?.componentVersion.stamp ?? source.stamp,
          current = _irView(entry, state, responseOriginal: responseOriginal),
          invitation = await _invView(entry, tx, sharedWorkBudget: work);
      final read = _irContext(
        operation: CalendarInvitationResponseOperation.read,
        recipient: recipient,
        invitation: invitation,
        current: current,
        actor: actor,
        responseOriginal: responseOriginal,
        recurring: recurring?.proof,
        recurringOpened: recurringOpened,
        source: source,
        sourceRevision: existing?.sourceRevision ?? entry.revision,
        sourceMessage: basis,
        retry: existing != null,
      );
      await _irAuthorize(
        read,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        work: work,
      );
      if (existing != null) {
        if (state == null) throw _failure(CalendarFailureCode.unavailable);
        await _irRecord(existing, state, source, entry, tx, work: work);
        if (existing.criteriaDigest != criteria) {
          throw _failure(CalendarFailureCode.validation);
        }
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
          responseOriginal: responseOriginal,
          recurring: recurring?.proof,
          recurringOpened: recurringOpened,
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
          work: work,
        );
        await _irSourceRead(
          actor,
          recipient,
          entry,
          source,
          tx,
          retry: true,
          work: work,
          phase: CalendarAuthorizationPhase.finalWrite,
        );
        await _irAuthorize(
          context,
          tx,
          CalendarAuthorizationPhase.finalWrite,
          work: work,
        );
        return existing.receipt;
      }
      if (recurring != null && !_rrOptions.enabled) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (recurring != null &&
          (recurring.head.currentEvidenceId != recurring.row.id ||
              recurring.head.state != 'active' ||
              !_rrVectorCurrent(recurring))) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (entry.revision != request.expectedInvitationRevision ||
          entry.currentSourceId != request.sourceId ||
          current.revision != request.expectedResponseRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      if (entry.kind !=
              (bundleMaster
                  ? CalendarInvitationSourceKind.requestBundle
                  : CalendarInvitationSourceKind.request) ||
          basis.method != IcalendarSchedulingMethod.request ||
          _invHead(basis).status == IcalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (target?.cancelled ?? false) {
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
        await _bounded(
          () async => _irRuntime.host.resolve(
            _session,
            (await _irEvidence(read, tx, work: work)).context,
            tx,
          ),
        ),
        recipient,
        basis,
      );
      final payload = _irPayload(
            basis,
            request.choice,
            authority,
            stamp,
            responseOriginal: responseOriginal,
            componentVersion: target?.componentVersion,
          ),
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
                  .where(
                    (r) =>
                        r.terminalAt == null &&
                        !(r.entryId == entry.id && r.targetKey == targetKey),
                  )
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
        invitationId: recurringInput?.openedInvitationId ?? entry.id!,
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
        sourceSequence: sourceSequence,
        sourceStamp: sourceStamp,
        appliesToCurrentSource: true,
        originalStart: responseOriginal ?? entry.originalStart,
        canSend: true,
        deliveryState: CalendarInvitationResponseDeliveryState.queued,
      );
      final context = _irContext(
        operation: CalendarInvitationResponseOperation.send,
        recipient: recipient,
        invitation: invitation,
        current: current,
        actor: actor,
        responseOriginal: responseOriginal,
        recurring: recurring?.proof,
        recurringOpened: recurringOpened,
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
        work: work,
      );
      for (final old in inState.where(
        (r) => r.terminalAt == null && r.targetKey == targetKey,
      )) {
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
            targetKey: targetKey,
            responseOriginalStart: responseOriginal,
            recipientAddress: recipient.calendarAddress,
            revision: revision,
            latestResponseId: id,
            lastStamp: stamp,
            choice: request.choice,
            sourceId: source.id!,
            sourceRevision: entry.revision,
            sourceDigest: recurring?.proof.digest ?? source.digest,
            sourceSequence: sourceSequence,
            sourceStamp: sourceStamp,
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
        state.sourceDigest = recurring?.proof.digest ?? source.digest;
        state.sourceSequence = sourceSequence;
        state.sourceStamp = sourceStamp;
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
          targetKey: targetKey,
          responseOriginalStart: responseOriginal,
          selectionEvidenceId: recurring?.row.id,
          commandId: request.commandId,
          criteriaDigest: criteria,
          request: request,
          receipt: receipt,
          sourceId: source.id!,
          sourceRevision: entry.revision,
          sourceDigest: source.digest,
          sourceSequence: sourceSequence,
          sourceStamp: sourceStamp,
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
        work: work,
        phase: CalendarAuthorizationPhase.finalWrite,
      );
      if (recurring != null) {
        await _rrSourcesRead(
          actor,
          recipient,
          recurring,
          tx,
          work!,
          phase: CalendarAuthorizationPhase.finalWrite,
        );
      }
      await _irAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        work: work,
      );
      return receipt;
    });
  }
}
