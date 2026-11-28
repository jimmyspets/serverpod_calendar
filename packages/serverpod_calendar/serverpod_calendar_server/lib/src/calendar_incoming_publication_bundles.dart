part of 'calendar_module.dart';

final _incomingValidationKey = Object();

final class _IncomingValidation {
  final work = RecurrenceWorkBudget(maxWork: eventMaxCandidateWork);
  bool bundled = false;
  final proofs = <(UuidValue, UuidValue)>{};
  final proposals = Expando<EventStorageProposal>();
  final sources = <String, IcalendarSchedulingMessage>{};
  final states = Expando<CalendarIncomingPublicationBundleState>();
  final cancellationChecks =
      <(IcalendarSchedulingMessage, IcalendarSchedulingMessage)>{};
}

Future<T> _incomingWithValidation<T>(Future<T> Function() body) {
  if (Zone.current[_incomingValidationKey] != null) return body();
  return runZoned(
    body,
    zoneValues: {_incomingValidationKey: _IncomingValidation()},
  );
}

_IncomingValidation? get _incomingValidation =>
    Zone.current[_incomingValidationKey] as _IncomingValidation?;
RecurrenceWorkBudget? get _incomingWork =>
    _incomingValidation?.bundled == true ? _incomingValidation!.work : null;
IcalendarSchedulingEvent _incomingMaster(IcalendarSchedulingMessage value) =>
    value.events.singleWhere((e) => !e.isOverride);

extension CalendarIncomingPublicationBundles on CalendarService {
  List<CalendarIncomingPublicationComponentVersion> _incomingBundleVersions(
    IcalendarSchedulingMessage message,
  ) => message.method == IcalendarSchedulingMethod.cancel
      ? [
          CalendarIncomingPublicationComponentVersion(
            sequence: _incomingMaster(message).sequence,
            stamp: _incomingMaster(message).stamp,
          ),
        ]
      : _incomingBundleState(message).versions;

  EventStorageProposal _incomingProposal(IcalendarSchedulingMessage message) {
    final cached = _incomingValidation?.proposals[message];
    if (cached != null) return cached;
    final value = message.events.length > 1
        ? informationPublicationBundleProposal(
            message,
            maxBytes: _incomingOptions.maxSourceBytes,
            sharedWorkBudget: _incomingWork,
          )
        : _schedulingMasterProposal(message, sharedWorkBudget: _incomingWork);
    _incomingValidation?.proposals[message] = value;
    return value;
  }

