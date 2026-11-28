import 'generated/protocol.dart';
import 'task_values.dart';

const taskOccurrenceContentGroups = {
  CalendarTaskFieldGroup.summary,
  CalendarTaskFieldGroup.description,
  CalendarTaskFieldGroup.location,
  CalendarTaskFieldGroup.priority,
};

CalendarTaskOccurrenceContent? validateTaskOccurrenceContent(
  CalendarTaskOccurrenceContent? value,
) {
  if (value == null) return null;
  validateTaskContent(
    CalendarTaskContent(
      timing: CalendarTaskTiming(kind: CalendarTaskTimeKind.undated),
      summary: value.summary,
      description: value.description,
      location: value.location,
      priority: value.priority,
    ),
  );
  return value.summary == null &&
          value.description == null &&
          value.location == null &&
          value.priority == null
      ? null
      : value;
}

CalendarTaskOccurrenceContent? changeTaskOccurrenceContentValues(
  CalendarTaskOccurrenceContent? before,
  List<CalendarTaskOccurrenceContentChange> changes,
) {
  if (changes.isEmpty ||
      changes.length > 4 ||
      changes.map((c) => c.field).toSet().length != changes.length) {
    throw ArgumentError('One to four unique content fields required');
  }
  var value = before ?? CalendarTaskOccurrenceContent();
  for (final change in changes) {
    final priority = change.field == CalendarTaskContentField.priority;
    if (change.action == CalendarTaskContentAction.setValue) {
      if (priority
          ? change.text != null || change.priority == null
          : change.priority != null ||
                change.text == null ||
                change.text!.isEmpty) {
        throw ArgumentError(
          'Set requires only the corresponding nonempty value',
        );
      }
    } else if (change.text != null || change.priority != null) {
      throw ArgumentError('Clear/inherit has no value');
    }
    final text = switch (change.action) {
      CalendarTaskContentAction.setValue => change.text,
      CalendarTaskContentAction.clearValue => '',
      CalendarTaskContentAction.inheritSeries => null,
    };
    switch (change.field) {
      case CalendarTaskContentField.summary:
        value = value.copyWith(summary: text);
      case CalendarTaskContentField.description:
        value = value.copyWith(description: text);
      case CalendarTaskContentField.location:
        value = value.copyWith(location: text);
      case CalendarTaskContentField.priority:
        value = value.copyWith(
          priority: switch (change.action) {
            CalendarTaskContentAction.setValue => change.priority,
            CalendarTaskContentAction.clearValue => 0,
            CalendarTaskContentAction.inheritSeries => null,
          },
        );
    }
  }
  return validateTaskOccurrenceContent(value);
}

CalendarTaskOccurrenceContent taskEffectiveOccurrenceContent(
  CalendarTaskContent master,
  CalendarTaskOccurrenceContent? own,
) => CalendarTaskOccurrenceContent(
  summary: own?.summary ?? master.summary,
  description: own?.description ?? master.description,
  location: own?.location ?? master.location,
  priority: own?.priority ?? master.priority,
);

CalendarTaskOccurrenceContent? taskDisclosedOccurrenceContent(
  CalendarTaskOccurrenceContent? value,
  Set<CalendarTaskFieldGroup> groups,
) => value == null
    ? null
    : validateTaskOccurrenceContent(
        CalendarTaskOccurrenceContent(
          summary: groups.contains(CalendarTaskFieldGroup.summary)
              ? value.summary
              : null,
          description: groups.contains(CalendarTaskFieldGroup.description)
              ? value.description
              : null,
          location: groups.contains(CalendarTaskFieldGroup.location)
              ? value.location
              : null,
          priority: groups.contains(CalendarTaskFieldGroup.priority)
              ? value.priority
              : null,
        ),
      );
