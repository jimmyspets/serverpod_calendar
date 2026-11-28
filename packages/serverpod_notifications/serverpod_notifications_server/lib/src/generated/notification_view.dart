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
abstract class NotificationView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const NotificationView._({
    required this.id,
    required this.title,
    this.body,
    required this.sourceNamespace,
    this.actionReference,
    required this.dueAt,
    required this.expiresAt,
  });

  const factory NotificationView({
    required _is.UuidValue id,
    required String title,
    String? body,
    required String sourceNamespace,
    String? actionReference,
    required DateTime dueAt,
    required DateTime expiresAt,
  }) = _NotificationViewImpl;

  factory NotificationView.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      title: jsonSerialization['title'] as String,
      body: jsonSerialization['body'] as String?,
      sourceNamespace: jsonSerialization['sourceNamespace'] as String,
      actionReference: jsonSerialization['actionReference'] as String?,
      dueAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  final _is.UuidValue id;

  final String title;

  final String? body;

  final String sourceNamespace;

  final String? actionReference;

  final DateTime dueAt;

  final DateTime expiresAt;

  /// Returns a shallow copy of this [NotificationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationView copyWith({
    _is.UuidValue? id,
    String? title,
    String? body,
    String? sourceNamespace,
    String? actionReference,
    DateTime? dueAt,
    DateTime? expiresAt,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is NotificationView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.title,
                  title,
                ) ||
                other.title == title) &&
            (identical(
                  other.body,
                  body,
                ) ||
                other.body == body) &&
            (identical(
                  other.sourceNamespace,
                  sourceNamespace,
                ) ||
                other.sourceNamespace == sourceNamespace) &&
            (identical(
                  other.actionReference,
                  actionReference,
                ) ||
                other.actionReference == actionReference) &&
            (identical(
                  other.dueAt,
                  dueAt,
                ) ||
                other.dueAt == dueAt) &&
            (identical(
                  other.expiresAt,
                  expiresAt,
                ) ||
                other.expiresAt == expiresAt);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      title,
      body,
      sourceNamespace,
      actionReference,
      dueAt,
      expiresAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationView',
      'id': id.toJson(),
      'title': title,
      if (body != null) 'body': body,
      'sourceNamespace': sourceNamespace,
      if (actionReference != null) 'actionReference': actionReference,
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_notifications.NotificationView',
      'id': id.toJson(),
      'title': title,
      if (body != null) 'body': body,
      'sourceNamespace': sourceNamespace,
      if (actionReference != null) 'actionReference': actionReference,
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationViewImpl extends NotificationView {
  const _NotificationViewImpl({
    required _is.UuidValue id,
    required String title,
    String? body,
    required String sourceNamespace,
    String? actionReference,
    required DateTime dueAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         title: title,
         body: body,
         sourceNamespace: sourceNamespace,
         actionReference: actionReference,
         dueAt: dueAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [NotificationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationView copyWith({
    _is.UuidValue? id,
    String? title,
    Object? body = _Undefined,
    String? sourceNamespace,
    Object? actionReference = _Undefined,
    DateTime? dueAt,
    DateTime? expiresAt,
  }) {
    return NotificationView(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body is String? ? body : this.body,
      sourceNamespace: sourceNamespace ?? this.sourceNamespace,
      actionReference: actionReference is String?
          ? actionReference
          : this.actionReference,
      dueAt: dueAt ?? this.dueAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
