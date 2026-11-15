@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

import 'published_range_cancellation_values_test.dart' as fixtures;

String raw({
  bool date = false,
  String? zone,
  List<fixtures.Own> own = const [],
  List<String> extra = const [],
  int? sequence = 2,
  String? rule = 'FREQ=DAILY;COUNT=8',
  String prefix = '203001',
  String time = '090000',
  int startDay = 1,
  bool ownClaims = true,
}) => fixtures
    .raw(
      date: date,
      zone: zone,
      own: own,
      extra: extra,
      sequence: sequence,
      rule: rule,
      prefix: prefix,
      time: time,
      startDay: startDay,
      ownClaims: ownClaims,
    )
    .split('\r\n')
    .where((line) => !line.startsWith('ATTENDEE'))
    .map((line) => line == 'METHOD:REQUEST' ? 'METHOD:PUBLISH' : line)
    .join('\r\n');

void main() {
  IcalendarSchedulingMessage parse(String source) =>
      parseIcalendarSchedulingMessage(utf8.encode(source));
  CalendarEventImportBaseline baseline(String source) =>
      informationPublicationBundleProposal(parse(source)).importBaseline;
  EventStorageProposal update(
    String before,
    String after, {
    RecurrenceWorkBudget? work,
  }) => informationPublicationBundleUpdateProposal(
    accepted: baseline(before),
    protocolUid: 'published@example.invalid',
    incoming: parse(after),
    sharedWorkBudget: work,
  );
  final base = raw(own: [(2, 4, false, 3), (5, 6, true, 12)]);

  test('identical graph is a non-advancing comparison', () {
    final state = informationPublicationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    expect(validateInformationPublicationBundleAdvance(state, state), isFalse);
    expect(() => state.versions.clear(), throwsUnsupportedError);
  });
  for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
    test('$profile child-only advancement preserves the master version', () {
      final before = raw(
        date: profile == 'date',
        zone: profile == 'date' || profile == 'utc' ? null : profile,
        own: [(2, 4, false, 3), (5, 6, true, 12)],
      );
      final next = update(
        before,
        before
            .replaceFirst('SEQUENCE:3', 'SEQUENCE:4')
            .replaceFirst('SUMMARY:Own 2', 'SUMMARY:Changed child'),
      );
      expect(next.protocolState.version.sequence, 2);
      expect(next.protocolState.overrides.first.version.sequence, 4);
    });
  }
  test(
    'master advancement does not reversion unchanged inherited child fields',
    () {
      final next = update(
        base,
        base
            .replaceFirst('SEQUENCE:2', 'SEQUENCE:3')
            .replaceFirst(
              'DESCRIPTION:Private retained text',
              'DESCRIPTION:Changed master',
            ),
      );
      expect(next.protocolState.overrides.map((v) => v.version.sequence), [
        3,
        12,
      ]);
    },
  );
  test('higher sequence preserves a backwards source clock', () {
    final next = update(
      base,
      base
          .replaceFirst('SEQUENCE:2', 'SEQUENCE:3')
          .replaceFirst('DTSTAMP:20260101T000000Z', 'DTSTAMP:20250101T000000Z'),
    );
    expect(next.protocolState.version.stamp, DateTime.utc(2025));
  });
  for (final after in [
    base.replaceFirst('SEQUENCE:3', 'SEQUENCE:1'),
    base.replaceFirst('SUMMARY:Own 2', 'SUMMARY:Changed without advancement'),
    base.replaceFirst('DTSTAMP:20260101T000000Z', 'DTSTAMP:20250101T000000Z'),
    raw(own: [(2, 4, false, 4)]),
    raw(own: [(2, 4, false, 4), (5, 6, false, 13)]),
  ]) {
    test(
      'regression, tied conflict or missing/range-converted component rejects',
      () {
        expect(() => update(base, after), throwsArgumentError);
      },
    );
  }
  test('new explicit components obey the prior effective range floor', () {
    expect(
      () => update(
        base,
        raw(own: [(2, 4, false, 3), (5, 6, true, 12), (7, 8, false, 12)]),
      ),
      throwsArgumentError,
    );
    final next = update(
      base,
      raw(own: [(2, 4, false, 3), (5, 6, true, 12), (7, 8, false, 13)]),
    );
    expect(next.edits!.singles.length, 2);
  });
  test('new recurrence originals use the accepted master floor', () {
    expect(
      () => update(
        base,
        raw(
          rule: 'FREQ=DAILY;COUNT=10',
          sequence: 3,
          own: [(2, 4, false, 3), (5, 6, true, 12), (9, 10, false, 2)],
        ),
      ),
      throwsArgumentError,
    );
    final next = update(
      base,
      raw(
        rule: 'FREQ=DAILY;COUNT=10',
        sequence: 3,
        own: [(2, 4, false, 3), (5, 6, true, 12), (9, 10, false, 3)],
      ),
    );
    expect(next.edits!.singles.length, 2);
  });
  test('reordered components compare by identity, not source list order', () {
    final reordered = raw(own: [(5, 6, true, 12), (2, 4, false, 3)]);
    final a = informationPublicationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    final b = informationPublicationBundleBaseline(
      baseline(reordered),
      protocolUid: 'published@example.invalid',
    );
    expect(validateInformationPublicationBundleAdvance(a, b), isFalse);
  });
  test('omitted and explicit zero remain distinct at an unchanged tuple', () {
    final before = raw(own: [(2, 4, false, null), (5, 6, true, 12)]);
    expect(
      () => update(before, raw(own: [(2, 4, false, 0), (5, 6, true, 12)])),
      throwsArgumentError,
    );
    final after = raw(own: [(2, 4, false, 0), (5, 6, true, 12)]).replaceFirst(
      'SUMMARY:Own 2',
      'LAST-MODIFIED:20260101T000000Z\r\nSUMMARY:Own 2',
    );
    expect(() => update(before, after), throwsArgumentError);
  });
  test('created/modified source changes require component advancement', () {
    expect(
      () => update(
        base,
        base.replaceFirst(
          'SUMMARY:Own 2',
          'CREATED:20250101T000000Z\r\nSUMMARY:Own 2',
        ),
      ),
      throwsArgumentError,
    );
  });
  test('matching source claims do not permit an organizer change against accepted state', () {
    expect(
      () => update(
        base,
        base.replaceAll(
          'mailto:organizer@example.invalid',
          'mailto:other@example.invalid',
        ),
      ),
      throwsArgumentError,
    );
  });
  test(
    'gap and fold identities remain civil originals across child updates',
    () {
      for (final (prefix, start, original, moved) in [
        ('203003', 29, 30, 31),
        ('203010', 25, 27, 26),
      ]) {
        final before = raw(
          zone: 'Europe/Stockholm',
          prefix: prefix,
          startDay: start,
          time: '023000',
          rule: 'FREQ=DAILY;COUNT=3',
          own: [(original, moved, false, 3)],
        );
        final next = update(
          before,
          before.replaceFirst('SEQUENCE:3', 'SEQUENCE:4'),
        );
        expect(next.edits!.singles.single.originalStart.start.day, original);
      }
    },
  );
  test('shared exhaustion rejects instead of proving prior absence', () {
    expect(
      () => update(base, base, work: RecurrenceWorkBudget(maxWork: 1)),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  IcalendarSchedulingMessage cancellation(
    int sequence, {
    bool attendee = false,
  }) => parse(
    [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic publication//EN',
      'METHOD:CANCEL',
      'BEGIN:VEVENT',
      'UID:published@example.invalid',
      'DTSTAMP:20260101T000000Z',
      'SEQUENCE:$sequence',
      'STATUS:CANCELLED',
      'ORGANIZER:mailto:organizer@example.invalid',
      if (attendee) 'ATTENDEE:mailto:alice@example.invalid',
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n'),
  );
  test('whole cancellation crosses every independent component floor', () {
    final state = informationPublicationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    expect(
      () => validateInformationPublicationBundleCancellation(
        accepted: state,
        incoming: cancellation(12),
      ),
      throwsArgumentError,
    );
    final version = validateInformationPublicationBundleCancellation(
      accepted: state,
      incoming: cancellation(13),
    );
    expect(version.sequence, 13);
    expect(version.originalStart, isNull);
    expect(
      () => validateInformationPublicationBundleCancellation(
        accepted: state,
        incoming: cancellation(14, attendee: true),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateInformationPublicationBundleCancellation(
        accepted: state,
        incoming: cancellation(13),
        previousCancellation: version,
      ),
      throwsArgumentError,
    );
  });
  test('whole cancellation includes a pending child version and reopening stays complete', () {
    final accepted = informationPublicationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    final pending = informationPublicationBundleBaseline(
      baseline(base.replaceFirst('SEQUENCE:3', 'SEQUENCE:40')),
      protocolUid: 'published@example.invalid',
    );
    expect(
      () => validateInformationPublicationBundleCancellation(
        accepted: accepted,
        pending: pending,
        incoming: cancellation(40),
      ),
      throwsArgumentError,
    );
    final version = validateInformationPublicationBundleCancellation(
      accepted: accepted,
      pending: pending,
      incoming: cancellation(41),
    );
    final reopened = informationPublicationBundleBaseline(
      baseline(base.replaceFirst('SEQUENCE:2', 'SEQUENCE:42')),
      protocolUid: 'published@example.invalid',
    );
    expect(
      validateInformationPublicationBundleReopening(
        accepted: accepted,
        incoming: reopened,
        cancellation: version,
      ),
      isTrue,
    );
    expect(
      () => validateInformationPublicationBundleReopening(
        accepted: accepted,
        incoming: accepted,
        cancellation: version,
      ),
      throwsArgumentError,
    );
  });
  test('a generated nonexistent original is rejected rather than invented', () {
    expect(
      () => baseline(
        raw(
          zone: 'Europe/Stockholm',
          prefix: '203003',
          startDay: 29,
          time: '023000',
          rule: 'FREQ=DAILY;COUNT=3',
          own: [(31, 30, false, 3)],
        ),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
