import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'icalendar_event_override_test.dart' show timed, single, rejects;
import 'support/icalendar_fixtures.dart' show file, event, load;

const metadata = [
  'URL:https://example.invalid/event?q=work',
  'CLASS:private',
  r'CATEGORIES;LANGUAGE=sv:Arbete\, möten,Planering',
  'CATEGORIES;LANGUAGE=en:Work,Work',
  r'COMMENT;LANGUAGE=sv;ALTREP="cid:note@example.invalid":Första\nAndra',
  'COMMENT:Another',
  r'CONTACT;LANGUAGE=en;ALTREP="https://example.invalid/contact":Synthetic\, Desk',
  'CONTACT:Other desk',
];
void main() {
  test('event metadata preserves groups Unicode annotations and source round trips', () {
    final c = timed([], extra: metadata), m = c.events.single.metadata;
    expect(m.url, 'https://example.invalid/event?q=work');
    expect(m.classification, 'PRIVATE');
    expect(m.categoryGroups.map((g) => g.values), [
      ['Arbete, möten', 'Planering'],
      ['Work', 'Work'],
    ]);
    expect(m.comments.first.value, 'Första\nAndra');
    expect(m.comments.first.alternativeUri, 'cid:note@example.invalid');
    expect(m.contacts.first.value, 'Synthetic, Desk');
    expect(m.contacts.first.language, 'en');
    final bytes = serializeIcalendarEventCalendar(c);
    expect(
      serializeIcalendarEventCalendar(parseIcalendarEventCalendar(bytes)),
      bytes,
    );
    expect(utf8.decode(bytes), contains('CLASS:private'));
    expect(() => m.categoryGroups.first.values.clear(), throwsUnsupportedError);
    expect(() => m.comments.clear(), throwsUnsupportedError);
  });
  test('event occurrence metadata inherits omissions and retains explicit matches at RANGE anchor', () {
    final c = timed([
      single(':20261023T120000Z', 'DTSTART:20261023T140000Z'),
      single(
        ';RANGE=THISANDFUTURE:20261024T120000Z',
        'DTSTART:20261024T150000Z',
        extra: metadata,
      ),
    ], extra: metadata);
    final series = c.series.single;
    expect(series.overrides.first.metadata.comments, isEmpty);
    expect(
      series.metadataFor(series.overrides.first).comments.first.value,
      'Första\nAndra',
    );
    expect(series.overrides.last.metadata.categoryGroups.length, 2);
    expect(series.metadataFor(series.master).classification, 'PRIVATE');
    expect(
      () => series.metadataFor(timed([]).events.single),
      throwsArgumentError,
    );
    expect(
      parseIcalendarEventCalendar(serializeIcalendarEventCalendar(c))
          .series
          .single
          .overrides
          .first
          .metadata
          .contacts,
      isEmpty,
    );
  });
  test('event CLASS omission stays absent while explicit occurrence PUBLIC matches default', () {
    final c = timed([
      single(
        ':20261023T120000Z',
        'DTSTART:20261023T120000Z',
        extra: ['CLASS:PUBLIC'],
      ),
    ]);
    expect(c.events.single.metadata.classification, isNull);
    expect(
      c.series.single
          .metadataFor(c.series.single.overrides.single)
          .classification,
      'PUBLIC',
    );
  });
  test(
    'event differing occurrence metadata and changed source grouping reject',
    () {
      for (final extra in <List<String>>[
        ['URL:https://example.invalid/other'],
        ['CLASS:PUBLIC'],
        ['CATEGORIES:Other'],
        ['COMMENT:Another'],
        ['CONTACT:Other desk'],
        [
          r'CATEGORIES;LANGUAGE=sv:Arbete\, möten',
          'CATEGORIES;LANGUAGE=sv:Planering',
          'CATEGORIES;LANGUAGE=en:Work,Work',
        ],
      ]) {
        expect(
          () => timed([
            single(
              ':20261023T120000Z',
              'DTSTART:20261023T120000Z',
              extra: extra,
            ),
          ], extra: metadata),
          rejects(IcalendarComponentError.unsupportedProperty),
        );
      }
    },
  );
  test('event metadata URI class parameters duplicates and text cardinality reject explicitly', () {
    for (final extra in <List<String>>[
      ['URL:relative'],
      ['URL:ftp://example.invalid/event'],
      ['URL:https://user:password@example.invalid/event'],
      ['CLASS:X-PRIVATE'],
      ['CLASS;LANGUAGE=en:PRIVATE'],
      ['CATEGORIES;ALTREP="cid:category@example.invalid":Work'],
      ['URL:https://example.invalid/a', 'URL:https://example.invalid/b'],
      ['CLASS:PRIVATE', 'CLASS:PUBLIC'],
    ]) {
      expect(
        () => timed([], extra: extra),
        throwsA(isA<IcalendarComponentException>()),
        reason: extra.first,
      );
    }
  });
  test('event metadata item limits are bounded without truncation', () {
    for (final extra in <List<String>>[
      [for (var i = 0; i < 65; i++) 'CATEGORIES:Work'],
      [for (var i = 0; i < 33; i++) 'COMMENT:Note'],
      [for (var i = 0; i < 33; i++) 'CONTACT:Desk'],
    ]) {
      expect(
        () => timed([], extra: extra),
        rejects(IcalendarComponentError.limitExceeded),
      );
    }
  });
  test('event metadata uses independent whole-file codepoint budget across masters and overrides', () {
    expect(
      () => timed(
        [],
        extra: ['COMMENT:ab'],
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 1),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => load(
        file(
          events: [
            event(uid: 'first', extra: ['COMMENT:abcd']),
            event(uid: 'second', extra: ['CONTACT:abcd']),
          ],
        ),
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 7),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => timed(
        [
          single(
            ':20261023T120000Z',
            'DTSTART:20261023T120000Z',
            extra: ['COMMENT:abcd'],
          ),
        ],
        extra: ['COMMENT:abcd'],
        limits: const IcalendarComponentLimits(maxEventMetadataCodePoints: 7),
      ),
      rejects(IcalendarComponentError.limitExceeded),
    );
  });
}
