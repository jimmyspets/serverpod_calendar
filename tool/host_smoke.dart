import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:calendar_example_client/calendar_example_client.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';

import 'notification_smoke.dart';

/// Runs real, independent example hosts against isolated shared test storage.
/// Compose test services must already be healthy. All child processes are owned
/// by this harness and are stopped in finally, including on test failure.
Future<void> main(List<String> args) async {
  if (args.contains('--browser-only') && !args.contains('--flutter')) {
    throw ArgumentError('--browser-only requires --flutter');
  }
  final root = Directory.current.absolute.path;
  final server = '$root/example/calendar_example/calendar_example_server';
  final hosts = <Process>[];
  final exited = <int>{};
  Future<void> stop(Process process) async {
    if (exited.contains(process.pid)) return;
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
    } else {
      process.kill();
    }
  }

  final logSinks = <IOSink>[];
  await Directory('.local').create(recursive: true);
  final executable =
      '$root/.local/host/bundle/bin/main${Platform.isWindows ? '.exe' : ''}';
  if (!File(executable).existsSync()) {
    throw StateError('Build the host bundle before running the smoke harness.');
  }
  Future<void> start(String id, int port) async {
    final ready = Completer<void>();
    final log = File('.local/host-$id.log').openWrite();
    logSinks.add(log);
    final process = await Process.start(
      executable,
      ['--mode=test', '--server-id=$id', '--apply-migrations'],
      workingDirectory: server,
      environment: {
        'CALENDAR_EXAMPLE_SEED_DEMO': 'true',
        'CALENDAR_EXAMPLE_FEED_TRANSPORT_PROBE': 'true',
        'SERVERPOD_API_SERVER_PORT': '$port',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${port + 1}',
        'SERVERPOD_WEB_SERVER_PORT': '${port + 2}',
      },
    );
    hosts.add(process);
    void line(String line) {
      log.writeln(line);
      if (line.contains('Synthetic demo accounts are ready') &&
          !ready.isCompleted) {
        ready.complete();
      }
    }

    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(line);
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(line);
    unawaited(
      process.exitCode.then((code) {
        exited.add(process.pid);
        if (!ready.isCompleted) {
          ready.completeError(
            StateError('Host $id exited ($code); see .local/host-$id.log'),
          );
        }
      }),
    );
    await ready.future.timeout(const Duration(seconds: 90));
    stdout.writeln('Host $id ready on $port.');
  }

  try {
    await start('smoke-a', 18180);
    await start('smoke-b', 18280);
    final settings =
        (jsonDecode(await File('.local/credentials.json').readAsString())
                as Map)['test']
            as Map;
    if (!args.contains('--browser-only')) {
      final client = await Process.start(Platform.resolvedExecutable, [
        'run',
        'tool/client_smoke.dart',
        if (args.contains('--feeds')) '--feeds',
        'http://localhost:18180/',
        'http://localhost:18280/',
      ], workingDirectory: root);
      final out = client.stdout.transform(utf8.decoder).listen(stdout.write);
      final err = client.stderr.transform(utf8.decoder).listen(stderr.write);
      final code = await client.exitCode.timeout(
        const Duration(seconds: 180),
        onTimeout: () {
          unawaited(stop(client));
          throw TimeoutException('Generated-client smoke timed out.');
        },
      );
      await out.cancel();
      await err.cancel();
      if (code != 0) throw StateError('Real-client smoke failed ($code).');
      if (args.contains('--feeds') && !args.contains('--flutter')) return;
      if (!args.contains('--feeds')) {
        final recoveryClients = [
          for (final port in [18180, 18280])
            Client('http://localhost:$port/')
              ..authSessionManager = ClientAuthSessionManager(
                storage: _RecoveryStorage(),
              ),
        ];
        try {
          final auth = await recoveryClients.first.emailIdp.login(
            email: 'alice@example.invalid',
            password: settings['demoAlicePassword'] as String,
          );
          for (final c in recoveryClients) {
            await c.auth.updateSignedInUser(auth);
          }
          await notificationSmoke(
            recoveryClients,
            setRecipientBlocked: (blocked) async {
              final result = await Process.run('python', [
                'tool/notification_access_probe.py',
                '${auth.authUserId}',
                blocked ? 'block' : 'unblock',
              ], workingDirectory: root);
              if (result.exitCode != 0) {
                throw StateError('Synthetic access fixture failed');
              }
            },
            loseProducer: () async {
              await stop(hosts.first);
              await hosts.first.exitCode;
            },
          );
          stdout.writeln(
            'PASS: producer host actually terminated; survivor reauthorized and recovered the same live notification.',
          );
        } finally {
          for (final c in recoveryClients) {
            c.close();
          }
        }
        // Restore the owned host so the complete Flutter journey still uses A/B.
        await start('smoke-a-recovered', 18180);
      }
    } else {
      stdout.writeln(
        'Focused browser only: generated-client and worker-loss prerequisites skipped.',
      );
    }
    if (args.contains('--flutter')) {
      final driverPath =
          Platform.environment['CHROMEDRIVER'] ??
          '$root/.local/webdriver/chromedriver-win64/chromedriver.exe';
      if (!File(driverPath).existsSync()) {
        throw StateError('Set CHROMEDRIVER or run tool/setup-webdriver.ps1.');
      }
      final driver = await Process.start(driverPath, [
        '--port=18444',
        '--allowed-ips=127.0.0.1',
      ]);
      hosts.add(driver);
      unawaited(
        driver.exitCode.then((_) {
          exited.add(driver.pid);
        }),
      );
      final driverLog = File('.local/webdriver.log').openWrite();
      logSinks.add(driverLog);
      driver.stdout.transform(utf8.decoder).listen(driverLog.write);
      driver.stderr.transform(utf8.decoder).listen(driverLog.write);
      final http = HttpClient();
      var driverReady = false;
      try {
        for (var i = 0; i < 50; i++) {
          try {
            final request = await http.getUrl(
              Uri.parse('http://localhost:18444/status'),
            );
            final response = await request.close();
            await response.drain<void>();
            if (response.statusCode == 200) {
              driverReady = true;
              break;
            }
          } on SocketException {
            /* Wait for the owned driver to bind. */
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      } finally {
        http.close(force: true);
      }
      if (!driverReady) {
        throw StateError(
          'ChromeDriver did not start; see .local/webdriver.log.',
        );
      }

      final packageConfig = jsonDecode(
        await File('.dart_tool/package_config.json').readAsString(),
      ) as Map;
      final flutterPackage = (packageConfig['packages'] as List)
          .cast<Map>()
          .firstWhere((p) => p['name'] == 'flutter');
      final flutterRoot = Directory.fromUri(
        Uri.parse(flutterPackage['rootUri'] as String),
      ).parent.parent.path;
      final flutter = '$flutterRoot/bin/cache/flutter_tools.snapshot';
      final result = await Process.start(Platform.resolvedExecutable, [
        flutter,
        'drive',
        '--no-pub',
        '-d',
        'web-server',
        '--driver=test_driver/integration_test.dart',
        args.contains('--scheduling')
            ? '--target=integration_test/scheduling_smoke_test.dart'
            : args.contains('--feeds')
            ? '--target=integration_test/feed_smoke_test.dart'
            : args.contains('--event-content')
            ? '--target=integration_test/event_content_smoke_test.dart'
            : args.contains('--task-replacement')
            ? '--target=integration_test/task_replace_smoke_test.dart'
            : args.contains('--event-replacement')
            ? '--target=integration_test/event_replace_smoke_test.dart'
            : '--target=integration_test/connected_smoke_test.dart',
        '--driver-port=18444',
        '--web-port=18380',
        '--web-hostname=localhost',
        '--headless',
        '--dart-define-from-file=$root/.local/test_defines.json',
      ], workingDirectory: '$server/../calendar_example_flutter');
      unawaited(
        result.exitCode.then((_) {
          exited.add(result.pid);
        }),
      );
      final output = result.stdout.transform(utf8.decoder).listen(stdout.write);
      final error = result.stderr.transform(utf8.decoder).listen(stderr.write);
      final focused =
          args.contains('--scheduling') ||
          args.contains('--feeds') ||
          args.contains('--task-replacement') ||
          args.contains('--event-replacement') ||
          args.contains('--event-content');
      // The full journey includes all delivered features and process shutdown.
      // Keep the focused feature targets short; per-action waits stay bounded.
      final browserCode = await result.exitCode.timeout(
        Duration(minutes: focused ? 4 : 8),
        onTimeout: () {
          unawaited(stop(result));
          throw TimeoutException('Flutter browser smoke timed out.');
        },
      );
      await output.cancel();
      await error.cancel();
      if (browserCode != 0) {
        throw StateError('Flutter browser smoke failed ($browserCode).');
      }
    }
  } finally {
    for (final process in hosts.reversed) {
      await stop(process);
    }
    for (final process in hosts.reversed) {
      await process.exitCode.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          process.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    }
    for (final sink in logSinks) {
      await sink.close();
    }
  }
}

final class _RecoveryStorage implements ClientAuthSuccessStorage {
  AuthSuccess? value;
  @override
  Future<AuthSuccess?> get() async => value;
  @override
  Future<void> set(AuthSuccess? data) async {
    value = data;
  }
}
