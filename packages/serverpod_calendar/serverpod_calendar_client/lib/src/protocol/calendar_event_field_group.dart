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

enum CalendarEventFieldGroup implements _isc.SerializableModel {
  summary,
  description,
  location,
  timing,
  state,
  protocolIdentity,
  priority,
  resources,
  url,
  classification,
  categories,
  comments;

  static CalendarEventFieldGroup fromJson(String name) {
    switch (name) {
      case 'summary':
        return CalendarEventFieldGroup.summary;
      case 'description':
        return CalendarEventFieldGroup.description;
      case 'location':
        return CalendarEventFieldGroup.location;
      case 'timing':
        return CalendarEventFieldGroup.timing;
      case 'state':
        return CalendarEventFieldGroup.state;
      case 'protocolIdentity':
        return CalendarEventFieldGroup.protocolIdentity;
      case 'priority':
        return CalendarEventFieldGroup.priority;
      case 'resources':
        return CalendarEventFieldGroup.resources;
      case 'url':
        return CalendarEventFieldGroup.url;
      case 'classification':
        return CalendarEventFieldGroup.classification;
      case 'categories':
        return CalendarEventFieldGroup.categories;
      case 'comments':
        return CalendarEventFieldGroup.comments;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CalendarEventFieldGroup"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
