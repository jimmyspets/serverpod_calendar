import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Local host fixtures only; never an endpoint or part of the reusable modules.
Future<void> seedDemoAccounts(Serverpod pod) async {
  if (!{'development', 'test'}.contains(pod.runMode)) {
    throw StateError('Demo seeding is restricted to local development/test.');
  }
  final session = await pod.createSession();
  try {
    for (final name in ['alice', 'bob']) {
      final email = '$name@example.invalid';
      await session.db.transaction((transaction) async {
        final admin = AuthServices.instance.emailIdp.admin;
        if (await admin.findAccount(
              session,
              email: email,
              transaction: transaction,
            ) !=
            null) {
          return;
        }
        final user = await AuthServices.instance.authUsers.create(
          session,
          transaction: transaction,
        );
        await admin.createEmailAuthentication(
          session,
          authUserId: user.id,
          email: email,
          password: pod.getPassword(
            'demo${name == 'alice' ? 'Alice' : 'Bob'}Password',
          )!,
          transaction: transaction,
        );
      });
    }
    stdout.writeln(
      'Synthetic demo accounts are ready (credentials are local only).',
    );
  } finally {
    await session.close();
  }
}

/// Recording adapter only; it never sends email or writes codes to server logs.
Future<void> recordAuthMail(String kind, String email, String code) async {
  final file = File('../../../.local/auth-mail.jsonl');
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${jsonEncode({'kind': kind, 'email': email, 'code': code})}\n',
    mode: FileMode.append,
    flush: true,
  );
}
