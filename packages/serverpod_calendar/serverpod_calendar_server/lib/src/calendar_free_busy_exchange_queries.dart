part of 'calendar_module.dart';

extension CalendarFreeBusyExchangeQueries on CalendarService {
  CalendarFreeBusyMailbox? _fbCommandMailbox(
    CalendarFreeBusyCommandRecord command,
  ) {
    if (command.scrubbedAt != null) return null;
    try {
      final args = jsonDecode(command.arguments!) as Map<String, dynamic>;
      final m = args['mailbox'] as Map<String, dynamic>;
      final mailbox = CalendarFreeBusyMailbox(
        scopeKey: m['scope'] as String,
        ownerKey: m['owner'] as String,
        calendarId: UuidValue.fromString(m['calendar'] as String),
        address: m['address'] as String,
        bindingRef: m['binding'] as String,
      );
      if (mailbox.scopeKey != command.scopeKey ||
          mailbox.ownerKey != command.ownerKey ||
          mailbox.calendarId != command.calendarId) {
        throw StateError('Invalid binding');
      }
      return mailbox;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarFreeBusyMailbox _fbSourceMailbox(
    CalendarFreeBusySourceRecord source,
  ) {
    try {
      final header = jsonDecode(source.header!) as Map<String, dynamic>;
      return CalendarFreeBusyMailbox(
        scopeKey: source.scopeKey,
        ownerKey: source.ownerKey,
        calendarId: UuidValue.fromString(header['calendarId'] as String),
        address: source.mailboxAddress!,
        bindingRef: source.bindingRef!,
      );
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarFreeBusyExchangePolicyContext _fbSourceContext(
    CalendarHostContext actor,
    CalendarFreeBusySourceRecord source,
    CalendarFreeBusyExchangeOperation operation,
  ) => CalendarFreeBusyExchangePolicyContext(
    operation: operation,
    scopeKey: actor.scopeKey,
    ownerKey: source.ownerKey,
    mailbox: _fbSourceMailbox(source),
    actor: actor,
    sourceId: source.id,
    message: _fbStoredSource(source),
    payloadDigest: source.payloadDigest,
    originRef: source.originRef,
  );

  Future<CalendarFreeBusySourceRecord> _fbOwnedSource(
    CalendarHostContext actor,
    String owner,
    UuidValue id,
    Transaction tx,
  ) async {
    final row = await CalendarFreeBusySourceRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    final now = await _revisionTime(tx);
    if (row == null ||
        row.scopeKey != actor.scopeKey ||
        row.ownerKey != owner) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (row.payload == null ||
        row.header == null ||
        row.purgedAt != null ||
        !row.expiresAt.isAfter(now)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return row;
  }

  Future<CalendarFreeBusyMessageView> _fbMessageView(
    CalendarFreeBusySourceRecord row,
    Transaction tx,
  ) async {
    final head = row.headId == null
        ? null
        : await CalendarFreeBusyRequestHeadRecord.db.findById(
            _session,
            row.headId!,
            transaction: tx,
          );
    if (row.headId != null &&
        (head == null ||
            head.scopeKey != row.scopeKey ||
            head.ownerKey != row.ownerKey)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final publicHeader = Map<String, dynamic>.from(
      jsonDecode(row.header!) as Map,
    )..remove('calendarId');
    return CalendarFreeBusyMessageView(
      id: row.id!,
      method: row.method,
      header: jsonEncode(publicHeader),
      headId: row.headId,
      sourceRevision: head?.sourceRevision,
      replyRevision: head?.replyRevision,
      isCurrent: head?.currentSourceId == row.id,
      conflicted: head?.conflicted ?? false,
      receivedAt: row.receivedAt,
      expiresAt: row.expiresAt,
      dismissedAt: row.dismissedAt,
    );
  }

  Future<CalendarFreeBusyMessageView> getFreeBusyMessage(
    UuidValue sourceId,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final owner = await _fbOwner(actor, tx, CalendarAuthorizationPhase.read);
      final source = await _fbOwnedSource(actor, owner, sourceId, tx);
      await _fbAuthorize(
        _fbSourceContext(
          actor,
          source,
          CalendarFreeBusyExchangeOperation.readHeader,
        ),
        tx,
        CalendarAuthorizationPhase.read,
      );
      final result = await _fbMessageView(source, tx);
      if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.read) != owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _verifyContext(actor);
      return result;
    });
  }

  Future<ByteData> getFreeBusySource(UuidValue sourceId) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final owner = await _fbOwner(actor, tx, CalendarAuthorizationPhase.read);
      final source = await _fbOwnedSource(actor, owner, sourceId, tx);
      await _fbAuthorize(
        _fbSourceContext(
          actor,
          source,
          CalendarFreeBusyExchangeOperation.readSource,
        ),
        tx,
        CalendarAuthorizationPhase.read,
      );
      if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.read) != owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _verifyContext(actor);
      return ByteData.sublistView(
        Uint8List.fromList(utf8.encode(source.payload!)),
      );
    });
  }

  Future<CalendarFreeBusyMessageView> dismissFreeBusyMessage(
    UuidValue sourceId,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final owner = await _fbOwner(
        actor,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final source = await _fbOwnedSource(actor, owner, sourceId, tx);
      final context = _fbSourceContext(
        actor,
        source,
        CalendarFreeBusyExchangeOperation.dismiss,
      );
      await _fbAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      await _fbAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
      if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.finalWrite) !=
          owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _verifyContext(actor);
      source.dismissedAt ??= await _revisionTime(tx);
      await CalendarFreeBusySourceRecord.db.updateRow(
        _session,
        source,
        transaction: tx,
      );
      // A dismissal neither changes the selected request nor withdraws a reply.
      return _fbMessageView(source, tx);
    });
  }

  Future<CalendarFreeBusyCommandReceipt> withdrawFreeBusyCommand(
    UuidValue id,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final owner = await _fbOwner(
        actor,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final command = await CalendarFreeBusyCommandRecord.db.findById(
        _session,
        id,
        transaction: tx,
      );
      if (command == null ||
          command.scopeKey != actor.scopeKey ||
          command.ownerKey != owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final context = CalendarFreeBusyExchangePolicyContext(
        operation: CalendarFreeBusyExchangeOperation.withdraw,
        scopeKey: actor.scopeKey,
        ownerKey: owner,
        actor: actor,
        mailbox: _fbCommandMailbox(command),
        commandId: id,
        payloadDigest: command.payloadDigest,
        message: command.payload == null ? null : _fbParse(command.payload!),
      );
      await _fbAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      await _fbAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
      if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.finalWrite) !=
          owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _verifyContext(actor);
      if (command.terminalAt == null) {
        if (command.generation >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final now = await _revisionTime(tx);
        command.generation++;
        command.terminalAt = now;
        await CalendarFreeBusyCommandRecord.db.updateRow(
          _session,
          command,
          transaction: tx,
        );
        final deliveries = await CalendarFreeBusyDeliveryRecord.db.find(
          _session,
          where: (t) => t.commandId.equals(id),
          limit: 65,
          transaction: tx,
        );
        if (deliveries.length > 64) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        for (final d in deliveries.where((d) => d.terminalAt == null)) {
          d
            ..state = 'withdrawn'
            ..generation = command.generation
            ..terminalAt = now
            ..leaseOwner = null
            ..leaseToken = null
            ..leaseUntil = null;
          await CalendarFreeBusyDeliveryRecord.db.updateRow(
            _session,
            d,
            transaction: tx,
          );
        }
      }
      return CalendarFreeBusyCommandReceipt.fromJson(
        jsonDecode(command.receipt) as Map<String, dynamic>,
      );
    });
  }

  Future<CalendarFreeBusyMessagePage> listFreeBusyInbox({
    int pageSize = 20,
    String? cursor,
  }) async {
    final result = await _fbPage('inbox', pageSize, cursor);
    return CalendarFreeBusyMessagePage(
      items: result.$1.cast<CalendarFreeBusyMessageView>(),
      cursor: result.$2,
    );
  }

  Future<CalendarFreeBusyOutgoingPage> listFreeBusyOutgoing({
    int pageSize = 20,
    String? cursor,
  }) async {
    final result = await _fbPage('outgoing', pageSize, cursor);
    return CalendarFreeBusyOutgoingPage(
      items: result.$1.cast<CalendarFreeBusyOutgoingView>(),
      cursor: result.$2,
    );
  }

  Future<CalendarFreeBusyDeliveryPage> freeBusyDeliveryActivity(
    UuidValue commandId, {
    int pageSize = 20,
    String? cursor,
  }) async {
    final result = await _fbPage(
      'activity',
      pageSize,
      cursor,
      parent: commandId,
    );
    return CalendarFreeBusyDeliveryPage(
      items: result.$1.cast<CalendarFreeBusyDeliveryView>(),
      cursor: result.$2,
    );
  }

  Future<(List<Object>, String?)> _fbPage(
    String family,
    int pageSize,
    String? token, {
    UuidValue? parent,
  }) async {
    if (pageSize < 1 || pageSize > 50) {
      throw _failure(CalendarFailureCode.validation);
    }
    final actor = await _context();
    return _transaction(actor, (tx, scope) async {
      final owner = await _fbOwner(actor, tx, CalendarAuthorizationPhase.read);
      final now = await _revisionTime(tx);
      final options = _fbRuntime.options;
      final sources = family != 'inbox'
          ? <CalendarFreeBusySourceRecord>[]
          : await CalendarFreeBusySourceRecord.db.find(
              _session,
              where: (t) =>
                  t.scopeKey.equals(actor.scopeKey) & t.ownerKey.equals(owner),
              orderBy: (t) => t.id,
              limit: options.maxOwnerSources + 1,
              transaction: tx,
            );
      final commands = family != 'outgoing' && family != 'activity'
          ? <CalendarFreeBusyCommandRecord>[]
          : await CalendarFreeBusyCommandRecord.db.find(
              _session,
              where: (t) =>
                  t.scopeKey.equals(actor.scopeKey) & t.ownerKey.equals(owner),
              orderBy: (t) => t.id,
              limit: options.maxOwnerCommands + 1,
              transaction: tx,
            );
      final heads = family != 'inbox'
          ? <CalendarFreeBusyRequestHeadRecord>[]
          : await CalendarFreeBusyRequestHeadRecord.db.find(
              _session,
              where: (t) =>
                  t.scopeKey.equals(actor.scopeKey) & t.ownerKey.equals(owner),
              orderBy: (t) => t.id,
              limit: options.maxOwnerHeads + 1,
              transaction: tx,
            );
      if (sources.length > options.maxOwnerSources ||
          commands.length > options.maxOwnerCommands ||
          heads.length > options.maxOwnerHeads) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (family == 'activity' &&
          !commands.any((c) => c.id == parent && c.scrubbedAt == null)) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final deliveries = family != 'activity'
          ? <CalendarFreeBusyDeliveryRecord>[]
          : await CalendarFreeBusyDeliveryRecord.db.find(
              _session,
              where: (t) =>
                  t.commandId.equals(parent!) &
                  t.scopeKey.equals(actor.scopeKey) &
                  t.ownerKey.equals(owner),
              orderBy: (t) => t.id,
              limit: 65,
              transaction: tx,
            );
      if (deliveries.length > 64) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final vector = _fbDigest([
        for (final s in sources)
          [
            s.id.toString(),
            s.payloadDigest,
            s.purgedAt?.toIso8601String(),
            s.dismissedAt?.toIso8601String(),
            s.expiresAt.isAfter(now),
          ],
        for (final h in heads)
          [
            h.id.toString(),
            h.currentSourceId?.toString(),
            h.sourceRevision,
            h.replyRevision,
            h.conflicted,
            h.purgedAt?.toIso8601String(),
          ],
        for (final c in commands)
          [
            c.id.toString(),
            c.generation,
            c.terminalAt?.toIso8601String(),
            c.scrubbedAt?.toIso8601String(),
          ],
        for (final d in deliveries)
          [
            d.id.toString(),
            d.state,
            d.attemptCount,
            d.terminalAt?.toIso8601String(),
          ],
      ]);
      final criteria = _fbDigest([family, parent?.toString(), pageSize]);
      UuidValue? after;
      if (token != null) {
        if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(token)) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        final saved = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (t) => t.token.equals(token),
          transaction: tx,
        );
        final state = saved?.freeBusyExchangeState;
        if (saved == null ||
            state == null ||
            state.version != 1 ||
            state.family != family ||
            state.ownerKey != owner ||
            state.criteriaDigest != criteria ||
            state.metadataVectorDigest != vector ||
            state.activityCommandId != parent ||
            state.timezoneIdentity != _occurrenceTimezoneIdentity ||
            saved.scopeKey != actor.scopeKey ||
            saved.principalId != actor.principalId ||
            saved.policyRevision != actor.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != pageSize ||
            !saved.expiresAt.isAfter(now) ||
            saved.fieldGroups.isNotEmpty ||
            saved.eventCalendarId != null ||
            saved.eventFieldGroups != null ||
            saved.taskCalendarId != null ||
            saved.taskFieldGroups != null ||
            saved.incomingPublicationState != null ||
            saved.eventOccurrenceState != null ||
            saved.categoryFilter != null ||
            saved.alarmActivityId != null ||
            saved.alarmActivityKind != null ||
            saved.taskHistoryTaskId != null ||
            saved.taskHistoryOriginalKey != null ||
            saved.taskHistoryAfterRevision != null) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final visible = <(UuidValue, Object)>[];
      Future<bool> allowed(
        CalendarFreeBusyExchangePolicyContext context,
      ) async {
        try {
          await _fbAuthorize(context, tx, CalendarAuthorizationPhase.read);
          return true;
        } on CalendarException catch (e) {
          if (e.code == CalendarFailureCode.accessDenied) return false;
          rethrow;
        }
      }

      bool later(UuidValue id) =>
          after == null || id.toString().compareTo(after.toString()) > 0;
      for (final source in sources) {
        if (!later(source.id!) ||
            source.payload == null ||
            source.header == null ||
            source.purgedAt != null ||
            !source.expiresAt.isAfter(now)) {
          continue;
        }
        if (await allowed(
          _fbSourceContext(
            actor,
            source,
            CalendarFreeBusyExchangeOperation.readHeader,
          ),
        )) {
          visible.add((source.id!, await _fbMessageView(source, tx)));
        }
        if (visible.length > pageSize) break;
      }
      for (final command
          in family == 'outgoing'
              ? commands
              : <CalendarFreeBusyCommandRecord>[]) {
        if (!later(command.id!) || command.scrubbedAt != null) continue;
        if (await allowed(
          CalendarFreeBusyExchangePolicyContext(
            operation: CalendarFreeBusyExchangeOperation.readOutgoing,
            mailbox: _fbCommandMailbox(command),
            scopeKey: actor.scopeKey,
            ownerKey: owner,
            actor: actor,
            commandId: command.id,
            payloadDigest: command.payloadDigest,
            message: command.payload == null
                ? null
                : _fbParse(command.payload!),
          ),
        )) {
          visible.add((
            command.id!,
            CalendarFreeBusyOutgoingView(
              id: command.id!,
              commandId: command.commandId,
              method: command.method,
              stamp: command.stamp,
              expiresAt: command.expiresAt,
              terminalAt: command.terminalAt,
            ),
          ));
        }
        if (visible.length > pageSize) break;
      }
      for (final delivery in deliveries) {
        if (!later(delivery.id!)) continue;
        if (await allowed(
          CalendarFreeBusyExchangePolicyContext(
            operation: CalendarFreeBusyExchangeOperation.readActivity,
            scopeKey: actor.scopeKey,
            ownerKey: owner,
            actor: actor,
            commandId: parent,
            route:
                delivery.recipientAddress == null || delivery.routeRef == null
                ? null
                : CalendarSchedulingRoute(
                    delivery.recipientAddress!,
                    delivery.routeRef!,
                  ),
          ),
        )) {
          visible.add((
            delivery.id!,
            CalendarFreeBusyDeliveryView(
              id: delivery.id!,
              commandId: delivery.commandId,
              state: delivery.state,
              attemptCount: delivery.attemptCount,
              expiresAt: delivery.expiresAt,
              terminalAt: delivery.terminalAt,
            ),
          ));
        }
        if (visible.length > pageSize) break;
      }
      if (await _fbOwner(actor, tx, CalendarAuthorizationPhase.read) != owner) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _verifyContext(actor);
      String? continuation;
      if (visible.length > pageSize) {
        visible.removeLast();
        await CalendarCursorRecord.db.deleteWhere(
          _session,
          where: (t) => t.scopeKey.equals(actor.scopeKey) & (t.expiresAt < now),
          transaction: tx,
        );
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(actor.scopeKey),
              transaction: tx,
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
            afterId: visible.last.$1,
            pageSize: pageSize,
            fieldGroups: [],
            freeBusyExchangeState: CalendarFreeBusyExchangeCursorState(
              version: 1,
              family: family,
              ownerKey: owner,
              criteriaDigest: criteria,
              metadataVectorDigest: vector,
              timezoneIdentity: _occurrenceTimezoneIdentity,
              activityCommandId: parent,
            ),
            expiresAt: now.add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return (visible.map((v) => v.$2).toList(), continuation);
    });
  }
}
