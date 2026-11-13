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
  Completer<void>? paused;
  bool stopped = false, exited = false;
  Future<Map<String, dynamic>> command(Map<String, Object?> input) async {
    process.stdin.writeln(jsonEncode(input));
    await process.stdin.flush();
    while (await lines.moveNext().timeout(const Duration(seconds: 60))) {
      final line = lines.current;
      log.writeln(line);
      if (line == 'PUBLICATION_PAUSED') paused?.complete();
      if (line.startsWith('PUBLICATION_RESULT ')) {
        return Map<String, dynamic>.from(jsonDecode(line.substring(19)) as Map);
      }
    }
    throw StateError('Owned publication probe exited');
  }

  Future<void> stop() async {
    if (stopped) return;
    stopped = true;
    if (exited) {
      await lines.cancel();
      await log.close();
      return;
    }
    if (Platform.isWindows) {
      await Process.run('taskkill', ['/PID', '${process.pid}', '/T', '/F']);
    } else {
      process.kill();
    }
    await process.exitCode.timeout(const Duration(seconds: 20));
    await lines.cancel();
    await log.close();
  }
}

String _wire(String id, int sequence, {bool cancel = false}) => [
  'BEGIN:VCALENDAR',
  'VERSION:2.0',
  'PRODID:-//Synthetic recovery//EN',
  'METHOD:${cancel ? 'CANCEL' : 'PUBLISH'}',
  'BEGIN:VEVENT',
  'UID:probe-$id@example.invalid',
  'ORGANIZER:mailto:publisher@example.invalid',
  'DTSTAMP:20261113T070000Z',
  'SEQUENCE:$sequence',
  'DTSTART:20270328T090000Z',
  'DURATION:PT1H',
  'SUMMARY:Synthetic publication',
  if (cancel) 'STATUS:CANCELLED',
  'END:VEVENT',
  'END:VCALENDAR',
  '',
].join('\r\n');
Future<void> main() async {
  final root = Directory.current.absolute.path, probes = <_Probe>[];
  final markers = <File>[];
  final server = '$root/example/calendar_example/calendar_example_server';
  // Build once rather than recompiling the same probe on every crash/restart.
  // The CLI bundle includes required native assets on Windows and Linux.
  final build = await Process.run(Platform.resolvedExecutable, [
    'build',
    'cli',
    '--target',
    'test/support/incoming_publication_probe.dart',
    '--output',
    '$root/.local/publication-probe',
  ], workingDirectory: server);
  await File('$root/.local/publication-probe-build.log')
      .writeAsString('${build.stdout}\n${build.stderr}');
  if (build.exitCode != 0) throw StateError('Publication probe build failed');
  final executable =
      '$root/.local/publication-probe/bundle/bin/incoming_publication_probe${Platform.isWindows ? '.exe' : ''}';
  Future<_Probe> start(String name, int port) async {
    // Probes use stdin, not HTTP clients. Allocate fresh ports for every
    // restart so Windows socket teardown cannot collide with the next process.
    final sockets = <ServerSocket>[];
    for (var i = 0; i < 3; i++) {
      sockets.add(await ServerSocket.bind(InternetAddress.loopbackIPv4, 0));
    }
    final ports = sockets.map((s) => s.port).toList();
    for (final socket in sockets) {
      await socket.close();
    }
    final process = await Process.start(
      executable,
      [name],
      workingDirectory: server,
      environment: {
        'SERVERPOD_API_SERVER_PORT': '${ports[0]}',
        'SERVERPOD_INSIGHTS_SERVER_PORT': '${ports[1]}',
        'SERVERPOD_WEB_SERVER_PORT': '${ports[2]}',
      },
    );
    final log = File('$root/.local/publication-worker-$name.log').openWrite();
    process.stderr.listen(log.add);
    final lines = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    final probe = _Probe(process, lines, log);
    probes.add(probe);
    while (await lines.moveNext().timeout(const Duration(seconds: 90))) {
      log.writeln(lines.current);
      if (lines.current == 'PUBLICATION_READY') return probe;
    }
    throw StateError('Publication probe did not start');
  }

  void require(bool ok, String reason) {
    if (!ok) throw StateError(reason);
  }

  try {
    var a = await start('a', 18780);
    final b = await start('b', 18880);
    for (final operation in ['receive', 'add', 'update', 'cancel', 'reopen']) {
      for (final stage in ['before', 'after']) {
        final id = cal.Uuid().v4();
        final key = cal.Uuid().v4();
        Future<Map<String, dynamic>> receive(
          int sequence, {
          bool cancel = false,
        }) => b.command({
          'command': 'receive',
          'caseId': id,
          'key': cal.Uuid().v4(),
          'wire': _wire(id, sequence, cancel: cancel),
        });
        late Map<String, Object?> command;
        if (operation == 'receive') {
          command = {
            'command': 'receive',
            'caseId': id,
            'key': key,
            'wire': _wire(id, 0),
          };
        } else {
          final source = await receive(0),
              parent = await b.command({'command': 'calendar', 'caseId': id});
          final add = {
            'entryId': source['entryId'],
            'sourceId': source['sourceId'],
            'expectedRevision': source['entryRevision'],
            'calendarId': parent['calendarId'],
            'expectedCalendarRevision': 1,
            'commandId': cal.Uuid().v4(),
          };
          if (operation == 'add') {
            command = {'command': 'add', 'caseId': id, 'request': add};
          } else {
            final created = await b.command({
              'command': 'add',
              'caseId': id,
              'request': add,
            });
            var expected = 1;
            if (operation == 'reopen') {
              final cancelled = await receive(1, cancel: true);
              await b.command({
                'command': 'apply',
                'caseId': id,
                'request': {
                  'entryId': source['entryId'],
                  'sourceId': cancelled['sourceId'],
                  'expectedRevision': cancelled['entryRevision'],
                  'expectedEventRevision': 1,
                  'commandId': cal.Uuid().v4(),
                },
              });
              expected = 2;
            }
            final newer = await receive(
              operation == 'reopen' ? 2 : 1,
              cancel: operation == 'cancel',
            );
            command = {
              'command': 'apply',
              'caseId': id,
              'request': {
                'entryId': newer['entryId'],
                'sourceId': newer['sourceId'],
                'expectedRevision': newer['entryRevision'],
                'expectedEventRevision': expected,
                'commandId': cal.Uuid().v4(),
              },
            };
            require(created['eventId'] != null, 'Probe adoption failed');
          }
        }
        a.paused = Completer<void>();
        final lost = a
            .command({...command, 'pause': stage})
            .then<Object?>((v) => v, onError: (Object e) => e);
        await a.paused!.future.timeout(const Duration(seconds: 45));
        await a.stop();
        await lost;
        if (stage == 'after') {
          final marker = File('$root/.local/publication-$id.revoked');
          markers.add(marker);
          await marker.writeAsString('synthetic');
          final denied = await b.command(command);
          require(
            denied['error'] == 'accessDenied',
            'Historical receipt bypassed current source authority',
          );
          await marker.delete();
        }
        final recovered = await b.command(command),
            retry = await b.command(command);
        require(
          recovered['error'] == null && retry['error'] == null,
          'Recovery command rejected: $recovered',
        );
        require(
          operation == 'receive'
              ? recovered['id'] == retry['id']
              : recovered['eventId'] == retry['eventId'] &&
                    retry['unchanged'] == true,
          'Receipt identity changed after loss',
        );
        final state = await b.command({'command': 'inspect', 'caseId': id});
        require(
          state['entries'] == 1 &&
              state['events'] == (operation == 'receive' ? 0 : 1),
          'Recovery duplicated state',
        );
        if (operation != 'receive') {
          require(
            (state['revisions'] as List).single ==
                (operation == 'add'
                    ? 1
                    : operation == 'reopen'
                    ? 3
                    : 2),
            'Recovery committed mutation twice',
          );
        }
        print(
          'PASS: publication $operation $stage-commit process loss and reauthorized exact retry.',
        );
        if (operation != 'reopen' || stage != 'after') {
          a = await start('a-$operation-$stage', 18780);
        }
      }
    }
  } finally {
    for (final probe in probes.reversed) {
      await probe.stop();
    }
    for (final marker in markers) {
      if (await marker.exists()) await marker.delete();
    }
  }
}
