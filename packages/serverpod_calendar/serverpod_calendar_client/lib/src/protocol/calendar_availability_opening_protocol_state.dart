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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

@_isc.immutable
abstract class CalendarAvailabilityOpeningProtocolState
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOpeningProtocolState._({
    required this.openingUid,
    this.created,
    required this.stamp,
    required this.lastModified,
  });

  const factory CalendarAvailabilityOpeningProtocolState({
    required _isc.UuidValue openingUid,
    DateTime? created,
    required DateTime stamp,
    required DateTime lastModified,
  }) = _CalendarAvailabilityOpeningProtocolStateImpl;

  factory CalendarAvailabilityOpeningProtocolState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpeningProtocolState(
      openingUid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      created: jsonSerialization['created'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['created']),
      stamp: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      lastModified: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastModified'],
      ),
    );
  }

  final _isc.UuidValue openingUid;

  final DateTime? created;

  final DateTime stamp;

  final DateTime lastModified;

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOpeningProtocolState copyWith({
    _isc.UuidValue? openingUid,
    DateTime? created,
    DateTime? stamp,
    DateTime? lastModified,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpeningProtocolState &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
            (identical(
                  other.created,
                  created,
                ) ||
                other.created == created) &&
            (identical(
                  other.stamp,
                  stamp,
                ) ||
                other.stamp == stamp) &&
            (identical(
                  other.lastModified,
                  lastModified,
                ) ||
                other.lastModified == lastModified);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      openingUid,
      created,
      stamp,
      lastModified,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOpeningProtocolState',
      'openingUid': openingUid.toJson(),
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      'lastModified': lastModified.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOpeningProtocolState',
      'openingUid': openingUid.toJson(),
      if (created != null) 'created': created?.toJson(),
      'stamp': stamp.toJson(),
      'lastModified': lastModified.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOpeningProtocolStateImpl
    extends CalendarAvailabilityOpeningProtocolState {
  const _CalendarAvailabilityOpeningProtocolStateImpl({
    required _isc.UuidValue openingUid,
    DateTime? created,
    required DateTime stamp,
    required DateTime lastModified,
  }) : super._(
         openingUid: openingUid,
         created: created,
         stamp: stamp,
         lastModified: lastModified,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpeningProtocolState]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOpeningProtocolState copyWith({
    _isc.UuidValue? openingUid,
    Object? created = _Undefined,
    DateTime? stamp,
    DateTime? lastModified,
  }) {
    return CalendarAvailabilityOpeningProtocolState(
      openingUid: openingUid ?? this.openingUid,
      created: created is DateTime? ? created : this.created,
      stamp: stamp ?? this.stamp,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
