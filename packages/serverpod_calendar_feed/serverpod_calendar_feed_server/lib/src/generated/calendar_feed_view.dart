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
import 'package:serverpod_calendar_feed_server/src/generated/protocol.dart'
    as _i0kswevi;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as _ipn35bcd;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

@_is.immutable
abstract class CalendarFeedView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFeedView._({
    required this.id,
    required this.revision,
    required this.displayName,
    required this.calendarIds,
    required this.protocolUid,
    required this.protocolModifiedAt,
    this.protocolMetadata,
    this.supplementalMetadata,
  });

  const factory CalendarFeedView({
    required _is.UuidValue id,
    required int revision,
    required String displayName,
    required List<_is.UuidValue> calendarIds,
    required _is.UuidValue protocolUid,
    required DateTime protocolModifiedAt,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
  }) = _CalendarFeedViewImpl;

  factory CalendarFeedView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarFeedView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      revision: jsonSerialization['revision'] as int,
      displayName: jsonSerialization['displayName'] as String,
      calendarIds: _i0kswevi.Protocol().deserialize<List<_is.UuidValue>>(
        jsonSerialization['calendarIds'],
      ),
      protocolUid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['protocolUid'],
      ),
      protocolModifiedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['protocolModifiedAt'],
      ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _i0kswevi.Protocol()
                .deserialize<_ipn35bcd.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _i0kswevi.Protocol()
                .deserialize<_ipn35bcd.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
    );
  }

  final _is.UuidValue id;

  final int revision;

  final String displayName;

  final List<_is.UuidValue> calendarIds;

  final _is.UuidValue protocolUid;

  final DateTime protocolModifiedAt;

  final _ipn35bcd.CalendarProtocolMetadata? protocolMetadata;

  final _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata;

  /// Returns a shallow copy of this [CalendarFeedView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedView copyWith({
    _is.UuidValue? id,
    int? revision,
    String? displayName,
    List<_is.UuidValue>? calendarIds,
    _is.UuidValue? protocolUid,
    DateTime? protocolModifiedAt,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFeedView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.displayName,
                  displayName,
                ) ||
                other.displayName == displayName) &&
            const _iss.DeepCollectionEquality().equals(
              other.calendarIds,
              calendarIds,
            ) &&
            (identical(
                  other.protocolUid,
                  protocolUid,
                ) ||
                other.protocolUid == protocolUid) &&
            (identical(
                  other.protocolModifiedAt,
                  protocolModifiedAt,
                ) ||
                other.protocolModifiedAt == protocolModifiedAt) &&
            (identical(
                  other.protocolMetadata,
                  protocolMetadata,
                ) ||
                other.protocolMetadata == protocolMetadata) &&
            (identical(
                  other.supplementalMetadata,
                  supplementalMetadata,
                ) ||
                other.supplementalMetadata == supplementalMetadata);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      revision,
      displayName,
      const _iss.DeepCollectionEquality().hash(calendarIds),
      protocolUid,
      protocolModifiedAt,
      protocolMetadata,
      supplementalMetadata,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedView',
      'id': id.toJson(),
      'revision': revision,
      'displayName': displayName,
      'calendarIds': calendarIds.toJson(valueToJson: (v) => v.toJson()),
      'protocolUid': protocolUid.toJson(),
      'protocolModifiedAt': protocolModifiedAt.toJson(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedView',
      'id': id.toJson(),
      'revision': revision,
      'displayName': displayName,
      'calendarIds': calendarIds.toJson(valueToJson: (v) => v.toJson()),
      'protocolUid': protocolUid.toJson(),
      'protocolModifiedAt': protocolModifiedAt.toJson(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedViewImpl extends CalendarFeedView {
  const _CalendarFeedViewImpl({
    required _is.UuidValue id,
    required int revision,
    required String displayName,
    required List<_is.UuidValue> calendarIds,
    required _is.UuidValue protocolUid,
    required DateTime protocolModifiedAt,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
  }) : super._(
         id: id,
         revision: revision,
         displayName: displayName,
         calendarIds: calendarIds,
         protocolUid: protocolUid,
         protocolModifiedAt: protocolModifiedAt,
         protocolMetadata: protocolMetadata,
         supplementalMetadata: supplementalMetadata,
       );

  /// Returns a shallow copy of this [CalendarFeedView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedView copyWith({
    _is.UuidValue? id,
    int? revision,
    String? displayName,
    List<_is.UuidValue>? calendarIds,
    _is.UuidValue? protocolUid,
    DateTime? protocolModifiedAt,
    Object? protocolMetadata = _Undefined,
    Object? supplementalMetadata = _Undefined,
  }) {
    return CalendarFeedView(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      displayName: displayName ?? this.displayName,
      calendarIds: calendarIds ?? this.calendarIds.map((e0) => e0).toList(),
      protocolUid: protocolUid ?? this.protocolUid,
      protocolModifiedAt: protocolModifiedAt ?? this.protocolModifiedAt,
      protocolMetadata: protocolMetadata is _ipn35bcd.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _ipn35bcd.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
    );
  }
}
