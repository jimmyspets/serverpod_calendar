part of 'calendar_module.dart';

const _informationPurpose =
    CalendarSchedulingBindingPurpose.informationPublication;

final class _InformationCheckpoint {
  const _InformationCheckpoint(
    this.canonical,
    this.outgoing,
    this.activeCanonical,
    this.active,
    this.kind,
    this.message, {
    this.version = 1,
    this.projectionOriginals = const [],
  });
  final int version;
  final List<EventSchedulingOriginal> projectionOriginals;
  final CalendarEventPolicySnapshot canonical,
      outgoing,
      activeCanonical,
      active;
  final CalendarSchedulingPublicationKind kind;
  final IcalendarSchedulingMessage message;
}

bool _informationOverrides(CalendarEventTimingOverrides? value) =>
    _schedulingOverrides(value) || value?.cancelledFrom != null;

void _informationBinding(
  _InformationCheckpoint checkpoint,
  CalendarSchedulingMeetingRecord meeting,
  _Event event,
) {
  if (meeting.purpose != _informationPurpose ||
      meeting.eventId != event.identity.id ||
      meeting.calendarId != event.identity.calendarId ||
      meeting.scopeKey != event.parent.identity.scopeKey ||
      checkpoint.canonical.eventId != event.identity.id ||
      checkpoint.canonical.calendarId != event.identity.calendarId ||
      checkpoint.canonical.protocolUid != event.data.protocolUid ||
      checkpoint.outgoing.protocolState!.sourceMetadata?.organizer?.address !=
          meeting.organizerAddress) {
    throw _failure(CalendarFailureCode.unavailable);
  }
}

CalendarEventPolicySnapshot _informationOutgoing(
  CalendarEventPolicySnapshot native,
  String organizer,
  CalendarEventProtocolVersion version,
) {
  final metadata =
      native.protocolState!.sourceMetadata ??
      CalendarEventSourceMetadata(
        categoryGroups: [],
        comments: [],
        contacts: [],
      );
  if (_informationOverrides(native.timingOverrides) ||
      (metadata.attendees?.isNotEmpty ?? false) ||
      (metadata.alarms?.isNotEmpty ?? false) ||
      metadata.organizer != null && metadata.organizer!.address != organizer) {
    throw _failure(CalendarFailureCode.validation);
  }
  final state = validateEventProtocolState(
    native.protocolState!.copyWith(
      version: version,
      overrides: [],
      sourceMetadata: metadata.copyWith(
        organizer:
            metadata.organizer ??
            CalendarEventSourceParticipant(address: organizer, parameters: {}),
      ),
    ),
    native.content,
    null,
  );
  return CalendarEventPolicySnapshot(
    native.eventId,
    native.calendarId,
    native.revision,
    native.content,
    native.protocolUid,
    native.updatedAt,
    origin: native.origin,
    protocolState: state,
  );
}

