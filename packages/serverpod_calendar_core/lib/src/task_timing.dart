import 'calendar_date.dart';
import 'calendar_duration.dart';
import 'date_recurrence_set.dart';
import 'timed_recurrence_set.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';
import 'utc_window.dart';

/// Task dates are milestones, never an implicit occupied event interval.
/// An undated, start-only or due-only task is valid; DURATION requires DTSTART.
final class DateTaskTiming {
  DateTaskTiming({this.start, this.due, this.duration}) {
    start?.requireOrdinary('start');
    due?.requireOrdinary('due');
    if (due != null && duration != null) {
      throw ArgumentError('DUE and DURATION are exclusive');
    }
    if (duration != null &&
        (start == null || duration!.sign < 0 || duration!.isZero)) {
      throw ArgumentError('Task duration requires a start and positive units');
    }
    final finish = effectiveDue;
    finish?.requireOrdinary('effectiveDue');
    if (start != null && finish != null && finish.compareTo(start!) <= 0) {
      throw ArgumentError('DUE must follow DTSTART');
    }
  }
  final CalendarDate? start, due;
  final CalendarDuration? duration;
  CalendarDate? get effectiveDue => due ?? duration?.addToDate(start!);
  DateTaskTiming at(CalendarDate occurrenceStart) {
    if (start == null) throw StateError('Recurrence requires DTSTART');
    return DateTaskTiming(
      start: occurrenceStart,
      due: due == null ? null : occurrenceStart.addDays(start!.daysUntil(due!)),
      duration: duration,
    );
  }

  /// Start-based query, with the recurrence set's original identities/budgets.
  List<DateTaskOccurrence> expandStarts(
    DateRecurrenceSet recurrence, {
    required CalendarDate from,
    required CalendarDate through,
    required int maxCandidateDays,
    required int maxRuleOccurrences,
    required int maxResults,
  }) {
    if (start == null || recurrence.start != start) {
      throw ArgumentError('Recurring task needs matching DTSTART');
    }
    return List.unmodifiable(
      recurrence
          .expand(
            from: from,
            through: through,
            maxCandidateDays: maxCandidateDays,
            maxRuleOccurrences: maxRuleOccurrences,
            maxResults: maxResults,
          )
          .map((v) => DateTaskOccurrence(v, at(v))),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DateTaskTiming &&
      start == other.start &&
      due == other.due &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(start, due, duration);
}

final class DateTaskOccurrence {
  const DateTaskOccurrence(this.originalStart, this.timing);
  final CalendarDate originalStart;
  final DateTaskTiming timing;
}

/// UTC/zoned task milestones, preserving explicit DUE versus nominal DURATION.
final class TimedTaskTiming {
  TimedTaskTiming({this.start, this.due, this.duration}) {
    start?.civil.date.requireOrdinary('start');
    due?.civil.date.requireOrdinary('due');
    if (due != null && duration != null) {
      throw ArgumentError('DUE and DURATION are exclusive');
    }
    if (start != null && due != null && !start!.sameProfile(due!)) {
      throw ArgumentError('DUE profile mismatch');
    }
    if (duration != null &&
        (start == null || duration!.sign < 0 || duration!.isZero)) {
      throw ArgumentError('Task duration requires a start and positive units');
    }
    final finish = effectiveDue;
    if (finish != null) {
      final zoneId = start?.zoneId ?? due?.zoneId;
      if (zoneId != null) {
        validateZonedInstant(finish, zoneId, allowExclusiveEnd: false);
      } else {
        TimedValue.utc(finish);
      }
    }
    if (start != null && finish != null && !finish.isAfter(start!.instant)) {
      throw ArgumentError('DUE must follow DTSTART');
    }
  }
  final TimedValue? start, due;
  final CalendarDuration? duration;
  DateTime? get effectiveDue =>
      due?.instant ?? (duration == null ? null : start!.add(duration!));

  /// Original explicit DUE propagates exact elapsed length; duration units stay
  /// nominal. The resolved due instant can retain a later-fold identity.
  TimedTaskProjection at(TimedValue occurrenceStart) {
    occurrenceStart.civil.date.requireOrdinary("occurrenceStart");
    if (start == null) throw StateError('Recurrence requires DTSTART');
    if (!start!.sameProfile(occurrenceStart)) {
      throw ArgumentError('Recurrence profile mismatch');
    }
    final finish = duration != null
        ? occurrenceStart.add(duration!)
        : due == null
        ? null
        : utcFromMicroseconds(
            utcMicroseconds(occurrenceStart.instant) +
                utcMicroseconds(due!.instant) -
                utcMicroseconds(start!.instant),
          );
    if (finish != null) {
      if (occurrenceStart.zoneId != null) {
        validateZonedInstant(
          finish,
          occurrenceStart.zoneId!,
          allowExclusiveEnd: false,
        );
      } else {
        TimedValue.utc(finish);
      }
    }
    return TimedTaskProjection(occurrenceStart, finish);
  }

  List<TimedTaskOccurrence> expandStarts(
    TimedRecurrenceSet recurrence, {
    required UtcWindow window,
    required int maxCandidateWork,
    required int maxRuleOccurrences,
    required int maxResults,
  }) {
    if (start == null || recurrence.start != start) {
      throw ArgumentError('Recurring task needs matching DTSTART');
    }
    if (recurrence.periods.isNotEmpty) {
      throw ArgumentError(
        'PERIOD RDATE is an event profile; not a task due override',
      );
    }
    return List.unmodifiable(
      recurrence
          .expand(
            window: window,
            maxCandidateWork: maxCandidateWork,
            maxRuleOccurrences: maxRuleOccurrences,
            maxResults: maxResults,
          )
          .map((v) => TimedTaskOccurrence(v, at(v))),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TimedTaskTiming &&
      start == other.start &&
      due == other.due &&
      duration == other.duration;
  @override
  int get hashCode => Object.hash(start, due, duration);
}

final class TimedTaskProjection {
  const TimedTaskProjection(this.start, this.dueInstant);
  final TimedValue start;
  final DateTime? dueInstant;
}

final class TimedTaskOccurrence {
  const TimedTaskOccurrence(this.originalStart, this.timing);
  final TimedValue originalStart;
  final TimedTaskProjection timing;
}
