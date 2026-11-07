part of 'calendar_module.dart';

extension on CalendarService {
  CalendarFreeBusyExchangeRuntime get _fbRuntime =>
      _runtime.freeBusyExchanges ??
      (throw _failure(CalendarFailureCode.unavailable));

  void _fbCheckGuarantee() {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _fbRuntime.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<void> _fbAuthorize(
    CalendarFreeBusyExchangePolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final host = _fbRuntime.host;
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        host.guarantee != CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    _fbCheckGuarantee();
    final verdict = await _bounded(
      () => host.authorize(_session, context, tx, phase),
    );
    _fbCheckGuarantee();
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  IcalendarFreeBusyMessage _fbParse(String payload) {
    if (payload.length > 262144 ||
        utf8.encode(payload).length > 262144 ||
        utf8.decode(utf8.encode(payload)) != payload) {
      throw _failure(CalendarFailureCode.validation);
    }
    try {
      return parseIcalendarFreeBusyMessage(utf8.encode(payload));
    } on IcalendarComponentException {
      throw _failure(CalendarFailureCode.validation);
    } on IcalendarSyntaxException {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  String _fbHeader(
    IcalendarFreeBusyMessage message,
    CalendarFreeBusyMailbox mailbox,
  ) => jsonEncode({
    'method': message.method.name,
    'mailbox': mailbox.address,
    'calendarId': mailbox.calendarId.toString(),
    'components': [
      for (final c in message.components)
        {
          'fromUtc': c.window.start.toIso8601String(),
          'untilUtc': c.window.end.toIso8601String(),
          'organizer': c.organizer.address,
          'attendees': c.attendees,
        },
    ],
  });

  IcalendarFreeBusyMessage _fbStoredSource(
    CalendarFreeBusySourceRecord source,
  ) {
    try {
      final body = source.payload;
      if (body == null ||
          source.header == null ||
          body.length > 262144 ||
          source.byteCount != utf8.encode(body).length ||
          sha256.convert(utf8.encode(body)).toString() !=
              source.payloadDigest) {
        throw StateError('Invalid stored source');
      }
      final message = _fbParse(body);
      final mailbox = _fbSourceMailbox(source);
      if (source.method != message.method.name ||
          source.sourceStamp != message.components.first.stamp ||
          source.header != _fbHeader(message, mailbox) ||
          (source.headId != null) !=
              (message.method == IcalendarFreeBusyMethod.request) ||
          (source.requestCommandId != null) !=
              (message.method == IcalendarFreeBusyMethod.reply)) {
        throw StateError('Invalid stored source binding');
      }
      return message;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  String _fbDigest(Object value) =>
      sha256.convert(utf8.encode(jsonEncode(value))).toString();

  Future<CalendarFreeBusyIngressReceipt> _receiveFreeBusy(
    CalendarFreeBusyIngress input,
  ) async {
    final mailbox = input.mailbox;
    for (final value in [
      mailbox.scopeKey,
      mailbox.ownerKey,
      mailbox.bindingRef,
      input.namespace,
      input.deliveryKey,
      input.originRef,
    ]) {
      if (value.isEmpty ||
          value.length > 512 ||
          utf8.encode(value).length > 512 ||
          value.runes.any((c) => c < 32 || c == 127)) {
        throw _failure(CalendarFailureCode.validation);
      }
    }
    if (mailbox.address.isEmpty ||
        mailbox.address.length > 4096 ||
        utf8.encode(mailbox.address).length > 4096 ||
        mailbox.address.runes.any((c) => c < 32 || c == 127)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final message = _fbParse(input.payload);
    final digest = sha256.convert(utf8.encode(input.payload)).toString();
    final inputDigest = _fbDigest([
      mailbox.scopeKey,
      mailbox.ownerKey,
      mailbox.calendarId.toString(),
      mailbox.address,
      mailbox.bindingRef,
      input.originRef,
      digest,
    ]);
    final operation = switch (message.method) {
      IcalendarFreeBusyMethod.publish =>
        CalendarFreeBusyExchangeOperation.receivePublish,
      IcalendarFreeBusyMethod.request =>
        CalendarFreeBusyExchangeOperation.receiveRequest,
      IcalendarFreeBusyMethod.reply =>
        CalendarFreeBusyExchangeOperation.receiveReply,
    };
    return _scopeTransaction(mailbox.scopeKey, (tx, _) async {
      CalendarFreeBusyCommandRecord? request;
      CalendarSchedulingRoute? replyRoute;
      _Active? parent;
      CalendarFreeBusyExchangePolicyContext context({
        UuidValue? sourceId,
        bool retry = false,
      }) => CalendarFreeBusyExchangePolicyContext(
        operation: operation,
        scopeKey: mailbox.scopeKey,
        ownerKey: mailbox.ownerKey,
        mailbox: mailbox,
        calendar: parent?.snapshot,
        message: message,
        sourceId: sourceId,
        payloadDigest: digest,
        originRef: input.originRef,
        namespace: input.namespace,
        deliveryKey: input.deliveryKey,
        isRetry: retry,
        commandId: request?.id,
        requestMessage: request?.payload == null
            ? null
            : _fbParse(request!.payload!),
        route: replyRoute,
      );
      // Historical delivery identity is resolved before quotas or current-source
      // selection. A retained retry cannot reactivate a stale/dismissed source.
      final old = await CalendarFreeBusyIngressReceiptRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(mailbox.scopeKey) &
            t.ownerKey.equals(mailbox.ownerKey) &
            t.namespace.equals(input.namespace) &
            t.deliveryKey.equals(input.deliveryKey),
        transaction: tx,
      );
      if (old != null) {
        if (old.inputDigest != inputDigest) {
          throw _failure(CalendarFailureCode.validation);
        }
        await _fbAuthorize(
          context(sourceId: old.sourceId, retry: true),
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        await _fbAuthorize(
          context(sourceId: old.sourceId, retry: true),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
        return CalendarFreeBusyIngressReceipt.fromJson(
          jsonDecode(old.result) as Map<String, dynamic>,
        );
      }
      parent = await _activeInScope(mailbox.scopeKey, mailbox.calendarId, tx);
      await _fbAuthorize(
        context(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final now = await _revisionTime(tx);
      final options = _fbRuntime.options;
      final component = message.components.first;
      CalendarFreeBusyRequestHeadRecord? head;
      String outcome = 'received';
      if (message.method == IcalendarFreeBusyMethod.request) {
        _busyWindow(component.window.start, component.window.end);
        if (!component.attendees.contains(mailbox.address)) {
          throw _failure(CalendarFailureCode.validation);
        }
        // Binding is verified separately so changing it for an existing UID
        // cannot bypass immutable-window checks by allocating another head.
        final correlation = _fbDigest([
          component.organizer.address,
          mailbox.address,
          component.uid,
        ]);
        head = await CalendarFreeBusyRequestHeadRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(mailbox.scopeKey) &
              t.ownerKey.equals(mailbox.ownerKey) &
              t.correlationDigest.equals(correlation),
          transaction: tx,
        );
        if (head != null &&
            (head.purgedAt != null ||
                head.calendarId != mailbox.calendarId ||
                head.bindingRef != mailbox.bindingRef ||
                head.mailboxAddress != mailbox.address ||
                head.fromUtc != component.window.start ||
                head.untilUtc != component.window.end)) {
          throw _failure(CalendarFailureCode.validation);
        }
        if (head == null) {
          final heads = await CalendarFreeBusyRequestHeadRecord.db.find(
            _session,
            where: (t) => t.scopeKey.equals(mailbox.scopeKey),
            limit: options.maxScopeHeads + 1,
            transaction: tx,
          );
          if (heads.length >= options.maxScopeHeads ||
              heads.where((h) => h.ownerKey == mailbox.ownerKey).length >=
                  options.maxOwnerHeads) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          head = await CalendarFreeBusyRequestHeadRecord.db.insertRow(
            _session,
            CalendarFreeBusyRequestHeadRecord(
              scopeKey: mailbox.scopeKey,
              ownerKey: mailbox.ownerKey,
              correlationDigest: correlation,
              calendarId: mailbox.calendarId,
              mailboxAddress: mailbox.address,
              bindingRef: mailbox.bindingRef,
              requesterAddress: component.organizer.address,
              fromUtc: component.window.start,
              untilUtc: component.window.end,
              sourceRevision: 0,
              replyRevision: 0,
              createdAt: now,
              updatedAt: now,
              expiresAt: now.add(options.retention),
            ),
            transaction: tx,
          );
        }
      } else if (message.method == IcalendarFreeBusyMethod.reply) {
        final candidates = await CalendarFreeBusyCommandRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(mailbox.scopeKey) &
              t.ownerKey.equals(mailbox.ownerKey) &
              t.method.equals('request'),
          limit: options.maxOwnerCommands + 1,
          transaction: tx,
        );
        if (candidates.length > options.maxOwnerCommands) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        for (final candidate in candidates) {
          if (candidate.payload == null ||
              candidate.scrubbedAt != null ||
              candidate.correlatableUntil == null ||
              !candidate.correlatableUntil!.isAfter(now)) {
            continue;
          }
          final sent = _fbParse(candidate.payload!).components.single;
          if (sent.uid != component.uid) continue;
          if (request != null ||
              candidate.calendarId != mailbox.calendarId ||
              sent.organizer.address != mailbox.address ||
              component.organizer.address != mailbox.address ||
              component.window.start != sent.window.start ||
              component.window.end != sent.window.end ||
              !sent.attendees.contains(component.attendees.single)) {
            throw _failure(CalendarFailureCode.validation);
          }
          request = candidate;
        }
        if (request == null) throw _failure(CalendarFailureCode.validation);
        final deliveries = await CalendarFreeBusyDeliveryRecord.db.find(
          _session,
          where: (t) =>
              t.commandId.equals(request!.id!) &
              t.scopeKey.equals(mailbox.scopeKey) &
              t.ownerKey.equals(mailbox.ownerKey) &
              t.recipientAddress.equals(component.attendees.single),
          limit: 2,
          transaction: tx,
        );
        if (deliveries.length != 1 || deliveries.single.routeRef == null) {
          throw _failure(CalendarFailureCode.validation);
        }
        replyRoute = CalendarSchedulingRoute(
          component.attendees.single,
          deliveries.single.routeRef!,
        );
      }
      final header = _fbHeader(message, mailbox);
      if (utf8.encode(header).length > 32768) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final sources = await CalendarFreeBusySourceRecord.db.find(
        _session,
        where: (t) => t.scopeKey.equals(mailbox.scopeKey),
        limit: options.maxScopeSources + 1,
        transaction: tx,
      );
      if (sources.length > options.maxScopeSources) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      CalendarFreeBusySourceRecord? source;
      for (final row in sources) {
        if (row.ownerKey == mailbox.ownerKey &&
            row.payloadDigest == digest &&
            row.bindingRef == mailbox.bindingRef &&
            row.mailboxAddress == mailbox.address &&
            row.headId == head?.id &&
            row.requestCommandId == request?.id &&
            row.payload != null) {
          if (!row.expiresAt.isAfter(now)) {
            throw _failure(CalendarFailureCode.unavailable);
          }
          source = row;
          break;
        }
      }
      final receipts = await CalendarFreeBusyIngressReceiptRecord.db.find(
        _session,
        where: (t) => t.scopeKey.equals(mailbox.scopeKey),
        limit: options.maxScopeIngress + 1,
        transaction: tx,
      );
      if (receipts.length >= options.maxScopeIngress ||
          receipts.where((r) => r.ownerKey == mailbox.ownerKey).length >=
              options.maxOwnerIngress) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (source == null) {
        final added =
            utf8.encode(input.payload).length + utf8.encode(header).length;
        int bytes(Iterable<CalendarFreeBusySourceRecord> rows) => rows.fold(
          0,
          (n, r) =>
              n +
              (r.payload == null ? 0 : r.byteCount) +
              (r.header == null ? 0 : utf8.encode(r.header!).length),
        );
        final own = sources.where((s) => s.ownerKey == mailbox.ownerKey);
        if (sources.length >= options.maxScopeSources ||
            own.length >= options.maxOwnerSources ||
            bytes(sources) + added > options.maxScopeBytes ||
            bytes(own) + added > options.maxOwnerBytes ||
            head != null &&
                sources.where((s) => s.headId == head!.id).length >=
                    options.maxHeadVersions) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        source = await CalendarFreeBusySourceRecord.db.insertRow(
          _session,
          CalendarFreeBusySourceRecord(
            scopeKey: mailbox.scopeKey,
            ownerKey: mailbox.ownerKey,
            method: message.method.name,
            headId: head?.id,
            requestCommandId: request?.id,
            payloadDigest: digest,
            byteCount: utf8.encode(input.payload).length,
            payload: input.payload,
            header: header,
            originRef: input.originRef,
            bindingRef: mailbox.bindingRef,
            mailboxAddress: mailbox.address,
            sourceStamp: component.stamp,
            receivedAt: now,
            expiresAt: now.add(options.retention),
          ),
          transaction: tx,
        );
      }
      if (head != null) {
        final previousSource = head.currentSourceId;
        final wasConflicted = head.conflicted;
        final selected = head.currentSourceId == null
            ? null
            : await CalendarFreeBusySourceRecord.db.findById(
                _session,
                head.currentSourceId!,
                transaction: tx,
              );
        if (head.currentSourceId != null && selected?.payload == null) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (selected != null) {
          if (selected.scopeKey != mailbox.scopeKey ||
              selected.ownerKey != mailbox.ownerKey ||
              selected.headId != head.id) {
            throw _failure(CalendarFailureCode.unavailable);
          }
          _fbStoredSource(selected);
        }
        if (selected == null || component.stamp.isAfter(selected.sourceStamp)) {
          head.currentSourceId = source.id;
          head.conflicted = false;
          head.expiresAt = source.expiresAt;
          head.sourceRevision++;
          outcome = 'current';
        } else if (selected.payloadDigest == digest) {
          outcome = head.conflicted ? 'conflict' : 'current';
        } else if (component.stamp == selected.sourceStamp) {
          if (!head.conflicted) head.sourceRevision++;
          head.conflicted = true;
          outcome = 'conflict';
        } else {
          outcome = 'stale';
        }
        if (head.sourceRevision > CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        head.updatedAt = now;
        await CalendarFreeBusyRequestHeadRecord.db.updateRow(
          _session,
          head,
          transaction: tx,
        );
        if (head.currentSourceId != previousSource ||
            head.conflicted && !wasConflicted) {
          final headSources = {
            source.id!,
            for (final s in sources)
              if (s.headId == head.id) s.id!,
          };
          final commands = await CalendarFreeBusyCommandRecord.db.find(
            _session,
            where: (t) =>
                t.scopeKey.equals(mailbox.scopeKey) &
                t.ownerKey.equals(mailbox.ownerKey),
            limit: options.maxOwnerCommands + 1,
            transaction: tx,
          );
          if (commands.length > options.maxOwnerCommands) {
            throw _failure(CalendarFailureCode.unavailable);
          }
          for (final command in commands) {
            if (!headSources.contains(command.sourceId) ||
                command.terminalAt != null ||
                !head.conflicted && command.sourceId == head.currentSourceId) {
              continue;
            }
            if (command.generation >= CalendarService._maxRevision) {
              throw _failure(CalendarFailureCode.unavailable);
            }
            command.generation++;
            command.terminalAt = now;
            await CalendarFreeBusyCommandRecord.db.updateRow(
              _session,
              command,
              transaction: tx,
            );
            final deliveries = await CalendarFreeBusyDeliveryRecord.db.find(
              _session,
              where: (t) => t.commandId.equals(command.id!),
              limit: 65,
              transaction: tx,
            );
            if (deliveries.length > 64) {
              throw _failure(CalendarFailureCode.unavailable);
            }
            for (final delivery in deliveries.where(
              (d) => d.terminalAt == null,
            )) {
              delivery
                ..state = 'withdrawn'
                ..generation = command.generation
                ..terminalAt = now
                ..leaseOwner = null
                ..leaseToken = null
                ..leaseUntil = null;
              await CalendarFreeBusyDeliveryRecord.db.updateRow(
                _session,
                delivery,
                transaction: tx,
              );
            }
          }
        }
      }
      await _fbAuthorize(
        context(sourceId: source.id),
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      final id = UuidValue.fromString(const Uuid().v4());
      final result = CalendarFreeBusyIngressReceipt(
        id: id,
        sourceId: source.id!,
        headId: head?.id,
        outcome: outcome,
        sourceRevision: head?.sourceRevision,
        receivedAt: now,
      );
      await CalendarFreeBusyIngressReceiptRecord.db.insertRow(
        _session,
        CalendarFreeBusyIngressReceiptRecord(
          id: id,
          scopeKey: mailbox.scopeKey,
          ownerKey: mailbox.ownerKey,
          namespace: input.namespace,
          deliveryKey: input.deliveryKey,
          inputDigest: inputDigest,
          sourceId: source.id!,
          result: jsonEncode(result.toJson()),
          createdAt: now,
          expiresAt: now.add(options.retention),
        ),
        transaction: tx,
      );
      return result;
    });
  }
}
