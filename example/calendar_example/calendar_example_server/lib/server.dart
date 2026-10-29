import 'dart:io';

import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as notify;

import 'src/notification_runtime.dart';

import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/serverpod.dart';
import 'src/local_demo.dart';
import 'src/calendar_policy.dart';
import 'src/invitation_runtime.dart';
import 'src/alarm_runtime.dart';
import 'src/scheduling_runtime.dart';
import 'src/feed_policy.dart';
import 'src/feed_transport_probe.dart';

import 'package:serverpod_calendar_feed_server/serverpod_calendar_feed_server.dart'
    as feed;

Future<void> run(List<String> args) async {
  final pod = Serverpod(args);
  if (!{'development', 'test'}.contains(pod.runMode)) {
    throw StateError(
      'This example is configured for local development/test only.',
    );
  }
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode:
            (
              session, {
              required email,
              required accountRequestId,
              required verificationCode,
              required transaction,
            }) async {
              await recordAuthMail('registration', email, verificationCode);
            },
        sendPasswordResetVerificationCode:
            (
              session, {
              required email,
              required passwordResetRequestId,
              required verificationCode,
              required transaction,
            }) async {
              await recordAuthMail('password-reset', email, verificationCode);
            },
      ),
    ],
  );
  notify.NotificationModule.install(
    pod,
    policy: DemoNotificationPolicy(),
    sources: [CalendarNotificationSource()],
    publication: DemoNotificationPublication(),
  );
  const feedDependencies = feed.CalendarFeedDependencies();
  CalendarModule.install(
    pod,
    dependencies: [feedDependencies],
    publicationPolicy: DemoCalendarPublicationPolicy(),
    policy: DemoCalendarPolicy(),
    invitations: CalendarInvitationRuntime(host: DemoInvitationHost()),
    scheduling: CalendarSchedulingRuntime(
      host: DemoSchedulingHost(),
      transport: DemoSchedulingTransport(),
      replies: CalendarSchedulingReplyRuntime(host: DemoSchedulingReplyHost()),
    ),
    alarms: CalendarAlarmRuntime(
      policy: DemoAlarmBackgroundPolicy(),
      delivery: CalendarNotificationDelivery(),
    ),
    availabilityExtensions: [
      CalendarAvailabilityExtensionRegistration(
        name: 'X-CALENDAR-EXAMPLE-LABEL',
        contexts: CalendarAvailabilityExtensionContext.values,
        validate: (value) =>
            value.runes.length <= 256 &&
            !value.contains('\n') &&
            !value.contains('\r'),
      ),
    ],
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
    ),
  );
  final web = pod.config.webServer!;
  feed.CalendarFeedModule.install(
    pod,
    policy: DemoFeedPolicy(),
    dependencies: feedDependencies,
    options: feed.CalendarFeedOptions(
      publicBaseUri: Uri(
        scheme: web.publicScheme,
        host: web.publicHost,
        port: web.publicPort,
        path: '/',
      ),
      allowInsecureLoopback: true,
      requiredGuarantee: CalendarAuthorizationGuarantee.freshCheck,
    ),
  );
  pod.webServer.addRoute(feed.CalendarFeedRoute(pod), '/calendar-feed');
  if (pod.runMode == 'test' &&
      Platform.environment['CALENDAR_EXAMPLE_FEED_TRANSPORT_PROBE'] == 'true') {
    pod.webServer.addRoute(
      FeedTransportProbe(),
      '/calendar-feed-transport-probe',
    );
  }
  await pod.start();
  // A distinct durable wake-up per host; cancellation never interrupts in-flight
  // module work. Duplicate executions remain guarded by module database fences.
  final alarmWakeId = 'calendar-alarm-maintenance:${pod.serverId}';
  await pod.futureCalls.cancel(alarmWakeId);
  await pod.futureCalls
      .callRecurring(identifier: alarmWakeId)
      .every(const Duration(seconds: 15))
      .calendarAlarmMaintenance
      .sweep();
  if (Platform.environment['CALENDAR_EXAMPLE_SEED_DEMO'] == 'true') {
    await seedDemoAccounts(pod);
  }
}
