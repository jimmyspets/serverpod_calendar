@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';

import 'invitation_occurrence_values_test.dart'
    show basis, incoming, calendar, snapshot;

CalendarInvitationOccurrenceProjection projectRange(
  EventStorageProposal b,
  IcalendarSchedulingMessage message, {
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState? state,
  CalendarEventContent? content,
  String? uid,
  String recipient = 'mailto:alice@example.invalid',
  int work = eventMaxCandidateWork,
}) => projectInvitationRangeRequest(
  protocolUid: uid ?? b.protocolUid,
  content: content ?? b.content,
  timingOverrides: edits ?? b.edits,
  protocolState: state ?? b.protocolState,
  message: message,
  recipientAddress: recipient,
  maxCandidateWork: work,
);

CalendarEventTiming point(int day, {int hour = 9}) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: CalendarEventCivil(year: 2030, month: 1, day: day, hour: hour),
);
CalendarEventProtocolState baseline(
  EventStorageProposal b,
  CalendarEventTimingOverrides edits,
) => eventProtocolBaseline(
  b.content,
  edits,
  DateTime.utc(2026),
  DateTime.utc(2026),
).copyWith(sourceMetadata: b.protocolState.sourceMetadata);
IcalendarSchedulingMessage raw(List<String> properties, {String? zone}) =>
    parseIcalendarSchedulingMessage(
      utf8.encode(calendar(properties, method: 'REQUEST', zone: zone)),
    );
CalendarEventContent effective(
  CalendarInvitationOccurrenceProjection r,
  CalendarEventTiming original,
) => eventSchedulingOccurrence(r.content, r.timingOverrides, original)!;

