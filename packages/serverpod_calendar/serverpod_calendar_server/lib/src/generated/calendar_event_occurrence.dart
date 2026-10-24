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
import 'calendar_event_occurrence_content.dart' as _io4uvjqi;

abstract class CalendarEventOccurrence
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarEventOccurrence._({
    required this.originalStart,
    required this.start,
    this.endDate,
    this.startUtc,
    this.endUtc,
    this.content,
    this.contentOverrides,
  });

  factory CalendarEventOccurrence({
    required _i1bb5k1r.CalendarEventCivil originalStart,
    required _i1bb5k1r.CalendarEventCivil start,
    _i1bb5k1r.CalendarEventCivil? endDate,
    DateTime? startUtc,
    DateTime? endUtc,
    _io4uvjqi.CalendarEventOccurrenceContent? content,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  }) = _CalendarEventOccurrenceImpl;

  factory CalendarEventOccurrence.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrence(
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_i1bb5k1r.CalendarEventCivil>(
            jsonSerialization['originalStart'],
          ),
      start: _ix00hwbf.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
        jsonSerialization['start'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['endDate'],
            ),
      startUtc: jsonSerialization['startUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['startUtc']),
      endUtc: jsonSerialization['endUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['endUtc']),
      content: jsonSerialization['content'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
                  jsonSerialization['content'],
                ),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
                  jsonSerialization['contentOverrides'],
                ),
    );
  }

  _i1bb5k1r.CalendarEventCivil originalStart;

  _i1bb5k1r.CalendarEventCivil start;

  _i1bb5k1r.CalendarEventCivil? endDate;

  DateTime? startUtc;

  DateTime? endUtc;

  _io4uvjqi.CalendarEventOccurrenceContent? content;

  _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides;

  /// Returns a shallow copy of this [CalendarEventOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrence copyWith({
    _i1bb5k1r.CalendarEventCivil? originalStart,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? endDate,
    DateTime? startUtc,
    DateTime? endUtc,
    _io4uvjqi.CalendarEventOccurrenceContent? content,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrence',
      'originalStart': originalStart.toJson(),
      'start': start.toJson(),
      if (endDate != null) 'endDate': endDate?.toJson(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (endUtc != null) 'endUtc': endUtc?.toJson(),
      if (content != null) 'content': content?.toJson(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrence',
      'originalStart': originalStart.toJsonForProtocol(),
      'start': start.toJsonForProtocol(),
      if (endDate != null) 'endDate': endDate?.toJsonForProtocol(),
      if (startUtc != null) 'startUtc': startUtc?.toJson(),
      if (endUtc != null) 'endUtc': endUtc?.toJson(),
      if (content != null) 'content': content?.toJsonForProtocol(),
      if (contentOverrides != null)
        'contentOverrides': contentOverrides?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrenceImpl extends CalendarEventOccurrence {
  _CalendarEventOccurrenceImpl({
    required _i1bb5k1r.CalendarEventCivil originalStart,
    required _i1bb5k1r.CalendarEventCivil start,
    _i1bb5k1r.CalendarEventCivil? endDate,
    DateTime? startUtc,
    DateTime? endUtc,
    _io4uvjqi.CalendarEventOccurrenceContent? content,
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides,
  }) : super._(
         originalStart: originalStart,
         start: start,
         endDate: endDate,
         startUtc: startUtc,
         endUtc: endUtc,
         content: content,
         contentOverrides: contentOverrides,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrence copyWith({
    _i1bb5k1r.CalendarEventCivil? originalStart,
    _i1bb5k1r.CalendarEventCivil? start,
    Object? endDate = _Undefined,
    Object? startUtc = _Undefined,
    Object? endUtc = _Undefined,
    Object? content = _Undefined,
    Object? contentOverrides = _Undefined,
  }) {
    return CalendarEventOccurrence(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      start: start ?? this.start.copyWith(),
      endDate: endDate is _i1bb5k1r.CalendarEventCivil?
          ? endDate
          : this.endDate?.copyWith(),
      startUtc: startUtc is DateTime? ? startUtc : this.startUtc,
      endUtc: endUtc is DateTime? ? endUtc : this.endUtc,
      content: content is _io4uvjqi.CalendarEventOccurrenceContent?
          ? content
          : this.content?.copyWith(),
      contentOverrides:
          contentOverrides is _io4uvjqi.CalendarEventOccurrenceContent?
          ? contentOverrides
          : this.contentOverrides?.copyWith(),
    );
  }
}
