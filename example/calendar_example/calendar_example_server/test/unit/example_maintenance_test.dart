import 'package:calendar_example_server/src/future_calls/calendar_alarm_maintenance_future_call.dart';
import 'package:test/test.dart';

void main() {
  test(
    'one failed module cannot skip later wake-ups or replace the first error',
    () async {
      final calls = <String>[];
      final first = StateError('synthetic first failure');
      final stack = StackTrace.current;
      try {
        await runExampleMaintenanceStages([
          () {
            calls.add('alarm');
            Error.throwWithStackTrace(first, stack);
          },
          () async {
            calls.add('notification');
          },
          () async {
            calls.add('scheduling');
            throw StateError('synthetic second failure');
          },
          () async {
            calls.add('remaining');
          },
        ]);
        fail('Expected original framework diagnostic');
      } catch (error, trace) {
        expect(error, same(first));
        expect(trace.toString(), stack.toString());
      }
      expect(calls, ['alarm', 'notification', 'scheduling', 'remaining']);
    },
  );
  test('successful stages await their work in order', () async {
    final calls = <int>[];
    await runExampleMaintenanceStages([
      () async {
        calls.add(1);
        await Future<void>.value();
        calls.add(2);
      },
      () async {
        calls.add(3);
      },
    ]);
    expect(calls, [1, 2, 3]);
  });
}
