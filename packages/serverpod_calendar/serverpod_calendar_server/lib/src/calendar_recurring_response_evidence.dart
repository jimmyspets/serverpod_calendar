part of 'calendar_module.dart';

final class _RecurringSelection {
  _RecurringSelection(
    this.head,
    this.row,
    this.data,
    this.entries,
    this.sources,
    this.proof,
  );
  final CalendarInvitationResponseSelectionHeadRecord head;
  final CalendarInvitationResponseSelectionEvidenceRecord row;
  final Map<String, dynamic> data;
  final Map<UuidValue, CalendarInvitationRecord> entries;
  final Map<UuidValue, CalendarInvitationSourceRecord> sources;
  final CalendarRecurringResponseEvidence proof;
  CalendarInvitationRecord get master => entries[head.masterEntryId]!;
  CalendarInvitationSourceRecord get membership =>
      sources[UuidValue.fromString(data['membership'] as String)]!;
}

extension CalendarRecurringResponseEvidenceOperations on CalendarService {
  Future<void> _rrMaintenance() async {
    final due = await _session.db.unsafeQuery(
      '''SELECT DISTINCT h."scopeKey",h."recipientKey"
      FROM calendar_inv_response_selection_head h WHERE
      EXISTS(SELECT 1 FROM calendar_inv_response_selection_evidence e WHERE e."headId"=h.id
        AND e."retiredAt"<=clock_timestamp()-make_interval(secs=>@seconds) AND (h."currentEvidenceId" IS NULL OR e.id<>h."currentEvidenceId")
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_response r WHERE r."selectionEvidenceId"=e.id))
      OR (h.state='purged' AND h."purgedAt"<=clock_timestamp()-make_interval(secs=>@seconds)
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_link l
          WHERE l."scopeKey"=h."scopeKey" AND l."recipientKey"=h."recipientKey" AND l."correlationDigest"=h."correlationDigest")
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation i WHERE i."scopeKey"=h."scopeKey"
          AND i."recipientKey"=h."recipientKey" AND i."correlationDigest"=h."correlationDigest" AND i."dismissedAt" IS NULL)
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_response r JOIN serverpod_calendar_invitation i ON i.id=r."entryId"
          WHERE i."scopeKey"=h."scopeKey" AND i."recipientKey"=h."recipientKey" AND i."correlationDigest"=h."correlationDigest"))
      OR (h.state<>'purged' AND (h."inactiveAt"<=clock_timestamp()-make_interval(secs=>@seconds) OR (h."inactiveAt" IS NULL
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation i WHERE i."scopeKey"=h."scopeKey"
          AND i."recipientKey"=h."recipientKey" AND i."correlationDigest"=h."correlationDigest" AND i."dismissedAt" IS NULL)
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_response r JOIN serverpod_calendar_invitation i ON i.id=r."entryId"
          WHERE i."scopeKey"=h."scopeKey" AND i."recipientKey"=h."recipientKey" AND i."correlationDigest"=h."correlationDigest")
        AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_link l JOIN serverpod_calendar_event e ON e.id=l."eventId"
          WHERE l."scopeKey"=h."scopeKey" AND l."recipientKey"=h."recipientKey" AND l."correlationDigest"=h."correlationDigest"
          AND e."deletedAt" IS NULL))))
      ORDER BY h."scopeKey",h."recipientKey" LIMIT @limit''',
      parameters: QueryParameters.named({
        'seconds': _invOptions.terminalRetention.inSeconds,
        'limit': _irOptions.batchSize,
      }),
    );
    for (final tuple in due) {
      final scope = tuple[0].toString(), key = tuple[1].toString();
      await _scopeTransaction(scope, (tx, _) async {
        // Identity for owned maintenance only. No actor/address or authority is fabricated.
        final recipient = CalendarInvitationRecipient(
          scopeKey: scope,
          key: key,
          calendarAddress: '',
        );
        await _invCleanup(recipient, tx, await _revisionTime(tx));
      });
    }
  }