_InformationCheckpoint _readInformationCheckpoint(
  CalendarSchedulingPublicationRecord p, {
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  try {
    _schedulingBound(p.snapshot);
    _schedulingBound(p.projection);
    _schedulingBound(p.payload);
    final recipients = _schedulingAddresses(p.recipients, 64);
    if (jsonEncode(recipients) != jsonEncode(p.recipients)) {
      throw StateError('Invalid recipient proof');
    }
    final data = jsonDecode(p.snapshot) as Map<String, dynamic>;
    if (data['informationVersion'] == 2) {
      return _readInformationBundle(
        p,
        data,
        sharedWorkBudget ??
            RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
      );
    }
    if (data.keys.toSet().difference({
          'informationVersion',
          'purpose',
          'kind',
          'canonical',
          'outgoing',
          'activeCanonical',
          'active',
          'priorSequence',
          'priorStamp',
        }).isNotEmpty ||
        data['informationVersion'] != 1 ||
        data['purpose'] != _informationPurpose.name ||
        _schedulingDigest(p.payload) != p.payloadDigest) {
      throw StateError('Invalid information proof');
    }
    final canonical = _schedulingReadSnapshot(
      data['canonical'],
      sharedWorkBudget: sharedWorkBudget,
    );
    final outgoing = _schedulingReadSnapshot(
      data['outgoing'],
      sharedWorkBudget: sharedWorkBudget,
    );
    final activeCanonical = _schedulingReadSnapshot(
      data['activeCanonical'],
      sharedWorkBudget: sharedWorkBudget,
    );
    final active = _schedulingReadSnapshot(
      data['active'],
      sharedWorkBudget: sharedWorkBudget,
    );
    final kind = CalendarSchedulingPublicationKind.values.byName(
      data['kind'] as String,
    );
    final cancel = kind == CalendarSchedulingPublicationKind.informationCancel;
    if (!{
          CalendarSchedulingPublicationKind.informationPublish,
          CalendarSchedulingPublicationKind.informationCancel,
          CalendarSchedulingPublicationKind.informationReopen,
        }.contains(kind) ||
        p.method != (cancel ? 'CANCEL' : 'PUBLISH') ||
        canonical.revision != p.eventRevision ||
        (canonical.content.status == CalendarEventStatus.cancelled) != cancel ||
        p.projection != _schedulingCanonicalKey(canonical) ||
        active.content.status == CalendarEventStatus.cancelled ||
        activeCanonical.content.status == CalendarEventStatus.cancelled ||
        _informationOverrides(activeCanonical.timingOverrides) ||
        _informationOverrides(active.timingOverrides)) {
      throw StateError('Invalid information shape');
    }
    for (final snapshot in [canonical, outgoing, activeCanonical, active]) {
      if (snapshot.eventId != canonical.eventId ||
          snapshot.calendarId != canonical.calendarId ||
          snapshot.protocolUid != p.protocolUid ||
          snapshot.origin != CalendarEventOrigin.native) {
        throw StateError('Invalid identity');
      }
    }
    final organizer =
        outgoing.protocolState!.sourceMetadata?.organizer?.address;
    if (organizer == null ||
        active.protocolState!.sourceMetadata?.organizer?.address != organizer) {
      throw StateError('Invalid organizer');
    }
    final regeneratedActive = _informationOutgoing(
      CalendarEventPolicySnapshot(
        activeCanonical.eventId,
        activeCanonical.calendarId,
        active.revision,
        activeCanonical.content,
        activeCanonical.protocolUid,
        active.updatedAt,
        origin: activeCanonical.origin,
        protocolState: activeCanonical.protocolState,
      ),
      organizer,
      active.protocolState!.version,
    );
    if (jsonEncode(_schedulingSnapshotMap(regeneratedActive)) !=
        jsonEncode(_schedulingSnapshotMap(active))) {
      throw StateError('Invalid active correspondence');
    }
    final basis = kind == CalendarSchedulingPublicationKind.informationPublish
        ? canonical
        : activeCanonical;
    final expected = _informationOutgoing(
      CalendarEventPolicySnapshot(
        basis.eventId,
        basis.calendarId,
        outgoing.revision,
        cancel
            ? basis.content.copyWith(status: CalendarEventStatus.cancelled)
            : basis.content,
        basis.protocolUid,
        outgoing.updatedAt,
        origin: basis.origin,
        protocolState: basis.protocolState!.copyWith(
          statusPresent: cancel ? true : basis.protocolState!.statusPresent,
        ),
      ),
      organizer,
      outgoing.protocolState!.version,
    );
    if (jsonEncode(_schedulingSnapshotMap(expected)) !=
            jsonEncode(_schedulingSnapshotMap(outgoing)) ||
        !cancel &&
            jsonEncode(_schedulingSnapshotMap(active)) !=
                jsonEncode(_schedulingSnapshotMap(outgoing))) {
      throw StateError('Invalid outgoing correspondence');
    }
    final message = parseIcalendarSchedulingMessage(
      utf8.encode(p.payload),
      sharedWorkBudget: sharedWorkBudget,
    );
    final component = message.events.single;
    final priorSequence = data['priorSequence'] as int;
    final priorStamp = data['priorStamp'] == null
        ? null
        : DateTime.parse(data['priorStamp'] as String);
    if (component.isOverride ||
        message.uid != p.protocolUid ||
        component.sequence != p.sequence ||
        component.stamp != p.stamp ||
        p.sequence <= priorSequence ||
        p.sequence > eventMaxSequence ||
        p.sequence < (canonical.protocolState!.version.sequence ?? 0) ||
        (active.protocolState!.version.sequence ?? 0) > p.sequence ||
        priorSequence < -1 ||
        priorStamp != null && eventProtocolInstant(priorStamp) != priorStamp ||
        priorStamp != null && p.stamp.isBefore(priorStamp) ||
        component.participants.attendees.isNotEmpty ||
        component.participants.organizer?.address != organizer ||
        _schedulingPayload(
              outgoing,
              524288,
              method: p.method,
              sharedWorkBudget: sharedWorkBudget,
            ) !=
            p.payload) {
      throw StateError('Invalid version/body');
    }
    return _InformationCheckpoint(
      canonical,
      outgoing,
      activeCanonical,
      active,
      kind,
      message,
    );
  } catch (_) {
    throw _failure(CalendarFailureCode.unavailable);
  }
}

extension CalendarInformationPublicationOperations on CalendarService {
  Future<CalendarSchedulingReceipt> saveAndPublishInformation(
    CalendarSchedulingSaveRequest request,
  ) => _publishInformation(
    request.eventId,
    request.expectedRevision,
    request.commandId,
    CalendarSchedulingPublicationKind.informationPublish,
    input: request,
  );
  Future<CalendarSchedulingReceipt> cancelPublishedInformation(
    CalendarSchedulingCancelRequest request,
  ) => _publishInformation(
    request.eventId,
    request.expectedRevision,
    request.commandId,
    CalendarSchedulingPublicationKind.informationCancel,
  );
  Future<CalendarSchedulingReceipt> reopenPublishedInformation(
    CalendarSchedulingReopenRequest request,
  ) => _publishInformation(
    request.eventId,
    request.expectedRevision,
    request.commandId,
    CalendarSchedulingPublicationKind.informationReopen,
  );

  List<CalendarAuthorizationRequest> _informationRequests(
    _Event e,
    CalendarSchedulingIntent? intent,
    CalendarSchedulingPublicationKind kind,
    CalendarEventPolicySnapshot proposed, {
    bool write = true,
  }) => [
    for (final operation in [
      if (!write)
        CalendarPermission.readEventInformationPublication
      else
        kind == CalendarSchedulingPublicationKind.informationCancel
            ? CalendarPermission.cancelEventInformation
            : kind == CalendarSchedulingPublicationKind.informationReopen
            ? CalendarPermission.reopenEventInformation
            : CalendarPermission.publishEventInformation,
      CalendarPermission.readEvent,
      if (write) CalendarPermission.readEventSource,
      if (write && kind == CalendarSchedulingPublicationKind.informationPublish)
        CalendarPermission.updateEvent,
      if (write &&
          (kind != CalendarSchedulingPublicationKind.informationPublish ||
              proposed.content.status != e.data.content.status))
        CalendarPermission.changeEventStatus,
    ])
      CalendarAuthorizationRequest(
        key: '${operation.name}:${e.identity.id}',
        operation: operation,
        calendarId: e.identity.calendarId,
        current: e.parent.snapshot,
        eventId: e.identity.id,
        currentEvent: e.snapshot,
        proposedEvent: proposed.content,
        proposedEventProtocolState: proposed.protocolState,
        proposedTimingOverrides: proposed.timingOverrides,
        scheduling: intent,
        eventGroups: write ? CalendarEventFieldGroup.values : const [],
      ),
  ];

  Future<CalendarSchedulingReceipt> _publishInformation(
    UuidValue eventId,
    int expectedRevision,
    UuidValue commandId,
    CalendarSchedulingPublicationKind kind, {
    CalendarSchedulingSaveRequest? input,
  }) async {
    final requested = input == null ? null : _validatedEvent(input.content);
    final addresses = input == null
        ? null
        : _schedulingAddresses(
            input.recipients,
            _scheduling.options.maxRecipients,
          );
    final digest = _schedulingDigest(
      jsonEncode([
        _informationPurpose.name,
        kind.name,
        eventId.toString(),
        expectedRevision,
        requested?.toJson(),
        addresses,
      ]),
    );
    final actor = await _context();
    return _transaction(actor, (tx, scope) async {
      final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
      // Reuse validation only for the exact immutable proof in this transaction.
      // Access/route decisions and mutable worker state are never cached.
      final proofs = <String, _InformationCheckpoint>{};
      _InformationCheckpoint readPublication(
        CalendarSchedulingPublicationRecord row,
      ) {
        final key = _schedulingDigest(
          jsonEncode([
            row.id?.toString(),
            row.meetingId.toString(),
            row.scopeKey,
            row.snapshot,
            row.projection,
            row.payload,
            row.payloadDigest,
            row.method,
            row.protocolUid,
            row.eventRevision,
            row.sequence,
            row.stamp.toIso8601String(),
            row.recipients,
          ]),
        );
        return proofs.putIfAbsent(
          key,
          () => _readInformationCheckpoint(row, sharedWorkBudget: work),
        );
      }

      final e = await _event(actor, eventId, tx);
      final meeting = await _meeting(eventId, tx, allowInformation: true);
      if (meeting != null && meeting.purpose != _informationPurpose) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      await _schedulingAuthorize(
        actor,
        _informationRequests(e, null, kind, e.snapshot),
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      if (e.data.origin != CalendarEventOrigin.native ||
          e.data.importBaseline != null) {
        throw _failure(CalendarFailureCode.validation);
      }
      final last = await _latest(meeting, tx);
      final previous = last == null ? null : readPublication(last);
      if (previous != null) _informationBinding(previous, meeting!, e);
      final cancel =
          kind == CalendarSchedulingPublicationKind.informationCancel;
      final reopen =
          kind == CalendarSchedulingPublicationKind.informationReopen;
      final retry = await CalendarSchedulingPublicationRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(actor.scopeKey) & t.commandId.equals(commandId),
        transaction: tx,
      );
      if (retry != null &&
          (retry.meetingId != meeting?.id ||
              retry.actorId != actor.principalId ||
              retry.requestDigest != digest ||
              readPublication(retry).kind != kind)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (previous == null && (cancel || reopen)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (retry != null) {
        _informationBinding(readPublication(retry), meeting!, e);
      }
      final proposals =
          addresses ??
          _schedulingAddresses(
            last!.recipients,
            _scheduling.options.maxRecipients,
          );
      final authority = _schedulingAuthority(
        await _bounded(
          () => _scheduling.host.resolve(
            _session,
            actor,
            e.snapshot,
            proposals,
            tx,
          ),
        ),
        proposals,
      );
      if (meeting != null &&
          (meeting.scopeKey != actor.scopeKey ||
              meeting.calendarId != e.identity.calendarId ||
              meeting.organizerAddress != authority.organizerAddress ||
              meeting.authorityRef != authority.authorityRef ||
              jsonEncode(proposals) != jsonEncode(last!.recipients))) {
        throw _failure(CalendarFailureCode.validation);
      }
      var content =
          requested ??
          e.data.content.copyWith(
            status: cancel
                ? CalendarEventStatus.cancelled
                : previous!.activeCanonical.content.status,
          );
      if (content.textParameters == null) {
        content = content.copyWith(
          textParameters: e.data.content.textParameters,
        );
      } else if (jsonEncode(content.textParameters?.toJson()) !=
          jsonEncode(e.data.content.textParameters?.toJson())) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (retry == null &&
          input != null &&
          (content.status == CalendarEventStatus.cancelled ||
              _schedulingRecurring(content) !=
                  _schedulingRecurring(e.data.content) ||
              previous != null &&
                  (_schedulingRecurring(previous.active.content) !=
                          _schedulingRecurring(content) ||
                      previous.kind ==
                          CalendarSchedulingPublicationKind
                              .informationCancel))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final unchanged =
          previous != null &&
          (cancel
              ? previous.kind ==
                        CalendarSchedulingPublicationKind.informationCancel &&
                    e.data.content.status == CalendarEventStatus.cancelled
              : reopen
              ? previous.kind ==
                        CalendarSchedulingPublicationKind.informationReopen &&
                    e.data.content.status ==
                        previous.activeCanonical.content.status
              : previous.kind !=
                        CalendarSchedulingPublicationKind.informationCancel &&
                    _schedulingCanonicalKey(e.snapshot) ==
                        _schedulingCanonicalKey(previous.activeCanonical) &&
                    jsonEncode(e.data.content.toJson()) ==
                        jsonEncode(content.toJson()));
      if (retry == null &&
          reopen &&
          previous!.kind !=
              CalendarSchedulingPublicationKind.informationCancel &&
          !unchanged) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (retry == null) _eventRevision(e, expectedRevision);
      final queuedAt = await _revisionTime(tx);
      final now = queuedAt.isBefore(e.data.updatedAt)
          ? e.data.updatedAt
          : queuedAt;
      final state = retry != null || unchanged
          ? e.data.protocolState!
          : _eventProtocolValue(
              () => advanceEventProtocol(
                e.data.protocolState!,
                e.data.content,
                e.data.timingOverrides,
                content,
                e.data.timingOverrides,
                now,
              ),
            );
      final proposed = CalendarEventPolicySnapshot(
        eventId,
        e.identity.calendarId,
        retry != null || unchanged
            ? e.identity.revision
            : e.identity.revision + 1,
        retry != null || unchanged ? e.data.content : content,
        e.data.protocolUid,
        retry != null || unchanged ? e.data.updatedAt : now,
        origin: e.data.origin,
        protocolState: state,
        timingOverrides: e.data.timingOverrides,
      );
      final receipt = retry ?? (unchanged ? last : null);
      late final CalendarEventPolicySnapshot activeCanonical;
      late final String payload, snapshot;
      if (receipt != null) {
        final saved = readPublication(receipt);
        activeCanonical = saved.activeCanonical;
        payload = receipt.payload;
        snapshot = receipt.snapshot;
      } else {
        final plan = _schedulingValue(
          () => _informationPlan(
            proposed,
            authority.organizerAddress,
            kind,
            previous,
            last,
            now,
            _scheduling.options.maxPayloadBytes,
            work,
          ),
        );
        activeCanonical = plan.activeCanonical;
        payload = plan.payload;
        snapshot = plan.snapshot;
      }

      final parsed = _schedulingValue(
        () => parseIcalendarSchedulingMessage(
          utf8.encode(payload),
          sharedWorkBudget: work,
        ),
      );
      final intent = CalendarSchedulingIntent(
        purpose: _informationPurpose,
        method: parsed.method.name.toUpperCase(),
        publicationKind: receipt == null ? kind : readPublication(receipt).kind,
        organizerAddress: authority.organizerAddress,
        recipients: proposals,
        payload: payload,
        publicationId: receipt?.id,
        generation: receipt?.generation ?? (meeting?.generation ?? 0) + 1,
      );
      final requests = _informationRequests(e, intent, kind, proposed);
      final context = CalendarSchedulingPolicyContext(
        purpose: _informationPurpose,
        scopeKey: actor.scopeKey,
        actor: actor,
        calendar: e.parent.snapshot,
        currentEvent: e.snapshot,
        proposedEvent: proposed,
        publicationEvent: activeCanonical,
        outgoingMessage: parsed,
        payloadDigest: _schedulingDigest(payload),
        authority: authority,
        intent: intent,
      );
      await _schedulingAuthorize(
        actor,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      await _schedulingHostCheck(
        context,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final checked = _schedulingAuthority(
        await _bounded(
          () => _scheduling.host.resolve(
            _session,
            actor,
            e.snapshot,
            proposals,
            tx,
          ),
        ),
        proposals,
      );
      if (_schedulingAuthorityKey(checked) !=
          _schedulingAuthorityKey(authority)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _schedulingHostCheck(
        context,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      await _schedulingAuthorize(
        actor,
        requests,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      if (receipt != null) {
        return CalendarSchedulingReceipt(
          publicationId: receipt.id!,
          eventRevision: receipt.eventRevision,
          unchanged: true,
        );
      }
      final binding =
          meeting ??
          CalendarSchedulingMeetingRecord(
            purpose: _informationPurpose,
            scopeKey: actor.scopeKey,
            calendarId: e.identity.calendarId,
            eventId: eventId,
            organizerAddress: authority.organizerAddress,
            authorityRef: authority.authorityRef,
            revision: 1,
            generation: 0,
            createdAt: queuedAt,
            updatedAt: now,
          );
      final options = _scheduling.options;
      if (binding.generation >= CalendarService._maxRevision ||
          binding.revision >= CalendarService._maxRevision ||
          proposed.revision > CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (meeting != null) {
        final retained = await CalendarSchedulingPublicationRecord.db.find(
          _session,
          where: (t) => t.meetingId.equals(meeting.id!),
          limit: options.maxRetainedPublications + 1,
          transaction: tx,
        );
        if (retained.length >= options.maxRetainedPublications ||
            retained.where((p) => p.completedAt == null).length >=
                options.maxPendingPublications) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
      }
      if (await CalendarSchedulingDeliveryRecord.db.count(
                _session,
                where: (t) =>
                    t.scopeKey.equals(actor.scopeKey) &
                    t.terminalAt.equals(null),
                transaction: tx,
              ) +
              proposals.length >
          options.maxScopeDeliveries) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final saved =
          meeting ??
          await CalendarSchedulingMeetingRecord.db.insertRow(
            _session,
            binding,
            transaction: tx,
          );
      final publication = await CalendarSchedulingPublicationRecord.db
          .insertRow(
            _session,
            CalendarSchedulingPublicationRecord(
              scopeKey: actor.scopeKey,
              meetingId: saved.id!,
              generation: saved.generation + 1,
              method: intent.method,
              protocolUid: e.data.protocolUid,
              sequence: parsed.events
                  .singleWhere((e) => !e.isOverride)
                  .sequence!,
              stamp: parsed.events.singleWhere((e) => !e.isOverride).stamp,
              snapshot: snapshot,
              projection: _schedulingCanonicalKey(proposed),
              payload: payload,
              payloadDigest: _schedulingDigest(payload),
              recipients: proposals,
              commandId: commandId,
              actorId: actor.principalId,
              requestDigest: digest,
              expectedRevision: expectedRevision,
              eventRevision: proposed.revision,
              createdAt: queuedAt,
              expiresAt: queuedAt.add(options.expiry),
              outcome: 'pending',
            ),
            transaction: tx,
          );
      readPublication(publication);
      await CalendarSchedulingDeliveryRecord.db.insert(_session, [
        for (final route in authority.routes)
          CalendarSchedulingDeliveryRecord(
            scopeKey: actor.scopeKey,
            publicationId: publication.id!,
            recipientAddress: route.address,
            routeRef: route.routeRef,
            nextAttemptAt: queuedAt,
          ),
      ], transaction: tx);
      saved.generation++;
      saved.revision++;
      saved.latestPublicationId = publication.id;
      saved.updatedAt = now;
      await CalendarSchedulingMeetingRecord.db.updateRow(
        _session,
        saved,
        transaction: tx,
      );
      final nativeChanged =
          _schedulingCanonicalKey(e.snapshot) !=
          _schedulingCanonicalKey(proposed);
      e.data
        ..content = proposed.content
        ..protocolState = state
        ..updatedAt = now;
      e.identity.revision = proposed.revision;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        e.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        e.identity,
        transaction: tx,
      );
      await _bump(
        scope,
        tx,
        publishedEventCalendar: nativeChanged ? e.identity.calendarId : null,
      );
      return CalendarSchedulingReceipt(
        publicationId: publication.id!,
        eventRevision: proposed.revision,
        unchanged: false,
      );
    });
  }

  Future<CalendarSchedulingView> informationPublicationStatus(
    UuidValue eventId,
  ) async {
    final actor = await _context();
    return _transaction(actor, (tx, _) async {
      final e = await _event(actor, eventId, tx);
      final meeting = await _meeting(eventId, tx, allowInformation: true);
      if (meeting != null && meeting.purpose != _informationPurpose) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final requests = _informationRequests(
        e,
        null,
        CalendarSchedulingPublicationKind.informationPublish,
        e.snapshot,
        write: false,
      );
      for (final request in requests) {
        await _decide(actor, [request], tx, CalendarAuthorizationPhase.read);
      }
      final p = await _latest(meeting, tx);
      final checkpoint = p == null ? null : _readInformationCheckpoint(p);
      if (checkpoint != null) _informationBinding(checkpoint, meeting!, e);
      final deliveries = p == null
          ? <CalendarSchedulingDeliveryRecord>[]
          : await CalendarSchedulingDeliveryRecord.db.find(
              _session,
              where: (t) => t.publicationId.equals(p.id!),
              orderBy: (t) => t.recipientAddress,
              limit: 65,
              transaction: tx,
            );
      if (deliveries.length > 64 ||
          p != null && deliveries.length != p.recipients.length) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _verifyContext(actor);
      final expected = checkpoint == null
          ? null
          : CalendarEventPolicySnapshot(
              eventId,
              e.identity.calendarId,
              e.identity.revision,
              checkpoint.kind ==
                      CalendarSchedulingPublicationKind.informationCancel
                  ? checkpoint.activeCanonical.content.copyWith(
                      status: CalendarEventStatus.cancelled,
                    )
                  : checkpoint.activeCanonical.content,
              e.data.protocolUid,
              e.data.updatedAt,
              protocolState: checkpoint.activeCanonical.protocolState,
              timingOverrides: checkpoint.activeCanonical.timingOverrides,
            );
      return CalendarSchedulingView(
        purpose: meeting?.purpose,
        eventId: eventId,
        eventRevision: e.identity.revision,
        origin: e.data.origin,
        organizerAddress: meeting?.organizerAddress,
        publicationId: p?.id,
        publishedAt: p?.createdAt,
        method: p?.method,
        publicationKind: checkpoint?.kind,
        hasLocalChanges:
            expected == null ||
            _schedulingCanonicalKey(expected) !=
                _schedulingCanonicalKey(e.snapshot),
        deliveries: [
          for (final d in deliveries)
            CalendarSchedulingDeliveryView(
              recipientAddress: d.recipientAddress,
              state: d.state,
              attemptCount: d.attemptCount,
              resultCode: d.resultCode,
            ),
        ],
      );
    });
  }

  Future<CalendarSchedulingPolicyContext> _informationDispatchContext(
    CalendarSchedulingDeliveryRecord delivery,
    CalendarSchedulingPublicationRecord p,
    CalendarSchedulingMeetingRecord meeting,
    Transaction tx,
  ) async {
    final e = await _eventInScope(meeting.scopeKey, meeting.eventId, tx);
    final saved = _readInformationCheckpoint(p);
    if (meeting.purpose != _informationPurpose ||
        p.meetingId != meeting.id ||
        p.scopeKey != meeting.scopeKey ||
        delivery.scopeKey != meeting.scopeKey ||
        meeting.calendarId != e.identity.calendarId ||
        e.data.origin != CalendarEventOrigin.native ||
        e.data.importBaseline != null ||
        e.data.protocolUid != p.protocolUid ||
        meeting.latestPublicationId != p.id ||
        meeting.generation != p.generation ||
        saved.canonical.eventId != e.identity.id ||
        saved.canonical.calendarId != e.identity.calendarId ||
        p.method == 'PUBLISH' &&
            e.data.content.status == CalendarEventStatus.cancelled ||
        _schedulingRecurring(saved.active.content) !=
            _schedulingRecurring(e.data.content)) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    final rows = await CalendarSchedulingDeliveryRecord.db.find(
      _session,
      where: (t) => t.publicationId.equals(p.id!),
      limit: 65,
      transaction: tx,
    );
    final authority = _schedulingAuthority(
      CalendarSchedulingAuthority(
        organizerAddress: meeting.organizerAddress,
        authorityRef: meeting.authorityRef,
        routes: rows.map(
          (d) => CalendarSchedulingRoute(d.recipientAddress, d.routeRef),
        ),
      ),
      p.recipients,
    );
    if (saved.message.events.any(
          (component) =>
              component.participants.organizer?.address !=
                  authority.organizerAddress ||
              component.participants.attendees.isNotEmpty,
        ) ||
        !rows.any(
          (d) =>
              d.id == delivery.id &&
              d.recipientAddress == delivery.recipientAddress &&
              d.routeRef == delivery.routeRef,
        )) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return CalendarSchedulingPolicyContext(
      purpose: _informationPurpose,
      scopeKey: meeting.scopeKey,
      calendar: e.parent.snapshot,
      currentEvent: e.snapshot,
      proposedEvent: e.snapshot,
      publicationEvent: saved.activeCanonical,
      outgoingMessage: saved.message,
      payloadDigest: p.payloadDigest,
      authority: authority,
      intent: CalendarSchedulingIntent(
        purpose: _informationPurpose,
        method: p.method,
        publicationKind: saved.kind,
        organizerAddress: authority.organizerAddress,
        recipients: p.recipients,
        payload: p.payload,
        publicationId: p.id,
        generation: p.generation,
      ),
      recipient: CalendarSchedulingRoute(
        delivery.recipientAddress,
        delivery.routeRef,
      ),
    );
  }
}
