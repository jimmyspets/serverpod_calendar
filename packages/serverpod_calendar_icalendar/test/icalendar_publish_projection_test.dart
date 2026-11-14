import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'icalendar_scheduling_projection_test.dart' as f;
import 'support/scheduling_fixtures.dart';
import 'support/icalendar_fixtures.dart' show fixedZone;

List<String> master({String? summary = 'SUMMARY:Series'}) =>
    f.master(summary: summary).where((p) => !p.startsWith('ATTENDEE')).toList();

void main() {
  test(
    'PUBLISH projects annotated fields without mutating source or versions',
    () {
      final value = f.source([
        master(
          summary: 'SUMMARY;LANGUAGE=sv;ALTREP="https://example.invalid/text":Möte\\, här',
        ),
        f.override(),
      ]);
      final before = serializeIcalendarSyntax(value.source);
      final result = projectIcalendarPublishFields(value),
          own = result.events.last;
      expect(result.method, IcalendarSchedulingMethod.publish);
      expect(own.summary!.value, 'Möte, här');
      expect(own.summary!.language, 'sv');
      expect(own.summary!.alternativeUri, 'https://example.invalid/text');
      expect(
        own.participants.organizer!.address,
        'mailto:organizer@example.invalid',
      );
      expect(
        result.events.every((e) => e.participants.attendees.isEmpty),
        isTrue,
      );
      expect(own.sequence, 7);
      expect(own.stamp, DateTime.utc(2026, 10, 23, 11));
      expect(serializeIcalendarSyntax(value.source), before);
      expect(value.series.single.overrides.single.summary, isNull);
    },
  );
  test(
    'PUBLISH preserves explicit empty summary and original future identity',
    () {
      final result = projectIcalendarPublishFields(
        f.source([
          master(),
          f.override(future: true, extra: ['SUMMARY:']),
        ]),
      );
      expect(result.events.last.summary!.value, '');
      expect(result.events.last.isThisAndFuture, isTrue);
      expect(
        result.events.last.originalTime!.instant,
        DateTime.utc(2026, 10, 23, 12),
      );
      expect(
        result.events.last.startTime!.instant,
        DateTime.utc(2026, 10, 23, 13),
      );
    },
  );
  test('PUBLISH projects absent master summary as empty', () {
    final result = projectIcalendarPublishFields(
      f.source([master(summary: null), f.override()]),
    );
    expect(result.events.every((e) => e.summary!.value.isEmpty), isTrue);
  });
  test('PUBLISH never strips master or occurrence attendees', () {
    for (final events in [
      [f.master(), f.override()],
      [
        master(),
        f.override(extra: [attendee]),
      ],
    ]) {
      expect(
        () => projectIcalendarPublishFields(f.source(events)),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
  });
  test('PUBLISH never invents organizer authority', () {
    expect(
      () => projectIcalendarPublishFields(
        f.source([master().where((p) => !p.startsWith('ORGANIZER')).toList()]),
      ),
      rejects(IcalendarComponentError.missing),
    );
  });
  test('PUBLISH retains PERIOD and exclusion source forms', () {
    final result = projectIcalendarPublishFields(
      f.source([
        [
          ...master(),
          'RDATE;VALUE=PERIOD:20261025T120000Z/PT2H',
          'EXDATE:20261024T120000Z',
        ],
        f.override(),
      ]),
    );
    final bytes = serializeIcalendarSchedulingMessage(result),
        text = utf8.decode(bytes);
    expect(text, contains('RDATE;VALUE=PERIOD:20261025T120000Z/PT2H'));
    expect(text, contains('EXDATE:'));
    expect(
      serializeIcalendarSchedulingMessage(
        parseIcalendarSchedulingMessage(bytes),
      ),
      bytes,
    );
  });
  test('PUBLISH does not remove unsupported source alarms', () {
    expect(
      () => projectIcalendarPublishFields(
        f.source([
          [
            ...master(),
            'BEGIN:VALARM',
            'ACTION:DISPLAY',
            'DESCRIPTION:Reminder',
            'TRIGGER:-PT5M',
            'END:VALARM',
          ],
        ]),
      ),
      rejects(),
    );
  });
  test('pure PUBLISH retains legal cancellation data without executing it', () {
    final result = projectIcalendarPublishFields(
      f.source([
        master(),
        f.override(extra: ['STATUS:CANCELLED']),
      ]),
    );
    expect(result.events.last.status, IcalendarEventStatus.cancelled);
  });
  test('PUBLISH preserves DATE and exact named-zone meaning', () {
    for (final date in [true, false]) {
      final fields = master()
          .map(
            (p) => p == start
                ? date
                      ? 'DTSTART;VALUE=DATE:20261022'
                      : 'DTSTART;TZID=UTC:20261022T120000'
                : p,
          )
          .toList();
      final result = projectIcalendarPublishFields(
        f.source([fields], zones: date ? [] : [fixedZone()]),
      );
      expect(result.events.single.startDate != null, date);
      expect(result.timeZones.keys, date ? isEmpty : ['UTC']);
    }
  });
  test('PUBLISH projection charges its shared budget', () {
    final value = f.source([master(), f.override()]),
        budget = RecurrenceWorkBudget(maxWork: 200000);
    projectIcalendarPublishFields(value, sharedWorkBudget: budget);
    expect(budget.used, greaterThan(0));
    expect(
      () => projectIcalendarPublishFields(
        value,
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test('PUBLISH cannot mix separate source series', () {
    expect(
      () => projectIcalendarPublishFields(
        f.source([
          master(),
          master()
              .map((p) => p == uid ? 'UID:other@example.invalid' : p)
              .toList(),
        ]),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
}
