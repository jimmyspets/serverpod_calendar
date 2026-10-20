import 'calendar_date.dart';

/// Weekday identity independent of a user's display preference.
enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;

  /// Monday is 1 and Sunday is 7, matching [CalendarDate.weekday].
  int get isoNumber => index + 1;
}

/// One BYDAY selection; an ordinal is legal only in the appropriate rule.
final class ByDayValue {
  ByDayValue({required this.weekday, this.ordinal}) {
    final value = ordinal;
    if (value != null) {
      RangeError.checkValueInInterval(value, -53, 53, 'ordinal');
      if (value == 0) {
        throw RangeError.value(value, 'ordinal', 'Must be nonzero');
      }
    }
  }

  final Weekday weekday;
  final int? ordinal;

  @override
  bool operator ==(Object other) =>
      other is ByDayValue &&
      weekday == other.weekday &&
      ordinal == other.ordinal;

  @override
  int get hashCode => Object.hash(weekday, ordinal);
}

/// Cadences available to a DATE-only recurrence rule.
///
/// Timed minutely/hourly rules require a separate timed contract.
enum DateRecurrenceFrequency { daily, weekly, monthly, yearly }

/// Immutable, structurally validated DATE-only recurrence parameters.
///
/// Filter lists are copied, sorted and deduplicated by exact value.
/// No occurrences are generated. Start alignment, inclusive UNTIL evaluation,
/// invalid-date skipping, COUNT evaluation and work budgets belong to expansion.
/// Empty filter lists mean absent; adapters must validate wire syntax separately.
final class DateRecurrenceRule {
  DateRecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.weekStart = Weekday.monday,
    List<ByDayValue> byDay = const [],
    List<int> byMonthDay = const [],
    List<int> byYearDay = const [],
    List<int> byWeekNo = const [],
    List<int> byMonth = const [],
    List<int> bySetPosition = const [],
  }) : byDay = _weekdays(byDay),
       byMonthDay = _integers(byMonthDay, 31, 'byMonthDay'),
       byYearDay = _integers(byYearDay, 366, 'byYearDay'),
       byWeekNo = _integers(byWeekNo, 53, 'byWeekNo'),
       byMonth = _integers(byMonth, 12, 'byMonth', positiveOnly: true),
       bySetPosition = _integers(bySetPosition, 366, 'bySetPosition') {
    until?.requireOrdinary('UNTIL');
    RangeError.checkValueInInterval(interval, 1, maxScalar, 'interval');
    final limit = count;
    if (limit != null) {
      RangeError.checkValueInInterval(limit, 1, maxScalar, 'count');
    }
    if (count != null && until != null) {
      throw ArgumentError('COUNT and UNTIL are mutually exclusive');
    }
    if (this.byMonthDay.isNotEmpty &&
        frequency == DateRecurrenceFrequency.weekly) {
      throw ArgumentError('BYMONTHDAY is not legal with WEEKLY');
    }
    if (this.byYearDay.isNotEmpty &&
        frequency != DateRecurrenceFrequency.yearly) {
      throw ArgumentError('DATE-only BYYEARDAY requires YEARLY');
    }
    if (this.byWeekNo.isNotEmpty &&
        frequency != DateRecurrenceFrequency.yearly) {
      throw ArgumentError('BYWEEKNO requires YEARLY');
    }
    if (this.byDay.any((value) => value.ordinal != null)) {
      if (frequency != DateRecurrenceFrequency.monthly &&
          frequency != DateRecurrenceFrequency.yearly) {
        throw ArgumentError('Ordinal BYDAY requires MONTHLY or YEARLY');
      }
      if (frequency == DateRecurrenceFrequency.yearly &&
          this.byWeekNo.isNotEmpty) {
        throw ArgumentError(
          'Ordinal BYDAY cannot be combined with yearly BYWEEKNO',
        );
      }
    }
    if (this.bySetPosition.isNotEmpty &&
        this.byDay.isEmpty &&
        this.byMonthDay.isEmpty &&
        this.byYearDay.isEmpty &&
        this.byWeekNo.isEmpty &&
        this.byMonth.isEmpty) {
      throw ArgumentError('BYSETPOS requires another BY rule part');
    }
  }

  /// Portable exact-integer representation bound, not an expansion budget.
  static const int maxScalar = 9007199254740991;

  final DateRecurrenceFrequency frequency;
  final int interval;
  final int? count;

  /// Inclusive DATE bound; evaluation relative to a start is not implemented.
  final CalendarDate? until;
  final Weekday weekStart;
  final List<ByDayValue> byDay;
  final List<int> byMonthDay;
  final List<int> byYearDay;
  final List<int> byWeekNo;
  final List<int> byMonth;
  final List<int> bySetPosition;

  static List<int> _integers(
    List<int> values,
    int maximum,
    String name, {
    bool positiveOnly = false,
  }) {
    for (final value in values) {
      RangeError.checkValueInInterval(
        value,
        positiveOnly ? 1 : -maximum,
        maximum,
        name,
      );
      if (value == 0) throw RangeError.value(value, name, 'Must be nonzero');
    }
    return List.unmodifiable(values.toSet().toList()..sort());
  }

  static List<ByDayValue> _weekdays(List<ByDayValue> values) =>
      List.unmodifiable(
        values.toSet().toList()..sort((a, b) {
          final dayOrder = a.weekday.index.compareTo(b.weekday.index);
          return dayOrder != 0
              ? dayOrder
              : (a.ordinal ?? 0).compareTo(b.ordinal ?? 0);
        }),
      );

  @override
  bool operator ==(Object other) =>
      other is DateRecurrenceRule &&
      frequency == other.frequency &&
      interval == other.interval &&
      count == other.count &&
      until == other.until &&
      weekStart == other.weekStart &&
      _same(byDay, other.byDay) &&
      _same(byMonthDay, other.byMonthDay) &&
      _same(byYearDay, other.byYearDay) &&
      _same(byWeekNo, other.byWeekNo) &&
      _same(byMonth, other.byMonth) &&
      _same(bySetPosition, other.bySetPosition);

  static bool _same<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    frequency,
    interval,
    count,
    until,
    weekStart,
    Object.hashAll(byDay),
    Object.hashAll(byMonthDay),
    Object.hashAll(byYearDay),
    Object.hashAll(byWeekNo),
    Object.hashAll(byMonth),
    Object.hashAll(bySetPosition),
  );
}
