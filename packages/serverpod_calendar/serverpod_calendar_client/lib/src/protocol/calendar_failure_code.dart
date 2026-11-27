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

enum CalendarFailureCode implements _isc.SerializableModel {
  validation,
  accessDenied,
  unavailable,
  staleRevision,
  dependencyConflict,
  limitExceeded,
  invalidCursor,
  invariantViolation;

  static CalendarFailureCode fromJson(String name) {
    switch (name) {
      case 'validation':
        return CalendarFailureCode.validation;
      case 'accessDenied':
        return CalendarFailureCode.accessDenied;
      case 'unavailable':
        return CalendarFailureCode.unavailable;
      case 'staleRevision':
        return CalendarFailureCode.staleRevision;
      case 'dependencyConflict':
        return CalendarFailureCode.dependencyConflict;
      case 'limitExceeded':
        return CalendarFailureCode.limitExceeded;
      case 'invalidCursor':
        return CalendarFailureCode.invalidCursor;
      case 'invariantViolation':
        return CalendarFailureCode.invariantViolation;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CalendarFailureCode"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
