part of 'event_values.dart';

CalendarEventSourceDuration _eventSignedDuration(CalendarDuration d) =>
    CalendarEventSourceDuration(
      sign: d.sign,
      weeks: d.weeks,
      days: d.days,
      hours: d.hours,
      minutes: d.minutes,
      seconds: d.seconds,
    );
CalendarEventSourceAlarm eventSourceAlarm(IcalendarDisplayAlarm a) =>
    CalendarEventSourceAlarm(
      description: CalendarEventSourceText(
        value: a.description.value,
        parameters:
            a.description.language == null &&
                a.description.alternativeUri == null
            ? null
            : CalendarTextParameters(
                language: a.description.language,
                alternativeUri: a.description.alternativeUri,
              ),
      ),
      relativeDuration: a.trigger.relativeDuration == null
          ? null
          : _eventSignedDuration(a.trigger.relativeDuration!),
      absoluteUtc: a.trigger.absoluteUtc,
      related: a.trigger.related,
      uid: a.uid,
      acknowledged: a.acknowledged,
      repeat: a.repeat,
      repeatInterval: a.repeatInterval == null
          ? null
          : _eventSignedDuration(a.repeatInterval!),
      snoozeTargetUid: a.snoozeTargetUid,
    );
IcalendarSyntaxComponent eventAlarmSyntax(CalendarEventSourceAlarm a) {
  IcalendarSyntaxParameter param(String n, String v) =>
      IcalendarSyntaxParameter(n, [v]);
  IcalendarSyntaxProperty property(
    String n,
    String v, [
    List<IcalendarSyntaxParameter> parameters = const [],
  ]) => IcalendarSyntaxProperty(n, v, parameters: parameters);
  String duration(CalendarEventSourceDuration d) => serializeIcalendarDuration(
    CalendarDuration(
      sign: d.sign,
      weeks: d.weeks,
      days: d.days,
      hours: d.hours,
      minutes: d.minutes,
      seconds: d.seconds,
    ),
  );
  String utc(DateTime value) =>
      serializeIcalendarDateTime(TimedValue.utc(value));
  if ((a.relativeDuration == null) == (a.absoluteUtc == null)) {
    throw ArgumentError('Exactly one source alarm trigger required');
  }
  final text = a.description;
  return IcalendarSyntaxComponent('VALARM', [
    property('ACTION', 'DISPLAY'),
    property('DESCRIPTION', encodeIcalendarText(text.value), [
      if (text.parameters?.language != null)
        param('LANGUAGE', text.parameters!.language!),
      if (text.parameters?.alternativeUri != null)
        param('ALTREP', text.parameters!.alternativeUri!),
    ]),
    property(
      'TRIGGER',
      a.absoluteUtc == null
          ? duration(a.relativeDuration!)
          : utc(a.absoluteUtc!),
      [
        if (a.absoluteUtc != null) param('VALUE', 'DATE-TIME'),
        if (a.related != null) param('RELATED', a.related!),
      ],
    ),
    if (a.uid != null) property('UID', encodeIcalendarText(a.uid!)),
    if (a.acknowledged != null) property('ACKNOWLEDGED', utc(a.acknowledged!)),
    if (a.repeat != null) property('REPEAT', '${a.repeat}'),
    if (a.repeatInterval != null)
      property('DURATION', duration(a.repeatInterval!)),
    if (a.snoozeTargetUid != null)
      property('RELATED-TO', encodeIcalendarText(a.snoozeTargetUid!), [
        param('RELTYPE', 'SNOOZE'),
      ]),
  ]);
}

void validateEventAlarmAnchors(
  CalendarEventContent content,
  CalendarEventTimingOverrides? edits,
  CalendarEventSourceMetadata? metadata,
) {
  if (!(metadata?.alarms?.any(
        (a) => a.relativeDuration != null && (a.related ?? 'START') == 'END',
      ) ??
      false)) {
    return;
  }
  void check(CalendarEventTiming t) {
    if (t.end == null && t.duration == null) {
      throw ArgumentError(
        'Retained END source alarm requires explicit end or duration',
      );
    }
  }

  check(content.timing);
  for (final s in edits?.singles ?? <CalendarEventSingleOverride>[]) {
    if (s.replacement != null) check(s.replacement!);
  }
  for (final s in edits?.future ?? <CalendarEventFutureOverride>[]) {
    check(s.replacement);
  }
}
