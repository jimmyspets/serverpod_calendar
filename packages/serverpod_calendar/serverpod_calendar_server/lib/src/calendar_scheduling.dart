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

bool _schedulingRecurring(CalendarEventContent value) =>
    value.recurrence?.rule != null ||
    (value.recurrence?.inclusions.isNotEmpty ?? false) ||
    (value.recurrence?.exclusions.isNotEmpty ?? false) ||
    (value.periods?.isNotEmpty ?? false);

bool _schedulingOverrides(CalendarEventTimingOverrides? value) =>
    (value?.singles.isNotEmpty ?? false) || (value?.future.isNotEmpty ?? false);

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

CalendarEventPolicySnapshot _schedulingPublished(
  CalendarSchedulingPublicationRecord p,
) => _schedulingReadCheckpoint(p).outgoing;

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

String _schedulingPayload(
  CalendarEventPolicySnapshot value,
  int maxBytes, {
  String method = 'REQUEST',
  List<EventSchedulingOriginal> projectionOriginals = const [],
}) {
  final bytes = eventExportBytes([
    method == 'REQUEST'
        ? _schedulingProjectionSource(value, projectionOriginals)
        : value,
  ]);
  if (method == 'REQUEST') {
    return utf8.decode(
      serializeIcalendarSchedulingMessage(
        projectIcalendarRequestFields(
          parseIcalendarEventCalendar(bytes),
          syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
        ),
        syntaxLimits: IcalendarSyntaxLimits(maxBytes: maxBytes),
      ),
    );
  }
  final source = parseIcalendarSyntax(bytes).components.single;
  final document = IcalendarSyntaxDocument([
    IcalendarSyntaxComponent('VCALENDAR', [
      ...source.entries.whereType<IcalendarSyntaxProperty>(),
      IcalendarSyntaxProperty('METHOD', method),
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

  Future<void> _requireSchedulingMode(
    UuidValue eventId,
    CalendarEventContent proposed,
    Transaction tx,
  ) async {
    final meeting = await _meeting(eventId, tx);
    if (meeting == null) return;
    final last = await _latest(meeting, tx);
    if (_schedulingRecurring(_schedulingPublished(last!).content) !=
        _schedulingRecurring(proposed)) {
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
    bool cancellation = false,
    CalendarEventPolicySnapshot? proposed,
  }) => [
    for (final op in [
      write
          ? cancellation
                ? CalendarPermission.cancelScheduling
                : CalendarPermission.publishScheduling
          : CalendarPermission.readScheduling,
      CalendarPermission.readEvent,
      CalendarPermission.readEventSource,
      if (write && !cancellation) CalendarPermission.updateEvent,
      if (write &&
          (cancellation || proposed!.content.status != e.data.content.status))
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
        proposedTimingOverrides: proposed?.timingOverrides,
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
      () => _scheduling.host.authorizeMessage(_session, value, tx, phase),
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
  ) => _publishScheduling(
    input.eventId,
    input.expectedRevision,
    input.commandId,
    input: input,
  );

  Future<CalendarSchedulingReceipt> cancelAndNotify(
    CalendarSchedulingCancelRequest input,
  ) => _publishScheduling(
    input.eventId,
    input.expectedRevision,
    input.commandId,
  );

  Future<CalendarSchedulingReceipt> _publishScheduling(
    UuidValue eventId,
    int expectedRevision,
    UuidValue commandId, {
    CalendarSchedulingSaveRequest? input,
  }) async {
    final cancellation = input == null;
    final method = cancellation ? 'CANCEL' : 'REQUEST';
    final requestedContent = input == null
            ? null
            : _validatedEvent(input.content),
        options = _scheduling.options;
    final requestedAddresses = input == null
        ? null
        : _schedulingAddresses(input.recipients, options.maxRecipients);
    final digest = _schedulingDigest(
      jsonEncode(
        cancellation
            ? ['CANCEL', eventId.toString(), expectedRevision]
            : [
                eventId.toString(),
                expectedRevision,
                requestedContent!.toJson(),
                requestedAddresses,
              ],
      ),
    );
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final e = await _event(c, eventId, tx);

      final meeting = await _meeting(e.identity.id!, tx);
      final last = await _latest(meeting, tx);
      final baseRequests = _schedulingRequests(
        e,
        null,
        write: true,
        cancellation: cancellation,
        proposed: e.snapshot,
      );
      await _schedulingAuthorize(
        c,
        baseRequests,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final previousCheckpoint = last == null
          ? null
          : _schedulingReadCheckpoint(last);
      if (previousCheckpoint != null &&
          (previousCheckpoint.canonical.eventId != e.identity.id ||
              previousCheckpoint.canonical.calendarId !=
                  e.identity.calendarId ||
              previousCheckpoint.outgoing.protocolUid != e.data.protocolUid)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (cancellation && (meeting == null || last == null)) {
        throw _failure(CalendarFailureCode.validation);
      }
      final proposals = cancellation
          ? _schedulingAddresses(last!.recipients, options.maxRecipients)
          : requestedAddresses!;
      var content = cancellation
          ? e.data.content.copyWith(status: CalendarEventStatus.cancelled)
          : requestedContent!;
      final retainedParameters = e.data.content.textParameters;
      if (content.textParameters == null) {
        content = content.copyWith(textParameters: retainedParameters);
      } else if (jsonEncode(content.textParameters!.toJson()) !=
          jsonEncode(retainedParameters?.toJson())) {
        throw _failure(CalendarFailureCode.validation);
      }

      if (e.data.origin != CalendarEventOrigin.native ||
          e.data.importBaseline != null ||
          _schedulingRecurring(content) !=
              _schedulingRecurring(e.data.content) ||
          !cancellation && content.status == CalendarEventStatus.cancelled) {
        throw _failure(CalendarFailureCode.validation);
      }
      final retry = await CalendarSchedulingPublicationRecord.db.findFirstRow(
        _session,
        where: (t) =>
            t.scopeKey.equals(c.scopeKey) & t.commandId.equals(commandId),
        transaction: tx,
      );
      if (retry != null &&
          (retry.method != method ||
              retry.actorId != c.principalId ||
              retry.requestDigest != digest ||
              retry.meetingId != meeting?.id)) {
        throw _failure(CalendarFailureCode.validation);
      }
      if (!cancellation &&
          retry == null &&
          (previousCheckpoint?.cancelled.isNotEmpty ?? false)) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (last != null &&
          _schedulingRecurring(previousCheckpoint!.outgoing.content) !=
              _schedulingRecurring(e.data.content)) {
        throw _failure(CalendarFailureCode.unavailable);
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
      final previousPublished = previousCheckpoint?.outgoing;
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
      final baseState = cancellation
          ? e.data.protocolState!.copyWith(statusPresent: true)
          : e.data.protocolState!.copyWith(sourceMetadata: source);
      final outgoingContent = cancellation
          ? previousPublished!.content.copyWith(
              status: CalendarEventStatus.cancelled,
            )
          : content;
      final projection = _schedulingProjection(content, baseState);
      final unchanged =
          last != null &&
          last.method == method &&
          (cancellation
              ? previousCheckpoint!.kind ==
                        CalendarSchedulingPublicationKind.seriesCancel &&
                    e.data.content.status == CalendarEventStatus.cancelled
              : _schedulingCanonicalKey(previousCheckpoint!.canonical) ==
                        _schedulingCanonicalKey(
                          CalendarEventPolicySnapshot(
                            e.identity.id!,
                            e.identity.calendarId,
                            e.identity.revision,
                            content,
                            e.data.protocolUid,
                            e.data.updatedAt,
                            protocolState: baseState,
                            timingOverrides: e.data.timingOverrides,
                          ),
                        ) &&
                    _schedulingProjection(
                          e.data.content,
                          e.data.protocolState!,
                        ) ==
                        projection &&
                    _schedulingValue(
                      () => _schedulingWireUnchanged(
                        CalendarEventPolicySnapshot(
                          e.identity.id!,
                          e.identity.calendarId,
                          e.identity.revision,
                          content,
                          e.data.protocolUid,
                          e.data.updatedAt,
                          protocolState: baseState,
                          timingOverrides: e.data.timingOverrides,
                        ),
                        previousCheckpoint,
                        options.maxPayloadBytes,
                      ),
                    ));
      if (retry == null) _eventRevision(e, expectedRevision);
      // Queue eligibility/expiry use raw database time, independent of audit floors.
      final queuedAt = await _revisionTime(tx);
      final now = queuedAt.isBefore(e.data.updatedAt)
          ? e.data.updatedAt
          : queuedAt;
      final componentChanged =
          _schedulingProjection(e.data.content, e.data.protocolState!) !=
          projection;
      final currentSequence = e.data.protocolState!.version.sequence ?? 0;
      final currentNativeMaximum = e.data.protocolState!.overrides.fold(
        currentSequence,
        (int value, component) => max(value, component.version.sequence ?? 0),
      );
      final previousMaximum = previousCheckpoint == null
          ? -1
          : previousCheckpoint.ledger.fold(
              previousCheckpoint.cancelled.fold(
                last!.sequence,
                (int a, r) => max(a, r.version.sequence),
              ),
              (int a, v) => max(a, v.sequence),
            );
      final masterUnchanged =
          !cancellation &&
          last?.method == 'REQUEST' &&
          _schedulingProjection(
                previousPublished!.content,
                previousPublished.protocolState!,
              ) ==
              projection;
      final nextSequence = cancellation
          ? max(currentNativeMaximum, previousMaximum) + 1
          : masterUnchanged
          ? last!.sequence
          : max(
              currentSequence + (componentChanged ? 1 : 0),
              (last?.sequence ?? -1) + 1,
            );
      if (retry == null && !unchanged && nextSequence > eventMaxSequence) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      DateTime latest(DateTime a, DateTime? b) =>
          b != null && b.isAfter(a) ? b : a;
      var versionTime = latest(
        latest(now, baseState.version.stamp),
        previousPublished?.protocolState?.version.stamp,
      );
      for (final row
          in previousCheckpoint?.cancelled ?? <_SchedulingCancellation>[]) {
        versionTime = latest(versionTime, row.version.stamp);
      }
      final modifiedTime = latest(
        latest(versionTime, baseState.version.lastModified),
        previousPublished?.protocolState?.version.lastModified,
      );
      final state =
          retry != null ||
              unchanged ||
              masterUnchanged ||
              !cancellation &&
                  !componentChanged &&
                  nextSequence == currentSequence
          ? e.data.protocolState!
          : _eventProtocolValue(
              () => validateEventProtocolState(
                baseState.copyWith(
                  version: baseState.version.copyWith(
                    sequence: nextSequence,
                    stamp: eventProtocolInstant(versionTime),
                    lastModified: eventProtocolInstant(modifiedTime),
                  ),
                ),
                content,
                e.data.timingOverrides,
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
        retry != null || unchanged ? e.data.updatedAt : now,
        origin: e.data.origin,
        timingOverrides: e.data.timingOverrides,
        protocolState: state,
      );
      final receiptPublication = retry ?? (unchanged ? last : null);
      final outgoingState = cancellation && receiptPublication == null
          ? _eventProtocolValue(
              () => validateEventProtocolState(
                previousPublished!.protocolState!.copyWith(
                  overrides: [],
                  statusPresent: true,
                  version: previousPublished.protocolState!.version.copyWith(
                    sequence: nextSequence,
                    stamp: state.version.stamp,
                    lastModified: state.version.lastModified,
                  ),
                ),
                outgoingContent,
                null,
              ),
            )
          : masterUnchanged && receiptPublication == null
          ? state.copyWith(
              version: state.version.copyWith(
                sequence: last!.sequence,
                stamp: last.stamp,
              ),
            )
          : state;
      final outgoing = receiptPublication == null
          ? CalendarEventPolicySnapshot(
              proposed.eventId,
              proposed.calendarId,
              proposed.revision,
              outgoingContent,
              proposed.protocolUid,
              proposed.updatedAt,
              origin: proposed.origin,
              timingOverrides: cancellation ? null : proposed.timingOverrides,
              protocolState: cancellation
                  ? outgoingState.copyWith(overrides: [])
                  : outgoingState,
            )
          : _schedulingPublished(receiptPublication);

      final projectionOriginals = cancellation
          ? previousCheckpoint!.projectionOriginals
          : receiptPublication != null
          ? _schedulingReadCheckpoint(receiptPublication).projectionOriginals
          : _schedulingResetOriginals(outgoing, previousCheckpoint);

      var payload =
          receiptPublication?.payload ??
          _schedulingValue<String>(
            () => _schedulingPayload(
              outgoing,
              options.maxPayloadBytes,
              method: method,
              projectionOriginals: projectionOriginals,
            ),
          );
      if (receiptPublication == null && !cancellation) {
        payload = _schedulingValue(
          () => _schedulingVersionedPayload(
            payload,
            previousCheckpoint,
            now,
            options.maxPayloadBytes,
          ),
        );
      }
      final outgoingMessage = _schedulingValue(
        () => parseIcalendarSchedulingMessage(
          utf8.encode(payload),
          syntaxLimits: IcalendarSyntaxLimits(
            maxBytes: options.maxPayloadBytes,
          ),
        ),
      );
      final components = _schedulingValue(
        () => _schedulingComponents(outgoingMessage),
      );
      final ledger = cancellation ? previousCheckpoint!.ledger : components;
      // Validate/bound private storage before policy callbacks or any write.
      var checkpoint =
          receiptPublication?.snapshot ??
          _schedulingWriteCheckpoint(
            proposed,
            outgoing,
            ledger,
            projectionOriginals,
          );
      var bundleProjection =
          receiptPublication?.projection ??
          _schedulingBundleProjection(components);
      if (receiptPublication == null &&
          cancellation &&
          previousCheckpoint!.cancelled.isNotEmpty) {
        final masterRecord = last!.copyWith(
          snapshot: checkpoint,
          projection: bundleProjection,
          payload: payload,
          payloadDigest: _schedulingDigest(payload),
          method: 'CANCEL',
          sequence: components.single.sequence,
          stamp: components.single.stamp,
        );
        checkpoint = _schedulingWriteV4(
          canonical: proposed,
          kind: CalendarSchedulingPublicationKind.seriesCancel,
          basis: previousCheckpoint.basisRecord!,
          cancelled: previousCheckpoint.cancelled,
          masterMessage: masterRecord,
        );
        bundleProjection = _schedulingV4Projection(
          CalendarSchedulingPublicationKind.seriesCancel,
          null,
          components,
        );
      }
      final intent = CalendarSchedulingIntent(
        method: method,
        publicationKind: cancellation
            ? CalendarSchedulingPublicationKind.seriesCancel
            : CalendarSchedulingPublicationKind.request,
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
        cancellation: cancellation,
        proposed: proposed,
      );
      final hostContext = CalendarSchedulingPolicyContext(
        scopeKey: c.scopeKey,
        actor: c,
        calendar: e.parent.snapshot,
        currentEvent: e.snapshot,
        proposedEvent: proposed,
        publicationEvent: receiptPublication == null
            ? proposed
            : _schedulingReadCheckpoint(receiptPublication).canonical,
        outgoingMessage: outgoingMessage,
        payloadDigest: _schedulingDigest(payload),
        authority: authority,
        intent: intent,
        publishedRequest: previousCheckpoint?.basisRecord == null
            ? null
            : _schedulingReadCheckpoint(previousCheckpoint!.basisRecord!)
                  .outgoing,
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
            createdAt: queuedAt,
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
              method: method,
              protocolUid: e.data.protocolUid,
              sequence: outgoingMessage.events
                  .singleWhere((e) => !e.isOverride)
                  .sequence!,
              stamp: outgoingMessage.events
                  .singleWhere((e) => !e.isOverride)
                  .stamp,
              snapshot: checkpoint,
              projection: bundleProjection,
              payload: payload,
              payloadDigest: _schedulingDigest(payload),
              recipients: proposals,
              commandId: commandId,
              actorId: c.principalId,
              requestDigest: digest,
              expectedRevision: expectedRevision,
              eventRevision: proposed.revision,
              createdAt: queuedAt,
              expiresAt: queuedAt.add(options.expiry),
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
            nextAttemptAt: queuedAt,
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
                method: p.method,
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
      final checkpoint = p == null ? null : _schedulingReadCheckpoint(p);
      if (checkpoint?.kind ==
          CalendarSchedulingPublicationKind.occurrenceCancel) {
        await _schedulingAuthorize(
          c,
          _schedulingRequests(
            e,
            CalendarSchedulingIntent(
              method: p!.method,
              publicationKind: checkpoint!.kind,
              originalStart: checkpoint.target,
              organizerAddress: binding!.organizerAddress,
              recipients: p.recipients,
              payload: p.payload,
              publicationId: p.id,
              generation: p.generation,
            ),
            write: false,
          ),
          tx,
          CalendarAuthorizationPhase.read,
        );
      }
      if (checkpoint != null &&
          (checkpoint.canonical.eventId != e.identity.id ||
              checkpoint.canonical.calendarId != e.identity.calendarId ||
              checkpoint.outgoing.protocolUid != e.data.protocolUid)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      return CalendarSchedulingView(
        eventId: eventId,
        eventRevision: e.identity.revision,
        origin: e.data.origin,
        organizerAddress: binding?.organizerAddress,
        publicationId: p?.id,
        publishedAt: p?.createdAt,
        method: p?.method,
        publicationKind: checkpoint?.kind,
        originalStart: checkpoint?.target,
        hasOccurrenceCancellations: checkpoint?.cancelled.isNotEmpty ?? false,
        hasLocalChanges:
            p == null ||
            _schedulingCanonicalKey(
                  _schedulingValue(() => _schedulingExpectedState(checkpoint!)),
                ) !=
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
}
