@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' as fixture;

IcalendarSyntaxDocument document(String text) =>
    parseIcalendarSyntax(utf8.encode(text));

void main() {
  test(
    'rejects changing an occurrence status omission to an explicit default',
    () {
      final raw = fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2)],
      );
      final changed = raw.replaceFirst(
        'SUMMARY:Own 3',
        'STATUS:CONFIRMED\r\nSUMMARY:Own 3',
      );
      expect(
        () => validatePublishedRangeRestorationPair(
          basis: document(raw),
          candidate: document(changed),
        ),
        throwsArgumentError,
      );
    },
  );
  test('rejects changing an omitted master status to an explicit default', () {
    final raw = fixture.raw(date: true, rule: 'FREQ=DAILY;UNTIL=20300108');
    final changed = raw.replaceFirst(
      'SUMMARY:Master',
      'STATUS:CONFIRMED\r\nSUMMARY:Master',
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: document(raw),
        candidate: document(changed),
      ),
      throwsArgumentError,
    );
  });
  test('preserves absent optional text when creating a future component', () {
    final raw = fixture
        .raw(
          date: true,
          rule: 'FREQ=DAILY;UNTIL=20300108',
          own: [(3, 5, false, 2)],
        )
        .replaceFirst('DESCRIPTION:Private retained text\r\n', '');
    final basis = document(raw);
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    final future = validateIcalendarSchedulingMessage(candidate).events
        .singleWhere((v) => v.isThisAndFuture);
    expect(future.description, isNull);
    expect(future.location, isNull);
  });
  test('COUNT exhaustion preserves a final moved original without a range', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;COUNT=3',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(
      validateIcalendarSchedulingMessage(candidate).events
          .where((v) => v.isThisAndFuture),
      isEmpty,
    );
  });
  test('skips a generated spring DST gap when locating the next original', () {
    const zone = 'Europe/Stockholm';
    final basis = document(
      fixture.raw(
        zone: zone,
        prefix: '202603',
        time: '023000',
        startDay: 28,
        rule: 'FREQ=DAILY;COUNT=4',
        own: [(28, 30, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(
        28,
        zone: zone,
        year: 2026,
        month: 3,
        hour: 2,
        minute: 30,
      ),
    );
    expect(
      validateIcalendarSchedulingMessage(candidate).events
          .singleWhere((v) => v.isThisAndFuture)
          .originalTime!
          .civil
          .date
          .day,
      30,
    );
  });
  test('uses the original identity through an autumn DST fold', () {
    const zone = 'Europe/Stockholm';
    final basis = document(
      fixture.raw(
        zone: zone,
        prefix: '202610',
        time: '023000',
        startDay: 24,
        rule: 'FREQ=DAILY;COUNT=4',
        own: [(24, 26, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(
        24,
        zone: zone,
        year: 2026,
        month: 10,
        hour: 2,
        minute: 30,
      ),
    );
    final next = validateIcalendarSchedulingMessage(candidate).events
        .singleWhere((v) => v.isThisAndFuture)
        .originalTime!;
    expect(next.civil.date.day, 25);
    expect(next.instant, DateTime.utc(2026, 10, 25, 0, 30));
  });
  test('rejects a projection that would exceed the 64-original limit', () {
    final base = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;COUNT=70',
      own: [(2, 3, false, 2)],
      extra: ['LOCATION:Room'],
    );
    String stamp(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}';
    final overrides = <String>[];
    for (var i = 3; i < 66; i++) {
      final day = stamp(DateTime.utc(2030, 1, 1).add(Duration(days: i)));
      overrides.addAll([
        'BEGIN:VEVENT',
        'UID:published@example.invalid',
        'DTSTAMP:20260101T000000Z',
        'SEQUENCE:2',
        'RECURRENCE-ID;VALUE=DATE:$day',
        'DTSTART;VALUE=DATE:$day',
        'SUMMARY:Master',
        'ORGANIZER;CN=Organizer:mailto:organizer@example.invalid',
        'ATTENDEE;CN=Alice;ROLE=REQ-PARTICIPANT:mailto:alice@example.invalid',
        'END:VEVENT',
      ]);
    }
    final text = base.replaceFirst(
      'END:VCALENDAR\r\n',
      '${overrides.join('\r\n')}\r\nEND:VCALENDAR\r\n',
    );
    final basis = document(text);
    expect(
      () =>
          validatePublishedRangeRestorationPair(basis: basis, candidate: basis),
      returnsNormally,
    );
    expect(
      () => projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(2, date: true),
      ),
      throwsA(
        isA<RecurrenceLimitException>().having(
          (e) => e.limit,
          'limit',
          'schedulingOriginals',
        ),
      ),
    );
  });
  test('caller cannot widen the shared work ceiling', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    expect(
      () => projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(3, date: true),
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 200001),
      ),
      throwsArgumentError,
    );
  });
  test('rejects a source exceeding the fixed byte limit', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final root = basis.components.single;
    final oversized = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent(root.name, [
        ...root.entries,
        IcalendarSyntaxProperty('X-PADDING', 'x' * 524289),
      ]),
    ]);
    expect(
      () => projectPublishedExceptionalRangeRestoration(
        basis: oversized,
        originalStart: fixture.point(3, date: true),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('accepts COUNT rules when all counted originals fit in the horizon', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;COUNT=8',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(validateIcalendarSchedulingMessage(candidate).events.length, 3);
  });
  test('invalid source diagnostics do not echo participant text', () {
    final raw = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;UNTIL=20300108',
      own: [(3, 5, false, 2)],
      extra: ['LOCATION:Room'],
    );
    final missing = document(
      raw.replaceAll(
        'ATTENDEE;CN=Alice;ROLE=REQ-PARTICIPANT:mailto:alice@example.invalid\r\n',
        '',
      ),
    );
    Object? captured;
    try {
      projectPublishedExceptionalRangeRestoration(
        basis: missing,
        originalStart: fixture.point(3, date: true),
      );
    } catch (error) {
      captured = error;
    }
    expect(captured, isA<ArgumentError>());
    expect(captured.toString(), isNot(contains('organizer@example.invalid')));
  });
  test('rejects an incompatible single component at the next original', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2), (4, 6, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    expect(
      () => projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      ),
      throwsArgumentError,
    );
  });
  test('restores a bounded exception near the 2100 horizon', () {
    final basis = document(
      fixture.raw(
        date: true,
        prefix: '209912',
        startDay: 27,
        rule: 'FREQ=DAILY;UNTIL=20991231',
        own: [(29, 30, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(29, date: true, year: 2099, month: 12),
    );
    expect(
      validateIcalendarSchedulingMessage(candidate).events
          .where((v) => v.isThisAndFuture)
          .single
          .originalDate!
          .day,
      30,
    );
  });
  test('final exceptional original emits no invented future component', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300103',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    expect(
      validateIcalendarSchedulingMessage(candidate).events
          .where((v) => v.isThisAndFuture),
      isEmpty,
    );
  });

  test('exhausted shared budget cannot return a partial REQUEST', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    expect(
      () => projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(3, date: true),
        sharedWorkBudget: RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(isA<RecurrenceLimitException>()),
    );
  });
  test('retains the individual duration of a later PERIOD addition', () {
    final basis = document(
      fixture.raw(
        rule: 'FREQ=DAILY;UNTIL=20300108T090000Z',
        own: [(3, 5, false, 2)],
        extra: [
          'LOCATION:Room',
          'RDATE;VALUE=PERIOD:20300106T090000Z/20300106T130000Z',
        ],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3),
    );
    final events = validateIcalendarSchedulingMessage(candidate).events;
    expect(
      events
          .where((v) => v.isOverride)
          .map((v) => v.originalTime!.civil.date.day),
      containsAll([3, 4, 6]),
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: basis,
        candidate: candidate,
      ),
      returnsNormally,
    );
  });
  test('keeps an excluded anchor while restoring later originals', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        extra: ['LOCATION:Room', 'EXDATE;VALUE=DATE:20300103'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    final result = validateIcalendarSchedulingMessage(candidate);
    expect(
      result.events.where((v) => v.isThisAndFuture).single.originalDate!.day,
      4,
    );
    final master = result.events.singleWhere((v) => !v.isOverride);
    expect(master.recurrence!.dateSet!.exclusions.any((v) => v.day == 3), true);
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: basis,
        candidate: candidate,
      ),
      returnsNormally,
    );
  });
  test(
    'reuses a future component at the next original without changing it',
    () {
      final basis = document(
        fixture.raw(
          date: true,
          rule: 'FREQ=DAILY;UNTIL=20300108',
          own: [(3, 5, false, 2), (4, 5, true, 3)],
          extra: ['LOCATION:Room'],
        ),
      );
      final candidate = projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(3, date: true),
      );
      expect(validateIcalendarSchedulingMessage(candidate).events.length, 3);
      expect(
        () => validatePublishedRangeRestorationPair(
          basis: basis,
          candidate: candidate,
        ),
        returnsNormally,
      );
    },
  );
  for (final zone in <String?>[null, 'Europe/Stockholm', 'US/Eastern']) {
    test('builds timed restoration REQUEST for ${zone ?? "UTC"}', () {
      final basis = document(
        fixture.raw(
          zone: zone,
          rule: 'FREQ=DAILY;UNTIL=20300108T090000Z',
          own: [(3, 5, false, 2)],
          extra: ['LOCATION:Room'],
        ),
      );
      final candidate = projectPublishedExceptionalRangeRestoration(
        basis: basis,
        originalStart: fixture.point(3, zone: zone),
      );
      final result = validateIcalendarSchedulingMessage(candidate);
      expect(
        result.events
            .where((v) => v.isThisAndFuture)
            .single
            .originalTime!
            .civil
            .date
            .day,
        4,
      );
    });
  }
  test('rejects changing source inheritance even when text is equal', () {
    final raw = fixture
        .raw(
          date: true,
          rule: 'FREQ=DAILY;UNTIL=20300108',
          own: [(3, 5, false, 2)],
        )
        .replaceFirst(
          'SUMMARY:Own 3',
          'SUMMARY:Own 3\r\nDESCRIPTION:Private retained text',
        );
    final index = raw.lastIndexOf('DESCRIPTION:Private retained text\r\n');
    final changed = raw.replaceRange(
      index,
      index + 'DESCRIPTION:Private retained text\r\n'.length,
      '',
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: document(raw),
        candidate: document(changed),
      ),
      throwsArgumentError,
    );
  });
  test('builds a bounded REQUEST restoring a moved original and suffix', () {
    final basis = document(
      fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;UNTIL=20300108',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      ),
    );
    final candidate = projectPublishedExceptionalRangeRestoration(
      basis: basis,
      originalStart: fixture.point(3, date: true),
    );
    final parsed = validateIcalendarSchedulingMessage(candidate);
    expect(parsed.events.length, 3);
    expect(
      parsed.events.where((v) => v.isThisAndFuture).single.originalDate!.day,
      4,
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: basis,
        candidate: candidate,
      ),
      returnsNormally,
    );
  });
  test('rejects changed component versions and unbounded source rules', () {
    const rule = 'FREQ=DAILY;UNTIL=20300108';
    final source = document(
      fixture.raw(date: true, rule: rule, own: [(3, 5, false, 2)]),
    );
    final changed = document(
      fixture.raw(date: true, rule: rule, own: [(3, 5, false, 3)]),
    );
    final unbounded = document(fixture.raw(date: true, rule: 'FREQ=DAILY'));
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: source,
        candidate: changed,
      ),
      throwsArgumentError,
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: unbounded,
        candidate: unbounded,
      ),
      throwsArgumentError,
    );
  });
  test('accepts a matching bounded complete REQUEST', () {
    final source = document(
      fixture.raw(date: true, rule: 'FREQ=DAILY;UNTIL=20300108'),
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: source,
        candidate: source,
      ),
      returnsNormally,
    );
  });

  test('rejects changed master claims and altered occurrence timing', () {
    final raw = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;UNTIL=20300108',
      own: [(3, 4, false, 2)],
    );
    final source = document(raw);
    final otherClaim = document(
      raw.replaceAll(
        'mailto:alice@example.invalid',
        'mailto:other@example.invalid',
      ),
    );
    final otherTiming = document(
      raw.replaceFirst(
        'DTSTART;VALUE=DATE:20300104',
        'DTSTART;VALUE=DATE:20300105',
      ),
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: source,
        candidate: otherClaim,
      ),
      throwsArgumentError,
    );
    expect(
      () => validatePublishedRangeRestorationPair(
        basis: source,
        candidate: otherTiming,
      ),
      throwsArgumentError,
    );
  });

  test(
    'accepts an equivalent future component following a moved exception',
    () {
      const rule = 'FREQ=DAILY;UNTIL=20300108';
      final source = document(
        fixture.raw(date: true, rule: rule, own: [(3, 5, false, 2)]),
      );
      final projected = document(
        fixture
            .raw(
              date: true,
              rule: rule,
              own: [(3, 5, false, 2), (4, 4, true, 2)],
            )
            .replaceFirst('SUMMARY:Own 4', 'SUMMARY:Master'),
      );
      expect(
        () => validatePublishedRangeRestorationPair(
          basis: source,
          candidate: projected,
        ),
        returnsNormally,
      );
    },
  );
}
