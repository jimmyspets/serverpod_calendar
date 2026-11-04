import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_test.dart'
    show
        TestPolicy,
        TestAlarmBackgroundPolicy,
        TestAlarmDeliveryPort,
        createInput,
        failure;
import 'invitation_test.dart'
    show InvitationTestHost, invitationBytes, invitationDelivery;
import 'instance_invitations_test.dart' show instanceInvitationBytes;
import 'range_invitations_test.dart' show rangeInvitationBytes;
import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('range applications preserving source restoration', (
    builder,
    endpoints,
  ) {
    late Session session;
    late InvitationTestHost host;
    late TestPolicy policy;
    late CalendarService service;
    void install({
      CalendarInvitationOptions? options,
      CalendarAlarmRuntime? alarms,
    }) {
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host, options: options),
        alarms: alarms,
      );
      service = CalendarModule.service(session);
    }

    setUp(() {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      host = InvitationTestHost();
      policy = TestPolicy();
      install();
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(
            key: const Uuid().v4obj().toString(),
            bytes: bytes,
          ),
        );
    Future<CalendarInvitationAdoptionReceipt> setup({
      bool date = false,
      String? zone,
      int? sequence = 1,
      String? start,
      List<String> extra = const [],
    }) async {
      var bytes = invitationBytes(
        sequence: sequence,
        date: date,
        zone: zone,
        extra: ['RRULE:FREQ=DAILY;COUNT=6', ...extra],
      );
      if (start != null) {
        final oldStart = date
            ? 'DTSTART;VALUE=DATE:20300101'
            : zone == null
            ? 'DTSTART:20300101T090000Z'
            : 'DTSTART;TZID=$zone:20300101T090000';
        bytes = Uint8List.fromList(
          utf8.encode(utf8.decode(bytes).replaceFirst(oldStart, start)),
        );
      }
      final m = await receive(bytes);
      final c = (await service.create(createInput()))!;
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: m.entryId,
          sourceId: m.sourceId,
          expectedRevision: m.entryRevision,
          calendarId: c.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationOccurrenceApplyRequest command(
      CalendarInvitationOccurrenceApplicationView v,
    ) => CalendarInvitationOccurrenceApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      linkId: v.linkId,
      expectedInvitationRevision: v.invitationRevision,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationOccurrenceApplyRequest> cancel({
      bool date = false,
      String? zone,
      int sequence = 3,
      String? original,
    }) async {
      final bytes = rangeInvitationBytes(
        cancel: true,
        original: original,
        sequence: sequence,
        date: date,
        zone: zone,
      );
      final r = await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bytes)
                .split('\r\n')
                .where((line) => !line.startsWith('SUMMARY:'))
                .join('\r\n'),
          ),
        ),
      );
      final v = await service.invitationRangeApplication(r.entryId);
      expect(v.canApply, isTrue);
      return command(v);
    }

    Future<CalendarEventDataRecord> data() async =>
        (await CalendarEventDataRecord.db.find(session)).single;
    Future<CalendarInvitationOccurrenceApplicationRecord> row() async =>
        (await CalendarInvitationOccurrenceApplicationRecord.db.find(session))
            .single;
    CalendarInvitationApplyRequest masterCommand(
      CalendarInvitationApplicationView v,
    ) => CalendarInvitationApplyRequest(
      invitationId: v.invitationId,
      sourceId: v.incomingSourceId!,
      expectedInvitationRevision: v.invitationRevision!,
      linkId: v.linkId,
      expectedEventRevision: v.eventRevision,
      expectedCalendarRevision: v.calendarRevision,
      expectedApplicationRevision: v.applicationRevision,
      expectedOccurrenceRevision: v.occurrenceRevision,
    );
    Future<CalendarInvitationApplicationView> newerMaster({
      int sequence = 3,
      bool date = false,
      String? zone,
      List<String> extra = const ['RRULE:FREQ=DAILY;COUNT=6'],
    }) async {
      final m = await receive(
        invitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          summary: 'Updated master',
          extra: extra,
        ),
      );
      return service.invitationApplication(m.entryId);
    }

    Future<CalendarInvitationApplicationView> whole({
      int sequence = 11,
      String stamp = '20260101T000000Z',
      List<String> extra = const [],
    }) async {
      var text = utf8
          .decode(
            invitationBytes(sequence: sequence, stamp: stamp, extra: extra),
          )
          .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
          .replaceFirst(
            'BEGIN:VEVENT\r\n',
            'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
          );
      text = text
          .split('\r\n')
          .where((l) => !l.startsWith('DTSTART') && !l.startsWith('SUMMARY'))
          .join('\r\n');
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationApplication(r.entryId);
    }

    Future<CalendarInvitationOccurrenceApplicationView> restoration({
      bool date = false,
      String? zone,
      int sequence = 4,
      String summary = 'Review',
    }) async {
      var text = utf8.decode(
        rangeInvitationBytes(date: date, zone: zone, sequence: sequence),
      );
      final a = date
          ? 'DTSTART;VALUE=DATE:20300101'
          : zone == null
          ? 'DTSTART:20300101T090000Z'
          : 'DTSTART;TZID=$zone:20300101T090000';
      text = text
          .replaceFirst(a, a.replaceFirst('20300101', '20300102'))
          .replaceFirst('SUMMARY:Review', 'SUMMARY:$summary');
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationRangeRestorationApplication(r.entryId);
    }

    Future<CalendarInvitationOccurrenceApplyRequest> ready({
      bool date = false,
      String? zone,
      bool composed = false,
    }) async {
      await setup(date: date, zone: zone);
      await service.applyInvitationRangeCancellation(
        await cancel(date: date, zone: zone),
      );
      final input = command(
        await restoration(date: date, zone: zone, sequence: 10),
      );
      await service.applyInvitationRangeRestoration(input);
      if (composed) {
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 2, date: date, zone: zone)),
        );
      }
      return input;
    }

    Future<CalendarInvitationOccurrenceApplicationView> single({
      bool date = false,
      String? zone,
      int sequence = 2,
      bool cancelled = false,
      String? original,
    }) async {
      final r = await receive(
        instanceInvitationBytes(
          date: date,
          zone: zone,
          sequence: sequence,
          cancel: cancelled,
          original: original,
        ),
      );
      return service.invitationOccurrenceApplication(r.entryId);
    }

    Future<CalendarInvitationOccurrenceApplicationView> rangeUpdate({
      int sequence = 11,
      bool date = false,
      String? zone,
      String? original,
      String? stamp,
    }) async {
      var text = utf8.decode(
        rangeInvitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          original: original,
        ),
      );
      if (stamp != null) {
        text = text.replaceFirst('DTSTAMP:20260101T000000Z', 'DTSTAMP:$stamp');
      }
      final r = await receive(Uint8List.fromList(utf8.encode(text)));
      return service.invitationRangeApplication(r.entryId);
    }

    String wirePoint(CalendarEventCivil c, bool date, bool utc) {
      String pad(int n, int width) => n.toString().padLeft(width, '0');
      final day = '${pad(c.year, 4)}${pad(c.month, 2)}${pad(c.day, 2)}';
      if (date) return day;
      final clock = '${pad(c.hour, 2)}${pad(c.minute, 2)}${pad(c.second, 2)}';
      return '${day}T$clock${utc ? 'Z' : ''}';
    }

    Future<CalendarInvitationOccurrenceApplicationView> currentRestoration(
      int sequence, {
      int day = 2,
      bool date = false,
      String? zone,
    }) async {
      final d = await data();
      final original = CalendarEventTiming(
        kind: d.content.timing.kind,
        zoneId: zone,
        start: d.content.timing.start.copyWith(day: day),
      );
      final edits = d.timingOverrides?.copyWith(
        cancelledFrom: null,
        singles: [
          for (final v in d.timingOverrides!.singles)
            v.copyWith(cancelled: false),
        ],
      );
      final effective = eventSchedulingOccurrence(d.content, edits, original)!;
      final timing = effective.timing;
      final text = utf8.decode(
        rangeInvitationBytes(
          sequence: sequence,
          date: date,
          zone: zone,
          original: wirePoint(original.start, date, zone == null),
        ),
      );
      final lines = <String>[];
      var inEvent = false;
      for (final line in text.split('\r\n')) {
        if (line == 'BEGIN:VEVENT') inEvent = true;
        if (!inEvent ||
            !line.startsWith('DTSTART') && !line.startsWith('SUMMARY:')) {
          lines.add(line);
        }
        if (line == 'END:VEVENT') inEvent = false;
      }
      String property(String name, CalendarEventCivil c) =>
          '$name${date
              ? ";VALUE=DATE"
              : zone == null
              ? ""
              : ";TZID=$zone"}:${wirePoint(c, date, zone == null)}';
      final own = [
        property('DTSTART', timing.start),
        'SUMMARY:${encodeIcalendarText(effective.summary ?? "")}',
        if (timing.end != null) property('DTEND', timing.end!),
      ];
      if (timing.duration != null) {
        final spans = validateEventTiming(timing);
        own.add(
          'DURATION:${serializeIcalendarDuration(spans.$1?.duration ?? spans.$2!.duration!)}',
        );
      }
      lines.insertAll(lines.indexOf('END:VEVENT'), own);
      final notice = await receive(
        Uint8List.fromList(utf8.encode(lines.join('\r\n'))),
      );
      return service.invitationRangeRestorationApplication(notice.entryId);
    }

    Future<void> nextCycle(
      int sequence, {
      int day = 2,
      bool date = false,
      String? zone,
    }) async {
      final input = await cancel(
        sequence: sequence,
        date: date,
        zone: zone,
        original: date
            ? '2030010$day'
            : zone == null
            ? '2030010${day}T090000Z'
            : '2030010${day}T090000',
      );
      await service.applyInvitationRangeCancellation(input);
      final preview = await currentRestoration(
        sequence + 1,
        day: day,
        date: date,
        zone: zone,
      );
      expect(preview.canApply, isTrue);
      await service.applyInvitationRangeRestoration(command(preview));
    }

    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      for (final initial in [7, 8, 9, 10, 11]) {
        test(
          'repeated durable cycles preserve $profile v$initial history and canonical values',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            await ready(date: date, zone: zone, composed: initial == 8);
            if (initial == 9) {
              final notice = await receive(
                Uint8List.fromList(
                  utf8.encode(
                    utf8
                        .decode(
                          invitationBytes(
                            sequence: 11,
                            date: date,
                            zone: zone,
                            extra: const [],
                          ),
                        )
                        .replaceFirst('METHOD:REQUEST', 'METHOD:CANCEL')
                        .replaceFirst(
                          'BEGIN:VEVENT\r\n',
                          'BEGIN:VEVENT\r\nSTATUS:CANCELLED\r\n',
                        )
                        .split('\r\n')
                        .where(
                          (l) => !l.startsWith('SUMMARY'),
                        )
                        .join('\r\n'),
                  ),
                ),
              );
              await service.applyInvitationCancellation(
                masterCommand(
                  await service.invitationApplication(notice.entryId),
                ),
              );
              await service.applyInvitationUpdate(
                masterCommand(
                  await newerMaster(sequence: 12, date: date, zone: zone),
                ),
              );
            }
            if (initial == 10) {
              await service.applyInvitationOccurrenceUpdate(
                command(await single(sequence: 2, date: date, zone: zone)),
              );
            }
            if (initial == 11) {
              final incoming = await currentRestoration(
                11,
                date: date,
                zone: zone,
              );
              await service.applyInvitationRangeUpdate(
                command(
                  await service.invitationRangeApplication(
                    incoming.invitationId,
                  ),
                ),
              );
            }
            final canonical = await data();
            String? frozen;
            for (var i = 0; i < 3; i++) {
              final day = i == 1 ? 3 : 2, seq = 20 + i * 2;
              final cancelInput = await cancel(
                sequence: seq,
                date: date,
                zone: zone,
                original: date
                    ? '2030010$day'
                    : zone == null
                    ? '2030010${day}T090000Z'
                    : '2030010${day}T090000',
              );
              final cancelled = await service.applyInvitationRangeCancellation(
                cancelInput,
              );
              final masked = await data(),
                  state = jsonDecode((await row()).stateJson) as Map;
              expect(state['version'], 12);
              expect((state['cycles'] as List).length, i + 1);
              expect(state['activeCycleKey'], isNotNull);
              frozen ??= jsonEncode(state['frozenRestoration']);
              expect(jsonEncode(state['frozenRestoration']), frozen);
              expect(
                masked.protocolState!.toJson(),
                canonical.protocolState!.toJson(),
              );
              expect(
                (await service.invitationRangeApplication(
                  cancelInput.invitationId,
                )).hasActiveAcceptedRangeCancellation,
                isTrue,
              );
              expect(
                (await service.applyInvitationRangeCancellation(cancelInput))
                    .id,
                cancelled.id,
              );
              final preview = await currentRestoration(
                seq + 1,
                day: day,
                date: date,
                zone: zone,
              );
              expect(preview.canApply, isTrue);
              expect(preview.hasActiveAcceptedRangeCancellation, isTrue);
              final request = command(preview),
                  restored = await service.applyInvitationRangeRestoration(
                    request,
                  );
              final clean = await data();
              expect(clean.content.toJson(), canonical.content.toJson());
              expect(
                clean.timingOverrides?.toJson(),
                canonical.timingOverrides?.toJson(),
              );
              expect(
                clean.protocolState!.toJson(),
                canonical.protocolState!.toJson(),
              );
              expect(
                (await service.invitationRangeRestorationApplication(
                  request.invitationId,
                )).hasActiveAcceptedRangeCancellation,
                isFalse,
              );
              expect(
                (await service.applyInvitationRangeRestoration(request)).id,
                restored.id,
              );
            }
          },
          timeout: const Timeout(Duration(minutes: 2)),
        );
      }
    }
    test(
      'v12 composes masters, whole lifecycle and subsequent canonical targets',
      () async {
        await ready();
        final cancellation = await cancel(sequence: 20);
        await service.applyInvitationRangeCancellation(cancellation);
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 21)),
        );
        expect((await data()).timingOverrides!.cancelledFrom, isNotNull);
        await service.applyInvitationCancellation(
          masterCommand(await whole(sequence: 22)),
        );
        expect(
          (await service.invitationRangeApplication(cancellation.invitationId))
              .hasActiveAcceptedRangeCancellation,
          isTrue,
        );
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 23)),
        );
        final restore = command(await currentRestoration(24));
        await service.applyInvitationRangeRestoration(restore);
        final singleInput = command(
          await single(sequence: 25, original: '20300104T090000Z'),
        );
        await service.applyInvitationOccurrenceUpdate(singleInput);
        await service.applyInvitationRangeUpdate(
          command(await rangeUpdate(sequence: 26)),
        );
        await nextCycle(30);
        await service.applyInvitationUpdate(
          masterCommand(await newerMaster(sequence: 40)),
        );
        await nextCycle(50, day: 3);
        expect(
          (jsonDecode((await row()).stateJson) as Map)['cycles'].length,
          3,
        );
        expect(
          (await service.invitationOccurrenceApplication(
            singleInput.invitationId,
          )).acceptedVersion.sequence,
          25,
        );
      },
      timeout: const Timeout(Duration(minutes: 2)),
    );

    test(
      'v12 master edits cannot orphan a closed historical cycle anchor',
      () async {
        await ready();
        await nextCycle(20, day: 3);
        final before = (await data()).toJson(),
            checkpoint = (await row()).toJson();
        final pending = await newerMaster(
          sequence: 30,
          extra: ['RRULE:FREQ=DAILY;COUNT=2'],
        );
        expect(pending.canApply, isFalse);
        await expectLater(
          service.applyInvitationUpdate(masterCommand(pending)),
          failure(CalendarFailureCode.validation),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), checkpoint);
      },
    );

    test('v12 authorizes superseded canonical sources retained only in legacy proof', () async {
      await setup();
      final old = command(
        await single(sequence: 2, original: '20300104T090000Z'),
      );
      await service.applyInvitationOccurrenceUpdate(old);
      await service.applyInvitationRangeCancellation(await cancel(sequence: 5));
      await service.applyInvitationRangeRestoration(
        command(await restoration(sequence: 10)),
      );
      await service.applyInvitationOccurrenceUpdate(
        command(await single(sequence: 3, original: '20300104T090000Z')),
      );
      await nextCycle(20);
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSource &&
            c.sourceId == old.sourceId) {
          host.denied.add(CalendarInvitationOperation.readSource);
        }
      };
      final receipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
        (jsonDecode((await row()).stateJson) as Map)['receipt'],
      );
      await expectLater(
        service.invitationRangeRestorationApplication(receipt.invitationId),
        failure(CalendarFailureCode.accessDenied),
      );
    }, timeout: const Timeout(Duration(minutes: 2)));

    String hashParts(List<String> parts) {
      final bytes = BytesBuilder(copy: false);
      for (final p in parts) {
        final v = utf8.encode(p);
        bytes.add(utf8.encode('${v.length}:'));
        bytes.add(v);
      }
      return sha256.convert(bytes.takeBytes()).toString();
    }

    Object? ordered(Object? v) {
      if (v is Map) {
        final keys = v.keys.cast<String>().toList()..sort();
        return {for (final k in keys) k: ordered(v[k])};
      }
      if (v is List) return v.map(ordered).toList();
      return v;
    }

    Future<void> reseal(Map<String, dynamic> state) async {
      final link = (await CalendarInvitationLinkRecord.db.find(session)).single;
      final body = Map<String, dynamic>.of(state)
        ..remove('compositionDigest')
        ..remove('receiptDigest');
      state['compositionDigest'] = hashParts([
        'range-cycles-v12',
        link.scopeKey,
        link.recipientKey,
        link.id.toString(),
        link.calendarId.toString(),
        link.eventId.toString(),
        link.uid,
        link.organizer,
        jsonEncode(ordered(body)),
      ]);
      state['receiptDigest'] = hashParts([
        'range-cycle-receipt-v12',
        state['compositionDigest'],
        state['latestLayer'],
        '${state['latestCycleKey']}',
        state['requestDigest'],
        jsonEncode(ordered(state['receipt'])),
        jsonEncode(ordered(state['latestTarget'])),
      ]);
    }

    for (final corruption in [
      'active',
      'duplicate',
      'nestedLegacy',
      'nestedBasis',
      'floor',
      'version',
      'native',
      'masterSource',
      'basisRevision',
      'sourceIdentity',
      'receipt',
      'layer',
      'order',
      'unknown',
      'slots',
      'rawWork',
      'depth',
    ]) {
      test(
        'v12 independently rejects rehashed $corruption proof corruption',
        () async {
          await ready();
          await nextCycle(20);
          if (corruption == 'order') await nextCycle(22, day: 3);
          final stored = await row(),
              state = jsonDecode(stored.stateJson) as Map<String, dynamic>;
          final c = state['cycles'][0] as Map;
          switch (corruption) {
            case 'active':
              state['activeCycleKey'] = c['key'];
            case 'duplicate':
              state['cycles'].add(jsonDecode(jsonEncode(c)));
            case 'nestedLegacy':
              state['frozenRestoration']['checkpoint']['state']['cycles'] = [];
            case 'nestedBasis':
              c['cancellationBasis']['cycles'] = [];
            case 'floor':
              c['cancellation']['requiredAfterSequence'] = 0;
            case 'version':
              c['restoration']['version']['sequence'] = 200;
            case 'native':
              c['restoration']['nativeDigest'] = '0' * 64;
            case 'masterSource':
              c['cancellationBasis']['masterSource']['digest'] = '0' * 64;
            case 'basisRevision':
              c['restorationBasis']['checkpointRevision'] = 1;
            case 'sourceIdentity':
              c['restoration']['sourceId'] = const Uuid().v4();
            case 'receipt':
              c['restoration']['receipt']['eventRevision'] = 9999;
            case 'layer':
              state['latestLayer'] = 'unexpected';
            case 'order':
              state['cycles'] = (state['cycles'] as List).reversed.toList();
            case 'unknown':
              state['unregistered'] = true;
            case 'slots':
              state['cycles'] = List.filled(128, c);
            case 'rawWork':
              c['cancellationBasis']['targets'] = List.filled(
                eventMaxCandidateWork,
                null,
              );
            case 'depth':
              Object? nested;
              for (var i = 0; i < 100; i++) {
                nested = [nested];
              }
              c['cancellationBasis']['targets'] = nested;
          }
          if (state['latestLayer'] == 'rangeRestoration') {
            final selected = (state['cycles'] as List).firstWhere(
              (v) => v['key'] == state['latestCycleKey'],
            );
            state['latestTarget'] = selected['restoration'];
          }
          await reseal(state);
          await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
            session,
            stored.copyWith(stateJson: jsonEncode(state)),
          );
          final entry = UuidValue.fromString(c['restoration']['invitationId']);
          await expectLater(
            service.invitationRangeRestorationApplication(entry),
            failure(CalendarFailureCode.unavailable),
          );
        },
      );
    }
    for (final restore in [false, true]) {
      for (final op in [
        CalendarInvitationOperation.applyRangeCancellation,
        CalendarInvitationOperation.applyRangeRestoration,
        CalendarInvitationOperation.composeAcceptedOccurrences,
        CalendarInvitationOperation.composeAcceptedRangeCancellation,
        CalendarInvitationOperation.composeAcceptedRangeRestoration,
        CalendarInvitationOperation.readSource,
      ]) {
        if (restore &&
                op == CalendarInvitationOperation.applyRangeCancellation ||
            !restore &&
                op == CalendarInvitationOperation.applyRangeRestoration) {
          continue;
        }
        test(
          'v12 final $op denial rolls back ${restore ? "restoration" : "cancellation"}',
          () async {
            await ready();
            CalendarInvitationOccurrenceApplyRequest input;
            if (restore) {
              await service.applyInvitationRangeCancellation(
                await cancel(sequence: 20),
              );
              input = command(await currentRestoration(21));
            } else {
              input = await cancel(sequence: 20);
            }
            final before = (await data()).toJson(),
                checkpoint = (await row()).toJson();
            host.onAuthorize = (c, tx, phase) async {
              if (c.operation == op &&
                  phase == CalendarAuthorizationPhase.finalWrite) {
                host.denied.add(op);
              }
            };
            await expectLater(
              (restore
                  ? service.applyInvitationRangeRestoration
                  : service.applyInvitationRangeCancellation)(input),
              failure(CalendarFailureCode.accessDenied),
            );
            expect((await data()).toJson(), before);
            expect((await row()).toJson(), checkpoint);
            expect(
              (await CalendarInvitationRecord.db.findById(
                session,
                input.invitationId,
              ))!.dismissedAt,
              isNull,
            );
          },
        );
      }
    }
    test(
      'v12 retained retry never replays a control over local edits',
      () async {
        await ready();
        final input = await cancel(sequence: 20),
            receipt = await service.applyInvitationRangeCancellation(input);
        final d = await data();
        d.content = d.content.copyWith(summary: 'Local unpublished');
        await CalendarEventDataRecord.db.updateRow(session, d);
        final before = d.toJson(), checkpoint = (await row()).toJson();
        expect(
          (await service.applyInvitationRangeCancellation(input)).id,
          receipt.id,
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), checkpoint);
        final v = await currentRestoration(21);
        expect(v.hasLocalChanges, isTrue);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeRestoration(command(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test('v12 native update authority controls preview without concealing the active flag', () async {
      await ready();
      final cancelInput = await cancel(sequence: 20);
      policy.denied.add(CalendarPermission.updateEvent);
      expect(
        (await service.invitationRangeApplication(cancelInput.invitationId))
            .canApply,
        isFalse,
      );
      policy.denied.clear();
      await service.applyInvitationRangeCancellation(cancelInput);
      final preview = await currentRestoration(21);
      policy.denied.add(CalendarPermission.updateEvent);
      final v = await service.invitationRangeRestorationApplication(
        preview.invitationId,
      );
      expect(v.hasActiveAcceptedRangeCancellation, isTrue);
      expect(v.canApply, isFalse);
    });
    test('v12 all required proof survives pruning and deletion scrubs the checkpoint', () async {
      await ready();
      await nextCycle(20);
      await service.applyInvitationUpdate(
        masterCommand(await newerMaster(sequence: 30)),
      );
      await nextCycle(40);
      final saved = await row();
      final latestReceipt = CalendarInvitationOccurrenceApplyReceipt.fromJson(
        (jsonDecode(saved.stateJson) as Map)['receipt'],
      );
      final latest = CalendarInvitationOccurrenceApplyRequest.fromJson(
        (jsonDecode(
          saved.stateJson,
        ) as Map)['cycles'].last['restoration']['request'],
      );
      for (final e in await CalendarInvitationRecord.db.find(session)) {
        await CalendarInvitationRecord.db.updateRow(
          session,
          e.copyWith(currentSourceId: null),
        );
      }
      await CalendarInvitationReceiptRecord.db.deleteWhere(
        session,
        where: (t) => t.id.notEquals(null),
      );
      await CalendarInvitationSourceRecord.db.deleteWhere(
        session,
        where: (t) => t.id.notEquals(null),
      );
      expect(
        (await service.applyInvitationRangeRestoration(latest)).sourceId,
        latest.sourceId,
      );
      final deniedSource = UuidValue.fromString(
        (jsonDecode(
          saved.stateJson,
        ) as Map)['cycles'][0]['cancellationBasis']['masterSource']['sourceId'],
      );
      host.onAuthorize = (c, tx, phase) async {
        if (c.operation == CalendarInvitationOperation.readSource &&
            c.sourceId == deniedSource) {
          host.denied.add(CalendarInvitationOperation.readSource);
        }
      };
      await expectLater(
        service.applyInvitationRangeRestoration(latest),
        failure(CalendarFailureCode.accessDenied),
      );
      host.onAuthorize = null;
      host.denied.clear();
      await nextCycle(50, day: 3);
      await service.deleteEvent(
        latestReceipt.eventId,
        (await CalendarEventRecord.db.findById(
          session,
          latestReceipt.eventId,
        ))!.revision,
      );
      expect(
        await CalendarInvitationOccurrenceApplicationRecord.db.find(session),
        isEmpty,
      );
    }, timeout: const Timeout(Duration(minutes: 2)));
    test('v12 configured capacity refuses another cycle without discarding history', () async {
      await ready();
      await nextCycle(20);
      final stored = await row(), before = (await data()).toJson();
      install(
        options: CalendarInvitationOptions(
          maxOccurrenceCheckpointBytes:
              utf8.encode(stored.stateJson).length + 100,
        ),
      );
      final input = await cancel(sequence: 22, original: '20300103T090000Z');
      await expectLater(
        service.applyInvitationRangeCancellation(input),
        failure(CalendarFailureCode.limitExceeded),
      );
      expect((await row()).toJson(), stored.toJson());
      expect((await data()).toJson(), before);
    });

    for (final profile in ['utc', 'date', 'Europe/Stockholm']) {
      for (final initial in [7, 8, 9, 10]) {
        test(
          '$profile v$initial to v11 range, single and master lifecycle preserve evidence',
          () async {
            final date = profile == 'date',
                zone = profile == 'Europe/Stockholm' ? profile : null;
            final restoreInput = await ready(
              date: date,
              zone: zone,
              composed: initial == 8,
            );
            if (initial == 9) {
              await service.applyInvitationCancellation(
                masterCommand(await whole()),
              );
              await service.applyInvitationUpdate(
                masterCommand(
                  await newerMaster(sequence: 12, date: date, zone: zone),
                ),
              );
            }
            if (initial == 10) {
              await service.applyInvitationOccurrenceUpdate(
                command(
                  await single(
                    date: date,
                    zone: zone,
                    original: date
                        ? '20300104'
                        : zone == null
                        ? '20300104T090000Z'
                        : '20300104T090000',
                  ),
                ),
              );
            }
            final old = jsonDecode((await row()).stateJson) as Map;
            final priorSingles = (await data()).timingOverrides?.singles
                .map((s) => s.toJson())
                .toList();
            final v = await rangeUpdate(sequence: 13, date: date, zone: zone);
            expect(v.canApply, isTrue);
            final input = command(v),
                receipt = await service.applyInvitationRangeUpdate(command(v));
            final first = jsonDecode((await row()).stateJson) as Map;
            expect(first['version'], 11);
            expect(first['latestTargetKey'], startsWith('range-v1:'));
            expect(
              first['frozenRestoration']['checkpoint']['state']['version'],
              7,
            );
            if (initial != 7) {
              expect(first['frozenRestoration'], old['frozenRestoration']);
            }
            expect(
              first['targets'].last['requiredAfterSequence'],
              initial == 9 ? 12 : 10,
            );
            if (priorSingles != null) {
              expect(
                (await data()).timingOverrides!.singles
                    .map((s) => s.toJson())
                    .toList(),
                priorSingles,
              );
            }
            expect(
              (await service.applyInvitationRangeUpdate(input)).toJson(),
              receipt.toJson(),
            );
            await expectLater(
              service.applyInvitationRangeRestoration(restoreInput),
              failure(CalendarFailureCode.dependencyConflict),
            );
            expect(
              (await service.invitationRangeRestorationApplication(
                restoreInput.invitationId,
              )).latestResult,
              isNull,
            );
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 20, date: date, zone: zone),
              ),
            );
            expect(
              (await service.applyInvitationRangeUpdate(input)).id,
              receipt.id,
            );
            final wholeView = await whole(sequence: 30);
            expect(wholeView.canApplyCancellation, isTrue);
            await service.applyInvitationCancellation(masterCommand(wholeView));
            await service.applyInvitationUpdate(
              masterCommand(
                await newerMaster(sequence: 31, date: date, zone: zone),
              ),
            );
            expect((await data()).timingOverrides?.cancelledFrom, isNull);
            final singleInput = command(
              await single(
                sequence: 14,
                date: date,
                zone: zone,
                original: date
                    ? '20300105'
                    : zone == null
                    ? '20300105T090000Z'
                    : '20300105T090000',
              ),
            );
            await service.applyInvitationOccurrenceUpdate(singleInput);
            expect((jsonDecode((await row()).stateJson) as Map)['version'], 11);
            await expectLater(
              service.applyInvitationRangeUpdate(input),
              failure(CalendarFailureCode.staleRevision),
            );
            final next = await rangeUpdate(
              sequence: 15,
              date: date,
              zone: zone,
            );
            expect(next.canApply, isTrue);
            await service.applyInvitationRangeUpdate(command(next));
            expect(
              (jsonDecode((await row()).stateJson) as Map)['frozenRestoration'],
              first['frozenRestoration'],
            );
          },
        );
      }
    }
    for (final sequence in [2, 9, 10]) {
      test(
        'historical floor rejects $sequence even with a later source stamp',
        () async {
          await ready();
          final before = (await data()).toJson(),
              prior = (await row()).toJson();
          final v = await rangeUpdate(
            sequence: sequence,
            original: '20300103T090000Z',
            stamp: '20270101T000000Z',
          );
          expect(v.acceptedVersion.sequence, 1);
          expect(v.canApply, isFalse);
          await expectLater(
            service.applyInvitationRangeUpdate(command(v)),
            failure(CalendarFailureCode.dependencyConflict),
          );
          expect((await data()).toJson(), before);
          expect((await row()).toJson(), prior);
        },
      );
    }
    for (final sequence in [11, 19, 20]) {
      test(
        'effective component floor rejects $sequence independently of historical restoration',
        () async {
          await ready();
          await service.applyInvitationUpdate(
            masterCommand(await newerMaster(sequence: 20)),
          );
          final v = await rangeUpdate(
            sequence: sequence,
            original: '20300103T090000Z',
            stamp: '20270101T000000Z',
          );
          expect(v.acceptedVersion.sequence, 20);
          expect(v.canApply, isFalse);
          await expectLater(
            service.applyInvitationRangeUpdate(command(v)),
            failure(CalendarFailureCode.dependencyConflict),
          );
        },
      );
    }
    test(
      'higher range sequence preserves backwards source stamp and omissions',
      () async {
        await ready();
        final v = await rangeUpdate(
          sequence: 11,
          original: '20300103T090000Z',
          stamp: '20200101T000000Z',
        );
        expect(v.canApply, isTrue);
        await service.applyInvitationRangeUpdate(command(v));
        final version = (await data()).protocolState!.overrides.single.version;
        expect(version.stamp, DateTime.utc(2020));
        expect(version.created, isNull);
        expect(version.lastModified, isNull);
      },
    );
    for (final maximum in ['effective', 'historical']) {
      test(
        'maximum $maximum sequence rejects rather than inventing an increment',
        () async {
          if (maximum == 'historical') {
            await setup();
            await service.applyInvitationRangeCancellation(await cancel());
            await service.applyInvitationRangeRestoration(
              command(await restoration(sequence: 2147483647)),
            );
          } else {
            await ready();
            await service.applyInvitationUpdate(
              masterCommand(await newerMaster(sequence: 2147483647)),
            );
          }
          final v = await rangeUpdate(
            sequence: 2147483647,
            original: '20300103T090000Z',
            stamp: '20270101T000000Z',
          );
          expect(v.canApply, isFalse);
          await expectLater(
            service.applyInvitationRangeUpdate(command(v)),
            failure(CalendarFailureCode.dependencyConflict),
          );
        },
      );
    }
    test('later independent range and cancelled single retain their exact versions and data', () async {
      await setup();
      final later = await rangeUpdate(
        sequence: 30,
        original: '20300104T090000Z',
      );
      await service.applyInvitationRangeUpdate(command(later));
      await service.applyInvitationOccurrenceCancellation(
        command(
          await single(
            sequence: 40,
            cancelled: true,
            original: '20300105T090000Z',
          ),
        ),
      );
      await service.applyInvitationRangeCancellation(
        await cancel(sequence: 41),
      );
      await service.applyInvitationRangeRestoration(
        command(await restoration(sequence: 42)),
      );
      final d = await data(),
          future = d.timingOverrides!.future.single.toJson(),
          one = d.timingOverrides!.singles.single.toJson(),
          versions = d.protocolState!.overrides.map((v) => v.toJson()).toList();
      await service.applyInvitationRangeUpdate(
        command(await rangeUpdate(sequence: 43)),
      );
      final after = await data();
      expect(after.timingOverrides!.future.last.toJson(), future);
      expect(after.timingOverrides!.singles.single.toJson(), one);
      for (final v in versions) {
        expect(
          after.protocolState!.overrides.map((v) => v.toJson()).toList(),
          contains(equals(v)),
        );
      }
    });
    test(
      'same-anchor single/range collision rejects without dropping the single',
      () async {
        await ready();
        await service.applyInvitationOccurrenceUpdate(command(await single()));
        final before = (await data()).toJson(),
            v = await rangeUpdate(sequence: 11);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(v)),
          failure(CalendarFailureCode.validation),
        );
        expect((await data()).toJson(), before);
      },
    );
    for (final op in [
      CalendarInvitationOperation.applyRangeUpdate,
      CalendarInvitationOperation.readRangeApplication,
      CalendarInvitationOperation.composeAcceptedOccurrences,
      CalendarInvitationOperation.composeAcceptedRangeCancellation,
      CalendarInvitationOperation.composeAcceptedRangeRestoration,
    ]) {
      test('final $op denial rolls back the complete range write', () async {
        await ready();
        final input = command(await rangeUpdate()),
            before = (await data()).toJson(),
            prior = (await row()).toJson();
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == op &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(op);
          }
        };
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), prior);
      });
    }
    test('denied range action removes preview eligibility', () async {
      await ready();
      final v = await rangeUpdate();
      host.denied.add(CalendarInvitationOperation.applyRangeUpdate);
      expect(
        (await service.invitationRangeApplication(v.invitationId)).canApply,
        isFalse,
      );
    });
    for (final mutation in [
      'floor-missing',
      'floor-low',
      'floor-equal',
      'range-key',
      'source',
      'kind',
      'nested',
      'namespace',
      'receipt',
      'targets',
    ]) {
      test(
        'corrupt v11 $mutation fails unavailable without legacy fallback',
        () async {
          await ready();
          final input = command(await rangeUpdate());
          await service.applyInvitationRangeUpdate(input);
          final value = await row(),
              state =
                  jsonDecode((await row()).stateJson) as Map<String, dynamic>;
          switch (mutation) {
            case 'floor-missing':
              state['targets'][0].remove('requiredAfterSequence');
            case 'floor-low':
              state['targets'][0]['requiredAfterSequence'] = 9;
            case 'floor-equal':
              state['targets'][0]['requiredAfterSequence'] = 11;
            case 'range-key':
              state['latestTargetKey'] = 'single';
            case 'source':
              state['targets'][0]['source'] = 'private malformed fixture';
            case 'kind':
              state['masterKind'] = 'meetingCancellation';
            case 'nested':
              state['frozenRestoration']['checkpoint']['state']['version'] = 11;
            case 'namespace':
              state['version'] = 10;
            case 'receipt':
              state.remove('receiptDigest');
            case 'targets':
              state['targets'].add(state['targets'][0]);
          }
          value.stateJson = jsonEncode(state);
          await CalendarInvitationOccurrenceApplicationRecord.db.updateRow(
            session,
            value,
          );
          await expectLater(
            service.applyInvitationRangeUpdate(input),
            failure(CalendarFailureCode.unavailable),
          );
        },
      );
    }
    test(
      'range capacity counts floor and retained proof bytes atomically',
      () async {
        await ready();
        final input = command(await rangeUpdate()),
            before = (await data()).toJson(),
            prior = (await row()).toJson();
        install(
          options: CalendarInvitationOptions(
            maxOccurrenceCheckpointBytes:
                utf8.encode((await row()).stateJson).length + 8,
          ),
        );
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect((await data()).toJson(), before);
        expect((await row()).toJson(), prior);
      },
    );
    test(
      'native draft conflicts but retained current range retry never replays',
      () async {
        await ready();
        final input = command(await rangeUpdate());
        final receipt = await service.applyInvitationRangeUpdate(input);
        final d = await data();
        d.content = d.content.copyWith(summary: 'Local draft');
        await CalendarEventDataRecord.db.updateRow(session, d);
        final v = await rangeUpdate(sequence: 12);
        expect(v.hasLocalChanges, isTrue);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        expect(
          (await service.applyInvitationRangeUpdate(input)).id,
          receipt.id,
        );
        expect((await data()).toJson(), d.toJson());
      },
    );
    test(
      'omitted incoming sequence stays absent and cannot pass range floors',
      () async {
        await ready();
        final text = utf8
            .decode(
              rangeInvitationBytes(sequence: 11, original: '20300103T090000Z'),
            )
            .replaceFirst('SEQUENCE:11\r\n', '');
        final r = await receive(Uint8List.fromList(utf8.encode(text)));
        final v = await service.invitationRangeApplication(r.entryId);
        expect(v.incomingVersion!.sequence, isNull);
        expect(v.canApply, isFalse);
        await expectLater(
          service.applyInvitationRangeUpdate(command(v)),
          failure(CalendarFailureCode.dependencyConflict),
        );
      },
    );
    test(
      'native update permission independently controls range eligibility',
      () async {
        await ready();
        final v = await rangeUpdate();
        policy.denied.add(CalendarPermission.updateEvent);
        expect(
          (await service.invitationRangeApplication(v.invitationId)).canApply,
          isFalse,
        );
        await expectLater(
          service.applyInvitationRangeUpdate(command(v)),
          failure(CalendarFailureCode.accessDenied),
        );
      },
    );
    test('whole cancellation blocks pending range but preserves current inert retry', () async {
      await ready();
      final input = command(await rangeUpdate());
      final r = await service.applyInvitationRangeUpdate(input);
      final pending = await rangeUpdate(sequence: 12);
      await service.applyInvitationCancellation(
        masterCommand(await whole(sequence: 30)),
      );
      final v = await service.invitationRangeApplication(pending.invitationId);
      expect(v.canApply, isFalse);
      await expectLater(
        service.applyInvitationRangeUpdate(command(v)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      final before = (await data()).toJson();
      expect((await service.applyInvitationRangeUpdate(input)).id, r.id);
      expect((await data()).toJson(), before);
    });
    test('legacy restoration retry permission remains unchanged before range acceptance', () async {
      final input = await ready();
      host.denied.add(
        CalendarInvitationOperation.composeAcceptedRangeRestoration,
      );
      expect(
        (await service.applyInvitationRangeRestoration(input)).eventRevision,
        3,
      );
    });
    test(
      'pruned range source is freshly authorized and deletion scrubs v11',
      () async {
        await ready();
        final input = command(await rangeUpdate());
        final r = await service.applyInvitationRangeUpdate(input);
        final source = (await CalendarInvitationSourceRecord.db.findById(
              session,
              input.sourceId,
            ))!,
            entry = (await CalendarInvitationRecord.db.findById(
              session,
              input.invitationId,
            ))!;
        await CalendarInvitationRecord.db.updateRow(
          session,
          entry.copyWith(currentSourceId: null),
        );
        await CalendarInvitationReceiptRecord.db.deleteWhere(
          session,
          where: (t) => t.sourceId.equals(input.sourceId),
        );
        await CalendarInvitationSourceRecord.db.deleteRow(session, source);
        expect((await service.applyInvitationRangeUpdate(input)).id, r.id);
        host.onAuthorize = (c, tx, phase) async {
          if (c.operation == CalendarInvitationOperation.readSource &&
              c.sourceId == input.sourceId &&
              phase == CalendarAuthorizationPhase.finalWrite) {
            host.denied.add(CalendarInvitationOperation.readSource);
          }
        };
        await expectLater(
          service.applyInvitationRangeUpdate(input),
          failure(CalendarFailureCode.accessDenied),
        );
        host.denied.clear();
        host.onAuthorize = null;
        await service.deleteEvent(r.eventId, r.eventRevision);
        expect(
          await CalendarInvitationOccurrenceApplicationRecord.db.count(session),
          0,
        );
      },
    );
    test(
      'range move changes complete busy clocks without hiding coverage',
      () async {
        final link = await setup(extra: ['DURATION:PT1H']);
        await service.applyInvitationRangeCancellation(await cancel());
        final restored = utf8
            .decode(
              rangeInvitationBytes(sequence: 10, extra: ['DURATION:PT1H']),
            )
            .replaceFirst(
              'DTSTART:20300101T090000Z',
              'DTSTART:20300102T090000Z',
            );
        final r = await receive(Uint8List.fromList(utf8.encode(restored)));
        await service.applyInvitationRangeRestoration(
          command(
            await service.invitationRangeRestorationApplication(r.entryId),
          ),
        );
        final query = CalendarFreeBusyQuery(
          calendarId: link.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 7),
        );
        expect(
          (await service.freeBusy(query)).periods
              .where((p) => p.kind == CalendarFreeBusyKind.busy)
              .length,
          6,
        );
        final text = utf8
            .decode(
              rangeInvitationBytes(
                sequence: 11,
                original: '20300103T090000Z',
                extra: ['DURATION:PT1H'],
              ),
            )
            .replaceFirst(
              'DTSTART:20300101T090000Z',
              'DTSTART:20300103T110000Z',
            );
        final next = await receive(Uint8List.fromList(utf8.encode(text)));
        await service.applyInvitationRangeUpdate(
          command(await service.invitationRangeApplication(next.entryId)),
        );
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        final periods = busy.periods
            .where((p) => p.kind == CalendarFreeBusyKind.busy)
            .toList();
        expect(periods.length, 6);
        expect(
          periods
              .where((p) => p.startUtc.day >= 3)
              .every((p) => p.startUtc.hour == 11),
          isTrue,
        );
        for (final sequence in [20, 22]) {
          await service.applyInvitationRangeCancellation(
            await cancel(sequence: sequence),
          );
          final masked = await service.freeBusy(query);
          expect(masked.coverage, CalendarFreeBusyCoverage.complete);
          final occurrences = await service.listEventOccurrences(
            CalendarEventOccurrenceListQuery(
              calendarId: link.calendarId,
              fromUtc: query.fromUtc,
              untilUtc: query.untilUtc,
              pageSize: 20,
              includeCancelled: true,
              fieldGroups: [],
            ),
          );
          expect(occurrences.occurrences, hasLength(6));
          expect(
            occurrences.occurrences
                .where(
                  (v) => v.status == CalendarEventStatus.cancelled,
                )
                .length,
            5,
          );
          expect(
            masked.periods
                .where((p) => p.kind == CalendarFreeBusyKind.busy)
                .length,
            1,
          );
          await service.applyInvitationRangeRestoration(
            command(await currentRestoration(sequence + 1)),
          );
          final reopened = await service.freeBusy(query);
          expect(reopened.coverage, CalendarFreeBusyCoverage.complete);
          expect(
            reopened.periods.map((p) => p.toJson()).toList(),
            busy.periods.map((p) => p.toJson()).toList(),
          );
        }
      },
    );
    for (final mode in ['relative', 'absolute', 'snooze']) {
      final absolute = mode == 'absolute';
      test(
        'v12 repeated cycles and whole lifecycle preserve $mode actions without replay',
        () async {
          final delivery = TestAlarmDeliveryPort();
          install(
            alarms: CalendarAlarmRuntime(
              policy: TestAlarmBackgroundPolicy(),
              delivery: delivery,
            ),
          );
          final raw =
              (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                      .single
                      .single
                  as DateTime;
          final due = DateTime.fromMillisecondsSinceEpoch(
            raw.toUtc().millisecondsSinceEpoch ~/ 1000 * 1000,
            isUtc: true,
          ).subtract(const Duration(minutes: 1));
          String point(DateTime d) =>
              '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}T${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}${d.second.toString().padLeft(2, '0')}Z';
          final link = await setup(
            start: 'DTSTART:${point(due)}',
            extra: ['DURATION:PT1H'],
          );
          final range = await cancel(
            sequence: 10,
            original: point(due.add(const Duration(days: 1))),
          );
          await service.applyInvitationRangeCancellation(range);
          final restoredBytes = utf8
              .decode(
                rangeInvitationBytes(
                  sequence: 11,
                  original: point(due.add(const Duration(days: 1))),
                ),
              )
              .replaceFirst(
                'DTSTART:20300101T090000Z',
                'DTSTART:${point(due.add(const Duration(days: 1)))}',
              )
              .replaceFirst(
                'SUMMARY:Review',
                'SUMMARY:Review\r\nDURATION:PT1H',
              );
          final restoredSource = await receive(
            Uint8List.fromList(utf8.encode(restoredBytes)),
          );
          await service.applyInvitationRangeRestoration(
            command(
              await service.invitationRangeRestorationApplication(
                restoredSource.entryId,
              ),
            ),
          );
          final newRangeText = utf8
              .decode(
                rangeInvitationBytes(
                  sequence: 12,
                  original: point(due.add(const Duration(days: 2))),
                  extra: ['DURATION:PT1H'],
                ),
              )
              .replaceFirst(
                'DTSTART:20300101T090000Z',
                'DTSTART:${point(due.add(const Duration(days: 2)))}',
              );
          final newRange = await receive(
            Uint8List.fromList(utf8.encode(newRangeText)),
          );
          await service.applyInvitationRangeUpdate(
            command(await service.invitationRangeApplication(newRange.entryId)),
          );
          expect((jsonDecode((await row()).stateJson) as Map)['version'], 11);
          final parent = CalendarAlarmParent(
            kind: CalendarAlarmParentKind.event,
            id: link.eventId,
          );
          final alarm = (await service.createPersonalAlarm(
            CalendarAlarmCreateRequest(
              parent: parent,
              definition: absolute
                  ? CalendarAlarmDefinition(absoluteUtc: due)
                  : CalendarAlarmDefinition(
                      relativeDuration: CalendarAlarmDuration(),
                      anchor: CalendarAlarmAnchor.start,
                    ),
            ),
          ))!;
          await service.setPersonalAlarmArmed(
            parent,
            alarm.id,
            alarm.revision,
            true,
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          final intent = delivery.accepted.values.single;
          expect(
            await CalendarModule.checkAlarmDelivery(session, intent),
            CalendarAlarmDeliveryCheck.eligible,
          );
          CalendarAlarmActionRecord? action;
          if (mode == 'snooze') {
            await service.actOnPersonalAlarm(
              CalendarAlarmActionRequest(
                parent: parent,
                alarmId: alarm.id,
                expectedAlarmRevision: (await CalendarAlarmRecord.db.findById(
                  session,
                  alarm.id,
                ))!.revision,
                expectedActionRevision: 0,
                kind: CalendarAlarmActionKind.snooze,
                firingId: intent.firingId,
                snoozeAt: due.add(const Duration(minutes: 6)),
              ),
            );
            action = (await CalendarAlarmActionRecord.db.find(session)).single;
          }
          for (final sequence in [20, 22]) {
            await service.applyInvitationRangeCancellation(
              await cancel(sequence: sequence, original: point(due)),
            );
            expect(
              await CalendarModule.checkAlarmDelivery(session, intent),
              absolute
                  ? isNot(CalendarAlarmDeliveryCheck.eligible)
                  : CalendarAlarmDeliveryCheck.withdrawn,
            );
            await CalendarModule.runAlarmMaintenance(session);
            expect(delivery.calls, 1);
            final text = utf8
                .decode(
                  rangeInvitationBytes(
                    sequence: sequence + 1,
                    original: point(due),
                    extra: ['DURATION:PT1H'],
                  ),
                )
                .replaceFirst(
                  'DTSTART:20300101T090000Z',
                  'DTSTART:${point(due)}',
                );
            final source = await receive(Uint8List.fromList(utf8.encode(text)));
            await service.applyInvitationRangeRestoration(
              command(
                await service.invitationRangeRestorationApplication(
                  source.entryId,
                ),
              ),
            );
            await CalendarModule.runAlarmMaintenance(session);
            expect(delivery.calls, 1);
          }
          await service.applyInvitationCancellation(
            masterCommand(await whole(sequence: 30)),
          );
          expect(
            await CalendarModule.checkAlarmDelivery(session, intent),
            CalendarAlarmDeliveryCheck.withdrawn,
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          final bytes = utf8
              .decode(
                invitationBytes(
                  sequence: 31,
                  extra: ['RRULE:FREQ=DAILY;COUNT=6', 'DURATION:PT1H'],
                ),
              )
              .replaceFirst(
                'DTSTART:20300101T090000Z',
                'DTSTART:${point(due)}',
              );
          final r = await receive(Uint8List.fromList(utf8.encode(bytes)));
          await service.applyInvitationUpdate(
            masterCommand(await service.invitationApplication(r.entryId)),
          );
          await CalendarModule.runAlarmMaintenance(session);
          expect(delivery.calls, 1);
          expect((await data()).timingOverrides?.cancelledFrom, isNull);
          if (action != null) {
            expect(
              (await CalendarAlarmActionRecord.db.findById(
                session,
                action.id!,
              ))!.toJson(),
              action.toJson(),
            );
          }
          expect(
            await CalendarAlarmFiringRecord.db.count(
              session,
              where: (t) =>
                  t.alarmId.equals(alarm.id) &
                  t.state.equals(CalendarAlarmFiringState.accepted),
            ),
            1,
          );
        },
        timeout: const Timeout(Duration(minutes: 2)),
      );
    }
    test('explicit DST gap original survives v12 cycles and an orphaning master still rejects', () async {
      const zone = 'Europe/Stockholm',
          inclusion = 'RDATE;TZID=Europe/Stockholm:20300331T023000';
      await setup(
        zone: zone,
        start: 'DTSTART;TZID=$zone:20300330T023000',
        extra: [inclusion],
      );
      await service.applyInvitationRangeCancellation(
        await cancel(zone: zone, original: '20300331T023000'),
      );
      Uint8List bytes(int sequence, {bool range = false, bool include = true}) {
        final raw = range
            ? rangeInvitationBytes(
                zone: zone,
                sequence: sequence,
                original: '20300331T023000',
              )
            : invitationBytes(
                zone: zone,
                sequence: sequence,
                extra: ['RRULE:FREQ=DAILY;COUNT=6', if (include) inclusion],
              );
        return Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(raw)
                .replaceFirst(
                  'DTSTART;TZID=$zone:20300101T090000',
                  'DTSTART;TZID=$zone:${range ? '20300331T023000' : '20300330T023000'}',
                ),
          ),
        );
      }

      final restored = await receive(bytes(4, range: true));
      await service.applyInvitationRangeRestoration(
        command(
          await service.invitationRangeRestorationApplication(restored.entryId),
        ),
      );
      final source = await receive(bytes(5, range: true)),
          view = await service.invitationRangeApplication(source.entryId);
      expect(view.canApply, isTrue);
      await service.applyInvitationRangeUpdate(command(view));
      final current = await service.invitationRangeApplication(source.entryId);
      expect(current.originalStart.start.hour, 2);
      expect(current.originalStart.start.minute, 30);
      expect(current.originalStart.zoneId, zone);
      for (final sequence in [20, 22]) {
        await service.applyInvitationRangeCancellation(
          await cancel(
            sequence: sequence,
            zone: zone,
            original: '20300331T023000',
          ),
        );
        final source = await receive(bytes(sequence + 1, range: true));
        await service.applyInvitationRangeRestoration(
          command(
            await service.invitationRangeRestorationApplication(source.entryId),
          ),
        );
        expect((await data()).timingOverrides?.cancelledFrom, isNull);
        expect(
          (await data()).protocolState!.overrides.single.version.sequence,
          5,
        );
      }
      final orphan = await receive(bytes(30, include: false)),
          blocked = await service.invitationApplication(orphan.entryId);
      expect(blocked.canApply, isFalse);
      await expectLater(
        service.applyInvitationUpdate(masterCommand(blocked)),
        failure(CalendarFailureCode.validation),
      );
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
