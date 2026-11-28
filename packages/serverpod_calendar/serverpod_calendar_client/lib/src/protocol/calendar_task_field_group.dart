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

enum CalendarTaskFieldGroup implements _isc.SerializableModel {
  summary,
  description,
  location,
  timing,
  priority,
  progress,
  assignments,
  protocolIdentity;

  static CalendarTaskFieldGroup fromJson(String name) {
    switch (name) {
      case 'summary':
        return CalendarTaskFieldGroup.summary;
      case 'description':
        return CalendarTaskFieldGroup.description;
      case 'location':
        return CalendarTaskFieldGroup.location;
      case 'timing':
        return CalendarTaskFieldGroup.timing;
      case 'priority':
        return CalendarTaskFieldGroup.priority;
      case 'progress':
        return CalendarTaskFieldGroup.progress;
      case 'assignments':
        return CalendarTaskFieldGroup.assignments;
      case 'protocolIdentity':
        return CalendarTaskFieldGroup.protocolIdentity;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CalendarTaskFieldGroup"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
