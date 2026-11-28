import 'package:serverpod/serverpod.dart';
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart';
import 'package:serverpod_notifications_server/src/notification_work_store.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

Matcher fails(NotificationFailureCode code) => throwsA(
  isA<NotificationException>().having((e) => e.code, 'code', code),
);

void main() {
  withServerpod('generic durable notification delivery', (builder, endpoints) {
    late Session session;
    late Policy policy;
    late Source source;
    late Publication publication;
    late NotificationService service;
    late DateTime now;
    void install({NotificationOptions? options}) {
      NotificationModule.install(
        session.serverpod,
        policy: policy,
        sources: [source],
        publication: publication,
        options: options,
      );
      service = NotificationModule.service(session);
    }

    NotificationEnvelope envelope(String id, {String reference = 'pointer'}) =>
        NotificationEnvelope(
          scopeKey: 'synthetic:scope',
          recipient: NotificationRecipient('test', 'alice'),
          sourceNamespace: 'synthetic.reminder',
          sourceVersion: 1,
          requestId: id,
          reference: reference,
          dueAt: now.subtract(const Duration(seconds: 10)),
          expiresAt: now.add(const Duration(hours: 1)),
        );
    Future<NotificationDeliveryRecord> row(UuidValue id) async =>
        (await NotificationDeliveryRecord.db.findById(session, id))!;
    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = Policy();
      source = Source();
      publication = Publication();
      install();
      final raw =
          (await session.db.unsafeQuery('SELECT clock_timestamp()'))
                  .single
                  .single
              as DateTime;
      now = DateTime.fromMillisecondsSinceEpoch(
        raw.millisecondsSinceEpoch ~/ 1000 * 1000,
        isUtc: true,
      );
    });

    test(
      'generic producer accepts once and rejects changed request identity',
      () async {
        final e = envelope('one');
        final id = await NotificationModule.accept(session, e);
        expect(await NotificationModule.accept(session, e), id);
        await expectLater(
          NotificationModule.accept(
            session,
            envelope('one', reference: 'changed'),
          ),
          fails(NotificationFailureCode.conflict),
        );
        expect(await NotificationDeliveryRecord.db.count(session), 1);
        expect((await row(id)).sourceReference, 'pointer');
      },
    );

    test(
      'duplicate acceptance still checks current source authority',
      () async {
        final e = envelope('one');
        await NotificationModule.accept(session, e);
        source.verdict = NotificationVerdict.deny;
        await expectLater(
          NotificationModule.accept(session, e),
          fails(NotificationFailureCode.accessDenied),
        );
      },
    );

    test('final acceptance denial leaves no durable delivery', () async {
      source.finalVerdict = NotificationVerdict.deny;
      await expectLater(
        NotificationModule.accept(session, envelope('one')),
        fails(NotificationFailureCode.accessDenied),
      );
      expect(await NotificationDeliveryRecord.db.count(session), 0);
    });

    test(
      'retained recipient capacity rejects atomically but allows retry',
      () async {
        install(options: NotificationOptions(maxRetainedPerRecipient: 1));
        final e = envelope('one');
        final id = await NotificationModule.accept(session, e);
        expect(await NotificationModule.accept(session, e), id);
        await expectLater(
          NotificationModule.accept(session, envelope('two')),
          fails(NotificationFailureCode.limitExceeded),
        );
        expect(await NotificationDeliveryRecord.db.count(session), 1);
      },
    );

    test(
      'recovery projects current source text without copying it to storage',
      () async {
        await NotificationModule.accept(session, envelope('one'));
        expect(
          (await service.recover(pageSize: 10)).notifications.single.title,
          'Initial title',
        );
        source.title = 'Changed private title';
        expect(
          (await service.recover(pageSize: 10)).notifications.single.title,
          source.title,
        );
        final stored = (await NotificationDeliveryRecord.db.find(session))
            .single
            .toJson()
            .toString();
        expect(stored, isNot(contains(source.title)));
        source.verdict = NotificationVerdict.deny;
        expect((await service.recover(pageSize: 10)).notifications, isEmpty);
      },
    );

    test(
      'unavailable source fails the entire recovery instead of a partial page',
      () async {
        await NotificationModule.accept(session, envelope('one'));
        source.verdict = NotificationVerdict.unavailable;
        await expectLater(
          service.recover(pageSize: 10),
          fails(NotificationFailureCode.unavailable),
        );
      },
    );

    test('projection followed by final denial discloses no content', () async {
      await NotificationModule.accept(session, envelope('one'));
      source.finalVerdict = NotificationVerdict.deny;
      expect((await service.recover(pageSize: 10)).notifications, isEmpty);
    });

    test('cursor binds recipient, policy epoch and page size', () async {
      for (var n = 0; n < 3; n++) {
        await NotificationModule.accept(session, envelope('$n'));
      }
      final first = await service.recover(pageSize: 1);
      expect(first.nextCursor, isNotNull);
      final second = await service.recover(
        pageSize: 1,
        cursor: first.nextCursor,
      );
      expect(
        second.notifications.single.id,
        isNot(first.notifications.single.id),
      );
      await expectLater(
        service.recover(pageSize: 2, cursor: first.nextCursor),
        fails(NotificationFailureCode.invalidCursor),
      );
      policy.epoch = 'changed';
      await expectLater(
        service.recover(pageSize: 1, cursor: first.nextCursor),
        fails(NotificationFailureCode.invalidCursor),
      );
      policy.recipient = 'bob';
      expect((await service.recover(pageSize: 1)).notifications, isEmpty);
      await expectLater(
        service.recover(pageSize: 1, cursor: first.nextCursor),
        fails(NotificationFailureCode.invalidCursor),
      );
    });

    test('host final denial blocks recovery and subscription', () async {
      await NotificationModule.accept(session, envelope('one'));
      policy.verdict = NotificationVerdict.deny;
      await expectLater(
        service.recover(pageSize: 1),
        fails(NotificationFailureCode.accessDenied),
      );
      await expectLater(
        service.authorizeSubscription(),
        fails(NotificationFailureCode.accessDenied),
      );
    });

    test('publication failure retries the same stable ID', () async {
      final id = await NotificationModule.accept(session, envelope('one'));
      publication.available = false;
      await NotificationModule.runMaintenance(session);
      expect((await row(id)).state, NotificationDeliveryState.queued);
      expect((await row(id)).attemptCount, 1);
      final retry = await row(id);
      retry.nextAttemptAt = now.subtract(const Duration(seconds: 1));
      await NotificationDeliveryRecord.db.updateRow(session, retry);
      publication.available = true;
      await NotificationModule.runMaintenance(session);
      expect((await row(id)).state, NotificationDeliveryState.published);
      expect(publication.ids, [id, id]);
      expect((await service.recover(pageSize: 1)).notifications.single.id, id);
    });

    test(
      'source unavailability stays retryable; withdrawal is terminal',
      () async {
        final id = await NotificationModule.accept(session, envelope('one'));
        source.verdict = NotificationVerdict.unavailable;
        await NotificationModule.runMaintenance(session);
        expect((await row(id)).state, NotificationDeliveryState.queued);
        expect(publication.ids, isEmpty);
        final retry = await row(id);
        retry.nextAttemptAt = now.subtract(const Duration(seconds: 1));
        await NotificationDeliveryRecord.db.updateRow(session, retry);
        source.verdict = NotificationVerdict.deny;
        await NotificationModule.runMaintenance(session);
        expect((await row(id)).state, NotificationDeliveryState.suppressed);
        expect(publication.ids, isEmpty);
      },
    );

    test('expired work never publishes or recovers', () async {
      final id = await NotificationModule.accept(session, envelope('one'));
      final expired = await row(id);
      expired.expiresAt = now.subtract(const Duration(seconds: 1));
      await NotificationDeliveryRecord.db.updateRow(session, expired);
      // Immutable fingerprint corruption fails closed before transport too.
      await NotificationModule.runMaintenance(session);
      expect(publication.ids, isEmpty);
      expect((await service.recover(pageSize: 1)).notifications, isEmpty);
    });

    test(
      'lease claims are fenced and cannot be reclaimed before expiry',
      () async {
        await NotificationModule.accept(session, envelope('one'));
        final store = NotificationWorkStore(session, NotificationOptions());
        final lease = (await store.claim()).single;
        expect(await store.claim(), isEmpty);
        expect(
          NotificationWorkStore.owns(await row(lease.id!), lease, now),
          isTrue,
        );
        final stale = lease.copyWith(leaseFence: lease.leaseFence - 1);
        expect(
          NotificationWorkStore.owns(await row(lease.id!), stale, now),
          isFalse,
        );
        expect(
          NotificationWorkStore.owns(
            await row(lease.id!),
            lease,
            lease.leaseUntil!,
          ),
          isFalse,
        );
      },
    );

    test('pruning retains live published records and removes expired terminal references', () async {
      final id = await NotificationModule.accept(session, envelope('one'));
      await NotificationModule.runMaintenance(session);
      final old = await row(id);
      old.terminalAt = now.subtract(const Duration(days: 31));
      await NotificationDeliveryRecord.db.updateRow(session, old);
      final store = NotificationWorkStore(session, NotificationOptions());
      expect(await store.prune(), 0);
      old.expiresAt = now.subtract(const Duration(seconds: 1));
      await NotificationDeliveryRecord.db.updateRow(session, old);
      expect(await store.prune(), 1);
      expect(await NotificationDeliveryRecord.db.findById(session, id), isNull);
    });

    test('expired valid reference is rejected at acceptance and expires without transport', () async {
      final expired = NotificationEnvelope(
        scopeKey: 'synthetic:scope',
        recipient: NotificationRecipient('test', 'alice'),
        sourceNamespace: source.namespace,
        sourceVersion: 1,
        requestId: 'expired',
        reference: 'pointer',
        dueAt: now.subtract(const Duration(hours: 2)),
        expiresAt: now.subtract(const Duration(hours: 1)),
      );
      await expectLater(
        NotificationModule.accept(session, expired),
        fails(NotificationFailureCode.validation),
      );
      final inserted = await NotificationDeliveryRecord.db.insertRow(
        session,
        NotificationDeliveryRecord(
          scopeKey: expired.scopeKey,
          recipientNamespace: 'test',
          recipientKey: 'alice',
          sourceNamespace: source.namespace,
          sourceVersion: 1,
          sourceRequestId: expired.requestId,
          requestDigest: expired.digest,
          sourceReference: expired.reference,
          dueAt: expired.dueAt,
          expiresAt: expired.expiresAt,
          nextAttemptAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      );
      await NotificationModule.runMaintenance(session);
      expect(
        (await row(inserted.id!)).state,
        NotificationDeliveryState.expired,
      );
      expect(publication.ids, isEmpty);
    });

    test('source timeout fails closed without retaining a delivery', () async {
      source.delay = const Duration(milliseconds: 30);
      install(
        options: NotificationOptions(
          callbackTimeout: const Duration(milliseconds: 5),
        ),
      );
      await expectLater(
        NotificationModule.accept(session, envelope('one')),
        fails(NotificationFailureCode.unavailable),
      );
      expect(await NotificationDeliveryRecord.db.count(session), 0);
      await Future<void>.delayed(source.delay);
    });

    test(
      'corrupted immutable reference cannot be recovered as a new source',
      () async {
        final id = await NotificationModule.accept(session, envelope('one'));
        final corrupt = await row(id);
        corrupt.sourceReference = 'different-pointer';
        await NotificationDeliveryRecord.db.updateRow(session, corrupt);
        await expectLater(
          service.recover(pageSize: 1),
          fails(NotificationFailureCode.unavailable),
        );
      },
    );

    test('coordinated requirement rejects a fresh-check adapter', () {
      expect(
        () => install(
          options: NotificationOptions(
            requiredGuarantee: NotificationGuarantee.coordinated,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}

final class Policy implements NotificationHostPolicy {
  String epoch = 'one', recipient = 'alice';
  NotificationVerdict verdict = NotificationVerdict.allow;
  @override
  NotificationGuarantee get guarantee => NotificationGuarantee.freshCheck;
  @override
  Future<NotificationActor> resolveContext(Session session) async =>
      NotificationActor(
        principalId: session.authenticated!.userIdentifier,
        scopeKey: 'synthetic:scope',
        policyRevision: epoch,
        recipient: NotificationRecipient('test', recipient),
      );
  @override
  Future<NotificationVerdict> authorize(
    Session session,
    NotificationActor actor,
    NotificationPermission operation,
    Transaction transaction,
    NotificationPhase phase,
  ) async => verdict;
}

final class Source implements NotificationSourceAdapter {
  NotificationVerdict verdict = NotificationVerdict.allow;
  NotificationVerdict? finalVerdict;
  String title = 'Initial title';
  Duration delay = Duration.zero;
  @override
  String get namespace => 'synthetic.reminder';
  @override
  int get version => 1;
  @override
  NotificationGuarantee get guarantee => NotificationGuarantee.freshCheck;
  @override
  Future<NotificationVerdict> check(
    Session session,
    NotificationEnvelope envelope,
    NotificationSourceOperation operation,
    Transaction transaction,
    NotificationPhase phase,
  ) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return phase == NotificationPhase.finalCheck
        ? finalVerdict ?? verdict
        : verdict;
  }

  @override
  Future<NotificationContent?> project(
    Session session,
    NotificationEnvelope envelope,
    NotificationActor actor,
    Transaction transaction,
  ) async => NotificationContent(title: title);
}

final class Publication implements NotificationPublicationPort {
  bool available = true;
  final ids = <UuidValue>[];
  @override
  Future<bool> publish(
    Session session,
    UuidValue notificationId,
    NotificationEnvelope envelope,
  ) async {
    ids.add(notificationId);
    return available;
  }
}
