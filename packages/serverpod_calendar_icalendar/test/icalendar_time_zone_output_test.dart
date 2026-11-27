import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

IcalendarAvailabilityCalendar readZone(IcalendarSyntaxComponent zone) =>
    validateIcalendarAvailabilityCalendar(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty('PRODID', '-//Synthetic//EN'),
          zone,
          IcalendarSyntaxComponent('VAVAILABILITY', [
            IcalendarSyntaxProperty('UID', 'example'),
            IcalendarSyntaxProperty('DTSTAMP', '20261022T000000Z'),
          ]),
        ]),
      ]),
    );
void main() {
  for (final zone in [
    'UTC',
    'US/Eastern',
    'Europe/Stockholm',
    'Europe/Dublin',
    'Australia/Lord_Howe',
    'Asia/Kathmandu',
    'Pacific/Apia',
    'Africa/Monrovia',
  ]) {
    test(
      'generated $zone matches pinned offset function for the full horizon',
      () {
        final generated = createIcalendarTimeZone(zone);
        final calendar = readZone(generated);
        final expected = NamedZoneResolver().calendarProfileSnapshot(
          zoneId: zone,
          maxTransitions: 8192,
        );
        expect(
          calendar.timeZones[zone]!.snapshot.matchesOffsets(expected),
          isTrue,
        );
        final bytes = serializeIcalendarAvailabilityCalendar(calendar);
        expect(
          serializeIcalendarAvailabilityCalendar(
            readZone(createIcalendarTimeZone(zone)),
          ),
          bytes,
        );
        expect(parseIcalendarAvailabilityCalendar(bytes).timeZones.keys, [
          zone,
        ]);
      },
    );
  }
  test(
    'onset bounds reject rather than truncate and DST labels come from IANA',
    () {
      expect(
        () => createIcalendarTimeZone('Europe/Stockholm', maxOnsets: 1),
        throwsA(isA<RecurrenceLimitException>()),
      );
      final zone = createIcalendarTimeZone('Europe/Stockholm');
      expect(
        zone.entries.whereType<IcalendarSyntaxComponent>().map((o) => o.name),
        containsAll(['STANDARD', 'DAYLIGHT']),
      );
    },
  );
}
