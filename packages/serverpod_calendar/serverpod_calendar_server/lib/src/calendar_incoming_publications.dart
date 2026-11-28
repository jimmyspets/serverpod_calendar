part of 'calendar_module.dart';

extension CalendarIncomingPublicationOperations on CalendarService {
  CalendarIncomingPublicationRuntime get _incoming =>
      _runtime.incomingPublications ??
      (throw _failure(CalendarFailureCode.unavailable));
  CalendarIncomingPublicationOptions get _incomingOptions => _incoming.options;
  void _incomingGuarantee() {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _incoming.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarIncomingPublicationRecipient _incomingRecipient(
    CalendarIncomingPublicationRecipient r,
  ) {
    _opaque(r.scopeKey);
    _opaque(r.key);
    final address = _schedulingAddresses([r.calendarAddress], 1).single;
    return CalendarIncomingPublicationRecipient(
      scopeKey: r.scopeKey,
      key: r.key,
      calendarAddress: address,
    );
  }

  Future<T> _incomingScoped<T>(
    Future<T> Function(
      CalendarHostContext,
      CalendarIncomingPublicationRecipient,
      Transaction,
      CalendarScopeRecord,
    )
    body,
  ) async {
    _incomingGuarantee();
    final actor = await _context();
    final recipient = _incomingRecipient(
      await _bounded(() => _incoming.host.resolveRecipient(_session, actor)),
    );
    if (recipient.scopeKey != actor.scopeKey) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return _transaction(actor, (tx, scope) async {
      final value = await body(actor, recipient, tx, scope);
      await _verifyContext(actor);
      final checked = _incomingRecipient(
        await _bounded(() => _incoming.host.resolveRecipient(_session, actor)),
      );
      if (!recipient.same(checked)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      _incomingGuarantee();
      return value;
    });
  }

  Future<bool> _incomingAuthorize(
    CalendarIncomingPublicationPolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    bool filter = false,
  }) async {
    _incomingGuarantee();
    final answer = await _bounded(
      () => _incoming.host.authorize(_session, context, tx, phase),
    );
    _incomingGuarantee();
    if (answer == CalendarAuthorizationVerdict.unavailable) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (answer == CalendarAuthorizationVerdict.deny && !filter) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return answer == CalendarAuthorizationVerdict.allow;
  }

  IcalendarSchedulingMessage _incomingParse(
    List<int> bytes, {
    bool stored = false,
    RecurrenceWorkBudget? work,
  }) {
    try {
      final limit = stored ? 524288 : _incomingOptions.maxSourceBytes;
      if (bytes.length > limit) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final message = _schedulingValue(
        () => parseIcalendarSchedulingMessage(
          bytes,
          syntaxLimits: IcalendarSyntaxLimits(maxBytes: limit),
          sharedWorkBudget: work,
        ),
      );
      if (!{
            IcalendarSchedulingMethod.publish,
            IcalendarSchedulingMethod.cancel,
          }.contains(message.method) ||
          message.events.length != 1) {
        throw _failure(CalendarFailureCode.validation);
      }
      final e = message.events.single;
      if (e.isOverride ||
          e.isThisAndFuture ||
          e.participants.organizer == null ||
          e.participants.attendees.isNotEmpty ||
          message.method == IcalendarSchedulingMethod.cancel &&
              e.status != IcalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.validation);
      }
      validateEventUid(e.uid);
      if (message.method == IcalendarSchedulingMethod.publish) {
        _schedulingMasterProposal(message, sharedWorkBudget: work);
      }
      return message;
    } catch (_) {
      if (stored) throw _failure(CalendarFailureCode.unavailable);
      rethrow;
    }
  }

