@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_source_values.dart';
import 'package:serverpod_calendar_server/src/task_values.dart';

TaskStorageProposal source({
  List<String> properties = const [],
  List<String> overrides = const [],
  List<String> timing = const ['DTSTART:20261023T120000Z'],
}) {
  final bytes = utf8.encode(
    [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic//EN',
      'BEGIN:VTODO',
      'UID:task@example.invalid',
      'DTSTAMP:20261023T100000Z',
      ...timing,
      ...properties,
      'END:VTODO',
      ...overrides,
      'END:VCALENDAR',
      '',
    ].join('\r\n'),
  );
  return taskStorageProposal(parseIcalendarTaskCalendar(bytes).series.single);
}

final now = DateTime.utc(2026, 10, 24, 10);
List<String> occurrence([List<String> extra = const []]) => [
  'BEGIN:VTODO',
  'UID:task@example.invalid',
  'DTSTAMP:20261023T110000Z',
  'RECURRENCE-ID:20261024T120000Z',
  ...extra,
  'END:VTODO',
];
void main() {
  test('future source range survives progress and master edits without changing old v2 JSON', () {
    final legacy = source(
      properties: ['RRULE:FREQ=DAILY;COUNT=3'],
      overrides: occurrence(),
    );
    expect(legacy.importBaseline.profile, startsWith('task-source-v2/'));
    expect(
      legacy.importBaseline.canonicalValue,
      isNot(contains('thisAndFuture')),
    );
    validateTaskImportBaseline(legacy.importBaseline, legacy.protocolUid);
    final p = source(
      properties: [
        'RRULE:FREQ=DAILY;COUNT=3',
        'DURATION:P1D',
        'PERCENT-COMPLETE:37',
      ],
      overrides:
          occurrence(['DTSTART:20261025T120000Z', 'PERCENT-COMPLETE:100'])
              .map(
                (s) => s.startsWith('RECURRENCE-ID:')
                    ? s.replaceFirst(
                        'RECURRENCE-ID:',
                        'RECURRENCE-ID;RANGE=THISANDFUTURE:',
                      )
                    : s,
              )
              .toList(),
    );
    expect(p.state.occurrences.single.thisAndFuture, isTrue);
    expect(taskSourceReplacement(p.state.occurrences.single), isNull);
    expect(taskSourceFuture(p.state.occurrences.single)!.start!.day, 25);
    expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
    expect(
      () => validateTaskSourceState(
        p.protocolUid,
        p.state.copyWith(
          occurrences: [
            p.state.occurrences.single.copyWith(thisAndFuture: false),
          ],
        ),
      ),
      throwsArgumentError,
    );
    final progress = changeTaskSourceOccurrence(
      p.protocolUid,
      p.state,
      p.state.occurrences.single.originalStart!,
      CalendarTaskProgress(percentComplete: 5),
      advanceTaskVersion(p.state.occurrences.single.version, now),
    );
    expect(progress.occurrences.single.thisAndFuture, isTrue);
    final after = changeTaskSourceMaster(
      p.protocolUid,
      progress,
      progress.master.content.copyWith(summary: 'Edited'),
      progress.master.progress,
      advanceTaskVersion(progress.master.version, now),
      now,
    );
    expect(after.occurrences.single.thisAndFuture, isTrue);
    expect(after.occurrences.single.progress.percentComplete, 5);
    expect(p.importBaseline.canonicalValue, contains('thisAndFuture'));
    final cleared = changeTaskSourceTiming(
      p.protocolUid,
      after,
      after.occurrences.single.originalStart!,
      null,
      after.occurrences.single.progress,
      advanceTaskVersion(after.occurrences.single.version, now),
      thisAndFuture: true,
    );
    expect(cleared.occurrences.single.thisAndFuture, isNull);
    expect(cleared.occurrences.single.content.timing.start, isNull);
    expect(cleared.occurrences.single.progress.percentComplete, 5);
  });
  test('independent source progress versions omissions and private canonical baseline', () {
    final p = source(
      properties: ['PERCENT-COMPLETE:37', 'COMPLETED:20261022T000000Z'],
    );
    expect(p.state.master.progress.status, isNull);
    expect(p.state.master.progress.percentComplete, 37);
    expect(p.state.master.progress.completedAt, DateTime.utc(2026, 10, 22));
    expect(p.state.master.version.sequence, isNull);
    expect(p.state.master.version.created, isNull);
    validateTaskImportBaseline(p.importBaseline, p.protocolUid);
    expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
    expect(
      () => validateTaskImportBaseline(
        p.importBaseline.copyWith(profile: 'unknown'),
        p.protocolUid,
      ),
      throwsStateError,
    );
    expect(
      () => validateTaskImportBaseline(
        p.importBaseline,
        'another@example.invalid',
      ),
      throwsStateError,
    );
    expect(
      () => validateTaskImportBaseline(
        p.importBaseline.copyWith(sourceSequence: 1),
        p.protocolUid,
      ),
      throwsStateError,
    );
  });
  test('grouped multilingual text participants unresolved references and inert URI attachments', () {
    final p = source(
      properties: [
        'SUMMARY;LANGUAGE=sv;ALTREP="cid:summary@example.invalid":Hej',
        'CATEGORIES;LANGUAGE=sv:ett,ett,tvÃ¥',
        'CATEGORIES:three',
        'COMMENT;LANGUAGE=en:first',
        'COMMENT;ALTREP="https://example.invalid/comment":second',
        'CONTACT:synthetic contact',
        'CLASS:PRIVATE',
        'URL:https://example.invalid/task',
        'ORGANIZER;CN=Organizer:mailto:organizer@example.invalid',
        'ATTENDEE;ROLE=CHAIR;RSVP=FALSE;MEMBER="mailto:group@example.invalid":mailto:guest@example.invalid',
        'RELATED-TO:missing@example.invalid',
        'RELATED-TO;RELTYPE=SIBLING:task@example.invalid',
        'ATTACH;VALUE=URI;FMTTYPE=application/pdf:cid:synthetic@example.invalid',
      ],
    );
    final m = p.state.master.metadata;
    expect(m.categoryGroups.first.values, ['ett', 'ett', 'tvÃ¥']);
    expect(
      m.comments.last.parameters!.alternativeUri,
      'https://example.invalid/comment',
    );
    expect(m.attendees.single.parameters['RSVP'], ['FALSE']);
    expect(m.relationships.first.relationType, isNull);
    expect(m.attachments.single.explicitUri, isTrue);
    expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
    expect(() => m.categoryGroups.first.values.clear(), throwsUnsupportedError);
    expect(
      () => m.attendees.single.parameters['MEMBER']!.clear(),
      throwsUnsupportedError,
    );
    expect(() => m.attendees.single.parameters.clear(), throwsUnsupportedError);
    expect(() => m.alarms.clear(), throwsUnsupportedError);
  });
  test(
    'unarmed DISPLAY repeats acknowledgements and sibling snooze round trip',
    () {
      final p = source(
        properties: [
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'DESCRIPTION;LANGUAGE=sv:Reminder',
          'TRIGGER:-PT5M',
          'REPEAT:0',
          'DURATION:PT1M',
          'UID:alarm@example.invalid',
          'ACKNOWLEDGED:20261023T110000Z',
          'END:VALARM',
          'BEGIN:VALARM',
          'ACTION:DISPLAY',
          'DESCRIPTION:Snooze',
          'TRIGGER;VALUE=DATE-TIME:20261023T120500Z',
          'UID:snooze@example.invalid',
          'RELATED-TO;RELTYPE=SNOOZE:alarm@example.invalid',
          'END:VALARM',
        ],
      );
      final alarms = p.state.master.metadata.alarms;
      expect(alarms.first.relativeDuration!.sign, -1);
      expect(alarms.first.relativeDuration!.minutes, 5);
      expect(alarms.first.repeat, 0);
      expect(alarms.last.snoozeTargetUid, 'alarm@example.invalid');
      expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
      expect(p.state.master.metadata.toJson().containsKey('armed'), isFalse);
      final updated = p.state.master.content.copyWith(
        timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
      );
      expect(
        () => changeTaskSourceMaster(
          p.protocolUid,
          p.state,
          updated,
          p.state.master.progress,
          advanceTaskVersion(p.state.master.version, now),
          now,
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
    },
  );
  test(
    'DATE undated due-only and duration source milestones remain distinct',
    () {
      for (final timing in <List<String>>[
        [],
        ['DUE;VALUE=DATE:20261024'],
        ['DTSTART;VALUE=DATE:20261023', 'DURATION:P1D'],
        ['DUE:20261024T000000Z'],
        ['DTSTART:20261023T120000Z', 'DURATION:PT1S'],
      ]) {
        final p = source(timing: timing);
        expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
      }
    },
  );
  test('sparse progress components preserve raw timing and explicit default presence', () {
    final p = source(
      properties: ['RRULE:FREQ=DAILY;COUNT=3'],
      overrides: occurrence([
        'PRIORITY:0',
        'CLASS:PUBLIC',
        'PERCENT-COMPLETE:12',
      ]),
    );
    final o = p.state.occurrences.single;
    expect(o.content.timing.kind, CalendarTaskTimeKind.undated);
    expect(o.content.priority, 0);
    expect(o.metadata.classification, 'PUBLIC');
    expect(o.progress.status, isNull);
    expect(o.progress.percentComplete, 12);
    expect(o.version.stamp, DateTime.utc(2026, 10, 23, 11));
    expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
    expect(() => p.state.occurrences.clear(), throwsUnsupportedError);
  });
  test('master edits retain annotations baseline and independent repeated component versions', () {
    final p = source(
      properties: ['SUMMARY;LANGUAGE=sv:Hej', 'RRULE:FREQ=DAILY;COUNT=3'],
      overrides: occurrence(['SUMMARY;LANGUAGE=sv:Hej']),
    );
    final before = p.importBaseline.canonicalValue;
    final after = changeTaskSourceMaster(
      p.protocolUid,
      p.state,
      p.state.master.content.copyWith(summary: 'HallÃ¥'),
      p.state.master.progress,
      advanceTaskVersion(p.state.master.version, now),
      now,
    );
    expect(after.master.content.summary, 'HallÃ¥');
    expect(after.master.textParameters!.summary!.language, 'sv');
    expect(after.occurrences.single.content.summary, 'HallÃ¥');
    expect(after.occurrences.single.version.sequence, 1);
    expect(after.occurrences.single.version.created, isNull);
    expect(p.importBaseline.canonicalValue, before);
    final unchanged = changeTaskSourceMaster(
      p.protocolUid,
      after,
      after.master.content,
      after.master.progress,
      after.master.version,
      now,
    );
    expect(unchanged, after);
  });
  test('occurrence progress owns its version without changing master or inventing history', () {
    final p = source(
      properties: ['RRULE:FREQ=DAILY;COUNT=3'],
      overrides: occurrence(),
    );
    final original = p.state.occurrences.single.originalStart!;
    final after = changeTaskSourceOccurrence(
      p.protocolUid,
      p.state,
      original,
      CalendarTaskProgress(
        status: CalendarTaskStatus.completed,
        percentComplete: 100,
        completedAt: now,
      ),
      advanceTaskVersion(p.state.occurrences.single.version, now),
    );
    expect(after.master, p.state.master);
    expect(after.occurrences.single.version.sequence, 1);
    expect(after.occurrences.single.version.created, isNull);
    expect(after.occurrences.single.progress.percentComplete, 100);
    expect(after.toJson().containsKey('history'), isFalse);
  });
  test('new occurrence component gets known local version and unchanged inherited content', () {
    final p = source(properties: ['RRULE:FREQ=DAILY;COUNT=3']);
    final original = CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 10, day: 24, hour: 12),
    );
    final after = changeTaskSourceOccurrence(
      p.protocolUid,
      p.state,
      original,
      CalendarTaskProgress(percentComplete: 5),
      taskOccurrenceInitialVersion(now),
    );
    expect(after.master, p.state.master);
    expect(after.occurrences.single.version.sequence, 0);
    expect(after.occurrences.single.version.created, now);
    expect(after.occurrences.single.content.summary, isNull);
  });
  test('source mutation rejects orphaned originals mismatching raw timing and sequence overflow', () {
    final p = source(
      properties: ['RRULE:FREQ=DAILY;COUNT=3'],
      overrides: occurrence(['DTSTART:20261024T120000Z']),
    );
    final timing = p.state.master.content.timing.copyWith(
      start: CalendarEventCivil(year: 2026, month: 10, day: 23, hour: 13),
    );
    expect(
      () => changeTaskSourceMaster(
        p.protocolUid,
        p.state,
        p.state.master.content.copyWith(timing: timing),
        p.state.master.progress,
        p.state.master.version,
        now,
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
    expect(
      () => advanceTaskVersion(
        p.state.master.version.copyWith(sequence: 2147483647),
        now,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('named zones retain exact identifiers and duration forms', () {
    final document = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty('PRODID', 'Synthetic'),
        createIcalendarTimeZone('Europe/Stockholm'),
        IcalendarSyntaxComponent('VTODO', [
          IcalendarSyntaxProperty('UID', 'zoned@example.invalid'),
          IcalendarSyntaxProperty('DTSTAMP', '20261023T100000Z'),
          IcalendarSyntaxProperty(
            'DTSTART',
            '20261024T120000',
            parameters: [
              IcalendarSyntaxParameter('TZID', ['Europe/Stockholm']),
            ],
          ),
          IcalendarSyntaxProperty('DURATION', 'P1D'),
        ]),
      ]),
    ]);
    final p = taskStorageProposal(
      validateIcalendarTaskCalendar(document).series.single,
    );
    expect(p.state.master.content.timing.zoneId, 'Europe/Stockholm');
    expect(p.state.master.content.timing.duration!.days, 1);
    expect(validateTaskSourceState(p.protocolUid, p.state), p.state);
  });
  test('oversized baseline and hidden invalid metadata fail closed', () {
    final p = source();
    expect(
      () => validateTaskImportBaseline(
        p.importBaseline.copyWith(
          canonicalValue: 'x' * (taskBaselineMaxBytes + 1),
        ),
        p.protocolUid,
      ),
      throwsStateError,
    );
    final bad = p.state.copyWith(
      master: p.state.master.copyWith(
        metadata: p.state.master.metadata.copyWith(
          url: 'https://user:secret@example.invalid',
        ),
      ),
    );
    expect(
      () => validateTaskSourceState(p.protocolUid, bad),
      throwsA(isA<IcalendarComponentException>()),
    );
    expect(
      () => validateTaskSourceState(
        p.protocolUid,
        p.state.copyWith(
          master: p.state.master.copyWith(
            originalStart: CalendarEventTiming(
              kind: CalendarEventTimeKind.utc,
              start: CalendarEventCivil(
                year: 2026,
                month: 10,
                day: 24,
                hour: 12,
              ),
            ),
          ),
        ),
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
