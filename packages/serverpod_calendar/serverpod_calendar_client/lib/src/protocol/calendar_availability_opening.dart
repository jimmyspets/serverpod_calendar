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
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarAvailabilityOpening
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOpening._({
    this.uid,
    required this.timing,
    this.recurrence,
    this.summary,
    this.description,
    this.location,
    this.categories,
    this.comments,
  });

  const factory CalendarAvailabilityOpening({
    _isc.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
  }) = _CalendarAvailabilityOpeningImpl;

  factory CalendarAvailabilityOpening.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpening(
      uid: jsonSerialization['uid'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['uid']),
      timing: _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
        jsonSerialization['timing'],
      ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      categories: jsonSerialization['categories'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<List<String>>(
              jsonSerialization['categories'],
            ),
      comments: jsonSerialization['comments'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<List<String>>(
              jsonSerialization['comments'],
            ),
    );
  }

  final _isc.UuidValue? uid;

  final _ieswiaty.CalendarEventTiming timing;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  final String? summary;

  final String? description;

  final String? location;

  final List<String>? categories;

  final List<String>? comments;

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOpening copyWith({
    _isc.UuidValue? uid,
    _ieswiaty.CalendarEventTiming? timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpening &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence) &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.description,
                  description,
                ) ||
                other.description == description) &&
            (identical(
                  other.location,
                  location,
                ) ||
                other.location == location) &&
            const _iss.DeepCollectionEquality().equals(
              other.categories,
              categories,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.comments,
              comments,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      uid,
      timing,
      recurrence,
      summary,
      description,
      location,
      const _iss.DeepCollectionEquality().hash(categories),
      const _iss.DeepCollectionEquality().hash(comments),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJsonForProtocol(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOpeningImpl extends CalendarAvailabilityOpening {
  const _CalendarAvailabilityOpeningImpl({
    _isc.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
  }) : super._(
         uid: uid,
         timing: timing,
         recurrence: recurrence,
         summary: summary,
         description: description,
         location: location,
         categories: categories,
         comments: comments,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOpening copyWith({
    Object? uid = _Undefined,
    _ieswiaty.CalendarEventTiming? timing,
    Object? recurrence = _Undefined,
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? categories = _Undefined,
    Object? comments = _Undefined,
  }) {
    return CalendarAvailabilityOpening(
      uid: uid is _isc.UuidValue? ? uid : this.uid,
      timing: timing ?? this.timing.copyWith(),
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      categories: categories is List<String>?
          ? categories
          : this.categories?.map((e0) => e0).toList(),
      comments: comments is List<String>?
          ? comments
          : this.comments?.map((e0) => e0).toList(),
    );
  }
}
