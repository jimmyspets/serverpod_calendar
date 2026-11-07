part of 'calendar_module.dart';

extension on CalendarService {
  Future<void> _fbPrune() async {
    final options = _fbRuntime.options;
    final scopes = await _session.db.unsafeQuery(
      'WITH bounds AS (SELECT clock_timestamp() AS now, '
      'clock_timestamp()-(@seconds * interval \'1 second\') AS cutoff) '
      'SELECT s."scopeKey" FROM serverpod_calendar_fb_source s, bounds b '
      'WHERE s."expiresAt"<=b.now AND (s."purgedAt" IS NULL OR s."purgedAt"<=b.cutoff) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_fb_ingress i WHERE i."sourceId"=s.id AND i."expiresAt">b.now) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_fb_command c WHERE c."sourceId"=s.id) '
      'UNION SELECT c."scopeKey" FROM serverpod_calendar_fb_command c, bounds b '
      'WHERE c."terminalAt"<=b.cutoff AND (c."correlatableUntil" IS NULL OR c."correlatableUntil"<=b.now) '
      'AND (c."scrubbedAt" IS NULL OR c."scrubbedAt"<=b.cutoff OR c."sourceId" IS NOT NULL) '
      'AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_fb_source s WHERE s."requestCommandId"=c.id) '
      'UNION SELECT h."scopeKey" FROM serverpod_calendar_fb_request_head h, bounds b '
      'WHERE h."purgedAt"<=b.cutoff AND NOT EXISTS (SELECT 1 FROM serverpod_calendar_fb_source s WHERE s."headId"=h.id) '
      'ORDER BY "scopeKey" LIMIT @limit',
      parameters: QueryParameters.named({
        'limit': options.batchSize,
        'seconds':
            options.retention.inMicroseconds / Duration.microsecondsPerSecond,
      }),
    );
    for (final scope in scopes) {
      await _scopeTransaction(scope.single as String, (tx, _) async {
        final scopeKey = scope.single as String;
        final now = await _revisionTime(tx);
        final cutoff = now.subtract(options.retention);
        // Expired receipts release their source pins first. A retained exact
        // receipt is never silently reassigned to a new source.
        final ingress = await CalendarFreeBusyIngressReceiptRecord.db.find(
          _session,
          where: (t) => t.scopeKey.equals(scopeKey) & (t.expiresAt <= now),
          orderBy: (t) => t.expiresAt,
          limit: 32769,
          transaction: tx,
        );
        if (ingress.length > 32768) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        if (ingress.isNotEmpty) {
          await CalendarFreeBusyIngressReceiptRecord.db.delete(
            _session,
            ingress,
            transaction: tx,
          );
        }
        final commands = await CalendarFreeBusyCommandRecord.db.find(
          _session,
          where: (t) => t.scopeKey.equals(scopeKey),
          limit: 4097,
          transaction: tx,
        );
        final sources = await CalendarFreeBusySourceRecord.db.find(
          _session,
          where: (t) => t.scopeKey.equals(scopeKey),
          limit: 8193,
          transaction: tx,
        );
        if (commands.length > 4096 || sources.length > 8192) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        var changed = 0;
        for (final source in sources) {
          if (source.expiresAt.isAfter(now) || changed >= options.batchSize) {
            continue;
          }
          final pinned =
              commands.any((c) => c.sourceId == source.id) ||
              await CalendarFreeBusyIngressReceiptRecord.db.count(
                    _session,
                    where: (t) => t.sourceId.equals(source.id!),
                    limit: 1,
                    transaction: tx,
                  ) !=
                  0;
          if (pinned) continue;
          if (source.purgedAt == null) {
            if (source.headId != null) {
              final head = await CalendarFreeBusyRequestHeadRecord.db.findById(
                _session,
                source.headId!,
                transaction: tx,
              );
              if (head != null &&
                  (head.scopeKey != source.scopeKey ||
                      head.ownerKey != source.ownerKey)) {
                throw _failure(CalendarFailureCode.unavailable);
              }
              if (head != null && head.currentSourceId == source.id) {
                head
                  ..currentSourceId = null
                  ..purgedAt = now
                  ..calendarId = null
                  ..mailboxAddress = null
                  ..bindingRef = null
                  ..requesterAddress = null
                  ..fromUtc = null
                  ..untilUtc = null;
                await CalendarFreeBusyRequestHeadRecord.db.updateRow(
                  _session,
                  head,
                  transaction: tx,
                );
              }
            }
            source
              ..payload = null
              ..header = null
              ..byteCount = 0
              ..originRef = null
              ..bindingRef = null
              ..mailboxAddress = null
              ..requestCommandId = null
              ..headId = null
              ..purgedAt = now;
            await CalendarFreeBusySourceRecord.db.updateRow(
              _session,
              source,
              transaction: tx,
            );
            changed++;
          } else if (!source.purgedAt!.isAfter(cutoff)) {
            await CalendarFreeBusySourceRecord.db.deleteRow(
              _session,
              source,
              transaction: tx,
            );
            changed++;
          }
        }
        changed = 0;
        for (final command in commands) {
          if (command.terminalAt == null ||
              command.terminalAt!.isAfter(cutoff) ||
              command.correlatableUntil != null &&
                  command.correlatableUntil!.isAfter(now) ||
              changed >= options.batchSize) {
            continue;
          }
          // Incoming reports may retain their original request longer than its
          // new-admission window; clearing a source marker releases this pin.
          if (await CalendarFreeBusySourceRecord.db.count(
                _session,
                where: (t) => t.requestCommandId.equals(command.id!),
                limit: 1,
                transaction: tx,
              ) !=
              0) {
            continue;
          }
          final deliveries = await CalendarFreeBusyDeliveryRecord.db.find(
            _session,
            where: (t) => t.commandId.equals(command.id!),
            limit: 65,
            transaction: tx,
          );
          if (deliveries.length > 64 ||
              deliveries.any((d) => d.terminalAt == null)) {
            throw _failure(CalendarFailureCode.unavailable);
          }
          if (command.scrubbedAt == null) {
            command
              ..payload = null
              ..arguments = null
              ..byteCount = 0
              ..sourceId = null
              ..timezoneIdentity = null
              ..parentSettingsDigest = null
              ..calculationProfile = null
              ..scrubbedAt = now;
            await CalendarFreeBusyCommandRecord.db.updateRow(
              _session,
              command,
              transaction: tx,
            );
            for (final d in deliveries) {
              d
                ..recipientAddress = null
                ..routeRef = null
                ..authorityRef = null
                ..providerReceipt = null
                ..leaseOwner = null
                ..leaseToken = null
                ..leaseUntil = null;
              await CalendarFreeBusyDeliveryRecord.db.updateRow(
                _session,
                d,
                transaction: tx,
              );
            }
            await CalendarFreeBusySourceReferenceRecord.db.deleteWhere(
              _session,
              where: (t) => t.commandId.equals(command.id!),
              transaction: tx,
            );
            changed++;
          } else if (!command.scrubbedAt!.isAfter(cutoff)) {
            for (final d in deliveries) {
              await CalendarFreeBusyAttemptRecord.db.deleteWhere(
                _session,
                where: (t) => t.deliveryId.equals(d.id!),
                transaction: tx,
              );
            }
            if (deliveries.isNotEmpty) {
              await CalendarFreeBusyDeliveryRecord.db.delete(
                _session,
                deliveries,
                transaction: tx,
              );
            }
            await CalendarFreeBusySourceReferenceRecord.db.deleteWhere(
              _session,
              where: (t) => t.commandId.equals(command.id!),
              transaction: tx,
            );
            await CalendarFreeBusyCommandRecord.db.deleteRow(
              _session,
              command,
              transaction: tx,
            );
            changed++;
          } else if (command.sourceId != null) {
            // A deletion-scrubbed marker needs no source-body ownership.
            command.sourceId = null;
            await CalendarFreeBusyCommandRecord.db.updateRow(
              _session,
              command,
              transaction: tx,
            );
          }
        }
        final heads = await CalendarFreeBusyRequestHeadRecord.db.find(
          _session,
          where: (t) => t.scopeKey.equals(scopeKey) & (t.purgedAt <= cutoff),
          limit: options.batchSize,
          transaction: tx,
        );
        for (final head in heads) {
          if (await CalendarFreeBusySourceRecord.db.count(
                _session,
                where: (t) => t.headId.equals(head.id!),
                limit: 1,
                transaction: tx,
              ) ==
              0) {
            await CalendarFreeBusyRequestHeadRecord.db.deleteRow(
              _session,
              head,
              transaction: tx,
            );
          }
        }
      });
    }
  }
}
