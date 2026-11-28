import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/free_busy_exchange_values.dart';
import 'package:test/test.dart';

void main() {
  final window = UtcWindow(
    start: DateTime.utc(2026, 11, 6),
    end: DateTime.utc(2026, 11, 7),
  );
  final stamp = DateTime.utc(2026, 11, 5);
  final complete = [
    AvailabilityInterval(window: window, kind: AvailabilityKind.free),
  ];
  IcalendarFreeBusyMessage build({
    IcalendarFreeBusyMethod method = IcalendarFreeBusyMethod.publish,
    Iterable<String> attendees = const [],
    List<AvailabilityInterval>? partition,
    bool refused = false,
  }) => buildCalendarFreeBusyExchange(
    method: method,
    uid: 'synthetic-report@example.invalid',
    stamp: stamp,
    window: window,
    organizer: 'mailto:requester@example.invalid',
    attendees: attendees,
    partition: partition,
    refused: refused,
  );

  test('complete free report is distinct from refusal', () {
    final free = build(partition: complete);
    expect(free.components.single.groups, isEmpty);
    expect(free.components.single.requestStatuses, isEmpty);
    final refusal = build(
      method: IcalendarFreeBusyMethod.reply,
      attendees: ['mailto:respondent@example.invalid'],
      refused: true,
    );
    expect(refusal.components.single.groups, isEmpty);
    expect(refusal.components.single.requestStatuses, hasLength(1));
    expect(
      utf8.decode(calendarFreeBusyExchangeBytes(refusal)),
      contains('REQUEST-STATUS:3.8;No authority'),
    );
  });

  test('report requires complete coverage, including an all-free result', () {
    expect(() => build(), throwsArgumentError);
    expect(() => build(partition: []), throwsA(anything));
    expect(
      () => build(
        partition: [
          AvailabilityInterval(
            window: UtcWindow(
              start: window.start,
              end: DateTime.utc(2026, 11, 6, 1),
            ),
            kind: AvailabilityKind.busy,
          ),
        ],
      ),
      throwsA(anything),
    );
  });

  test('request contains only roles and window, never a report', () {
    final request = build(
      method: IcalendarFreeBusyMethod.request,
      attendees: ['mailto:target@example.invalid'],
    );
    expect(request.components.single.groups, isEmpty);
    expect(request.components.single.attendees, [
      'mailto:target@example.invalid',
    ]);
    expect(
      () => build(
        method: IcalendarFreeBusyMethod.request,
        attendees: ['mailto:target@example.invalid'],
        partition: complete,
      ),
      throwsArgumentError,
    );
  });

  test('recipient cardinality and refusal shape fail before serialization', () {
    expect(
      () => build(method: IcalendarFreeBusyMethod.request),
      throwsArgumentError,
    );
    expect(
      () => build(method: IcalendarFreeBusyMethod.reply, partition: complete),
      throwsArgumentError,
    );
    expect(
      () => build(attendees: ['mailto:x@example.invalid'], partition: complete),
      throwsArgumentError,
    );
    expect(() => build(refused: true), throwsArgumentError);
    expect(
      () => build(
        method: IcalendarFreeBusyMethod.reply,
        attendees: ['mailto:x@example.invalid'],
        partition: complete,
        refused: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => build(
        method: IcalendarFreeBusyMethod.request,
        attendees: List.filled(2, 'mailto:x@example.invalid'),
      ),
      throwsArgumentError,
    );
    expect(
      () => build(
        method: IcalendarFreeBusyMethod.request,
        attendees: List.generate(65, (i) => 'mailto:x$i@example.invalid'),
      ),
      throwsArgumentError,
    );
  });

  test(
    'busy classifications survive with no native identity or event text',
    () {
      final periods = [
        for (var i = 0; i < 4; i++)
          AvailabilityInterval(
            window: UtcWindow(
              start: window.start.add(Duration(hours: i * 6)),
              end: window.start.add(Duration(hours: (i + 1) * 6)),
            ),
            kind: [
              AvailabilityKind.free,
              AvailabilityKind.busy,
              AvailabilityKind.tentative,
              AvailabilityKind.unavailable,
            ][i],
          ),
      ];
      final report = build(partition: periods);
      expect(report.components.single.groups.map((g) => g.effectiveType), [
        'BUSY',
        'BUSY-TENTATIVE',
        'BUSY-UNAVAILABLE',
      ]);
      final text = utf8.decode(calendarFreeBusyExchangeBytes(report));
      expect(text, isNot(contains('SUMMARY')));
      expect(text, isNot(contains('VEVENT')));
      expect(text, isNot(contains('ATTENDEE')));
      expect(
        calendarFreeBusyExchangeBytes(report),
        calendarFreeBusyExchangeBytes(report),
      );
    },
  );

  test('native profile rejects fractional stamps and oversized windows', () {
    for (final value in [
      stamp.add(const Duration(milliseconds: 1)),
      stamp.toLocal(),
    ]) {
      if (value.isUtc) continue;
      expect(
        () => buildCalendarFreeBusyExchange(
          method: IcalendarFreeBusyMethod.request,
          uid: 'x',
          stamp: value,
          window: window,
          organizer: 'mailto:a@example.invalid',
          attendees: ['mailto:b@example.invalid'],
        ),
        throwsA(anything),
      );
    }
    expect(
      () => buildCalendarFreeBusyExchange(
        method: IcalendarFreeBusyMethod.request,
        uid: 'x',
        stamp: stamp.add(const Duration(milliseconds: 1)),
        window: window,
        organizer: 'mailto:a@example.invalid',
        attendees: ['mailto:b@example.invalid'],
      ),
      throwsA(anything),
    );
    expect(
      () => buildCalendarFreeBusyExchange(
        method: IcalendarFreeBusyMethod.request,
        uid: 'x',
        stamp: stamp,
        window: UtcWindow(
          start: window.start,
          end: window.end.add(const Duration(days: 31)),
        ),
        organizer: 'mailto:a@example.invalid',
        attendees: ['mailto:b@example.invalid'],
      ),
      throwsArgumentError,
    );
  });
  test('reply preserves source UIDs beyond the native editing limit, including escaped TEXT', () {
    final uid = '${List.filled(2048, 'ü').join()},;\\\n';
    final reply = buildCalendarFreeBusyExchange(
      method: IcalendarFreeBusyMethod.reply,
      uid: uid,
      stamp: stamp,
      window: window,
      organizer: 'mailto:requester@example.invalid',
      attendees: ['mailto:respondent@example.invalid'],
      partition: complete,
    );
    expect(reply.components.single.uid, uid);
    expect(
      utf8.decode(calendarFreeBusyExchangeBytes(reply)),
      isNot(contains('partition-validation')),
    );
  });
}
