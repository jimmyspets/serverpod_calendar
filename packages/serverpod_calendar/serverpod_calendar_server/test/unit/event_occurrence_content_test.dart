@TestOn('vm')
library;

import 'package:test/test.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart'
    show UtcWindow;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';
import 'package:serverpod_calendar_server/src/event_values.dart';
import 'package:serverpod_calendar_server/src/event_protocol_values.dart';
import 'package:serverpod_calendar_server/src/event_wire_output.dart';

import 'event_overrides_test.dart' as f;

CalendarEventOccurrenceContentRequest request(
  CalendarEventContentAction action, {
  String? text,
  int day = 29,
  CalendarEventContentField field = CalendarEventContentField.summary,
}) => CalendarEventOccurrenceContentRequest(
  eventId: f.id,
  expectedRevision: 1,
  originalStart: f.timing(day),
  changes: [
    CalendarEventOccurrenceContentChange(
      field: field,
      action: action,
      text: text,
    ),
  ],
);
void main() {
  final c = f.content().copyWith(
    summary: 'Master',
    description: 'Details',
    location: 'Room',
    textParameters: CalendarEventTextParameters(
      summary: CalendarTextParameters(language: 'sv'),
    ),
  );
  test('inherit-only membership probe does not consume an override slot at capacity', () {
    CalendarEventTiming original(int index) {
      final d = DateTime.utc(2026, 3, 28).add(Duration(days: index));
      return CalendarEventTiming(
        kind: CalendarEventTimeKind.date,
        start: CalendarEventCivil(year: d.year, month: d.month, day: d.day),
      );
    }

    final master = c.copyWith(
      recurrence: c.recurrence!.copyWith(
        rule: c.recurrence!.rule!.copyWith(count: 200),
      ),
    );
    final current = validateEventOverrides(
      master,
      CalendarEventTimingOverrides(
        singles: [
          for (var i = 0; i < eventMaxOverrides; i++)
            CalendarEventSingleOverride(
              originalStart: original(i),
              contentOverrides: CalendarEventOccurrenceContent(summary: 'Own'),
            ),
        ],
        future: [],
      ),
    );
    final noop = request(CalendarEventContentAction.inheritSeries)
        .copyWith(originalStart: original(150));
    expect(changeEventContentOverrides(master, current, noop), current);
  });
  test('content-only keeps timing inheritance, disclosed fields and own annotations', () {
    final v = changeEventContentOverrides(
      c,
      null,
      request(CalendarEventContentAction.setValue, text: 'Own'),
    )!;
    expect(v.singles.single.replacement, isNull);
    expect(
      v.singles.single.contentOverrides!.textParameters!.summary!.language,
      'sv',
    );
    final before = previewEventOccurrences(c, f.query());
    final hidden = previewEventOccurrences(c, f.query(), overrides: v);
    expect(hidden.toJson(), before.toJson());
    final window = UtcWindow(
      start: DateTime.utc(2026, 3, 25),
      end: DateTime.utc(2026, 4, 5),
    );
    expect(
      eventOccupiedWindows(c, v, window, dateZone: 'Europe/Stockholm'),
      eventOccupiedWindows(c, null, window, dateZone: 'Europe/Stockholm'),
    );

    final shown = previewEventOccurrences(
      c,
      f.query().copyWith(fieldGroups: [CalendarEventFieldGroup.summary]),
      overrides: v,
    );
    expect(shown.occurrences[1].content!.summary, 'Own');
    expect(shown.occurrences[1].content!.description, isNull);
    expect(shown.occurrences[2].content!.summary, 'Master');
    expect(
      eventDisclosedOverrides(v, {CalendarEventFieldGroup.timing}),
      isNull,
    );
    final moved = changeEventOverrides(
      c,
      v,
      f.change(
        f.timing(29),
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: f.timing(30),
      ),
    )!;
    final projected = previewEventOccurrences(
      c,
      f.query().copyWith(fieldGroups: [CalendarEventFieldGroup.summary]),
      overrides: moved,
    );
    expect(projected.occurrences[1].start.day, 30);
    expect(projected.occurrences[1].content!.summary, 'Own');
    expect(projected.occurrences[2].content!.summary, 'Master');
    final back = changeEventOverrides(
      c,
      moved,
      f.change(f.timing(29), CalendarEventOccurrenceAction.clearFutureTiming),
    )!;
    expect(back.singles.single.contentOverrides!.summary, 'Own');
    expect(back.singles.single.replacement, isNull);
  });
  test(
    'clear and inherit remove own annotations without altering other fields',
    () {
      var v = changeEventContentOverrides(
        c,
        null,
        request(CalendarEventContentAction.setValue, text: 'Own'),
      );
      v = changeEventContentOverrides(
        c,
        v,
        request(CalendarEventContentAction.clearValue),
      );
      expect(v!.singles.single.contentOverrides!.summary, '');
      expect(v.singles.single.contentOverrides!.textParameters, isNull);
      expect(
        eventEffectiveOccurrenceContent(
          c,
          v.singles.single.contentOverrides,
        ).description,
        'Details',
      );
      expect(
        changeEventContentOverrides(
          c,
          v,
          request(CalendarEventContentAction.inheritSeries),
        ),
        isNull,
      );
    },
  );
  test('timing clear and cancellation preserve own content independently', () {
    var v = changeEventContentOverrides(
      c,
      null,
      request(CalendarEventContentAction.setValue, text: 'Own'),
    );
    for (final action in [
      CalendarEventOccurrenceAction.replaceSingleTiming,
      CalendarEventOccurrenceAction.cancelSingle,
      CalendarEventOccurrenceAction.clearSingleTiming,
      CalendarEventOccurrenceAction.restoreSingle,
    ]) {
      v = changeEventOverrides(
        c,
        v,
        f.change(
          f.timing(29),
          action,
          replacement:
              action == CalendarEventOccurrenceAction.replaceSingleTiming
              ? f.timing(30)
              : null,
        ),
      );
      expect(v!.singles.single.contentOverrides!.summary, 'Own');
    }
    expect(v!.singles.single.replacement, isNull);
    expect(v.singles.single.cancelled, isFalse);
  });
  test('member profile orphan and malformed content requests reject', () {
    for (final action in CalendarEventContentAction.values) {
      expect(
        () => changeEventContentOverrides(
          c,
          null,
          request(
            action,
            text: action == CalendarEventContentAction.setValue ? 'Own' : null,
            day: 26,
          ),
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => changeEventContentOverrides(
        c.copyWith(recurrence: null),
        null,
        request(CalendarEventContentAction.setValue, text: 'Own'),
      ),
      throwsArgumentError,
    );
    expect(
      () => changeEventContentOverrides(
        c,
        null,
        request(CalendarEventContentAction.setValue, text: ''),
      ),
      throwsArgumentError,
    );
    final v = changeEventContentOverrides(
      c,
      null,
      request(CalendarEventContentAction.setValue, text: 'Own'),
    );
    final changed = c.copyWith(
      recurrence: c.recurrence!.copyWith(exclusions: [f.timing(29)]),
    );
    expect(() => validateEventOverrides(changed, v), throwsArgumentError);
  });
  test('component versions pin text and retain creation across timing-scope transfer', () {
    final now = DateTime.utc(2026, 10, 24);
    var v = changeEventContentOverrides(
      c,
      null,
      request(CalendarEventContentAction.setValue, text: 'Own'),
    );
    final initial = eventProtocolBaseline(c, null, now, now);
    var state = advanceEventProtocol(initial, c, null, c, v, now);
    final created = state.overrides.single.version.created;
    expect(state.version.sequence, 0);
    expect(state.overrides.single.version.sequence, 0);
    final same = advanceEventProtocol(
      state,
      c,
      v,
      c,
      v,
      now.add(const Duration(days: 1)),
    );
    expect(same, state);
    final changed = advanceEventProtocol(
      state,
      c,
      v,
      c.copyWith(summary: 'New master'),
      v,
      now.add(const Duration(days: 1)),
    );
    expect(changed.overrides.single.version, state.overrides.single.version);
    final range = changeEventOverrides(
      c,
      v,
      f.change(
        f.timing(29),
        CalendarEventOccurrenceAction.replaceFutureTiming,
        replacement: f.timing(30),
      ),
    );
    state = advanceEventProtocol(
      state,
      c,
      v,
      c,
      range,
      now.add(const Duration(days: 2)),
    );
    expect(state.overrides.single.version.created, created);
    expect(state.overrides.single.version.sequence, 1);
    v = changeEventOverrides(
      c,
      range,
      f.change(f.timing(29), CalendarEventOccurrenceAction.clearFutureTiming),
    );
    state = advanceEventProtocol(
      state,
      c,
      range,
      c,
      v,
      now.add(const Duration(days: 3)),
    );
    expect(state.overrides.single.version.created, created);
    expect(state.overrides.single.version.sequence, 2);
  });
  test('content-only export rejects rather than pinning invented timing and v1 rejects', () {
    final now = DateTime.utc(2026, 10, 24);
    final v = changeEventContentOverrides(
      c,
      null,
      request(CalendarEventContentAction.setValue, text: 'Own'),
    );
    final state = eventProtocolBaseline(c, v, now, now);
    final snapshot = CalendarEventPolicySnapshot(
      f.id,
      f.id,
      1,
      c,
      'synthetic@example.invalid',
      now,
      timingOverrides: v,
      protocolState: state,
    );
    expect(() => eventExportBytes([snapshot]), throwsArgumentError);
    final baseline = eventImportBaseline(
      'synthetic@example.invalid',
      c,
      v,
      state,
    );
    expect(
      () => validateEventImportBaseline(
        baseline.copyWith(profile: baseline.profile.replaceFirst('v2', 'v1')),
        'synthetic@example.invalid',
      ),
      throwsStateError,
    );
  });
}
