import 'dart:convert';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'event_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_output.dart';
import 'event_wire_storage.dart';
import 'generated/protocol.dart';

/// A detached original identity; this is neither a native edit nor a receipt.
final class CalendarSchedulingCancellationTarget {
  CalendarSchedulingCancellationTarget._(
    CalendarEventTiming point,
    this.isThisAndFuture,
  ) : _point = CalendarEventTiming.fromJson(point.toJson());
  final CalendarEventTiming _point;
  final bool isThisAndFuture;
  CalendarEventTiming get originalStart =>
      CalendarEventTiming.fromJson(_point.toJson());
}

/// Untrusted wire projection. It proves no publication history or authority.
final class CalendarPublishedRangeCancellation {
  CalendarPublishedRangeCancellation._(
    this.message,
    Iterable<CalendarSchedulingCancellationTarget> targets,
    this.requiredAfterSequence,
    this.minimumStamp,
  ) : targets = List.unmodifiable(targets);
  final IcalendarSchedulingMessage message;
  final List<CalendarSchedulingCancellationTarget> targets;
  final int requiredAfterSequence;
  final DateTime minimumStamp;
}

/// Projects a claimed, unmasked active published REQUEST to one complete CANCEL
/// bundle. Later durable callers must prove provenance and supply history floors.
/// No clock, sequence allocation, authorization, storage or delivery is involved.
CalendarPublishedRangeCancellation projectPublishedRangeCancellation({
  required IcalendarSyntaxDocument basis,
  required CalendarEventTiming originalStart,
  required int sequence,
  required DateTime stamp,
  int minimumSequence = 0,
  DateTime? minimumStamp,
  int maxBytes = 524288,
  int maxTargets = 64,
  int maxZones = 32,
  int maxCandidateWork = eventMaxCandidateWork,
  RecurrenceWorkBudget? sharedWorkBudget,
}) {
  try {
    RangeError.checkValueInInterval(maxBytes, 1, 524288);
    RangeError.checkValueInInterval(maxTargets, 1, 64);
    RangeError.checkValueInInterval(maxZones, 1, 32);
    RangeError.checkValueInInterval(maxCandidateWork, 1, eventMaxCandidateWork);
    RangeError.checkValueInInterval(sequence, 0, eventMaxSequence);
    RangeError.checkValueInInterval(minimumSequence, 0, eventMaxSequence);
    if (sharedWorkBudget != null &&
        sharedWorkBudget.maxWork > maxCandidateWork) {
      throw ArgumentError();
    }
    TimedValue.utc(stamp);
    if (minimumStamp != null) TimedValue.utc(minimumStamp);
    final work =
        sharedWorkBudget ?? RecurrenceWorkBudget(maxWork: maxCandidateWork);
    final syntax = IcalendarSyntaxLimits(maxBytes: maxBytes);
    final limits = IcalendarComponentLimits(
      maxEvents: 65,
      maxOverridesPerEvent: 64,
      maxZones: maxZones,
      maxCandidates: maxCandidateWork,
    );
    void raw(IcalendarSyntaxDocument value) {
      final bytes = serializeIcalendarSyntax(value, limits: syntax);
      for (var i = 0; i < bytes.length; i += 64) {
        work.charge();
      }
    }

    raw(basis);
    if (basis.components.length != 1 ||
        basis.components.single.canonicalName != 'VCALENDAR') {
      throw ArgumentError();
    }
    final root = basis.components.single;
    final methods = root.entries
        .whereType<IcalendarSyntaxProperty>()
        .where((p) => p.canonicalName == 'METHOD')
        .toList();
    if (methods.length != 1 ||
        methods.single.parameters.isNotEmpty ||
        methods.single.value.codeUnits.any((v) => v <= 32 || v >= 127) ||
        methods.single.value.toUpperCase() != 'REQUEST') {
      throw ArgumentError();
    }
    // This removes only the scheduling envelope for full standalone validation;
    // no component property, unsupported data or cancellation is discarded.
    final calendar = validateIcalendarEventCalendar(
      IcalendarSyntaxDocument([
        IcalendarSyntaxComponent(root.name, [
          for (final entry in root.entries)
            if (entry is! IcalendarSyntaxProperty ||
                entry.canonicalName != 'METHOD')
              entry,
        ]),
      ]),
      syntaxLimits: syntax,
      limits: limits,
      sharedWorkBudget: work,
    );
    if (calendar.series.length != 1) throw ArgumentError();
    final source = eventWireProjection(
      calendar.series.single,
      sharedWorkBudget: work,
    );
    if ((source.content.recurrence == null &&
            (source.content.periods?.isEmpty ?? true)) ||
        originalStart.end != null ||
        originalStart.duration != null ||
        !eventSchedulingMember(
          source.content,
          originalStart,
          sharedWorkBudget: work,
        )) {
      throw ArgumentError();
    }
    final projected = projectIcalendarRequestFields(
      calendar,
      syntaxLimits: syntax,
      limits: limits,
      sharedWorkBudget: work,
    );
    raw(projected.source);
    var floor = minimumSequence;
    var stampFloor = minimumStamp;
    final keys = <String>{};
    for (final e in projected.events) {
      work.charge();
      if (e.sequence == null || e.status == IcalendarEventStatus.cancelled) {
        throw ArgumentError();
      }
      if (e.sequence! > floor) floor = e.sequence!;
      if (stampFloor == null || e.stamp.isAfter(stampFloor)) {
        stampFloor = e.stamp;
      }
      if (e.isOverride && !keys.add(_order(_point(e.originalStart!)))) {
        throw ArgumentError();
      }
    }
    if (sequence <= floor || stamp.isBefore(stampFloor!)) throw ArgumentError();
    final master = projected.events.singleWhere((e) => !e.isOverride);
    String roster(IcalendarEventParticipants p) {
      if (p.organizer == null ||
          p.attendees.isEmpty ||
          p.attendees.length > 64 ||
          p.attendees.map((a) => a.address).toSet().length !=
              p.attendees.length) {
        throw ArgumentError();
      }
      // Standalone series validation already compares every explicit parameter
      // using RFC token semantics; preserve the master's actual claim spelling.
      final attendees = p.attendees.map((a) => a.address).toList()..sort();
      return jsonEncode([p.organizer!.address, attendees]);
    }

    final claims = roster(master.participants);
    for (final e in projected.events) {
      work.charge();
      if (roster(e.participants) != claims) throw ArgumentError();
    }
    final later =
        projected.events
            .where(
              (e) =>
                  e.isOverride &&
                  _order(_point(e.originalStart!))
                          .compareTo(_order(originalStart)) >
                      0,
            )
            .toList()
          ..sort(
            (a, b) =>
                _order(_point(a.originalStart!))
                    .compareTo(_order(_point(b.originalStart!))),
          );
    if (later.length + 1 > maxTargets) {
      throw const RecurrenceLimitException('publishedCancellationTargets');
    }
    final targets = [
      CalendarSchedulingCancellationTarget._(originalStart, true),
      for (final e in later)
        CalendarSchedulingCancellationTarget._(
          _point(e.originalStart!),
          e.isThisAndFuture,
        ),
    ];
    final writer = EventComponentWriter();
    final document = IcalendarSyntaxDocument([
      IcalendarSyntaxComponent('VCALENDAR', [
        IcalendarSyntaxProperty('VERSION', '2.0'),
        IcalendarSyntaxProperty(
          'PRODID',
          '-//Serverpod Calendar//Range cancellation//EN',
        ),
        IcalendarSyntaxProperty('METHOD', 'CANCEL'),
        if (originalStart.zoneId != null)
          createIcalendarTimeZone(originalStart.zoneId!),
        for (final target in targets)
          IcalendarSyntaxComponent('VEVENT', [
            for (final p
                in master.source.entries.whereType<IcalendarSyntaxProperty>())
              if ({'UID', 'ORGANIZER', 'ATTENDEE'}.contains(p.canonicalName)) p,
            writer.time(
              'RECURRENCE-ID',
              target.originalStart,
              future: target.isThisAndFuture,
            ),
            IcalendarSyntaxProperty('SEQUENCE', '$sequence'),
            IcalendarSyntaxProperty('DTSTAMP', writer.utc(stamp)),
            IcalendarSyntaxProperty('STATUS', 'CANCELLED'),
          ]),
      ]),
    ]);
    raw(document);
    final result = validateIcalendarSchedulingMessage(
      document,
      syntaxLimits: syntax,
      limits: IcalendarComponentLimits(
        maxEvents: maxTargets,
        maxOverridesPerEvent: maxTargets,
        maxZones: maxZones,
        maxCandidates: maxCandidateWork,
      ),
      sharedWorkBudget: work,
    );
    // Bound actual codec output too, including normalized parameter encoding.
    final bytes = serializeIcalendarSchedulingMessage(
      result,
      syntaxLimits: syntax,
    );
    for (var i = 0; i < bytes.length; i += 64) {
      work.charge();
    }
    return CalendarPublishedRangeCancellation._(
      result,
      targets,
      floor,
      stampFloor,
    );
  } on IcalendarSyntaxException catch (e) {
    if (e.kind == IcalendarSyntaxError.limitExceeded) {
      throw const RecurrenceLimitException('publishedCancellationSource');
    }
    throw ArgumentError('Unsupported published range cancellation');
  } on IcalendarComponentException catch (e) {
    if (e.kind == IcalendarComponentError.limitExceeded) {
      throw const RecurrenceLimitException('publishedCancellationWork');
    }
    throw ArgumentError('Unsupported published range cancellation');
  } on ArgumentError {
    throw ArgumentError('Unsupported published range cancellation');
  } on StateError {
    throw ArgumentError('Unsupported published range cancellation');
  }
}

CalendarEventTiming _point(Object value) {
  if (value is CalendarDate) {
    return CalendarEventTiming(
      kind: CalendarEventTimeKind.date,
      start: eventDate(value),
    );
  }
  final time = value as TimedValue;
  return CalendarEventTiming(
    kind: time.zoneId == null
        ? CalendarEventTimeKind.utc
        : CalendarEventTimeKind.zoned,
    zoneId: time.zoneId,
    start: eventCivil(time.civil),
  );
}

String _order(CalendarEventTiming point) => DateTime.utc(
  point.start.year,
  point.start.month,
  point.start.day,
  point.start.hour,
  point.start.minute,
  point.start.second,
).toIso8601String();
