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
import 'calendar_feed_failure_code.dart' as _iuwqxkhl;

abstract class CalendarFeedException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  CalendarFeedException._({
    required this.code,
    required this.message,
  });

  factory CalendarFeedException({
    required _iuwqxkhl.CalendarFeedFailureCode code,
    required String message,
  }) = _CalendarFeedExceptionImpl;

  factory CalendarFeedException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedException(
      code: _iuwqxkhl.CalendarFeedFailureCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _iuwqxkhl.CalendarFeedFailureCode code;

  String message;

  /// Returns a shallow copy of this [CalendarFeedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFeedException copyWith({
    _iuwqxkhl.CalendarFeedFailureCode? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'CalendarFeedException(code: $code, message: $message)';
  }
}

class _CalendarFeedExceptionImpl extends CalendarFeedException {
  _CalendarFeedExceptionImpl({
    required _iuwqxkhl.CalendarFeedFailureCode code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [CalendarFeedException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFeedException copyWith({
    _iuwqxkhl.CalendarFeedFailureCode? code,
    String? message,
  }) {
    return CalendarFeedException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
