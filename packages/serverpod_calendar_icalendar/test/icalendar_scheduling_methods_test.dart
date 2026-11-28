import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show explicitZone;
import 'support/scheduling_fixtures.dart';

void main() {
  for (final method in ['ADD', 'REFRESH', 'COUNTER', 'DECLINECOUNTER']) {
    test(
      '$method minimal source round trips without invoking a transition',
      () {
        final source = message(method, minimal(method)), value = load(source);
        expect(
          value.method,
          {
            'ADD': IcalendarSchedulingMethod.add,
            'REFRESH': IcalendarSchedulingMethod.refresh,
            'COUNTER': IcalendarSchedulingMethod.counter,
            'DECLINECOUNTER': IcalendarSchedulingMethod.declineCounter,
          }[method],
        );
        final event = value.events.single;
        expect(
          event.startTime == null,
          method == 'REFRESH' || method == 'DECLINECOUNTER',
        );
        expect(
          event.summary?.value,
          method == 'ADD' || method == 'COUNTER' ? '' : null,
        );
        expect(event.status, isNull);
        expect(
          event.sequence,
          method == 'ADD'
              ? 1
              : method == 'DECLINECOUNTER'
              ? 2
              : null,
        );
        expect(event.originalStart, isNull);
        expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
      },
    );
    for (final required in [
      'UID',
      'DTSTAMP',
      'ORGANIZER',
      if (method == 'ADD' || method == 'COUNTER') ...['DTSTART', 'SUMMARY'],
      if (method == 'REFRESH' || method == 'DECLINECOUNTER') 'ATTENDEE',
      if (method == 'ADD' || method == 'DECLINECOUNTER') 'SEQUENCE',
    ]) {
      test('$method rejects missing $required', () {
        expect(
          () => load(
            message(
              method,
              minimal(method)
                  .where(
                    (p) =>
                        !p.startsWith('$required:') &&
                        !p.startsWith('$required;'),
                  )
                  .toList(),
            ),
          ),
          rejects(),
        );
      });
    }
  }
  test(
    'ADD sequence must be positive and source timing is an addition claim',
    () {
      for (final raw in ['0', '-1', '2147483648']) {
        expect(
          () => load(
            message(
              'ADD',
              minimal('ADD')
                  .map((p) => p == 'SEQUENCE:1' ? 'SEQUENCE:$raw' : p)
                  .toList(),
            ),
          ),
          rejects(),
        );
      }
      final source = message(
        'ADD',
        minimal('ADD')
            .map((p) => p == 'SEQUENCE:1' ? 'SEQUENCE:+0001' : p)
            .toList(),
      );
      final value = load(source), event = value.events.single;
      expect(event.sequence, 1);
      expect(event.recurrence, isNull);
      expect(event.originalStart, isNull);
      expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
      for (final property in [
        'RECURRENCE-ID:20261023T120000Z',
        'RRULE:FREQ=DAILY',
        'RDATE:20261023T120000Z',
        'EXDATE:20261023T120000Z',
      ]) {
        expect(
          () => load(message('ADD', [...minimal('ADD'), property])),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
      for (final raw in ['TENTATIVE', 'CONFIRMED']) {
        expect(
          load(message('ADD', [...minimal('ADD'), 'STATUS:$raw']))
              .events
              .single
              .status,
          isNotNull,
        );
      }
      expect(
        () => load(message('ADD', [...minimal('ADD'), 'STATUS:CANCELLED'])),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('ADD supports DATE and named-zone duration timing without recurrence metadata', () {
    final date =
        minimal('ADD')
            .map((p) => p == start ? 'DTSTART;VALUE=DATE:20261023' : p)
            .toList()
          ..add('DURATION:P2D');
    expect(load(message('ADD', date)).events.single.dateSpan!.dayCount, 2);
    final zoned =
        minimal('ADD')
            .map(
              (p) => p == start
                  ? 'DTSTART;TZID=Europe/Stockholm:20261023T120000'
                  : p,
            )
            .toList()
          ..add('DURATION:PT2H');
    final source = message(
      'ADD',
      zoned,
      zones: [explicitZone('Europe/Stockholm')],
    );
    final value = load(source);
    expect(value.events.single.startTime!.zoneId, 'Europe/Stockholm');
    expect(value.events.single.duration!.hours, 2);
    expect(
      load(utf8.decode(serializeIcalendarSchedulingMessage(value)))
          .events
          .single
          .startTime,
      value.events.single.startTime,
    );
  });
  test('REFRESH whitelist rejects metadata, timing, recurrence and zero SEQUENCE too', () {
    for (final property in [
      'ATTACH:https://example.invalid/file',
      'CATEGORIES:Room',
      'CLASS:PRIVATE',
      'CONTACT:Person',
      'CREATED:20261022T100000Z',
      'DESCRIPTION:Text',
      'DTEND:20261022T130000Z',
      start,
      'DURATION:PT1H',
      'EXDATE:20261023T120000Z',
      'GEO:1;2',
      'LAST-MODIFIED:20261022T100000Z',
      'LOCATION:Room',
      'PRIORITY:0',
      'RDATE:20261023T120000Z',
      'RELATED-TO:source',
      'REQUEST-STATUS:2.0;Success',
      'RESOURCES:Room',
      'RRULE:FREQ=DAILY',
      'SEQUENCE:0',
      'STATUS:CONFIRMED',
      'SUMMARY:',
      'TRANSP:OPAQUE',
      'URL:https://example.invalid/event',
    ]) {
      expect(
        () => load(message('REFRESH', [...minimal('REFRESH'), property])),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => load(message('REFRESH', [...minimal('REFRESH'), attendee])),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('REFRESH retains comments and detached identity without content or version defaults', () {
    final source = message('REFRESH', [
      ...minimal('REFRESH'),
      'RECURRENCE-ID:20261023T120000Z',
      'COMMENT;LANGUAGE=en:Please refresh',
      'COMMENT:Second',
    ]);
    final value = load(source), event = value.events.single;
    expect(event.originalTime!.instant, DateTime.utc(2026, 10, 23, 12));
    expect(event.metadata.comments.map((v) => v.value), [
      'Please refresh',
      'Second',
    ]);
    expect(event.sequence, isNull);
    expect(event.summary, isNull);
    expect(event.startTime, isNull);
    expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
  });
  test('COUNTER source omission is distinct from explicit zero and unverified echo', () {
    final absent = load(message('COUNTER', minimal('COUNTER')));
    expect(absent.events.single.sequence, isNull);
    for (final seq in [0, 3]) {
      final source = message('COUNTER', [
        ...minimal('COUNTER'),
        'SEQUENCE:$seq',
      ]);
      final value = load(source);
      expect(value.events.single.sequence, seq);
      expect(utf8.decode(serializeIcalendarSchedulingMessage(value)), source);
    }
    expect(absent.events.single.participants.attendees, isEmpty);
    // Proposed participant addresses and status are not a trusted sender/action.
    final proposal = load(
      message('COUNTER', [
        ...minimal('COUNTER'),
        'STATUS:CANCELLED',
        attendee,
        'ATTENDEE:mailto:proposed@example.invalid',
        'REQUEST-STATUS:3.1;Reported result',
        'PRIORITY:2',
        'GEO:1;2',
        'RESOURCES:Room',
      ]),
    );
    expect(proposal.events.single.status, IcalendarEventStatus.cancelled);
    expect(proposal.events.single.participants.attendees, hasLength(2));
    expect(proposal.events.single.requestStatuses.single.code, '3.1');
  });
  test('COUNTER preserves a recurring proposal or a detached instance, not both patterns', () {
    final recurring = message('COUNTER', [
      ...minimal('COUNTER'),
      'RRULE:FREQ=DAILY;COUNT=3',
      'RDATE:20261026T120000Z',
    ]);
    expect(load(recurring).events.single.recurrence!.timedSet!.rule!.count, 3);
    final detached = message(
      'COUNTER',
      instance('COUNTER', '20261023T120000Z'),
    );
    expect(load(detached).events.single.isOverride, isTrue);
    expect(load(detached).events.single.sequence, isNull);
    expect(
      () => load(
        message('COUNTER', [
          ...instance('COUNTER', '20261023T120000Z'),
          'RRULE:FREQ=DAILY',
        ]),
      ),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
  });
  test('DECLINECOUNTER retains recipients, optional timing and reported result claims', () {
    final fields = [
      ...minimal('DECLINECOUNTER'),
      'ATTENDEE:mailto:another@example.invalid',
      'COMMENT:Not accepted',
      'REQUEST-STATUS;LANGUAGE=en:2.0;Reported outcome',
    ];
    final value = load(message('DECLINECOUNTER', fields)),
        event = value.events.single;
    expect(event.participants.attendees, hasLength(2));
    expect(event.sequence, 2);
    expect(event.startTime, isNull);
    expect(event.requestStatuses.single.language, 'en');
    for (final status in ['TENTATIVE', 'CONFIRMED']) {
      expect(
        load(message('DECLINECOUNTER', [...fields, 'STATUS:$status']))
            .events
            .single
            .status,
        isNotNull,
      );
    }
    expect(
      () => load(message('DECLINECOUNTER', [...fields, 'STATUS:CANCELLED'])),
      rejects(IcalendarComponentError.invalidValue),
    );
    final source = multiple('DECLINECOUNTER', [
      minimal('DECLINECOUNTER'),
      instance('DECLINECOUNTER', '20261023T120000Z'),
    ]);
    expect(load(source).events, hasLength(2));
    expect(
      utf8.decode(serializeIcalendarSchedulingMessage(load(source))),
      source,
    );
  });
  test(
    'method-specific component cardinality and generic budgets remain enforced',
    () {
      for (final method in ['ADD', 'REFRESH', 'COUNTER']) {
        expect(
          () => load(multiple(method, [minimal(method), minimal(method)])),
          rejects(IcalendarComponentError.unsupportedComponent),
        );
      }
      final rows = [
        minimal('DECLINECOUNTER'),
        instance('DECLINECOUNTER', '20261023T120000Z'),
      ];
      expect(
        () => load(
          multiple('DECLINECOUNTER', rows),
          limits: const IcalendarComponentLimits(maxEvents: 1),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          message('COUNTER', [
            ...minimal('COUNTER'),
            ...List.filled(33, 'REQUEST-STATUS:2.0;Reported'),
          ]),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
      expect(
        () => load(
          message('REFRESH', [...minimal('REFRESH'), 'COMMENT:${'x' * 200}']),
          limits: const IcalendarComponentLimits(
            maxEventMetadataCodePoints: 128,
          ),
        ),
        rejects(IcalendarComponentError.limitExceeded),
      );
    },
  );
  test('all new methods retain strict syntax/parameters and ordinary-import separation', () {
    for (final method in ['ADD', 'REFRESH', 'COUNTER', 'DECLINECOUNTER']) {
      final source = message(method, minimal(method));
      expect(
        () => parseIcalendarEventCalendar(utf8.encode(source)),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      expect(
        () => load(
          message(method, [...minimal(method), 'X-SCHEDULING:unsupported']),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
      expect(
        () => load(
          message(
            method,
            minimal(method)
                .map(
                  (p) => p == organizer
                      ? 'ORGANIZER;X-TRUSTED=yes:mailto:organizer@example.invalid'
                      : p,
                )
                .toList(),
          ),
        ),
        rejects(IcalendarComponentError.unsupportedParameter),
      );
    }
  });
}
