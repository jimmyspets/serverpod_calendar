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
abstract class CalendarAvailabilityImportBaseline
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityImportBaseline._({
    required this.profile,
    required this.canonicalValue,
    this.sourceSequence,
  });

  const factory CalendarAvailabilityImportBaseline({
    required String profile,
    required String canonicalValue,
    int? sourceSequence,
  }) = _CalendarAvailabilityImportBaselineImpl;

  factory CalendarAvailabilityImportBaseline.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityImportBaseline(
      profile: jsonSerialization['profile'] as String,
      canonicalValue: jsonSerialization['canonicalValue'] as String,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
    );
  }

  final String profile;

  final String canonicalValue;

  final int? sourceSequence;

  /// Returns a shallow copy of this [CalendarAvailabilityImportBaseline]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityImportBaseline copyWith({
    String? profile,
    String? canonicalValue,
    int? sourceSequence,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityImportBaseline &&
            (identical(
                  other.profile,
                  profile,
                ) ||
                other.profile == profile) &&
            (identical(
                  other.canonicalValue,
                  canonicalValue,
                ) ||
                other.canonicalValue == canonicalValue) &&
            (identical(
                  other.sourceSequence,
                  sourceSequence,
                ) ||
                other.sourceSequence == sourceSequence);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      profile,
      canonicalValue,
      sourceSequence,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityImportBaseline',
      'profile': profile,
      'canonicalValue': canonicalValue,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
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

class _Undefined {}

class _CalendarAvailabilityImportBaselineImpl
    extends CalendarAvailabilityImportBaseline {
  const _CalendarAvailabilityImportBaselineImpl({
    required String profile,
    required String canonicalValue,
    int? sourceSequence,
  }) : super._(
         profile: profile,
         canonicalValue: canonicalValue,
         sourceSequence: sourceSequence,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityImportBaseline]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityImportBaseline copyWith({
    String? profile,
    String? canonicalValue,
    Object? sourceSequence = _Undefined,
  }) {
    return CalendarAvailabilityImportBaseline(
      profile: profile ?? this.profile,
      canonicalValue: canonicalValue ?? this.canonicalValue,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
    );
  }
}
