@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_values.dart';
import 'package:serverpod_calendar_server/src/task_recurrence_values.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;

final id = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
CalendarEventCivil civil(int day, {int hour = 0}) =>
    CalendarEventCivil(year: 2026, month: 3, day: day, hour: hour);
CalendarEventRule rule({int count = 3}) => CalendarEventRule(
  frequency: CalendarEventFrequency.daily,
  count: count,
  byDay: [],
  byMonthDay: [],
  byYearDay: [],
  byWeekNo: [],
  byMonth: [],
  byHour: [],
  byMinute: [],
  bySetPosition: [],
);
CalendarTaskContent content({
  CalendarTaskTimeKind kind = CalendarTaskTimeKind.date,
  CalendarEventDuration? duration,
  CalendarEventCivil? due,
}) => validateTaskContent(
  CalendarTaskContent(
    timing: CalendarTaskTiming(
      kind: kind,
      start: civil(28, hour: kind == CalendarTaskTimeKind.date ? 0 : 9),
      zoneId: kind == CalendarTaskTimeKind.zoned ? 'Europe/Stockholm' : null,
      duration: duration,
      due: due,
    ),
    recurrence: CalendarEventRecurrence(
      rule: rule(),
      inclusions: [],
      exclusions: [],
    ),
  ),
);
CalendarTaskOccurrenceQuery query({bool date = true}) =>
    CalendarTaskOccurrenceQuery(
      taskId: id,
      expectedRevision: 1,
      fromDate: date ? civil(27) : null,
      untilDate: date ? civil(31) : null,
      fromUtc: date ? null : DateTime.utc(2026, 3, 27),
      untilUtc: date ? null : DateTime.utc(2026, 3, 31),
    );

void main() {
  test('task DATE recurring projections preserve due offsets and independent defaults', () {
    final c = content(due: civil(29));
    final values = previewTaskValues(c, query());
    expect(values.map((v) => v.originalStart.start.day), [28, 29, 30]);
    expect(values.map((v) => v.dueDate!.day), [29, 30, 31]);
    expect(values.every((v) => v.progress.percentComplete == 0), isTrue);
    expect(values.every((v) => v.startUtc == null && v.dueUtc == null), isTrue);
    requireTaskOriginals(c, values.map((v) => v.originalStart).toList());
  });
  test('zoned nominal days differ from explicit elapsed due across DST', () {
    final nominal = previewTaskValues(
      content(
        kind: CalendarTaskTimeKind.zoned,
        duration: CalendarEventDuration(days: 1),
      ),
      query(date: false),
    );
    final elapsed = previewTaskValues(
      content(kind: CalendarTaskTimeKind.zoned, due: civil(29, hour: 9)),
      query(date: false),
    );
    expect(
      nominal.first.dueUtc!.difference(nominal.first.startUtc!).inHours,
      23,
    );
    expect(nominal[1].dueUtc!.difference(nominal[1].startUtc!).inHours, 24);
    expect(elapsed[1].dueUtc!.difference(elapsed[1].startUtc!).inHours, 23);
    expect(nominal[1].originalStart.start.hour, 9);
  });
  test('recurrence requires explicit start while due-only non-recurring remains valid', () {
    final dueOnly = CalendarTaskContent(
      timing: CalendarTaskTiming(
        kind: CalendarTaskTimeKind.date,
        due: civil(29),
      ),
    );
    expect(validateTaskContent(dueOnly).timing.start, isNull);
    expect(
      () => validateTaskContent(
        dueOnly.copyWith(recurrence: content().recurrence),
      ),
      throwsArgumentError,
    );
    expect(() => previewTaskValues(dueOnly, query()), throwsArgumentError);
  });
  test('exact original identity rejects excluded absent profile-changed and interval forms', () {
    final c = content(), first = taskAnchor(c.timing);
    final excluded = validateTaskContent(
      c.copyWith(recurrence: c.recurrence!.copyWith(exclusions: [first])),
    );
    expect(() => requireTaskOriginal(excluded, first), throwsArgumentError);
    expect(
      () => requireTaskOriginal(c, first.copyWith(start: civil(31))),
      throwsArgumentError,
    );
    expect(
      () => requireTaskOriginal(
        c,
        first.copyWith(kind: CalendarEventTimeKind.utc),
      ),
      throwsArgumentError,
    );
    expect(
      () => taskOriginalKey(
        first.copyWith(duration: CalendarEventDuration(days: 1)),
      ),
      throwsArgumentError,
    );
    expect(() => requireTaskOriginals(excluded, [first]), throwsArgumentError);
  });
  test('earlier explicit inclusions and exclusion precedence preserve original keys', () {
    final c = content(),
        earlier = taskAnchor(c.timing).copyWith(start: civil(27));
    final added = validateTaskContent(
      c.copyWith(
        recurrence: c.recurrence!.copyWith(inclusions: [earlier, earlier]),
      ),
    );
    final values = previewTaskValues(added, query());
    expect(values, hasLength(4));
    expect(
      taskOriginalKey(values.first.originalStart),
      taskOriginalKey(earlier),
    );
    final removed = validateTaskContent(
      added.copyWith(
        recurrence: added.recurrence!.copyWith(exclusions: [earlier]),
      ),
    );
    expect(previewTaskValues(removed, query()), hasLength(3));
  });
  test('preview validates whole-second bound kinds maximum windows and result budget', () {
    final c = content(kind: CalendarTaskTimeKind.utc);
    expect(() => previewTaskValues(c, query()), throwsArgumentError);
    expect(
      () => previewTaskValues(
        c,
        query(date: false).copyWith(untilUtc: DateTime.utc(2028)),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => previewTaskValues(
        c,
        query(date: false)
            .copyWith(fromUtc: DateTime.utc(2026, 3, 27, 0, 0, 0, 1)),
      ),
      throwsArgumentError,
    );
    final dense = validateTaskContent(
      c.copyWith(
        recurrence: c.recurrence!.copyWith(
          rule: rule(count: 800)
              .copyWith(frequency: CalendarEventFrequency.minutely),
        ),
      ),
    );
    expect(
      () => previewTaskValues(dense, query(date: false)),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
}
