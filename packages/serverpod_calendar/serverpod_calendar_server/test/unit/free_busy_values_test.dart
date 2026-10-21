@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

CalendarEventContent input(CalendarEventTimeKind kind) => CalendarEventContent(
  timing: CalendarEventTiming(
    kind: kind,
    start: CalendarEventCivil(year: 2026, month: 3, day: 29),
    zoneId: kind == CalendarEventTimeKind.zoned ? 'Europe/Stockholm' : null,
  ),
);
void main() {
  final window = UtcWindow(
    start: DateTime.utc(2026, 3, 28),
    end: DateTime.utc(2026, 3, 31),
  );
  test(
    'DATE occupancy uses explicit calendar zone across DST and clips to query',
    () {
      final p = eventOccupiedWindows(
        input(CalendarEventTimeKind.date),
        null,
        window,
        dateZone: 'Europe/Stockholm',
      );
      expect(p.single.start, DateTime.utc(2026, 3, 28, 23));
      expect(p.single.end, DateTime.utc(2026, 3, 29, 22));
      expect(p.single.duration, const Duration(hours: 23));
    },
  );
  test('points transparent and cancelled events never produce positive booking intervals', () {
    final c = input(CalendarEventTimeKind.utc);
    for (final v in [
      c,
      c.copyWith(status: CalendarEventStatus.cancelled),
      input(CalendarEventTimeKind.date)
          .copyWith(transparency: CalendarEventTransparency.transparent),
    ]) {
      expect(
        eventOccupiedWindows(v, null, window, dateZone: 'Europe/Stockholm'),
        isEmpty,
      );
    }
  });
  test('single cancellation hides retained DATE timing until restoration', () {
    final c = input(CalendarEventTimeKind.date);
    final anchor = c.timing;
    final overrides = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: anchor,
          cancelled: true,
          replacement: anchor.copyWith(start: anchor.start.copyWith(day: 28)),
        ),
      ],
      future: [],
    );
    expect(
      eventOccupiedWindows(c, overrides, window, dateZone: 'Europe/Stockholm'),
      isEmpty,
    );
    final restored = overrides.copyWith(
      singles: [overrides.singles.single.copyWith(cancelled: false)],
    );
    final p = eventOccupiedWindows(
      c,
      restored,
      window,
      dateZone: 'Europe/Stockholm',
    );
    expect(p.single.start, window.start);
    expect(p.single.end, DateTime.utc(2026, 3, 28, 23));
  });
  test('timed explicit intervals retain exact geometry and clip without DATE inference', () {
    final c = input(CalendarEventTimeKind.utc).copyWith(
      timing: input(CalendarEventTimeKind.utc).timing
          .copyWith(duration: CalendarEventDuration(days: 3)),
    );
    final p = eventOccupiedWindows(
      c,
      null,
      window,
      dateZone: 'Europe/Stockholm',
    );
    expect(p.single.start, DateTime.utc(2026, 3, 29));
    expect(p.single.end, window.end);
  });
}
