@TestOn('vm')
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_wire_storage.dart';
import 'package:serverpod_calendar_server/src/availability_wire_output.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

final registry = IcalendarAvailabilityExtensionRegistry([
  IcalendarAvailabilityExtensionRegistration(
    name: 'X-TEST',
    contexts: IcalendarAvailabilityExtensionContext.values,
    validateText: (_) => true,
  ),
]);
String component(String name, List<String> lines) =>
    ['BEGIN:$name', ...lines, 'END:$name'].join('\r\n');
IcalendarAvailabilityDefinition fixture({
  bool named = false,
  bool future = false,
}) {
  final zone = named ? ';TZID=Etc/UTC' : '';
  final suffix = named ? '' : 'Z';
  final lines = [
    'UID:Definition/界@example.invalid',
    'DTSTAMP:20400101T000000Z',
    'SEQUENCE:17',
    'CREATED:20410101T000000Z',
    'DTSTART:20261001T000000Z',
    'DURATION:P4W',
    'SUMMARY;LANGUAGE=sv;ALTREP="cid:title@example.invalid":Titel',
    'DESCRIPTION:Line one\\nLine two',
    'LOCATION:Room\\, one',
    'CATEGORIES;LANGUAGE=en:One,One',
    'CATEGORIES;LANGUAGE=sv:Två',
    'COMMENT;LANGUAGE=sv:Note',
    'CONTACT;ALTREP="cid:desk@example.invalid":Desk',
    'URL:https://example.invalid/info',
    'CLASS:PRIVATE',
    'ORGANIZER;CN="Example ^\'Name^\'";LANGUAGE=en;DIR="https://example.invalid/directory":mailto:organizer@example.invalid',
    'X-TEST:Private value',
    component('AVAILABLE', [
      'UID:opening/source',
      'DTSTAMP:20500101T000000Z',
      'DTSTART$zone:20261022T090000$suffix',
      'DURATION:PT1H',
      'RRULE:FREQ=DAILY;COUNT=3;WKST=SU',
      'RDATE;VALUE=PERIOD$zone:20261025T090000$suffix/PT2H',
      'SUMMARY;LANGUAGE=sv:Open',
      'CATEGORIES:Hours',
      'CONTACT:Opening desk',
      'X-TEST:Opening value',
    ]),
    component('AVAILABLE', [
      'UID:opening/source',
      'DTSTAMP:20390101T000000Z',
      'RECURRENCE-ID$zone${future ? ';RANGE=THISANDFUTURE' : ''}:20261023T090000$suffix',
      'DTSTART$zone:20261023T120000$suffix',
      'DTEND$zone:20261023T140000$suffix',
      'SUMMARY;LANGUAGE=sv:Open',
      'CONTACT:Opening desk',
    ]),
  ];
  final syntax = component('VCALENDAR', [
    'VERSION:2.0',
    'PRODID:-//Synthetic//EN',
    if (named)
      component('VTIMEZONE', [
        'TZID:Etc/UTC',
        component('STANDARD', [
          'DTSTART:19690101T000000',
          'TZOFFSETFROM:+0000',
          'TZOFFSETTO:+0000',
        ]),
      ]),
    component('VAVAILABILITY', lines),
  ]);
  return parseIcalendarAvailabilityCalendar(
    utf8.encode('$syntax\r\n'),
    extensions: registry,
  ).definitions.single;
}

CalendarAvailabilityView view(IcalendarAvailabilityDefinition source) {
  final proposal = availabilityStorageProposal(source);
  return CalendarAvailabilityView(
    id: const Uuid().v4obj(),
    calendarId: const Uuid().v4obj(),
    revision: 1,
    protocolUid: proposal.protocolUid,
    protocolState: proposal.protocolState,
    lastModified: proposal.protocolState.lastModified,
    content: proposal.content,
    timingOverrides: proposal.edits,
  );
}

