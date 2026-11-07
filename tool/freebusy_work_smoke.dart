import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

final class _Probe {
  _Probe(this.process, this.lines, this.log);
  final Process process;
  final StreamIterator<String> lines;
  final IOSink log;
  Completer<void>? paused;
  bool stopped = false;
  Future<Object?> command(
    String caseId,
    String name, [
    Map<String, Object?> extra = const {},
  ]) async {
    process.stdin.writeln(
      jsonEncode({'case': caseId, 'command': name, ...extra}),
    );
    await process.stdin.flush();
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      final line = lines.current;
      log.writeln(line);
      if (line.startsWith('FREEBUSY_PAUSED ')) paused?.complete();
      if (line.startsWith('FREEBUSY_RESULT ')) {
        return jsonDecode(line.substring('FREEBUSY_RESULT '.length));
      }
    }
    throw StateError('Owned free/busy probe exited without a result');
  }

  Future<void> stop() async {
    if (stopped) return;
    stopped = true;
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
    } else {
      process.kill(ProcessSignal.sigkill);
    }
    await process.exitCode;
    await lines.cancel();
    await log.close();
  }
}

void require(bool value, String message) {
  if (!value) throw StateError(message);
}

/// Two real Serverpod processes, shared disposable storage, actual process loss.
Future<void> main() async {
  final root = Directory.current.absolute.path;
  final probes = <_Probe>[], cases = <String>[];
  var serial = 0;
  Future<_Probe> start(int port) async {
    final name = '${serial++}';
    final process = await Process.start(
      Platform.resolvedExecutable,
      ['run', 'test/support/free_busy_work_probe.dart', name],
      workingDirectory:
          '$root/example/calendar_example/calendar_example_server',
      environment: {
        'SERVERPOD_API_SERVER_PORT': '$port',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${port + 1}',
        'SERVERPOD_WEB_SERVER_PORT': '${port + 2}',
      },
    );
    final log = File('$root/.local/freebusy-worker-$name.log').openWrite();
    process.stderr.listen(log.add);
    final lines = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final probe = _Probe(process, lines, log);
    probes.add(probe);
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      log.writeln(lines.current);
      if (lines.current == 'FREEBUSY_READY') return probe;
    }
    throw StateError('Owned free/busy probe failed to start');
  }

  String nextCase() {
    final id = cal.Uuid().v4obj().toString();
    cases.add(id);
    return id;
  }

  Map<String, dynamic> request(Map fixture) =>
      cal.CalendarFreeBusyPublishRequest(
        commandId: cal.Uuid().v4obj(),
        calendarId: cal.UuidValue.fromString(fixture['calendar'] as String),
        fromUtc: DateTime.utc(2030, 11, 6),
        untilUtc: DateTime.utc(2030, 11, 7),
        recipients: ['mailto:recipient@example.invalid'],
      ).toJson();
  Future<Map> state(_Probe p, String id) async =>
      (await p.command(id, 'state')) as Map;
  List<Map> deliveries(Map s) => (s['deliveries'] as List).cast<Map>();
  Future<void> lose(
    _Probe p,
    String id,
    String command,
    String phase, [
    Map<String, Object?> extra = const {},
  ]) async {
    p.paused = Completer<void>();
    final pending = p.command(id, command, {...extra, 'pause': phase});
    unawaited(pending.catchError((_) => null));
    await p.paused!.future.timeout(const Duration(seconds: 60));
    await p.stop();
    await pending.catchError((_) => null);
  }

  _Probe? cleanup;
  try {
    var a = await start(19180);
    final b = await start(19280);
    cleanup = b;
    var id = nextCase();
    var fixture = (await a.command(id, 'create')) as Map;
    var frozen = request(fixture);
    final receipts = await Future.wait([
      a.command(id, 'queue', {'request': frozen}),
      b.command(id, 'queue', {'request': frozen}),
    ]);
    require(
      jsonEncode(receipts[0]) == jsonEncode(receipts[1]),
      'Competing commands changed receipt identity',
    );
    final workers = await Future.wait([
      a.command(id, 'work'),
      b.command(id, 'work'),
    ]);
    require(
      workers.cast<int>().reduce((a, b) => a + b) == 1,
      'Competing workers submitted twice',
    );
    var saved = await state(b, id);
    require(
      deliveries(saved).single['state'] == 'accepted',
      'Shared acceptance missing',
    );
    final payload = (saved['commands'] as List).single['payload'] as String;
    require(
      !payload.contains(fixture['event'] as String) &&
          !payload.contains(fixture['calendar'] as String) &&
          !payload.contains('Synthetic private text'),
      'Report disclosed native identity/text',
    );
    require(
      (saved['attempts'] as List).cast<Map>().single['mimeDigest'] is String,
      'Actual MIME digest not recorded',
    );
    stdout.writeln(
      'PASS competing command/worker processes, native privacy and MIME identity',
    );

    id = nextCase();
    fixture = (await a.command(id, 'create')) as Map;
    frozen = request(fixture);
    await lose(a, id, 'queue', 'beforeCommit', {'request': frozen});
    require(
      ((await state(b, id))['commands'] as List).isEmpty,
      'Uncommitted queue survived process loss',
    );
    await b.command(id, 'queue', {'request': frozen});
    await b.command(id, 'work');
    a = await start(19180);
    stdout.writeln('PASS queue rollback after actual process loss');

    id = nextCase();
    fixture = (await a.command(id, 'create')) as Map;
    frozen = request(fixture);
    await lose(a, id, 'queue', 'afterCommit', {'request': frozen});
    saved = await state(b, id);
    final retained = jsonDecode(
      (saved['commands'] as List).single['receipt'] as String,
    );
    require(
      jsonEncode(await b.command(id, 'queue', {'request': frozen})) ==
          jsonEncode(retained),
      'Committed retry allocated new identity',
    );
    await b.command(id, 'work');
    a = await start(19180);
    stdout.writeln('PASS committed command retry after actual process loss');

    for (final phase in ['beforeSubmit', 'afterLease', 'afterAcceptance']) {
      id = nextCase();
      fixture = (await a.command(id, 'create')) as Map;
      frozen = request(fixture);
      await a.command(id, 'queue', {'request': frozen});
      await lose(a, id, 'work', phase);
      if (phase != 'beforeSubmit') {
        require(
          await b.command(id, 'work') == 0,
          'Live database lease was bypassed',
        );
        await Future<void>.delayed(const Duration(seconds: 7));
      }
      require(
        await b.command(id, 'work') == 1,
        'Survivor did not recover eligible delivery',
      );
      saved = await state(b, id);
      require(
        deliveries(saved).single['state'] == 'accepted',
        'Recovered delivery was not accepted',
      );
      require(
        (saved['attempts'] as List).cast<Map>().every(
          (a) => a['finished'] == true,
        ),
        'Lost lease left an unfinished attempt',
      );
      require(
        deliveries(saved).single['attempts'] ==
            (phase == 'beforeSubmit' ? 1 : 2),
        'Retry attempt accounting changed',
      );
      require(await b.command(id, 'work') == 0, 'Accepted report was replayed');
      a = await start(19180);
      stdout.writeln(
        'PASS $phase process loss, database lease expiry, stable UUID/calendar/MIME bytes',
      );
    }

    for (final flag in ['revoked', 'source-revoked', 'route-changed']) {
      id = nextCase();
      fixture = (await a.command(id, 'create')) as Map;
      await a.command(id, 'queue', {'request': request(fixture)});
      await b.command(id, 'flag', {'flag': flag});
      require(
        await a.command(id, 'work') == 0,
        'Revoked authority reached transport',
      );
      require(
        deliveries(await state(b, id)).single['state'] == 'withdrawn',
        'Cross-process revocation was not durable',
      );
    }
    stdout.writeln('PASS cross-host owner/source/route revocation');
    id = nextCase();
    fixture = (await a.command(id, 'create')) as Map;
    frozen = request(fixture);
    await a.command(id, 'queue', {'request': frozen});
    await b.command(id, 'delete-event', {'event': fixture['event']});
    saved = await state(a, id);
    require(
      (saved['commands'] as List).cast<Map>().single['payload'] == null,
      'Deletion retained busy body',
    );
    require(
      deliveries(saved).single['state'] == 'withdrawn',
      'Deletion did not fence private delivery',
    );
    require(await a.command(id, 'work') == 0, 'Deleted report was submitted');
    require(
      await b.command(id, 'queue', {'request': frozen}) is Map,
      'Scrubbed exact retry failed',
    );
    stdout.writeln(
      'PASS cross-host source-deletion scrubbing and content-free retry',
    );
  } finally {
    if (cleanup != null) {
      for (final id in cases) {
        try {
          await cleanup.command(id, 'cleanup');
        } catch (_) {
          /* Stop all owned children even on failure. */
        }
      }
    }
    for (final p in probes) {
      await p.stop();
    }
    for (final entry in Directory('.local').listSync()) {
      if (entry is File &&
          cases.any(
            (id) =>
                entry.uri.pathSegments.last.startsWith('freebusy-probe-$id.'),
          )) {
        await entry.delete();
      }
    }
  }
  stdout.writeln('Two-host VFREEBUSY recovery checks passed.');
}
