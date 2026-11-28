import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as cal;

bool _recurringResponseMode = false;
// This is the test client's frozen command cache, surviving owned server loss.
final _recurringCommands = <String, Map<String, dynamic>>{};

final class _Probe {
  _Probe(this.process, this.lines, this.log) {
    unawaited(process.exitCode.then((_) => exited = true));
  }
  final Process process;
  final StreamIterator<String> lines;
  final IOSink log;
  bool stopped = false, exited = false;
  bool busy = false, unusable = false;
  Completer<Map<String, dynamic>>? paused;
  Future<Object?> command(Map<String, Object?> input) async {
    if (_recurringResponseMode && input['command'] == 'recurring-response') {
      final key = jsonEncode([
        input['request'],
        input['originalStart'],
        input['openedId'],
      ]);
      var frozen = _recurringCommands[key];
      if (frozen == null) {
        final result = await command({
          ...input,
          'command': 'recurring-response-freeze',
          'pause': '',
        });
        if (result is! Map || result['request'] == null) {
          return result;
        }
        frozen = Map<String, dynamic>.from(result);
        _recurringCommands[key] = frozen;
      }
      input = {...input, 'selectionRequest': frozen};
    }
    if (busy || unusable) {
      throw StateError('Probe cannot accept another command');
    }
    busy = true;
    try {
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
    } catch (_) {
      unusable = true;
      rethrow;
    } finally {
      busy = false;
    }
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
  final recurringResponses = args.contains('--recurring-responses');
  _recurringResponseMode = recurringResponses;
  final bundles = args.contains('--bundles');
  final bundleResponses = args.contains('--bundle-responses');
  final bundleOccurrenceResponses = args.contains(
    '--bundle-occurrence-responses',
  );
  final nativeFuture = args.contains('--native-future');
  final rangeCycles = args.contains('--range-cycles');
  final restoredRanges = args.contains('--restored-ranges');
  final restoredSingles = args.contains('--restored-singles');
  final restoredLifecycle = args.contains('--restored-lifecycle');
  final restoredCompose =
      args.contains('--restoration-compositions') ||
      restoredLifecycle ||
      restoredSingles ||
      restoredRanges ||
      rangeCycles;
  final rangeRestoration =
      args.contains('--range-restorations') || restoredCompose;
  final rangeLifecycle = args.contains('--range-lifecycle');
  final rangeCompose =
      args.contains('--range-compositions') ||
      rangeLifecycle ||
      rangeRestoration;
  final rangeCancel = args.contains('--range-cancellations') || rangeCompose;
  final rangeApply = args.contains('--range-applications') || rangeCancel;
  final occurrenceApply =
      args.contains('--occurrence-applications') || rangeApply;
  final instanceResponses = args.contains('--instance-responses');
  final ranges = args.contains('--ranges');
  final instance = args.contains('--instances') || ranges;
  final recurring =
      bundles ||
      recurringResponses ||
      bundleResponses ||
      bundleOccurrenceResponses ||
      instanceResponses ||
      occurrenceApply ||
      instance ||
      args.contains('--recurring');
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
        'CALENDAR_INVITATION_PROBE_RECURRING_RESPONSES': '$recurringResponses',
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
    if (bundles) {
      Map<String, Object?> request(Map source, String parent) => {
        'invitationId': source['entryId'],
        'expectedRevision': 1,
        'sourceId': source['sourceId'],
        'calendarId': parent,
        'expectedCalendarRevision': 1,
      };
      for (final pause in [
        '',
        'before',
        'after',
        'adopt-before',
        'adopt-after',
      ]) {
        final id = nextCase();
        final packet = <String, Object?>{
          'command': 'receive',
          'bundle': true,
          'caseId': id,
          'key': 'initial',
        };
        late Map source;
        if (pause == 'before' || pause == 'after') {
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({...packet, 'pause': pause})
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          final submitted = await a.paused!.future.timeout(
            const Duration(seconds: 40),
          );
          final visible =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            visible['sources'] == (pause == 'after' ? 1 : 0),
            'Partial bundle intake visible',
          );
          await a.stop();
          await lost;
          source = await b.command(packet) as Map;
          require(
            (source['id'] == submitted['id']) == (pause == 'after'),
            'Bundle receipt recovery changed identity',
          );
          a = await start('a-bundle-intake-$pause', 18780);
        } else {
          source = await b.command(packet) as Map;
        }
        final parent =
            await b.command({'command': 'calendar', 'caseId': id}) as String;
        final body = request(source, parent);
        Map result;
        if (pause.startsWith('adopt-')) {
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({
                'command': 'adopt',
                'caseId': id,
                'request': body,
                'pause': pause,
              })
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          final submitted = await a.paused!.future.timeout(
            const Duration(seconds: 40),
          );
          final visible =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            visible['events'] == (pause == 'adopt-after' ? 1 : 0) &&
                visible['links'] == (pause == 'adopt-after' ? 1 : 0),
            'Partial bundle adoption visible',
          );
          await a.stop();
          await lost;
          result = await b.command({
            'command': 'adopt',
            'caseId': id,
            'request': body,
          }) as Map;
          require(
            (result['id'] == submitted['id']) == (pause == 'adopt-after'),
            'Bundle adoption receipt changed',
          );
          a = await start('a-bundle-$pause', 18780);
        } else {
          final raced = await Future.wait(
            [a, b].map(
              (p) => p.command({
                'command': 'adopt',
                'caseId': id,
                'request': body,
              }),
            ),
          );
          result = raced.first as Map;
          require(
            result['id'] != null && result['id'] == (raced.last as Map)['id'],
            'Bundle adoption race duplicated identity',
          );
        }
        final state =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          result['bundledRequest'] == true &&
              state['events'] == 1 &&
              state['bundledLinks'] == 1 &&
              state['singleCount'] == 1 &&
              state['futureCount'] == 1 &&
              (state['responses'] as List).isEmpty,
          'Bundle recovery lost components or created participation state',
        );
      }
      for (final pause in [
        '',
        'before',
        'after',
        'bundle-before',
        'bundle-after',
      ]) {
        final id = nextCase();
        final packet = <String, Object?>{
          'command': 'receive',
          'bundle': true,
          'caseId': id,
          'key': 'initial',
        };
        final source = await b.command(packet) as Map;
        final parent =
            await b.command({'command': 'calendar', 'caseId': id}) as String;
        await b.command({
          'command': 'adopt',
          'caseId': id,
          'request': request(source, parent),
        });
        final update = <String, Object?>{
          ...packet,
          'key': 'child-update',
          'bundleChild': 1,
        };
        if (pause == 'before' || pause == 'after') {
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({...update, 'pause': pause})
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          final submitted = await a.paused!.future.timeout(
            const Duration(seconds: 40),
          );
          final visible =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            visible['sources'] == (pause == 'after' ? 2 : 1) &&
                visible['eventRevision'] == 1,
            'Component-aware intake partially changed native state',
          );
          await a.stop();
          await lost;
          final recovered = await b.command(update) as Map;
          require(
            (recovered['id'] == submitted['id']) == (pause == 'after'),
            'Update ingress receipt identity changed',
          );
          a = await start('a-bundle-update-intake-$pause', 18780);
        } else {
          final raced = await Future.wait([a, b].map((p) => p.command(update)));
          require(
            (raced.first as Map)['id'] == (raced.last as Map)['id'],
            'Update ingress race changed identity',
          );
        }
        final view = await b.command({
          'command': 'bundle-view',
          'caseId': id,
          'entryId': source['entryId'],
        }) as Map;
        require(
          view['canApply'] == true,
          'Complete pending update is not applicable',
        );
        final body = <String, Object?>{
          'invitationId': view['invitationId'],
          'sourceId': view['incomingSourceId'],
          'expectedInvitationRevision': view['invitationRevision'],
          'linkId': view['linkId'],
          'expectedEventRevision': view['eventRevision'],
          'expectedCalendarRevision': view['calendarRevision'],
          'expectedApplicationRevision': view['applicationRevision'],
        };
        Map result;
        if (pause.startsWith('bundle-')) {
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({
                'command': 'bundle-apply',
                'caseId': id,
                'request': body,
                'pause': pause,
              })
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          final submitted = await a.paused!.future.timeout(
            const Duration(seconds: 40),
          );
          final visible =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            visible['eventRevision'] == (pause == 'bundle-after' ? 2 : 1) &&
                visible['applications'] == (pause == 'bundle-after' ? 1 : 0),
            'Partial bundle application visible',
          );
          await a.stop();
          await lost;
          result = await b.command({
            'command': 'bundle-apply',
            'caseId': id,
            'request': body,
          }) as Map;
          require(
            (result['id'] == submitted['id']) == (pause == 'bundle-after'),
            'Update recovery changed result identity',
          );
          a = await start('a-bundle-update-$pause', 18780);
        } else {
          final raced = await Future.wait(
            [a, b].map(
              (p) => p.command({
                'command': 'bundle-apply',
                'caseId': id,
                'request': body,
              }),
            ),
          );
          result = raced.first as Map;
          require(
            result['id'] != null && result['id'] == (raced.last as Map)['id'],
            'Bundle apply race changed latest receipt',
          );
        }
        final retry = await b.command({
          'command': 'bundle-apply',
          'caseId': id,
          'request': body,
        }) as Map;
        final state =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          retry['id'] == result['id'] &&
              state['events'] == 1 &&
              state['links'] == 1 &&
              state['applications'] == 1 &&
              state['eventRevision'] == 2 &&
              state['acceptedKind'] == 'requestBundle' &&
              (state['bundleVersions'] as List).contains(1) &&
              (state['responses'] as List).isEmpty,
          'Bundle update lost components or reactivated retry',
        );
      }
      for (final mode in ['cancel', 'reopen']) {
        for (final pause in [
          '',
          'before',
          'after',
          'bundle-before',
          'bundle-after',
        ]) {
          final id = nextCase();
          final packet = <String, Object?>{
            'command': 'receive',
            'bundle': true,
            'caseId': id,
            'key': 'initial',
          };
          final source = await b.command(packet) as Map;
          final parent =
              await b.command({'command': 'calendar', 'caseId': id}) as String;
          await b.command({
            'command': 'adopt',
            'caseId': id,
            'request': request(source, parent),
          });
          Map<String, Object?> bodyFor(Map view) => {
            'invitationId': view['invitationId'],
            'sourceId': view['incomingSourceId'],
            'expectedInvitationRevision': view['invitationRevision'],
            'linkId': view['linkId'],
            'expectedEventRevision': view['eventRevision'],
            'expectedCalendarRevision': view['calendarRevision'],
            'expectedApplicationRevision': view['applicationRevision'],
          };
          if (mode == 'reopen') {
            await b.command({
              'command': 'receive',
              'caseId': id,
              'key': 'prior-cancel',
              'cancel': true,
              'sequence': 13,
            });
            final cancelledView = await b.command({
              'command': 'bundle-view',
              'caseId': id,
              'entryId': source['entryId'],
            }) as Map;
            await b.command({
              'command': 'bundle-apply',
              'mode': 'cancel',
              'caseId': id,
              'request': bodyFor(cancelledView),
            });
          }
          final initialRevision = mode == 'reopen' ? 2 : 1;
          final initialSources = mode == 'reopen' ? 2 : 1;
          final update = <String, Object?>{
            'command': 'receive',
            'caseId': id,
            'key': 'lifecycle-$mode',
            if (mode == 'cancel') ...{
              'cancel': true,
              'sequence': 13,
            } else ...{
              'bundle': true,
              'sequence': 14,
            },
          };
          if (pause == 'before' || pause == 'after') {
            a.paused = Completer<Map<String, dynamic>>();
            final lost = a
                .command({...update, 'pause': pause})
                .then<void>((_) {}, onError: (Object _, StackTrace _) {});
            final submitted = await a.paused!.future.timeout(
              const Duration(seconds: 40),
            );
            final visible =
                await b.command({'command': 'inspect', 'caseId': id}) as Map;
            require(
              visible['sources'] ==
                      (pause == 'after'
                          ? initialSources + 1
                          : initialSources) &&
                  visible['eventRevision'] == initialRevision,
              'Component-aware intake partially changed native state',
            );
            await a.stop();
            await lost;
            final recovered = await b.command(update) as Map;
            require(
              (recovered['id'] == submitted['id']) == (pause == 'after'),
              'Update ingress receipt identity changed',
            );
            a = await start('a-bundle-update-intake-$pause', 18780);
          } else {
            final raced = await Future.wait(
              [a, b].map((p) => p.command(update)),
            );
            require(
              (raced.first as Map)['id'] == (raced.last as Map)['id'],
              'Update ingress race changed identity',
            );
          }
          final view = await b.command({
            'command': 'bundle-view',
            'caseId': id,
            'entryId': source['entryId'],
          }) as Map;
          require(
            view[mode == 'cancel' ? 'canApplyCancellation' : 'canReopen'] ==
                true,
            'Complete pending update is not applicable',
          );
          final body = <String, Object?>{
            'invitationId': view['invitationId'],
            'sourceId': view['incomingSourceId'],
            'expectedInvitationRevision': view['invitationRevision'],
            'linkId': view['linkId'],
            'expectedEventRevision': view['eventRevision'],
            'expectedCalendarRevision': view['calendarRevision'],
            'expectedApplicationRevision': view['applicationRevision'],
          };
          Map result;
          if (pause.startsWith('bundle-')) {
            a.paused = Completer<Map<String, dynamic>>();
            final lost = a
                .command({
                  'command': 'bundle-apply',
                  'mode': mode,
                  'caseId': id,
                  'request': body,
                  'pause': pause,
                })
                .then<void>((_) {}, onError: (Object _, StackTrace _) {});
            final submitted = await a.paused!.future.timeout(
              const Duration(seconds: 40),
            );
            final visible =
                await b.command({'command': 'inspect', 'caseId': id}) as Map;
            require(
              visible['eventRevision'] ==
                      (pause == 'bundle-after'
                          ? initialRevision + 1
                          : initialRevision) &&
                  visible['applications'] ==
                      (mode == 'reopen'
                          ? 1
                          : pause == 'bundle-after'
                          ? 1
                          : 0),
              'Partial bundle application visible',
            );
            await a.stop();
            await lost;
            result = await b.command({
              'command': 'bundle-apply',
              'mode': mode,
              'caseId': id,
              'request': body,
            }) as Map;
            require(
              (result['id'] == submitted['id']) == (pause == 'bundle-after'),
              'Update recovery changed result identity',
            );
            a = await start('a-bundle-update-$pause', 18780);
          } else {
            final raced = await Future.wait(
              [a, b].map(
                (p) => p.command({
                  'command': 'bundle-apply',
                  'mode': mode,
                  'caseId': id,
                  'request': body,
                }),
              ),
            );
            result = raced.first as Map;
            require(
              result['id'] != null && result['id'] == (raced.last as Map)['id'],
              'Bundle apply race changed latest receipt',
            );
          }
          final retry = await b.command({
            'command': 'bundle-apply',
            'mode': mode,
            'caseId': id,
            'request': body,
          }) as Map;
          final state =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            retry['id'] == result['id'] &&
                state['events'] == 1 &&
                state['links'] == 1 &&
                state['applications'] == 1 &&
                state['eventRevision'] == initialRevision + 1 &&
                state['acceptedKind'] ==
                    (mode == 'cancel'
                        ? 'bundleCancellation'
                        : 'requestBundle') &&
                (state['bundleVersions'] as List).contains(12) &&
                (state['responses'] as List).isEmpty,
            'Bundle update lost components or reactivated retry',
          );
        }
      }
      stdout.writeln(
        'PASS: complete bundle adoption, updates and whole cancellation/reopening preserve components across two-host races and actual process loss before/after every commit boundary.',
      );
      return;
    }
    if (nativeFuture) {
      for (final restore in [false, true]) {
        for (final pause in ['native-before', 'native-after']) {
          final id = nextCase();
          final seed =
              await b.command({'command': 'native-seed', 'caseId': id}) as Map;
          final anchor = cal.CalendarEventTiming(
            kind: cal.CalendarEventTimeKind.utc,
            start: cal.CalendarEventCivil(
              year: 2026,
              month: 1,
              day: 3,
              hour: 9,
            ),
          );
          var input = cal.CalendarEventOccurrenceChange(
            eventId: cal.UuidValue.fromString(seed['eventId'] as String),
            expectedRevision: 1,
            originalStart: anchor,
            action: cal.CalendarEventOccurrenceAction.cancelFuture,
          );
          final race = await Future.wait(
            [a, b].map(
              (p) => p.command({
                'command': 'native-change',
                'caseId': id,
                'request': input.toJson(),
              }),
            ),
          );
          require(
            race.where((v) => (v as Map)['error'] == 'staleRevision').length ==
                1,
            'Native race must have one stale writer',
          );
          input = input.copyWith(
            expectedRevision: 2,
            action: restore
                ? cal.CalendarEventOccurrenceAction.restoreFuture
                : cal.CalendarEventOccurrenceAction.cancelFuture,
            originalStart: restore
                ? anchor
                : anchor.copyWith(start: anchor.start.copyWith(day: 2)),
          );
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({
                'command': 'native-change',
                'caseId': id,
                'request': input.toJson(),
                'pause': pause,
              })
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          await a.paused!.future.timeout(const Duration(seconds: 40));
          await a.stop();
          await lost;
          final current = await b.command({
            'command': 'native-inspect',
            'caseId': id,
            'eventId': seed['eventId'],
          }) as Map;
          require(
            current['revision'] == (pause == 'native-before' ? 2 : 3),
            'Native loss left partial revision',
          );
          require(
            current['cutoff'] ==
                (pause == 'native-before'
                    ? 3
                    : restore
                    ? null
                    : 2),
            'Native loss left partial cutoff',
          );
          final retried = await b.command({
            'command': 'native-change',
            'caseId': id,
            'request': input.toJson(),
          }) as Map;
          require(
            pause == 'native-before'
                ? retried['revision'] == 3
                : retried['error'] == 'staleRevision',
            'Native uncertain-write revision fencing failed',
          );
          a = await start(
            'native-recovered-${restore ? 'restore' : 'cancel'}-$pause',
            18780,
          );
        }
      }
      stdout.writeln(
        'PASS: actual two-host native cutoff races and before/after cancellation/restoration commit loss; survivor revision reconciliation.',
      );
      return;
    }
    if (bundleResponses || bundleOccurrenceResponses || recurringResponses) {
      final responseCommand = recurringResponses
          ? 'recurring-response'
          : bundleOccurrenceResponses
          ? 'bundle-occurrence-response'
          : 'bundle-response';
      if (recurringResponses) {
        for (final pause in ['before', 'after']) {
          final id = nextCase();
          final input = <String, Object?>{
            'command': 'receive',
            'caseId': id,
            'key': 'initial',
            'sequence': 2,
          };
          a.paused = Completer<Map<String, dynamic>>();
          final lost = a
              .command({...input, 'pause': pause})
              .then<void>((_) {}, onError: (Object _, StackTrace _) {});
          final receipt = await a.paused!.future.timeout(
            const Duration(seconds: 40),
          );
          final seen =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            seen['selectionHeads'] == (pause == 'after' ? 1 : 0) &&
                seen['selectionEvidence'] == (pause == 'after' ? 1 : 0) &&
                seen['selectionPins'] == (pause == 'after' ? 1 : 0),
            'Partial or missing source-proof capture at process loss',
          );
          await a.stop();
          await lost;
          final retry = await b.command(input) as Map;
          require(
            (retry['id'] == receipt['id']) == (pause == 'after'),
            'Source-proof capture retry changed committed identity',
          );
          final complete =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            complete['selectionHeads'] == 1 &&
                complete['selectionEvidence'] == 1 &&
                complete['selectionPins'] == 1,
            'Source-proof capture recovery duplicated head/evidence/pins',
          );
          a = await start('a-recurring-proof-$pause', 18780);
        }
      }
      if (recurringResponses) {
        final id = nextCase();
        final root = await a.command({
          'command': 'receive',
          'caseId': id,
          'key': 'root',
          'sequence': 2,
        }) as Map;
        final notices = await Future.wait([
          a.command({
            'command': 'receive',
            'caseId': id,
            'key': 'three',
            'instance': true,
            'sequence': 3,
          }),
          b.command({
            'command': 'receive',
            'caseId': id,
            'key': 'five',
            'instance': true,
            'original': '20300105T090000Z',
            'sequence': 4,
          }),
        ]);
        final captured =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          captured['selectionHeads'] == 1 &&
              captured['selectionEvidence'] == 3 &&
              captured['selectionPins'] == 6,
          'Concurrent notices lost or duplicated the combined source history',
        );
        final point = cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(year: 2030, month: 1, day: 3, hour: 9),
        );
        final base = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(root['entryId'] as String),
          sourceId: cal.UuidValue.fromString(root['sourceId'] as String),
          expectedInvitationRevision: root['entryRevision'] as int,
          expectedResponseRevision: 0,
          commandId: const cal.Uuid().v4obj(),
          choice: cal.CalendarInvitationResponseChoice.accepted,
        );
        final choices = await Future.wait([
          a.command({
            'command': responseCommand,
            'caseId': id,
            'request': base.toJson(),
            'originalStart': point.toJson(),
          }),
          b.command({
            'command': responseCommand,
            'caseId': id,
            'openedId': (notices.first as Map)['entryId'],
            'originalStart': point.toJson(),
            'request': base
                .copyWith(
                  commandId: const cal.Uuid().v4obj(),
                  choice: cal.CalendarInvitationResponseChoice.declined,
                )
                .toJson(),
          }),
        ]);
        require(
          choices.where((v) => (v as Map)['id'] != null).length == 1 &&
              choices
                      .where((v) => (v as Map)['error'] == 'staleRevision')
                      .length ==
                  1,
          'Master/instance routes queued contradictory choices for one original',
        );
        stdout.writeln(
          'PASS: concurrent different-notice capture and cross-route competing choices share one original state.',
        );
      }
      for (final pause in ['response-before', 'response-after']) {
        final id = nextCase();
        final incoming = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'bundle',
          'bundle': !recurringResponses,
          'sequence': 2,
        }) as Map;
        final request = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(incoming['entryId'] as String),
          sourceId: cal.UuidValue.fromString(incoming['sourceId'] as String),
          expectedInvitationRevision: incoming['entryRevision'] as int,
          expectedResponseRevision: 0,
          commandId: const cal.Uuid().v4obj(),
          choice: cal.CalendarInvitationResponseChoice.declined,
        );
        final raced = await Future.wait(
          [a, b].map(
            (p) => p.command({
              'command': responseCommand,
              'caseId': id,
              'request': request.toJson(),
            }),
          ),
        );
        require(
          (raced.first as Map)['id'] != null &&
              (raced.first as Map)['id'] == (raced.last as Map)['id'],
          'Bundle master response race duplicated result',
        );
        a.paused = Completer<Map<String, dynamic>>();
        final lost = a
            .command({'command': 'response-work', 'caseId': id, 'pause': pause})
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final submitted = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        await b.command({'command': 'response-work', 'caseId': id});
        final visible =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          ((visible['responses'] as List).single as Map)['attempts'] == 1 &&
              visible['events'] == 0 &&
              visible['links'] == 0,
          'Competing bundle-master worker bypassed lease or adopted a calendar',
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
              recovered['events'] == 0,
          'Bundle master response recovery failed',
        );
        final records = await File(
          '$root/.local/invitation-response-probe-$id.jsonl',
        ).readAsLines();
        require(
          records.length == (pause == 'response-after' ? 2 : 1),
          'Wrong uncertain bundle-master delivery evidence',
        );
        for (final line in records) {
          final actual = jsonDecode(line) as Map;
          require(
            actual['key'] == submitted['key'] &&
                actual['digest'] == submitted['digest'] &&
                actual['mimeDigest'] == submitted['mimeDigest'],
            'Bundle master retry changed delivery identity/bytes',
          );
        }
        final retried = await b.command({
          'command': responseCommand,
          'caseId': id,
          'request': request.toJson(),
        }) as Map;
        require(
          retried['id'] == (raced.first as Map)['id'],
          'Recovered bundle-master command lost historical receipt',
        );
        a = await start('a-bundle-master-response-recovered-$pause', 18780);
      }
      for (final pause in ['bundle-response-before', 'bundle-response-after']) {
        final id = nextCase();
        final incoming = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'bundle',
          'bundle': !recurringResponses,
          'sequence': 2,
        }) as Map;
        final request = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(incoming['entryId'] as String),
          sourceId: cal.UuidValue.fromString(incoming['sourceId'] as String),
          expectedInvitationRevision: incoming['entryRevision'] as int,
          expectedResponseRevision: 0,
          commandId: const cal.Uuid().v4obj(),
          choice: cal.CalendarInvitationResponseChoice.declined,
        );
        a.paused = Completer<Map<String, dynamic>>();
        final lost = a
            .command({
              'command': responseCommand,
              'caseId': id,
              'pause': pause,
              'request': request.toJson(),
            })
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final proposed = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        await a.stop();
        await lost;
        final state =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          (state['responses'] as List).length ==
              (pause.endsWith('before') ? 0 : 1),
          'Bundle response command loss violated atomicity',
        );
        final retried = await b.command({
          'command': responseCommand,
          'caseId': id,
          'request': request.toJson(),
        }) as Map;
        require(
          retried['id'] != null &&
              (pause.endsWith('before') || retried['id'] == proposed['id']),
          'Bundle response retry lost committed identity',
        );
        a = await start('a-$pause-recovered', 18780);
      }
      for (final changedSource in [false, true]) {
        final id = nextCase();
        final source = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'initial',
          'bundle': !recurringResponses,
        }) as Map;
        var revision = source['entryRevision'] as int;
        if (changedSource) {
          final calendar =
              await b.command({'command': 'calendar', 'caseId': id}) as String;
          final adopted = await b.command({
            'command': 'adopt',
            'caseId': id,
            'request': {
              'invitationId': source['entryId'],
              'expectedRevision': revision,
              'sourceId': source['sourceId'],
              'calendarId': calendar,
              'expectedCalendarRevision': 1,
            },
          }) as Map;
          revision = adopted['invitationRevision'] as int;
        }
        final request = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(source['entryId'] as String),
          sourceId: cal.UuidValue.fromString(source['sourceId'] as String),
          expectedInvitationRevision: revision,
          expectedResponseRevision: 0,
          commandId: const cal.Uuid().v4obj(),
          choice: cal.CalendarInvitationResponseChoice.declined,
        );
        final receipt = await a.command({
          'command': responseCommand,
          'caseId': id,
          'request': request.toJson(),
        }) as Map;
        if (changedSource) {
          await a.command({
            'command': 'receive',
            'caseId': id,
            'key': 'child-only',
            'bundle': !recurringResponses,
            'bundleChild': 1,
            if (recurringResponses) 'instance': true,
            if (recurringResponses) 'sequence': 1,
          });
        } else {
          await a.command({'command': 'response-revoke', 'caseId': id});
        }
        await b.command({'command': 'response-work', 'caseId': id});
        final state =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          ((state['responses'] as List).single as Map)['state'] ==
                  'withdrawn' &&
              !await File('$root/.local/invitation-response-probe-$id.jsonl')
                  .exists(),
          'Changed bundle source or recipient authority dispatched stale work',
        );
        if (changedSource) {
          final retry = await b.command({
            'command': responseCommand,
            'caseId': id,
            'request': request.toJson(),
          }) as Map;
          require(
            retry['id'] == receipt['id'],
            'Source change destroyed historical retry',
          );
        }
      }
      final raceId = nextCase();
      final source = await b.command({
        'command': 'receive',
        'caseId': raceId,
        'key': 'bundle',
        'bundle': !recurringResponses,
        'sequence': 2,
      }) as Map;
      final request = cal.CalendarInvitationResponseRequest(
        invitationId: cal.UuidValue.fromString(source['entryId'] as String),
        sourceId: cal.UuidValue.fromString(source['sourceId'] as String),
        expectedInvitationRevision: source['entryRevision'] as int,
        expectedResponseRevision: 0,
        commandId: const cal.Uuid().v4obj(),
        choice: cal.CalendarInvitationResponseChoice.accepted,
      );
      final choices = await Future.wait([
        a.command({
          'command': responseCommand,
          'caseId': raceId,
          'request': request.toJson(),
        }),
        b.command({
          'command': responseCommand,
          'caseId': raceId,
          'request': request
              .copyWith(
                commandId: const cal.Uuid().v4obj(),
                choice: cal.CalendarInvitationResponseChoice.declined,
              )
              .toJson(),
        }),
      ]);
      require(
        choices.where((v) => (v as Map)['id'] != null).length == 1 &&
            choices
                    .where((v) => (v as Map)['error'] == 'staleRevision')
                    .length ==
                1,
        'Bundle master response choices bypassed revision fence',
      );
      if (bundleOccurrenceResponses || recurringResponses) {
        final id = nextCase();
        final source = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'independent',
          'bundle': !recurringResponses,
          'sequence': 2,
        }) as Map;
        final base = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(source['entryId'] as String),
          sourceId: cal.UuidValue.fromString(source['sourceId'] as String),
          expectedInvitationRevision: 1,
          expectedResponseRevision: 0,
          commandId: const cal.Uuid().v4obj(),
          choice: cal.CalendarInvitationResponseChoice.accepted,
        );
        Map<String, dynamic> original(int day) => cal.CalendarEventTiming(
          kind: cal.CalendarEventTimeKind.utc,
          start: cal.CalendarEventCivil(
            year: 2030,
            month: 1,
            day: day,
            hour: 9,
          ),
        ).toJson();
        final choices = await Future.wait([
          a.command({
            'command': responseCommand,
            'caseId': id,
            'request': base.toJson(),
            'originalStart': original(1),
          }),
          b.command({
            'command': responseCommand,
            'caseId': id,
            'request': base
                .copyWith(
                  commandId: const cal.Uuid().v4obj(),
                  choice: cal.CalendarInvitationResponseChoice.declined,
                )
                .toJson(),
            'originalStart': original(3),
          }),
        ]);
        require(
          choices.every((v) => (v as Map)['id'] != null) &&
              (choices.first as Map)['id'] != (choices.last as Map)['id'],
          'Different original commands incorrectly share a state/revision',
        );
        await b.command({
          'command': recurringResponses ? 'response' : 'bundle-response',
          'caseId': id,
          'request': base
              .copyWith(commandId: const cal.Uuid().v4obj())
              .toJson(),
        });
        final queued =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        final rows = (queued['responses'] as List).cast<Map>();
        require(
          rows.length == 3 &&
              rows.every((r) => r['state'] == 'queued') &&
              rows.map((r) => r['targetKey']).toSet().length == 3,
          'Master or sibling publication withdrew another target intent',
        );
        await b.command({'command': 'response-work', 'caseId': id});
        final accepted =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          (accepted['responses'] as List).cast<Map>().every(
                (r) => r['state'] == 'accepted',
              ) &&
              accepted['events'] == 0 &&
              accepted['links'] == 0,
          'Independent target workers changed adoption or failed to deliver',
        );
      }
      stdout.writeln(
        'PASS: independent ${recurringResponses
            ? 'ordinary recurring occurrence'
            : bundleOccurrenceResponses
            ? 'bundle occurrence'
            : 'bundle master'} response hosts, same-command and competing-choice races, command loss before/after commit, competing leases, actual loss before/after acceptance and stable retry key/bytes without adoption.',
      );
      return;
    }
    if (instanceResponses) {
      for (final pause in ['response-before', 'response-after']) {
        final id = nextCase();
        await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'master',
          'sequence': 20,
        });
        final incoming = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'instance',
          'instance': true,
          'sequence': 2,
        }) as Map;
        final request = cal.CalendarInvitationResponseRequest(
          invitationId: cal.UuidValue.fromString(incoming['entryId'] as String),
          sourceId: cal.UuidValue.fromString(incoming['sourceId'] as String),
          expectedInvitationRevision: incoming['entryRevision'] as int,
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
          (raced.first as Map)['id'] != null &&
              (raced.first as Map)['id'] == (raced.last as Map)['id'],
          'Instance response race duplicated result',
        );
        // A compatible newer master cannot rewrite the selected source version.
        await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'new-master',
          'sequence': 21,
        });
        a.paused = Completer<Map<String, dynamic>>();
        final lost = a
            .command({'command': 'response-work', 'caseId': id, 'pause': pause})
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final submitted = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        await b.command({'command': 'response-work', 'caseId': id});
        final visible =
            await b.command({'command': 'inspect', 'caseId': id}) as Map;
        require(
          ((visible['responses'] as List).single as Map)['attempts'] == 1 &&
              visible['events'] == 0 &&
              visible['links'] == 0,
          'Competing instance worker bypassed lease or adopted a calendar',
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
              recovered['events'] == 0,
          'Instance response recovery failed',
        );
        final records = await File(
          '$root/.local/invitation-response-probe-$id.jsonl',
        ).readAsLines();
        require(
          records.length == (pause == 'response-after' ? 2 : 1),
          'Wrong uncertain instance delivery evidence',
        );
        for (final line in records) {
          final actual = jsonDecode(line) as Map;
          require(
            actual['key'] == submitted['key'] &&
                actual['digest'] == submitted['digest'],
            'Instance retry changed delivery identity/bytes',
          );
        }
        final retried = await b.command({
          'command': 'response',
          'caseId': id,
          'request': request.toJson(),
        }) as Map;
        require(
          retried['id'] == (raced.first as Map)['id'],
          'Recovered instance command lost historical receipt',
        );
        a = await start('a-instance-response-recovered-$pause', 18780);
      }
      final raceId = nextCase();
      await b.command({
        'command': 'receive',
        'caseId': raceId,
        'key': 'master',
        'sequence': 20,
      });
      final source = await b.command({
        'command': 'receive',
        'caseId': raceId,
        'key': 'instance',
        'instance': true,
        'sequence': 2,
      }) as Map;
      final request = cal.CalendarInvitationResponseRequest(
        invitationId: cal.UuidValue.fromString(source['entryId'] as String),
        sourceId: cal.UuidValue.fromString(source['sourceId'] as String),
        expectedInvitationRevision: source['entryRevision'] as int,
        expectedResponseRevision: 0,
        commandId: const cal.Uuid().v4obj(),
        choice: cal.CalendarInvitationResponseChoice.accepted,
      );
      final choices = await Future.wait([
        a.command({
          'command': 'response',
          'caseId': raceId,
          'request': request.toJson(),
        }),
        b.command({
          'command': 'response',
          'caseId': raceId,
          'request': request
              .copyWith(
                commandId: const cal.Uuid().v4obj(),
                choice: cal.CalendarInvitationResponseChoice.declined,
              )
              .toJson(),
        }),
      ]);
      require(
        choices.where((v) => (v as Map)['id'] != null).length == 1 &&
            choices
                    .where((v) => (v as Map)['error'] == 'staleRevision')
                    .length ==
                1,
        'Instance response choices bypassed revision fence',
      );
      stdout.writeln(
        'PASS: independent single-instance response hosts, same-command and competing-choice races, preserved target version across master update, competing leases, actual loss before/after acceptance and stable retry key/bytes without adoption.',
      );
      return;
    }
    if (occurrenceApply) {
      Future<Map> prepare(String id) async {
        final master = await b.command({
          'range': rangeApply,
          'command': 'receive',
          'caseId': id,
          'key': 'master',
          'sequence': 1,
        }) as Map;
        final calendar = await b.command({
          'range': rangeApply,
          'command': 'calendar',
          'caseId': id,
        });
        final link = await b.command({
          'range': rangeApply,
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
          'range': rangeApply,
          'command': 'receive',
          'caseId': id,
          'key': 'instance',
          'instance': true,
          'cancel': rangeCancel,
          'sequence': 2,
        }) as Map;
        final v = await b.command({
          'range': rangeApply,
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

      if (rangeCompose) {
        Future<Map<String, dynamic>> masterInput(
          String id,
          int sequence, {
          bool cancel = false,
        }) async {
          final incoming = await b.command({
            'command': 'receive',
            'caseId': id,
            'key': 'master-$sequence',
            'sequence': sequence,
            'cancel': cancel,
            'summary': 'Composed-$sequence',
          }) as Map;
          final v = await b.command({
            'command': 'application',
            'caseId': id,
            'entryId': incoming['entryId'],
          }) as Map;
          require(
            v['hasAcceptedRangeCancellation'] == true &&
                v[cancel ? 'canApplyCancellation' : 'canApply'] == true &&
                v['occurrenceCompositionBlocked'] == false,
            'Masked master preview failed',
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

        Future<Map> apply(
          _Probe p,
          String id,
          Map request, {
          bool cancel = false,
          String? pause,
        }) async => await p.command({
          'command': 'apply',
          'caseId': id,
          'request': request,
          'cancel': cancel,
          'pause': pause,
        }) as Map;
        Future<Map<String, dynamic>> cancellation(String id) async {
          final request = await prepare(id);
          final result = await b.command({
            'command': 'occurrence-apply',
            'caseId': id,
            'range': true,
            'cancel': true,
            'request': request,
          }) as Map;
          require(result['id'] != null, 'Composition seed cancellation failed');
          return {'request': request, 'id': result['id']};
        }

        Future<void> retained(String id, Map<String, dynamic> cancelled) async {
          final result = await b.command({
            'command': 'occurrence-apply',
            'caseId': id,
            'range': true,
            'cancel': true,
            'request': cancelled['request'],
          }) as Map;
          require(
            result['id'] == cancelled['id'],
            'Composition lost original cancellation receipt',
          );
          final state =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            state['checkpointVersion'] == (rangeLifecycle ? 6 : 5) &&
                state['cutoff'] != null,
            'Composition lost its checkpoint or native cutoff',
          );
        }

        if (rangeRestoration) {
          Future<Map<String, dynamic>> restoreInput(
            String id,
            int sequence,
          ) async {
            final incoming = await b.command({
              'command': 'receive',
              'caseId': id,
              'key': 'restore-$sequence',
              'range': true,
              'instance': true,
              'restore': true,
              'sequence': sequence,
            }) as Map;
            final v = await b.command({
              'command': 'occurrence-view',
              'caseId': id,
              'entryId': incoming['entryId'],
              'range': true,
              'restore': true,
            }) as Map;
            require(v['canApply'] == true, 'Restoration preview blocked');
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

          Future<Map> restore(
            _Probe p,
            String id,
            Map request, {
            String? pause,
          }) async => await p.command({
            'command': 'occurrence-apply',
            'caseId': id,
            'range': true,
            'restore': true,
            'request': request,
            'pause': pause,
          }) as Map;
          if (restoredCompose) {
            Future<Map<String, dynamic>> seed(String id) async {
              await cancellation(id);
              final request = await restoreInput(id, 3),
                  result = await restore(b, id, request);
              require(result['id'] != null, 'Restored seed failed');
              return {'request': request, 'id': result['id']};
            }

            if (rangeCycles) {
              Future<Map<String, dynamic>> controlInput(
                String id,
                int sequence, {
                required bool cancel,
                String? original,
              }) async {
                final incoming = await b.command({
                  'command': 'receive',
                  'caseId': id,
                  'key': 'cycle-$sequence',
                  'instance': true,
                  'range': true,
                  'cancel': cancel,
                  'restore': !cancel,
                  'sequence': sequence,
                  'original': original,
                }) as Map;
                final view = await b.command({
                  'command': 'occurrence-view',
                  'caseId': id,
                  'entryId': incoming['entryId'],
                  'range': true,
                  'restore': !cancel,
                }) as Map;
                require(
                  view['canApply'] == true,
                  'Cycle preview blocked: $view',
                );
                return {
                  'invitationId': view['invitationId'],
                  'sourceId': view['incomingSourceId'],
                  'linkId': view['linkId'],
                  for (final name in [
                    'Invitation',
                    'Event',
                    'Calendar',
                    'Application',
                    'Occurrence',
                  ])
                    'expected${name}Revision':
                        view['${name[0].toLowerCase()}${name.substring(1)}Revision'],
                };
              }

              Future<Map> control(
                _Probe p,
                String id,
                Map request, {
                required bool cancel,
                String? pause,
              }) async => await p.command({
                'command': 'occurrence-apply',
                'caseId': id,
                'request': request,
                'range': true,
                'cancel': cancel,
                'restore': !cancel,
                'pause': pause,
              }) as Map;
              Future<void> state(String id, bool active, int revision) async {
                final value = await b.command({
                  'command': 'inspect',
                  'caseId': id,
                }) as Map;
                require(
                  value['checkpointVersion'] == 12 &&
                      (value['cutoff'] != null) == active &&
                      value['eventRevision'] == revision,
                  'Cycle commit was lost or partially visible: $value',
                );
              }

              final id = nextCase();
              await seed(id);
              for (final sequence in [10, 12, 14]) {
                for (final cancel in [true, false]) {
                  final request = await controlInput(
                    id,
                    sequence + (cancel ? 0 : 1),
                    cancel: cancel,
                  );
                  final raced = await Future.wait([
                    control(a, id, request, cancel: cancel),
                    control(b, id, request, cancel: cancel),
                  ]);
                  require(
                    raced.first['id'] != null &&
                        raced.first['id'] == raced.last['id'],
                    'Cycle competitors duplicated or lost transition: $raced',
                  );
                  await state(id, cancel, 4 + sequence - 10 + (cancel ? 0 : 1));
                }
              }
              for (final cancel in [true, false]) {
                for (final stage in ['before', 'after']) {
                  final id = nextCase();
                  await seed(id);
                  if (!cancel) {
                    await control(
                      b,
                      id,
                      await controlInput(id, 10, cancel: true),
                      cancel: true,
                    );
                  }
                  final request = await controlInput(
                    id,
                    cancel ? 10 : 11,
                    cancel: cancel,
                  );
                  a.paused = Completer<Map<String, dynamic>>();
                  final lost = control(
                    a,
                    id,
                    request,
                    cancel: cancel,
                    pause: 'occurrence-$stage',
                  ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
                  final proposed = await a.paused!.future.timeout(
                    const Duration(seconds: 40),
                  );
                  final visible = await b.command({
                    'command': 'inspect',
                    'caseId': id,
                  }) as Map;
                  final committed = stage == 'after';
                  require(
                    (visible['cutoff'] != null) == (cancel == committed) &&
                        visible['eventRevision'] ==
                            3 + (cancel ? 0 : 1) + (committed ? 1 : 0),
                    'Cycle loss crossed commit boundary: $visible',
                  );
                  await a.stop();
                  await lost;
                  final recovered = await control(
                    b,
                    id,
                    request,
                    cancel: cancel,
                  );
                  require(
                    recovered['id'] != null &&
                        committed == (recovered['id'] == proposed['id']),
                    'Cycle recovery lost exact receipt identity: $recovered',
                  );
                  await state(id, cancel, cancel ? 4 : 5);
                  a = await start('a-cycle-$cancel-$stage', 18780);
                }
              }
              for (final other in ['cancel', 'master', 'single']) {
                final id = nextCase();
                await seed(id);
                final older = await controlInput(id, 10, cancel: true);
                Map<String, dynamic> newer;
                if (other == 'single') {
                  final source = await b.command({
                    'command': 'receive',
                    'caseId': id,
                    'key': 'single-12',
                    'instance': true,
                    'original': '20300105T090000Z',
                    'sequence': 12,
                  }) as Map;
                  final view = await b.command({
                    'command': 'occurrence-view',
                    'caseId': id,
                    'entryId': source['entryId'],
                  }) as Map;
                  require(
                    view['canApply'] == true,
                    'Competing canonical preview blocked',
                  );
                  newer = {
                    'invitationId': view['invitationId'],
                    'sourceId': view['incomingSourceId'],
                    'linkId': view['linkId'],
                    for (final name in [
                      'Invitation',
                      'Event',
                      'Calendar',
                      'Application',
                      'Occurrence',
                    ])
                      'expected${name}Revision':
                          view['${name[0].toLowerCase()}${name.substring(1)}Revision'],
                  };
                } else {
                  newer = other == 'master'
                      ? await masterInput(id, 12)
                      : await controlInput(
                          id,
                          11,
                          cancel: true,
                          original: '20300105T090000Z',
                        );
                }
                final raced = await Future.wait([
                  control(a, id, older, cancel: true),
                  other == 'single'
                      ? b
                            .command({
                              'command': 'occurrence-apply',
                              'caseId': id,
                              'request': newer,
                            })
                            .then((v) => v as Map)
                      : other == 'master'
                      ? apply(b, id, newer)
                      : control(b, id, newer, cancel: true),
                ]);
                require(
                  raced.where((r) => r['id'] != null).length == 1 &&
                      raced
                              .where(
                                (r) => {
                                  'staleRevision',
                                  'dependencyConflict',
                                }.contains(r['error']),
                              )
                              .length ==
                          1,
                  'Competing cycle/$other bypassed revision fence: $raced',
                );
                final current = await b.command({
                  'command': 'inspect',
                  'caseId': id,
                }) as Map;
                require(
                  current['eventRevision'] == 4,
                  'Competing cycle/$other silently rebased a second write: $current',
                );
              }
              stdout.writeln(
                'PASS: three durable range cycles, competing same/different controls and master commands, actual process loss before/after CANCEL and restoration, atomic cutoff/checkpoint/revisions and stable retry identities.',
              );
              return;
            }
            if (restoredRanges) {
              Future<Map<String, dynamic>> input(
                String id,
                int sequence, {
                bool single = false,
              }) async {
                final received = await b.command({
                  'command': 'receive',
                  'caseId': id,
                  'key': '${single ? 'one' : 'range'}-$sequence',
                  'instance': true,
                  'range': !single,
                  'sequence': sequence,
                }) as Map;
                final v = await b.command({
                  'command': 'occurrence-view',
                  'caseId': id,
                  'entryId': received['entryId'],
                  'range': !single,
                }) as Map;
                require(
                  v['canApply'] == true,
                  'Restored range/single preview blocked',
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

              Future<Map> change(
                _Probe p,
                String id,
                Map request, {
                bool single = false,
                String? pause,
              }) async => await p.command({
                'command': 'occurrence-apply',
                'caseId': id,
                'range': !single,
                'request': request,
                'pause': pause,
              }) as Map;
              Future<void> checked(String id, Map saved) async {
                require(
                  (await restore(b, id, saved['request'] as Map))['error'] ==
                      'dependencyConflict',
                  'Range failed to supersede restoration receipt',
                );
                final state = await b.command({
                  'command': 'inspect',
                  'caseId': id,
                }) as Map;
                require(
                  state['checkpointVersion'] == 11 && state['cutoff'] == null,
                  'Range lost current/frozen state',
                );
              }

              final id = nextCase(),
                  saved = await seed(id),
                  request = await input(id, 4);
              final same = await Future.wait([
                change(a, id, request),
                change(b, id, request),
              ]);
              require(
                same.first['id'] != null && same.first['id'] == same.last['id'],
                'Range same-command race duplicated effect',
              );
              await checked(id, saved);
              await apply(b, id, await masterInput(id, 6));
              await apply(
                b,
                id,
                await masterInput(id, 8, cancel: true),
                cancel: true,
              );
              await apply(b, id, await masterInput(id, 9));
              require(
                (await change(b, id, request))['id'] == same.first['id'],
                'Master lifecycle lost current range receipt',
              );
              for (final other in ['range', 'single', 'master']) {
                final id = nextCase();
                await seed(id);
                final older = await input(id, 4),
                    newer = other == 'master'
                        ? await masterInput(id, 6)
                        : await input(id, 5, single: other == 'single');
                final raced = await Future.wait([
                  change(a, id, older),
                  other == 'master'
                      ? apply(b, id, newer)
                      : change(b, id, newer, single: other == 'single'),
                ]);
                require(
                  raced.where((r) => r['id'] != null).length == 1 &&
                      raced
                              .where((r) => r['error'] == 'staleRevision')
                              .length ==
                          1,
                  'Range/$other bypassed revision fencing',
                );
              }
              for (final continued in [false, true]) {
                for (final stage in ['before', 'after']) {
                  final id = nextCase(), saved = await seed(id);
                  if (continued) {
                    await change(b, id, await input(id, 4));
                  }
                  final request = await input(id, continued ? 5 : 4);
                  a.paused = Completer<Map<String, dynamic>>();
                  final lost = change(
                    a,
                    id,
                    request,
                    pause: 'occurrence-$stage',
                  ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
                  final proposed = await a.paused!.future.timeout(
                    const Duration(seconds: 40),
                  );
                  final visible = await b.command({
                    'command': 'inspect',
                    'caseId': id,
                  }) as Map;
                  require(
                    visible['checkpointVersion'] ==
                            (continued || stage == 'after' ? 11 : 7) &&
                        visible['cutoff'] == null &&
                        visible['eventRevision'] ==
                            3 +
                                (continued ? 1 : 0) +
                                (stage == 'after' ? 1 : 0),
                    'Range commit partially visible',
                  );
                  await a.stop();
                  await lost;
                  final recovered = await change(b, id, request);
                  require(
                    recovered['id'] != null &&
                        ((stage == 'after') ==
                            (recovered['id'] == proposed['id'])),
                    'Range recovery lost receipt identity',
                  );
                  await checked(id, saved);
                  a = await start('a-restored-range-$continued-$stage', 18780);
                }
              }
              stdout.writeln(
                'PASS: restored range same/competing/single/master races, v7/v11 visibility, master lifecycle receipts, restoration supersession and actual loss before/after first and continued commits.',
              );
              return;
            }

            if (restoredSingles) {
              Future<Map<String, dynamic>> singleInput(
                String id,
                int sequence, {
                bool cancel = false,
              }) async {
                final incoming = await b.command({
                  'command': 'receive',
                  'caseId': id,
                  'key': 'single-$sequence',
                  'instance': true,
                  'sequence': sequence,
                  'cancel': cancel,
                }) as Map;
                final v = await b.command({
                  'command': 'occurrence-view',
                  'caseId': id,
                  'entryId': incoming['entryId'],
                }) as Map;
                require(
                  v['canApply'] == true,
                  'Restored single preview blocked',
                );
                return {
                  for (final key in [
                    'invitationId',
                    'linkId',
                    'expectedInvitationRevision',
                    'expectedEventRevision',
                    'expectedCalendarRevision',
                    'expectedApplicationRevision',
                    'expectedOccurrenceRevision',
                  ])
                    key: switch (key) {
                      'expectedInvitationRevision' => v['invitationRevision'],
                      'expectedEventRevision' => v['eventRevision'],
                      'expectedCalendarRevision' => v['calendarRevision'],
                      'expectedApplicationRevision' => v['applicationRevision'],
                      'expectedOccurrenceRevision' => v['occurrenceRevision'],
                      _ => v[key],
                    },
                  'sourceId': v['incomingSourceId'],
                };
              }

              Future<Map> change(
                _Probe p,
                String id,
                Map request, {
                bool cancel = false,
                String? pause,
              }) async => await p.command({
                'command': 'occurrence-apply',
                'caseId': id,
                'request': request,
                'cancel': cancel,
                'pause': pause,
              }) as Map;
              Future<void> superseded(String id, Map saved) async {
                require(
                  (await restore(b, id, saved['request'] as Map))['error'] ==
                      'dependencyConflict',
                  'Old restoration receipt remained current',
                );
                final state = await b.command({
                  'command': 'inspect',
                  'caseId': id,
                }) as Map;
                require(
                  state['checkpointVersion'] == 10 && state['cutoff'] == null,
                  'Single lost restored evidence/native state',
                );
              }

              final id = nextCase(),
                  saved = await seed(id),
                  input = await singleInput(id, 4);
              final race = await Future.wait([
                change(a, id, input),
                change(b, id, input),
              ]);
              require(
                race.first['id'] != null && race.first['id'] == race.last['id'],
                'Same single command duplicated',
              );
              await superseded(id, saved);
              await apply(b, id, await masterInput(id, 6));
              require(
                (await change(b, id, input))['id'] == race.first['id'],
                'Master composition lost latest single receipt',
              );
              await apply(
                b,
                id,
                await masterInput(id, 8, cancel: true),
                cancel: true,
              );
              await apply(b, id, await masterInput(id, 9));
              require(
                (await change(b, id, input))['id'] == race.first['id'],
                'Master lifecycle lost latest single receipt',
              );
              final competing = nextCase(),
                  c = await seed(competing),
                  older = await singleInput(competing, 4),
                  newer = await singleInput(competing, 5);
              final results = await Future.wait([
                change(a, competing, older),
                change(b, competing, newer),
              ]);
              require(
                results.where((r) => r['id'] != null).length == 1 &&
                    results
                            .where((r) => r['error'] == 'staleRevision')
                            .length ==
                        1,
                'Competing singles bypassed fence',
              );
              await superseded(competing, c);
              final mixed = nextCase();
              await seed(mixed);
              final one = await singleInput(mixed, 4),
                  master = await masterInput(mixed, 6);
              final mixedResults = await Future.wait([
                change(a, mixed, one),
                apply(b, mixed, master),
              ]);
              require(
                mixedResults.where((r) => r['id'] != null).length == 1 &&
                    mixedResults
                            .where((r) => r['error'] == 'staleRevision')
                            .length ==
                        1,
                'Master/single race rebased silently',
              );
              for (final cancel in [false, true]) {
                for (final stage in ['before', 'after']) {
                  final id = nextCase(), saved = await seed(id);
                  if (cancel) {
                    await change(b, id, await singleInput(id, 4));
                  }
                  final input = await singleInput(
                    id,
                    cancel ? 5 : 4,
                    cancel: cancel,
                  );
                  a.paused = Completer<Map<String, dynamic>>();
                  final lost = change(
                    a,
                    id,
                    input,
                    cancel: cancel,
                    pause: 'occurrence-$stage',
                  ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
                  final submitted = await a.paused!.future.timeout(
                    const Duration(seconds: 40),
                  );
                  final visible = await b.command({
                    'command': 'inspect',
                    'caseId': id,
                  }) as Map;
                  require(
                    visible['checkpointVersion'] ==
                            (cancel || stage == 'after' ? 10 : 7) &&
                        visible['cutoff'] == null &&
                        visible['eventRevision'] ==
                            3 + (cancel ? 1 : 0) + (stage == 'after' ? 1 : 0),
                    'Single transition partially visible',
                  );
                  await a.stop();
                  await lost;
                  final recovered = await change(b, id, input, cancel: cancel);
                  require(
                    recovered['id'] != null &&
                        ((stage == 'after') ==
                            (recovered['id'] == submitted['id'])),
                    'Single recovery lost retry identity',
                  );
                  await superseded(id, saved);
                  a = await start('a-restored-single-$cancel-$stage', 18780);
                }
              }
              stdout.writeln(
                'PASS: restored singles same/competing/master races, v7/v10 atomic visibility, lifecycle receipt preservation, restoration supersession and actual loss before/after update/cancel commits.',
              );
              return;
            }

            Future<void> preserved(
              String id,
              Map saved, {
              bool cancelled = false,
            }) async {
              require(
                (await restore(b, id, saved['request'] as Map))['id'] ==
                    saved['id'],
                'Composition lost restoration retry',
              );
              final s =
                  await b.command({'command': 'inspect', 'caseId': id}) as Map;
              require(
                s['checkpointVersion'] == (restoredLifecycle ? 9 : 8) &&
                    s['cutoff'] == null &&
                    s['eventStatus'] == (cancelled ? 'cancelled' : 'confirmed'),
                'Composition did not preserve restored native state',
              );
            }

            final id = nextCase(),
                saved = await seed(id),
                input = await masterInput(id, 5, cancel: restoredLifecycle);
            final result = await Future.wait([
              apply(a, id, input, cancel: restoredLifecycle),
              apply(b, id, input, cancel: restoredLifecycle),
            ]);
            require(
              result.first['id'] != null &&
                  result.first['id'] == result.last['id'],
              'Restored master race duplicated commit',
            );
            await preserved(id, saved, cancelled: restoredLifecycle);
            final second = await masterInput(id, 6);
            require(
              (await apply(b, id, second))['id'] != null,
              'Continuing v8 composition failed',
            );
            await preserved(id, saved);
            final competing = nextCase(),
                c = await seed(competing),
                older = await masterInput(
                  competing,
                  5,
                  cancel: restoredLifecycle,
                ),
                newer = await masterInput(
                  competing,
                  6,
                  cancel: restoredLifecycle,
                );
            final races = await Future.wait([
              apply(a, competing, older, cancel: restoredLifecycle),
              apply(b, competing, newer, cancel: restoredLifecycle),
            ]);
            require(
              races.where((r) => r['id'] != null).length == 1 &&
                  races.where((r) => r['error'] == 'staleRevision').length == 1,
              'Restored competing masters bypassed revision fence',
            );
            await preserved(competing, c, cancelled: restoredLifecycle);
            for (final cancel
                in (restoredLifecycle ? [true, false] : [false])) {
              for (final stage in ['before', 'after']) {
                final pause = '${cancel ? 'cancel-apply' : 'apply'}-$stage';
                final id = nextCase(), saved = await seed(id);
                if (restoredLifecycle && !cancel) {
                  await apply(
                    b,
                    id,
                    await masterInput(id, 4, cancel: true),
                    cancel: true,
                  );
                }
                final input = await masterInput(id, 5, cancel: cancel);
                a.paused = Completer<Map<String, dynamic>>();
                final lost = apply(
                  a,
                  id,
                  input,
                  pause: pause,
                  cancel: cancel,
                ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
                final submitted = await a.paused!.future.timeout(
                  const Duration(seconds: 40),
                );
                final visible = await b.command({
                  'command': 'inspect',
                  'caseId': id,
                }) as Map;
                require(
                  visible['checkpointVersion'] ==
                          (stage == 'before'
                              ? (restoredLifecycle && !cancel ? 9 : 7)
                              : (restoredLifecycle ? 9 : 8)) &&
                      visible['cutoff'] == null &&
                      visible['eventRevision'] ==
                          (stage == 'before' ? 3 : 4) +
                              (restoredLifecycle && !cancel ? 1 : 0),
                  'Restored master commit partially visible',
                );
                await a.stop();
                await lost;
                final recovered = await apply(b, id, input, cancel: cancel);
                require(
                  recovered['id'] != null &&
                      ((stage == 'after') ==
                          (recovered['id'] == submitted['id'])),
                  'Restored master process loss broke retry identity',
                );
                await preserved(id, saved, cancelled: cancel);
                a = await start('a-restored-compose-$pause', 18780);
              }
            }
            stdout.writeln(
              'PASS: restored-master same/competing-command hosts, atomic visibility, continuing composition/lifecycle, actual loss before/after commit and preserved restoration retries.',
            );
            return;
          }
          final id = nextCase();
          await cancellation(id);
          final request = await restoreInput(id, 3);
          final results = await Future.wait([
            restore(a, id, request),
            restore(b, id, request),
          ]);
          require(
            results.first['id'] != null &&
                results.first['id'] == results.last['id'],
            'Restoration race duplicated commit',
          );
          final state =
              await b.command({'command': 'inspect', 'caseId': id}) as Map;
          require(
            state['checkpointVersion'] == 7 && state['cutoff'] == null,
            'Restoration not atomically visible',
          );
          final competing = nextCase();
          await cancellation(competing);
          final older = await restoreInput(competing, 3),
              newer = await restoreInput(competing, 4);
          final races = await Future.wait([
            restore(a, competing, older),
            restore(b, competing, newer),
          ]);
          require(
            races.where((r) => r['id'] != null).length == 1 &&
                races
                        .where(
                          (r) => {
                            'staleRevision',
                            'dependencyConflict',
                          }.contains(r['error']),
                        )
                        .length ==
                    1,
            'Competing sources bypassed revision fence',
          );
          for (final pause in ['occurrence-before', 'occurrence-after']) {
            final id = nextCase();
            await cancellation(id);
            final request = await restoreInput(id, 3);
            a.paused = Completer<Map<String, dynamic>>();
            final lost = restore(
              a,
              id,
              request,
              pause: pause,
            ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
            final submitted = await a.paused!.future.timeout(
              const Duration(seconds: 40),
            );
            final visible =
                await b.command({'command': 'inspect', 'caseId': id}) as Map;
            require(
              visible['checkpointVersion'] ==
                      (pause == 'occurrence-before' ? 4 : 7) &&
                  (visible['cutoff'] == null) == (pause == 'occurrence-after'),
              'Partial restoration visible across hosts',
            );
            await a.stop();
            await lost;
            final recovered = await restore(b, id, request);
            require(
              recovered['id'] != null &&
                  ((pause == 'occurrence-after') ==
                      (recovered['id'] == submitted['id'])),
              'Restoration recovery broke retry identity',
            );
            a = await start('a-restoration-recovered-$pause', 18780);
          }
          stdout.writeln(
            'PASS: range restoration same/competing-command hosts, atomic v7 visibility, actual process loss before/after commit and stable retries.',
          );
          return;
        }
        final id = nextCase(),
            cancelled = await cancellation(id),
            request = await masterInput(id, 5, cancel: rangeLifecycle);
        final race = await Future.wait(
          [a, b].map((p) => apply(p, id, request, cancel: rangeLifecycle)),
        );
        require(
          race.first['id'] != null && race.first['id'] == race.last['id'],
          'Masked master race duplicated a commit',
        );
        await retained(id, cancelled);
        if (rangeLifecycle) {
          final reopen = await masterInput(id, 6);
          final results = await Future.wait(
            [a, b].map((p) => apply(p, id, reopen)),
          );
          require(
            results.first['id'] != null &&
                results.first['id'] == results.last['id'],
            'Masked reopening race duplicated a commit',
          );
          await retained(id, cancelled);
        }
        final changed = nextCase(),
            changedCancel = await cancellation(changed),
            older = await masterInput(changed, 5, cancel: rangeLifecycle);
        final replaced = await Future.wait([
          apply(a, changed, older, cancel: rangeLifecycle),
          b.command({
            'command': 'receive',
            'caseId': changed,
            'key': 'newer-6',
            'sequence': 6,
            'cancel': rangeLifecycle,
            'summary': 'Newer-6',
          }),
        ]);
        require(
          (replaced.first as Map)['id'] != null ||
              (replaced.first as Map)['error'] == 'staleRevision',
          'Competing newer master bypassed source revision fence',
        );
        final newer = await b.command({
          'command': 'application',
          'caseId': changed,
          'entryId': older['invitationId'],
        }) as Map;
        require(
          newer[rangeLifecycle ? 'canApplyCancellation' : 'canApply'] == true &&
              newer['incomingSourceId'] != older['sourceId'],
          'Old command dismissed or replaced the newer notice',
        );
        final finalInput = {
          ...older,
          'sourceId': newer['incomingSourceId'],
          'expectedInvitationRevision': newer['invitationRevision'],
          'expectedEventRevision': newer['eventRevision'],
          'expectedApplicationRevision': newer['applicationRevision'],
          'expectedOccurrenceRevision': newer['occurrenceRevision'],
        };
        require(
          (await apply(b, changed, finalInput, cancel: rangeLifecycle))['id'] !=
              null,
          'Survivor could not apply newest master',
        );
        await retained(changed, changedCancel);
        for (final cancelling in rangeLifecycle ? [true, false] : [false]) {
          for (final pause in ['apply-before', 'apply-after']) {
            final id = nextCase(), cancelled = await cancellation(id);
            if (rangeLifecycle && !cancelling) {
              require(
                (await apply(
                      b,
                      id,
                      await masterInput(id, 5, cancel: true),
                      cancel: true,
                    ))['id'] !=
                    null,
                'Reopening seed failed',
              );
            }
            final request = await masterInput(
              id,
              rangeLifecycle && !cancelling ? 6 : 5,
              cancel: cancelling,
            );
            final actualPause = cancelling
                ? pause.replaceFirst('apply', 'cancel-apply')
                : pause;
            final oldRevision = rangeLifecycle && !cancelling ? 3 : 2;
            final oldVersion = rangeLifecycle && !cancelling ? 6 : 4;
            a.paused = Completer<Map<String, dynamic>>();
            final lost = apply(
              a,
              id,
              request,
              cancel: cancelling,
              pause: actualPause,
            ).then<void>((_) {}, onError: (Object _, StackTrace _) {});
            final submitted = await a.paused!.future.timeout(
              const Duration(seconds: 40),
            );
            final visible =
                await b.command({'command': 'inspect', 'caseId': id}) as Map;
            require(
              visible['eventRevision'] ==
                      (pause == 'apply-before'
                          ? oldRevision
                          : oldRevision + 1) &&
                  visible['checkpointVersion'] ==
                      (pause == 'apply-before'
                          ? oldVersion
                          : rangeLifecycle
                          ? 6
                          : 5) &&
                  visible['cutoff'] != null,
              'Masked master commit was partially visible',
            );
            await a.stop();
            await lost;
            final recovered = await apply(b, id, request, cancel: cancelling);
            require(
              recovered['id'] != null &&
                  ((pause == 'apply-after') ==
                      (recovered['id'] == submitted['id'])),
              'Masked master process loss broke receipt semantics',
            );
            await retained(id, cancelled);
            a = await start(
              'a-range-${cancelling ? 'cancel' : 'request'}-recovered-$pause',
              18780,
            );
          }
        }
        stdout.writeln(
          rangeLifecycle
              ? 'PASS: masked whole cancellation/reopening races, competing sources, actual before/after commit loss, frozen v6 state and independent retries.'
              : 'PASS: masked master two-host races, competing newer sources, actual before/after commit loss, frozen v5 state and original cancellation retries.',
        );
        return;
      }
      final raceId = nextCase();
      final raceRequest = await prepare(raceId);
      final race = await Future.wait(
        [a, b].map(
          (p) => p.command({
            'range': rangeApply,
            'command': 'occurrence-apply',
            'cancel': rangeCancel,
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
              'range': rangeApply,
              'command': 'occurrence-apply',
              'cancel': rangeCancel,
              'caseId': id,
              'request': request,
              'pause': pause,
            })
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final submitted = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        final visible = await b.command({
          'range': rangeApply,
          'command': 'inspect',
          'caseId': id,
        }) as Map;
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
          'range': rangeApply,
          'command': 'occurrence-apply',
          'cancel': rangeCancel,
          'caseId': id,
          'request': request,
        }) as Map;
        require(
          recovered['id'] != null &&
              ((pause == 'occurrence-after') ==
                  (recovered['id'] == submitted['id'])),
          'Occurrence loss recovery changed retry semantics',
        );
        final complete = await b.command({
          'range': rangeApply,
          'command': 'inspect',
          'caseId': id,
        }) as Map;
        require(
          complete['occurrenceApplications'] == 1 &&
              complete['eventRevision'] == 2 &&
              complete['applications'] == 0,
          'Occurrence recovery duplicated state or overwrote master acceptance',
        );
        a = await start('a-occurrence-recovered-$pause', 18780);
      }
      if (rangeCancel) {
        final id = nextCase(), first = await prepare(id);
        final next = await b.command({
          'command': 'receive',
          'caseId': id,
          'key': 'competing-cutoff',
          'range': true,
          'instance': true,
          'cancel': true,
          'sequence': 3,
          'original': '20300105T090000Z',
        }) as Map;
        final v = await b.command({
          'command': 'occurrence-view',
          'caseId': id,
          'range': true,
          'entryId': next['entryId'],
        }) as Map;
        require(
          v['canApply'] == true,
          'Competing cancellation was not eligible',
        );
        final second = {
          ...first,
          'invitationId': v['invitationId'],
          'sourceId': v['incomingSourceId'],
          'expectedInvitationRevision': v['invitationRevision'],
        };
        final results = await Future.wait([
          a.command({
            'command': 'occurrence-apply',
            'caseId': id,
            'range': true,
            'cancel': true,
            'request': first,
          }),
          b.command({
            'command': 'occurrence-apply',
            'caseId': id,
            'range': true,
            'cancel': true,
            'request': second,
          }),
        ]);
        require(
          results.where((v) => (v as Map)['id'] != null).length == 1 &&
              results
                      .where((v) => (v as Map)['error'] == 'dependencyConflict')
                      .length ==
                  1,
          'Competing cutoffs replaced or duplicated first acceptance',
        );
      }
      if (rangeCancel) {
        final incoming = await b.command({
          'command': 'receive',
          'caseId': raceId,
          'key': 'blocked-master',
          'sequence': 5,
        }) as Map;
        final view = await b.command({
          'command': 'application',
          'caseId': raceId,
          'entryId': incoming['entryId'],
        }) as Map;
        require(
          view['occurrenceCompositionBlocked'] == false &&
              view['hasAcceptedRangeCancellation'] == true &&
              view['canApply'] == true &&
              view['hasLocalChanges'] == false,
          'Accepted cancellation guard/state failed across hosts',
        );
        final retry = await b.command({
          'command': 'occurrence-apply',
          'caseId': raceId,
          'range': true,
          'cancel': true,
          'request': raceRequest,
        }) as Map;
        require(
          retry['id'] == (race.first as Map)['id'],
          'New notice lost retained cancellation retry',
        );
        stdout.writeln(
          'PASS: range cancellation two-host race, actual loss before/after commit, stable retries and cross-host preserved-cutoff preview.',
        );
        return;
      }
      Future<Map<String, dynamic>> composedCommand(String id) async {
        final incoming = await b.command({
          'range': rangeApply,
          'command': 'receive',
          'caseId': id,
          'key': 'new-master',
          'sequence': 3,
        }) as Map;
        final v = await b.command({
          'range': rangeApply,
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
          'range': rangeApply,
          'command': 'occurrence-apply',
          'caseId': id,
          'request': occurrence,
        }) as Map;
        final request = await composedCommand(id);
        a.paused = Completer<Map<String, dynamic>>();
        final lost = a
            .command({
              'range': rangeApply,
              'command': 'apply',
              'caseId': id,
              'request': request,
              'pause': pause,
            })
            .then<void>((_) {}, onError: (Object _, StackTrace _) {});
        final submitted = await a.paused!.future.timeout(
          const Duration(seconds: 40),
        );
        final visible = await b.command({
          'range': rangeApply,
          'command': 'inspect',
          'caseId': id,
        }) as Map;
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
          'range': rangeApply,
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
          'range': rangeApply,
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
        'range': rangeApply,
        'command': 'occurrence-apply',
        'caseId': id,
        'request': initial,
      });
      final masterRequest = await composedCommand(id);
      final source = await b.command({
        'range': rangeApply,
        'command': 'receive',
        'caseId': id,
        'key': 'next-instance',
        'instance': true,
        'sequence': 4,
      }) as Map;
      final v = await b.command({
        'range': rangeApply,
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
        a.command({
          'range': rangeApply,
          'command': 'apply',
          'caseId': id,
          'request': masterRequest,
        }),
        b.command({
          'range': rangeApply,
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
        'PASS: independent ${rangeApply ? 'range' : 'occurrence'}-application hosts, same-command race, atomic event/checkpoint/review visibility and actual loss before/after occurrence and composed-master commits, historical retry recovery and master/instance races.',
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
        if (ranges) 'range': true,
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
          if (ranges) 'range': false,
          'original': ranges ? '20300103T090000Z' : '20300105T090000Z',
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
          if (ranges) 'range': true,
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
        'PASS: independent ${ranges ? 'range/single' : 'instance'} invitation hosts, shared-key and distinct-original races, master/native isolation, actual loss before/after commit and exact retained receipt recovery through synthetic MIME.',
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
    try {
      // Release deliberately paused transactions before cleanup takes locks.
      for (final probe in probes.where((p) => p.busy || p.unusable)) {
        await probe.stop();
      }
      final live = probes
          .where((p) => !p.stopped && !p.exited && !p.busy && !p.unusable)
          .toList();
      if (live.isNotEmpty) {
        for (final id in cases) {
          await live.last.command({'command': 'cleanup', 'caseId': id});
        }
      }
    } finally {
      for (final p in probes) {
        await p.stop();
      }
    }
  }
}
