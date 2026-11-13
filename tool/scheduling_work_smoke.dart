import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    show Uuid;

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
Future<void> main(List<String> args) async {
  final root = Directory.current.absolute.path, probes = <_Probe>[];
  final fixtures = <Map<String, dynamic>>[];
  final informationOccurrences = args.contains('--information-occurrences');
  final compiledProbe =
      '$root/.local/scheduling-work-probe${Platform.isWindows ? '.exe' : ''}';
  if (informationOccurrences) {
    final build = await Process.run(
      Platform.resolvedExecutable,
      [
        'compile',
        'exe',
        'test/support/scheduling_work_probe.dart',
        '-o',
        compiledProbe,
      ],
      workingDirectory:
          '$root/example/calendar_example/calendar_example_server',
    );
    if (build.exitCode != 0) {
      throw StateError(
        'Owned scheduling probe compilation failed: ${build.stderr}',
      );
    }
  }
  Future<_Probe> start(String name, int port) async {
    final p = await Process.start(
      informationOccurrences ? compiledProbe : Platform.resolvedExecutable,
      informationOccurrences
          ? [name]
          : ['run', 'test/support/scheduling_work_probe.dart', name],
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
    if (args.contains('--information') ||
        informationOccurrences ||
        args.contains('--information-commands')) {
      for (final restore in [false, true]) {
        for (final pause in ['before', 'after']) {
          final fixture = (await b.command({
            'command': 'seed',
            'method': restore ? 'INFORMATION_CANCEL' : 'INFORMATION',
            'occurrences': informationOccurrences,
          })) as Map<String, dynamic>;
          fixtures.add(fixture);
          final command = {
            'command': 'information-command',
            'eventId': fixture['eventId'],
            'revision': int.parse(fixture['revision'] as String),
            'restore': restore,
            'key': Uuid().v4obj().toString(),
          };
          a.submitted = Completer<void>();
          final lost = a
              .command({...command, 'pause': pause})
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          await a.submitted!.future.timeout(const Duration(seconds: 30));
          await a.stop();
          await lost;
          final recovered = (await b.command(command)) as Map<String, dynamic>;
          final retry = (await b.command(command)) as Map<String, dynamic>;
          if (recovered['unchanged'] != (pause == 'after') ||
              retry['unchanged'] != true ||
              recovered['publicationId'] != retry['publicationId'] ||
              recovered['publications'] !=
                  (restore ? 3 : 2) + (informationOccurrences ? 1 : 0)) {
            throw StateError(
              'Information lifecycle commit loss changed atomic receipt/intent identity',
            );
          }
          a = await start('a-information-command-$restore-$pause', 18580);
        }
      }
      stdout.writeln(
        'PASS: information cancel/reopen actual loss before/after commit, atomic one-intent recovery and stable cross-process command receipts.',
      );
      if (args.contains('--information-commands')) return;
    }
    if (args.contains('--replies')) {
      final fixture = (await b.command({
        'command': 'seed',
        'method': args.contains('--instances')
            ? 'INSTANCE_REPLY'
            : args.contains('--recurring')
            ? 'RECURRING_REPLY'
            : 'REPLY',
      })) as Map<String, dynamic>;
      fixtures.add(fixture);
      final raced = await Future.wait([
        for (final probe in [a, b])
          probe.command({
            'command': 'reply',
            ...fixture,
            'key': 'raced',
            'instance': args.contains('--instances'),
          }),
      ]);
      final r0 = raced.first as Map, r1 = raced.last as Map;
      if (r0['receiptId'] != r1['receiptId'] ||
          [r0, r1].where((r) => r['unchanged'] == false).length != 1) {
        throw StateError('Independent-host reply deduplication failed');
      }
      for (final pause in ['before', 'after']) {
        final fixture = (await b.command({
          'command': 'seed',
          'method': args.contains('--instances')
              ? 'INSTANCE_REPLY'
              : args.contains('--recurring')
              ? 'RECURRING_REPLY'
              : 'REPLY',
        })) as Map<String, dynamic>;
        fixtures.add(fixture);
        a.submitted = Completer<void>();
        final lost = a
            .command({
              'command': 'reply',
              'instance': args.contains('--instances'),
              ...fixture,
              'key': 'recover-$pause',
              'pause': pause,
            })
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        await a.submitted!.future.timeout(const Duration(seconds: 30));
        await a.stop();
        await lost;
        final recovered = (await b.command({
          'command': 'reply',
          'instance': args.contains('--instances'),
          ...fixture,
          'key': 'recover-$pause',
        })) as Map;
        if (recovered['unchanged'] != (pause == 'after') ||
            recovered['sources'] != 1 ||
            recovered['receipts'] != 1 ||
            recovered['responses'] != 1 ||
            recovered['outcome'] != 'applied' ||
            recovered['instance'] != args.contains('--instances')) {
          throw StateError('Reply process-loss recovery violated atomicity');
        }
        if (pause == 'before') a = await start('reply-recovered', 18580);
      }
      stdout.writeln(
        'PASS: independent ${args.contains('--instances')
            ? 'instance'
            : args.contains('--recurring')
            ? 'recurring-master'
            : 'non-recurring'} reply hosts, raced stable keys, actual loss before commit and after commit, atomic three-table recovery.',
      );
      return;
    }
    if (args.isEmpty ||
        args.contains('--range-commands') ||
        args.contains('--range-group')) {
      for (final restore in [false, true]) {
        for (final pause in ['before', 'after']) {
          final fixture = (await b.command({
            'command': 'seed',
            'method': 'REQUEST',
          })) as Map<String, dynamic>;
          fixtures.add(fixture);
          await b.command({'command': 'work'});
          if (restore) {
            await b.command({
              'command': 'range-command',
              ...fixture,
              'key': Uuid().v4(),
              'revision': 2,
            });
            await b.command({'command': 'work'});
          }
          final command = {
            'command': 'range-command',
            ...fixture,
            'restore': restore,
            'revision': int.parse(fixture['revision'] as String),
            'key': Uuid().v4(),
          };
          a.submitted = Completer<void>();
          final lost = a
              .command({...command, 'pause': pause})
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          await a.submitted!.future.timeout(const Duration(seconds: 30));
          await a.stop();
          await lost;
          final recovered = (await b.command(command)) as Map<String, dynamic>;
          if (recovered['publications'] !=
                  (restore ? 3 : 2) + (informationOccurrences ? 1 : 0) ||
              recovered['unchanged'] != (pause == 'after') ||
              recovered['revision'] != (restore ? 4 : 3)) {
            throw StateError(
              'Range command loss failed atomic receipt recovery',
            );
          }
          await b.command({'command': 'work'});
          a = await start('a-range-command-$restore-$pause', 18580);
        }
      }
      stdout.writeln(
        'PASS: outgoing range cancel/restore actual process loss before transaction commit and after commit, exact receipt recovery and atomic single-intent writes.',
      );
      if (args.contains('--range-commands')) return;
    }
    final methods = args.contains('--information') || informationOccurrences
        ? ['INFORMATION', 'INFORMATION_CANCEL', 'INFORMATION_REOPEN']
        : args.contains('--range-only') || args.contains('--range-group')
        ? ['RANGE_CANCEL', 'RANGE_RESTORE']
        : args.contains('--mime-only')
        ? ['REQUEST', 'CANCEL']
        : args.contains('--projected-only')
        ? ['REOPEN', 'MASKRESTORE']
        : args.contains('--restore-only')
        ? ['RESTORE']
        : [
            'REQUEST',
            'CANCEL',
            'INSTANCE',
            'RESTORE',
            'REOPEN',
            'MASKRESTORE',
            'RANGE_CANCEL',
            'RANGE_RESTORE',
          ];
    for (final method in methods) {
      final first = (await a.command({
        'command': 'seed',
        'method': method,
        'occurrences': informationOccurrences,
      })) as Map<String, dynamic>;
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
        final fixture = (await b.command({
          'command': 'seed',
          'method': method,
          'occurrences': informationOccurrences,
        })) as Map<String, dynamic>;
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
        final accepted = await File(
          '$root/.local/scheduling-worker-acceptance.jsonl',
        ).readAsLines();
        final recorded = accepted
            .map((line) => jsonDecode(line) as Map<String, dynamic>)
            .where((v) => v['publication'] == fixture['publicationId'])
            .toList();
        if (recorded.length != (pause == 'after' ? 2 : 1) ||
            recorded.any((v) => v['key'] != recovered['key']) ||
            recorded.map((v) => v['digest']).toSet().length != 1 ||
            recorded.map((v) => v['mimeDigest']).toSet().length != 1 ||
            recorded.any(
              (v) =>
                  v['mimeDigest'] is! String ||
                  v['decodedDigest'] != v['digest'],
            )) {
          throw StateError(
            'Recovered $method submissions changed identity or bytes',
          );
        }
        if (pause == 'before' || method != methods.last) {
          a = await start('a-recovered-$method-$pause', 18580);
        }
      }
    }
    stdout.writeln(
      'PASS: ${methods.join(', ')} on two independent scheduling workers, competing claims, actual loss before/after synthetic acceptance, fenced stable-key recovery and byte-identical MIME/decoded payloads.',
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
