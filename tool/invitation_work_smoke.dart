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

Future<void> main(List<String> args) async {
  final occurrenceApply = args.contains('--occurrence-applications');
  final instance = args.contains('--instances');
  final recurring = occurrenceApply || instance || args.contains('--recurring');
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
        'CALENDAR_INVITATION_PROBE_RECURRING': '$recurring',
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
    if (occurrenceApply) {
      Future<Map> prepare(String id) async {
        final master = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'master',
          'sequence': 1,
        }) as Map;
        final calendar = await b.command({'command': 'calendar', 'caseId': id});
        final link = await b.command({
          'command': 'adopt',
          'caseId': id,
          'request': {
            'invitationId': master['entryId'],
            'sourceId': master['sourceId'],
            'expectedRevision': master['entryRevision'],
            'calendarId': calendar,
            'expectedCalendarRevision': 1,
          },
        }) as Map;
        require(link['eventId'] != null, 'Probe adoption failed');
        final source = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'instance',
          'instance': true,
          'sequence': 2,
        }) as Map;
        final v = await b.command({
          'command': 'occurrence-view',
          'caseId': id,
          'entryId': source['entryId'],
        }) as Map;
        require(
          v['canApply'] == true,
          'Occurrence preview unexpectedly blocked',
        );
        return {
          'invitationId': v['invitationId'],
          'sourceId': v['incomingSourceId'],
          'linkId': v['linkId'],
          'expectedInvitationRevision': v['invitationRevision'],
          'expectedEventRevision': v['eventRevision'],
          'expectedCalendarRevision': v['calendarRevision'],
          'expectedApplicationRevision': v['applicationRevision'],
          'expectedOccurrenceRevision': v['occurrenceRevision'],
        };
      }

      final raceId = nextCase();
      final raceRequest = await prepare(raceId);
      final race = await Future.wait(
        [a, b].map(
          (p) => p.command({
            'command': 'occurrence-apply',
            'caseId': raceId,
            'request': raceRequest,
          }),
        ),
      );
      require(
        (race.first as Map)['id'] != null &&
            (race.first as Map)['id'] == (race.last as Map)['id'],
        'Occurrence race duplicated effect/result',
      );
      for (final pause in ['occurrence-before', 'occurrence-after']) {
        final id = nextCase(), request = await prepare(id);
        a.paused = Completer<Map<String, dynamic>>();
        final lost = a
            .command({
              'command': 'occurrence-apply',
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
        require(
          visible['occurrenceApplications'] ==
                  (pause == 'occurrence-before' ? 0 : 1) &&
              visible['eventRevision'] ==
                  (pause == 'occurrence-before' ? 1 : 2),
          'Partial occurrence application visible',
        );
        await a.stop();
        await lost;
        final recovered = await b.command({
          'command': 'occurrence-apply',
          'caseId': id,
          'request': request,
        }) as Map;
        require(
          recovered['id'] != null &&
              ((pause == 'occurrence-after') ==
                  (recovered['id'] == submitted['id'])),
          'Occurrence loss recovery changed retry semantics',
        );
        final complete =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          complete['occurrenceApplications'] == 1 &&
              complete['eventRevision'] == 2 &&
              complete['applications'] == 0,
          'Occurrence recovery duplicated state or overwrote master acceptance',
        );
        a = await start('a-occurrence-recovered-$pause', 18780);
      }
      Future<Map<String, dynamic>> composedCommand(String id) async {
        final incoming = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'new-master',
          'sequence': 3,
        }) as Map;
        final v = await b.command({
          'command': 'application',
          'caseId': id,
          'entryId': incoming['entryId'],
        }) as Map;
        require(
          v['canApply'] == true && v['occurrenceRevision'] == 1,
          'Composed master preview failed',
        );
        return {
          'invitationId': v['invitationId'],
          'sourceId': v['incomingSourceId'],
          'linkId': v['linkId'],
          'expectedInvitationRevision': v['invitationRevision'],
          'expectedEventRevision': v['eventRevision'],
          'expectedCalendarRevision': v['calendarRevision'],
          'expectedApplicationRevision': v['applicationRevision'],
          'expectedOccurrenceRevision': v['occurrenceRevision'],
        };
      }

      // Actual process loss around the atomic master/event/occurrence write.
      for (final pause in ['apply-before', 'apply-after']) {
        final id = nextCase(), occurrence = await prepare(id);
        final original = await b.command({
          'command': 'occurrence-apply',
          'caseId': id,
          'request': occurrence,
        }) as Map;
        final request = await composedCommand(id);
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
        require(
          visible['eventRevision'] == (pause == 'apply-before' ? 2 : 3) &&
              visible['occurrenceRevision'] ==
                  (pause == 'apply-before' ? 1 : 2) &&
              visible['applications'] == (pause == 'apply-before' ? 0 : 1),
          'Composition partially visible',
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
              ((pause == 'apply-after') ==
                  (recovered['id'] == submitted['id'])),
          'Composition loss retry changed result',
        );
        final retry = await b.command({
          'command': 'occurrence-apply',
          'caseId': id,
          'request': occurrence,
        }) as Map;
        require(
          retry['id'] == original['id'],
          'Composition lost historical occurrence receipt',
        );
        a = await start('a-composition-recovered-$pause', 18780);
      }
      // Different valid master/instance commands from one snapshot have one winner.
      final id = nextCase(), initial = await prepare(id);
      await b.command({
        'command': 'occurrence-apply',
        'caseId': id,
        'request': initial,
      });
      final masterRequest = await composedCommand(id);
      final source = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'next-instance',
        'instance': true,
        'sequence': 4,
      }) as Map;
      final v = await b.command({
        'command': 'occurrence-view',
        'caseId': id,
        'entryId': source['entryId'],
      }) as Map;
      final instanceRequest = {
        'invitationId': v['invitationId'],
        'sourceId': v['incomingSourceId'],
        'linkId': v['linkId'],
        'expectedInvitationRevision': v['invitationRevision'],
        'expectedEventRevision': v['eventRevision'],
        'expectedCalendarRevision': v['calendarRevision'],
        'expectedApplicationRevision': v['applicationRevision'],
        'expectedOccurrenceRevision': v['occurrenceRevision'],
      };
      final compositionRace = await Future.wait([
        a.command({'command': 'apply', 'caseId': id, 'request': masterRequest}),
        b.command({
          'command': 'occurrence-apply',
          'caseId': id,
          'request': instanceRequest,
        }),
      ]);
      require(
        compositionRace.where((r) => (r as Map)['id'] != null).length == 1 &&
            compositionRace
                    .where((r) => (r as Map)['error'] == 'staleRevision')
                    .length ==
                1,
        'Master/instance revision fence failed',
      );
      stdout.writeln(
        'PASS: independent occurrence-application hosts, same-command race, atomic event/checkpoint/review visibility and actual loss before/after occurrence and composed-master commits, historical retry recovery and master/instance races.',
      );
      return;
    }
    if (instance) {
      final id = nextCase();
      await b.command({'command': 'receive', 'caseId': id, 'key': 'master'});
      final incoming = {
        'command': 'receive',
        'caseId': id,
        'key': 'instance',
        'instance': true,
        'sequence': 1,
      };
      final raced = await Future.wait([a, b].map((p) => p.command(incoming)));
      require(
        (raced.first as Map)['id'] != null &&
            (raced.first as Map)['id'] == (raced.last as Map)['id'],
        'Instance ingress race duplicated receipt',
      );
      final distinct = await Future.wait([
        a.command({
          ...incoming,
          'key': 'cancel',
          'cancel': true,
          'sequence': 2,
        }),
        b.command({
          ...incoming,
          'key': 'period',
          'original': '20300105T090000Z',
        }),
      ]);
      require(
        distinct.every((v) => (v as Map)['id'] != null),
        'Independent targets blocked each other',
      );
      final state =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        state['entries'] == 3 &&
            state['events'] == 0 &&
            state['links'] == 0 &&
            (state['targets'] as List)
                    .where((v) => (v as Map)['target'] == 'master')
                    .length ==
                1,
        'Instance target race changed master/native state',
      );
      for (final pause in ['before', 'after']) {
        final lossId = nextCase();
        await b.command({
          'command': 'receive',
          'caseId': lossId,
          'key': 'master',
        });
        a.paused = Completer<Map<String, dynamic>>();
        final input = {
          'command': 'receive',
          'caseId': lossId,
          'key': 'loss',
          'instance': true,
          'sequence': 1,
        };
        final lost = a
            .command({...input, 'pause': pause})
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final submitted = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        final visible =
            await b.command({'command': 'inspect', 'caseId': lossId}) as Map;
        require(
          visible['entries'] == (pause == 'before' ? 1 : 2) &&
              visible['receipts'] == (pause == 'before' ? 1 : 2),
          'Instance source/target partially visible around commit',
        );
        await a.stop();
        await lost;
        final recovered = await b.command(input) as Map;
        require(
          recovered['id'] != null &&
              ((pause == 'after') == (recovered['id'] == submitted['id'])),
          'Instance loss recovery retargeted retained receipt',
        );
        final complete =
            await b.command({'command': 'inspect', 'caseId': lossId}) as Map;
        require(
          complete['entries'] == 2 &&
              complete['sources'] == 2 &&
              complete['receipts'] == 2 &&
              complete['events'] == 0 &&
              complete['applications'] == 0,
          'Instance recovery duplicated intent or mutated native state',
        );
        a = await start('a-instance-recovered-$pause', 18780);
      }
      stdout.writeln(
        'PASS: independent instance invitation hosts, shared-key and distinct-original races, master/native isolation, actual loss before/after commit and exact retained receipt recovery through synthetic MIME.',
      );
      return;
    }
    // Explicit responses run in real independent hosts against the same storage.
    for (final pause in ['response-before', 'response-after']) {
      final id = nextCase();
      final incoming = await b.command({
        'command': 'receive',
        'caseId': id,
        'key': 'response',
      }) as Map;
      final request = cal.CalendarInvitationResponseRequest(
        invitationId: cal.UuidValue.fromString(incoming['entryId'] as String),
        expectedInvitationRevision: incoming['entryRevision'] as int,
        sourceId: cal.UuidValue.fromString(incoming['sourceId'] as String),
        expectedResponseRevision: 0,
        commandId: const cal.Uuid().v4obj(),
        choice: cal.CalendarInvitationResponseChoice.declined,
      );
      final raced = await Future.wait(
        [a, b].map(
          (p) => p.command({
            'command': 'response',
            'caseId': id,
            'request': request.toJson(),
          }),
        ),
      );
      require(
        (raced.first as Map)['id'] == (raced.last as Map)['id'] &&
            (raced.first as Map)['id'] != null,
        'Cross-host command retry duplicated response',
      );
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({'command': 'response-work', 'caseId': id, 'pause': pause})
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      await b.command({'command': 'response-work', 'caseId': id});
      final claimed =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        ((claimed['responses'] as List).single as Map)['attempts'] == 1,
        'Competing host bypassed active response lease',
      );
      await a.stop();
      await lost;
      await b.command({'command': 'response-expire-lease', 'caseId': id});
      await b.command({'command': 'response-work', 'caseId': id});
      final recovered =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      final row = (recovered['responses'] as List).single as Map;
      require(
        row['state'] == 'accepted' &&
            row['attempts'] == 2 &&
            recovered['events'] == 0 &&
            recovered['links'] == 0,
        'Response loss recovery changed calendar state or failed takeover',
      );
      final records = await File(
        '$root/.local/invitation-response-probe-$id.jsonl',
      ).readAsLines();
      require(
        records.length == (pause == 'response-after' ? 2 : 1),
        'Incorrect synthetic acceptance evidence',
      );
      for (final line in records) {
        final evidence = jsonDecode(line) as Map;
        require(
          evidence['key'] == submitted['key'] &&
              evidence['digest'] == submitted['digest'],
          'Response recovery changed stable delivery identity or bytes',
        );
      }
      a = await start('a-response-recovered-$pause', 18780);
    }
    for (final revoke in [false, true]) {
      final id = nextCase();
      final incoming = await a.command({
        'command': 'receive',
        'caseId': id,
        'key': 'response',
      }) as Map;
      final request = cal.CalendarInvitationResponseRequest(
        invitationId: cal.UuidValue.fromString(incoming['entryId'] as String),
        expectedInvitationRevision: incoming['entryRevision'] as int,
        sourceId: cal.UuidValue.fromString(incoming['sourceId'] as String),
        expectedResponseRevision: 0,
        commandId: const cal.Uuid().v4obj(),
        choice: cal.CalendarInvitationResponseChoice.accepted,
      );
      final commands = await Future.wait(
        [a, b].map(
          (p) => p.command({
            'command': 'response',
            'caseId': id,
            'request': request
                .copyWith(commandId: const cal.Uuid().v4obj())
                .toJson(),
          }),
        ),
      );
      require(
        commands.where((r) => (r as Map)['id'] != null).length == 1 &&
            commands
                    .where((r) => (r as Map)['error'] == 'staleRevision')
                    .length ==
                1,
        'Response CAS race did not have exactly one winner',
      );
      if (revoke) {
        await a.command({'command': 'response-revoke', 'caseId': id});
      } else {
        await a.command({
          'command': 'receive',
          'caseId': id,
          'key': 'new-source',
          'sequence': 1,
        });
      }
      await b.command({'command': 'response-work', 'caseId': id});
      final inspected =
          await a.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        ((inspected['responses'] as List).single as Map)['state'] ==
                'withdrawn' &&
            !await File('$root/.local/invitation-response-probe-$id.jsonl')
                .exists(),
        'Changed source/access dispatched a stale response',
      );
    }
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
    Future<Map<String, Object?>> updateRequest(
      String id, {
      bool cancellation = false,
    }) async {
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
        'cancel': cancellation,
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

    final cancelApplyCase = nextCase(),
        cancelApplyBody = await updateRequest(
          cancelApplyCase,
          cancellation: true,
        );
    final cancelledRace = await Future.wait([
      for (final p in [a, b])
        p.command({
          'command': 'apply',
          'caseId': cancelApplyCase,
          'request': cancelApplyBody,
          'cancel': true,
        }),
    ]);
    require(
      (cancelledRace.first as Map)['id'] != null &&
          (cancelledRace.first as Map)['id'] ==
              (cancelledRace.last as Map)['id'] &&
          (cancelledRace.first as Map)['kind'] == 'meetingCancellation',
      'Competing cancellation application changed result',
    );
    for (final pause in ['cancel-apply-before', 'cancel-apply-after']) {
      final id = nextCase(),
          request = await updateRequest(id, cancellation: true);
      a.paused = Completer<Map<String, dynamic>>();
      final lost = a
          .command({
            'command': 'apply',
            'caseId': id,
            'request': request,
            'cancel': true,
            'pause': pause,
          })
          .then<void>((_) {}, onError: (Object _, StackTrace _) {});
      final submitted = await a.paused!.future.timeout(
        const Duration(seconds: 40),
      );
      final visible =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      final committed = pause == 'cancel-apply-after';
      require(
        visible['eventStatus'] == (committed ? 'cancelled' : 'confirmed') &&
            visible['acceptedKind'] ==
                (committed ? 'meetingCancellation' : null) &&
            visible['applications'] == (committed ? 1 : 0) &&
            visible['dismissed'] == committed,
        'Cancellation application was partially visible',
      );
      await a.stop();
      await lost;
      final recovered = await b.command({
        'command': 'apply',
        'caseId': id,
        'request': request,
        'cancel': true,
      }) as Map;
      require(
        recovered['id'] != null &&
            committed == (recovered['id'] == submitted['id']),
        'Cancellation application lost stable retry identity',
      );
      final state =
          await b.command({'command': 'inspect', 'caseId': id}) as Map;
      require(
        state['eventStatus'] == 'cancelled' &&
            state['acceptedKind'] == 'meetingCancellation' &&
            state['events'] == 1 &&
            state['links'] == 1 &&
            state['applications'] == 1 &&
            state['eventRevision'] == 2 &&
            state['dismissed'] == true,
        'Cancellation application recovery duplicated or lost state',
      );
      a = await start(
        'a-cancel-apply-recovered-${committed ? 'after' : 'before'}',
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
      'PASS: ${recurring ? 'recurring-master' : 'non-recurring'} independent invitation hosts, response command/CAS races, competing response leases, actual loss before/after response acceptance with stable key/bytes, cross-host source/access withdrawal, duplicate ingress/dismissal, adoption/update/cancellation races and commit-loss recovery.',
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
