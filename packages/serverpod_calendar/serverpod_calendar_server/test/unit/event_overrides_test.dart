@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

final id = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
CalendarEventTiming timing(
  int day, {
  CalendarEventTimeKind kind = CalendarEventTimeKind.date,
  int hour = 0,
  int? days,
}) => CalendarEventTiming(
  kind: kind,
  start: CalendarEventCivil(year: 2026, month: 3, day: day, hour: hour),
  zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
  duration: days == null ? null : CalendarEventDuration(days: days),
);
CalendarEventContent content({
  CalendarEventTimeKind kind = CalendarEventTimeKind.date,
  int hour = 0,
}) => validateEventContent(
  CalendarEventContent(
    timing: timing(28, kind: kind, hour: hour, days: 1),
    recurrence: CalendarEventRecurrence(
      rule: CalendarEventRule(
        frequency: CalendarEventFrequency.daily,
        count: 5,
        byDay: [],
        byMonthDay: [],
        byYearDay: [],
        byWeekNo: [],
        byMonth: [],
        byHour: [],
        byMinute: [],
        bySetPosition: [],
      ),
      inclusions: [],
      exclusions: [],
    ),
  ),
);
CalendarEventOccurrenceChange change(
  CalendarEventTiming anchor,
  CalendarEventOccurrenceAction action, {
  CalendarEventTiming? replacement,
}) => CalendarEventOccurrenceChange(
  eventId: id,
  expectedRevision: 1,
  originalStart: anchor,
  action: action,
  replacement: replacement,
);
CalendarEventOccurrenceQuery query({
  bool timed = false,
}) => CalendarEventOccurrenceQuery(
  eventId: id,
  expectedRevision: 1,
  fromDate: timed ? null : CalendarEventCivil(year: 2026, month: 3, day: 25),
  untilDate: timed ? null : CalendarEventCivil(year: 2026, month: 4, day: 5),
  fromUtc: timed ? DateTime.utc(2026, 3, 25) : null,
  untilUtc: timed ? DateTime.utc(2026, 4, 5) : null,
);
void main() {
  test('DATE future timing preserves original order and separate moved-in single identity', () {
    final c = content();
    var v = changeEventOverrides(
      c,
      null,
      change(
        timing(29),
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: timing(30, days: 2),
      ),
    );
    v = changeEventOverrides(
      c,
      v,
      change(
        timing(30),
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: timing(26, days: 3),
      ),
    );
    final p = previewEventOccurrences(c, query(), overrides: v);
    expect(p.occurrences.first.originalStart.day, 30);
    expect(p.occurrences.first.start.day, 26);
    expect(p.occurrences.map((o) => o.originalStart.day), [30, 28, 29, 31, 1]);
    expect(p.occurrences[2].endDate!.day, 1);
    expect(() => v!.singles.clear(), throwsUnsupportedError);
  });
  test('single cancellation retains timing; restore and clear timing are independent', () {
    final c = content();
    final anchor = timing(29);
    var v = changeEventOverrides(
      c,
      null,
      change(
        anchor,
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: timing(26),
      ),
    );
    v = changeEventOverrides(
      c,
      v,
      change(anchor, CalendarEventOccurrenceAction.cancelSingle),
    );
    expect(v!.singles.single.replacement!.start.day, 26);
    expect(
      previewEventOccurrences(c, query(), overrides: v).occurrences.length,
      4,
    );
    v = changeEventOverrides(
      c,
      v,
      change(anchor, CalendarEventOccurrenceAction.restoreSingle),
    );
    expect(
      previewEventOccurrences(
        c,
        query(),
        overrides: v,
      ).occurrences.first.start.day,
      26,
    );
    v = changeEventOverrides(
      c,
      v,
      change(anchor, CalendarEventOccurrenceAction.cancelSingle),
    );
    v = changeEventOverrides(
      c,
      v,
      change(anchor, CalendarEventOccurrenceAction.clearSingleTiming),
    );
    expect(v!.singles.single.cancelled, isTrue);
    expect(v.singles.single.replacement, isNull);
    v = changeEventOverrides(
      c,
      v,
      change(anchor, CalendarEventOccurrenceAction.restoreSingle),
    );
    expect(v, isNull);
    expect(previewEventOccurrences(c, query()).occurrences.length, 5);
  });
  test('later future changes use absolute shifts; clearing reveals preceding segment', () {
    final c = content();
    var v = changeEventOverrides(
      c,
      null,
      change(
        timing(29),
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: timing(30),
      ),
    );
    v = changeEventOverrides(
      c,
      v,
      change(
        timing(31),
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: timing(29),
      ),
    );
    final p = previewEventOccurrences(c, query(), overrides: v);
    expect(
      p.occurrences.singleWhere((o) => o.originalStart.day == 31).start.day,
      29,
    );
    v = changeEventOverrides(
      c,
      v,
      change(timing(31), CalendarEventOccurrenceAction.clearFutureTiming),
    );
    expect(
      previewEventOccurrences(
        c,
        query(),
        overrides: v,
      ).occurrences.singleWhere((o) => o.originalStart.day == 31).start.day,
      1,
    );
  });
  test('UTC and zoned projections retain moved identities and nominal-day DST semantics', () {
    for (final kind in [
      CalendarEventTimeKind.utc,
      CalendarEventTimeKind.zoned,
    ]) {
      final c = content(kind: kind, hour: 12);
      var v = changeEventOverrides(
        c,
        null,
        change(
          timing(30, kind: kind, hour: 12),
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: timing(28, kind: kind, hour: 12, days: 1),
        ),
      );
      final p = previewEventOccurrences(c, query(timed: true), overrides: v);
      expect(p.occurrences.length, 5);
      final moved = p.occurrences.singleWhere((o) => o.originalStart.day == 30);
      expect(moved.start.day, 28);
      expect(
        moved.endUtc!.difference(moved.startUtc!),
        Duration(hours: kind == CalendarEventTimeKind.zoned ? 23 : 24),
      );
      expect(p.occurrences.where((o) => o.start.day == 28).length, 2);
      v = changeEventOverrides(
        c,
        v,
        change(
          timing(29, kind: kind, hour: 12),
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: timing(30, kind: kind, hour: 12, days: 1),
        ),
      );
      expect(
        previewEventOccurrences(
          c,
          query(timed: true),
          overrides: v,
        ).occurrences.singleWhere((o) => o.originalStart.day == 30).start.day,
        28,
      );
    }
  });
  test(
    'orphaned excluded duplicate or same-anchor single/future edits reject',
    () {
      final c = content();
      final v = changeEventOverrides(
        c,
        null,
        change(timing(29), CalendarEventOccurrenceAction.cancelSingle),
      )!;
      expect(
        () => validateEventOverrides(
          c.copyWith(
            recurrence: c.recurrence!.copyWith(exclusions: [timing(29)]),
          ),
          v,
        ),
        throwsArgumentError,
      );
      expect(
        () => validateEventOverrides(
          c.copyWith(
            recurrence: c.recurrence!.copyWith(
              rule: c.recurrence!.rule!.copyWith(count: 1),
            ),
          ),
          v,
        ),
        throwsArgumentError,
      );
      expect(
        () => changeEventOverrides(
          c,
          null,
          change(timing(27), CalendarEventOccurrenceAction.cancelSingle),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeEventOverrides(
          c,
          v,
          change(
            timing(29),
            CalendarEventOccurrenceAction.replaceFutureTiming,
            replacement: timing(30),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateEventOverrides(
          c,
          CalendarEventTimingOverrides(
            singles: [...v.singles, ...v.singles],
            future: [],
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'reject mixed profiles fractions anchor spans malformed action and raw cap',
    () {
      final c = content();
      for (final bad in [
        timing(29, kind: CalendarEventTimeKind.utc),
        timing(29, days: 1),
        timing(29).copyWith(start: timing(29).start.copyWith(microsecond: 1)),
      ]) {
        expect(
          () => changeEventOverrides(
            c,
            null,
            change(bad, CalendarEventOccurrenceAction.cancelSingle),
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => changeEventOverrides(
          c,
          null,
          change(timing(29), CalendarEventOccurrenceAction.replaceSingleTiming),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeEventOverrides(
          c,
          null,
          change(
            timing(29),
            CalendarEventOccurrenceAction.cancelSingle,
            replacement: timing(30),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => changeEventOverrides(
          c,
          null,
          change(timing(29), CalendarEventOccurrenceAction.restoreSingle),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateEventOverrides(
          c,
          CalendarEventTimingOverrides(
            singles: List.filled(
              129,
              CalendarEventSingleOverride(
                originalStart: timing(29),
                cancelled: true,
              ),
            ),
            future: [],
          ),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
}