  CalendarIncomingPublicationKind _incomingKind(IcalendarSchedulingMessage m) =>
      m.method == IcalendarSchedulingMethod.publish
      ? CalendarIncomingPublicationKind.publication
      : CalendarIncomingPublicationKind.cancellation;
  String _incomingCorrelation(
    CalendarIncomingPublicationRecipient r,
    String uid,
    String organizer,
  ) => _invitationHash([
    'incoming-publication-v1',
    r.scopeKey,
    r.key,
    uid,
    organizer,
  ]);
  int _incomingVersion(
    int? sequence,
    DateTime stamp,
    int? otherSequence,
    DateTime otherStamp,
  ) {
    final order = (sequence ?? 0).compareTo(otherSequence ?? 0);
    return order == 0 ? stamp.compareTo(otherStamp) : order;
  }

  Future<CalendarIncomingPublicationRecord> _incomingEntry(
    UuidValue id,
    CalendarIncomingPublicationRecipient recipient,
    Transaction tx,
  ) async {
    final row = await CalendarIncomingPublicationRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (row == null ||
        row.scopeKey != recipient.scopeKey ||
        row.recipientKey != recipient.key) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (row.correlationDigest !=
            _incomingCorrelation(recipient, row.uid, row.organizer) ||
        row.revision < 1 ||
        row.revision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return row;
  }

  Future<CalendarIncomingPublicationSourceRecord> _incomingSourceRow(
    CalendarIncomingPublicationRecord entry,
    UuidValue id,
    Transaction tx,
  ) async {
    final source = await CalendarIncomingPublicationSourceRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (source == null || source.entryId != entry.id) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (id == entry.currentSourceId &&
        (source.kind != entry.kind ||
            source.sequence != entry.sequence ||
            source.stamp != entry.stamp ||
            source.digest != entry.digest)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return source;
  }

  IcalendarSchedulingMessage _incomingStored(
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationSourceRecord source, {
    RecurrenceWorkBudget? work,
  }) {
    try {
      final text = source.normalizedSource;
      if (text == null ||
          utf8.encode(text).length != source.byteCount ||
          _schedulingDigest(text) != source.digest) {
        throw StateError('Invalid source proof');
      }
      if ((source.kind == CalendarIncomingPublicationKind.publication) !=
          (source.basisSourceId == null)) {
        throw StateError('Invalid source basis shape');
      }
      final message = _incomingParse(
        utf8.encode(text),
        stored: true,
        work: work,
      );
      final e = message.events.single;
      if (source.entryId != entry.id ||
          _incomingKind(message) != source.kind ||
          e.uid != entry.uid ||
          e.participants.organizer!.address != entry.organizer ||
          e.sequence != source.sequence ||
          e.stamp != source.stamp ||
          utf8.decode(serializeIcalendarSchedulingMessage(message)) != text ||
          message.method == IcalendarSchedulingMethod.publish &&
              (message.events.single.recurrence != null) != entry.recurring) {
        throw StateError('Invalid source correspondence');
      }
      return message;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarIncomingPublicationView _incomingView(
    CalendarIncomingPublicationRecord e, {
    IcalendarSchedulingMessage? message,
    DateTime? receivedAt,
  }) {
    final event = message?.events.single;
    return CalendarIncomingPublicationView(
      id: e.id!,
      revision: e.revision,
      uid: e.uid,
      organizer: e.organizer,
      recurring: e.recurring,
      kind: e.kind,
      sourceId: e.currentSourceId,
      sequence: e.sequence,
      stamp: e.stamp,
      summary: event?.summary?.value,
      timing: event == null ? null : _invitationTiming(event),
      status: event?.status == null
          ? null
          : CalendarEventStatus.values.byName(event!.status!.name),
      receivedAt: receivedAt ?? e.createdAt,
      dismissedAt: e.dismissedAt,
    );
  }

  Future<CalendarIncomingPublicationLinkRecord?> _incomingFindLink(
    CalendarIncomingPublicationRecord e,
    Transaction tx,
  ) async {
    final row = await CalendarIncomingPublicationLinkRecord.db.findFirstRow(
      _session,
      where: (t) =>
          t.scopeKey.equals(e.scopeKey) &
          t.recipientKey.equals(e.recipientKey) &
          t.correlationDigest.equals(e.correlationDigest),
      transaction: tx,
    );
    if (row != null && row.entryId != e.id) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return row;
  }

  Future<void> _incomingPruneEntry(
    CalendarIncomingPublicationRecord entry,
    Transaction tx,
    DateTime now, {
    bool removeExpiredEntry = false,
  }) async {
    await _session.db.unsafeExecute(
      'DELETE FROM serverpod_calendar_incoming_publication_receipt WHERE "entryId"=@id AND "expiresAt"<=@now',
      parameters: QueryParameters.named({
        'id': entry.id.toString(),
        'now': now,
      }),
      transaction: tx,
    );
    await _session.db.unsafeExecute(
      'DELETE FROM serverpod_calendar_incoming_publication_source s WHERE s."entryId"=@id AND s."inactiveAt"<=@cutoff '
      'AND s.id<>@current AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_receipt r WHERE r."sourceId"=s.id) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_source b WHERE b."basisSourceId"=s.id) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_link l WHERE l."creationSourceId"=s.id OR l."acceptedSourceId"=s.id OR l."basisSourceId"=s.id)',
      parameters: QueryParameters.named({
        'id': entry.id.toString(),
        'current': entry.currentSourceId.toString(),
        'cutoff': now.subtract(_incomingOptions.retention),
      }),
      transaction: tx,
    );
    if (removeExpiredEntry &&
        entry.dismissedAt != null &&
        !entry.dismissedAt!.isAfter(now.subtract(_incomingOptions.retention))) {
      final link = await CalendarIncomingPublicationLinkRecord.db.findFirstRow(
        _session,
        where: (t) => t.entryId.equals(entry.id!),
        transaction: tx,
      );
      final receipts = await CalendarIncomingPublicationReceiptRecord.db.count(
        _session,
        where: (t) => t.entryId.equals(entry.id!),
        limit: 1,
        transaction: tx,
      );
      if (link == null && receipts == 0) {
        await CalendarIncomingPublicationSourceRecord.db.deleteWhere(
          _session,
          where: (t) => t.entryId.equals(entry.id!),
          transaction: tx,
        );
        await CalendarIncomingPublicationRecord.db.deleteRow(
          _session,
          entry,
          transaction: tx,
        );
      }
    }
  }

  Future<void> _incomingCapacity(
    CalendarIncomingPublicationRecipient r,
    Transaction tx, {
    CalendarIncomingPublicationRecord? entry,
  }) async {
    final o = _incomingOptions;
    final own = await CalendarIncomingPublicationRecord.db.count(
      _session,
      where: (t) =>
          t.scopeKey.equals(r.scopeKey) & t.recipientKey.equals(r.key),
      transaction: tx,
      limit: o.maxEntriesPerRecipient + 1,
    );
    final scope = await CalendarIncomingPublicationRecord.db.count(
      _session,
      where: (t) => t.scopeKey.equals(r.scopeKey),
      transaction: tx,
      limit: o.maxEntriesPerScope + 1,
    );
    if (own > o.maxEntriesPerRecipient || scope > o.maxEntriesPerScope) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    if (entry != null &&
        (await CalendarIncomingPublicationSourceRecord.db.count(
                  _session,
                  where: (t) => t.entryId.equals(entry.id!),
                  transaction: tx,
                  limit: o.maxSourcesPerEntry + 1,
                ) >
                o.maxSourcesPerEntry ||
            await CalendarIncomingPublicationReceiptRecord.db.count(
                  _session,
                  where: (t) => t.entryId.equals(entry.id!),
                  transaction: tx,
                  limit: o.maxReceiptsPerEntry + 1,
                ) >
                o.maxReceiptsPerEntry)) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    for (final recipient in [true, false]) {
      final predicate = recipient ? ' AND e."recipientKey"=@recipient' : '';
      final rows = await _session.db.unsafeQuery(
        'SELECT '
        '(SELECT COALESCE(sum(octet_length(s."normalizedSource")),0) FROM serverpod_calendar_incoming_publication_source s JOIN serverpod_calendar_incoming_publication e ON e.id=s."entryId" WHERE e."scopeKey"=@scope$predicate) + '
        '(SELECT COALESCE(sum(octet_length(l."creationReceipt") + COALESCE(octet_length(l."lastReceipt"),0) + COALESCE(octet_length(d."importBaseline"::text),0)),0) '
        'FROM serverpod_calendar_incoming_publication_link l JOIN serverpod_calendar_incoming_publication e ON e.id=l."entryId" LEFT JOIN serverpod_calendar_event_data d ON d."eventId"=l."eventId" '
        'WHERE e."scopeKey"=@scope$predicate)',
        parameters: QueryParameters.named({
          'scope': r.scopeKey,
          if (recipient) 'recipient': r.key,
        }),
        transaction: tx,
      );
      final size = rows.single.single as int;
      if (size > (recipient ? o.maxRecipientBytes : o.maxScopeBytes)) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
    }
  }

  Future<CalendarIncomingPublicationIngressReceipt> _incomingReceive(
    CalendarIncomingPublicationDelivery delivery,
  ) async {
    for (final s in [
      delivery.namespace,
      delivery.deliveryKey,
      delivery.originReference,
    ]) {
      _opaque(s);
    }
    _incomingGuarantee();
    final message = _incomingParse(
      delivery.bytes,
      work: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
    );
    final text = _schedulingValue(
      () => utf8.decode(serializeIcalendarSchedulingMessage(message)),
    );
    if (utf8.encode(text).length > _incomingOptions.maxSourceBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final event = message.events.single, digest = _schedulingDigest(text);
    final recipient = _incomingRecipient(
      await _bounded(
        () => _incoming.host.resolveDelivery(_session, delivery, message),
      ),
    );
    final correlation = _incomingCorrelation(
      recipient,
      event.uid,
      event.participants.organizer!.address,
    );
    final ingress = _invitationHash([
      'incoming-publication-ingress-v1',
      delivery.namespace,
      delivery.deliveryKey,
    ]);
    final origin = _invitationHash([delivery.originReference]);
    return _scopeTransaction(recipient.scopeKey, (tx, _) async {
      final previous = await CalendarIncomingPublicationReceiptRecord.db
          .findFirstRow(
            _session,
            where: (t) =>
                t.scopeKey.equals(recipient.scopeKey) &
                t.recipientKey.equals(recipient.key) &
                t.ingressDigest.equals(ingress),
            transaction: tx,
          );
      var entry = await CalendarIncomingPublicationRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key) &
            t.correlationDigest.equals(correlation),
        transaction: tx,
      );
      final now = await _revisionTime(tx);
      if (entry != null) entry = await _incomingEntry(entry.id!, recipient, tx);
      final kind = _incomingKind(message);
      final operation = kind == CalendarIncomingPublicationKind.publication
          ? CalendarIncomingPublicationOperation.receive
          : CalendarIncomingPublicationOperation.receiveCancellation;
      final link = entry == null ? null : await _incomingFindLink(entry, tx);
      final acceptedBasis = link != null && link.deletedAt == null
          ? await _incomingBasis(entry!, link, tx)
          : null;
      CalendarIncomingPublicationSourceRecord? reused;
      CalendarIncomingPublicationSourceRecord? cancellationBasis;
      IcalendarSchedulingMessage? sourceBasis;
      if (previous != null) {
        if (previous.originDigest != origin ||
            entry == null ||
            previous.entryId != entry.id) {
          throw _failure(CalendarFailureCode.validation);
        }
        reused = await _incomingSourceRow(entry, previous.sourceId, tx);
        if (reused.digest != digest) {
          throw _failure(CalendarFailureCode.validation);
        }
        _incomingStored(entry, reused);
        sourceBasis = await _incomingSourceBasis(entry, reused, tx);
      }
      CalendarIncomingPublicationPolicyContext context() =>
          CalendarIncomingPublicationPolicyContext(
            operation: operation,
            recipient: recipient,
            delivery: delivery,
            entry: entry == null ? null : _incomingView(entry),
            source: message,
            sourceBasis: sourceBasis,
            acceptedBasis: acceptedBasis,
            sourceId: reused?.id,
            sourceDigest: digest,
            isRetry: previous != null,
          );
      await _incomingAuthorize(
        context(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (previous == null) {
        if (entry == null &&
            kind == CalendarIncomingPublicationKind.cancellation) {
          throw _failure(CalendarFailureCode.validation);
        }
        if (entry != null) {
          final current = await _incomingSourceRow(
            entry,
            entry.currentSourceId,
            tx,
          );
          _incomingStored(entry, current);
          if (kind == CalendarIncomingPublicationKind.publication &&
              _schedulingRecurring(
                    _schedulingMasterProposal(message).content,
                  ) !=
                  entry.recurring) {
            throw _failure(CalendarFailureCode.validation);
          }
          if (kind == CalendarIncomingPublicationKind.cancellation) {
            final prior = await CalendarIncomingPublicationSourceRecord.db
                .findFirstRow(
                  _session,
                  where: (t) =>
                      t.entryId.equals(entry!.id!) & t.digest.equals(digest),
                  transaction: tx,
                );
            if (prior != null) {
              sourceBasis = await _incomingSourceBasis(entry, prior, tx);
              cancellationBasis = await _incomingSourceRow(
                entry,
                prior.basisSourceId!,
                tx,
              );
            } else {
              cancellationBasis = await _incomingChooseCancellationBasis(
                entry,
                message,
                tx,
              );
              sourceBasis = _incomingStored(entry, cancellationBasis);
            }
          }
          await _incomingPruneEntry(entry, tx, now);
        }
      }
      final checked = _incomingRecipient(
        await _bounded(
          () => _incoming.host.resolveDelivery(_session, delivery, message),
        ),
      );
      if (!recipient.same(checked)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (previous != null) {
        await _incomingAuthorize(
          context(),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
        return CalendarIncomingPublicationIngressReceipt(
          id: previous.id!,
          entryId: previous.entryId,
          sourceId: previous.sourceId,
          outcome: previous.outcome,
          entryRevision: previous.entryRevision,
          receivedAt: previous.receivedAt,
        );
      }
      var outcome = CalendarIncomingPublicationOutcome.selected;
      if (entry != null) {
        final order = _incomingVersion(
          event.sequence,
          event.stamp,
          entry.sequence,
          entry.stamp,
        );
        outcome = digest == entry.digest
            ? CalendarIncomingPublicationOutcome.duplicate
            : order < 0
            ? CalendarIncomingPublicationOutcome.stale
            : order == 0
            ? CalendarIncomingPublicationOutcome.conflict
            : CalendarIncomingPublicationOutcome.selected;
        if (link?.acceptedSourceId != null) {
          final accepted = await _incomingSourceRow(
            entry,
            link!.acceptedSourceId!,
            tx,
          );
          final floor = _incomingVersion(
            event.sequence,
            event.stamp,
            accepted.sequence,
            accepted.stamp,
          );
          if (floor < 0) outcome = CalendarIncomingPublicationOutcome.stale;
          if (floor == 0 && digest != accepted.digest) {
            outcome = CalendarIncomingPublicationOutcome.conflict;
          }
        }
      }
      final sourceId = const Uuid().v4obj();
      entry ??= await CalendarIncomingPublicationRecord.db.insertRow(
        _session,
        CalendarIncomingPublicationRecord(
          scopeKey: recipient.scopeKey,
          recipientKey: recipient.key,
          correlationDigest: correlation,
          uid: event.uid,
          organizer: event.participants.organizer!.address,
          recurring: _schedulingRecurring(
            _schedulingMasterProposal(message).content,
          ),
          revision: 1,
          currentSourceId: sourceId,
          kind: kind,
          sequence: event.sequence,
          stamp: event.stamp,
          digest: digest,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      reused = await CalendarIncomingPublicationSourceRecord.db.findFirstRow(
        _session,
        where: (t) => t.entryId.equals(entry!.id!) & t.digest.equals(digest),
        transaction: tx,
      );
      if (reused != null && reused.normalizedSource == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final source =
          reused ??
          await CalendarIncomingPublicationSourceRecord.db.insertRow(
            _session,
            CalendarIncomingPublicationSourceRecord(
              id: sourceId,
              entryId: entry.id!,
              normalizedSource: text,
              byteCount: utf8.encode(text).length,
              digest: digest,
              kind: kind,
              basisSourceId: cancellationBasis?.id,
              sequence: event.sequence,
              stamp: event.stamp,
              outcome: outcome,
              receivedAt: now,
              inactiveAt: outcome == CalendarIncomingPublicationOutcome.selected
                  ? null
                  : now,
            ),
            transaction: tx,
          );
      reused = source;
      if (source.kind == CalendarIncomingPublicationKind.cancellation) {
        sourceBasis = await _incomingSourceBasis(entry, source, tx);
      }
      if (outcome == CalendarIncomingPublicationOutcome.selected &&
          entry.currentSourceId != source.id) {
        final old = await _incomingSourceRow(
          entry,
          entry.currentSourceId,
          tx,
        );
        old.inactiveAt = now;
        await CalendarIncomingPublicationSourceRecord.db.updateRow(
          _session,
          old,
          transaction: tx,
        );
        entry.revision++;
      }
      if (outcome == CalendarIncomingPublicationOutcome.selected) {
        if (entry.revision > CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final selected = entry;
        selected.currentSourceId = source.id!;
        selected.kind = kind;
        selected.sequence = event.sequence;
        selected.stamp = event.stamp;
        selected.digest = digest;
        selected.updatedAt = now;
        selected.dismissedAt = null;
        await CalendarIncomingPublicationRecord.db.updateRow(
          _session,
          entry,
          transaction: tx,
        );
      }
      final receipt = await CalendarIncomingPublicationReceiptRecord.db
          .insertRow(
            _session,
            CalendarIncomingPublicationReceiptRecord(
              scopeKey: recipient.scopeKey,
              recipientKey: recipient.key,
              ingressDigest: ingress,
              originDigest: origin,
              sourceId: source.id!,
              entryId: entry.id!,
              outcome: outcome,
              entryRevision: entry.revision,
              receivedAt: now,
              expiresAt: now.add(_incomingOptions.retention),
            ),
            transaction: tx,
          );
      await _incomingCapacity(recipient, tx, entry: entry);
      await _incomingAuthorize(
        context(),
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      return CalendarIncomingPublicationIngressReceipt(
        id: receipt.id!,
        entryId: entry.id!,
        sourceId: source.id!,
        outcome: outcome,
        entryRevision: entry.revision,
        receivedAt: now,
      );
    });
  }

  Future<IcalendarSchedulingMessage?> _incomingSourceBasis(
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationSourceRecord source,
    Transaction tx,
  ) async {
    if (source.kind == CalendarIncomingPublicationKind.publication) {
      if (source.basisSourceId != null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      return null;
    }
    if (source.basisSourceId == null || source.basisSourceId == source.id) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final row = await _incomingSourceRow(entry, source.basisSourceId!, tx);
    if (row.kind != CalendarIncomingPublicationKind.publication ||
        row.basisSourceId != null ||
        _incomingVersion(
              source.sequence,
              source.stamp,
              row.sequence,
              row.stamp,
            ) <=
            0) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final basis = _incomingStored(entry, row);
    try {
      _incomingCheckCancellation(_incomingStored(entry, source), basis);
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return basis;
  }

  Future<CalendarIncomingPublicationSourceRecord>
  _incomingChooseCancellationBasis(
    CalendarIncomingPublicationRecord entry,
    IcalendarSchedulingMessage message,
    Transaction tx,
  ) async {
    final rows = await CalendarIncomingPublicationSourceRecord.db.find(
      _session,
      where: (t) =>
          t.entryId.equals(entry.id!) &
          t.kind.equals(CalendarIncomingPublicationKind.publication),
      limit: _incomingOptions.maxSourcesPerEntry + 1,
      transaction: tx,
    );
    if (rows.length > _incomingOptions.maxSourcesPerEntry) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    rows.sort(
      (a, b) => _incomingVersion(b.sequence, b.stamp, a.sequence, a.stamp),
    );
    final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
    for (final row in rows) {
      work.charge();
      if (row.normalizedSource == null ||
          row.outcome != CalendarIncomingPublicationOutcome.selected ||
          _incomingVersion(
                message.events.single.sequence,
                message.events.single.stamp,
                row.sequence,
                row.stamp,
              ) <=
              0) {
        continue;
      }
      final basis = _incomingStored(entry, row, work: work);
      try {
        _incomingCheckCancellation(message, basis, work: work);
        return row;
      } on CalendarException catch (e) {
        if (e.code != CalendarFailureCode.validation) rethrow;
      }
    }
    throw _failure(CalendarFailureCode.validation);
  }

  Future<IcalendarSchedulingMessage> _incomingBasis(
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationLinkRecord? link,
    Transaction tx,
  ) async {
    if (link?.basisSourceId != null) {
      return _incomingStored(
        entry,
        await _incomingSourceRow(entry, link!.basisSourceId!, tx),
      );
    }
    final rows = await CalendarIncomingPublicationSourceRecord.db.find(
      _session,
      where: (t) =>
          t.entryId.equals(entry.id!) &
          t.kind.equals(CalendarIncomingPublicationKind.publication),
      orderBy: (t) => t.receivedAt,
      limit: _incomingOptions.maxSourcesPerEntry + 1,
      transaction: tx,
    );
    if (rows.length > _incomingOptions.maxSourcesPerEntry) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    rows.sort(
      (a, b) => _incomingVersion(b.sequence, b.stamp, a.sequence, a.stamp),
    );
    for (final row in rows) {
      if (row.normalizedSource != null &&
          row.outcome == CalendarIncomingPublicationOutcome.selected) {
        return _incomingStored(entry, row);
      }
    }
    throw _failure(CalendarFailureCode.unavailable);
  }

  void _incomingCheckCancellation(
    IcalendarSchedulingMessage cancellation,
    IcalendarSchedulingMessage basis, {
    RecurrenceWorkBudget? work,
  }) {
    _schedulingValue(() {
      final source = cancellation.events.single, original = basis.events.single;
      if (cancellation.method != IcalendarSchedulingMethod.cancel ||
          basis.method != IcalendarSchedulingMethod.publish ||
          source.uid != original.uid ||
          source.participants.organizer!.address !=
              original.participants.organizer!.address) {
        throw _failure(CalendarFailureCode.validation);
      }
      const version = {
        'DTSTAMP',
        'SEQUENCE',
        'CREATED',
        'LAST-MODIFIED',
        'STATUS',
        'COMMENT',
      };
      final supplied = source.source.entries
          .whereType<IcalendarSyntaxProperty>()
          .where((p) => !version.contains(p.canonicalName))
          .toList();
      final names = supplied.map((p) => p.canonicalName).toSet();
      final merged = IcalendarSyntaxComponent(original.source.name, [
        ...original.source.entries.where(
          (e) =>
              e is! IcalendarSyntaxProperty || !names.contains(e.canonicalName),
        ),
        ...supplied,
      ]);
      final envelope = basis.source.components.single;
      final document = IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(envelope.name, [
          for (final e in envelope.entries)
            if (e is IcalendarSyntaxComponent && e.canonicalName == 'VEVENT')
              merged
            else if (e is! IcalendarSyntaxProperty ||
                e.canonicalName != 'METHOD')
              e,
        ]),
      ]);
      final parsed = validateIcalendarEventCalendar(
        document,
        sharedWorkBudget: work,
      );
      final candidate = eventStorageProposal(parsed.series.single);
      final expected = _schedulingMasterProposal(basis);
      if (jsonEncode(candidate.importBaseline.toJson()) !=
          jsonEncode(expected.importBaseline.toJson())) {
        throw _failure(CalendarFailureCode.validation);
      }
    });
  }

  Future<int> _incomingMaintenance() async {
    _incomingGuarantee();
    final now =
        (await _session.db.unsafeQuery('SELECT clock_timestamp()'))
                .single
                .single
            as DateTime;
    final rows = await _session.db.unsafeQuery(
      'SELECT DISTINCT e."scopeKey" FROM serverpod_calendar_incoming_publication e WHERE EXISTS '
      '(SELECT 1 FROM serverpod_calendar_incoming_publication_receipt r WHERE r."entryId"=e.id AND r."expiresAt"<=@now) OR EXISTS '
      '(SELECT 1 FROM serverpod_calendar_incoming_publication_source s WHERE s."entryId"=e.id AND s."inactiveAt"<=@cutoff AND s.id<>e."currentSourceId" '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_link l WHERE l."creationSourceId"=s.id OR l."acceptedSourceId"=s.id OR l."basisSourceId"=s.id) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_source b WHERE b."basisSourceId"=s.id) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_receipt r WHERE r."sourceId"=s.id AND r."expiresAt">@now)) '
      'OR (e."dismissedAt"<=@cutoff AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_incoming_publication_link l WHERE l."entryId"=e.id)) LIMIT 100',
      parameters: QueryParameters.named({
        'now': now,
        'cutoff': now.subtract(_incomingOptions.retention),
      }),
    );
    var count = 0;
    for (final row in rows) {
      await _scopeTransaction(row.single as String, (tx, _) async {
        final entries = await CalendarIncomingPublicationRecord.db.find(
          _session,
          where: (t) => t.scopeKey.equals(row.single as String),
          limit: _incomingOptions.maxEntriesPerScope + 1,
          transaction: tx,
        );
        if (entries.length > _incomingOptions.maxEntriesPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        for (final e in entries) {
          await _incomingPruneEntry(e, tx, now, removeExpiredEntry: true);
        }
      });
      count++;
    }
    return count;
  }

  Future<CalendarIncomingPublicationPage> incomingPublicationList(
    CalendarIncomingPublicationQuery query,
  ) => _incomingList(query);
  Future<CalendarIncomingPublicationView> incomingPublicationGet(
    UuidValue id,
  ) => _incomingGet(id);
  Future<CalendarIncomingPublicationSourceView> incomingPublicationSource(
    UuidValue id,
    UuidValue sourceId,
  ) => _incomingGetSource(id, sourceId);
  Future<void> incomingPublicationDismiss(UuidValue id, int expectedRevision) =>
      _incomingDismiss(id, expectedRevision);
  Future<CalendarIncomingPublicationLinkView?> incomingPublicationLink(
    UuidValue id,
  ) => _incomingLinkView(id);
  Future<CalendarIncomingPublicationCommandReceipt> incomingPublicationAdd(
    CalendarIncomingPublicationAddRequest input,
  ) => _incomingAdd(input);
  Future<CalendarIncomingPublicationCommandReceipt> incomingPublicationApply(
    CalendarIncomingPublicationApplyRequest input,
  ) => _incomingApply(input);
}
