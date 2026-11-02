@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

import 'invitation_occurrence_values_test.dart'
    show basis, incoming, calendar, snapshot;

IcalendarSchedulingMessage cancellation({
  bool date = false,
  String? zone,
  String? original,
  int sequence = 8,
  List<String> extra = const [],
}) => parseIcalendarSchedulingMessage(
  utf8.encode(
    calendar(
      [
        date
            ? 'RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:${original ?? '20300102'}'
            : 'RECURRENCE-ID;RANGE=THISANDFUTURE${zone == null ? '' : ';TZID=$zone'}:${original ?? (zone == null ? '20300102T090000Z' : '20300102T090000')}',
        'SEQUENCE:$sequence',
        'STATUS:CANCELLED',
        ...extra,
      ],
      method: 'CANCEL',
      zone: zone,
    ),
  ),
);
CalendarEventTiming point(int day, {int hour = 9}) => CalendarEventTiming(
  kind: CalendarEventTimeKind.utc,
  start: CalendarEventCivil(year: 2030, month: 1, day: day, hour: hour),
);
CalendarEventProtocolState versions(
  EventStorageProposal b,
  CalendarEventTimingOverrides? edits, {
  int? master = 7,
  Map<String, int?> own = const {},
}) {
  final state = eventProtocolBaseline(
    b.content,
    edits?.copyWith(
      singles: [
        for (final v in edits.singles) v.copyWith(sourceMetadata: null),
      ],
      future: [for (final v in edits.future) v.copyWith(sourceMetadata: null)],
    ),
    DateTime.utc(2026),
    DateTime.utc(2026),
  );
  return state.copyWith(
    sourceMetadata: b.protocolState.sourceMetadata,
    version: b.protocolState.version.copyWith(sequence: master),
    overrides: [
      for (final v in state.overrides)
        v.copyWith(
          version: v.version.copyWith(
            sequence:
                own['${v.isThisAndFuture ? 'R' : 'S'}:${v.originalStart.start.day}'],
          ),
        ),
    ],
  );
}

CalendarInvitationRangeCancellationProjection project(
  EventStorageProposal b,
  IcalendarSchedulingMessage message, {
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState? state,
  CalendarEventContent? content,
  String? uid,
  String recipient = 'mailto:alice@example.invalid',
  int work = eventMaxCandidateWork,
}) => projectInvitationRangeCancellation(
  protocolUid: uid ?? b.protocolUid,
  content: content ?? b.content,
  timingOverrides: edits ?? b.edits,
  protocolState: state ?? b.protocolState,
  message: message,
  recipientAddress: recipient,
  maxCandidateWork: work,
);
final argument = throwsArgumentError;
final limit = throwsA(isA<RecurrenceLimitException>());

