import 'dart:convert';

import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart'
    show validateCalendarPlainText;

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'event_values.dart';
import 'task_recurrence_values.dart';
import 'event_protocol_values.dart';
import 'generated/protocol.dart';

const taskMaxAssignees = 128;
CalendarTaskContent validateTaskContent(CalendarTaskContent value) {
  if (value.recurrence != null &&
      (value.timing.start == null ||
          value.timing.kind == CalendarTaskTimeKind.undated)) {
    throw ArgumentError('Task recurrence requires an explicit start');
  }
  for (final item in [
    (value.summary, 4096),
    (value.description, 16384),
    (value.location, 4096),
  ]) {
    if (item.$1 != null) {
      validateCalendarPlainText(item.$1!, maxCodePoints: item.$2);
    }
  }
  if (value.priority != null) {
    RangeError.checkValueInInterval(value.priority!, 0, 9, 'priority');
  }
  final t = value.timing;
  if (t.kind == CalendarTaskTimeKind.undated) {
    if (t.start != null ||
        t.due != null ||
        t.duration != null ||
        t.zoneId != null) {
      throw ArgumentError('Undated timing has no dates or zone');
    }
    return value;
  }
  if (t.start == null && t.due == null) {
    throw ArgumentError('Dated timing requires a milestone');
  }
  CalendarDuration? duration;
  final d = t.duration;
  if (d != null) {
    duration = CalendarDuration(
      weeks: d.weeks,
      days: d.days,
      hours: d.hours,
      minutes: d.minutes,
      seconds: d.seconds,
      microsecond: d.microsecond,
    );
  }
  CalendarDate date(CalendarEventCivil c) {
    if (c.hour != 0 || c.minute != 0 || c.second != 0 || c.microsecond != 0) {
      throw ArgumentError('DATE has no clock fields');
    }
    return CalendarDate(year: c.year, month: c.month, day: c.day);
  }

  if (t.kind == CalendarTaskTimeKind.date) {
    if (t.zoneId != null) {
      throw ArgumentError('DATE has no named zone');
    }
    DateTaskTiming(
      start: t.start == null ? null : date(t.start!),
      due: t.due == null ? null : date(t.due!),
      duration: duration,
    );
  } else {
    TimedValue timed(CalendarEventCivil c) => validateEventTiming(
      CalendarEventTiming(
        kind: t.kind == CalendarTaskTimeKind.utc
            ? CalendarEventTimeKind.utc
            : CalendarEventTimeKind.zoned,
        start: c,
        zoneId: t.zoneId,
      ),
    ).$2!.start;
    TimedTaskTiming(
      start: t.start == null ? null : timed(t.start!),
      due: t.due == null ? null : timed(t.due!),
      duration: duration,
    );
  }
  return value.recurrence == null
      ? value
      : value.copyWith(
          recurrence: validateEventRecurrence(
            taskAnchor(value.timing),
            value.recurrence,
          ),
        );
}

String taskAssigneeKey(CalendarTaskAssignee v) =>
    jsonEncode([v.namespace, v.kind, v.externalId]);
List<CalendarTaskAssignee> validateTaskAssignees(
  List<CalendarTaskAssignee> input, {
  int max = taskMaxAssignees,
}) {
  if (input.length > max || input.length > taskMaxAssignees) {
    throw const RecurrenceLimitException('taskAssignees');
  }
  final values = <String, CalendarTaskAssignee>{};
  for (final v in input) {
    if (!RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$').hasMatch(v.namespace) ||
        !RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$').hasMatch(v.kind) ||
        v.externalId.isEmpty) {
      throw ArgumentError('Invalid assignee reference');
    }
    validateCalendarPlainText(v.externalId, maxCodePoints: 256);
    values[taskAssigneeKey(v)] = v;
  }
  return List.unmodifiable([
    for (final k in values.keys.toList()..sort()) values[k]!,
  ]);
}

CalendarTaskProgress validateTaskProgress(CalendarTaskProgress value) {
  if (value.percentComplete != null) {
    RangeError.checkValueInInterval(value.percentComplete!, 0, 100);
  }
  if (value.completedAt != null) {
    if (!value.completedAt!.isUtc) {
      throw ArgumentError('UTC completion time required');
    }
    TimedValue.utc(value.completedAt!);
  }
  return value;
}

CalendarTaskProgress changeTaskProgressValue(
  CalendarTaskProgress before,
  CalendarTaskProgressRequest request,
  DateTime now,
) {
  if (request.action != CalendarTaskProgressAction.setPercentage &&
      request.percentComplete != null) {
    throw ArgumentError('Percentage belongs to setPercentage');
  }
  return validateTaskProgress(switch (request.action) {
    CalendarTaskProgressAction.complete =>
      before.status == CalendarTaskStatus.cancelled
          ? throw ArgumentError('Reopen before completing')
          : before.status == CalendarTaskStatus.completed &&
                before.percentComplete == 100 &&
                before.completedAt != null
          ? before
          : CalendarTaskProgress(
              status: CalendarTaskStatus.completed,
              percentComplete: 100,
              completedAt: eventProtocolInstant(now),
            ),
    CalendarTaskProgressAction.reopen => CalendarTaskProgress(
      status: CalendarTaskStatus.needsAction,
      percentComplete: 0,
    ),
    CalendarTaskProgressAction.cancel => CalendarTaskProgress(
      status: CalendarTaskStatus.cancelled,
      percentComplete: before.percentComplete,
    ),
    CalendarTaskProgressAction.setPercentage => (() {
      if (before.status == CalendarTaskStatus.cancelled ||
          before.status == CalendarTaskStatus.completed ||
          request.percentComplete == null) {
        throw ArgumentError('Reopen before editing progress');
      }
      RangeError.checkValueInInterval(request.percentComplete!, 0, 99);
      return CalendarTaskProgress(
        status: request.percentComplete == 0
            ? CalendarTaskStatus.needsAction
            : CalendarTaskStatus.inProcess,
        percentComplete: request.percentComplete!,
      );
    })(),
  });
}

CalendarTaskProtocolVersion validateTaskVersion(CalendarTaskProtocolVersion v) {
  if (v.sequence != null) {
    RangeError.checkValueInInterval(v.sequence!, 0, eventMaxSequence);
  }
  for (final t in [v.stamp, ?v.created, ?v.lastModified]) {
    TimedValue.utc(t);
  }
  return v;
}

CalendarTaskProtocolVersion advanceTaskVersion(
  CalendarTaskProtocolVersion before,
  DateTime now,
) {
  if (before.sequence == eventMaxSequence) {
    throw const RecurrenceLimitException('taskSequence');
  }
  var stamp = eventProtocolInstant(now);
  for (final old in [before.stamp, ?before.lastModified]) {
    if (old.isAfter(stamp)) stamp = old;
  }
  return before.copyWith(
    sequence: (before.sequence ?? 0) + 1,
    stamp: stamp,
    lastModified: stamp,
  );
}

CalendarTaskTiming validateTaskReplacement(
  CalendarTaskContent master,
  CalendarTaskTiming replacement,
) {
  validateTaskContent(CalendarTaskContent(timing: replacement));
  if (replacement.start == null ||
      replacement.kind != master.timing.kind ||
      replacement.zoneId != master.timing.zoneId) {
    throw ArgumentError('Task replacement profile mismatch');
  }
  return replacement;
}
