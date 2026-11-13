part of 'calendar_module.dart';

extension CalendarIncomingPublicationQueries on CalendarService {
  Future<CalendarIncomingPublicationView> _incomingDisclose(
    CalendarHostContext actor,
    CalendarIncomingPublicationRecipient recipient,
    CalendarIncomingPublicationRecord entry,
    Transaction tx, {
    RecurrenceWorkBudget? work,
  }) async {
    final source = await _incomingSourceRow(entry, entry.currentSourceId, tx);
    final header = _incomingView(entry, receivedAt: source.receivedAt);
    final request = CalendarIncomingPublicationPolicyContext(
      operation: CalendarIncomingPublicationOperation.readHeader,
      recipient: recipient,
      actor: actor,
      entry: header,
      sourceId: source.id,
      sourceDigest: source.digest,
    );
    await _incomingAuthorize(request, tx, CalendarAuthorizationPhase.read);
    final summary = await _incomingAuthorize(
      CalendarIncomingPublicationPolicyContext(
        operation: CalendarIncomingPublicationOperation.readSummary,
        recipient: recipient,
        actor: actor,
        entry: header,
        sourceId: source.id,
        sourceDigest: source.digest,
      ),
      tx,
      CalendarAuthorizationPhase.read,
      filter: true,
    );
    if (!summary || source.normalizedSource == null) return header;
    final message = _incomingStored(entry, source, work: work);
    return _incomingView(
      entry,
      message: message,
      receivedAt: source.receivedAt,
    );
  }

