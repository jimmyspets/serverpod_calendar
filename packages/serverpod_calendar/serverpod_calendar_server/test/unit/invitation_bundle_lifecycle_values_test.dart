@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' show raw;

void main() {
  IcalendarSchedulingMessage parse(String input) =>
      parseIcalendarSchedulingMessage(utf8.encode(input));
  CalendarInvitationBundleState state(String input) => invitationBundleBaseline(
    invitationRequestBundleProposal(parse(input)).importBaseline,
    protocolUid: 'published@example.invalid',
  );
  final request = raw(own: [(2, 4, false, 3), (5, 6, true, 12)]);
  String cancel({
    int sequence = 13,
    String extra = '',
    String recipient = 'mailto:alice@example.invalid',
    String stamp = '20260101T000000Z',
  }) => [
    'BEGIN:VCALENDAR',
    'VERSION:2.0',
    'PRODID:-//Synthetic//EN',
    'METHOD:CANCEL',
    'BEGIN:VEVENT',
    'UID:published@example.invalid',
    'DTSTAMP:$stamp',
    'SEQUENCE:$sequence',
    'ORGANIZER:mailto:organizer@example.invalid',
    'ATTENDEE:$recipient',
    'STATUS:CANCELLED',
    if (extra.isNotEmpty) extra,
    'END:VEVENT',
    'END:VCALENDAR',
    '',
  ].join('\r\n');
  CalendarInvitationBundleComponentVersion check(
    String input, {
    CalendarInvitationBundleState? pending,
    CalendarInvitationBundleComponentVersion? previous,
    RecurrenceWorkBudget? work,
  }) => validateInvitationBundleCancellation(
    accepted: state(request),
    incoming: parse(input),
    recipientAddress: 'mailto:alice@example.invalid',
    pending: pending,
    previousCancellation: previous,
    sharedWorkBudget: work,
  );

  test('whole cancellation crosses every component independently', () {
    final value = check(cancel());
    expect(value.sequence, 13);
    expect(value.originalStart, isNull);
    expect(value.isThisAndFuture, isFalse);
  });
  for (final sequence in [0, 2, 3, 11, 12]) {
    test(
      'sequence $sequence cannot suppress newer retained components',
      () => expect(
        () => check(cancel(sequence: sequence, stamp: '20270101T000000Z')),
        throwsArgumentError,
      ),
    );
  }
  test(
    'higher sequence permits corrected source clock',
    () => expect(
      check(cancel(stamp: '20250101T000000Z')).stamp,
      DateTime.utc(2025),
    ),
  );
  test(
    'pending full vector is an additional floor',
    () => expect(
      () => check(
        cancel(),
        pending: state(request.replaceFirst('SEQUENCE:12', 'SEQUENCE:14')),
      ),
      throwsArgumentError,
    ),
  );
  test(
    'previous cancellation is an independent strict floor',
    () => expect(
      () => check(
        cancel(),
        previous: CalendarInvitationBundleComponentVersion(
          sequence: 13,
          stamp: DateTime.utc(2025),
        ),
      ),
      throwsArgumentError,
    ),
  );
  for (final extra in [
    'SUMMARY:Unapplied text',
    'CREATED:20250101T000000Z',
    'DTSTART:20260101T100000Z',
    'RECURRENCE-ID:20260102T100000Z',
    'RRULE:FREQ=DAILY',
  ]) {
    test(
      'minimal profile rejects $extra',
      () => expect(() => check(cancel(extra: extra)), throwsA(anything)),
    );
  }
  test(
    'foreign recipient does not establish trusted recipient membership',
    () => expect(
      () => check(cancel(recipient: 'mailto:foreign@example.invalid')),
      throwsArgumentError,
    ),
  );
  test(
    'source omission cannot become sequence zero',
    () => expect(
      () => check(cancel().replaceFirst('SEQUENCE:13\r\n', '')),
      throwsA(anything),
    ),
  );
  test(
    'delegated source participants stay unsupported',
    () => expect(
      () => check(
        cancel().replaceFirst(
          'ATTENDEE:',
          'ATTENDEE;SENT-BY="mailto:agent@example.invalid":',
        ),
      ),
      throwsArgumentError,
    ),
  );
  test(
    'shared exhausted work never proves a cancellation floor',
    () => expect(
      () => check(cancel(), work: RecurrenceWorkBudget(maxWork: 1)),
      throwsA(isA<RecurrenceLimitException>()),
    ),
  );
  test('reopening keeps unchanged children and crosses cancellation', () {
    final next = state(request.replaceFirst('SEQUENCE:2', 'SEQUENCE:14'));
    expect(
      validateInvitationBundleReopening(
        accepted: state(request),
        incoming: next,
        cancellation: CalendarInvitationBundleComponentVersion(
          sequence: 13,
          stamp: DateTime.utc(2026),
        ),
      ),
      isTrue,
    );
    expect(
      next.versions
          .where((v) => v.originalStart != null)
          .map((v) => v.sequence),
      [3, 12],
    );
  });
  test(
    'child-only update never reopens cancelled master',
    () => expect(
      () => validateInvitationBundleReopening(
        accepted: state(request),
        incoming: state(request.replaceFirst('SEQUENCE:3', 'SEQUENCE:14')),
        cancellation: CalendarInvitationBundleComponentVersion(
          sequence: 13,
          stamp: DateTime.utc(2026),
        ),
      ),
      throwsArgumentError,
    ),
  );
}
