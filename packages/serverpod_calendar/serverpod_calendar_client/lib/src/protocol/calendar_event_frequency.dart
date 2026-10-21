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

enum CalendarEventFrequency implements _isc.SerializableModel {
  minutely,
  hourly,
  daily,
  weekly,
  monthly,
  yearly;

  static CalendarEventFrequency fromJson(String name) {
    switch (name) {
      case 'minutely':
        return CalendarEventFrequency.minutely;
      case 'hourly':
        return CalendarEventFrequency.hourly;
      case 'daily':
        return CalendarEventFrequency.daily;
      case 'weekly':
        return CalendarEventFrequency.weekly;
      case 'monthly':
        return CalendarEventFrequency.monthly;
      case 'yearly':
        return CalendarEventFrequency.yearly;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CalendarEventFrequency"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
