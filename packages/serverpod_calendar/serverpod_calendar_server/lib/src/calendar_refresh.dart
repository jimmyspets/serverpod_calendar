part of 'calendar_module.dart';

const _refreshPerMeeting = 64;
const _refreshPerScope = 2048;
const _refreshPending = 16;
const _refreshExpiry = Duration(days: 7);
const _refreshRetention = Duration(days: 30);

extension CalendarEventRefresh on CalendarService {
  CalendarRefreshHost get _refresh =>
      _scheduling.refresh ?? (throw _failure(CalendarFailureCode.unavailable));

  Future<void> _refreshHostDecision(
    Future<CalendarAuthorizationVerdict> Function() decide,
  ) async {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _refresh.guarantee != CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final verdict = await _bounded(decide);
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  Future<CalendarSchedulingMeetingRecord> _refreshMeeting(
    _Event event,
    String scope,
    Transaction tx,
  ) async {
    final meeting = await _meeting(event.identity.id!, tx);
    if (meeting == null ||
        meeting.scopeKey != scope ||
        meeting.calendarId != event.identity.calendarId ||
        event.data.origin != CalendarEventOrigin.native ||
        event.data.importBaseline != null ||
        _schedulingRecurring(event.data.content)) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return meeting;
  }

  _SchedulingCheckpoint _refreshPublished(
    _Event event,
    CalendarSchedulingMeetingRecord meeting,
    CalendarSchedulingPublicationRecord publication,
    String attendee,
  ) {
    if (publication.scopeKey != meeting.scopeKey ||
        publication.meetingId != meeting.id ||
        publication.protocolUid != event.data.protocolUid ||
        publication.method != 'REQUEST' ||
        !publication.recipients.contains(attendee)) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final checkpoint = _schedulingReadCheckpoint(publication);
    if (checkpoint.kind != CalendarSchedulingPublicationKind.request ||
        checkpoint.canonical.eventId != event.identity.id ||
        checkpoint.canonical.calendarId != event.identity.calendarId ||
        _schedulingRecurring(checkpoint.outgoing.content) ||
        checkpoint.message.events.single.participants.organizer?.address !=
            meeting.organizerAddress) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return checkpoint;
  }

  Future<UuidValue> _receiveEventRefresh(CalendarRefreshDelivery input) async {
    final host = _refresh;
    for (final value in [
      input.scopeKey,
      input.namespace,
      input.deliveryKey,
      input.originReference,
    ]) {
      _schedulingValue(
        () => validateCalendarOpaqueText(value, maxUtf8Bytes: 512),
      );
    }
    final message = _schedulingValue(
      () => parseIcalendarSchedulingMessage(
        input.bytes,
        syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 32768),
      ),
    );
    if (message.method != IcalendarSchedulingMethod.refresh) {
      throw _failure(CalendarFailureCode.validation);
    }
    final source = message.events.single;
    final attendee = source.participants.attendees.single;
    if (source.isOverride ||
        attendee.sentBy != null ||
        attendee.delegatedFrom.isNotEmpty ||
        attendee.delegatedTo.isNotEmpty ||
        source.participants.organizer?.sentBy != null) {
      throw _failure(CalendarFailureCode.validation);
    }
    final comments = source.source.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((entry) => entry.canonicalName == 'COMMENT')
        .map((entry) => decodeIcalendarText(entry.value))
        .toList();
    final digest = sha256.convert(input.bytes).toString();
    return _scopeTransaction(input.scopeKey, (tx, _) async {
      final event = await _eventInScope(input.scopeKey, input.eventId, tx);
      final meeting = await _refreshMeeting(event, input.scopeKey, tx);
      if (message.uid != event.data.protocolUid ||
          source.participants.organizer?.address != meeting.organizerAddress) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      Future<void> check(CalendarAuthorizationPhase phase) =>
          _refreshHostDecision(
            () => host.authorizeReceipt(
              _session,
              input,
              event.snapshot,
              attendee.address,
              tx,
              phase,
            ),
          );
      await check(CalendarAuthorizationPhase.preliminaryWrite);
      final prior = await CalendarRefreshRequestRecord.db.findFirstRow(
        _session,
        where: (row) =>
            row.scopeKey.equals(input.scopeKey) &
            row.namespace.equals(input.namespace) &
            row.deliveryKey.equals(input.deliveryKey),
        transaction: tx,
      );
      if (prior != null) {
        if (prior.meetingId != meeting.id ||
            prior.attendeeAddress != attendee.address ||
            prior.sourceDigest != digest ||
            prior.originReference != input.originReference) {
          throw _failure(CalendarFailureCode.validation);
        }
        await check(CalendarAuthorizationPhase.finalWrite);
        return prior.id!;
      }
      _refreshPublished(
        event,
        meeting,
        (await _latest(meeting, tx))!,
        attendee.address,
      );
      if (event.data.content.status == CalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _refreshCapacity(input.scopeKey, meeting.id!, tx);
      final now = await _revisionTime(tx);
      final row = await CalendarRefreshRequestRecord.db.insertRow(
        _session,
        CalendarRefreshRequestRecord(
          scopeKey: input.scopeKey,
          meetingId: meeting.id!,
          namespace: input.namespace,
          deliveryKey: input.deliveryKey,
          originReference: input.originReference,
          sourceDigest: digest,
          attendeeAddress: attendee.address,
          sourceStamp: source.stamp,
          comments: comments,
          receivedAt: now,
          expiresAt: now.add(_refreshExpiry),
        ),
        transaction: tx,
      );
      await check(CalendarAuthorizationPhase.finalWrite);
      return row.id!;
    });
  }

  Future<void> _refreshCapacity(
    String scope,
    UuidValue meetingId,
    Transaction tx, {
    bool resend = false,
  }) async {
    final scoped = resend
        ? await CalendarRefreshResendRecord.db.count(
            _session,
            where: (row) => row.scopeKey.equals(scope),
            transaction: tx,
            limit: _refreshPerScope,
          )
        : await CalendarRefreshRequestRecord.db.count(
            _session,
            where: (row) => row.scopeKey.equals(scope),
            transaction: tx,
            limit: _refreshPerScope,
          );
    final bound = resend
        ? await CalendarRefreshResendRecord.db.count(
            _session,
            where: (row) => row.meetingId.equals(meetingId),
            transaction: tx,
            limit: _refreshPerMeeting,
          )
        : await CalendarRefreshRequestRecord.db.count(
            _session,
            where: (row) => row.meetingId.equals(meetingId),
            transaction: tx,
            limit: _refreshPerMeeting,
          );
    if (scoped >= _refreshPerScope || bound >= _refreshPerMeeting) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    if (resend &&
        await CalendarRefreshResendRecord.db.count(
              _session,
              where: (row) =>
                  row.scopeKey.equals(scope) & row.terminalAt.equals(null),
              transaction: tx,
              limit: _refreshPending,
            ) >=
            _refreshPending) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  Future<void> _refreshAuthorize(
    CalendarHostContext actor,
    _Event event,
    CalendarPermission operation,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) => _schedulingAuthorize(
    actor,
    [
      ..._schedulingRequests(event, null, write: false),
      CalendarAuthorizationRequest(
        key: operation.name,
        operation: operation,
        calendarId: event.identity.calendarId,
        current: event.parent.snapshot,
        eventId: event.identity.id,
        currentEvent: event.snapshot,
        eventGroups: CalendarEventFieldGroup.values,
      ),
    ],
    tx,
    phase,
  );

  Future<CalendarRefreshRequestRecord> _refreshRequest(
    CalendarSchedulingMeetingRecord meeting,
    UuidValue id,
    Transaction tx,
  ) async {
    final row = await CalendarRefreshRequestRecord.db.findById(
      _session,
      id,
      transaction: tx,
    );
    if (row == null ||
        row.scopeKey != meeting.scopeKey ||
        row.meetingId != meeting.id) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return row;
  }

  Future<CalendarRefreshPage> listEventRefresh(
    UuidValue eventId,
    int pageSize,
    String? cursor,
  ) async {
    final host = _refresh;
    if (pageSize < 1 ||
        pageSize > 32 ||
        cursor != null && !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
      throw _failure(CalendarFailureCode.invalidCursor);
    }
    final actor = await _context();
    return _transaction(actor, (tx, scope) async {
      final event = await _event(actor, eventId, tx);
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.reviewEventRefresh,
        tx,
        CalendarAuthorizationPhase.read,
      );
      final meeting = await _refreshMeeting(event, actor.scopeKey, tx);
      final latest = (await _latest(meeting, tx))!;
      final now = await _revisionTime(tx);
      final rows = await CalendarRefreshRequestRecord.db.find(
        _session,
        where: (row) =>
            row.scopeKey.equals(actor.scopeKey) &
            row.meetingId.equals(meeting.id!) &
            (row.expiresAt > now),
        orderBy: (row) => row.id,
        limit: _refreshPerMeeting + 1,
        transaction: tx,
      );
      final resends = await CalendarRefreshResendRecord.db.find(
        _session,
        where: (row) =>
            row.scopeKey.equals(actor.scopeKey) &
            row.meetingId.equals(meeting.id!),
        limit: _refreshPerMeeting + 1,
        transaction: tx,
      );
      if (rows.length > _refreshPerMeeting ||
          resends.length > _refreshPerMeeting) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final byRequest = {
        for (final resend in resends) resend.requestId: resend.state,
      };
      final policyKey = _schedulingDigest(
        jsonEncode([
          'event-refresh-v1',
          actor.policyRevision,
          host.guarantee.name,
          _runtime.policy.guarantee.name,
          eventId.toString(),
          latest.generation,
          for (final row in rows)
            [
              row.id.toString(),
              row.dismissedAt?.toIso8601String(),
              byRequest[row.id]?.name,
            ],
        ]),
      );
      var start = 0;
      if (cursor != null) {
        final stored = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (row) =>
              row.token.equals(cursor) &
              row.scopeKey.equals(actor.scopeKey) &
              row.principalId.equals(actor.principalId),
          transaction: tx,
        );
        if (stored == null ||
            stored.policyRevision != policyKey ||
            stored.dataRevision != scope.revision ||
            stored.pageSize != pageSize ||
            !stored.expiresAt.isAfter(now)) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        start = rows.indexWhere((row) => row.id == stored.afterId) + 1;
        if (start == 0) throw _failure(CalendarFailureCode.invalidCursor);
      }
      final selected = rows.skip(start).take(pageSize).toList();
      String? next;
      if (start + selected.length < rows.length) {
        final expired = await CalendarCursorRecord.db.find(
          _session,
          where: (row) =>
              row.scopeKey.equals(actor.scopeKey) & (row.expiresAt <= now),
          limit: _options.maxCursorsPerScope,
          transaction: tx,
        );
        if (expired.isNotEmpty) {
          await CalendarCursorRecord.db.delete(
            _session,
            expired,
            transaction: tx,
          );
        }
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (row) => row.scopeKey.equals(actor.scopeKey),
              limit: _options.maxCursorsPerScope,
              transaction: tx,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final random = Random.secure();
        next = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))
            .replaceAll('=', '');
        await CalendarCursorRecord.db.insertRow(
          _session,
          CalendarCursorRecord(
            token: next,
            scopeKey: actor.scopeKey,
            principalId: actor.principalId,
            policyRevision: policyKey,
            dataRevision: scope.revision,
            afterId: selected.last.id!,
            pageSize: pageSize,
            fieldGroups: [],
            expiresAt: now.add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.reviewEventRefresh,
        tx,
        CalendarAuthorizationPhase.read,
      );
      return CalendarRefreshPage(
        entries: [
          for (final row in selected)
            CalendarRefreshView(
              requestId: row.id!,
              attendeeAddress: row.attendeeAddress,
              sourceStamp: row.sourceStamp,
              comments: row.comments,
              receivedAt: row.receivedAt,
              expiresAt: row.expiresAt,
              dismissedAt: row.dismissedAt,
              resendState: byRequest[row.id],
            ),
        ],
        publicationId: latest.method == 'REQUEST' ? latest.id : null,
        generation: latest.method == 'REQUEST' ? latest.generation : null,
        nextCursor: next,
      );
    });
  }

