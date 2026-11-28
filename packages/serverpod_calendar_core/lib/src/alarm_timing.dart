import 'calendar_duration.dart';
import 'civil_date_time.dart';
import 'date_event_span.dart';
import 'named_zone_resolver.dart';
import 'task_timing.dart';
import 'timed_event_span.dart';
import 'timed_value.dart';
import 'utc_arithmetic.dart';

enum AlarmAnchor { start, end }

/// Pure timing configuration. No recipient, authority, arming or delivery state.
final class AlarmTiming {
  factory AlarmTiming.absolute({
    required DateTime utc,
    int? repeat,
    CalendarDuration? repeatInterval,
  }) {
    TimedValue.utc(utc);
    _validateRepeats(repeat, repeatInterval);
    return AlarmTiming._(
      absoluteUtc: utc,
      repeat: repeat,
      repeatInterval: repeatInterval,
    );
  }

  factory AlarmTiming.relative({
    required CalendarDuration offset,
    required AlarmAnchor anchor,
    String? dateZoneId,
    int? repeat,
    CalendarDuration? repeatInterval,
  }) {
    _durationBound(offset);
    if (dateZoneId != null &&
        (dateZoneId.length > 255 ||
            !NamedZoneResolver().zoneIds.contains(dateZoneId))) {
      throw ArgumentError('Exact known DATE anchor zone required');
    }
    _validateRepeats(repeat, repeatInterval);
    return AlarmTiming._(
      offset: offset,
      anchor: anchor,
      dateZoneId: dateZoneId,
      repeat: repeat,
      repeatInterval: repeatInterval,
    );
  }

  const AlarmTiming._({
    this.absoluteUtc,
    this.offset,
    this.anchor,
    this.dateZoneId,
    this.repeat,
    this.repeatInterval,
  });
  final DateTime? absoluteUtc;
  final CalendarDuration? offset;
  final AlarmAnchor? anchor;
  final String? dateZoneId;
  final int? repeat;
  final CalendarDuration? repeatInterval;

  List<DateTime> resolveDateEvent(DateEventSpan event) {
    if (absoluteUtc != null) return _firings(null);
    if (anchor == AlarmAnchor.end &&
        event.end == null &&
        event.duration == null) {
      throw ArgumentError('END needs an explicit event end or duration');
    }
    return _firings(
      _dateAnchor(
        anchor == AlarmAnchor.start
            ? CivilDateTime(date: event.start, hour: 0, minute: 0)
            : CivilDateTime(date: event.endExclusive, hour: 0, minute: 0),
      ),
    );
  }

  List<DateTime> resolveTimedEvent(TimedEventSpan event) {
    if (absoluteUtc != null) return _firings(null);
    if (anchor == AlarmAnchor.start) {
      return _firings(_explicitAnchor(event.start));
    }
    if (event.isPoint) {
      throw ArgumentError('END needs an explicit event end or duration');
    }
    return _firings(
      event.end != null
          ? _explicitAnchor(event.end!)
          : _instantAnchor(event.endExclusive, event.start.zoneId),
    );
  }

  /// An already validated recurrence projection can end in the later fold.
  /// Keep its resolved end instant instead of reconstructing an explicit wall end.
  List<DateTime> resolveTimedProjection({
    required TimedValue start,
    DateTime? end,
  }) {
    if (absoluteUtc != null) return _firings(null);
    if (end != null && !end.isAfter(start.instant)) {
      throw ArgumentError('Projected end must follow start');
    }
    if (anchor == AlarmAnchor.start) return _firings(_explicitAnchor(start));
    if (end == null) throw ArgumentError('Projected END anchor is absent');
    return _firings(_instantAnchor(end, start.zoneId));
  }

  List<DateTime> resolveDateTask(DateTaskTiming task) {
    if (absoluteUtc != null) return _firings(null);
    final date = anchor == AlarmAnchor.start ? task.start : task.effectiveDue;
    if (date == null) throw ArgumentError('Task alarm anchor is absent');
    return _firings(_dateAnchor(CivilDateTime(date: date, hour: 0, minute: 0)));
  }

  List<DateTime> resolveTimedTask(TimedTaskTiming task) {
    if (absoluteUtc != null) return _firings(null);
    if (anchor == AlarmAnchor.start) {
      if (task.start == null) throw ArgumentError('Task start is absent');
      return _firings(_explicitAnchor(task.start!));
    }
    final due = task.effectiveDue;
    if (due == null) throw ArgumentError('Task due is absent');
    return _firings(
      task.due != null
          ? _explicitAnchor(task.due!)
          : _instantAnchor(due, task.start!.zoneId),
    );
  }

