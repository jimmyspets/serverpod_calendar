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

import 'calendar_refresh_view.dart' as _i34hhk2q;

abstract class CalendarRefreshPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarRefreshPage._({
    required this.entries,
    this.publicationId,
    this.generation,
    this.nextCursor,
  });

  factory CalendarRefreshPage({
    required List<_i34hhk2q.CalendarRefreshView> entries,
    _isc.UuidValue? publicationId,
    int? generation,
    String? nextCursor,
  }) = _CalendarRefreshPageImpl;

  factory CalendarRefreshPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarRefreshPage(
      entries: _ie4a1wrz.Protocol()
          .deserialize<List<_i34hhk2q.CalendarRefreshView>>(
            jsonSerialization['entries'],
          ),
      publicationId: jsonSerialization['publicationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['publicationId'],
            ),
      generation: jsonSerialization['generation'] as int?,
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  List<_i34hhk2q.CalendarRefreshView> entries;

  _isc.UuidValue? publicationId;

  int? generation;

  String? nextCursor;

  /// Returns a shallow copy of this [CalendarRefreshPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarRefreshPage copyWith({
    List<_i34hhk2q.CalendarRefreshView>? entries,
    _isc.UuidValue? publicationId = const _isc.$UndefinedUuidValue(),
    int? generation,
    String? nextCursor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      if (publicationId != null) 'publicationId': publicationId?.toJson(),
      if (generation != null) 'generation': generation,
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (publicationId != null) 'publicationId': publicationId?.toJson(),
      if (generation != null) 'generation': generation,
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarRefreshPageImpl extends CalendarRefreshPage {
  _CalendarRefreshPageImpl({
    required List<_i34hhk2q.CalendarRefreshView> entries,
    _isc.UuidValue? publicationId,
    int? generation,
    String? nextCursor,
  }) : super._(
         entries: entries,
         publicationId: publicationId,
         generation: generation,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarRefreshPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarRefreshPage copyWith({
    List<_i34hhk2q.CalendarRefreshView>? entries,
    _isc.UuidValue? publicationId = const _isc.$UndefinedUuidValue(),
    Object? generation = _Undefined,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarRefreshPage(
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      publicationId: publicationId is _isc.UndefinedSentinel
          ? this.publicationId
          : publicationId,
      generation: generation is int? ? generation : this.generation,
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
