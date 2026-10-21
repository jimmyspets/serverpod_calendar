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
abstract class CalendarAvailabilitySlot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilitySlot._({
    required this.startUtc,
    required this.endUtc,
  });

  const factory CalendarAvailabilitySlot({
    required DateTime startUtc,
    required DateTime endUtc,
  }) = _CalendarAvailabilitySlotImpl;

  factory CalendarAvailabilitySlot.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilitySlot(
      startUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['startUtc'],
      ),
      endUtc: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endUtc']),
    );
  }

  final DateTime startUtc;

  final DateTime endUtc;

  /// Returns a shallow copy of this [CalendarAvailabilitySlot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilitySlot copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilitySlot &&
            (identical(
                  other.startUtc,
                  startUtc,
                ) ||
                other.startUtc == startUtc) &&
            (identical(
                  other.endUtc,
                  endUtc,
                ) ||
                other.endUtc == endUtc);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      startUtc,
      endUtc,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySlot',
      'startUtc': startUtc.toJson(),
      'endUtc': endUtc.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySlot',
      'startUtc': startUtc.toJson(),
      'endUtc': endUtc.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilitySlotImpl extends CalendarAvailabilitySlot {
  const _CalendarAvailabilitySlotImpl({
    required DateTime startUtc,
    required DateTime endUtc,
  }) : super._(
         startUtc: startUtc,
         endUtc: endUtc,
       );

  /// Returns a shallow copy of this [CalendarAvailabilitySlot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilitySlot copyWith({
    DateTime? startUtc,
    DateTime? endUtc,
  }) {
    return CalendarAvailabilitySlot(
      startUtc: startUtc ?? this.startUtc,
      endUtc: endUtc ?? this.endUtc,
    );
  }
}
