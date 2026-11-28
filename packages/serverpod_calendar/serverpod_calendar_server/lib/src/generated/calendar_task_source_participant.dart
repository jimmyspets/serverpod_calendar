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

@_is.immutable
abstract class CalendarTaskSourceParticipant
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceParticipant._({
    required this.address,
    required this.parameters,
  });

  const factory CalendarTaskSourceParticipant({
    required String address,
    required Map<String, List<String>> parameters,
  }) = _CalendarTaskSourceParticipantImpl;

  factory CalendarTaskSourceParticipant.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceParticipant(
      address: jsonSerialization['address'] as String,
      parameters: _ix00hwbf.Protocol().deserialize<Map<String, List<String>>>(
        jsonSerialization['parameters'],
      ),
    );
  }

  final String address;

  final Map<String, List<String>> parameters;

  /// Returns a shallow copy of this [CalendarTaskSourceParticipant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceParticipant copyWith({
    String? address,
    Map<String, List<String>>? parameters,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceParticipant &&
            (identical(
                  other.address,
                  address,
                ) ||
                other.address == address) &&
            const _iss.DeepCollectionEquality().equals(
              other.parameters,
              parameters,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      address,
      const _iss.DeepCollectionEquality().hash(parameters),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceParticipant',
      'address': address,
      'parameters': parameters.toJson(valueToJson: (v) => v.toJson()),
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

class _CalendarTaskSourceParticipantImpl extends CalendarTaskSourceParticipant {
  const _CalendarTaskSourceParticipantImpl({
    required String address,
    required Map<String, List<String>> parameters,
  }) : super._(
         address: address,
         parameters: parameters,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceParticipant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceParticipant copyWith({
    String? address,
    Map<String, List<String>>? parameters,
  }) {
    return CalendarTaskSourceParticipant(
      address: address ?? this.address,
      parameters:
          parameters ??
          this.parameters.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0.map((e1) => e1).toList(),
            ),
          ),
    );
  }
}