void main() {
  for (final original in [
    '19691231T090000Z',
    '21000101T000000Z',
    '20300102T090000.0Z',
    '20300102T090000',
    '20300102T090060Z',
  ]) {
    test('unsupported wire original rejects: $original', () {
      expect(
        () => cancellation(original: original),
        throwsA(isA<IcalendarComponentException>()),
      );
    });
  }
  test('CANCEL without explicit SEQUENCE rejects at the message boundary', () {
    expect(
      () => parseIcalendarSchedulingMessage(
        utf8.encode(
          calendar([
            'RECURRENCE-ID;RANGE=THISANDFUTURE:20300102T090000Z',
            'STATUS:CANCELLED',
          ], method: 'CANCEL'),
        ),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
  test(
    'inert organizer and recipient claims must still match the supplied basis',
    () {
      final b = basis(),
          text = utf8.decode(
            serializeIcalendarSchedulingMessage(cancellation()),
          );
      final wrongOrganizer = parseIcalendarSchedulingMessage(
        utf8.encode(
          text.replaceFirst(
            'mailto:organizer@example.invalid',
            'mailto:other@example.invalid',
          ),
        ),
      );
      expect(() => project(b, wrongOrganizer), argument);
      final missingRecipient = parseIcalendarSchedulingMessage(
        utf8.encode(
          text.replaceFirst('ATTENDEE:mailto:alice@example.invalid\r\n', ''),
        ),
      );
      expect(() => project(b, missingRecipient), argument);
    },
  );
  for (final prefix in ['ORGANIZER', 'ATTENDEE']) {
    test('delegated $prefix claim is never authority', () {
      final text = utf8.decode(
        serializeIcalendarSchedulingMessage(cancellation()),
      );
      final message = parseIcalendarSchedulingMessage(
        utf8.encode(
          text.replaceFirst(
            '$prefix:',
            '$prefix;SENT-BY="mailto:delegate@example.invalid":',
          ),
        ),
      );
      expect(() => project(basis(), message), argument);
    });
  }
  test(
    'generated DST gap original rejects, but explicit inclusion is retained',
    () {
      const zone = 'Europe/Stockholm';
      final b = basis(zone: zone, start: 'DTSTART;TZID=$zone:20300330T023000');
      final m = cancellation(zone: zone, original: '20300331T023000');
      expect(() => project(b, m), argument);
      final explicit = basis(
        zone: zone,
        start: 'DTSTART;TZID=$zone:20300330T023000',
        extra: ['RDATE;TZID=$zone:20300331T023000'],
      );
      expect(project(explicit, m).originalStart.start.minute, 30);
    },
  );
  test('a last-member anchor single still requires the underlying version', () {
    final b = basis();
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: point(3), cancelled: true),
      ],
      future: [],
    );
    final state = versions(b, edits, master: 20, own: {'S:3': 2});
    expect(
      () => project(
        b,
        cancellation(original: '20300103T090000Z', sequence: 3),
        edits: edits,
        state: state,
      ),
      argument,
    );
    expect(
      project(
        b,
        cancellation(original: '20300103T090000Z', sequence: 21),
        edits: edits,
        state: state,
      ).requiredAfterSequence,
      20,
    );
  });
  for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
    test(
      '$profile minimal cancellation retains basis, omissions and independent versions',
      () {
        final date = profile == 'date',
            zone = profile == 'Europe/Stockholm' ? profile : null;
        final b = basis(date: date, zone: zone), before = snapshot(b);
        final m = cancellation(
          date: date,
          zone: zone,
          extra: ['CREATED:20200101T000000Z', 'LAST-MODIFIED:20210101T000000Z'],
        );
        final r = project(b, m);
        expect(r.requiredAfterSequence, 7);
        expect(r.cancellationVersion.sequence, 8);
        expect(r.cancellationVersion.stamp, m.events.single.stamp);
        expect(r.cancellationVersion.created, DateTime.utc(2020));
        expect(r.cancellationVersion.lastModified, DateTime.utc(2021));
        expect(r.protocolState.toJson(), b.protocolState.toJson());
        expect(r.content.toJson(), b.content.toJson());
        expect(
          r.timingOverrides.cancelledFrom!.toJson(),
          r.originalStart.toJson(),
        );
        expect(r.timingOverrides.singles, isEmpty);
        expect(r.timingOverrides.future, isEmpty);
        expect(r.originalStart.kind, b.content.timing.kind);
        expect(r.originalStart.zoneId, zone);
        expect(r.sourceMessage.events.single.startTime, isNull);
        expect(r.sourceMessage.events.single.startDate, isNull);
        expect(r.sourceMessage.events.single.summary, isNull);
        expect(identical(r.sourceMessage, m), isTrue);
        expect(snapshot(b), before);
        expect(() => r.timingOverrides.singles.clear(), throwsUnsupportedError);
        expect(() => r.protocolState.overrides.clear(), throwsUnsupportedError);
        expect(
          () => validateEventImportBaseline(
            eventImportBaseline(
              r.protocolUid,
              r.content,
              r.timingOverrides,
              r.protocolState,
            ),
            r.protocolUid,
          ),
          throwsStateError,
        );
      },
    );
    for (final form in ['end', 'duration']) {
      test(
        '$profile matching $form is checked without changing retained timing form',
        () {
          final date = profile == 'date',
              zone = profile == 'Europe/Stockholm' ? profile : null;
          final b = basis(date: date, zone: zone);
          final start = date
              ? 'DTSTART;VALUE=DATE:20300102'
              : zone == null
              ? 'DTSTART:20300102T090000Z'
              : 'DTSTART;TZID=$zone:20300102T090000';
          final end = date
              ? 'DTEND;VALUE=DATE:20300103'
              : zone == null
              ? 'DTEND:20300102T100000Z'
              : 'DTEND;TZID=$zone:20300102T100000';
          final r = project(
            b,
            cancellation(
              date: date,
              zone: zone,
              extra: [
                start,
                form == 'end'
                    ? end
                    : date
                    ? 'DURATION:P1D'
                    : 'DURATION:PT1H',
              ],
            ),
          );
          expect(r.content.timing.toJson(), b.content.timing.toJson());
          expect(
            r.sourceMessage.events.single.duration != null,
            form == 'duration',
          );
        },
      );
    }
  }
  for (final sequence in [0, 6, 7]) {
    test(
      'equal/lower incoming SEQUENCE $sequence rejects without timestamp fallback',
      () {
        final m = cancellation(sequence: sequence);
        final later = parseIcalendarSchedulingMessage(
          utf8.encode(
            utf8
                .decode(serializeIcalendarSchedulingMessage(m))
                .replaceFirst(
                  'DTSTAMP:20260101T000000Z',
                  'DTSTAMP:20350101T000000Z',
                ),
          ),
        );
        expect(() => project(basis(), later), argument);
      },
    );
  }
  test('older source timestamp with higher sequence is retained exactly', () {
    final m = parseIcalendarSchedulingMessage(
      utf8.encode(
        utf8
            .decode(serializeIcalendarSchedulingMessage(cancellation()))
            .replaceFirst(
              'DTSTAMP:20260101T000000Z',
              'DTSTAMP:20200101T000000Z',
            ),
      ),
    );
    expect(project(basis(), m).cancellationVersion.stamp, DateTime.utc(2020));
  });
  test('missing accepted sequences compare as zero and stay absent', () {
    final b = basis(), state = versions(b, null, master: null);
    final r = project(b, cancellation(sequence: 1), state: state);
    expect(r.requiredAfterSequence, 0);
    expect(r.protocolState.version.sequence, isNull);
    expect(r.cancellationVersion.created, isNull);
    expect(r.cancellationVersion.lastModified, isNull);
    expect(() => project(b, cancellation(sequence: 0), state: state), argument);
  });
  test('maximum comparison never overflows or invents a newer version', () {
    final b = basis();
    expect(
      project(
        b,
        cancellation(sequence: eventMaxSequence),
      ).cancellationVersion.sequence,
      eventMaxSequence,
    );
    expect(
      () => project(
        b,
        cancellation(sequence: eventMaxSequence),
        state: versions(b, null, master: eventMaxSequence),
      ),
      argument,
    );
  });
  test('anchor single cannot hide a newer underlying master', () {
    final b = basis();
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: point(2), cancelled: true),
      ],
      future: [],
    );
    final state = versions(b, edits, master: 20, own: {'S:2': 2});
    expect(
      () => project(b, cancellation(sequence: 3), edits: edits, state: state),
      argument,
    );
    final r = project(
      b,
      cancellation(sequence: 21),
      edits: edits,
      state: state,
    );
    expect(r.requiredAfterSequence, 20);
    expect(r.timingOverrides.singles.single.cancelled, isTrue);
    expect(r.protocolState.toJson(), state.toJson());
  });
  test('underlying range is checked beneath the selected single', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=8');
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: point(2), cancelled: true),
      ],
      future: [
        CalendarEventFutureOverride(
          originalStart: point(1),
          replacement: point(1)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
        ),
      ],
    );
    final state = versions(b, edits, master: 99, own: {'R:1': 12, 'S:2': 2});
    expect(
      () => project(b, cancellation(sequence: 12), edits: edits, state: state),
      argument,
    );
    expect(
      project(
        b,
        cancellation(sequence: 13),
        edits: edits,
        state: state,
      ).requiredAfterSequence,
      12,
    );
  });
  test('later components count by original order; superseded earlier versions do not', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=8');
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: point(2),
          replacement: point(8)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
          cancelled: false,
        ),
        CalendarEventSingleOverride(
          originalStart: point(6),
          replacement: point(1)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
          cancelled: false,
        ),
      ],
      future: [
        CalendarEventFutureOverride(
          originalStart: point(1),
          replacement: point(1)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
        ),
        CalendarEventFutureOverride(
          originalStart: point(3),
          replacement: point(3)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
        ),
      ],
    );
    final state = versions(
      b,
      edits,
      master: 100,
      own: {'R:1': 99, 'S:2': 88, 'R:3': 3, 'S:6': 4},
    );
    final r = project(
      b,
      cancellation(original: '20300104T090000Z', sequence: 5),
      edits: edits,
      state: state,
    );
    expect(r.requiredAfterSequence, 4);
    expect(r.protocolState.toJson(), state.toJson());
    expect(
      r.timingOverrides.singles.map((v) => v.toJson()),
      edits.singles.map((v) => v.toJson()),
    );
    expect(
      () => project(
        b,
        cancellation(original: '20300104T090000Z', sequence: 4),
        edits: edits,
        state: state,
      ),
      argument,
    );
  });
  test(
    'co-located future component is retained instead of replaced by CANCEL',
    () {
      final b = basis(extra: ['URL:https://example.invalid/anchor']);
      final own = CalendarEventSourceMetadata(
        categoryGroups: [],
        comments: [],
        contacts: [],
        url: 'https://example.invalid/anchor',
      );
      final edits = CalendarEventTimingOverrides(
        singles: [],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(2),
            replacement: point(3)
                .copyWith(duration: CalendarEventDuration(hours: 1)),
            contentOverrides: CalendarEventOccurrenceContent(summary: 'Own'),
            sourceMetadata: own,
          ),
        ],
      );
      final state = versions(b, edits, own: {'R:2': 11});
      final r = project(
        b,
        cancellation(
          sequence: 12,
          extra: [
            'DTSTART:20300103T090000Z',
            'SUMMARY:Own',
            'URL:https://example.invalid/anchor',
          ],
        ),
        edits: edits,
        state: state,
      );
      expect(r.requiredAfterSequence, 11);
      expect(
        r.timingOverrides.future.single.toJson(),
        edits.future.single.toJson(),
      );
      expect(r.protocolState.toJson(), state.toJson());
      expect(
        () => project(
          b,
          cancellation(sequence: 12, extra: ['SUMMARY:Master']),
          edits: edits,
          state: state,
        ),
        argument,
      );
    },
  );
  test('matching single own metadata/text preserves annotations and cancellation flag', () {
    final b = basis(extra: ['URL:https://example.invalid/single']);
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(
          originalStart: point(2),
          replacement: point(3)
              .copyWith(duration: CalendarEventDuration(hours: 2)),
          cancelled: true,
          contentOverrides: CalendarEventOccurrenceContent(
            summary: 'Own',
            textParameters: CalendarEventTextParameters(
              summary: CalendarTextParameters(language: 'sv'),
            ),
          ),
          sourceMetadata: CalendarEventSourceMetadata(
            categoryGroups: [],
            comments: [],
            contacts: [],
            url: 'https://example.invalid/single',
          ),
        ),
      ],
      future: [],
    );
    final state = versions(b, edits);
    final r = project(
      b,
      cancellation(
        extra: [
          'DTSTART:20300103T090000Z',
          'DURATION:PT2H',
          'SUMMARY;LANGUAGE=sv:Own',
          'URL:https://example.invalid/single',
        ],
      ),
      edits: edits,
      state: state,
    );
    expect(
      r.timingOverrides.singles.single.toJson(),
      edits.singles.single.toJson(),
    );
    expect(
      () => project(
        b,
        cancellation(extra: ['SUMMARY;LANGUAGE=en:Own']),
        edits: edits,
        state: state,
      ),
      argument,
    );
  });
  test('later individual cancellation version still raises the floor', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=6');
    final edits = CalendarEventTimingOverrides(
      singles: [
        CalendarEventSingleOverride(originalStart: point(5), cancelled: true),
      ],
      future: [],
    );
    final state = versions(b, edits, own: {'S:5': 15});
    expect(
      () => project(b, cancellation(), edits: edits, state: state),
      argument,
    );
    expect(
      project(
        b,
        cancellation(sequence: 16),
        edits: edits,
        state: state,
      ).requiredAfterSequence,
      15,
    );
  });
  test('later timing ranges raise the floor even when moved earlier', () {
    final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=6');
    final edits = CalendarEventTimingOverrides(
      singles: [],
      future: [
        CalendarEventFutureOverride(
          originalStart: point(5),
          replacement: point(1)
              .copyWith(duration: CalendarEventDuration(hours: 1)),
        ),
      ],
    );
    final state = versions(b, edits, own: {'R:5': 18});
    expect(
      () => project(b, cancellation(sequence: 18), edits: edits, state: state),
      argument,
    );
    expect(
      project(
        b,
        cancellation(sequence: 19),
        edits: edits,
        state: state,
      ).requiredAfterSequence,
      18,
    );
  });
  for (final extra in [
    'DTSTART:20300102T100000Z',
    'DTEND:20300102T110000Z',
    'DURATION:PT2H',
    'SUMMARY:Different',
    'TRANSP:TRANSPARENT',
    'URL:https://example.invalid/different',
    'RRULE:FREQ=DAILY;COUNT=3',
    'RDATE:20300103T090000Z',
    'EXDATE:20300103T090000Z',
  ]) {
    test(
      'supplied differing/unprofiled property rejects: ${extra.split(':').first}',
      () {
        if (['RRULE', 'RDATE', 'EXDATE'].contains(extra.split(':').first)) {
          expect(
            () => cancellation(extra: [extra]),
            throwsA(isA<IcalendarComponentException>()),
          );
        } else {
          expect(
            () => project(basis(), cancellation(extra: [extra])),
            argument,
          );
        }
      },
    );
  }
  test(
    'earlier DATE inclusion and UTC PERIOD retain exact identities/forms',
    () {
      final date = basis(date: true, extra: ['RDATE;VALUE=DATE:20291230']);
      final r = project(date, cancellation(date: true, original: '20291230'));
      expect(r.originalStart.start.year, 2029);
      expect(r.content.toJson(), date.content.toJson());
      final timed = basis(extra: ['RDATE;VALUE=PERIOD:20291230T090000Z/PT2H']);
      final p = project(
        timed,
        cancellation(original: '20291230T090000Z', extra: ['DURATION:PT2H']),
      );
      expect(p.content.periods!.single.duration!.hours, 2);
      expect(p.content.toJson(), timed.content.toJson());
    },
  );
  for (final (month, day, hours) in [(3, 30, 23), (10, 26, 25)]) {
    test('nominal retained duration spans $hours hours across DST', () {
      const zone = 'Europe/Stockholm';
      final dayText = day.toString().padLeft(2, '0'),
          monthText = month.toString().padLeft(2, '0');
      final b = basis(
        zone: zone,
        start: 'DTSTART;TZID=$zone:2030$monthText${dayText}T090000',
      );
      final c = b.content.copyWith(
        timing: b.content.timing.copyWith(
          duration: CalendarEventDuration(days: 1),
        ),
      );
      final r = project(
        b,
        cancellation(zone: zone, original: '2030$monthText${day + 1}T090000'),
        content: c,
      );
      final occupied = eventOccupiedWindows(
        r.content,
        r.timingOverrides,
        UtcWindow(
          start: DateTime.utc(2030, month, day - 1),
          end: DateTime.utc(2030, month + 1, 3),
        ),
        dateZone: zone,
      );
      expect(occupied.single.duration.inHours, hours);
      expect(r.content.timing.duration!.days, 1);
    });
  }
  test('current cutoff, orphan, excluded and whole-cancelled basis reject', () {
    final b = basis();
    final mask = CalendarEventTimingOverrides(
      singles: [],
      future: [],
      cancelledFrom: point(2),
    );
    expect(() => project(b, cancellation(), edits: mask), argument);
    expect(
      () => project(b, cancellation(original: '20300109T090000Z')),
      argument,
    );
    expect(
      () => project(basis(extra: ['EXDATE:20300102T090000Z']), cancellation()),
      argument,
    );
    expect(
      () => project(
        b,
        cancellation(),
        content: b.content.copyWith(status: CalendarEventStatus.cancelled),
      ),
      argument,
    );
  });
  test(
    'identity recipient and temporal profile mismatches reject without echo',
    () {
      final b = basis();
      expect(
        () => project(
          b,
          cancellation(),
          recipient: 'mailto:private@example.invalid',
        ),
        argument,
      );
      expect(() => project(b, cancellation(date: true)), argument);
      expect(() => project(b, cancellation(zone: 'Etc/UTC')), argument);
      try {
        project(b, cancellation(), uid: 'PRIVATE-UID');
        fail('Expected rejection');
      } on ArgumentError catch (e) {
        expect(e.toString(), isNot(contains('PRIVATE-UID')));
      }
    },
  );
  test(
    'single REQUEST/single CANCEL/whole CANCEL/attendee removal stay separate',
    () {
      final b = basis();
      for (final m in [
        incoming(future: true),
        incoming(cancel: true),
        parseIcalendarSchedulingMessage(
          utf8.encode(
            calendar(['SEQUENCE:8', 'STATUS:CANCELLED'], method: 'CANCEL'),
          ),
        ),
        parseIcalendarSchedulingMessage(
          utf8.encode(
            calendar([
              'RECURRENCE-ID;RANGE=THISANDFUTURE:20300102T090000Z',
              'SEQUENCE:8',
            ], method: 'CANCEL'),
          ),
        ),
      ]) {
        expect(() => project(b, m), argument);
      }
    },
  );
  test(
    'shared work and raw source ceilings cannot yield partial proposals',
    () {
      final b = basis();
      expect(() => project(b, cancellation(), work: 1), limit);
      expect(() => project(b, cancellation(), work: 0), argument);
      expect(
        () => project(b, cancellation(), work: eventMaxCandidateWork + 1),
        argument,
      );
      final dates = List.filled(5000, '19800101T000000').join(',');
      final text = calendar(
        [
          'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Etc/UTC:20300102T090000',
          'SEQUENCE:8',
          'STATUS:CANCELLED',
        ],
        method: 'CANCEL',
        zone: 'Etc/UTC',
      ).replaceFirst('END:STANDARD', 'RDATE:$dates\r\nEND:STANDARD');
      final m = parseIcalendarSchedulingMessage(
        utf8.encode(text),
        syntaxLimits: const IcalendarSyntaxLimits(
          maxPhysicalLineBytes: 200000,
          maxUnfoldedLineBytes: 200000,
        ),
      );
      expect(() => project(basis(zone: 'Etc/UTC'), m), limit);
    },
  );
  test(
    'large native sets are preserved; cutoff still costs one of 128 slots',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=130');
      CalendarEventSingleOverride single(int i) {
        final d = DateTime.utc(2030).add(Duration(days: i));
        return CalendarEventSingleOverride(
          originalStart: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(
              year: d.year,
              month: d.month,
              day: d.day,
              hour: 9,
            ),
          ),
          cancelled: true,
        );
      }

      final list = [for (var i = 0; i < 127; i++) single(i)];
      final edits = CalendarEventTimingOverrides(singles: list, future: []);
      final state = versions(b, edits);
      final r = project(b, cancellation(), edits: edits, state: state);
      expect(r.timingOverrides.singles.length, 127);
      list.clear();
      state.overrides.clear();
      expect(r.timingOverrides.singles.length, 127);
      expect(r.protocolState.overrides.length, 127);
      final full = CalendarEventTimingOverrides(
        singles: [for (var i = 0; i < 128; i++) single(i)],
        future: [],
      );
      expect(
        () => project(b, cancellation(), edits: full, state: versions(b, full)),
        limit,
      );
    },
  );
  test(
    'source alarms reject while accepted unarmed alarms remain untouched',
    () {
      final b = basis(
        extra: [
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'TRIGGER:-PT15M',
          'DESCRIPTION:Reminder',
          'END:VALARM',
        ],
      );
      final r = project(b, cancellation());
      expect(r.protocolState.sourceMetadata!.alarms!.length, 1);
      expect(r.protocolState.toJson(), b.protocolState.toJson());
      expect(
        () => project(
          b,
          cancellation(
            extra: [
              'BEGIN:VALARM',
              'ACTION:DISPLAY',
              'TRIGGER:-PT15M',
              'DESCRIPTION:Reminder',
              'END:VALARM',
            ],
          ),
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
}
