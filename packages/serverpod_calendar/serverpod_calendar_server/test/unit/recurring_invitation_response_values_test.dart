@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' show raw, point;

IcalendarSchedulingMessage packet(
  String body,
  int index, {
  bool cancel = false,
}) {
  final root = parseIcalendarSyntax(utf8.encode(body)).components.single;
  final event = root.entries
      .whereType<IcalendarSyntaxComponent>()
      .where((c) => c.canonicalName == 'VEVENT')
      .elementAt(index);
  final selected = cancel
      ? IcalendarSyntaxComponent('VEVENT', [
          ...event.entries.whereType<IcalendarSyntaxProperty>().where(
            (p) => {
              'UID',
              'DTSTAMP',
              'SEQUENCE',
              'RECURRENCE-ID',
              'ORGANIZER',
              'ATTENDEE',
            }.contains(p.canonicalName),
          ),
          IcalendarSyntaxProperty('STATUS', 'CANCELLED'),
        ])
      : event;
  return validateIcalendarSchedulingMessage(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        ...root.entries.where(
          (e) =>
              e is IcalendarSyntaxProperty && e.canonicalName != 'METHOD' ||
              e is IcalendarSyntaxComponent && e.canonicalName != 'VEVENT',
        ),
        IcalendarSyntaxProperty('METHOD', cancel ? 'CANCEL' : 'REQUEST'),
        selected,
      ]),
    ]),
  );
}

