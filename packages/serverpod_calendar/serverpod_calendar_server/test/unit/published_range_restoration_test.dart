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
  test(
    'cancelled native candidate must preserve the complete finite series',
    () {
      final base = f.content();
      final content = base.copyWith(
        summary: 'Series',
        description: 'Details',
        location: 'Room',
        recurrence: CalendarEventRecurrence(
          rule: CalendarEventRule(
            frequency: CalendarEventFrequency.daily,
            untilDate: CalendarEventCivil(year: 2026, month: 3, day: 31),
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
      );
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(29),
            cancelled: true,
          ),
        ],
        future: [],
      );
      final result = eventSchedulingProvenCancelledAnchorStep(
        content,
        edits,
        [],
        f.timing(29),
        f.timing(30),
      );
      expect(result.$1.singles.single.cancelled, true);
      expect(result.$1.future.single.originalStart.start.day, 30);
      expect(
        () => eventSchedulingProvenCancelledAnchorStep(
          base,
          edits,
          [],
          f.timing(29),
          f.timing(30),
        ),
        throwsArgumentError,
      );
    },
  );
  test('native candidate requires a complete bounded equivalence proof', () {
    final base = f.content();
    final content = base.copyWith(
      summary: 'Series',
      description: 'Details',
      location: 'Room',
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
          frequency: CalendarEventFrequency.daily,
          untilDate: CalendarEventCivil(year: 2026, month: 3, day: 31),
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
    );
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: f.timing(29),
          replacement: f.timing(31, days: 2),
          contentOverrides: CalendarEventOccurrenceContent(summary: 'Moved'),
        ),
      ],
      future: [],
    );
    final result = eventSchedulingProvenExceptionalAnchorStep(
      content,
      edits,
      [],
      f.timing(29),
      f.timing(30),
    );
    expect(result.$1.future.length, 1);
    expect(
      () => eventSchedulingProvenExceptionalAnchorStep(
        base,
        edits,
        [],
        f.timing(29),
        f.timing(30),
      ),
      throwsArgumentError,
    );
  });
  for (final kind in [CalendarEventTimeKind.utc, CalendarEventTimeKind.zoned]) {
    test('$kind finite equivalence detects an altered occurrence', () {
      final base = f.content(kind: kind, hour: 9);
      final content = base.copyWith(
        recurrence: CalendarEventRecurrence(
          rule: CalendarEventRule(
            frequency: CalendarEventFrequency.daily,
            untilUtc: DateTime.utc(2026, 3, 31, 9),
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
      );
      final changed = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(30, kind: kind, hour: 9),
            replacement: f.timing(31, kind: kind, hour: 9),
          ),
        ],
        future: [],
      );
      expect(
        () => eventSchedulingProveFiniteTimedEquivalence(content, null, null),
        returnsNormally,
      );
      expect(
        () =>
            eventSchedulingProveFiniteTimedEquivalence(content, null, changed),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingProveFiniteTimedEquivalence(base, null, null),
        returnsNormally,
      );
    });
  }
  test('finite DATE equivalence checks every original and fails closed', () {
    final base = f.content();
    final content = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
          frequency: CalendarEventFrequency.daily,
          untilDate: CalendarEventCivil(year: 2026, month: 3, day: 31),
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
    );
    final changed = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: f.timing(31),
          replacement: f.timing(30),
        ),
      ],
      future: [],
    );
    expect(
      () => eventSchedulingProveFiniteDateEquivalence(content, null, null),
      returnsNormally,
    );
    expect(
      () => eventSchedulingProveFiniteDateEquivalence(content, null, changed),
      throwsArgumentError,
    );
    expect(
      () => eventSchedulingProveFiniteDateEquivalence(base, null, null),
      returnsNormally,
    );
    expect(
      () => eventSchedulingProveFiniteDateEquivalence(
        content,
        null,
        null,
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'cancelled successor and exhausted work reject without changing edits',
    () {
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(29),
            cancelled: true,
          ),
          CalendarEventSingleOverride(
            originalStart: f.timing(30),
            cancelled: true,
          ),
        ],
        future: [],
      );
      final original = jsonEncode(edits.toJson());
      expect(
        () => eventSchedulingCancelledAnchorStep(
          f.content(),
          edits,
          [],
          f.timing(29),
          f.timing(30),
        ),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingCancelledAnchorStep(
          f.content(),
          edits,
          [],
          f.timing(29),
          f.timing(30),
          sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(jsonEncode(edits.toJson()), original);
    },
  );
  for (final kind in [
    CalendarEventTimeKind.date,
    CalendarEventTimeKind.utc,
    CalendarEventTimeKind.zoned,
  ]) {
    test(
      '$kind exceptional anchor keeps its timing and does not shift successors',
      () {
        CalendarEventTiming point(int day, {int? days}) => f.timing(
          day,
          kind: kind,
          hour: kind == CalendarEventTimeKind.date ? 0 : 9,
          days: days,
        );
        final content = f.content(
          kind: kind,
          hour: kind == CalendarEventTimeKind.date ? 0 : 9,
        );
        final edits = CalendarEventTimingOverrides(
          singles: [
            CalendarEventSingleOverride(
              originalStart: point(29),
              replacement: point(31, days: 2),
            ),
          ],
          future: [],
        );
        final projected = eventSchedulingExceptionalAnchorStep(
          content,
          edits,
          [],
          point(29),
          point(30),
        );
        for (final day in [29, 30, 31]) {
          expect(
            visible(
              eventSchedulingOccurrence(content, projected.$1, point(day))!,
            ),
            visible(eventSchedulingOccurrence(content, edits, point(day))!),
          );
        }
        expect(
          () => eventSchedulingExceptionalAnchorStep(
            content,
            edits,
            [],
            point(29),
            point(31),
          ),
          throwsArgumentError,
        );
      },
    );
  }
  test(
    'exceptional projection preserves content and an existing later range',
    () {
      final content = f.content().copyWith(summary: 'Series');
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(
            originalStart: f.timing(29),
            replacement: f.timing(31, days: 2),
            contentOverrides: CalendarEventOccurrenceContent(summary: 'Moved'),
          ),
        ],
        future: [
          CalendarEventFutureOverride(
            originalStart: f.timing(30),
            replacement: f.timing(31, days: 2),
          ),
        ],
      );
      final result = eventSchedulingExceptionalAnchorStep(
        content,
        edits,
        [],
        f.timing(29),
        f.timing(30),
      );
      for (final day in [29, 30, 31]) {
        expect(
          visible(
            eventSchedulingOccurrence(content, result.$1, f.timing(day))!,
          ),
          visible(eventSchedulingOccurrence(content, edits, f.timing(day))!),
        );
      }
      expect(
        eventSchedulingOccurrence(content, result.$1, f.timing(29))!.summary,
        'Moved',
      );
      expect(
        eventSchedulingOccurrence(content, result.$1, f.timing(30))!.summary,
        'Series',
      );
    },
  );

  test('exceptional projection rejects a single at the next original', () {
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: f.timing(29),
          replacement: f.timing(31),
        ),
        CalendarEventSingleOverride(
          originalStart: f.timing(30),
          replacement: f.timing(28),
        ),
      ],
      future: [],
    );
    expect(
      () => eventSchedulingExceptionalAnchorStep(
        f.content(),
        edits,
        [],
        f.timing(29),
        f.timing(30),
      ),
      throwsArgumentError,
    );
  });

  test('exceptional projection finds a successor after an excluded date', () {
    final base = f.content();
    final content = base.copyWith(
      recurrence: base.recurrence!.copyWith(exclusions: [f.timing(30)]),
    );
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: f.timing(29),
          contentOverrides: CalendarEventOccurrenceContent(
            summary: 'Only this one',
          ),
        ),
      ],
      future: [],
    );
    final projected = eventSchedulingExceptionalAnchorStep(
      content,
      edits,
      [],
      f.timing(29),
      f.timing(31),
    );
    for (final day in [29, 31]) {
      expect(
        visible(
          eventSchedulingOccurrence(content, projected.$1, f.timing(day))!,
        ),
        visible(eventSchedulingOccurrence(content, edits, f.timing(day))!),
      );
    }
  });

  test('a provably final exception needs no synthetic range anchor', () {
    final base = f.content();
    final content = base.copyWith(
      recurrence: CalendarEventRecurrence(
        rule: CalendarEventRule(
          frequency: CalendarEventFrequency.daily,
          untilDate: CalendarEventCivil(year: 2026, month: 3, day: 29),
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
    );
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: f.timing(29),
          replacement: f.timing(30),
        ),
      ],
      future: [],
    );
    final projected = eventSchedulingExceptionalAnchorStep(
      content,
      edits,
      [],
      f.timing(29),
      null,
    );
    expect(projected.$1.future, isEmpty);
    expect(
      visible(eventSchedulingOccurrence(content, projected.$1, f.timing(29))!),
      visible(eventSchedulingOccurrence(content, edits, f.timing(29))!),
    );
    expect(
      () => eventSchedulingExceptionalAnchorStep(
        f.content(),
        edits,
        [],
        f.timing(29),
        null,
      ),
      throwsArgumentError,
    );
  });

  test(
    'cancelled anchor remains cancelled while later occurrences are restored',
    () {
      final content = f.content();
      final originalCancellation = CalendarEventSingleOverride(
        originalStart: f.timing(29),
        replacement: f.timing(28, days: 2),
        cancelled: true,
        contentOverrides: CalendarEventOccurrenceContent(summary: 'Retained'),
      );
      final otherCancellation = CalendarEventSingleOverride(
        originalStart: f.timing(31),
        cancelled: true,
      );
      final edits = CalendarEventTimingOverrides(
        singles: [originalCancellation, otherCancellation],
        future: [],
      );
      final result = eventSchedulingCancelledAnchorStep(
        content,
        edits,
        [EventSchedulingOriginal(f.timing(29), false)],
        f.timing(29),
        f.timing(30),
      );
      expect(
        result.$1.singles.map((s) => s.toJson()).toList(),
        edits.singles.map((s) => s.toJson()).toList(),
      );
      expect(
        result.$2.any(
          (s) => s.key == EventSchedulingOriginal(f.timing(29), false).key,
        ),
        isTrue,
      );
      expect(
        visible(eventSchedulingOccurrence(content, result.$1, f.timing(30))!),
        visible(eventSchedulingOccurrence(content, edits, f.timing(30))!),
      );
      expect(
        () => eventSchedulingOccurrence(content, result.$1, f.timing(29)),
        throwsArgumentError,
      );
      expect(
        () => eventSchedulingOccurrence(content, result.$1, f.timing(31)),
        throwsArgumentError,
      );
    },
  );
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
