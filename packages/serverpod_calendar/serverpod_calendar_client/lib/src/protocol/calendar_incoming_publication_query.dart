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
abstract class CalendarIncomingPublicationQuery
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationQuery._({
    int? pageSize,
    bool? includeDismissed,
    this.cursor,
  }) : pageSize = pageSize ?? 20,
       includeDismissed = includeDismissed ?? false;

  const factory CalendarIncomingPublicationQuery({
    int? pageSize,
    bool? includeDismissed,
    String? cursor,
  }) = _CalendarIncomingPublicationQueryImpl;

  factory CalendarIncomingPublicationQuery.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationQuery(
      pageSize: jsonSerialization['pageSize'] as int?,
      includeDismissed: jsonSerialization['includeDismissed'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['includeDismissed'],
            ),
      cursor: jsonSerialization['cursor'] as String?,
    );
  }

  final int pageSize;

  final bool includeDismissed;

  final String? cursor;

  /// Returns a shallow copy of this [CalendarIncomingPublicationQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationQuery copyWith({
    int? pageSize,
    bool? includeDismissed,
    String? cursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationQuery &&
            (identical(
                  other.pageSize,
                  pageSize,
                ) ||
                other.pageSize == pageSize) &&
            (identical(
                  other.includeDismissed,
                  includeDismissed,
                ) ||
                other.includeDismissed == includeDismissed) &&
            (identical(
                  other.cursor,
                  cursor,
                ) ||
                other.cursor == cursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      pageSize,
      includeDismissed,
      cursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationQuery',
      'pageSize': pageSize,
      'includeDismissed': includeDismissed,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationQuery',
      'pageSize': pageSize,
      'includeDismissed': includeDismissed,
      if (cursor != null) 'cursor': cursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationQueryImpl
    extends CalendarIncomingPublicationQuery {
  const _CalendarIncomingPublicationQueryImpl({
    int? pageSize,
    bool? includeDismissed,
    String? cursor,
  }) : super._(
         pageSize: pageSize,
         includeDismissed: includeDismissed,
         cursor: cursor,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationQuery]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationQuery copyWith({
    int? pageSize,
    bool? includeDismissed,
    Object? cursor = _Undefined,
  }) {
    return CalendarIncomingPublicationQuery(
      pageSize: pageSize ?? this.pageSize,
      includeDismissed: includeDismissed ?? this.includeDismissed,
      cursor: cursor is String? ? cursor : this.cursor,
    );
  }
}
