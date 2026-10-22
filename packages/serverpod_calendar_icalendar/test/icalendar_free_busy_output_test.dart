import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

DateTime at(int hour) => DateTime.utc(2026, 10, 22, hour);
AvailabilityInterval interval(int a, int b, AvailabilityKind kind) =>
    AvailabilityInterval(
      window: UtcWindow(start: at(a), end: at(b)),
      kind: kind,
    );
final window = UtcWindow(start: at(0), end: at(24));
String output(
  List<AvailabilityInterval> periods, {
  int maxPeriods = 1000,
  IcalendarSyntaxLimits limits = const IcalendarSyntaxLimits(),
}) => utf8.decode(
  serializeIcalendarFreeBusy(
    uid: 'snapshot@example.invalid',
    stamp: at(0),
    window: window,
    partition: periods,
    maxPeriods: maxPeriods,
    syntaxLimits: limits,
  ),
);
Matcher invalid([
  IcalendarComponentError kind = IcalendarComponentError.invalidValue,
]) => throwsA(
  isA<IcalendarComponentException>().having((e) => e.kind, 'kind', kind),
);

void main() {
  test('UTC periods retain classification and chronological order; adjacent kinds merge', () {
    final text = output([
      interval(0, 1, AvailabilityKind.free),
      interval(1, 2, AvailabilityKind.tentative),
      interval(2, 3, AvailabilityKind.tentative),
      interval(3, 4, AvailabilityKind.busy),
      interval(4, 24, AvailabilityKind.unavailable),
    ]);
    expect(
      text,
      contains(
        'FREEBUSY;FBTYPE=BUSY-TENTATIVE:20261022T010000Z/20261022T030000Z\r\n',
      ),
    );
    final component = parseIcalendarSyntax(utf8.encode(text))
        .components
        .single
        .entries
        .whereType<IcalendarSyntaxComponent>()
        .single;
    final periods = component.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.name == 'FREEBUSY')
        .toList();
    expect(periods.map((p) => p.parameters.single.values.single), [
      'BUSY-TENTATIVE',
      'BUSY',
      'BUSY-UNAVAILABLE',
    ]);
    expect(text, isNot(contains('FBTYPE=FREE')));
    for (final name in [
      'VEVENT',
      'VTIMEZONE',
      'SUMMARY',
      'LOCATION',
      'ORGANIZER',
      'ATTENDEE',
      'RRULE',
      'METHOD',
      'COUNT',
      'URL',
    ]) {
      expect(text, isNot(contains('$name:')));
    }
  });
  test(
    'complete all-free input has required metadata and no occupied periods',
    () {
      final text = output([interval(0, 24, AvailabilityKind.free)]);
      expect(
        text,
        contains('BEGIN:VFREEBUSY\r\nUID:snapshot@example.invalid\r\n'),
      );
      expect(
        text,
        contains('DTSTART:20261022T000000Z\r\nDTEND:20261023T000000Z\r\n'),
      );
      expect(text, isNot(contains('FREEBUSY;')));
      expect(text, endsWith('END:VFREEBUSY\r\nEND:VCALENDAR\r\n'));
    },
  );
  test('holes, overlaps, unordered, empty and out-of-window input never imply free', () {
    for (final periods in <List<AvailabilityInterval>>[
      [],
      [interval(1, 24, AvailabilityKind.free)],
      [
        interval(0, 1, AvailabilityKind.free),
        interval(2, 24, AvailabilityKind.busy),
      ],
      [
        interval(0, 5, AvailabilityKind.busy),
        interval(4, 24, AvailabilityKind.free),
      ],
      [
        interval(10, 24, AvailabilityKind.busy),
        interval(0, 10, AvailabilityKind.free),
      ],
      [interval(0, 25, AvailabilityKind.busy)],
    ]) {
      expect(() => output(periods), invalid());
    }
  });
  test('whole-second validation includes free input and stamp', () {
    expect(
      () => output([
        AvailabilityInterval(
          kind: AvailabilityKind.free,
          window: UtcWindow(
            start: at(0),
            end: at(24).subtract(const Duration(microseconds: 1)),
          ),
        ),
      ]),
      throwsArgumentError,
    );
    expect(
      () => serializeIcalendarFreeBusy(
        uid: 'x',
        stamp: at(0).add(const Duration(milliseconds: 1)),
        window: window,
        partition: [interval(0, 24, AvailabilityKind.free)],
      ),
      invalid(),
    );
    expect(
      () => serializeIcalendarFreeBusy(
        uid: 'x',
        stamp: DateTime(2026),
        window: window,
        partition: [interval(0, 24, AvailabilityKind.free)],
      ),
      invalid(),
    );
  });
  test('exclusive 2100 endpoint is permitted but ordinary out-of-profile dates reject', () {
    final w = UtcWindow(
      start: DateTime.utc(2099, 12, 31),
      end: DateTime.utc(2100),
    );
    final text = utf8.decode(
      serializeIcalendarFreeBusy(
        uid: 'x',
        stamp: at(0),
        window: w,
        partition: [
          AvailabilityInterval(window: w, kind: AvailabilityKind.busy),
        ],
      ),
    );
    expect(text, contains('/21000101T000000Z'));
    expect(
      () => serializeIcalendarFreeBusy(
        uid: 'x',
        stamp: DateTime.utc(2100),
        window: w,
        partition: [
          AvailabilityInterval(window: w, kind: AvailabilityKind.free),
        ],
      ),
      invalid(),
    );
  });
  test('period, byte and 31-day limits reject without partial output', () {
    expect(
      () => output([
        interval(0, 1, AvailabilityKind.free),
        interval(1, 24, AvailabilityKind.busy),
      ], maxPeriods: 1),
      invalid(IcalendarComponentError.limitExceeded),
    );
    expect(
      () => output([
        interval(0, 24, AvailabilityKind.free),
      ], limits: const IcalendarSyntaxLimits(maxBytes: 40)),
      invalid(IcalendarComponentError.limitExceeded),
    );
    final w = UtcWindow(start: at(0), end: at(24 * 32));
    expect(
      () => serializeIcalendarFreeBusy(
        uid: 'x',
        stamp: at(0),
        window: w,
        partition: [
          AvailabilityInterval(window: w, kind: AvailabilityKind.free),
        ],
      ),
      invalid(),
    );
  });
  test('UID TEXT escaping cannot inject properties; controls reject', () {
    for (final uid in ['', 'x\r\nSUMMARY:private', 'x\u0000', 'x' * 1025]) {
      expect(
        () => serializeIcalendarFreeBusy(
          uid: uid,
          stamp: at(0),
          window: window,
          partition: [interval(0, 24, AvailabilityKind.free)],
        ),
        invalid(),
      );
    }
    final bytes = serializeIcalendarFreeBusy(
      uid: '界,;\\x',
      stamp: at(0),
      window: window,
      partition: [interval(0, 24, AvailabilityKind.free)],
    );
    final c = parseIcalendarSyntax(bytes).components.single.entries
        .whereType<IcalendarSyntaxComponent>()
        .single;
    expect(
      decodeIcalendarText(
        c.entries.whereType<IcalendarSyntaxProperty>().first.value,
      ),
      '界,;\\x',
    );
  });
  test('projection is deterministic for supplied snapshot metadata and does not mutate source', () {
    final periods = [
      interval(0, 10, AvailabilityKind.busy),
      interval(10, 24, AvailabilityKind.free),
    ];
    final original = List.of(periods);
    expect(output(periods), output(periods));
    expect(periods, original);
  });
}
