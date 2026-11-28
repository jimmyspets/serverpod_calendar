import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

DateTime at(int minute, [int second = 0]) =>
    DateTime.utc(2026, 3, 29, 12, minute, second);
AlarmFiringCandidate candidate(
  int minute, {
  String key = 'original',
  int ordinal = 0,
}) => AlarmFiringCandidate(
  originalKey: key,
  repeatOrdinal: ordinal,
  dueAt: at(minute),
);
AlarmPlan plan(
  Iterable<AlarmFiringCandidate> values, {
  int cap = 1000,
  Set<String> actions = const {},
  bool suppressed = false,
  DateTime? now,
}) => AlarmPlan.complete(
  window: UtcWindow(
    start: DateTime.utc(2026, 3, 29, 11),
    end: DateTime.utc(2026, 4, 28, 12),
  ),
  now: now ?? at(30),
  candidates: values,
  maxFirings: cap,
  suppressedOriginals: actions,
  lifecycleSuppressed: suppressed,
);

void main() {
  test('recovery keeps latest eligible; earlier eligible and expired remain distinct', () {
    final result = plan([
      candidate(10, ordinal: 0),
      candidate(20, ordinal: 1),
      candidate(25, ordinal: 2),
      candidate(40, ordinal: 3),
    ]);
    expect(result.firings.map((f) => f.disposition), [
      AlarmFiringDisposition.expired,
      AlarmFiringDisposition.suppressed,
      AlarmFiringDisposition.pending,
      AlarmFiringDisposition.pending,
    ]);
    expect(() => result.firings.clear(), throwsUnsupportedError);
  });
  test('eligibility expiry is exclusive and shared clock fractions are not rounded', () {
    expect(
      plan([candidate(15)]).firings.single.disposition,
      AlarmFiringDisposition.expired,
    );
    expect(
      plan(
        [candidate(16)],
        now: at(31).subtract(const Duration(microseconds: 1)),
      ).firings.single.disposition,
      AlarmFiringDisposition.pending,
    );
  });
  test('acknowledgement suppresses every repeat of that original only', () {
    final result = plan(
      [
        candidate(25, key: 'acked'),
        candidate(40, key: 'acked', ordinal: 1),
        candidate(41, key: 'other'),
      ],
      actions: {'acked'},
    );
    expect(result.firings.map((f) => f.disposition), [
      AlarmFiringDisposition.suppressed,
      AlarmFiringDisposition.suppressed,
      AlarmFiringDisposition.pending,
    ]);
  });
  test('budget applies before coalescing and suppression, never returns a partial plan', () {
    expect(
      () => plan([candidate(25), candidate(26, ordinal: 1)], cap: 1),
      throwsA(isA<AlarmPlanLimitException>()),
    );
    expect(
      () => plan(
        [candidate(25), candidate(26, ordinal: 1)],
        cap: 1,
        suppressed: true,
      ),
      throwsA(isA<AlarmPlanLimitException>()),
    );
    Iterable<AlarmFiringCandidate> failsLate() sync* {
      yield candidate(25);
      throw StateError('Incomplete enumeration');
    }

    expect(() => plan(failsLate()), throwsStateError);
  });
  test('duplicate identities reject; equal instants use deterministic original/ordinal order', () {
    expect(() => plan([candidate(25), candidate(26)]), throwsArgumentError);
    final a = candidate(25, key: 'a'), b = candidate(25, key: 'b');
    final result = plan([b, a]);
    expect(result.firings.first.candidate.originalKey, 'a');
    expect(result.firings.first.disposition, AlarmFiringDisposition.suppressed);
    expect(result.firings.last.candidate.originalKey, 'b');
    expect(result.firings.last.disposition, AlarmFiringDisposition.pending);
  });
  test(
    'source progress fields suppress independently without normalization',
    () {
      for (final value in [
        TaskAlarmProgress(status: TaskAlarmStatus.completed),
        TaskAlarmProgress(status: TaskAlarmStatus.cancelled),
        TaskAlarmProgress(percentComplete: 100),
        TaskAlarmProgress(
          status: TaskAlarmStatus.needsAction,
          completedAt: at(0),
        ),
      ]) {
        expect(value.suppresses, isTrue);
      }
      final neutral = TaskAlarmProgress(percentComplete: 99);
      expect(neutral.status, isNull);
      expect(neutral.completedAt, isNull);
      expect(neutral.suppresses, isFalse);
      expect(() => TaskAlarmProgress(percentComplete: 101), throwsRangeError);
    },
  );
  test(
    'future lifecycle suppression and expiry bounds do not extend the profile',
    () {
      expect(
        plan([candidate(40)], suppressed: true).firings.single.disposition,
        AlarmFiringDisposition.suppressed,
      );
      final due = DateTime.utc(2099, 12, 31, 23, 59, 59);
      final result = AlarmPlan.complete(
        window: UtcWindow(start: due, end: DateTime.utc(2100)),
        now: due,
        candidates: [
          AlarmFiringCandidate(
            originalKey: 'end',
            repeatOrdinal: 0,
            dueAt: due,
          ),
        ],
      );
      expect(result.firings.single.expiresAt, DateTime.utc(2100));
      expect(
        () => AlarmFiringCandidate(
          originalKey: 'x',
          repeatOrdinal: 0,
          dueAt: DateTime.utc(2100),
        ),
        throwsRangeError,
      );
    },
  );
  test('action state is captured before candidate enumeration', () {
    final actions = <String>{'acked'};
    Iterable<AlarmFiringCandidate> values() sync* {
      actions.clear();
      yield candidate(40, key: 'acked');
    }

    expect(
      plan(values(), actions: actions).firings.single.disposition,
      AlarmFiringDisposition.suppressed,
    );
  });
  test('scan budgets include discarded out-of-window input', () {
    expect(
      () => AlarmPlan.complete(
        window: UtcWindow(start: at(20), end: at(30)),
        now: at(25),
        candidates: [candidate(0), candidate(1, ordinal: 1)],
        maxScannedCandidates: 1,
      ),
      throwsA(isA<AlarmPlanLimitException>()),
    );
  });
}
