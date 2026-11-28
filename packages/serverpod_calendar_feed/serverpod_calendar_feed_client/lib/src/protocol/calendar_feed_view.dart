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
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as _imrxcdin;
import 'package:serverpod_calendar_feed_client/src/protocol/protocol.dart'
    as _ip8jx9v6;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;

@_isc.immutable
abstract class CalendarFeedView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue id,
    required int revision,
    required String displayName,
    required List<_isc.UuidValue> calendarIds,
    required _isc.UuidValue protocolUid,
    required DateTime protocolModifiedAt,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
  }) = _CalendarFeedViewImpl;

  factory CalendarFeedView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarFeedView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      revision: jsonSerialization['revision'] as int,
      displayName: jsonSerialization['displayName'] as String,
      calendarIds: _ip8jx9v6.Protocol().deserialize<List<_isc.UuidValue>>(
        jsonSerialization['calendarIds'],
      ),
      protocolUid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['protocolUid'],
      ),
      protocolModifiedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['protocolModifiedAt'],
      ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _ip8jx9v6.Protocol()
                .deserialize<_imrxcdin.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _ip8jx9v6.Protocol()
                .deserialize<_imrxcdin.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
    );
  }

  final _isc.UuidValue id;

  final int revision;

  final String displayName;

  final List<_isc.UuidValue> calendarIds;

  final _isc.UuidValue protocolUid;

  final DateTime protocolModifiedAt;

  final _imrxcdin.CalendarProtocolMetadata? protocolMetadata;

  final _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata;

  /// Returns a shallow copy of this [CalendarFeedView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFeedView copyWith({
    _isc.UuidValue? id,
    int? revision,
    String? displayName,
    List<_isc.UuidValue>? calendarIds,
    _isc.UuidValue? protocolUid,
    DateTime? protocolModifiedAt,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedViewImpl extends CalendarFeedView {
  const _CalendarFeedViewImpl({
    required _isc.UuidValue id,
    required int revision,
    required String displayName,
    required List<_isc.UuidValue> calendarIds,
    required _isc.UuidValue protocolUid,
    required DateTime protocolModifiedAt,
    _imrxcdin.CalendarProtocolMetadata? protocolMetadata,
    _imrxcdin.CalendarSupplementalMetadata? supplementalMetadata,
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
  @_isc.useResult
  @override
  CalendarFeedView copyWith({
    _isc.UuidValue? id,
    int? revision,
    String? displayName,
    List<_isc.UuidValue>? calendarIds,
    _isc.UuidValue? protocolUid,
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
      protocolMetadata: protocolMetadata is _imrxcdin.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _imrxcdin.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
    );
  }
}
