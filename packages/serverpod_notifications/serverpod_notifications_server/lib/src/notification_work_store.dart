import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';
import 'notification_runtime.dart';

/// Internal persistence mechanics, not an authorization or enqueue API.
final class NotificationWorkStore {
  NotificationWorkStore(this.session, this.options);
  final Session session;
  final NotificationOptions options;
  static const maxCounter = 9007199254740991;
  Future<DateTime> databaseTime(Transaction tx) async =>
      ((await session.db.unsafeQuery(
                'SELECT clock_timestamp()',
                transaction: tx,
              )).single.single
              as DateTime)
          .toUtc();
  Future<List<NotificationDeliveryRecord>> claim() =>
      session.db.transaction((tx) async {
        final now = await databaseTime(tx);
        final rows = await NotificationDeliveryRecord.db.find(
          session,
          where: (t) =>
              t.state.equals(NotificationDeliveryState.queued) &
              (t.nextAttemptAt <= now) &
              (t.dueAt <= now) &
              (t.leaseUntil.equals(null) | (t.leaseUntil <= now)) &
              (t.leaseFence < maxCounter) &
              (t.attemptCount < maxCounter),
          orderBy: (t) => t.nextAttemptAt,
          limit: options.maxClaims,
          lockMode: LockMode.forUpdate,
          lockBehavior: LockBehavior.skipLocked,
          transaction: tx,
        );
        final claimed = <NotificationDeliveryRecord>[];
        for (final row in rows) {
          row.leaseOwner = const Uuid().v4obj();
          row.leaseFence++;
          row.leaseUntil = now.add(options.leaseDuration);
          await NotificationDeliveryRecord.db.updateRow(
            session,
            row,
            transaction: tx,
          );
          claimed.add(row.copyWith());
        }
        return claimed;
      });
  static bool owns(
    NotificationDeliveryRecord? row,
    NotificationDeliveryRecord lease,
    DateTime now,
  ) =>
      row != null &&
      row.id == lease.id &&
      row.scopeKey == lease.scopeKey &&
      row.requestDigest == lease.requestDigest &&
      row.state == NotificationDeliveryState.queued &&
      row.leaseOwner == lease.leaseOwner &&
      row.leaseFence == lease.leaseFence &&
      row.leaseUntil != null &&
      row.leaseUntil!.isAfter(now);
  Future<int> prune() => session.db.transaction((tx) async {
    final now = await databaseTime(tx);
    final cursors = await NotificationCursorRecord.db.find(
      session,
      where: (t) => t.expiresAt <= now,
      limit: options.maxClaims,
      orderBy: (t) => t.expiresAt,
      lockMode: LockMode.forUpdate,
      lockBehavior: LockBehavior.skipLocked,
      transaction: tx,
    );
    if (cursors.isNotEmpty) {
      await NotificationCursorRecord.db.delete(
        session,
        cursors,
        transaction: tx,
      );
    }
    final rows = await NotificationDeliveryRecord.db.find(
      session,
      where: (t) =>
          t.state.notEquals(NotificationDeliveryState.queued) &
          (t.terminalAt < now.subtract(options.terminalRetention)) &
          (t.expiresAt <= now) &
          (t.leaseUntil.equals(null) | (t.leaseUntil <= now)),
      orderBy: (t) => t.terminalAt,
      limit: options.maxClaims,
      lockMode: LockMode.forUpdate,
      lockBehavior: LockBehavior.skipLocked,
      transaction: tx,
    );
    if (rows.isNotEmpty) {
      await NotificationDeliveryRecord.db.delete(
        session,
        rows,
        transaction: tx,
      );
    }
    return rows.length;
  });
}
