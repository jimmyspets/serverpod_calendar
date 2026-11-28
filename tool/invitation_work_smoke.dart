import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

final class _Probe {
  _Probe(this.process, this.lines, this.log) {
    unawaited(process.exitCode.then((_) => exited = true));
  }
  final Process process;
  final StreamIterator<String> lines;
  final IOSink log;
  bool stopped = false, exited = false;
  Completer<Map<String, dynamic>>? paused;
  Future<Object?> command(Map<String, Object?> input) async {
    process.stdin.writeln(jsonEncode(input));
    await process.stdin.flush();
    while (await lines.moveNext().timeout(const Duration(seconds: 60))) {
      final line = lines.current;
      log.writeln(line);
      if (line.startsWith('INVITATION_PAUSED ')) {
        paused?.complete(
          jsonDecode(line.substring('INVITATION_PAUSED '.length))
              as Map<String, dynamic>,
        );
      }
      if (line.startsWith('INVITATION_RESULT ')) {
        return jsonDecode(line.substring('INVITATION_RESULT '.length));
      }
    }
    throw StateError('Owned invitation probe exited without result');
  }

  Future<void> stop() async {
    if (stopped) return;
    stopped = true;
    if (!exited) {
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
      } else {
        process.kill(ProcessSignal.sigkill);
      }
    }
    await process.exitCode;
    await lines.cancel();
    await log.close();
  }
}

void require(bool value, String message) {
  if (!value) throw StateError(message);
}

Future<void> main() async {
  final root = Directory.current.absolute.path,
      probes = <_Probe>[],
      cases = <String>[];
  Future<_Probe> start(String name, int port) async {
    final process = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'test/support/invitation_work_probe.dart', name],
      workingDirectory:
          '$root/example/calendar_example/calendar_example_server',
      environment: {
        'SERVERPOD_API_SERVER_PORT': '$port',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${port + 1}',
        'SERVERPOD_WEB_SERVER_PORT': '${port + 2}',
      },
    );
    final log = File('$root/.local/invitation-worker-$name.log').openWrite();
    process.stderr.listen(log.add);
    final lines = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final probe = _Probe(process, lines, log);
    probes.add(probe);
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      log.writeln(lines.current);
      if (lines.current == 'INVITATION_READY') return probe;
    }
    throw StateError('Owned invitation probe failed to start');
  }

  String nextCase() {
    final id = const cal.Uuid().v4obj().toString();
    cases.add(id);
    return id;
  }

  try {
    var a = await start('a', 18780);
    final b = await start('b', 18880);
    final duplicate = nextCase();
    final raced = await Future.wait(
      [a, b].map(
        (p) => p.command({
          'command': 'receive',
          'caseId': duplicate,
          'key': 'same',
        }),
      ),
    );
    final first = raced[0] as Map, second = raced[1] as Map;
    require(
      first['id'] != null &&
          first['id'] == second['id'] &&
          first['sourceId'] == second['sourceId'],
      'Concurrent duplicate ingress created different receipts',
    );
    final cross = await b.command({
      'command': 'receive',
      'caseId': duplicate,
      'key': 'cross',
    }) as Map;
    require(
      cross['outcome'] == 'duplicate' && cross['sourceId'] == first['sourceId'],
      'Cross-key duplicate changed source identity',
    );
    final dismissed = await Future.wait(
      [a, b].map(
        (p) => p.command({
          'command': 'dismiss',
          'caseId': duplicate,
          'entryId': first['entryId'],
          'revision': 1,
        }),
      ),
    );
    require(
      dismissed.where((r) => r == true).length == 1 &&
          dismissed.whereType<Map>().single['error'] == 'staleRevision',
      'Dismissal race did not fence stale revision',
    );
    final beforeRetry =
        await b.command({'command': 'inspect', 'caseId': duplicate}) as Map;
    await a.command({'command': 'receive', 'caseId': duplicate, 'key': 'same'});
    final afterRetry =
        await b.command({'command': 'inspect', 'caseId': duplicate}) as Map;
    require(
      jsonEncode(beforeRetry) == jsonEncode(afterRetry) &&
          afterRetry['dismissed'] == true,
      'Retained retry reopened dismissal',
    );
    final newer = await b.command({
      'command': 'receive',
      'caseId': duplicate,
      'key': 'new',
      'sequence': 1,
    }) as Map;
    require(
      newer['entryRevision'] == 3,
      'New version did not reopen only the review entry',
    );
    final conflict = nextCase();
    final contested = await Future.wait([
      a.command({
        'command': 'receive',
        'caseId': conflict,
        'key': 'collision',
        'summary': 'A',
      }),
      b.command({
        'command': 'receive',
        'caseId': conflict,
        'key': 'collision',
        'summary': 'B',
      }),
    ]);
    require(
      contested
              .whereType<Map>()
              .where((r) => r['error'] == 'validation')
              .length ==
          1,
      'Conflicting key reuse was not rejected',
    );
    final state =
        await b.command({'command': 'inspect', 'caseId': conflict}) as Map;
    require(
      state['entries'] == 1 && state['sources'] == 1 && state['receipts'] == 1,
      'Conflicting ingress left partial state',
    );
    for (final pause in ['before', 'after']) {
      final id = nextCase();
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({
            'command': 'receive',
            'caseId': id,
            'key': 'loss',
            'pause': pause,
          })
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      final visible =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        visible['receipts'] == (pause == 'before' ? 0 : 1),
        'Ingress was partially visible across commit boundary',
      );
      await a.stop();
      await lost;
      final recovered = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'loss',
      }) as Map;
      require(
        (pause == 'after') == (recovered['id'] == submitted['id']),
        'Process-loss recovery used incorrect retained receipt',
      );
      final committed =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        committed['entries'] == 1 &&
            committed['sources'] == 1 &&
            committed['receipts'] == 1,
        'Process loss duplicated or lost committed ingress',
      );
      if (pause == 'before') a = await start('a-recovered', 18780);
    }
    stdout.writeln(
      'PASS: independent invitation hosts, duplicate/conflicting ingress and dismissal races, actual loss before/after commit, stable receipt recovery and no partial state.',
    );
  } finally {
    final live = probes.where((p) => !p.stopped && !p.exited).toList();
    if (live.isNotEmpty) {
      for (final id in cases) {
        await live.last.command({'command': 'cleanup', 'caseId': id});
      }
    }
    for (final p in probes) {
      await p.stop();
    }
  }
}