  Future<void> dismissEventRefresh(
    UuidValue eventId,
    UuidValue requestId,
  ) async {
    _refresh;
    final actor = await _context();
    await _transaction(actor, (tx, _) async {
      final event = await _event(actor, eventId, tx);
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.dismissEventRefresh,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final meeting = await _refreshMeeting(event, actor.scopeKey, tx);
      final request = await _refreshRequest(meeting, requestId, tx);
      final now = await _revisionTime(tx);
      if (!request.expiresAt.isAfter(now)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (request.dismissedAt == null) {
        request.dismissedAt = now;
        await CalendarRefreshRequestRecord.db.updateRow(
          _session,
          request,
          transaction: tx,
        );
      }
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.dismissEventRefresh,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
    });
  }

  CalendarSchedulingPolicyContext _refreshContext(
    _Event event,
    CalendarSchedulingPublicationRecord publication,
    _SchedulingCheckpoint checkpoint,
    CalendarSchedulingAuthority authority, {
    CalendarHostContext? actor,
  }) => CalendarSchedulingPolicyContext(
    scopeKey: publication.scopeKey,
    actor: actor,
    calendar: event.parent.snapshot,
    currentEvent: event.snapshot,
    proposedEvent: event.snapshot,
    publicationEvent: checkpoint.canonical,
    outgoingMessage: checkpoint.message,
    payloadDigest: publication.payloadDigest,
    authority: authority,
    recipient: authority.routes.single,
    intent: CalendarSchedulingIntent(
      organizerAddress: authority.organizerAddress,
      recipients: [authority.routes.single.address],
      payload: publication.payload,
      publicationId: publication.id,
      generation: publication.generation,
    ),
  );

  Future<CalendarRefreshResendReceipt> resendEventRefresh(
    CalendarRefreshResendCommand command,
  ) async {
    final host = _refresh;
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final event = await _event(actor, command.eventId, tx);
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.resendEventRefresh,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final meeting = await _refreshMeeting(event, actor.scopeKey, tx);
      final request = await _refreshRequest(meeting, command.requestId, tx);
      final prior = await CalendarRefreshResendRecord.db.findFirstRow(
        _session,
        where: (row) =>
            row.scopeKey.equals(actor.scopeKey) &
            row.commandId.equals(command.commandId),
        transaction: tx,
      );
      if (prior != null &&
          (prior.actorId != actor.principalId ||
              prior.requestId != request.id ||
              prior.meetingId != meeting.id ||
              prior.publicationId != command.publicationId ||
              prior.generation != command.generation ||
              prior.recipientAddress != request.attendeeAddress)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final publication = prior == null
          ? (await _latest(meeting, tx))!
          : (await CalendarSchedulingPublicationRecord.db.findById(
                  _session,
                  prior.publicationId,
                  transaction: tx,
                ) ??
                (throw _failure(CalendarFailureCode.unavailable)));
      if (publication.id != command.publicationId ||
          publication.generation != command.generation) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final checkpoint = _refreshPublished(
        event,
        meeting,
        publication,
        request.attendeeAddress,
      );
      final recipients = [request.attendeeAddress];
      Future<CalendarSchedulingAuthority> resolve() async =>
          _schedulingAuthority(
            await _bounded(
              () => _scheduling.host.resolve(
                _session,
                actor,
                event.snapshot,
                recipients,
                tx,
              ),
            ),
            recipients,
          );
      final authority = await resolve();
      if (authority.organizerAddress != meeting.organizerAddress ||
          authority.authorityRef != meeting.authorityRef ||
          prior != null &&
              (prior.routeRef != authority.routes.single.routeRef ||
                  prior.payloadDigest != publication.payloadDigest)) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final context = _refreshContext(
        event,
        publication,
        checkpoint,
        authority,
        actor: actor,
      );
      Future<void> check(CalendarAuthorizationPhase phase) =>
          _refreshHostDecision(
            () => host.authorizeResend(
              _session,
              context,
              request.originReference,
              tx,
              phase,
            ),
          );
      await check(CalendarAuthorizationPhase.preliminaryWrite);
      var result = prior;
      if (result == null) {
        final now = await _revisionTime(tx);
        final original = await CalendarSchedulingDeliveryRecord.db.findFirstRow(
          _session,
          where: (row) =>
              row.publicationId.equals(publication.id!) &
              row.recipientAddress.equals(request.attendeeAddress),
          transaction: tx,
        );
        if (original?.terminalAt == null ||
            original!.scopeKey != actor.scopeKey ||
            event.data.content.status == CalendarEventStatus.cancelled ||
            !request.expiresAt.isAfter(now) ||
            request.dismissedAt != null ||
            await CalendarRefreshResendRecord.db.count(
                  _session,
                  where: (row) => row.requestId.equals(request.id!),
                  transaction: tx,
                ) !=
                0) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
        await _refreshCapacity(actor.scopeKey, meeting.id!, tx, resend: true);
        result = await CalendarRefreshResendRecord.db.insertRow(
          _session,
          CalendarRefreshResendRecord(
            scopeKey: actor.scopeKey,
            meetingId: meeting.id!,
            requestId: request.id!,
            commandId: command.commandId,
            actorId: actor.principalId,
            publicationId: publication.id!,
            generation: publication.generation,
            payloadDigest: publication.payloadDigest,
            recipientAddress: request.attendeeAddress,
            routeRef: authority.routes.single.routeRef,
            createdAt: now,
            expiresAt: now.add(_refreshExpiry),
            nextAttemptAt: now,
          ),
          transaction: tx,
        );
      }
      if (_schedulingAuthorityKey(await resolve()) !=
          _schedulingAuthorityKey(authority)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await check(CalendarAuthorizationPhase.finalWrite);
      await _refreshAuthorize(
        actor,
        event,
        CalendarPermission.resendEventRefresh,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      return CalendarRefreshResendReceipt(
        resendId: result.id!,
        state: result.state,
        unchanged: prior != null,
      );
    });
  }
}
