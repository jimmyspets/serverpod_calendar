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
import 'calendar_scheduling_reply_source_view.dart' as _i2peuvqu;

@_is.immutable
abstract class CalendarSchedulingReplyDocument
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarSchedulingReplyDocument._({
    required this.metadata,
    required this.normalizedSource,
  });

  const factory CalendarSchedulingReplyDocument({
    required _i2peuvqu.CalendarSchedulingReplySourceView metadata,
    required String normalizedSource,
  }) = _CalendarSchedulingReplyDocumentImpl;

  factory CalendarSchedulingReplyDocument.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReplyDocument(
      metadata: _ix00hwbf.Protocol()
          .deserialize<_i2peuvqu.CalendarSchedulingReplySourceView>(
            jsonSerialization['metadata'],
          ),
      normalizedSource: jsonSerialization['normalizedSource'] as String,
    );
  }

  final _i2peuvqu.CalendarSchedulingReplySourceView metadata;

  final String normalizedSource;

  /// Returns a shallow copy of this [CalendarSchedulingReplyDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReplyDocument copyWith({
    _i2peuvqu.CalendarSchedulingReplySourceView? metadata,
    String? normalizedSource,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingReplyDocument &&
            (identical(
                  other.metadata,
                  metadata,
                ) ||
                other.metadata == metadata) &&
            (identical(
                  other.normalizedSource,
                  normalizedSource,
                ) ||
                other.normalizedSource == normalizedSource);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      metadata,
      normalizedSource,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplyDocument',
      'metadata': metadata.toJson(),
      'normalizedSource': normalizedSource,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplyDocument',
      'metadata': metadata.toJsonForProtocol(),
      'normalizedSource': normalizedSource,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarSchedulingReplyDocumentImpl
    extends CalendarSchedulingReplyDocument {
  const _CalendarSchedulingReplyDocumentImpl({
    required _i2peuvqu.CalendarSchedulingReplySourceView metadata,
    required String normalizedSource,
  }) : super._(
         metadata: metadata,
         normalizedSource: normalizedSource,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReplyDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReplyDocument copyWith({
    _i2peuvqu.CalendarSchedulingReplySourceView? metadata,
    String? normalizedSource,
  }) {
    return CalendarSchedulingReplyDocument(
      metadata: metadata ?? this.metadata.copyWith(),
      normalizedSource: normalizedSource ?? this.normalizedSource,
    );
  }
}
