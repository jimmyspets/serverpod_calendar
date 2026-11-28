@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/exceptional_range_proof.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' as fixture;

void main() {
  test(
    'committed REQUEST must match both proof and trusted version ledger',
    () {
      final basis = fixture.raw(
        date: true,
        rule: 'FREQ=DAILY;COUNT=8',
        own: [(3, 5, false, 2)],
        extra: ['LOCATION:Room'],
      );
      final proof = ExceptionalRangeProof.create(
        basis: basis,
        anchor: fixture.point(3, date: true),
        masks: [],
      );
      final candidate =
          (jsonDecode(proof.encoded) as Map<String, dynamic>)['candidate']
              as String;
      final message = parseIcalendarSchedulingMessage(utf8.encode(candidate));
      final versions = <String, (int, DateTime)>{
        for (final event in message.events)
          if (!event.isOverride)
            'master': (7, DateTime.utc(2026))
          else
            eventComponentKey(
              CalendarEventTiming(
                kind: CalendarEventTimeKind.date,
                start: eventDate(event.originalDate!),
              ),
              event.isThisAndFuture,
            ): (
              7,
              DateTime.utc(2026),
            ),
      };
      final actual = candidate.replaceAll('SEQUENCE:2', 'SEQUENCE:7');
      expect(
        () => proof.requireCommittedRequest(actual, versions),
        returnsNormally,
      );
      expect(() => proof.requireUnmaskedLineage(actual), returnsNormally);
      expect(
        () => proof.requireUnmaskedLineage(
          actual.replaceFirst('SUMMARY:Own 3', 'SUMMARY:Lost'),
        ),
        throwsArgumentError,
      );
      expect(
        () => proof.requireCommittedRequest(
          actual.replaceFirst('SUMMARY:Master', 'SUMMARY:Changed'),
          versions,
        ),
        throwsArgumentError,
      );
      expect(
        () => proof.requireCommittedRequest(candidate, versions),
        throwsArgumentError,
      );
      expect(
        () => proof.requireCommittedRequest(
          actual.replaceFirst('SUMMARY:Own 3', 'SUMMARY:Changed'),
          versions,
        ),
        throwsArgumentError,
      );
      expect(
        () => proof.requireCommittedRequest(
          actual,
          {...versions}..remove('master'),
        ),
        throwsArgumentError,
      );
    },
  );
  test('flat v8 carrier reconstructs proof without nesting v8 history', () {
    final basis = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;COUNT=8',
      own: [(3, 5, false, 2)],
      extra: ['LOCATION:Room'],
    );
    final proof = ExceptionalRangeProof.create(
      basis: basis,
      anchor: fixture.point(3, date: true),
      masks: [],
    );
    final v7 = <String, dynamic>{
      'version': 7,
      'kind': 'rangeCancel',
      'facts': {'source': 'synthetic'},
    };
    final encoded = ExceptionalRangeEnvelope.write(v7, proof);
    final decoded = ExceptionalRangeEnvelope.read(encoded);
    expect(decoded.v7, v7);
    expect(decoded.proof.encoded, proof.encoded);
    final frozen = <String, dynamic>{
      'snapshot': '{"version":3}',
      'projection': '{}',
      'payload': 'synthetic',
      'method': 'REQUEST',
      'sequence': 2,
      'stamp': '2026-01-01T00:00:00.000Z',
    };
    expect(
      ExceptionalRangeEnvelope.read(
        ExceptionalRangeEnvelope.write(v7, proof, frozen: frozen),
      ).frozen,
      frozen,
    );
    expect(
      () => ExceptionalRangeEnvelope.write(
        v7,
        proof,
        frozen: {...frozen, 'snapshot': '{"version":8}'},
      ),
      throwsFormatException,
    );
    expect(
      () => ExceptionalRangeEnvelope.write({'version': 8}, proof),
      throwsFormatException,
    );
    final tampered = jsonDecode(encoded) as Map<String, dynamic>;
    final payload = jsonDecode(
      tampered['exceptionalProof'] as String,
    ) as Map<String, dynamic>;
    payload['candidateDigest'] = '0' * 64;
    tampered['exceptionalProof'] = jsonEncode(payload);
    expect(
      () => ExceptionalRangeEnvelope.read(jsonEncode(tampered)),
      throwsFormatException,
    );
  });
  test('retains every mask and skips masked successor originals', () {
    final basis = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;COUNT=8',
      extra: ['LOCATION:Room'],
    );
    final proof = ExceptionalRangeProof.create(
      basis: basis,
      anchor: fixture.point(3, date: true),
      masks: [fixture.point(3, date: true), fixture.point(4, date: true)],
    );
    final candidate =
        (jsonDecode(proof.encoded) as Map<String, dynamic>)['candidate']
            as String;
    expect(candidate, contains('EXDATE;VALUE=DATE:20300103'));
    expect(candidate, contains('EXDATE;VALUE=DATE:20300104'));
    expect(
      candidate,
      contains('RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20300105'),
    );
    final message = parseIcalendarSchedulingMessage(utf8.encode(candidate));
    final versions = <String, (int, DateTime)>{
      for (final event in message.events)
        if (!event.isOverride)
          'master': (7, DateTime.utc(2026))
        else
          eventComponentKey(
            CalendarEventTiming(
              kind: CalendarEventTimeKind.date,
              start: eventDate(event.originalDate!),
            ),
            event.isThisAndFuture,
          ): (
            7,
            DateTime.utc(2026),
          ),
    };
    final actual = candidate.replaceAll('SEQUENCE:2', 'SEQUENCE:7');
    expect(
      () => proof.requireCommittedRequest(actual, versions),
      returnsNormally,
    );
    expect(
      () => proof.requireCommittedRequest(
        actual.replaceFirst('EXDATE;VALUE=DATE:20300104\r\n', ''),
        versions,
      ),
      throwsArgumentError,
    );
    final unmasked = fixture
        .raw(
          date: true,
          rule: 'FREQ=DAILY;COUNT=8',
          own: [(5, 5, true, 2)],
          extra: ['LOCATION:Room'],
        )
        .replaceFirst('SUMMARY:Own 5', 'SUMMARY:Master');
    expect(() => proof.requireUnmaskedLineage(unmasked), returnsNormally);
    final excluded = unmasked.replaceFirst(
      'SUMMARY:Master',
      'EXDATE;VALUE=DATE:20300103\r\nSUMMARY:Master',
    );
    expect(() => proof.requireUnmaskedLineage(excluded), throwsArgumentError);
  });
  test('a masked ordinary original remains excluded in the candidate', () {
    final basis = fixture.raw(
      date: true,
      rule: 'FREQ=DAILY;COUNT=8',
      extra: ['LOCATION:Room'],
    );
    final proof = ExceptionalRangeProof.create(
      basis: basis,
      anchor: fixture.point(3, date: true),
      masks: [fixture.point(3, date: true)],
    );
    final result = jsonDecode(proof.encoded) as Map<String, dynamic>;
    expect(result['candidate'], contains('EXDATE;VALUE=DATE:20300103'));
    expect(
      result['candidate'],
      contains('RECURRENCE-ID;VALUE=DATE;RANGE=THISANDFUTURE:20300104'),
    );
  });
  String source({List<String> extra = const []}) => fixture.raw(
    date: true,
    rule: 'FREQ=DAILY;COUNT=8',
    own: [(3, 5, false, 2)],
    extra: ['LOCATION:Room', ...extra],
  );

  test('reconstructs bounded proof and rejects changed bindings', () {
    final proof = ExceptionalRangeProof.create(
      basis: source(),
      anchor: fixture.point(3, date: true),
      masks: [fixture.point(3, date: true)],
    );
    final evidence = jsonDecode(proof.encoded) as Map<String, dynamic>;
    expect(evidence['basis'], contains('SUMMARY:Own 3'));
    expect(evidence['candidate'], isNot(contains('SUMMARY:Own 3')));
    expect(evidence['candidate'], contains('EXDATE;VALUE=DATE:20300103'));
    expect(ExceptionalRangeProof.read(proof.encoded).encoded, proof.encoded);
    expect(
      () => proof.requireBindings(
        basis: source(),
        anchor: fixture.point(3, date: true),
        masks: [fixture.point(3, date: true)],
      ),
      returnsNormally,
    );
    expect(
      () => proof.requireBindings(
        basis: source(),
        anchor: fixture.point(3, date: true),
        masks: [fixture.point(4, date: true)],
      ),
      throwsFormatException,
    );
    expect(
      () => proof.requireBindings(
        basis: source(),
        anchor: fixture.point(4, date: true),
        masks: [fixture.point(3, date: true)],
      ),
      throwsFormatException,
    );
    for (final field in ['basisDigest', 'candidateDigest']) {
      final value = jsonDecode(proof.encoded) as Map<String, dynamic>;
      value[field] = '0' * 64;
      expect(
        () => ExceptionalRangeProof.read(jsonEncode(value)),
        throwsFormatException,
      );
    }
    final changed = jsonDecode(proof.encoded) as Map<String, dynamic>;
    changed['candidate'] = '${changed['candidate']}tampered';
    expect(
      () => ExceptionalRangeProof.read(jsonEncode(changed)),
      throwsFormatException,
    );
    final extra = jsonDecode(proof.encoded) as Map<String, dynamic>;
    extra['unexpected'] = true;
    expect(
      () => ExceptionalRangeProof.read(jsonEncode(extra)),
      throwsFormatException,
    );
  });

  test('rejects duplicates and source exclusions as cancellation evidence', () {
    expect(
      () => ExceptionalRangeProof.create(
        basis: source(),
        anchor: fixture.point(3, date: true),
        masks: [fixture.point(3, date: true), fixture.point(3, date: true)],
      ),
      throwsArgumentError,
    );
    expect(
      () => ExceptionalRangeProof.create(
        basis: source(extra: ['EXDATE;VALUE=DATE:20300104']),
        anchor: fixture.point(3, date: true),
        masks: [fixture.point(4, date: true)],
      ),
      throwsArgumentError,
    );
  });
  test(
    'exceptional proof fails closed when its shared work budget is exhausted',
    () {
      final work = RecurrenceWorkBudget(maxWork: 1);
      expect(
        () => ExceptionalRangeProof.create(
          basis: source(),
          anchor: fixture.point(3, date: true),
          masks: [],
          sharedWorkBudget: work,
        ),
        throwsA(
          isA<IcalendarComponentException>().having(
            (error) => error.kind,
            'kind',
            IcalendarComponentError.limitExceeded,
          ),
        ),
      );
    },
  );
  test('exceptional proof rejects oversized input and too many masks', () {
    expect(
      () => ExceptionalRangeProof.create(
        basis: 'x' * 524289,
        anchor: fixture.point(3, date: true),
        masks: [],
      ),
      throwsArgumentError,
    );
    expect(
      () => ExceptionalRangeProof.create(
        basis: source(),
        anchor: fixture.point(3, date: true),
        masks: List.generate(65, (_) => fixture.point(3, date: true)),
      ),
      throwsArgumentError,
    );
  });
}
