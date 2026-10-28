part of 'calendar_module.dart';

/// A current master target carried by a complete or partial publication row.
/// The checkpoint reader validates the whole retained message and its proof.
final class _ReplyMaster {
  _ReplyMaster(this.carrier) {
    checkpoint = _schedulingReadCheckpoint(carrier);
    final cancelled =
        checkpoint.kind == CalendarSchedulingPublicationKind.seriesCancel;
    final basis = checkpoint.basisRecord == null
        ? null
        : _schedulingReadCheckpoint(checkpoint.basisRecord!);
    message = cancelled
        ? checkpoint.message
        : checkpoint.fullRequestPayload != null
        ? _schedulingValue(
            () => parseIcalendarSchedulingMessage(
              utf8.encode(checkpoint.fullRequestPayload!),
            ),
          )
        : checkpoint.target != null
        ? (basis ?? (throw _failure(CalendarFailureCode.unavailable))).message
        : checkpoint.message;
    published = cancelled
        ? checkpoint.outgoing
        : checkpoint.target != null || checkpoint.fullRequestPayload != null
        ? (basis ?? (throw _failure(CalendarFailureCode.unavailable))).canonical
        : checkpoint.canonical;
    final masters = message.events.where((e) => !e.isOverride).toList();
    if (masters.length != 1 ||
        masters.single.sequence == null ||
        message.uid != carrier.protocolUid ||
        message.method !=
            (cancelled
                ? IcalendarSchedulingMethod.cancel
                : IcalendarSchedulingMethod.request)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    master = masters.single;
  }
  final CalendarSchedulingPublicationRecord carrier;
  late final _SchedulingCheckpoint checkpoint;
  late final IcalendarSchedulingMessage message;
  late final IcalendarSchedulingEvent master;
  late final CalendarEventPolicySnapshot published;
  int get sequence => master.sequence!;
  String get method =>
      message.method == IcalendarSchedulingMethod.cancel ? 'CANCEL' : 'REQUEST';
  UuidValue? get id => carrier.id;
  String get protocolUid => carrier.protocolUid;
  List<String> get recipients => carrier.recipients;
  bool get recurring => _schedulingRecurring(published.content);
}

CalendarSchedulingParticipation? _replyParticipation(String? value) =>
    switch (value?.toUpperCase()) {
      null => null,
      'NEEDS-ACTION' => CalendarSchedulingParticipation.needsAction,
      'ACCEPTED' => CalendarSchedulingParticipation.accepted,
      'DECLINED' => CalendarSchedulingParticipation.declined,
      'TENTATIVE' => CalendarSchedulingParticipation.tentative,
      _ => throw _failure(CalendarFailureCode.validation),
    };

IcalendarSchedulingMessage _replyMessage(List<int> bytes, int maxBytes) =>
    _schedulingValue(() {
      if (bytes.length > maxBytes) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final message = parseIcalendarSchedulingMessage(
        bytes,
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      );
      if (message.method != IcalendarSchedulingMethod.reply ||
          message.events.length != 1) {
        throw _failure(CalendarFailureCode.validation);
      }
      final event = message.events.single;
      if (event.isOverride ||
          event.isThisAndFuture ||
          event.participants.attendees.length != 1 ||
          event.participants.organizer == null) {
        throw _failure(CalendarFailureCode.validation);
      }
      final attendee = event.participants.attendees.single;
      if (attendee.sentBy != null ||
          attendee.delegatedFrom.isNotEmpty ||
          attendee.delegatedTo.isNotEmpty ||
          event.participants.organizer!.sentBy != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      _replyParticipation(attendee.participationStatus);
      return message;
    });

// Compare only supplied ordinary properties. Identity, response-owned data and
// independent source versions are checked separately. Never fill absent input.
bool _replyMatchesPublication(
  IcalendarSchedulingEvent reply,
  IcalendarSchedulingEvent published,
) {
  final suppliedNames = reply.source.entries
      .whereType<IcalendarSyntaxProperty>()
      .map((p) => p.canonicalName)
      .toSet();
  const recurrenceNames = {'RRULE', 'RDATE', 'EXDATE'};
  bool sameSet(Iterable<Object> a, Iterable<Object> b) {
    final left = a.toSet(), right = b.toSet();
    return left.length == right.length && left.containsAll(right);
  }

  final incoming = reply.recurrence, expected = published.recurrence;
  for (final name in suppliedNames.intersection(recurrenceNames)) {
    if (incoming == null || expected == null) return false;
    final date = incoming.dateSet, targetDate = expected.dateSet;
    final timed = incoming.timedSet, targetTimed = expected.timedSet;
    if ((date == null) != (targetDate == null)) return false;
    final matches = switch (name) {
      'RRULE' =>
        date != null
            ? date.rule == targetDate!.rule
            : timed!.rule == targetTimed!.rule,
      'EXDATE' =>
        date != null
            ? sameSet(date.exclusions, targetDate!.exclusions)
            : sameSet(timed!.exclusions, targetTimed!.exclusions),
      'RDATE' =>
        date != null
            ? sameSet(date.inclusions, targetDate!.inclusions)
            : sameSet(timed!.inclusions, targetTimed!.inclusions) &&
                  timed.periods.length == targetTimed.periods.length &&
                  timed.periods.entries.every(
                    (e) => targetTimed.periods[e.key] == e.value,
                  ),
      _ => false,
    };
    if (!matches) return false;
  }
  const independent = {
    'UID',
    'DTSTAMP',
    'SEQUENCE',
    'ORGANIZER',
    'ATTENDEE',
    'COMMENT',
    'REQUEST-STATUS',
  };
  Object key(IcalendarSyntaxProperty p) {
    final parameters = [...p.parameters]
      ..sort((a, b) => a.canonicalName.compareTo(b.canonicalName));
    final text = {
      'SUMMARY',
      'DESCRIPTION',
      'LOCATION',
      'CONTACT',
      'CATEGORIES',
    };
    return [
      p.canonicalName,
      if (text.contains(p.canonicalName))
        p.canonicalName == 'CATEGORIES'
            ? decodeIcalendarTextList(p.value)
            : decodeIcalendarText(p.value)
      else
        p.value,
      for (final parameter in parameters)
        if (!(parameter.canonicalName == 'VALUE' &&
            parameter.values.single.toUpperCase() == 'DATE-TIME'))
          [parameter.canonicalName, parameter.values],
    ];
  }

  final source = published.source.entries.whereType<IcalendarSyntaxProperty>();
  final grouped = <String, List<Object>>{};
  for (final p in source) {
    grouped.putIfAbsent(p.canonicalName, () => []).add(key(p));
  }
  final supplied = <String, List<Object>>{};
  for (final p in reply.source.entries.whereType<IcalendarSyntaxProperty>()) {
    if (!independent.contains(p.canonicalName) &&
        !recurrenceNames.contains(p.canonicalName)) {
      supplied.putIfAbsent(p.canonicalName, () => []).add(key(p));
    }
  }
  return supplied.entries.every(
    (e) => jsonEncode(e.value) == jsonEncode(grouped[e.key]),
  );
}

extension CalendarSchedulingReplies on CalendarService {
  CalendarSchedulingReplyRuntime get _replies =>
      _scheduling.replies ?? (throw _failure(CalendarFailureCode.unavailable));

  Future<void> _inactivateReplySources(
    CalendarSchedulingMeetingRecord meeting,
    CalendarSchedulingPublicationRecord publication,
    Transaction tx,
    DateTime now,
  ) async {
    // Runs on publication even when this process has no inbound adapter. The
    // retained ordering state must be consistent across differently configured hosts.
    final sources = await CalendarSchedulingReplySourceRecord.db.find(
      _session,
      where: (t) => t.meetingId.equals(meeting.id!) & t.inactiveAt.equals(null),
      limit: 65,
      transaction: tx,
    );
    if (sources.length > 64) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (sources.isEmpty) return;
    final target = _ReplyMaster(publication);
    for (final source in sources) {
      if (source.scopeKey != meeting.scopeKey) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (target.method == 'REQUEST' &&
          (source.sequence ?? 0) == target.sequence) {
        continue;
      }
      source.inactiveAt = now.isBefore(source.receivedAt)
          ? source.receivedAt
          : now;
      await CalendarSchedulingReplySourceRecord.db.updateRow(
        _session,
        source,
        transaction: tx,
      );
    }
  }

  Future<void> _cleanupReplies() async {
    final options = _replies.options;
    final parameters = QueryParameters.named({
      'seconds': options.retention.inSeconds,
      'limit': options.cleanupBatch,
    });
    final receipts = await _session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_scheduling_reply_receipt '
      'WHERE "receivedAt" < clock_timestamp()-(@seconds * interval \'1 second\') '
      'ORDER BY "receivedAt", id LIMIT @limit',
      parameters: parameters,
    );
    for (final row in receipts) {
      await _scopeTransaction(row[1].toString(), (tx, _) async {
        final receipt = await CalendarSchedulingReplyReceiptRecord.db.findById(
          _session,
          UuidValue.fromString(row[0].toString()),
          transaction: tx,
        );
        final now = await _revisionTime(tx);
        if (receipt != null &&
            receipt.scopeKey == row[1] &&
            receipt.receivedAt.isBefore(now.subtract(options.retention))) {
          await CalendarSchedulingReplyReceiptRecord.db.deleteRow(
            _session,
            receipt,
            transaction: tx,
          );
        }
      });
    }
    final sources = await _session.db.unsafeQuery(
      'SELECT id, "scopeKey" FROM serverpod_calendar_scheduling_reply_source '
      'WHERE "inactiveAt" < clock_timestamp()-(@seconds * interval \'1 second\') '
      'ORDER BY "inactiveAt", id LIMIT @limit',
      parameters: parameters,
    );
    for (final row in sources) {
      await _scopeTransaction(row[1].toString(), (tx, _) async {
        final source = await CalendarSchedulingReplySourceRecord.db.findById(
          _session,
          UuidValue.fromString(row[0].toString()),
          transaction: tx,
        );
        final now = await _revisionTime(tx);
        if (source == null ||
            source.scopeKey != row[1] ||
            source.inactiveAt == null ||
            !source.inactiveAt!.isBefore(now.subtract(options.retention))) {
          return;
        }
        final meeting = await CalendarSchedulingMeetingRecord.db.findById(
          _session,
          source.meetingId,
          transaction: tx,
        );
        final record = await _latest(meeting, tx);
        if (record == null || meeting == null) {
          return;
        }
        final publication = _ReplyMaster(record);
        _validateReplySource(source, meeting, publication);
        final response = await CalendarSchedulingAttendeeResponseRecord.db
            .findFirstRow(
              _session,
              where: (t) => t.sourceId.equals(source.id!),
              transaction: tx,
            );
        if (response != null &&
            publication.method == 'REQUEST' &&
            response.sequence == publication.sequence) {
          return;
        }
        final references = await CalendarSchedulingReplyReceiptRecord.db.find(
          _session,
          where: (t) => t.sourceId.equals(source.id!),
          limit: options.maxReceiptsPerBinding + 1,
          transaction: tx,
        );
        if (references.length > options.maxReceiptsPerBinding) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        references.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
        final reference = references.firstOrNull;
        if (reference != null) {
          if (reference.receivedAt.isAfter(source.inactiveAt!)) {
            source.inactiveAt = reference.receivedAt;
            await CalendarSchedulingReplySourceRecord.db.updateRow(
              _session,
              source,
              transaction: tx,
            );
          }
          return;
        }
        if (response != null) {
          await CalendarSchedulingAttendeeResponseRecord.db.deleteRow(
            _session,
            response,
            transaction: tx,
          );
        }
        await CalendarSchedulingReplySourceRecord.db.deleteRow(
          _session,
          source,
          transaction: tx,
        );
      });
    }
  }

  void _validateReplySource(
    CalendarSchedulingReplySourceRecord source,
    CalendarSchedulingMeetingRecord meeting,
    _ReplyMaster publication,
  ) {
    try {
      final decoded = _replyMessage(
        utf8.encode(source.normalizedSource),
        _replies.options.maxSourceBytes,
      );
      final event = decoded.events.single;
      final attendee = event.participants.attendees.single;
      final participation = _replyParticipation(attendee.participationStatus);
      if (source.id == null ||
          source.scopeKey != meeting.scopeKey ||
          source.meetingId != meeting.id ||
          event.uid != publication.protocolUid ||
          event.participants.organizer!.address != meeting.organizerAddress ||
          attendee.address != source.attendeeAddress ||
          !publication.recipients.contains(attendee.address) ||
          source.sequence != event.sequence ||
          source.stamp != event.stamp ||
          source.sourceParticipation != participation ||
          source.effectiveParticipation !=
              (participation ?? CalendarSchedulingParticipation.needsAction) ||
          source.digest != _schedulingDigest(source.normalizedSource) ||
          source.publishedSequence < 0 ||
          source.outcome == CalendarSchedulingReplyOutcome.duplicate ||
          source.receivedAt.isUtc == false ||
          source.inactiveAt?.isBefore(source.receivedAt) == true) {
        throw StateError('Invalid stored reply');
      }
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarSchedulingReplySourceView _replySourceView(
    CalendarSchedulingReplySourceRecord source,
    CalendarSchedulingAttendeeResponseRecord? response,
    _ReplyMaster publication,
  ) {
    if (response != null &&
        (response.scopeKey != source.scopeKey ||
            response.meetingId != source.meetingId ||
            response.attendeeAddress != source.attendeeAddress ||
            response.revision < 1 ||
            response.sourceId == source.id &&
                (response.sequence != (source.sequence ?? 0) ||
                    response.stamp != source.stamp ||
                    response.sourceParticipation !=
                        source.sourceParticipation ||
                    response.effectiveParticipation !=
                        source.effectiveParticipation ||
                    source.outcome !=
                        CalendarSchedulingReplyOutcome.applied))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return CalendarSchedulingReplySourceView(
      id: source.id!,
      attendeeAddress: source.attendeeAddress,
      sourceSequence: source.sequence,
      stamp: source.stamp,
      sourceParticipation: source.sourceParticipation,
      effectiveParticipation: source.effectiveParticipation,
      outcome: source.outcome,
      publishedSequence: source.publishedSequence,
      publishedCancelled: source.publishedCancelled,
      receivedAt: source.receivedAt,
      isCurrent:
          response?.sourceId == source.id &&
          publication.method == 'REQUEST' &&
          response?.sequence == publication.sequence,
    );
  }

  Future<void> _replyReadAccess(
    CalendarHostContext actor,
    _Event event,
    CalendarSchedulingMeetingRecord meeting,
    _ReplyMaster publication,
    Transaction tx, {
    CalendarSchedulingReplySourceRecord? source,
    bool sourceAccess = false,
    CalendarSchedulingAttendeeResponseRecord? response,
  }) async {
    final intent = CalendarSchedulingIntent(
      method: publication.carrier.method,
      publicationKind: publication.checkpoint.kind,
      originalStart: publication.checkpoint.target,
      organizerAddress: meeting.organizerAddress,
      recipients: publication.recipients,
      payload: publication.carrier.payload,
      publicationId: publication.id,
      generation: publication.carrier.generation,
    );
    await _schedulingAuthorize(
      actor,
      [
        ..._schedulingRequests(event, intent, write: false),
        for (final operation in [
          CalendarPermission.readSchedulingResponses,
          if (sourceAccess) CalendarPermission.readSchedulingReplySource,
        ])
          CalendarAuthorizationRequest(
            key: '${operation.name}:${source?.id ?? event.identity.id}',
            operation: operation,
            calendarId: event.parent.identity.id,
            current: event.parent.snapshot,
            eventId: event.identity.id,
            currentEvent: event.snapshot,
            scheduling: intent,
            schedulingReplySource: source == null
                ? null
                : _replySourceView(source, response, publication),
            schedulingReplyDocument: source?.normalizedSource,
            replyPublishedMessage: publication.message,
            replyPublishedMaster: publication.master,
          ),
      ],
      tx,
      CalendarAuthorizationPhase.read,
    );
  }

  Future<T> _replyRead<T>(
    UuidValue eventId,
    Future<T> Function(
      CalendarHostContext,
      _Event,
      CalendarSchedulingMeetingRecord,
      _ReplyMaster,
      Transaction,
    )
    action,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final event = await _event(actor, eventId, tx);
      final meeting = await _meeting(eventId, tx);
      final record = await _latest(meeting, tx);
      if (meeting == null ||
          record == null ||
          meeting.scopeKey != actor.scopeKey ||
          meeting.calendarId != event.parent.identity.id ||
          event.data.origin != CalendarEventOrigin.native) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final publication = _ReplyMaster(record);
      final published = publication.published;
      if (published.eventId != event.identity.id ||
          published.calendarId != event.parent.identity.id ||
          published.protocolUid != event.data.protocolUid) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _replyReadAccess(actor, event, meeting, publication, tx);
      final value = await action(actor, event, meeting, publication, tx);
      await _verifyContext(actor);
      return value;
    });
  }

  Future<CalendarSchedulingResponsesView> schedulingResponses(
    UuidValue eventId,
  ) => _replyRead(eventId, (actor, event, meeting, publication, tx) async {
    final rows = await CalendarSchedulingAttendeeResponseRecord.db.find(
      _session,
      where: (t) => t.meetingId.equals(meeting.id!),
      limit: 65,
      transaction: tx,
    );
    if (rows.length > 64 ||
        publication.recipients.length > 64 ||
        rows.any((r) => !publication.recipients.contains(r.attendeeAddress))) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final views = <CalendarSchedulingAttendeeResponseView>[];
    for (final attendee in publication.recipients) {
      final matching = rows
          .where((r) => r.attendeeAddress == attendee)
          .toList();
      if (matching.length > 1) throw _failure(CalendarFailureCode.unavailable);
      final response = matching.firstOrNull;
      final source = response == null
          ? null
          : await CalendarSchedulingReplySourceRecord.db.findById(
              _session,
              response.sourceId,
              transaction: tx,
            );
      if (response != null) {
        if (source == null ||
            response.scopeKey != actor.scopeKey ||
            response.sequence != (source.sequence ?? 0) ||
            response.stamp != source.stamp ||
            response.revision < 1 ||
            response.sourceParticipation != source.sourceParticipation ||
            response.effectiveParticipation != source.effectiveParticipation ||
            response.attendeeAddress != source.attendeeAddress ||
            source.outcome != CalendarSchedulingReplyOutcome.applied) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        _validateReplySource(source, meeting, publication);
      }
      views.add(_replyResponseView(attendee, response, source, publication));
    }
    await _replyReadAccess(actor, event, meeting, publication, tx);
    return CalendarSchedulingResponsesView(
      eventId: eventId,
      publicationId: publication.id!,
      publishedSequence: publication.sequence,
      publishedCancelled: publication.method == 'CANCEL',
      recurring: publication.recurring,
      responses: views,
    );
  });

  Future<List<CalendarSchedulingReplySourceView>> schedulingReplySources(
    UuidValue eventId,
  ) => _replyRead(eventId, (actor, event, meeting, publication, tx) async {
    await _replyReadAccess(
      actor,
      event,
      meeting,
      publication,
      tx,
      sourceAccess: true,
    );
    final sources = await CalendarSchedulingReplySourceRecord.db.find(
      _session,
      where: (t) => t.meetingId.equals(meeting.id!),
      orderBy: (t) => t.receivedAt,
      limit: _replies.options.maxSourcesPerBinding + 1,
      transaction: tx,
    );
    if (sources.length > _replies.options.maxSourcesPerBinding) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final output = <CalendarSchedulingReplySourceView>[];
    for (final source in sources) {
      _validateReplySource(source, meeting, publication);
      final response = await CalendarSchedulingAttendeeResponseRecord.db
          .findFirstRow(
            _session,
            where: (t) =>
                t.meetingId.equals(meeting.id!) &
                t.attendeeAddress.equals(source.attendeeAddress),
            transaction: tx,
          );
      await _replyReadAccess(
        actor,
        event,
        meeting,
        publication,
        tx,
        source: source,
        response: response,
        sourceAccess: true,
      );
      output.add(_replySourceView(source, response, publication));
    }
    return List.unmodifiable(output);
  });

  Future<CalendarSchedulingReplyDocument> schedulingReplySource(
    UuidValue eventId,
    UuidValue sourceId,
  ) => _replyRead(eventId, (actor, event, meeting, publication, tx) async {
    await _replyReadAccess(
      actor,
      event,
      meeting,
      publication,
      tx,
      sourceAccess: true,
    );
    final source = await CalendarSchedulingReplySourceRecord.db.findById(
      _session,
      sourceId,
      transaction: tx,
    );
    if (source == null ||
        source.meetingId != meeting.id ||
        source.scopeKey != actor.scopeKey) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    _validateReplySource(source, meeting, publication);
    final response = await CalendarSchedulingAttendeeResponseRecord.db
        .findFirstRow(
          _session,
          where: (t) =>
              t.meetingId.equals(meeting.id!) &
              t.attendeeAddress.equals(source.attendeeAddress),
          transaction: tx,
        );
    await _replyReadAccess(
      actor,
      event,
      meeting,
      publication,
      tx,
      source: source,
      response: response,
      sourceAccess: true,
    );
    return CalendarSchedulingReplyDocument(
      metadata: _replySourceView(source, response, publication),
      normalizedSource: source.normalizedSource,
    );
  });

  Future<void> _replyHostCheck(
    CalendarSchedulingReplyPolicyContext context,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _replies.host.guarantee != CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final verdict = await _bounded(
      () => _replies.host.authorizeReply(_session, context, tx, phase),
    );
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  CalendarSchedulingAttendeeResponseView _replyResponseView(
    String attendee,
    CalendarSchedulingAttendeeResponseRecord? response,
    CalendarSchedulingReplySourceRecord? source,
    _ReplyMaster publication,
  ) => CalendarSchedulingAttendeeResponseView(
    attendeeAddress: attendee,
    sourceId: response?.sourceId,
    revision: response?.revision,
    invitationSequence: response?.sequence,
    sourceSequence: source?.sequence,
    stamp: response?.stamp,
    sourceParticipation: response?.sourceParticipation,
    effectiveParticipation: response?.effectiveParticipation,
    receivedAt: response?.receivedAt,
    isCurrent:
        response != null &&
        publication.method == 'REQUEST' &&
        response.sequence == publication.sequence,
  );

  Future<CalendarSchedulingReplyReceipt> _receiveReply(
    CalendarSchedulingReplyDelivery delivery,
  ) async {
    for (final value in [
      delivery.scopeKey,
      delivery.namespace,
      delivery.deliveryKey,
      delivery.originReference,
    ]) {
      validateCalendarOpaqueText(value, maxUtf8Bytes: 512);
    }
    final options = _replies.options;
    final message = _replyMessage(delivery.bytes, options.maxSourceBytes);
    final normalized = utf8.decode(
      _schedulingValue(
        () => serializeIcalendarSchedulingMessage(
          message,
          syntaxLimits: IcalendarSyntaxLimits(maxBytes: options.maxSourceBytes),
        ),
      ),
    );
    final digest = _schedulingDigest(normalized);
    final incoming = message.events.single;
    final attendee = incoming.participants.attendees.single;
    final participation = _replyParticipation(attendee.participationStatus);
    final effective =
        participation ?? CalendarSchedulingParticipation.needsAction;
    return _scopeTransaction(delivery.scopeKey, (tx, _) async {
      final event = await _eventInScope(
        delivery.scopeKey,
        delivery.eventId,
        tx,
      );
      final meeting = await _meeting(delivery.eventId, tx);
      final record = await _latest(meeting, tx);
      if (meeting == null ||
          record == null ||
          meeting.scopeKey != delivery.scopeKey ||
          meeting.calendarId != event.parent.identity.id ||
          event.data.origin != CalendarEventOrigin.native) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final publication = _ReplyMaster(record);
      final published = publication.published;
      if (published.eventId != event.identity.id ||
          published.calendarId != event.parent.identity.id ||
          published.protocolUid != event.data.protocolUid) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (publication.protocolUid != incoming.uid ||
          incoming.participants.organizer!.address !=
              meeting.organizerAddress ||
          !publication.recipients.contains(attendee.address)) {
        throw _failure(CalendarFailureCode.validation);
      }
      CalendarSchedulingReplyPolicyContext context({
        CalendarSchedulingAttendeeResponseView? response,
        CalendarSchedulingReplyOutcome? outcome,
        UuidValue? sourceId,
        UuidValue? receiptId,
        bool retry = false,
      }) => CalendarSchedulingReplyPolicyContext(
        delivery: delivery,
        calendar: event.parent.snapshot,
        currentEvent: event.snapshot,
        publishedEvent: published,
        publishedSequence: publication.sequence,
        publishedCancelled: publication.method == 'CANCEL',
        publishedMessage: publication.message,
        publishedMaster: publication.master,
        latestPublicationKind: publication.checkpoint.kind,
        message: message,
        normalizedSource: normalized,
        sourceDigest: digest,
        currentResponse: response,
        proposedOutcome: outcome,
        sourceId: sourceId,
        receiptId: receiptId,
        isRetry: retry,
      );
      // Sender approval precedes every lookup of private reply history.
      await _replyHostCheck(
        context(),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final response = await CalendarSchedulingAttendeeResponseRecord.db
          .findFirstRow(
            _session,
            where: (t) =>
                t.meetingId.equals(meeting.id!) &
                t.attendeeAddress.equals(attendee.address),
            transaction: tx,
          );
      final previousSource = response == null
          ? null
          : await CalendarSchedulingReplySourceRecord.db.findById(
              _session,
              response.sourceId,
              transaction: tx,
            );
      if (response != null &&
          (previousSource == null ||
              response.scopeKey != delivery.scopeKey ||
              previousSource.scopeKey != delivery.scopeKey ||
              previousSource.meetingId != meeting.id ||
              previousSource.attendeeAddress != attendee.address)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (response != null) {
        _validateReplySource(previousSource!, meeting, publication);
        if (response.revision < 1 ||
            response.sequence != (previousSource.sequence ?? 0) ||
            response.stamp != previousSource.stamp ||
            response.sourceParticipation !=
                previousSource.sourceParticipation ||
            response.effectiveParticipation !=
                previousSource.effectiveParticipation ||
            previousSource.outcome != CalendarSchedulingReplyOutcome.applied) {
          throw _failure(CalendarFailureCode.unavailable);
        }
      }
      final current = _replyResponseView(
        attendee.address,
        response,
        previousSource,
        publication,
      );
      final ingressDigest = _schedulingDigest(
        jsonEncode([
          delivery.scopeKey,
          meeting.id.toString(),
          delivery.namespace,
          delivery.deliveryKey,
        ]),
      );
      final receipt = await CalendarSchedulingReplyReceiptRecord.db
          .findFirstRow(
            _session,
            where: (t) =>
                t.scopeKey.equals(delivery.scopeKey) &
                t.meetingId.equals(meeting.id!) &
                t.ingressDigest.equals(ingressDigest),
            transaction: tx,
          );
      CalendarSchedulingReplyReceipt result(
        CalendarSchedulingReplyReceiptRecord r,
        CalendarSchedulingReplySourceRecord source,
        bool unchanged,
      ) => CalendarSchedulingReplyReceipt(
        receiptId: r.id!,
        sourceId: source.id!,
        outcome: r.outcome,
        invitationSequence: source.publishedSequence,
        sourceSequence: source.sequence,
        sourceStamp: source.stamp,
        unchanged: unchanged,
      );
      if (receipt != null) {
        final source = await CalendarSchedulingReplySourceRecord.db.findById(
          _session,
          receipt.sourceId,
          transaction: tx,
        );
        if (source == null ||
            source.scopeKey != delivery.scopeKey ||
            source.meetingId != meeting.id ||
            source.digest != digest ||
            source.normalizedSource != normalized) {
          throw _failure(CalendarFailureCode.validation);
        }
        _validateReplySource(source, meeting, publication);
        await _replyHostCheck(
          context(
            response: current,
            outcome: receipt.outcome,
            sourceId: source.id,
            receiptId: receipt.id,
            retry: true,
          ),
          tx,
          CalendarAuthorizationPhase.finalWrite,
        );
        return result(receipt, source, true);
      }
      final existing = await CalendarSchedulingReplySourceRecord.db
          .findFirstRow(
            _session,
            where: (t) =>
                t.meetingId.equals(meeting.id!) &
                t.attendeeAddress.equals(attendee.address) &
                t.digest.equals(digest),
            transaction: tx,
          );
      if (existing != null &&
          (existing.normalizedSource != normalized ||
              existing.scopeKey != delivery.scopeKey)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (existing != null) {
        _validateReplySource(existing, meeting, publication);
      }
      final sequence = incoming.sequence ?? 0;
      var outcome = CalendarSchedulingReplyOutcome.applied;
      if (existing != null) {
        outcome = CalendarSchedulingReplyOutcome.duplicate;
      } else if (sequence < publication.sequence) {
        outcome = CalendarSchedulingReplyOutcome.stale;
      } else if (sequence > publication.sequence) {
        outcome = CalendarSchedulingReplyOutcome.unmatched;
      } else if (publication.method == 'CANCEL' ||
          incoming.requestStatuses.any((s) => s.levels.first != 2)) {
        outcome = CalendarSchedulingReplyOutcome.unappliedResult;
      } else {
        if (!_schedulingValue(
          () => _replyMatchesPublication(incoming, publication.master),
        )) {
          outcome = CalendarSchedulingReplyOutcome.conflict;
        } else if (current.isCurrent &&
            !incoming.stamp.isAfter(response!.stamp)) {
          outcome = incoming.stamp.isBefore(response.stamp)
              ? CalendarSchedulingReplyOutcome.stale
              : CalendarSchedulingReplyOutcome.conflict;
        }
      }
      final sourceCount = existing != null
          ? 0
          : await CalendarSchedulingReplySourceRecord.db.count(
              _session,
              where: (t) => t.meetingId.equals(meeting.id!),
              transaction: tx,
            );
      final scopeSources = existing != null
          ? 0
          : await CalendarSchedulingReplySourceRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(delivery.scopeKey),
              transaction: tx,
            );
      final receiptCount = await CalendarSchedulingReplyReceiptRecord.db.count(
        _session,
        where: (t) => t.meetingId.equals(meeting.id!),
        transaction: tx,
      );
      final scopeReceipts = await CalendarSchedulingReplyReceiptRecord.db.count(
        _session,
        where: (t) => t.scopeKey.equals(delivery.scopeKey),
        transaction: tx,
      );
      if (sourceCount >= options.maxSourcesPerBinding ||
          scopeSources >= options.maxSourcesPerScope ||
          receiptCount >= options.maxReceiptsPerBinding ||
          scopeReceipts >= options.maxReceiptsPerScope) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final now = await _revisionTime(tx);
      final source =
          existing ??
          CalendarSchedulingReplySourceRecord(
            id: const Uuid().v4obj(),
            scopeKey: delivery.scopeKey,
            meetingId: meeting.id!,
            attendeeAddress: attendee.address,
            digest: digest,
            normalizedSource: normalized,
            sequence: incoming.sequence,
            stamp: incoming.stamp,
            sourceParticipation: participation,
            effectiveParticipation: effective,
            outcome: outcome,
            publishedSequence: publication.sequence,
            publishedCancelled: publication.method == 'CANCEL',
            receivedAt: now,
            inactiveAt: outcome == CalendarSchedulingReplyOutcome.applied
                ? null
                : now,
          );
      final savedReceipt = CalendarSchedulingReplyReceiptRecord(
        id: const Uuid().v4obj(),
        scopeKey: delivery.scopeKey,
        meetingId: meeting.id!,
        sourceId: source.id!,
        ingressDigest: ingressDigest,
        outcome: outcome,
        receivedAt: now,
      );
      final proposed = context(
        response: current,
        outcome: outcome,
        sourceId: source.id,
        receiptId: savedReceipt.id,
      );
      await _replyHostCheck(
        proposed,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (existing == null) {
        await CalendarSchedulingReplySourceRecord.db.insertRow(
          _session,
          source,
          transaction: tx,
        );
      }
      if (outcome == CalendarSchedulingReplyOutcome.applied) {
        if ((response?.revision ?? 0) >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        if (previousSource != null) {
          previousSource.inactiveAt = now.isAfter(previousSource.receivedAt)
              ? now
              : previousSource.receivedAt;
          await CalendarSchedulingReplySourceRecord.db.updateRow(
            _session,
            previousSource,
            transaction: tx,
          );
        }
        final next = CalendarSchedulingAttendeeResponseRecord(
          id: response?.id ?? const Uuid().v4obj(),
          scopeKey: delivery.scopeKey,
          meetingId: meeting.id!,
          attendeeAddress: attendee.address,
          revision: (response?.revision ?? 0) + 1,
          sourceId: source.id!,
          sequence: sequence,
          stamp: incoming.stamp,
          sourceParticipation: participation,
          effectiveParticipation: effective,
          receivedAt: now,
        );
        if (response == null) {
          await CalendarSchedulingAttendeeResponseRecord.db.insertRow(
            _session,
            next,
            transaction: tx,
          );
        } else {
          await CalendarSchedulingAttendeeResponseRecord.db.updateRow(
            _session,
            next,
            transaction: tx,
          );
        }
      }
      await CalendarSchedulingReplyReceiptRecord.db.insertRow(
        _session,
        savedReceipt,
        transaction: tx,
      );
      await _replyHostCheck(
        proposed,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      return result(savedReceipt, source, false);
    });
  }
}
