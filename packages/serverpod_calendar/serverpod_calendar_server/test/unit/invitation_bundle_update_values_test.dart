@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

import 'published_range_cancellation_values_test.dart' show raw;

void main() {
  IcalendarSchedulingMessage parse(String source) =>
      parseIcalendarSchedulingMessage(utf8.encode(source));
  CalendarEventImportBaseline baseline(String source) =>
      invitationRequestBundleProposal(parse(source)).importBaseline;
  EventStorageProposal update(
    String before,
    String after, {
    RecurrenceWorkBudget? work,
  }) => invitationRequestBundleUpdateProposal(
    accepted: baseline(before),
    protocolUid: 'published@example.invalid',
    incoming: parse(after),
    sharedWorkBudget: work,
  );
  final base = raw(own: [(2, 4, false, 3), (5, 6, true, 12)]);

  test('identical graph is a non-advancing comparison', () {
    final state = invitationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    expect(validateInvitationBundleAdvance(state, state), isFalse);
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
    final a = invitationBundleBaseline(
      baseline(base),
      protocolUid: 'published@example.invalid',
    );
    final b = invitationBundleBaseline(
      baseline(reordered),
      protocolUid: 'published@example.invalid',
    );
    expect(validateInvitationBundleAdvance(a, b), isFalse);
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
  test('matching claimed rosters do not permit a roster change against accepted state', () {
    expect(
      () => update(
        base,
        base.replaceAll(
          'mailto:alice@example.invalid',
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
        ('203003', 27, 28, 30),
        ('203010', 24, 25, 26),
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
}
