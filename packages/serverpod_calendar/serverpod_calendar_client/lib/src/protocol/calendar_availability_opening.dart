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
import 'calendar_availability_extension.dart' as _ip5gybl4;
import 'calendar_availability_text.dart' as _itw42wa3;
import 'calendar_availability_text_parameters.dart' as _ipbm7ji7;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_timing.dart' as _ieswiaty;

@_isc.immutable
abstract class CalendarAvailabilityOpening
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOpening._({
    this.uid,
    required this.timing,
    this.recurrence,
    this.summary,
    this.description,
    this.location,
    this.categories,
    this.comments,
    this.textParameters,
    this.extensions,
    this.categoryGroups,
    this.contacts,
    this.protocolUid,
    this.periods,
  });

  const factory CalendarAvailabilityOpening({
    _isc.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
    String? protocolUid,
    List<_ieswiaty.CalendarEventTiming>? periods,
  }) = _CalendarAvailabilityOpeningImpl;

  factory CalendarAvailabilityOpening.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOpening(
      uid: jsonSerialization['uid'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['uid']),
      timing: _ie4a1wrz.Protocol().deserialize<_ieswiaty.CalendarEventTiming>(
        jsonSerialization['timing'],
      ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
      summary: jsonSerialization['summary'] as String?,
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
      protocolUid: jsonSerialization['protocolUid'] as String?,
      periods: jsonSerialization['periods'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_ieswiaty.CalendarEventTiming>>(
                  jsonSerialization['periods'],
                ),
    );
  }

  final _isc.UuidValue? uid;

  final _ieswiaty.CalendarEventTiming timing;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  final String? summary;

  final String? description;

  final String? location;

  final List<String>? categories;

  final List<String>? comments;

  final _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters;

  final List<_ip5gybl4.CalendarAvailabilityExtension>? extensions;

  final List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups;

  final List<_itw42wa3.CalendarAvailabilityText>? contacts;

  final String? protocolUid;

  final List<_ieswiaty.CalendarEventTiming>? periods;

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOpening copyWith({
    _isc.UuidValue? uid = const _isc.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence =
        const _UndefinedCalendarAvailabilityOpening$recurrence(),
    String? summary,
    String? description,
    String? location,
    List<String>? categories = const _isc.$UndefinedList<String>(),
    List<String>? comments = const _isc.$UndefinedList<String>(),
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters =
        const _UndefinedCalendarAvailabilityOpening$textParameters(),
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions =
        const _isc.$UndefinedList<_ip5gybl4.CalendarAvailabilityExtension>(),
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups =
        const _isc.$UndefinedList<
          _iywbqexh.CalendarAvailabilityCategoryGroup
        >(),
    List<_itw42wa3.CalendarAvailabilityText>? contacts =
        const _isc.$UndefinedList<_itw42wa3.CalendarAvailabilityText>(),
    String? protocolUid,
    List<_ieswiaty.CalendarEventTiming>? periods =
        const _isc.$UndefinedList<_ieswiaty.CalendarEventTiming>(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOpening &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence) &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
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
                  other.textParameters,
                  textParameters,
                ) ||
                other.textParameters == textParameters) &&
            const _iss.DeepCollectionEquality().equals(
              other.extensions,
              extensions,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.categoryGroups,
              categoryGroups,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.contacts,
              contacts,
            ) &&
            (identical(
                  other.protocolUid,
                  protocolUid,
                ) ||
                other.protocolUid == protocolUid) &&
            const _iss.DeepCollectionEquality().equals(
              other.periods,
              periods,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      uid,
      timing,
      recurrence,
      summary,
      description,
      location,
      const _iss.DeepCollectionEquality().hash(categories),
      const _iss.DeepCollectionEquality().hash(comments),
      textParameters,
      const _iss.DeepCollectionEquality().hash(extensions),
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(contacts),
      protocolUid,
      const _iss.DeepCollectionEquality().hash(periods),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
      if (textParameters != null) 'textParameters': textParameters?.toJson(),
      if (extensions != null)
        'extensions': extensions?.toJson(valueToJson: (v) => v.toJson()),
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJson()),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (periods != null)
        'periods': periods?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityOpening',
      if (uid != null) 'uid': uid?.toJson(),
      'timing': timing.toJsonForProtocol(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (categories != null) 'categories': categories?.toJson(),
      if (comments != null) 'comments': comments?.toJson(),
      if (textParameters != null)
        'textParameters': textParameters?.toJsonForProtocol(),
      if (extensions != null)
        'extensions': extensions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (periods != null)
        'periods': periods?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarAvailabilityOpening$recurrence
    extends _isc.UndefinedSentinel
    implements _iqxs44bf.CalendarEventRecurrence {
  const _UndefinedCalendarAvailabilityOpening$recurrence();
}

class _UndefinedCalendarAvailabilityOpening$textParameters
    extends _isc.UndefinedSentinel
    implements _ipbm7ji7.CalendarAvailabilityTextParameters {
  const _UndefinedCalendarAvailabilityOpening$textParameters();
}

class _CalendarAvailabilityOpeningImpl extends CalendarAvailabilityOpening {
  const _CalendarAvailabilityOpeningImpl({
    _isc.UuidValue? uid,
    required _ieswiaty.CalendarEventTiming timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? summary,
    String? description,
    String? location,
    List<String>? categories,
    List<String>? comments,
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
    String? protocolUid,
    List<_ieswiaty.CalendarEventTiming>? periods,
  }) : super._(
         uid: uid,
         timing: timing,
         recurrence: recurrence,
         summary: summary,
         description: description,
         location: location,
         categories: categories,
         comments: comments,
         textParameters: textParameters,
         extensions: extensions,
         categoryGroups: categoryGroups,
         contacts: contacts,
         protocolUid: protocolUid,
         periods: periods,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOpening]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOpening copyWith({
    _isc.UuidValue? uid = const _isc.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? timing,
    _iqxs44bf.CalendarEventRecurrence? recurrence =
        const _UndefinedCalendarAvailabilityOpening$recurrence(),
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    List<String>? categories = const _isc.$UndefinedList<String>(),
    List<String>? comments = const _isc.$UndefinedList<String>(),
    _ipbm7ji7.CalendarAvailabilityTextParameters? textParameters =
        const _UndefinedCalendarAvailabilityOpening$textParameters(),
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions =
        const _isc.$UndefinedList<_ip5gybl4.CalendarAvailabilityExtension>(),
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categoryGroups =
        const _isc.$UndefinedList<
          _iywbqexh.CalendarAvailabilityCategoryGroup
        >(),
    List<_itw42wa3.CalendarAvailabilityText>? contacts =
        const _isc.$UndefinedList<_itw42wa3.CalendarAvailabilityText>(),
    Object? protocolUid = _Undefined,
    List<_ieswiaty.CalendarEventTiming>? periods =
        const _isc.$UndefinedList<_ieswiaty.CalendarEventTiming>(),
  }) {
    return CalendarAvailabilityOpening(
      uid: uid is _isc.UndefinedSentinel ? this.uid : uid,
      timing: timing ?? this.timing.copyWith(),
      recurrence: recurrence is _isc.UndefinedSentinel
          ? this.recurrence?.copyWith()
          : recurrence,
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      categories: categories is _isc.UndefinedSentinel
          ? this.categories?.map((e0) => e0).toList()
          : categories,
      comments: comments is _isc.UndefinedSentinel
          ? this.comments?.map((e0) => e0).toList()
          : comments,
      textParameters: textParameters is _isc.UndefinedSentinel
          ? this.textParameters?.copyWith()
          : textParameters,
      extensions: extensions is _isc.UndefinedSentinel
          ? this.extensions?.map((e0) => e0.copyWith()).toList()
          : extensions,
      categoryGroups: categoryGroups is _isc.UndefinedSentinel
          ? this.categoryGroups?.map((e0) => e0.copyWith()).toList()
          : categoryGroups,
      contacts: contacts is _isc.UndefinedSentinel
          ? this.contacts?.map((e0) => e0.copyWith()).toList()
          : contacts,
      protocolUid: protocolUid is String? ? protocolUid : this.protocolUid,
      periods: periods is _isc.UndefinedSentinel
          ? this.periods?.map((e0) => e0.copyWith()).toList()
          : periods,
    );
  }
}
