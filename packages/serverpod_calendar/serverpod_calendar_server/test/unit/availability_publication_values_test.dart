@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_values.dart';

CalendarAvailabilityContent sample() => CalendarAvailabilityContent(
  openings: [],
  summary: 'Möte',
  categories: ['Work'],
  comments: ['First', 'Second'],
);
void main() {
  test('text parameters retain spelling and independent repeated comment positions', () {
    final raw = <CalendarTextParameters?>[
      CalendarTextParameters(language: 'SV'),
      CalendarTextParameters(alternativeUri: 'cid:second@example.invalid'),
    ];
    final c = validateAvailabilityContent(
      sample().copyWith(
        textParameters: CalendarAvailabilityTextParameters(
          summary: CalendarTextParameters(
            language: 'sv-SE',
            alternativeUri: 'https://example.invalid/plain',
          ),
          categoryLanguage: 'EN',
          comments: raw,
        ),
      ),
    );
    raw.clear();
    expect(c.summary, 'Möte');
    expect(c.textParameters!.comments, hasLength(2));
    expect(c.textParameters!.comments![0]!.language, 'SV');
    expect(() => c.textParameters!.comments!.clear(), throwsUnsupportedError);
    expect(c.textParameters!.summary!.language, 'sv-SE');
    expect(c.textParameters!.categoryLanguage, 'EN');
  });
  test('orphan parameters, invalid tags and comment cardinality reject', () {
    for (final p in [
      CalendarAvailabilityTextParameters(
        description: CalendarTextParameters(language: 'sv'),
      ),
      CalendarAvailabilityTextParameters(
        summary: CalendarTextParameters(language: 'en_US'),
      ),
      CalendarAvailabilityTextParameters(
        comments: [CalendarTextParameters(language: 'sv')],
      ),
      CalendarAvailabilityTextParameters(
        summary: CalendarTextParameters(alternativeUri: '../relative'),
      ),
    ]) {
      expect(
        () => validateAvailabilityContent(sample().copyWith(textParameters: p)),
        throwsArgumentError,
      );
    }
    expect(
      () => validateAvailabilityContent(
        sample().copyWith(
          categories: [],
          textParameters: CalendarAvailabilityTextParameters(
            categoryLanguage: 'sv',
          ),
        ),
      ),
      throwsArgumentError,
    );
  });
  test('organizer is URI metadata and language refers to common name only', () {
    final c = validateAvailabilityContent(
      sample().copyWith(
        organizer: CalendarAvailabilityOrganizer(
          address: 'mailto:alice@example.invalid',
          commonName: 'Åsa',
          language: 'sv',
          directoryUri: 'ldap://example.invalid/people',
        ),
      ),
    );
    expect(c.organizer!.commonName, 'Åsa');
    for (final o in [
      CalendarAvailabilityOrganizer(address: 'relative'),
      CalendarAvailabilityOrganizer(
        address: 'mailto:alice@example.invalid',
        language: 'sv',
      ),
      CalendarAvailabilityOrganizer(
        address: 'https://name:password@example.invalid',
      ),
    ]) {
      expect(
        () => validateAvailabilityContent(sample().copyWith(organizer: o)),
        throwsArgumentError,
      );
    }
    for (final uri in [
      'https://example.invalid/%ZZ',
      'https://example.invalid/ bad',
      'https://example.invalid/\n',
      'https://example.invalid/å',
    ]) {
      expect(() => validateAvailabilityMetadataUri(uri), throwsArgumentError);
    }
  });
  test('extensions are bounded decoded text, unique by case and frozen', () {
    final raw = [
      CalendarAvailabilityExtension(name: 'X-HOST-LABEL', value: 'Résumé'),
    ];
    final c = validateAvailabilityContent(sample().copyWith(extensions: raw));
    raw.clear();
    expect(c.extensions!.single.value, 'Résumé');
    expect(() => c.extensions!.clear(), throwsUnsupportedError);
    for (final values in [
      [CalendarAvailabilityExtension(name: 'SUMMARY', value: 'Override')],
      [
        CalendarAvailabilityExtension(name: 'X-A', value: ''),
        CalendarAvailabilityExtension(name: 'x-a', value: ''),
      ],
      List.generate(
        33,
        (i) => CalendarAvailabilityExtension(name: 'X-A-$i', value: ''),
      ),
      [CalendarAvailabilityExtension(name: 'X-A', value: 'x' * 4097)],
    ]) {
      expect(
        () =>
            validateAvailabilityContent(sample().copyWith(extensions: values)),
        throwsArgumentError,
      );
    }
  });
  test(
    'old JSON defaults stay absent and new metadata uses aggregate budget',
    () {
      final old = CalendarAvailabilityContent.fromJson({
        'openings': <dynamic>[],
        'summary': 'Legacy',
      });
      final c = validateAvailabilityContent(old);
      expect(c.textParameters, isNull);
      expect(c.organizer, isNull);
      expect(c.extensions, isNull);
      final large = List.generate(
        17,
        (i) => CalendarAvailabilityExtension(name: 'X-A-$i', value: 'x' * 4096),
      );
      expect(
        () => validateAvailabilityContent(sample().copyWith(extensions: large)),
        throwsArgumentError,
      );
    },
  );
}
