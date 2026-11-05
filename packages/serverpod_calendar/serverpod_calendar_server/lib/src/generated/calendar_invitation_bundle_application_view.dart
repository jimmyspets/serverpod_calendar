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

import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_timing_overrides.dart' as _ijijze99;
import 'calendar_invitation_apply_receipt.dart' as _ic2yh4ry;
import 'calendar_invitation_bundle_component_version.dart' as _iu3tvjvj;
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_is.immutable
abstract class CalendarInvitationBundleApplicationView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationBundleApplicationView._({
    required this.linkId,
    required this.invitationId,
    required this.calendarId,
    required this.eventId,
    required this.calendarRevision,
    required this.eventRevision,
    required this.applicationRevision,
    required this.acceptedInvitationId,
    required this.acceptedSourceId,
    required this.acceptedKind,
    this.acceptedCancellationVersion,
    this.incomingKind,
    bool? canApplyCancellation,
    bool? canReopen,
    required this.acceptedAt,
    required this.acceptedComponents,
    required this.acceptedSourceUnavailable,
    required this.currentContent,
    this.currentOverrides,
    required this.hasLocalChanges,
    this.incomingSourceId,
    this.invitationRevision,
    this.incomingContent,
    this.incomingOverrides,
    this.incomingSourceText,
    this.incomingComponents,
    required this.canApply,
    this.latestResult,
  }) : canApplyCancellation = canApplyCancellation ?? false,
       canReopen = canReopen ?? false;

  const factory CalendarInvitationBundleApplicationView({
    required _is.UuidValue linkId,
    required _is.UuidValue invitationId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _is.UuidValue acceptedInvitationId,
    required _is.UuidValue acceptedSourceId,
    required _ilccsff7.CalendarInvitationSourceKind acceptedKind,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion?
    acceptedCancellationVersion,
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    bool? canApplyCancellation,
    bool? canReopen,
    required DateTime acceptedAt,
    required List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
    acceptedComponents,
    required bool acceptedSourceUnavailable,
    required _id4cvk34.CalendarEventContent currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides,
    required bool hasLocalChanges,
    _is.UuidValue? incomingSourceId,
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent,
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides,
    String? incomingSourceText,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    incomingComponents,
    required bool canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult,
  }) = _CalendarInvitationBundleApplicationViewImpl;

  factory CalendarInvitationBundleApplicationView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationBundleApplicationView(
      linkId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      calendarRevision: jsonSerialization['calendarRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      applicationRevision: jsonSerialization['applicationRevision'] as int,
      acceptedInvitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['acceptedInvitationId'],
      ),
      acceptedSourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['acceptedSourceId'],
      ),
      acceptedKind: _ilccsff7.CalendarInvitationSourceKind.fromJson(
        (jsonSerialization['acceptedKind'] as String),
      ),
      acceptedCancellationVersion:
          jsonSerialization['acceptedCancellationVersion'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              _iu3tvjvj.CalendarInvitationBundleComponentVersion
            >(jsonSerialization['acceptedCancellationVersion']),
      incomingKind: jsonSerialization['incomingKind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['incomingKind'] as String),
            ),
      canApplyCancellation: jsonSerialization['canApplyCancellation'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['canApplyCancellation'],
            ),
      canReopen: jsonSerialization['canReopen'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['canReopen']),
      acceptedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptedAt'],
      ),
      acceptedComponents: _ix00hwbf.Protocol()
          .deserialize<
            List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
          >(jsonSerialization['acceptedComponents']),
      acceptedSourceUnavailable: _is.BoolJsonExtension.fromJson(
        jsonSerialization['acceptedSourceUnavailable'],
      ),
      currentContent: _ix00hwbf.Protocol()
          .deserialize<_id4cvk34.CalendarEventContent>(
            jsonSerialization['currentContent'],
          ),
      currentOverrides: jsonSerialization['currentOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['currentOverrides'],
                ),
      hasLocalChanges: _is.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
      ),
      incomingSourceId: jsonSerialization['incomingSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['incomingSourceId'],
            ),
      invitationRevision: jsonSerialization['invitationRevision'] as int?,
      incomingContent: jsonSerialization['incomingContent'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
              jsonSerialization['incomingContent'],
            ),
      incomingOverrides: jsonSerialization['incomingOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['incomingOverrides'],
                ),
      incomingSourceText: jsonSerialization['incomingSourceText'] as String?,
      incomingComponents: jsonSerialization['incomingComponents'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
            >(jsonSerialization['incomingComponents']),
      canApply: _is.BoolJsonExtension.fromJson(jsonSerialization['canApply']),
      latestResult: jsonSerialization['latestResult'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ic2yh4ry.CalendarInvitationApplyReceipt>(
                  jsonSerialization['latestResult'],
                ),
    );
  }

  final _is.UuidValue linkId;

  final _is.UuidValue invitationId;

  final _is.UuidValue calendarId;

  final _is.UuidValue eventId;

  final int calendarRevision;

  final int eventRevision;

  final int applicationRevision;

  final _is.UuidValue acceptedInvitationId;

  final _is.UuidValue acceptedSourceId;

  final _ilccsff7.CalendarInvitationSourceKind acceptedKind;

  final _iu3tvjvj.CalendarInvitationBundleComponentVersion?
  acceptedCancellationVersion;

  final _ilccsff7.CalendarInvitationSourceKind? incomingKind;

  final bool canApplyCancellation;

  final bool canReopen;

  final DateTime acceptedAt;

  final List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
  acceptedComponents;

  final bool acceptedSourceUnavailable;

  final _id4cvk34.CalendarEventContent currentContent;

  final _ijijze99.CalendarEventTimingOverrides? currentOverrides;

  final bool hasLocalChanges;

  final _is.UuidValue? incomingSourceId;

  final int? invitationRevision;

  final _id4cvk34.CalendarEventContent? incomingContent;

  final _ijijze99.CalendarEventTimingOverrides? incomingOverrides;

  final String? incomingSourceText;

  final List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
  incomingComponents;

  final bool canApply;

  final _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult;

  /// Returns a shallow copy of this [CalendarInvitationBundleApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationBundleApplicationView copyWith({
    _is.UuidValue? linkId,
    _is.UuidValue? invitationId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _is.UuidValue? acceptedInvitationId,
    _is.UuidValue? acceptedSourceId,
    _ilccsff7.CalendarInvitationSourceKind? acceptedKind,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion?
        acceptedCancellationVersion =
        const _UndefinedCalendarInvitationBundleApplicationView$acceptedCancellationVersion(),
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    bool? canApplyCancellation,
    bool? canReopen,
    DateTime? acceptedAt,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    acceptedComponents,
    bool? acceptedSourceUnavailable,
    _id4cvk34.CalendarEventContent? currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    bool? hasLocalChanges,
    _is.UuidValue? incomingSourceId = const _is.$UndefinedUuidValue(),
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent =
        const _UndefinedCalendarInvitationBundleApplicationView$incomingContent(),
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    String? incomingSourceText,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
        incomingComponents =
        const _is.$UndefinedList<
          _iu3tvjvj.CalendarInvitationBundleComponentVersion
        >(),
    bool? canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult =
        const _UndefinedCalendarInvitationBundleApplicationView$latestResult(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationBundleApplicationView &&
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
                  other.acceptedKind,
                  acceptedKind,
                ) ||
                other.acceptedKind == acceptedKind) &&
            (identical(
                  other.acceptedCancellationVersion,
                  acceptedCancellationVersion,
                ) ||
                other.acceptedCancellationVersion ==
                    acceptedCancellationVersion) &&
            (identical(
                  other.incomingKind,
                  incomingKind,
                ) ||
                other.incomingKind == incomingKind) &&
            (identical(
                  other.canApplyCancellation,
                  canApplyCancellation,
                ) ||
                other.canApplyCancellation == canApplyCancellation) &&
            (identical(
                  other.canReopen,
                  canReopen,
                ) ||
                other.canReopen == canReopen) &&
            (identical(
                  other.acceptedAt,
                  acceptedAt,
                ) ||
                other.acceptedAt == acceptedAt) &&
            const _iss.DeepCollectionEquality().equals(
              other.acceptedComponents,
              acceptedComponents,
            ) &&
            (identical(
                  other.acceptedSourceUnavailable,
                  acceptedSourceUnavailable,
                ) ||
                other.acceptedSourceUnavailable == acceptedSourceUnavailable) &&
            (identical(
                  other.currentContent,
                  currentContent,
                ) ||
                other.currentContent == currentContent) &&
            (identical(
                  other.currentOverrides,
                  currentOverrides,
                ) ||
                other.currentOverrides == currentOverrides) &&
            (identical(
                  other.hasLocalChanges,
                  hasLocalChanges,
                ) ||
                other.hasLocalChanges == hasLocalChanges) &&
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
                  other.incomingOverrides,
                  incomingOverrides,
                ) ||
                other.incomingOverrides == incomingOverrides) &&
            (identical(
                  other.incomingSourceText,
                  incomingSourceText,
                ) ||
                other.incomingSourceText == incomingSourceText) &&
            const _iss.DeepCollectionEquality().equals(
              other.incomingComponents,
              incomingComponents,
            ) &&
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
      acceptedKind,
      acceptedCancellationVersion,
      incomingKind,
      canApplyCancellation,
      canReopen,
      acceptedAt,
      const _iss.DeepCollectionEquality().hash(acceptedComponents),
      acceptedSourceUnavailable,
      currentContent,
      currentOverrides,
      hasLocalChanges,
      incomingSourceId,
      invitationRevision,
      incomingContent,
      incomingOverrides,
      incomingSourceText,
      const _iss.DeepCollectionEquality().hash(incomingComponents),
      canApply,
      latestResult,
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'acceptedInvitationId': acceptedInvitationId.toJson(),
      'acceptedSourceId': acceptedSourceId.toJson(),
      'acceptedKind': acceptedKind.toJson(),
      if (acceptedCancellationVersion != null)
        'acceptedCancellationVersion': acceptedCancellationVersion?.toJson(),
      if (incomingKind != null) 'incomingKind': incomingKind?.toJson(),
      'canApplyCancellation': canApplyCancellation,
      'canReopen': canReopen,
      'acceptedAt': acceptedAt.toJson(),
      'acceptedComponents': acceptedComponents.toJson(
        valueToJson: (v) => v.toJson(),
      ),
      'acceptedSourceUnavailable': acceptedSourceUnavailable,
      'currentContent': currentContent.toJson(),
      if (currentOverrides != null)
        'currentOverrides': currentOverrides?.toJson(),
      'hasLocalChanges': hasLocalChanges,
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      if (invitationRevision != null) 'invitationRevision': invitationRevision,
      if (incomingContent != null) 'incomingContent': incomingContent?.toJson(),
      if (incomingOverrides != null)
        'incomingOverrides': incomingOverrides?.toJson(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      if (incomingComponents != null)
        'incomingComponents': incomingComponents?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      'canApply': canApply,
      if (latestResult != null) 'latestResult': latestResult?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleApplicationView',
      'linkId': linkId.toJson(),
      'invitationId': invitationId.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'calendarRevision': calendarRevision,
      'eventRevision': eventRevision,
      'applicationRevision': applicationRevision,
      'acceptedInvitationId': acceptedInvitationId.toJson(),
      'acceptedSourceId': acceptedSourceId.toJson(),
      'acceptedKind': acceptedKind.toJson(),
      if (acceptedCancellationVersion != null)
        'acceptedCancellationVersion': acceptedCancellationVersion
            ?.toJsonForProtocol(),
      if (incomingKind != null) 'incomingKind': incomingKind?.toJson(),
      'canApplyCancellation': canApplyCancellation,
      'canReopen': canReopen,
      'acceptedAt': acceptedAt.toJson(),
      'acceptedComponents': acceptedComponents.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'acceptedSourceUnavailable': acceptedSourceUnavailable,
      'currentContent': currentContent.toJsonForProtocol(),
      if (currentOverrides != null)
        'currentOverrides': currentOverrides?.toJsonForProtocol(),
      'hasLocalChanges': hasLocalChanges,
      if (incomingSourceId != null)
        'incomingSourceId': incomingSourceId?.toJson(),
      if (invitationRevision != null) 'invitationRevision': invitationRevision,
      if (incomingContent != null)
        'incomingContent': incomingContent?.toJsonForProtocol(),
      if (incomingOverrides != null)
        'incomingOverrides': incomingOverrides?.toJsonForProtocol(),
      if (incomingSourceText != null) 'incomingSourceText': incomingSourceText,
      if (incomingComponents != null)
        'incomingComponents': incomingComponents?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      'canApply': canApply,
      if (latestResult != null)
        'latestResult': latestResult?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarInvitationBundleApplicationView$acceptedCancellationVersion
    extends _is.UndefinedSentinel
    implements _iu3tvjvj.CalendarInvitationBundleComponentVersion {
  const _UndefinedCalendarInvitationBundleApplicationView$acceptedCancellationVersion();
}

class _UndefinedCalendarInvitationBundleApplicationView$currentOverrides
    extends _is.UndefinedSentinel
    implements _ijijze99.CalendarEventTimingOverrides {
  const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides();
}

class _UndefinedCalendarInvitationBundleApplicationView$incomingContent
    extends _is.UndefinedSentinel
    implements _id4cvk34.CalendarEventContent {
  const _UndefinedCalendarInvitationBundleApplicationView$incomingContent();
}

class _UndefinedCalendarInvitationBundleApplicationView$latestResult
    extends _is.UndefinedSentinel
    implements _ic2yh4ry.CalendarInvitationApplyReceipt {
  const _UndefinedCalendarInvitationBundleApplicationView$latestResult();
}

class _CalendarInvitationBundleApplicationViewImpl
    extends CalendarInvitationBundleApplicationView {
  const _CalendarInvitationBundleApplicationViewImpl({
    required _is.UuidValue linkId,
    required _is.UuidValue invitationId,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _is.UuidValue acceptedInvitationId,
    required _is.UuidValue acceptedSourceId,
    required _ilccsff7.CalendarInvitationSourceKind acceptedKind,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion?
    acceptedCancellationVersion,
    _ilccsff7.CalendarInvitationSourceKind? incomingKind,
    bool? canApplyCancellation,
    bool? canReopen,
    required DateTime acceptedAt,
    required List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
    acceptedComponents,
    required bool acceptedSourceUnavailable,
    required _id4cvk34.CalendarEventContent currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides,
    required bool hasLocalChanges,
    _is.UuidValue? incomingSourceId,
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent,
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides,
    String? incomingSourceText,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    incomingComponents,
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
         acceptedKind: acceptedKind,
         acceptedCancellationVersion: acceptedCancellationVersion,
         incomingKind: incomingKind,
         canApplyCancellation: canApplyCancellation,
         canReopen: canReopen,
         acceptedAt: acceptedAt,
         acceptedComponents: acceptedComponents,
         acceptedSourceUnavailable: acceptedSourceUnavailable,
         currentContent: currentContent,
         currentOverrides: currentOverrides,
         hasLocalChanges: hasLocalChanges,
         incomingSourceId: incomingSourceId,
         invitationRevision: invitationRevision,
         incomingContent: incomingContent,
         incomingOverrides: incomingOverrides,
         incomingSourceText: incomingSourceText,
         incomingComponents: incomingComponents,
         canApply: canApply,
         latestResult: latestResult,
       );

  /// Returns a shallow copy of this [CalendarInvitationBundleApplicationView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationBundleApplicationView copyWith({
    _is.UuidValue? linkId,
    _is.UuidValue? invitationId,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _is.UuidValue? acceptedInvitationId,
    _is.UuidValue? acceptedSourceId,
    _ilccsff7.CalendarInvitationSourceKind? acceptedKind,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion?
        acceptedCancellationVersion =
        const _UndefinedCalendarInvitationBundleApplicationView$acceptedCancellationVersion(),
    Object? incomingKind = _Undefined,
    bool? canApplyCancellation,
    bool? canReopen,
    DateTime? acceptedAt,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    acceptedComponents,
    bool? acceptedSourceUnavailable,
    _id4cvk34.CalendarEventContent? currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    bool? hasLocalChanges,
    _is.UuidValue? incomingSourceId = const _is.$UndefinedUuidValue(),
    Object? invitationRevision = _Undefined,
    _id4cvk34.CalendarEventContent? incomingContent =
        const _UndefinedCalendarInvitationBundleApplicationView$incomingContent(),
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    Object? incomingSourceText = _Undefined,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
        incomingComponents =
        const _is.$UndefinedList<
          _iu3tvjvj.CalendarInvitationBundleComponentVersion
        >(),
    bool? canApply,
    _ic2yh4ry.CalendarInvitationApplyReceipt? latestResult =
        const _UndefinedCalendarInvitationBundleApplicationView$latestResult(),
  }) {
    return CalendarInvitationBundleApplicationView(
      linkId: linkId ?? this.linkId,
      invitationId: invitationId ?? this.invitationId,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      calendarRevision: calendarRevision ?? this.calendarRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      applicationRevision: applicationRevision ?? this.applicationRevision,
      acceptedInvitationId: acceptedInvitationId ?? this.acceptedInvitationId,
      acceptedSourceId: acceptedSourceId ?? this.acceptedSourceId,
      acceptedKind: acceptedKind ?? this.acceptedKind,
      acceptedCancellationVersion:
          acceptedCancellationVersion is _is.UndefinedSentinel
          ? this.acceptedCancellationVersion?.copyWith()
          : acceptedCancellationVersion,
      incomingKind: incomingKind is _ilccsff7.CalendarInvitationSourceKind?
          ? incomingKind
          : this.incomingKind,
      canApplyCancellation: canApplyCancellation ?? this.canApplyCancellation,
      canReopen: canReopen ?? this.canReopen,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedComponents:
          acceptedComponents ??
          this.acceptedComponents.map((e0) => e0.copyWith()).toList(),
      acceptedSourceUnavailable:
          acceptedSourceUnavailable ?? this.acceptedSourceUnavailable,
      currentContent: currentContent ?? this.currentContent.copyWith(),
      currentOverrides: currentOverrides is _is.UndefinedSentinel
          ? this.currentOverrides?.copyWith()
          : currentOverrides,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      incomingSourceId: incomingSourceId is _is.UndefinedSentinel
          ? this.incomingSourceId
          : incomingSourceId,
      invitationRevision: invitationRevision is int?
          ? invitationRevision
          : this.invitationRevision,
      incomingContent: incomingContent is _is.UndefinedSentinel
          ? this.incomingContent?.copyWith()
          : incomingContent,
      incomingOverrides: incomingOverrides is _is.UndefinedSentinel
          ? this.incomingOverrides?.copyWith()
          : incomingOverrides,
      incomingSourceText: incomingSourceText is String?
          ? incomingSourceText
          : this.incomingSourceText,
      incomingComponents: incomingComponents is _is.UndefinedSentinel
          ? this.incomingComponents?.map((e0) => e0.copyWith()).toList()
          : incomingComponents,
      canApply: canApply ?? this.canApply,
      latestResult: latestResult is _is.UndefinedSentinel
          ? this.latestResult?.copyWith()
          : latestResult,
    );
  }
}
