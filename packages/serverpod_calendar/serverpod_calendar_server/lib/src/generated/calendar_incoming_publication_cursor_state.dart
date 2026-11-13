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
abstract class CalendarIncomingPublicationCursorState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationCursorState._({
    required this.recipientKey,
    required this.criteriaDigest,
    required this.basisDigest,
  });

  const factory CalendarIncomingPublicationCursorState({
    required String recipientKey,
    required String criteriaDigest,
    required String basisDigest,
  }) = _CalendarIncomingPublicationCursorStateImpl;

  factory CalendarIncomingPublicationCursorState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationCursorState(
      recipientKey: jsonSerialization['recipientKey'] as String,
      criteriaDigest: jsonSerialization['criteriaDigest'] as String,
      basisDigest: jsonSerialization['basisDigest'] as String,
    );
  }

  final String recipientKey;

  final String criteriaDigest;

  final String basisDigest;

  /// Returns a shallow copy of this [CalendarIncomingPublicationCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationCursorState copyWith({
    String? recipientKey,
    String? criteriaDigest,
    String? basisDigest,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationCursorState &&
            (identical(
                  other.recipientKey,
                  recipientKey,
                ) ||
                other.recipientKey == recipientKey) &&
            (identical(
                  other.criteriaDigest,
                  criteriaDigest,
                ) ||
                other.criteriaDigest == criteriaDigest) &&
            (identical(
                  other.basisDigest,
                  basisDigest,
                ) ||
                other.basisDigest == basisDigest);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      recipientKey,
      criteriaDigest,
      basisDigest,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationCursorState',
      'recipientKey': recipientKey,
      'criteriaDigest': criteriaDigest,
      'basisDigest': basisDigest,
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

class _CalendarIncomingPublicationCursorStateImpl
    extends CalendarIncomingPublicationCursorState {
  const _CalendarIncomingPublicationCursorStateImpl({
    required String recipientKey,
    required String criteriaDigest,
    required String basisDigest,
  }) : super._(
         recipientKey: recipientKey,
         criteriaDigest: criteriaDigest,
         basisDigest: basisDigest,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationCursorState copyWith({
    String? recipientKey,
    String? criteriaDigest,
    String? basisDigest,
  }) {
    return CalendarIncomingPublicationCursorState(
      recipientKey: recipientKey ?? this.recipientKey,
      criteriaDigest: criteriaDigest ?? this.criteriaDigest,
      basisDigest: basisDigest ?? this.basisDigest,
    );
  }
}
