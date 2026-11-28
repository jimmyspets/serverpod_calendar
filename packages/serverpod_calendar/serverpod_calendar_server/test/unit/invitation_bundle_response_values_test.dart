@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' show raw, point;

void main() {
  CalendarInvitationBundleResponseTarget resolve(
    String body,
    CalendarEventTiming original, {
    RecurrenceWorkBudget? work,
  }) => resolveInvitationBundleResponseTarget(
    parseIcalendarSchedulingMessage(utf8.encode(body)),
    original,
    sharedWorkBudget: work,
  );
  for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
    final date = profile == 'date',
        zone = profile == 'date' || profile == 'utc' ? null : profile;
    final body = raw(
      date: date,
      zone: zone,
      own: [(2, 4, false, 3), (5, 6, true, 12)],
    );
    for (final (day, sequence, anchor, future) in [
      (1, 2, null, false),
      (2, 3, 2, false),
      (4, 2, null, false),
      (5, 12, 5, true),
      (7, 12, 5, true),
    ]) {
      test(
        '$profile original $day selects version $sequence independently of moved timing',
        () {
          final original = point(day, date: date, zone: zone);
          final target = resolve(body, original);
          expect(target.originalStart.toJson(), original.toJson());
          expect(target.componentVersion.sequence, sequence);
          expect(target.componentVersion.originalStart?.start.day, anchor);
          expect(target.componentVersion.isThisAndFuture, future);
          expect(target.cancelled, isFalse);
          expect(
            invitationBundleResponseTargetKey(original),
            startsWith('bundle-occurrence-v1:'),
          );
        },
      );
    }
  }
  for (final sequence in [null, 0]) {
    test(
      'master sequence $sequence preserves omission/zero below a later range',
      () {
        final target = resolve(
          raw(sequence: sequence, own: [(5, 6, true, 12)]),
          point(3),
        );
        expect(target.componentVersion.sequence, sequence);
      },
    );
    test('single sequence $sequence preserves omission/zero', () {
      final target = resolve(
        raw(own: [(2, 4, false, sequence), (5, 6, true, 12)]),
        point(2),
      );
      expect(target.componentVersion.sequence, sequence);
    });
  }
  test('exclusions and nonmembers do not become absent-component targets', () {
    final body = raw(
      own: [(5, 6, true, 12)],
      extra: ['EXDATE:20300103T090000Z'],
    );
    expect(() => resolve(body, point(3)), throwsArgumentError);
    expect(() => resolve(body, point(9)), throwsArgumentError);
  });
  test(
    'exact profile, alias, point and whole-second identities are required',
    () {
      final body = raw(zone: 'US/Eastern', own: [(5, 6, true, 12)]);
      for (final invalid in [
        point(3),
        point(3, date: true),
        point(3, zone: 'America/New_York'),
        point(
          3,
          zone: 'US/Eastern',
        ).copyWith(duration: CalendarEventDuration(seconds: 1)),
        point(3, zone: 'US/Eastern').copyWith(
          start: CalendarEventCivil(
            year: 2030,
            month: 1,
            day: 3,
            hour: 9,
            microsecond: 1,
          ),
        ),
      ]) {
        expect(() => resolve(body, invalid), throwsArgumentError);
      }
    },
  );
  test('RDATE and PERIOD originals can be selected; EXDATE still wins', () {
    final body = raw(
      own: [(5, 6, true, 12)],
      extra: ['RDATE;VALUE=PERIOD:20300110T090000Z/PT2H'],
    );
    expect(resolve(body, point(10)).componentVersion.sequence, 12);
    expect(
      () => resolve(
        body.replaceFirst('RDATE;', 'EXDATE:20300110T090000Z\r\nRDATE;'),
        point(10),
      ),
      throwsArgumentError,
    );
  });
  test(
    'unsupported child data is validated before selecting a master original',
    () {
      final body = raw(own: [(5, 6, true, 12)])
          .replaceFirst('SUMMARY:Own 5', 'X-UNSUPPORTED:secret');
      expect(
        () => resolve(body, point(1)),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
  test(
    'shared work exhaustion cannot prove membership or select a version',
    () {
      final body = raw(own: [(5, 6, true, 12)]);
      expect(
        () => resolve(body, point(1), work: RecurrenceWorkBudget(maxWork: 1)),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  test('an earlier explicit inclusion keeps its identity before DTSTART', () {
    final body = raw(
      startDay: 3,
      own: [(5, 6, true, 12)],
      extra: ['RDATE:20300101T090000Z'],
    );
    expect(resolve(body, point(1)).componentVersion.sequence, 2);
  });
  test('generated gap originals are absent while explicit civil identities stay exact', () {
    final body = raw(
      zone: 'Europe/Stockholm',
      prefix: '203003',
      startDay: 30,
      time: '023000',
      own: [(30, 30, false, 3)],
    );
    expect(
      () => resolve(
        body,
        point(31, zone: 'Europe/Stockholm', month: 3, hour: 2, minute: 30),
      ),
      throwsArgumentError,
    );
    expect(
      resolve(
        body,
        point(1, zone: 'Europe/Stockholm', month: 4, hour: 2, minute: 30),
      ).componentVersion.sequence,
      2,
    );
  });
  test(
    'fold civil original is one member and is not substituted with a UTC point',
    () {
      final body = raw(
        zone: 'Europe/Stockholm',
        prefix: '203010',
        startDay: 26,
        time: '023000',
        own: [(26, 26, false, 3)],
      );
      expect(
        resolve(
          body,
          point(27, zone: 'Europe/Stockholm', month: 10, hour: 2, minute: 30),
        ).componentVersion.sequence,
        2,
      );
      expect(
        () => resolve(body, point(27, month: 10, hour: 0, minute: 30)),
        throwsArgumentError,
      );
    },
  );
}
