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
abstract class CalendarSchedulingReceipt
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingReceipt._({
    required this.publicationId,
    required this.eventRevision,
    required this.unchanged,
  });

  const factory CalendarSchedulingReceipt({
    required _is.UuidValue publicationId,
    required int eventRevision,
    required bool unchanged,
  }) = _CalendarSchedulingReceiptImpl;

  factory CalendarSchedulingReceipt.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReceipt(
      publicationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      eventRevision: jsonSerialization['eventRevision'] as int,
      unchanged: _is.BoolJsonExtension.fromJson(jsonSerialization['unchanged']),
    );
  }

  final _is.UuidValue publicationId;

  final int eventRevision;

  final bool unchanged;

  /// Returns a shallow copy of this [CalendarSchedulingReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReceipt copyWith({
    _is.UuidValue? publicationId,
    int? eventRevision,
    bool? unchanged,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingReceipt &&
            (identical(
                  other.publicationId,
                  publicationId,
                ) ||
                other.publicationId == publicationId) &&
            (identical(
                  other.eventRevision,
                  eventRevision,
                ) ||
                other.eventRevision == eventRevision) &&
            (identical(
                  other.unchanged,
                  unchanged,
                ) ||
                other.unchanged == unchanged);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      publicationId,
      eventRevision,
      unchanged,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReceipt',
      'publicationId': publicationId.toJson(),
      'eventRevision': eventRevision,
      'unchanged': unchanged,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReceipt',
      'publicationId': publicationId.toJson(),
      'eventRevision': eventRevision,
      'unchanged': unchanged,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingReceiptImpl extends CalendarSchedulingReceipt {
  const _CalendarSchedulingReceiptImpl({
    required _is.UuidValue publicationId,
    required int eventRevision,
    required bool unchanged,
  }) : super._(
         publicationId: publicationId,
         eventRevision: eventRevision,
         unchanged: unchanged,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReceipt]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReceipt copyWith({
    _is.UuidValue? publicationId,
    int? eventRevision,
    bool? unchanged,
  }) {
    return CalendarSchedulingReceipt(
      publicationId: publicationId ?? this.publicationId,
      eventRevision: eventRevision ?? this.eventRevision,
      unchanged: unchanged ?? this.unchanged,
    );
  }
}
