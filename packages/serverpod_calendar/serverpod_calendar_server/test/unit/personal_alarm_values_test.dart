@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/alarm_values.dart';

void main() {
  CalendarAlarmDefinition relative() => CalendarAlarmDefinition(
    relativeDuration: CalendarAlarmDuration(sign: -1, days: 1, hours: 2),
    anchor: CalendarAlarmAnchor.start,
  );
  test('exact one trigger, relative anchor and UTC whole-second guards', () {
    expect(
      () => validateAlarmDefinition(CalendarAlarmDefinition()),
      throwsArgumentError,
    );
    final absolute = CalendarAlarmDefinition(absoluteUtc: DateTime.utc(2026));
    expect(validateAlarmDefinition(absolute), same(absolute));
    expect(
      () => validateAlarmDefinition(
        relative().copyWith(absoluteUtc: DateTime.utc(2026)),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateAlarmDefinition(
        absolute.copyWith(anchor: CalendarAlarmAnchor.start),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateAlarmDefinition(
        absolute.copyWith(absoluteUtc: DateTime.utc(2026, 1, 1, 0, 0, 0, 1)),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateAlarmDefinition(
        absolute.copyWith(absoluteUtc: DateTime.utc(2100)),
      ),
      throwsArgumentError,
    );
    expect(
      () => validateAlarmDefinition(
        CalendarAlarmDefinition(relativeDuration: CalendarAlarmDuration()),
      ),
      throwsArgumentError,
    );
  });
  test(
    'signed units retain calendar versus clock meaning and enforce caps',
    () {
      final d = validateAlarmDefinition(relative());
      expect(alarmDuration(d.relativeDuration!).days, 1);
      expect(alarmDuration(d.relativeDuration!).hours, 2);
      expect(alarmDuration(d.relativeDuration!).sign, -1);
      expect(
        () => validateAlarmDefinition(
          d.copyWith(relativeDuration: CalendarAlarmDuration(days: 367)),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateAlarmDefinition(
          d.copyWith(
            relativeDuration: CalendarAlarmDuration(weeks: 1, days: 1),
          ),
        ),
        throwsArgumentError,
      );
    },
  );
  test('portable maximum magnitudes cannot wrap the scheduling bound', () {
    const maximum = 9007199254740991;
    for (final huge in [
      CalendarAlarmDuration(weeks: maximum),
      CalendarAlarmDuration(days: maximum),
      CalendarAlarmDuration(hours: maximum),
      CalendarAlarmDuration(minutes: maximum),
      CalendarAlarmDuration(seconds: maximum),
    ]) {
      expect(
        () => validateAlarmDefinition(
          relative().copyWith(relativeDuration: huge),
        ),
        throwsArgumentError,
      );
      expect(
        () => validateAlarmDefinition(
          relative().copyWith(repeat: 100, repeatInterval: huge),
        ),
        throwsArgumentError,
      );
    }
  });
  test('repeat pairing, positive interval, count and aggregate span', () {
    final d = relative();
    for (final invalid in [
      d.copyWith(repeat: 1),
      d.copyWith(repeatInterval: CalendarAlarmDuration(minutes: 1)),
      d.copyWith(
        repeat: 101,
        repeatInterval: CalendarAlarmDuration(minutes: 1),
      ),
      d.copyWith(repeat: 1, repeatInterval: CalendarAlarmDuration()),
      d.copyWith(
        repeat: 1,
        repeatInterval: CalendarAlarmDuration(sign: -1, minutes: 1),
      ),
      d.copyWith(repeat: 100, repeatInterval: CalendarAlarmDuration(days: 4)),
    ]) {
      expect(() => validateAlarmDefinition(invalid), throwsArgumentError);
    }
    expect(
      validateAlarmDefinition(
        d.copyWith(
          repeat: 100,
          repeatInterval: CalendarAlarmDuration(minutes: 1),
        ),
      ).repeat,
      100,
    );
  });
  test('zone names are exact and DATE requires explicit midnight zone', () {
    final date = CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: CalendarEventCivil(year: 2026, month: 3, day: 29),
    );
    expect(alarmEventAnchorCompatible(relative(), date), isFalse);
    expect(
      alarmEventAnchorCompatible(
        relative().copyWith(dateZoneId: 'Europe/Stockholm'),
        date,
      ),
      isTrue,
    );
    expect(
      () => validateAlarmDefinition(
        relative().copyWith(dateZoneId: 'europe/stockholm'),
      ),
      throwsArgumentError,
    );
    expect(
      () =>
          validateAlarmDefinition(relative().copyWith(dateZoneId: 'CET typo')),
      throwsArgumentError,
    );
  });
  test('implicit event ends do not provide an END anchor', () {
    final point = CalendarEventTiming(
      kind: CalendarEventTimeKind.utc,
      start: CalendarEventCivil(year: 2026, month: 3, day: 29),
    );
    final end = relative().copyWith(anchor: CalendarAlarmAnchor.end);
    expect(alarmEventAnchorCompatible(relative(), point), isTrue);
    expect(alarmEventAnchorCompatible(end, point), isFalse);
    expect(
      alarmEventAnchorCompatible(
        end,
        point.copyWith(duration: CalendarEventDuration(hours: 1)),
      ),
      isTrue,
    );
  });
  test('absolute undated and independent start/due task anchors', () {
    final undated = CalendarTaskTiming(kind: CalendarTaskTimeKind.undated);
    expect(alarmTaskAnchorCompatible(relative(), undated), isFalse);
    expect(
      alarmTaskAnchorCompatible(
        CalendarAlarmDefinition(absoluteUtc: DateTime.utc(2026)),
        undated,
      ),
      isTrue,
    );
    final due = CalendarTaskTiming(
      kind: CalendarTaskTimeKind.utc,
      due: CalendarEventCivil(year: 2026, month: 3, day: 29),
    );
    expect(alarmTaskAnchorCompatible(relative(), due), isFalse);
    expect(
      alarmTaskAnchorCompatible(
        relative().copyWith(anchor: CalendarAlarmAnchor.end),
        due,
      ),
      isTrue,
    );
  });
}
