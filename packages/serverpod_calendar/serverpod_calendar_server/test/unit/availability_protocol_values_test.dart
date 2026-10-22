@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/availability_values.dart';
import 'package:serverpod_calendar_server/src/availability_protocol_values.dart';

final uid = UuidValue.fromString('11111111-1111-4111-8111-111111111111');
final other = UuidValue.fromString('22222222-2222-4222-8222-222222222222');
CalendarEventTiming start({
  int year = 2026,
  int month = 3,
  int day = 28,
  bool zoned = false,
}) => CalendarEventTiming(
  kind: zoned ? CalendarEventTimeKind.zoned : CalendarEventTimeKind.utc,
  zoneId: zoned ? 'Europe/Stockholm' : null,
  start: CalendarEventCivil(
    year: year,
    month: month,
    day: day,
    hour: year == 2099 ? 0 : 12,
  ),
);
CalendarAvailabilityContent content() => validateAvailabilityContent(
  CalendarAvailabilityContent(
    openings: [
      CalendarAvailabilityOpening(
        uid: uid,
        timing: start().copyWith(duration: CalendarEventDuration(hours: 1)),
      ),
    ],
  ),
);
void main() {
  final created = DateTime.utc(2026, 1, 1, 0, 0, 0, 123),
      modified = DateTime.utc(2026, 1, 2, 0, 0, 0, 987),
      later = DateTime.utc(2026, 1, 3);
  test(
    'legacy baseline is read-only frozen and does not invent opening creation',
    () {
      final c = content(),
          baseline = availabilityProtocolBaseline(
            content(),
            created,
            modified,
            legacy: true,
          );
      expect(baseline.created, DateTime.utc(2026, 1, 1));
      expect(baseline.sequence, 0);
      expect(baseline.openings.single.created, isNull);
      expect(baseline.openings.single.stamp, baseline.stamp);
      expect(() => baseline.openings.clear(), throwsUnsupportedError);
      expect(
        validateAvailabilityProtocolState(
          baseline,
          c,
        ).openings.single.openingUid,
        uid,
      );
    },
  );
  test('identical normalized state preserves sequence and stamps', () {
    final c = content(),
        baseline = availabilityProtocolBaseline(content(), created, modified);
    final next = advanceAvailabilityProtocol(
      baseline,
      c,
      null,
      validateAvailabilityContent(c.copyWith(categories: [])),
      null,
      later,
    );
    expect(next.toJson(), baseline.toJson());
  });
  test(
    'metadata advances envelope only while opening edit advances its own stamp',
    () {
      final c = content(),
          baseline = availabilityProtocolBaseline(content(), created, modified);
      final envelope = c.copyWith(summary: 'Updated');
      final next = advanceAvailabilityProtocol(
        baseline,
        c,
        null,
        envelope,
        null,
        later,
      );
      expect(next.sequence, 1);
      expect(next.created, baseline.created);
      expect(next.openings.single.stamp, baseline.openings.single.stamp);
      final opening = envelope.copyWith(
        openings: [envelope.openings.single.copyWith(summary: 'Opening')],
      );
      final result = advanceAvailabilityProtocol(
        next,
        envelope,
        null,
        opening,
        null,
        later,
      );
      expect(result.sequence, 2);
      expect(result.openings.single.stamp, later);
      expect(result.openings.single.created, baseline.openings.single.created);
    },
  );
  test('new and deleted opening timestamps follow stable identity', () {
    final c = content(),
        baseline = availabilityProtocolBaseline(
          content(),
          created,
          modified,
          legacy: true,
        );
    final added = c.copyWith(
      openings: [
        ...c.openings,
        c.openings.single.copyWith(uid: other),
      ],
    );
    final next = advanceAvailabilityProtocol(
      baseline,
      c,
      null,
      added,
      null,
      later,
    );
    expect(next.openings.first.created, isNull);
    expect(next.openings.last.created, later);
    final removed = added.copyWith(openings: [added.openings.last]);
    expect(
      advanceAvailabilityProtocol(
        next,
        added,
        null,
        removed,
        null,
        later,
      ).openings.single.openingUid,
      other,
    );
  });
  test('sequence maximum rejects changes but permits identical state', () {
    final c = content(),
        baseline = availabilityProtocolBaseline(
          content(),
          created,
          modified,
        ).copyWith(sequence: availabilityMaxSequence);
    expect(
      advanceAvailabilityProtocol(baseline, c, null, c, null, later).sequence,
      availabilityMaxSequence,
    );
    expect(
      () => advanceAvailabilityProtocol(
        baseline,
        c,
        null,
        c.copyWith(summary: 'New'),
        null,
        later,
      ),
      throwsA(isA<AvailabilityLimitException>()),
    );
    expect(
      () =>
          validateAvailabilityProtocolState(baseline.copyWith(sequence: -1), c),
      throwsArgumentError,
    );
  });
  test(
    'invalid identities and fractional stamps reject; clock correction clamps',
    () {
      final c = content(),
          baseline = availabilityProtocolBaseline(content(), created, modified);
      expect(
        () => validateAvailabilityProtocolState(
          baseline.copyWith(
            stamp: modified.add(const Duration(microseconds: 1)),
          ),
          c,
        ),
        throwsArgumentError,
      );
      expect(
        () => validateAvailabilityProtocolState(
          baseline.copyWith(openings: []),
          c,
        ),
        throwsArgumentError,
      );
      final clamped = advanceAvailabilityProtocol(
        baseline,
        c,
        null,
        c.copyWith(summary: 'New'),
        null,
        created,
      );
      expect(clamped.stamp, baseline.stamp);
      expect(clamped.sequence, 1);
    },
  );
  test('envelope duration preserves units and nominal DST days differ from elapsed hours', () {
    final c = content().copyWith(
      validFrom: start(zoned: true),
      validDuration: CalendarEventDuration(days: 1),
    );
    expect(availabilityEnvelopeEnd(c), DateTime.utc(2026, 3, 29, 10));
    final elapsed = c.copyWith(validDuration: CalendarEventDuration(hours: 24));
    expect(availabilityEnvelopeEnd(elapsed), DateTime.utc(2026, 3, 29, 11));
    expect(validateAvailabilityContent(c).validDuration!.days, 1);
  });
  test(
    'envelope duration requires start excludes end and rejects invalid units',
    () {
      final c = content();
      for (final v in [
        c.copyWith(validDuration: CalendarEventDuration(days: 1)),
        c.copyWith(
          validFrom: start(),
          validUntil: start(day: 30),
          validDuration: CalendarEventDuration(days: 1),
        ),
        c.copyWith(validFrom: start(), validDuration: CalendarEventDuration()),
        c.copyWith(
          validFrom: start(),
          validDuration: CalendarEventDuration(seconds: -1),
        ),
        c.copyWith(
          validFrom: start(),
          validDuration: CalendarEventDuration(microsecond: 1),
        ),
        c.copyWith(
          validFrom: start(),
          validDuration: CalendarEventDuration(weeks: 1, days: 1),
        ),
      ]) {
        expect(() => validateAvailabilityContent(v), throwsArgumentError);
      }
    },
  );
  test(
    'envelope duration permits exclusive 2100 boundary but rejects overflow',
    () {
      final c = content().copyWith(
        validFrom: start(year: 2099, month: 12, day: 31),
        validDuration: CalendarEventDuration(days: 1),
      );
      expect(availabilityEnvelopeEnd(c), DateTime.utc(2100));
      expect(
        () => validateAvailabilityContent(
          c.copyWith(validDuration: CalendarEventDuration(days: 2)),
        ),
        throwsArgumentError,
      );
    },
  );
}
