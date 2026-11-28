@TestOn('vm')
library;

import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:serverpod_calendar_server/src/recurring_response_history.dart';
import 'package:test/test.dart';

import 'published_range_cancellation_values_test.dart' show raw;
import 'recurring_invitation_response_values_test.dart' show packet;

void main() {
  final root = packet(raw(sequence: 1), 0);
  Map<String, IcalendarSchedulingMessage> sources() => {'root': root};
  Map<String, dynamic> advance(
    Map<String, dynamic>? previous,
    Map<String, IcalendarSchedulingMessage> packets,
    Map<String, String> current,
    String incoming, {
    int maxHistory = 64,
  }) => buildRecurringResponseHistory(
    previous: previous,
    masterEntryId: 'master-entry',
    rootSourceId: current['master']!,
    membershipSourceId: 'root',
    current: [
      for (final entry in current.entries)
        {'entry': entry.key, 'target': entry.key, 'source': entry.value},
    ],
    incomingSourceId: incoming,
    packets: packets,
    recipientAddress: 'mailto:alice@example.invalid',
    work: RecurrenceWorkBudget(maxWork: 200000),
    maxHistorySlots: maxHistory,
  );
  IcalendarSchedulingMessage cancel(int version) =>
      packet(raw(own: [(3, 3, true, version)]), 1, cancel: true);
  IcalendarSchedulingMessage restore(int version, {int day = 3}) => packet(
    raw(own: [(3, day, true, version)])
        .replaceAll('SUMMARY:Own 3', 'SUMMARY:Master'),
    1,
  );
  test('three cancellation/restoration cycles replay without recursive proof or source mutation', () {
    final packets = sources(), current = <String, String>{'master': 'root'};
    var data = advance(null, packets, current, 'root');
    for (var n = 0; n < 3; n++) {
      final c = 'cancel$n', r = 'restore$n';
      packets[c] = cancel(3 + n * 2);
      current['range'] = c;
      data = advance(data, packets, current, c);
      validateRecurringResponseHistory(
        data,
        packets,
        'mailto:alice@example.invalid',
        RecurrenceWorkBudget(maxWork: 200000),
      );
      expect(
        recurringResponseCycles(data).where(recurringResponseActive).length,
        1,
      );
      packets[r] = restore(4 + n * 2);
      current['range'] = r;
      data = advance(data, packets, current, r);
      validateRecurringResponseHistory(
        data,
        packets,
        'mailto:alice@example.invalid',
        RecurrenceWorkBudget(maxWork: 200000),
      );
      expect(
        recurringResponseCycles(data).where(recurringResponseActive),
        isEmpty,
      );
    }
    expect((data['events'] as List).length, 6);
    expect(jsonEncode(data), isNot(contains('previousEvidence')));
    expect(root.events.single.sequence, 1);
  });
  test('an unrelated earlier single version does not become a suffix version floor', () {
    final packets = sources(), current = <String, String>{'master': 'root'};
    var data = advance(null, packets, current, 'root');
    packets['single'] = packet(raw(own: [(2, 2, false, 50)]), 1);
    current['single'] = 'single';
    data = advance(data, packets, current, 'single');
    packets['cancel'] = cancel(3);
    current['range'] = 'cancel';
    data = advance(data, packets, current, 'cancel');
    expect(data['complete'], isTrue);
    packets['restore'] = restore(4);
    current['range'] = 'restore';
    data = advance(data, packets, current, 'restore');
    validateRecurringResponseHistory(
      data,
      packets,
      'mailto:alice@example.invalid',
      RecurrenceWorkBudget(maxWork: 200000),
    );
    expect(recurringResponseCycles(data).single['restored'], 'restore');
  });
  test(
    'forged restore flag or unmatched transition never proves a cleared cutoff',
    () {
      final packets = sources(), current = <String, String>{'master': 'root'};
      var data = advance(null, packets, current, 'root');
      packets['cancel'] = cancel(3);
      current['range'] = 'cancel';
      data = advance(data, packets, current, 'cancel');
      packets['reschedule'] = restore(4, day: 5);
      current['range'] = 'reschedule';
      data = advance(data, packets, current, 'reschedule');
      expect(recurringResponseCycles(data).single['restored'], isNull);
      final forged = jsonDecode(jsonEncode(data)) as Map<String, dynamic>;
      (forged['cycles'] as List).single['restored'] = 'reschedule';
      expect(
        () => validateRecurringResponseHistory(
          forged,
          packets,
          'mailto:alice@example.invalid',
          RecurrenceWorkBudget(maxWork: 200000),
        ),
        throwsArgumentError,
      );
      (forged['events'] as List).add({
        'kind': 'restore',
        'source': 'reschedule',
        'cycle': 0,
        'floorMaster': 'root',
        'floorNotices': <String>[],
      });
      expect(
        () => validateRecurringResponseHistory(
          forged,
          packets,
          'mailto:alice@example.invalid',
          RecurrenceWorkBudget(maxWork: 200000),
        ),
        throwsArgumentError,
      );
    },
  );
  test('history slots and replay budget reject rather than erase proof', () {
    final packets = sources(), current = <String, String>{'master': 'root'};
    var data = advance(null, packets, current, 'root');
    packets['cancel'] = cancel(3);
    current['range'] = 'cancel';
    data = advance(data, packets, current, 'cancel');
    packets['restore'] = restore(4);
    current['range'] = 'restore';
    expect(
      () => advance(data, packets, current, 'restore', maxHistory: 2),
      throwsA(isA<RecurrenceLimitException>()),
    );
    expect(
      () => validateRecurringResponseHistory(
        data,
        packets,
        'mailto:alice@example.invalid',
        RecurrenceWorkBudget(maxWork: 1),
      ),
      throwsA(
        anyOf(
          isA<RecurrenceLimitException>(),
          isA<IcalendarComponentException>().having(
            (e) => e.kind,
            'kind',
            IcalendarComponentError.limitExceeded,
          ),
        ),
      ),
    );
    expect(recurringResponseCycles(data).single['restored'], isNull);
  });
}
