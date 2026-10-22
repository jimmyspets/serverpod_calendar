@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_values.dart';
import 'package:serverpod_calendar_server/src/availability_protocol_values.dart';
import 'package:serverpod_calendar_server/src/availability_storage_values.dart';
import 'package:serverpod_calendar_server/src/availability_wire_storage.dart';

String component(String name, List<String> values) =>
    ['BEGIN:$name', ...values, 'END:$name'].join('\r\n');
IcalendarAvailabilityDefinition source({
  String uid = 'definition/α@example.invalid',
  List<String> fields = const [],
  List<String> openingFields = const [],
  List<String> overrides = const [],
  bool named = false,
}) {
  final zone = named ? ';TZID=Etc/UTC' : '';
  final suffix = named ? '' : 'Z';
  final opening = component('AVAILABLE', [
    'UID:opening/β@example.invalid',
    'DTSTAMP:20500101T000000Z',
    'DTSTART$zone:20261022T090000$suffix',
    'DURATION:PT1H',
    'RRULE:FREQ=DAILY;COUNT=3',
    ...openingFields,
  ]);
  final definition = component('VAVAILABILITY', [
    'UID:$uid',
    'DTSTAMP:20261020T000000Z',
    ...fields,
    opening,
    ...overrides,
  ]);
  final calendar = component('VCALENDAR', [
    'VERSION:2.0',
    'PRODID:-//Synthetic storage test//EN',
    if (named)
      component('VTIMEZONE', [
        'TZID:Etc/UTC',
        component('STANDARD', [
          'DTSTART:19690101T000000',
          'TZOFFSETFROM:+0000',
          'TZOFFSETTO:+0000',
        ]),
      ]),
    definition,
  ]);
  return parseIcalendarAvailabilityCalendar(utf8.encode('$calendar\r\n'))
      .definitions
      .single;
}

String change({bool future = false, List<String> fields = const []}) =>
    component('AVAILABLE', [
      'UID:opening/β@example.invalid',
      'DTSTAMP:20400101T000000Z',
      'RECURRENCE-ID${future ? ';RANGE=THISANDFUTURE' : ''}:20261023T090000Z',
      'DTSTART:20261023T120000Z',
      'DURATION:PT2H',
      ...fields,
    ]);
CalendarEventTiming utc(int day, {int hour = 9, int? endHour}) =>
    CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 10, day: day, hour: hour),
      end: endHour == null
          ? null
          : CalendarEventCivil(year: 2026, month: 10, day: day, hour: endHour),
    );
