import 'timed_value.dart';
import 'utc_window.dart';

enum TaskAlarmStatus { needsAction, inProcess, completed, cancelled }

/// Independent optional source fields remain intact; this is delivery policy.
final class TaskAlarmProgress {
  TaskAlarmProgress({this.status, this.percentComplete, this.completedAt}) {
    if (percentComplete != null) {
      RangeError.checkValueInInterval(percentComplete!, 0, 100);
    }
    if (completedAt != null) TimedValue.utc(completedAt!);
  }
  final TaskAlarmStatus? status;
  final int? percentComplete;
  final DateTime? completedAt;
  bool get suppresses =>
      status == TaskAlarmStatus.completed ||
      status == TaskAlarmStatus.cancelled ||
      percentComplete == 100 ||
      completedAt != null;
}

final class AlarmFiringCandidate {
  AlarmFiringCandidate({
    required this.originalKey,
    required this.repeatOrdinal,
    required this.dueAt,
  }) {
    if (originalKey.isEmpty || originalKey.length > 512) {
      throw ArgumentError('Invalid original identity');
    }
    RangeError.checkValueInInterval(repeatOrdinal, 0, 100);
    TimedValue.utc(dueAt);
  }
  final String originalKey;
  final int repeatOrdinal;
  final DateTime dueAt;
}

enum AlarmFiringDisposition { pending, suppressed, expired }

final class PlannedAlarmFiring {
  const PlannedAlarmFiring._(this.candidate, this.expiresAt, this.disposition);
  final AlarmFiringCandidate candidate;
  final DateTime expiresAt;
  final AlarmFiringDisposition disposition;
}

final class AlarmPlanLimitException implements Exception {
  const AlarmPlanLimitException();
  @override
  String toString() => 'Complete alarm plan exceeds its work or firing budget';
}

/// Complete private plan for one alarm definition. Never an authorized result.
/// Any enumeration/validation/budget failure throws before returning any plan.
final class AlarmPlan {
  AlarmPlan._(this.window, this.firings);
  final UtcWindow window;
  final List<PlannedAlarmFiring> firings;

  factory AlarmPlan.complete({
    required UtcWindow window,
    required DateTime now,
    required Iterable<AlarmFiringCandidate> candidates,
    Duration grace = const Duration(minutes: 15),
    int maxFirings = 1000,
    int maxScannedCandidates = 100000,
    Set<String> suppressedOriginals = const {},
    bool lifecycleSuppressed = false,
    Map<String, DateTime> resetCutoffs = const {},
  }) {
    TimedValue.utc(window.start);
    TimedValue.utcEnd(window.end);
    if (!now.isUtc ||
        now.isBefore(DateTime.utc(1970)) ||
        !now.isBefore(DateTime.utc(2100))) {
      throw ArgumentError('Explicit supported UTC clock required');
    }
    if (grace <= Duration.zero ||
        grace > const Duration(days: 1) ||
        grace.inMicroseconds % 1000000 != 0) {
      throw ArgumentError('Grace must be positive whole seconds up to one day');
    }
    RangeError.checkValueInInterval(maxFirings, 1, 10000);
    RangeError.checkValueInInterval(maxScannedCandidates, 1, 1000000);
    final actions = Set<String>.unmodifiable(suppressedOriginals);
    final cutoffs = Map<String, DateTime>.unmodifiable(resetCutoffs);
    for (final cutoff in cutoffs.values) {
      if (!cutoff.isUtc ||
          cutoff.isBefore(DateTime.utc(1970)) ||
          !cutoff.isBefore(DateTime.utc(2100))) {
        throw ArgumentError(
          'Reset cutoff requires a supported UTC database instant',
        );
      }
    }
    bool resetSuppressed(AlarmFiringCandidate c) =>
        cutoffs[c.originalKey] != null &&
        !c.dueAt.isAfter(cutoffs[c.originalKey]!);
    final values = <AlarmFiringCandidate>[];
    final identities = <(String, int)>{};
    var scanned = 0;
    for (final candidate in candidates) {
      if (++scanned > maxScannedCandidates) {
        throw const AlarmPlanLimitException();
      }
      if (!window.contains(candidate.dueAt)) continue;
      if (!identities.add((candidate.originalKey, candidate.repeatOrdinal))) {
        throw ArgumentError('Duplicate original/repeat identity');
      }
      if (values.length >= maxFirings) throw const AlarmPlanLimitException();
      values.add(candidate);
    }
    values.sort((a, b) {
      final due = a.dueAt.compareTo(b.dueAt);
      if (due != 0) return due;
      final original = a.originalKey.compareTo(b.originalKey);
      return original != 0
          ? original
          : a.repeatOrdinal.compareTo(b.repeatOrdinal);
    });
    DateTime expiry(AlarmFiringCandidate value) {
      final end = value.dueAt.add(grace), limit = DateTime.utc(2100);
      return end.isAfter(limit) ? limit : end;
    }

    AlarmFiringCandidate? latest;
    for (final value in values) {
      if (!lifecycleSuppressed &&
          !actions.contains(value.originalKey) &&
          !resetSuppressed(value) &&
          !value.dueAt.isAfter(now) &&
          expiry(value).isAfter(now)) {
        latest = value;
      }
    }
    return AlarmPlan._(
      window,
      List.unmodifiable([
        for (final value in values)
          PlannedAlarmFiring._(
            value,
            expiry(value),
            !expiry(value).isAfter(now)
                ? AlarmFiringDisposition.expired
                : lifecycleSuppressed ||
                      actions.contains(value.originalKey) ||
                      resetSuppressed(value) ||
                      (!value.dueAt.isAfter(now) && !identical(value, latest))
                ? AlarmFiringDisposition.suppressed
                : AlarmFiringDisposition.pending,
          ),
      ]),
    );
  }
}
