import 'dart:io';

import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import 'src/generated/serverpod.dart';
import 'src/local_demo.dart';
import 'src/calendar_policy.dart';

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
  CalendarModule.install(
    pod,
    policy: DemoCalendarPolicy(),
    options: const CalendarModuleOptions(
      requiredWriteGuarantee: CalendarAuthorizationGuarantee.freshCheck,
    ),
  );
  await pod.start();
  if (Platform.environment['CALENDAR_EXAMPLE_SEED_DEMO'] == 'true') {
    await seedDemoAccounts(pod);
  }
}
