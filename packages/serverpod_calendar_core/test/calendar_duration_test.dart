import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:test/test.dart';

void main() {
  final constructors = <String, CalendarDuration Function(int)>{
    'weeks': (value) => CalendarDuration(weeks: value),
    'days': (value) => CalendarDuration(days: value),
    'hours': (value) => CalendarDuration(hours: value),
    'minutes': (value) => CalendarDuration(minutes: value),
    'seconds': (value) => CalendarDuration(seconds: value),
    'microsecond': (value) => CalendarDuration(microsecond: value),
  };
  for (final entry in constructors.entries) {
    final maximum = entry.key == 'microsecond'
        ? 999999
        : CalendarDuration.maxComponent;
    test('${entry.key} accepts zero and the portable upper bound', () {
      expect(entry.value(0).isZero, isTrue);
      expect(entry.value(maximum).isZero, isFalse);
    });
    test('${entry.key} rejects negative magnitudes', () {
      expect(() => entry.value(-1), throwsRangeError);
    });
    test('${entry.key} rejects values beyond its representation bound', () {
      expect(() => entry.value(maximum + 1), throwsRangeError);
    });
  }
  for (final sign in [-2, 0, 2]) {
    test('rejects invalid sign $sign', () {
      expect(() => CalendarDuration(sign: sign), throwsArgumentError);
    });
  }
  final mixedWeeks = <String, CalendarDuration Function()>{
    'days': () => CalendarDuration(weeks: 1, days: 1),
    'hours': () => CalendarDuration(weeks: 1, hours: 1),
    'minutes': () => CalendarDuration(weeks: 1, minutes: 1),
    'seconds': () => CalendarDuration(weeks: 1, seconds: 1),
    'microsecond': () => CalendarDuration(weeks: 1, microsecond: 1),
  };
  for (final entry in mixedWeeks.entries) {
    test('rejects weeks combined with ${entry.key}', () {
      expect(entry.value, throwsArgumentError);
    });
  }
  test('retains signed mixed day and clock magnitudes without carrying', () {
    final value = CalendarDuration(
      sign: -1,
      days: 15,
      hours: 25,
      minutes: 90,
      seconds: 60,
      microsecond: 123456,
    );
    expect(value.sign, -1);
    expect(value.weeks, 0);
    expect(value.days, 15);
    expect(value.hours, 25);
    expect(value.minutes, 90);
    expect(value.seconds, 60);
    expect(value.microsecond, 123456);
    expect(value.isZero, isFalse);
  });
  test(
    'calendar units remain distinct from equivalent-looking clock units',
    () {
      expect(CalendarDuration(days: 1), isNot(CalendarDuration(hours: 24)));
      expect(CalendarDuration(weeks: 1), isNot(CalendarDuration(days: 7)));
      expect(
        CalendarDuration(minutes: 1),
        isNot(CalendarDuration(seconds: 60)),
      );
    },
  );
  test('zero retains sign while consumers decide contextual validity', () {
    final positive = CalendarDuration();
    final negative = CalendarDuration(sign: -1);
    expect(positive.isZero, isTrue);
    expect(negative.isZero, isTrue);
    expect(positive.sign, 1);
    expect(negative.sign, -1);
    expect(positive, isNot(negative));
  });
  test('equality and hashing include sign and every magnitude', () {
    final value = CalendarDuration(
      sign: -1,
      days: 2,
      hours: 3,
      minutes: 4,
      seconds: 5,
      microsecond: 6,
    );
    final equal = CalendarDuration(
      sign: -1,
      days: 2,
      hours: 3,
      minutes: 4,
      seconds: 5,
      microsecond: 6,
    );
    expect(value, equal);
    expect(value.hashCode, equal.hashCode);
    final different = [
      CalendarDuration(
        days: 2,
        hours: 3,
        minutes: 4,
        seconds: 5,
        microsecond: 6,
      ),
      CalendarDuration(
        sign: -1,
        days: 1,
        hours: 3,
        minutes: 4,
        seconds: 5,
        microsecond: 6,
      ),
      CalendarDuration(
        sign: -1,
        days: 2,
        hours: 1,
        minutes: 4,
        seconds: 5,
        microsecond: 6,
      ),
      CalendarDuration(
        sign: -1,
        days: 2,
        hours: 3,
        minutes: 1,
        seconds: 5,
        microsecond: 6,
      ),
      CalendarDuration(
        sign: -1,
        days: 2,
        hours: 3,
        minutes: 4,
        seconds: 1,
        microsecond: 6,
      ),
      CalendarDuration(
        sign: -1,
        days: 2,
        hours: 3,
        minutes: 4,
        seconds: 5,
        microsecond: 1,
      ),
    ];
    expect(different, everyElement(isNot(value)));
    expect({value, equal, ...different}, hasLength(7));
    expect(CalendarDuration(weeks: 1), isNot(CalendarDuration(weeks: 2)));
  });
}
