@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_storage.dart';

import 'invitation_occurrence_values_test.dart' show basis, calendar, snapshot;
import 'invitation_range_cancellation_values_test.dart'
    show cancellation, point, versions;
import 'invitation_range_restoration_values_test.dart' show request, changed;

CalendarEventProtocolVersion previous({int? sequence = 10, DateTime? stamp}) =>
    CalendarEventProtocolVersion(
      sequence: sequence,
      stamp: stamp ?? DateTime.utc(2035),
    );
CalendarInvitationRangeRecancellationProjection recancel(
  EventStorageProposal b,
  IcalendarSchedulingMessage message, {
  CalendarEventProtocolVersion? restoration,
  CalendarEventTimingOverrides? edits,
  CalendarEventProtocolState? state,
  CalendarEventContent? content,
  String? uid,
  String recipient = 'mailto:alice@example.invalid',
  int work = eventMaxCandidateWork,
}) => projectInvitationRangeRecancellation(
  protocolUid: uid ?? b.protocolUid,
  content: content ?? b.content,
  timingOverrides: edits ?? b.edits,
  protocolState: state ?? b.protocolState,
  previousRestorationVersion: restoration ?? previous(),
  message: message,
  recipientAddress: recipient,
  maxCandidateWork: work,
);

void main() {
  for (final profile in ['date', 'utc', 'Europe/Stockholm']) {
    final date = profile == 'date',
        zone = profile == 'Europe/Stockholm' ? profile : null;
    test(
      '$profile repeated same/different-anchor pure cycles preserve canonical values',
      () {
        final b = basis(date: date, zone: zone), before = snapshot(b);
        var control = previous();
        var content = b.content;
        var edits = b.edits;
        var protocol = b.protocolState;
        for (final day in [2, 3, 2]) {
          final original =
              '2030010$day${date
                  ? ''
                  : zone == null
                  ? 'T090000Z'
                  : 'T090000'}';
          final c = recancel(
            b,
            cancellation(
              date: date,
              zone: zone,
              original: original,
              sequence: control.sequence! + 1,
            ),
            restoration: control,
            content: content,
            edits: edits,
            state: protocol,
          );
          expect(c.requiredAfterSequence, control.sequence);
          expect(c.previousRestorationVersion.toJson(), control.toJson());
          expect(c.protocolState.toJson(), b.protocolState.toJson());
          expect(c.sourceMessage.events.single.startTime, isNull);
          expect(c.sourceMessage.events.single.startDate, isNull);
          expect(c.sourceMessage.events.single.summary, isNull);
          final start = date
              ? 'DTSTART;VALUE=DATE:$original'
              : zone == null
              ? 'DTSTART:$original'
              : 'DTSTART;TZID=$zone:$original';
          final restored = projectInvitationRangeRestoration(
            protocolUid: b.protocolUid,
            content: c.content,
            timingOverrides: c.timingOverrides,
            protocolState: c.protocolState,
            cancellationVersion: c.cancellationVersion,
            message: request(
              date: date,
              zone: zone,
              original: original,
              start: start,
              sequence: c.cancellationVersion.sequence! + 1,
            ),
            recipientAddress: 'mailto:alice@example.invalid',
          );
          expect(restored.timingOverrides, isNull);
          expect(restored.content.toJson(), b.content.toJson());
          expect(restored.protocolState.toJson(), b.protocolState.toJson());
          control = restored.restorationVersion;
          content = restored.content;
          edits = restored.timingOverrides;
          protocol = restored.protocolState;
        }
        expect(control.sequence, 16);
        expect(snapshot(b), before);
      },
    );
  }
  for (final (master, history, source, valid) in [
    (7, 10, 9, false),
    (7, 10, 10, false),
    (7, 10, 11, true),
    (20, 10, 11, false),
    (20, 10, 20, false),
    (20, 10, 21, true),
  ]) {
    test(
      'independent floors canonical=$master history=$history source=$source',
      () {
        final b = basis(),
            m = changed(
              cancellation(sequence: source),
              'DTSTAMP:20260101T000000Z',
              'DTSTAMP:20400101T000000Z',
            );
        final state = versions(b, null, master: master);
        if (!valid) {
          expect(
            () => recancel(
              b,
              m,
              state: state,
              restoration: previous(sequence: history),
            ),
            throwsArgumentError,
          );
        } else {
          final result = recancel(
            b,
            m,
            state: state,
            restoration: previous(sequence: history),
          );
          expect(
            result.requiredAfterSequence,
            master > history ? master : history,
          );
        }
      },
    );
  }
  test('first helper retains its canonical-only contract', () {
    final b = basis(), m = cancellation();
    expect(
      projectInvitationRangeCancellation(
        protocolUid: b.protocolUid,
        content: b.content,
        protocolState: b.protocolState,
        message: m,
        recipientAddress: 'mailto:alice@example.invalid',
      ).requiredAfterSequence,
      7,
    );
    expect(() => recancel(b, m), throwsArgumentError);
  });
  for (final (master, history) in [(2147483647, 10), (7, 2147483647)]) {
    test(
      'maximum canonical=$master history=$history rejects without increment',
      () {
        final b = basis();
        expect(
          () => recancel(
            b,
            cancellation(sequence: 2147483647),
            state: versions(b, null, master: master),
            restoration: previous(sequence: history),
          ),
          throwsArgumentError,
        );
      },
    );
  }
  test('maximum incoming version can exceed both floors', () {
    final r = recancel(
      basis(),
      cancellation(sequence: 2147483647),
      restoration: previous(sequence: 2147483646),
    );
    expect(r.requiredAfterSequence, 2147483646);
  });
  for (final seq in <int?>[null, -1, 2147483648]) {
    test('invalid historical sequence $seq rejects', () {
      expect(
        () => recancel(
          basis(),
          cancellation(sequence: 11),
          restoration: previous(sequence: seq),
        ),
        throwsArgumentError,
      );
    });
  }
  for (final stamp in [
    DateTime(2026),
    DateTime.utc(1969),
    DateTime.utc(2100),
    DateTime.utc(2026, 1, 1, 0, 0, 0, 1),
    DateTime.utc(2026, 1, 1, 0, 0, 0, 0, 1),
  ]) {
    test(
      'invalid historical stamp ${stamp.toIso8601String()} utc=${stamp.isUtc}',
      () {
        expect(
          () => recancel(
            basis(),
            cancellation(sequence: 11),
            restoration: previous(stamp: stamp),
          ),
          throwsArgumentError,
        );
      },
    );
  }
  for (final field in ['created', 'lastModified']) {
    test('optional historical $field is validated', () {
      final p = field == 'created'
          ? previous().copyWith(created: DateTime.utc(2100))
          : previous().copyWith(
              lastModified: DateTime.utc(2026, 1, 1, 0, 0, 0, 1),
            );
      expect(
        () => recancel(basis(), cancellation(sequence: 11), restoration: p),
        throwsArgumentError,
      );
    });
  }
  test('zero history input and missing canonical sequence stay distinct', () {
    final b = basis(),
        r = recancel(
          b,
          cancellation(sequence: 1),
          state: versions(b, null, master: null),
          restoration: previous(sequence: 0),
        );
    expect(r.requiredAfterSequence, 0);
    expect(r.protocolState.version.sequence, isNull);
    expect(r.previousRestorationVersion.sequence, 0);
  });
  test('source clocks/omissions and historical copies remain independent', () {
    final b = basis(), p = previous().copyWith(created: DateTime.utc(2020));
    final before = snapshot(b), history = p.toJson();
    final r = recancel(b, cancellation(sequence: 11), restoration: p);
    expect(r.cancellationVersion.stamp, DateTime.utc(2026));
    expect(r.cancellationVersion.created, isNull);
    expect(r.cancellationVersion.lastModified, isNull);
    final altered = p.copyWith(sequence: 100, created: null);
    expect(r.previousRestorationVersion.toJson(), history);
    expect(identical(p, r.previousRestorationVersion), isFalse);
    expect(altered.sequence, 100);
    expect(p.toJson(), history);
    expect(snapshot(b), before);
    expect(() => r.protocolState.overrides.clear(), throwsUnsupportedError);
    expect(() => r.timingOverrides.singles.clear(), throwsUnsupportedError);
    expect(() => r.sourceMessage.events.clear(), throwsUnsupportedError);
  });
  test(
    'underlying range, later single and original order govern the floor',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=5');
      final edits = CalendarEventTimingOverrides(
        singles: [
          CalendarEventSingleOverride(originalStart: point(1), cancelled: true),
          CalendarEventSingleOverride(
            originalStart: point(4),
            replacement: CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: point(1).start,
              duration: CalendarEventDuration(hours: 1),
            ),
            cancelled: true,
          ),
        ],
        future: [
          CalendarEventFutureOverride(
            originalStart: point(2),
            replacement: CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: point(2, hour: 10).start,
              duration: CalendarEventDuration(hours: 1),
            ),
          ),
        ],
      );
      final state = versions(
        b,
        edits,
        master: 7,
        own: {'S:1': 100, 'S:4': 30, 'R:2': 20},
      );
      final m = cancellation(original: '20300104T090000Z', sequence: 31);
      final r = recancel(b, m, edits: edits, state: state);
      expect(r.requiredAfterSequence, 30);
      expect(
        r.timingOverrides.singles.map((e) => e.toJson()).toList(),
        edits.singles.map((e) => e.toJson()).toList(),
      );
      expect(
        r.timingOverrides.future.map((e) => e.toJson()).toList(),
        edits.future.map((e) => e.toJson()).toList(),
      );
      expect(r.protocolState.toJson(), state.toJson());
      expect(r.originalStart.start.day, 4);
      expect(
        () => recancel(
          b,
          cancellation(original: '20300104T090000Z', sequence: 30),
          edits: edits,
          state: state,
        ),
        throwsArgumentError,
      );
      final low = versions(b, edits, own: {'S:1': 100, 'S:4': 2, 'R:2': 20});
      expect(
        () => recancel(
          b,
          cancellation(original: '20300104T090000Z', sequence: 20),
          edits: edits,
          state: low,
        ),
        throwsArgumentError,
      );
    },
  );
  for (final text in ['20300331T023000', '20301027T023000']) {
    test(
      'explicit Stockholm gap/fold original $text survives another cycle',
      () {
        const zone = 'Europe/Stockholm';
        final seed = text.startsWith('203003')
            ? '20300330T023000'
            : '20301026T023000';
        final b = basis(
          zone: zone,
          start: 'DTSTART;TZID=$zone:$seed',
          extra: ['RDATE;TZID=$zone:$text'],
        );
        final c = recancel(
          b,
          cancellation(zone: zone, original: text, sequence: 11),
        );
        final r = projectInvitationRangeRestoration(
          protocolUid: b.protocolUid,
          content: c.content,
          timingOverrides: c.timingOverrides,
          protocolState: c.protocolState,
          cancellationVersion: c.cancellationVersion,
          message: request(
            zone: zone,
            original: text,
            start: 'DTSTART;TZID=$zone:$text',
            sequence: 12,
          ),
          recipientAddress: 'mailto:alice@example.invalid',
        );
        expect(r.timingOverrides, isNull);
        expect(r.content.toJson(), b.content.toJson());
        expect(r.protocolState.toJson(), b.protocolState.toJson());
      },
    );
  }
  test('generated nonexistent original still rejects without an explicit inclusion', () {
    final b = basis(
      zone: 'Europe/Stockholm',
      start: 'DTSTART;TZID=Europe/Stockholm:20300330T023000',
    );
    expect(
      () => recancel(
        b,
        cancellation(
          zone: 'Europe/Stockholm',
          original: '20300331T023000',
          sequence: 11,
        ),
      ),
      throwsArgumentError,
    );
  });
  test(
    'earlier date inclusion and PERIOD preserve original/end distinctions',
    () {
      final d = basis(date: true, extra: ['RDATE;VALUE=DATE:20291230']);
      expect(
        recancel(
          d,
          cancellation(date: true, original: '20291230', sequence: 11),
        ).originalStart.start.year,
        2029,
      );
      final b = basis(extra: ['RDATE;VALUE=PERIOD:20291230T090000Z/PT2H']);
      final r = recancel(
        b,
        cancellation(original: '20291230T090000Z', sequence: 11),
      );
      expect(r.content.periods!.single.duration!.hours, 2);
      final restored = projectInvitationRangeRestoration(
        protocolUid: b.protocolUid,
        content: r.content,
        timingOverrides: r.timingOverrides,
        protocolState: r.protocolState,
        cancellationVersion: r.cancellationVersion,
        message: request(
          original: '20291230T090000Z',
          start: 'DTSTART:20291230T090000Z',
          ending: ['DURATION:PT2H'],
          sequence: 12,
        ),
        recipientAddress: 'mailto:alice@example.invalid',
      );
      expect(restored.content.toJson(), b.content.toJson());
    },
  );
  test('exclusion and existing cutoff reject without mutation', () {
    expect(
      () => recancel(
        basis(extra: ['EXDATE:20300102T090000Z']),
        cancellation(sequence: 11),
      ),
      throwsArgumentError,
    );
    final b = basis(),
        edits = CalendarEventTimingOverrides(
          singles: [],
          future: [],
          cancelledFrom: point(2),
        );
    final before = edits.toJson();
    expect(
      () => recancel(b, cancellation(sequence: 11), edits: edits),
      throwsArgumentError,
    );
    expect(edits.toJson(), before);
  });
  for (final mismatch in [
    'uid',
    'recipient',
    'cancelled',
    'summary',
    'timing',
    'delegation',
  ]) {
    test('profile/source mismatch $mismatch does not produce a proposal', () {
      final b = basis();
      var m = cancellation(sequence: 11);
      if (mismatch == 'summary') {
        m = cancellation(sequence: 11, extra: ['SUMMARY:Different']);
      }
      if (mismatch == 'timing') {
        m = cancellation(sequence: 11, extra: ['DTSTART:20300102T110000Z']);
      }
      if (mismatch == 'delegation') {
        m = changed(
          m,
          'ORGANIZER:',
          'ORGANIZER;SENT-BY="mailto:delegate@example.invalid":',
        );
      }
      expect(
        () => recancel(
          b,
          m,
          uid: mismatch == 'uid' ? 'different' : null,
          recipient: mismatch == 'recipient'
              ? 'mailto:other@example.invalid'
              : 'mailto:alice@example.invalid',
          content: mismatch == 'cancelled'
              ? b.content.copyWith(status: CalendarEventStatus.cancelled)
              : null,
        ),
        throwsArgumentError,
      );
    });
  }
  test('shared budget rejects incomplete validation', () {
    expect(
      () => recancel(basis(), cancellation(sequence: 11), work: 1),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => recancel(basis(), cancellation(sequence: 11), work: 0),
      throwsArgumentError,
    );
    expect(
      () => recancel(
        basis(),
        cancellation(sequence: 11),
        work: eventMaxCandidateWork + 1,
      ),
      throwsArgumentError,
    );
  });
  test(
    'accepted source alarms stay unarmed while new source alarms reject',
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
      final r = recancel(b, cancellation(sequence: 11));
      expect(r.protocolState.sourceMetadata!.alarms!.length, 1);
      expect(r.protocolState.toJson(), b.protocolState.toJson());
      expect(
        () => cancellation(
          sequence: 11,
          extra: [
            'BEGIN:VALARM',
            'ACTION:DISPLAY',
            'TRIGGER:-PT15M',
            'DESCRIPTION:Reminder',
            'END:VALARM',
          ],
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
  for (final date in [true, false]) {
    test(
      'last ordinary ${date ? "DATE" : "UTC"} retains exclusive 2100 end',
      () {
        final original = date ? '20991231' : '20991231T230000Z';
        final start = date
            ? 'DTSTART;VALUE=DATE:$original'
            : 'DTSTART:$original';
        final b = basis(
          date: date,
          start: start,
          rule: 'RRULE:FREQ=DAILY;COUNT=1',
        );
        final c = recancel(
          b,
          cancellation(date: date, original: original, sequence: 11),
        );
        final r = projectInvitationRangeRestoration(
          protocolUid: b.protocolUid,
          content: c.content,
          timingOverrides: c.timingOverrides,
          protocolState: c.protocolState,
          cancellationVersion: c.cancellationVersion,
          message: request(
            date: date,
            original: original,
            start: start,
            sequence: 12,
          ),
          recipientAddress: 'mailto:alice@example.invalid',
        );
        expect(r.content.toJson(), b.content.toJson());
        expect(r.timingOverrides, isNull);
      },
    );
  }
  test('exact named zone identity rejects equivalent neighboring zone', () {
    expect(
      () => recancel(
        basis(zone: 'Europe/Stockholm'),
        cancellation(zone: 'Europe/Oslo', sequence: 11),
      ),
      throwsArgumentError,
    );
  });
  test('raw source budget cannot be bypassed by a larger parse budget', () {
    final dates = List.filled(5000, '19800101T000000').join(',');
    final text = calendar(
      [
        'RECURRENCE-ID;RANGE=THISANDFUTURE;TZID=Etc/UTC:20300102T090000',
        'SEQUENCE:11',
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
    expect(
      () => recancel(basis(zone: 'Etc/UTC'), m),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'cutoff costs a native slot and successful output detaches input lists',
    () {
      final b = basis(rule: 'RRULE:FREQ=DAILY;COUNT=130');
      CalendarEventSingleOverride own(int i) {
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

      final list = [for (var i = 0; i < 127; i++) own(i)];
      final edits = CalendarEventTimingOverrides(singles: list, future: []),
          state = versions(
            b,
            CalendarEventTimingOverrides(singles: list, future: []),
          );
      final r = recancel(
        b,
        cancellation(sequence: 11),
        edits: edits,
        state: state,
      );
      list.clear();
      state.overrides.clear();
      expect(r.timingOverrides.singles.length, 127);
      expect(r.protocolState.overrides.length, 127);
      final full = CalendarEventTimingOverrides(
        singles: [for (var i = 0; i < 128; i++) own(i)],
        future: [],
      );
      expect(
        () => recancel(
          b,
          cancellation(sequence: 11),
          edits: full,
          state: versions(b, full),
        ),
        throwsA(isA<RecurrenceLimitException>()),
      );
    },
  );
  test('historical validation diagnostics omit invalid input details', () {
    expect(
      () => recancel(
        basis(),
        cancellation(sequence: 11),
        restoration: previous(sequence: 1234567890, stamp: DateTime.utc(2100)),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.toString(),
          'sanitized message',
          allOf(isNot(contains('2100')), isNot(contains('1234567890'))),
        ),
      ),
    );
  });
}
