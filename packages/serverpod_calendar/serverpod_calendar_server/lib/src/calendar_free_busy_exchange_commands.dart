part of 'calendar_module.dart';

extension CalendarFreeBusyExchangeCommands on CalendarService {
  Future<CalendarFreeBusyCommandReceipt> publishFreeBusy(
    CalendarFreeBusyPublishRequest request,
  ) => _fbPublish(CalendarFreeBusyExchangeOperation.publish, request);
  Future<CalendarFreeBusyCommandReceipt> requestFreeBusy(
    CalendarFreeBusyPublishRequest request,
  ) => _fbPublish(CalendarFreeBusyExchangeOperation.request, request);

  Future<CalendarFreeBusyCommandReceipt> _fbPublish(
    CalendarFreeBusyExchangeOperation operation,
    CalendarFreeBusyPublishRequest input,
  ) {
    if (input.recipients.isEmpty ||
        input.recipients.length > 64 ||
        input.recipients.any(
          (a) => a.isEmpty || a.length > 4096 || utf8.encode(a).length > 4096,
        )) {
      throw _failure(CalendarFailureCode.validation);
    }
    final request = input.copyWith(
      recipients: List.unmodifiable(input.recipients),
    );
    return _fbSend(
      operation,
      request.commandId,
      request.toJson(),
      publication: request,
    );
  }

  Future<CalendarFreeBusyCommandReceipt> replyFreeBusy(
    CalendarFreeBusyReplyRequest request,
  ) => _fbSend(
    CalendarFreeBusyExchangeOperation.share,
    request.commandId,
    request.toJson(),
    reply: request,
  );
  Future<CalendarFreeBusyCommandReceipt> refuseFreeBusy(
    CalendarFreeBusyReplyRequest request,
  ) => _fbSend(
    CalendarFreeBusyExchangeOperation.refuse,
    request.commandId,
    request.toJson(),
    reply: request,
  );

