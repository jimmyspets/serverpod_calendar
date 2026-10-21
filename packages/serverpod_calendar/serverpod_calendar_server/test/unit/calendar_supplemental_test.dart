import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

void main() {
  test('HTTP URI profile preserves valid spelling without normalization or fetching', () {
    const url = 'HTTP://EXAMPLE.INVALID:80/a%2Fb?x=1#part';
    expect(IcalendarSupplementalMetadata(url: url).url, url);
    for (final uri in [
      'https://example.invalid',
      'http://localhost:8080/a',
      'http://[::1]:8080/image.png',
      'https://example.invalid/?a=%23#x',
    ]) {
      validateCalendarHttpUri(uri);
    }
  });
  test(
    'URI rejects user information, malformed escapes and out-of-profile forms',
    () {
      for (final uri in [
        '',
        '/relative',
        '//example.invalid/a',
        'data:image/png;base64,a',
        'file:///tmp/a',
        'https://user:pass@example.invalid/a',
        'http://@example.invalid',
        'https://example.invalid/a b',
        'https://example.invalid/%zz',
        'https://example.invalid/a\n',
        'http://example.invalid:99999',
        'http://example.invalid:0',
        'http:///a',
        'https://example.invalid/a#b#c',
        'https://example.invalid/\u00e9',
        'http://example.invalid/[]',
      ]) {
        expect(
          () => validateCalendarHttpUri(uri),
          throwsArgumentError,
          reason: uri,
        );
      }
    },
  );
  test(
    'categories preserve exact text and match language tags case-insensitively',
    () {
      final category = IcalendarCategory(' Work ', language: 'SV');
      expect(category.matches(IcalendarCategory(' Work ')), isTrue);
      expect(
        category.matches(IcalendarCategory(' Work ', language: 'sv')),
        isTrue,
      );
      expect(
        category.matches(IcalendarCategory(' Work ', language: 'en')),
        isFalse,
      );
      expect(category.matches(IcalendarCategory('Work')), isFalse);
      expect(category.matches(IcalendarCategory(' work ')), isFalse);
      for (final value in ['', '  ', 'a\n', 'a\u2028', 'a' * 257]) {
        expect(() => IcalendarCategory(value), throwsArgumentError);
      }
      expect(
        () => IcalendarSupplementalMetadata(
          categories: [
            category,
            IcalendarCategory(' Work ', language: 'sv'),
          ],
        ),
        throwsArgumentError,
      );
    },
  );
  test('category and image collections are bounded and immutable', () {
    final source = [IcalendarCategory('A')];
    final value = IcalendarSupplementalMetadata(categories: source);
    source.clear();
    expect(value.categories.single.value, 'A');
    expect(() => value.categories.clear(), throwsUnsupportedError);
    expect(
      () => IcalendarSupplementalMetadata(
        categories: [for (var i = 0; i < 65; i++) IcalendarCategory('$i')],
      ),
      throwsArgumentError,
    );
    expect(
      () => IcalendarSupplementalMetadata(
        images: [
          for (var i = 0; i < 17; i++)
            IcalendarImageLink('https://example.invalid/$i'),
        ],
      ),
      throwsArgumentError,
    );
  });
  test('DISPLAY preserves absent and multiple/unknown tokens without rendering fallback', () {
    final omitted = IcalendarImageLink('https://example.invalid/a.png');
    expect(omitted.display, isNull);
    expect(omitted.effectiveDisplay, ['BADGE']);
    expect(omitted.hasOnlyKnownDisplayHints, isTrue);
    final known = IcalendarImageLink(
      'https://example.invalid/a.png',
      display: ['badge', 'THUMBNAIL'],
      mediaType: 'Image/PNG',
    );
    expect(known.display, ['badge', 'THUMBNAIL']);
    expect(known.hasOnlyKnownDisplayHints, isTrue);
    final unknown = IcalendarImageLink(
      'https://example.invalid/a.png',
      display: ['BADGE', 'X-PRIVATE'],
    );
    expect(unknown.hasOnlyKnownDisplayHints, isFalse);
    expect(unknown.display!.last, 'X-PRIVATE');
    expect(() => unknown.display!.clear(), throwsUnsupportedError);
    for (final display in [
      <String>[],
      ['BADGE', 'badge'],
      ['bad token'],
    ]) {
      expect(
        () => IcalendarImageLink(
          'https://example.invalid/a.png',
          display: display,
        ),
        throwsArgumentError,
      );
    }
    for (final type in ['text/html', 'image/png;param=x', 'image/png\n']) {
      expect(
        () => IcalendarImageLink(
          'https://example.invalid/a.png',
          mediaType: type,
        ),
        throwsArgumentError,
      );
    }
  });
  test(
    'refresh units remain distinct with positive, whole-unit 365-day bound',
    () {
      final day = IcalendarRefreshHint(days: 1),
          clock = IcalendarRefreshHint(hours: 24);
      expect(day.duration.days, 1);
      expect(day.duration.hours, 0);
      expect(clock.duration.days, 0);
      expect(clock.duration.hours, 24);
      expect(IcalendarRefreshHint(weeks: 52).duration.weeks, 52);
      expect(IcalendarRefreshHint(days: 365).duration.days, 365);
      expect(() => IcalendarRefreshHint(), throwsArgumentError);
      expect(() => IcalendarRefreshHint(seconds: -1), throwsArgumentError);
      expect(
        () => IcalendarRefreshHint(weeks: 1, seconds: 1),
        throwsArgumentError,
      );
      expect(() => IcalendarRefreshHint(weeks: 53), throwsArgumentError);
      expect(
        () => IcalendarRefreshHint(seconds: 31536001),
        throwsArgumentError,
      );
      expect(
        () => IcalendarRefreshHint(days: 9007199254740991),
        throwsArgumentError,
      );
    },
  );
  test('aggregate decoded metadata byte cap rejects without truncation', () {
    const prefix = 'https://example.invalid/';
    final image = IcalendarImageLink(prefix + 'a' * (4096 - prefix.length));
    expect(
      IcalendarSupplementalMetadata(images: List.filled(16, image))
          .images
          .length,
      16,
    );
    expect(
      () => IcalendarSupplementalMetadata(
        url: prefix,
        images: List.filled(16, image),
      ),
      throwsArgumentError,
    );
  });
}
