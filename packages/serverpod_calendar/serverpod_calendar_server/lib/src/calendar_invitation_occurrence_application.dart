part of 'calendar_module.dart';

typedef _OccurrenceAccepted = ({
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState protocol,
});

_OccurrenceAccepted _occAccepted(CalendarEventImportBaseline baseline) {
  final value = jsonDecode(baseline.canonicalValue) as Map<String, dynamic>;
  // Canonical baselines omit empty participant parameter maps.
  void restore(Object? node) {
    if (node is Map) {
      final metadata = node['sourceMetadata'];
      if (metadata is Map) {
        final participants = [
          metadata['organizer'],
          ...?metadata['attendees'] as List?,
        ];
        for (final p in participants) {
          if (p is Map) {
            p.putIfAbsent('parameters', () => <String, dynamic>{});
          }
        }
      }
      for (final child in node.values) {
        restore(child);
      }
    } else if (node is List) {
      for (final child in node) {
        restore(child);
      }
    }
  }

  restore(value);
  return (
    content: CalendarEventContent.fromJson(value['content']),
    edits: value['edits'] == null
        ? null
        : CalendarEventTimingOverrides.fromJson(value['edits']),
    protocol: CalendarEventProtocolState.fromJson(value['protocol']),
  );
}

Object? _occOrdered(Object? value) {
  if (value is Map) {
    final keys = value.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: _occOrdered(value[key])};
  }
  if (value is List) {
    return value.map(_occOrdered).toList();
  }
  return value;
}

String _occComponent(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
  String sourceDigest,
) {
  final key = eventComponentKey(original, false);
  final edit = accepted.edits?.singles
      .where((v) => eventComponentKey(v.originalStart, false) == key)
      .firstOrNull;
  final version = accepted.protocol.overrides
      .where(
        (v) =>
            !v.isThisAndFuture &&
            eventComponentKey(v.originalStart, false) == key,
      )
      .firstOrNull;
  return _invitationHash([
    sourceDigest,
    jsonEncode(_occOrdered(edit?.toJson())),
    jsonEncode(_occOrdered(version?.toJson())),
  ]);
}

CalendarEventProtocolVersion _occFloor(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
) {
  final single = accepted.protocol.overrides
      .where(
        (v) => !v.isThisAndFuture && _replySamePoint(v.originalStart, original),
      )
      .firstOrNull;
  if (single != null) return single.version;
  final ranges =
      accepted.protocol.overrides
          .where(
            (v) =>
                v.isThisAndFuture &&
                _replyPointOrder(v.originalStart)
                        .compareTo(_replyPointOrder(original)) <=
                    0,
          )
          .toList()
        ..sort(
          (a, b) =>
              _replyPointOrder(a.originalStart)
                  .compareTo(_replyPointOrder(b.originalStart)),
        );
  return ranges.lastOrNull?.version ?? accepted.protocol.version;
}

CalendarEventContent? _occEffective(
  _OccurrenceAccepted accepted,
  CalendarEventTiming original,
) {
  final key = eventComponentKey(original, false);
  final edits = accepted.edits?.copyWith(
    singles: [
      for (final s in accepted.edits!.singles)
        eventComponentKey(s.originalStart, false) == key
            ? s.copyWith(cancelled: false)
            : s,
    ],
  );
  final value = eventSchedulingOccurrence(
    accepted.content,
    edits,
    original,
    sharedWorkBudget: RecurrenceWorkBudget(maxWork: eventMaxCandidateWork),
  );
  final cancelled =
      accepted.edits?.singles.any(
        (s) => s.cancelled && eventComponentKey(s.originalStart, false) == key,
      ) ??
      false;
  return cancelled
      ? value?.copyWith(status: CalendarEventStatus.cancelled)
      : value;
}

extension CalendarInvitationOccurrenceApplicationOperations on CalendarService {
  Future<CalendarInvitationOccurrenceApplicationRecord?> _occRow(
    UuidValue linkId,
    Transaction tx,
  ) => CalendarInvitationOccurrenceApplicationRecord.db.findFirstRow(
    _session,
    where: (t) => t.linkId.equals(linkId),
    transaction: tx,
  );

