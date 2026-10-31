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
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_invitation_occurrence_apply_receipt.dart' as _iyajy5op;
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_isc.immutable
abstract class CalendarInvitationOccurrenceApplicationView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationOccurrenceApplicationView._({
    required this.linkId,
    required this.invitationId,
    required this.calendarId,
    required this.eventId,
    required this.calendarRevision,
    required this.eventRevision,
    required this.applicationRevision,
    required this.occurrenceRevision,
    required this.originalStart,
    required this.hasLocalChanges,
    required this.acceptedVersion,
    required this.acceptedKind,
    this.currentOccurrence,
    this.proposedOccurrence,
    this.incomingKind,
    this.incomingSourceId,
    required this.invitationRevision,
    this.incomingVersion,
    this.incomingSourceText,
    this.acceptedSourceText,
    required this.canApply,
    this.latestResult,
  });

  const factory CalendarInvitationOccurrenceApplicationView({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required int occurrenceRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required bool hasLocalChanges,
    required _iblfo3t0.CalendarEventProtocolVersion acceptedVersion,
    required _ilccsff7.CalendarInvitationSourceKind acceptedKind,
    _id4cvk34.CalendarEventContent? currentOccurrence,
    _id4cvk34.CalendarEventContent? proposedOccurrence,
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    _isc.UuidValue? incomingSourceId,
    required int invitationRevision,
    _iblfo3t0.CalendarEventProtocolVersion? incomingVersion,
    String? incomingSourceText,
    String? acceptedSourceText,
    required bool canApply,
    _iyajy5op.CalendarInvitationOccurrenceApplyReceipt? latestResult,
  }) = _CalendarInvitationOccurrenceApplicationViewImpl;

  factory CalendarInvitationOccurrenceApplicationView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationOccurrenceApplicationView(
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
      occurrenceRevision: jsonSerialization['occurrenceRevision'] as int,
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      hasLocalChanges: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
      ),
      acceptedVersion: _ie4a1wrz.Protocol()
          .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
            jsonSerialization['acceptedVersion'],
          ),
      acceptedKind: _ilccsff7.CalendarInvitationSourceKind.fromJson(
        (jsonSerialization['acceptedKind'] as String),
      ),
      currentOccurrence: jsonSerialization['currentOccurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
              jsonSerialization['currentOccurrence'],
            ),
      proposedOccurrence: jsonSerialization['proposedOccurrence'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
              jsonSerialization['proposedOccurrence'],
            ),
      incomingKind: jsonSerialization['incomingKind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['incomingKind'] as String),
            ),
      incomingSourceId: jsonSerialization['incomingSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['incomingSourceId'],
            ),
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      incomingVersion: jsonSerialization['incomingVersion'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_iblfo3t0.CalendarEventProtocolVersion>(
                  jsonSerialization['incomingVersion'],
                ),
      incomingSourceText: jsonSerialization['incomingSourceText'] as String?,
      acceptedSourceText: jsonSerialization['acceptedSourceText'] as String?,
      canApply: _isc.BoolJsonExtension.fromJson(jsonSerialization['canApply']),
      latestResult: jsonSerialization['latestResult'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<
              _iyajy5op.CalendarInvitationOccurrenceApplyReceipt
            >(jsonSerialization['latestResult']),
    );
  }

  final _isc.UuidValue linkId;

  final _isc.UuidValue invitationId;

  final _isc.UuidValue calendarId;

  final _isc.UuidValue eventId;

  final int calendarRevision;

  final int eventRevision;

  final int applicationRevision;

  final int occurrenceRevision;

  final _ieswiaty.CalendarEventTiming originalStart;

  final bool hasLocalChanges;

  final _iblfo3t0.CalendarEventProtocolVersion acceptedVersion;

  final _ilccsff7.CalendarInvitationSourceKind acceptedKind;

  final _id4cvk34.CalendarEventContent? currentOccurrence;

  final _id4cvk34.CalendarEventContent? proposedOccurrence;

  final _ilccsff7.CalendarInvitationSourceKind? incomingKind;

  final _isc.UuidValue? incomingSourceId;

  final int invitationRevision;

  final _iblfo3t0.CalendarEventProtocolVersion? incomingVersion;

  final String? incomingSourceText;

  final String? acceptedSourceText;

  final bool canApply;

  final _iyajy5op.CalendarInvitationOccurrenceApplyReceipt? latestResult;

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationOccurrenceApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    int? occurrenceRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? hasLocalChanges,
    _iblfo3t0.CalendarEventProtocolVersion? acceptedVersion,
    _ilccsff7.CalendarInvitationSourceKind? acceptedKind,
    _id4cvk34.CalendarEventContent? currentOccurrence,
    _id4cvk34.CalendarEventContent? proposedOccurrence,
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    _isc.UuidValue? incomingSourceId,
    int? invitationRevision,
    _iblfo3t0.CalendarEventProtocolVersion? incomingVersion,
    String? incomingSourceText,
    String? acceptedSourceText,
    bool? canApply,
    _iyajy5op.CalendarInvitationOccurrenceApplyReceipt? latestResult,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationOccurrenceApplicationView &&
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
                  other.occurrenceRevision,
                  occurrenceRevision,
                ) ||
                other.occurrenceRevision == occurrenceRevision) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.hasLocalChanges,
                  hasLocalChanges,
                ) ||
                other.hasLocalChanges == hasLocalChanges) &&
            (identical(
                  other.acceptedVersion,
                  acceptedVersion,
                ) ||
                other.acceptedVersion == acceptedVersion) &&
            (identical(
                  other.acceptedKind,
                  acceptedKind,
                ) ||
                other.acceptedKind == acceptedKind) &&
            (identical(
                  other.currentOccurrence,
                  currentOccurrence,
                ) ||
                other.currentOccurrence == currentOccurrence) &&
            (identical(
                  other.proposedOccurrence,
                  proposedOccurrence,
                ) ||
                other.proposedOccurrence == proposedOccurrence) &&
            (identical(
                  other.incomingKind,
                  incomingKind,
                ) ||
                other.incomingKind == incomingKind) &&
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
                  other.incomingVersion,
                  incomingVersion,
                ) ||
                other.incomingVersion == incomingVersion) &&
            (identical(
                  other.incomingSourceText,
                  incomingSourceText,
                ) ||
                other.incomingSourceText == incomingSourceText) &&
            (identical(
                  other.acceptedSourceText,
                  acceptedSourceText,
                ) ||
                other.acceptedSourceText == acceptedSourceText) &&
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
      occurrenceRevision,
      originalStart,
      hasLocalChanges,
      acceptedVersion,
      acceptedKind,
      currentOccurrence,
      proposedOccurrence,
      incomingKind,
      incomingSourceId,
      invitationRevision,
      incomingVersion,
      incomingSourceText,
      acceptedSourceText,
      canApply,
      latestResult,
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'occurrenceRevision': occurrenceRevision,
      'originalStart': originalStart.toJson(),
      'hasLocalChanges': hasLocalChanges,
      'acceptedVersion': acceptedVersion.toJson(),
      'acceptedKind': acceptedKind.toJson(),
      if (currentOccurrence != null)
        'currentOccurrence': currentOccurrence?.toJson(),
      if (proposedOccurrence != null)
        'proposedOccurrence': proposedOccurrence?.toJson(),
      if (incomingKind != null) 'incomingKind': incomingKind?.toJson(),
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      'invitationRevision': invitationRevision,
      if (incomingVersion != null) 'incomingVersion': incomingVersion?.toJson(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      if (acceptedSourceText != null) 'acceptedSourceText': acceptedSourceText,
      'canApply': canApply,
      if (latestResult != null) 'latestResult': latestResult?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'occurrenceRevision': occurrenceRevision,
      'originalStart': originalStart.toJsonForProtocol(),
      'hasLocalChanges': hasLocalChanges,
      'acceptedVersion': acceptedVersion.toJsonForProtocol(),
      'acceptedKind': acceptedKind.toJson(),
      if (currentOccurrence != null)
        'currentOccurrence': currentOccurrence?.toJsonForProtocol(),
      if (proposedOccurrence != null)
        'proposedOccurrence': proposedOccurrence?.toJsonForProtocol(),
      if (incomingKind != null) 'incomingKind': incomingKind?.toJson(),
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      'invitationRevision': invitationRevision,
      if (incomingVersion != null)
        'incomingVersion': incomingVersion?.toJsonForProtocol(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      if (acceptedSourceText != null) 'acceptedSourceText': acceptedSourceText,
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

class _CalendarInvitationOccurrenceApplicationViewImpl
    extends CalendarInvitationOccurrenceApplicationView {
  const _CalendarInvitationOccurrenceApplicationViewImpl({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required int occurrenceRevision,
    required _ieswiaty.CalendarEventTiming originalStart,
    required bool hasLocalChanges,
    required _iblfo3t0.CalendarEventProtocolVersion acceptedVersion,
    required _ilccsff7.CalendarInvitationSourceKind acceptedKind,
    _id4cvk34.CalendarEventContent? currentOccurrence,
    _id4cvk34.CalendarEventContent? proposedOccurrence,
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    _isc.UuidValue? incomingSourceId,
    required int invitationRevision,
    _iblfo3t0.CalendarEventProtocolVersion? incomingVersion,
    String? incomingSourceText,
    String? acceptedSourceText,
    required bool canApply,
    _iyajy5op.CalendarInvitationOccurrenceApplyReceipt? latestResult,
  }) : super._(
         linkId: linkId,
         invitationId: invitationId,
         calendarId: calendarId,
         eventId: eventId,
         calendarRevision: calendarRevision,
         eventRevision: eventRevision,
         applicationRevision: applicationRevision,
         occurrenceRevision: occurrenceRevision,
         originalStart: originalStart,
         hasLocalChanges: hasLocalChanges,
         acceptedVersion: acceptedVersion,
         acceptedKind: acceptedKind,
         currentOccurrence: currentOccurrence,
         proposedOccurrence: proposedOccurrence,
         incomingKind: incomingKind,
         incomingSourceId: incomingSourceId,
         invitationRevision: invitationRevision,
         incomingVersion: incomingVersion,
         incomingSourceText: incomingSourceText,
         acceptedSourceText: acceptedSourceText,
         canApply: canApply,
         latestResult: latestResult,
       );

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationOccurrenceApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    int? occurrenceRevision,
    _ieswiaty.CalendarEventTiming? originalStart,
    bool? hasLocalChanges,
    _iblfo3t0.CalendarEventProtocolVersion? acceptedVersion,
    _ilccsff7.CalendarInvitationSourceKind? acceptedKind,
    Object? currentOccurrence = _Undefined,
    Object? proposedOccurrence = _Undefined,
    Object? incomingKind = _Undefined,
    Object? incomingSourceId = _Undefined,
    int? invitationRevision,
    Object? incomingVersion = _Undefined,
    Object? incomingSourceText = _Undefined,
    Object? acceptedSourceText = _Undefined,
    bool? canApply,
    Object? latestResult = _Undefined,
  }) {
    return CalendarInvitationOccurrenceApplicationView(
      linkId: linkId ?? this.linkId,
      invitationId: invitationId ?? this.invitationId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      calendarRevision: calendarRevision ?? this.calendarRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      applicationRevision: applicationRevision ?? this.applicationRevision,
      occurrenceRevision: occurrenceRevision ?? this.occurrenceRevision,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      acceptedVersion: acceptedVersion ?? this.acceptedVersion.copyWith(),
      acceptedKind: acceptedKind ?? this.acceptedKind,
      currentOccurrence: currentOccurrence is _id4cvk34.CalendarEventContent?
          ? currentOccurrence
          : this.currentOccurrence?.copyWith(),
      proposedOccurrence: proposedOccurrence is _id4cvk34.CalendarEventContent?
          ? proposedOccurrence
          : this.proposedOccurrence?.copyWith(),
      incomingKind: incomingKind is _ilccsff7.CalendarInvitationSourceKind?
          ? incomingKind
          : this.incomingKind,
      incomingSourceId: incomingSourceId is _isc.UuidValue?
          ? incomingSourceId
          : this.incomingSourceId,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      incomingVersion:
          incomingVersion is _iblfo3t0.CalendarEventProtocolVersion?
          ? incomingVersion
          : this.incomingVersion?.copyWith(),
      incomingSourceText: incomingSourceText is String?
          ? incomingSourceText
          : this.incomingSourceText,
      acceptedSourceText: acceptedSourceText is String?
          ? acceptedSourceText
          : this.acceptedSourceText,
      canApply: canApply ?? this.canApply,
      latestResult:
          latestResult is _iyajy5op.CalendarInvitationOccurrenceApplyReceipt?
          ? latestResult
          : this.latestResult?.copyWith(),
    );
  }
}
