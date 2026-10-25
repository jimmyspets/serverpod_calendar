import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as cal;
import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart'
    as feed;
import 'package:test/test.dart';

import 'calendar_test.dart' as fixtures;
import 'test_tools/serverpod_test_tools.dart';

Matcher failed(feed.CalendarFeedFailureCode code) => throwsA(
  isA<feed.CalendarFeedException>().having((e) => e.code, 'code', code),
);

final class FeedPolicy
    implements feed.CalendarFeedHostPolicy, cal.CalendarPublicationPolicy {
  final denied = <feed.CalendarFeedOperation>{};
  final hidden = <UuidValue>{};
  bool finalDeny = false,
      publicationAllowed = true,
      publicationFinalDeny = false;
  String epoch = 'feed-test-v1';
  void Function()? finalAction;
  feed.CalendarFeedPolicyState? proposed;
  final publicationRequests = <cal.CalendarPublicationRequest>[];
  cal.CalendarAuthorizationGuarantee capability =
      cal.CalendarAuthorizationGuarantee.freshCheck;
  @override
  cal.CalendarAuthorizationGuarantee get guarantee => capability;
  @override
  Future<feed.CalendarFeedHostContext> resolveContext(Session session) async {
    final actor = session.authenticated!.userIdentifier;
    return feed.CalendarFeedHostContext(
      actor: actor,
      scopeKey: 'test:$actor',
      policyRevision: epoch,
      authorityReference: 'reference:$actor',
    );
  }

  @override
  Future<bool> authorize(
    Session session,
    feed.CalendarFeedHostContext context,
    feed.CalendarFeedOperation operation,
    Transaction transaction, {
    feed.CalendarFeedPolicyState? current,
    feed.CalendarFeedPolicyState? proposed,
    required bool finalCheck,
  }) async {
    this.proposed = proposed;
    if (finalCheck) finalAction?.call();
    return !denied.contains(operation) &&
        !(finalCheck && finalDeny) &&
        !(operation == feed.CalendarFeedOperation.read &&
            hidden.contains(current?.id));
  }

  @override
  Future<bool> authorizePublication(
    Session session,
    cal.CalendarPublicationRequest request,
    Transaction transaction, {
    required bool finalCheck,
  }) async {
    publicationRequests.add(request);
    return publicationAllowed && !(finalCheck && publicationFinalDeny);
  }
}

