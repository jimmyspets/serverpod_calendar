@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';

final id = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
CalendarEventTiming t(
  int offset,
  CalendarEventTimeKind kind, {
  bool span = false,
}) {
  final d = DateTime.utc(2026, 3, 28).add(Duration(days: offset));
  return CalendarEventTiming(
    kind: kind,
    zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
    start: CalendarEventCivil(
      year: d.year,
      month: d.month,
      day: d.day,
      hour: kind == CalendarEventTimeKind.date ? 0 : 9,
    ),
    duration: span
        ? (kind == CalendarEventTimeKind.date
              ? CalendarEventDuration(days: 1)
              : CalendarEventDuration(hours: 1))
        : null,
  );
}

CalendarEventContent content(CalendarEventTimeKind kind) =>
    CalendarEventContent(
      summary: 'Retained series',
      timing: t(0, kind, span: true),
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
    );
CalendarEventTimingOverrides? act(
  CalendarEventContent c,
  CalendarEventTimingOverrides? v,
  CalendarEventOccurrenceAction action,
  int offset, {
  CalendarEventTiming? replacement,
}) => changeEventOverrides(
  c,
  v,
  CalendarEventOccurrenceChange(
    eventId: id,
    expectedRevision: 1,
    originalStart: t(offset, c.timing.kind),
    action: action,
    replacement: replacement,
  ),
);
final window = UtcWindow(
  start: DateTime.utc(2026, 3, 20),
  end: DateTime.utc(2026, 4, 10),
);
List<EventOccurrenceWindowProjection> rows(
  CalendarEventContent c,
  CalendarEventTimingOverrides? v, {
  bool cancelled = false,
}) => eventOccurrenceWindow(
  c,
  v,
  window,
  dateZone: 'Europe/Stockholm',
  groups: {CalendarEventFieldGroup.timing},
  work: EventOccurrenceQueryWork(maxWork: 200000, maxResults: 100),
  includeCancelled: cancelled,
);

