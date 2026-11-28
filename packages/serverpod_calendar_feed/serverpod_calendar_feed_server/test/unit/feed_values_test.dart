@TestOn('vm')
library;

import 'package:serverpod/serverpod.dart' show UuidValue;
import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart';
import 'package:serverpod_calendar_feed_server/src/feed_values.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as cal;
import 'package:test/test.dart';

final id = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
CalendarFeedSettings value() =>
    CalendarFeedSettings(displayName: '  Synthetic feed  ', calendarIds: [id]);

void main() {
  test('normalizes labels/empty metadata and detaches caller-owned state', () {
    final input = value().copyWith(
      protocolMetadata: cal.CalendarProtocolMetadata(
        names: [cal.CalendarTextVariant(value: 'Original')],
        descriptions: [],
      ),
    );
    final stored = validateFeedSettings(input);
    input.calendarIds.clear();
    input.protocolMetadata!.names.single.value = 'Changed';
    expect(stored.displayName, 'Synthetic feed');
    expect(stored.calendarIds, [id]);
    expect(stored.protocolMetadata!.names.single.value, 'Original');
    expect(
      validateFeedSettings(
        value().copyWith(
          protocolMetadata: cal.CalendarProtocolMetadata(
            names: [],
            descriptions: [],
          ),
          supplementalMetadata: cal.CalendarSupplementalMetadata(
            categories: [],
            images: [],
          ),
        ),
      ).protocolMetadata,
      isNull,
    );
    expect(
      feedPublicationSettingsKey(stored.copyWith(displayName: 'Private label')),
      feedPublicationSettingsKey(stored),
    );
  });
  test('rejects invalid labels, duplicate/empty/oversized selections', () {
    for (final name in [
      '',
      '  ',
      '\nSynthetic',
      'Synthetic\r',
      'x' * 257,
      '\u0000',
    ]) {
      expect(
        () => validateFeedSettings(value().copyWith(displayName: name)),
        throwsArgumentError,
      );
    }
    for (final ids in [
      <UuidValue>[],
      [id, id],
      List.filled(17, id),
    ]) {
      expect(
        () => validateFeedSettings(value().copyWith(calendarIds: ids)),
        throwsArgumentError,
      );
    }
    expect(validateFeedCredentialLabel('  Subscriber  '), 'Subscriber');
    expect(validateFeedCredentialLabel('  '), isNull);
    expect(
      () => validateFeedCredentialLabel('\nSubscriber'),
      throwsArgumentError,
    );
  });
  test(
    'reuses bounded language/color/link/refresh profiles without fetching',
    () {
      expect(
        () => validateFeedSettings(
          value().copyWith(
            protocolMetadata: cal.CalendarProtocolMetadata(
              names: [],
              descriptions: [],
              color: '#112233',
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateFeedSettings(
          value().copyWith(
            protocolMetadata: cal.CalendarProtocolMetadata(
              names: [
                cal.CalendarTextVariant(value: 'One', language: 'en'),
                cal.CalendarTextVariant(value: 'Two', language: 'EN'),
              ],
              descriptions: [],
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateFeedSettings(
          value().copyWith(
            supplementalMetadata: cal.CalendarSupplementalMetadata(
              url: 'https://user:password@example.invalid/',
              categories: [],
              images: [],
            ),
          ),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateFeedSettings(
          value().copyWith(
            supplementalMetadata: cal.CalendarSupplementalMetadata(
              categories: [],
              images: [],
              refreshHint: cal.CalendarRefreshHint(days: 366),
            ),
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test('host options require HTTPS or explicit loopback and bounded retention/language', () {
    CalendarFeedOptions options(
      String uri, {
      bool local = false,
      int days = 30,
      String? language,
    }) => CalendarFeedOptions(
      publicBaseUri: Uri.parse(uri),
      allowInsecureLoopback: local,
      retention: Duration(days: days),
      contentLanguage: language,
      requiredGuarantee: cal.CalendarAuthorizationGuarantee.freshCheck,
    );
    expect(
      options('https://example.invalid/', language: 'en').contentLanguage,
      'en',
    );
    expect(
      options('http://localhost:18182/', local: true).allowInsecureLoopback,
      isTrue,
    );
    for (final uri in [
      'http://example.invalid/',
      'https://user:pass@example.invalid/',
      'https://example.invalid/?x=y',
      'https://example.invalid/no-trailing-slash',
    ]) {
      expect(() => options(uri, local: true), throwsArgumentError);
    }
    expect(
      () => options('https://example.invalid/', days: 0),
      throwsArgumentError,
    );
    expect(
      () =>
          options('https://example.invalid/', language: 'en\r\nInjected: yes'),
      throwsArgumentError,
    );
  });
}