  Future<Set<UuidValue>> _rrProtectedSources(
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final rows = await _session.db.unsafeQuery(
      '''SELECT p."sourceId",i."scopeKey",i."recipientKey",i."correlationDigest",h."correlationDigest"
      FROM calendar_inv_response_selection_pin p JOIN calendar_inv_response_selection_evidence e ON e.id=p."evidenceId"
      JOIN calendar_inv_response_selection_head h ON h.id=e."headId"
      JOIN serverpod_calendar_invitation_source s ON s.id=p."sourceId"
      JOIN serverpod_calendar_invitation i ON i.id=s."entryId"
      WHERE h."scopeKey"=@scope AND h."recipientKey"=@recipient LIMIT 16385''',
      parameters: QueryParameters.named({
        'scope': recipient.scopeKey,
        'recipient': recipient.key,
      }),
      transaction: tx,
    );
    if (rows.length > 16384 ||
        rows.any(
          (r) =>
              r[1] != recipient.scopeKey ||
              r[2] != recipient.key ||
              r[3] != r[4],
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return rows.map((r) => UuidValue.fromString(r[0].toString())).toSet();
  }

  Future<void> _rrCleanup(
    CalendarInvitationRecipient recipient,
    Transaction tx,
    DateTime now,
  ) async {
    final heads = await CalendarInvitationResponseSelectionHeadRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key),
      limit: 129,
      transaction: tx,
    );
    if (heads.length > 128) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (heads.isEmpty) {
      return;
    }
    final threshold = now.subtract(_invOptions.terminalRetention);
    final entries = await _invEntries(recipient, tx);
    final responses = (await _irRows(
      recipient.scopeKey,
      tx,
    )).where((r) => r.recipientKey == recipient.key).toList();
    for (final head in heads) {
      final related = entries
          .where((e) => e.correlationDigest == head.correlationDigest)
          .toList();
      final pinned = responses.any(
        (r) => related.any((e) => e.id == r.entryId),
      );
      final link = await CalendarInvitationLinkRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key) &
            t.correlationDigest.equals(head.correlationDigest),
        transaction: tx,
      );
      final event = link == null
          ? null
          : await CalendarEventRecord.db.findById(
              _session,
              link.eventId,
              transaction: tx,
            );
      final activeLink =
          link != null && (event == null || event.deletedAt == null);
      final inactive =
          related.isNotEmpty &&
          related.every((e) => e.dismissedAt != null) &&
          !pinned &&
          !activeLink;
      if (head.state != 'purged') {
        if (inactive) {
          final last = related
              .map((e) => e.dismissedAt!)
              .reduce((a, b) => a.isAfter(b) ? a : b);
          head.inactiveAt ??= last.isBefore(head.updatedAt)
              ? head.updatedAt
              : last;
          if (!head.inactiveAt!.isAfter(threshold)) {
            if (head.currentEvidenceId != null) {
              final proof =
                  await CalendarInvitationResponseSelectionEvidenceRecord.db
                      .findById(
                        _session,
                        head.currentEvidenceId!,
                        transaction: tx,
                      );
              if (proof == null || proof.headId != head.id) {
                throw _failure(CalendarFailureCode.unavailable);
              }
              proof.retiredAt ??= head.inactiveAt;
              await CalendarInvitationResponseSelectionEvidenceRecord.db
                  .updateRow(_session, proof, transaction: tx);
            }
            head.currentEvidenceId = null;
            head.state = 'purged';
            head.purgedAt = now;
          }
        } else {
          head.inactiveAt = null;
        }
        await CalendarInvitationResponseSelectionHeadRecord.db.updateRow(
          _session,
          head,
          transaction: tx,
        );
      }
      if (head.state == 'purged' &&
          head.purgedAt != null &&
          !head.purgedAt!.isAfter(threshold) &&
          !pinned &&
          link == null &&
          related.every((e) => e.dismissedAt != null)) {
        final proofCount =
            await CalendarInvitationResponseSelectionEvidenceRecord.db.count(
              _session,
              where: (t) => t.headId.equals(head.id!),
              transaction: tx,
            );
        final sourceCount = related.isEmpty
            ? 0
            : await CalendarInvitationSourceRecord.db.count(
                _session,
                where: (t) =>
                    t.entryId.inSet(related.map((e) => e.id!).toSet()),
                transaction: tx,
              );
        if (proofCount == 0 && sourceCount == 0) {
          await CalendarInvitationResponseSelectionHeadRecord.db.deleteRow(
            _session,
            head,
            transaction: tx,
          );
        }
      }
    }
    // One structurally verified unreferenced proof per pass guarantees bounded GC.
    // Cleanup does not turn any discarded source into reply eligibility.
    final due = await _session.db.unsafeQuery(
      '''SELECT e.id FROM calendar_inv_response_selection_evidence e
      JOIN calendar_inv_response_selection_head h ON h.id=e."headId"
      WHERE h."scopeKey"=@scope AND h."recipientKey"=@recipient AND e."retiredAt"<=@threshold
      AND (h."currentEvidenceId" IS NULL OR h."currentEvidenceId"<>e.id)
      AND NOT EXISTS(SELECT 1 FROM serverpod_calendar_invitation_response r WHERE r."selectionEvidenceId"=e.id)
      ORDER BY e."retiredAt",e.id LIMIT 1''',
      parameters: QueryParameters.named({
        'scope': recipient.scopeKey,
        'recipient': recipient.key,
        'threshold': threshold,
      }),
      transaction: tx,
    );
    if (due.isNotEmpty) {
      final id = UuidValue.fromString(due.single.single.toString());
      final row = (await CalendarInvitationResponseSelectionEvidenceRecord.db
          .findById(_session, id, transaction: tx))!;
      if (row.byteCount != utf8.encode(row.evidenceJson).length ||
          row.byteCount > 4194304 ||
          row.digest !=
              _invitationHash([
                'recurring-response-evidence-v1',
                row.evidenceJson,
              ])) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final ids = (jsonDecode(row.evidenceJson)['sources'] as List)
          .cast<String>()
          .toSet();
      final pins = await CalendarInvitationResponseSelectionSourcePinRecord.db
          .find(
            _session,
            where: (t) => t.evidenceId.equals(id),
            limit: 66,
            transaction: tx,
          );
      if (ids.length > 65 ||
          pins.length != ids.length ||
          pins.any((p) => !ids.contains(p.sourceId.toString()))) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _rrProtectedSources(recipient, tx);
      await CalendarInvitationResponseSelectionSourcePinRecord.db.delete(
        _session,
        pins,
        transaction: tx,
      );
      await CalendarInvitationResponseSelectionEvidenceRecord.db.deleteRow(
        _session,
        row,
        transaction: tx,
      );
    }
  }

  CalendarRecurringResponseOptions get _rrOptions =>
      _irOptions.recurringOccurrences;
  Future<CalendarInvitationResponseSelectionHeadRecord?> _rrHead(
    CalendarInvitationRecipient recipient,
    String correlation,
    Transaction tx,
  ) async {
    final rows = await CalendarInvitationResponseSelectionHeadRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key) &
          t.correlationDigest.equals(correlation),
      limit: 2,
      transaction: tx,
    );
    if (rows.length > 1) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final h = rows.firstOrNull;
    if (h != null &&
        (h.id == null ||
            h.revision < 1 ||
            h.revision > CalendarService._maxRevision ||
            !{'active', 'unavailable', 'purged'}.contains(h.state))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return h;
  }

  Future<_RecurringSelection> _rrLoad(
    CalendarInvitationRecipient recipient,
    UuidValue evidenceId,
    Transaction tx,
    RecurrenceWorkBudget work,
  ) async {
    try {
      return await _rrLoadUnchecked(recipient, evidenceId, tx, work);
    } on CalendarException catch (e) {
      if (e.code == CalendarFailureCode.accessDenied) {
        rethrow;
      }
      throw _failure(CalendarFailureCode.unavailable);
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<_RecurringSelection> _rrLoadUnchecked(
    CalendarInvitationRecipient recipient,
    UuidValue evidenceId,
    Transaction tx,
    RecurrenceWorkBudget work,
  ) async {
    final row = await CalendarInvitationResponseSelectionEvidenceRecord.db
        .findById(_session, evidenceId, transaction: tx);
    if (row == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final head = await CalendarInvitationResponseSelectionHeadRecord.db
        .findById(_session, row.headId, transaction: tx);
    if (head == null ||
        head.scopeKey != recipient.scopeKey ||
        head.recipientKey != recipient.key) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (row.byteCount != utf8.encode(row.evidenceJson).length ||
        row.byteCount > 4194304 ||
        row.digest !=
            _invitationHash([
              'recurring-response-evidence-v1',
              row.evidenceJson,
            ]) ||
        row.revision < 1 ||
        row.revision > head.revision) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final data = jsonDecode(row.evidenceJson) as Map<String, dynamic>;
    if (data['version'] != 1 ||
        data['recipientAddress'] != recipient.calendarAddress ||
        data['master'] != head.masterEntryId.toString() ||
        jsonEncode(_occOrdered(data)) != row.evidenceJson) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final ids = (data['sources'] as List).cast<String>();
    if (ids.isEmpty || ids.length > 65 || ids.toSet().length != ids.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final entries = {
      for (final e in await _invEntries(recipient, tx))
        if (e.correlationDigest == head.correlationDigest) e.id!: e,
    };
    if (!entries.containsKey(head.masterEntryId)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final sourceRows = await _invSources(entries.values.toList(), tx);
    final sources = {
      for (final r in sourceRows)
        if (ids.contains(r.id.toString())) r.id!: r,
    };
    if (sources.length != ids.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final pins = await CalendarInvitationResponseSelectionSourcePinRecord.db
        .find(
          _session,
          where: (t) => t.evidenceId.equals(evidenceId),
          limit: 66,
          transaction: tx,
        );
    if (pins.length != ids.length ||
        pins
            .map((p) => p.sourceId.toString())
            .toSet()
            .difference(ids.toSet())
            .isNotEmpty) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final packets = <String, IcalendarSchedulingMessage>{};
    var bytes = 0;
    final bindings = (data['bindings'] as List).cast<Map<String, dynamic>>();
    if (bindings.length != ids.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    for (final id in ids) {
      work.charge();
      final source = sources[UuidValue.fromString(id)]!,
          entry = entries[source.entryId]!;
      bytes += source.byteCount;
      if (bytes > 262144) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final b = bindings.where((b) => b['source'] == id).single;
      if (b['entry'] != entry.id.toString() ||
          b['target'] != entry.targetKey ||
          b['digest'] != source.digest) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      packets[id] = _invStored(source, entry, sharedWorkBudget: work);
    }
    if (head.id == null ||
        head.revision < 1 ||
        head.revision > CalendarService._maxRevision ||
        !{'active', 'unavailable', 'purged'}.contains(head.state)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final current = (data['current'] as List).cast<Map<String, dynamic>>();
    if (current.map((v) => v['entry']).toSet().length != current.length ||
        !current.every(
          (v) => bindings.any(
            (b) =>
                b['source'] == v['source'] &&
                b['entry'] == v['entry'] &&
                b['target'] == v['target'],
          ),
        ) ||
        !current.any(
          (v) =>
              v['entry'] == head.masterEntryId.toString() &&
              v['source'] == data['root'],
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    _schedulingValue(
      () => validateRecurringResponseHistory(
        data,
        packets,
        recipient.calendarAddress,
        work,
      ),
    );
    return _RecurringSelection(
      head,
      row,
      data,
      entries,
      sources,
      CalendarRecurringResponseEvidence(
        headId: head.id!,
        evidenceId: row.id!,
        revision: row.revision,
        digest: row.digest,
        snapshotJson: row.evidenceJson,
        packets: packets,
      ),
    );
  }

  bool _rrVectorCurrent(_RecurringSelection s) {
    final current = (s.data['current'] as List).cast<Map<String, dynamic>>();
    final actual = s.entries.values
        .where((e) => e.currentSourceId != null)
        .toList();
    return actual.length == current.length &&
        actual.every(
          (e) => current.any(
            (v) =>
                v['entry'] == e.id.toString() &&
                v['source'] == e.currentSourceId.toString() &&
                v['target'] == e.targetKey,
          ),
        );
  }

  Future<void> _rrMaintainAuthorize(
    CalendarInvitationRecipient recipient,
    _RecurringSelection? before,
    CalendarRecurringResponseEvidence proposed,
    CalendarInvitationRecord master,
    CalendarInvitationRecord opened,
    IcalendarSchedulingMessage incoming,
    Transaction tx,
    CalendarAuthorizationPhase phase,
    RecurrenceWorkBudget work,
  ) async {
    _irGuarantee();
    final context = CalendarInvitationResponsePolicyContext(
      operation:
          CalendarInvitationResponseOperation.maintainRecurringResponseEvidence,
      recipient: recipient,
      invitation: await _invView(master, tx, sharedWorkBudget: work),
      currentState: _irView(master, null).copyWith(canSend: false),
      recurringOpenedInvitation: await _invView(
        opened,
        tx,
        sharedWorkBudget: work,
      ),
      recurringSelection: before?.proof,
      proposedRecurringSelection: proposed,
      sourceMessage: incoming,
    );
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

  Future<void> _rrCapture(
    CalendarInvitationRecipient recipient,
    CalendarInvitationRecord changed,
    CalendarInvitationSourceRecord incoming,
    Transaction tx, {
    required bool enroll,
    required RecurrenceWorkBudget work,
  }) async {
    var head = await _rrHead(recipient, changed.correlationDigest, tx);
    if (head == null &&
        (!enroll || _invitations.responses == null || !_rrOptions.enabled)) {
      return;
    }
    if (_invitations.responses == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (head?.state == 'purged') {
      return;
    }
    final entries = (await _invEntries(
      recipient,
      tx,
    )).where((e) => e.correlationDigest == changed.correlationDigest).toList();
    final master = entries.where((e) => e.targetKey == 'master').single;
    if (!master.recurring || _invBundleKind(master.kind)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final rows = await _invSources(entries, tx),
        sources = {for (final r in rows) r.id!.toString(): r};
    final previous = head?.currentEvidenceId == null
        ? null
        : await _rrLoad(recipient, head!.currentEvidenceId!, tx, work);
    final current = [
      for (final e in entries)
        if (e.currentSourceId != null)
          <String, dynamic>{
            'entry': e.id.toString(),
            'source': e.currentSourceId.toString(),
            'target': e.targetKey,
          },
    ]..sort((a, b) => (a['target'] as String).compareTo(b['target'] as String));
    final root = sources[master.currentSourceId.toString()];
    if (root == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final rootMessage = _invStored(root, master, sharedWorkBudget: work);
    final membership = rootMessage.method == IcalendarSchedulingMethod.request
        ? root.id.toString()
        : previous?.data['membership'] as String?;
    if (membership == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final needed = <String>{
      ...current.map((v) => v['source'] as String),
      membership,
      ...?previous?.proof.packets.keys,
    };
    if (needed.length > 65) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final packets = <String, IcalendarSchedulingMessage>{};
    for (final id in needed) {
      final r = sources[id];
      if (r == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      packets[id] =
          previous?.proof.packets[id] ??
          _invStored(
            r,
            entries.singleWhere((e) => e.id == r.entryId),
            sharedWorkBudget: work,
          );
    }
    final data = _schedulingValue(
      () => buildRecurringResponseHistory(
        previous: previous?.data,
        masterEntryId: master.id.toString(),
        rootSourceId: root.id.toString(),
        membershipSourceId: membership,
        current: current,
        incomingSourceId: incoming.id.toString(),
        packets: packets,
        recipientAddress: recipient.calendarAddress,
        work: work,
        maxHistorySlots: _rrOptions.maxHistorySlots,
      ),
    );
    data['bindings'] = [
      for (final id in (data['sources'] as List).cast<String>())
        {
          'source': id,
          'entry': sources[id]!.entryId.toString(),
          'target': entries
              .singleWhere((e) => e.id == sources[id]!.entryId)
              .targetKey,
          'digest': sources[id]!.digest,
        },
    ];
    final json = jsonEncode(_occOrdered(data)),
        byteCount = utf8.encode(json).length;
    if (previous?.row.evidenceJson == json) {
      return;
    }
    final now = await _revisionTime(tx),
        headId = head?.id ?? const Uuid().v4obj(),
        evidenceId = const Uuid().v4obj();
    final revision = (head?.revision ?? 0) + 1;
    if (revision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final digest = _invitationHash(['recurring-response-evidence-v1', json]);
    final proposed = CalendarRecurringResponseEvidence(
      headId: headId,
      evidenceId: evidenceId,
      revision: revision,
      digest: digest,
      snapshotJson: json,
      packets: {
        for (final id in (data['sources'] as List).cast<String>())
          id: packets[id]!,
      },
    );
    await _rrMaintainAuthorize(
      recipient,
      previous,
      proposed,
      master,
      changed,
      packets[incoming.id.toString()]!,
      tx,
      CalendarAuthorizationPhase.preliminaryWrite,
      work,
    );
    await _rrQuota(
      recipient,
      headId,
      head == null,
      byteCount,
      (data['sources'] as List).length,
      tx,
    );
    head ??= await CalendarInvitationResponseSelectionHeadRecord.db.insertRow(
      _session,
      CalendarInvitationResponseSelectionHeadRecord(
        id: headId,
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        correlationDigest: changed.correlationDigest,
        masterEntryId: master.id!,
        revision: revision,
        state: 'unavailable',
        createdAt: now,
        updatedAt: now,
      ),
      transaction: tx,
    );
    if (previous != null) {
      previous.row.retiredAt ??= now;
      await CalendarInvitationResponseSelectionEvidenceRecord.db.updateRow(
        _session,
        previous.row,
        transaction: tx,
      );
    }
    await CalendarInvitationResponseSelectionEvidenceRecord.db.insertRow(
      _session,
      CalendarInvitationResponseSelectionEvidenceRecord(
        id: evidenceId,
        headId: headId,
        revision: revision,
        evidenceJson: json,
        digest: digest,
        byteCount: byteCount,
        createdAt: now,
      ),
      transaction: tx,
    );
    for (final id in (data['sources'] as List).cast<String>()) {
      await CalendarInvitationResponseSelectionSourcePinRecord.db.insertRow(
        _session,
        CalendarInvitationResponseSelectionSourcePinRecord(
          evidenceId: evidenceId,
          sourceId: UuidValue.fromString(id),
        ),
        transaction: tx,
      );
    }
    head.revision = revision;
    head.currentEvidenceId = evidenceId;
    head.state = data['complete'] == true ? 'active' : 'unavailable';
    head.updatedAt = now;
    head.inactiveAt = null;
    await CalendarInvitationResponseSelectionHeadRecord.db.updateRow(
      _session,
      head,
      transaction: tx,
    );
    await _rrMaintainAuthorize(
      recipient,
      previous,
      proposed,
      master,
      changed,
      packets[incoming.id.toString()]!,
      tx,
      CalendarAuthorizationPhase.finalWrite,
      work,
    );
  }

  Future<void> _rrQuota(
    CalendarInvitationRecipient recipient,
    UuidValue headId,
    bool fresh,
    int bytes,
    int pins,
    Transaction tx,
  ) async {
    final p = QueryParameters.named({
      'scope': recipient.scopeKey,
      'recipient': recipient.key,
      'head': headId.toString(),
    });
    final heads = (await _session.db.unsafeQuery(
      '''SELECT count(*),count(*) FILTER(WHERE "recipientKey"=@recipient)
      FROM calendar_inv_response_selection_head WHERE "scopeKey"=@scope''',
      parameters: QueryParameters.named({
        'scope': recipient.scopeKey,
        'recipient': recipient.key,
      }),
      transaction: tx,
    )).single;
    final values = (await _session.db.unsafeQuery(
      '''SELECT count(*) FILTER(WHERE e."headId"=CAST(@head AS uuid)),
      COALESCE(sum(e."byteCount"),0),COALESCE(sum(e."byteCount") FILTER(WHERE h."recipientKey"=@recipient),0),
      COALESCE(sum(e."byteCount") FILTER(WHERE e."headId"=CAST(@head AS uuid)),0)
      FROM calendar_inv_response_selection_evidence e JOIN calendar_inv_response_selection_head h ON h.id=e."headId"
      WHERE h."scopeKey"=@scope''',
      parameters: p,
      transaction: tx,
    )).single;
    final counts = (await _session.db.unsafeQuery(
      '''SELECT count(*),count(*) FILTER(WHERE h."recipientKey"=@recipient)
      FROM calendar_inv_response_selection_pin p JOIN calendar_inv_response_selection_evidence e ON e.id=p."evidenceId"
      JOIN calendar_inv_response_selection_head h ON h.id=e."headId" WHERE h."scopeKey"=@scope''',
      parameters: QueryParameters.named({
        'scope': recipient.scopeKey,
        'recipient': recipient.key,
      }),
      transaction: tx,
    )).single;
    int value(Object? n) => n is int ? n : int.parse(n.toString());
    final o = _rrOptions;
    if (fresh &&
            (value(heads[0]) >= o.maxHeadsPerScope ||
                value(heads[1]) >= o.maxHeadsPerRecipient) ||
        value(values[0]) >= o.maxVersionsPerHead ||
        value(values[1]) + bytes > o.maxEvidenceBytesPerScope ||
        value(values[2]) + bytes > o.maxEvidenceBytesPerRecipient ||
        value(values[3]) + bytes > o.maxEvidenceBytesPerHead ||
        value(counts[0]) + pins > o.maxPinsPerScope ||
        value(counts[1]) + pins > o.maxPinsPerRecipient) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }
}
