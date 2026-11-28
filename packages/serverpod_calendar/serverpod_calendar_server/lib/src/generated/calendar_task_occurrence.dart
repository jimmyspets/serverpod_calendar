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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_occurrence_content.dart' as _irmu5f0n;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_timing.dart' as _i9h8y8lg;

@_is.immutable
abstract class CalendarTaskOccurrence
    implements _is.SerializableModel, _is.ProtocolSerialization {
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
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      actualStart: jsonSerialization['actualStart'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['actualStart'],
            ),
      replacementTiming: jsonSerialization['replacementTiming'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['replacementTiming'],
            ),
      futureTiming: jsonSerialization['futureTiming'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['futureTiming'],
            ),
      content: jsonSerialization['content'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_irmu5f0n.CalendarTaskOccurrenceContent>(
                  jsonSerialization['content'],
                ),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_irmu5f0n.CalendarTaskOccurrenceContent>(
                  jsonSerialization['contentOverrides'],
                ),
      startUtc: jsonSerialization['startUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['startUtc']),
      duration: jsonSerialization['duration'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_idn2i48l.CalendarEventDuration>(
              jsonSerialization['duration'],
            ),
      dueDate: jsonSerialization['dueDate'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['dueDate'],
            ),
      dueUtc: jsonSerialization['dueUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueUtc']),
      progress: _ix00hwbf.Protocol()
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
  @_is.useResult
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    _ieswiaty.CalendarEventTiming? actualStart,
    _i9h8y8lg.CalendarTaskTiming? replacementTiming,
    _i9h8y8lg.CalendarTaskTiming? futureTiming,
    _irmu5f0n.CalendarTaskOccurrenceContent? content,
    _irmu5f0n.CalendarTaskOccurrenceContent? contentOverrides,
    DateTime? startUtc,
    _idn2i48l.CalendarEventDuration? duration,
    _i1bb5k1r.CalendarEventCivil? dueDate,
    DateTime? dueUtc,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

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
  @_is.useResult
  @override
  CalendarTaskOccurrence copyWith({
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? actualStart = _Undefined,
    Object? replacementTiming = _Undefined,
    Object? futureTiming = _Undefined,
    Object? content = _Undefined,
    Object? contentOverrides = _Undefined,
    Object? startUtc = _Undefined,
    Object? duration = _Undefined,
    Object? dueDate = _Undefined,
    Object? dueUtc = _Undefined,
    _ikcsq95s.CalendarTaskProgress? progress,
  }) {
    return CalendarTaskOccurrence(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      actualStart: actualStart is _ieswiaty.CalendarEventTiming?
          ? actualStart
          : this.actualStart?.copyWith(),
      replacementTiming: replacementTiming is _i9h8y8lg.CalendarTaskTiming?
          ? replacementTiming
          : this.replacementTiming?.copyWith(),
      futureTiming: futureTiming is _i9h8y8lg.CalendarTaskTiming?
          ? futureTiming
          : this.futureTiming?.copyWith(),
      content: content is _irmu5f0n.CalendarTaskOccurrenceContent?
          ? content
          : this.content?.copyWith(),
      contentOverrides:
          contentOverrides is _irmu5f0n.CalendarTaskOccurrenceContent?
          ? contentOverrides
          : this.contentOverrides?.copyWith(),
      startUtc: startUtc is DateTime? ? startUtc : this.startUtc,
      duration: duration is _idn2i48l.CalendarEventDuration?
          ? duration
          : this.duration?.copyWith(),
      dueDate: dueDate is _i1bb5k1r.CalendarEventCivil?
          ? dueDate
          : this.dueDate?.copyWith(),
      dueUtc: dueUtc is DateTime? ? dueUtc : this.dueUtc,
      progress: progress ?? this.progress.copyWith(),
    );
  }
}
