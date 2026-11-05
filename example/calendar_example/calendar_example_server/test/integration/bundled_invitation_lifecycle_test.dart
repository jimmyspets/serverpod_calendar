import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:test/test.dart';

import 'calendar_test.dart'
    show
        TestPolicy,
        TestAlarmBackgroundPolicy,
        TestAlarmDeliveryPort,
        createInput,
        failure;
import 'invitation_test.dart' show InvitationTestHost, invitationDelivery;
import 'invitation_bundles_test.dart' show bundleBytes;
import 'test_tools/serverpod_test_tools.dart';

Uint8List bundleCancellationBytes({
  int sequence = 13,
  String recipient = 'alice',
  String extra = '',
  String stamp = '20250101T000000Z',
}) => Uint8List.fromList(
  utf8.encode(
    [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//Synthetic//EN',
      'METHOD:CANCEL',
      'BEGIN:VEVENT',
      'UID:bundle',
      'DTSTAMP:$stamp',
      'SEQUENCE:$sequence',
      'STATUS:CANCELLED',
      'ORGANIZER:mailto:organizer@example.invalid',
      'ATTENDEE:mailto:$recipient@example.invalid',
      if (extra.isNotEmpty) extra,
      'END:VEVENT',
      'END:VCALENDAR',
      '',
    ].join('\r\n'),
  ),
);

