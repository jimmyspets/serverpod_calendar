import 'dart:convert';
import 'dart:typed_data';

import 'package:calendar_example_server/src/scheduling_mime.dart';
import 'package:enough_mail/mime.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

const organizer = 'mailto:organizer@example.invalid';
const recipient = 'mailto:guest@example.invalid';
String component(List<String> fields) =>
    ['BEGIN:VEVENT', ...fields, 'END:VEVENT'].join('\r\n');
List<String> fields(String method) => [
  'UID:synthetic@example.invalid',
  'DTSTAMP:20261030T100000Z',
  'ORGANIZER:$organizer',
  if (method != 'CANCEL') ...[
    'DTSTART:20261031T120000Z',
    'SUMMARY:Möte\\, synthetic',
    'ATTENDEE:$recipient',
  ],
  if (method == 'CANCEL') ...['SEQUENCE:1', 'STATUS:CANCELLED'],
];
String calendar(
  String method, {
  List<List<String>>? events,
  List<String> zones = const [],
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic MIME//EN',
  'METHOD:$method',
  ...zones,
  ...(events ?? [fields(method)]).map(component),
  'END:VCALENDAR',
  '',
].join('\r\n');
CalendarSchedulingSubmission submission({
  String? payload,
  String from = organizer,
  String to = recipient,
  String key = '00000000-0000-4000-8000-000000000001',
}) => CalendarSchedulingSubmission(
  deliveryKey: UuidValue.fromString(key),
  publicationId: UuidValue.fromString('00000000-0000-4000-8000-000000000002'),
  scopeKey: 'synthetic-private-scope',
  organizerAddress: from,
  recipient: CalendarSchedulingRoute(to, 'trusted-private-route'),
  payload: payload ?? calendar('REQUEST'),
);
String compose(CalendarSchedulingSubmission s) =>
    composeSyntheticSchedulingMime(s, requireProtection: false);
MimeMessage decode(String mime) =>
    MimeMessage.parseFromData(Uint8List.fromList(ascii.encode(mime)));
Matcher failure(SyntheticSchedulingMimeError kind) => throwsA(
  isA<SyntheticSchedulingMimeException>().having((e) => e.kind, 'kind', kind),
);

void main() {
  for (final method in ['REQUEST', 'CANCEL']) {
    test(
      '$method MIME headers and independently decoded body match exact payload',
      () {
        final value = submission(payload: calendar(method));
        final mime = compose(value), parsed = decode(mime);
        expect(mime.codeUnits.every((b) => b < 128), isTrue);
        expect(mime.length, lessThanOrEqualTo(1048576));
        expect(parsed.getHeaderValue('content-transfer-encoding'), 'base64');
        expect(
          parsed.getHeaderContentType()!.mediaType.toString(),
          'text/calendar',
        );
        expect(
          parsed.getHeaderContentType()!.parameters,
          containsPair('method', method),
        );
        expect(
          parsed.getHeaderContentType()!.parameters,
          containsPair('charset', 'utf-8'),
        );
        expect(
          parsed.getHeaderContentType()!.parameters,
          containsPair('component', 'VEVENT'),
        );
        expect(parsed.decodeContentBinary(), utf8.encode(value.payload));
        // Independent base64 assertion on the generated single-part fixture.
        final encoded = mime
            .substring(mime.indexOf('\r\n\r\n') + 4)
            .replaceAll('\r\n', '');
        expect(base64.decode(encoded), utf8.encode(value.payload));
        expect(parsed.decodeDate()!.toUtc(), DateTime.utc(2026, 10, 30, 10));
        expect(
          parsed.getHeaderValue('message-id'),
          '<calendar-${value.deliveryKey}@example.invalid>',
        );
        expect(parsed.decodeSubject(), 'Calendar update');
        expect(
          parsed.getHeaderValue('from'),
          contains('organizer@example.invalid'),
        );
        expect(parsed.getHeaderValue('to'), contains('guest@example.invalid'));
        expect(parsed.parts, isNull);
        expect(
          RegExp(
            r'^(Cc|Bcc|Sender|Reply-To):',
            caseSensitive: false,
            multiLine: true,
          ).hasMatch(mime),
          isFalse,
        );
        expect(mime, isNot(contains('synthetic-private-scope')));
        expect(mime, isNot(contains('trusted-private-route')));
        expect(mime, isNot(contains('Möte')));
      },
    );
  }
  test('stable submission yields identical MIME from fresh builders', () {
    final value = submission();
    expect(compose(value), compose(value));
    expect(compose(value), compose(submission(payload: value.payload)));
    final other = submission(
      payload: value.payload,
      key: '00000000-0000-4000-8000-000000000003',
    );
    expect(compose(other), isNot(compose(value)));
    expect(
      decode(compose(other)).decodeContentBinary(),
      utf8.encode(value.payload),
    );
  });
  test(
    'folds and source token spelling remain exact rather than canonicalized',
    () {
      final source = calendar('REQUEST')
          .replaceFirst(
            'SUMMARY:Möte\\, synthetic',
            'SUMMARY:Möte\\,\r\n  synthetic',
          )
          .replaceFirst('METHOD:REQUEST', 'METHOD:request');
      expect(
        decode(compose(submission(payload: source))).decodeContentBinary(),
        utf8.encode(source),
      );
    },
  );
  test('recurring request bundle keeps each independent component version', () {
    final source = calendar(
      'REQUEST',
      events: [
        [...fields('REQUEST'), 'SEQUENCE:5', 'RRULE:FREQ=DAILY;COUNT=2'],
        [
          ...fields('REQUEST').map(
            (s) => s == 'DTSTART:20261031T120000Z'
                ? 'DTSTART:20261101T130000Z'
                : s,
          ),
          'RECURRENCE-ID:20261101T120000Z',
          'SEQUENCE:9',
        ],
      ],
    );
    final body = decode(compose(submission(payload: source)))
        .decodeContentBinary();
    expect(body, utf8.encode(source));
    expect(utf8.decode(body!), contains('SEQUENCE:9'));
  });
  test(
    'historical detached cancellation keeps omitted timing and source identity',
    () {
      final source = calendar(
        'CANCEL',
        events: [
          [...fields('CANCEL'), 'RECURRENCE-ID:20261101T120000Z'],
        ],
      );
      final body = decode(compose(submission(payload: source)))
          .decodeContentBinary();
      expect(body, utf8.encode(source));
      expect(utf8.decode(body!), isNot(contains('DTSTART')));
    },
  );
  test('named-zone body and observance bytes are not regenerated', () {
    final source = calendar(
      'REQUEST',
      events: [
        fields('REQUEST')
            .map(
              (s) => s == 'DTSTART:20261031T120000Z'
                  ? 'DTSTART;TZID=UTC:20261031T120000'
                  : s,
            )
            .toList(),
      ],
      zones: [
        [
          'BEGIN:VTIMEZONE',
          'TZID:UTC',
          'BEGIN:STANDARD',
          'DTSTART:19000101T000000',
          'TZOFFSETFROM:+0000',
          'TZOFFSETTO:+0000',
          'END:STANDARD',
          'END:VTIMEZONE',
        ].join('\r\n'),
      ],
    );
    expect(
      decode(compose(submission(payload: source))).decodeContentBinary(),
      utf8.encode(source),
    );
  });
  for (final address in [
    'mailto:a@real.example',
    'guest@example.invalid',
    'mailto:a@example.invalid\r\nBcc:private@example.invalid',
    'mailto:a@example.invalid\n',
    'mailto:.a@example.invalid',
    'mailto:a..b@example.invalid',
    'mailto:a@example.invalid?subject=private',
    'mailto:ä@example.invalid',
  ]) {
    test(
      'synthetic sender and recipient guards reject $address without echo',
      () {
        expect(
          () => compose(submission(from: address)),
          failure(SyntheticSchedulingMimeError.profile),
        );
        expect(
          () => compose(submission(to: address)),
          failure(SyntheticSchedulingMimeError.profile),
        );
        try {
          compose(submission(to: address));
        } on SyntheticSchedulingMimeException catch (e) {
          expect(e.toString(), isNot(contains(address)));
          expect(e.toString(), isNot(contains('private')));
        }
      },
    );
  }
  test('every component organizer must match host-approved sender', () {
    final source = calendar('REQUEST').replaceFirst(
      'ORGANIZER:$organizer',
      'ORGANIZER:mailto:other@example.invalid',
    );
    expect(
      () => compose(submission(payload: source)),
      failure(SyntheticSchedulingMimeError.profile),
    );
    final bundled = calendar(
      'REQUEST',
      events: [
        fields('REQUEST'),
        [
          ...fields('REQUEST').map(
            (s) => s == 'ORGANIZER:$organizer'
                ? 'ORGANIZER:mailto:other@example.invalid'
                : s,
          ),
          'RECURRENCE-ID:20261101T120000Z',
        ],
      ],
    );
    expect(
      () => compose(submission(payload: bundled)),
      failure(SyntheticSchedulingMimeError.profile),
    );
  });
  test(
    'source parties and delegates cannot turn recording into real-address data',
    () {
      for (final attendee in [
        'ATTENDEE:mailto:private@real.example',
        'ATTENDEE;SENT-BY="mailto:private@real.example":$recipient',
        'ATTENDEE;DELEGATED-TO="mailto:private@real.example":$recipient',
      ]) {
        final source = calendar('REQUEST')
            .replaceFirst('ATTENDEE:$recipient', attendee);
        expect(
          () => compose(submission(payload: source)),
          failure(SyntheticSchedulingMimeError.profile),
        );
      }
    },
  );
  test(
    'required confidentiality rejects instead of invoking library composition',
    () {
      expect(
        () => composeSyntheticSchedulingMime(
          submission(payload: 'private invalid'),
          requireProtection: true,
        ),
        failure(SyntheticSchedulingMimeError.protection),
      );
    },
  );
  test('ASCII and multibyte payload caps precede calendar parsing', () {
    for (final source in ['x' * 524289, 'ä' * 300000]) {
      expect(
        () => compose(submission(payload: source)),
        failure(SyntheticSchedulingMimeError.limitExceeded),
      );
    }
  });
  for (final source in [
    '',
    'private malformed calendar',
    calendar('REQUEST').replaceAll('\r\n', '\n'),
    calendar('PUBLISH'),
    calendar('REQUEST').replaceFirst('METHOD:REQUEST\r\n', ''),
  ]) {
    test(
      'unsupported/malformed source profile rejects without repair ${source.length}',
      () {
        expect(
          () => compose(submission(payload: source)),
          failure(SyntheticSchedulingMimeError.profile),
        );
      },
    );
  }
  for (final method in [
    'PUBLISH',
    'REPLY',
    'REFRESH',
    'COUNTER',
    'ADD',
    'DECLINECOUNTER',
  ]) {
    test(
      'valid pure $method remains outside organizer MIME transport scope',
      () {
        final source = calendar(
          method,
          events: [
            [
              'UID:synthetic@example.invalid',
              'DTSTAMP:20261030T100000Z',
              'ORGANIZER:$organizer',
              if (const {'PUBLISH', 'COUNTER', 'ADD'}.contains(method)) ...[
                'DTSTART:20261031T120000Z',
                'SUMMARY:Synthetic',
              ],
              if (const {'REPLY', 'REFRESH', 'DECLINECOUNTER'}.contains(method))
                'ATTENDEE:$recipient',
              if (const {'ADD', 'DECLINECOUNTER'}.contains(method))
                'SEQUENCE:1',
            ],
          ],
        );
        expect(
          parseIcalendarSchedulingMessage(utf8.encode(source)).method.name
              .toUpperCase(),
          method,
        );
        expect(
          () => compose(submission(payload: source)),
          failure(SyntheticSchedulingMimeError.profile),
        );
      },
    );
  }
  test(
    'duplicate methods and unsupported alarm children are never stripped',
    () {
      final original = calendar('REQUEST');
      for (final source in [
        original.replaceFirst(
          'METHOD:REQUEST',
          'METHOD:REQUEST\r\nMETHOD:REQUEST',
        ),
        original.replaceFirst(
          'END:VEVENT',
          'BEGIN:VALARM\r\nACTION:DISPLAY\r\nTRIGGER:-PT5M\r\nDESCRIPTION:Synthetic\r\nEND:VALARM\r\nEND:VEVENT',
        ),
      ]) {
        expect(
          () => compose(submission(payload: source)),
          failure(SyntheticSchedulingMimeError.profile),
        );
      }
    },
  );
}