Object? withoutNativeIds(Object? value) => switch (value) {
  Map() => {
    for (final e in value.entries)
      if (e.key != 'uid' && e.key != 'openingUid' && e.key != '__className__')
        e.key: withoutNativeIds(e.value),
  },
  List() => value.map(withoutNativeIds).toList(),
  _ => value,
};
void main() {
  test('aggregate metadata and component budgets reject the whole export', () {
    final original = view(fixture());
    final closure = original.copyWith(
      content: original.content.copyWith(
        openings: [],
        description: 'x' * 16000,
      ),
      timingOverrides: null,
      protocolState: original.protocolState.copyWith(openings: []),
    );
    expect(
      () => availabilityExportBytes([
        for (var i = 0; i < 5; i++) closure.copyWith(protocolUid: 'closure-$i'),
      ], extensions: registry),
      throwsA(
        isA<IcalendarComponentException>().having(
          (e) => e.kind,
          'kind',
          IcalendarComponentError.limitExceeded,
        ),
      ),
    );
    final tooMany = original.copyWith(
      content: original.content.copyWith(
        openings: List.filled(129, original.content.openings.single),
      ),
    );
    expect(
      () => availabilityExportBytes([tooMany], extensions: registry),
      throwsA(isA<AvailabilityLimitException>()),
    );
  });
  test(
    'exclusive 2100 endpoint and native categories retain their wire meaning',
    () {
      final original = view(fixture());
      final current = original.copyWith(
        content: original.content.copyWith(
          validDuration: null,
          validFrom: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2099, month: 12, day: 31),
          ),
          validUntil: CalendarEventTiming(
            kind: CalendarEventTimeKind.utc,
            start: CalendarEventCivil(year: 2100, month: 1, day: 1),
          ),
          categories: ['Native category'],
          categoryGroups: null,
        ),
      );
      final parsed = parseIcalendarAvailabilityCalendar(
        availabilityExportBytes([current], extensions: registry),
        extensions: registry,
      ).definitions.single;
      expect(parsed.end!.instant, DateTime.utc(2100));
      expect(parsed.metadata.categoryGroups.single.values, ['Native category']);
    },
  );
  for (final named in [false, true]) {
    for (final future in [false, true]) {
      test(
        'current state round trip retains metadata timing versions periods and override masks ($named/$future)',
        () {
          final before = view(fixture(named: named, future: future));
          final bytes = availabilityExportBytes([before], extensions: registry);
          final parsed = parseIcalendarAvailabilityCalendar(
            bytes,
            extensions: registry,
          );
          final after = view(parsed.definitions.single);
          expect(after.protocolUid, before.protocolUid);
          expect(
            withoutNativeIds(after.content.toJson()),
            withoutNativeIds(before.content.toJson()),
          );
          expect(
            withoutNativeIds(after.protocolState.toJson()),
            withoutNativeIds(before.protocolState.toJson()),
          );
          expect(
            withoutNativeIds(after.timingOverrides!.single.toJson()),
            withoutNativeIds(before.timingOverrides!.single.toJson()),
          );
          expect(
            availabilityExportBytes([before], extensions: registry),
            bytes,
          );
          expect(parsed.timeZones.keys, named ? ['Etc/UTC'] : isEmpty);
          expect(utf8.decode(bytes), isNot(contains(before.id.toString())));
        },
      );
    }
  }
  test('uses current native edits rather than source syntax', () {
    final original = view(fixture());
    final current = original.copyWith(
      content: original.content.copyWith(summary: 'Current title'),
      protocolState: original.protocolState.copyWith(sequence: 18),
    );
    final parsed = parseIcalendarAvailabilityCalendar(
      availabilityExportBytes([current], extensions: registry),
      extensions: registry,
    ).definitions.single;
    expect(parsed.summary!.value, 'Current title');
    expect(parsed.sequence, 18);
  });
  test(
    'native skipped state rejects without discarding retained replacement',
    () {
      final original = view(fixture());
      final edits = original.timingOverrides!.single;
      final skipped = original.copyWith(
        timingOverrides: [
          edits.copyWith(
            overrides: edits.overrides.copyWith(
              singles: [
                edits.overrides.singles.single.copyWith(cancelled: true),
              ],
            ),
          ),
        ],
      );
      expect(
        () => availabilityExportBytes([skipped], extensions: registry),
        throwsArgumentError,
      );
    },
  );
  test(
    'missing component stamps reject instead of inventing protocol history',
    () {
      final original = view(fixture());
      final opening = original.protocolState.openings.single;
      final legacy = original.copyWith(
        protocolState: original.protocolState.copyWith(
          openings: [opening.copyWith(overrides: null)],
        ),
      );
      expect(
        () => availabilityExportBytes([legacy], extensions: registry),
        throwsArgumentError,
      );
    },
  );
  test('unknown current extension registration and duplicate opening source identity reject entire file', () {
    final original = view(fixture());
    expect(
      () => availabilityExportBytes([
        original,
      ], extensions: IcalendarAvailabilityExtensionRegistry()),
      throwsA(isA<IcalendarComponentException>()),
    );
    final duplicate = original.copyWith(protocolUid: 'Other definition');
    expect(
      () =>
          availabilityExportBytes([original, duplicate], extensions: registry),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
