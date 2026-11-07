import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/subject_free_busy_export_values.dart';
import 'package:test/test.dart';

void main() {
  final start = DateTime.utc(2030, 1, 1);
  final window = UtcWindow(
    start: start,
    end: start.add(const Duration(hours: 24)),
  );
  AvailabilityInterval span(int from, int until, AvailabilityKind kind) =>
      AvailabilityInterval(
        window: UtcWindow(
          start: start.add(Duration(hours: from)),
          end: start.add(Duration(hours: until)),
        ),
        kind: kind,
      );
  final free = [span(0, 24, AvailabilityKind.free)];
  List<IcalendarSyntaxComponent> components(
    List<List<AvailabilityInterval>> partitions, {
    int maxPeriods = 1000,
    int maxBytes = 262144,
  }) => parseIcalendarSyntax(
    serializeSubjectFreeBusySnapshots(
      uids: [for (var i = 0; i < partitions.length; i++) 'snapshot-$i'],
      stamp: start,
      window: window,
      partitions: partitions,
      maxPeriods: maxPeriods,
      maxBytes: maxBytes,
    ),
  ).components.single.entries.whereType<IcalendarSyntaxComponent>().toList();
  List<IcalendarSyntaxProperty> properties(
    IcalendarSyntaxComponent component,
    String name,
  ) => component.entries
      .whereType<IcalendarSyntaxProperty>()
      .where((p) => p.canonicalName == name)
      .toList();

  test('ordered targets retain independent identity and complete geometry', () {
    final result = components([
      [
        span(0, 9, AvailabilityKind.free),
        span(9, 10, AvailabilityKind.tentative),
        span(10, 24, AvailabilityKind.free),
      ],
      [
        span(0, 12, AvailabilityKind.free),
        span(12, 24, AvailabilityKind.unavailable),
      ],
    ]);
    expect(result.map((c) => properties(c, 'UID').single.value), [
      'snapshot-0',
      'snapshot-1',
    ]);
    expect(
      properties(result.first, 'FREEBUSY').single.value,
      '20300101T090000Z/20300101T100000Z',
    );
    expect(
      properties(result.last, 'FREEBUSY').single.parameters.single.values,
      ['BUSY-UNAVAILABLE'],
    );
    expect(
      properties(result.first, 'DTSTAMP').single.value,
      properties(result.last, 'DTSTAMP').single.value,
    );
  });
  test(
    'all-free requires full coverage, never an empty or holed partition',
    () {
      expect(properties(components([free]).single, 'FREEBUSY'), isEmpty);
      for (final bad in <List<AvailabilityInterval>>[
        [],
        [span(1, 24, AvailabilityKind.free)],
      ]) {
        expect(
          () => components([free, bad]),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
    },
  );
  test('aggregate period ceiling spans individually valid components', () {
    final p = [
      span(0, 1, AvailabilityKind.busy),
      span(1, 2, AvailabilityKind.free),
      span(2, 24, AvailabilityKind.busy),
    ];
    expect(
      () => components([p, p], maxPeriods: 3),
      throwsA(
        isA<IcalendarComponentException>().having(
          (e) => e.kind,
          'kind',
          IcalendarComponentError.limitExceeded,
        ),
      ),
    );
    expect(components([p, p], maxPeriods: 4), hasLength(2));
  });
  test('file budget rejects the whole output', () {
    expect(
      () => components([free, free], maxBytes: 64),
      throwsA(
        anyOf(
          isA<IcalendarComponentException>(),
          isA<IcalendarSyntaxException>(),
        ),
      ),
    );
  });
  test('wire includes no mail claims or native detail', () {
    final text = utf8.decode(
      serializeSubjectFreeBusySnapshots(
        uids: ['snapshot'],
        stamp: start,
        window: window,
        partitions: [free],
      ),
    );
    for (final name in [
      'METHOD:',
      'ORGANIZER',
      'ATTENDEE',
      'SUMMARY',
      'LOCATION',
      'TZID',
      'COUNT',
    ]) {
      expect(text, isNot(contains(name)));
    }
    expect(text.endsWith('END:VCALENDAR\r\n'), isTrue);
  });
  test('profile ceilings and duplicate identities cannot be widened', () {
    for (final invoke in <void Function()>[
      () => serializeSubjectFreeBusySnapshots(
        uids: [],
        stamp: start,
        window: window,
        partitions: [],
      ),
      () => serializeSubjectFreeBusySnapshots(
        uids: ['same', 'same'],
        stamp: start,
        window: window,
        partitions: [free, free],
      ),
      () => components([free], maxPeriods: 1001),
      () => components([free], maxBytes: 262145),
      () => components(List.filled(9, free)),
    ]) {
      expect(invoke, throwsArgumentError);
    }
  });
  test('fractional stamps reject without rounding', () {
    expect(
      () => serializeSubjectFreeBusySnapshots(
        uids: ['snapshot'],
        stamp: start.add(const Duration(microseconds: 1)),
        window: window,
        partitions: [free],
      ),
      throwsA(isA<IcalendarComponentException>()),
    );
  });
}
