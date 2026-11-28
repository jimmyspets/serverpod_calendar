import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'support/scheduling_fixtures.dart';

void main() {
  for (final identity in [
    null,
    'RECURRENCE-ID:20300102T090000Z',
    'RECURRENCE-ID;VALUE=DATE:20300102',
  ]) {
    test('duration-only CANCEL retains no manufactured span: $identity', () {
      final source = message('CANCEL', [
        ...minimal('CANCEL'),
        ?identity,
        identity?.contains('VALUE=DATE') ?? false
            ? 'DURATION:P1D'
            : 'DURATION:PT5M',
      ]);
      final parsed = load(source), event = parsed.events.single;
      expect(event.startDate, isNull);
      expect(event.startTime, isNull);
      expect(event.dateSpan, isNull);
      expect(event.timedSpan, isNull);
      expect(event.duration, isNotNull);
      expect(utf8.decode(serializeIcalendarSchedulingMessage(parsed)), source);
    });
  }
  for (final method in ['PUBLISH', 'REQUEST', 'ADD', 'COUNTER', 'REPLY']) {
    test('$method does not gain a start-less duration profile', () {
      expect(
        () => load(
          message(method, [
            ...minimal(method).where((v) => !v.startsWith('DTSTART:')),
            'DURATION:PT1H',
          ]),
        ),
        rejects(),
      );
    });
  }
  test(
    'aggregate calendar work remains consumed across validations/failures',
    () {
      final source = parseIcalendarSyntax(
        utf8.encode(
          [
            'BEGIN:VCALENDAR',
            'VERSION:2.0',
            'PRODID:-//Synthetic//EN',
            'BEGIN:VEVENT',
            'UID:budget',
            'DTSTAMP:20260101T000000Z',
            'DTSTART:20300101T090000Z',
            'RRULE:FREQ=DAILY;COUNT=3',
            'END:VEVENT',
            'END:VCALENDAR',
            '',
          ].join('\r\n'),
        ),
      );
      final work = RecurrenceWorkBudget(maxWork: 100);
      validateIcalendarEventCalendar(source, sharedWorkBudget: work);
      final first = work.used;
      expect(first, greaterThan(0));
      validateIcalendarEventCalendar(source, sharedWorkBudget: work);
      expect(work.used, greaterThan(first));
      while (work.remaining > 0) {
        work.charge();
      }
      expect(
        () => validateIcalendarEventCalendar(source, sharedWorkBudget: work),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(work.used, 100);
      expect(
        () => validateIcalendarEventCalendar(
          source,
          limits: const IcalendarComponentLimits(maxCandidates: 1),
          sharedWorkBudget: RecurrenceWorkBudget(maxWork: 2),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
}
