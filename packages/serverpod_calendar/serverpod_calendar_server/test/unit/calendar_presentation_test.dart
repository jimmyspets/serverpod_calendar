import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/native_calendar_name.dart';
import 'package:test/test.dart';

void main() {
  test('native descriptions preserve text and clear only empty values', () {
    expect(normalizeCalendarDescription('  a\r\nb\n\t '), '  a\r\nb\n\t ');
    expect(normalizeCalendarDescription(' '), ' ');
    expect(normalizeCalendarDescription(''), isNull);
    expect(normalizeCalendarDescription(null), isNull);
    expect(
      normalizeCalendarDescription('\u{1f600}' * 16384),
      '\u{1f600}' * 16384,
    );
    expect(
      () => normalizeCalendarDescription('x' * 16385),
      throwsArgumentError,
    );
  });
  test('decoded text rejects malformed Unicode and unsupported controls', () {
    for (final text in [
      'a\u0000',
      'a\u0001',
      '\u007f',
      String.fromCharCode(0xd800),
      String.fromCharCode(0xdc00),
    ]) {
      expect(() => normalizeCalendarDescription(text), throwsArgumentError);
      expect(
        () =>
            IcalendarCalendarTextMetadata(names: [IcalendarTextVariant(text)]),
        throwsArgumentError,
      );
    }
  });
  test('native RGB is distinct from RFC named colors', () {
    expect(normalizeCalendarNativeColor('#a0b1c2'), '#A0B1C2');
    expect(normalizeCalendarNativeColor(''), isNull);
    for (final color in ['red', '#abc', '#aabbccdd', '#aabbcc\n', ' #aabbcc']) {
      expect(() => normalizeCalendarNativeColor(color), throwsArgumentError);
    }
    expect(
      IcalendarCalendarTextMetadata(color: 'LightGoldenrodYellow').color,
      'LightGoldenrodYellow',
    );
    for (final color in [
      '#aabbcc',
      'transparent',
      'currentColor',
      'rebeccapurple',
      'red\n',
      '',
    ]) {
      expect(
        () => IcalendarCalendarTextMetadata(color: color),
        throwsArgumentError,
      );
    }
  });
  test(
    'protocol values retain spelling, empty text and legal multilingual forms',
    () {
      final source = [
        const IcalendarTextVariant('  e\u0301\n', language: 'SV-se'),
        const IcalendarTextVariant('', language: 'en'),
      ];
      final value = IcalendarCalendarTextMetadata(names: source);
      source.clear();
      expect(value.names.first.value, '  e\u0301\n');
      expect(value.names.first.language, 'SV-se');
      expect(value.names.last.value, '');
      expect(() => value.names.clear(), throwsUnsupportedError);
      expect(
        IcalendarCalendarTextMetadata(names: [IcalendarTextVariant('n' * 4096)])
            .names
            .single
            .value
            .length,
        4096,
      );
      expect(
        () => IcalendarCalendarTextMetadata(
          names: [IcalendarTextVariant('n' * 4097)],
        ),
        throwsArgumentError,
      );
    },
  );
  test(
    'duplicate languages reject without guessing equivalents or defaults',
    () {
      for (final languages in [
        <String?>['en', 'EN'],
        <String?>[null, null],
      ]) {
        expect(
          () => IcalendarCalendarTextMetadata(
            names: [
              for (final language in languages)
                IcalendarTextVariant('text', language: language),
            ],
          ),
          throwsArgumentError,
        );
      }
      expect(
        IcalendarCalendarTextMetadata(
          names: [
            const IcalendarTextVariant('default'),
            const IcalendarTextVariant('English', language: 'en'),
          ],
        ).names.length,
        2,
      );
    },
  );
  test('BCP47 syntactic forms include extensions, private use and grandfathered tags', () {
    for (final language in [
      'sv',
      'SV-se',
      'es-419',
      'zh-Hant-TW',
      'de-DE-u-co-phonebk',
      'sl-rozaj-biske-1994',
      'x-demo',
      'en-x-test',
      'i-klingon',
      'en-GB-oed',
      'en-abc-def-ghi-Latn-US-1996-u-ca-gregory-x-foo',
      'zzzz',
    ]) {
      validateCalendarLanguageTag(language);
    }
    for (final language in [
      '',
      'en_US',
      'en\n',
      'en-',
      'x',
      'en-u',
      'en-x',
      'en-1234-1234',
      'en-u-ca-u-nu',
      'a',
      'en-abcdefghi',
      'en--US',
      'en-12',
      'en-\u00e9',
    ]) {
      expect(
        () => validateCalendarLanguageTag(language),
        throwsArgumentError,
        reason: language,
      );
    }
  });
  test('variant count and aggregate byte budget reject without truncation', () {
    final max = IcalendarCalendarTextMetadata(
      descriptions: [
        for (final lang in ['en', 'sv', 'de', 'fr'])
          IcalendarTextVariant('a' * 16382, language: lang),
      ],
    );
    expect(max.descriptions.length, 4);
    expect(
      () => IcalendarCalendarTextMetadata(
        descriptions: [
          for (final lang in ['en', 'sv', 'de', 'fr'])
            IcalendarTextVariant('a' * 16383, language: lang),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => IcalendarCalendarTextMetadata(
        names: [
          for (var i = 0; i < 17; i++)
            IcalendarTextVariant('a', language: 'x-$i'),
        ],
      ),
      throwsArgumentError,
    );
  });
}
