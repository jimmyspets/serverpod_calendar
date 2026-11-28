@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_values.dart';

CalendarEventCivil civil(int day, {int hour = 0, int microsecond = 0}) =>
    CalendarEventCivil(
      year: 2026,
      month: 3,
      day: day,
      hour: hour,
      microsecond: microsecond,
    );
CalendarTaskContent content(CalendarTaskTiming timing) =>
    CalendarTaskContent(timing: timing);
void main() {
  test(
    'undated and independent start-only due-only task values remain milestones',
    () {
      final undated = CalendarTaskTiming(kind: CalendarTaskTimeKind.undated);
      expect(validateTaskContent(content(undated)).timing.start, isNull);
      expect(
        () => validateTaskContent(content(undated.copyWith(zoneId: 'UTC'))),
        throwsArgumentError,
      );
      final due = CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        due: civil(29),
      );
      expect(validateTaskContent(content(due)).timing.start, isNull);
      expect(
        validateTaskContent(
          content(
            CalendarTaskTiming(
              kind: CalendarTaskTimeKind.utc,
              start: civil(29, hour: 9),
            ),
          ),
        ).timing.due,
        isNull,
      );
    },
  );
  test('DATE due constraints and ordinary year boundary reject invalid native values', () {
    for (final value in [
      CalendarTaskTiming(kind: CalendarTaskTimeKind.date),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        due: civil(29, hour: 1),
      ),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        start: civil(29),
        due: civil(29),
      ),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        due: CalendarEventCivil(year: 2100, month: 1, day: 1),
      ),
      CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        start: CalendarEventCivil(year: 2099, month: 12, day: 31),
        duration: CalendarEventDuration(days: 1),
      ),
    ]) {
      expect(() => validateTaskContent(content(value)), throwsArgumentError);
    }
  });
  test(
    'positive nominal units and explicit due preserve native source forms',
    () {
      final nominal = CalendarTaskTiming(
        kind: CalendarTaskTimeKind.zoned,
        start: civil(28, hour: 12),
        zoneId: 'Europe/Stockholm',
        duration: CalendarEventDuration(days: 1),
      );
      expect(validateTaskContent(content(nominal)).timing.duration!.days, 1);
      expect(
        validateTaskContent(
          content(nominal.copyWith(duration: CalendarEventDuration(hours: 24))),
        ).timing.duration!.hours,
        24,
      );
      expect(
        () => validateTaskContent(
          content(nominal.copyWith(due: civil(30, hour: 12))),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateTaskContent(
          content(
            CalendarTaskTiming(
              kind: CalendarTaskTimeKind.utc,
              due: civil(29),
              duration: CalendarEventDuration(hours: 1),
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateTaskContent(
          content(nominal.copyWith(duration: CalendarEventDuration())),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'UTC named profiles and whole-second precision reject malformed input',
    () {
      for (final t in [
        CalendarTaskTiming(
          kind: CalendarTaskTimeKind.utc,
          start: civil(29, microsecond: 1),
        ),
        CalendarTaskTiming(
          kind: CalendarTaskTimeKind.utc,
          start: civil(29),
          zoneId: 'UTC',
        ),
        CalendarTaskTiming(kind: CalendarTaskTimeKind.zoned, due: civil(29)),
        CalendarTaskTiming(
          kind: CalendarTaskTimeKind.zoned,
          due: civil(29),
          zoneId: 'europe/stockholm',
        ),
        CalendarTaskTiming(
          kind: CalendarTaskTimeKind.date,
          start: civil(29),
          duration: CalendarEventDuration(hours: 1),
        ),
      ]) {
        expect(() => validateTaskContent(content(t)), throwsArgumentError);
      }
    },
  );
  test(
    'priority text and unsupported recurrence are validated without trimming',
    () {
      final c = content(CalendarTaskTiming(kind: CalendarTaskTimeKind.undated))
          .copyWith(summary: '', description: '  Notes\n', priority: 0);
      expect(validateTaskContent(c).description, '  Notes\n');
      expect(
        () => validateTaskContent(c.copyWith(priority: 10)),
        throwsArgumentError,
      );
      expect(
        () => validateTaskContent(
          c.copyWith(
            recurrence: CalendarEventRecurrence(inclusions: [], exclusions: []),
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'completion reopen and cancellation use selected native transitions',
    () {
      final id = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
      CalendarTaskProgressRequest request(
        CalendarTaskProgressAction action, {
        int? percent,
      }) => CalendarTaskProgressRequest(
        taskId: id,
        expectedRevision: 1,
        action: action,
        percentComplete: percent,
      );
      final initial = CalendarTaskProgress();
      final progress = changeTaskProgressValue(
        initial,
        request(CalendarTaskProgressAction.setPercentage, percent: 63),
        DateTime.utc(2026),
      );
      expect(progress.status, CalendarTaskStatus.inProcess);
      final complete = changeTaskProgressValue(
        progress,
        request(CalendarTaskProgressAction.complete),
        DateTime.utc(2026, 3, 29, 12, 0, 0, 999),
      );
      expect(complete.percentComplete, 100);
      expect(complete.completedAt, DateTime.utc(2026, 3, 29, 12));
      expect(
        changeTaskProgressValue(
          complete,
          request(CalendarTaskProgressAction.complete),
          DateTime.utc(2026, 4),
        ).completedAt,
        complete.completedAt,
      );
      final cancelled = changeTaskProgressValue(
        complete,
        request(CalendarTaskProgressAction.cancel),
        DateTime.utc(2026),
      );
      expect(cancelled.percentComplete, 100);
      expect(cancelled.completedAt, isNull);
      final reopened = changeTaskProgressValue(
        cancelled,
        request(CalendarTaskProgressAction.reopen),
        DateTime.utc(2026),
      );
      expect(reopened.status, CalendarTaskStatus.needsAction);
      expect(reopened.percentComplete, 0);
      expect(reopened.completedAt, isNull);
      expect(
        () => changeTaskProgressValue(
          cancelled,
          request(CalendarTaskProgressAction.complete),
          DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeTaskProgressValue(
          complete,
          request(CalendarTaskProgressAction.setPercentage, percent: 20),
          DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeTaskProgressValue(
          initial,
          request(CalendarTaskProgressAction.setPercentage, percent: 100),
          DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeTaskProgressValue(
          initial,
          request(CalendarTaskProgressAction.complete, percent: 10),
          DateTime.utc(2026),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'progress constraints never accept forged incomplete completion values',
    () {
      for (final p in [
        CalendarTaskProgress(percentComplete: 1),
        CalendarTaskProgress(
          status: CalendarTaskStatus.completed,
          percentComplete: 100,
        ),
        CalendarTaskProgress(
          status: CalendarTaskStatus.inProcess,
          percentComplete: 100,
        ),
        CalendarTaskProgress(completedAt: DateTime.utc(2026)),
      ]) {
        expect(() => validateTaskProgress(p), throwsArgumentError);
      }
    },
  );
  test('opaque assignments canonicalize exactly after charging raw limits', () {
    final a = CalendarTaskAssignee(
          namespace: 'host',
          kind: 'user',
          externalId: 'A',
        ),
        b = CalendarTaskAssignee(
          namespace: 'host',
          kind: 'user',
          externalId: 'a',
        );
    final values = validateTaskAssignees([b, a, a]);
    expect(values.map((v) => v.externalId), ['A', 'a']);
    expect(() => values.clear(), throwsUnsupportedError);
    expect(
      () => validateTaskAssignees(List.filled(129, a)),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => validateTaskAssignees([a.copyWith(namespace: 'invalid space')]),
      throwsArgumentError,
    );
    expect(
      () => validateTaskAssignees([a.copyWith(externalId: '')]),
      throwsArgumentError,
    );
  });
  test(
    'native protocol version times never regress and sequence cannot overflow',
    () {
      final v = CalendarTaskProtocolVersion(
        sequence: 8,
        stamp: DateTime.utc(2040),
        created: DateTime.utc(2026),
        lastModified: DateTime.utc(2041),
      );
      final next = advanceTaskVersion(v, DateTime.utc(2026));
      expect(next.sequence, 9);
      expect(next.stamp, DateTime.utc(2041));
      expect(next.created, v.created);
      expect(
        () => advanceTaskVersion(
          v.copyWith(sequence: 2147483647),
          DateTime.utc(2026),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
}
