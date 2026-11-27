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
import 'calendar_failure_code.dart' as _i7h2f30k;

abstract class CalendarException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  CalendarException._({
    required this.code,
    required this.message,
  });

  factory CalendarException({
    required _i7h2f30k.CalendarFailureCode code,
    required String message,
  }) = _CalendarExceptionImpl;

  factory CalendarException.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarException(
      code: _i7h2f30k.CalendarFailureCode.fromJson(
        (jsonSerialization['code'] as String),
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  _i7h2f30k.CalendarFailureCode code;

  String message;

  /// Returns a shallow copy of this [CalendarException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarException copyWith({
    _i7h2f30k.CalendarFailureCode? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarException',
      'code': code.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return 'CalendarException(code: $code, message: $message)';
  }
}

class _CalendarExceptionImpl extends CalendarException {
  _CalendarExceptionImpl({
    required _i7h2f30k.CalendarFailureCode code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [CalendarException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarException copyWith({
    _i7h2f30k.CalendarFailureCode? code,
    String? message,
  }) {
    return CalendarException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
