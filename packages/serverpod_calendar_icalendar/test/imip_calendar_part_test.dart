import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'support/icalendar_fixtures.dart' show fixedZone;
import 'support/scheduling_fixtures.dart' as f;

ImipDecodedPart part(
  String text, {
  String mediaType = 'text/calendar',
  List<ImipParameter> parameters = const [ImipParameter('method', 'REQUEST')],
  ImipProtection protection = ImipProtection.none,
  ImipPartLimits limits = const ImipPartLimits(),
}) => ImipDecodedPart(
  mediaType: mediaType,
  parameters: parameters,
  body: utf8.encode(text),
  protection: protection,
  limits: limits,
);
String request([List<String> extra = const []]) =>
    f.message('REQUEST', [...f.minimal('REQUEST'), ...extra]);
Matcher error(ImipPartError kind) =>
    throwsA(isA<ImipPartException>().having((e) => e.kind, 'kind', kind));

String busy(String method) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic//EN',
  'METHOD:$method',
  'BEGIN:VFREEBUSY',
  'UID:busy-source',
  'DTSTAMP:20261026T070000Z',
  'DTSTART:20261026T080000Z',
  'DTEND:20261027T080000Z',
  'ORGANIZER:mailto:source@example.invalid',
  if (method != 'PUBLISH') 'ATTENDEE:mailto:target@example.invalid',
  if (method != 'REQUEST') 'FREEBUSY:20261026T100000Z/PT1H',
  'END:VFREEBUSY',
  'END:VCALENDAR',
  '',
].join('\r\n');

