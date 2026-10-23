@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/task_content_values.dart';

CalendarTaskOccurrenceContentChange change(
  CalendarTaskContentField field,
  CalendarTaskContentAction action, {
  String? text,
  int? priority,
}) => CalendarTaskOccurrenceContentChange(
  field: field,
  action: action,
  text: text,
  priority: priority,
);
void main() {
  test(
    'selected set clear inherit preserves other fields and pins equal values',
    () {
      final master = CalendarTaskContent(
        timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
        summary: 'Series',
        location: 'Room',
        priority: 3,
      );
      final own = changeTaskOccurrenceContentValues(null, [
        change(
          CalendarTaskContentField.summary,
          CalendarTaskContentAction.setValue,
          text: 'Series',
        ),
        change(
          CalendarTaskContentField.priority,
          CalendarTaskContentAction.clearValue,
        ),
      ]);
      expect(own!.summary, 'Series');
      expect(own.priority, 0);
      final later = taskEffectiveOccurrenceContent(
        master.copyWith(summary: 'New', location: 'New room'),
        own,
      );
      expect(later.summary, 'Series');
      expect(later.location, 'New room');
      final cleared = changeTaskOccurrenceContentValues(own, [
        change(
          CalendarTaskContentField.summary,
          CalendarTaskContentAction.clearValue,
        ),
      ]);
      expect(taskEffectiveOccurrenceContent(master, cleared).summary, '');
      expect(
        changeTaskOccurrenceContentValues(cleared, [
          change(
            CalendarTaskContentField.summary,
            CalendarTaskContentAction.inheritSeries,
          ),
          change(
            CalendarTaskContentField.priority,
            CalendarTaskContentAction.inheritSeries,
          ),
        ]),
        isNull,
      );
    },
  );
  test(
    'disclosure does not reveal unrequested values or hidden override presence',
    () {
      final own = CalendarTaskOccurrenceContent(
        location: 'Hidden',
        priority: 9,
      );
      expect(
        taskDisclosedOccurrenceContent(own, {CalendarTaskFieldGroup.summary}),
        isNull,
      );
      expect(
        taskDisclosedOccurrenceContent(own, {
          CalendarTaskFieldGroup.priority,
        })!.location,
        isNull,
      );
      expect(
        taskDisclosedOccurrenceContent(own, {
          CalendarTaskFieldGroup.priority,
        })!.priority,
        9,
      );
    },
  );
  test('duplicate invalid typed or oversized field changes reject without normalization', () {
    final summary = change(
      CalendarTaskContentField.summary,
      CalendarTaskContentAction.setValue,
      text: 'x',
    );
    for (final changes in <List<CalendarTaskOccurrenceContentChange>>[
      [],
      [summary, summary],
      [
        change(
          CalendarTaskContentField.summary,
          CalendarTaskContentAction.setValue,
          text: '',
        ),
      ],
      [
        change(
          CalendarTaskContentField.priority,
          CalendarTaskContentAction.setValue,
          text: '1',
          priority: 1,
        ),
      ],
      [
        change(
          CalendarTaskContentField.priority,
          CalendarTaskContentAction.setValue,
          priority: 10,
        ),
      ],
      [
        change(
          CalendarTaskContentField.summary,
          CalendarTaskContentAction.clearValue,
          text: 'x',
        ),
      ],
      [
        change(
          CalendarTaskContentField.location,
          CalendarTaskContentAction.setValue,
          text: 'x' * 4097,
        ),
      ],
    ]) {
      expect(
        () => changeTaskOccurrenceContentValues(null, changes),
        throwsArgumentError,
      );
    }
  });
}