void main() {
  test('floating and non-recurring future cancellation reject explicitly', () {
    final c = content(CalendarEventTimeKind.utc);
    expect(
      () => act(
        content(CalendarEventTimeKind.floating),
        null,
        CalendarEventOccurrenceAction.cancelFuture,
        1,
      ),
      throwsArgumentError,
    );
    expect(
      () => act(
        c.copyWith(recurrence: null),
        null,
        CalendarEventOccurrenceAction.cancelFuture,
        0,
      ),
      throwsArgumentError,
    );
    final excluded = c.copyWith(
      recurrence: c.recurrence!.copyWith(
        exclusions: [t(1, CalendarEventTimeKind.utc)],
      ),
    );
    expect(
      () => act(excluded, null, CalendarEventOccurrenceAction.cancelFuture, 1),
      throwsArgumentError,
    );
  });
  test('a co-located cutoff consumes its own bounded override slot', () {
    final kind = CalendarEventTimeKind.utc;
    final c = content(kind).copyWith(
      recurrence: content(kind).recurrence!
          .copyWith(rule: content(kind).recurrence!.rule!.copyWith(count: 130)),
    );
    final singles = [
      for (var i = 0; i < 127; i++)
        CalendarEventSingleOverride(originalStart: t(i, kind), cancelled: true),
    ];
    final value = validateEventOverrides(
      c,
      CalendarEventTimingOverrides(
        singles: singles,
        future: [],
        cancelledFrom: t(0, kind),
      ),
    )!;
    expect(value.singles.length, 127);
    expect(
      () => validateEventOverrides(
        c,
        value.copyWith(
          singles: [
            ...singles,
            CalendarEventSingleOverride(
              originalStart: t(127, kind),
              cancelled: true,
            ),
          ],
        ),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'legacy nullable JSON remains mask-free; REQUEST cannot erase cutoff',
    () {
      final old = CalendarEventTimingOverrides.fromJson({
        'singles': <dynamic>[],
        'future': <dynamic>[],
      });
      expect(old.cancelledFrom, isNull);
      expect(old.toJson().containsKey('cancelledFrom'), isFalse);
      final c = content(CalendarEventTimeKind.utc);
      final value = act(c, null, CalendarEventOccurrenceAction.cancelFuture, 1);
      expect(
        () => eventSchedulingProjection(c, value, []),
        throwsArgumentError,
      );
    },
  );
  for (final kind in [
    CalendarEventTimeKind.date,
    CalendarEventTimeKind.utc,
    CalendarEventTimeKind.zoned,
  ]) {
    group('${kind.name} native future cancellation', () {
      test(
        'all later originals suppressed; explicit restoration retains singles',
        () {
          final c = content(kind);
          final prior = validateEventOverrides(
            c,
            CalendarEventTimingOverrides(
              singles: [
                CalendarEventSingleOverride(
                  originalStart: t(2, kind),
                  replacement: t(-2, kind, span: true),
                  cancelled: false,
                  contentOverrides: CalendarEventOccurrenceContent(
                    summary: 'Own text',
                  ),
                ),
                CalendarEventSingleOverride(
                  originalStart: t(3, kind),
                  cancelled: true,
                ),
              ],
              future: [
                CalendarEventFutureOverride(
                  originalStart: t(1, kind),
                  replacement: t(3, kind, span: true),
                ),
              ],
            ),
          );
          final masked = act(
            c,
            prior,
            CalendarEventOccurrenceAction.cancelFuture,
            1,
          )!;
          expect(rows(c, masked).map((v) => v.occurrence.originalStart.day), [
            28,
          ]);
          final now = DateTime.utc(2026);
          final oldState = eventProtocolBaseline(c, prior, now, now);
          final newState = advanceEventProtocol(
            oldState,
            c,
            prior,
            c,
            masked,
            now,
          );
          expect(
            newState.overrides.map((s) => s.toJson()),
            oldState.overrides.map((s) => s.toJson()),
          );
          expect(
            rows(c, masked, cancelled: true).where((v) => v.cancelled).length,
            4,
          );
          expect(
            masked.singles.map((v) => v.toJson()),
            prior!.singles.map((v) => v.toJson()),
          );
          expect(
            masked.future.map((v) => v.toJson()),
            prior.future.map((v) => v.toJson()),
          );
          final restored = act(
            c,
            masked,
            CalendarEventOccurrenceAction.restoreFuture,
            1,
          )!;
          expect(restored.toJson(), prior.toJson());
          expect(rows(c, restored).where((v) => !v.cancelled).length, 4);
          expect(restored.singles.last.cancelled, isTrue);
          expect(
            rows(c, restored, cancelled: true).where((v) => v.cancelled).length,
            1,
          );
          expect(
            eventOccupiedWindows(
              c,
              masked,
              window,
              dateZone: 'Europe/Stockholm',
            ).length,
            1,
          );
          expect(
            eventOccupiedWindows(
              c,
              restored,
              window,
              dateZone: 'Europe/Stockholm',
            ).length,
            4,
          );
        },
      );
      test('earliest cutoff wins; restore must name exact saved original', () {
        final c = content(kind);
        final a = act(c, null, CalendarEventOccurrenceAction.cancelFuture, 2)!;
        final b = act(c, a, CalendarEventOccurrenceAction.cancelFuture, 4)!;
        expect(b.toJson(), a.toJson());
        expect(
          () => act(c, b, CalendarEventOccurrenceAction.cancelFuture, 8),
          throwsArgumentError,
        );
        expect(
          () => act(c, b, CalendarEventOccurrenceAction.restoreFuture, 4),
          throwsArgumentError,
        );
        final earlier = act(
          c,
          b,
          CalendarEventOccurrenceAction.cancelFuture,
          1,
        )!;
        expect(earlier.cancelledFrom!.start.day, 29);
        expect(
          act(c, earlier, CalendarEventOccurrenceAction.restoreFuture, 1),
          isNull,
        );
        expect(
          () => act(c, null, CalendarEventOccurrenceAction.restoreFuture, 1),
          throwsArgumentError,
        );
      });
      test(
        'timing/content edits preserve cutoff and source/version boundaries',
        () {
          final c = content(kind);
          var v = act(c, null, CalendarEventOccurrenceAction.cancelFuture, 1)!;
          v = act(
            c,
            v,
            CalendarEventOccurrenceAction.replaceSingleTiming,
            2,
            replacement: t(-2, kind, span: true),
          )!;
          v = changeEventContentOverrides(
            c,
            v,
            CalendarEventOccurrenceContentRequest(
              eventId: id,
              expectedRevision: 1,
              originalStart: t(2, kind),
              changes: [
                CalendarEventOccurrenceContentChange(
                  field: CalendarEventContentField.summary,
                  action: CalendarEventContentAction.setValue,
                  text: 'Retained override',
                ),
              ],
            ),
          )!;
          expect(v.cancelledFrom!.start.day, 29);
          expect(
            v.singles.single.contentOverrides!.summary,
            'Retained override',
          );
          expect(rows(c, v).length, 1);
          expect(
            eventDisclosedOverrides(v, {
              CalendarEventFieldGroup.timing,
            })!.cancelledFrom,
            v.cancelledFrom,
          );
          expect(() => v.singles.clear(), throwsUnsupportedError);
          expect(
            () => validateEventOverrides(
              c.copyWith(
                recurrence: c.recurrence!.copyWith(exclusions: [t(1, kind)]),
              ),
              v,
            ),
            throwsArgumentError,
          );
          expect(
            () => act(
              c,
              v,
              CalendarEventOccurrenceAction.cancelFuture,
              0,
              replacement: t(1, kind, span: true),
            ),
            throwsArgumentError,
          );
        },
      );
      test(
        'relative reminders suppressed; absolute item reminder unchanged',
        () {
          final c = content(kind),
              v = act(
                content(kind),
                null,
                CalendarEventOccurrenceAction.cancelFuture,
                1,
              );
          final relative = AlarmTiming.relative(
            offset: CalendarDuration(minutes: 10, sign: -1),
            anchor: AlarmAnchor.start,
            dateZoneId: kind == CalendarEventTimeKind.date
                ? 'Europe/Stockholm'
                : null,
          );
          expect(eventAlarmCandidates(c, v, relative, window).length, 1);
          final absolute = AlarmTiming.absolute(utc: DateTime.utc(2026, 3, 28));
          expect(
            eventAlarmCandidates(c, v, absolute, window).single.originalKey,
            'item',
          );
          expect(
            eventAlarmCandidates(
              c,
              act(c, v, CalendarEventOccurrenceAction.restoreFuture, 1),
              relative,
              window,
            ).length,
            5,
          );
        },
      );
      test('protocol master advances only for actual cutoff changes', () {
        final c = content(kind), now = DateTime.utc(2026, 1, 1);
        final original = eventProtocolBaseline(c, null, now, now);
        final masked = act(
          c,
          null,
          CalendarEventOccurrenceAction.cancelFuture,
          1,
        );
        final version = advanceEventProtocol(original, c, null, c, masked, now);
        expect(version.version.sequence, 1);
        final unchanged = act(
          c,
          masked,
          CalendarEventOccurrenceAction.cancelFuture,
          4,
        );
        expect(
          advanceEventProtocol(version, c, masked, c, unchanged, now).toJson(),
          version.toJson(),
        );
        final restored = advanceEventProtocol(
          version,
          c,
          masked,
          c,
          act(c, masked, CalendarEventOccurrenceAction.restoreFuture, 1),
          now,
        );
        expect(restored.version.sequence, 2);
        expect(
          () => EventComponentWriter().components(
            'test@example.invalid',
            c,
            masked,
            version,
          ),
          throwsArgumentError,
        );
        expect(
          EventComponentWriter().components(
            'test@example.invalid',
            c,
            null,
            restored,
          ),
          isNotEmpty,
        );
        final baseline = eventImportBaseline(
          'test@example.invalid',
          c,
          null,
          original,
        );
        validateEventImportBaseline(baseline, 'test@example.invalid');
        expect(
          eventImportBaseline(
            'test@example.invalid',
            c,
            masked,
            version,
          ).canonicalValue,
          isNot(baseline.canonicalValue),
        );
        expect(
          () => validateEventImportBaseline(
            eventImportBaseline('test@example.invalid', c, masked, version),
            'test@example.invalid',
          ),
          throwsStateError,
        );
      });
    });
  }
}