void main() {
  for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
    for (final form in ['default', 'end', 'duration']) {
      test(
        '$profile range $form retains source and canonical timing forms',
        () {
          final date = profile == 'date';
          final zone = profile == 'Europe/Stockholm' ? profile : null;
          final b = basis(date: date, zone: zone), before = snapshot(b);
          final timing = form == 'default'
              ? <String>[]
              : form == 'duration'
              ? [date ? 'DURATION:P2D' : 'DURATION:PT2H']
              : [
                  date
                      ? 'DTEND;VALUE=DATE:20300105'
                      : zone == null
                      ? 'DTEND:20300102T130000Z'
                      : 'DTEND;TZID=$zone:20300102T130000',
                ];
          final m = incoming(
            date: date,
            zone: zone,
            future: true,
            timing: timing,
          );
          final r = projectRange(b, m), f = r.timingOverrides.future.single;
          expect(f.originalStart.start.day, 2);
          expect(f.replacement.start.day, date ? 3 : 2);
          expect(f.replacement.kind, b.content.timing.kind);
          expect(f.replacement.zoneId, zone);
          expect(f.replacement.duration != null, form == 'duration');
          expect(f.replacement.end != null, form == 'end');
          expect(r.timingOverrides.singles, isEmpty);
          expect(r.protocolState.version, b.protocolState.version);
          expect(r.protocolState.overrides.single.isThisAndFuture, isTrue);
          expect(r.protocolState.overrides.single.version.sequence, isNull);
          expect(identical(r.sourceMessage, m), isTrue);
          expect(snapshot(b), before);
        },
      );
    }
  }
  test('original ordering controls range; only timing propagates', () {
    final r = projectRange(
      basis(),
      incoming(future: true, summary: '', extra: ['LOCATION:']),
    );
    final anchor = effective(r, point(2)), later = effective(r, point(3));
    expect(anchor.summary, '');
    expect(anchor.location, '');
    expect(anchor.description, 'Beskrivning');
    expect(later.summary, 'Master');
    expect(later.location, 'Room');
    expect(later.timing.start.hour, 11);
    expect(effective(r, point(1)).timing.start.hour, 9);
  });
  test(
    'earlier/later ranges and independent singles retain values and versions',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=8');
      final single = CalendarEventSingleOverride(
        originalStart: point(4),
        replacement: point(1, hour: 15),
        contentOverrides: CalendarEventOccurrenceContent(summary: 'Single'),
      );
      final cancelled = CalendarEventSingleOverride(
        originalStart: point(6),
        cancelled: true,
      );
      final edits = CalendarEventTimingOverrides(
        singles: [single, cancelled],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(1),
            replacement: point(1, hour: 10),
          ),
          CalendarEventFutureOverride(
            originalStart: point(5),
            replacement: point(5, hour: 12),
          ),
        ],
      );
      final state = baseline(b, edits);
      final r = projectRange(
        b,
        incoming(future: true),
        edits: edits,
        state: state,
      );
      expect(r.timingOverrides.singles, edits.singles);
      expect(r.timingOverrides.future.first, edits.future.first);
      expect(r.timingOverrides.future.last, edits.future.last);
      for (final old in state.overrides) {
        expect(
          r.protocolState.overrides.singleWhere(
            (v) =>
                v.originalStart == old.originalStart &&
                v.isThisAndFuture == old.isThisAndFuture,
          ),
          old,
        );
      }
      expect(effective(r, point(3)).timing.start.hour, 11);
      expect(effective(r, point(4)).timing.start.hour, 15);
      expect(effective(r, point(4)).summary, 'Single');
      expect(effective(r, point(5)).timing.start.hour, 12);
      expect(effective(r, point(7)).timing.start.hour, 12);
      expect(() => effective(r, point(6)), throwsArgumentError);
    },
  );
  test('replacing the same range does not compound the old shift', () {
    final b = basis();
    final first = projectRange(
      b,
      incoming(future: true, timing: ['DURATION:PT1H']),
    );
    final m = raw([
      'RECURRENCE-ID;RANGE=THISANDFUTURE:20300102T090000Z',
      'DTSTART:20300102T120000Z',
      'DURATION:PT2H',
      'SUMMARY:Second',
      'SEQUENCE:0',
    ]);
    final second = projectRange(
      b,
      m,
      edits: first.timingOverrides,
      state: first.protocolState,
    );
    expect(second.timingOverrides.future, hasLength(1));
    expect(effective(second, point(3)).timing.start.hour, 12);
    expect(second.protocolState.overrides.single.version.sequence, 0);
    expect(first.protocolState.overrides.single.version.sequence, isNull);
    expect(second.content, b.content);
  });
  test('source timestamps and optional versions stay independent', () {
    final m = incoming(
      future: true,
      extra: [
        'SEQUENCE:0',
        'CREATED:20250101T000000Z',
        'LAST-MODIFIED:20251201T000000Z',
      ],
    );
    final b = basis(), r = projectRange(b, m);
    final version = r.protocolState.overrides.single.version;
    expect(version.sequence, 0);
    expect(version.stamp, DateTime.utc(2026));
    expect(version.created, DateTime.utc(2025));
    expect(version.lastModified, DateTime.utc(2025, 12));
    expect(r.protocolState.version, b.protocolState.version);
  });
  for (final original in ['20291230T090000Z', '20300105T090000Z']) {
    test('explicit addition $original retains exact membership', () {
      final b = basis(
        extra: [
          'RDATE:20291230T090000Z',
          'RDATE;VALUE=PERIOD:20300105T090000Z/PT2H',
        ],
      );
      final r = projectRange(b, incoming(future: true, original: original));
      expect(r.originalStart.start.day, original.startsWith('2029') ? 30 : 5);
      expect(r.content.periods, b.content.periods);
      expect(r.content.recurrence, b.content.recurrence);
    });
  }
  test('PERIOD-only series remains a series without a fabricated RRULE', () {
    final b = basis(rule: 'RDATE;VALUE=PERIOD:20300102T090000Z/PT2H');
    final r = projectRange(b, incoming(future: true));
    expect(r.content.recurrence?.rule, isNull);
    expect(r.content.periods, b.content.periods);
  });
  test(
    'same-anchor single and cancelled single both reject without deletion',
    () {
      for (final cancelled in [false, true]) {
        final b = basis(), before = snapshot(b);
        final edits = CalendarEventTimingOverrides(
          future: [],
          singles: [
            CalendarEventSingleOverride(
              originalStart: point(2),
              cancelled: cancelled,
              replacement: cancelled ? null : point(2, hour: 14),
            ),
          ],
        );
        expect(
          () => projectRange(
            b,
            incoming(future: true),
            edits: edits,
            state: baseline(b, edits),
          ),
          throwsArgumentError,
        );
        expect(edits.singles.single.cancelled, cancelled);
        expect(snapshot(b), before);
      }
    },
  );
  for (final mismatch in [
    'excluded',
    'absent',
    'zone',
    'recipient',
    'uid',
    'organizer',
    'cancelled master',
    'nonrecurring',
    'single',
    'cancel',
  ]) {
    test('$mismatch input rejects without mutating accepted values', () {
      final b = basis(
        extra: mismatch == 'excluded' ? ['EXDATE:20300102T090000Z'] : [],
      );
      final before = snapshot(b);
      final m = incoming(
        future: mismatch != 'single',
        cancel: mismatch == 'cancel',
        original: mismatch == 'absent' ? '20300109T090000Z' : null,
        zone: mismatch == 'zone' ? 'Europe/Stockholm' : null,
      );
      final actual = mismatch == 'organizer'
          ? parseIcalendarSchedulingMessage(
              utf8.encode(
                utf8
                    .decode(serializeIcalendarSchedulingMessage(m))
                    .replaceAll(
                      'mailto:organizer@example.invalid',
                      'mailto:other@example.invalid',
                    ),
              ),
            )
          : m;
      expect(
        () => projectRange(
          b,
          actual,
          uid: mismatch == 'uid' ? 'different@example.invalid' : null,
          recipient: mismatch == 'recipient'
              ? 'mailto:outsider@example.invalid'
              : 'mailto:alice@example.invalid',
          content: mismatch == 'cancelled master'
              ? b.content.copyWith(status: CalendarEventStatus.cancelled)
              : mismatch == 'nonrecurring'
              ? b.content.copyWith(recurrence: null)
              : null,
        ),
        throwsArgumentError,
      );
      expect(snapshot(b), before);
    });
  }
  for (final property in [
    'CLASS:PRIVATE',
    'URL:https://example.invalid/different',
    'CONTACT:Different',
    'TRANSP:TRANSPARENT',
    'STATUS:TENTATIVE',
  ]) {
    test('unsupported differing $property does not get discarded', () {
      final b = basis();
      expect(
        () => projectRange(b, incoming(future: true, extra: [property])),
        throwsArgumentError,
      );
    });
  }
  test(
    'matching richer source metadata and annotations survive projection',
    () {
      final b = basis(extra: ['CLASS:PUBLIC', 'CONTACT;LANGUAGE=sv:Kontakt']);
      final r = projectRange(
        b,
        incoming(
          future: true,
          extra: [
            'CLASS:PUBLIC',
            'CONTACT;LANGUAGE=sv:Kontakt',
            'DESCRIPTION;LANGUAGE=sv:Ankartext',
          ],
        ),
      );
      expect(
        r.timingOverrides.future.single.sourceMetadata!.classification,
        'PUBLIC',
      );
      expect(
        r.timingOverrides.future.single.sourceMetadata!.contacts.single.value,
        'Kontakt',
      );
      expect(
        r
            .timingOverrides
            .future
            .single
            .contentOverrides!
            .textParameters!
            .description!
            .language,
        'sv',
      );
    },
  );
  test('candidate and caller budgets fail explicitly without mutation', () {
    final b = basis(), before = snapshot(b);
    expect(
      () => projectRange(b, incoming(future: true), work: 1),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => projectRange(b, incoming(future: true), work: 0),
      throwsArgumentError,
    );
    expect(
      () => projectRange(b, incoming(future: true), work: 200001),
      throwsArgumentError,
    );
    expect(snapshot(b), before);
  });
  test('128 native slots stay independent from the smaller wire profile', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=200');
    CalendarEventTiming day(int offset) {
      final d = DateTime.utc(2030).add(Duration(days: offset));
      return point(1).copyWith(
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
        for (var i = 2; i < 129; i++)
          CalendarEventSingleOverride(originalStart: day(i), cancelled: true),
      ],
      future: [
        CalendarEventFutureOverride(
          originalStart: point(2),
          replacement: point(2, hour: 10),
        ),
      ],
    );
    final state = baseline(b, edits);
    final r = projectRange(
      b,
      incoming(future: true),
      edits: edits,
      state: state,
    );
    expect(r.timingOverrides.singles, hasLength(127));
    expect(r.timingOverrides.future, hasLength(1));
    expect(
      () => projectRange(
        b,
        incoming(future: true, original: '20300510T090000Z'),
        edits: edits,
        state: state,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'proposal/source collections are immutable and detached from input lists',
    () {
      final b = basis();
      final singles = [
        CalendarEventSingleOverride(originalStart: point(3), cancelled: true),
      ];
      final edits = CalendarEventTimingOverrides(singles: singles, future: []);
      final r = projectRange(
        b,
        incoming(future: true),
        edits: edits,
        state: baseline(b, edits),
      );
      singles.clear();
      expect(r.timingOverrides.singles, hasLength(1));
      expect(() => r.timingOverrides.future.clear(), throwsUnsupportedError);
      expect(() => r.protocolState.overrides.clear(), throwsUnsupportedError);
      expect(() => r.sourceMessage.events.clear(), throwsUnsupportedError);
    },
  );

  test('zoned shifts preserve civil hours across the spring transition', () {
    final b = basis(
      zone: 'Europe/Stockholm',
      start: 'DTSTART;TZID=Europe/Stockholm:20300330T090000',
    );
    final r = projectRange(
      b,
      raw([
        'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Europe/Stockholm:20300330T090000',
        'DTSTART;TZID=Europe/Stockholm:20300330T110000',
        'DURATION:PT1H',
        'SUMMARY:Anchor',
      ], zone: 'Europe/Stockholm'),
    );
    CalendarEventTiming original(int day) => b.content.timing.copyWith(
      start: CalendarEventCivil(year: 2030, month: 3, day: day, hour: 9),
      duration: null,
      end: null,
    );
    final next = effective(r, original(31));
    expect(next.timing.start.hour, 11);
    expect(
      validateEventTiming(next.timing).$2!.start.instant,
      DateTime.utc(2030, 3, 31, 9),
    );
    expect(next.summary, 'Master');
  });
  for (final duration in ['P1D', 'PT24H']) {
    test('$duration retains nominal/elapsed meaning across DST', () {
      final b = basis(
        zone: 'Europe/Stockholm',
        start: 'DTSTART;TZID=Europe/Stockholm:20300330T090000',
      );
      final r = projectRange(
        b,
        raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Europe/Stockholm:20300330T090000',
          'DTSTART;TZID=Europe/Stockholm:20300330T090000',
          'DURATION:$duration',
          'SUMMARY:Anchor',
        ], zone: 'Europe/Stockholm'),
      );
      final span = validateEventTiming(
        r.timingOverrides.future.single.replacement,
      ).$2!;
      expect(
        span.endExclusive.difference(span.start.instant).inHours,
        duration == 'P1D' ? 23 : 24,
      );
    });
  }
  for (final fold in [false, true]) {
    test('explicit ${fold ? 'fold' : 'gap'} replacement uses native RFC policy', () {
      final date = fold ? '20301027' : '20300331';
      final month = fold ? 10 : 3, day = fold ? 27 : 31;
      final b = basis(
        zone: 'Europe/Stockholm',
        start: 'DTSTART;TZID=Europe/Stockholm:${date}T090000',
      );
      final r = projectRange(
        b,
        raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Europe/Stockholm:${date}T090000',
          'DTSTART;TZID=Europe/Stockholm:${date}T023000',
          'DURATION:PT1H',
          'SUMMARY:Anchor',
        ], zone: 'Europe/Stockholm'),
      );
      expect(
        validateEventTiming(r.timingOverrides.future.single.replacement)
            .$2!
            .start
            .instant,
        DateTime.utc(2030, month, day, fold ? 0 : 1, 30),
      );
    });
  }
  test('a recurrence-generated gap is not a valid original', () {
    final b = basis(
      zone: 'Europe/Stockholm',
      start: 'DTSTART;TZID=Europe/Stockholm:20300330T023000',
    );
    expect(
      () => projectRange(
        b,
        raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Europe/Stockholm:20300331T023000',
          'DTSTART;TZID=Europe/Stockholm:20300331T043000',
          'SUMMARY:Anchor',
        ], zone: 'Europe/Stockholm'),
      ),
      throwsArgumentError,
    );
  });
  test(
    'exclusive 2100 endpoint is retained while ordinary starts remain bounded',
    () {
      final b = basis(
        start: 'DTSTART:20991230T090000Z',
        rule: 'RRULE:FREQ=DAILY;COUNT=2',
      );
      final r = projectRange(
        b,
        raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE:20991231T090000Z',
          'DTSTART:20991231T230000Z',
          'DTEND:21000101T000000Z',
          'SUMMARY:Last',
        ]),
      );
      expect(r.timingOverrides.future.single.replacement.end!.year, 2100);
      expect(
        () => raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE:20991231T090000Z',
          'DTSTART:21000101T000000Z',
          'SUMMARY:Outside',
        ]),
        throwsA(isA<IcalendarComponentException>()),
      );
      expect(
        () => raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE:20991231T090000Z',
          'DTSTART:20991231T230000.5Z',
          'SUMMARY:Fraction',
        ]),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
  test('the inclusive lower horizon boundary can be a range original', () {
    final b = basis(
      start: 'DTSTART:19700101T090000Z',
      rule: 'RRULE:FREQ=DAILY;COUNT=2',
    );
    final r = projectRange(
      b,
      raw([
        'RECURRENCE-ID;RANGE=THISANDFUTURE:19700101T090000Z',
        'DTSTART:19700101T110000Z',
        'SUMMARY:First',
      ]),
    );
    expect(r.originalStart.start.year, 1970);
    expect(r.content.timing.start.hour, 9);
  });
  test('caller-expanded syntax limits cannot bypass source limits', () {
    final dates = List.filled(5000, '19800101T000000').join(',');
    final text = calendar(
      [
        'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Etc/UTC:20300102T090000',
        'DTSTART;TZID=Etc/UTC:20300102T110000',
        'SUMMARY:Anchor',
      ],
      method: 'REQUEST',
      zone: 'Etc/UTC',
    ).replaceFirst('END:STANDARD', 'RDATE:$dates\r\nEND:STANDARD');
    final m = parseIcalendarSchedulingMessage(
      utf8.encode(text),
      syntaxLimits: const IcalendarSyntaxLimits(
        maxPhysicalLineBytes: 200000,
        maxUnfoldedLineBytes: 200000,
      ),
    );
    expect(
      () => projectRange(basis(zone: 'Etc/UTC'), m),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('delegated organizer/attendee claims do not become authority', () {
    final b = basis();
    final source = utf8.decode(
      serializeIcalendarSchedulingMessage(incoming(future: true)),
    );
    for (final prefix in ['ORGANIZER', 'ATTENDEE']) {
      final delegated = source.replaceFirst(
        '$prefix:',
        '$prefix;SENT-BY="mailto:delegate@example.invalid":',
      );
      final m = parseIcalendarSchedulingMessage(utf8.encode(delegated));
      expect(() => projectRange(b, m), throwsArgumentError);
    }
    final state = b.protocolState.copyWith(
      sourceMetadata: b.protocolState.sourceMetadata!.copyWith(attendees: []),
    );
    expect(
      () => projectRange(b, incoming(future: true), state: state),
      throwsArgumentError,
    );
  });
  test(
    'bundled source cannot bypass the one-component projection boundary',
    () {
      final text = utf8.decode(
        serializeIcalendarSchedulingMessage(incoming(future: true)),
      );
      final second = text
          .substring(
            text.indexOf('BEGIN:VEVENT'),
            text.indexOf('END:VEVENT') + 'END:VEVENT'.length,
          )
          .replaceAll('20300102', '20300103');
      final m = parseIcalendarSchedulingMessage(
        utf8.encode(
          text.replaceFirst('END:VCALENDAR', '$second\r\nEND:VCALENDAR'),
        ),
      );
      expect(m.events, hasLength(2));
      expect(() => projectRange(basis(), m), throwsArgumentError);
    },
  );
  test(
    'accepted unarmed master alarms remain intact without source invention',
    () {
      const alarm = [
        'BEGIN:VALARM',
        'ACTION:DISPLAY',
        'TRIGGER:-PT10M',
        'DESCRIPTION:Reminder',
        'END:VALARM',
      ];
      final b = basis(extra: alarm);
      final r = projectRange(b, incoming(future: true));
      expect(
        r.protocolState.sourceMetadata!.alarms,
        b.protocolState.sourceMetadata!.alarms,
      );
      expect(
        utf8.decode(serializeIcalendarSchedulingMessage(r.sourceMessage)),
        isNot(contains('BEGIN:VALARM')),
      );
    },
  );
  test(
    'scheduling source alarms still reject before projection, never stripped',
    () {
      expect(
        () => incoming(
          future: true,
          extra: [
            'BEGIN:VALARM',
            'ACTION:DISPLAY',
            'TRIGGER:-PT10M',
            'DESCRIPTION:Reminder',
            'END:VALARM',
          ],
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
  test(
    'ordinary REQUEST requirements remain: absent SUMMARY is not repaired',
    () {
      expect(
        () => raw([
          'RECURRENCE-ID;RANGE=THISANDFUTURE:20300102T090000Z',
          'DTSTART:20300102T110000Z',
        ]),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
}
