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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_scheduling_attendee_response_view.dart' as _itopoldj;

@_isc.immutable
abstract class CalendarSchedulingInstanceResponsesView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarSchedulingInstanceResponsesView._({
    required this.eventId,
    required this.publicationId,
    required this.originalStart,
    this.publishedSequence,
    this.publishedCancelled,
    required this.responses,
  });

  const factory CalendarSchedulingInstanceResponsesView({
    required _isc.UuidValue eventId,
    required _isc.UuidValue publicationId,
    required _ieswiaty.CalendarEventTiming originalStart,
    int? publishedSequence,
    bool? publishedCancelled,
    required List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses,
  }) = _CalendarSchedulingInstanceResponsesViewImpl;

  factory CalendarSchedulingInstanceResponsesView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingInstanceResponsesView(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      publicationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      publishedSequence: jsonSerialization['publishedSequence'] as int?,
      publishedCancelled: jsonSerialization['publishedCancelled'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['publishedCancelled'],
            ),
      responses: _ie4a1wrz.Protocol()
          .deserialize<List<_itopoldj.CalendarSchedulingAttendeeResponseView>>(
            jsonSerialization['responses'],
          ),
    );
  }

  final _isc.UuidValue eventId;

  final _isc.UuidValue publicationId;

  final _ieswiaty.CalendarEventTiming originalStart;

  final int? publishedSequence;

  final bool? publishedCancelled;

  final List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses;

  /// Returns a shallow copy of this [CalendarSchedulingInstanceResponsesView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSchedulingInstanceResponsesView copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? publicationId,
    _ieswiaty.CalendarEventTiming? originalStart,
    int? publishedSequence,
    bool? publishedCancelled,
    List<_itopoldj.CalendarSchedulingAttendeeResponseView>? responses,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingInstanceResponsesView &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.publicationId,
                  publicationId,
                ) ||
                other.publicationId == publicationId) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.publishedSequence,
                  publishedSequence,
                ) ||
                other.publishedSequence == publishedSequence) &&
            (identical(
                  other.publishedCancelled,
                  publishedCancelled,
                ) ||
                other.publishedCancelled == publishedCancelled) &&
            const _iss.DeepCollectionEquality().equals(
              other.responses,
              responses,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      publicationId,
      originalStart,
      publishedSequence,
      publishedCancelled,
      const _iss.DeepCollectionEquality().hash(responses),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingInstanceResponsesView',
      'eventId': eventId.toJson(),
      'publicationId': publicationId.toJson(),
      'originalStart': originalStart.toJson(),
      if (publishedSequence != null) 'publishedSequence': publishedSequence,
      if (publishedCancelled != null) 'publishedCancelled': publishedCancelled,
      'responses': responses.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingInstanceResponsesView',
      'eventId': eventId.toJson(),
      'publicationId': publicationId.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
      if (publishedSequence != null) 'publishedSequence': publishedSequence,
      if (publishedCancelled != null) 'publishedCancelled': publishedCancelled,
      'responses': responses.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingInstanceResponsesViewImpl
    extends CalendarSchedulingInstanceResponsesView {
  const _CalendarSchedulingInstanceResponsesViewImpl({
    required _isc.UuidValue eventId,
    required _isc.UuidValue publicationId,
    required _ieswiaty.CalendarEventTiming originalStart,
    int? publishedSequence,
    bool? publishedCancelled,
    required List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses,
  }) : super._(
         eventId: eventId,
         publicationId: publicationId,
         originalStart: originalStart,
         publishedSequence: publishedSequence,
         publishedCancelled: publishedCancelled,
         responses: responses,
       );

  /// Returns a shallow copy of this [CalendarSchedulingInstanceResponsesView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSchedulingInstanceResponsesView copyWith({
    _isc.UuidValue? eventId,
    _isc.UuidValue? publicationId,
    _ieswiaty.CalendarEventTiming? originalStart,
    Object? publishedSequence = _Undefined,
    Object? publishedCancelled = _Undefined,
    List<_itopoldj.CalendarSchedulingAttendeeResponseView>? responses,
  }) {
    return CalendarSchedulingInstanceResponsesView(
      eventId: eventId ?? this.eventId,
      publicationId: publicationId ?? this.publicationId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      publishedSequence: publishedSequence is int?
          ? publishedSequence
          : this.publishedSequence,
      publishedCancelled: publishedCancelled is bool?
          ? publishedCancelled
          : this.publishedCancelled,
      responses:
          responses ?? this.responses.map((e0) => e0.copyWith()).toList(),
    );
  }
}
