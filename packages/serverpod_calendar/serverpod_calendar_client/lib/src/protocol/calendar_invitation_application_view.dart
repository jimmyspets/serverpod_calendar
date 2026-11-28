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
import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_protocol_version.dart' as _iblfo3t0;
import 'calendar_invitation_apply_receipt.dart' as _ic2yh4ry;

@_isc.immutable
abstract class CalendarInvitationApplicationView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationApplicationView._({
    required this.linkId,
    required this.invitationId,
    required this.calendarId,
    required this.eventId,
    required this.calendarRevision,
    required this.eventRevision,
    required this.applicationRevision,
    required this.acceptedInvitationId,
    required this.acceptedSourceId,
    this.acceptedSequence,
    required this.acceptedStamp,
    required this.acceptedAt,
    required this.hasLocalChanges,
    required this.currentContent,
    required this.currentVersion,
    this.incomingSourceId,
    this.invitationRevision,
    this.incomingContent,
    this.incomingSourceText,
    required this.canApply,
    this.latestResult,
  });

  const factory CalendarInvitationApplicationView({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _isc.UuidValue acceptedInvitationId,
    required _isc.UuidValue acceptedSourceId,
    int? acceptedSequence,
    required DateTime acceptedStamp,
    required DateTime acceptedAt,
    required bool hasLocalChanges,
    required _id4cvk34.CalendarEventContent currentContent,
    required _iblfo3t0.CalendarEventProtocolVersion currentVersion,
    _isc.UuidValue? incomingSourceId,
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent,
    String? incomingSourceText,
    required bool canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult,
  }) = _CalendarInvitationApplicationViewImpl;

  factory CalendarInvitationApplicationView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplicationView(
      linkId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      invitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      calendarRevision: jsonSerialization['calendarRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      applicationRevision: jsonSerialization['applicationRevision'] as int,
      acceptedInvitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['acceptedInvitationId'],
      ),
      acceptedSourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['acceptedSourceId'],
      ),
      acceptedSequence: jsonSerialization['acceptedSequence'] as int?,
      acceptedStamp: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptedStamp'],
      ),
      acceptedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptedAt'],
      ),
      hasLocalChanges: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
      ),
      currentContent: _ie4a1wrz.Protocol()
          .deserialize<_id4cvk34.CalendarEventContent>(
            jsonSerialization['currentContent'],
          ),
      currentVersion: _ie4a1wrz.Protocol()
          .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
            jsonSerialization['currentVersion'],
          ),
      incomingSourceId: jsonSerialization['incomingSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['incomingSourceId'],
            ),
      invitationRevision: jsonSerialization['invitationRevision'] as int?,
      incomingContent: jsonSerialization['incomingContent'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
              jsonSerialization['incomingContent'],
            ),
      incomingSourceText: jsonSerialization['incomingSourceText'] as String?,
      canApply: _isc.BoolJsonExtension.fromJson(jsonSerialization['canApply']),
      latestResult: jsonSerialization['latestResult'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_ic2yh4ry.CalendarInvitationApplyReceipt>(
                  jsonSerialization['latestResult'],
                ),
    );
  }

  final _isc.UuidValue linkId;

  final _isc.UuidValue invitationId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int calendarRevision;

  final int eventRevision;

  final int applicationRevision;

  final _isc.UuidValue acceptedInvitationId;

  final _isc.UuidValue acceptedSourceId;

  final int? acceptedSequence;

  final DateTime acceptedStamp;

  final DateTime acceptedAt;

  final bool hasLocalChanges;

  final _id4cvk34.CalendarEventContent currentContent;

  final _iblfo3t0.CalendarEventProtocolVersion currentVersion;

  final _isc.UuidValue? incomingSourceId;

  final int? invitationRevision;

  final _id4cvk34.CalendarEventContent? incomingContent;

  final String? incomingSourceText;

  final bool canApply;

  final _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult;

  /// Returns a shallow copy of this [CalendarInvitationApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _isc.UuidValue? acceptedInvitationId,
    _isc.UuidValue? acceptedSourceId,
    int? acceptedSequence,
    DateTime? acceptedStamp,
    DateTime? acceptedAt,
    bool? hasLocalChanges,
    _id4cvk34.CalendarEventContent? currentContent,
    _iblfo3t0.CalendarEventProtocolVersion? currentVersion,
    _isc.UuidValue? incomingSourceId,
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent,
    String? incomingSourceText,
    bool? canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationApplicationView &&
            (identical(
                  other.linkId,
                  linkId,
                ) ||
                other.linkId == linkId) &&
            (identical(
                  other.invitationId,
                  invitationId,
                ) ||
                other.invitationId == invitationId) &&
            (identical(
                  other.calendarId,
                  calendarId,
                ) ||
                other.calendarId == calendarId) &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.calendarRevision,
                  calendarRevision,
                ) ||
                other.calendarRevision == calendarRevision) &&
            (identical(
                  other.eventRevision,
                  eventRevision,
                ) ||
                other.eventRevision == eventRevision) &&
            (identical(
                  other.applicationRevision,
                  applicationRevision,
                ) ||
                other.applicationRevision == applicationRevision) &&
            (identical(
                  other.acceptedInvitationId,
                  acceptedInvitationId,
                ) ||
                other.acceptedInvitationId == acceptedInvitationId) &&
            (identical(
                  other.acceptedSourceId,
                  acceptedSourceId,
                ) ||
                other.acceptedSourceId == acceptedSourceId) &&
            (identical(
                  other.acceptedSequence,
                  acceptedSequence,
                ) ||
                other.acceptedSequence == acceptedSequence) &&
            (identical(
                  other.acceptedStamp,
                  acceptedStamp,
                ) ||
                other.acceptedStamp == acceptedStamp) &&
            (identical(
                  other.acceptedAt,
                  acceptedAt,
                ) ||
                other.acceptedAt == acceptedAt) &&
            (identical(
                  other.hasLocalChanges,
                  hasLocalChanges,
                ) ||
                other.hasLocalChanges == hasLocalChanges) &&
            (identical(
                  other.currentContent,
                  currentContent,
                ) ||
                other.currentContent == currentContent) &&
            (identical(
                  other.currentVersion,
                  currentVersion,
                ) ||
                other.currentVersion == currentVersion) &&
            (identical(
                  other.incomingSourceId,
                  incomingSourceId,
                ) ||
                other.incomingSourceId == incomingSourceId) &&
            (identical(
                  other.invitationRevision,
                  invitationRevision,
                ) ||
                other.invitationRevision == invitationRevision) &&
            (identical(
                  other.incomingContent,
                  incomingContent,
                ) ||
                other.incomingContent == incomingContent) &&
            (identical(
                  other.incomingSourceText,
                  incomingSourceText,
                ) ||
                other.incomingSourceText == incomingSourceText) &&
            (identical(
                  other.canApply,
                  canApply,
                ) ||
                other.canApply == canApply) &&
            (identical(
                  other.latestResult,
                  latestResult,
                ) ||
                other.latestResult == latestResult);
  }

  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType,
      linkId,
      invitationId,
      calendarId,
      eventId,
      calendarRevision,
      eventRevision,
      applicationRevision,
      acceptedInvitationId,
      acceptedSourceId,
      acceptedSequence,
      acceptedStamp,
      acceptedAt,
      hasLocalChanges,
      currentContent,
      currentVersion,
      incomingSourceId,
      invitationRevision,
      incomingContent,
      incomingSourceText,
      canApply,
      latestResult,
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'acceptedInvitationId': acceptedInvitationId.toJson(),
      'acceptedSourceId': acceptedSourceId.toJson(),
      if (acceptedSequence != null) 'acceptedSequence': acceptedSequence,
      'acceptedStamp': acceptedStamp.toJson(),
      'acceptedAt': acceptedAt.toJson(),
      'hasLocalChanges': hasLocalChanges,
      'currentContent': currentContent.toJson(),
      'currentVersion': currentVersion.toJson(),
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      if (invitationRevision != null) 'invitationRevision': invitationRevision,
      if (incomingContent != null) 'incomingContent': incomingContent?.toJson(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      'canApply': canApply,
      if (latestResult != null) 'latestResult': latestResult?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'acceptedInvitationId': acceptedInvitationId.toJson(),
      'acceptedSourceId': acceptedSourceId.toJson(),
      if (acceptedSequence != null) 'acceptedSequence': acceptedSequence,
      'acceptedStamp': acceptedStamp.toJson(),
      'acceptedAt': acceptedAt.toJson(),
      'hasLocalChanges': hasLocalChanges,
      'currentContent': currentContent.toJsonForProtocol(),
      'currentVersion': currentVersion.toJsonForProtocol(),
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      if (invitationRevision != null) 'invitationRevision': invitationRevision,
      if (incomingContent != null)
        'incomingContent': incomingContent?.toJsonForProtocol(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      'canApply': canApply,
      if (latestResult != null)
        'latestResult': latestResult?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationApplicationViewImpl
    extends CalendarInvitationApplicationView {
  const _CalendarInvitationApplicationViewImpl({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _isc.UuidValue acceptedInvitationId,
    required _isc.UuidValue acceptedSourceId,
    int? acceptedSequence,
    required DateTime acceptedStamp,
    required DateTime acceptedAt,
    required bool hasLocalChanges,
    required _id4cvk34.CalendarEventContent currentContent,
    required _iblfo3t0.CalendarEventProtocolVersion currentVersion,
    _isc.UuidValue? incomingSourceId,
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent,
    String? incomingSourceText,
    required bool canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult,
  }) : super._(
         linkId: linkId,
         invitationId: invitationId,
         calendarId: calendarId,
         eventId: eventId,
         calendarRevision: calendarRevision,
         eventRevision: eventRevision,
         applicationRevision: applicationRevision,
         acceptedInvitationId: acceptedInvitationId,
         acceptedSourceId: acceptedSourceId,
         acceptedSequence: acceptedSequence,
         acceptedStamp: acceptedStamp,
         acceptedAt: acceptedAt,
         hasLocalChanges: hasLocalChanges,
         currentContent: currentContent,
         currentVersion: currentVersion,
         incomingSourceId: incomingSourceId,
         invitationRevision: invitationRevision,
         incomingContent: incomingContent,
         incomingSourceText: incomingSourceText,
         canApply: canApply,
         latestResult: latestResult,
       );

  /// Returns a shallow copy of this [CalendarInvitationApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _isc.UuidValue? acceptedInvitationId,
    _isc.UuidValue? acceptedSourceId,
    Object? acceptedSequence = _Undefined,
    DateTime? acceptedStamp,
    DateTime? acceptedAt,
    bool? hasLocalChanges,
    _id4cvk34.CalendarEventContent? currentContent,
    _iblfo3t0.CalendarEventProtocolVersion? currentVersion,
    Object? incomingSourceId = _Undefined,
    Object? invitationRevision = _Undefined,
    Object? incomingContent = _Undefined,
    Object? incomingSourceText = _Undefined,
    bool? canApply,
    Object? latestResult = _Undefined,
  }) {
    return CalendarInvitationApplicationView(
      linkId: linkId ?? this.linkId,
      invitationId: invitationId ?? this.invitationId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      calendarRevision: calendarRevision ?? this.calendarRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      applicationRevision: applicationRevision ?? this.applicationRevision,
      acceptedInvitationId: acceptedInvitationId ?? this.acceptedInvitationId,
      acceptedSourceId: acceptedSourceId ?? this.acceptedSourceId,
      acceptedSequence: acceptedSequence is int?
          ? acceptedSequence
          : this.acceptedSequence,
      acceptedStamp: acceptedStamp ?? this.acceptedStamp,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      currentContent: currentContent ?? this.currentContent.copyWith(),
      currentVersion: currentVersion ?? this.currentVersion.copyWith(),
      incomingSourceId: incomingSourceId is _isc.UuidValue?
          ? incomingSourceId
          : this.incomingSourceId,
      invitationRevision: invitationRevision is int?
          ? invitationRevision
          : this.invitationRevision,
      incomingContent: incomingContent is _id4cvk34.CalendarEventContent?
          ? incomingContent
          : this.incomingContent?.copyWith(),
      incomingSourceText: incomingSourceText is String?
          ? incomingSourceText
          : this.incomingSourceText,
      canApply: canApply ?? this.canApply,
      latestResult: latestResult is _ic2yh4ry.CalendarInvitationApplyReceipt?
          ? latestResult
          : this.latestResult?.copyWith(),
    );
  }
}
