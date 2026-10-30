import 'dart:convert';

import 'package:calendar_example_server/src/invitation_response_mime.dart';
import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:calendar_example_server/src/scheduling_mime.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

String reply({
  String choice = 'ACCEPTED',
  int? sequence,
  List<String> extra = const [],
  String attendee = 'mailto:attendee@example.invalid',
  String organizer = 'mailto:organizer@example.invalid',
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:Synthetic',
  'METHOD:REPLY',
  'BEGIN:VEVENT',
  'UID:synthetic-節',
  'DTSTAMP:20261030T120000Z',
  if (sequence != null) 'SEQUENCE:$sequence',
  'ORGANIZER:$organizer',
  'ATTENDEE;PARTSTAT=$choice:$attendee',
  ...extra,
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');
CalendarInvitationResponseSubmission input({
  String? payload,
  String attendee = 'mailto:attendee@example.invalid',
  String organizer = 'mailto:organizer@example.invalid',
}) => CalendarInvitationResponseSubmission(
  deliveryKey: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
  scopeKey: 'synthetic',
  attendeeAddress: attendee,
  organizer: CalendarSchedulingRoute(organizer, 'verified-route'),
  payload: payload ?? reply(),
);
Matcher failure(SyntheticSchedulingMimeError kind) => throwsA(
  isA<SyntheticSchedulingMimeException>().having((e) => e.kind, 'kind', kind),
);
void main() {
  for (final choice in ['ACCEPTED', 'TENTATIVE', 'DECLINED']) {
    test(
      '$choice has attendee sender, organizer destination and exact retained bytes',
      () {
        final submission = input(payload: reply(choice: choice)),
            mime = composeSyntheticInvitationResponseMime(
              submission,
              requireProtection: false,
            );
        expect(mime, contains('From: attendee@example.invalid'));
        expect(mime, contains('To: organizer@example.invalid'));
        expect(mime, contains('Subject: Calendar response'));
        expect(
          mime,
          contains(
            '<calendar-reply-${submission.deliveryKey}@example.invalid>',
          ),
        );
        final decoded = parseHostImipMime(
          ascii.encode(mime),
          outerProtection: ImipProtection.none,
        );
        expect(decoded.source.body, utf8.encode(submission.payload));
        expect(decoded.eventMessage!.events.single.sequence, isNull);
        expect(
          decoded
              .eventMessage!
              .events
              .single
              .participants
              .attendees
              .single
              .participationStatus,
          choice,
        );
        expect(
          composeSyntheticInvitationResponseMime(
            submission,
            requireProtection: false,
          ),
          mime,
        );
      },
    );
  }
  test('explicit SEQUENCE zero is preserved, never allocated by sender', () {
    final parsed = parseHostImipMime(
      ascii.encode(
        composeSyntheticInvitationResponseMime(
          input(payload: reply(sequence: 0)),
          requireProtection: false,
        ),
      ),
      outerProtection: ImipProtection.none,
    );
    expect(parsed.eventMessage!.events.single.sequence, 0);
  });
  test('required protection is rejected without an unprotected fallback', () {
    expect(
      () => composeSyntheticInvitationResponseMime(
        input(),
        requireProtection: true,
      ),
      failure(SyntheticSchedulingMimeError.protection),
    );
  });
  test('mismatched sender or organizer route cannot manufacture authority', () {
    for (final value in [
      input(attendee: 'mailto:other@example.invalid'),
      input(organizer: 'mailto:other@example.invalid'),
    ]) {
      expect(
        () => composeSyntheticInvitationResponseMime(
          value,
          requireProtection: false,
        ),
        failure(SyntheticSchedulingMimeError.profile),
      );
    }
  });
  test('production domains and header-injection addresses reject', () {
    for (final value in [
      'mailto:person@example.com',
      'mailto:person@example.invalid\r\nBcc: hidden@example.invalid',
    ]) {
      expect(
        () => composeSyntheticInvitationResponseMime(
          input(attendee: value),
          requireProtection: false,
        ),
        failure(SyntheticSchedulingMimeError.profile),
      );
    }
  });
  test('optional source content and participant parameters never enter the minimal reply profile', () {
    for (final value in [
      reply(extra: ['SUMMARY:PRIVATE']),
      reply(extra: ['COMMENT:PRIVATE']),
      reply().replaceFirst('PARTSTAT=ACCEPTED', 'PARTSTAT=ACCEPTED;CN=PRIVATE'),
    ]) {
      expect(
        () => composeSyntheticInvitationResponseMime(
          input(payload: value),
          requireProtection: false,
        ),
        failure(SyntheticSchedulingMimeError.profile),
      );
    }
  });
  test('wrong methods and missing current participation reject', () {
    for (final value in [
      reply().replaceFirst('METHOD:REPLY', 'METHOD:REQUEST'),
      reply(choice: 'NEEDS-ACTION'),
    ]) {
      expect(
        () => composeSyntheticInvitationResponseMime(
          input(payload: value),
          requireProtection: false,
        ),
        failure(SyntheticSchedulingMimeError.profile),
      );
    }
  });
  test('payload budgets and diagnostics are bounded and non-echo', () {
    expect(
      () => composeSyntheticInvitationResponseMime(
        input(payload: 'PRIVATE' * 6000),
        requireProtection: false,
      ),
      failure(SyntheticSchedulingMimeError.limitExceeded),
    );
    try {
      composeSyntheticInvitationResponseMime(
        input(payload: 'PRIVATE'),
        requireProtection: false,
      );
      fail('Expected rejection');
    } on SyntheticSchedulingMimeException catch (e) {
      expect(e.toString(), isNot(contains('PRIVATE')));
    }
  });
  test('response defaults reject values beyond approved profile caps', () {
    for (final create in [
      () => CalendarInvitationResponseOptions(maxResponsesPerState: 33),
      () => CalendarInvitationResponseOptions(maxStatesPerRecipient: 129),
      () => CalendarInvitationResponseOptions(maxPayloadBytes: 32769),
      () =>
          CalendarInvitationResponseOptions(lease: const Duration(seconds: 1)),
      () => CalendarInvitationResponseOptions(maxAttempts: 33),
      () => CalendarInvitationResponseOptions(retention: Duration.zero),
    ]) {
      expect(create, throwsArgumentError);
    }
  });
}
