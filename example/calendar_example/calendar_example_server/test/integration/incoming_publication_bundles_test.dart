import 'dart:convert';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';
import 'package:test/test.dart';

import 'calendar_test.dart' show TestPolicy, createInput, failure;
import 'incoming_publications_test.dart' show IncomingPublicationHost;
import 'test_tools/serverpod_test_tools.dart';

String bundleWire({
  int master = 0,
  int child = 0,
  String title = 'Child',
  String hour = '11',
  bool omitChild = false,
  String? childOriginal,
}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic bundle//EN',
  'METHOD:PUBLISH',
  'BEGIN:VEVENT',
  'UID:information-bundle@example.invalid',
  'ORGANIZER:mailto:publisher@example.invalid',
  'DTSTAMP:20261113T070000Z',
  'SEQUENCE:$master',
  'DTSTART:20270328T090000Z',
  'DURATION:PT1H',
  'RRULE:FREQ=DAILY;COUNT=4',
  'SUMMARY:Master',
  'END:VEVENT',
  if (!omitChild) ...[
    'BEGIN:VEVENT',
    'UID:information-bundle@example.invalid',
    'ORGANIZER:mailto:publisher@example.invalid',
    'DTSTAMP:20261113T070000Z',
    'SEQUENCE:$child',
    'RECURRENCE-ID:${childOriginal ?? '20270329T090000Z'}',
    'DTSTART:20270329T${hour}0000Z',
    'DURATION:PT1H',
    'SUMMARY:$title',
    'END:VEVENT',
  ],
  'END:VCALENDAR',
  '',
].join('\r\n');

String cancellationWire(int sequence) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic bundle//EN',
  'METHOD:CANCEL',
  'BEGIN:VEVENT',
  'UID:information-bundle@example.invalid',
  'ORGANIZER:mailto:publisher@example.invalid',
  'DTSTAMP:20261113T080000Z',
  'SEQUENCE:$sequence',
  'STATUS:CANCELLED',
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');

