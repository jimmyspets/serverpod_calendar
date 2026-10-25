import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/alarm_work_store.dart';

import 'package:calendar_example_server/src/generated/serverpod.dart';

/// Internal synthetic process harness only; never installed as an endpoint.
Future<void> main(List<String> args) async {
  final pod = Serverpod([
    '--mode=test',
    '--server-id=alarm-work-probe-${args[1]}',
    '--apply-migrations',
  ]);
  final session = await pod.createSession(enableLogging: false);
  try {
    final database = (await session.db.unsafeQuery('SELECT current_database()'))
        .single
        .single;
    if (database != 'calendar_example_test') {
      throw StateError('Synthetic test storage required');
    }
    // Start the real independent host only after checking the database name.
    // This applies the pinned generated migrations outside rollback fixtures.
    await pod.start();
    final store = AlarmWorkStore(
      session,
      CalendarAlarmWorkOptions(
        leaseDuration: const Duration(seconds: 5),
        maxClaims: 1,
      ),
    );
    stdout.writeln('ALARM_WORK_READY');
    final channel = File(args.first);
    var nonce = 0;
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      Map<String, dynamic> input;
      try {
        if (!await channel.exists()) continue;
        input =
            jsonDecode(await channel.readAsString()) as Map<String, dynamic>;
      } on FormatException {
        continue;
      }
      if (input['nonce'] == nonce) continue;
      nonce = input['nonce'] as int;
      Object result;
      switch (input['command']) {
        case 'seed':
          final id = const Uuid().v4obj();
          final scope = 'alarm-work-probe:$id';
          final now = DateTime.utc(2026);
          final calendar = await CalendarIdentityRecord.db.insertRow(
            session,
            CalendarIdentityRecord(scopeKey: scope, revision: 1),
          );
          final alarm = await CalendarAlarmRecord.db.insertRow(
            session,
            CalendarAlarmRecord(
              scopeKey: scope,
              calendarId: calendar.id!,
              parentKind: CalendarAlarmParentKind.event,
              parentId: id,
              recipientNamespace: 'synthetic',
              recipientKey: 'probe',
              revision: 1,
              definition: CalendarAlarmDefinition(absoluteUtc: now),
              createdAt: now,
              updatedAt: now,
            ),
          );
          await CalendarAlarmPlanRecord.db.insertRow(
            session,
            CalendarAlarmPlanRecord(
              alarmId: alarm.id!,
              scopeKey: scope,
              generation: 1,
              nextScanAt: DateTime.utc(2020),
            ),
          );
          result = {
            'alarmId': alarm.id.toString(),
            'calendarId': calendar.id.toString(),
            'scopeKey': scope,
          };
        case 'claim':
          result = [
            for (final lease in await store.claimPlans())
              {
                'planId': lease.planId.toString(),
                'alarmId': lease.alarmId.toString(),
                'scopeKey': lease.scopeKey,
                'generation': lease.generation,
                'owner': lease.owner.toString(),
                'fence': lease.fence,
              },
          ];
        case 'validate':
          final value = input['lease'] as Map<String, dynamic>;
          final lease = AlarmPlanLease(
            planId: UuidValue.fromString(value['planId']),
            alarmId: UuidValue.fromString(value['alarmId']),
            scopeKey: value['scopeKey'],
            generation: value['generation'],
            owner: UuidValue.fromString(value['owner']),
            fence: value['fence'],
          );
          result = await session.db.transaction(
            (tx) async => await store.ownedPlan(lease, tx) != null,
          );
        case 'cleanup':
          final fixture = input['fixture'] as Map<String, dynamic>;
          if (!(fixture['scopeKey'] as String).startsWith(
            'alarm-work-probe:',
          )) {
            throw StateError('Foreign fixture');
          }
          final alarmId = UuidValue.fromString(fixture['alarmId']);
          final alarm = await CalendarAlarmRecord.db.findById(session, alarmId);
          if (alarm == null || alarm.scopeKey != fixture['scopeKey']) {
            throw StateError('Fixture mismatch');
          }
          await CalendarAlarmPlanRecord.db.deleteWhere(
            session,
            where: (t) => t.alarmId.equals(alarmId),
          );
          await CalendarAlarmRecord.db.deleteRow(session, alarm);
          await CalendarIdentityRecord.db.deleteWhere(
            session,
            where: (t) =>
                t.id.equals(alarm.calendarId) &
                t.scopeKey.equals(alarm.scopeKey),
          );
          result = true;
        default:
          throw ArgumentError('Unknown probe command');
      }
      stdout.writeln('ALARM_WORK_RESULT ${jsonEncode(result)}');
    }
  } catch (error, stack) {
    stderr.writeln('Synthetic worker probe failed: $error\n$stack');
    rethrow;
  } finally {
    await session.close();
    await pod.shutdown();
  }
}
