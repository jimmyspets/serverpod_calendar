import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);
void main() {
  test('retains original anchor independently of replacement timing', () {
    final span = DateEventSpan(
      start: d(8),
      duration: CalendarDuration(weeks: 1),
    );
    final value = DateEventRangeChange(originalStart: d(3), replacement: span);
    expect(value.originalStart, d(3));
    expect(identical(value.replacement, span), isTrue);
    expect(value.dayShift, 5);
    expect(value.replacement.dayCount, 7);
  });
  test('signed shift supports earlier and unchanged starts', () {
    expect(
      DateEventRangeChange(
        originalStart: d(8),
        replacement: DateEventSpan(start: d(3)),
      ).dayShift,
      -5,
    );
    expect(
      DateEventRangeChange(
        originalStart: d(8),
        replacement: DateEventSpan(start: d(8)),
      ).dayShift,
      0,
    );
  });
  test('shift uses Gregorian days across a year and leap day', () {
    final leap = CalendarDate(year: 2024, month: 2, day: 28);
    expect(
      DateEventRangeChange(
        originalStart: leap,
        replacement: DateEventSpan(
          start: CalendarDate(year: 2024, month: 3, day: 1),
        ),
      ).dayShift,
      2,
    );
    expect(
      DateEventRangeChange(
        originalStart: CalendarDate(year: 2025, month: 12, day: 31),
        replacement: DateEventSpan(start: d(2)),
      ).dayShift,
      2,
    );
  });
  test('equality/hash retain anchor and complete replacement form', () {
    final a = DateEventRangeChange(
      originalStart: d(3),
      replacement: DateEventSpan(start: d(8)),
    );
    final b = DateEventRangeChange(
      originalStart: d(3),
      replacement: DateEventSpan(start: d(8)),
    );
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a,
      isNot(
        DateEventRangeChange(originalStart: d(4), replacement: b.replacement),
      ),
    );
    expect(
      a,
      isNot(
        DateEventRangeChange(
          originalStart: d(3),
          replacement: DateEventSpan(start: d(9)),
        ),
      ),
    );
    expect(
      a,
      isNot(
        DateEventRangeChange(
          originalStart: d(3),
          replacement: DateEventSpan(start: d(8), end: d(9)),
        ),
      ),
    );
    expect(a, isNot(a.replacement));
  });
}
