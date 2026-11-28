import 'dart:async';
import 'dart:convert';

import 'package:calendar_example_server/src/imip_mime_input.dart';
import 'package:calendar_example_server/src/scheduling_mime.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'scheduling_mime_test.dart' as f;

String b64(List<int> bytes) {
  final encoded = base64.encode(bytes);
  return RegExp('.{1,76}').allMatches(encoded).map((m) => m[0]!).join('\r\n');
}

String wire(
  String body, {
  String type = 'text/calendar; method=REQUEST; charset=UTF-8',
  String? encoding = 'base64',
  List<String> extra = const [],
  bool root = true,
}) => [
  if (root) 'MIME-Version: 1.0',
  'Content-Type: $type',
  if (encoding != null) 'Content-Transfer-Encoding: $encoding',
  ...extra,
  '',
  body,
].join('\r\n');

String message([String? calendar]) =>
    wire(b64(utf8.encode(calendar ?? f.calendar('REQUEST'))));

ImipCalendarPart parse(String text) =>
    parseHostImipMime(ascii.encode(text), outerProtection: ImipProtection.none);

Matcher error(HostImipMimeError kind) =>
    throwsA(isA<HostImipMimeException>().having((e) => e.kind, 'kind', kind));

String alternative(
  List<String> parts, {
  String boundary = 'synthetic',
  String preamble = '',
  String epilogue = '',
}) => wire(
  '$preamble${parts.map((p) => '--$boundary\r\n$p\r\n').join()}--$boundary--\r\n$epilogue',
  type: 'multipart/alternative; boundary="$boundary"',
  encoding: null,
);

String calendarLeaf({String? source, String? encoding = 'base64'}) => wire(
  encoding == 'base64'
      ? b64(utf8.encode(source ?? f.calendar('REQUEST')))
      : source ?? f.calendar('REQUEST'),
  encoding: encoding,
  root: false,
);

String human(
  String type, {
  String body = 'Synthetic',
  String? encoding = '7bit',
}) => wire(
  encoding == 'base64' ? b64(utf8.encode(body)) : body,
  type: 'text/$type; charset=UTF-8',
  encoding: encoding,
  root: false,
);