void main() {
  test('text source UIDs remain distinct from stable native UUIDs', () {
    final id = const Uuid().v4obj();
    final p = availabilityStorageProposal(source(), newOpeningId: () => id);
    expect(p.protocolUid, 'definition/α@example.invalid');
    expect(p.content.openings.single.uid, id);
    expect(p.content.openings.single.protocolUid, 'opening/β@example.invalid');
    expect(p.protocolState.openings.single.openingUid, id);
    final copy = availabilityStorageProposal(source());
    expect(copy.protocolUid, p.protocolUid);
    expect(copy.content.openings.single.uid, isNot(id));
  });
  test(
    'UID candidate equality is exact including Unicode case and spacing',
    () {
      for (final uid in ['a', 'A', 'é', 'e\u0301', ' a', 'a ']) {
        final digest = availabilityUidDigest(uid);
        expect(digest.length, 64);
        expect(availabilityUidConflicts(uid, [uid]), isTrue);
        expect(availabilityUidConflicts(uid, ['$uid!']), isFalse);
      }
      expect(availabilityUidConflicts('a', ['A']), isFalse);
      expect(
        availabilityUidDigest('é'),
        isNot(availabilityUidDigest('e\u0301')),
      );
    },
  );
  test(
    'adapter-supported long Unicode UIDs require no text-index truncation',
    () {
      final uid = '界' * 4096;
      final p = availabilityStorageProposal(source(uid: uid));
      expect(p.protocolUid, uid);
      expect(availabilityUidDigest(uid).length, 64);
      expect(() => validateAvailabilityUid(''), throwsArgumentError);
      expect(() => validateAvailabilityUid('a' * 4097), throwsArgumentError);
    },
  );
  test(
    'source groups duplicates and independently annotated contacts survive',
    () {
      final p = availabilityStorageProposal(
        source(
          fields: [
            r'CATEGORIES;LANGUAGE=en:A\,B,A\,B',
            'CATEGORIES;LANGUAGE=sv:Arbete',
            'CONTACT;LANGUAGE=en;ALTREP="cid:contact@example.invalid":Desk',
            'CONTACT:Other desk',
            'COMMENT;LANGUAGE=sv:Notering',
          ],
          openingFields: [
            'CATEGORIES;LANGUAGE=sv:Öppet',
            'CONTACT:Opening desk',
          ],
        ),
      );
      expect(p.content.categoryGroups!.first.values, ['A,B', 'A,B']);
      expect(p.content.categoryGroups!.last.language, 'sv');
      expect(p.content.categories, isEmpty);
      expect(
        p.content.contacts!.first.alternativeUri,
        'cid:contact@example.invalid',
      );
      expect(p.content.contacts!.last.value, 'Other desk');
      expect(p.content.textParameters!.comments!.single!.language, 'sv');
      expect(p.content.openings.single.contacts!.single.value, 'Opening desk');
      expect(() => p.content.categoryGroups!.clear(), throwsUnsupportedError);
      expect(
        () => p.content.categoryGroups!.first.values.clear(),
        throwsUnsupportedError,
      );
      expect(() => p.content.contacts!.clear(), throwsUnsupportedError);
    },
  );
  test('ambiguous single and grouped category representations reject', () {
    final p = availabilityStorageProposal(source(fields: ['CATEGORIES:A']));
    expect(
      () => validateAvailabilityContent(p.content.copyWith(categories: ['B'])),
      throwsArgumentError,
    );
    expect(
      () => validateAvailabilityContent(
        p.content.copyWith(
          categoryGroups: [
            CalendarAvailabilityCategoryGroup(values: []),
          ],
        ),
      ),
      throwsArgumentError,
    );
  });
  test('source protocol dates sequence and omissions stay independent of local audit time', () {
    final absent = availabilityStorageProposal(source());
    expect(absent.protocolState.sequence, isNull);
    expect(absent.protocolState.created, isNull);
    expect(absent.protocolState.lastModified, isNull);
    expect(absent.protocolState.openings.single.created, isNull);
    expect(absent.protocolState.openings.single.lastModified, isNull);
    expect(absent.protocolState.openings.single.stamp, DateTime.utc(2050));
    final explicit = availabilityStorageProposal(
      source(
        fields: [
          'SEQUENCE:7',
          'CREATED:20900101T000000Z',
          'LAST-MODIFIED:20000101T000000Z',
        ],
      ),
    );
    expect(explicit.protocolState.sequence, 7);
    expect(explicit.protocolState.created, DateTime.utc(2090));
    expect(explicit.protocolState.lastModified, DateTime.utc(2000));
    expect(explicit.protocolState.stamp, DateTime.utc(2026, 10, 20));
  });
  test('identical saves preserve imported omission and later edits increment effective sequence', () {
    final p = availabilityStorageProposal(source());
    final same = advanceAvailabilityProtocol(
      p.protocolState,
      p.content,
      p.edits,
      p.content,
      p.edits,
      DateTime.utc(2026),
    );
    expect(same.toJson(), p.protocolState.toJson());
    final next = advanceAvailabilityProtocol(
      p.protocolState,
      p.content,
      p.edits,
      p.content.copyWith(summary: 'Local edit'),
      p.edits,
      DateTime.utc(2026),
    );
    expect(next.sequence, 1);
    expect(next.created, isNull);
    expect(next.stamp, p.protocolState.stamp);
    expect(next.lastModified, p.protocolState.stamp);
    expect(
      next.openings.single.toJson(),
      p.protocolState.openings.single.toJson(),
    );
  });
  test(
    'PERIOD additions preserve nominal representation and affect calculation',
    () {
      final p = availabilityStorageProposal(
        source(
          openingFields: [
            'RDATE;VALUE=PERIOD:20261025T090000Z/PT2H,20261026T090000Z/20261026T120000Z',
          ],
        ),
      );
      final periods = p.content.openings.single.periods!;
      expect(periods.first.duration!.hours, 2);
      expect(periods.last.end!.hour, 12);
      final result = evaluateAvailability(
        p.content,
        UtcWindow(
          start: DateTime.utc(2026, 10, 25),
          end: DateTime.utc(2026, 10, 27),
        ),
      );
      expect(result.openings.map((v) => v.end.difference(v.start).inHours), [
        2,
        3,
      ]);
    },
  );
  test('PERIOD original identity supports native single timing changes', () {
    final p = availabilityStorageProposal(
      source(
        openingFields: [
          'RDATE;VALUE=PERIOD:20261025T090000Z/PT2H',
        ],
      ),
    );
    final opening = p.content.openings.single;
    final edits = changeAvailabilityEdits(
      p.content,
      null,
      CalendarAvailabilityOccurrenceChange(
        availabilityId: const Uuid().v4obj(),
        openingUid: opening.uid!,
        expectedRevision: 1,
        originalStart: utc(25),
        action: CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: utc(25, hour: 13, endHour: 16),
      ),
    );
    final result = evaluateAvailability(
      p.content,
      UtcWindow(
        start: DateTime.utc(2026, 10, 25),
        end: DateTime.utc(2026, 10, 26),
      ),
      edits: edits,
    );
    expect(result.openings.single.start.hour, 13);
    expect(result.openings.single.end.hour, 16);
  });
  test('PERIOD conflicts profile mismatches point values and shared raw caps reject', () {
    final p = availabilityStorageProposal(source());
    final o = p.content.openings.single;
    for (final periods in [
      [utc(25)],
      [utc(25, endHour: 10), utc(25, endHour: 11)],
      [
        utc(
          25,
          endHour: 10,
        ).copyWith(kind: CalendarEventTimeKind.zoned, zoneId: 'Etc/UTC'),
      ],
      List.filled(257, utc(25, endHour: 10)),
    ]) {
      expect(
        () => validateAvailabilityContent(
          p.content.copyWith(openings: [o.copyWith(periods: periods)]),
        ),
        throwsA(anyOf(isA<ArgumentError>(), isA<RecurrenceLimitException>())),
      );
    }
  });
  test('named-zone PERIOD storage preserves exact zone profile', () {
    final p = availabilityStorageProposal(
      source(
        named: true,
        openingFields: [
          'RDATE;VALUE=PERIOD;TZID=Etc/UTC:20261025T090000/PT2H',
        ],
      ),
    );
    final o = p.content.openings.single;
    expect(o.timing.zoneId, 'Etc/UTC');
    expect(o.periods!.single.zoneId, 'Etc/UTC');
  });
  for (final future in [false, true]) {
    test(
      'timing component retains source protocol metadata and omission (future=$future)',
      () {
        final p = availabilityStorageProposal(
          source(overrides: [change(future: future)]),
        );
        final state = p.protocolState.openings.single.overrides!.single;
        expect(state.isThisAndFuture, future);
        expect(state.stamp, DateTime.utc(2040));
        expect(state.created, isNull);
        expect(state.metadata!.summary, isNull);
        expect(p.edits!.single.openingUid, p.content.openings.single.uid);
        expect(p.edits!.single.overrides.singles.length, future ? 0 : 1);
      },
    );
  }
  test('native metadata edits evolve explicit inherited component text and keep omissions', () {
    final p = availabilityStorageProposal(
      source(
        openingFields: ['SUMMARY:Old'],
        overrides: [
          change(fields: ['SUMMARY:Old']),
        ],
      ),
    );
    final after = validateAvailabilityContent(
      p.content.copyWith(
        openings: [
          p.content.openings.single.copyWith(summary: 'New'),
        ],
      ),
    );
    final state = advanceAvailabilityProtocol(
      p.protocolState,
      p.content,
      p.edits,
      after,
      p.edits,
      DateTime.utc(2026),
    );
    final componentState = state.openings.single.overrides!.single;
    expect(componentState.metadata!.summary!.value, 'New');
    expect(componentState.metadata!.description, isNull);
    expect(componentState.stamp, DateTime.utc(2040));
    expect(componentState.created, isNull);
  });
  test('orphan source component states and mismatched metadata fail storage validation', () {
    final p = availabilityStorageProposal(
      source(
        openingFields: ['SUMMARY:Old'],
        overrides: [
          change(fields: ['SUMMARY:Old']),
        ],
      ),
    );
    expect(
      () => validateAvailabilityProtocolState(p.protocolState, p.content),
      throwsArgumentError,
    );
    final o = p.protocolState.openings.single;
    final bad = o.overrides!.single.copyWith(
      metadata: CalendarAvailabilitySourceMetadata(
        summary: CalendarAvailabilityText(value: 'Different'),
      ),
    );
    expect(
      () => validateAvailabilityProtocolState(
        p.protocolState.copyWith(
          openings: [
            o.copyWith(overrides: [bad]),
          ],
        ),
        p.content,
        edits: p.edits,
      ),
      throwsArgumentError,
    );
  });
  test('source component collections remain frozen after rebasing', () {
    final p = availabilityStorageProposal(
      source(
        openingFields: ['CATEGORIES:A'],
        overrides: [
          change(fields: ['CATEGORIES:A']),
        ],
      ),
    );
    final state = p.protocolState.openings.single.overrides!.single;
    expect(
      () => state.metadata!.categories!.first.values.clear(),
      throwsUnsupportedError,
    );
    expect(
      () => p.protocolState.openings.single.overrides!.clear(),
      throwsUnsupportedError,
    );
  });
  test('availability recurrence work is shared across opening series', () {
    final p = availabilityStorageProposal(source());
    final opening = p.content.openings.single;
    final doubled = validateAvailabilityContent(
      p.content.copyWith(
        openings: [
          opening,
          opening.copyWith(uid: const Uuid().v4obj(), protocolUid: 'other'),
        ],
      ),
    );
    final window = UtcWindow(
      start: DateTime.utc(2026, 10, 22),
      end: DateTime.utc(2026, 10, 25),
    );
    final work = RecurrenceWorkBudget(maxWork: 100);
    evaluateAvailability(p.content, window, sharedWorkBudget: work);
    expect(work.used, greaterThan(0));
    final bounded = RecurrenceWorkBudget(maxWork: work.used);
    expect(
      () => evaluateAvailability(doubled, window, sharedWorkBudget: bounded),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(bounded.remaining, 0);
  });
  test(
    'existing native timing components get an honest unknown-created baseline',
    () {
      final p = availabilityStorageProposal(source(overrides: [change()]));
      final before = p.protocolState.copyWith(
        openings: [
          p.protocolState.openings.single.copyWith(overrides: null),
        ],
      );
      final after = advanceAvailabilityProtocol(
        before,
        p.content,
        p.edits,
        p.content.copyWith(summary: 'Envelope edit'),
        p.edits,
        DateTime.utc(2060),
      );
      final state = after.openings.single.overrides!.single;
      expect(state.created, isNull);
      expect(state.stamp, before.openings.single.stamp);
      expect(state.lastModified, before.openings.single.lastModified);
    },
  );
  test('new local components use known creation time rather than future parent stamps', () {
    final p = availabilityStorageProposal(source());
    final now = DateTime.utc(2026);
    final newId = const Uuid().v4obj();
    final after = validateAvailabilityContent(
      p.content.copyWith(
        openings: [
          ...p.content.openings,
          CalendarAvailabilityOpening(
            uid: newId,
            protocolUid: 'new-local',
            timing: utc(25, endHour: 10),
          ),
        ],
      ),
    );
    final protocol = advanceAvailabilityProtocol(
      p.protocolState,
      p.content,
      null,
      after,
      null,
      now,
    );
    expect(protocol.openings.last.created, now);
    expect(protocol.openings.last.stamp, now);
    final opening = p.content.openings.single;
    final edits = changeAvailabilityEdits(
      p.content,
      null,
      CalendarAvailabilityOccurrenceChange(
        availabilityId: const Uuid().v4obj(),
        openingUid: opening.uid!,
        expectedRevision: 1,
        originalStart: utc(23),
        action: CalendarEventOccurrenceAction.replaceSingleTiming,
        replacement: utc(23, hour: 12, endHour: 14),
      ),
    );
    final changed = advanceAvailabilityProtocol(
      p.protocolState,
      p.content,
      null,
      p.content,
      edits,
      now,
    );
    final component = changed.openings.single.overrides!.single;
    expect(component.created, now);
    expect(component.stamp, now);
    expect(changed.openings.single.stamp, DateTime.utc(2050));
  });
}