void main() {
  withServerpod('optional feed management and publication boundary', (
    builder,
    endpoints,
  ) {
    late Session session;
    late cal.CalendarService calendars;
    late feed.CalendarFeedService feeds;
    late FeedPolicy policy;
    late UuidValue calendar;
    setUp(() async {
      session = builder
          .copyWith(
            authentication: AuthenticationOverride.authenticationInfo(
              'alice',
              {},
            ),
          )
          .build();
      policy = FeedPolicy();
      const dependencies = feed.CalendarFeedDependencies();
      cal.CalendarModule.install(
        session.serverpod,
        policy: fixtures.TestPolicy(),
        publicationPolicy: policy,
        dependencies: [dependencies],
        options: const cal.CalendarModuleOptions(
          requiredWriteGuarantee: cal.CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      feed.CalendarFeedModule.install(
        session.serverpod,
        policy: policy,
        dependencies: dependencies,
        options: feed.CalendarFeedOptions(
          publicBaseUri: Uri.parse('https://subscriptions.example.invalid/'),
          requiredGuarantee: cal.CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      calendars = cal.CalendarModule.service(session);
      feeds = feed.CalendarFeedModule.service(session);
      calendar = (await calendars.create(fixtures.createInput()))!.calendarId;
    });
    feed.CalendarFeedSettings settings([List<UuidValue>? ids]) =>
        feed.CalendarFeedSettings(
          displayName: '  Synthetic feed  ',
          calendarIds: ids ?? [calendar],
          protocolMetadata: cal.CalendarProtocolMetadata(
            names: [cal.CalendarTextVariant(value: 'Published name')],
            descriptions: [],
          ),
        );

    test('creates separate stable presentation identity and actual selection context', () async {
      final value = await feeds.create(settings());
      expect(value.displayName, 'Synthetic feed');
      expect(value.protocolMetadata!.names.single.value, 'Published name');
      expect(value.protocolUid, isNot(value.id));
      expect(value.protocolModifiedAt.microsecond, 0);
      expect(value.protocolModifiedAt.millisecond, 0);
      expect(value.calendarIds, [calendar]);
      expect(
        policy.publicationRequests.every(
          (r) =>
              r.selecting &&
              r.scopeKey == 'test:alice' &&
              r.authorityReference == 'reference:alice' &&
              r.sources.single.calendar.calendarId == calendar,
        ),
        isTrue,
      );
      final renamed = await feeds.update(
        value.id,
        1,
        settings().copyWith(displayName: 'Renamed'),
      );
      expect(renamed.revision, 2);
      expect(renamed.protocolUid, value.protocolUid);
      expect(renamed.protocolModifiedAt, value.protocolModifiedAt);
      expect(
        (await calendars.get(
          calendar,
          cal.CalendarFieldGroup.values,
        )).displayName,
        'Calendar',
      );
    });
    test(
      'separate create and publication rights; final denial is atomic',
      () async {
        policy.denied.add(feed.CalendarFeedOperation.create);
        await expectLater(
          feeds.create(settings()),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        policy.denied.clear();
        policy.publicationAllowed = false;
        await expectLater(
          feeds.create(settings()),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        policy.publicationAllowed = true;
        policy.publicationFinalDeny = true;
        await expectLater(
          feeds.create(settings()),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        policy.publicationFinalDeny = false;
        policy.finalDeny = true;
        await expectLater(
          feeds.create(settings()),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        expect(await feed.CalendarFeedIdentityRecord.db.count(session), 0);
        expect(await feed.CalendarFeedDataRecord.db.count(session), 0);
        expect(await feed.CalendarFeedSelectionRecord.db.count(session), 0);
      },
    );
    test(
      'context epoch changes during final policy reject the entire write',
      () async {
        policy.finalAction = () => policy.epoch = 'changed';
        await expectLater(
          feeds.create(settings()),
          failed(feed.CalendarFeedFailureCode.unavailable),
        );
        expect(await feed.CalendarFeedIdentityRecord.db.count(session), 0);
      },
    );
    test(
      'stale settings and invalid/foreign selections preserve current state',
      () async {
        final value = await feeds.create(settings());
        await expectLater(
          feeds.update(value.id, 2, settings()),
          failed(feed.CalendarFeedFailureCode.staleRevision),
        );
        await expectLater(
          feeds.update(value.id, 1, settings([calendar, calendar])),
          failed(feed.CalendarFeedFailureCode.validation),
        );
        final bob = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        final foreign = (await cal.CalendarModule.service(
          bob,
        ).create(fixtures.createInput()))!.calendarId;
        await expectLater(
          feeds.update(value.id, 1, settings([foreign])),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        expect((await feeds.read(value.id)).revision, 1);
        expect((await feeds.read(value.id)).calendarIds, [calendar]);
        await bob.close();
      },
    );
    test(
      'read filtering and cross-scope access disclose no hidden feed',
      () async {
        final visible = await feeds.create(settings());
        final hidden = await feeds.create(settings());
        policy.hidden.add(hidden.id);
        expect((await feeds.list()).map((v) => v.id), [visible.id]);
        await expectLater(
          feeds.read(hidden.id),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        final bob = builder
            .copyWith(
              authentication: AuthenticationOverride.authenticationInfo(
                'bob',
                {},
              ),
            )
            .build();
        await expectLater(
          feed.CalendarFeedModule.service(bob).read(visible.id),
          failed(feed.CalendarFeedFailureCode.accessDenied),
        );
        await bob.close();
      },
    );
    test(
      'credentials disclose URL once and store only a versioned digest',
      () async {
        final value = await feeds.create(settings());
        final issued = await feeds.createCredential(
          value.id,
          1,
          '  Synthetic subscriber  ',
        );
        final token = Uri.parse(issued.url).pathSegments.last
            .replaceFirst('.ics', '');
        expect(base64Url.decode('$token='), hasLength(32));
        final row = (await feed.CalendarFeedCredentialRecord.db.find(session))
            .single;
        expect(row.digestVersion, 1);
        expect(row.digest, sha256.convert(utf8.encode(token)).toString());
        expect(jsonEncode(row.toJson()), isNot(contains(token)));
        expect(
          jsonEncode((await feeds.credentials(value.id)).single.toJson()),
          isNot(contains(token)),
        );
        expect(issued.credential.label, 'Synthetic subscriber');
        expect(
          policy.proposed,
          isNull,
        ); // credential listing has no proposed write
        expect((await feeds.read(value.id)).revision, 2);
        expect(
          (await feeds.read(value.id)).protocolModifiedAt,
          value.protocolModifiedAt,
        );
      },
    );
    test('independent credential gates, stale revisions and atomic final rejection', () async {
      final value = await feeds.create(settings());
      policy.denied.add(feed.CalendarFeedOperation.createCredential);
      await expectLater(
        feeds.createCredential(value.id, 1, null),
        failed(feed.CalendarFeedFailureCode.accessDenied),
      );
      policy.denied.clear();
      policy.finalDeny = true;
      await expectLater(
        feeds.createCredential(value.id, 1, null),
        failed(feed.CalendarFeedFailureCode.accessDenied),
      );
      expect(await feed.CalendarFeedCredentialRecord.db.count(session), 0);
      policy.finalDeny = false;
      final issued = await feeds.createCredential(value.id, 1, null);
      await expectLater(
        feeds.revokeCredential(value.id, 1, issued.credential.id, 1),
        failed(feed.CalendarFeedFailureCode.staleRevision),
      );
      policy.denied.add(feed.CalendarFeedOperation.revokeCredential);
      await expectLater(
        feeds.revokeCredential(value.id, 2, issued.credential.id, 1),
        failed(feed.CalendarFeedFailureCode.accessDenied),
      );
      policy.denied.clear();
      await feeds.revokeCredential(value.id, 2, issued.credential.id, 1);
      expect((await feeds.credentials(value.id)).single.revokedAt, isNotNull);
      expect((await feeds.credentials(value.id)).single.revision, 2);
      expect(
        (await feeds.read(value.id)).protocolModifiedAt,
        value.protocolModifiedAt,
      );
    });
    test('retained credential cap waits for eligible pruning without evicting active rows', () async {
      final value = await feeds.create(settings());
      final now = DateTime.now().toUtc();
      final rows = await feed.CalendarFeedCredentialRecord.db.insert(session, [
        for (var i = 0; i < 64; i++)
          feed.CalendarFeedCredentialRecord(
            feedId: value.id,
            digestVersion: 1,
            digest: sha256
                .convert(utf8.encode('synthetic:${value.id}:$i'))
                .toString(),
            revision: 2,
            createdAt: now,
            revokedAt: now,
          ),
      ]);
      await expectLater(
        feeds.createCredential(value.id, 1, null),
        failed(feed.CalendarFeedFailureCode.limitExceeded),
      );
      expect(await feeds.credentials(value.id), hasLength(64));
      await feed.CalendarFeedCredentialRecord.db.updateRow(
        session,
        rows.first.copyWith(revokedAt: DateTime.utc(2000)),
      );
      await feed.CalendarFeedModule.runMaintenance(session);
      await feeds.createCredential(value.id, 1, null);
      expect(await feeds.credentials(value.id), hasLength(64));
      expect(
        (await feeds.credentials(value.id)).where((c) => c.revokedAt == null),
        hasLength(1),
      );
    });
    test('active feed cap excludes content-free deleted markers', () async {
      final values = <feed.CalendarFeedView>[];
      for (var i = 0; i < 64; i++) {
        values.add(await feeds.create(settings()));
      }
      await expectLater(
        feeds.create(settings()),
        failed(feed.CalendarFeedFailureCode.limitExceeded),
      );
      await feeds.delete(values.first.id, 1);
      await feeds.create(settings());
      expect(await feeds.list(), hasLength(64));
      expect(await feed.CalendarFeedIdentityRecord.db.count(session), 65);
    });
    test('coordinated installation requires both host and publication capabilities', () {
      const dependencies = feed.CalendarFeedDependencies();
      final options = feed.CalendarFeedOptions(
        publicBaseUri: Uri.parse('https://subscriptions.example.invalid/'),
        requiredGuarantee: cal.CalendarAuthorizationGuarantee.coordinated,
      );
      expect(
        () => feed.CalendarFeedModule.install(
          session.serverpod,
          policy: policy,
          dependencies: dependencies,
          options: options,
        ),
        throwsArgumentError,
      );
      final coordinated = FeedPolicy()
        ..capability = cal.CalendarAuthorizationGuarantee.coordinated;
      expect(
        () => feed.CalendarFeedModule.install(
          session.serverpod,
          policy: coordinated,
          dependencies: dependencies,
          options: options,
        ),
        throwsArgumentError,
      );
      cal.CalendarModule.install(
        session.serverpod,
        policy: fixtures.TestPolicy(),
        publicationPolicy: coordinated,
        dependencies: [dependencies],
        options: const cal.CalendarModuleOptions(
          requiredWriteGuarantee: cal.CalendarAuthorizationGuarantee.freshCheck,
        ),
      );
      expect(
        () => feed.CalendarFeedModule.install(
          session.serverpod,
          policy: policy,
          dependencies: dependencies,
          options: options,
        ),
        throwsArgumentError,
      );
      feed.CalendarFeedModule.install(
        session.serverpod,
        policy: coordinated,
        dependencies: dependencies,
        options: options,
      );
    });
    test(
      'native core runs without feed installation or a publication policy',
      () async {
        cal.CalendarModule.install(
          session.serverpod,
          policy: fixtures.TestPolicy(),
          options: const cal.CalendarModuleOptions(
            requiredWriteGuarantee:
                cal.CalendarAuthorizationGuarantee.freshCheck,
          ),
        );
        final receipt = await cal.CalendarModule.service(session)
            .create(fixtures.createInput('No feeds installed'));
        expect(receipt, isNotNull);
        expect(
          () => feed.CalendarFeedModule.install(
            session.serverpod,
            policy: policy,
            dependencies: const feed.CalendarFeedDependencies(),
            options: feed.CalendarFeedOptions(
              publicBaseUri: Uri.parse(
                'https://subscriptions.example.invalid/',
              ),
              requiredGuarantee: cal.CalendarAuthorizationGuarantee.freshCheck,
            ),
          ),
          throwsArgumentError,
        );
        await expectLater(
          cal.CalendarModule.publicationTransaction(
            session,
            'test:alice',
            (port) async => true,
          ),
          fixtures.failure(cal.CalendarFailureCode.unavailable),
        );
      },
    );
    test('active URL cap rejects atomically and revocation releases active capacity', () async {
      final value = await feeds.create(settings());
      for (var i = 0; i < 16; i++) {
        await feeds.createCredential(value.id, i + 1, null);
      }
      await expectLater(
        feeds.createCredential(value.id, 17, null),
        failed(feed.CalendarFeedFailureCode.limitExceeded),
      );
      final credential = (await feeds.credentials(value.id)).first;
      await feeds.revokeCredential(
        value.id,
        17,
        credential.id,
        credential.revision,
      );
      await feeds.createCredential(value.id, 18, 'Replacement');
      expect(
        (await feeds.credentials(value.id)).where((v) => v.revokedAt == null),
        hasLength(16),
      );
    });
    test(
      'selection blocks calendar deletion; feed deletion scrubs everything',
      () async {
        final value = await feeds.create(settings());
        await feeds.createCredential(value.id, 1, null);
        await expectLater(
          calendars.delete(calendar, 1),
          fixtures.failure(cal.CalendarFailureCode.dependencyConflict),
        );
        await feeds.delete(value.id, 2);
        expect(await feed.CalendarFeedDataRecord.db.count(session), 0);
        expect(await feed.CalendarFeedSelectionRecord.db.count(session), 0);
        expect(await feed.CalendarFeedCredentialRecord.db.count(session), 0);
        final marker = (await feed.CalendarFeedIdentityRecord.db.find(session))
            .single;
        expect(marker.deletedAt, isNotNull);
        expect(marker.revision, 3);
        expect((await feeds.list()), isEmpty);
        await calendars.delete(calendar, 1);
      },
    );
    test('publication port final denial returns no bytes and closes its transaction', () async {
      await calendars.createEvent(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: fixtures.eventInput(summary: 'Published'),
        ),
      );
      cal.CalendarPublicationTransaction? saved;
      final bytes = await cal.CalendarModule.publicationTransaction(
        session,
        'test:alice',
        (port) async {
          saved = port;
          return port.eventBytes([calendar], 'reference:alice');
        },
      );
      expect(utf8.decode(bytes), contains('SUMMARY:Published'));
      expect(() => saved!.transaction, throwsStateError);
      policy.publicationFinalDeny = true;
      await expectLater(
        cal.CalendarModule.publicationTransaction(
          session,
          'test:alice',
          (port) => port.eventBytes([calendar], 'reference:alice'),
        ),
        fixtures.failure(cal.CalendarFailureCode.accessDenied),
      );
    });
    test('event changes track selected feeds; native no-op and unrelated calendars do not', () async {
      final value = await feeds.create(settings());
      final record = (await feed.CalendarFeedDataRecord.db.find(session))
          .single;
      final old = DateTime.utc(2000);
      await feed.CalendarFeedDataRecord.db.updateRow(
        session,
        record.copyWith(protocolModifiedAt: old),
      );
      final other = (await calendars.create(fixtures.createInput('Other')))!
          .calendarId;
      await calendars.createEvent(
        cal.CalendarEventCreateRequest(
          calendarId: other,
          content: fixtures.eventInput(),
        ),
      );
      expect((await feeds.read(value.id)).protocolModifiedAt, old);
      final event = (await calendars.createEvent(
        cal.CalendarEventCreateRequest(
          calendarId: calendar,
          content: fixtures.eventInput(summary: 'Tracked'),
        ),
      ))!;
      final changed = (await feeds.read(value.id)).protocolModifiedAt;
      expect(changed.isAfter(old), isTrue);
      final nowRecord = (await feed.CalendarFeedDataRecord.db.find(session))
          .single;
      await feed.CalendarFeedDataRecord.db.updateRow(
        session,
        nowRecord.copyWith(protocolModifiedAt: old),
      );
      await calendars.updateEvent(
        cal.CalendarEventUpdateRequest(
          eventId: event.eventId,
          expectedRevision: 1,
          content: fixtures.eventInput(summary: 'Tracked'),
        ),
      );
      expect((await feeds.read(value.id)).protocolModifiedAt, old);
      expect((await feeds.read(value.id)).revision, 1);
    });
    test(
      'retention prunes old revoked references and markers without rearming',
      () async {
        final value = await feeds.create(settings());
        await feeds.createCredential(value.id, 1, null);
        final issued = (await feeds.credentials(value.id)).single;
        await feeds.revokeCredential(value.id, 2, issued.id, 1);
        final row = (await feed.CalendarFeedCredentialRecord.db.find(session))
            .single;
        await feed.CalendarFeedCredentialRecord.db.updateRow(
          session,
          row.copyWith(revokedAt: DateTime.utc(2000)),
        );
        await feed.CalendarFeedModule.runMaintenance(session);
        expect(await feeds.credentials(value.id), isEmpty);
        await feeds.delete(value.id, 3);
        final marker = (await feed.CalendarFeedIdentityRecord.db.find(session))
            .single;
        await feed.CalendarFeedIdentityRecord.db.updateRow(
          session,
          marker.copyWith(deletedAt: DateTime.utc(2000)),
        );
        await feed.CalendarFeedModule.runMaintenance(session);
        expect(await feed.CalendarFeedIdentityRecord.db.count(session), 0);
      },
    );
  });
}
