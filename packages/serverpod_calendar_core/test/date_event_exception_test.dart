import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

CalendarDate d(int day) => CalendarDate(year: 2026, month: 1, day: day);

void main() {
  test('cancellation retains original identity without a replacement', () {
    final value = DateEventException.cancel(originalStart: d(2));
    expect(value.originalStart, d(2));
    expect(value.isCancelled, isTrue);
    expect(value.replacement, isNull);
  });
  test('replacement retains identity and complete changed span', () {
    final span = DateEventSpan(start: d(8), end: d(11));
    final value = DateEventException.replace(
      originalStart: d(2),
      replacement: span,
    );
    expect(value.originalStart, d(2));
    expect(value.isCancelled, isFalse);
    expect(identical(value.replacement, span), isTrue);
    expect(value.replacement!.dayCount, 3);
  });
  test(
    'exception equality includes original identity and replacement form',
    () {
      final a = DateEventException.replace(
        originalStart: d(2),
        replacement: DateEventSpan(start: d(8)),
      );
      final b = DateEventException.replace(
        originalStart: d(2),
        replacement: DateEventSpan(start: d(8)),
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(
        a,
        isNot(
          DateEventException.replace(
            originalStart: d(3),
            replacement: b.replacement!,
          ),
        ),
      );
      expect(
        a,
        isNot(
          DateEventException.replace(
            originalStart: d(2),
            replacement: DateEventSpan(start: d(8), end: d(9)),
          ),
        ),
      );
      expect(a, isNot(DateEventException.cancel(originalStart: d(2))));
      final cancelled = DateEventException.cancel(originalStart: d(2));
      expect(cancelled, DateEventException.cancel(originalStart: d(2)));
      expect(
        cancelled.hashCode,
        DateEventException.cancel(originalStart: d(2)).hashCode,
      );
      expect(cancelled, isNot(DateEventException.cancel(originalStart: d(3))));
    },
  );
  test(
    'moved occurrence retains original date independently of actual start',
    () {
      final value = DateEventOccurrence(
        originalStart: d(2),
        span: DateEventSpan(start: d(8)),
      );
      expect(value.originalStart, d(2));
      expect(value.span.start, d(8));
    },
  );
  test('occurrence equality does not collapse equal actual starts', () {
    final span = DateEventSpan(start: d(8));
    final a = DateEventOccurrence(originalStart: d(2), span: span);
    final same = DateEventOccurrence(
      originalStart: d(2),
      span: DateEventSpan(start: d(8)),
    );
    expect(a, same);
    expect(a.hashCode, same.hashCode);
    expect(a, isNot(DateEventOccurrence(originalStart: d(3), span: span)));
    expect(
      a,
      isNot(
        DateEventOccurrence(
          originalStart: d(2),
          span: DateEventSpan(start: d(9)),
        ),
      ),
    );
    expect(a, isNot(span));
  });
}
