import 'dart:convert';
import 'dart:math';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

Matcher fails(IcalendarValueError kind) =>
    throwsA(isA<IcalendarValueException>().having((e) => e.kind, 'kind', kind));

void main() {
  test('DATE round trips independently of timezones', () {
    for (final text in ['19700101', '20000229', '20261022', '20991231']) {
      expect(serializeIcalendarDate(parseIcalendarDate(text)), text);
    }
    expect(parseIcalendarDate('20000229').day, 29);
  });
  test('invalid dates are rejected rather than normalized', () {
    for (final text in [
      '20260229',
      '20010229',
      '20260431',
      '20260001',
      '20261301',
      '20260100',
    ]) {
      expect(
        () => parseIcalendarDate(text),
        fails(IcalendarValueError.invalidValue),
      );
    }
  });
  test(
    'DATE rejects alternate spellings, escapes, lists and trailing data',
    () {
      for (final text in [
        '2026-10-22',
        ' 20261022',
        '20261022\n',
        '20261022Z',
        '20261022,20261023',
        r'20261022\n',
        '２０２６１０２２',
        '2026102',
      ]) {
        expect(
          () => parseIcalendarDate(text),
          fails(IcalendarValueError.invalidSyntax),
        );
      }
    },
  );
  test('ordinary DATE excludes both ends outside the selected profile', () {
    for (final text in ['00000101', '19691231', '21000101', '99991231']) {
      expect(
        () => parseIcalendarDate(text),
        fails(IcalendarValueError.outsideProfile),
      );
    }
  });
  test(
    'exclusive DATE endpoint requires explicit opt-in in both directions',
    () {
      final end = parseIcalendarDate('21000101', exclusiveEnd: true);
      expect(end, const CalendarDate.exclusiveEnd());
      expect(serializeIcalendarDate(end, exclusiveEnd: true), '21000101');
      expect(
        () => serializeIcalendarDate(end),
        fails(IcalendarValueError.outsideProfile),
      );
      expect(
        () => parseIcalendarDate('21000102', exclusiveEnd: true),
        fails(IcalendarValueError.outsideProfile),
      );
    },
  );
  test('UTC DATE-TIME preserves whole seconds', () {
    final value = parseIcalendarDateTime('20261022T123456Z');
    expect(value.instant, DateTime.utc(2026, 10, 22, 12, 34, 56));
    expect(value.zoneId, isNull);
    expect(serializeIcalendarDateTime(value), '20261022T123456Z');
  });
  test(
    'DATE-TIME rejects fractions including all-zero fractions and offsets',
    () {
      for (final text in [
        '20261022T123456.000Z',
        '20261022T123456.001Z',
        '20261022T123456+0100',
        '20261022T1234Z',
        '2026-10-22T12:34:56Z',
        '20261022t123456z',
        '20261022T123456Z\n',
        '20261022T123456Z,20261023T123456Z',
      ]) {
        expect(
          () => parseIcalendarDateTime(text),
          fails(IcalendarValueError.invalidSyntax),
        );
      }
    },
  );
  test('DATE-TIME rejects leap seconds and normalized time fields', () {
    for (final text in [
      '20161231T235960Z',
      '20261022T240000Z',
      '20261022T126000Z',
    ]) {
      expect(
        () => parseIcalendarDateTime(text),
        fails(IcalendarValueError.invalidValue),
      );
    }
  });
  test('floating values and UTC with TZID reject explicitly', () {
    expect(
      () => parseIcalendarDateTime('20261022T123456'),
      fails(IcalendarValueError.floatingTime),
    );
    expect(
      () => parseIcalendarDateTime('20261022T123456Z', zoneId: 'Etc/UTC'),
      fails(IcalendarValueError.invalidContext),
    );
  });
  test('named zones preserve aliases and requested gap fields', () {
    final value = parseIcalendarDateTime(
      '20260308T023000',
      zoneId: 'US/Eastern',
    );
    expect(value.zoneId, 'US/Eastern');
    expect(value.instant, DateTime.utc(2026, 3, 8, 7, 30));
    expect(serializeIcalendarDateTime(value), '20260308T023000');
    expect(
      parseIcalendarDateTime(
        serializeIcalendarDateTime(value),
        zoneId: value.zoneId,
      ),
      value,
    );
  });
  test('named fold selects first occurrence', () {
    final value = parseIcalendarDateTime(
      '20261101T013000',
      zoneId: 'America/New_York',
    );
    expect(value.instant, DateTime.utc(2026, 11, 1, 5, 30));
  });
  test('unknown, differently cased and over-limit zones do not guess', () {
    for (final zone in [
      '',
      'europe/Stockholm',
      'Windows Zone',
      '/Europe/Stockholm',
    ]) {
      expect(
        () => parseIcalendarDateTime('20261022T123456', zoneId: zone),
        fails(IcalendarValueError.unsupportedZone),
      );
    }
    expect(
      () => parseIcalendarDateTime('20261022T123456', zoneId: 'x' * 256),
      fails(IcalendarValueError.limitExceeded),
    );
  });
  test(
    'DATE-TIME boundary is midnight only and explicit in both directions',
    () {
      for (final zone in [null, 'Pacific/Kiritimati', 'America/New_York']) {
        final text = zone == null ? '21000101T000000Z' : '21000101T000000';
        expect(
          () => parseIcalendarDateTime(text, zoneId: zone),
          fails(IcalendarValueError.outsideProfile),
        );
        final value = parseIcalendarDateTime(
          text,
          zoneId: zone,
          exclusiveEnd: true,
        );
        expect(serializeIcalendarDateTime(value, exclusiveEnd: true), text);
        expect(
          () => serializeIcalendarDateTime(value),
          fails(IcalendarValueError.outsideProfile),
        );
      }
      expect(
        () => parseIcalendarDateTime('21000101T000001Z', exclusiveEnd: true),
        fails(IcalendarValueError.invalidValue),
      );
      expect(
        () => parseIcalendarDateTime('19691231T235959Z'),
        fails(IcalendarValueError.outsideProfile),
      );
    },
  );
  test('duration forms and signs map to retained units', () {
    final examples = {
      'P7W': CalendarDuration(weeks: 7),
      'P15DT5H0M20S': CalendarDuration(days: 15, hours: 5, seconds: 20),
      'PT20M5S': CalendarDuration(minutes: 20, seconds: 5),
      '-PT15M': CalendarDuration(sign: -1, minutes: 15),
      '+P0002D': CalendarDuration(days: 2),
      'P0W': CalendarDuration(),
      '-P0D': CalendarDuration(sign: -1),
      'P1DT0S': CalendarDuration(days: 1),
    };
    for (final item in examples.entries) {
      expect(parseIcalendarDuration(item.key), item.value);
      expect(
        parseIcalendarDuration(serializeIcalendarDuration(item.value)),
        item.value,
      );
    }
    expect(serializeIcalendarDuration(parseIcalendarDuration('-P0D')), '-PT0S');
    expect(
      serializeIcalendarDuration(parseIcalendarDuration('+P0002D')),
      'P2D',
    );
  });
  test(
    'duration grammar rejects invalid order, fractions and unsupported units',
    () {
      for (final text in [
        '',
        'P',
        'PT',
        'P1DT',
        'P1Y',
        'P1M',
        'P1W1D',
        'P0WT0S',
        'PT1H1S',
        'PT1S1M',
        'PT1.000S',
        'P1.0D',
        'P-1D',
        'PT1M2M',
        'p1d',
        'P1D\n',
        ' P1D',
        r'P1D\n',
        'P1D,P2D',
      ]) {
        expect(
          () => parseIcalendarDuration(text),
          fails(IcalendarValueError.invalidSyntax),
          reason: text,
        );
      }
    },
  );
  test('duration magnitude checks exact web-safe integer boundaries', () {
    expect(
      parseIcalendarDuration('PT9007199254740991S').seconds,
      CalendarDuration.maxComponent,
    );
    for (final text in [
      'PT9007199254740992S',
      'PT9007199254740993S',
      'P9999999999999999999999999999W',
    ]) {
      expect(
        () => parseIcalendarDuration(text),
        fails(IcalendarValueError.outsideProfile),
      );
    }
    expect(
      () => parseIcalendarDuration('P${'0' * 128}D'),
      fails(IcalendarValueError.limitExceeded),
    );
  });
  test(
    'duration serialization inserts required minute field without carrying',
    () {
      expect(
        serializeIcalendarDuration(CalendarDuration(hours: 1, seconds: 1)),
        'PT1H0M1S',
      );
      expect(
        serializeIcalendarDuration(CalendarDuration(minutes: 90)),
        'PT90M',
      );
      expect(serializeIcalendarDuration(CalendarDuration(hours: 24)), 'PT24H');
      expect(serializeIcalendarDuration(CalendarDuration(days: 1)), 'P1D');
    },
  );
  test('nominal day and elapsed hours remain different across DST', () {
    final start = parseIcalendarDateTime(
      '20260307T120000',
      zoneId: 'America/New_York',
    );
    expect(
      start.add(parseIcalendarDuration('P1D')),
      DateTime.utc(2026, 3, 8, 16),
    );
    expect(
      start.add(parseIcalendarDuration('PT24H')),
      DateTime.utc(2026, 3, 8, 17),
    );
  });
  test(
    'generated duration and timestamp round trips on native and browser',
    () {
      final random = Random(5545);
      for (var i = 0; i < 300; i++) {
        final duration = i % 5 == 0
            ? CalendarDuration(
                sign: i.isEven ? 1 : -1,
                weeks: random.nextInt(9999),
              )
            : CalendarDuration(
                sign: i.isEven ? 1 : -1,
                days: random.nextInt(90),
                hours: random.nextInt(90),
                minutes: random.nextInt(90),
                seconds: random.nextInt(90),
              );
        expect(
          parseIcalendarDuration(serializeIcalendarDuration(duration)),
          duration,
        );
        final value = TimedValue.utc(
          DateTime.utc(
            1970 + random.nextInt(130),
            1 + random.nextInt(12),
            1 + random.nextInt(28),
            random.nextInt(24),
            random.nextInt(60),
            random.nextInt(60),
          ),
        );
        expect(
          parseIcalendarDateTime(serializeIcalendarDateTime(value)),
          value,
        );
      }
    },
  );
  test(
    'syntax and typed values compose without treating a tree as an import',
    () {
      final bytes = utf8.encode(
        'BEGIN:VEVENT\r\nDTSTART;VALUE=DATE:20261022\r\nDURATION:P1D\r\nEND:VEVENT\r\n',
      );
      final entries = parseIcalendarSyntax(bytes).components.single.entries
          .cast<IcalendarSyntaxProperty>()
          .toList();
      final date = parseIcalendarDate(entries[0].value);
      final duration = parseIcalendarDuration(entries[1].value);
      expect(
        duration.addToDate(date),
        CalendarDate(year: 2026, month: 10, day: 23),
      );
    },
  );
  test('errors never echo a supplied zone or invalid source', () {
    try {
      parseIcalendarDateTime('20261022T123456', zoneId: 'private-secret-zone');
      fail('Expected rejection');
    } on IcalendarValueException catch (error) {
      expect(error.toString(), 'IcalendarValueException(unsupportedZone)');
      expect(error.toString(), isNot(contains('private')));
    }
  });
}