void main() {
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
      '$method event mail part preserves source omissions and round trips',
      () {
        final source = f.message(method, f.minimal(method));
        final value = parseImipCalendarPart(
          part(
            source,
            mediaType: 'Text/Calendar',
            parameters: [ImipParameter('MeThOd', method.toLowerCase())],
          ),
        );
        expect(value.component, 'VEVENT');
        expect(value.method, method);
        expect(value.freeBusyMessage, isNull);
        expect(value.source.parameters.single.name, 'MeThOd');
        final own = value.eventMessage!.events.single;
        expect(
          own.startTime == null,
          const {
            'REPLY',
            'CANCEL',
            'REFRESH',
            'DECLINECOUNTER',
          }.contains(method),
        );
        expect(
          own.sequence == null,
          !const {'ADD', 'CANCEL', 'DECLINECOUNTER'}.contains(method),
        );
        final output = serializeImipSchedulingMessage(
          value.eventMessage!,
          requireProtection: false,
        );
        expect(output.parameters.map((p) => '${p.name}=${p.value}'), [
          'charset=UTF-8',
          'method=$method',
          'component=VEVENT',
        ]);
        expect(parseImipCalendarPart(output).method, method);
        expect(utf8.decode(output.body), source);
      },
    );
  }
  for (final method in ['PUBLISH', 'REQUEST', 'REPLY']) {
    test(
      '$method free busy part keeps periods without establishing coverage',
      () {
        final value = parseImipCalendarPart(
          part(
            busy(method),
            parameters: [
              ImipParameter('method', method),
              const ImipParameter('component', 'vfreebusy'),
            ],
          ),
        );
        expect(value.eventMessage, isNull);
        expect(
          value.freeBusyMessage!.components.single.groups.length,
          method == 'REQUEST' ? 0 : 1,
        );
        final output = serializeImipFreeBusyMessage(
          value.freeBusyMessage!,
          requireProtection: false,
        );
        expect(utf8.decode(output.body), busy(method));
        expect(parseImipCalendarPart(output).component, 'VFREEBUSY');
      },
    );
  }
  test(
    'Unicode display text needs declared UTF-8; charset aliases never repair',
    () {
      final text = request().replaceFirst('SUMMARY:', 'SUMMARY:Möte');
      for (final charset in [null, 'US-ASCII', 'utf8', 'ISO-8859-1']) {
        expect(
          () => parseImipCalendarPart(
            part(
              text,
              parameters: [
                const ImipParameter('method', 'REQUEST'),
                if (charset != null) ImipParameter('charset', charset),
              ],
            ),
          ),
          error(ImipPartError.charset),
        );
      }
      final value = parseImipCalendarPart(
        part(
          text,
          parameters: const [
            ImipParameter('method', 'REQUEST'),
            ImipParameter('charset', 'utf-8'),
          ],
        ),
      );
      expect(value.eventMessage!.events.single.summary!.value, 'Möte');
      expect(
        parseImipCalendarPart(
          serializeImipSchedulingMessage(
            value.eventMessage!,
            requireProtection: false,
          ),
        ).eventMessage!.events.single.summary!.value,
        'Möte',
      );
    },
  );
  test('explicit ASCII and absent component are supported', () {
    expect(
      parseImipCalendarPart(
        part(
          request(),
          parameters: const [
            ImipParameter('method', 'REQUEST'),
            ImipParameter('charset', 'us-ascii'),
          ],
        ),
      ).method,
      'REQUEST',
    );
  });
  for (final params in <List<ImipParameter>>[
    const [
      ImipParameter('method', 'REQUEST'),
      ImipParameter('METHOD', 'REQUEST'),
    ],
    const [
      ImipParameter('method', 'REQUEST'),
      ImipParameter('charset', 'UTF-8'),
      ImipParameter('CHARSET', 'UTF-8'),
    ],
    const [
      ImipParameter('method', 'REQUEST'),
      ImipParameter('name', 'invite.ics'),
    ],
    const [
      ImipParameter('method', 'REQUEST'),
      ImipParameter('component*', 'VEVENT'),
    ],
    const [ImipParameter('method', '')],
    const [ImipParameter('method', 'REQUEST\n')],
    const [ImipParameter('method\n', 'REQUEST')],
    const [ImipParameter('méthod', 'REQUEST')],
  ]) {
    test(
      'ambiguous or unprofiled parameter list ${params.indexed.map((e) => e.$1)} rejects',
      () {
        expect(
          () => parseImipCalendarPart(part(request(), parameters: params)),
          error(ImipPartError.parameter),
        );
      },
    );
  }
  test('MIME type/method/component are checked against the actual payload', () {
    expect(
      () => parseImipCalendarPart(
        part(request(), mediaType: 'application/octet-stream'),
      ),
      error(ImipPartError.mediaType),
    );
    expect(
      () => parseImipCalendarPart(part(request(), parameters: [])),
      error(ImipPartError.missingMethod),
    );
    expect(
      () => parseImipCalendarPart(
        part(request(), parameters: const [ImipParameter('method', 'PUBLISH')]),
      ),
      error(ImipPartError.methodMismatch),
    );
    expect(
      () => parseImipCalendarPart(
        part(
          request(),
          parameters: const [
            ImipParameter('method', 'REQUEST'),
            ImipParameter('component', 'VFREEBUSY'),
          ],
        ),
      ),
      error(ImipPartError.componentMismatch),
    );
    expect(
      () =>
          parseImipCalendarPart(part(request().replaceAll('VEVENT', 'VTODO'))),
      error(ImipPartError.calendar),
    );
    final mixed = request().replaceFirst(
      'END:VCALENDAR',
      'BEGIN:VFREEBUSY\r\nEND:VFREEBUSY\r\nEND:VCALENDAR',
    );
    expect(
      () => parseImipCalendarPart(part(mixed)),
      error(ImipPartError.calendar),
    );
    expect(
      () => parseImipCalendarPart(part(request() + request())),
      error(ImipPartError.calendar),
    );
    expect(
      () => parseImipCalendarPart(part(request(['X-UNKNOWN:private']))),
      error(ImipPartError.calendar),
    );
  });
  test('malformed transfer-decoded bytes and line endings never repair', () {
    final valid = utf8.encode(request());
    for (final body in [
      [...valid, 255],
      [239, 187, 191, ...valid],
      utf8.encode(request().replaceAll('\r\n', '\n')),
      utf8.encode(request().replaceAll('\r\n', '\r')),
    ]) {
      expect(
        () => parseImipCalendarPart(
          ImipDecodedPart(
            mediaType: 'text/calendar',
            parameters: const [
              ImipParameter('method', 'REQUEST'),
              ImipParameter('charset', 'UTF-8'),
            ],
            body: body,
            protection: ImipProtection.none,
          ),
        ),
        error(ImipPartError.calendar),
      );
    }
  });
  for (final mailbox in [
    'mailto:one@example.invalid',
    'MAILTO:first.last+tag@xn--bcher-kva.example',
    'mailto:one%2Btag@example.invalid',
    'mailto:%61@example.invalid',
  ]) {
    test('proper mailto spelling retained: $mailbox', () {
      final text = request().replaceFirst(
        'mailto:organizer@example.invalid',
        mailbox,
      );
      final value = parseImipCalendarPart(part(text));
      expect(
        value.eventMessage!.events.single.participants.organizer!.address,
        mailbox,
      );
      expect(
        utf8.decode(
          serializeImipSchedulingMessage(
            value.eventMessage!,
            requireProtection: false,
          ).body,
        ),
        text,
      );
    });
  }
  for (final mailbox in [
    'https://example.invalid/person',
    'mailto:',
    'mailto:a,b@example.invalid',
    'mailto:a@example.invalid?subject=private',
    'mailto:a@example.invalid#private',
    'mailto:a%0A@example.invalid',
    'mailto:a%7F@example.invalid',
    'mailto:%22a%22@example.invalid',
    'mailto:a@[127.0.0.1]',
    'mailto:a@-example.invalid',
    'mailto:a@ex_ample.invalid',
    'mailto:a..b@example.invalid',
    'mailto:.a@example.invalid',
    'mailto:a.@example.invalid',
    'mailto:%C3%A4@example.invalid',
    'mailto:a%ZZ@example.invalid',
    'mailto:a%40b@example.invalid',
  ]) {
    test(
      'mail-specific address subset rejects $mailbox without source disclosure',
      () {
        final text = request().replaceFirst(
          'mailto:organizer@example.invalid',
          mailbox,
        );
        expect(
          () => parseImipCalendarPart(part(text)),
          throwsA(isA<ImipPartException>()),
        );
        try {
          parseImipCalendarPart(part(text));
        } on ImipPartException catch (e) {
          expect(e.toString(), isNot(contains(mailbox)));
          expect(e.toString(), isNot(contains('private')));
        }
      },
    );
  }
  test(
    'SENT-BY and every delegation address use the same mail-specific gate',
    () {
      for (final field in [
        'ORGANIZER;SENT-BY="https://example.invalid/agent":mailto:organizer@example.invalid',
        'ATTENDEE;DELEGATED-TO="https://example.invalid/agent":mailto:guest@example.invalid',
        'ATTENDEE;DELEGATED-FROM="mailto:ok@example.invalid","https://example.invalid/agent":mailto:guest@example.invalid',
      ]) {
        final text = request().replaceFirst(
          field.startsWith('ORGANIZER') ? f.organizer : f.attendee,
          field,
        );
        expect(
          () => parseImipCalendarPart(part(text)),
          error(ImipPartError.mailbox),
        );
      }
      final text = request().replaceFirst(
        f.organizer,
        'ORGANIZER;SENT-BY="mailto:agent@example.invalid";CN=Organizer:mailto:organizer@example.invalid',
      );
      expect(
        parseImipCalendarPart(part(text))
            .eventMessage!
            .events
            .single
            .participants
            .organizer!
            .sentBy,
        'mailto:agent@example.invalid',
      );
    },
  );
  test('URI metadata stays inert and is not mistaken for mailbox routing', () {
    final value = parseImipCalendarPart(
      part(
        request([
          'URL:https://example.invalid/data',
          'ATTACH:https://example.invalid/file',
        ]),
      ),
    );
    expect(
      value.eventMessage!.events.single.references.attachments,
      hasLength(1),
    );
  });
  test('named zones and recurrence retain existing validation and original identity', () {
    final fields = [
      ...f
          .minimal('REQUEST')
          .map((v) => v == f.start ? 'DTSTART;TZID=UTC:20261022T120000' : v),
      'RRULE:COUNT=2;FREQ=DAILY',
    ];
    final value = parseImipCalendarPart(
      part(f.message('REQUEST', fields, zones: [fixedZone()])),
    );
    expect(value.eventMessage!.timeZones.keys, ['UTC']);
    final out = serializeImipSchedulingMessage(
      value.eventMessage!,
      requireProtection: false,
    );
    expect(utf8.decode(out.body), contains('RRULE:FREQ=DAILY;COUNT=2'));
    expect(
      parseImipCalendarPart(out).eventMessage!.events.single.recurrence,
      isNotNull,
    );
    final detached = parseImipCalendarPart(
      part(
        f.message('REPLY', f.instance('REPLY', '20261023T120000Z')),
        parameters: const [ImipParameter('method', 'REPLY')],
      ),
    );
    expect(detached.eventMessage!.events.single.originalTime, isNotNull);
    expect(detached.eventMessage!.events.single.startTime, isNull);
  });
  test('protected or unknown context and required protection output never downgrade', () {
    for (final protection in [
      ImipProtection.signed,
      ImipProtection.encrypted,
      ImipProtection.unknown,
    ]) {
      expect(
        () => parseImipCalendarPart(
          part('private invalid calendar', protection: protection),
        ),
        error(ImipPartError.protection),
      );
    }
    final event = f.load(request());
    expect(
      () => serializeImipSchedulingMessage(event, requireProtection: true),
      error(ImipPartError.protection),
    );
    final fb = parseIcalendarFreeBusyMessage(utf8.encode(busy('REQUEST')));
    expect(
      () => serializeImipFreeBusyMessage(fb, requireProtection: true),
      error(ImipPartError.protection),
    );
  });
  test(
    'raw bounds apply before normalization/copy; lower caller budgets recheck',
    () {
      final text = request(), bytes = utf8.encode(text);
      expect(
        () => part(
          text,
          limits: ImipPartLimits(maxDecodedBytes: bytes.length - 1),
        ),
        error(ImipPartError.limitExceeded),
      );
      final value = part(
        text,
        limits: ImipPartLimits(maxDecodedBytes: bytes.length),
      );
      expect(
        parseImipCalendarPart(
          value,
          limits: ImipPartLimits(maxDecodedBytes: bytes.length),
        ).method,
        'REQUEST',
      );
      expect(
        () => parseImipCalendarPart(
          value,
          limits: ImipPartLimits(maxDecodedBytes: bytes.length - 1),
        ),
        error(ImipPartError.limitExceeded),
      );
      expect(
        () => ImipDecodedPart(
          mediaType: 'text/calendar',
          parameters: Iterable.generate(
            100000,
            (_) => const ImipParameter('method', 'REQUEST'),
          ),
          body: bytes,
          protection: ImipProtection.none,
        ),
        error(ImipPartError.limitExceeded),
      );
      for (final param in [
        ImipParameter('x' * 65, 'x'),
        ImipParameter('x', 'x' * 1025),
        ImipParameter('x', 'ä' * 600),
      ]) {
        expect(
          () => part(text, parameters: [param]),
          error(ImipPartError.limitExceeded),
        );
      }
      for (final limit in [0, 1048577]) {
        expect(
          () => part(text, limits: ImipPartLimits(maxDecodedBytes: limit)),
          throwsArgumentError,
        );
      }
      expect(
        () => part(text, limits: const ImipPartLimits(maxParameters: 65)),
        throwsArgumentError,
      );
      expect(
        () => serializeImipSchedulingMessage(
          f.load(text),
          requireProtection: false,
          limits: const ImipPartLimits(maxDecodedBytes: 50),
        ),
        error(ImipPartError.limitExceeded),
      );
    },
  );
  test(
    'carrier is deeply immutable and invalid byte integers do not truncate',
    () {
      final bytes = utf8.encode(request()),
          parameters = [const ImipParameter('method', 'REQUEST')];
      final value = ImipDecodedPart(
        mediaType: 'text/calendar',
        parameters: parameters,
        body: bytes,
        protection: ImipProtection.none,
      );
      bytes[0] = 0;
      parameters.clear();
      expect(parseImipCalendarPart(value).method, 'REQUEST');
      expect(() => value.body[0] = 0, throwsUnsupportedError);
      expect(() => value.parameters.clear(), throwsUnsupportedError);
      for (final byte in [-1, 256]) {
        expect(
          () => ImipDecodedPart(
            mediaType: 'text/calendar',
            parameters: [],
            body: [byte],
            protection: ImipProtection.none,
          ),
          error(ImipPartError.calendar),
        );
      }
    },
  );
  test(
    'output revalidates addresses and caller component/recurrence budgets',
    () {
      final nonmail = f.load(
        request().replaceFirst(
          'mailto:organizer@example.invalid',
          'https://example.invalid/person',
        ),
      );
      expect(
        () => serializeImipSchedulingMessage(nonmail, requireProtection: false),
        error(ImipPartError.mailbox),
      );
      final text = f.multiple('REQUEST', [
        f.minimal('REQUEST'),
        f.instance('REQUEST', '20261023T120000Z'),
      ]);
      final event = f.load(text);
      expect(
        () => serializeImipSchedulingMessage(
          event,
          requireProtection: false,
          componentLimits: const IcalendarComponentLimits(maxEvents: 1),
        ),
        error(ImipPartError.limitExceeded),
      );
    },
  );
  test('shared syntax and recurrence budgets still govern decoded mail', () {
    expect(
      () => parseImipCalendarPart(
        part(request()),
        syntaxLimits: const IcalendarSyntaxLimits(maxLines: 2),
      ),
      error(ImipPartError.limitExceeded),
    );
    final text = request(['RRULE:FREQ=DAILY;COUNT=2']);
    expect(
      () => parseImipCalendarPart(
        part(text),
        componentLimits: const IcalendarComponentLimits(maxCandidates: 1),
      ),
      throwsA(isA<ImipPartException>()),
    );
    for (final start in [
      '19691231T120000Z',
      '21000101T000000Z',
      '20261022T120000.1Z',
      '20261022T120000',
    ]) {
      expect(
        () => parseImipCalendarPart(
          part(request().replaceFirst('20261022T120000Z', start)),
        ),
        error(ImipPartError.calendar),
      );
    }
  });
  test('every event component and free-busy attendee is checked', () {
    final text = f.multiple('REQUEST', [
      f.minimal('REQUEST'),
      f
          .instance('REQUEST', '20261023T120000Z')
          .map(
            (s) =>
                s == f.attendee ? 'ATTENDEE:https://example.invalid/person' : s,
          )
          .toList(),
    ]);
    expect(
      () => parseImipCalendarPart(part(text)),
      error(ImipPartError.mailbox),
    );
    expect(
      () => parseImipCalendarPart(
        part(
          busy('REQUEST').replaceFirst(
            'mailto:target@example.invalid',
            'https://example.invalid/person',
          ),
        ),
      ),
      error(ImipPartError.mailbox),
    );
  });
  test('hard carrier ceilings precede allocation and mailbox decoding', () {
    expect(
      () => ImipDecodedPart(
        mediaType: 'text/calendar',
        parameters: [],
        body: List.filled(1048577, 65),
        protection: ImipProtection.none,
        limits: const ImipPartLimits(maxDecodedBytes: 1048576),
      ),
      error(ImipPartError.limitExceeded),
    );
    final value = part(
      request(),
      parameters: const [
        ImipParameter('method', 'REQUEST'),
        ImipParameter('charset', 'UTF-8'),
      ],
    );
    expect(
      () => parseImipCalendarPart(
        value,
        limits: const ImipPartLimits(maxParameters: 1),
      ),
      error(ImipPartError.limitExceeded),
    );
    expect(
      () => parseImipCalendarPart(
        part(
          request().replaceFirst(
            'mailto:organizer@example.invalid',
            'mailto:${'a' * 2050}@example.invalid',
          ),
        ),
      ),
      error(ImipPartError.limitExceeded),
    );
  });
}
