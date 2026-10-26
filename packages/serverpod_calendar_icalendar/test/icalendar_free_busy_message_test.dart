import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

String component(List<String> values) =>
    ['BEGIN:VFREEBUSY', ...values, 'END:VFREEBUSY'].join('\r\n');
String envelope(String method, List<String> components) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic test//EN',
  'METHOD:$method',
  ...components,
  'END:VCALENDAR',
  '',
].join('\r\n');
List<String> fields(String method) => [
  'UID:busy-source',
  'DTSTAMP:20261026T070000Z',
  'DTSTART:20261026T080000Z',
  'DTEND:20261027T080000Z',
  'ORGANIZER:mailto:source@example.invalid',
  if (method != 'PUBLISH') 'ATTENDEE:mailto:target@example.invalid',
];
IcalendarFreeBusyMessage load(String value) =>
    parseIcalendarFreeBusyMessage(utf8.encode(value));
final componentError = throwsA(isA<IcalendarComponentException>());

void main() {
  test(
    'default component and recipient caps reject the entire source message',
    () {
      expect(
        () => load(
          envelope('PUBLISH', [
            for (var i = 0; i < 33; i++) component(fields('PUBLISH')),
          ]),
        ),
        componentError,
      );
      expect(
        () => load(
          envelope('REQUEST', [
            component([
              ...fields('REQUEST'),
              for (var i = 0; i < 64; i++)
                'ATTENDEE:mailto:target$i@example.invalid',
            ]),
          ]),
        ),
        componentError,
      );
    },
  );
  test(
    'period limits count list values across repeated properties and components',
    () {
      final source = envelope('PUBLISH', [
        component([
          ...fields('PUBLISH'),
          'FREEBUSY:20261026T100000Z/PT1H,20261026T110000Z/PT1H',
        ]),
        component([...fields('PUBLISH'), 'FREEBUSY:20261026T120000Z/PT1H']),
      ]);
      expect(
        () => parseIcalendarFreeBusyMessage(utf8.encode(source), maxPeriods: 2),
        componentError,
      );
      expect(
        parseIcalendarFreeBusyMessage(
          utf8.encode(source),
          maxPeriods: 3,
        ).components.length,
        2,
      );
    },
  );
  test('source type spelling stays intact while known interpretation is case insensitive', () {
    final source = envelope('PUBLISH', [
      component([
        ...fields('PUBLISH'),
        'FREEBUSY;FBTYPE=busy-unavailable:20261026T100000Z/PT1H',
      ]),
    ]);
    final value = load(source);
    expect(value.components.single.groups.single.type, 'busy-unavailable');
    expect(
      value.components.single.groups.single.effectiveType,
      'BUSY-UNAVAILABLE',
    );
    expect(utf8.decode(serializeIcalendarFreeBusyMessage(value)), source);
  });
  test(
    'window end overflow and source diagnostics do not expose private values',
    () {
      final source = envelope('PUBLISH', [
        component(
          fields('PUBLISH')
              .map((p) => p.startsWith('DTEND:') ? 'DTEND:21000101T000001Z' : p)
              .toList(),
        ),
      ]);
      try {
        load(source);
        fail('Out-of-range source accepted');
      } on IcalendarComponentException catch (e) {
        expect(e.toString(), isNot(contains('busy-source')));
        expect(e.toString(), isNot(contains('example.invalid')));
      }
    },
  );
  for (final method in ['PUBLISH', 'REQUEST', 'REPLY']) {
    test('$method preserves minimal source without claiming free coverage', () {
      final source = envelope(method, [component(fields(method))]);
      final value = load(source), busy = value.components.single;
      expect(value.method.name.toUpperCase(), method);
      expect(busy.uid, 'busy-source');
      expect(busy.organizer.address, 'mailto:source@example.invalid');
      expect(busy.attendees.length, method == 'PUBLISH' ? 0 : 1);
      expect(busy.groups, isEmpty);
      expect(busy.requestStatuses, isEmpty);
      expect(busy.window.start, DateTime.utc(2026, 10, 26, 8));
      expect(utf8.decode(serializeIcalendarFreeBusyMessage(value)), source);
      expect(() => value.components.clear(), throwsUnsupportedError);
      expect(() => busy.attendees.clear(), throwsUnsupportedError);
    });
    for (final required in [
      'UID',
      'DTSTAMP',
      'DTSTART',
      'DTEND',
      'ORGANIZER',
      if (method != 'PUBLISH') 'ATTENDEE',
    ]) {
      test('$method rejects omission of $required', () {
        expect(
          () => load(
            envelope(method, [
              component(
                fields(method)
                    .where((p) => !p.startsWith('$required:'))
                    .toList(),
              ),
            ]),
          ),
          componentError,
        );
      });
    }
  }
  for (final method in ['PUBLISH', 'REPLY']) {
    test(
      '$method retains period groups forms overlaps order and annotations',
      () {
        final source = envelope(method, [
          component([
            ...fields(method),
            'FREEBUSY;FBTYPE=BUSY-TENTATIVE:20261026T100000Z/PT2H,20261026T090000Z/20261026T110000Z',
            'FREEBUSY:20261026T100000Z/PT2H',
            'FREEBUSY;FBTYPE=BUSY:20261026T100000Z/PT2H',
            'FREEBUSY;FBTYPE=FREE:20261026T120000Z/PT1H',
            'FREEBUSY;FBTYPE=X-FUTURE:20261026T130000Z/PT1H',
            'COMMENT;LANGUAGE=en;ALTREP="https://example.invalid/comment":Source claim',
            'COMMENT:Second comment',
            'CONTACT:Source contact',
            'URL:https://example.invalid/busy',
            if (method == 'REPLY') 'REQUEST-STATUS;LANGUAGE=en:3.7;Denied;',
          ]),
        ]);
        final value = load(source), busy = value.components.single;
        expect(busy.groups.length, 5);
        expect(busy.groups.first.periods.length, 2);
        expect(busy.groups.first.periods.first.duration!.hours, 2);
        expect(busy.groups.first.periods[1].duration, isNull);
        expect(
          busy.groups.first.periods[1].end!.instant,
          DateTime.utc(2026, 10, 26, 11),
        );
        expect(busy.groups[1].type, isNull);
        expect(busy.groups[2].type, 'BUSY');
        expect(busy.groups.map((g) => g.effectiveType), [
          'BUSY-TENTATIVE',
          'BUSY',
          'BUSY',
          'FREE',
          'BUSY',
        ]);
        expect(busy.groups.last.type, 'X-FUTURE');
        expect(busy.metadata.comments.first.language, 'en');
        expect(
          busy.metadata.comments.first.alternativeUri,
          'https://example.invalid/comment',
        );
        expect(busy.metadata.contacts.single.value, 'Source contact');
        if (method == 'REPLY') {
          expect(busy.requestStatuses.single.code, '3.7');
          expect(busy.requestStatuses.single.extraData, '');
        }
        expect(() => busy.groups.clear(), throwsUnsupportedError);
        expect(() => busy.groups.first.periods.clear(), throwsUnsupportedError);
        final encoded = serializeIcalendarFreeBusyMessage(value);
        expect(
          serializeIcalendarFreeBusyMessage(load(utf8.decode(encoded))),
          encoded,
        );
      },
    );
  }
  test('PUBLISH keeps independent UIDs windows and unverified organizers', () {
    final value = load(
      envelope('PUBLISH', [
        component(fields('PUBLISH')),
        component(
          fields('PUBLISH')
              .map(
                (p) => p
                    .replaceAll('busy-source', 'other')
                    .replaceAll('20261026T080000Z', '20261025T080000Z'),
              )
              .toList(),
        ),
      ]),
    );
    expect(value.components.map((c) => c.uid), ['busy-source', 'other']);
    expect(value.components[1].window.start, DateTime.utc(2026, 10, 25, 8));
  });
  for (final method in ['REQUEST', 'REPLY']) {
    test('$method rejects multiple components', () {
      expect(
        () => load(
          envelope(method, [
            component(fields(method)),
            component(fields(method)),
          ]),
        ),
        componentError,
      );
    });
  }
  test('REQUEST may name multiple recipients but REPLY cannot', () {
    final values = [
      ...fields('REQUEST'),
      'ATTENDEE:mailto:other@example.invalid',
    ];
    expect(
      load(envelope('REQUEST', [component(values)]))
          .components
          .single
          .attendees
          .length,
      2,
    );
    expect(() => load(envelope('REPLY', [component(values)])), componentError);
  });
  for (final forbidden in [
    'FREEBUSY:20261026T100000Z/PT1H',
    'URL:https://example.invalid/',
    'REQUEST-STATUS:2.0;Success',
  ]) {
    test('REQUEST rejects $forbidden', () {
      expect(
        () => load(
          envelope('REQUEST', [
            component([...fields('REQUEST'), forbidden]),
          ]),
        ),
        componentError,
      );
    });
  }
  for (final forbidden in [
    'ATTENDEE:mailto:other@example.invalid',
    'REQUEST-STATUS:2.0;Success',
  ]) {
    test('PUBLISH rejects $forbidden', () {
      expect(
        () => load(
          envelope('PUBLISH', [
            component([...fields('PUBLISH'), forbidden]),
          ]),
        ),
        componentError,
      );
    });
  }
  for (final parameter in [
    'CN=Name',
    'PARTSTAT=ACCEPTED',
    'ROLE=CHAIR',
    'CUTYPE=ROOM',
    'RSVP=TRUE',
    'SENT-BY="mailto:actor@example.invalid"',
    'DELEGATED-TO="mailto:delegate@example.invalid"',
    'LANGUAGE=en',
  ]) {
    test('VFREEBUSY attendee rejects event parameter $parameter', () {
      final values = fields('REPLY')
          .map(
            (p) => p.startsWith('ATTENDEE:')
                ? p.replaceFirst('ATTENDEE:', 'ATTENDEE;$parameter:')
                : p,
          )
          .toList();
      expect(
        () => load(envelope('REPLY', [component(values)])),
        componentError,
      );
    });
  }
  test('organizer annotations are unverified source and never fetched', () {
    final values = fields('PUBLISH')
        .map(
          (p) => p.startsWith('ORGANIZER:')
              ? 'ORGANIZER;CN=Source;LANGUAGE=en;SENT-BY="mailto:actor@example.invalid":mailto:source@example.invalid'
              : p,
        )
        .toList();
    final organizer = load(envelope('PUBLISH', [component(values)]))
        .components
        .single
        .organizer;
    expect(organizer.commonName, 'Source');
    expect(organizer.sentBy, 'mailto:actor@example.invalid');
  });
  for (final period in [
    '20261026T100000/PT1H',
    '20261026/PT1H',
    '20261026T100000Z/20261026T100000Z',
    '20261026T100000Z/20261026T090000Z',
    '20261026T100000Z/20261026T110000',
    '20261026T100000Z/PT0S',
    '20261026T100000Z/-PT1H',
    '20261026T100000Z/PT0.5S',
    '19691231T235959Z/PT1S',
    '21000101T000000Z/PT1S',
    '20991231T235959Z/PT2S',
    '20261026T100000Z/PT1H/extra',
    '20261026T100000Z/PT1H,',
  ]) {
    test('rejects malformed unsupported or nonpositive period $period', () {
      expect(
        () => load(
          envelope('REPLY', [
            component([...fields('REPLY'), 'FREEBUSY:$period']),
          ]),
        ),
        componentError,
      );
    });
  }
  test(
    'exclusive 2100 endpoint works; ordinary start and stamp remain bounded',
    () {
      final values = fields('PUBLISH')
          .map((p) => p.startsWith('DTEND:') ? 'DTEND:21000101T000000Z' : p)
          .toList();
      final value = load(
        envelope('PUBLISH', [
          component([...values, 'FREEBUSY:20991231T235959Z/PT1S']),
        ]),
      );
      expect(
        value.components.single.groups.single.periods.single.endExclusive,
        DateTime.utc(2100),
      );
      for (final name in ['DTSTART', 'DTSTAMP']) {
        expect(
          () => load(
            envelope('PUBLISH', [
              component(
                values
                    .map(
                      (p) =>
                          p.startsWith('$name:') ? '$name:21000101T000000Z' : p,
                    )
                    .toList(),
              ),
            ]),
          ),
          componentError,
        );
      }
    },
  );
  test(
    'period outside advertised window remains a source claim without clipping',
    () {
      final busy = load(
        envelope('REPLY', [
          component([...fields('REPLY'), 'FREEBUSY:20261025T100000Z/P1D']),
        ]),
      ).components.single;
      expect(
        busy.groups.single.periods.single.start.instant,
        DateTime.utc(2026, 10, 25, 10),
      );
      expect(busy.window.start, DateTime.utc(2026, 10, 26, 8));
    },
  );
  for (final bad in [
    'DTSTART:20261026T080000',
    'DTEND:20261026T080000Z',
    'DTSTART;VALUE=DATE:20261026',
    'DTSTART;TZID=Europe/Stockholm:20261026T080000',
  ]) {
    test('rejects invalid window $bad', () {
      final name = bad.split(RegExp('[:;]')).first;
      expect(
        () => load(
          envelope('PUBLISH', [
            component(
              fields('PUBLISH')
                  .map((p) => p.startsWith('$name:') ? bad : p)
                  .toList(),
            ),
          ]),
        ),
        componentError,
      );
    });
  }
  for (final forbidden in [
    'SEQUENCE:0',
    'DURATION:PT1H',
    'RRULE:FREQ=DAILY',
    'SUMMARY:Hidden',
    'X-UNREGISTERED:Hidden',
    'CONTACT:one\r\nCONTACT:two',
    'FREEBUSY;VALUE=PERIOD:20261026T100000Z/PT1H',
    'FREEBUSY;FBTYPE=BUSY;FBTYPE=FREE:20261026T100000Z/PT1H',
    'FREEBUSY;FBTYPE=:20261026T100000Z/PT1H',
    'BEGIN:VALARM\r\nACTION:DISPLAY\r\nEND:VALARM',
  ]) {
    test(
      'unsupported or duplicated payload rejects atomically: $forbidden',
      () {
        expect(
          () => load(
            envelope('PUBLISH', [
              component([...fields('PUBLISH'), forbidden]),
            ]),
          ),
          componentError,
        );
      },
    );
  }
  test(
    'component period metadata work and output budgets apply to whole message',
    () {
      final source = envelope('PUBLISH', [
        for (var i = 0; i < 2; i++)
          component([...fields('PUBLISH'), 'FREEBUSY:20261026T100000Z/PT1H']),
      ]);
      final bytes = utf8.encode(source);
      expect(
        () => parseIcalendarFreeBusyMessage(bytes, maxComponents: 1),
        componentError,
      );
      expect(
        () => parseIcalendarFreeBusyMessage(bytes, maxPeriods: 1),
        componentError,
      );
      expect(
        () => parseIcalendarFreeBusyMessage(
          bytes,
          limits: const IcalendarComponentLimits(maxCandidates: 1),
        ),
        componentError,
      );
      expect(
        () => parseIcalendarFreeBusyMessage(
          bytes,
          limits: const IcalendarComponentLimits(maxCalendarExplicitDates: 1),
        ),
        componentError,
      );
      expect(
        () => parseIcalendarFreeBusyMessage(
          bytes,
          limits: const IcalendarComponentLimits(
            maxEventMetadataCodePoints: 60,
          ),
        ),
        componentError,
      );
      final value = load(source);
      expect(
        () => serializeIcalendarFreeBusyMessage(
          value,
          syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 50),
        ),
        throwsA(isA<IcalendarSyntaxException>()),
      );
      expect(
        () => validateIcalendarFreeBusyMessage(value.source, maxPeriods: 1),
        componentError,
      );
      expect(
        () => parseIcalendarFreeBusyMessage(bytes, maxPeriods: 0),
        throwsRangeError,
      );
    },
  );
  test('empty malformed mixed or unsupported envelopes reject; event adapter stays separate', () {
    for (final source in [
      envelope('PUBLISH', []),
      envelope('CANCEL', [component(fields('PUBLISH'))]),
      envelope('PUBLISH', ['BEGIN:VTIMEZONE\r\nEND:VTIMEZONE']),
      envelope('PUBLISH', [
        component(fields('PUBLISH')),
        'BEGIN:VEVENT\r\nEND:VEVENT',
      ]),
    ]) {
      expect(() => load(source), componentError);
    }
    final source = envelope('PUBLISH', [component(fields('PUBLISH'))]);
    expect(
      () => parseIcalendarSchedulingMessage(utf8.encode(source)),
      componentError,
    );
    expect(
      () => parseIcalendarEventCalendar(utf8.encode(source)),
      componentError,
    );
    expect(
      () => load(source.replaceAll('\r\n', '\n')),
      throwsA(isA<IcalendarSyntaxException>()),
    );
  });
}
