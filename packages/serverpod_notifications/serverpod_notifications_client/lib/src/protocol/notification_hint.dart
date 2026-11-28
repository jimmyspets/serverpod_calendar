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
abstract class NotificationHint
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const NotificationHint._({this.notificationId});

  const factory NotificationHint({_isc.UuidValue? notificationId}) =
      _NotificationHintImpl;

  factory NotificationHint.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotificationHint(
      notificationId: jsonSerialization['notificationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['notificationId'],
            ),
    );
  }

  final _isc.UuidValue? notificationId;

  /// Returns a shallow copy of this [NotificationHint]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  NotificationHint copyWith({_isc.UuidValue? notificationId});
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is NotificationHint &&
            (identical(
                  other.notificationId,
                  notificationId,
                ) ||
                other.notificationId == notificationId);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      notificationId,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationHint',
      if (notificationId != null) 'notificationId': notificationId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_notifications.NotificationHint',
      if (notificationId != null) 'notificationId': notificationId?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationHintImpl extends NotificationHint {
  const _NotificationHintImpl({_isc.UuidValue? notificationId})
    : super._(notificationId: notificationId);

  /// Returns a shallow copy of this [NotificationHint]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  NotificationHint copyWith({Object? notificationId = _Undefined}) {
    return NotificationHint(
      notificationId: notificationId is _isc.UuidValue?
          ? notificationId
          : this.notificationId,
    );
  }
}