  Future<CalendarIncomingPublicationView> _incomingGet(UuidValue id) =>
      _incomingScoped((actor, r, tx, _) async {
        final entry = await _incomingEntry(id, r, tx);
        return _incomingDisclose(
          actor,
          r,
          entry,
          tx,
          work: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
        );
      });
  Future<CalendarIncomingPublicationSourceView> _incomingGetSource(
    UuidValue id,
    UuidValue sourceId,
  ) => _incomingScoped((actor, r, tx, _) async {
    final entry = await _incomingEntry(id, r, tx);
    final source = await _incomingSourceRow(entry, sourceId, tx);
    final message = _incomingStored(entry, source);
    final sourceBasis = await _incomingSourceBasis(entry, source, tx);
    await _incomingAuthorize(
      CalendarIncomingPublicationPolicyContext(
        operation: CalendarIncomingPublicationOperation.readSource,
        recipient: r,
        actor: actor,
        entry: _incomingView(entry),
        source: message,
        sourceBasis: sourceBasis,
        sourceId: source.id,
        sourceDigest: source.digest,
      ),
      tx,
      CalendarAuthorizationPhase.read,
    );
    return CalendarIncomingPublicationSourceView(
      id: source.id!,
      entryId: entry.id!,
      kind: source.kind,
      basisSourceId: source.basisSourceId,
      sequence: source.sequence,
      stamp: source.stamp,
      digest: source.digest,
      normalizedSource: source.normalizedSource!,
      outcome: source.outcome,
      isCurrent: source.id == entry.currentSourceId,
      receivedAt: source.receivedAt,
    );
  });
  void _incomingRevision(CalendarIncomingPublicationRecord e, int expected) {
    if (expected < 1 || expected > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (expected != e.revision) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
  }

  Future<void> _incomingDismiss(UuidValue id, int expected) =>
      _incomingScoped((actor, r, tx, _) async {
        final e = await _incomingEntry(id, r, tx);
        final source = await _incomingSourceRow(e, e.currentSourceId, tx);
        final message = _incomingStored(e, source);
        final context = CalendarIncomingPublicationPolicyContext(
          operation: CalendarIncomingPublicationOperation.dismiss,
          recipient: r,
          actor: actor,
          entry: _incomingView(e),
          source: message,
          sourceId: source.id,
          sourceDigest: source.digest,
        );
        await _incomingAuthorize(
          context,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        _incomingRevision(e, expected);
        await _incomingAuthorize(
          context,
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
        if (e.dismissedAt != null) return;
        if (e.revision >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        e.dismissedAt = await _revisionTime(tx);
        e.revision++;
        await CalendarIncomingPublicationRecord.db.updateRow(
          _session,
          e,
          transaction: tx,
        );
      });
  Future<CalendarIncomingPublicationPage> _incomingList(
    CalendarIncomingPublicationQuery query,
  ) => _incomingScoped((actor, r, tx, scope) async {
    if (query.pageSize < 1 || query.pageSize > min(100, _options.maxPageSize)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final now = await _revisionTime(tx);
    await _incomingAuthorize(
      CalendarIncomingPublicationPolicyContext(
        operation: CalendarIncomingPublicationOperation.list,
        recipient: r,
        actor: actor,
      ),
      tx,
      CalendarAuthorizationPhase.read,
    );
    final rows = await CalendarIncomingPublicationRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(r.scopeKey) & t.recipientKey.equals(r.key),
      orderBy: (t) => t.id,
      limit: _incomingOptions.maxScannedEntries + 1,
      transaction: tx,
    );
    if (rows.length > _incomingOptions.maxScannedEntries) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final criteria = _invitationHash([
      'publication-inbox-v1',
      '${query.pageSize}',
      '${query.includeDismissed}',
    ]);
    final basis = _invitationHash([
      for (final e in rows) ...[
        e.id.toString(),
        '${e.revision}',
        e.digest,
        e.dismissedAt?.toIso8601String() ?? '',
      ],
    ]);
    UuidValue? after;
    if (query.cursor != null) {
      if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(query.cursor!)) {
        throw _failure(CalendarFailureCode.invalidCursor);
      }
      final saved = await CalendarCursorRecord.db.findFirstRow(
        _session,
        where: (t) => t.token.equals(query.cursor!),
        transaction: tx,
      );
      final state = saved?.incomingPublicationState;
      if (saved == null ||
          state == null ||
          state.recipientKey != r.key ||
          state.criteriaDigest != criteria ||
          state.basisDigest != basis ||
          saved.scopeKey != actor.scopeKey ||
          saved.principalId != actor.principalId ||
          saved.policyRevision != actor.policyRevision ||
          saved.dataRevision != scope.revision ||
          saved.pageSize != query.pageSize ||
          !saved.expiresAt.isAfter(now) ||
          saved.fieldGroups.isNotEmpty ||
          saved.freeBusyExchangeState != null ||
          saved.eventOccurrenceState != null ||
          saved.categoryFilter != null ||
          saved.eventCalendarId != null ||
          saved.eventFieldGroups != null ||
          saved.taskCalendarId != null ||
          saved.taskFieldGroups != null ||
          saved.alarmActivityId != null ||
          saved.alarmActivityKind != null ||
          saved.taskHistoryTaskId != null ||
          saved.taskHistoryOriginalKey != null ||
          saved.taskHistoryAfterRevision != null ||
          !rows.any((e) => e.id == saved.afterId)) {
        throw _failure(CalendarFailureCode.invalidCursor);
      }
      after = saved.afterId;
    }
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    final entries = <CalendarIncomingPublicationView>[];
    var remaining = false, passed = after == null;
    UuidValue? last;
    for (final entry in rows) {
      work.charge();
      if (!passed) {
        if (entry.id == after) passed = true;
        continue;
      }
      if (!query.includeDismissed && entry.dismissedAt != null) continue;
      if (entry.correlationDigest !=
          _incomingCorrelation(r, entry.uid, entry.organizer)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final source = await _incomingSourceRow(entry, entry.currentSourceId, tx);
      final header = _incomingView(entry, receivedAt: source.receivedAt);
      if (!await _incomingAuthorize(
        CalendarIncomingPublicationPolicyContext(
          operation: CalendarIncomingPublicationOperation.readHeader,
          recipient: r,
          actor: actor,
          entry: header,
          sourceId: source.id,
          sourceDigest: source.digest,
        ),
        tx,
        CalendarAuthorizationPhase.read,
        filter: true,
      )) {
        continue;
      }
      if (entries.length == query.pageSize) {
        remaining = true;
        break;
      }
      final summary = await _incomingAuthorize(
        CalendarIncomingPublicationPolicyContext(
          operation: CalendarIncomingPublicationOperation.readSummary,
          recipient: r,
          actor: actor,
          entry: header,
          sourceId: source.id,
          sourceDigest: source.digest,
        ),
        tx,
        CalendarAuthorizationPhase.read,
        filter: true,
      );
      entries.add(
        !summary || source.normalizedSource == null
            ? header
            : _incomingView(
                entry,
                message: _incomingStored(entry, source, work: work),
                receivedAt: source.receivedAt,
              ),
      );
      last = entry.id;
    }
    String? continuation;
    if (remaining) {
      await CalendarCursorRecord.db.deleteWhere(
        _session,
        where: (t) => t.scopeKey.equals(actor.scopeKey) & (t.expiresAt <= now),
        transaction: tx,
      );
      if (await CalendarCursorRecord.db.count(
            _session,
            where: (t) => t.scopeKey.equals(actor.scopeKey),
            transaction: tx,
            limit: _options.maxCursorsPerScope + 1,
          ) >=
          _options.maxCursorsPerScope) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final random = Random.secure();
      continuation = base64UrlEncode(
        List.generate(32, (_) => random.nextInt(256)),
      ).replaceAll('=', '');
      await CalendarCursorRecord.db.insertRow(
        _session,
        CalendarCursorRecord(
          token: continuation,
          scopeKey: actor.scopeKey,
          principalId: actor.principalId,
          policyRevision: actor.policyRevision,
          dataRevision: scope.revision,
          afterId: last!,
          pageSize: query.pageSize,
          fieldGroups: [],
          incomingPublicationState: CalendarIncomingPublicationCursorState(
            recipientKey: r.key,
            criteriaDigest: criteria,
            basisDigest: basis,
          ),
          expiresAt: now.add(_options.cursorLifetime),
        ),
        transaction: tx,
      );
    }
    return CalendarIncomingPublicationPage(
      entries: entries,
      continuation: continuation,
    );
  });
}