void main() {
  withServerpod('complete incoming information bundles', (builder, endpoints) {
    late Session session;
    late CalendarService service;
    late IncomingPublicationHost host;
    late UuidValue calendarId;
    void install({CalendarIncomingPublicationOptions? options}) {
      CalendarModule.install(
        session.serverpod,
        policy: TestPolicy(),
        options: const CalendarModuleOptions(
          requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
        ),
        incomingPublications: CalendarIncomingPublicationRuntime(
          host: host,
          options: options,
        ),
      );
      service = CalendarModule.service(session);
    }

    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      host = IncomingPublicationHost();
      install();
      calendarId = (await service.create(createInput()))!.calendarId;
    });
    Future<CalendarIncomingPublicationIngressReceipt> receive(
      String source, {
      String? key,
    }) => CalendarModule.receiveIncomingPublication(
      session,
      CalendarIncomingPublicationDelivery(
        namespace: 'synthetic',
        deliveryKey: key ?? const Uuid().v4(),
        originReference: 'verified-publisher',
        bytes: Uint8List.fromList(utf8.encode(source)),
      ),
    );
    CalendarIncomingPublicationAddRequest addInput(
      CalendarIncomingPublicationIngressReceipt source,
    ) => CalendarIncomingPublicationAddRequest(
      entryId: source.entryId,
      sourceId: source.sourceId,
      expectedRevision: source.entryRevision,
      calendarId: calendarId,
      expectedCalendarRevision: 1,
      commandId: const Uuid().v4obj(),
    );
    CalendarIncomingPublicationApplyRequest applyInput(
      CalendarIncomingPublicationIngressReceipt source,
      int revision,
    ) => CalendarIncomingPublicationApplyRequest(
      entryId: source.entryId,
      sourceId: source.sourceId,
      expectedRevision: source.entryRevision,
      expectedEventRevision: revision,
      commandId: const Uuid().v4obj(),
    );

    test(
      'child-only update survives dedicated APIs and scalar guards',
      () async {
        final first = await receive(bundleWire());
        expect(
          (await service.incomingPublicationGet(first.entryId))
              .bundledPublication,
          isTrue,
        );
        final source = await service.incomingPublicationBundleSource(
          first.entryId,
          first.sourceId,
        );
        expect(source.componentVersions.map((v) => v.sequence), [0, 0]);
        await expectLater(
          service.incomingPublicationSource(first.entryId, first.sourceId),
          failure(CalendarFailureCode.validation),
        );
        await expectLater(
          service.incomingPublicationAdd(addInput(first)),
          failure(CalendarFailureCode.validation),
        );
        final request = addInput(first);
        final added = await service.incomingPublicationAddBundle(request);
        expect(
          (await service.incomingPublicationAddBundle(request)).eventId,
          added.eventId,
        );
        await expectLater(
          service.incomingPublicationLink(first.entryId),
          failure(CalendarFailureCode.validation),
        );
        final next = await receive(bundleWire(child: 1, hour: '12'));
        expect(next.outcome, CalendarIncomingPublicationOutcome.selected);
        final applied = await service.incomingPublicationApplyBundle(
          applyInput(next, added.eventRevision),
        );
        final link = (await service.incomingPublicationBundleLink(
          first.entryId,
        ))!;
        expect(link.link.eventRevision, applied.eventRevision);
        expect(link.link.hasLocalChanges, isFalse);
        expect(link.acceptedComponentVersions!.map((v) => v.sequence), [0, 1]);
      },
    );

    test('future timing components retain their typed range identity in storage and views', () async {
      String wire(int child) => bundleWire(child: child)
          .replaceFirst('RECURRENCE-ID:', 'RECURRENCE-ID;RANGE=THISANDFUTURE:');
      final first = await receive(wire(0));
      final added = await service.incomingPublicationAddBundle(addInput(first));
      final update = await receive(wire(1));
      await service.incomingPublicationApplyBundle(
        applyInput(update, added.eventRevision),
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(added.eventId),
      ))!;
      expect(data.timingOverrides!.future, hasLength(1));
      final versions = (await service.incomingPublicationBundleLink(
        first.entryId,
      ))!.acceptedComponentVersions!;
      expect(versions.last.isThisAndFuture, isTrue);
      expect(versions.last.originalStart!.start.day, 29);
      expect(versions.last.sequence, 1);
    });

    for (final profile in ['date', 'Europe/Stockholm', 'US/Eastern']) {
      test('$profile preserves original identity and zone through a child update', () async {
        String wire(int child) {
          var value = bundleWire(
            child: child,
            title: child == 0 ? 'Child' : 'Changed',
          );
          value = value
              .split('\r\n')
              .map((line) {
                if (!line.startsWith('DTSTART:') &&
                    !line.startsWith('RECURRENCE-ID:')) {
                  return line;
                }
                final parts = line.split(':');
                return profile == 'date'
                    ? '${parts.first};VALUE=DATE:${parts.last.substring(0, 8)}'
                    : '${parts.first};TZID=$profile:${parts.last.substring(0, parts.last.length - 1)}';
              })
              .join('\r\n');
          if (profile == 'date') {
            return value.replaceAll('DURATION:PT1H', 'DURATION:P1D');
          }
          final zone = utf8
              .decode(
                serializeIcalendarSyntax(
                  IcalendarSyntaxDocument([createIcalendarTimeZone(profile)]),
                ),
              )
              .trimRight();
          return value.replaceFirst('BEGIN:VEVENT', '$zone\r\nBEGIN:VEVENT');
        }

        final first = await receive(wire(0));
        final added = await service.incomingPublicationAddBundle(
          addInput(first),
        );
        final update = await receive(wire(1));
        await service.incomingPublicationApplyBundle(
          applyInput(update, added.eventRevision),
        );
        final link = (await service.incomingPublicationBundleLink(
          first.entryId,
        ))!;
        final original = link.acceptedComponentVersions!.last.originalStart!;
        expect(
          original.kind,
          profile == 'date'
              ? CalendarEventTimeKind.date
              : CalendarEventTimeKind.zoned,
        );
        expect(original.zoneId, profile == 'date' ? isNull : profile);
        expect(original.start.day, 29);
        expect(link.link.hasLocalChanges, isFalse);
      });
    }

    test('PERIOD additions stay in the accepted baseline through lifecycle', () async {
      String wire(
        int master,
        int child,
      ) => bundleWire(master: master, child: child).replaceFirst(
        'RRULE:FREQ=DAILY;COUNT=4',
        'RRULE:FREQ=DAILY;COUNT=4\r\nRDATE;VALUE=PERIOD:20270331T090000Z/PT2H',
      );
      final first = await receive(wire(0, 0));
      final added = await service.incomingPublicationAddBundle(addInput(first));
      final cancel = await receive(cancellationWire(2));
      final cancelled = await service.incomingPublicationApplyBundle(
        applyInput(cancel, added.eventRevision),
      );
      final data = (await CalendarEventDataRecord.db.findFirstRow(
        session,
        where: (t) => t.eventId.equals(added.eventId),
      ))!;
      expect(data.content.periods, hasLength(1));
      final reopen = await receive(wire(3, 3));
      await service.incomingPublicationApplyBundle(
        applyInput(reopen, cancelled.eventRevision),
      );
      expect(
        (await service.incomingPublicationBundleLink(first.entryId))!
            .link
            .hasLocalChanges,
        isFalse,
      );
    });

    for (final changed in [
      () => bundleWire(child: 0, hour: '12'),
      () => bundleWire(master: 2, omitChild: true),
      () => bundleWire(master: 2, child: 2, childOriginal: '20270330T090000Z'),
    ]) {
      test(
        'incompatible/tied changed packet rejects without a new source',
        () async {
          final first = await receive(bundleWire(child: 1));
          await expectLater(
            receive(changed()),
            failure(CalendarFailureCode.validation),
          );
          final entry = await service.incomingPublicationGet(first.entryId);
          expect(entry.sourceId, first.sourceId);
          expect(entry.revision, first.entryRevision);
        },
      );
    }

    test(
      'unapplied sender update cannot replace accepted child on cancellation',
      () async {
        final first = await receive(bundleWire());
        final added = await service.incomingPublicationAddBundle(
          addInput(first),
        );
        final before = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(added.eventId),
        ))!;
        await receive(bundleWire(child: 3, hour: '14'));
        await expectLater(
          receive(cancellationWire(3)),
          failure(CalendarFailureCode.validation),
        );
        final cancel = await receive(cancellationWire(4));
        final cancelled = await service.incomingPublicationApplyBundle(
          applyInput(cancel, added.eventRevision),
        );
        final after = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(added.eventId),
        ))!;
        expect(
          after.timingOverrides!.toJson(),
          before.timingOverrides!.toJson(),
        );
        expect(after.importBaseline!.toJson(), before.importBaseline!.toJson());
        expect(after.content.status, CalendarEventStatus.cancelled);
        final link = (await service.incomingPublicationBundleLink(
          first.entryId,
        ))!;
        expect(link.acceptedComponentVersions!.map((v) => v.sequence), [0, 0]);
        expect(link.acceptedCancellationVersion!.sequence, 4);
        final reopen = await receive(
          bundleWire(master: 5, child: 4, hour: '15'),
        );
        await service.incomingPublicationApplyBundle(
          applyInput(reopen, cancelled.eventRevision),
        );
        expect(
          (await service.incomingPublicationBundleLink(first.entryId))!
              .link
              .hasLocalChanges,
          isFalse,
        );
      },
    );

    for (final operation in [
      CalendarIncomingPublicationOperation.receiveBundle,
      CalendarIncomingPublicationOperation.readBundleSource,
      CalendarIncomingPublicationOperation.readBundleLink,
      CalendarIncomingPublicationOperation.adoptBundle,
      CalendarIncomingPublicationOperation.applyBundleUpdate,
      CalendarIncomingPublicationOperation.receiveBundleCancellation,
      CalendarIncomingPublicationOperation.applyBundleCancellation,
      CalendarIncomingPublicationOperation.reopenBundle,
    ]) {
      test('$operation remains an independent permission', () async {
        if (operation == CalendarIncomingPublicationOperation.receiveBundle) {
          host.denied.add(operation);
          await expectLater(
            receive(bundleWire()),
            failure(CalendarFailureCode.accessDenied),
          );
          return;
        }
        final first = await receive(bundleWire());
        if (operation ==
            CalendarIncomingPublicationOperation.readBundleSource) {
          host.denied.add(operation);
          await expectLater(
            service.incomingPublicationBundleSource(
              first.entryId,
              first.sourceId,
            ),
            failure(CalendarFailureCode.accessDenied),
          );
          return;
        }
        if (operation == CalendarIncomingPublicationOperation.adoptBundle) {
          host.denied.add(operation);
          await expectLater(
            service.incomingPublicationAddBundle(addInput(first)),
            failure(CalendarFailureCode.accessDenied),
          );
          expect(
            await service.incomingPublicationBundleLink(first.entryId),
            isNull,
          );
          return;
        }
        final added = await service.incomingPublicationAddBundle(
          addInput(first),
        );
        if (operation == CalendarIncomingPublicationOperation.readBundleLink) {
          host.denied.add(operation);
          await expectLater(
            service.incomingPublicationBundleLink(first.entryId),
            failure(CalendarFailureCode.accessDenied),
          );
          return;
        }
        if (operation ==
            CalendarIncomingPublicationOperation.applyBundleUpdate) {
          final next = await receive(bundleWire(child: 1));
          host.denied.add(operation);
          await expectLater(
            service.incomingPublicationApplyBundle(
              applyInput(next, added.eventRevision),
            ),
            failure(CalendarFailureCode.accessDenied),
          );
        } else if (operation ==
            CalendarIncomingPublicationOperation.receiveBundleCancellation) {
          host.denied.add(operation);
          await expectLater(
            receive(cancellationWire(2)),
            failure(CalendarFailureCode.accessDenied),
          );
        } else {
          final cancel = await receive(cancellationWire(2));
          if (operation ==
              CalendarIncomingPublicationOperation.applyBundleCancellation) {
            host.denied.add(operation);
            await expectLater(
              service.incomingPublicationApplyBundle(
                applyInput(cancel, added.eventRevision),
              ),
              failure(CalendarFailureCode.accessDenied),
            );
          } else {
            final cancelled = await service.incomingPublicationApplyBundle(
              applyInput(cancel, added.eventRevision),
            );
            final next = await receive(bundleWire(master: 3, child: 3));
            host.denied.add(operation);
            await expectLater(
              service.incomingPublicationApplyBundle(
                applyInput(next, cancelled.eventRevision),
              ),
              failure(CalendarFailureCode.accessDenied),
            );
          }
        }
      });
    }

    test(
      'duplicate envelope does not reactivate dismissal or advance the vector',
      () async {
        final first = await receive(bundleWire(), key: 'initial');
        await service.incomingPublicationDismiss(
          first.entryId,
          first.entryRevision,
        );
        final dismissed = await service.incomingPublicationGet(first.entryId);
        final duplicate = await receive(
          bundleWire().replaceFirst('Synthetic bundle', 'Different envelope'),
        );
        expect(duplicate.outcome, CalendarIncomingPublicationOutcome.duplicate);
        final after = await service.incomingPublicationGet(first.entryId);
        expect(after.revision, dismissed.revision);
        expect(after.dismissedAt, dismissed.dismissedAt);
        await receive(bundleWire(child: 1));
        final retry = await receive(bundleWire(), key: 'initial');
        expect(retry.id, first.id);
        expect(
          (await service.incomingPublicationGet(first.entryId)).revision,
          dismissed.revision + 1,
        );
      },
    );

    test(
      'local master edits block complete updates without dropping exceptions',
      () async {
        final first = await receive(bundleWire());
        final added = await service.incomingPublicationAddBundle(
          addInput(first),
        );
        final data = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(added.eventId),
        ))!;
        await service.updateEvent(
          CalendarEventUpdateRequest(
            eventId: added.eventId,
            expectedRevision: added.eventRevision,
            content: data.content.copyWith(summary: 'Private draft'),
          ),
        );
        final update = await receive(bundleWire(child: 1));
        await expectLater(
          service.incomingPublicationApplyBundle(applyInput(update, 2)),
          failure(CalendarFailureCode.dependencyConflict),
        );
        final after = (await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(added.eventId),
        ))!;
        expect(after.content.summary, 'Private draft');
        expect(after.timingOverrides!.toJson(), data.timingOverrides!.toJson());
      },
    );

    test('deleted link preserves profile and creation retry without recreating data', () async {
      final first = await receive(bundleWire());
      final request = addInput(first);
      final added = await service.incomingPublicationAddBundle(request);
      await service.deleteEvent(added.eventId, added.eventRevision);
      final link = (await service.incomingPublicationBundleLink(
        first.entryId,
      ))!;
      expect(link.link.deleted, isTrue);
      expect(link.link.bundledPublication, isTrue);
      expect(link.acceptedComponentVersions, isNull);
      expect(link.acceptedSourceUnavailable, isTrue);
      expect(
        (await service.incomingPublicationAddBundle(request)).eventId,
        added.eventId,
      );
      expect(
        await CalendarEventDataRecord.db.findFirstRow(
          session,
          where: (t) => t.eventId.equals(added.eventId),
        ),
        isNull,
      );
      await expectLater(
        service.incomingPublicationAdd(addInput(first)),
        failure(CalendarFailureCode.validation),
      );
    });

    test(
      'source capacity exhaustion rolls back the complete update and receipt',
      () async {
        final first = await receive(bundleWire());
        install(
          options: CalendarIncomingPublicationOptions(maxSourcesPerEntry: 1),
        );
        await expectLater(
          receive(bundleWire(child: 1)),
          failure(CalendarFailureCode.limitExceeded),
        );
        expect(
          (await service.incomingPublicationGet(first.entryId)).revision,
          first.entryRevision,
        );
        expect(
          await CalendarIncomingPublicationSourceRecord.db.count(session),
          1,
        );
        expect(
          await CalendarIncomingPublicationReceiptRecord.db.count(session),
          1,
        );
      },
    );

    test('missing pending vector proof is unavailable rather than a scalar fallback', () async {
      final first = await receive(bundleWire());
      final row = (await CalendarIncomingPublicationSourceRecord.db.findById(
        session,
        first.sourceId,
      ))!;
      row.normalizedSource = null;
      await CalendarIncomingPublicationSourceRecord.db.updateRow(session, row);
      await expectLater(
        receive(bundleWire(child: 1)),
        failure(CalendarFailureCode.unavailable),
      );
      expect(
        await CalendarIncomingPublicationSourceRecord.db.count(session),
        1,
      );
    });

    test('pruning retains both full cancellation bases and their independent child versions', () async {
      final first = await receive(bundleWire());
      final added = await service.incomingPublicationAddBundle(addInput(first));
      final pending = await receive(bundleWire(child: 3, hour: '14'));
      final cancel = await receive(cancellationWire(4));
      await service.incomingPublicationApplyBundle(
        applyInput(cancel, added.eventRevision),
      );
      for (final source
          in await CalendarIncomingPublicationSourceRecord.db.find(session)) {
        source.inactiveAt = DateTime.utc(2000);
        await CalendarIncomingPublicationSourceRecord.db.updateRow(
          session,
          source,
        );
      }
      for (final receipt
          in await CalendarIncomingPublicationReceiptRecord.db.find(session)) {
        receipt.expiresAt = DateTime.utc(2000);
        await CalendarIncomingPublicationReceiptRecord.db.updateRow(
          session,
          receipt,
        );
      }
      await CalendarModule.runIncomingPublicationMaintenance(session);
      expect(
        await CalendarIncomingPublicationReceiptRecord.db.count(session),
        0,
      );
      expect(
        await CalendarIncomingPublicationSourceRecord.db.count(session),
        3,
      );
      expect(
        (await service.incomingPublicationBundleSource(
          cancel.entryId,
          cancel.sourceId,
        )).source.basisSourceId,
        pending.sourceId,
      );
      final link = (await service.incomingPublicationBundleLink(
        first.entryId,
      ))!;
      expect(link.acceptedComponentVersions!.map((v) => v.sequence), [0, 0]);
      expect(link.acceptedCancellationVersion!.sequence, 4);
      expect(link.link.hasLocalChanges, isFalse);
    });

    test(
      'source denial in final phase rolls back child-only admission',
      () async {
        final first = await receive(bundleWire());
        host.onCheck = (context, phase) {
          if (phase == CalendarAuthorizationPhase.finalWrite &&
              context.operation ==
                  CalendarIncomingPublicationOperation.readBundleSource) {
            if (context.sourceId == first.sourceId) {
              host.denied.add(
                CalendarIncomingPublicationOperation.readBundleSource,
              );
            }
          }
        };
        await expectLater(
          receive(bundleWire(child: 1)),
          failure(CalendarFailureCode.accessDenied),
        );
        host.onCheck = null;
        host.denied.clear();
        expect(
          (await service.incomingPublicationGet(first.entryId)).sourceId,
          first.sourceId,
        );
      },
    );
  });
}
