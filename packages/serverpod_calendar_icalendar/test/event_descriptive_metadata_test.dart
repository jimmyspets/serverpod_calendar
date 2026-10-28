import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'icalendar_event_override_test.dart' show timed, single, rejects;

const descriptive = [
  'PRIORITY:0',
  'GEO:+090.000000000000000000;-000.000',
  r'RESOURCES;LANGUAGE=sv;ALTREP="cid:labels@example.invalid":Rum\, ett,,Rum',
  'RESOURCES:Room,Room',
];
void main() {
  test('descriptive wire preserves exact decimals, zero, source groups and annotations', () {
    final c = timed([], extra: descriptive), m = c.events.single.metadata;
    expect(m.priority, 0);
    expect(m.geographicPosition!.latitudeText, '+090.000000000000000000');
    expect(m.geographicPosition!.longitudeText, '-000.000');
    expect(m.resources.first.values, ['Rum, ett', '', 'Rum']);
    expect(m.resources.last.values, ['Room', 'Room']);
    expect(m.resources.first.alternativeUri, 'cid:labels@example.invalid');
    expect(() => m.resources.first.values.clear(), throwsUnsupportedError);
    final bytes = serializeIcalendarEventCalendar(c);
    expect(
      serializeIcalendarEventCalendar(parseIcalendarEventCalendar(bytes)),
      bytes,
    );
    expect(
      utf8.decode(bytes),
      contains('GEO:+090.000000000000000000;-000.000'),
    );
    expect(timed([]).events.single.metadata.priority, isNull);
  });
  test('descriptive occurrence omissions inherit and matching groups retain presence', () {
    final c = timed([
      single(':20261023T120000Z', 'DTSTART:20261023T130000Z'),
      single(
        ';RANGE=THISANDFUTURE:20261024T120000Z',
        'DTSTART:20261024T130000Z',
        extra: descriptive,
      ),
    ], extra: descriptive);
    final s = c.series.single;
    expect(s.overrides.first.metadata.geographicPosition, isNull);
    expect(s.metadataFor(s.overrides.first).priority, 0);
    expect(s.metadataFor(s.overrides.first).resources.length, 2);
    expect(
      s.overrides.last.metadata.geographicPosition!.longitudeText,
      '-000.000',
    );
    for (final extra in <List<String>>[
      ['PRIORITY:1'],
      ['GEO:90;0'],
      ['RESOURCES:Room,Room'],
    ]) {
      expect(
        () => timed([
          single(':20261023T120000Z', 'DTSTART:20261023T130000Z', extra: extra),
        ], extra: descriptive),
        rejects(IcalendarComponentError.unsupportedProperty),
      );
    }
  });
  for (final value in [
    '90.000000000000000001;0',
    '0;-180.000000000000001',
    '1e1;0',
    '.1;0',
    '1.;0',
    'NaN;0',
    '1;2;3',
    ' 1;0',
  ]) {
    test('strict exact GEO rejects $value', () {
      expect(
        () => timed([], extra: ['GEO:$value']),
        rejects(IcalendarComponentError.invalidValue),
      );
    });
  }
  test('descriptive raw caps parameters and duplicate cardinality reject', () {
    for (final extra in <List<String>>[
      ['PRIORITY:10'],
      ['PRIORITY:-1'],
      ['GEO;VALUE=FLOAT:1;2'],
      ['RESOURCES;X-HOST=x:Room'],
    ]) {
      expect(
        () => timed([], extra: extra),
        throwsA(isA<IcalendarComponentException>()),
      );
    }
    expect(
      () => timed([], extra: ['GEO:0;0', 'GEO:0;0']),
      rejects(IcalendarComponentError.duplicate),
    );
    expect(
      () => timed([], extra: List.filled(33, 'RESOURCES:Room')),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed([], extra: ['RESOURCES:${List.filled(65, '').join(',')}']),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed([], extra: ['GEO:${'0' * 65};0']),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed([], extra: ['RESOURCES:${'x' * 4097}']),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
