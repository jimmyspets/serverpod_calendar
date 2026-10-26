part of 'calendar_module.dart';

T _schedulingValue<T>(T Function() action) {
  try {
    return action();
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
  } on RecurrenceLimitException {
    throw _failure(CalendarFailureCode.limitExceeded);
  } on ZoneCoverageException {
    throw _failure(CalendarFailureCode.validation);
  } on ArgumentError {
    throw _failure(CalendarFailureCode.validation);
  }
}

String _schedulingDigest(String value) =>
    sha256.convert(utf8.encode(value)).toString();

String _schedulingProjection(
  CalendarEventContent content,
  CalendarEventProtocolState state,
) => jsonEncode([
  content.toJson(),
  state.sourceMetadata?.toJson(),
  state.statusPresent,
  state.transparencyPresent,
]);

String _schedulingSnapshot(CalendarEventPolicySnapshot value) => jsonEncode({
  'eventId': value.eventId.toString(),
  'calendarId': value.calendarId.toString(),
  'revision': value.revision,
  'protocolUid': value.protocolUid,
  'updatedAt': value.updatedAt.toIso8601String(),
  'content': value.content.toJson(),
  'state': value.protocolState!.toJson(),
});

CalendarEventPolicySnapshot _schedulingPublished(
  CalendarSchedulingPublicationRecord p,
) {
  final v = jsonDecode(p.snapshot) as Map<String, dynamic>;
  return CalendarEventPolicySnapshot(
    UuidValue.fromString(v['eventId'] as String),
    UuidValue.fromString(v['calendarId'] as String),
    v['revision'] as int,
    CalendarEventContent.fromJson(v['content'] as Map<String, dynamic>),
    v['protocolUid'] as String,
    DateTime.parse(v['updatedAt'] as String),
    origin: CalendarEventOrigin.native,
    protocolState: CalendarEventProtocolState.fromJson(
      v['state'] as Map<String, dynamic>,
    ),
  );
}

List<String> _schedulingAddresses(Iterable<String> input, int limit) {
  final values = input.toList();
  if (values.isEmpty || values.length > limit) {
    throw _failure(CalendarFailureCode.limitExceeded);
  }
  for (final v in values) {
    _schedulingValue(
      () => decodeIcalendarEventParticipant(
        IcalendarSyntaxProperty('ATTENDEE', v),
      ),
    );
  }
  values.sort();
  if (values.toSet().length != values.length) {
    throw _failure(CalendarFailureCode.validation);
  }
  return List.unmodifiable(values);
}

CalendarSchedulingAuthority _schedulingAuthority(
  CalendarSchedulingAuthority value,
  List<String> expected,
) {
  _schedulingAddresses([value.organizerAddress], 1);
  validateCalendarOpaqueText(value.authorityRef, maxUtf8Bytes: 512);
  final routes = [...value.routes]
    ..sort((a, b) => a.address.compareTo(b.address));
  if (jsonEncode(routes.map((r) => r.address).toList()) !=
          jsonEncode(expected) ||
      routes.map((r) => r.routeRef).toSet().length != routes.length) {
    throw _failure(CalendarFailureCode.accessDenied);
  }
  for (final route in routes) {
    validateCalendarOpaqueText(route.routeRef, maxUtf8Bytes: 512);
  }
  return CalendarSchedulingAuthority(
    organizerAddress: value.organizerAddress,
    authorityRef: value.authorityRef,
    routes: routes,
  );
}

String _schedulingAuthorityKey(CalendarSchedulingAuthority value) =>
    jsonEncode([
      value.organizerAddress,
      value.authorityRef,
      value.routes.map((r) => [r.address, r.routeRef]).toList(),
    ]);

String _schedulingPayload(CalendarEventPolicySnapshot value, int maxBytes) {
  final source = parseIcalendarSyntax(eventExportBytes([value]))
      .components
      .single;
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      ...source.entries.whereType<IcalendarSyntaxProperty>(),
      IcalendarSyntaxProperty('METHOD', 'REQUEST'),
      for (final child in source.entries.whereType<IcalendarSyntaxComponent>())
        if (child.canonicalName == 'VEVENT')
          IcalendarSyntaxComponent(child.name, [
            ...child.entries,
            if (!child.entries.whereType<IcalendarSyntaxProperty>().any(
              (p) => p.canonicalName == 'SUMMARY',
            ))
              IcalendarSyntaxProperty('SUMMARY', ''),
          ])
        else
          child,
    ]),
  ]);
  return utf8.decode(
    serializeIcalendarSchedulingMessage(
      validateIcalendarSchedulingMessage(
        document,
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      ),
      syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
    ),
  );
}

