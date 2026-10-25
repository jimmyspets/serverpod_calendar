import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';

/// Server-side work limits. No process-local correctness or calendar clock.
final class CalendarAlarmWorkOptions {
  CalendarAlarmWorkOptions({
    this.leaseDuration = const Duration(seconds: 30),
    this.terminalRetention = const Duration(days: 30),
    this.maxClaims = 100,
    this.maxFirings = 1000,
    this.maxRetainedFirings = 10000,
  }) {
    if (leaseDuration < const Duration(seconds: 1) ||
        leaseDuration > const Duration(minutes: 5) ||
        terminalRetention <= Duration.zero ||
        terminalRetention > const Duration(days: 3660)) {
      throw ArgumentError('Invalid alarm work duration');
    }
    RangeError.checkValueInInterval(maxClaims, 1, 1000);
    RangeError.checkValueInInterval(maxFirings, 1, 10000);
    RangeError.checkValueInInterval(maxRetainedFirings, maxFirings, 100000);
  }
  final Duration leaseDuration, terminalRetention;
  final int maxClaims, maxFirings, maxRetainedFirings;
}

/// Opaque fenced ownership snapshot; a UUID alone never establishes ownership.
final class AlarmPlanLease {
  const AlarmPlanLease({
    required this.planId,
    required this.alarmId,
    required this.scopeKey,
    required this.generation,
    required this.owner,
    required this.fence,
  });
  final UuidValue planId, alarmId, owner;
  final String scopeKey;
  final int generation, fence;
}

/// Internal persistence mechanics, not an authorization or dispatch API.
/// Callers must separately validate actual parent, recipient and lifecycle.
final class AlarmWorkStore {
  AlarmWorkStore(this.session, this.options);
  final Session session;
  final CalendarAlarmWorkOptions options;
  static const maxCounter = 9007199254740991;

  Future<DateTime> databaseTime(Transaction tx) async {
    final rows = await session.db.unsafeQuery(
      'SELECT clock_timestamp()',
      transaction: tx,
    );
    return (rows.single.single as DateTime).toUtc();
  }

  /// Claim only briefly; expensive occurrence calculation follows commit.
  Future<List<AlarmPlanLease>> claimPlans() => session.db.transaction((
    tx,
  ) async {
    final now = await databaseTime(tx);
    final rows = await CalendarAlarmPlanRecord.db.find(
      session,
      where: (t) =>
          (t.nextScanAt <= now) &
          (t.leaseUntil.equals(null) | (t.leaseUntil <= now)),
      orderBy: (t) => t.nextScanAt,
      limit: options.maxClaims,
      lockMode: LockMode.forUpdate,
      lockBehavior: LockBehavior.skipLocked,
      transaction: tx,
    );
    final leases = <AlarmPlanLease>[];
    for (final row in rows) {
      if (row.leaseFence < 0 || row.leaseFence >= maxCounter) {
        // Exhaustion is fail-closed and never wraps to an old fence.
        row.status = CalendarAlarmPlanStatus.needsAttention;
        row.reason = 'counterExhausted';
        row.dirty = true;
        row.nextScanAt = now.add(const Duration(days: 1));
        await CalendarAlarmPlanRecord.db.updateRow(
          session,
          row,
          transaction: tx,
        );
        continue;
      }
      row.leaseOwner = const Uuid().v4obj();
      row.leaseFence++;
      row.leaseUntil = now.add(options.leaseDuration);
      await CalendarAlarmPlanRecord.db.updateRow(session, row, transaction: tx);
      leases.add(
        AlarmPlanLease(
          planId: row.id!,
          alarmId: row.alarmId,
          scopeKey: row.scopeKey,
          generation: row.generation,
          owner: row.leaseOwner!,
          fence: row.leaseFence,
        ),
      );
    }
    return List.unmodifiable(leases);
  });

  /// Must run after acquiring the trusted scope lock, in the committing tx.
  Future<CalendarAlarmPlanRecord?> ownedPlan(
    AlarmPlanLease lease,
    Transaction tx,
  ) async {
    final row = await CalendarAlarmPlanRecord.db.findById(
      session,
      lease.planId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    final now = await databaseTime(tx);
    if (row == null ||
        row.alarmId != lease.alarmId ||
        row.scopeKey != lease.scopeKey ||
        row.generation != lease.generation ||
        row.leaseOwner != lease.owner ||
        row.leaseFence != lease.fence ||
        row.leaseUntil == null ||
        !row.leaseUntil!.isAfter(now)) {
      return null;
    }
    return row;
  }

  /// Bounded terminal-only pruning; action rows are deliberately untouched.
  /// An active lease, pending retry or missing terminal time never qualifies.
  Future<int> pruneTerminalHistory() => session.db.transaction((tx) async {
    final now = await databaseTime(tx);
    final cutoff = now.subtract(options.terminalRetention);
    final rows = await CalendarAlarmFiringRecord.db.find(
      session,
      where: (t) =>
          t.state.notEquals(CalendarAlarmFiringState.pending) &
          (t.terminalAt <= cutoff) &
          (t.leaseUntil.equals(null) | (t.leaseUntil <= now)),
      orderBy: (t) => t.terminalAt,
      limit: options.maxClaims,
      lockMode: LockMode.forUpdate,
      lockBehavior: LockBehavior.skipLocked,
      transaction: tx,
    );
    if (rows.isEmpty) return 0;
    await CalendarAlarmFiringRecord.db.deleteWhere(
      session,
      where: (t) => t.id.inSet(rows.map((r) => r.id!).toSet()),
      transaction: tx,
      noReturn: true,
    );
    return rows.length;
  });
}
