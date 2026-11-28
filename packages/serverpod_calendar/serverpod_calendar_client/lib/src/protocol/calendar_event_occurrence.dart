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
import 'calendar_event_occurrence_content.dart' as _io4uvjqi;

abstract class CalendarEventOccurrence
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_i1bb5k1r.CalendarEventCivil>(
            jsonSerialization['originalStart'],
          ),
      start: _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
        jsonSerialization['start'],
      ),
      endDate: jsonSerialization['endDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['endDate'],
            ),
      startUtc: jsonSerialization['startUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['startUtc']),
      endUtc: jsonSerialization['endUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endUtc']),
      content: jsonSerialization['content'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_io4uvjqi.CalendarEventOccurrenceContent>(
                  jsonSerialization['content'],
                ),
      contentOverrides: jsonSerialization['contentOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
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
  @_isc.useResult
  CalendarEventOccurrence copyWith({
    _i1bb5k1r.CalendarEventCivil? originalStart,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? endDate =
        const _UndefinedCalendarEventOccurrence$endDate(),
    DateTime? startUtc = const _isc.$UndefinedDateTime(),
    DateTime? endUtc = const _isc.$UndefinedDateTime(),
    _io4uvjqi.CalendarEventOccurrenceContent? content =
        const _UndefinedCalendarEventOccurrence$content(),
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides =
        const _UndefinedCalendarEventOccurrence$content(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _UndefinedCalendarEventOccurrence$endDate extends _isc.UndefinedSentinel
    implements _i1bb5k1r.CalendarEventCivil {
  const _UndefinedCalendarEventOccurrence$endDate();
}

class _UndefinedCalendarEventOccurrence$content extends _isc.UndefinedSentinel
    implements _io4uvjqi.CalendarEventOccurrenceContent {
  const _UndefinedCalendarEventOccurrence$content();
}

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
  @_isc.useResult
  @override
  CalendarEventOccurrence copyWith({
    _i1bb5k1r.CalendarEventCivil? originalStart,
    _i1bb5k1r.CalendarEventCivil? start,
    _i1bb5k1r.CalendarEventCivil? endDate =
        const _UndefinedCalendarEventOccurrence$endDate(),
    DateTime? startUtc = const _isc.$UndefinedDateTime(),
    DateTime? endUtc = const _isc.$UndefinedDateTime(),
    _io4uvjqi.CalendarEventOccurrenceContent? content =
        const _UndefinedCalendarEventOccurrence$content(),
    _io4uvjqi.CalendarEventOccurrenceContent? contentOverrides =
        const _UndefinedCalendarEventOccurrence$content(),
  }) {
    return CalendarEventOccurrence(
      originalStart: originalStart ?? this.originalStart.copyWith(),
      start: start ?? this.start.copyWith(),
      endDate: endDate is _isc.UndefinedSentinel
          ? this.endDate?.copyWith()
          : endDate,
      startUtc: startUtc is _isc.UndefinedSentinel ? this.startUtc : startUtc,
      endUtc: endUtc is _isc.UndefinedSentinel ? this.endUtc : endUtc,
      content: content is _isc.UndefinedSentinel
          ? this.content?.copyWith()
          : content,
      contentOverrides: contentOverrides is _isc.UndefinedSentinel
          ? this.contentOverrides?.copyWith()
          : contentOverrides,
    );
  }
}
