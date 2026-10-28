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
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_item_category_group.dart' as _i3iolgr8;
import 'calendar_item_comment.dart' as _itx19m90;
import 'calendar_task_assignee.dart' as _ih5e3u6u;
import 'calendar_task_field_group.dart' as _isemqyyv;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_protocol_version.dart' as _iz9t6x1i;
import 'calendar_task_timing.dart' as _i9h8y8lg;

@_isc.immutable
abstract class CalendarTaskView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarTaskView._({
    required this.id,
    required this.calendarId,
    required this.revision,
    required this.disclosedGroups,
    this.summary,
    this.description,
    this.location,
    this.timing,
    this.priority,
    this.progress,
    this.assignees,
    this.protocolUid,
    this.protocolVersion,
    this.recurrence,
    this.url,
    this.classification,
    this.categoryGroups,
    this.comments,
  });

  const factory CalendarTaskView({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _i9h8y8lg.CalendarTaskTiming? timing,
    int? priority,
    _ikcsq95s.CalendarTaskProgress? progress,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
    String? protocolUid,
    _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  }) = _CalendarTaskViewImpl;

  factory CalendarTaskView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      disclosedGroups: _ie4a1wrz.Protocol()
          .deserialize<List<_isemqyyv.CalendarTaskFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
      summary: jsonSerialization['summary'] as String?,
      description: jsonSerialization['description'] as String?,
      location: jsonSerialization['location'] as String?,
      timing: jsonSerialization['timing'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i9h8y8lg.CalendarTaskTiming>(
              jsonSerialization['timing'],
            ),
      priority: jsonSerialization['priority'] as int?,
      progress: jsonSerialization['progress'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ikcsq95s.CalendarTaskProgress>(
              jsonSerialization['progress'],
            ),
      assignees: jsonSerialization['assignees'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_ih5e3u6u.CalendarTaskAssignee>>(
                  jsonSerialization['assignees'],
                ),
      protocolUid: jsonSerialization['protocolUid'] as String?,
      protocolVersion: jsonSerialization['protocolVersion'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_iz9t6x1i.CalendarTaskProtocolVersion>(
                  jsonSerialization['protocolVersion'],
                ),
      recurrence: jsonSerialization['recurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_iqxs44bf.CalendarEventRecurrence>(
              jsonSerialization['recurrence'],
            ),
      url: jsonSerialization['url'] as String?,
      classification: jsonSerialization['classification'] as String?,
      categoryGroups: jsonSerialization['categoryGroups'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_i3iolgr8.CalendarItemCategoryGroup>>(
                  jsonSerialization['categoryGroups'],
                ),
      comments: jsonSerialization['comments'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_itx19m90.CalendarItemComment>>(
                  jsonSerialization['comments'],
                ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue calendarId;

  final int revision;

  final List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups;

  final String? summary;

  final String? description;

  final String? location;

  final _i9h8y8lg.CalendarTaskTiming? timing;

  final int? priority;

  final _ikcsq95s.CalendarTaskProgress? progress;

  final List<_ih5e3u6u.CalendarTaskAssignee>? assignees;

  final String? protocolUid;

  final _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion;

  final _iqxs44bf.CalendarEventRecurrence? recurrence;

  final String? url;

  final String? classification;

  final List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups;

  final List<_itx19m90.CalendarItemComment>? comments;

  /// Returns a shallow copy of this [CalendarTaskView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarTaskView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    List<_isemqyyv.CalendarTaskFieldGroup>? disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _i9h8y8lg.CalendarTaskTiming? timing,
    int? priority,
    _ikcsq95s.CalendarTaskProgress? progress,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
    String? protocolUid,
    _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskView &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            const _iss.DeepCollectionEquality().equals(
              other.disclosedGroups,
              disclosedGroups,
            ) &&
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
            (identical(
                  other.timing,
                  timing,
                ) ||
                other.timing == timing) &&
            (identical(
                  other.priority,
                  priority,
                ) ||
                other.priority == priority) &&
            (identical(
                  other.progress,
                  progress,
                ) ||
                other.progress == progress) &&
            const _iss.DeepCollectionEquality().equals(
              other.assignees,
              assignees,
            ) &&
            (identical(
                  other.protocolUid,
                  protocolUid,
                ) ||
                other.protocolUid == protocolUid) &&
            (identical(
                  other.protocolVersion,
                  protocolVersion,
                ) ||
                other.protocolVersion == protocolVersion) &&
            (identical(
                  other.recurrence,
                  recurrence,
                ) ||
                other.recurrence == recurrence) &&
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
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      calendarId,
      revision,
      const _iss.DeepCollectionEquality().hash(disclosedGroups),
      summary,
      description,
      location,
      timing,
      priority,
      progress,
      const _iss.DeepCollectionEquality().hash(assignees),
      protocolUid,
      protocolVersion,
      recurrence,
      url,
      classification,
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(comments),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (timing != null) 'timing': timing?.toJson(),
      if (priority != null) 'priority': priority,
      if (progress != null) 'progress': progress?.toJson(),
      if (assignees != null)
        'assignees': assignees?.toJson(valueToJson: (v) => v.toJson()),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (protocolVersion != null) 'protocolVersion': protocolVersion?.toJson(),
      if (recurrence != null) 'recurrence': recurrence?.toJson(),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (summary != null) 'summary': summary,
      if (description != null) 'description': description,
      if (location != null) 'location': location,
      if (timing != null) 'timing': timing?.toJsonForProtocol(),
      if (priority != null) 'priority': priority,
      if (progress != null) 'progress': progress?.toJsonForProtocol(),
      if (assignees != null)
        'assignees': assignees?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (protocolUid != null) 'protocolUid': protocolUid,
      if (protocolVersion != null)
        'protocolVersion': protocolVersion?.toJsonForProtocol(),
      if (recurrence != null) 'recurrence': recurrence?.toJsonForProtocol(),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskViewImpl extends CalendarTaskView {
  const _CalendarTaskViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups,
    String? summary,
    String? description,
    String? location,
    _i9h8y8lg.CalendarTaskTiming? timing,
    int? priority,
    _ikcsq95s.CalendarTaskProgress? progress,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
    String? protocolUid,
    _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion,
    _iqxs44bf.CalendarEventRecurrence? recurrence,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  }) : super._(
         id: id,
         calendarId: calendarId,
         revision: revision,
         disclosedGroups: disclosedGroups,
         summary: summary,
         description: description,
         location: location,
         timing: timing,
         priority: priority,
         progress: progress,
         assignees: assignees,
         protocolUid: protocolUid,
         protocolVersion: protocolVersion,
         recurrence: recurrence,
         url: url,
         classification: classification,
         categoryGroups: categoryGroups,
         comments: comments,
       );

  /// Returns a shallow copy of this [CalendarTaskView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarTaskView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    List<_isemqyyv.CalendarTaskFieldGroup>? disclosedGroups,
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? timing = _Undefined,
    Object? priority = _Undefined,
    Object? progress = _Undefined,
    Object? assignees = _Undefined,
    Object? protocolUid = _Undefined,
    Object? protocolVersion = _Undefined,
    Object? recurrence = _Undefined,
    Object? url = _Undefined,
    Object? classification = _Undefined,
    Object? categoryGroups = _Undefined,
    Object? comments = _Undefined,
  }) {
    return CalendarTaskView(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
      summary: summary is String? ? summary : this.summary,
      description: description is String? ? description : this.description,
      location: location is String? ? location : this.location,
      timing: timing is _i9h8y8lg.CalendarTaskTiming?
          ? timing
          : this.timing?.copyWith(),
      priority: priority is int? ? priority : this.priority,
      progress: progress is _ikcsq95s.CalendarTaskProgress?
          ? progress
          : this.progress?.copyWith(),
      assignees: assignees is List<_ih5e3u6u.CalendarTaskAssignee>?
          ? assignees
          : this.assignees?.map((e0) => e0.copyWith()).toList(),
      protocolUid: protocolUid is String? ? protocolUid : this.protocolUid,
      protocolVersion: protocolVersion is _iz9t6x1i.CalendarTaskProtocolVersion?
          ? protocolVersion
          : this.protocolVersion?.copyWith(),
      recurrence: recurrence is _iqxs44bf.CalendarEventRecurrence?
          ? recurrence
          : this.recurrence?.copyWith(),
      url: url is String? ? url : this.url,
      classification: classification is String?
          ? classification
          : this.classification,
      categoryGroups:
          categoryGroups is List<_i3iolgr8.CalendarItemCategoryGroup>?
          ? categoryGroups
          : this.categoryGroups?.map((e0) => e0.copyWith()).toList(),
      comments: comments is List<_itx19m90.CalendarItemComment>?
          ? comments
          : this.comments?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
