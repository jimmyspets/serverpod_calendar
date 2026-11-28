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

enum NotificationFailureCode implements _isc.SerializableModel {
  accessDenied,
  unavailable,
  validation,
  conflict,
  invalidCursor,
  limitExceeded;

  static NotificationFailureCode fromJson(String name) {
    switch (name) {
      case 'accessDenied':
        return NotificationFailureCode.accessDenied;
      case 'unavailable':
        return NotificationFailureCode.unavailable;
      case 'validation':
        return NotificationFailureCode.validation;
      case 'conflict':
        return NotificationFailureCode.conflict;
      case 'invalidCursor':
        return NotificationFailureCode.invalidCursor;
      case 'limitExceeded':
        return NotificationFailureCode.limitExceeded;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "NotificationFailureCode"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
