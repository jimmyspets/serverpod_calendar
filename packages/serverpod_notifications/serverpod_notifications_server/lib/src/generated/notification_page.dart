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
import 'package:serverpod_notifications_server/src/generated/protocol.dart'
    as _i117tju2;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'notification_view.dart' as _i86vfscw;

@_is.immutable
abstract class NotificationPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const NotificationPage._({
    required this.notifications,
    this.nextCursor,
  });

  const factory NotificationPage({
    required List<_i86vfscw.NotificationView> notifications,
    String? nextCursor,
  }) = _NotificationPageImpl;

  factory NotificationPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationPage(
      notifications: _i117tju2.Protocol()
          .deserialize<List<_i86vfscw.NotificationView>>(
            jsonSerialization['notifications'],
          ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  final List<_i86vfscw.NotificationView> notifications;

  final String? nextCursor;

  /// Returns a shallow copy of this [NotificationPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationPage copyWith({
    List<_i86vfscw.NotificationView>? notifications,
    String? nextCursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is NotificationPage &&
            const _iss.DeepCollectionEquality().equals(
              other.notifications,
              notifications,
            ) &&
            (identical(
                  other.nextCursor,
                  nextCursor,
                ) ||
                other.nextCursor == nextCursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(notifications),
      nextCursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationPage',
      'notifications': notifications.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_notifications.NotificationPage',
      'notifications': notifications.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationPageImpl extends NotificationPage {
  const _NotificationPageImpl({
    required List<_i86vfscw.NotificationView> notifications,
    String? nextCursor,
  }) : super._(
         notifications: notifications,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [NotificationPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationPage copyWith({
    List<_i86vfscw.NotificationView>? notifications,
    Object? nextCursor = _Undefined,
  }) {
    return NotificationPage(
      notifications:
          notifications ??
          this.notifications.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
