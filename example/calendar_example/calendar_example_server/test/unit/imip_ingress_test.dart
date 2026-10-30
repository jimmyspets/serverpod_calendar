import 'dart:convert';

import 'package:calendar_example_server/src/imip_ingress.dart';
import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:calendar_example_server/src/synthetic_imip_input.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'scheduling_mime_test.dart' as f;
import 'imip_mime_input_test.dart' as r;

final class _Session implements Session {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError("Unexpected native access");
  int reads = 0;
  @override
  Serverpod get serverpod {
    reads++;
    throw StateError('Native entry reached');
  }
}

String reply({String comment = '', String producer = 'Synthetic'}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:$producer',
  'METHOD:REPLY',
  'BEGIN:VEVENT',
  'UID:fixture',
  'DTSTAMP:20260101T000000Z',
  'ORGANIZER:mailto:organizer@example.invalid',
  'ATTENDEE;PARTSTAT=ACCEPTED:mailto:guest@example.invalid',
  if (comment.isNotEmpty) ...List.filled(16, 'COMMENT:$comment'),
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');

Future<Object> _invitation(
  _Session session,
  List<int> raw, {
  ImipProtection protection = ImipProtection.none,
}) => receiveHostImipInvitation(
  session,
  raw: raw,
  outerProtection: protection,
  namespace: 'fixture',
  deliveryKey: 'stable',
  originReference: 'unverified',
);
Future<Object> _response(
  _Session session,
  List<int> raw, {
  ImipProtection protection = ImipProtection.none,
}) => receiveHostImipReply(
  session,
  raw: raw,
  outerProtection: protection,
  scopeKey: 'fixture',
  eventId: UuidValue.fromString('00000000-0000-4000-8000-000000000001'),
  namespace: 'fixture',
  deliveryKey: 'stable',
  originReference: 'unverified',
);
Matcher error(HostImipMimeError kind) =>
    throwsA(isA<HostImipMimeException>().having((e) => e.kind, 'kind', kind));

void main() {
  for (final method in IcalendarSchedulingMethod.values) {
    if ({
      IcalendarSchedulingMethod.request,
      IcalendarSchedulingMethod.cancel,
    }.contains(method)) {
      continue;
    }
    test(
      'invitation route rejects pure ${method.name} before native access',
      () async {
        final session = _Session();
        final name = method.name.toUpperCase();
        final source = f.calendar(
          name,
          events: [
            [
              'UID:synthetic@example.invalid',
              'DTSTAMP:20261030T100000Z',
              'ORGANIZER:mailto:organizer@example.invalid',
              if ({'PUBLISH', 'REQUEST', 'ADD', 'COUNTER'}.contains(name)) ...[
                'DTSTART:20261031T120000Z',
                'SUMMARY:Synthetic',
              ],
              if ({
                'REQUEST',
                'REPLY',
                'REFRESH',
                'DECLINECOUNTER',
              }.contains(name))
                'ATTENDEE:mailto:guest@example.invalid',
              if ({'ADD', 'CANCEL', 'DECLINECOUNTER'}.contains(name))
                'SEQUENCE:1',
            ],
          ],
        );
        final raw = composeSyntheticIngressMime(
          utf8.encode(source),
          method: method,
        );
        // Establish that route rejection is not a malformed source failure.
        expect(
          parseHostImipMime(
            raw,
            outerProtection: ImipProtection.none,
          ).eventMessage!.method,
          method,
        );
        await expectLater(
          _invitation(session, raw),
          error(HostImipMimeError.profile),
        );
        expect(session.reads, 0);
      },
    );
  }
  for (final method in [
    IcalendarSchedulingMethod.request,
    IcalendarSchedulingMethod.cancel,
  ]) {
    test('reply route rejects ${method.name} before native access', () async {
      final session = _Session();
      final raw = composeSyntheticIngressMime(
        utf8.encode(f.calendar(method.name.toUpperCase())),
        method: method,
      );
      await expectLater(
        _response(session, raw),
        error(HostImipMimeError.profile),
      );
      expect(session.reads, 0);
    });
  }
  for (final call in [_invitation, _response]) {
    test(
      'malformed and protected inputs fail before native entry: $call',
      () async {
        final session = _Session();
        await expectLater(
          call(session, [13, 10]),
          error(HostImipMimeError.profile),
        );
        for (final protection in [
          ImipProtection.signed,
          ImipProtection.encrypted,
          ImipProtection.unknown,
        ]) {
          await expectLater(
            call(session, [], protection: protection),
            error(HostImipMimeError.protection),
          );
        }
        expect(session.reads, 0);
      },
    );
    test('free/busy cannot enter native event route: $call', () async {
      final source = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:Synthetic',
        'METHOD:REQUEST',
        'BEGIN:VFREEBUSY',
        'UID:busy',
        'DTSTAMP:20260101T000000Z',
        'DTSTART:20300101T000000Z',
        'DTEND:20300102T000000Z',
        'ORGANIZER:mailto:organizer@example.invalid',
        'ATTENDEE:mailto:guest@example.invalid',
        'END:VFREEBUSY',
        'END:VCALENDAR',
        '',
      ].join('\r\n');
      final raw = ascii.encode(
        r.wire(
          r.b64(utf8.encode(source)),
          type: 'text/calendar; method=REQUEST; component=VFREEBUSY; charset=UTF-8',
        ),
      );
      expect(
        parseHostImipMime(raw, outerProtection: ImipProtection.none).component,
        'VFREEBUSY',
      );
      final session = _Session();
      await expectLater(call(session, raw), error(HostImipMimeError.profile));
      expect(session.reads, 0);
    });
  }
  test(
    'invitation cap stays 256 KiB while reply gate permits up to 512 KiB',
    () async {
      final large = reply(comment: '😀' * 4050, producer: 'p' * 4000);
      final bytes = utf8.encode(large);
      expect(bytes.length, greaterThan(262144));
      final raw = composeSyntheticIngressMime(
        bytes,
        method: IcalendarSchedulingMethod.reply,
      );
      expect(
        parseHostImipMime(
          raw,
          outerProtection: ImipProtection.none,
        ).source.body,
        bytes,
      );
      final session = _Session();
      await expectLater(_response(session, raw), throwsStateError);
      expect(session.reads, 1);
      final request = large
          .replaceFirst('METHOD:REPLY', 'METHOD:REQUEST')
          .replaceFirst(
            'UID:fixture',
            'UID:fixture\r\nDTSTART:20300101T000000Z\r\nSUMMARY:Request',
          );
      final requestRaw = composeSyntheticIngressMime(
        utf8.encode(request),
        method: IcalendarSchedulingMethod.request,
      );
      expect(
        parseHostImipMime(
          requestRaw,
          outerProtection: ImipProtection.none,
        ).source.body.length,
        greaterThan(262144),
      );
      await expectLater(
        _invitation(session, requestRaw),
        error(HostImipMimeError.limitExceeded),
      );
      expect(session.reads, 1);
    },
  );
  test(
    'fixture composition preserves exact UTF-8 and stable inert headers',
    () {
      for (final method in [
        IcalendarSchedulingMethod.request,
        IcalendarSchedulingMethod.cancel,
        IcalendarSchedulingMethod.reply,
      ]) {
        final bytes = utf8.encode(
          method == IcalendarSchedulingMethod.reply
              ? reply()
              : f.calendar(method.name.toUpperCase()),
        );
        final raw = composeSyntheticIngressMime(bytes, method: method);
        final source = parseHostImipMime(
          raw,
          outerProtection: ImipProtection.none,
        );
        expect(source.source.body, bytes);
        final text = ascii.decode(raw);
        expect(text, contains('transport@example.invalid'));
        expect(text, contains('fixture@example.invalid'));
        expect(text, contains('<synthetic-input@example.invalid>'));
      }
    },
  );
  test(
    'fixture builder rejects invalid bytes, UTF-8 and oversize without echo',
    () {
      for (final bytes in [
        [300],
        [-1],
        [255],
        [239, 187, 191, 65],
      ]) {
        expect(
          () => composeSyntheticIngressMime(
            bytes,
            method: IcalendarSchedulingMethod.request,
          ),
          error(HostImipMimeError.profile),
        );
      }
      expect(
        () => composeSyntheticIngressMime(
          List.filled(524289, 65),
          method: IcalendarSchedulingMethod.reply,
        ),
        error(HostImipMimeError.limitExceeded),
      );
    },
  );
}
