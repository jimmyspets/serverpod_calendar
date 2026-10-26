import 'dart:async';
import 'dart:convert';
import 'dart:io';

final class _Probe {
  _Probe(this.process, this.lines, this.log);
  final Process process;
  final StreamIterator<String> lines;
  final IOSink log;
  bool stopped = false;
  Completer<void>? submitted;
  Future<Object?> command(Map<String, Object?> input) async {
    process.stdin.writeln(jsonEncode(input));
    await process.stdin.flush();
    while (await lines.moveNext().timeout(const Duration(seconds: 60))) {
      log.writeln(lines.current);
      if (lines.current == 'SCHEDULING_SUBMITTED') submitted?.complete();
      if (lines.current.startsWith('SCHEDULING_RESULT ')) {
        return jsonDecode(lines.current.substring('SCHEDULING_RESULT '.length));
      }
    }
    throw StateError('Owned scheduling probe exited without result');
  }

  Future<void> stop() async {
    if (!stopped) {
      stopped = true;
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
      } else {
        process.kill(ProcessSignal.sigkill);
      }
      await process.exitCode;
    }
    await lines.cancel();
    await log.close();
  }
}

/// Real independent Serverpod processes, leases, actual holder loss and takeover.
Future<void> main() async {
  final root = Directory.current.absolute.path, probes = <_Probe>[];
  final fixtures = <Map<String, dynamic>>[];
  Future<_Probe> start(String name, int port) async {
    final p = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'test/support/scheduling_work_probe.dart', name],
      workingDirectory:
          '$root/example/calendar_example/calendar_example_server',
      environment: {
        'SERVERPOD_API_SERVER_PORT': '$port',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${port + 1}',
        'SERVERPOD_WEB_SERVER_PORT': '${port + 2}',
      },
    );
    final log = File('$root/.local/scheduling-worker-$name.log').openWrite();
    p.stderr.listen(log.add);
    final lines = StreamIterator(
      p.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final probe = _Probe(p, lines, log);
    probes.add(probe);
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      log.writeln(lines.current);
      if (lines.current == 'SCHEDULING_READY') return probe;
    }
    throw StateError('Owned scheduling probe failed to start');
  }

  try {
    var a = await start('a', 18580);
    final b = await start('b', 18680);
    final first =
        (await a.command({'command': 'seed'})) as Map<String, dynamic>;
    fixtures.add(first);
    await Future.wait([
      a.command({'command': 'work'}),
      b.command({'command': 'work'}),
    ]);
    final raced = (await b.command({
      'command': 'inspect',
      ...first,
    })) as Map<String, dynamic>;
    if (raced['state'] != 'accepted' ||
        (raced['attempts'] as List).length != 1) {
      throw StateError('Competing workers duplicated a live claim');
    }
    for (final pause in ['before', 'after']) {
      final fixture =
          (await b.command({'command': 'seed'})) as Map<String, dynamic>;
      fixtures.add(fixture);
      a.submitted = Completer<void>();
      final lost = a
          .command({'command': 'work', 'pause': pause})
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      await a.submitted!.future.timeout(const Duration(seconds: 30));
      await a.stop();
      await lost;
      await Future<void>.delayed(const Duration(seconds: 7));
      await b.command({'command': 'work'});
      final recovered = (await b.command({
        'command': 'inspect',
        ...fixture,
      })) as Map<String, dynamic>;
      if (recovered['state'] != 'accepted' ||
          jsonEncode(recovered['attempts']) !=
              jsonEncode(['uncertain', 'accepted'])) {
        throw StateError(
          'Actual holder loss did not recover with retained uncertain attempt',
        );
      }
      if (pause == 'before') a = await start('a-recovered', 18580);
    }
    stdout.writeln(
      'PASS: two independent scheduling workers, competing claims, actual loss before/after synthetic acceptance and fenced stable-key recovery.',
    );
  } finally {
    final live = probes.where((p) => !p.stopped).toList();
    if (live.isNotEmpty) {
      for (final fixture in fixtures) {
        await live.first.command({'command': 'cleanup', ...fixture});
      }
    }
    for (final probe in probes) {
      if (!probe.stopped) await probe.stop();
    }
  }
}
