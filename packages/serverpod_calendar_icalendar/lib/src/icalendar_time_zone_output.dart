import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'icalendar_syntax.dart';

/// Deterministic bounded VTIMEZONE from pinned IANA evidence. Explicit onsets
/// avoid inventing indefinite future RRULEs or retaining obsolete source rules.
IcalendarSyntaxComponent createIcalendarTimeZone(
  String zoneId, {
  int maxOnsets = 8192,
}) {
  final values = NamedZoneResolver().calendarProfileObservances(
    zoneId: zoneId,
    maxObservances: maxOnsets,
  );
  final groups = <(Duration, Duration, bool), List<ZoneObservance>>{};
  for (final value in values) {
    groups
        .putIfAbsent((
          value.offsetFrom,
          value.offsetTo,
          value.isDaylight,
        ), () => [])
        .add(value);
  }
  String offset(Duration value) {
    final seconds = value.inSeconds.abs();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.isNegative ? '-' : '+'}${two(seconds ~/ 3600)}${two(seconds ~/ 60 % 60)}'
        '${seconds % 60 == 0 ? '' : two(seconds % 60)}';
  }

  String wall(ZoneObservance value) {
    final date = value.instant.add(value.offsetFrom);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}${two(date.month)}${two(date.day)}T${two(date.hour)}${two(date.minute)}${two(date.second)}';
  }

  return IcalendarSyntaxComponent('VTIMEZONE', [
    IcalendarSyntaxProperty('TZID', encodeIcalendarText(zoneId)),
    for (final group in groups.entries)
      IcalendarSyntaxComponent(group.key.$3 ? 'DAYLIGHT' : 'STANDARD', [
        IcalendarSyntaxProperty('DTSTART', wall(group.value.first)),
        IcalendarSyntaxProperty('TZOFFSETFROM', offset(group.key.$1)),
        IcalendarSyntaxProperty('TZOFFSETTO', offset(group.key.$2)),
        if (group.value.length > 1)
          IcalendarSyntaxProperty(
            'RDATE',
            group.value.skip(1).map(wall).join(','),
          ),
      ]),
  ]);
}
