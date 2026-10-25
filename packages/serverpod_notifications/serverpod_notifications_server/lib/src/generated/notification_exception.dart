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
import 'notification_failure_code.dart' as _i909e29g;

abstract class NotificationException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  NotificationException._({
    required this.code,
    required this.message,
  });

  factory NotificationException({
    required _i909e29g.NotificationFailureCode code,
    required String message,
  }) = _NotificationExceptionImpl;

  factory NotificationException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NotificationException(
      code: _i909e29g.NotificationFailureCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _i909e29g.NotificationFailureCode code;

  String message;

  /// Returns a shallow copy of this [NotificationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationException copyWith({
    _i909e29g.NotificationFailureCode? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_notifications.NotificationException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'NotificationException(code: $code, message: $message)';
  }
}

class _NotificationExceptionImpl extends NotificationException {
  _NotificationExceptionImpl({
    required _i909e29g.NotificationFailureCode code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [NotificationException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationException copyWith({
    _i909e29g.NotificationFailureCode? code,
    String? message,
  }) {
    return NotificationException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
