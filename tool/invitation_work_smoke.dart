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
    final adoptionCase = nextCase();
    final received = await a.command({
      'command': 'receive',
      'caseId': adoptionCase,
      'key': 'adopt',
    }) as Map;
    final calendar = await a.command({
      'command': 'calendar',
      'caseId': adoptionCase,
    }) as String;
    Map<String, Object?> adoptionRequest(Map received, String calendar) => {
      'invitationId': received['entryId'],
      'sourceId': received['sourceId'],
      'expectedRevision': 1,
      'calendarId': calendar,
      'expectedCalendarRevision': 1,
    };
    final body = adoptionRequest(received, calendar);
    final adopted = await Future.wait(
      [a, b].map(
        (p) => p.command({
          'command': 'adopt',
          'caseId': adoptionCase,
          'request': body,
        }),
      ),
    );
    require(
      (adopted.first as Map)['id'] != null &&
          (adopted.first as Map)['id'] == (adopted.last as Map)['id'],
      'Concurrent adoption failed stable one-event identity',
    );
    final adoptionState =
        await b.command({'command': 'inspect', 'caseId': adoptionCase}) as Map;
    require(
      adoptionState['events'] == 1 &&
          adoptionState['links'] == 1 &&
          adoptionState['dismissed'] == true,
      'Adoption was not atomic',
    );
    for (final pause in ['adopt-before', 'adopt-after']) {
      final id = nextCase();
      final source = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'source',
      }) as Map;
      final parent =
          await b.command({'command': 'calendar', 'caseId': id}) as String;
      final request = adoptionRequest(source, parent);
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({
            'command': 'adopt',
            'caseId': id,
            'request': request,
            'pause': pause,
          })
          .catchError((Object _) => null);
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      final visible =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      final committed = pause == 'adopt-after';
      require(
        visible['events'] == (committed ? 1 : 0) &&
            visible['links'] == (committed ? 1 : 0) &&
            visible['dismissed'] == committed,
        'Partial adoption visible across commit boundary',
      );
      await a.stop();
      await lost;
      final recovered = await b.command({
        'command': 'adopt',
        'caseId': id,
        'request': request,
      }) as Map;
      require(
        recovered['id'] != null &&
            (committed == (recovered['id'] == submitted['id'])),
        'Adoption process loss did not recover the correct retained receipt',
      );
      final state =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        state['events'] == 1 &&
            state['links'] == 1 &&
            state['dismissed'] == true,
        'Adoption recovery duplicated or lost state',
      );
      a = await start(
        'a-adoption-recovered-${committed ? 'after' : 'before'}',
        18780,
      );
    }
    Future<Map<String, Object?>> updateRequest(String id) async {
      final received = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'initial',
      }) as Map;
      final parent =
          await b.command({'command': 'calendar', 'caseId': id}) as String;
      await b.command({
        'command': 'adopt',
        'caseId': id,
        'request': adoptionRequest(received, parent),
      });
      await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'update',
        'sequence': 1,
        'summary': 'Updated',
      });
      final view = await b.command({
        'command': 'application',
        'caseId': id,
        'entryId': received['entryId'],
      }) as Map;
      return {
        'invitationId': view['invitationId'],
        'sourceId': view['incomingSourceId'],
        'expectedInvitationRevision': view['invitationRevision'],
        'linkId': view['linkId'],
        'expectedEventRevision': view['eventRevision'],
        'expectedCalendarRevision': view['calendarRevision'],
        'expectedApplicationRevision': view['applicationRevision'],
      };
    }

    final applyCase = nextCase(), applyBody = await updateRequest(applyCase);
    final appliedRace = await Future.wait(
      [a, b].map(
        (p) => p.command({
          'command': 'apply',
          'caseId': applyCase,
          'request': applyBody,
        }),
      ),
    );
    require(
      (appliedRace.first as Map)['id'] != null &&
          (appliedRace.first as Map)['id'] == (appliedRace.last as Map)['id'],
      'Competing update changed latest receipt',
    );
    for (final pause in ['apply-before', 'apply-after']) {
      final id = nextCase(), request = await updateRequest(id);
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({
            'command': 'apply',
            'caseId': id,
            'request': request,
            'pause': pause,
          })
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      final visible =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      final committed = pause == 'apply-after';
      require(
        visible['applications'] == (committed ? 1 : 0) &&
            visible['eventRevision'] == (committed ? 2 : 1) &&
            visible['dismissed'] == committed,
        'Update was partially visible',
      );
      await a.stop();
      await lost;
      final recovered = await b.command({
        'command': 'apply',
        'caseId': id,
        'request': request,
      }) as Map;
      require(
        recovered['id'] != null &&
            committed == (recovered['id'] == submitted['id']),
        'Update loss did not recover correct result',
      );
      final state =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        state['events'] == 1 &&
            state['links'] == 1 &&
            state['applications'] == 1 &&
            state['eventRevision'] == 2 &&
            state['dismissed'] == true,
        'Update recovery duplicated writes',
      );
      a = await start(
        'a-apply-recovered-${committed ? 'after' : 'before'}',
        18780,
      );
    }

    final cancellationRace = nextCase();
    await b.command({
      'command': 'receive',
      'caseId': cancellationRace,
      'key': 'seed',
    });
    await Future.wait([
      a.command({
        'command': 'receive',
        'caseId': cancellationRace,
        'key': 'request2',
        'sequence': 2,
      }),
      b.command({
        'command': 'receive',
        'caseId': cancellationRace,
        'key': 'cancel3',
        'sequence': 3,
        'cancel': true,
      }),
    ]);
    final racedCancellation = await b.command({
      'command': 'inspect',
      'caseId': cancellationRace,
    }) as Map;
    require(
      racedCancellation['kind'] == 'meetingCancellation' &&
          racedCancellation['events'] == 0,
      'REQUEST/CANCEL race selected wrong kind or created native state',
    );
    for (final pause in ['before', 'after']) {
      final id = nextCase();
      await b.command({'command': 'receive', 'caseId': id, 'key': 'seed'});
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({
            'command': 'receive',
            'caseId': id,
            'key': 'cancel-loss',
            'sequence': 1,
            'cancel': true,
            'pause': pause,
          })
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      final visible =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        visible['kind'] ==
                (pause == 'before' ? 'request' : 'meetingCancellation') &&
            visible['sources'] == (pause == 'before' ? 1 : 2),
        'Cancellation crossed commit boundary partially',
      );
      await a.stop();
      await lost;
      final recovered = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'cancel-loss',
        'sequence': 1,
        'cancel': true,
      }) as Map;
      require(
        (pause == 'after') == (recovered['id'] == submitted['id']),
        'Cancellation retry identity changed',
      );
      final state =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        state['kind'] == 'meetingCancellation' &&
            state['entries'] == 1 &&
            state['sources'] == 2 &&
            state['receipts'] == 2 &&
            state['events'] == 0 &&
            state['applications'] == 0,
        'Cancellation loss duplicated source or mutated native state',
      );
      a = await start('a-cancel-recovered-$pause', 18780);
    }
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
      'PASS: independent invitation hosts, duplicate/conflicting ingress and dismissal races, actual loss before/after commit, stable receipt recovery, one-event adoption and latest-update races/loss plus REQUEST/CANCEL races and cancellation loss/retry with no native mutation or partial state.',
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
