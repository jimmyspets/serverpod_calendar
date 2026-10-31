@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';

String zoneSource(String zone) => utf8
    .decode(
      serializeIcalendarSyntax(
        IcalendarSyntaxDocument([createIcalendarTimeZone(zone)]),
      ),
    )
    .trimRight();
String calendar(List<String> lines, {String? method, String? zone}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic projection//EN',
  if (method != null) 'METHOD:$method',
  if (zone != null) zoneSource(zone),
  'BEGIN:VEVENT',
  'UID:source@example.invalid',
  'DTSTAMP:20260101T000000Z',
  ...lines,
  'ORGANIZER:mailto:organizer@example.invalid',
  'ATTENDEE:mailto:alice@example.invalid',
  'ATTENDEE:mailto:bob@example.invalid',
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');
EventStorageProposal basis({
  bool date = false,
  String? zone,
  List<String> extra = const [],
  String rule = 'RRULE:FREQ=DAILY;COUNT=3',
  String? start,
}) => eventStorageProposal(
  parseIcalendarEventCalendar(
    utf8.encode(
      calendar([
        start ??
            (date
                ? 'DTSTART;VALUE=DATE:20300101'
                : zone == null
                ? 'DTSTART:20300101T090000Z'
                : 'DTSTART;TZID=$zone:20300101T090000'),
        if (!date) 'DURATION:PT1H',
        rule,
        'SEQUENCE:7',
        'SUMMARY:Master',
        'DESCRIPTION;LANGUAGE=sv:Beskrivning',
        'LOCATION:Room',
        ...extra,
      ], zone: zone),
    ),
  ).series.single,
);
IcalendarSchedulingMessage incoming({
  bool cancel = false,
  bool date = false,
  String? zone,
  String? original,
  List<String> timing = const [],
  List<String> extra = const [],
  String? summary = 'Moved',
  bool future = false,
}) => parseIcalendarSchedulingMessage(
  utf8.encode(
    calendar(
      [
        date
            ? 'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''};VALUE=DATE:${original ?? '20300102'}'
            : 'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}${zone == null ? '' : ';TZID=$zone'}:${original ?? (zone == null ? '20300102T090000Z' : '20300102T090000')}',
        if (cancel) ...[
          'SEQUENCE:8',
          'STATUS:CANCELLED',
        ] else ...[
          date
              ? 'DTSTART;VALUE=DATE:20300103'
              : zone == null
              ? 'DTSTART:20300102T110000Z'
              : 'DTSTART;TZID=$zone:20300102T110000',
          if (summary != null) 'SUMMARY:${encodeIcalendarText(summary)}',
        ],
        ...timing,
        ...extra,
      ],
      method: cancel ? 'CANCEL' : 'REQUEST',
      zone: zone,
    ),
  ),
);
CalendarInvitationOccurrenceProjection project(
  EventStorageProposal b,
  IcalendarSchedulingMessage m, {
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState? state,
  int work = 200000,
  String recipient = 'mailto:alice@example.invalid',
}) => projectInvitationOccurrence(
  protocolUid: b.protocolUid,
  content: b.content,
  timingOverrides: edits ?? b.edits,
  protocolState: state ?? b.protocolState,
  message: m,
  recipientAddress: recipient,
  maxCandidateWork: work,
);
CalendarInvitationOccurrenceProjection next(
  CalendarInvitationOccurrenceProjection b,
  IcalendarSchedulingMessage m,
) => projectInvitationOccurrence(
  protocolUid: b.protocolUid,
  content: b.content,
  timingOverrides: b.timingOverrides,
  protocolState: b.protocolState,
  message: m,
  recipientAddress: 'mailto:alice@example.invalid',
);
String snapshot(EventStorageProposal b) => jsonEncode([
  b.content.toJson(),
  b.edits?.toJson(),
  b.protocolState.toJson(),
]);

void main() {
  for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
    test(
      '$profile REQUEST preserves source timing forms and independent versions',
      () {
        final date = profile == 'date',
            zone = profile == 'Europe/Stockholm' ? profile : null;
        final b = basis(date: date, zone: zone), before = snapshot(b);
        final m = incoming(date: date, zone: zone);
        final result = project(b, m),
            edit = result.timingOverrides.singles.single;
        expect(edit.originalStart.start.day, 2);
        expect(edit.replacement!.start.day, date ? 3 : 2);
        expect(edit.replacement!.duration, isNull);
        expect(edit.replacement!.end, isNull);
        expect(edit.contentOverrides!.summary, 'Moved');
        expect(edit.contentOverrides!.description, isNull);
        expect(result.protocolState.version, b.protocolState.version);
        expect(result.protocolState.overrides.single.version.sequence, isNull);
        expect(identical(result.sourceMessage, m), isTrue);
        expect(snapshot(b), before);
      },
    );
    test(
      '$profile minimal cancellation preserves inheritance and source omissions',
      () {
        final date = profile == 'date',
            zone = profile == 'Europe/Stockholm' ? profile : null;
        final b = basis(date: date, zone: zone),
            m = incoming(cancel: true, date: date, zone: zone);
        final result = project(b, m),
            single = result.timingOverrides.singles.single;
        expect(single.cancelled, isTrue);
        expect(single.replacement, isNull);
        expect(single.contentOverrides, isNull);
        expect(m.events.single.startDate, isNull);
        expect(m.events.single.startTime, isNull);
        expect(result.protocolState.version, b.protocolState.version);
        expect(result.protocolState.overrides.single.version.sequence, 8);
        expect(result.protocolState.overrides.single.version.created, isNull);
      },
    );
  }
  test('REQUEST selected empty text stays own while omitted text inherits', () {
    final r = project(basis(), incoming(summary: '', extra: ['LOCATION:']));
    expect(r.timingOverrides.singles.single.contentOverrides!.summary, '');
    expect(r.timingOverrides.singles.single.contentOverrides!.location, '');
    expect(
      r.timingOverrides.singles.single.contentOverrides!.description,
      isNull,
    );
    expect(r.protocolState.overrides.single.descriptionPresent, isFalse);
  });
  test('cancel existing move preserves complete timing/content; REQUEST reopens only target', () {
    final first = project(basis(), incoming(extra: ['DESCRIPTION:Own']));
    final cancelled = next(first, incoming(cancel: true));
    final old = first.timingOverrides.singles.single,
        newEdit = cancelled.timingOverrides.singles.single;
    expect(newEdit.replacement, old.replacement);
    expect(newEdit.contentOverrides, old.contentOverrides);
    final opened = next(
      cancelled,
      incoming(extra: ['SEQUENCE:1'], summary: 'New'),
    );
    expect(opened.timingOverrides.singles.single.cancelled, isFalse);
    expect(opened.protocolState.overrides.single.version.sequence, 1);
    // A pure proposal deliberately establishes no freshness ordering.
    expect(cancelled.timingOverrides.singles.single.cancelled, isTrue);
  });
  test('unrelated originals and versions survive replacement', () {
    final first = project(basis(), incoming());
    final second = next(
      first,
      incoming(original: '20300103T090000Z', summary: 'Third'),
    );
    expect(second.timingOverrides.singles, hasLength(2));
    final prior = second.timingOverrides.singles.first;
    expect(prior, first.timingOverrides.singles.single);
    final replaced = next(second, incoming(summary: 'Updated'));
    expect(
      replaced.timingOverrides.singles.last,
      second.timingOverrides.singles.last,
    );
    expect(
      replaced.protocolState.overrides.last,
      second.protocolState.overrides.last,
    );
  });
  for (final fields in [
    ['DTSTART:20300102T090000Z'],
    ['DTEND:20300102T100000Z'],
    ['DURATION:PT1H'],
    ['SUMMARY:Master'],
    ['DESCRIPTION:Beskrivning'],
    ['LOCATION:Room'],
  ]) {
    test(
      'CANCEL checks only supplied fields: ${fields.single.split(':').first}',
      () {
        final r = project(basis(), incoming(cancel: true, timing: fields));
        expect(r.timingOverrides.singles.single.replacement, isNull);
      },
    );
  }
  for (final fields in [
    ['DTSTART:20300102T110000Z'],
    ['DTEND:20300102T110000Z'],
    ['DURATION:PT2H'],
    ['SUMMARY:Different'],
    ['DESCRIPTION;LANGUAGE=en:Beskrivning'],
    ['LOCATION:Elsewhere'],
  ]) {
    test('CANCEL different supplied fields reject: ${fields.single}', () {
      final b = basis(), before = snapshot(b);
      expect(
        () => project(b, incoming(cancel: true, timing: fields)),
        throwsArgumentError,
      );
      expect(snapshot(b), before);
    });
  }
  test(
    'PERIOD additions and earlier inclusions use exact original membership',
    () {
      final b = basis(
        extra: [
          'RDATE:20291230T090000Z',
          'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
        ],
      );
      for (final original in ['20291230T090000Z', '20300105T090000Z']) {
        expect(
          project(b, incoming(original: original)).originalStart.start.hour,
          9,
        );
      }
      final r = project(
        b,
        incoming(
          cancel: true,
          original: '20300105T090000Z',
          timing: ['DURATION:PT2H'],
        ),
      );
      expect(r.content.periods, b.content.periods);
    },
  );
  test('excluded originals, wrong profiles, recipient and RANGE reject', () {
    expect(
      () => project(basis(extra: ['EXDATE:20300102T090000Z']), incoming()),
      throwsArgumentError,
    );
    expect(
      () => project(basis(), incoming(original: '20300104T090000Z')),
      throwsArgumentError,
    );
    expect(
      () => project(basis(zone: 'Europe/Stockholm'), incoming()),
      throwsArgumentError,
    );
    expect(
      () => project(
        basis(),
        incoming(),
        recipient: 'mailto:outsider@example.invalid',
      ),
      throwsArgumentError,
    );
    expect(() => project(basis(), incoming(future: true)), throwsArgumentError);
  });
  test(
    'shared candidate ceiling and invalid caller budgets fail without mutation',
    () {
      final b = basis(), before = snapshot(b);
      expect(
        () => project(b, incoming(), work: 1),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(() => project(b, incoming(), work: 200001), throwsArgumentError);
      expect(snapshot(b), before);
    },
  );
  test('retained native 128 slots are independent of smaller wire caps', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=200');
    CalendarEventTiming point(int offset) {
      final d = DateTime.utc(2030, 1, 1).add(Duration(days: offset));
      return CalendarEventTiming(
        kind: CalendarEventTimeKind.utc,
        start: CalendarEventCivil(
          year: d.year,
          month: d.month,
          day: d.day,
          hour: 9,
        ),
      );
    }

    final edits = CalendarEventTimingOverrides(
      singles: [
        for (var i = 0; i < 128; i++)
          CalendarEventSingleOverride(originalStart: point(i), cancelled: true),
      ],
      future: [],
    );
    final state = eventProtocolBaseline(
      b.content,
      edits,
      DateTime.utc(2026),
      DateTime.utc(2026),
    ).copyWith(sourceMetadata: b.protocolState.sourceMetadata);
    expect(
      project(
        b,
        incoming(),
        edits: edits,
        state: state,
      ).timingOverrides.singles,
      hasLength(128),
    );
    expect(
      () => project(
        b,
        incoming(original: '20300509T090000Z'),
        edits: edits,
        state: state,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(edits.singles.every((v) => v.cancelled), isTrue);
  });
  test('source message and proposal collections remain immutable', () {
    final r = project(basis(), incoming());
    expect(() => r.timingOverrides.singles.clear(), throwsUnsupportedError);
    expect(() => r.protocolState.overrides.clear(), throwsUnsupportedError);
    expect(() => r.sourceMessage.events.clear(), throwsUnsupportedError);
  });
  test(
    'a caller-parsed larger unfolded line cannot bypass projection bounds',
    () {
      final dates = List.filled(5000, '19800101T000000').join(',');
      final text = calendar(
        [
          'SEQUENCE:8',
          'STATUS:CANCELLED',
          'RECURRENCE-ID:20300102T090000Z',
        ],
        method: 'CANCEL',
        zone: 'Etc/UTC',
      ).replaceFirst('END:STANDARD', 'RDATE:$dates\r\nEND:STANDARD');
      final message = parseIcalendarSchedulingMessage(
        utf8.encode(text),
        syntaxLimits: const IcalendarSyntaxLimits(
          maxPhysicalLineBytes: 200000,
          maxUnfoldedLineBytes: 200000,
        ),
      );
      expect(message.timeZones, isNotEmpty);
      expect(
        () => project(basis(), message),
        throwsA(isA<RecurrenceLimitException>()),
      );
      expect(message.timeZones, isNotEmpty);
    },
  );
  test(
    'grouped cancellation metadata agrees without flattening escaped commas',
    () {
      final b = basis(
        extra: [
          'CATEGORIES:one\\,two,three',
          'COMMENT;LANGUAGE=sv:Text',
          'URL:https://example.invalid/calendar',
          'CLASS:PRIVATE',
          'PRIORITY:3',
          'GEO:1.00;-2.00',
          'RESOURCES;LANGUAGE=sv:Room\\, A,Projector',
        ],
      );
      final good = incoming(
        cancel: true,
        extra: [
          'CATEGORIES:one\\,two,three',
          'COMMENT:Text',
          'URL:https://example.invalid/calendar',
          'CLASS:private',
          'PRIORITY:+03',
          'GEO:1.00;-2.00',
          'RESOURCES:Room\\, A,Projector',
        ],
      );
      final r = project(b, good);
      expect(identical(r.sourceMessage, good), isTrue);
      expect(r.protocolState.sourceMetadata, b.protocolState.sourceMetadata);
      for (final mismatch in [
        'CATEGORIES:one,two\\,three',
        'COMMENT;LANGUAGE=en:Text',
        'GEO:1.0;-2.0',
        'RESOURCES:Room,A\\, Projector',
        'PRIORITY:4',
      ]) {
        expect(
          () => project(b, incoming(cancel: true, extra: [mismatch])),
          throwsArgumentError,
        );
      }
    },
  );
  test(
    'REQUEST annotations survive while unsupported own metadata rejects',
    () {
      final r = project(
        basis(extra: ['URL:https://example.invalid/master']),
        incoming(
          extra: [
            'DESCRIPTION;LANGUAGE=fr;ALTREP="cid:synthetic@example.invalid":Texte',
          ],
        ),
      );
      final own = r.timingOverrides.singles.single.contentOverrides!;
      expect(own.textParameters!.description!.language, 'fr');
      expect(
        own.textParameters!.description!.alternativeUri,
        'cid:synthetic@example.invalid',
      );
      expect(
        () => project(
          basis(extra: ['URL:https://example.invalid/master']),
          incoming(extra: ['URL:https://example.invalid/different']),
        ),
        throwsArgumentError,
      );
    },
  );
  test('DATE duration-only cancellation rejects clock units against accepted timing', () {
    expect(
      project(
        basis(date: true),
        incoming(cancel: true, date: true, timing: ['DURATION:P1D']),
      ).timingOverrides.singles.single.replacement,
      isNull,
    );
    expect(
      () => project(
        basis(date: true),
        incoming(cancel: true, date: true, timing: ['DURATION:PT1H']),
      ),
      throwsArgumentError,
    );
    expect(
      () => project(
        basis(date: true),
        incoming(cancel: true, date: true, timing: ['DURATION:P1DT0H']),
      ),
      throwsArgumentError,
    );
  });
  test(
    'DST nominal day differs from 24 elapsed hours in cancellation comparison',
    () {
      final b = basis(
        zone: 'Europe/Stockholm',
        start: 'DTSTART;TZID=Europe/Stockholm:20300330T090000',
      );
      final content = b.content.copyWith(
        timing: b.content.timing.copyWith(
          duration: CalendarEventDuration(days: 1),
        ),
      );
      CalendarInvitationOccurrenceProjection run(String duration) =>
          projectInvitationOccurrence(
            protocolUid: b.protocolUid,
            content: content,
            protocolState: b.protocolState,
            message: incoming(
              cancel: true,
              zone: 'Europe/Stockholm',
              original: '20300330T090000',
              timing: ['DURATION:$duration'],
            ),
            recipientAddress: 'mailto:alice@example.invalid',
          );
      final r = run('P1D');
      expect(r.originalStart.start.day, 30);
      expect(r.timingOverrides.singles.single.replacement, isNull);
      expect(r.sourceMessage.events.single.duration!.days, 1);
      expect(() => run('PT24H'), throwsArgumentError);
    },
  );
  test(
    'future timing remains intact and its content stays local to its anchor',
    () {
      final b = basis();
      final anchor = CalendarEventTiming(
        kind: CalendarEventTimeKind.utc,
        start: CalendarEventCivil(year: 2030, month: 1, day: 1, hour: 9),
      );
      final edits = CalendarEventTimingOverrides(
        singles: [],
        future: [
          CalendarEventFutureOverride(
            originalStart: anchor,
            replacement: anchor.copyWith(
              start: CalendarEventCivil(year: 2030, month: 1, day: 1, hour: 10),
              duration: CalendarEventDuration(hours: 1),
            ),
            contentOverrides: CalendarEventOccurrenceContent(
              summary: 'Anchor only',
            ),
          ),
        ],
      );
      final state = eventProtocolBaseline(
        b.content,
        edits,
        DateTime.utc(2026),
        DateTime.utc(2026),
      ).copyWith(sourceMetadata: b.protocolState.sourceMetadata);
      final r = project(
        b,
        incoming(
          cancel: true,
          timing: ['DTSTART:20300102T100000Z', 'SUMMARY:Master'],
        ),
        edits: edits,
        state: state,
      );
      expect(r.timingOverrides.future.single, edits.future.single);
      expect(
        () => project(
          b,
          incoming(original: '20300101T090000Z'),
          edits: edits,
          state: state,
        ),
        throwsArgumentError,
      );
    },
  );
}
