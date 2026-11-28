part of 'calendar_module.dart';

extension on CalendarService {
  /// Runs under the same scope transaction as deletion, even when this host has
  /// no exchange transport installed. Private retained reports cannot preserve
  /// source intervals after their contributing native data has been deleted.
  Future<void> _scrubFreeBusyReports(
    String scopeKey,
    Transaction tx, {
    UuidValue? calendarId,
    UuidValue? eventId,
    UuidValue? availabilityId,
  }) async {
    if ([calendarId, eventId, availabilityId].whereType<UuidValue>().length !=
        1) {
      throw StateError('Exactly one deletion source is required');
    }
    final commands = <UuidValue>{};
    if (calendarId != null) {
      final rows = await CalendarFreeBusyCommandRecord.db.find(
        _session,
        where: (t) =>
            t.scopeKey.equals(scopeKey) & t.calendarId.equals(calendarId),
        limit: 4097,
        transaction: tx,
      );
      if (rows.length > 4096) throw _failure(CalendarFailureCode.unavailable);
      commands.addAll(rows.map((r) => r.id!));
      final heads = await CalendarFreeBusyRequestHeadRecord.db.find(
        _session,
        where: (t) =>
            t.scopeKey.equals(scopeKey) & t.calendarId.equals(calendarId),
        limit: 4097,
        transaction: tx,
      );
      if (heads.length > 4096) throw _failure(CalendarFailureCode.unavailable);
      final now = await _revisionTime(tx);
      for (final head in heads) {
        head
          ..calendarId = null
          ..mailboxAddress = null
          ..bindingRef = null
          ..requesterAddress = null
          ..fromUtc = null
          ..untilUtc = null
          ..currentSourceId = null
          ..purgedAt = now;
        await CalendarFreeBusyRequestHeadRecord.db.updateRow(
          _session,
          head,
          transaction: tx,
        );
      }
    } else {
      final references = await CalendarFreeBusySourceReferenceRecord.db.find(
        _session,
        where: (t) =>
            t.scopeKey.equals(scopeKey) &
            (eventId != null
                ? t.eventId.equals(eventId)
                : t.availabilityId.equals(availabilityId)),
        limit: 4097,
        transaction: tx,
      );
      if (references.length > 4096) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      commands.addAll(references.map((r) => r.commandId));
    }
    if (commands.isEmpty) return;
    final now = await _revisionTime(tx);
    for (final id in commands) {
      final command = await CalendarFreeBusyCommandRecord.db.findById(
        _session,
        id,
        transaction: tx,
      );
      if (command == null || command.scopeKey != scopeKey) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (command.scrubbedAt != null) continue;
      if (command.generation >= CalendarService._maxRevision) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      command
        ..generation = command.generation + 1
        ..payload = null
        ..arguments = null
        ..timezoneIdentity = null
        ..calculationProfile = null
        ..parentSettingsDigest = null
        ..byteCount = 0
        ..scrubbedAt = now
        ..terminalAt ??= now;
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
      for (final delivery in deliveries) {
        if (delivery.scopeKey != scopeKey ||
            delivery.ownerKey != command.ownerKey) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        // Preserve terminal acceptance: no transaction can recall an external
        // message. Fencing makes any outstanding lease unable to accept anew.
        if (delivery.terminalAt == null) {
          delivery.state = 'withdrawn';
          delivery.terminalAt = now;
        }
        delivery
          ..generation = command.generation
          ..recipientAddress = null
          ..routeRef = null
          ..authorityRef = null
          ..providerReceipt = null
          ..leaseOwner = null
          ..leaseToken = null
          ..leaseUntil = null;
        await CalendarFreeBusyDeliveryRecord.db.updateRow(
          _session,
          delivery,
          transaction: tx,
        );
      }
      await CalendarFreeBusySourceReferenceRecord.db.deleteWhere(
        _session,
        where: (t) => t.commandId.equals(id),
        transaction: tx,
      );
    }
  }
}
