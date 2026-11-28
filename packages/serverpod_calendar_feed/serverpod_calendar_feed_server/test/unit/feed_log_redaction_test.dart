@TestOn('vm')
library;

import 'dart:async';

import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart';
import 'package:test/test.dart';

void main() {
  test(
    'suppresses complete framework messages with raw or encoded bearer paths',
    () {
      final secret = 'syntheticSecret${'x' * 28}';
      final path = '/calendar-feed/$secret.ics';
      for (final message in [
        'Method.get $path\nUnhandled error\nHttpException: uri=$path',
        'https://example.invalid$path?ignored=value',
        'uri=${path.replaceAll('/', r'\/')}',
        'uri=%2f%63alendar-feed%2f$secret.ics',
        'uri=${Uri.encodeComponent(Uri.encodeComponent(path))}',
        'uri=${path.toUpperCase()}',
      ]) {
        final result = redactCalendarFeedLogLine(message);
        expect(result, '[calendar feed request redacted]');
        expect(result, isNot(contains(secret)));
      }
      expect(
        redactCalendarFeedLogLine('Ordinary application diagnostic'),
        'Ordinary application diagnostic',
      );
    },
  );
  test('whole-startup zone catches asynchronous framework prints', () async {
    final messages = <String>[];
    await runZoned(
      () => runWithCalendarFeedLogRedaction(() async {
        expect(calendarFeedLogRedactionEnabled('/calendar-feed'), isTrue);
        await Future<void>.delayed(Duration.zero);
        // ignore: avoid_print
        print(
          'Method.get /calendar-feed/synthetic-secret.ics\nSocket exception',
        );
        // ignore: avoid_print
        print('Token-free diagnostic');
      }),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => messages.add(line),
      ),
    );
    expect(messages, [
      '[calendar feed request redacted]',
      'Token-free diagnostic',
    ]);
    expect(calendarFeedLogRedactionEnabled('/calendar-feed'), isFalse);
  });
  test('mounts are explicit, bounded and can be nested', () {
    runWithCalendarFeedLogRedaction(() {
      expect(
        calendarFeedLogRedactionEnabled('/subscriptions/calendar'),
        isTrue,
      );
      expect(calendarFeedLogRedactionEnabled('/calendar-feed'), isFalse);
    }, mountPaths: ['/subscriptions/calendar']);
    expect(
      () => runWithCalendarFeedLogRedaction(() {}, mountPaths: []),
      throwsArgumentError,
    );
    expect(
      () => runWithCalendarFeedLogRedaction(() {}, mountPaths: ['/unsafe/**']),
      throwsArgumentError,
    );
  });
}