void main() {
  test(
    'existing outgoing MIME round trips exact Unicode/CRLF and source identity',
    () {
      final submission = f.submission();
      final output = composeSyntheticSchedulingMime(
        submission,
        requireProtection: false,
      );
      final result = parse(output);
      expect(result.source.body, utf8.encode(submission.payload));
      expect(result.method, 'REQUEST');
      expect(result.component, 'VEVENT');
      expect(
        result.eventMessage!.events.single.uid,
        'synthetic@example.invalid',
      );
    },
  );

  for (final method in [
    'PUBLISH',
    'REQUEST',
    'REPLY',
    'CANCEL',
    'ADD',
    'REFRESH',
    'COUNTER',
    'DECLINECOUNTER',
  ]) {
    test(
      'raw $method retains the existing pure profile without native authority',
      () {
        final fields = [
          'UID:synthetic@example.invalid',
          'DTSTAMP:20261030T100000Z',
          'ORGANIZER:mailto:organizer@example.invalid',
          if (const {
            'PUBLISH',
            'REQUEST',
            'ADD',
            'COUNTER',
          }.contains(method)) ...[
            'DTSTART:20261031T120000Z',
            'SUMMARY:Synthetic',
          ],
          if (const {
            'REQUEST',
            'REPLY',
            'REFRESH',
            'DECLINECOUNTER',
          }.contains(method))
            'ATTENDEE:mailto:guest@example.invalid',
          if (const {'ADD', 'CANCEL', 'DECLINECOUNTER'}.contains(method))
            'SEQUENCE:1',
          if (method == 'CANCEL') 'STATUS:CANCELLED',
        ];
        final source = f.calendar(method, events: [fields]);
        final result = parse(
          wire(
            b64(utf8.encode(source)),
            type: 'text/calendar; method=$method',
          ),
        );
        expect(result.method, method);
        expect(result.source.body, utf8.encode(source));
        expect(
          result.eventMessage!.events.single.startTime == null,
          const {
            'REPLY',
            'CANCEL',
            'REFRESH',
            'DECLINECOUNTER',
          }.contains(method),
        );
      },
    );
  }

  for (final method in ['PUBLISH', 'REQUEST', 'REPLY']) {
    test('raw $method VFREEBUSY remains an untrusted source claim', () {
      final source = [
        'BEGIN:VCALENDAR',
        'VERSION:2.0',
        'PRODID:-//Synthetic//EN',
        'METHOD:$method',
        'BEGIN:VFREEBUSY',
        'UID:synthetic',
        'DTSTAMP:20261030T100000Z',
        'DTSTART:20261031T100000Z',
        'DTEND:20261101T100000Z',
        'ORGANIZER:mailto:organizer@example.invalid',
        if (method != 'PUBLISH') 'ATTENDEE:mailto:guest@example.invalid',
        'END:VFREEBUSY',
        'END:VCALENDAR',
        '',
      ].join('\r\n');
      expect(
        parse(
          wire(
            b64(ascii.encode(source)),
            type: 'text/calendar; method=$method; component=VFREEBUSY',
          ),
        ).freeBusyMessage,
        isNotNull,
      );
    });
  }

  test('simple quotes, folding and parameter source case/order survive', () {
    final result = parse(
      wire(
        b64(utf8.encode(f.calendar('REQUEST'))),
        type: 'Text/Calendar; MeThOd="request";\r\n\tCHARSET="UTF-8"; component=vevent',
      ),
    );
    expect(result.source.mediaType, 'Text/Calendar');
    expect(result.source.parameters.map((p) => p.name), [
      'MeThOd',
      'CHARSET',
      'component',
    ]);
    expect(result.source.parameters.first.value, 'request');
  });

  test(
    'ordinary source headers do not rewrite the calendar or establish identity',
    () {
      final result = parse(
        message().replaceFirst(
          'MIME-Version: 1.0',
          'From: forged@real.example\r\nTo: unrelated@real.example\r\nSubject: Private unrelated label\r\nDate: opaque source claim\r\nMessage-ID: untrusted-not-a-delivery-key\r\nMIME-Version: 1.0',
        ),
      );
      expect(
        result.eventMessage!.events.single.participants.organizer!.address,
        'mailto:organizer@example.invalid',
      );
      expect(
        result.eventMessage!.events.single.summary!.value,
        'Möte, synthetic',
      );
    },
  );

  for (final order in [
    ['calendar'],
    ['calendar', 'plain'],
    ['plain', 'calendar'],
    ['html', 'calendar'],
    ['calendar', 'html', 'plain'],
    ['plain', 'html', 'calendar'],
  ]) {
    test(
      'flat alternative $order accepts one calendar and inert presentation',
      () {
        final parts = order
            .map(
              (kind) => kind == 'calendar'
                  ? calendarLeaf()
                  : human(
                      kind,
                      body: kind == 'html'
                          ? '<script>private()</script><img src="https://example.invalid/never-fetch">'
                          : 'Synthetic',
                    ),
            )
            .toList();
        final result = parse(
          alternative(
            parts,
            preamble: 'MIME presentation\r\n',
            epilogue: 'Ignored presentation',
          ),
        );
        expect(result.source.body, utf8.encode(f.calendar('REQUEST')));
      },
    );
  }

  for (final encoding in [null, '7bit', 'base64', 'quoted-printable']) {
    test('boundary separator is framing only for $encoding', () {
      final source = f.calendar('REQUEST').replaceAll('Möte', 'Synthetic');
      final result = parse(
        alternative([
          calendarLeaf(source: source, encoding: encoding),
          human('plain'),
        ]),
      );
      expect(result.source.body, ascii.encode(source));
    });
  }

  test(
    'missing decoded calendar CRLF is never repaired from a MIME separator',
    () {
      final source = f.calendar('REQUEST').replaceAll('Möte', 'Synthetic');
      final missing = source.substring(0, source.length - 2);
      expect(
        () => parse(
          alternative([calendarLeaf(source: missing, encoding: '7bit')]),
        ),
        error(HostImipMimeError.calendar),
      );
    },
  );

  test('empty human text and bounded preamble/epilogue are inert', () {
    expect(
      parse(alternative([calendarLeaf(), human('plain', body: '')])).method,
      'REQUEST',
    );
    expect(
      parse(
        alternative(
          [calendarLeaf()],
          preamble:
              '${List.filled(4, 'p' * 998 + '\r\n').join()}${'p' * 94}\r\n',
          epilogue: List.filled(4, 'e' * 998 + '\r\n').join() + 'e' * 96,
        ),
      ),
      isNotNull,
    );
  });

  for (final parts in [
    [calendarLeaf(), calendarLeaf()],
    [calendarLeaf(), human('plain'), human('plain')],
    [calendarLeaf(), human('html'), human('html')],
    [human('plain')],
    [
      calendarLeaf(),
      wire(
        'x',
        type: 'application/octet-stream',
        encoding: '7bit',
        root: false,
      ),
    ],
    [
      calendarLeaf(),
      wire('x', type: 'message/rfc822', encoding: '7bit', root: false),
    ],
    [
      calendarLeaf(),
      wire(
        'x',
        type: 'multipart/mixed; boundary=inner',
        encoding: null,
        root: false,
      ),
    ],
  ]) {
    test(
      'duplicate, missing, nested or unknown MIME leaves reject ${parts.length}',
      () {
        expect(
          () => parse(alternative(parts)),
          error(HostImipMimeError.profile),
        );
      },
    );
  }

  test('all parts are checked even after a valid calendar was found', () {
    expect(
      () => parse(
        alternative([calendarLeaf(), human('plain', encoding: '8bit')]),
      ),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(
        alternative([
          calendarLeaf(),
          human('plain', body: 'A' * 65537, encoding: 'base64'),
        ]),
      ),
      error(HostImipMimeError.limitExceeded),
    );
  });

  for (final name in [
    'Content-Type',
    'Content-Transfer-Encoding',
    'MIME-Version',
    'From',
    'Date',
    'Message-ID',
  ]) {
    test('duplicate $name is rejected before normalized lookup', () {
      final values = {
        'Content-Type': 'text/calendar; method=REQUEST',
        'Content-Transfer-Encoding': 'base64',
        'MIME-Version': '1.0',
        'From': 'source@example.invalid',
        'Date': 'opaque',
        'Message-ID': 'opaque',
      };
      final value = values[name]!;
      final text = message().replaceFirst(
        'MIME-Version: 1.0',
        'MIME-Version: 1.0\r\n$name: $value\r\n${name.toLowerCase()}: $value',
      );
      expect(() => parse(text), error(HostImipMimeError.profile));
    });
  }

  for (final type in [
    'text/calendar; method=REQUEST; METHOD=CANCEL',
    'text/calendar; method*=utf-8\'\'REQUEST',
    'text/calendar; method=REQUEST; charset*0=UTF-8',
    'text/calendar; method="REQUE\\ST"',
    'text/calendar; method="REQUEST; charset=UTF-8"',
    'text/calendar (comment); method=REQUEST',
    'text/calendar; method=REQUEST;',
    'text/calendar; method=REQUEST; name=meeting.ics',
    'text/calendar; method="REQUEST',
  ]) {
    test('ambiguous or unprofiled raw parameters reject $type', () {
      expect(
        () => parse(wire('QQ==', type: type)),
        error(HostImipMimeError.profile),
      );
    });
  }

  test('root MIME-Version/Content-Type and explicit child Content-Type are required', () {
    expect(
      () => parse(message().replaceFirst('MIME-Version: 1.0\r\n', '')),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(
        message().replaceFirst('MIME-Version: 1.0', 'MIME-Version: 2.0'),
      ),
      error(HostImipMimeError.profile),
    );
    expect(
      () =>
          parse(message().replaceFirst(RegExp(r'Content-Type:[^\r]+\r\n'), '')),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(
        alternative([
          calendarLeaf().replaceFirst(RegExp(r'Content-Type:[^\r]+\r\n'), ''),
        ]),
      ),
      error(HostImipMimeError.profile),
    );
  });

  for (final type in [
    'multipart/signed',
    'multipart/encrypted',
    'application/pkcs7-mime',
    'application/x-pkcs7-mime',
    'application/pkcs7-signature',
    'application/pgp-encrypted',
  ]) {
    test(
      'actual protected type $type rejects even when caller claims none',
      () {
        expect(
          () => parse(wire('private protected body', type: type)),
          error(HostImipMimeError.protection),
        );
      },
    );
  }

  test('outer signed/encrypted/unknown context cannot be stripped', () {
    for (final marker in ImipProtection.values.where(
      (p) => p != ImipProtection.none,
    )) {
      expect(
        () => parseHostImipMime([255], outerProtection: marker),
        error(HostImipMimeError.protection),
      );
    }
  });

  for (final encoded in [
    'A',
    'AAA',
    'AAAA=',
    'AB==',
    'AAB=',
    'A===',
    'AA==AAAA',
    'AA-_',
    'AA%3D%3D',
    '%%%%',
  ]) {
    test('noncanonical base64 $encoded is not repaired by the library', () {
      expect(() => parse(wire(encoded)), error(HostImipMimeError.profile));
    });
  }

  test(
    'base64 permits MIME whitespace but preserves decoded calendar bytes',
    () {
      final source = f.calendar('REQUEST');
      final encoded = base64.encode(utf8.encode(source));
      final folded = RegExp('.{1,48}')
          .allMatches(encoded)
          .map((m) => ' \t${m[0]} \t')
          .join('\r\n');
      expect(parse(wire(folded)).source.body, utf8.encode(source));
    },
  );

  test('quoted printable golden vector handles soft breaks, Unicode and real whitespace', () {
    final source = f.calendar('REQUEST').replaceAll('Möte', 'Möte ');
    final qp = source
        .replaceAll('ö', '=C3=B6')
        .replaceFirst('SUMMARY:M', '=53UMMARY:M=\r\n')
        .replaceFirst('M=C3=B6te ', 'M=C3=B6te=20');
    expect(
      parse(wire(qp, encoding: 'quoted-printable')).source.body,
      utf8.encode(source),
    );
    final padded = qp
        .replaceAll('=\r\n', '= \t\r\n')
        .replaceAll('END:VCALENDAR\r\n', 'END:VCALENDAR \t\r\n');
    expect(
      parse(wire(padded, encoding: 'quoted-printable')).source.body,
      utf8.encode(source),
    );
  });

  for (final qp in ['=', 'x=Q0', '=0', 'x=\n', '=00\r\n', 'x' * 77]) {
    test('malformed quoted-printable rejects ${qp.length}', () {
      expect(
        () => parse(wire(qp, encoding: 'quoted-printable')),
        throwsA(isA<HostImipMimeException>()),
      );
    });
  }

  test('charset declarations never guess or transcode', () {
    final source = f.calendar('REQUEST');
    expect(
      () => parse(
        wire(
          b64(utf8.encode(source)),
          type: 'text/calendar; method=REQUEST',
        ),
      ),
      error(HostImipMimeError.calendar),
    );
    expect(
      () => parse(
        wire(
          b64(utf8.encode(source)),
          type: 'text/calendar; method=REQUEST; charset=ISO-8859-1',
        ),
      ),
      error(HostImipMimeError.calendar),
    );
    expect(
      () => parse(
        alternative([
          calendarLeaf(),
          wire('/w==', type: 'text/html; charset=UTF-8', root: false),
        ]),
      ),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parseHostImipMime(
        utf8.encode(wire(source, encoding: '7bit')),
        outerProtection: ImipProtection.none,
      ),
      error(HostImipMimeError.profile),
    );
  });

  test(
    'boundary framing is case sensitive, bounded and requires one final close',
    () {
      final valid = alternative([calendarLeaf()]);
      for (final broken in [
        valid.replaceFirst('--synthetic--', '--Synthetic--'),
        valid.replaceFirst('--synthetic--', '--synthetic'),
        '$valid--synthetic--\r\n',
        valid.replaceFirst('--synthetic\r\n', '--synthetic--\r\n'),
      ]) {
        expect(() => parse(broken), error(HostImipMimeError.profile));
      }
      expect(
        parse(alternative([calendarLeaf()], boundary: 'quoted=boundary')),
        isNotNull,
      );
      expect(
        () => parse(
          valid.replaceFirst('boundary="synthetic"', 'boundary="a;hidden"'),
        ),
        error(HostImipMimeError.profile),
      );
      expect(
        () => parse(alternative([calendarLeaf()], boundary: 'x' * 71)),
        error(HostImipMimeError.profile),
      );
    },
  );

  test(
    'raw and aggregate work budgets reject before returning partial data',
    () {
      expect(
        () => parseHostImipMime(
          List.filled(1048577, 65),
          outerProtection: ImipProtection.none,
        ),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(wire('A' * 999)),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(
          message().replaceFirst(
            'MIME-Version: 1.0',
            'MIME-Version: 1.0\r\n${List.generate(65, (i) => 'X-$i: value').join('\r\n')}',
          ),
        ),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(
          alternative([
            calendarLeaf(),
            human('plain'),
            human('html'),
            human('plain'),
          ]),
        ),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(
          alternative([
            calendarLeaf(),
          ], preamble: List.filled(410, 'p\r\n').join() * 4),
        ),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(wire(List.filled(16385, '\r\n').join())),
        error(HostImipMimeError.limitExceeded),
      );
    },
  );

  test('wire/header controls, invalid byte integers and malformed UTF-8 never repair', () {
    for (final value in [
      message().replaceFirst('\r\n', '\n'),
      message().replaceFirst('Content-Type', 'Bad Header'),
      message().replaceFirst('MIME-Version', '\tMIME-Version'),
    ]) {
      expect(() => parse(value), error(HostImipMimeError.profile));
    }
    for (final byte in [-1, 256]) {
      expect(
        () => parseHostImipMime([byte], outerProtection: ImipProtection.none),
        error(HostImipMimeError.profile),
      );
    }
    expect(() => parse(wire('/w==')), error(HostImipMimeError.calendar));
  });

  test('rejected decoder inputs emit no private diagnostics', () {
    final printed = <String>[];
    runZoned(
      () {
        for (final body in ['private%%%%', 'A', 'AB==']) {
          expect(() => parse(wire(body)), error(HostImipMimeError.profile));
        }
        try {
          parse(wire('private%%%%'));
        } on HostImipMimeException catch (e) {
          expect(e.toString(), isNot(contains('private')));
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => printed.add(line),
      ),
    );
    expect(printed, isEmpty);
  });

  test('decoded calendar cap applies before base64/quoted-printable work', () {
    final body = List.filled(7000, 'a' * 75 + '\r\n').join();
    expect(
      () => parse(wire(b64(ascii.encode(body)))),
      error(HostImipMimeError.limitExceeded),
    );
    expect(
      () => parse(wire(body, encoding: 'quoted-printable')),
      error(HostImipMimeError.limitExceeded),
    );
  });

  test(
    'header bytes, names and raw parameter counts are aggregate budgets',
    () {
      final headers = List.generate(20, (i) => 'X-$i: ${'x' * 900}');
      expect(
        () => parse(wire('QQ==', extra: headers)),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(wire('QQ==', extra: ['X' * 65 + ': value'])),
        error(HostImipMimeError.limitExceeded),
      );
      final params = List.filled(17, 'charset=UTF-8').join(';');
      expect(
        () => parse(wire('QQ==', type: 'text/calendar;$params')),
        error(HostImipMimeError.limitExceeded),
      );
      expect(
        () => parse(wire('QQ==', type: 'text/calendar; method=${'x' * 1025}')),
        error(HostImipMimeError.limitExceeded),
      );
      final child = calendarLeaf().replaceFirst(
        'Content-Type:',
        '${List.generate(33, (i) => 'X-$i: value\r\n').join()}Content-Type:',
      );
      expect(
        () => parse(
          alternative([
            child,
            human('plain').replaceFirst(
              'Content-Type:',
              '${List.generate(33, (i) => 'Y-$i: value\r\n').join()}Content-Type:',
            ),
          ]),
        ),
        error(HostImipMimeError.limitExceeded),
      );
    },
  );

  test(
    'body and wrapper bytes are immutable and do not inherit later edits',
    () {
      final bytes = ascii.encode(message());
      final result = parseHostImipMime(
        bytes,
        outerProtection: ImipProtection.none,
      );
      bytes[0] = 0;
      expect(result.source.body, utf8.encode(f.calendar('REQUEST')));
      expect(() => result.source.body.clear(), throwsUnsupportedError);
    },
  );

  test('child critical headers and explicit empty encoding reject', () {
    final child = calendarLeaf().replaceFirst(
      'Content-Type:',
      'MIME-Version: 1.0\r\nMIME-Version: 1.0\r\nContent-Type:',
    );
    expect(() => parse(alternative([child])), error(HostImipMimeError.profile));
    expect(
      () => parse(wire('QQ==', encoding: '')),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(
        alternative([calendarLeaf()]).replaceFirst(
          'Content-Type: multipart/alternative',
          'Content-Transfer-Encoding: base64\r\nContent-Type: multipart/alternative',
        ),
      ),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(
        alternative([calendarLeaf()]).replaceFirst(
          'MIME-Version: 1.0',
          'MIME-Version: 1.0\r\nFrom:\r\nfrom: forged@example.invalid',
        ),
      ),
      error(HostImipMimeError.profile),
    );
  });

  test(
    'auxiliary charset/encoding is validated without returning human contents',
    () {
      final unicode = human('html', body: '<p>Möte</p>', encoding: 'base64');
      expect(parse(alternative([unicode, calendarLeaf()])).component, 'VEVENT');
      expect(
        () => parse(
          alternative([
            unicode.replaceFirst('charset=UTF-8', 'charset=ISO-8859-1'),
            calendarLeaf(),
          ]),
        ),
        error(HostImipMimeError.profile),
      );
    },
  );

  test('raw non-ASCII quoted-printable and lone CR reject before decode', () {
    final raw = utf8.encode(wire('é', encoding: 'quoted-printable'));
    expect(
      () => parseHostImipMime(raw, outerProtection: ImipProtection.none),
      error(HostImipMimeError.profile),
    );
    expect(
      () => parse(wire('x\rZ', encoding: 'quoted-printable')),
      error(HostImipMimeError.profile),
    );
  });
  test(
    'named-zone validation retains source bytes and rejects mismatched offsets',
    () {
      final zone = [
        'BEGIN:VTIMEZONE',
        'TZID:UTC',
        'BEGIN:STANDARD',
        'DTSTART:19000101T000000',
        'TZOFFSETFROM:+0000',
        'TZOFFSETTO:+0000',
        'END:STANDARD',
        'END:VTIMEZONE',
      ].join('\r\n');
      final source = f.calendar(
        'REQUEST',
        events: [
          f
              .fields('REQUEST')
              .map(
                (v) => v == 'DTSTART:20261031T120000Z'
                    ? 'DTSTART;TZID=UTC:20261031T120000'
                    : v,
              )
              .toList(),
        ],
        zones: [zone],
      );
      final accepted = parse(message(source));
      expect(accepted.eventMessage!.timeZones.keys, ['UTC']);
      expect(accepted.source.body, utf8.encode(source));
      expect(
        () => parse(
          message(source.replaceAll('TZOFFSETTO:+0000', 'TZOFFSETTO:+0100')),
        ),
        error(HostImipMimeError.calendar),
      );
    },
  );
  test('calendar horizon, whole-second and floating-time rules survive MIME decoding', () {
    for (final start in [
      '19691231T120000Z',
      '21000101T000000Z',
      '20261031T120000.1Z',
      '20261031T120000',
    ]) {
      expect(
        () => parse(
          message(
            f.calendar('REQUEST').replaceFirst('20261031T120000Z', start),
          ),
        ),
        error(HostImipMimeError.calendar),
      );
    }
    final source = [239, 187, 191, ...utf8.encode(f.calendar('REQUEST'))];
    expect(() => parse(wire(b64(source))), error(HostImipMimeError.calendar));
  });
  test(
    'whitespace-heavy transfer padding stays bounded and does not invent data',
    () {
      final padded = List.filled(1000, ' ' * 998 + '\r\n').join();
      expect(
        () => parse(wire(padded, encoding: 'quoted-printable')),
        error(HostImipMimeError.calendar),
      );
    },
  );
}
