@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

import 'event_overrides_test.dart' as f;

Map<String, dynamic> visible(CalendarEventContent value) {
  final result = value.toJson();
  for (final key in ['summary', 'description', 'location']) {
    if (result[key] == '') result.remove(key);
  }
  return result;
}

void main() {
  for (final kind in [
    CalendarEventTimeKind.date,
    CalendarEventTimeKind.utc,
    CalendarEventTimeKind.zoned,
  ]) {
    for (final hour in kind == CalendarEventTimeKind.date ? [0] : [2, 9]) {
      test(
        '$kind $hour restoration preserves suffix, moved singles and later ranges',
        () {
          CalendarEventTiming point(int day) =>
              f.timing(day, kind: kind, hour: hour);
          final content = f.content(kind: kind, hour: hour);
          final edits = CalendarEventTimingOverrides(
            singles: [
              CalendarEventSingleOverride(
                originalStart: point(30),
                replacement: point(28),
              ),
            ],
            future: [
              CalendarEventFutureOverride(
                originalStart: point(31),
                replacement: point(30),
              ),
            ],
          );
          final before = jsonEncode(edits.toJson());
          final projected = eventSchedulingRangeRestoration(
            content,
            edits,
            [],
            point(kind == CalendarEventTimeKind.zoned && hour == 2 ? 28 : 29),
          );
          for (final day in [28, 29, 30, 31]) {
            if (!eventSchedulingMember(content, point(day))) continue;
            expect(
              visible(
                eventSchedulingOccurrence(
                  content,
                  projected.$1,
                  point(day),
                )!,
              ),
              visible(eventSchedulingOccurrence(content, edits, point(day))!),
            );
          }
          expect(jsonEncode(edits.toJson()), before);
          expect(projected.$2.single.isThisAndFuture, true);
          expect(edits.future.length, 1);
        },
      );
    }
    test('$kind PERIOD additions retain their special lengths', () {
      CalendarEventTiming point(int day) => f.timing(day, kind: kind);
      final content = f
          .content(kind: kind)
          .copyWith(
            periods: [
              point(31).copyWith(duration: CalendarEventDuration(days: 2)),
            ],
          );
      final projected = eventSchedulingRangeRestoration(
        content,
        null,
        [],
        point(29),
      );
      expect(projected.$2.length, 2);
      expect(
        eventSchedulingOccurrence(
          content,
          projected.$1,
          point(31),
        )!.timing.toJson(),
        eventSchedulingOccurrence(content, null, point(31))!.timing.toJson(),
      );
      expect(
        () => eventSchedulingRangeRestoration(content, null, [], point(31)),
        throwsArgumentError,
      );
    });
  }
  test('single, cancelled and retained single anchors reject', () {
    final content = f.content();
    for (final cancelled in [false, true]) {
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(29),
            cancelled: cancelled,
            replacement: cancelled ? null : f.timing(30),
          ),
        ],
        future: [],
      );
      expect(
        () => eventSchedulingRangeRestoration(content, edits, [], f.timing(29)),
        throwsArgumentError,
      );
    }
    expect(
      () => eventSchedulingRangeRestoration(content, null, [
        EventSchedulingOriginal(f.timing(29), false),
      ], f.timing(29)),
      throwsArgumentError,
    );
  });
  test('existing future anchor is reused, not shifted twice', () {
    final edits = CalendarEventTimingOverrides(
      singles: [],
      future: [
        CalendarEventFutureOverride(
          originalStart: f.timing(29),
          replacement: f.timing(30, days: 2),
        ),
      ],
    );
    final projected = eventSchedulingRangeRestoration(
      f.content(),
      edits,
      [],
      f.timing(29),
    );
    expect(projected.$1.future.length, 1);
    for (final day in [29, 30, 31]) {
      expect(
        visible(
          eventSchedulingOccurrence(
            f.content(),
            projected.$1,
            f.timing(day),
          )!,
        ),
        eventSchedulingOccurrence(f.content(), edits, f.timing(day))!.toJson(),
      );
    }
  });
  test(
    'excluded, wrong profile, non-point and exhausted membership reject',
    () {
      final content = f.content();
      expect(
        () => eventSchedulingRangeRestoration(
          content.copyWith(
            recurrence: content.recurrence!.copyWith(
              exclusions: [f.timing(29)],
            ),
          ),
          null,
          [],
          f.timing(29),
        ),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingRangeRestoration(
          content,
          null,
          [],
          f.timing(29, kind: CalendarEventTimeKind.utc),
        ),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingRangeRestoration(
          content,
          null,
          [],
          f.timing(29, days: 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingRangeRestoration(
          content,
          null,
          [],
          f.timing(31),
          sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
}
