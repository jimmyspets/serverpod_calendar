import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart';

Matcher rejects(IcalendarComponentError kind) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);

void main() {
  test('UTC event maps to a point with absent metadata still absent', () {
    final value = load(file()).events.single;
    expect(value.uid, 'synthetic@example.invalid');
    expect(value.stamp, DateTime.utc(2026, 10, 22, 10));
    expect(value.timedSpan!.isPoint, isTrue);
    expect(value.dateSpan, isNull);
    expect(value.summary, isNull);
    expect(value.status, isNull);
    expect(value.transparency, isNull);
    expect(value.isTransparent, isFalse);
  });
  test(
    'DATE defaults to one day and preserves exclusive end versus duration',
    () {
      for (final extra in [
        <String>[],
        ['DTEND;VALUE=DATE:20261024'],
        ['DURATION:P2D'],
        ['DURATION:P1W'],
      ]) {
        final span = load(
          file(
            events: [
              event(timing: 'DTSTART;VALUE=DATE:20261022', extra: extra),
            ],
          ),
        ).events.single.dateSpan!;
        expect(span.start, CalendarDate(year: 2026, month: 10, day: 22));
        expect(
          span.dayCount,
          extra.isEmpty
              ? 1
              : extra.single == 'DURATION:P1W'
              ? 7
              : 2,
        );
        expect(
          span.end != null,
          extra.isNotEmpty && extra.single.startsWith('DTEND'),
        );
        expect(
          span.duration != null,
          extra.isNotEmpty && extra.single.startsWith('DURATION'),
        );
      }
    },
  );
  test(
    'text annotations, empty summary and protocol metadata are retained',
    () {
      final source = file(
        envelope: ['CALSCALE:gregorian'],
        events: [
          event(
            extra: [
              'SUMMARY;LANGUAGE=sv;ALTREP="https://example.invalid/title":',
              r'DESCRIPTION:Line one\nLine two\, three',
              r'LOCATION:Room\; 2',
              'STATUS:tentative',
              'TRANSP:transparent',
              'CREATED:20261021T100000Z',
              'LAST-MODIFIED:20261022T090000Z',
              'SEQUENCE:+0002',
            ],
          ),
        ],
      );
      final value = load(source);
      final e = value.events.single;
      expect(e.summary!.value, '');
      expect(e.summary!.language, 'sv');
      expect(e.summary!.alternativeUri, 'https://example.invalid/title');
      expect(e.description!.value, 'Line one\nLine two, three');
      expect(e.location!.value, 'Room; 2');
      expect(e.status, IcalendarEventStatus.tentative);
      expect(e.isTransparent, isTrue);
      expect(e.created, DateTime.utc(2026, 10, 21, 10));
      expect(e.sequence, 2);
      final again = parseIcalendarEventCalendar(
        serializeIcalendarEventCalendar(value),
      );
      expect(again.events.single.description!.value, e.description!.value);
      expect(
        utf8.decode(serializeIcalendarEventCalendar(again)),
        utf8.decode(serializeIcalendarEventCalendar(value)),
      );
    },
  );
  test('source syntax and result collections are immutable', () {
    final source = parseIcalendarSyntax(
      utf8.encode(file(zones: [fixedZone()])),
    );
    final value = validateIcalendarEventCalendar(source);
    expect(() => value.events.clear(), throwsUnsupportedError);
    expect(() => value.timeZones.clear(), throwsUnsupportedError);
    expect(() => value.source.components.clear(), throwsUnsupportedError);
    expect(
      () => value.events.single.source.entries.clear(),
      throwsUnsupportedError,
    );
  });
  test('mandatory envelope and event properties reject when absent', () {
    final source = file();
    for (final line in [
      'VERSION:2.0',
      'PRODID:-//Synthetic calendar tests//EN',
      'UID:synthetic@example.invalid',
      'DTSTAMP:20261022T100000Z',
      'DTSTART:20261022T120000Z',
    ]) {
      expect(
        () => load(source.replaceFirst('$line\r\n', '')),
        rejects(IcalendarComponentError.missing),
        reason: line,
      );
    }
    expect(
      () => load(file(events: [])),
      rejects(IcalendarComponentError.missing),
    );
  });
  test(
    'duplicate singular properties and parameters reject case-insensitively',
    () {
      expect(
        () => load(file(envelope: ['version:2.0'])),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['summary:A', 'SUMMARY:B']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          file(
            events: [event(timing: 'DTSTART;VALUE=DATE;value=DATE:20261022')],
          ),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['SUMMARY;LANGUAGE=en,sv:A']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('unsupported properties never disappear from a semantic import', () {
    for (final line in [
      'CONFERENCE:https://example.invalid/unprofiled',
      'X-PRIVATE:Unregistered',
      'COLOR:red',
    ]) {
      expect(
        () => load(
          file(
            events: [
              event(extra: [line]),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
        reason: line,
      );
    }
    for (final line in ['METHOD:PUBLISH', 'NAME:Calendar', 'X-PRIVATE:test']) {
      expect(
        () => load(file(envelope: [line])),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
    expect(
      () => load(
        file(
          events: [
            event(extra: ['SUMMARY;X-PRIVATE=one:Title']),
          ],
        ),
      ),
      rejects(IcalendarComponentError.unsupportedParameter),
    );
  });
  test('unknown roots, mixed components and alarms fail the whole source', () {
    expect(
      () => load(
        file()
            .replaceFirst('BEGIN:VCALENDAR', 'BEGIN:OTHER')
            .replaceFirst('END:VCALENDAR', 'END:OTHER'),
      ),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
    expect(
      () => load(file(events: [event(), 'BEGIN:VTODO\r\nEND:VTODO'])),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
    expect(
      () => load(
        file(
          events: [
            event(extra: ['BEGIN:VALARM', 'ACTION:DISPLAY', 'END:VALARM']),
          ],
        ),
      ),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
    expect(
      () => load(file() + file()),
      rejects(IcalendarComponentError.unsupportedComponent),
    );
  });
  test('late invalid event exposes no partial results', () {
    expect(
      () => load(
        file(
          events: [
            event(),
            event(uid: 'second', extra: ['UNSUPPORTED:private-value']),
          ],
        ),
      ),
      rejects(IcalendarComponentError.unsupportedProperty),
    );
    expect(
      () => load(file(events: [event(), event()])),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(load(file()).events.single.uid, load(file()).events.single.uid);
  });
  test('temporal type, zone and end-duration constraints reject', () {
    for (final extra in [
      ['DTEND:20261022T110000Z'],
      ['DTEND:20261022T120000Z'],
      ['DURATION:PT0S'],
      ['DURATION:-PT1H'],
      ['DTEND:20261022T130000Z', 'DURATION:PT1H'],
      ['DTEND;VALUE=DATE:20261023'],
    ]) {
      expect(
        () => load(file(events: [event(extra: extra)])),
        rejects(IcalendarComponentError.invalidValue),
        reason: extra.toString(),
      );
    }
    for (final duration in ['PT24H', 'P1DT0H', 'P1DT0S']) {
      expect(
        () => load(
          file(
            events: [
              event(
                timing: 'DTSTART;VALUE=DATE:20261022',
                extra: ['DURATION:$duration'],
              ),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    }
  });
  test(
    'fraction, leap-second, floating and metadata timestamp restrictions hold',
    () {
      for (final timing in [
        'DTSTART:20261022T120000',
        'DTSTART:20261022T120000.000Z',
        'DTSTART:20161231T235960Z',
        'DTSTART:19691231T235959Z',
        'DTSTART:21000101T000000Z',
        'DTSTART;VALUE=DATE-TIME:20261022',
        'DTSTART;VALUE=PERIOD:20261022T120000Z/PT1H',
      ]) {
        expect(
          () => load(file(events: [event(timing: timing)])),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        () => load(
          file().replaceFirst(
            'DTSTAMP:20261022T100000Z',
            'DTSTAMP:20261022T100000',
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            events: [
              event(extra: ['CREATED;VALUE=DATE:20261021']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedParameter),
      );
    },
  );
  test('explicit exclusive endpoints do not widen ordinary starts', () {
    final date = load(
      file(
        events: [
          event(
            timing: 'DTSTART;VALUE=DATE:20991231',
            extra: ['DTEND;VALUE=DATE:21000101'],
          ),
        ],
      ),
    ).events.single;
    expect(date.dateSpan!.end!.isExclusiveEnd, isTrue);
    final timed = load(
      file(
        events: [
          event(
            timing: 'DTSTART:20991231T230000Z',
            extra: ['DTEND:21000101T000000Z'],
          ),
        ],
      ),
    ).events.single;
    expect(timed.timedSpan!.end!.civil.date.isExclusiveEnd, isTrue);
    expect(
      () => load(file(events: [event(timing: 'DTSTART;VALUE=DATE:21000101')])),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('invalid enum, sequence, URI and language metadata reject', () {
    for (final line in [
      'STATUS:COMPLETED',
      'TRANSP:FREE',
      'SEQUENCE:-1',
      'SEQUENCE:2147483648',
      'SEQUENCE:1.0',
      'SUMMARY;LANGUAGE=not_a_tag:Title',
      'SUMMARY;ALTREP="/relative":Title',
      'DESCRIPTION;ALTREP="https://user:password@example.invalid":Text',
    ]) {
      expect(
        () => load(
          file(
            events: [
              event(extra: [line]),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
        reason: line,
      );
    }
    expect(
      load(
        file(
          events: [
            event(extra: ['SEQUENCE:2147483647']),
          ],
        ),
      ).events.single.sequence,
      2147483647,
    );
  });
  test('manually constructed syntax still faces syntax and text budgets', () {
    final raw = parseIcalendarSyntax(utf8.encode(file()));
    expect(
      () => validateIcalendarEventCalendar(
        raw,
        syntaxLimits: const IcalendarSyntaxLimits(maxBytes: 10),
      ),
      throwsA(isA<IcalendarSyntaxException>()),
    );
    expect(
      () => load(
        file(
          events: [
            event(extra: ['SUMMARY:${'x' * 4097}']),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(
        file(
          events: [
            event(extra: [r'SUMMARY:bad\q']),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test('resource limits are shared across the complete source', () {
    expect(
      () => load(
        file(
          events: [
            event(),
            event(uid: 'second'),
          ],
        ),
        limits: const IcalendarComponentLimits(maxEvents: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(),
            fixedZone(id: 'Etc/UTC'),
          ],
        ),
        limits: const IcalendarComponentLimits(maxZones: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(),
            fixedZone(id: 'Etc/UTC'),
          ],
        ),
        limits: const IcalendarComponentLimits(maxObservances: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(),
            fixedZone(id: 'Etc/UTC'),
          ],
        ),
        limits: const IcalendarComponentLimits(maxOnsets: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(file(), limits: const IcalendarComponentLimits(maxEvents: 0)),
      throwsArgumentError,
    );
  });
  test(
    'named times require their exact validated definition and no UTC TZID',
    () {
      expect(
        () => load(
          file(events: [event(timing: 'DTSTART;TZID=UTC:20261022T120000')]),
        ),
        rejects(IcalendarComponentError.missing),
      );
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [event(timing: 'DTSTART;TZID=UTC:20261022T120000Z')],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [event(timing: 'DTSTART;VALUE=DATE;TZID=UTC:20261022')],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [event(timing: 'DTSTART;TZID=Etc/UTC:20261022T120000')],
          ),
        ),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test('fixed offset matching includes the civil-profile UTC edges', () {
    final value = load(
      file(
        zones: [fixedZone(id: 'Etc/GMT-14', offset: '+1400')],
        events: [event(timing: 'DTSTART;TZID=Etc/GMT-14:19700101T000000')],
      ),
    );
    expect(
      value.events.single.timedSpan!.start.instant,
      DateTime.utc(1969, 12, 31, 10),
    );
    final snapshot = value.timeZones.values.single.snapshot;
    expect(snapshot.horizon.start, DateTime.utc(1969, 12, 31));
    expect(snapshot.horizon.end, DateTime.utc(2100, 1, 2));
  });
  test('full-history explicit definitions match diverse pinned IANA zones', () {
    for (final id in [
      'Europe/Stockholm',
      'US/Eastern',
      'Pacific/Apia',
      'Australia/Lord_Howe',
      'Asia/Kathmandu',
    ]) {
      final value = load(
        file(
          zones: [explicitZone(id)],
          events: [event(timing: 'DTSTART;TZID=$id:20261022T120000')],
        ),
      );
      expect(value.timeZones[id]!.dataVersion, NamedZoneResolver.dataVersion);
      expect(value.events.single.timedSpan!.start.zoneId, id);
      final again = parseIcalendarEventCalendar(
        serializeIcalendarEventCalendar(value),
      );
      expect(again.events.single.timedSpan, value.events.single.timedSpan);
    }
  });
  test(
    'historical YEARLY regimes and one-off onsets match New York exactly',
    () {
      final value = load(
        file(
          zones: [newYorkZone()],
          events: [
            event(
              timing: 'DTSTART;TZID=America/New_York:20260308T023000',
              extra: ['DURATION:P1D'],
            ),
          ],
        ),
      );
      final span = value.events.single.timedSpan!;
      expect(span.start.instant, DateTime.utc(2026, 3, 8, 7, 30));
      expect(span.start.civil.hour, 2);
      expect(span.start.civil.minute, 30);
      expect(span.duration!.days, 1);
      final fold = load(
        file(
          zones: [newYorkZone()],
          events: [
            event(timing: 'DTSTART;TZID=America/New_York:20261101T013000'),
          ],
        ),
      ).events.single;
      expect(fold.timedSpan!.start.instant, DateTime.utc(2026, 11, 1, 5, 30));
    },
  );
  test('correct event-date offsets cannot hide a historical mismatch', () {
    final wrong = newYorkZone().replaceFirst(
      '19740106T020000',
      '19740107T020000',
    );
    expect(
      () => load(file(zones: [wrong])),
      rejects(IcalendarComponentError.zoneMismatch),
    );
    expect(
      () => load(
        file(
          zones: [fixedZone(id: 'America/New_York', offset: '-0500')],
        ),
      ),
      rejects(IcalendarComponentError.zoneMismatch),
    );
  });
  test('unknown, case-mismatched and duplicate zone identities reject', () {
    expect(
      () => load(file(zones: [fixedZone(id: 'europe/stockholm')])),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(file(zones: [fixedZone(id: 'Custom/Private')])),
      rejects(IcalendarComponentError.invalidValue),
    );
    expect(
      () => load(file(zones: [fixedZone(), fixedZone()])),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => load(file(zones: [fixedZone(id: 'Factory')])),
      rejects(IcalendarComponentError.zoneCoverage),
    );
  });
  test(
    'a definition beginning after the horizon has insufficient coverage',
    () {
      expect(
        () => load(file(zones: [fixedZone(seed: '19700101T000000')])),
        rejects(IcalendarComponentError.zoneCoverage),
      );
    },
  );
  test(
    'observance DTSTART and offsets obey their own strict value grammar',
    () {
      for (final seed in [
        '00000101T000000',
        '19000229T000000',
        '19000101T000000Z',
        '19000101T000000.000',
        '21010101T000000',
        '19000101T000060',
      ]) {
        expect(
          () => load(file(zones: [fixedZone(seed: seed)])),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      for (final offset in [
        '-0000',
        '+2400',
        '+0060',
        '+000060',
        '+00:00',
        '0000',
      ]) {
        expect(
          () => load(file(zones: [fixedZone(offset: offset)])),
          rejects(IcalendarComponentError.invalidValue),
        );
      }
      expect(
        load(file(zones: [fixedZone(seed: '00010101T000000')]))
            .timeZones
            .length,
        1,
      );
      expect(
        () => load(
          file(
            zones: [fixedZone()],
            events: [event(timing: 'DTSTART:00010101T000000Z')],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('conflicting same-instant onsets and offset discontinuities reject', () {
    final second = [
      'BEGIN:STANDARD',
      'DTSTART:20000101T000000',
      'TZOFFSETFROM:+0000',
      'TZOFFSETTO:+0100',
      'END:STANDARD',
    ].join('\r\n');
    final third = second.replaceFirst('TZOFFSETTO:+0100', 'TZOFFSETTO:+0200');
    expect(
      () => load(
        file(
          zones: [
            fixedZone().replaceFirst(
              'END:VTIMEZONE',
              '$second\r\n$third\r\nEND:VTIMEZONE',
            ),
          ],
        ),
      ),
      rejects(IcalendarComponentError.zoneMismatch),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(extra: ['RDATE:20000101T000000'])
                .replaceFirst('END:VTIMEZONE', '$second\r\nEND:VTIMEZONE'),
          ],
        ),
      ),
      rejects(IcalendarComponentError.zoneMismatch),
    );
  });
  test(
    'zone labels, comments and URLs are retained without determining offsets',
    () {
      final zone =
          fixedZone(
            extra: [
              'TZNAME;LANGUAGE=en:Display only',
              'COMMENT;ALTREP="urn:synthetic:note":No lookup',
            ],
          ).replaceFirst(
            'TZID:UTC',
            'TZID:UTC\r\nTZURL:https://example.invalid/zone\r\nLAST-MODIFIED:20261022T090000Z',
          );
      final value = load(file(zones: [zone]));
      final serialized = utf8.decode(serializeIcalendarEventCalendar(value));
      expect(serialized, contains('Display only'));
      expect(serialized, contains('urn:synthetic:note'));
      expect(serialized, contains('https://example.invalid/zone'));
      expect(value.timeZones['UTC']!.snapshot.initialOffset, Duration.zero);
    },
  );
  test(
    'unsupported observance forms and invalid yearly rules reject explicitly',
    () {
      for (final rule in [
        'FREQ=MONTHLY',
        'FREQ=YEARLY;COUNT=2',
        'FREQ=YEARLY;BYHOUR=1',
        'FREQ=YEARLY;BYDAY=1MO',
        'FREQ=YEARLY;BYMONTHDAY=1',
        'FREQ=YEARLY;BYMONTH=0',
        'FREQ=YEARLY;BYMONTH=1;BYDAY=0MO',
        'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=0',
        'FREQ=YEARLY;INTERVAL=0',
        'FREQ=YEARLY;FREQ=YEARLY',
        'FREQ=YEARLY;UNTIL=20000101T000000',
        'FREQ=YEARLY;UNTIL=18990101T000000Z',
        'FREQ=YEARLY;UNTIL=20000102T000000Z',
      ]) {
        expect(
          () => load(
            file(
              zones: [
                fixedZone(extra: ['RRULE:$rule']),
              ],
            ),
          ),
          throwsA(isA<IcalendarComponentException>()),
          reason: rule,
        );
      }
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['RDATE;VALUE=DATE:20000101']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['EXDATE:20000101T000000']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    },
  );
  test(
    'yearly matching uses month-day intersections, negative days and intervals',
    () {
      for (final rule in [
        'FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=1',
        'FREQ=YEARLY;BYMONTH=1;BYDAY=MO;BYMONTHDAY=1,2,3,4,5,6,7',
        'FREQ=YEARLY;BYMONTH=1;BYDAY=1MO',
        'FREQ=YEARLY;INTERVAL=2;BYMONTH=1;BYMONTHDAY=1',
        'FREQ=YEARLY;BYMONTH=1,2;BYMONTHDAY=1',
      ]) {
        expect(
          load(
            file(
              zones: [
                fixedZone(extra: ['RRULE:$rule']),
              ],
            ),
          ).timeZones.length,
          1,
        );
      }
      expect(
        load(
          file(
            zones: [
              fixedZone(
                seed: '19000131T000000',
                extra: ['RRULE:FREQ=YEARLY;BYMONTH=1;BYMONTHDAY=-1'],
              ),
            ],
          ),
        ).timeZones.length,
        1,
      );
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['RRULE:FREQ=YEARLY;BYMONTH=2;BYMONTHDAY=1']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
      );
    },
  );
  test('expansion budgets charge duplicate RDATEs and yearly candidates before deduplication', () {
    expect(
      () => load(
        file(
          zones: [
            fixedZone(extra: ['RDATE:19000101T000000,19000101T000000']),
          ],
        ),
        limits: const IcalendarComponentLimits(maxOnsets: 2),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(extra: ['RRULE:FREQ=YEARLY']),
          ],
        ),
        limits: const IcalendarComponentLimits(maxCandidates: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
  test(
    'URI metadata keeps valid ASCII spelling and rejects implicit repair',
    () {
      for (final uri in [
        "https://example.invalid/a'b",
        'https://[::1]/note',
        'urn:synthetic:note%20one',
      ]) {
        final value = load(
          file(
            events: [
              event(extra: ['SUMMARY;ALTREP="$uri":Title']),
            ],
          ),
        );
        expect(value.events.single.summary!.alternativeUri, uri);
      }
      for (final uri in [
        'https://',
        'urn:',
        'https://example.invalid/a[b]',
        'urn:note#one#two',
        'urn:note%zz',
        'urn:note\\bad',
      ]) {
        expect(
          () => load(
            file(
              events: [
                event(extra: ['SUMMARY;ALTREP="$uri":Title']),
              ],
            ),
          ),
          rejects(IcalendarComponentError.invalidValue),
          reason: uri,
        );
      }
    },
  );
  test('named endpoints preserve midnight and exact start zone profile', () {
    final value = load(
      file(
        zones: [newYorkZone()],
        events: [
          event(
            timing: 'DTSTART;TZID=America/New_York:20991231T230000',
            extra: ['DTEND;TZID=America/New_York:21000101T000000'],
          ),
        ],
      ),
    );
    expect(
      value.events.single.timedSpan!.end!.instant,
      DateTime.utc(2100, 1, 1, 5),
    );
    expect(
      () => load(
        file(
          zones: [
            fixedZone(),
            fixedZone(id: 'Etc/UTC'),
          ],
          events: [
            event(
              timing: 'DTSTART;TZID=UTC:20261022T120000',
              extra: ['DTEND;TZID=Etc/UTC:20261022T130000'],
            ),
          ],
        ),
      ),
      rejects(IcalendarComponentError.invalidValue),
    );
  });
  test(
    'zone grammar rejects nested components and duplicate required values',
    () {
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['TZOFFSETTO:+0000']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.duplicate),
      );
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['BEGIN:STANDARD', 'END:STANDARD']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedComponent),
      );
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['TZNAME;X-PRIVATE=one:Label']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.unsupportedParameter),
      );
      expect(
        () => load(
          file(zones: [fixedZone().replaceFirst('TZOFFSETFROM:+0000\r\n', '')]),
        ),
        rejects(IcalendarComponentError.missing),
      );
    },
  );
  test('yearly numeric fields enforce RFC signs and digit widths', () {
    for (final part in [
      'BYMONTH=+1',
      'BYMONTH=001',
      'BYMONTHDAY=001',
      'BYMONTHDAY=+001',
      'INTERVAL=+1',
    ]) {
      expect(
        () => load(
          file(
            zones: [
              fixedZone(extra: ['RRULE:FREQ=YEARLY;$part']),
            ],
          ),
        ),
        rejects(IcalendarComponentError.invalidValue),
        reason: part,
      );
    }
    expect(
      load(
        file(
          zones: [
            fixedZone(
              extra: [
                'RRULE:FREQ=YEARLY;INTERVAL=0001;BYMONTH=01;BYMONTHDAY=+01',
              ],
            ),
          ],
        ),
      ).timeZones.length,
      1,
    );
  });
  test('diagnostics never echo private unknown property or zone values', () {
    try {
      load(
        file(
          events: [
            event(extra: ['X-PRIVATE-SECRET:sensitive-value']),
          ],
        ),
      );
      fail('Expected rejection');
    } on IcalendarComponentException catch (error) {
      expect(
        error.toString(),
        'IcalendarComponentException(unsupportedProperty)',
      );
    }
  });
}
