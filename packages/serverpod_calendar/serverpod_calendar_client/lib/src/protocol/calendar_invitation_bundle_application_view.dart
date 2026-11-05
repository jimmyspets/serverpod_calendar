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

import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_timing_overrides.dart' as _ijijze99;
import 'calendar_invitation_apply_receipt.dart' as _ic2yh4ry;
import 'calendar_invitation_bundle_component_version.dart' as _iu3tvjvj;

@_isc.immutable
abstract class CalendarInvitationBundleApplicationView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
  });

  const factory CalendarInvitationBundleApplicationView({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _isc.UuidValue acceptedInvitationId,
    required _isc.UuidValue acceptedSourceId,
    required DateTime acceptedAt,
    required List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
    acceptedComponents,
    required bool acceptedSourceUnavailable,
    required _id4cvk34.CalendarEventContent currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides,
    required bool hasLocalChanges,
    _isc.UuidValue? incomingSourceId,
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
      acceptedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['acceptedAt'],
      ),
      acceptedComponents: _ie4a1wrz.Protocol()
          .deserialize<
            List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
          >(jsonSerialization['acceptedComponents']),
      acceptedSourceUnavailable: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['acceptedSourceUnavailable'],
      ),
      currentContent: _ie4a1wrz.Protocol()
          .deserialize<_id4cvk34.CalendarEventContent>(
            jsonSerialization['currentContent'],
          ),
      currentOverrides: jsonSerialization['currentOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['currentOverrides'],
                ),
      hasLocalChanges: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
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
      incomingOverrides: jsonSerialization['incomingOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['incomingOverrides'],
                ),
      incomingSourceText: jsonSerialization['incomingSourceText'] as String?,
      incomingComponents: jsonSerialization['incomingComponents'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<
              List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
            >(jsonSerialization['incomingComponents']),
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

  final DateTime acceptedAt;

  final List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
  acceptedComponents;

  final bool acceptedSourceUnavailable;

  final _id4cvk34.CalendarEventContent currentContent;

  final _ijijze99.CalendarEventTimingOverrides? currentOverrides;

  final bool hasLocalChanges;

  final _isc.UuidValue? incomingSourceId;

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
  @_isc.useResult
  CalendarInvitationBundleApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _isc.UuidValue? acceptedInvitationId,
    _isc.UuidValue? acceptedSourceId,
    DateTime? acceptedAt,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    acceptedComponents,
    bool? acceptedSourceUnavailable,
    _id4cvk34.CalendarEventContent? currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    bool? hasLocalChanges,
    _isc.UuidValue? incomingSourceId = const _isc.$UndefinedUuidValue(),
    int? invitationRevision,
    _id4cvk34.CalendarEventContent? incomingContent =
        const _UndefinedCalendarInvitationBundleApplicationView$incomingContent(),
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    String? incomingSourceText,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
        incomingComponents =
        const _isc.$UndefinedList<
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarInvitationBundleApplicationView$currentOverrides
    extends _isc.UndefinedSentinel
    implements _ijijze99.CalendarEventTimingOverrides {
  const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides();
}

class _UndefinedCalendarInvitationBundleApplicationView$incomingContent
    extends _isc.UndefinedSentinel
    implements _id4cvk34.CalendarEventContent {
  const _UndefinedCalendarInvitationBundleApplicationView$incomingContent();
}

class _UndefinedCalendarInvitationBundleApplicationView$latestResult
    extends _isc.UndefinedSentinel
    implements _ic2yh4ry.CalendarInvitationApplyReceipt {
  const _UndefinedCalendarInvitationBundleApplicationView$latestResult();
}

class _CalendarInvitationBundleApplicationViewImpl
    extends CalendarInvitationBundleApplicationView {
  const _CalendarInvitationBundleApplicationViewImpl({
    required _isc.UuidValue linkId,
    required _isc.UuidValue invitationId,
    required _isc.UuidValue calendarId,
    required _isc.UuidValue eventId,
    required int calendarRevision,
    required int eventRevision,
    required int applicationRevision,
    required _isc.UuidValue acceptedInvitationId,
    required _isc.UuidValue acceptedSourceId,
    required DateTime acceptedAt,
    required List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>
    acceptedComponents,
    required bool acceptedSourceUnavailable,
    required _id4cvk34.CalendarEventContent currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides,
    required bool hasLocalChanges,
    _isc.UuidValue? incomingSourceId,
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
  @_isc.useResult
  @override
  CalendarInvitationBundleApplicationView copyWith({
    _isc.UuidValue? linkId,
    _isc.UuidValue? invitationId,
    _isc.UuidValue? calendarId,
    _isc.UuidValue? eventId,
    int? calendarRevision,
    int? eventRevision,
    int? applicationRevision,
    _isc.UuidValue? acceptedInvitationId,
    _isc.UuidValue? acceptedSourceId,
    DateTime? acceptedAt,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
    acceptedComponents,
    bool? acceptedSourceUnavailable,
    _id4cvk34.CalendarEventContent? currentContent,
    _ijijze99.CalendarEventTimingOverrides? currentOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    bool? hasLocalChanges,
    _isc.UuidValue? incomingSourceId = const _isc.$UndefinedUuidValue(),
    Object? invitationRevision = _Undefined,
    _id4cvk34.CalendarEventContent? incomingContent =
        const _UndefinedCalendarInvitationBundleApplicationView$incomingContent(),
    _ijijze99.CalendarEventTimingOverrides? incomingOverrides =
        const _UndefinedCalendarInvitationBundleApplicationView$currentOverrides(),
    Object? incomingSourceText = _Undefined,
    List<_iu3tvjvj.CalendarInvitationBundleComponentVersion>?
        incomingComponents =
        const _isc.$UndefinedList<
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
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedComponents:
          acceptedComponents ??
          this.acceptedComponents.map((e0) => e0.copyWith()).toList(),
      acceptedSourceUnavailable:
          acceptedSourceUnavailable ?? this.acceptedSourceUnavailable,
      currentContent: currentContent ?? this.currentContent.copyWith(),
      currentOverrides: currentOverrides is _isc.UndefinedSentinel
          ? this.currentOverrides?.copyWith()
          : currentOverrides,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      incomingSourceId: incomingSourceId is _isc.UndefinedSentinel
          ? this.incomingSourceId
          : incomingSourceId,
      invitationRevision: invitationRevision is int?
          ? invitationRevision
          : this.invitationRevision,
      incomingContent: incomingContent is _isc.UndefinedSentinel
          ? this.incomingContent?.copyWith()
          : incomingContent,
      incomingOverrides: incomingOverrides is _isc.UndefinedSentinel
          ? this.incomingOverrides?.copyWith()
          : incomingOverrides,
      incomingSourceText: incomingSourceText is String?
          ? incomingSourceText
          : this.incomingSourceText,
      incomingComponents: incomingComponents is _isc.UndefinedSentinel
          ? this.incomingComponents?.map((e0) => e0.copyWith()).toList()
          : incomingComponents,
      canApply: canApply ?? this.canApply,
      latestResult: latestResult is _isc.UndefinedSentinel
          ? this.latestResult?.copyWith()
          : latestResult,
    );
  }
}
