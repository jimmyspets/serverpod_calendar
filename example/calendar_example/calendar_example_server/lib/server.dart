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
import 'src/alarm_runtime.dart';

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
  CalendarModule.install(
    pod,
    policy: DemoCalendarPolicy(),
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
