@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

import 'event_values_test.dart' show rule;

CalendarEventCivil c(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
]) => CalendarEventCivil(
  year: year,
  month: month,
  day: day,
  hour: hour,
  minute: minute,
);
CalendarEventTiming utc(int day, [int hour = 9]) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: c(2026, 1, day, hour),
);

void main() {
  List<EventOccurrenceWindowProjection> project(
    CalendarEventContent content,
    DateTime start,
    DateTime end, {
    CalendarEventTimingOverrides? edits,
    String zone = 'UTC',
    EventOccurrenceQueryWork? work,
  }) => eventOccurrenceWindow(
    validateEventContent(content),
    validateEventOverrides(content, edits),
    UtcWindow(start: start, end: end),
    dateZone: zone,
    groups: {
      CalendarEventFieldGroup.timing,
      CalendarEventFieldGroup.state,
      CalendarEventFieldGroup.summary,
    },
    work: work ?? EventOccurrenceQueryWork(maxWork: 100000, maxResults: 10000),
  );

  test('half-open overlap retains full spans and point membership', () {
    final point = CalendarEventContent(timing: utc(2));
    expect(
      project(point, DateTime.utc(2026, 1, 2, 9), DateTime.utc(2026, 1, 2, 10)),
      hasLength(1),
    );
    expect(
      project(point, DateTime.utc(2026, 1, 2, 8), DateTime.utc(2026, 1, 2, 9)),
      isEmpty,
    );
    final span = CalendarEventContent(
      timing: utc(1).copyWith(end: c(2026, 1, 4, 9)),
    );
    final result = project(
      span,
      DateTime.utc(2026, 1, 2),
      DateTime.utc(2026, 1, 3),
    ).single;
    expect(result.occurrence.startUtc, DateTime.utc(2026, 1, 1, 9));
    expect(result.occurrence.endUtc, DateTime.utc(2026, 1, 4, 9));
    expect(
      project(span, DateTime.utc(2026, 1, 4, 9), DateTime.utc(2026, 1, 5)),
      isEmpty,
    );
  });
  test(
    'named spans preserve calculation spillover at both UTC profile edges',
    () {
      final first = CalendarEventContent(
        timing: CalendarEventTiming(
          kind: CalendarEventTimeKind.zoned,
          zoneId: 'Etc/GMT-14',
          start: c(1970, 1, 1),
          duration: CalendarEventDuration(hours: 24),
        ),
      );
      final early = project(
        first,
        DateTime.utc(1970),
        DateTime.utc(1970, 1, 2),
      ).single;
      expect(early.occurrence.startUtc, DateTime.utc(1969, 12, 31, 10));
      expect(early.occurrence.originalStart.year, 1970);
      final last = CalendarEventContent(
        timing: CalendarEventTiming(
          kind: CalendarEventTimeKind.zoned,
          zoneId: 'Etc/GMT+12',
          start: c(2099, 12, 30, 23),
          duration: CalendarEventDuration(hours: 24),
        ),
      );
      final late = project(
        last,
        DateTime.utc(2099, 12, 31),
        DateTime.utc(2100),
      ).single;
      expect(late.occurrence.endUtc, DateTime.utc(2100, 1, 1, 11));
      expect(late.occurrence.originalStart.year, 2099);
    },
  );
  test('DATE near 1970 western-zone padding keeps civil values', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: c(1970, 1, 1),
      ),
    );
    final result = project(
      content,
      DateTime.utc(1970),
      DateTime.utc(1970, 1, 2),
      zone: 'America/New_York',
    ).single;
    expect(result.orderStart, DateTime.utc(1970, 1, 1, 5));
    expect(result.occurrence.start.year, 1970);
    expect(result.occurrence.endDate!.day, 2);
    expect(result.occurrence.startUtc, isNull);
    expect(result.occurrence.endUtc, isNull);
  });
  test('DATE terminal exclusive endpoint is retained near 2100', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: c(2099, 12, 31),
      ),
    );
    final result = project(
      content,
      DateTime.utc(2099, 12, 30),
      DateTime.utc(2100),
      zone: 'Pacific/Kiritimati',
    ).single;
    expect(result.occurrence.endDate!.year, 2100);
    expect(result.orderStart, DateTime.utc(2099, 12, 30, 10));
  });
  test('DATE uses midnight in calendar zone across DST', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: c(2026, 3, 29),
      ),
    );
    final result = project(
      content,
      DateTime.utc(2026, 3, 28),
      DateTime.utc(2026, 3, 31),
      zone: 'Europe/Stockholm',
    ).single;
    expect(result.orderStart, DateTime.utc(2026, 3, 28, 23));
    expect(result.occurrence.endDate, c(2026, 3, 30));
    expect(
      project(
        content,
        DateTime.utc(2026, 3, 29, 22),
        DateTime.utc(2026, 3, 30),
        zone: 'Europe/Stockholm',
      ),
      isEmpty,
    );
  });
  test('wholly skipped DATE has no matching instant geometry', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: c(2011, 12, 30),
      ),
    );
    expect(
      project(
        content,
        DateTime.utc(2011, 12, 29),
        DateTime.utc(2012, 1, 1),
        zone: 'Pacific/Apia',
      ),
      isEmpty,
    );
  });
  test(
    'cancelled moved-in original retains its explicit timing and content',
    () {
      final content = CalendarEventContent(
        summary: 'Series',
        timing: utc(1).copyWith(duration: CalendarEventDuration(hours: 1)),
        recurrence: CalendarEventRecurrence(
          rule: rule(CalendarEventFrequency.daily, count: 5),
          inclusions: [],
          exclusions: [],
        ),
      );
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: utc(1),
            replacement: utc(
              4,
              12,
            ).copyWith(duration: CalendarEventDuration(hours: 2)),
            cancelled: true,
            contentOverrides: CalendarEventOccurrenceContent(summary: ''),
          ),
        ],
        future: [],
      );
      final rows = project(
        content,
        DateTime.utc(2026, 1, 4, 12),
        DateTime.utc(2026, 1, 4, 15),
        edits: edits,
      );
      expect(rows, hasLength(1));
      expect(rows.single.cancelled, isTrue);
      expect(rows.single.occurrence.originalStart, c(2026, 1, 1, 9));
      expect(rows.single.occurrence.endUtc, DateTime.utc(2026, 1, 4, 14));
      expect(rows.single.occurrence.content!.summary, '');
      expect(edits.singles.single.cancelled, isTrue);
    },
  );
  test('follow-series cancellation follows a future shift without pinning', () {
    final content = CalendarEventContent(
      summary: 'Series',
      timing: utc(1),
      recurrence: CalendarEventRecurrence(
        rule: rule(CalendarEventFrequency.daily, count: 5),
        inclusions: [],
        exclusions: [],
      ),
    );
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: utc(3), cancelled: true),
      ],
      future: [
        CalendarEventFutureOverride(
          originalStart: utc(2),
          replacement: utc(4, 10),
        ),
      ],
    );
    final rows = project(
      content,
      DateTime.utc(2026, 1, 5),
      DateTime.utc(2026, 1, 6),
      edits: edits,
    );
    expect(rows.single.occurrence.originalStart, c(2026, 1, 3, 9));
    expect(rows.single.occurrence.startUtc, DateTime.utc(2026, 1, 5, 10));
    expect(rows.single.cancelled, isTrue);
    expect(edits.singles.single.replacement, isNull);
  });
  test('PERIOD lengths, earlier inclusions and exclusions retain meaning', () {
    final content = CalendarEventContent(
      timing: utc(3).copyWith(duration: CalendarEventDuration(hours: 1)),
      recurrence: CalendarEventRecurrence(
        rule: rule(CalendarEventFrequency.daily, count: 2),
        inclusions: [utc(1)],
        exclusions: [utc(4)],
      ),
      periods: [utc(2).copyWith(duration: CalendarEventDuration(hours: 3))],
    );
    final rows = project(
      content,
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 1, 5),
    );
    expect(rows.map((v) => v.occurrence.start.day), [1, 2, 3]);
    expect(rows[1].occurrence.endUtc, DateTime.utc(2026, 1, 2, 12));
  });
  test(
    'named recurrence skips generated gaps and keeps original local identity',
    () {
      final timing = CalendarEventTiming(
        kind: CalendarEventTimeKind.zoned,
        zoneId: 'Europe/Stockholm',
        start: c(2026, 3, 28, 2, 30),
      );
      final content = CalendarEventContent(
        timing: timing,
        recurrence: CalendarEventRecurrence(
          rule: rule(CalendarEventFrequency.daily, count: 2),
          inclusions: [],
          exclusions: [],
        ),
      );
      final rows = project(
        content,
        DateTime.utc(2026, 3, 27),
        DateTime.utc(2026, 3, 31),
      );
      expect(rows.map((v) => v.occurrence.originalStart.day), [28, 30]);
      expect(rows.last.occurrence.startUtc, DateTime.utc(2026, 3, 30, 0, 30));
    },
  );
  test('materialization ceiling counts cancelled and transparent matches', () {
    final content = CalendarEventContent(
      status: CalendarEventStatus.cancelled,
      transparency: CalendarEventTransparency.transparent,
      timing: utc(1),
      recurrence: CalendarEventRecurrence(
        rule: rule(CalendarEventFrequency.daily, count: 3),
        inclusions: [],
        exclusions: [],
      ),
    );
    expect(
      () => project(
        content,
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 5),
        work: EventOccurrenceQueryWork(maxWork: 100000, maxResults: 2),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('DATE work is charged across separate series and cannot replenish', () {
    final content = CalendarEventContent(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: c(2026, 1, 1),
      ),
      recurrence: CalendarEventRecurrence(
        rule: rule(CalendarEventFrequency.daily, count: 3),
        inclusions: [],
        exclusions: [],
      ),
    );
    final probe = EventOccurrenceQueryWork(maxWork: 100000, maxResults: 10000);
    project(
      content,
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 1, 5),
      work: probe,
    );
    final bounded = EventOccurrenceQueryWork(
      maxWork: probe.recurrence.used,
      maxResults: 10000,
    );
    project(
      content,
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 1, 5),
      work: bounded,
    );
    expect(
      () => project(
        content,
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 5),
        work: bounded,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
}
