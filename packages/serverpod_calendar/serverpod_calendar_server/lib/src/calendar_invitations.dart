part of 'calendar_module.dart';

String _invitationHash(Iterable<String> parts) {
  final bytes = BytesBuilder(copy: false);
  for (final part in parts) {
    final value = utf8.encode(part);
    bytes.add(utf8.encode('${value.length}:'));
    bytes.add(value);
  }
  return sha256.convert(bytes.takeBytes()).toString();
}

CalendarInvitationSourceKind _invKind(IcalendarSchedulingMessage message) =>
    message.method == IcalendarSchedulingMethod.request
    ? CalendarInvitationSourceKind.request
    : CalendarInvitationSourceKind.meetingCancellation;

CalendarEventTiming? _invitationTiming(IcalendarSchedulingEvent event) {
  if (event.startDate == null && event.startTime == null) return null;
  final time = event.startTime;
  final d = event.duration;
  return CalendarEventTiming(
    kind: event.startDate != null
        ? CalendarEventTimeKind.date
        : time!.zoneId == null
        ? CalendarEventTimeKind.utc
        : CalendarEventTimeKind.zoned,
    start: event.startDate != null
        ? eventDate(event.startDate!)
        : eventCivil(time!.civil),
    zoneId: time?.zoneId,
    end: event.endDate != null
        ? eventDate(event.endDate!)
        : event.endTime == null
        ? null
        : eventCivil(event.endTime!.civil),
    duration: d == null
        ? null
        : CalendarEventDuration(
            weeks: d.weeks,
            days: d.days,
            hours: d.hours,
            minutes: d.minutes,
            seconds: d.seconds,
            microsecond: d.microsecond,
          ),
  );
}

extension CalendarInvitationOperations on CalendarService {
  CalendarInvitationRuntime get _invitations =>
      _runtime.invitations ?? (throw _failure(CalendarFailureCode.unavailable));
  CalendarInvitationOptions get _invOptions => _invitations.options;

