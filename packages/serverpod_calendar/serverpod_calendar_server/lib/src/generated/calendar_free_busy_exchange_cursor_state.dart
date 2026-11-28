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

@_is.immutable
abstract class CalendarFreeBusyExchangeCursorState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFreeBusyExchangeCursorState._({
    required this.version,
    required this.family,
    required this.ownerKey,
    required this.criteriaDigest,
    required this.metadataVectorDigest,
    required this.timezoneIdentity,
    this.activityCommandId,
  });

  const factory CalendarFreeBusyExchangeCursorState({
    required int version,
    required String family,
    required String ownerKey,
    required String criteriaDigest,
    required String metadataVectorDigest,
    required String timezoneIdentity,
    _is.UuidValue? activityCommandId,
  }) = _CalendarFreeBusyExchangeCursorStateImpl;

  factory CalendarFreeBusyExchangeCursorState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyExchangeCursorState(
      version: jsonSerialization['version'] as int,
      family: jsonSerialization['family'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      criteriaDigest: jsonSerialization['criteriaDigest'] as String,
      metadataVectorDigest: jsonSerialization['metadataVectorDigest'] as String,
      timezoneIdentity: jsonSerialization['timezoneIdentity'] as String,
      activityCommandId: jsonSerialization['activityCommandId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['activityCommandId'],
            ),
    );
  }

  final int version;

  final String family;

  final String ownerKey;

  final String criteriaDigest;

  final String metadataVectorDigest;

  final String timezoneIdentity;

  final _is.UuidValue? activityCommandId;

  /// Returns a shallow copy of this [CalendarFreeBusyExchangeCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyExchangeCursorState copyWith({
    int? version,
    String? family,
    String? ownerKey,
    String? criteriaDigest,
    String? metadataVectorDigest,
    String? timezoneIdentity,
    _is.UuidValue? activityCommandId = const _is.$UndefinedUuidValue(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyExchangeCursorState &&
            (identical(
                  other.version,
                  version,
                ) ||
                other.version == version) &&
            (identical(
                  other.family,
                  family,
                ) ||
                other.family == family) &&
            (identical(
                  other.ownerKey,
                  ownerKey,
                ) ||
                other.ownerKey == ownerKey) &&
            (identical(
                  other.criteriaDigest,
                  criteriaDigest,
                ) ||
                other.criteriaDigest == criteriaDigest) &&
            (identical(
                  other.metadataVectorDigest,
                  metadataVectorDigest,
                ) ||
                other.metadataVectorDigest == metadataVectorDigest) &&
            (identical(
                  other.timezoneIdentity,
                  timezoneIdentity,
                ) ||
                other.timezoneIdentity == timezoneIdentity) &&
            (identical(
                  other.activityCommandId,
                  activityCommandId,
                ) ||
                other.activityCommandId == activityCommandId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      version,
      family,
      ownerKey,
      criteriaDigest,
      metadataVectorDigest,
      timezoneIdentity,
      activityCommandId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyExchangeCursorState',
      'version': version,
      'family': family,
      'ownerKey': ownerKey,
      'criteriaDigest': criteriaDigest,
      'metadataVectorDigest': metadataVectorDigest,
      'timezoneIdentity': timezoneIdentity,
      if (activityCommandId != null)
        'activityCommandId': activityCommandId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyExchangeCursorStateImpl
    extends CalendarFreeBusyExchangeCursorState {
  const _CalendarFreeBusyExchangeCursorStateImpl({
    required int version,
    required String family,
    required String ownerKey,
    required String criteriaDigest,
    required String metadataVectorDigest,
    required String timezoneIdentity,
    _is.UuidValue? activityCommandId,
  }) : super._(
         version: version,
         family: family,
         ownerKey: ownerKey,
         criteriaDigest: criteriaDigest,
         metadataVectorDigest: metadataVectorDigest,
         timezoneIdentity: timezoneIdentity,
         activityCommandId: activityCommandId,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyExchangeCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyExchangeCursorState copyWith({
    int? version,
    String? family,
    String? ownerKey,
    String? criteriaDigest,
    String? metadataVectorDigest,
    String? timezoneIdentity,
    _is.UuidValue? activityCommandId = const _is.$UndefinedUuidValue(),
  }) {
    return CalendarFreeBusyExchangeCursorState(
      version: version ?? this.version,
      family: family ?? this.family,
      ownerKey: ownerKey ?? this.ownerKey,
      criteriaDigest: criteriaDigest ?? this.criteriaDigest,
      metadataVectorDigest: metadataVectorDigest ?? this.metadataVectorDigest,
      timezoneIdentity: timezoneIdentity ?? this.timezoneIdentity,
      activityCommandId: activityCommandId is _is.UndefinedSentinel
          ? this.activityCommandId
          : activityCommandId,
    );
  }
}
