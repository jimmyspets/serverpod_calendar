/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_occurrence_content.dart' as _irmu5f0n;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_timing.dart' as _i9h8y8lg;

@_isc.immutable
abstract class CalendarTaskOccurrence
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskOccurrence._({
    required this.originalStart,
    this.actualStart,
    this.replacementTiming,
    this.futureTiming,
    this.content,
    this.contentOverrides,
    this.startUtc,
    this.duration,
    this.dueDate,
    this.dueUtc,
    required this.progress,
  });

  const factory CalendarTaskOccurrence({
    required _ieswiaty.CalendarEventTiming originalStart,
    _ieswiaty.CalendarEventTiming? actualStart,
    _i9h8y8lg.CalendarTaskTiming? replacementTiming,
    _i9h8y8lg.CalendarTaskTiming? futureTiming,
    _irmu5f0n.CalendarTaskOccurrenceContent? content,
    _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides,
    DateTime? startUtc,
    _idn2i48l.CalendarEventDuration? duration,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) = _CalendarTaskOccurrenceImpl;

  factory CalendarTaskOccurrence.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrence(
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      actualStart: jsonSerialization['actualStart'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['actualStart'],
            ),
      replacementTiming: jsonSerialization['replacementTiming'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['replacementTiming'],
            ),
      futureTiming: jsonSerialization['futureTiming'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['futureTiming'],
            ),
      content: jsonSerialization['content'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_irmu5f0n.CalendarTaskOccurrenceContent>(
                  jsonSerialization['content'],
                ),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_irmu5f0n.CalendarTaskOccurrenceContent>(
                  jsonSerialization['contentOverrides'],
                ),
      startUtc: jsonSerialization['startUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startUtc']),
      duration: jsonSerialization['duration'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_idn2i48l.CalendarEventDuration>(
              jsonSerialization['duration'],
            ),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['dueDate'],
            ),
      dueUtc: jsonSerialization['dueUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueUtc']),
      progress: _ie4a1wrz.Protocol()
          .deserialize<_ikcsq95s.CalendarTaskProgress>(
            jsonSerialization['progress'],
          ),
    );
  }

  final _ieswiaty.CalendarEventTiming originalStart;

  final _ieswiaty.CalendarEventTiming? actualStart;

  final _i9h8y8lg.CalendarTaskTiming? replacementTiming;

  final _i9h8y8lg.CalendarTaskTiming? futureTiming;

  final _irmu5f0n.CalendarTaskOccurrenceContent? content;

  final _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides;

  final DateTime? startUtc;

  final _idn2i48l.CalendarEventDuration? duration;

  final _i1bb5k1r.CalendarEventCivil? dueDate;

  final DateTime? dueUtc;

  final _ikcsq95s.CalendarTaskProgress progress;

  /// Returns a shallow copy of this [CalendarTaskOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? actualStart =
        const _UndefinedCalendarTaskOccurrence$actualStart(),
    _i9h8y8lg.CalendarTaskTiming? replacementTiming =
        const _UndefinedCalendarTaskOccurrence$replacementTiming(),
    _i9h8y8lg.CalendarTaskTiming? futureTiming =
        const _UndefinedCalendarTaskOccurrence$replacementTiming(),
    _irmu5f0n.CalendarTaskOccurrenceContent? content =
        const _UndefinedCalendarTaskOccurrence$content(),
    _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides =
        const _UndefinedCalendarTaskOccurrence$content(),
    DateTime? startUtc = const _isc.$UndefinedDateTime(),
    _idn2i48l.CalendarEventDuration? duration =
        const _UndefinedCalendarTaskOccurrence$duration(),
    _i1bb5k1r.CalendarEventCivil? dueDate =
        const _UndefinedCalendarTaskOccurrence$dueDate(),
    DateTime? dueUtc = const _isc.$UndefinedDateTime(),
    _ikcsq95s.CalendarTaskProgress? progress,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrence &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.actualStart,
                  actualStart,
                ) ||
                other.actualStart == actualStart) &&
            (identical(
                  other.replacementTiming,
                  replacementTiming,
                ) ||
                other.replacementTiming == replacementTiming) &&
            (identical(
                  other.futureTiming,
                  futureTiming,
                ) ||
                other.futureTiming == futureTiming) &&
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content) &&
            (identical(
                  other.contentOverrides,
                  contentOverrides,
                ) ||
                other.contentOverrides == contentOverrides) &&
            (identical(
                  other.startUtc,
                  startUtc,
                ) ||
                other.startUtc == startUtc) &&
            (identical(
                  other.duration,
                  duration,
                ) ||
                other.duration == duration) &&
            (identical(
                  other.dueDate,
                  dueDate,
                ) ||
                other.dueDate == dueDate) &&
            (identical(
                  other.dueUtc,
                  dueUtc,
                ) ||
                other.dueUtc == dueUtc) &&
            (identical(
                  other.progress,
                  progress,
                ) ||
                other.progress == progress);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      originalStart,
      actualStart,
      replacementTiming,
      futureTiming,
      content,
      contentOverrides,
      startUtc,
      duration,
      dueDate,
      dueUtc,
      progress,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrence',
      'originalStart': originalStart.toJson(),
      if (actualStart != null) 'actualStart': actualStart?.toJson(),
      if (replacementTiming != null)
        'replacementTiming': replacementTiming?.toJson(),
      if (futureTiming != null) 'futureTiming': futureTiming?.toJson(),
      if (content != null) 'content': content?.toJson(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJson(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (duration != null) 'duration': duration?.toJson(),
      if (dueDate != null) 'dueDate': dueDate?.toJson(),
      if (dueUtc != null) 'dueUtc': dueUtc?.toJson(),
      'progress': progress.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrence',
      'originalStart': originalStart.toJsonForProtocol(),
      if (actualStart != null) 'actualStart': actualStart?.toJsonForProtocol(),
      if (replacementTiming != null)
        'replacementTiming': replacementTiming?.toJsonForProtocol(),
      if (futureTiming != null)
        'futureTiming': futureTiming?.toJsonForProtocol(),
      if (content != null) 'content': content?.toJsonForProtocol(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJsonForProtocol(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (duration != null) 'duration': duration?.toJsonForProtocol(),
      if (dueDate != null) 'dueDate': dueDate?.toJsonForProtocol(),
      if (dueUtc != null) 'dueUtc': dueUtc?.toJson(),
      'progress': progress.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UndefinedCalendarTaskOccurrence$actualStart
    extends _isc.UndefinedSentinel
    implements _ieswiaty.CalendarEventTiming {
  const _UndefinedCalendarTaskOccurrence$actualStart();
}

class _UndefinedCalendarTaskOccurrence$replacementTiming
    extends _isc.UndefinedSentinel
    implements _i9h8y8lg.CalendarTaskTiming {
  const _UndefinedCalendarTaskOccurrence$replacementTiming();
}

class _UndefinedCalendarTaskOccurrence$content extends _isc.UndefinedSentinel
    implements _irmu5f0n.CalendarTaskOccurrenceContent {
  const _UndefinedCalendarTaskOccurrence$content();
}

class _UndefinedCalendarTaskOccurrence$duration extends _isc.UndefinedSentinel
    implements _idn2i48l.CalendarEventDuration {
  const _UndefinedCalendarTaskOccurrence$duration();
}

class _UndefinedCalendarTaskOccurrence$dueDate extends _isc.UndefinedSentinel
    implements _i1bb5k1r.CalendarEventCivil {
  const _UndefinedCalendarTaskOccurrence$dueDate();
}

class _CalendarTaskOccurrenceImpl extends CalendarTaskOccurrence {
  const _CalendarTaskOccurrenceImpl({
    required _ieswiaty.CalendarEventTiming originalStart,
    _ieswiaty.CalendarEventTiming? actualStart,
    _i9h8y8lg.CalendarTaskTiming? replacementTiming,
    _i9h8y8lg.CalendarTaskTiming? futureTiming,
    _irmu5f0n.CalendarTaskOccurrenceContent? content,
    _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides,
    DateTime? startUtc,
    _idn2i48l.CalendarEventDuration? duration,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) : super._(
         originalStart: originalStart,
         actualStart: actualStart,
         replacementTiming: replacementTiming,
         futureTiming: futureTiming,
         content: content,
         contentOverrides: contentOverrides,
         startUtc: startUtc,
         duration: duration,
         dueDate: dueDate,
         dueUtc: dueUtc,
         progress: progress,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? actualStart =
        const _UndefinedCalendarTaskOccurrence$actualStart(),
    _i9h8y8lg.CalendarTaskTiming? replacementTiming =
        const _UndefinedCalendarTaskOccurrence$replacementTiming(),
    _i9h8y8lg.CalendarTaskTiming? futureTiming =
        const _UndefinedCalendarTaskOccurrence$replacementTiming(),
    _irmu5f0n.CalendarTaskOccurrenceContent? content =
        const _UndefinedCalendarTaskOccurrence$content(),
    _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides =
        const _UndefinedCalendarTaskOccurrence$content(),
    DateTime? startUtc = const _isc.$UndefinedDateTime(),
    _idn2i48l.CalendarEventDuration? duration =
        const _UndefinedCalendarTaskOccurrence$duration(),
    _i1bb5k1r.CalendarEventCivil? dueDate =
        const _UndefinedCalendarTaskOccurrence$dueDate(),
    DateTime? dueUtc = const _isc.$UndefinedDateTime(),
    _ikcsq95s.CalendarTaskProgress? progress,
  }) {
    return CalendarTaskOccurrence(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      actualStart: actualStart is _isc.UndefinedSentinel
          ? this.actualStart?.copyWith()
          : actualStart,
      replacementTiming: replacementTiming is _isc.UndefinedSentinel
          ? this.replacementTiming?.copyWith()
          : replacementTiming,
      futureTiming: futureTiming is _isc.UndefinedSentinel
          ? this.futureTiming?.copyWith()
          : futureTiming,
      content: content is _isc.UndefinedSentinel
          ? this.content?.copyWith()
          : content,
      contentOverrides: contentOverrides is _isc.UndefinedSentinel
          ? this.contentOverrides?.copyWith()
          : contentOverrides,
      startUtc: startUtc is _isc.UndefinedSentinel ? this.startUtc : startUtc,
      duration: duration is _isc.UndefinedSentinel
          ? this.duration?.copyWith()
          : duration,
      dueDate: dueDate is _isc.UndefinedSentinel
          ? this.dueDate?.copyWith()
          : dueDate,
      dueUtc: dueUtc is _isc.UndefinedSentinel ? this.dueUtc : dueUtc,
      progress: progress ?? this.progress.copyWith(),
    );
  }
}
