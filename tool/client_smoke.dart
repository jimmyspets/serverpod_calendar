import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

class MemoryAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}

Future<void> main(List<String> args) async {
  final mode = args.contains('--development') ? 'development' : 'test';
  final urls = args.where((a) => a.startsWith('http')).toList();
  if (urls.isEmpty) {
    urls.add(
      mode == 'test' ? 'http://localhost:18180/' : 'http://localhost:18080/',
    );
  }
  final values =
      (jsonDecode(await File('.local/credentials.json').readAsString())
              as Map)[mode]
          as Map;
  final clients = urls
      .map(
        (url) => Client(url)
          ..authSessionManager = ClientAuthSessionManager(
            storage: MemoryAuthStorage(),
          ),
      )
      .toList();
  try {
    final first = clients.first;
    var rejected = false;
    try {
      await first.smoke.whoAmI();
    } on ServerpodClientUnauthorized {
      rejected = true;
    }
    if (!rejected) {
      throw StateError('Unauthenticated host call was not rejected.');
    }
    for (final module in [
      () => first.modules.serverpod_calendar.calendarDiagnostics.check(),
      () =>
          first.modules.serverpod_notifications.notificationDiagnostics.check(),
    ]) {
      rejected = false;
      try {
        await module();
      } on ServerpodClientUnauthorized {
        rejected = true;
      }
      if (!rejected) {
        throw StateError('Unauthenticated module call was not rejected.');
      }
    }
    final auth = await first.emailIdp.login(
      email: 'alice@example.invalid',
      password: values['demoAlicePassword'] as String,
    );
    for (final client in clients) {
      await client.auth.updateSignedInUser(auth);
      final id = await client.smoke.whoAmI();
      if (id != auth.authUserId.toString()) {
        throw StateError('Identity mismatch.');
      }
      final calendar = await client
          .modules
          .serverpod_calendar
          .calendarDiagnostics
          .check();
      final notifications = await client
          .modules
          .serverpod_notifications
          .notificationDiagnostics
          .check();
      if (calendar != 'calendar:ready:$id' ||
          notifications != 'notifications:ready:$id') {
        throw StateError('Module identity mismatch.');
      }
    }
    await first.auth.signOutDevice();
    // The same token must also fail on a different running host after revocation.
    final verifier = clients.length > 1 ? clients.last : first;
    rejected = false;
    try {
      await verifier.smoke.whoAmI();
    } on ServerpodClientUnauthorized {
      rejected = true;
    }
    if (!rejected) {
      throw StateError('Signed-out/revoked call was not rejected.');
    }
    stdout.writeln(
      'PASS: generated-client auth, module identity and revocation on ${clients.length} host(s).',
    );
  } finally {
    for (final client in clients) {
      client.close();
    }
  }
}
