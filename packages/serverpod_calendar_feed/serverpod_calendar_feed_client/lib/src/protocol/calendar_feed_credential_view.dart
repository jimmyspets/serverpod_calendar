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
abstract class CalendarFeedCredentialView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFeedCredentialView._({
    required this.id,
    required this.feedId,
    required this.revision,
    this.label,
    required this.createdAt,
    this.revokedAt,
  });

  const factory CalendarFeedCredentialView({
    required _isc.UuidValue id,
    required _isc.UuidValue feedId,
    required int revision,
    String? label,
    required DateTime createdAt,
    DateTime? revokedAt,
  }) = _CalendarFeedCredentialViewImpl;

  factory CalendarFeedCredentialView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedCredentialView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      feedId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['feedId']),
      revision: jsonSerialization['revision'] as int,
      label: jsonSerialization['label'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue feedId;

  final int revision;

  final String? label;

  final DateTime createdAt;

  final DateTime? revokedAt;

  /// Returns a shallow copy of this [CalendarFeedCredentialView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFeedCredentialView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? feedId,
    int? revision,
    String? label,
    DateTime? createdAt,
    DateTime? revokedAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFeedCredentialView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.feedId,
                  feedId,
                ) ||
                other.feedId == feedId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.label,
                  label,
                ) ||
                other.label == label) &&
            (identical(
                  other.createdAt,
                  createdAt,
                ) ||
                other.createdAt == createdAt) &&
            (identical(
                  other.revokedAt,
                  revokedAt,
                ) ||
                other.revokedAt == revokedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      feedId,
      revision,
      label,
      createdAt,
      revokedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedCredentialView',
      'id': id.toJson(),
      'feedId': feedId.toJson(),
      'revision': revision,
      if (label != null) 'label': label,
      'createdAt': createdAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedCredentialView',
      'id': id.toJson(),
      'feedId': feedId.toJson(),
      'revision': revision,
      if (label != null) 'label': label,
      'createdAt': createdAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedCredentialViewImpl extends CalendarFeedCredentialView {
  const _CalendarFeedCredentialViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue feedId,
    required int revision,
    String? label,
    required DateTime createdAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         feedId: feedId,
         revision: revision,
         label: label,
         createdAt: createdAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [CalendarFeedCredentialView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFeedCredentialView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? feedId,
    int? revision,
    Object? label = _Undefined,
    DateTime? createdAt,
    Object? revokedAt = _Undefined,
  }) {
    return CalendarFeedCredentialView(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      revision: revision ?? this.revision,
      label: label is String? ? label : this.label,
      createdAt: createdAt ?? this.createdAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}
