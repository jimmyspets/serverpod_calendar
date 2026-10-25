import 'dart:async';
import 'dart:convert';
import 'dart:io';

final class _Probe {
  _Probe(this.process, this.lines, this.errorLog, this.channel);
  final Process process;
  final StreamIterator<String> lines;
  final IOSink errorLog;
  bool exited = false;
  final File channel;
  int nonce = 0;
  Future<Object?> command(Map<String, Object?> value) async {
    await channel.writeAsString(
      jsonEncode({...value, 'nonce': ++nonce}),
      flush: true,
    );
    while (await lines.moveNext().timeout(const Duration(seconds: 30))) {
      errorLog.writeln('stdout: ${lines.current}');
      if (lines.current.startsWith('NOTIFICATION_WORK_RESULT ')) {
        return jsonDecode(
          lines.current.substring('NOTIFICATION_WORK_RESULT '.length),
        );
      }
    }
    await errorLog.flush();
    throw StateError(
      'Worker probe exited without a result; inspect its ignored log',
    );
  }

  Future<void> stop() async {
    if (!exited) {
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
      } else {
        process.kill(ProcessSignal.sigkill);
      }
      await process.exitCode;
    }
    await lines.cancel();
    await errorLog.close();
  }
}

/// Two real independent Serverpod worker processes share only synthetic storage.
Future<void> main() async {
  final root = Directory.current.absolute.path;
  final probes = <_Probe>[];
  Map<String, dynamic>? fixture;
  Future<_Probe> start(String name) async {
    final channel = File('$root/.local/notification-worker-$name.command.json');
    if (await channel.exists()) await channel.delete();
    final process = await Process.start(
      Platform.resolvedExecutable,
      [
        'run',
        'test/support/notification_work_probe.dart',
        '$root/.local/notification-worker-$name.command.json',
        name,
      ],
      workingDirectory:
          '$root/example/calendar_example/calendar_example_server',
      environment: {
        'SERVERPOD_API_SERVER_PORT': name == 'a' ? '18380' : '18480',
        'SERVERPOD_INSIGHTS_SERVER_PORT': name == 'a' ? '18381' : '18481',
        'SERVERPOD_WEB_SERVER_PORT': name == 'a' ? '18382' : '18482',
      },
    );
    final log = File('$root/.local/notification-worker-$name.err.log')
        .openWrite();
    process.stderr.listen(log.add);
    final lines = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final probe = _Probe(
      process,
      lines,
      log,
      File('$root/.local/notification-worker-$name.command.json'),
    );
    probes.add(probe);
    unawaited(
      process.exitCode.then((_) {
        probe.exited = true;
      }),
    );
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      log.writeln('startup: ${lines.current}');
      if (lines.current == 'NOTIFICATION_WORK_READY') return probe;
    }
    throw StateError('Worker probe failed to initialize');
  }

  try {
    final both = [await start('a'), await start('b')];
    fixture =
        (await both.first.command({'command': 'seed'})) as Map<String, dynamic>;
    final accepted = await Future.wait([
      for (final p in both)
        p.command({'command': 'accept', 'fixture': fixture}),
    ]);
    if (accepted.first != accepted.last) {
      throw StateError(
        'Concurrent acceptance created different delivery identities',
      );
    }
    await both.first.command({'command': 'removeRace', 'fixture': fixture});
    final claims = await Future.wait([
      for (final p in both) p.command({'command': 'claim'}),
    ]);
    final winners = [
      for (var i = 0; i < claims.length; i++)
        if ((claims[i] as List).isNotEmpty) i,
    ];
    if (winners.length != 1) {
      throw StateError('Competing processes claimed the same delivery');
    }
    final winner = winners.single, survivor = 1 - winner;
    final old = (claims[winner] as List).single as Map<String, dynamic>;
    if (await both[survivor].command({'command': 'validate', 'lease': old}) !=
        true) {
      throw StateError('Committed ownership was not visible across processes');
    }
    await both[winner].stop(); // Actual process loss, not a rewritten lease.
    await Future<void>.delayed(const Duration(seconds: 6));
    final recovered =
        (await both[survivor].command({'command': 'claim'})) as List;
    if (recovered.length != 1) {
      throw StateError('Survivor did not reclaim expired worker ownership');
    }
    final current = recovered.single as Map<String, dynamic>;
    if (current['fence'] <= old['fence'] ||
        current['owner'] == old['owner'] ||
        await both[survivor].command({'command': 'validate', 'lease': old}) !=
            false ||
        await both[survivor].command({
              'command': 'validate',
              'lease': current,
            }) !=
            true) {
      throw StateError('Stale worker fence remained valid after recovery');
    }
    await both[survivor].command({'command': 'cleanup', 'fixture': fixture});
    fixture = null;
    stdout.writeln(
      'PASS: independent Serverpod workers, concurrent idempotent acceptance, competing committed claims, actual instance loss, expiry takeover and stale-owner fencing.',
    );
  } finally {
    if (fixture != null) {
      for (final probe in probes.where((p) => !p.exited)) {
        try {
          await probe.command({'command': 'cleanup', 'fixture': fixture});
          break;
        } catch (_) {}
      }
    }
    for (final probe in probes) {
      await probe.stop();
    }
  }
}
