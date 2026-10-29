import 'package:calendar_example_flutter/invitation_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

void main() {
  test('DATE summary stays date-only and identifies its exclusive end', () {
    final text = invitationTimingLabel(
      cal.CalendarEventTiming(
        kind: cal.CalendarEventTimeKind.date,
        start: cal.CalendarEventCivil(year: 2030, month: 1, day: 1),
        end: cal.CalendarEventCivil(year: 2030, month: 1, day: 3),
      ),
    );
    expect(text, contains('[DATE]'));
    expect(text, contains('DTEND (exclusive): 2030-01-03'));
    expect(text, isNot(contains('00:00')));
    expect(text, isNot(contains('UTC')));
  });
  test(
    'timed summaries preserve civil clock zone duration units and omitted end',
    () {
      final start = cal.CalendarEventCivil(
        year: 2030,
        month: 3,
        day: 31,
        hour: 2,
        minute: 30,
      );
      final text = invitationTimingLabel(
        cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.zoned,
          zoneId: 'Europe/Stockholm',
          start: start,
          duration: cal.CalendarEventDuration(days: 1),
        ),
      );
      expect(text, contains('02:30:00 [Europe/Stockholm]'));
      expect(text, contains('0w 1d 0h 0m 0s'));
      final utc = invitationTimingLabel(
        cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: start,
        ),
      );
      expect(utc, contains('02:30:00 [UTC]'));
      expect(utc, contains('DTEND/DURATION omitted'));
    },
  );
}