  String _occMasterDigest(
    CalendarInvitationLinkRecord link,
    CalendarInvitationApplicationRecord? master,
  ) =>
      _invitationHash([_invCreationDigest(link), jsonEncode(master?.toJson())]);

  Map<String, dynamic> _occDecode(
    CalendarInvitationLinkRecord link,
    _Event event,
    CalendarInvitationOccurrenceApplicationRecord row,
    CalendarInvitationApplicationRecord? master,
  ) {
    try {
      if (row.scopeKey != link.scopeKey ||
          row.recipientKey != link.recipientKey ||
          row.linkId != link.id ||
          row.revision < 1 ||
          row.revision > CalendarService._maxRevision ||
          row.eventRevision < 2 ||
          row.eventRevision > event.identity.revision ||
          utf8.encode(row.stateJson).length > 4194304) {
        throw StateError('Invalid checkpoint');
      }
      final state = jsonDecode(row.stateJson) as Map<String, dynamic>;
      if (!{1, 2}.contains(state['version']) ||
          state['masterDigest'] != _occMasterDigest(link, master) ||
          state['baselineDigest'] !=
              _invBaselineDigest(event.data.importBaseline!)) {
        throw StateError('Invalid checkpoint binding');
      }
      final frozen = CalendarEventImportBaseline.fromJson(
        state['masterBaseline'],
      );
      validateEventImportBaseline(frozen, link.uid);
      if (state['masterBaselineDigest'] != _invBaselineDigest(frozen)) {
        throw StateError('Invalid frozen baseline');
      }
      final targets = (state['targets'] as List).cast<Map<String, dynamic>>();
      if (targets.isEmpty || targets.length > 128) {
        throw StateError('Invalid targets');
      }
      final accepted = _occAccepted(event.data.importBaseline!);
      final seen = <String>{};
      for (final target in targets) {
        if (target['reopened'] is! bool) {
          throw StateError('Invalid lifecycle evidence');
        }
        final original = CalendarEventTiming.fromJson(target['original']);
        final key = _invTargetKey(original);
        final text = target['source'] as String;
        if (!seen.add(key) ||
            key != target['key'] ||
            utf8.encode(text).length > 262144 ||
            sha256.convert(utf8.encode(text)).toString() != target['digest'] ||
            _occComponent(accepted, original, target['digest'] as String) !=
                target['component']) {
          throw StateError('Invalid target');
        }
        final message = _invParse(utf8.encode(text), stored: true);
        final source = message.events.single;
        final version = CalendarEventProtocolVersion.fromJson(
          target['version'],
        );
        validateEventProtocolVersion(version);
        final single = accepted.edits?.singles
            .where((v) => _replySamePoint(v.originalStart, original))
            .single;
        if (message.uid != link.uid ||
            source.participants.organizer?.address != link.organizer ||
            !source.participants.attendees.any(
              (a) => a.address == target['recipientAddress'],
            ) ||
            !_replySamePoint(_replyOriginal(source), original) ||
            _invKind(message).name != target['kind'] ||
            source.sequence != version.sequence ||
            source.stamp != version.stamp ||
            source.created != version.created ||
            source.lastModified != version.lastModified ||
            jsonEncode(_occFloor(accepted, original).toJson()) !=
                jsonEncode(version.toJson()) ||
            single == null ||
            single.cancelled !=
                (message.method == IcalendarSchedulingMethod.cancel)) {
          throw StateError('Invalid accepted component');
        }
        UuidValue.fromString(target['invitationId']);
        UuidValue.fromString(target['sourceId']);
        final time = DateTime.parse(target['acceptedAt']);
        if (time.isAfter(row.updatedAt)) {
          throw StateError('Invalid acceptance time');
        }
      }
      final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
        state['receipt'],
      );
      final selected = targets
          .where((t) => t['key'] == _invTargetKey(receipt.originalStart))
          .single;
      if (receipt.linkId != link.id ||
          receipt.calendarId != link.calendarId ||
          receipt.eventId != link.eventId ||
          receipt.occurrenceRevision < 1 ||
          receipt.occurrenceRevision > row.revision ||
          receipt.eventRevision < 2 ||
          receipt.eventRevision > row.eventRevision ||
          receipt.appliedAt != DateTime.parse(selected['acceptedAt']) ||
          (state['version'] == 1 &&
              (receipt.occurrenceRevision != row.revision ||
                  receipt.eventRevision != row.eventRevision ||
                  receipt.appliedAt != row.updatedAt)) ||
          receipt.invitationId.toString() != selected['invitationId'] ||
          receipt.sourceId.toString() != selected['sourceId'] ||
          receipt.kind.name != selected['kind'] ||
          !RegExp(r'^[0-9a-f]{64}$')
              .hasMatch(state['requestDigest'] as String)) {
        throw StateError('Invalid result');
      }
      if (state['version'] == 2) {
        if (state['receiptDigest'] !=
            _invitationHash([
              state['requestDigest'] as String,
              jsonEncode(_occOrdered(receipt.toJson())),
              selected['digest'] as String,
            ])) {
          throw StateError('Invalid retained result binding');
        }
        final layer = _occAccepted(frozen);
        final composed = _invCompose(
          CalendarEventImportMember(
            eventId: link.eventId,
            protocolUid: link.uid,
            content: layer.content,
            timingOverrides: layer.edits,
            protocolState: layer.protocol,
          ),
          event,
          state,
        );
        if (eventImportBaseline(
              link.uid,
              composed.content,
              composed.timingOverrides,
              composed.protocolState,
            ).canonicalValue !=
            event.data.importBaseline!.canonicalValue) {
          throw StateError('Invalid composition');
        }
      }
      return state;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  CalendarInvitationOccurrenceApplicationSnapshot? _occSnapshot(
    CalendarInvitationOccurrenceApplicationRecord? row,
  ) => row == null
      ? null
      : CalendarInvitationOccurrenceApplicationSnapshot(
          revision: row.revision,
          stateJson: row.stateJson,
          eventRevision: row.eventRevision,
          updatedAt: row.updatedAt,
        );

  Future<CalendarInvitationLinkRecord?> _occLink(
    CalendarInvitationRecord? entry,
    CalendarInvitationRecipient recipient,
    Transaction tx, {
    UuidValue? retainedLink,
  }) async {
    if (entry != null) {
      _invTargetValid(entry);
      if (entry.targetKey == 'master') {
        throw _failure(CalendarFailureCode.validation);
      }
    }
    final candidate = entry == null
        ? retainedLink == null
              ? null
              : await CalendarInvitationLinkRecord.db.findById(
                  _session,
                  retainedLink,
                  transaction: tx,
                )
        : await CalendarInvitationLinkRecord.db.findFirstRow(
            _session,
            where: (t) =>
                t.scopeKey.equals(recipient.scopeKey) &
                t.recipientKey.equals(recipient.key) &
                t.correlationDigest.equals(entry.correlationDigest),
            transaction: tx,
          );
    if (candidate == null ||
        candidate.scopeKey != recipient.scopeKey ||
        candidate.recipientKey != recipient.key) {
      return null;
    }
    final link = await _invFindLink(
      candidate.invitationId,
      null,
      recipient,
      tx,
    );
    if (entry != null &&
        (entry.uid != link?.uid || entry.organizer != link?.organizer)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    return link;
  }

  Future<void> _occHost(
    CalendarHostContext actor,
    CalendarInvitationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    required CalendarInvitationOperation operation,
    CalendarInvitationView? view,
    CalendarInvitationLinkRecord? link,
    _Event? event,
    CalendarEventPolicySnapshot? before,
    CalendarEventPolicySnapshot? proposed,
    IcalendarSchedulingMessage? message,
    String? text,
    CalendarInvitationApplicationState? master,
    CalendarInvitationOccurrenceApplicationRecord? current,
    CalendarInvitationOccurrenceApplicationRecord? next,
    CalendarInvitationOccurrenceApplyRequest? request,
    CalendarInvitationOccurrenceApplyReceipt? receipt,
    CalendarEventImportBaseline? baseline,
    bool? dirty,
    bool? historicalUnavailable,
    bool retry = false,
  }) async {
    for (final op in {
      CalendarInvitationOperation.readSummary,
      CalendarInvitationOperation.readSource,
      CalendarInvitationOperation.readLink,
      CalendarInvitationOperation.readApplication,
      CalendarInvitationOperation.readOccurrenceApplication,
      operation,
    }) {
      await _invAuthorize(
        CalendarInvitationPolicyContext(
          operation: op,
          actor: actor,
          recipient: recipient,
          current: view,
          entryId: request?.invitationId ?? view?.id,
          sourceId: request?.sourceId ?? view?.sourceId,
          message: message,
          normalizedSource: text,
          sourceDigest: text == null
              ? null
              : sha256.convert(utf8.encode(text)).toString(),
          link: link == null ? null : _invLinkReceipt(link),
          linkSource: link == null ? null : _invLinkSource(link),
          calendar: event?.parent.snapshot,
          currentEvent: before ?? event?.snapshot,
          proposedEvent: proposed,
          currentApplication: master,
          currentOccurrenceApplication: _occSnapshot(current),
          proposedOccurrenceApplication: _occSnapshot(next),
          occurrenceRequest: request,
          occurrenceReceipt: receipt,
          proposedBaseline: baseline,
          localChanges: dirty,
          isRetry: retry,
          historicalSourceUnavailable:
              historicalUnavailable ?? (message == null ? null : false),
          proposedDismissed: next == null ? null : true,
          proposedRevision: receipt?.invitationRevision,
        ),
        tx,
        phase,
      );
    }
  }

  Future<void> _occQuota(
    CalendarInvitationRecipient recipient,
    CalendarInvitationOccurrenceApplicationRecord next,
    Transaction tx,
  ) async {
    final size = utf8.encode(next.stateJson).length;
    if (size > _invOptions.maxOccurrenceCheckpointBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final rows = await CalendarInvitationOccurrenceApplicationRecord.db.find(
      _session,
      where: (t) => t.scopeKey.equals(recipient.scopeKey),
      transaction: tx,
    );
    var scopeBytes = size, recipientBytes = size;
    for (final row in rows) {
      if (row.linkId == next.linkId) {
        continue;
      }
      final bytes = utf8.encode(row.stateJson).length;
      scopeBytes += bytes;
      if (row.recipientKey == recipient.key) {
        recipientBytes += bytes;
      }
    }
    if (scopeBytes > _invOptions.maxScopeOccurrenceBytes ||
        recipientBytes > _invOptions.maxRecipientOccurrenceBytes) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  Future<CalendarInvitationOccurrenceApplicationView>
  invitationOccurrenceApplication(UuidValue id) => _invNativeScoped((
    actor,
    recipient,
    tx,
    scope,
  ) async {
    final entry = await _invEntry(id, recipient, tx);
    final view = await _invView(entry, tx);
    await _occHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readOccurrenceApplication,
      view: view,
    );
    final link = await _occLink(entry, recipient, tx);
    if (link == null) throw _failure(CalendarFailureCode.accessDenied);
    final event = await _invLinkedEvent(link, actor, tx);
    await _invApplicationNative(
      actor,
      event,
      tx,
      CalendarAuthorizationPhase.read,
    );
    final masterRow = await _invCheckpoint(link, event, tx);
    final master = await _invApplicationState(link, event, masterRow, tx);
    final row = await _occRow(link.id!, tx);
    final state = row == null ? null : _occDecode(link, event, row, masterRow);
    final accepted = _occAccepted(event.data.importBaseline!);
    final target = (state?['targets'] as List?)
        ?.cast<Map<String, dynamic>>()
        .where((v) => v['key'] == entry.targetKey)
        .firstOrNull;
    final source = entry.currentSourceId == null
        ? null
        : await CalendarInvitationSourceRecord.db.findById(
            _session,
            entry.currentSourceId!,
            transaction: tx,
          );
    final message = source == null ? null : _invStored(source, entry);
    final dirty = _invLocalChanges(event);
    final floor = _occFloor(accepted, entry.originalStart!);
    CalendarInvitationOccurrenceProjection? projection;
    if (message != null) {
      try {
        projection = projectInvitationOccurrence(
          protocolUid: link.uid,
          content: accepted.content,
          timingOverrides: accepted.edits,
          protocolState: accepted.protocol,
          message: message,
          recipientAddress: recipient.calendarAddress,
        );
      } on ArgumentError {
        /* Unsupported proposed differences remain reviewable. */
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
    }
    final cancelled =
        target?['kind'] ==
        CalendarInvitationSourceKind.instanceCancellation.name;
    final newer =
        message != null && _occNewer(message, floor, cancelled: cancelled);
    await _occHost(
      actor,
      recipient,
      tx,
      CalendarAuthorizationPhase.read,
      operation: CalendarInvitationOperation.readOccurrenceApplication,
      view: view,
      link: link,
      event: event,
      message:
          message ??
          (target == null
              ? null
              : _invParse(
                  utf8.encode(target['source'] as String),
                  stored: true,
                )),
      text: source?.normalizedSource ?? target?['source'] as String?,
      historicalUnavailable: message == null && target == null,
      master: master,
      current: row,
      dirty: dirty,
    );
    CalendarEventContent? effective(_OccurrenceAccepted a) {
      try {
        return _occEffective(a, entry.originalStart!);
      } on ArgumentError {
        return null;
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
    }

    final latest = state == null
        ? null
        : CalendarInvitationOccurrenceApplyReceipt.fromJson(state['receipt']);
    return CalendarInvitationOccurrenceApplicationView(
      linkId: link.id!,
      invitationId: id,
      calendarId: link.calendarId,
      eventId: link.eventId,
      calendarRevision: event.parent.identity.revision,
      eventRevision: event.identity.revision,
      applicationRevision: master.revision,
      occurrenceRevision: row?.revision ?? 0,
      originalStart: entry.originalStart!,
      hasLocalChanges: dirty,
      acceptedVersion: floor,
      acceptedKind: target == null
          ? master.kind
          : cancelled
          ? CalendarInvitationSourceKind.instanceCancellation
          : CalendarInvitationSourceKind.request,
      currentOccurrence: effective((
        content: event.data.content,
        edits: event.data.timingOverrides,
        protocol: event.data.protocolState!,
      )),
      proposedOccurrence: projection == null
          ? null
          : effective((
              content: projection.content,
              edits: projection.timingOverrides,
              protocol: projection.protocolState,
            )),
      incomingKind: message == null ? null : _invKind(message),
      incomingSourceId: source?.id,
      invitationRevision: entry.revision,
      incomingVersion: message == null ? null : _occVersion(message),
      incomingSourceText: source?.normalizedSource,
      acceptedSourceText: target?['source'] as String?,
      canApply:
          projection != null && newer && !dirty && entry.dismissedAt == null,
      latestResult:
          latest != null &&
              _replySamePoint(latest.originalStart, entry.originalStart)
          ? latest
          : null,
    );
  });

  CalendarEventProtocolVersion _occVersion(IcalendarSchedulingMessage m) {
    final s = m.events.single;
    return CalendarEventProtocolVersion(
      sequence: s.sequence,
      stamp: s.stamp,
      created: s.created,
      lastModified: s.lastModified,
    );
  }

  bool _occNewer(
    IcalendarSchedulingMessage message,
    CalendarEventProtocolVersion floor, {
    required bool cancelled,
  }) =>
      _invSourceOrder(
            message.events.single.sequence,
            message.events.single.stamp,
            floor.sequence,
            floor.stamp,
          ) >
          0 &&
      (!(message.method == IcalendarSchedulingMethod.cancel || cancelled) ||
          (message.events.single.sequence ?? 0) > (floor.sequence ?? 0));

  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationOccurrenceUpdate(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, false);
  Future<CalendarInvitationOccurrenceApplyReceipt>
  applyInvitationOccurrenceCancellation(
    CalendarInvitationOccurrenceApplyRequest request,
  ) => _occApply(request, true);

  Future<CalendarInvitationOccurrenceApplyReceipt> _occApply(
    CalendarInvitationOccurrenceApplyRequest input,
    bool cancellation,
  ) {
    if ([
          input.expectedInvitationRevision,
          input.expectedEventRevision,
          input.expectedCalendarRevision,
        ].any((r) => r < 1 || r > CalendarService._maxRevision) ||
        [
          input.expectedApplicationRevision,
          input.expectedOccurrenceRevision,
        ].any((r) => r < 0 || r > CalendarService._maxRevision)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final operation = cancellation
        ? CalendarInvitationOperation.applyOccurrenceCancellation
        : CalendarInvitationOperation.applyOccurrenceUpdate;
    final digest = _invitationHash([
      'occurrence-apply-v1',
      operation.name,
      jsonEncode(input.toJson()),
    ]);
    return _invNativeScoped((actor, recipient, tx, scope) async {
      final entry = await _invOptionalEntry(input.invitationId, recipient, tx);
      final view = entry == null ? null : await _invView(entry, tx);
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        request: input,
      );
      final link = await _occLink(
        entry,
        recipient,
        tx,
        retainedLink: input.linkId,
      );
      if (link == null || link.id != input.linkId) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final event = await _invLinkedEvent(link, actor, tx),
          before = event.snapshot;
      final masterRow = await _invCheckpoint(link, event, tx),
          master = await _invApplicationState(link, event, masterRow, tx);
      final row = await _occRow(link.id!, tx);
      final state = row == null
          ? null
          : _occDecode(link, event, row, masterRow);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation,
      );
      if (state?['requestDigest'] == digest) {
        final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
          state!['receipt'],
        );
        if (receipt.invitationId != input.invitationId ||
            receipt.sourceId != input.sourceId ||
            (receipt.kind ==
                    CalendarInvitationSourceKind.instanceCancellation) !=
                cancellation) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final target = (state['targets'] as List)
            .cast<Map<String, dynamic>>()
            .singleWhere(
              (v) => v['key'] == _invTargetKey(receipt.originalStart),
            );
        final message = _invParse(
          utf8.encode(target['source'] as String),
          stored: true,
        );
        for (final phase in [
          CalendarAuthorizationPhase.preliminaryWrite,
          CalendarAuthorizationPhase.finalWrite,
        ]) {
          await _invApplicationNative(
            actor,
            event,
            tx,
            phase,
            writing: true,
            cancellation: cancellation,
          );
          if (!cancellation && target['reopened'] == true) {
            await _occLifecycle(actor, event, tx, phase);
          }
          await _occHost(
            actor,
            recipient,
            tx,
            phase,
            operation: operation,
            view: view,
            link: link,
            event: event,
            message: message,
            text: target['source'],
            master: master,
            current: row,
            request: input,
            receipt: receipt,
            dirty: _invLocalChanges(event),
            retry: true,
          );
        }
        return receipt;
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        master: master,
        current: row,
        request: input,
      );
      if (entry == null ||
          entry.revision != input.expectedInvitationRevision ||
          entry.currentSourceId != input.sourceId ||
          entry.dismissedAt != null ||
          event.identity.revision != input.expectedEventRevision ||
          event.parent.identity.revision != input.expectedCalendarRevision ||
          master.revision != input.expectedApplicationRevision ||
          (row?.revision ?? 0) != input.expectedOccurrenceRevision) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      final source = await CalendarInvitationSourceRecord.db.findById(
        _session,
        input.sourceId,
        transaction: tx,
      );
      if (source == null || source.entryId != entry.id) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final message = _invStored(source, entry);
      if ((message.method == IcalendarSchedulingMethod.cancel) !=
          cancellation) {
        throw _failure(CalendarFailureCode.validation);
      }
      final accepted = _occAccepted(event.data.importBaseline!);
      final target = (state?['targets'] as List?)
          ?.cast<Map<String, dynamic>>()
          .where((v) => v['key'] == entry.targetKey)
          .firstOrNull;
      final cancelled =
          accepted.edits?.singles.any(
            (v) =>
                v.cancelled &&
                _replySamePoint(v.originalStart, entry.originalStart),
          ) ??
          false;
      final dirty = _invLocalChanges(event);
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        request: input,
        dirty: dirty,
      );
      if (dirty ||
          !_occNewer(
            message,
            _occFloor(accepted, entry.originalStart!),
            cancelled: cancelled,
          )) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (target != null &&
          target['recipientAddress'] != recipient.calendarAddress) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
      final projected = _eventReplacementValue(
        () => projectInvitationOccurrence(
          protocolUid: link.uid,
          content: accepted.content,
          timingOverrides: accepted.edits,
          protocolState: accepted.protocol,
          message: message,
          recipientAddress: recipient.calendarAddress,
        ),
      );
      final member = CalendarEventImportMember(
        eventId: link.eventId,
        protocolUid: link.uid,
        content: projected.content,
        timingOverrides: projected.timingOverrides,
        protocolState: projected.protocolState,
      );
      final baseline = eventImportBaseline(
        link.uid,
        member.content,
        member.timingOverrides,
        member.protocolState,
      );
      if ([
        event.identity.revision,
        entry.revision,
        row?.revision ?? 0,
      ].any((v) => v == CalendarService._maxRevision)) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final now = await _revisionTime(
        tx,
        previous: event.data.updatedAt.isAfter(entry.updatedAt)
            ? event.data.updatedAt
            : entry.updatedAt,
      );
      final receipt = CalendarInvitationOccurrenceApplyReceipt(
        id: const Uuid().v4obj(),
        kind: _invKind(message),
        originalStart: entry.originalStart!,
        linkId: link.id!,
        invitationId: entry.id!,
        sourceId: source.id!,
        calendarId: link.calendarId,
        eventId: link.eventId,
        occurrenceRevision: (row?.revision ?? 0) + 1,
        eventRevision: event.identity.revision + 1,
        invitationRevision: entry.revision + 1,
        appliedAt: now,
      );
      final targets = <Map<String, dynamic>>[
        for (final v
            in (state?['targets'] as List? ?? []).cast<Map<String, dynamic>>())
          if (v['key'] != entry.targetKey) v,
        {
          'key': entry.targetKey,
          'original': entry.originalStart!.toJson(),
          'kind': receipt.kind.name,
          'invitationId': entry.id.toString(),
          'sourceId': source.id.toString(),
          'source': source.normalizedSource,
          'digest': source.digest,
          'version': _occVersion(message).toJson(),
          'recipientAddress': recipient.calendarAddress,
          'acceptedAt': now.toIso8601String(),
          'reopened': !cancellation && cancelled,
          'component': _occComponent(
            (
              content: member.content,
              edits: member.timingOverrides,
              protocol: member.protocolState,
            ),
            entry.originalStart!,
            source.digest,
          ),
        },
      ];
      if (targets.length > 128) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final next = CalendarInvitationOccurrenceApplicationRecord(
        id: row?.id ?? const Uuid().v4obj(),
        scopeKey: recipient.scopeKey,
        recipientKey: recipient.key,
        linkId: link.id!,
        revision: receipt.occurrenceRevision,
        eventRevision: receipt.eventRevision,
        updatedAt: now,
        stateJson: jsonEncode({
          'version': state?['version'] ?? 1,
          'masterBaseline':
              state?['masterBaseline'] ?? event.data.importBaseline!.toJson(),
          'masterBaselineDigest':
              state?['masterBaselineDigest'] ??
              _invBaselineDigest(event.data.importBaseline!),
          'masterDigest': _occMasterDigest(link, masterRow),
          'baselineDigest': _invBaselineDigest(baseline),
          'targets': targets,
          'requestDigest': digest,
          'receipt': receipt.toJson(),
          if (state?['version'] == 2)
            'receiptDigest': _invitationHash([
              digest,
              jsonEncode(_occOrdered(receipt.toJson())),
              source.digest,
            ]),
        }),
      );
      final proposed = CalendarEventPolicySnapshot(
        link.eventId,
        link.calendarId,
        receipt.eventRevision,
        member.content,
        link.uid,
        now,
        origin: event.data.origin,
        timingOverrides: member.timingOverrides,
        protocolState: member.protocolState,
      );
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        writing: true,
        cancellation: cancellation,
        member: member,
        before: before,
      );
      if (!cancellation && cancelled) {
        await _occLifecycle(
          actor,
          event,
          tx,
          CalendarAuthorizationPhase.preliminaryWrite,
          before: before,
          member: member,
        );
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        before: before,
        proposed: proposed,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        next: next,
        request: input,
        receipt: receipt,
        baseline: baseline,
        dirty: dirty,
      );
      await _occQuota(recipient, next, tx);
      await _invCleanup(recipient, tx, now);
      if ((await _invEntries(
            recipient,
            tx,
          )).where((e) => e.dismissedAt != null).length >=
          _invOptions.maxDismissed) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      event.data.content = member.content;
      event.data.timingOverrides = member.timingOverrides;
      event.data.protocolState = member.protocolState;
      event.data.importBaseline = baseline;
      event.data.updatedAt = now;
      event.identity.revision = receipt.eventRevision;
      await CalendarEventDataRecord.db.updateRow(
        _session,
        event.data,
        transaction: tx,
      );
      await CalendarEventRecord.db.updateRow(
        _session,
        event.identity,
        transaction: tx,
      );
      if (row == null) {
        await CalendarInvitationOccurrenceApplicationRecord.db.insertRow(
          _session,
          next,
          transaction: tx,
        );
      } else {
        await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
          _session,
          next,
          transaction: tx,
        );
      }
      entry.revision = receipt.invitationRevision;
      entry.dismissedAt = now;
      entry.updatedAt = now;
      source.inactiveAt = now;
      await CalendarInvitationRecord.db.updateRow(
        _session,
        entry,
        transaction: tx,
      );
      await CalendarInvitationSourceRecord.db.updateRow(
        _session,
        source,
        transaction: tx,
      );
      await _bump(scope, tx, publishedEventCalendar: link.calendarId);
      await _invApplicationNative(
        actor,
        event,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        writing: true,
        cancellation: cancellation,
        member: member,
        before: before,
      );
      if (!cancellation && cancelled) {
        await _occLifecycle(
          actor,
          event,
          tx,
          CalendarAuthorizationPhase.finalWrite,
          before: before,
          member: member,
        );
      }
      await _occHost(
        actor,
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        operation: operation,
        view: view,
        link: link,
        event: event,
        before: before,
        proposed: proposed,
        message: message,
        text: source.normalizedSource,
        master: master,
        current: row,
        next: next,
        request: input,
        receipt: receipt,
        baseline: baseline,
        dirty: dirty,
      );
      return receipt;
    });
  }

  Future<void> _deleteOccurrenceAcceptance(
    UuidValue eventId,
    Transaction tx,
  ) async {
    final links = await CalendarInvitationLinkRecord.db.find(
      _session,
      where: (t) => t.eventId.equals(eventId),
      transaction: tx,
    );
    for (final link in links) {
      await CalendarInvitationOccurrenceApplicationRecord.db.deleteWhere(
        _session,
        where: (t) => t.linkId.equals(link.id!),
        transaction: tx,
      );
    }
  }

  Future<void> _occLifecycle(
    CalendarHostContext actor,
    _Event event,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    CalendarEventPolicySnapshot? before,
    CalendarEventImportMember? member,
  }) async {
    final request = CalendarAuthorizationRequest(
      key: '${CalendarPermission.changeEventStatus.name}:${event.identity.id}',
      operation: CalendarPermission.changeEventStatus,
      calendarId: event.parent.identity.id,
      current: event.parent.snapshot,
      eventId: event.identity.id,
      currentEvent: before ?? event.snapshot,
      proposedEvent: member?.content,
      proposedEventProtocolState: member?.protocolState,
      proposedTimingOverrides: member?.timingOverrides,
      eventGroups: CalendarEventFieldGroup.values,
    );
    final decisions = phase == CalendarAuthorizationPhase.finalWrite
        ? await _final(actor, [request], tx)
        : await _decide(actor, [request], tx, phase);
    if (phase == CalendarAuthorizationPhase.finalWrite &&
        !decisions[request.key]!.discloseMutationReceipt) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
  }
}