void main() {
  withServerpod('bundled whole-series lifecycle', (builder, endpoints) {
    late Session session;
    late TestPolicy policy;
    late InvitationTestHost host;
    late CalendarService service;
    late TestAlarmDeliveryPort delivery;
    setUp(() {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = TestPolicy();
      host = InvitationTestHost();
      delivery = TestAlarmDeliveryPort();
      CalendarModule.install(
        session.serverpod,
        policy: policy,
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        invitations: CalendarInvitationRuntime(host: host),
        alarms: CalendarAlarmRuntime(
          policy: TestAlarmBackgroundPolicy(),
          delivery: delivery,
        ),
      );
      service = CalendarModule.service(session);
    });
    Future<CalendarInvitationReceipt> receive(Uint8List bytes, String key) =>
        CalendarModule.receiveSchedulingInvitation(
          session,
          invitationDelivery(key: key, bytes: bytes),
        );
    Future<CalendarInvitationAdoptionReceipt> seed({
      bool date = false,
      String? zone,
      bool explicitStatus = false,
    }) async {
      final calendar = (await service.create(createInput()))!;
      var source = bundleBytes(date: date, zone: zone);
      if (explicitStatus) {
        source = Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(source)
                .replaceAll('SUMMARY:', 'STATUS:TENTATIVE\r\nSUMMARY:'),
          ),
        );
      }
      final receipt = await receive(source, 'initial');
      return service.adoptInvitation(
        CalendarInvitationAdoptionRequest(
          invitationId: receipt.entryId,
          expectedRevision: 1,
          sourceId: receipt.sourceId,
          calendarId: calendar.calendarId,
          expectedCalendarRevision: 1,
        ),
      );
    }

    CalendarInvitationApplyRequest command(
      CalendarInvitationBundleApplicationView view,
    ) => CalendarInvitationApplyRequest(
      invitationId: view.invitationId,
      sourceId: view.incomingSourceId!,
      expectedInvitationRevision: view.invitationRevision!,
      linkId: view.linkId,
      expectedEventRevision: view.eventRevision,
      expectedCalendarRevision: view.calendarRevision,
      expectedApplicationRevision: view.applicationRevision,
    );
    Future<CalendarInvitationBundleApplicationView> cancel(
      CalendarInvitationAdoptionReceipt link, {
      int sequence = 13,
    }) async {
      await receive(
        bundleCancellationBytes(sequence: sequence),
        'cancel-$sequence',
      );
      final view = await service.invitationBundleApplication(link.invitationId);
      expect(view.canApplyCancellation, isTrue);
      expect(view.canApply, isFalse);
      expect(view.incomingComponents, hasLength(1));
      expect(view.acceptedComponents, hasLength(3));
      await service.applyInvitationBundleCancellation(command(view));
      return service.invitationBundleApplication(link.invitationId);
    }

    Future<void> expire({bool keepMarker = false}) async {
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_receipt SET "expiresAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        'UPDATE serverpod_calendar_invitation_source SET "inactiveAt" = now() - interval \'40 days\'',
      );
      await session.db.unsafeExecute(
        keepMarker
            ? 'UPDATE serverpod_calendar_invitation SET "dismissedAt" = now()'
            : 'UPDATE serverpod_calendar_invitation SET "dismissedAt" = now() - interval \'40 days\'',
      );
      await service.listInvitations();
    }

    for (final profile in ['date', 'utc', 'Europe/Stockholm', 'US/Eastern']) {
      test(
        '$profile cancellation/reopening cycles retain original source components',
        () async {
          final date = profile == 'date',
              zone = profile == 'date' || profile == 'utc' ? null : profile;
          final link = await seed(date: date, zone: zone, explicitStatus: true);
          final data = (await CalendarEventDataRecord.db.find(session)).single;
          final baseline = data.importBaseline!.canonicalValue;
          final children = jsonEncode(
            data.protocolState!.overrides.map((v) => v.toJson()).toList(),
          );
          for (final sequence in [13, 15]) {
            final cancelled = await cancel(link, sequence: sequence);
            expect(
              cancelled.acceptedKind,
              CalendarInvitationSourceKind.bundleCancellation,
            );
            expect(cancelled.acceptedCancellationVersion!.sequence, sequence);
            expect(
              cancelled.acceptedComponents
                  .firstWhere((v) => v.originalStart == null)
                  .sequence,
              sequence == 13 ? 2 : 14,
            );
            expect(cancelled.hasLocalChanges, isFalse);
            expect(
              (await service.adoptInvitation(
                CalendarInvitationAdoptionRequest(
                  invitationId: link.invitationId,
                  expectedRevision: 1,
                  sourceId: link.sourceId,
                  calendarId: link.calendarId,
                  expectedCalendarRevision: 1,
                ),
              )).toJson(),
              link.toJson(),
            );

            final current = (await CalendarEventDataRecord.db.find(session))
                .single;
            expect(current.content.status, CalendarEventStatus.cancelled);
            expect(
              current.importBaseline!.canonicalValue,
              sequence == 13
                  ? baseline
                  : current.importBaseline!.canonicalValue,
            );
            expect(
              jsonEncode(
                current.protocolState!.overrides
                    .map((v) => v.toJson())
                    .toList(),
              ),
              children,
            );
            expect(current.protocolState!.version.created, isNull);
            await receive(
              Uint8List.fromList(
                utf8.encode(
                  utf8
                      .decode(
                        bundleBytes(
                          sequence: sequence + 1,
                          date: date,
                          zone: zone,
                        ),
                      )
                      .replaceAll('SUMMARY:', 'STATUS:TENTATIVE\r\nSUMMARY:'),
                ),
              ),
              'reopen-$sequence',
            );
            final reopening = await service.invitationBundleApplication(
              link.invitationId,
            );
            expect(reopening.canReopen, isTrue);
            expect(reopening.canApply, isFalse);
            await expectLater(
              service.applyInvitationBundleUpdate(command(reopening)),
              failure(CalendarFailureCode.validation),
            );
            final input = command(reopening);
            final result = await service.applyInvitationBundleReopening(input);
            expect(
              (await service.applyInvitationBundleReopening(input)).toJson(),
              result.toJson(),
            );
            final reopened = await service.invitationBundleApplication(
              link.invitationId,
            );
            expect(reopened.acceptedCancellationVersion, isNull);
            expect(
              reopened.currentContent.status,
              CalendarEventStatus.tentative,
            );
            expect(reopened.hasLocalChanges, isFalse);
            expect(
              reopened.acceptedComponents
                  .where((v) => v.originalStart != null)
                  .map((v) => v.sequence),
              [null, 12],
            );
          }
          expect(await CalendarEventRecord.db.count(session), 1);
          expect(
            await CalendarInvitationApplicationRecord.db.count(session),
            1,
          );
        },
      );
    }
    test('pending complete vector and cancellation floors reject stale/incomparable bodies', () async {
      final link = await seed();
      await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes())
                .replaceFirst('SEQUENCE:12', 'SEQUENCE:14'),
          ),
        ),
        'pending',
      );
      await expectLater(
        receive(bundleCancellationBytes(), 'low'),
        failure(CalendarFailureCode.validation),
      );
      await receive(bundleCancellationBytes(sequence: 15), 'new');
      await expectLater(
        receive(bundleBytes(sequence: 15), 'tied-reopen'),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        receive(
          Uint8List.fromList(
            utf8.encode(
              utf8
                  .decode(bundleCancellationBytes(sequence: 15))
                  .replaceFirst('Synthetic', 'Different'),
            ),
          ),
          'tied-cancel',
        ),
        failure(CalendarFailureCode.validation),
      );
      // A complete REQUEST above the pending CANCEL supersedes review only.
      await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes(sequence: 16))
                .replaceFirst('SEQUENCE:12', 'SEQUENCE:14'),
          ),
        ),
        'supersede',
      );
      final view = await service.invitationBundleApplication(link.invitationId);
      expect(view.canApply, isTrue);
      expect(view.currentContent.status, CalendarEventStatus.confirmed);
    });
    test('local draft blocks cancellation, latest exact retry never overwrites draft', () async {
      final link = await seed();
      await receive(bundleCancellationBytes(), 'cancel');
      final view = await service.invitationBundleApplication(link.invitationId);
      final input = command(view);
      final result = await service.applyInvitationBundleCancellation(input);
      final data = (await CalendarEventDataRecord.db.find(session)).single;
      await service.updateEvent(
        CalendarEventUpdateRequest(
          eventId: link.eventId,
          expectedRevision: result.eventRevision,
          content: data.content.copyWith(summary: 'Private draft'),
        ),
      );
      expect(
        (await service.applyInvitationBundleCancellation(input)).toJson(),
        result.toJson(),
      );
      await receive(bundleCancellationBytes(sequence: 14), 'next');
      final conflict = await service.invitationBundleApplication(
        link.invitationId,
      );
      expect(conflict.hasLocalChanges, isTrue);
      expect(conflict.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationBundleCancellation(command(conflict)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session)).single.content.summary,
        'Private draft',
      );
    });
    test('source pruning preserves cancellation proof, baseline and exact latest command', () async {
      final link = await seed(explicitStatus: true);
      await receive(bundleCancellationBytes(), 'cancel');
      final input = command(
        await service.invitationBundleApplication(link.invitationId),
      );
      final result = await service.applyInvitationBundleCancellation(input);
      await expire();
      expect(
        (await service.applyInvitationBundleCancellation(input)).toJson(),
        result.toJson(),
      );
      final view = await service.invitationBundleApplication(link.invitationId);
      expect(view.acceptedSourceUnavailable, isTrue);
      expect(view.hasLocalChanges, isFalse);
      expect(view.acceptedComponents, hasLength(3));
      expect(view.acceptedCancellationVersion!.sequence, 13);
      await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes(sequence: 14))
                .replaceAll('SUMMARY:', 'STATUS:TENTATIVE\r\nSUMMARY:'),
          ),
        ),
        'reopen',
      );
      final newView = await service.invitationBundleApplication(
        (await service.listInvitations()).single.id,
      );
      await service.applyInvitationBundleReopening(command(newView));
      await expectLater(
        service.applyInvitationBundleCancellation(input),
        failure(CalendarFailureCode.staleRevision),
      );
    });
    test('separate cancellation/reopening authority and final denial roll back all state', () async {
      final link = await seed();
      host.denied.add(CalendarInvitationOperation.receiveBundleCancellation);
      await expectLater(
        receive(bundleCancellationBytes(), 'denied'),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      await receive(bundleCancellationBytes(), 'cancel');
      var view = await service.invitationBundleApplication(link.invitationId);
      host.denied.add(CalendarInvitationOperation.applyBundleCancellation);
      await expectLater(
        service.applyInvitationBundleCancellation(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denied.clear();
      host.denyFinal = true;
      await expectLater(
        service.applyInvitationBundleCancellation(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
      host.denyFinal = false;
      expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
      await service.applyInvitationBundleCancellation(command(view));
      await receive(bundleBytes(sequence: 14), 'reopen');
      view = await service.invitationBundleApplication(link.invitationId);
      host.denied.add(CalendarInvitationOperation.reopenBundle);
      await expectLater(
        service.applyInvitationBundleReopening(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('native lifecycle authority and actual before/proposed context remain independent', () async {
      final link = await seed(explicitStatus: true);
      await receive(bundleCancellationBytes(), 'cancel');
      var view = await service.invitationBundleApplication(link.invitationId);
      policy.denied.add(CalendarPermission.changeEventStatus);
      expect(
        (await service.invitationBundleApplication(link.invitationId))
            .canApplyCancellation,
        isFalse,
      );
      await expectLater(
        service.applyInvitationBundleCancellation(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
      policy.denied.clear();
      final phases = <CalendarAuthorizationPhase>[];
      host.onAuthorize = (context, tx, phase) async {
        if (context.operation ==
                CalendarInvitationOperation.applyBundleCancellation &&
            context.proposedApplication != null) {
          phases.add(phase);
          expect(
            context.currentEvent!.content.status,
            CalendarEventStatus.tentative,
          );
          expect(
            context.proposedEvent!.content.status,
            CalendarEventStatus.cancelled,
          );
          expect(
            context.currentApplication!.kind,
            CalendarInvitationSourceKind.requestBundle,
          );
          expect(
            context.proposedApplication!.kind,
            CalendarInvitationSourceKind.bundleCancellation,
          );
          expect(context.bundleEvidence!.accepted, hasLength(3));
          expect(context.bundleEvidence!.incoming, hasLength(1));
          expect(context.current!.dismissedAt, isNull);
          expect(context.proposedDismissed, isTrue);
        }
      };
      await service.applyInvitationBundleCancellation(command(view));
      expect(phases, contains(CalendarAuthorizationPhase.finalWrite));
      host.onAuthorize = null;
      await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes(sequence: 14))
                .replaceAll('SUMMARY:', 'STATUS:TENTATIVE\r\nSUMMARY:'),
          ),
        ),
        'reopen',
      );
      view = await service.invitationBundleApplication(link.invitationId);
      policy.denied.add(CalendarPermission.changeEventStatus);
      expect(
        (await service.invitationBundleApplication(link.invitationId))
            .canReopen,
        isFalse,
      );
      await expectLater(
        service.applyInvitationBundleReopening(command(view)),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test('new cancellation profile never opens scalar, instance or participation paths', () async {
      final link = await seed();
      await cancel(link);
      await expectLater(
        service.invitationApplication(link.invitationId),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.invitationOccurrenceApplication(link.invitationId),
        failure(CalendarFailureCode.validation),
      );
      await expectLater(
        service.invitationResponse(link.invitationId),
        failure(CalendarFailureCode.validation),
      );
    });
    test('a private individual cancellation blocks whole-source replacement and is retained', () async {
      final link = await seed();
      final initial = await service.invitationBundleApplication(
        link.invitationId,
      );
      final original = initial.currentOverrides!.singles.single.originalStart;
      await service.changeOccurrence(
        CalendarEventOccurrenceChange(
          eventId: link.eventId,
          expectedRevision: 1,
          originalStart: original,
          action: CalendarEventOccurrenceAction.cancelSingle,
        ),
      );
      await receive(bundleCancellationBytes(), 'cancel');
      final view = await service.invitationBundleApplication(link.invitationId);
      expect(view.hasLocalChanges, isTrue);
      expect(view.canApplyCancellation, isFalse);
      await expectLater(
        service.applyInvitationBundleCancellation(command(view)),
        failure(CalendarFailureCode.dependencyConflict),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session))
            .single
            .timingOverrides!
            .singles
            .single
            .cancelled,
        isTrue,
      );
      expect(await CalendarInvitationApplicationRecord.db.count(session), 0);
    });
    test('historical exact and semantic-duplicate REQUEST receipts survive a cancellation kind change', () async {
      final link = await seed();
      final initial = await receive(bundleBytes(), 'initial');
      final variant = Uint8List.fromList(
        utf8.encode(
          utf8
              .decode(bundleBytes())
              .replaceFirst('Synthetic//EN', 'Different//EN'),
        ),
      );
      final duplicate = await receive(variant, 'duplicate');
      expect(duplicate.outcome, CalendarInvitationOutcome.duplicate);
      await cancel(link);
      expect(
        (await receive(bundleBytes(), 'initial')).toJson(),
        initial.toJson(),
      );
      expect(
        (await receive(variant, 'duplicate')).toJson(),
        duplicate.toJson(),
      );
      expect(
        (await service.invitationBundleApplication(link.invitationId))
            .currentContent
            .status,
        CalendarEventStatus.cancelled,
      );
    });
    test('minimal cancellation rejects foreign roster and extra source metadata atomically', () async {
      await seed();
      final sources = await CalendarInvitationSourceRecord.db.count(session);
      for (final bytes in [
        bundleCancellationBytes(
          extra: 'ATTENDEE:mailto:foreign@example.invalid',
        ),
        bundleCancellationBytes(extra: 'SUMMARY:Not an accepted text edit'),
        bundleCancellationBytes(extra: 'CREATED:20200101T000000Z'),
      ]) {
        await expectLater(
          receive(bytes, 'bad-$sources'),
          failure(CalendarFailureCode.validation),
        );
        expect(await CalendarInvitationSourceRecord.db.count(session), sources);
      }
      await expectLater(
        receive(bundleCancellationBytes(recipient: 'bob'), 'wrong-recipient'),
        failure(CalendarFailureCode.accessDenied),
      );
    });
    test(
      'corrupt cancellation floor fails after its original body expires',
      () async {
        final link = await seed();
        await cancel(link);
        await expire();
        final row = (await CalendarInvitationApplicationRecord.db.find(session))
            .single;
        row.sequence = 12;
        await CalendarInvitationApplicationRecord.db.updateRow(session, row);
        await expectLater(
          service.invitationBundleApplication(link.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
        await expectLater(
          receive(bundleBytes(sequence: 14), 'reopen'),
          failure(CalendarFailureCode.unavailable),
        );
      },
    );
    for (final corrupt in ['fractional stamp', 'sequence overflow']) {
      test('pruned cancellation checkpoint rejects $corrupt', () async {
        final link = await seed();
        await cancel(link);
        await expire();
        final row = (await CalendarInvitationApplicationRecord.db.find(session))
            .single;
        if (corrupt == 'fractional stamp') {
          row.stamp = row.stamp.add(const Duration(microseconds: 1));
        } else {
          row.sequence = 2147483648;
        }
        await CalendarInvitationApplicationRecord.db.updateRow(session, row);
        await expectLater(
          service.invitationBundleApplication(link.invitationId),
          failure(CalendarFailureCode.unavailable),
        );
      });
    }
    test('missing pending cancellation body cannot be replaced by guessed version history', () async {
      final link = await seed();
      await receive(bundleCancellationBytes(), 'pending');
      await expire(keepMarker: true);
      await expectLater(
        receive(bundleBytes(sequence: 14), 'reopen'),
        failure(CalendarFailureCode.unavailable),
      );
      expect((await CalendarEventRecord.db.find(session)).single.revision, 1);
      // Once the unaccepted marker is pruned, only the surviving accepted REQUEST is authoritative.
      await expire();
      await receive(bundleBytes(sequence: 3), 'new-review');
      final entry = (await service.listInvitations()).single;
      final view = await service.invitationBundleApplication(entry.id);
      expect(view.canApply, isTrue);
      expect(view.eventId, link.eventId);
    });
    test(
      'cancellation and reopening retain private reminders and acknowledgement',
      () async {
        final link = await seed();
        final alarm = (await service.createPersonalAlarm(
          CalendarAlarmCreateRequest(
            parent: CalendarAlarmParent(
              kind: CalendarAlarmParentKind.event,
              id: link.eventId,
            ),
            definition: CalendarAlarmDefinition(
              absoluteUtc: DateTime.utc(2030),
            ),
          ),
        ))!;
        final time =
            ((await session.db.unsafeQuery(
                      "SELECT date_trunc('second',clock_timestamp())",
                    )).single.single
                    as DateTime)
                .toUtc();
        final action = await CalendarAlarmActionRecord.db.insertRow(
          session,
          CalendarAlarmActionRecord(
            alarmId: alarm.id,
            originalKey: 'item',
            revision: 1,
            acknowledgedAt: time,
            createdAt: time,
            updatedAt: time,
          ),
        );
        final saved = (await CalendarAlarmRecord.db.findById(
          session,
          alarm.id,
        ))!.toJson();
        await cancel(link);
        await receive(bundleBytes(sequence: 14), 'reopen');
        await service.applyInvitationBundleReopening(
          command(await service.invitationBundleApplication(link.invitationId)),
        );
        expect(
          (await CalendarAlarmRecord.db.findById(session, alarm.id))!.toJson(),
          saved,
        );
        expect(
          (await CalendarAlarmActionRecord.db.findById(
            session,
            action.id!,
          ))!.toJson(),
          action.toJson(),
        );
      },
    );
    test('accepted reminder is withdrawn on cancellation and never replayed by reopening', () async {
      final link = await seed();
      final now =
          ((await session.db.unsafeQuery(
                    "SELECT date_trunc('second',clock_timestamp())",
                  )).single.single
                  as DateTime)
              .toUtc();
      final parent = CalendarAlarmParent(
        kind: CalendarAlarmParentKind.event,
        id: link.eventId,
      );
      final alarm = (await service.createPersonalAlarm(
        CalendarAlarmCreateRequest(
          parent: parent,
          definition: CalendarAlarmDefinition(
            absoluteUtc: now.subtract(const Duration(minutes: 1)),
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
      expect(delivery.accepted, hasLength(1));
      final intent = delivery.accepted.values.single;
      expect(
        await CalendarModule.checkAlarmDelivery(session, intent),
        CalendarAlarmDeliveryCheck.eligible,
      );
      await cancel(link);
      expect(
        await CalendarModule.checkAlarmDelivery(session, intent),
        CalendarAlarmDeliveryCheck.withdrawn,
      );
      expect(
        await CalendarModule.projectAlarmNotification(session, intent),
        isNull,
      );
      await CalendarModule.runAlarmMaintenance(session);
      await receive(bundleBytes(sequence: 14), 'reopen');
      await service.applyInvitationBundleReopening(
        command(await service.invitationBundleApplication(link.invitationId)),
      );
      await CalendarModule.runAlarmMaintenance(session);
      expect(delivery.accepted, hasLength(1));
      expect(
        (await CalendarAlarmRecord.db.findById(session, alarm.id))!.armed,
        isTrue,
      );
    });
    test('current export rejects unrepresentable cancelled child state without changing retained source', () async {
      final link = await seed(explicitStatus: true);
      final before = (await CalendarEventDataRecord.db.find(session))
          .single
          .importBaseline!
          .canonicalValue;
      await cancel(link);
      await expectLater(
        service.exportEvents(
          CalendarEventExportRequest(
            calendarId: link.calendarId,
            expectedRevision: 1,
            selection: [
              CalendarEventExportSelection(
                eventId: link.eventId,
                expectedRevision: 2,
              ),
            ],
          ),
        ),
        failure(CalendarFailureCode.validation),
      );
      expect(
        (await CalendarEventDataRecord.db.find(session))
            .single
            .importBaseline!
            .canonicalValue,
        before,
      );
      await receive(
        Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes(sequence: 14))
                .replaceAll('SUMMARY:', 'STATUS:TENTATIVE\r\nSUMMARY:'),
          ),
        ),
        'reopen',
      );
      await service.applyInvitationBundleReopening(
        command(await service.invitationBundleApplication(link.invitationId)),
      );
      expect(
        (await service.exportEvents(
          CalendarEventExportRequest(
            calendarId: link.calendarId,
            expectedRevision: 1,
            selection: [
              CalendarEventExportSelection(
                eventId: link.eventId,
                expectedRevision: 3,
              ),
            ],
          ),
        )).lengthInBytes,
        greaterThan(0),
      );
    });
    test(
      'whole cancellation suppresses busy times and reopening restores them',
      () async {
        final calendar = (await service.create(createInput()))!;
        final bytes = Uint8List.fromList(
          utf8.encode(
            utf8
                .decode(bundleBytes())
                .replaceFirst(
                  'DTSTART:20300101T090000Z',
                  'DTSTART:20300101T090000Z\r\nDTEND:20300101T100000Z',
                ),
          ),
        );
        final received = await receive(bytes, 'initial');
        final link = await service.adoptInvitation(
          CalendarInvitationAdoptionRequest(
            invitationId: received.entryId,
            expectedRevision: 1,
            sourceId: received.sourceId,
            calendarId: calendar.calendarId,
            expectedCalendarRevision: 1,
          ),
        );
        final query = CalendarFreeBusyQuery(
          calendarId: calendar.calendarId,
          fromUtc: DateTime.utc(2030),
          untilUtc: DateTime.utc(2030, 1, 3),
        );
        expect(
          (await service.freeBusy(query)).periods
              .any((p) => p.kind == CalendarFreeBusyKind.busy),
          isTrue,
        );
        await cancel(link);
        final busy = await service.freeBusy(query);
        expect(busy.coverage, CalendarFreeBusyCoverage.complete);
        expect(
          busy.periods.every((p) => p.kind == CalendarFreeBusyKind.free),
          isTrue,
        );
        await receive(
          Uint8List.fromList(
            utf8.encode(
              utf8.decode(bytes).replaceFirst('SEQUENCE:2', 'SEQUENCE:14'),
            ),
          ),
          'reopen',
        );
        await service.applyInvitationBundleReopening(
          command(await service.invitationBundleApplication(link.invitationId)),
        );
        expect(
          (await service.freeBusy(query)).periods
              .any((p) => p.kind == CalendarFreeBusyKind.busy),
          isTrue,
        );
      },
    );
    test('cancellation does not make the parent deletable or recreate a deleted event', () async {
      final link = await seed();
      await receive(bundleCancellationBytes(), 'cancel');
      final input = command(
        await service.invitationBundleApplication(link.invitationId),
      );
      await service.applyInvitationBundleCancellation(input);
      await expectLater(
        service.delete(link.calendarId, 1),
        failure(CalendarFailureCode.dependencyConflict),
      );
      await service.deleteEvent(link.eventId, 2);
      await expectLater(
        service.applyInvitationBundleCancellation(input),
        failure(CalendarFailureCode.unavailable),
      );
      expect(await CalendarEventDataRecord.db.count(session), 0);
    });
  });
}
