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
abstract class CalendarFreeBusyMessageView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarFreeBusyMessageView._({
    required this.id,
    required this.method,
    required this.header,
    this.headId,
    this.sourceRevision,
    this.replyRevision,
    required this.isCurrent,
    required this.conflicted,
    required this.receivedAt,
    required this.expiresAt,
    this.dismissedAt,
  });

  const factory CalendarFreeBusyMessageView({
    required _isc.UuidValue id,
    required String method,
    required String header,
    _isc.UuidValue? headId,
    int? sourceRevision,
    int? replyRevision,
    required bool isCurrent,
    required bool conflicted,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
  }) = _CalendarFreeBusyMessageViewImpl;

  factory CalendarFreeBusyMessageView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyMessageView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      method: jsonSerialization['method'] as String,
      header: jsonSerialization['header'] as String,
      headId: jsonSerialization['headId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['headId']),
      sourceRevision: jsonSerialization['sourceRevision'] as int?,
      replyRevision: jsonSerialization['replyRevision'] as int?,
      isCurrent: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['isCurrent'],
      ),
      conflicted: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['conflicted'],
      ),
      receivedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  final _isc.UuidValue id;

  final String method;

  final String header;

  final _isc.UuidValue? headId;

  final int? sourceRevision;

  final int? replyRevision;

  final bool isCurrent;

  final bool conflicted;

  final DateTime receivedAt;

  final DateTime expiresAt;

  final DateTime? dismissedAt;

  /// Returns a shallow copy of this [CalendarFreeBusyMessageView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyMessageView copyWith({
    _isc.UuidValue? id,
    String? method,
    String? header,
    _isc.UuidValue? headId = const _isc.$UndefinedUuidValue(),
    int? sourceRevision,
    int? replyRevision,
    bool? isCurrent,
    bool? conflicted,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _isc.$UndefinedDateTime(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFreeBusyMessageView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.method,
                  method,
                ) ||
                other.method == method) &&
            (identical(
                  other.header,
                  header,
                ) ||
                other.header == header) &&
            (identical(
                  other.headId,
                  headId,
                ) ||
                other.headId == headId) &&
            (identical(
                  other.sourceRevision,
                  sourceRevision,
                ) ||
                other.sourceRevision == sourceRevision) &&
            (identical(
                  other.replyRevision,
                  replyRevision,
                ) ||
                other.replyRevision == replyRevision) &&
            (identical(
                  other.isCurrent,
                  isCurrent,
                ) ||
                other.isCurrent == isCurrent) &&
            (identical(
                  other.conflicted,
                  conflicted,
                ) ||
                other.conflicted == conflicted) &&
            (identical(
                  other.receivedAt,
                  receivedAt,
                ) ||
                other.receivedAt == receivedAt) &&
            (identical(
                  other.expiresAt,
                  expiresAt,
                ) ||
                other.expiresAt == expiresAt) &&
            (identical(
                  other.dismissedAt,
                  dismissedAt,
                ) ||
                other.dismissedAt == dismissedAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      method,
      header,
      headId,
      sourceRevision,
      replyRevision,
      isCurrent,
      conflicted,
      receivedAt,
      expiresAt,
      dismissedAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyMessageView',
      'id': id.toJson(),
      'method': method,
      'header': header,
      if (headId != null) 'headId': headId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      if (replyRevision != null) 'replyRevision': replyRevision,
      'isCurrent': isCurrent,
      'conflicted': conflicted,
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyMessageView',
      'id': id.toJson(),
      'method': method,
      'header': header,
      if (headId != null) 'headId': headId?.toJson(),
      if (sourceRevision != null) 'sourceRevision': sourceRevision,
      if (replyRevision != null) 'replyRevision': replyRevision,
      'isCurrent': isCurrent,
      'conflicted': conflicted,
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyMessageViewImpl extends CalendarFreeBusyMessageView {
  const _CalendarFreeBusyMessageViewImpl({
    required _isc.UuidValue id,
    required String method,
    required String header,
    _isc.UuidValue? headId,
    int? sourceRevision,
    int? replyRevision,
    required bool isCurrent,
    required bool conflicted,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         method: method,
         header: header,
         headId: headId,
         sourceRevision: sourceRevision,
         replyRevision: replyRevision,
         isCurrent: isCurrent,
         conflicted: conflicted,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyMessageView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyMessageView copyWith({
    _isc.UuidValue? id,
    String? method,
    String? header,
    _isc.UuidValue? headId = const _isc.$UndefinedUuidValue(),
    Object? sourceRevision = _Undefined,
    Object? replyRevision = _Undefined,
    bool? isCurrent,
    bool? conflicted,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _isc.$UndefinedDateTime(),
  }) {
    return CalendarFreeBusyMessageView(
      id: id ?? this.id,
      method: method ?? this.method,
      header: header ?? this.header,
      headId: headId is _isc.UndefinedSentinel ? this.headId : headId,
      sourceRevision: sourceRevision is int?
          ? sourceRevision
          : this.sourceRevision,
      replyRevision: replyRevision is int? ? replyRevision : this.replyRevision,
      isCurrent: isCurrent ?? this.isCurrent,
      conflicted: conflicted ?? this.conflicted,
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      dismissedAt: dismissedAt is _isc.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
    );
  }
}