void main() {
  RecurringInvitationResponseTarget select(
    IcalendarSchedulingMessage master,
    CalendarEventTiming original, {
    List<IcalendarSchedulingMessage> notices = const [],
    List<IcalendarSchedulingMessage> cutoffs = const [],
    RecurrenceWorkBudget? work,
    int maxNotices = 64,
    int maxBytes = 262144,
    int maxComponents = 1000,
    int maxZones = 32,
    String recipient = 'mailto:alice@example.invalid',
  }) => resolveRecurringInvitationResponseTarget(
    master: master,
    originalStart: original,
    recipientAddress: recipient,
    notices: notices,
    activeRangeCancellations: cutoffs,
    sharedWorkBudget: work,
    maxNotices: maxNotices,
    maxBytes: maxBytes,
    maxComponents: maxComponents,
    maxZones: maxZones,
  );
  for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
    final date = profile == 'date',
        zone = {'date', 'utc'}.contains(profile) ? null : profile;
    final body = raw(
      date: date,
      zone: zone,
      own: [(2, 4, false, null), (5, 6, true, 0), (7, 8, true, 1)],
    );
    final master = packet(body, 0),
        notices = [for (var i = 1; i <= 3; i++) packet(body, i)];
    for (final (day, seq, role, anchor) in [
      (1, 2, RecurringInvitationResponseRole.master, null),
      (2, null, RecurringInvitationResponseRole.single, 2),
      (4, 2, RecurringInvitationResponseRole.master, null),
      (5, 0, RecurringInvitationResponseRole.range, 5),
      (6, 0, RecurringInvitationResponseRole.range, 5),
      (8, 1, RecurringInvitationResponseRole.range, 7),
    ]) {
      test(
        '$profile original $day selects exact $role version $seq independent of input order',
        () {
          final original = point(day, date: date, zone: zone);
          for (final order in [notices, notices.reversed.toList()]) {
            final result = select(master, original, notices: order);
            expect(result.originalStart.toJson(), original.toJson());
            expect(result.role, role);
            expect(result.sequence, seq);
            expect(result.sourceOriginalStart?.start.day, anchor);
            expect(result.blocked, isFalse);
            expect(result.stamp, DateTime.utc(2026));
          }
        },
      );
    }
    test(
      '$profile range cancellation masks later moved singles/ranges and same-anchor REQUEST',
      () {
        final body = raw(
          date: date,
          zone: zone,
          own: [(3, 4, true, 1), (6, 7, false, 90), (7, 8, true, 99)],
        );
        final master = packet(body, 0), cancel = packet(body, 1, cancel: true);
        final original = point(7, date: date, zone: zone);
        final current = [for (var i = 1; i <= 3; i++) packet(body, i)];
        final result = select(
          master,
          original,
          notices: current,
          cutoffs: [cancel],
        );
        expect(result.block, RecurringInvitationResponseBlock.rangeCancelled);
        expect(result.sourceOriginalStart!.start.day, 3);
        expect(result.sequence, 1);
        expect(
          select(
            master,
            point(2, date: date, zone: zone),
            cutoffs: [cancel],
          ).blocked,
          isFalse,
        );
        expect(select(master, original, notices: current).blocked, isFalse);
        // Omitting evidence proves no historical restoration; the helper does no lookup.
      },
    );
    test('$profile single cancellation affects only exact original', () {
      final cancel = packet(
        raw(date: date, zone: zone, own: [(2, 4, false, 1)]),
        1,
        cancel: true,
      );
      expect(
        select(
          master,
          point(2, date: date, zone: zone),
          notices: [cancel],
        ).block,
        RecurringInvitationResponseBlock.singleCancelled,
      );
      expect(
        select(
          master,
          point(3, date: date, zone: zone),
          notices: [cancel],
        ).blocked,
        isFalse,
      );
    });
  }
  test('same-anchor single wins without merging packets or changing source omissions', () {
    final body = raw(own: [(3, 4, true, 90), (3, 5, false, null)]);
    final master = packet(body, 0),
        range = packet(body, 1),
        single = packet(body, 2);
    final before = serializeIcalendarSchedulingMessage(single);
    final result = select(master, point(3), notices: [range, single]);
    expect(result.role, RecurringInvitationResponseRole.single);
    expect(result.sequence, isNull);
    expect(result.sourceMessage.events.single.summary?.value, 'Own 3');
    expect(serializeIcalendarSchedulingMessage(single), before);
    expect(result.sourceMessage.events.single.startTime!.civil.date.day, 5);
    expect(result.originalStart.start.day, 3);
  });
  test(
    'all anchors/claims validate before a master selection or blocked return',
    () {
      final valid = raw(own: [(5, 6, true, 12)]), master = packet(valid, 0);
      for (final bad in [
        packet(
          valid.replaceAll(
            'published@example.invalid',
            'other@example.invalid',
          ),
          1,
        ),
        packet(
          valid.replaceAll(
            'organizer@example.invalid',
            'other@example.invalid',
          ),
          1,
        ),
        packet(
          valid.replaceAll('alice@example.invalid', 'other@example.invalid'),
          1,
        ),
        packet(raw(own: [(9, 10, true, 1)]), 1),
        packet(raw(zone: 'US/Eastern', own: [(5, 6, true, 1)]), 1),
      ]) {
        expect(
          () => select(master, point(1), notices: [bad]),
          throwsArgumentError,
        );
        expect(
          () => select(
            master,
            point(7),
            notices: [bad],
            cutoffs: [packet(valid, 1, cancel: true)],
          ),
          throwsArgumentError,
        );
      }
    },
  );
  test('duplicate targets reject even for identical source and noncontrolling notices', () {
    final body = raw(own: [(5, 6, true, 1)]),
        master = packet(body, 0),
        range = packet(body, 1);
    expect(
      () => select(master, point(1), notices: [range, range]),
      throwsArgumentError,
    );
    final cancel = packet(body, 1, cancel: true);
    expect(
      () => select(master, point(1), cutoffs: [cancel, cancel]),
      throwsArgumentError,
    );
    expect(
      () => select(master, point(7), notices: [cancel]),
      throwsArgumentError,
    );
    expect(
      () => select(master, point(7), cutoffs: [range]),
      throwsArgumentError,
    );
  });
  test(
    'membership includes earlier RDATE and PERIOD, exclusions still win',
    () {
      final body = raw(
        startDay: 3,
        extra: [
          'RDATE:20300101T090000Z',
          'RDATE;VALUE=PERIOD:20300110T090000Z/PT2H',
          'EXDATE:20300104T090000Z',
        ],
      );
      final master = packet(body, 0);
      expect(
        select(master, point(1)).role,
        RecurringInvitationResponseRole.master,
      );
      expect(select(master, point(10)).sequence, 2);
      expect(() => select(master, point(4)), throwsArgumentError);
    },
  );
  test('DATE/UTC/alias/fraction/end identities are never guessed', () {
    final master = packet(raw(zone: 'US/Eastern'), 0);
    for (final original in [
      point(2),
      point(2, date: true),
      point(2, zone: 'America/New_York'),
      point(
        2,
        zone: 'US/Eastern',
      ).copyWith(duration: CalendarEventDuration(seconds: 1)),
      point(2, zone: 'US/Eastern').copyWith(
        start: CalendarEventCivil(
          year: 2030,
          month: 1,
          day: 2,
          hour: 9,
          microsecond: 1,
        ),
      ),
      point(1, year: 2100, zone: 'US/Eastern'),
    ]) {
      expect(() => select(master, original), throwsArgumentError);
    }
  });
  test(
    'gap generated originals are absent, fold retains exact local identity',
    () {
      final gap = packet(
        raw(
          zone: 'Europe/Stockholm',
          prefix: '203003',
          startDay: 30,
          time: '023000',
        ),
        0,
      );
      expect(
        () => select(
          gap,
          point(31, zone: 'Europe/Stockholm', month: 3, hour: 2, minute: 30),
        ),
        throwsArgumentError,
      );
      final fold = packet(
        raw(
          zone: 'Europe/Stockholm',
          prefix: '203010',
          startDay: 26,
          time: '023000',
        ),
        0,
      );
      expect(
        select(
          fold,
          point(27, zone: 'Europe/Stockholm', month: 10, hour: 2, minute: 30),
        ).blocked,
        isFalse,
      );
    },
  );
  test(
    'cancelled REQUEST and whole CANCEL never become eligible membership bases',
    () {
      expect(
        () => packet(
          raw().replaceFirst(
            'SUMMARY:Master',
            'STATUS:CANCELLED\r\nSUMMARY:Master',
          ),
          0,
        ),
        throwsA(isA<IcalendarComponentException>()),
      );
      expect(
        () => select(packet(raw(), 0, cancel: true), point(3)),
        throwsArgumentError,
      );
    },
  );
  test('budgets aggregate all packets and do not return partial selection', () {
    final body = raw(own: [(5, 6, true, 1)]),
        master = packet(body, 0),
        notice = packet(body, 1);
    expect(
      () => select(master, point(1), notices: [notice], maxNotices: 0),
      throwsA(isA<RecurrenceLimitException>()),
    );
    final size = serializeIcalendarSchedulingMessage(master).length;
    expect(
      () => select(master, point(1), notices: [notice], maxBytes: size + 1),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => select(master, point(1), notices: [notice], maxComponents: 3),
      throwsA(isA<RecurrenceLimitException>()),
    );
    final zoned = raw(zone: 'US/Eastern', own: [(5, 6, true, 1)]);
    expect(
      () => select(
        packet(zoned, 0),
        point(1, zone: 'US/Eastern'),
        notices: [packet(zoned, 1)],
        maxZones: 1,
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => select(
        master,
        point(1),
        notices: [notice],
        work: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () =>
          select(master, point(1), work: RecurrenceWorkBudget(maxWork: 200001)),
      throwsArgumentError,
    );
  });
  test('non-recurring, detached and complete bundles are not ordinary master bases', () {
    expect(
      () => select(packet(raw(rule: null), 0), point(1)),
      throwsArgumentError,
    );
    expect(
      () => select(packet(raw(own: [(2, 4, false, 1)]), 1), point(2)),
      throwsArgumentError,
    );
    expect(
      () => select(
        parseIcalendarSchedulingMessage(
          utf8.encode(raw(own: [(2, 4, false, 1)])),
        ),
        point(2),
      ),
      throwsArgumentError,
    );
  });
  test('64 notices fit one shared ceiling; a 65th cannot be admitted', () {
    final master = packet(raw(rule: 'FREQ=DAILY;COUNT=90'), 0);
    final notices = [
      for (var i = 0; i < 65; i++)
        (() {
          final d = DateTime.utc(2030).add(Duration(days: i));
          return packet(
            raw(
              prefix: '${d.year}${d.month.toString().padLeft(2, '0')}',
              own: [(d.day, d.day, false, i)],
            ),
            1,
          );
        })(),
    ];
    expect(
      select(master, point(1), notices: notices.take(64).toList()).sequence,
      0,
    );
    expect(
      () => select(master, point(1), notices: notices),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test(
    'all participant claims validate, including a noncontrolling notice',
    () {
      final body = raw(own: [(5, 6, true, 1)]), master = packet(body, 0);
      for (final changed in [
        body.replaceAll(
          'ORGANIZER;CN=Organizer:',
          'ORGANIZER;SENT-BY="mailto:agent@example.invalid":',
        ),
        body.replaceAll(
          'ROLE=REQ-PARTICIPANT',
          'ROLE=REQ-PARTICIPANT;DELEGATED-TO="mailto:agent@example.invalid"',
        ),
      ]) {
        expect(
          () => select(master, point(1), notices: [packet(changed, 1)]),
          throwsArgumentError,
        );
      }
      expect(
        () =>
            select(master, point(1), recipient: 'mailto:other@example.invalid'),
        throwsArgumentError,
      );
    },
  );
  test(
    'unprofiled properties and alarms reject at the complete packet boundary',
    () {
      for (final extra in [
        'X-UNSUPPORTED:value',
        'BEGIN:VALARM\r\nACTION:DISPLAY\r\nTRIGGER:-PT5M\r\nDESCRIPTION:Unarmed\r\nEND:VALARM',
      ]) {
        expect(
          () => packet(raw(extra: [extra]), 0),
          throwsA(isA<IcalendarComponentException>()),
        );
      }
    },
  );
  test(
    'multiple active cutoffs are order independent and retain blocking source',
    () {
      final body = raw(own: [(3, 4, true, 8), (5, 6, true, 2)]),
          master = packet(body, 0);
      final cutoffs = [
        packet(body, 1, cancel: true),
        packet(body, 2, cancel: true),
      ];
      for (final order in [cutoffs, cutoffs.reversed.toList()]) {
        final result = select(master, point(7), cutoffs: order);
        expect(result.sourceOriginalStart!.start.day, 3);
        expect(result.sequence, 8);
        expect(result.blocked, isTrue);
      }
    },
  );
}