extension CalendarSchedulingOperations on CalendarService {
  CalendarSchedulingRuntime get _scheduling =>
      _runtime.scheduling ?? (throw _failure(CalendarFailureCode.unavailable));

  Future<CalendarSchedulingMeetingRecord?> _meeting(
    UuidValue eventId,
    Transaction tx,
  ) => CalendarSchedulingMeetingRecord.db.findFirstRow(
    _session,
    where: (t) => t.eventId.equals(eventId),
    transaction: tx,
  );

  Future<void> _rejectSchedulingBinding(
    UuidValue eventId,
    Transaction tx,
  ) async {
    if (await _meeting(eventId, tx) != null) {
      throw _failure(CalendarFailureCode.dependencyConflict);
    }
  }

  Future<CalendarSchedulingPublicationRecord?> _latest(
    CalendarSchedulingMeetingRecord? meeting,
    Transaction tx,
  ) async {
    if (meeting == null) return null;
    final p = meeting.latestPublicationId == null
        ? null
        : await CalendarSchedulingPublicationRecord.db.findById(
            _session,
            meeting.latestPublicationId!,
            transaction: tx,
          );
    if (p == null ||
        p.meetingId != meeting.id ||
        p.scopeKey != meeting.scopeKey ||
        p.generation != meeting.generation) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return p;
  }

  List<CalendarAuthorizationRequest> _schedulingRequests(
    _Event e,
    CalendarSchedulingIntent? intent, {
    required bool write,
    CalendarEventPolicySnapshot? proposed,
  }) => [
    for (final op in [
      write
          ? CalendarPermission.publishScheduling
          : CalendarPermission.readScheduling,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      if (write) CalendarPermission.updateEvent,
      if (write && proposed!.content.status != e.data.content.status)
        CalendarPermission.changeEventStatus,
    ])
      CalendarAuthorizationRequest(
        key: '${op.name}:${e.identity.id}',
        operation: op,
        calendarId: e.parent.identity.id,
        current: e.parent.snapshot,
        eventId: e.identity.id,
        currentEvent: e.snapshot,
        proposedEvent: proposed?.content,
        proposedEventProtocolState: proposed?.protocolState,
        scheduling: intent,
        eventGroups: CalendarEventFieldGroup.values,
      ),
  ];