  List<DateTime> resolveUndatedTask() {
    if (absoluteUtc == null) {
      throw ArgumentError('Undated task needs an absolute trigger');
    }
    return _firings(null);
  }

  _ResolvedAnchor _dateAnchor(CivilDateTime civil) {
    final zone = dateZoneId;
    if (zone == null) {
      throw ArgumentError('DATE anchor needs an explicit named zone');
    }
    return _explicitAnchor(TimedValue.zonedEnd(civil, zoneId: zone));
  }

  List<DateTime> _firings(_ResolvedAnchor? relativeAnchor) {
    var current = absoluteUtc ?? _apply(relativeAnchor!, offset!);
    TimedValue.utc(current);
    final zone = relativeAnchor?.zoneId;
    final result = <DateTime>[current];
    for (var i = 0; i < (repeat ?? 0); i++) {
      // An interval starts at the preceding resolved firing. Re-resolving its
      // fold wall fields would silently move a later-fold instant backwards.
      final next = _apply(_instantAnchor(current, zone), repeatInterval!);
      if (!next.isAfter(current)) {
        throw ArgumentError('Alarm repeats must advance');
      }
      result.add(next);
      current = next;
    }
    return List.unmodifiable(result);
  }
}

final class _ResolvedAnchor {
  const _ResolvedAnchor(this.instant, this.civil, this.zoneId);
  final DateTime instant;
  final CivilDateTime civil;
  final String? zoneId;
}

_ResolvedAnchor _explicitAnchor(TimedValue value) =>
    _ResolvedAnchor(value.instant, value.civil, value.zoneId);
_ResolvedAnchor _instantAnchor(DateTime instant, String? zone) =>
    _ResolvedAnchor(
      instant,
      zone == null
          ? civilFields(instant)
          : NamedZoneResolver().localAt(instant, zoneId: zone),
      zone,
    );

DateTime _apply(_ResolvedAnchor anchor, CalendarDuration duration) {
  var base = anchor.instant;
  if (anchor.zoneId == null) {
    base = duration.addToUtc(base);
  } else {
    final resolver = NamedZoneResolver();
    if (duration.weeks != 0 || duration.days != 0) {
      final date = CalendarDuration(
        sign: duration.sign,
        weeks: duration.weeks,
        days: duration.days,
      ).addToDate(anchor.civil.date);
      base = resolver
          .resolve(
            CivilDateTime(
              date: date,
              hour: anchor.civil.hour,
              minute: anchor.civil.minute,
              second: anchor.civil.second,
            ),
            zoneId: anchor.zoneId!,
          )
          .instant;
    }
    final clock =
        BigInt.from(duration.hours) * BigInt.from(3600000000) +
        BigInt.from(duration.minutes) * BigInt.from(60000000) +
        BigInt.from(duration.seconds) * BigInt.from(1000000);
    base = utcFromMicroseconds(
      utcMicroseconds(base) + BigInt.from(duration.sign) * clock,
    );
    resolver.localAt(base, zoneId: anchor.zoneId!);
  }
  // Calculation padding/exclusive anchors do not expand ordinary firing storage.
  TimedValue.utc(base);
  return base;
}

void _validateRepeats(int? repeat, CalendarDuration? interval) {
  if ((repeat == null) != (interval == null)) {
    throw ArgumentError('Repeat and interval must be paired');
  }
  if (repeat == null) return;
  RangeError.checkValueInInterval(repeat, 0, 100, 'repeat');
  if (interval!.sign < 0 || interval.isZero) {
    throw ArgumentError('Positive interval required');
  }
  _durationBound(interval, multiplier: repeat);
}

void _durationBound(CalendarDuration duration, {int multiplier = 1}) {
  final seconds =
      BigInt.from(duration.weeks) * BigInt.from(604800) +
      BigInt.from(duration.days) * BigInt.from(86400) +
      BigInt.from(duration.hours) * BigInt.from(3600) +
      BigInt.from(duration.minutes) * BigInt.from(60) +
      BigInt.from(duration.seconds);
  final bound = BigInt.from(366 * 86400);
  if (seconds > bound || seconds * BigInt.from(multiplier) > bound) {
    throw ArgumentError('Alarm duration exceeds supported bound');
  }
}
