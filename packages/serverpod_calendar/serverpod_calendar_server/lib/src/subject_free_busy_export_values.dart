import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

/// Anonymous complete snapshots in caller-defined order. This proves geometry,
/// not contributor completeness, host authority or a scheduling identity.
Uint8List serializeSubjectFreeBusySnapshots({
  required List<String> uids,
  required DateTime stamp,
  required UtcWindow window,
  required List<List<AvailabilityInterval>> partitions,
  int maxPeriods = 1000,
  int maxBytes = 262144,
}) {
  if (partitions.isEmpty ||
      partitions.length > 8 ||
      uids.length != partitions.length ||
      uids.toSet().length != uids.length ||
      maxPeriods < 1 ||
      maxPeriods > 1000 ||
      maxBytes < 1 ||
      maxBytes > 262144) {
    throw ArgumentError('Invalid subject snapshot profile');
  }
  final limits = IcalendarSyntaxLimits(maxBytes: maxBytes);
  final components = <IcalendarSyntaxComponent>[];
  var periods = 0;
  for (var i = 0; i < partitions.length; i++) {
    final document = parseIcalendarSyntax(
      serializeIcalendarFreeBusy(
        uid: uids[i],
        stamp: stamp,
        window: window,
        partition: partitions[i],
        syntaxLimits: limits,
      ),
      limits: limits,
    );
    final component = document.components.single.entries
        .whereType<IcalendarSyntaxComponent>()
        .single;
    periods += component.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == 'FREEBUSY')
        .length;
    if (periods > maxPeriods) {
      throw const IcalendarComponentException(
        IcalendarComponentError.limitExceeded,
      );
    }
    components.add(component);
  }
  return serializeIcalendarSyntax(
    IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty(
          'PRODID',
          '-//serverpod_calendar//Subject snapshots//EN',
        ),
        ...components,
      ]),
    ]),
    limits: limits,
  );
}
