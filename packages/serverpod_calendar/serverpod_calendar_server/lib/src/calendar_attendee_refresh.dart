part of 'calendar_module.dart';

const _attendeeRefreshExpiry = Duration(days: 7);
const _attendeeRefreshRetention = Duration(days: 30);

extension CalendarAttendeeRefreshOperations on CalendarService {
  CalendarAttendeeRefreshRuntime get _arRuntime =>
      _invitations.attendeeRefresh ??
      (throw _failure(CalendarFailureCode.unavailable));

  void _arProfile(CalendarInvitationRecord entry) {
    if (entry.recurring ||
        entry.originalStart != null ||
        entry.targetKey != 'master') {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  IcalendarSchedulingMessage _arSource(
    CalendarInvitationSourceRecord row,
    CalendarInvitationRecord entry,
    CalendarInvitationRecipient recipient,
  ) {
    final message = _invStored(row, entry);
    if (message.method != IcalendarSchedulingMethod.request ||
        message.events.length != 1) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final source = message.events.single;
    final attendees = source.participants.attendees
        .where((item) => item.address == recipient.calendarAddress)
        .toList();
    if (source.isOverride ||
        source.recurrence != null ||
        attendees.length != 1 ||
        source.participants.organizer?.sentBy != null ||
        attendees.single.sentBy != null ||
        attendees.single.participationStatus == 'DELEGATED' ||
        attendees.single.delegatedFrom.isNotEmpty ||
        attendees.single.delegatedTo.isNotEmpty) {
      throw _failure(CalendarFailureCode.validation);
    }
    return message;
  }

  Future<void> _arAuthorize(
    CalendarAttendeeRefreshContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    _invGuarantee();
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _arRuntime.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final verdict = await _bounded(
      () => _arRuntime.host.authorize(_session, context, tx, phase),
    );
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  Future<CalendarAttendeeRefreshContext> _arContext(
    CalendarAttendeeRefreshOperation operation,
    CalendarInvitationRecord entry,
    CalendarInvitationRecipient recipient,
    Transaction tx, {
    CalendarHostContext? actor,
    CalendarInvitationSourceRecord? source,
    int? revision,
    IcalendarSchedulingMessage? outgoing,
    String? payloadDigest,
    CalendarInvitationResponseAuthority? authority,
    bool retry = false,
  }) async => CalendarAttendeeRefreshContext(
    operation: operation,
    recipient: recipient,
    invitation: await _invView(entry, tx),
    actor: actor,
    sourceId: source?.id,
    sourceRevision: revision,
    sourceDigest: source?.digest,
    sourceMessage: source == null ? null : _arSource(source, entry, recipient),
    outgoingMessage: outgoing,
    payloadDigest: payloadDigest,
    authority: authority,
    isRetry: retry,
  );

  String _arPayload(
    IcalendarSchedulingMessage source,
    CalendarInvitationResponseAuthority authority,
    DateTime stamp,
  ) => _schedulingValue(() {
    final document = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty(
          'PRODID',
          '-//Serverpod Calendar//Attendee Refresh//EN',
        ),
        IcalendarSyntaxProperty('METHOD', 'REFRESH'),
        IcalendarSyntaxComponent('VEVENT', [
          IcalendarSyntaxProperty('UID', encodeIcalendarText(source.uid)),
          IcalendarSyntaxProperty('DTSTAMP', EventComponentWriter().utc(stamp)),
          IcalendarSyntaxProperty('ORGANIZER', authority.organizer.address),
          IcalendarSyntaxProperty('ATTENDEE', authority.attendeeAddress),
        ]),
      ]),
    ]);
    const limits = IcalendarSyntaxLimits(maxBytes: 32768);
    final bytes = serializeIcalendarSyntax(document, limits: limits);
    parseIcalendarSchedulingMessage(bytes, syntaxLimits: limits);
    return utf8.decode(bytes);
  });

  CalendarInvitationResponseAuthority _arStoredAuthority(
    CalendarAttendeeRefreshRecord row,
  ) => CalendarInvitationResponseAuthority(
    attendeeAddress: row.attendeeAddress,
    authorityRef: row.authorityRef,
    organizer: CalendarSchedulingRoute(row.organizerAddress, row.routeRef),
  );

  IcalendarSchedulingMessage _arStoredOutgoing(
    CalendarAttendeeRefreshRecord row,
    CalendarInvitationSourceRecord source,
    CalendarInvitationRecord entry,
    CalendarInvitationRecipient recipient,
  ) {
    final authority = _arStoredAuthority(row);
    final basis = _arSource(source, entry, recipient);
    _irAuthority(authority, recipient, basis);
    if (row.scopeKey != recipient.scopeKey ||
        row.recipientKey != recipient.key ||
        row.entryId != entry.id ||
        row.sourceId != source.id ||
        row.sourceDigest != source.digest ||
        row.sourceSequence != source.sequence ||
        row.sourceStamp != source.stamp ||
        row.sourceRevision < 1 ||
        row.sourceRevision > entry.revision ||
        row.payloadDigest != _schedulingDigest(row.payload) ||
        !row.stamp.isUtc ||
        row.stamp != eventProtocolInstant(row.stamp) ||
        row.payload != _arPayload(basis, authority, row.stamp)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return parseIcalendarSchedulingMessage(
      utf8.encode(row.payload),
      syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 32768),
    );
  }

  CalendarAttendeeRefreshView _arView(
    CalendarAttendeeRefreshRecord? row,
    bool canRequest, {
    bool unchanged = false,
  }) => CalendarAttendeeRefreshView(
    deliveryId: row?.id,
    state: row?.state,
    canRequest: canRequest && (row == null || row.terminalAt != null),
    unchanged: unchanged,
  );

  Future<CalendarAttendeeRefreshView> attendeeRefresh(UuidValue id) =>
      _invNative((actor, recipient, tx) async {
        final entry = await _invEntry(id, recipient, tx);
        _arProfile(entry);
        await _irSourceRead(actor, recipient, entry, null, tx);
        final history = await CalendarAttendeeRefreshRecord.db.find(
          _session,
          where: (row) =>
              row.scopeKey.equals(recipient.scopeKey) &
              row.recipientKey.equals(recipient.key) &
              row.entryId.equals(id),
          limit: 33,
          transaction: tx,
        );
        if (history.length > 32) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        history.sort((a, b) {
          if ((a.terminalAt == null) != (b.terminalAt == null)) {
            return a.terminalAt == null ? -1 : 1;
          }
          final created = b.createdAt.compareTo(a.createdAt);
          return created != 0
              ? created
              : b.id!.toString().compareTo(a.id!.toString());
        });
        final latest = history.firstOrNull;
        final sourceId =
            latest?.sourceId ??
            (entry.kind == CalendarInvitationSourceKind.request
                ? entry.currentSourceId
                : null);
        final source = sourceId == null
            ? null
            : await _irSource(sourceId, entry, tx);
        if (source != null) {
          await _irSourceRead(actor, recipient, entry, source, tx);
        }
        final outgoing = latest == null
            ? null
            : _arStoredOutgoing(latest, source!, entry, recipient);
        await _arAuthorize(
          await _arContext(
            CalendarAttendeeRefreshOperation.read,
            entry,
            recipient,
            tx,
            actor: actor,
            source: source,
            revision: latest?.sourceRevision ?? entry.revision,
            outgoing: outgoing,
            payloadDigest: latest?.payloadDigest,
            authority: latest == null ? null : _arStoredAuthority(latest),
          ),
          tx,
          CalendarAuthorizationPhase.read,
        );
        final currentId = entry.currentSourceId;
        final canRequest =
            entry.kind == CalendarInvitationSourceKind.request &&
            currentId != null &&
            (latest == null || latest.terminalAt != null);
        if (canRequest && currentId != sourceId) {
          final current = await _irSource(currentId, entry, tx);
          await _irSourceRead(actor, recipient, entry, current, tx);
          await _arAuthorize(
            await _arContext(
              CalendarAttendeeRefreshOperation.read,
              entry,
              recipient,
              tx,
              actor: actor,
              source: current,
              revision: entry.revision,
            ),
            tx,
            CalendarAuthorizationPhase.read,
          );
        }
        return _arView(latest, canRequest);
      });

  Future<CalendarAttendeeRefreshView> requestAttendeeRefresh(
    CalendarAttendeeRefreshCommand input,
  ) {
    final command = input.copyWith();
    return _invNative((actor, recipient, tx) async {
      final entry = await _invEntry(command.invitationId, recipient, tx);
      _arProfile(entry);
      await _irSourceRead(actor, recipient, entry, null, tx);
      await _arAuthorize(
        await _arContext(
          CalendarAttendeeRefreshOperation.read,
          entry,
          recipient,
          tx,
          actor: actor,
        ),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final prior = await CalendarAttendeeRefreshRecord.db.findFirstRow(
        _session,
        where: (row) =>
            row.scopeKey.equals(recipient.scopeKey) &
            row.recipientKey.equals(recipient.key) &
            row.commandId.equals(command.commandId),
        transaction: tx,
      );
      if (prior != null &&
          (prior.entryId != entry.id ||
              prior.actorId != actor.principalId ||
              prior.sourceRevision != command.expectedInvitationRevision)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (prior == null &&
          entry.revision != command.expectedInvitationRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final sourceId = prior?.sourceId ?? entry.currentSourceId;
      if (sourceId == null ||
          prior == null && entry.kind != CalendarInvitationSourceKind.request) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final source = await _irSource(sourceId, entry, tx);
      await _irSourceRead(
        actor,
        recipient,
        entry,
        source,
        tx,
        retry: prior != null,
        phase: CalendarAuthorizationPhase.preliminaryWrite,
      );
      final basis = _arSource(source, entry, recipient);
      final initial = await _arContext(
        CalendarAttendeeRefreshOperation.send,
        entry,
        recipient,
        tx,
        source: source,
        revision: command.expectedInvitationRevision,
        actor: actor,
        retry: prior != null,
      );
      Future<CalendarInvitationResponseAuthority> resolve() async =>
          _irAuthority(
            await _bounded(
              () => _arRuntime.host.resolve(_session, initial, tx),
            ),
            recipient,
            basis,
          );
      final authority = await resolve();
      Object key(CalendarInvitationResponseAuthority value) => jsonEncode([
        value.attendeeAddress,
        value.authorityRef,
        value.organizer.address,
        value.organizer.routeRef,
      ]);
      if (prior != null && key(_arStoredAuthority(prior)) != key(authority)) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final now = await _revisionTime(tx);
      final stamp = prior?.stamp ?? eventProtocolInstant(now);
      final payload = prior?.payload ?? _arPayload(basis, authority, stamp);
      final digest = _schedulingDigest(payload);
      final outgoing = prior == null
          ? parseIcalendarSchedulingMessage(
              utf8.encode(payload),
              syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 32768),
            )
          : _arStoredOutgoing(prior, source, entry, recipient);
      final context = await _arContext(
        CalendarAttendeeRefreshOperation.send,
        entry,
        recipient,
        tx,
        actor: actor,
        source: source,
        revision: command.expectedInvitationRevision,
        outgoing: outgoing,
        payloadDigest: digest,
        authority: authority,
        retry: prior != null,
      );
      await _arAuthorize(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      var saved = prior;
      if (saved == null) {
        await _arCapacity(recipient, entry.id!, tx);
        saved = await CalendarAttendeeRefreshRecord.db.insertRow(
          _session,
          CalendarAttendeeRefreshRecord(
            scopeKey: recipient.scopeKey,
            recipientKey: recipient.key,
            entryId: entry.id!,
            commandId: command.commandId,
            actorId: actor.principalId,
            sourceId: source.id!,
            sourceRevision: entry.revision,
            sourceDigest: source.digest,
            sourceSequence: source.sequence,
            sourceStamp: source.stamp,
            attendeeAddress: authority.attendeeAddress,
            organizerAddress: authority.organizer.address,
            authorityRef: authority.authorityRef,
            routeRef: authority.organizer.routeRef,
            payload: payload,
            payloadDigest: digest,
            stamp: stamp,
            createdAt: now,
            expiresAt: now.add(_attendeeRefreshExpiry),
            nextAttemptAt: now,
          ),
          transaction: tx,
        );
      }
      if (key(await resolve()) != key(authority)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _irSourceRead(
        actor,
        recipient,
        entry,
        source,
        tx,
        retry: prior != null,
        phase: CalendarAuthorizationPhase.finalWrite,
      );
      await _arAuthorize(context, tx, CalendarAuthorizationPhase.finalWrite);
      return _arView(
        saved,
        false,
        unchanged: prior != null,
      );
    });
  }

  Future<void> _arCapacity(
    CalendarInvitationRecipient recipient,
    UuidValue entryId,
    Transaction tx,
  ) async {
    final records = await CalendarAttendeeRefreshRecord.db.find(
      _session,
      where: (row) =>
          row.scopeKey.equals(recipient.scopeKey) &
          row.recipientKey.equals(recipient.key),
      limit: 512,
      transaction: tx,
    );
    if (records.any(
      (row) => row.entryId == entryId && row.terminalAt == null,
    )) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
    if (records.length >= 512 ||
        records.where((row) => row.entryId == entryId).length >= 32 ||
        records.where((row) => row.terminalAt == null).length >= 16 ||
        await CalendarAttendeeRefreshRecord.db.count(
              _session,
              where: (row) => row.scopeKey.equals(recipient.scopeKey),
              limit: 4096,
              transaction: tx,
            ) >=
            4096) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }
}
