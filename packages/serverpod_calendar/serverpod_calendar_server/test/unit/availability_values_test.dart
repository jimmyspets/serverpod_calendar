@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_values.dart';

CalendarEventTiming timing({
  int day = 28,
  int hour = 9,
  int? endHour,
  CalendarEventTimeKind kind = CalendarEventTimeKind.zoned,
}) => CalendarEventTiming(
  kind: kind,
  zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
  start: CalendarEventCivil(year: 2026, month: 3, day: day, hour: hour),
  end: endHour == null
      ? null
      : CalendarEventCivil(year: 2026, month: 3, day: day, hour: endHour),
);
CalendarEventRule daily() => CalendarEventRule(
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
);
void main() {
  test('explicit named-zone recurring hours cross DST without calendar-zone inference', () {
    final c = validateAvailabilityContent(
      CalendarAvailabilityContent(
        openings: [
          CalendarAvailabilityOpening(
            timing: timing(endHour: 17),
            recurrence: CalendarEventRecurrence(
              rule: daily(),
              inclusions: [],
              exclusions: [],
            ),
          ),
        ],
      ),
    );
    final p = evaluateAvailability(
      c,
      UtcWindow(
        start: DateTime.utc(2026, 3, 28),
        end: DateTime.utc(2026, 3, 31),
      ),
    ).openings;
    expect(p.map((o) => o.start.hour), [8, 7, 7]);
    expect(p.map((o) => o.end.hour), [16, 15, 15]);
  });
  test(
    'recurrence exclusions and earlier inclusions survive canonicalization',
    () {
      final c = validateAvailabilityContent(
        CalendarAvailabilityContent(
          openings: [
            CalendarAvailabilityOpening(
              timing: timing(endHour: 17),
              recurrence: CalendarEventRecurrence(
                rule: daily(),
                inclusions: [timing(day: 27)],
                exclusions: [timing(day: 29)],
              ),
            ),
          ],
        ),
      );
      final p = evaluateAvailability(
        c,
        UtcWindow(
          start: DateTime.utc(2026, 3, 27),
          end: DateTime.utc(2026, 3, 31),
        ),
      ).openings;
      expect(p.map((o) => o.start.day), [27, 28, 30]);
      expect(() => c.openings.clear(), throwsUnsupportedError);
      expect(
        () => c.openings.single.recurrence!.exclusions.clear(),
        throwsUnsupportedError,
      );
    },
  );
  test('optional and exclusive bounds clip openings without making closures missing rules', () {
    final c = validateAvailabilityContent(
      CalendarAvailabilityContent(
        validUntil: timing(day: 28, hour: 12),
        openings: [
          CalendarAvailabilityOpening(timing: timing(endHour: 17)),
        ],
      ),
    );
    final p = evaluateAvailability(
      c,
      UtcWindow(
        start: DateTime.utc(2026, 3, 28),
        end: DateTime.utc(2026, 3, 29),
      ),
    );
    expect(p.start, isNull);
    expect(p.end, DateTime.utc(2026, 3, 28, 11));
    expect(p.openings.single.end, p.end);
    final exclusive = CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2100, month: 1, day: 1),
    );
    expect(availabilityBound(exclusive, end: true), DateTime.utc(2100));
    expect(() => availabilityBound(exclusive), throwsArgumentError);
  });
  test('reject DATE floating fractions point openings invalid priorities and free BUSYTYPE', () {
    for (final c in [
      CalendarAvailabilityContent(
        openings: [CalendarAvailabilityOpening(timing: timing())],
      ),
      CalendarAvailabilityContent(priority: 10, openings: []),
      CalendarAvailabilityContent(
        closedKind: CalendarFreeBusyKind.free,
        openings: [],
      ),
      for (final kind in [
        CalendarEventTimeKind.date,
        CalendarEventTimeKind.floating,
      ])
        CalendarAvailabilityContent(
          openings: [
            CalendarAvailabilityOpening(
              timing: timing(kind: kind, endHour: 17),
            ),
          ],
        ),
      CalendarAvailabilityContent(
        openings: [
          CalendarAvailabilityOpening(
            timing: timing(endHour: 17)
                .copyWith(start: timing().start.copyWith(microsecond: 1)),
          ),
        ],
      ),
    ]) {
      expect(() => validateAvailabilityContent(c), throwsArgumentError);
    }
    expect(
      () => validateAvailabilityContent(
        CalendarAvailabilityContent(
          openings: List.generate(
            17,
            (_) => CalendarAvailabilityOpening(timing: timing(endHour: 17)),
          ),
        ),
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
  });
}