  Future<void> _schedulingAuthorize(
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    await _verifyContext(c);
    for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
      final chunk = requests.sublist(
        i,
        min(i + _options.policyBatchSize, requests.length),
      );
      final decisions = phase == CalendarAuthorizationPhase.finalWrite
          ? await _final(c, chunk, tx)
          : await _decide(c, chunk, tx, phase);
      for (final r in chunk.where(
        (r) => r.operation == CalendarPermission.readEvent,
      )) {
        if (!decisions[r.key]!.eventDisclosedGroups.containsAll(
          CalendarEventFieldGroup.values,
        )) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      }
    }
  }

  Future<void> _schedulingHostCheck(
    CalendarSchedulingPolicyContext value,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _scheduling.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final verdict = await _bounded(
      () => _scheduling.host.authorize(_session, value, tx, phase),
    );
    if (verdict != CalendarAuthorizationVerdict.allow) {
      throw _failure(
        verdict == CalendarAuthorizationVerdict.deny
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
  }

  Future<CalendarSchedulingReceipt> saveAndNotify(
    CalendarSchedulingSaveRequest input,
  ) async {
    final requestedContent = _validatedEvent(input.content),
        options = _scheduling.options;
    final proposals = _schedulingAddresses(
      input.recipients,
      options.maxRecipients,
    );
    final digest = _schedulingDigest(
      jsonEncode([
        input.eventId.toString(),
        input.expectedRevision,
        requestedContent.toJson(),
        proposals,
      ]),
    );
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, input.eventId, tx);
      var content = requestedContent;
      final meeting = await _meeting(e.identity.id!, tx);
      final last = await _latest(meeting, tx);
      final baseRequests = _schedulingRequests(
        e,
        null,
        write: true,
        proposed: e.snapshot,
      );
      await _schedulingAuthorize(
        c,
        baseRequests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final retainedParameters = e.data.content.textParameters;
      if (content.textParameters == null) {
        content = content.copyWith(textParameters: retainedParameters);
      } else if (jsonEncode(content.textParameters!.toJson()) !=
          jsonEncode(retainedParameters?.toJson())) {
        throw _failure(CalendarFailureCode.validation);
      }

      if (e.data.origin != CalendarEventOrigin.native ||
          e.data.importBaseline != null ||
          content.recurrence != null ||
          e.data.content.recurrence != null ||
          e.data.timingOverrides != null ||
          (content.periods?.isNotEmpty ?? false) ||
          content.status == CalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.validation);
      }
      final authority = _schedulingAuthority(
        await _bounded(
          () =>
              _scheduling.host.resolve(_session, c, e.snapshot, proposals, tx),
        ),
        proposals,
      );
      if (meeting != null &&
          (meeting.scopeKey != c.scopeKey ||
              meeting.calendarId != e.identity.calendarId ||
              meeting.organizerAddress != authority.organizerAddress ||
              meeting.authorityRef != authority.authorityRef ||
              jsonEncode(last!.recipients) != jsonEncode(proposals))) {
        throw _failure(CalendarFailureCode.validation);
      }
      final metadata = e.data.protocolState!.sourceMetadata;
      final source =
          (metadata ??
                  CalendarEventSourceMetadata(
                    categoryGroups: [],
                    comments: [],
                    contacts: [],
                  ))
              .copyWith(
                organizer: CalendarEventSourceParticipant(
                  address: authority.organizerAddress,
                  parameters: {},
                ),
                attendees: [
                  for (final address in proposals)
                    CalendarEventSourceParticipant(
                      address: address,
                      parameters: {
                        'PARTSTAT': ['NEEDS-ACTION'],
                        'RSVP': ['TRUE'],
                      },
                    ),
                ],
              );
      final baseState = e.data.protocolState!.copyWith(sourceMetadata: source);
      final projection = _schedulingProjection(content, baseState);
      final retry = await CalendarSchedulingPublicationRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(c.scopeKey) & t.commandId.equals(input.commandId),
        transaction: tx,
      );
      if (retry != null &&
          (retry.actorId != c.principalId ||
              retry.requestDigest != digest ||
              retry.meetingId != meeting?.id)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final unchanged =
          last != null &&
          last.projection == projection &&
          _schedulingProjection(e.data.content, e.data.protocolState!) ==
              projection;
      if (retry == null) _eventRevision(e, input.expectedRevision);
      final now = await _revisionTime(tx, previous: e.data.updatedAt);
      final componentChanged =
          _schedulingProjection(e.data.content, e.data.protocolState!) !=
          projection;
      final currentSequence = e.data.protocolState!.version.sequence ?? 0;
      final nextSequence = max(
        currentSequence + (componentChanged ? 1 : 0),
        (last?.sequence ?? -1) + 1,
      );
      if (retry == null && !unchanged && nextSequence > eventMaxSequence) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final state =
          retry != null ||
              unchanged ||
              !componentChanged && nextSequence == currentSequence
          ? e.data.protocolState!
          : _eventProtocolValue(
              () => validateEventProtocolState(
                baseState.copyWith(
                  version: baseState.version.copyWith(
                    sequence: nextSequence,
                    stamp: eventProtocolInstant(
                      now.isBefore(baseState.version.stamp)
                          ? baseState.version.stamp
                          : now,
                    ),
                    lastModified: eventProtocolInstant(
                      now.isBefore(
                            baseState.version.lastModified ??
                                baseState.version.stamp,
                          )
                          ? (baseState.version.lastModified ??
                                baseState.version.stamp)
                          : now,
                    ),
                  ),
                ),
                content,
                null,
              ),
            );
      final proposed = CalendarEventPolicySnapshot(
        e.identity.id!,
        e.identity.calendarId,
        retry != null || unchanged
            ? e.identity.revision
            : e.identity.revision + 1,
        retry != null || unchanged ? e.data.content : content,
        e.data.protocolUid,
        now,
        origin: e.data.origin,
        protocolState: state,
      );
      final receiptPublication = retry ?? (unchanged ? last : null);
      final String payload =
          receiptPublication?.payload ??
          _schedulingValue<String>(
            () => _schedulingPayload(proposed, options.maxPayloadBytes),
          );
      final intent = CalendarSchedulingIntent(
        organizerAddress: authority.organizerAddress,
        recipients: proposals,
        payload: payload,
        publicationId: receiptPublication?.id,
        generation:
            receiptPublication?.generation ?? (meeting?.generation ?? 0) + 1,
      );
      final requests = _schedulingRequests(
        e,
        intent,
        write: true,
        proposed: proposed,
      );
      final hostContext = CalendarSchedulingPolicyContext(
        scopeKey: c.scopeKey,
        actor: c,
        calendar: e.parent.snapshot,
        currentEvent: e.snapshot,
        proposedEvent: receiptPublication == null
            ? proposed
            : _schedulingPublished(receiptPublication),
        authority: authority,
        intent: intent,
      );
      await _schedulingAuthorize(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      await _schedulingHostCheck(
        hostContext,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final checked = _schedulingAuthority(
        await _bounded(
          () =>
              _scheduling.host.resolve(_session, c, e.snapshot, proposals, tx),
        ),
        proposals,
      );
      if (_schedulingAuthorityKey(checked) !=
          _schedulingAuthorityKey(authority)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      await _schedulingHostCheck(
        hostContext,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      await _schedulingAuthorize(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.finalWrite,
      );
      if (receiptPublication != null) {
        return CalendarSchedulingReceipt(
          publicationId: receiptPublication.id!,
          eventRevision: receiptPublication.eventRevision,
          unchanged: true,
        );
      }
      final binding =
          meeting ??
          CalendarSchedulingMeetingRecord(
            scopeKey: c.scopeKey,
            calendarId: e.identity.calendarId,
            eventId: e.identity.id!,
            organizerAddress: authority.organizerAddress,
            authorityRef: authority.authorityRef,
            revision: 1,
            generation: 0,
            createdAt: now,
            updatedAt: now,
          );
      if (binding.generation >= CalendarService._maxRevision ||
          binding.revision >= CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      if (meeting != null) {
        final existing = await CalendarSchedulingPublicationRecord.db.find(
          _session,
          where: (t) => t.meetingId.equals(binding.id!),
          limit: options.maxRetainedPublications + 1,
          transaction: tx,
        );
        if (existing.length >= options.maxRetainedPublications ||
            existing.where((p) => p.completedAt == null).length >=
                options.maxPendingPublications) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
      }
      final pending = await CalendarSchedulingDeliveryRecord.db.count(
        _session,
        where: (t) => t.scopeKey.equals(c.scopeKey) & t.terminalAt.equals(null),
        transaction: tx,
      );
      if (pending + proposals.length > options.maxScopeDeliveries) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final savedMeeting =
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
              scopeKey: c.scopeKey,
              meetingId: savedMeeting.id!,
              generation: savedMeeting.generation + 1,
              method: 'REQUEST',
              protocolUid: e.data.protocolUid,
              sequence: state.version.sequence!,
              stamp: state.version.stamp,
              snapshot: _schedulingSnapshot(proposed),
              projection: projection,
              payload: payload,
              payloadDigest: _schedulingDigest(payload),
              recipients: proposals,
              commandId: input.commandId,
              actorId: c.principalId,
              requestDigest: digest,
              expectedRevision: input.expectedRevision,
              eventRevision: proposed.revision,
              createdAt: now,
              expiresAt: now.add(options.expiry),
              outcome: 'pending',
            ),
            transaction: tx,
          );
      await CalendarSchedulingDeliveryRecord.db.insert(_session, [
        for (final route in authority.routes)
          CalendarSchedulingDeliveryRecord(
            scopeKey: c.scopeKey,
            publicationId: publication.id!,
            recipientAddress: route.address,
            routeRef: route.routeRef,
            nextAttemptAt: now,
          ),
      ], transaction: tx);
      savedMeeting.generation++;
      savedMeeting.revision++;
      savedMeeting.latestPublicationId = publication.id;
      savedMeeting.updatedAt = now;
      await CalendarSchedulingMeetingRecord.db.updateRow(
        _session,
        savedMeeting,
        transaction: tx,
      );
      e.data.content = content;
      e.data.protocolState = state;
      e.data.updatedAt = now;
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
        publishedEventCalendar:
            componentChanged || nextSequence != currentSequence
            ? e.identity.calendarId
            : null,
      );
      return CalendarSchedulingReceipt(
        publicationId: publication.id!,
        eventRevision: proposed.revision,
        unchanged: false,
      );
    });
  }

  Future<CalendarSchedulingView> schedulingStatus(UuidValue eventId) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final e = await _event(c, eventId, tx),
          binding = await _meeting(eventId, tx);
      final p = await _latest(binding, tx);
      final requests = _schedulingRequests(
        e,
        p == null
            ? null
            : CalendarSchedulingIntent(
                organizerAddress: binding!.organizerAddress,
                recipients: p.recipients,
                payload: p.payload,
                publicationId: p.id,
                generation: p.generation,
              ),
        write: false,
      );
      await _schedulingAuthorize(
        c,
        requests,
        tx,
        CalendarAuthorizationPhase.read,
      );
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
      await _verifyContext(c);
      return CalendarSchedulingView(
        eventId: eventId,
        eventRevision: e.identity.revision,
        origin: e.data.origin,
        organizerAddress: binding?.organizerAddress,
        publicationId: p?.id,
        publishedAt: p?.createdAt,
        hasLocalChanges:
            p == null ||
            p.projection !=
                _schedulingProjection(e.data.content, e.data.protocolState!),
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
}