  Future<String> _fbOwner(
    CalendarHostContext actor,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    final owner = await _bounded(
      () => _fbRuntime.host.resolveOwner(_session, actor, tx, phase),
    );
    if (owner.isEmpty ||
        utf8.encode(owner).length > 512 ||
        owner.runes.any((c) => c < 32 || c == 127)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return owner;
  }

  Future<CalendarFreeBusyCommandReceipt> _fbSend(
    CalendarFreeBusyExchangeOperation operation,
    UuidValue commandId,
    Map<String, dynamic> criteria, {
    CalendarFreeBusyPublishRequest? publication,
    CalendarFreeBusyReplyRequest? reply,
  }) async {
    final actor = await _context();
    final criteriaDigest = _fbDigest([operation.name, criteria]);
    return _transaction(actor, (tx, _) async {
      final owner = await _fbOwner(
        actor,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final old = await CalendarFreeBusyCommandRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(actor.scopeKey) &
            t.ownerKey.equals(owner) &
            t.commandId.equals(commandId),
        transaction: tx,
      );
      if (old != null) {
        // Scrubbed receipts are deliberately authorized without reconstructing
        // mailbox addresses, query windows or the old private report.
        final historicalSource = old.sourceId == null
            ? null
            : await CalendarFreeBusySourceRecord.db.findById(
                _session,
                old.sourceId!,
                transaction: tx,
              );
        if (old.payload != null &&
            old.sourceId != null &&
            historicalSource?.payload == null) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final context = CalendarFreeBusyExchangePolicyContext(
          operation: CalendarFreeBusyExchangeOperation.values.byName(
            old.action,
          ),
          scopeKey: actor.scopeKey,
          ownerKey: owner,
          actor: actor,
          mailbox: _fbCommandMailbox(old),
          commandId: old.id,
          sourceId: old.sourceId,
          sourceMessage: historicalSource?.payload == null
              ? null
              : _fbStoredSource(historicalSource!),
          originRef: historicalSource?.originRef,
          payloadDigest: old.payloadDigest,
          message: old.payload == null ? null : _fbParse(old.payload!),
          isRetry: true,
        );
        await _fbAuthorize(
          context,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        if (old.criteriaDigest != criteriaDigest) {
          throw _failure(CalendarFailureCode.validation);
        }
        await _fbAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
        if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.finalWrite) !=
            owner) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        await _verifyContext(actor);
        return CalendarFreeBusyCommandReceipt.fromJson(
          jsonDecode(old.receipt) as Map<String, dynamic>,
        );
      }
      final now = await _revisionTime(tx);
      final stamp = availabilityProtocolInstant(now);
      CalendarFreeBusySourceRecord? source;
      CalendarFreeBusyRequestHeadRecord? head;
      UuidValue calendarId;
      UtcWindow window;
      String uid;
      List<String> recipientAddresses;
      if (publication != null) {
        calendarId = publication.calendarId;
        window = _busyWindow(publication.fromUtc, publication.untilUtc);
        uid = const Uuid().v4();
        recipientAddresses = List.of(publication.recipients);
      } else {
        source = await CalendarFreeBusySourceRecord.db.findById(
          _session,
          reply!.sourceId,
          transaction: tx,
        );
        if (source == null ||
            source.scopeKey != actor.scopeKey ||
            source.ownerKey != owner ||
            source.method != 'request' ||
            source.payload == null ||
            source.headId == null ||
            !source.expiresAt.isAfter(now)) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        await _fbAuthorize(
          CalendarFreeBusyExchangePolicyContext(
            operation: operation,
            scopeKey: actor.scopeKey,
            ownerKey: owner,
            actor: actor,
            sourceId: source.id,
            mailbox: _fbSourceMailbox(source),
            sourceMessage: _fbStoredSource(source),
            originRef: source.originRef,
          ),
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        head = await CalendarFreeBusyRequestHeadRecord.db.findById(
          _session,
          source.headId!,
          transaction: tx,
        );
        if (head == null ||
            head.purgedAt != null ||
            head.calendarId == null ||
            head.conflicted ||
            head.currentSourceId != source.id ||
            head.scopeKey != actor.scopeKey ||
            head.ownerKey != owner) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (head.sourceRevision != reply.expectedSourceRevision ||
            head.replyRevision != reply.expectedReplyRevision) {
          throw _failure(CalendarFailureCode.staleRevision);
        }
        if (head.lastReplyStamp != null &&
            !stamp.isAfter(head.lastReplyStamp!)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final incoming = _fbStoredSource(source).components.single;
        if (head.fromUtc != incoming.window.start ||
            head.untilUtc != incoming.window.end ||
            incoming.organizer.address != head.requesterAddress ||
            !incoming.attendees.contains(head.mailboxAddress)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        calendarId = head.calendarId!;
        window = _busyWindow(incoming.window.start, incoming.window.end);
        uid = incoming.uid;
        recipientAddresses = [incoming.organizer.address];
      }
      final parent = await _active(actor, calendarId, tx);
      final mailbox = await _bounded(
        () => _fbRuntime.host.resolveMailbox(
          _session,
          actor,
          calendarId,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        ),
      );
      if (mailbox.scopeKey != actor.scopeKey ||
          mailbox.ownerKey != owner ||
          mailbox.calendarId != calendarId ||
          head != null &&
              (head.bindingRef != mailbox.bindingRef ||
                  head.mailboxAddress != mailbox.address)) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      for (final pair in [(mailbox.address, 4096), (mailbox.bindingRef, 512)]) {
        final value = pair.$1;
        if (value.isEmpty ||
            value.length > pair.$2 ||
            utf8.encode(value).length > pair.$2 ||
            value.runes.any((c) => c < 32 || c == 127)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
      }
      if (recipientAddresses.isEmpty ||
          recipientAddresses.length > _fbRuntime.options.maxRecipients ||
          recipientAddresses.toSet().length != recipientAddresses.length ||
          recipientAddresses.any(
            (a) => a.isEmpty || utf8.encode(a).length > 4096,
          )) {
        throw _failure(CalendarFailureCode.validation);
      }
      CalendarFreeBusyExchangePolicyContext context({
        IcalendarFreeBusyMessage? message,
        String? digest,
        CalendarSchedulingRoute? route,
      }) => CalendarFreeBusyExchangePolicyContext(
        operation: operation,
        scopeKey: actor.scopeKey,
        ownerKey: owner,
        mailbox: mailbox,
        actor: actor,
        calendar: parent.snapshot,
        sourceId: source?.id,
        sourceMessage: source?.payload == null
            ? null
            : _fbStoredSource(source!),
        originRef: source?.originRef,
        message: message,
        payloadDigest: digest,
        route: route,
      );
      await _fbAuthorize(
        context(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final routes = List<CalendarSchedulingRoute>.unmodifiable(
        await _bounded(
          () => _fbRuntime.host.resolveRoutes(
            _session,
            context(),
            List.unmodifiable(recipientAddresses),
            tx,
            CalendarAuthorizationPhase.preliminaryWrite,
          ),
        ),
      );
      if (routes.length != recipientAddresses.length ||
          routes.map((r) => r.address).toSet().length != routes.length ||
          routes.any(
            (r) =>
                !recipientAddresses.contains(r.address) ||
                r.routeRef.isEmpty ||
                utf8.encode(r.routeRef).length > 512,
          )) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final query = CalendarFreeBusyQuery(
        calendarId: calendarId,
        fromUtc: window.start,
        untilUtc: window.end,
      );
      final needsSnapshot =
          operation == CalendarFreeBusyExchangeOperation.publish ||
          operation == CalendarFreeBusyExchangeOperation.share;
      final authority = needsSnapshot
          ? [
              _er(parent, CalendarPermission.readFreeBusy, freeBusy: query),
              _er(parent, CalendarPermission.exportFreeBusy, freeBusy: query),
            ]
          : <CalendarAuthorizationRequest>[];
      final projections = <CalendarAuthorizationRequest>[];
      CalendarFreeBusyView? snapshot;
      if (needsSnapshot) {
        await _decide(
          actor,
          authority,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
        snapshot = await _calendarBusy(
          actor,
          parent,
          query,
          window,
          tx,
          _BusyBudget(),
          authorizedSources: projections,
        );
        if (snapshot.coverage != CalendarFreeBusyCoverage.complete) {
          throw _failure(CalendarFailureCode.unavailable);
        }
      }
      final method = operation == CalendarFreeBusyExchangeOperation.publish
          ? IcalendarFreeBusyMethod.publish
          : operation == CalendarFreeBusyExchangeOperation.request
          ? IcalendarFreeBusyMethod.request
          : IcalendarFreeBusyMethod.reply;
      late final IcalendarFreeBusyMessage message;
      late final String payload;
      try {
        message = buildCalendarFreeBusyExchange(
          method: method,
          uid: uid,
          stamp: stamp,
          window: window,
          organizer: method == IcalendarFreeBusyMethod.reply
              ? recipientAddresses.single
              : mailbox.address,
          attendees: method == IcalendarFreeBusyMethod.publish
              ? []
              : method == IcalendarFreeBusyMethod.reply
              ? [mailbox.address]
              : recipientAddresses,
          refused: operation == CalendarFreeBusyExchangeOperation.refuse,
          partition: snapshot == null
              ? null
              : [
                  for (final p in snapshot.periods)
                    AvailabilityInterval(
                      window: UtcWindow(start: p.startUtc, end: p.endUtc),
                      kind: AvailabilityKind.values.byName(p.kind.name),
                    ),
                ],
        );
        payload = utf8.decode(calendarFreeBusyExchangeBytes(message));
      } on IcalendarComponentException catch (e) {
        throw _failure(
          e.kind == IcalendarComponentError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on IcalendarSyntaxException catch (e) {
        throw _failure(
          e.kind == IcalendarSyntaxError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on ArgumentError {
        throw _failure(CalendarFailureCode.validation);
      }
      final digest = sha256.convert(utf8.encode(payload)).toString();
      for (final route in routes) {
        await _fbAuthorize(
          context(message: message, digest: digest, route: route),
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
        );
      }
      final options = _fbRuntime.options;
      final commands = await CalendarFreeBusyCommandRecord.db.find(
        _session,
        where: (t) => t.scopeKey.equals(actor.scopeKey),
        limit: options.maxScopeCommands + 1,
        transaction: tx,
      );
      final own = commands.where((c) => c.ownerKey == owner);
      final byteCount = utf8.encode(payload).length;
      if (byteCount > 262144) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (commands.length >= options.maxScopeCommands ||
          own.length >= options.maxOwnerCommands ||
          commands.fold<int>(0, (n, c) => n + c.byteCount) + byteCount >
              options.maxScopeBytes ||
          own.fold<int>(0, (n, c) => n + c.byteCount) + byteCount >
              options.maxOwnerBytes) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      for (final ownerOnly in [false, true]) {
        final pending = await CalendarFreeBusyDeliveryRecord.db.count(
          _session,
          where: (t) =>
              t.scopeKey.equals(actor.scopeKey) &
              t.terminalAt.equals(null) &
              (ownerOnly ? t.ownerKey.equals(owner) : Constant.bool(true)),
          transaction: tx,
        );
        final references = await CalendarFreeBusySourceReferenceRecord.db.count(
          _session,
          where: (t) =>
              t.scopeKey.equals(actor.scopeKey) &
              (ownerOnly ? t.ownerKey.equals(owner) : Constant.bool(true)),
          transaction: tx,
        );
        if (pending + routes.length >
                (ownerOnly
                    ? options.maxOwnerPendingDeliveries
                    : options.maxScopePendingDeliveries) ||
            references + projections.length >
                (ownerOnly
                    ? options.maxOwnerReferences
                    : options.maxScopeReferences)) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
      }
      for (
        var i = 0;
        i < authority.length + projections.length;
        i += _options.policyBatchSize
      ) {
        final all = [...authority, ...projections];
        await _decide(
          actor,
          all.sublist(i, min(i + _options.policyBatchSize, all.length)),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
      }
      final finalMailbox = await _bounded(
        () => _fbRuntime.host.resolveMailbox(
          _session,
          actor,
          calendarId,
          tx,
          CalendarAuthorizationPhase.finalWrite,
        ),
      );
      if (_fbDigest([
                finalMailbox.scopeKey,
                finalMailbox.ownerKey,
                finalMailbox.calendarId.toString(),
                finalMailbox.address,
                finalMailbox.bindingRef,
              ]) !=
              _fbDigest([
                mailbox.scopeKey,
                mailbox.ownerKey,
                mailbox.calendarId.toString(),
                mailbox.address,
                mailbox.bindingRef,
              ]) ||
          await _fbOwner(actor, tx, CalendarAuthorizationPhase.finalWrite) !=
              owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final finalRoutes = await _bounded(
        () => _fbRuntime.host.resolveRoutes(
          _session,
          context(message: message, digest: digest),
          List.unmodifiable(recipientAddresses),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        ),
      );
      if (_fbDigest([
            for (final r in routes) [r.address, r.routeRef],
          ]) !=
          _fbDigest([
            for (final r in finalRoutes) [r.address, r.routeRef],
          ])) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      for (final route in routes) {
        await _fbAuthorize(
          context(message: message, digest: digest, route: route),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
      }
      await _verifyContext(actor);
      final id = UuidValue.fromString(const Uuid().v4());
      final deliveryIds = [
        for (final _ in routes) UuidValue.fromString(const Uuid().v4()),
      ];
      final receipt = CalendarFreeBusyCommandReceipt(
        id: id,
        commandId: commandId,
        deliveryIds: deliveryIds,
        stamp: stamp,
      );
      final expiry = now.add(
        method == IcalendarFreeBusyMethod.request
            ? options.requestExpiry
            : options.reportExpiry,
      );
      await CalendarFreeBusyCommandRecord.db.insertRow(
        _session,
        CalendarFreeBusyCommandRecord(
          id: id,
          scopeKey: actor.scopeKey,
          ownerKey: owner,
          commandId: commandId,
          criteriaDigest: criteriaDigest,
          method: method.name,
          action: operation.name,
          sourceId: source?.id,
          calendarId: calendarId,
          stamp: stamp,
          timezoneIdentity: needsSnapshot ? _occurrenceTimezoneIdentity : null,
          calculationProfile: needsSnapshot ? 1 : null,
          parentSettingsDigest: needsSnapshot
              ? _fbDigest([
                  parent.data.availabilityZoneId,
                  parent.data.noRuleFallback.name,
                ])
              : null,
          arguments: jsonEncode({
            'mailbox': {
              'scope': mailbox.scopeKey,
              'owner': owner,
              'calendar': calendarId.toString(),
              'address': mailbox.address,
              'binding': mailbox.bindingRef,
            },
            'fromUtc': window.start.toIso8601String(),
            'untilUtc': window.end.toIso8601String(),
          }),
          payload: payload,
          payloadDigest: digest,
          byteCount: byteCount,
          generation: 1,
          receipt: jsonEncode(receipt.toJson()),
          createdAt: now,
          expiresAt: expiry,
          correlatableUntil: method == IcalendarFreeBusyMethod.request
              ? now.add(options.retention)
              : null,
        ),
        transaction: tx,
      );
      for (final projection in projections) {
        final e = projection.currentEvent;
        final a = projection.currentAvailability;
        if ((e == null) == (a == null)) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        await CalendarFreeBusySourceReferenceRecord.db.insertRow(
          _session,
          CalendarFreeBusySourceReferenceRecord(
            scopeKey: actor.scopeKey,
            ownerKey: owner,
            commandId: id,
            sourceKey: e == null
                ? 'availability:${a!.availabilityId}'
                : 'event:${e.eventId}',
            eventId: e?.eventId,
            availabilityId: a?.availabilityId,
            revision: e?.revision ?? a!.revision,
            contentDigest: e != null
                ? _fbDigest([e.content.toJson(), e.timingOverrides?.toJson()])
                : _fbDigest([
                    a!.content.toJson(),
                    a.timingOverrides?.map((v) => v.toJson()).toList(),
                  ]),
          ),
          transaction: tx,
        );
      }
      for (var i = 0; i < routes.length; i++) {
        await CalendarFreeBusyDeliveryRecord.db.insertRow(
          _session,
          CalendarFreeBusyDeliveryRecord(
            id: deliveryIds[i],
            scopeKey: actor.scopeKey,
            ownerKey: owner,
            commandId: id,
            recipientAddress: routes[i].address,
            routeRef: routes[i].routeRef,
            authorityRef: mailbox.bindingRef,
            generation: 1,
            state: 'queued',
            nextAttemptAt: now,
            createdAt: now,
            expiresAt: expiry,
          ),
          transaction: tx,
        );
      }
      if (head != null) {
        if (head.replyRevision >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        head.replyRevision++;
        head.lastReplyStamp = stamp;
        head.latestCommandId = id;
        head.updatedAt = now;
        await CalendarFreeBusyRequestHeadRecord.db.updateRow(
          _session,
          head,
          transaction: tx,
        );
      }
      return receipt;
    });
  }
}