  void _incomingProfile(CalendarIncomingPublicationRecord entry, bool bundled) {
    if (entry.bundledPublication != bundled) {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  CalendarIncomingPublicationOperation? _incomingBundleOperation(
    CalendarIncomingPublicationPolicyContext c,
  ) {
    if (!(c.entry?.bundledPublication ?? false) &&
        (c.source?.events.length ?? 0) < 2) {
      return null;
    }
    return switch (c.operation) {
      CalendarIncomingPublicationOperation.receive =>
        CalendarIncomingPublicationOperation.receiveBundle,
      CalendarIncomingPublicationOperation.receiveCancellation =>
        CalendarIncomingPublicationOperation.receiveBundleCancellation,
      CalendarIncomingPublicationOperation.readSource =>
        CalendarIncomingPublicationOperation.readBundleSource,
      CalendarIncomingPublicationOperation.readLink =>
        CalendarIncomingPublicationOperation.readBundleLink,
      CalendarIncomingPublicationOperation.adopt =>
        CalendarIncomingPublicationOperation.adoptBundle,
      CalendarIncomingPublicationOperation.applyUpdate =>
        CalendarIncomingPublicationOperation.applyBundleUpdate,
      CalendarIncomingPublicationOperation.applyCancellation =>
        CalendarIncomingPublicationOperation.applyBundleCancellation,
      CalendarIncomingPublicationOperation.reopen =>
        CalendarIncomingPublicationOperation.reopenBundle,
      _ => null,
    };
  }

  CalendarIncomingPublicationPolicyContext _incomingOperationContext(
    CalendarIncomingPublicationPolicyContext c,
    CalendarIncomingPublicationOperation operation,
  ) => CalendarIncomingPublicationPolicyContext(
    operation: operation,
    recipient: c.recipient,
    actor: c.actor,
    delivery: c.delivery,
    entry: c.entry,
    source: c.source,
    sourceId: c.sourceId,
    sourceDigest: c.sourceDigest,
    acceptedBasis: c.acceptedBasis,
    sourceBasis: c.sourceBasis,
    calendar: c.calendar,
    currentEvent: c.currentEvent,
    proposedEvent: c.proposedEvent,
    targetCalendarId: c.targetCalendarId,
    targetEventId: c.targetEventId,
    targetDeleted: c.targetDeleted,
    isRetry: c.isRetry,
  );

  CalendarIncomingPublicationBundleState _incomingBundleState(
    IcalendarSchedulingMessage message,
  ) {
    final cached = _incomingValidation?.states[message];
    if (cached != null) return cached;
    final proposal = _incomingProposal(message);
    final value = _schedulingValue(
      () => informationPublicationBundleBaseline(
        proposal.importBaseline,
        protocolUid: proposal.protocolUid,
        sharedWorkBudget: _incomingWork,
      ),
    );
    _incomingValidation?.states[message] = value;
    return value;
  }

  // This set records source dependencies only. It never records an allow result;
  // every dependency is reloaded and reauthorized at the final write boundary.
  Future<IcalendarSchedulingMessage> _incomingReadBundleProof(
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationSourceRecord source,
    CalendarIncomingPublicationRecipient recipient,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    CalendarHostContext? actor,
  }) async {
    final message = _incomingStored(entry, source);
    final basis = await _incomingSourceBasis(entry, source, tx);
    if (source.basisSourceId != null) {
      await _incomingReadBundleProof(
        entry,
        await _incomingSourceRow(entry, source.basisSourceId!, tx),
        recipient,
        tx,
        phase,
        actor: actor,
      );
    }
    await _incomingAuthorize(
      CalendarIncomingPublicationPolicyContext(
        operation: CalendarIncomingPublicationOperation.readSource,
        recipient: recipient,
        actor: actor,
        entry: _incomingView(entry),
        source: message,
        sourceBasis: basis,
        sourceId: source.id,
        sourceDigest: source.digest,
      ),
      tx,
      phase,
    );
    _incomingValidation!.proofs.add((entry.id!, source.id!));
    return message;
  }

  Future<void> _incomingRecheckBundleProofs(
    CalendarIncomingPublicationRecipient recipient,
    Transaction tx, {
    CalendarHostContext? actor,
  }) async {
    for (final (entryId, sourceId) in _incomingValidation!.proofs.toList()) {
      final entry = await _incomingEntry(entryId, recipient, tx);
      await _incomingReadBundleProof(
        entry,
        await _incomingSourceRow(entry, sourceId, tx),
        recipient,
        tx,
        CalendarAuthorizationPhase.finalWrite,
        actor: actor,
      );
    }
  }

  Future<bool> _incomingBundleAdmission(
    CalendarIncomingPublicationRecord entry,
    CalendarIncomingPublicationLinkRecord? link,
    IcalendarSchedulingMessage incoming,
    String digest,
    CalendarIncomingPublicationRecipient recipient,
    Transaction tx, {
    CalendarHostContext? actor,
  }) async {
    Future<
      ({
        CalendarIncomingPublicationBundleState state,
        CalendarIncomingPublicationComponentVersion? cancellation,
      })
    >
    floor(
      CalendarIncomingPublicationSourceRecord row,
    ) async {
      final message = await _incomingReadBundleProof(
        entry,
        row,
        recipient,
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
        actor: actor,
      );
      final basis = message.method == IcalendarSchedulingMethod.publish
          ? message
          : (await _incomingSourceBasis(entry, row, tx))!;
      return (
        state: _incomingBundleState(basis),
        cancellation: message.method == IcalendarSchedulingMethod.cancel
            ? CalendarIncomingPublicationComponentVersion(
                sequence: row.sequence,
                stamp: row.stamp,
              )
            : null,
      );
    }

    final currentRow = await _incomingSourceRow(
      entry,
      entry.currentSourceId,
      tx,
    );
    final current = await floor(currentRow);
    final next = incoming.method == IcalendarSchedulingMethod.publish
        ? _incomingBundleState(incoming)
        : null;
    bool compare(
      CalendarIncomingPublicationBundleState state,
      CalendarIncomingPublicationComponentVersion? cancellation,
      bool same,
    ) => _schedulingValue(() {
      if (next == null) {
        validateInformationPublicationBundleCancellation(
          accepted: state,
          incoming: incoming,
          previousCancellation: same ? null : cancellation,
          sharedWorkBudget: _incomingWork,
        );
        return !same;
      }
      return cancellation == null
          ? validateInformationPublicationBundleAdvance(
              state,
              next,
              sharedWorkBudget: _incomingWork,
            )
          : validateInformationPublicationBundleReopening(
              accepted: state,
              incoming: next,
              cancellation: cancellation,
              sharedWorkBudget: _incomingWork,
            );
    });
    final advance = compare(
      current.state,
      current.cancellation,
      digest == currentRow.digest,
    );
    if (link?.acceptedSourceId != null && link!.deletedAt == null) {
      final acceptedRow = await _incomingSourceRow(
        entry,
        link.acceptedSourceId!,
        tx,
      );
      final accepted = await floor(acceptedRow);
      compare(
        accepted.state,
        accepted.cancellation,
        digest == acceptedRow.digest,
      );
      // The native accepted basis and a CANCEL sender's basis are separate proof.
      if (link.basisSourceId != null && link.basisSourceId != acceptedRow.id) {
        final basis = await floor(
          await _incomingSourceRow(entry, link.basisSourceId!, tx),
        );
        compare(basis.state, null, false);
      }
    }
    return advance;
  }
}