  void _invGuarantee() {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _invitations.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarInvitationRecipient _invRecipient(
    CalendarInvitationRecipient recipient,
  ) {
    _opaque(recipient.scopeKey);
    _opaque(recipient.key);
    _schedulingValue(
      () => validateIcalendarMetadataUri(recipient.calendarAddress),
    );
    return recipient;
  }

  Future<bool> _invAuthorize(
    CalendarInvitationPolicyContext request,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    bool filterDenied = false,
  }) async {
    _invGuarantee();
    final verdict = await _bounded(
      () => _invitations.host.authorize(_session, request, tx, phase),
    );
    _invGuarantee();
    if (verdict == CalendarAuthorizationVerdict.unavailable) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (verdict == CalendarAuthorizationVerdict.deny) {
      if (filterDenied) return false;
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (request.operation == CalendarInvitationOperation.receive &&
        request.message?.method == IcalendarSchedulingMethod.cancel) {
      await _invAuthorize(
        request.forOperation(CalendarInvitationOperation.receiveCancellation),
        tx,
        phase,
      );
    }
    return true;
  }

  IcalendarSchedulingMessage _invParse(List<int> bytes, {bool stored = false}) {
    try {
      if (bytes.length > (stored ? 262144 : _invOptions.maxSourceBytes)) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final message = _schedulingValue(
        () => parseIcalendarSchedulingMessage(bytes),
      );
      if (!{
            IcalendarSchedulingMethod.request,
            IcalendarSchedulingMethod.cancel,
          }.contains(message.method) ||
          message.events.length != 1) {
        throw _failure(CalendarFailureCode.validation);
      }
      final event = message.events.single;
      if (message.method == IcalendarSchedulingMethod.cancel &&
              event.status != IcalendarEventStatus.cancelled ||
          event.isOverride ||
          event.recurrence != null ||
          event.source.entries.whereType<IcalendarSyntaxProperty>().any(
            (p) => {
              'RRULE',
              'RDATE',
              'EXDATE',
              'RECURRENCE-ID',
            }.contains(p.canonicalName),
          ) ||
          event.participants.organizer == null ||
          event.participants.organizer!.sentBy != null ||
          event.participants.attendees.any(
            (a) =>
                a.sentBy != null ||
                a.delegatedTo.isNotEmpty ||
                a.delegatedFrom.isNotEmpty ||
                a.participationStatus?.toUpperCase() == 'DELEGATED',
          )) {
        throw _failure(CalendarFailureCode.validation);
      }
      return message;
    } on CalendarException {
      if (stored) throw _failure(CalendarFailureCode.unavailable);
      rethrow;
    }
  }

  IcalendarSchedulingMessage _invStored(
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry,
  ) {
    final bytes = utf8.encode(source.normalizedSource);
    if (source.entryId != entry.id ||
        bytes.length != source.byteCount ||
        sha256.convert(bytes).toString() != source.digest ||
        source.outcome == CalendarInvitationOutcome.duplicate) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final message = _invParse(bytes, stored: true),
        event = message.events.single;
    if ((entry.currentSourceId == source.id &&
            _invKind(message) != entry.kind) ||
        message.uid != entry.uid ||
        event.participants.organizer!.address != entry.organizer ||
        event.sequence != source.sequence ||
        event.stamp != source.stamp ||
        utf8.decode(serializeIcalendarSchedulingMessage(message)) !=
            source.normalizedSource) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return message;
  }

  Future<CalendarInvitationView> _invView(
    CalendarInvitationRecord entry,
    Transaction tx,
  ) async {
    CalendarInvitationSourceRecord? source;
    IcalendarSchedulingEvent? event;
    if (entry.currentSourceId != null) {
      source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        entry.currentSourceId!,
        transaction: tx,
      );
      if (source == null ||
          source.sequence != entry.sequence ||
          source.stamp != entry.stamp ||
          source.digest != entry.digest) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      event = _invStored(source, entry).events.single;
    } else if (entry.dismissedAt == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return CalendarInvitationView(
      kind: entry.kind,
      id: entry.id!,
      revision: entry.revision,
      uid: entry.uid,
      organizer: entry.organizer,
      sequence: entry.sequence,
      stamp: entry.stamp,
      sourceId: source?.id,
      summary: event?.summary?.value,
      timing: event == null ? null : _invitationTiming(event),
      receivedAt: source?.receivedAt,
      dismissedAt: entry.dismissedAt,
    );
  }

  Future<List<CalendarInvitationRecord>> _invEntries(
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final entries = await CalendarInvitationRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key),
      orderBy: (t) => t.id,
      limit: 129,
      transaction: tx,
    );
    if (entries.length > 128 ||
        entries.any(
          (e) =>
              e.id == null ||
              e.revision < 1 ||
              e.revision > CalendarService._maxRevision ||
              e.correlationDigest != _invitationHash([e.uid, e.organizer]),
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return entries;
  }

  Future<List<CalendarInvitationSourceRecord>> _invSources(
    List<CalendarInvitationRecord> entries,
    Transaction tx,
  ) async {
    if (entries.isEmpty) return [];
    final sources = await CalendarInvitationSourceRecord.db.find(
      _session,
      where: (t) => t.entryId.inSet(entries.map((e) => e.id!).toSet()),
      orderBy: (t) => t.id,
      limit: 257,
      transaction: tx,
    );
    if (sources.length > 256 ||
        sources.any(
          (s) =>
              s.byteCount != utf8.encode(s.normalizedSource).length ||
              s.byteCount > 262144 ||
              s.byteCount < 1,
        ) ||
        sources.fold<int>(0, (n, s) => n + s.byteCount) > 16777216) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return sources;
  }

  /// All scans use hard profile bounds. Configured lower caps affect admission.
  Future<void> _invCleanup(
    CalendarInvitationRecipient recipient,
    Transaction tx,
    DateTime now,
  ) async {
    final entries = await _invEntries(recipient, tx);
    final receipts = await CalendarInvitationReceiptRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key),
      limit: 1025,
      transaction: tx,
    );
    if (receipts.length > 1024) throw _failure(CalendarFailureCode.unavailable);
    final expired = receipts.where((r) => !r.expiresAt.isAfter(now)).toList();
    if (expired.isNotEmpty) {
      await CalendarInvitationReceiptRecord.db.delete(
        _session,
        expired,
        transaction: tx,
      );
    }
    // Retained personal responses pin their exact authorization evidence, even
    // when this particular host has not installed its optional response worker.
    final responsePins = await CalendarInvitationResponseRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(recipient.scopeKey) &
          t.recipientKey.equals(recipient.key),
      limit: 513,
      transaction: tx,
    );
    if (responsePins.length > 512) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final protectedSources = receipts
        .where((r) => r.expiresAt.isAfter(now))
        .map((r) => r.sourceId)
        .toSet();
    protectedSources.addAll(responsePins.map((r) => r.sourceId));
    final sources = await _invSources(entries, tx);
    if (responsePins.any(
      (r) =>
          !entries.any((e) => e.id == r.entryId) ||
          !sources.any((v) => v.id == r.sourceId && v.entryId == r.entryId),
    )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final threshold = now.subtract(_invOptions.terminalRetention);
    final removable = <CalendarInvitationSourceRecord>[];
    for (final source in sources) {
      final entry = entries.singleWhere((e) => e.id == source.entryId);
      if (entry.currentSourceId == source.id && entry.dismissedAt == null) {
        if (source.inactiveAt != null) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        continue;
      }
      if (source.inactiveAt == null) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (!protectedSources.contains(source.id) &&
          !source.inactiveAt!.isAfter(threshold)) {
        if (entry.currentSourceId == source.id) {
          entry.currentSourceId = null;
          await CalendarInvitationRecord.db.updateRow(
            _session,
            entry,
            transaction: tx,
          );
        }
        removable.add(source);
      }
    }
    if (removable.isNotEmpty) {
      await CalendarInvitationSourceRecord.db.delete(
        _session,
        removable,
        transaction: tx,
      );
    }
    for (final entry in entries) {
      if (entry.dismissedAt != null &&
          !entry.dismissedAt!.isAfter(threshold) &&
          entry.currentSourceId == null &&
          !sources.any(
            (s) => s.entryId == entry.id && !removable.contains(s),
          )) {
        if (responsePins.any((r) => r.entryId == entry.id)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        await CalendarInvitationResponseStateRecord.db.deleteWhere(
          _session,
          where: (t) =>
              t.entryId.equals(entry.id!) &
              t.scopeKey.equals(recipient.scopeKey) &
              t.recipientKey.equals(recipient.key),
          transaction: tx,
        );
        await CalendarInvitationRecord.db.deleteRow(
          _session,
          entry,
          transaction: tx,
        );
      }
    }
  }

  Future<CalendarInvitationReceipt> _receiveInvitation(
    CalendarInvitationDelivery delivery,
  ) async {
    _opaque(delivery.namespace);
    _opaque(delivery.deliveryKey);
    _opaque(delivery.originReference);
    _invGuarantee();
    final message = _invParse(delivery.bytes), event = message.events.single;
    final normalized = utf8.decode(
      _schedulingValue(() => serializeIcalendarSchedulingMessage(message)),
    );
    final byteCount = utf8.encode(normalized).length;
    if (byteCount > _invOptions.maxSourceBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final digest = sha256.convert(utf8.encode(normalized)).toString();
    final recipient = _invRecipient(
      await _bounded(
        () => _invitations.host.resolveDelivery(_session, delivery, message),
      ),
    );
    if (!event.participants.attendees.any(
      (a) => a.address == recipient.calendarAddress,
    )) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final correlation = _invitationHash([
      message.uid,
      event.participants.organizer!.address,
    ]);
    final ingress = _invitationHash([delivery.namespace, delivery.deliveryKey]);
    final origin = _invitationHash([
      delivery.namespace,
      delivery.originReference,
      recipient.calendarAddress,
    ]);
    return _scopeTransaction(recipient.scopeKey, (tx, _) async {
      CalendarInvitationLinkRecord? linked;
      _Event? linkedEvent;
      CalendarInvitationApplicationState? accepted;
      bool? linkedUnavailable;
      CalendarInvitationPolicyContext context({
        CalendarInvitationView? current,
        CalendarInvitationOutcome? outcome,
        int? revision,
        UuidValue? entryId,
        UuidValue? sourceId,
        UuidValue? receiptId,
        bool retry = false,
        CalendarInvitationReceipt? receipt,
      }) => CalendarInvitationPolicyContext(
        operation: CalendarInvitationOperation.receive,
        recipient: recipient,
        delivery: delivery,
        message: message,
        normalizedSource: normalized,
        sourceDigest: digest,
        current: current,
        proposedOutcome: outcome,
        proposedRevision: revision,
        proposedDismissed:
            outcome == CalendarInvitationOutcome.selected && !retry
            ? false
            : current?.dismissedAt != null,
        entryId: entryId,
        sourceId: sourceId,
        receiptId: receiptId,
        isRetry: retry,
        receipt: receipt,
        link: linked == null ? null : _invLinkReceipt(linked),
        linkSource: linked == null ? null : _invLinkSource(linked),
        calendar: linkedEvent?.parent.snapshot,
        currentEvent: linkedEvent?.snapshot,
        currentApplication: accepted,
        linkedEventUnavailable: linkedUnavailable,
      );
      await _invAuthorize(
        context(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final now = await _revisionTime(tx);
      await _invCleanup(recipient, tx, now);
      final entries = await _invEntries(recipient, tx);
      var entry = entries
          .where((e) => e.correlationDigest == correlation)
          .firstOrNull;
      if (entry != null &&
          (entry.uid != message.uid ||
              entry.organizer != event.participants.organizer!.address)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final current = entry == null ? null : await _invView(entry, tx);
      final cancellation = message.method == IcalendarSchedulingMethod.cancel;
      if (cancellation) {
        final candidate = await CalendarInvitationLinkRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(recipient.scopeKey) &
              t.recipientKey.equals(recipient.key) &
              t.correlationDigest.equals(correlation),
          transaction: tx,
        );
        if (candidate != null) {
          linked = await _invFindLink(
            candidate.invitationId,
            entry,
            recipient,
            tx,
          );
          final bound = linked;
          if (bound == null ||
              bound.uid != message.uid ||
              bound.organizer != event.participants.organizer!.address) {
            throw _failure(CalendarFailureCode.unavailable);
          }
          try {
            linkedEvent = await _invLinkedEventScope(
              bound,
              recipient.scopeKey,
              tx,
            );
            accepted = _invApplicationState(
              bound,
              linkedEvent,
              await _invCheckpoint(bound, linkedEvent, tx),
            );
            linkedUnavailable = false;
          } on CalendarException {
            linkedUnavailable = true;
          }
        }
        await _invAuthorize(
          context(current: current, entryId: entry?.id),
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        if (linkedUnavailable == true) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (entry == null && linked == null) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      }
      final retained = await CalendarInvitationReceiptRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key) &
            t.ingressDigest.equals(ingress),
        transaction: tx,
      );
      if (retained != null) {
        final source = await CalendarInvitationSourceRecord.db.findById(
          _session,
          retained.sourceId,
          transaction: tx,
        );
        if (entry == null ||
            source == null ||
            source.entryId != entry.id ||
            source.digest != digest ||
            source.normalizedSource != normalized ||
            retained.originDigest != origin) {
          throw _failure(CalendarFailureCode.validation);
        }
        _invStored(source, entry);
        final result = CalendarInvitationReceipt(
          id: retained.id!,
          entryId: entry.id!,
          sourceId: source.id!,
          outcome: retained.outcome,
          entryRevision: retained.entryRevision,
          receivedAt: retained.receivedAt,
        );
        final retry = context(
          current: current,
          outcome: retained.outcome,
          revision: entry.revision,
          entryId: entry.id,
          sourceId: source.id,
          receiptId: retained.id,
          retry: true,
          receipt: result,
        );
        await _invAuthorize(
          retry,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        await _invAuthorize(retry, tx, CalendarAuthorizationPhase.finalWrite);
        return result;
      }
      final sources = await _invSources(entries, tx);
      var source = sources
          .where((s) => s.entryId == entry?.id && s.digest == digest)
          .firstOrNull;
      if (source != null) {
        if (source.normalizedSource != normalized) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        _invStored(source, entry!);
      }
      var outcome = source != null || entry?.digest == digest
          ? CalendarInvitationOutcome.duplicate
          : entry == null ||
                (event.sequence ?? 0) > (entry.sequence ?? 0) ||
                (event.sequence ?? 0) == (entry.sequence ?? 0) &&
                    event.stamp.isAfter(entry.stamp)
          ? CalendarInvitationOutcome.selected
          : (event.sequence ?? 0) < (entry.sequence ?? 0) ||
                event.stamp.isBefore(entry.stamp)
          ? CalendarInvitationOutcome.stale
          : CalendarInvitationOutcome.conflict;
      if (cancellation && outcome != CalendarInvitationOutcome.duplicate) {
        // Cancellation must advance every known REQUEST, even after queue expiry.
        final requestSequences = <int>[
          if (entry?.kind == CalendarInvitationSourceKind.request)
            entry!.sequence ?? 0,
          if (accepted?.kind == CalendarInvitationSourceKind.request)
            accepted!.sequence ?? 0,
          for (final historical in sources.where((s) => s.entryId == entry?.id))
            if (_invKind(_invStored(historical, entry!)) ==
                CalendarInvitationSourceKind.request)
              historical.sequence ?? 0,
        ];
        final stale =
            requestSequences.any((v) => event.sequence! <= v) ||
            accepted != null &&
                _invSourceOrder(
                      event.sequence,
                      event.stamp,
                      accepted.sequence,
                      accepted.stamp,
                    ) <=
                    0;
        if (stale) {
          if (entry == null) throw _failure(CalendarFailureCode.staleRevision);
          outcome = CalendarInvitationOutcome.stale;
        }
      }
      if (outcome == CalendarInvitationOutcome.duplicate && source == null) {
        // A digest-only marker cannot prove exact text equality after pruning.
        // Fail closed without reopening or manufacturing a duplicate receipt.
        throw _failure(CalendarFailureCode.unavailable);
      }
      final selected = outcome == CalendarInvitationOutcome.selected;
      final freshEntry = entry == null;
      final revision = freshEntry ? 1 : entry.revision + (selected ? 1 : 0);
      if (revision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (freshEntry || selected && entry.dismissedAt != null) {
        if (entries.where((e) => e.dismissedAt == null).length >=
            _invOptions.maxPending) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
      }
      final receipts = await CalendarInvitationReceiptRecord.db.count(
        _session,
        where: (t) =>
            t.scopeKey.equals(recipient.scopeKey) &
            t.recipientKey.equals(recipient.key),
        transaction: tx,
      );
      if (receipts >= _invOptions.maxReceipts) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (source == null &&
          (sources.length >= _invOptions.maxSources ||
              sources.fold<int>(0, (n, s) => n + s.byteCount) + byteCount >
                  _invOptions.maxRetainedBytes ||
              sources.where((s) => s.entryId == entry?.id).length >=
                  _invOptions.maxSourcesPerEntry)) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final entryId = entry?.id ?? const Uuid().v4obj(),
          sourceId = source?.id ?? const Uuid().v4obj(),
          receiptId = const Uuid().v4obj();
      final proposedReceipt = CalendarInvitationReceipt(
        id: receiptId,
        entryId: entryId,
        sourceId: sourceId,
        outcome: outcome,
        entryRevision: revision,
        receivedAt: now,
      );
      final request = context(
        current: current,
        outcome: outcome,
        revision: revision,
        entryId: entryId,
        sourceId: sourceId,
        receiptId: receiptId,
        receipt: proposedReceipt,
      );
      await _invAuthorize(
        request,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (freshEntry) {
        entry = await CalendarInvitationRecord.db.insertRow(
          _session,
          CalendarInvitationRecord(
            id: entryId,
            scopeKey: recipient.scopeKey,
            recipientKey: recipient.key,
            correlationDigest: correlation,
            kind: _invKind(message),
            uid: message.uid,
            organizer: event.participants.organizer!.address,
            revision: 1,
            sequence: event.sequence,
            stamp: event.stamp,
            digest: digest,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
      }
      source ??= await CalendarInvitationSourceRecord.db.insertRow(
        _session,
        CalendarInvitationSourceRecord(
          id: sourceId,
          entryId: entryId,
          normalizedSource: normalized,
          byteCount: byteCount,
          digest: digest,
          sequence: event.sequence,
          stamp: event.stamp,
          outcome: outcome == CalendarInvitationOutcome.duplicate
              ? CalendarInvitationOutcome.selected
              : outcome,
          receivedAt: now,
          inactiveAt: selected ? null : now,
        ),
        transaction: tx,
      );
      if (selected) {
        if (!freshEntry && entry.currentSourceId != null) {
          final old = sources.singleWhere(
            (s) => s.id == entry!.currentSourceId,
          );
          old.inactiveAt ??= now;
          await CalendarInvitationSourceRecord.db.updateRow(
            _session,
            old,
            transaction: tx,
          );
        }
        entry.revision = revision;
        entry.kind = _invKind(message);
        entry.currentSourceId = source.id;
        entry.sequence = event.sequence;
        entry.stamp = event.stamp;
        entry.digest = digest;
        entry.dismissedAt = null;
        entry.updatedAt = now.isBefore(entry.updatedAt) ? entry.updatedAt : now;
        await CalendarInvitationRecord.db.updateRow(
          _session,
          entry,
          transaction: tx,
        );
      }
      final receipt = await CalendarInvitationReceiptRecord.db.insertRow(
        _session,
        CalendarInvitationReceiptRecord(
          id: receiptId,
          scopeKey: recipient.scopeKey,
          recipientKey: recipient.key,
          ingressDigest: ingress,
          sourceId: source.id!,
          originDigest: origin,
          outcome: outcome,
          entryRevision: revision,
          receivedAt: now,
          expiresAt: now.add(_invOptions.terminalRetention),
        ),
        transaction: tx,
      );
      await _invAuthorize(request, tx, CalendarAuthorizationPhase.finalWrite);
      return CalendarInvitationReceipt(
        id: receipt.id!,
        entryId: entryId,
        sourceId: source.id!,
        outcome: outcome,
        entryRevision: revision,
        receivedAt: now,
      );
    });
  }

  Future<T> _invNative<T>(
    Future<T> Function(
      CalendarHostContext,
      CalendarInvitationRecipient,
      Transaction,
    )
    body,
  ) async {
    return _invNativeScoped(
      (actor, recipient, tx, _) => body(actor, recipient, tx),
    );
  }

  Future<T> _invNativeScoped<T>(
    Future<T> Function(
      CalendarHostContext,
      CalendarInvitationRecipient,
      Transaction,
      CalendarScopeRecord,
    )
    body,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, scope) async {
      _invGuarantee();
      final recipient = _invRecipient(
        await _bounded(
          () => _invitations.host.resolveCurrent(_session, actor, tx),
        ),
      );
      if (recipient.scopeKey != actor.scopeKey) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final result = await body(actor, recipient, tx, scope);
      final finalRecipient = _invRecipient(
        await _bounded(
          () => _invitations.host.resolveCurrent(_session, actor, tx),
        ),
      );
      if (!recipient.same(finalRecipient)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _verifyContext(actor);
      _invGuarantee();
      return result;
    });
  }

  Future<CalendarInvitationRecord> _invEntry(
    UuidValue id,
    CalendarInvitationRecipient recipient,
    Transaction tx,
  ) async {
    final entry = await CalendarInvitationRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (entry == null ||
        entry.scopeKey != recipient.scopeKey ||
        entry.recipientKey != recipient.key) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (entry.correlationDigest !=
            _invitationHash([entry.uid, entry.organizer]) ||
        entry.revision < 1 ||
        entry.revision > CalendarService._maxRevision) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return entry;
  }

  Future<List<CalendarInvitationView>> listInvitations() => _invNative((
    actor,
    recipient,
    tx,
  ) async {
    final request = CalendarInvitationPolicyContext(
      operation: CalendarInvitationOperation.list,
      recipient: recipient,
      actor: actor,
    );
    await _invAuthorize(request, tx, CalendarAuthorizationPhase.read);
    await _invCleanup(recipient, tx, await _revisionTime(tx));
    final entries = (await _invEntries(
      recipient,
      tx,
    )).where((e) => e.dismissedAt == null).toList();
    if (entries.length > 64) throw _failure(CalendarFailureCode.unavailable);
    final views = <CalendarInvitationView>[];
    for (final entry in entries) {
      final view = await _invView(entry, tx);
      if (await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: CalendarInvitationOperation.readSummary,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: entry.id,
        ),
        tx,
        CalendarAuthorizationPhase.read,
        filterDenied: true,
      )) {
        views.add(view);
      }
    }
    await _invAuthorize(request, tx, CalendarAuthorizationPhase.read);
    return List<CalendarInvitationView>.unmodifiable(views);
  });
  Future<CalendarInvitationView> getInvitation(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invEntry(id, recipient, tx),
            view = await _invView(entry, tx);
        await _invAuthorize(
          CalendarInvitationPolicyContext(
            operation: CalendarInvitationOperation.readSummary,
            actor: actor,
            recipient: recipient,
            current: view,
            entryId: id,
          ),
          tx,
          CalendarAuthorizationPhase.read,
        );
        return view;
      });
  Future<List<CalendarInvitationSourceView>> invitationSources(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invEntry(id, recipient, tx),
            view = await _invView(entry, tx);
        for (final operation in [
          CalendarInvitationOperation.readSummary,
          CalendarInvitationOperation.readSource,
        ]) {
          await _invAuthorize(
            CalendarInvitationPolicyContext(
              operation: operation,
              actor: actor,
              recipient: recipient,
              current: view,
              entryId: id,
            ),
            tx,
            CalendarAuthorizationPhase.read,
          );
        }
        final sources = await _invSources([entry], tx);
        if (sources.length > 16) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final result = <CalendarInvitationSourceView>[];
        for (final source in sources) {
          final message = _invStored(source, entry);
          await _invAuthorize(
            CalendarInvitationPolicyContext(
              operation: CalendarInvitationOperation.readSource,
              actor: actor,
              recipient: recipient,
              current: view,
              entryId: id,
              sourceId: source.id,
              message: message,
              normalizedSource: source.normalizedSource,
              sourceDigest: source.digest,
            ),
            tx,
            CalendarAuthorizationPhase.read,
          );
          result.add(
            CalendarInvitationSourceView(
              kind: _invKind(message),
              id: source.id!,
              entryId: id,
              sequence: source.sequence,
              stamp: source.stamp,
              outcome: source.outcome,
              isCurrent: entry.currentSourceId == source.id,
              receivedAt: source.receivedAt,
              inactiveAt: source.inactiveAt,
            ),
          );
        }
        return List<CalendarInvitationSourceView>.unmodifiable(result);
      });
  Future<CalendarInvitationDocument> invitationSource(
    UuidValue id,
    UuidValue sourceId,
  ) => _invNative((actor, recipient, tx) async {
    final entry = await _invEntry(id, recipient, tx),
        view = await _invView(entry, tx);
    await _invAuthorize(
      CalendarInvitationPolicyContext(
        operation: CalendarInvitationOperation.readSummary,
        actor: actor,
        recipient: recipient,
        current: view,
        entryId: id,
      ),
      tx,
      CalendarAuthorizationPhase.read,
    );
    final source = await CalendarInvitationSourceRecord.db.findById(
      _session,
      sourceId,
      transaction: tx,
    );
    if (source == null || source.entryId != id) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final message = _invStored(source, entry);
    await _invAuthorize(
      CalendarInvitationPolicyContext(
        operation: CalendarInvitationOperation.readSource,
        actor: actor,
        recipient: recipient,
        current: view,
        entryId: id,
        sourceId: sourceId,
        message: message,
        normalizedSource: source.normalizedSource,
        sourceDigest: source.digest,
      ),
      tx,
      CalendarAuthorizationPhase.read,
    );
    return CalendarInvitationDocument(
      kind: _invKind(message),
      sourceId: sourceId,
      text: source.normalizedSource,
    );
  });
  Future<void> dismissInvitation(UuidValue id, int expectedRevision) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invEntry(id, recipient, tx),
            view = await _invView(entry, tx);
        final changed = entry.dismissedAt == null,
            revision = entry.revision + (changed ? 1 : 0);
        final request = CalendarInvitationPolicyContext(
          operation: CalendarInvitationOperation.dismiss,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: id,
          proposedRevision: revision,
          proposedDismissed: true,
        );
        await _invAuthorize(
          request,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        if (entry.revision != expectedRevision) {
          throw _failure(CalendarFailureCode.staleRevision);
        }
        if (revision > CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final now = await _revisionTime(tx, previous: entry.updatedAt);
        if (changed) {
          await _invCleanup(recipient, tx, now);
          final entries = await _invEntries(recipient, tx);
          if (entries.where((e) => e.dismissedAt != null).length >=
              _invOptions.maxDismissed) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          entry.dismissedAt = now;
          entry.updatedAt = now;
          entry.revision = revision;
          await CalendarInvitationRecord.db.updateRow(
            _session,
            entry,
            transaction: tx,
          );
          final source = await CalendarInvitationSourceRecord.db.findById(
            _session,
            entry.currentSourceId!,
            transaction: tx,
          );
          if (source == null) throw _failure(CalendarFailureCode.unavailable);
          source.inactiveAt = now;
          await CalendarInvitationSourceRecord.db.updateRow(
            _session,
            source,
            transaction: tx,
          );
        }
        await _invAuthorize(request, tx, CalendarAuthorizationPhase.finalWrite);
      });
}
