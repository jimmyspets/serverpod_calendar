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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_task_source_alarm.dart' as _i00avof0;
import 'calendar_task_source_attachment.dart' as _iuzk4pe3;
import 'calendar_task_source_category_group.dart' as _iic8eifm;
import 'calendar_task_source_participant.dart' as _iw6fme2j;
import 'calendar_task_source_relationship.dart' as _izyrs4yl;
import 'calendar_task_source_text.dart' as _i9mnuab5;

@_is.immutable
abstract class CalendarTaskSourceMetadata
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceMetadata._({
    this.url,
    this.classification,
    required this.categoryGroups,
    required this.comments,
    required this.contacts,
    this.organizer,
    required this.attendees,
    required this.relationships,
    required this.attachments,
    required this.alarms,
  });

  const factory CalendarTaskSourceMetadata({
    String? url,
    String? classification,
    required List<_iic8eifm.CalendarTaskSourceCategoryGroup> categoryGroups,
    required List<_i9mnuab5.CalendarTaskSourceText> comments,
    required List<_i9mnuab5.CalendarTaskSourceText> contacts,
    _iw6fme2j.CalendarTaskSourceParticipant? organizer,
    required List<_iw6fme2j.CalendarTaskSourceParticipant> attendees,
    required List<_izyrs4yl.CalendarTaskSourceRelationship> relationships,
    required List<_iuzk4pe3.CalendarTaskSourceAttachment> attachments,
    required List<_i00avof0.CalendarTaskSourceAlarm> alarms,
  }) = _CalendarTaskSourceMetadataImpl;

  factory CalendarTaskSourceMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceMetadata(
      url: jsonSerialization['url'] as String?,
      classification: jsonSerialization['classification'] as String?,
      categoryGroups: _ix00hwbf.Protocol()
          .deserialize<List<_iic8eifm.CalendarTaskSourceCategoryGroup>>(
            jsonSerialization['categoryGroups'],
          ),
      comments: _ix00hwbf.Protocol()
          .deserialize<List<_i9mnuab5.CalendarTaskSourceText>>(
            jsonSerialization['comments'],
          ),
      contacts: _ix00hwbf.Protocol()
          .deserialize<List<_i9mnuab5.CalendarTaskSourceText>>(
            jsonSerialization['contacts'],
          ),
      organizer: jsonSerialization['organizer'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_iw6fme2j.CalendarTaskSourceParticipant>(
                  jsonSerialization['organizer'],
                ),
      attendees: _ix00hwbf.Protocol()
          .deserialize<List<_iw6fme2j.CalendarTaskSourceParticipant>>(
            jsonSerialization['attendees'],
          ),
      relationships: _ix00hwbf.Protocol()
          .deserialize<List<_izyrs4yl.CalendarTaskSourceRelationship>>(
            jsonSerialization['relationships'],
          ),
      attachments: _ix00hwbf.Protocol()
          .deserialize<List<_iuzk4pe3.CalendarTaskSourceAttachment>>(
            jsonSerialization['attachments'],
          ),
      alarms: _ix00hwbf.Protocol()
          .deserialize<List<_i00avof0.CalendarTaskSourceAlarm>>(
            jsonSerialization['alarms'],
          ),
    );
  }

  final String? url;

  final String? classification;

  final List<_iic8eifm.CalendarTaskSourceCategoryGroup> categoryGroups;

  final List<_i9mnuab5.CalendarTaskSourceText> comments;

  final List<_i9mnuab5.CalendarTaskSourceText> contacts;

  final _iw6fme2j.CalendarTaskSourceParticipant? organizer;

  final List<_iw6fme2j.CalendarTaskSourceParticipant> attendees;

  final List<_izyrs4yl.CalendarTaskSourceRelationship> relationships;

  final List<_iuzk4pe3.CalendarTaskSourceAttachment> attachments;

  final List<_i00avof0.CalendarTaskSourceAlarm> alarms;

  /// Returns a shallow copy of this [CalendarTaskSourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceMetadata copyWith({
    String? url,
    String? classification,
    List<_iic8eifm.CalendarTaskSourceCategoryGroup>? categoryGroups,
    List<_i9mnuab5.CalendarTaskSourceText>? comments,
    List<_i9mnuab5.CalendarTaskSourceText>? contacts,
    _iw6fme2j.CalendarTaskSourceParticipant? organizer,
    List<_iw6fme2j.CalendarTaskSourceParticipant>? attendees,
    List<_izyrs4yl.CalendarTaskSourceRelationship>? relationships,
    List<_iuzk4pe3.CalendarTaskSourceAttachment>? attachments,
    List<_i00avof0.CalendarTaskSourceAlarm>? alarms,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceMetadata &&
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
            const _iss.DeepCollectionEquality().equals(
              other.categoryGroups,
              categoryGroups,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.comments,
              comments,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.contacts,
              contacts,
            ) &&
            (identical(
                  other.organizer,
                  organizer,
                ) ||
                other.organizer == organizer) &&
            const _iss.DeepCollectionEquality().equals(
              other.attendees,
              attendees,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.relationships,
              relationships,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.attachments,
              attachments,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.alarms,
              alarms,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      url,
      classification,
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(comments),
      const _iss.DeepCollectionEquality().hash(contacts),
      organizer,
      const _iss.DeepCollectionEquality().hash(attendees),
      const _iss.DeepCollectionEquality().hash(relationships),
      const _iss.DeepCollectionEquality().hash(attachments),
      const _iss.DeepCollectionEquality().hash(alarms),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceMetadata',
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      'categoryGroups': categoryGroups.toJson(valueToJson: (v) => v.toJson()),
      'comments': comments.toJson(valueToJson: (v) => v.toJson()),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
      if (organizer != null) 'organizer': organizer?.toJson(),
      'attendees': attendees.toJson(valueToJson: (v) => v.toJson()),
      'relationships': relationships.toJson(valueToJson: (v) => v.toJson()),
      'attachments': attachments.toJson(valueToJson: (v) => v.toJson()),
      'alarms': alarms.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskSourceMetadataImpl extends CalendarTaskSourceMetadata {
  const _CalendarTaskSourceMetadataImpl({
    String? url,
    String? classification,
    required List<_iic8eifm.CalendarTaskSourceCategoryGroup> categoryGroups,
    required List<_i9mnuab5.CalendarTaskSourceText> comments,
    required List<_i9mnuab5.CalendarTaskSourceText> contacts,
    _iw6fme2j.CalendarTaskSourceParticipant? organizer,
    required List<_iw6fme2j.CalendarTaskSourceParticipant> attendees,
    required List<_izyrs4yl.CalendarTaskSourceRelationship> relationships,
    required List<_iuzk4pe3.CalendarTaskSourceAttachment> attachments,
    required List<_i00avof0.CalendarTaskSourceAlarm> alarms,
  }) : super._(
         url: url,
         classification: classification,
         categoryGroups: categoryGroups,
         comments: comments,
         contacts: contacts,
         organizer: organizer,
         attendees: attendees,
         relationships: relationships,
         attachments: attachments,
         alarms: alarms,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceMetadata copyWith({
    Object? url = _Undefined,
    Object? classification = _Undefined,
    List<_iic8eifm.CalendarTaskSourceCategoryGroup>? categoryGroups,
    List<_i9mnuab5.CalendarTaskSourceText>? comments,
    List<_i9mnuab5.CalendarTaskSourceText>? contacts,
    Object? organizer = _Undefined,
    List<_iw6fme2j.CalendarTaskSourceParticipant>? attendees,
    List<_izyrs4yl.CalendarTaskSourceRelationship>? relationships,
    List<_iuzk4pe3.CalendarTaskSourceAttachment>? attachments,
    List<_i00avof0.CalendarTaskSourceAlarm>? alarms,
  }) {
    return CalendarTaskSourceMetadata(
      url: url is String? ? url : this.url,
      classification: classification is String?
          ? classification
          : this.classification,
      categoryGroups:
          categoryGroups ??
          this.categoryGroups.map((e0) => e0.copyWith()).toList(),
      comments: comments ?? this.comments.map((e0) => e0.copyWith()).toList(),
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
      organizer: organizer is _iw6fme2j.CalendarTaskSourceParticipant?
          ? organizer
          : this.organizer?.copyWith(),
      attendees:
          attendees ?? this.attendees.map((e0) => e0.copyWith()).toList(),
      relationships:
          relationships ??
          this.relationships.map((e0) => e0.copyWith()).toList(),
      attachments:
          attachments ?? this.attachments.map((e0) => e0.copyWith()).toList(),
      alarms: alarms ?? this.alarms.map((e0) => e0.copyWith()).toList(),
    );
  }
}
