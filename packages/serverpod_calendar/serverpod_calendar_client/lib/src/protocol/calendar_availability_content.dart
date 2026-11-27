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
import 'package:serverpod_calendar_client/src/protocol/protocol.dart'
    as _ie4a1wrz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_availability_category_group.dart' as _iywbqexh;
import 'calendar_availability_class.dart' as _iucw7bzg;
import 'calendar_availability_extension.dart' as _ip5gybl4;
import 'calendar_availability_opening.dart' as _i8tf9h36;
import 'calendar_availability_organizer.dart' as _i5oc0nlo;
import 'calendar_availability_text.dart' as _itw42wa3;
import 'calendar_availability_text_parameters.dart' as _ipbm7ji7;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_free_busy_kind.dart' as _izms466b;

@_isc.immutable
abstract class CalendarAvailabilityContent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityContent._({
    this.summary,
    this.validFrom,
    this.validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required this.openings,
    this.description,
    this.location,
    this.categories,
    this.comments,
    this.url,
    this.classification,
    this.textParameters,
    this.extensions,
    this.organizer,
    this.validDuration,
    this.categoryGroups,
    this.contacts,
  }) : priority = priority ?? 0,
       closedKind = closedKind ?? _izms466b.CalendarFreeBusyKind.unavailable;

  const factory CalendarAvailabilityContent({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required List<_i8tf9h36.CalendarAvailabilityOpening> openings,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
    String? url,
    _iucw7bzg.CalendarAvailabilityClass? classification,
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
    _i5oc0nlo.CalendarAvailabilityOrganizer? organizer,
    _idn2i48l.CalendarEventDuration? validDuration,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
  }) = _CalendarAvailabilityContentImpl;

  factory CalendarAvailabilityContent.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityContent(
      summary: jsonSerialization['summary'] as String?,
      validFrom: jsonSerialization['validFrom'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['validFrom'],
            ),
      validUntil: jsonSerialization['validUntil'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
              jsonSerialization['validUntil'],
            ),
      priority: jsonSerialization['priority'] as int?,
      closedKind: jsonSerialization['closedKind'] == null
          ? null
          : _izms466b.CalendarFreeBusyKind.fromJson(
              (jsonSerialization['closedKind'] as String),
            ),
      openings: _ie4a1wrz.Protocol()
          .deserialize<List<_i8tf9h36.CalendarAvailabilityOpening>>(
            jsonSerialization['openings'],
          ),
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      categories: jsonSerialization['categories'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<List<String>>(
              jsonSerialization['categories'],
            ),
      comments: jsonSerialization['comments'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<List<String>>(
              jsonSerialization['comments'],
            ),
      url: jsonSerialization['url'] as String?,
      classification: jsonSerialization['classification'] == null
          ? null
          : _iucw7bzg.CalendarAvailabilityClass.fromJson(
              (jsonSerialization['classification'] as String),
            ),
      textParameters: jsonSerialization['textParameters'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_ipbm7ji7.CalendarAvailabilityTextParameters>(
                  jsonSerialization['textParameters'],
                ),
      extensions: jsonSerialization['extensions'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_ip5gybl4.CalendarAvailabilityExtension>>(
                  jsonSerialization['extensions'],
                ),
      organizer: jsonSerialization['organizer'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_i5oc0nlo.CalendarAvailabilityOrganizer>(
                  jsonSerialization['organizer'],
                ),
      validDuration: jsonSerialization['validDuration'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_idn2i48l.CalendarEventDuration>(
              jsonSerialization['validDuration'],
            ),
      categoryGroups: jsonSerialization['categoryGroups'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_iywbqexh.CalendarAvailabilityCategoryGroup>>(
                  jsonSerialization['categoryGroups'],
                ),
      contacts: jsonSerialization['contacts'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_itw42wa3.CalendarAvailabilityText>>(
                  jsonSerialization['contacts'],
                ),
    );
  }

  final String? summary;

  final _ieswiaty.CalendarEventTiming? validFrom;

  final _ieswiaty.CalendarEventTiming? validUntil;

  final int priority;

  final _izms466b.CalendarFreeBusyKind closedKind;

  final List<_i8tf9h36.CalendarAvailabilityOpening> openings;

  final String? description;

  final String? location;

  final List<String>? categories;

  final List<String>? comments;

  final String? url;

  final _iucw7bzg.CalendarAvailabilityClass? classification;

  final _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters;

  final List<_ip5gybl4.CalendarAvailabilityExtension>? extensions;

  final _i5oc0nlo.CalendarAvailabilityOrganizer? organizer;

  final _idn2i48l.CalendarEventDuration? validDuration;

  final List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups;

  final List<_itw42wa3.CalendarAvailabilityText>? contacts;

  /// Returns a shallow copy of this [CalendarAvailabilityContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityContent copyWith({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    List<_i8tf9h36.CalendarAvailabilityOpening>? openings,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
    String? url,
    _iucw7bzg.CalendarAvailabilityClass? classification,
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
    _i5oc0nlo.CalendarAvailabilityOrganizer? organizer,
    _idn2i48l.CalendarEventDuration? validDuration,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityContent &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.validFrom,
                  validFrom,
                ) ||
                other.validFrom == validFrom) &&
            (identical(
                  other.validUntil,
                  validUntil,
                ) ||
                other.validUntil == validUntil) &&
            (identical(
                  other.priority,
                  priority,
                ) ||
                other.priority == priority) &&
            (identical(
                  other.closedKind,
                  closedKind,
                ) ||
                other.closedKind == closedKind) &&
            const _iss.DeepCollectionEquality().equals(
              other.openings,
              openings,
            ) &&
            (identical(
                  other.description,
                  description,
                ) ||
                other.description == description) &&
            (identical(
                  other.location,
                  location,
                ) ||
                other.location == location) &&
            const _iss.DeepCollectionEquality().equals(
              other.categories,
              categories,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.comments,
              comments,
            ) &&
            (identical(
                  other.url,
                  url,
                ) ||
                other.url == url) &&
            (identical(
                  other.classification,
                  classification,
                ) ||
                other.classification == classification) &&
            (identical(
                  other.textParameters,
                  textParameters,
                ) ||
                other.textParameters == textParameters) &&
            const _iss.DeepCollectionEquality().equals(
              other.extensions,
              extensions,
            ) &&
            (identical(
                  other.organizer,
                  organizer,
                ) ||
                other.organizer == organizer) &&
            (identical(
                  other.validDuration,
                  validDuration,
                ) ||
                other.validDuration == validDuration) &&
            const _iss.DeepCollectionEquality().equals(
              other.categoryGroups,
              categoryGroups,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.contacts,
              contacts,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      validFrom,
      validUntil,
      priority,
      closedKind,
      const _iss.DeepCollectionEquality().hash(openings),
      description,
      location,
      const _iss.DeepCollectionEquality().hash(categories),
      const _iss.DeepCollectionEquality().hash(comments),
      url,
      classification,
      textParameters,
      const _iss.DeepCollectionEquality().hash(extensions),
      organizer,
      validDuration,
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(contacts),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityContent',
      if (summary != null) 'summary': summary,
      if (validFrom != null) 'validFrom': validFrom?.toJson(),
      if (validUntil != null) 'validUntil': validUntil?.toJson(),
      'priority': priority,
      'closedKind': closedKind.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJson()),
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification?.toJson(),
      if (textParameters != null) 'textParameters': textParameters?.toJson(),
      if (extensions != null)
        'extensions': extensions?.toJson(valueToJson: (v) => v.toJson()),
      if (organizer != null) 'organizer': organizer?.toJson(),
      if (validDuration != null) 'validDuration': validDuration?.toJson(),
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityContent',
      if (summary != null) 'summary': summary,
      if (validFrom != null) 'validFrom': validFrom?.toJsonForProtocol(),
      if (validUntil != null) 'validUntil': validUntil?.toJsonForProtocol(),
      'priority': priority,
      'closedKind': closedKind.toJson(),
      'openings': openings.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification?.toJson(),
      if (textParameters != null)
        'textParameters': textParameters?.toJsonForProtocol(),
      if (extensions != null)
        'extensions': extensions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (organizer != null) 'organizer': organizer?.toJsonForProtocol(),
      if (validDuration != null)
        'validDuration': validDuration?.toJsonForProtocol(),
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityContentImpl extends CalendarAvailabilityContent {
  const _CalendarAvailabilityContentImpl({
    String? summary,
    _ieswiaty.CalendarEventTiming? validFrom,
    _ieswiaty.CalendarEventTiming? validUntil,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    required List<_i8tf9h36.CalendarAvailabilityOpening> openings,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
    String? url,
    _iucw7bzg.CalendarAvailabilityClass? classification,
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
    _i5oc0nlo.CalendarAvailabilityOrganizer? organizer,
    _idn2i48l.CalendarEventDuration? validDuration,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
  }) : super._(
         summary: summary,
         validFrom: validFrom,
         validUntil: validUntil,
         priority: priority,
         closedKind: closedKind,
         openings: openings,
         description: description,
         location: location,
         categories: categories,
         comments: comments,
         url: url,
         classification: classification,
         textParameters: textParameters,
         extensions: extensions,
         organizer: organizer,
         validDuration: validDuration,
         categoryGroups: categoryGroups,
         contacts: contacts,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityContent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityContent copyWith({
    Object? summary = _Undefined,
    Object? validFrom = _Undefined,
    Object? validUntil = _Undefined,
    int? priority,
    _izms466b.CalendarFreeBusyKind? closedKind,
    List<_i8tf9h36.CalendarAvailabilityOpening>? openings,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? categories = _Undefined,
    Object? comments = _Undefined,
    Object? url = _Undefined,
    Object? classification = _Undefined,
    Object? textParameters = _Undefined,
    Object? extensions = _Undefined,
    Object? organizer = _Undefined,
    Object? validDuration = _Undefined,
    Object? categoryGroups = _Undefined,
    Object? contacts = _Undefined,
  }) {
    return CalendarAvailabilityContent(
      summary: summary is String? ? summary : this.summary,
      validFrom: validFrom is _ieswiaty.CalendarEventTiming?
          ? validFrom
          : this.validFrom?.copyWith(),
      validUntil: validUntil is _ieswiaty.CalendarEventTiming?
          ? validUntil
          : this.validUntil?.copyWith(),
      priority: priority ?? this.priority,
      closedKind: closedKind ?? this.closedKind,
      openings: openings ?? this.openings.map((e0) => e0.copyWith()).toList(),
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      categories: categories is List<String>?
          ? categories
          : this.categories?.map((e0) => e0).toList(),
      comments: comments is List<String>?
          ? comments
          : this.comments?.map((e0) => e0).toList(),
      url: url is String? ? url : this.url,
      classification: classification is _iucw7bzg.CalendarAvailabilityClass?
          ? classification
          : this.classification,
      textParameters:
          textParameters is _ipbm7ji7.CalendarAvailabilityTextParameters?
          ? textParameters
          : this.textParameters?.copyWith(),
      extensions: extensions is List<_ip5gybl4.CalendarAvailabilityExtension>?
          ? extensions
          : this.extensions?.map((e0) => e0.copyWith()).toList(),
      organizer: organizer is _i5oc0nlo.CalendarAvailabilityOrganizer?
          ? organizer
          : this.organizer?.copyWith(),
      validDuration: validDuration is _idn2i48l.CalendarEventDuration?
          ? validDuration
          : this.validDuration?.copyWith(),
      categoryGroups:
          categoryGroups is List<_iywbqexh.CalendarAvailabilityCategoryGroup>?
          ? categoryGroups
          : this.categoryGroups?.map((e0) => e0.copyWith()).toList(),
      contacts: contacts is List<_itw42wa3.CalendarAvailabilityText>?
          ? contacts
          : this.contacts?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
