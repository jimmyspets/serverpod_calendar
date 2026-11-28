part of 'calendar_module.dart';

final class _FreeBusyBasisChanged implements Exception {}

final class _FreeBusyLease {
  const _FreeBusyLease(this.delivery, this.command, this.token, this.attempt);
  final CalendarFreeBusyDeliveryRecord delivery;
  final CalendarFreeBusyCommandRecord command;
  final UuidValue token, attempt;
}

extension on CalendarService {
  Future<void> _fbDispatchCheck(
    CalendarFreeBusyCommandRecord command,
    CalendarFreeBusyDeliveryRecord delivery,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    try {
      _fbCheckGuarantee();
      await _fbDispatchCheckUnchecked(command, delivery, tx, phase);
      _fbCheckGuarantee();
    } on _FreeBusyBasisChanged {
      rethrow;
    } on CalendarException {
      rethrow;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<void> _fbDispatchCheckUnchecked(
    CalendarFreeBusyCommandRecord command,
    CalendarFreeBusyDeliveryRecord delivery,
    Transaction tx,
    CalendarAuthorizationPhase phase,
  ) async {
    if (command.payload == null ||
        command.arguments == null ||
        command.scrubbedAt != null ||
        command.calendarId == null ||
        delivery.recipientAddress == null ||
        delivery.routeRef == null ||
        delivery.scopeKey != command.scopeKey ||
        delivery.ownerKey != command.ownerKey ||
        delivery.generation != command.generation ||
        sha256.convert(utf8.encode(command.payload!)).toString() !=
            command.payloadDigest) {
      throw _FreeBusyBasisChanged();
    }
    final message = _fbParse(command.payload!);
    if (message.method.name != command.method ||
        message.components.length != 1) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final arguments = jsonDecode(command.arguments!) as Map<String, dynamic>;
    final mb = arguments['mailbox'] as Map<String, dynamic>;
    final mailbox = CalendarFreeBusyMailbox(
      scopeKey: mb['scope'] as String,
      ownerKey: mb['owner'] as String,
      calendarId: UuidValue.fromString(mb['calendar'] as String),
      address: mb['address'] as String,
      bindingRef: mb['binding'] as String,
    );
    if (mailbox.scopeKey != command.scopeKey ||
        mailbox.ownerKey != command.ownerKey ||
        mailbox.calendarId != command.calendarId ||
        mailbox.bindingRef != delivery.authorityRef) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final parent = await _activeInScope(
      command.scopeKey,
      command.calendarId!,
      tx,
    );
    final route = CalendarSchedulingRoute(
      delivery.recipientAddress!,
      delivery.routeRef!,
    );
    final componentBinding = message.components.single;
    if (componentBinding.stamp != command.stamp ||
        componentBinding.window.start !=
            DateTime.parse(arguments['fromUtc'] as String) ||
        componentBinding.window.end !=
            DateTime.parse(arguments['untilUtc'] as String) ||
        command.action == 'publish' &&
            message.method != IcalendarFreeBusyMethod.publish ||
        command.action == 'request' &&
            message.method != IcalendarFreeBusyMethod.request ||
        {'share', 'refuse'}.contains(command.action) &&
            message.method != IcalendarFreeBusyMethod.reply ||
        message.method != IcalendarFreeBusyMethod.reply &&
            (command.sourceId != null ||
                componentBinding.organizer.address != mailbox.address) ||
        message.method == IcalendarFreeBusyMethod.request &&
            !componentBinding.attendees.contains(route.address) ||
        message.method == IcalendarFreeBusyMethod.reply &&
            (command.sourceId == null ||
                componentBinding.attendees.single != mailbox.address ||
                componentBinding.organizer.address != route.address)) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (command.action == 'refuse' &&
            (componentBinding.groups.isNotEmpty ||
                componentBinding.requestStatuses.length != 1 ||
                componentBinding.requestStatuses.single.code != '3.8') ||
        command.action == 'share' &&
            componentBinding.requestStatuses.isNotEmpty) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final retainedSource = command.sourceId == null
        ? null
        : await CalendarFreeBusySourceRecord.db.findById(
            _session,
            command.sourceId!,
            transaction: tx,
          );
    if (command.sourceId != null &&
        (retainedSource == null ||
            retainedSource.payload == null ||
            retainedSource.scopeKey != command.scopeKey ||
            retainedSource.ownerKey != command.ownerKey ||
            !retainedSource.expiresAt.isAfter(await _revisionTime(tx)) ||
            sha256.convert(utf8.encode(retainedSource.payload!)).toString() !=
                retainedSource.payloadDigest)) {
      throw _FreeBusyBasisChanged();
    }
    final context = CalendarFreeBusyExchangePolicyContext(
      operation: CalendarFreeBusyExchangeOperation.dispatch,
      scopeKey: command.scopeKey,
      ownerKey: command.ownerKey,
      mailbox: mailbox,
      calendar: parent.snapshot,
      message: message,
      sourceMessage: retainedSource?.payload == null
          ? null
          : _fbStoredSource(retainedSource!),
      originRef: retainedSource?.originRef,
      commandId: command.id,
      sourceId: command.sourceId,
      payloadDigest: command.payloadDigest,
      route: route,
    );
    await _fbAuthorize(context, tx, phase);
    final routes = await _bounded(
      () => _fbRuntime.host.resolveRoutes(
        _session,
        context,
        List.unmodifiable([route.address]),
        tx,
        phase,
      ),
    );
    if (routes.length != 1 ||
        routes.single.address != route.address ||
        routes.single.routeRef != route.routeRef) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    if (command.sourceId != null) {
      final source = await CalendarFreeBusySourceRecord.db.findById(
        _session,
        command.sourceId!,
        transaction: tx,
      );
      if (source == null ||
          source.payload == null ||
          source.headId == null ||
          source.scopeKey != command.scopeKey ||
          source.ownerKey != command.ownerKey) {
        throw _FreeBusyBasisChanged();
      }
      final head = await CalendarFreeBusyRequestHeadRecord.db.findById(
        _session,
        source.headId!,
        transaction: tx,
      );
      if (head == null ||
          head.purgedAt != null ||
          head.conflicted ||
          head.currentSourceId != source.id ||
          head.latestCommandId != command.id ||
          head.calendarId != command.calendarId ||
          head.mailboxAddress != mailbox.address ||
          head.bindingRef != mailbox.bindingRef) {
        throw _FreeBusyBasisChanged();
      }
      final incoming = _fbStoredSource(source).components.single;
      final outgoing = message.components.single;
      if (incoming.uid != outgoing.uid ||
          incoming.window.start != outgoing.window.start ||
          incoming.window.end != outgoing.window.end ||
          incoming.organizer.address != route.address ||
          outgoing.attendees.single != mailbox.address ||
          outgoing.organizer.address != route.address) {
        throw _failure(CalendarFailureCode.unavailable);
      }
    }
    final needsSnapshot =
        command.action == 'publish' || command.action == 'share';
    if (!needsSnapshot) {
      if (command.action != 'request' && command.action != 'refuse') {
        throw _failure(CalendarFailureCode.unavailable);
      }
      return;
    }
    if (command.calculationProfile != 1 ||
        command.timezoneIdentity != _occurrenceTimezoneIdentity) {
      // A binary/data mismatch is operational unavailability, not a user edit.
      throw _failure(CalendarFailureCode.unavailable);
    }
    if (command.parentSettingsDigest !=
        _fbDigest([
          parent.data.availabilityZoneId,
          parent.data.noRuleFallback.name,
        ])) {
      throw _FreeBusyBasisChanged();
    }
    final component = message.components.single;
    final query = CalendarFreeBusyQuery(
      calendarId: parent.identity.id!,
      fromUtc: component.window.start,
      untilUtc: component.window.end,
    );
    final actual = <CalendarAuthorizationRequest>[];
    var denied = false;
    Future<void> authorize(List<CalendarAuthorizationRequest> requests) async {
      _fbCheckGuarantee();
      final verdict = await _bounded(
        () => _fbRuntime.host.authorizeSources(
          _session,
          context,
          List.unmodifiable(requests),
          tx,
          phase,
        ),
      );
      _fbCheckGuarantee();
      if (verdict != CalendarAuthorizationVerdict.allow) {
        denied = verdict == CalendarAuthorizationVerdict.deny;
        throw _failure(
          denied
              ? CalendarFailureCode.accessDenied
              : CalendarFailureCode.unavailable,
        );
      }
    }

    await authorize([
      _er(parent, CalendarPermission.readFreeBusy, freeBusy: query),
      _er(parent, CalendarPermission.exportFreeBusy, freeBusy: query),
    ]);
    final result = await _calendarBusyAuthorized(
      parent,
      query,
      component.window,
      tx,
      _BusyBudget(),
      authorize: authorize,
      authorizedSources: actual,
    );
    if (result.coverage != CalendarFreeBusyCoverage.complete) {
      throw _failure(
        denied
            ? CalendarFailureCode.accessDenied
            : CalendarFailureCode.unavailable,
      );
    }
    final recorded = await CalendarFreeBusySourceReferenceRecord.db.find(
      _session,
      where: (t) => t.commandId.equals(command.id!),
      limit: 321,
      transaction: tx,
    );
    if (recorded.length != actual.length || recorded.length > 320) {
      throw _FreeBusyBasisChanged();
    }
    final map = {for (final r in recorded) r.sourceKey: r};
    if (map.length != recorded.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    for (final request in actual) {
      final e = request.currentEvent;
      final a = request.currentAvailability;
      if ((e == null) == (a == null)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      final key = e == null
          ? 'availability:${a!.availabilityId}'
          : 'event:${e.eventId}';
      final reference = map[key];
      final fingerprint = e != null
          ? _fbDigest([e.content.toJson(), e.timingOverrides?.toJson()])
          : _fbDigest([
              a!.content.toJson(),
              a.timingOverrides?.map((v) => v.toJson()).toList(),
            ]);
      if (reference == null ||
          reference.scopeKey != command.scopeKey ||
          reference.ownerKey != command.ownerKey ||
          reference.eventId != e?.eventId ||
          reference.availabilityId != a?.availabilityId ||
          reference.revision != (e?.revision ?? a!.revision) ||
          reference.contentDigest != fingerprint) {
        throw _FreeBusyBasisChanged();
      }
    }
  }

  Future<int> _fbMaintenance() async {
    final options = _fbRuntime.options;
    await _fbPrune();
    final owner = UuidValue.fromString(const Uuid().v4());
    final now = await _session.db.transaction((tx) => _revisionTime(tx));
    final candidates = await CalendarFreeBusyDeliveryRecord.db.find(
      _session,
      where: (t) =>
          t.terminalAt.equals(null) &
          (t.nextAttemptAt <= now) &
          (t.leaseUntil.equals(null) | (t.leaseUntil <= now)),
      orderBy: (t) => t.nextAttemptAt,
      limit: options.batchSize,
    );
    var processed = 0;
    for (final candidate in candidates) {
      final lease = await _scopeTransaction(candidate.scopeKey, (tx, _) async {
        final d = await CalendarFreeBusyDeliveryRecord.db.findById(
          _session,
          candidate.id!,
          transaction: tx,
        );
        var time = await _revisionTime(tx);
        if (d == null ||
            d.terminalAt != null ||
            d.nextAttemptAt.isAfter(time) ||
            d.leaseUntil != null && d.leaseUntil!.isAfter(time)) {
          return null;
        }
        final command = await CalendarFreeBusyCommandRecord.db.findById(
          _session,
          d.commandId,
          transaction: tx,
        );
        String? terminal;
        if (!d.expiresAt.isAfter(time)) terminal = 'expired';
        if (command == null ||
            command.terminalAt != null ||
            command.generation != d.generation ||
            command.scrubbedAt != null) {
          terminal = 'withdrawn';
        }
        if (terminal == null) {
          try {
            await _fbDispatchCheck(
              command!,
              d,
              tx,
              CalendarAuthorizationPhase.preliminaryWrite,
            );
            await _fbDispatchCheck(
              command,
              d,
              tx,
              CalendarAuthorizationPhase.finalWrite,
            );
          } on _FreeBusyBasisChanged {
            terminal = 'withdrawn';
          } on CalendarException catch (e) {
            if (e.code == CalendarFailureCode.accessDenied) {
              terminal = 'withdrawn';
            } else {
              d.state = 'unavailable';
              d.nextAttemptAt = time.add(options.retryBase);
              await CalendarFreeBusyDeliveryRecord.db.updateRow(
                _session,
                d,
                transaction: tx,
              );
              return null;
            }
          }
        }
        // Authorization/calculation may take time. Lease and expiry decisions
        // use a fresh actual database instant after that work, not its start.
        time = await _revisionTime(tx);
        if (terminal == null &&
            (!d.expiresAt.isAfter(time) || !command!.expiresAt.isAfter(time))) {
          terminal = 'expired';
        }
        if (terminal != null || d.attemptCount >= options.maxAttempts) {
          d.state = terminal ?? 'failed';
          d.terminalAt = time;
          d.leaseOwner = null;
          d.leaseToken = null;
          d.leaseUntil = null;
          await CalendarFreeBusyDeliveryRecord.db.updateRow(
            _session,
            d,
            transaction: tx,
          );
          if (command != null &&
              command.terminalAt == null &&
              await CalendarFreeBusyDeliveryRecord.db.count(
                    _session,
                    where: (t) =>
                        t.commandId.equals(command.id!) &
                        t.terminalAt.equals(null),
                    transaction: tx,
                  ) ==
                  0) {
            command.terminalAt = time;
            await CalendarFreeBusyCommandRecord.db.updateRow(
              _session,
              command,
              transaction: tx,
            );
          }
          return null;
        }
        if (d.leaseFence >= CalendarService._maxRevision) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final unfinished = await CalendarFreeBusyAttemptRecord.db.find(
          _session,
          where: (t) => t.deliveryId.equals(d.id!) & t.finishedAt.equals(null),
          limit: 9,
          transaction: tx,
        );
        if (unfinished.length > 8) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        for (final old in unfinished) {
          old.finishedAt = time;
          old.outcome = 'uncertain';
          old.reasonCode = 'leaseExpired';
          await CalendarFreeBusyAttemptRecord.db.updateRow(
            _session,
            old,
            transaction: tx,
          );
        }
        final token = UuidValue.fromString(const Uuid().v4());
        d.attemptCount++;
        d.leaseFence++;
        d.leaseOwner = owner;
        d.leaseToken = token;
        d.leaseUntil = time.add(options.lease);
        d.state = 'submitting';
        await CalendarFreeBusyDeliveryRecord.db.updateRow(
          _session,
          d,
          transaction: tx,
        );
        final attempt = await CalendarFreeBusyAttemptRecord.db.insertRow(
          _session,
          CalendarFreeBusyAttemptRecord(
            scopeKey: d.scopeKey,
            ownerKey: d.ownerKey,
            deliveryId: d.id!,
            generation: d.generation,
            ordinal: d.attemptCount,
            leaseOwner: owner,
            startedAt: time,
            payloadDigest: command!.payloadDigest,
          ),
          transaction: tx,
        );
        return _FreeBusyLease(d, command, token, attempt.id!);
      });
      if (lease == null) continue;
      processed++;
      CalendarSchedulingTransportResult result;
      try {
        final message = _fbParse(lease.command.payload!).components.single;
        result = await _fbRuntime.transport
            .submit(
              _session,
              CalendarSchedulingSubmission(
                deliveryKey: lease.delivery.id!,
                publicationId: lease.command.id!,
                scopeKey: lease.command.scopeKey,
                organizerAddress: lease.command.method == 'reply'
                    ? message.attendees.single
                    : message.organizer.address,
                recipient: CalendarSchedulingRoute(
                  lease.delivery.recipientAddress!,
                  lease.delivery.routeRef!,
                ),
                payload: lease.command.payload!,
              ),
            )
            .timeout(options.transportTimeout);
      } catch (_) {
        result = const CalendarSchedulingTransportResult(
          CalendarSchedulingTransportOutcome.uncertain,
        );
      }
      await _scopeTransaction(lease.command.scopeKey, (tx, _) async {
        final d = await CalendarFreeBusyDeliveryRecord.db.findById(
          _session,
          lease.delivery.id!,
          transaction: tx,
        );
        final command = await CalendarFreeBusyCommandRecord.db.findById(
          _session,
          lease.command.id!,
          transaction: tx,
        );
        final time = await _revisionTime(tx);
        final attempt = await CalendarFreeBusyAttemptRecord.db.findById(
          _session,
          lease.attempt,
          transaction: tx,
        );
        final current =
            d != null &&
            command != null &&
            d.terminalAt == null &&
            d.leaseToken == lease.token &&
            d.leaseOwner == owner &&
            d.leaseFence == lease.delivery.leaseFence &&
            d.generation == command.generation &&
            d.generation == lease.delivery.generation &&
            d.leaseUntil != null &&
            d.leaseUntil!.isAfter(time);
        if (attempt != null) {
          attempt.finishedAt = time;
          attempt.outcome = current ? result.outcome.name : 'superseded';
          if (result.mimeDigest != null &&
              RegExp(r'^[a-f0-9]{64}$').hasMatch(result.mimeDigest!)) {
            attempt.mimeDigest = result.mimeDigest;
          }
          await CalendarFreeBusyAttemptRecord.db.updateRow(
            _session,
            attempt,
            transaction: tx,
          );
        }
        if (!current) return;
        d.leaseOwner = null;
        d.leaseToken = null;
        d.leaseUntil = null;
        if (result.outcome == CalendarSchedulingTransportOutcome.accepted) {
          d.state = 'accepted';
          d.terminalAt = time;
          if (result.receipt != null &&
              utf8.encode(result.receipt!).length <= 512) {
            d.providerReceipt = result.receipt;
          }
        } else if (result.outcome ==
                CalendarSchedulingTransportOutcome.permanentFailure ||
            d.attemptCount >= options.maxAttempts) {
          d.state = 'failed';
          d.terminalAt = time;
        } else {
          d.state = 'queued';
          d.nextAttemptAt = time.add(
            Duration(
              microseconds: min(
                const Duration(hours: 1).inMicroseconds,
                options.retryBase.inMicroseconds * (1 << (d.attemptCount - 1)),
              ),
            ),
          );
        }
        await CalendarFreeBusyDeliveryRecord.db.updateRow(
          _session,
          d,
          transaction: tx,
        );
        if (await CalendarFreeBusyDeliveryRecord.db.count(
              _session,
              where: (t) =>
                  t.commandId.equals(command.id!) & t.terminalAt.equals(null),
              transaction: tx,
            ) ==
            0) {
          command.terminalAt = time;
          await CalendarFreeBusyCommandRecord.db.updateRow(
            _session,
            command,
            transaction: tx,
          );
        }
      });
    }
    return processed;
  }
}
