@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_values.dart';

final uid = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
CalendarEventTiming timing(int day, {int hour = 9, bool span = false}) =>
    CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 3, day: day, hour: hour),
      duration: span ? CalendarEventDuration(hours: 8) : null,
    );
CalendarAvailabilityContent content() => validateAvailabilityContent(
  CalendarAvailabilityContent(
    openings: [
      CalendarAvailabilityOpening(
        uid: uid,
        timing: timing(28, span: true),
        recurrence: CalendarEventRecurrence(
          rule: CalendarEventRule(
            frequency: CalendarEventFrequency.daily,
            count: 3,
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
    ],
  ),
);
CalendarAvailabilityOccurrenceChange change(
  CalendarEventOccurrenceAction action, {
  int day = 29,
  CalendarEventTiming? replacement,
}) => CalendarAvailabilityOccurrenceChange(
  availabilityId: uid,
  openingUid: uid,
  expectedRevision: 1,
  originalStart: timing(day),
  action: action,
  replacement: replacement,
);
void main() {
  final window = UtcWindow(
    start: DateTime.utc(2026, 3, 28),
    end: DateTime.utc(2026, 4, 1),
  );
  test('opening single timing skip and restore retain original identity and timing', () {
    final c = content();
    var edits = changeAvailabilityEdits(
      c,
      null,
      change(
        CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: timing(29, hour: 10, span: true),
      ),
    );
    edits = changeAvailabilityEdits(
      c,
      edits,
      change(CalendarEventOccurrenceAction.cancelSingle),
    );
    expect(
      evaluateAvailability(c, window, edits: edits).openings,
      hasLength(2),
    );
    edits = changeAvailabilityEdits(
      c,
      edits,
      change(CalendarEventOccurrenceAction.restoreSingle),
    );
    final periods = evaluateAvailability(c, window, edits: edits).openings;
    expect(periods[1].start, DateTime.utc(2026, 3, 29, 10));
    expect(edits!.single.overrides.singles.single.originalStart.start.hour, 9);
    expect(() => edits!.clear(), throwsUnsupportedError);
  });
  test('future timing changes and orphaning pattern edits use the shared bounded engine', () {
    final c = content();
    final edits = changeAvailabilityEdits(
      c,
      null,
      change(
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: timing(29, hour: 10, span: true),
      ),
    );
    expect(
      evaluateAvailability(
        c,
        window,
        edits: edits,
      ).openings.map((w) => w.start.hour),
      [9, 10, 10],
    );
    final incompatible = c.copyWith(
      openings: [
        c.openings.single.copyWith(
          recurrence: c.openings.single.recurrence!.copyWith(
            exclusions: [timing(29)],
          ),
        ),
      ],
    );
    expect(
      () => validateAvailabilityEdits(incompatible, edits),
      throwsArgumentError,
    );
  });
  test('opening edits reject points wrong profiles collisions and aggregate raw overflow', () {
    final c = content();
    expect(
      () => changeAvailabilityEdits(
        c,
        null,
        change(
          CalendarEventOccurrenceAction.replaceSingleTiming,
          replacement: timing(29),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => changeAvailabilityEdits(
        c,
        null,
        change(
          CalendarEventOccurrenceAction.replaceSingleTiming,
          day: 27,
          replacement: timing(27, span: true),
        ),
      ),
      throwsArgumentError,
    );
    final edits = changeAvailabilityEdits(
      c,
      null,
      change(CalendarEventOccurrenceAction.cancelSingle),
    );
    expect(
      () => changeAvailabilityEdits(
        c,
        edits,
        change(
          CalendarEventOccurrenceAction.replaceFutureTiming,
          replacement: timing(29, span: true),
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateAvailabilityEdits(c, [
        CalendarAvailabilityOpeningEdits(
          openingUid: uid,
          overrides: CalendarEventTimingOverrides(
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
      ]),
      throwsA(isA<AvailabilityLimitException>()),
    );
  });
  test('availability metadata validates exact categories preserves multiline comments and freezes collections', () {
    final c = validateAvailabilityContent(
      content().copyWith(
        description: '  Notes\n',
        location: 'Room',
        categories: ['Work', 'work', 'Work'],
        comments: ['one\ntwo', ''],
        url: 'https://example.invalid/info',
        classification: CalendarAvailabilityClass.private,
      ),
    );
    expect(c.categories, ['Work', 'work']);
    expect(c.comments, ['one\ntwo', '']);
    expect(c.description, '  Notes\n');
    expect(() => c.categories!.add('Other'), throwsUnsupportedError);
    expect(() => c.comments!.clear(), throwsUnsupportedError);
    expect(() => c.openings.single.categories!.clear(), throwsUnsupportedError);
  });
  test('metadata bounds and unsafe URL forms reject rather than truncate', () {
    final c = content();
    for (final v in [
      c.copyWith(categories: ['']),
      c.copyWith(categories: List.filled(65, 'x')),
      c.copyWith(comments: List.filled(33, 'x')),
      c.copyWith(url: 'https://user:password@example.invalid'),
      c.copyWith(url: 'file:///secret'),
      c.copyWith(description: 'x' * 16385),
      c.copyWith(comments: List.filled(17, 'x' * 4096)),
    ]) {
      expect(() => validateAvailabilityContent(v), throwsArgumentError);
    }
  });
}
