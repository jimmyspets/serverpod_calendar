import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';

import 'icalendar_component_support.dart';
import 'icalendar_syntax.dart';
import 'icalendar_temporal_values.dart';

/// Output-only privacy projection. The caller must establish source authority
/// and complete coverage; structural completeness is checked again here.
Uint8List serializeIcalendarFreeBusy({
  required String uid,
  required DateTime stamp,
  required UtcWindow window,
  required List<AvailabilityInterval> partition,
  int maxPeriods = 1000,
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
}) => componentGuard(() {
  if (maxPeriods < 1 || maxPeriods > 1000000) {
    throw ArgumentError('Invalid period limit');
  }
  if (partition.length > maxPeriods) {
    componentFail(IcalendarComponentError.limitExceeded);
  }
  if (uid.isEmpty ||
      uid.runes.length > 1024 ||
      uid.runes.any((v) => v < 32 || v == 127)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  String utc(DateTime value, {bool end = false}) => serializeIcalendarDateTime(
    end ? TimedValue.utcEnd(value) : TimedValue.utc(value),
    exclusiveEnd: end,
  );
  final start = utc(window.start), end = utc(window.end, end: true);
  final stampValue = utc(stamp);
  if (window.duration > const Duration(days: 31)) {
    componentFail(IcalendarComponentError.invalidValue);
  }
  // Reject holes, overlaps, unordered or out-of-window data before omitting free
  // periods. Empty/unknown input must never become an all-free file.
  final normalized = combineCompleteAvailability(
    window: window,
    sources: [partition],
    maxSources: 1,
    maxInputIntervals: maxPeriods,
    maxOutputIntervals: maxPeriods,
  );
  for (final p in partition) {
    utc(p.window.start);
    utc(p.window.end, end: true);
  }
  try {
    return serializeIcalendarSyntax(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent('VCALENDAR', [
          IcalendarSyntaxProperty('VERSION', '2.0'),
          IcalendarSyntaxProperty(
            'PRODID',
            '-//serverpod_calendar//Free busy snapshot//EN',
          ),
          IcalendarSyntaxComponent('VFREEBUSY', [
            IcalendarSyntaxProperty('UID', encodeIcalendarText(uid)),
            IcalendarSyntaxProperty('DTSTAMP', stampValue),
            IcalendarSyntaxProperty('DTSTART', start),
            IcalendarSyntaxProperty('DTEND', end),
            for (final p in normalized.where(
              (p) => p.kind != AvailabilityKind.free,
            ))
              IcalendarSyntaxProperty(
                'FREEBUSY',
                '${utc(p.window.start)}/${utc(p.window.end, end: true)}',
                parameters: [
                  IcalendarSyntaxParameter('FBTYPE', [
                    switch (p.kind) {
                      AvailabilityKind.busy => 'BUSY',
                      AvailabilityKind.tentative => 'BUSY-TENTATIVE',
                      AvailabilityKind.unavailable => 'BUSY-UNAVAILABLE',
                      AvailabilityKind.free => throw StateError(
                        'Free periods are omitted',
                      ),
                    },
                  ]),
                ],
              ),
          ]),
        ]),
      ]),
      limits: syntaxLimits,
    );
  } on IcalendarSyntaxException catch (e) {
    componentFail(
      e.kind == IcalendarSyntaxError.limitExceeded
          ? IcalendarComponentError.limitExceeded
          : IcalendarComponentError.invalidValue,
    );
  }
});
