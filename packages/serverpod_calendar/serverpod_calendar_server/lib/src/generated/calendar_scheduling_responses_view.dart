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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_scheduling_attendee_response_view.dart' as _itopoldj;

@_is.immutable
abstract class CalendarSchedulingResponsesView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingResponsesView._({
    required this.eventId,
    required this.publicationId,
    required this.publishedSequence,
    required this.publishedCancelled,
    required this.recurring,
    required this.responses,
  });

  const factory CalendarSchedulingResponsesView({
    required _is.UuidValue eventId,
    required _is.UuidValue publicationId,
    required int publishedSequence,
    required bool publishedCancelled,
    required bool recurring,
    required List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses,
  }) = _CalendarSchedulingResponsesViewImpl;

  factory CalendarSchedulingResponsesView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingResponsesView(
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      publicationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      publishedSequence: jsonSerialization['publishedSequence'] as int,
      publishedCancelled: _is.BoolJsonExtension.fromJson(
        jsonSerialization['publishedCancelled'],
      ),
      recurring: _is.BoolJsonExtension.fromJson(jsonSerialization['recurring']),
      responses: _ix00hwbf.Protocol()
          .deserialize<List<_itopoldj.CalendarSchedulingAttendeeResponseView>>(
            jsonSerialization['responses'],
          ),
    );
  }

  final _is.UuidValue eventId;

  final _is.UuidValue publicationId;

  final int publishedSequence;

  final bool publishedCancelled;

  final bool recurring;

  final List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses;

  /// Returns a shallow copy of this [CalendarSchedulingResponsesView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingResponsesView copyWith({
    _is.UuidValue? eventId,
    _is.UuidValue? publicationId,
    int? publishedSequence,
    bool? publishedCancelled,
    bool? recurring,
    List<_itopoldj.CalendarSchedulingAttendeeResponseView>? responses,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingResponsesView &&
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
                  other.publishedSequence,
                  publishedSequence,
                ) ||
                other.publishedSequence == publishedSequence) &&
            (identical(
                  other.publishedCancelled,
                  publishedCancelled,
                ) ||
                other.publishedCancelled == publishedCancelled) &&
            (identical(
                  other.recurring,
                  recurring,
                ) ||
                other.recurring == recurring) &&
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
      publishedSequence,
      publishedCancelled,
      recurring,
      const _iss.DeepCollectionEquality().hash(responses),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingResponsesView',
      'eventId': eventId.toJson(),
      'publicationId': publicationId.toJson(),
      'publishedSequence': publishedSequence,
      'publishedCancelled': publishedCancelled,
      'recurring': recurring,
      'responses': responses.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingResponsesView',
      'eventId': eventId.toJson(),
      'publicationId': publicationId.toJson(),
      'publishedSequence': publishedSequence,
      'publishedCancelled': publishedCancelled,
      'recurring': recurring,
      'responses': responses.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingResponsesViewImpl
    extends CalendarSchedulingResponsesView {
  const _CalendarSchedulingResponsesViewImpl({
    required _is.UuidValue eventId,
    required _is.UuidValue publicationId,
    required int publishedSequence,
    required bool publishedCancelled,
    required bool recurring,
    required List<_itopoldj.CalendarSchedulingAttendeeResponseView> responses,
  }) : super._(
         eventId: eventId,
         publicationId: publicationId,
         publishedSequence: publishedSequence,
         publishedCancelled: publishedCancelled,
         recurring: recurring,
         responses: responses,
       );

  /// Returns a shallow copy of this [CalendarSchedulingResponsesView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingResponsesView copyWith({
    _is.UuidValue? eventId,
    _is.UuidValue? publicationId,
    int? publishedSequence,
    bool? publishedCancelled,
    bool? recurring,
    List<_itopoldj.CalendarSchedulingAttendeeResponseView>? responses,
  }) {
    return CalendarSchedulingResponsesView(
      eventId: eventId ?? this.eventId,
      publicationId: publicationId ?? this.publicationId,
      publishedSequence: publishedSequence ?? this.publishedSequence,
      publishedCancelled: publishedCancelled ?? this.publishedCancelled,
      recurring: recurring ?? this.recurring,
      responses:
          responses ?? this.responses.map((e0) => e0.copyWith()).toList(),
    );
  }
}
