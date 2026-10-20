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
    var auth = await first.emailIdp.login(
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
    if (auth.authStrategy != AuthStrategy.jwt.name ||
        auth.refreshToken == null) {
      throw StateError('Expected JWT access and refresh credentials.');
    }
    final verifier = clients.length > 1 ? clients.last : first;
    // Exercise real refresh/rotation on another host before revoking the pair.
    final refreshed = await verifier.refreshJwtTokens.refreshAccessToken(
      refreshToken: auth.refreshToken!,
    );
    if (refreshed.authUserId != auth.authUserId ||
        refreshed.refreshToken == null ||
        refreshed.refreshToken == auth.refreshToken) {
      throw StateError(
        'JWT refresh did not preserve identity and rotate secret.',
      );
    }
    auth = refreshed;
    for (final client in clients) {
      await client.auth.updateSignedInUser(auth);
      if (await client.smoke.whoAmI() != auth.authUserId.toString()) {
        throw StateError('Refreshed JWT identity mismatch.');
      }
    }
    if (!await first.auth.signOutDevice() || first.auth.isAuthenticated) {
      throw StateError('Sign-out failed or retained local authentication.');
    }
    rejected = false;
    try {
      await first.smoke.whoAmI();
    } on ServerpodClientUnauthorized {
      rejected = true;
    }
    if (!rejected) {
      throw StateError('Signed-out local call was not rejected.');
    }
    // Logout revokes refresh credentials; a copied access JWT stays valid until
    // expiry. Use a separate client even in the single-host development smoke.
    final copied = Client(urls.last)
      ..authSessionManager = ClientAuthSessionManager(
        storage: MemoryAuthStorage(),
      );
    try {
      await copied.auth.updateSignedInUser(auth);
      if (await copied.smoke.whoAmI() != auth.authUserId.toString()) {
        throw StateError(
          'Unexpired copied JWT should remain valid after logout.',
        );
      }
      rejected = false;
      try {
        await copied.refreshJwtTokens.refreshAccessToken(
          refreshToken: auth.refreshToken!,
        );
      } on RefreshTokenNotFoundException {
        rejected = true;
      }
      if (!rejected) {
        throw StateError('Revoked JWT refresh credential was accepted.');
      }
    } finally {
      copied.close();
    }
    stdout.writeln(
      'PASS: JWT login, module identity, cross-host refresh/rotation, local '
      'logout and refresh revocation on ${clients.length} host(s).',
    );
  } finally {
    for (final client in clients) {
      client.close();
    }
  }
}
