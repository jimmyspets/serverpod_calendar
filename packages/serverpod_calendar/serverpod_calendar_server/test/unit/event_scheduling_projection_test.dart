@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show RecurrenceLimitException;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

import 'event_overrides_test.dart' as f;

void main() {
  test('retained-slot union cannot evict an old original at capacity', () {
    final content = f.content().copyWith(
      recurrence: f.content().recurrence!.copyWith(
        rule: f.content().recurrence!.rule!.copyWith(count: 70),
      ),
    );
    CalendarEventTiming point(int days) {
      final v = DateTime.utc(2026, 3, 28).add(Duration(days: days));
      return CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: CalendarEventCivil(year: v.year, month: v.month, day: v.day),
      );
    }

    expect(
      () => eventSchedulingProjection(
        content,
        CalendarEventTimingOverrides(
          singles: [
            CalendarEventSingleOverride(
              originalStart: point(64),
              replacement: point(64),
            ),
          ],
          future: [],
        ),
        List.generate(64, (i) => EventSchedulingOriginal(point(i), false)),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('current annotations follow effective values and cleared own annotations do not return', () {
    final content = f.content().copyWith(
      summary: 'Series',
      description: 'Description',
      textParameters: CalendarEventTextParameters(
        summary: CalendarTextParameters(language: 'de'),
        description: CalendarTextParameters(language: 'sv'),
      ),
    );
    final result = eventSchedulingProjection(
      content,
      CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(29),
            replacement: f.timing(29),
            contentOverrides: CalendarEventOccurrenceContent(summary: ''),
          ),
        ],
        future: [],
      ),
      [EventSchedulingOriginal(f.timing(29), false)],
    ).$1!.singles.single.contentOverrides!;
    expect(result.summary, '');
    expect(result.textParameters!.summary, isNull);
    expect(result.description, 'Description');
    expect(result.textParameters!.description!.language, 'sv');
  });
  test('explicit date end can reach only the approved exclusive boundary', () {
    final content = f.content().copyWith(
      timing: CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: CalendarEventCivil(year: 2099, month: 12, day: 30),
        end: CalendarEventCivil(year: 2099, month: 12, day: 31),
      ),
    );
    final result = eventSchedulingProjection(content, null, [
      EventSchedulingOriginal(
        CalendarEventTiming(
          kind: CalendarEventTimeKind.date,
          start: CalendarEventCivil(year: 2099, month: 12, day: 31),
        ),
        false,
      ),
    ]).$1!.singles.single.replacement!;
    expect(result.end!.year, 2100);
    expect(result.end!.day, 1);
    expect(result.duration, isNull);
  });
  for (final kind in [
    CalendarEventTimeKind.date,
    CalendarEventTimeKind.utc,
    CalendarEventTimeKind.zoned,
  ]) {
    test(
      '${kind.name} retained reset projects current values without canonical edits',
      () {
        final hour = kind == CalendarEventTimeKind.date ? 0 : 9;
        final content = f
            .content(kind: kind, hour: hour)
            .copyWith(summary: 'Current');
        final original = f.timing(29, kind: kind, hour: hour);
        final before = jsonEncode(content.toJson());
        final projected = eventSchedulingProjection(content, null, [
          EventSchedulingOriginal(original, false),
        ]).$1!.singles.single;
        expect(projected.originalStart.toJson(), original.toJson());
        expect(projected.replacement!.start.day, 29);
        expect(projected.replacement!.duration!.days, 1);
        expect(projected.contentOverrides!.summary, 'Current');
        expect(projected.contentOverrides!.description, '');
        expect(projected.contentOverrides!.location, '');
        expect(jsonEncode(content.toJson()), before);
      },
    );
  }
  test('cleared future anchor follows the surviving earlier original-relative shift', () {
    final content = f.content();
    final current = CalendarEventTimingOverrides(
      singles: [],
      future: [
        CalendarEventFutureOverride(
          originalStart: f.timing(29),
          replacement: f.timing(30, days: 2),
        ),
      ],
    );
    final before = jsonEncode(current.toJson());
    final result = eventSchedulingProjection(content, current, [
      EventSchedulingOriginal(f.timing(30), true),
    ]).$1!;
    expect(result.future.last.originalStart.start.day, 30);
    expect(result.future.last.replacement.start.day, 31);
    expect(result.future.last.replacement.duration!.days, 2);
    expect(jsonEncode(current.toJson()), before);
  });
  test(
    'single replacement and own content take precedence over an earlier range',
    () {
      final result = eventSchedulingProjection(
        f.content().copyWith(summary: 'Series'),
        CalendarEventTimingOverrides(
          singles: [
            CalendarEventSingleOverride(
              originalStart: f.timing(30),
              replacement: f.timing(31, days: 3),
              contentOverrides: CalendarEventOccurrenceContent(summary: 'Own'),
            ),
          ],
          future: [
            CalendarEventFutureOverride(
              originalStart: f.timing(29),
              replacement: f.timing(30, days: 2),
            ),
          ],
        ),
        [EventSchedulingOriginal(f.timing(30), false)],
      ).$1!.singles.single;
      expect(result.replacement!.duration!.days, 3);
      expect(result.contentOverrides!.summary, 'Own');
    },
  );
  test(
    'original membership, kind and raw slot caps reject rather than retarget',
    () {
      expect(
        () => eventSchedulingProjection(f.content(), null, [
          EventSchedulingOriginal(f.timing(27), false),
        ]),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingProjection(
          f.content(),
          null,
          List.generate(
            65,
            (_) => EventSchedulingOriginal(f.timing(29), false),
          ),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(
        () => eventSchedulingProjection(
          f.content(),
          CalendarEventTimingOverrides(
            singles: [],
            future: [
              CalendarEventFutureOverride(
                originalStart: f.timing(29),
                replacement: f.timing(30),
              ),
            ],
          ),
          [EventSchedulingOriginal(f.timing(29), false)],
        ),
        throwsArgumentError,
      );
    },
  );
  test('explicit timed end retains elapsed length and rejects a later-fold wall encoding', () {
    final utc = f
        .content(kind: CalendarEventTimeKind.utc, hour: 9)
        .copyWith(
          timing: f
              .timing(28, kind: CalendarEventTimeKind.utc, hour: 9)
              .copyWith(
                end: CalendarEventCivil(
                  year: 2026,
                  month: 3,
                  day: 28,
                  hour: 11,
                ),
              ),
        );
    final projected = eventSchedulingProjection(utc, null, [
      EventSchedulingOriginal(
        f.timing(29, kind: CalendarEventTimeKind.utc, hour: 9),
        false,
      ),
    ]).$1!.singles.single.replacement!;
    expect(projected.duration, isNull);
    expect(projected.end!.day, 29);
    expect(projected.end!.hour, 11);
    final fold = f
        .content(kind: CalendarEventTimeKind.zoned, hour: 1)
        .copyWith(
          timing: CalendarEventTiming(
            kind: CalendarEventTimeKind.zoned,
            zoneId: 'Europe/Stockholm',
            start: CalendarEventCivil(
              year: 2026,
              month: 10,
              day: 24,
              hour: 1,
              minute: 30,
            ),
            end: CalendarEventCivil(
              year: 2026,
              month: 10,
              day: 24,
              hour: 3,
              minute: 30,
            ),
          ),
        );
    expect(
      () => eventSchedulingProjection(fold, null, [
        EventSchedulingOriginal(
          CalendarEventTiming(
            kind: CalendarEventTimeKind.zoned,
            zoneId: 'Europe/Stockholm',
            start: CalendarEventCivil(
              year: 2026,
              month: 10,
              day: 25,
              hour: 1,
              minute: 30,
            ),
          ),
          false,
        ),
      ]),
      throwsArgumentError,
    );
  });
}
