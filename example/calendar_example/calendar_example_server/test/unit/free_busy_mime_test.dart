import 'package:serverpod/serverpod.dart' show UuidValue;

import 'dart:convert';

import 'package:calendar_example_server/src/free_busy_mime.dart';
import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

void main() {
  final window = UtcWindow(
    start: DateTime.utc(2026, 11, 6),
    end: DateTime.utc(2026, 11, 7),
  );
  CalendarSchedulingSubmission submission(IcalendarFreeBusyMethod method) {
    const local = 'mailto:busy-calendar@example.invalid';
    const remote = 'mailto:respondent@example.invalid';
    final message = buildCalendarFreeBusyExchange(
      method: method,
      uid: 'synthetic-source',
      stamp: DateTime.utc(2026, 11, 5),
      window: window,
      organizer: method == IcalendarFreeBusyMethod.reply ? remote : local,
      attendees: method == IcalendarFreeBusyMethod.publish
          ? []
          : [method == IcalendarFreeBusyMethod.reply ? local : remote],
      partition: method == IcalendarFreeBusyMethod.request
          ? null
          : [
              AvailabilityInterval(
                window: window,
                kind: AvailabilityKind.tentative,
              ),
            ],
    );
    return CalendarSchedulingSubmission(
      deliveryKey: UuidValue.fromString('11111111-1111-4111-8111-111111111111'),
      publicationId: UuidValue.fromString(
        '22222222-2222-4222-8222-222222222222',
      ),
      scopeKey: 'synthetic',
      organizerAddress: local,
      recipient: const CalendarSchedulingRoute(remote, remote),
      payload: utf8.decode(calendarFreeBusyExchangeBytes(message)),
    );
  }

  for (final method in IcalendarFreeBusyMethod.values) {
    test(
      '${method.name} MIME is deterministic and preserves exact authorized bytes',
      () {
        final input = submission(method);
        final mime = composeSyntheticFreeBusyMime(input);
        expect(composeSyntheticFreeBusyMime(input), mime);
        final part = parseHostImipMime(
          ascii.encode(mime),
          outerProtection: ImipProtection.none,
        );
        expect(part.freeBusyMessage!.method, method);
        expect(utf8.decode(part.source.body), input.payload);
        expect(mime, contains('VFREEBUSY'));
        expect(mime, contains('base64'));
        expect(
          RegExp(
            r'^From:.*busy-calendar@example.invalid',
            multiLine: true,
          ).hasMatch(mime),
          isTrue,
        );
        expect(
          RegExp(
            r'^To:.*respondent@example.invalid',
            multiLine: true,
          ).hasMatch(mime),
          isTrue,
        );
      },
    );
  }
  test('wrong reply sender and external routes reject before composition', () {
    final valid = submission(IcalendarFreeBusyMethod.reply);
    for (final value in [
      'mailto:respondent@example.invalid',
      'mailto:other@external.invalid',
    ]) {
      expect(
        () => composeSyntheticFreeBusyMime(
          CalendarSchedulingSubmission(
            deliveryKey: valid.deliveryKey,
            publicationId: valid.publicationId,
            scopeKey: valid.scopeKey,
            organizerAddress: value,
            recipient: valid.recipient,
            payload: valid.payload,
          ),
        ),
        throwsA(isA<HostImipMimeException>()),
      );
    }
  });
  test('request MIME cannot silently replace the approved recipient', () {
    final valid = submission(IcalendarFreeBusyMethod.request);
    expect(
      () => composeSyntheticFreeBusyMime(
        CalendarSchedulingSubmission(
          deliveryKey: valid.deliveryKey,
          publicationId: valid.publicationId,
          scopeKey: valid.scopeKey,
          organizerAddress: valid.organizerAddress,
          recipient: const CalendarSchedulingRoute(
            'mailto:other@example.invalid',
            'synthetic',
          ),
          payload: valid.payload,
        ),
      ),
      throwsA(isA<HostImipMimeException>()),
    );
  });
}
