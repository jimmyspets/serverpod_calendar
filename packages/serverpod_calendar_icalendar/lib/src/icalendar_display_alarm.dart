part of 'icalendar_event_calendar.dart';

/// Source trigger only. No firing instant, recipient or pending work is inferred.
final class IcalendarAlarmTrigger {
  IcalendarAlarmTrigger._(
    this.source,
    this.relativeDuration,
    this.absoluteUtc,
    this.related,
  );
  final IcalendarSyntaxProperty source;
  final CalendarDuration? relativeDuration;
  final DateTime? absoluteUtc;
  final String? related;
  String? get effectiveRelated =>
      relativeDuration == null ? null : related ?? 'START';
}

/// Unarmed source DISPLAY alarm; ACKNOWLEDGED is not a verified native action.
final class IcalendarDisplayAlarm {
  IcalendarDisplayAlarm._(
    this.source,
    this.description,
    this.trigger,
    this.uid,
    this.acknowledged,
    this.repeat,
    this.repeatInterval,
  );
  final IcalendarSyntaxComponent source;
  final IcalendarEventText description;
  final IcalendarAlarmTrigger trigger;
  final String? uid;
  final DateTime? acknowledged;
  final int? repeat;
  final CalendarDuration? repeatInterval;
}

List<IcalendarDisplayAlarm> _displayAlarms(
  IcalendarSyntaxComponent task,
  ComponentBudget budget,
) {
  final result = <IcalendarDisplayAlarm>[];
  final uids = <String>{};
  for (final source in task.entries.whereType<IcalendarSyntaxComponent>()) {
    if (source.canonicalName != 'VALARM' ||
        source.entries.any((e) => e is IcalendarSyntaxComponent)) {
      componentFail(IcalendarComponentError.unsupportedComponent);
    }
    if (result.length >= budget.limits.maxAlarmsPerTask) {
      componentFail(IcalendarComponentError.limitExceeded);
    }
    budget.alarm();
    final p = componentProperties(source, {
      'ACTION',
      'DESCRIPTION',
      'TRIGGER',
      'UID',
      'ACKNOWLEDGED',
      'REPEAT',
      'DURATION',
    });
    final action = requiredProperty(p, 'ACTION');
    componentParameters(action, {});
    if (componentToken(action.value) != 'DISPLAY') {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
    final description = _componentTextValue(
      requiredProperty(p, 'DESCRIPTION'),
      4096,
    )!;
    final property = requiredProperty(p, 'TRIGGER'),
        parameters = componentParameters(property, {'VALUE', 'RELATED'});
    final type = parameters['VALUE'] == null
        ? 'DURATION'
        : componentToken(parameters['VALUE']!);
    CalendarDuration? relative;
    DateTime? absolute;
    String? related;
    if (type == 'DURATION') {
      relative = parseIcalendarDuration(property.value);
      _alarmDurationBound(relative, budget.limits);
      related = parameters['RELATED'] == null
          ? null
          : componentToken(parameters['RELATED']!);
      if (related != null && !{'START', 'END'}.contains(related)) {
        componentFail(IcalendarComponentError.invalidValue);
      }
    } else if (type == 'DATE-TIME') {
      if (parameters.containsKey('RELATED') || !property.value.endsWith('Z')) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      absolute = parseIcalendarDateTime(property.value).instant;
    } else {
      componentFail(IcalendarComponentError.invalidValue);
    }
    String? uid;
    if (p['UID'] != null) {
      uid = componentText(p['UID']!.single);
      if (uid.isEmpty) componentFail(IcalendarComponentError.invalidValue);
      if (!uids.add(uid)) componentFail(IcalendarComponentError.duplicate);
    }
    final acknowledged = p['ACKNOWLEDGED'] == null
        ? null
        : componentUtc(p['ACKNOWLEDGED']!.single);
    if (p.containsKey('REPEAT') != p.containsKey('DURATION')) {
      componentFail(IcalendarComponentError.missing);
    }
    final repeat = _componentInteger(p['REPEAT']?.single);
    CalendarDuration? interval;
    if (repeat != null) {
      if (repeat > budget.limits.maxAlarmRepeat) {
        componentFail(IcalendarComponentError.limitExceeded);
      }
      final duration = p['DURATION']!.single;
      componentParameters(duration, {});
      interval = parseIcalendarDuration(duration.value);
      if (interval.sign < 0 || interval.isZero) {
        componentFail(IcalendarComponentError.invalidValue);
      }
      _alarmDurationBound(interval, budget.limits);
      _alarmDurationBound(interval, budget.limits, multiplier: repeat);
    }
    budget.taskMetadata(
      description.value.runes.length +
          (description.language?.runes.length ?? 0) +
          (description.alternativeUri?.runes.length ?? 0) +
          (uid?.runes.length ?? 0),
    );
    result.add(
      IcalendarDisplayAlarm._(
        source,
        description,
        IcalendarAlarmTrigger._(property, relative, absolute, related),
        uid,
        acknowledged,
        repeat,
        interval,
      ),
    );
  }
  return List.unmodifiable(result);
}

void _alarmDurationBound(
  CalendarDuration d,
  IcalendarComponentLimits limits, {
  int multiplier = 1,
}) {
  final days = BigInt.from(d.weeks) * BigInt.from(7) + BigInt.from(d.days);
  final magnitude =
      days * BigInt.from(86400) +
      BigInt.from(d.hours) * BigInt.from(3600) +
      BigInt.from(d.minutes) * BigInt.from(60) +
      BigInt.from(d.seconds);
  if (magnitude * BigInt.from(multiplier) >
      BigInt.from(limits.maxAlarmDurationDays) * BigInt.from(86400)) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
}

void _taskAlarmAnchors(IcalendarTask task) {
  for (final alarm in task.alarms) {
    switch (alarm.trigger.effectiveRelated) {
      case 'START':
        if (task.dateTiming?.start == null && task.timedTiming?.start == null) {
          componentFail(IcalendarComponentError.missing);
        }
      case 'END':
        if (task.dateTiming?.effectiveDue == null &&
            task.timedTiming?.effectiveDue == null) {
          componentFail(IcalendarComponentError.missing);
        }
    }
  }
}

void _matchingDisplayAlarms(
  List<IcalendarDisplayAlarm> master,
  List<IcalendarDisplayAlarm> override,
) {
  if (override.isEmpty) return;
  if (override.length != master.length) {
    componentFail(IcalendarComponentError.unsupportedProperty);
  }
  for (var i = 0; i < override.length; i++) {
    final a = override[i], b = master[i];
    if (a.uid != b.uid ||
        a.acknowledged != b.acknowledged ||
        a.repeat != b.repeat ||
        a.repeatInterval != b.repeatInterval ||
        a.trigger.relativeDuration != b.trigger.relativeDuration ||
        a.trigger.absoluteUtc != b.trigger.absoluteUtc ||
        a.trigger.effectiveRelated != b.trigger.effectiveRelated ||
        a.description.value != b.description.value ||
        a.description.language != b.description.language ||
        a.description.alternativeUri != b.description.alternativeUri) {
      componentFail(IcalendarComponentError.unsupportedProperty);
    }
  }
}
