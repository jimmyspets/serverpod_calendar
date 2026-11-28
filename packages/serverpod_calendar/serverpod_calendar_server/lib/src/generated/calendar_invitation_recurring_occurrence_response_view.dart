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

import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_invitation_bundle_component_version.dart' as _iu3tvjvj;
import 'calendar_invitation_response_view.dart' as _irmbkh1p;

@_is.immutable
abstract class CalendarInvitationRecurringOccurrenceResponseView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationRecurringOccurrenceResponseView._({
    required this.response,
    required this.openedInvitationId,
    required this.openedInvitationRevision,
    required this.masterInvitationId,
    required this.masterInvitationRevision,
    this.membershipSourceId,
    required this.originalStart,
    required this.selectionHeadId,
    required this.selectionRevision,
    this.selectionEvidenceId,
    this.selectionDigest,
    required this.canSend,
    this.blockedReason,
    this.controllingInvitationId,
    this.controllingSourceId,
    this.controllingRole,
    this.componentVersion,
  });

  const factory CalendarInvitationRecurringOccurrenceResponseView({
    required _irmbkh1p.CalendarInvitationResponseView response,
    required _is.UuidValue openedInvitationId,
    required int openedInvitationRevision,
    required _is.UuidValue masterInvitationId,
    required int masterInvitationRevision,
    _is.UuidValue? membershipSourceId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _is.UuidValue selectionHeadId,
    required int selectionRevision,
    _is.UuidValue? selectionEvidenceId,
    String? selectionDigest,
    required bool canSend,
    String? blockedReason,
    _is.UuidValue? controllingInvitationId,
    _is.UuidValue? controllingSourceId,
    String? controllingRole,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion,
  }) = _CalendarInvitationRecurringOccurrenceResponseViewImpl;

  factory CalendarInvitationRecurringOccurrenceResponseView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationRecurringOccurrenceResponseView(
      response: _ix00hwbf.Protocol()
          .deserialize<_irmbkh1p.CalendarInvitationResponseView>(
            jsonSerialization['response'],
          ),
      openedInvitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openedInvitationId'],
      ),
      openedInvitationRevision:
          jsonSerialization['openedInvitationRevision'] as int,
      masterInvitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['masterInvitationId'],
      ),
      masterInvitationRevision:
          jsonSerialization['masterInvitationRevision'] as int,
      membershipSourceId: jsonSerialization['membershipSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['membershipSourceId'],
            ),
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      selectionHeadId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['selectionHeadId'],
      ),
      selectionRevision: jsonSerialization['selectionRevision'] as int,
      selectionEvidenceId: jsonSerialization['selectionEvidenceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['selectionEvidenceId'],
            ),
      selectionDigest: jsonSerialization['selectionDigest'] as String?,
      canSend: _is.BoolJsonExtension.fromJson(jsonSerialization['canSend']),
      blockedReason: jsonSerialization['blockedReason'] as String?,
      controllingInvitationId:
          jsonSerialization['controllingInvitationId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['controllingInvitationId'],
            ),
      controllingSourceId: jsonSerialization['controllingSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['controllingSourceId'],
            ),
      controllingRole: jsonSerialization['controllingRole'] as String?,
      componentVersion: jsonSerialization['componentVersion'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              _iu3tvjvj.CalendarInvitationBundleComponentVersion
            >(jsonSerialization['componentVersion']),
    );
  }

  final _irmbkh1p.CalendarInvitationResponseView response;

  final _is.UuidValue openedInvitationId;

  final int openedInvitationRevision;

  final _is.UuidValue masterInvitationId;

  final int masterInvitationRevision;

  final _is.UuidValue? membershipSourceId;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _is.UuidValue selectionHeadId;

  final int selectionRevision;

  final _is.UuidValue? selectionEvidenceId;

  final String? selectionDigest;

  final bool canSend;

  final String? blockedReason;

  final _is.UuidValue? controllingInvitationId;

  final _is.UuidValue? controllingSourceId;

  final String? controllingRole;

  final _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion;

  /// Returns a shallow copy of this [CalendarInvitationRecurringOccurrenceResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationRecurringOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    _is.UuidValue? openedInvitationId,
    int? openedInvitationRevision,
    _is.UuidValue? masterInvitationId,
    int? masterInvitationRevision,
    _is.UuidValue? membershipSourceId = const _is.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? originalStart,
    _is.UuidValue? selectionHeadId,
    int? selectionRevision,
    _is.UuidValue? selectionEvidenceId = const _is.$UndefinedUuidValue(),
    String? selectionDigest,
    bool? canSend,
    String? blockedReason,
    _is.UuidValue? controllingInvitationId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? controllingSourceId = const _is.$UndefinedUuidValue(),
    String? controllingRole,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion =
        const _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationRecurringOccurrenceResponseView &&
            (identical(
                  other.response,
                  response,
                ) ||
                other.response == response) &&
            (identical(
                  other.openedInvitationId,
                  openedInvitationId,
                ) ||
                other.openedInvitationId == openedInvitationId) &&
            (identical(
                  other.openedInvitationRevision,
                  openedInvitationRevision,
                ) ||
                other.openedInvitationRevision == openedInvitationRevision) &&
            (identical(
                  other.masterInvitationId,
                  masterInvitationId,
                ) ||
                other.masterInvitationId == masterInvitationId) &&
            (identical(
                  other.masterInvitationRevision,
                  masterInvitationRevision,
                ) ||
                other.masterInvitationRevision == masterInvitationRevision) &&
            (identical(
                  other.membershipSourceId,
                  membershipSourceId,
                ) ||
                other.membershipSourceId == membershipSourceId) &&
            (identical(
                  other.originalStart,
                  originalStart,
                ) ||
                other.originalStart == originalStart) &&
            (identical(
                  other.selectionHeadId,
                  selectionHeadId,
                ) ||
                other.selectionHeadId == selectionHeadId) &&
            (identical(
                  other.selectionRevision,
                  selectionRevision,
                ) ||
                other.selectionRevision == selectionRevision) &&
            (identical(
                  other.selectionEvidenceId,
                  selectionEvidenceId,
                ) ||
                other.selectionEvidenceId == selectionEvidenceId) &&
            (identical(
                  other.selectionDigest,
                  selectionDigest,
                ) ||
                other.selectionDigest == selectionDigest) &&
            (identical(
                  other.canSend,
                  canSend,
                ) ||
                other.canSend == canSend) &&
            (identical(
                  other.blockedReason,
                  blockedReason,
                ) ||
                other.blockedReason == blockedReason) &&
            (identical(
                  other.controllingInvitationId,
                  controllingInvitationId,
                ) ||
                other.controllingInvitationId == controllingInvitationId) &&
            (identical(
                  other.controllingSourceId,
                  controllingSourceId,
                ) ||
                other.controllingSourceId == controllingSourceId) &&
            (identical(
                  other.controllingRole,
                  controllingRole,
                ) ||
                other.controllingRole == controllingRole) &&
            (identical(
                  other.componentVersion,
                  componentVersion,
                ) ||
                other.componentVersion == componentVersion);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      response,
      openedInvitationId,
      openedInvitationRevision,
      masterInvitationId,
      masterInvitationRevision,
      membershipSourceId,
      originalStart,
      selectionHeadId,
      selectionRevision,
      selectionEvidenceId,
      selectionDigest,
      canSend,
      blockedReason,
      controllingInvitationId,
      controllingSourceId,
      controllingRole,
      componentVersion,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationRecurringOccurrenceResponseView',
      'response': response.toJson(),
      'openedInvitationId': openedInvitationId.toJson(),
      'openedInvitationRevision': openedInvitationRevision,
      'masterInvitationId': masterInvitationId.toJson(),
      'masterInvitationRevision': masterInvitationRevision,
      if (membershipSourceId != null)
        'membershipSourceId': membershipSourceId?.toJson(),
      'originalStart': originalStart.toJson(),
      'selectionHeadId': selectionHeadId.toJson(),
      'selectionRevision': selectionRevision,
      if (selectionEvidenceId != null)
        'selectionEvidenceId': selectionEvidenceId?.toJson(),
      if (selectionDigest != null) 'selectionDigest': selectionDigest,
      'canSend': canSend,
      if (blockedReason != null) 'blockedReason': blockedReason,
      if (controllingInvitationId != null)
        'controllingInvitationId': controllingInvitationId?.toJson(),
      if (controllingSourceId != null)
        'controllingSourceId': controllingSourceId?.toJson(),
      if (controllingRole != null) 'controllingRole': controllingRole,
      if (componentVersion != null)
        'componentVersion': componentVersion?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationRecurringOccurrenceResponseView',
      'response': response.toJsonForProtocol(),
      'openedInvitationId': openedInvitationId.toJson(),
      'openedInvitationRevision': openedInvitationRevision,
      'masterInvitationId': masterInvitationId.toJson(),
      'masterInvitationRevision': masterInvitationRevision,
      if (membershipSourceId != null)
        'membershipSourceId': membershipSourceId?.toJson(),
      'originalStart': originalStart.toJsonForProtocol(),
      'selectionHeadId': selectionHeadId.toJson(),
      'selectionRevision': selectionRevision,
      if (selectionEvidenceId != null)
        'selectionEvidenceId': selectionEvidenceId?.toJson(),
      if (selectionDigest != null) 'selectionDigest': selectionDigest,
      'canSend': canSend,
      if (blockedReason != null) 'blockedReason': blockedReason,
      if (controllingInvitationId != null)
        'controllingInvitationId': controllingInvitationId?.toJson(),
      if (controllingSourceId != null)
        'controllingSourceId': controllingSourceId?.toJson(),
      if (controllingRole != null) 'controllingRole': controllingRole,
      if (componentVersion != null)
        'componentVersion': componentVersion?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion
    extends _is.UndefinedSentinel
    implements _iu3tvjvj.CalendarInvitationBundleComponentVersion {
  const _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion();
}

class _CalendarInvitationRecurringOccurrenceResponseViewImpl
    extends CalendarInvitationRecurringOccurrenceResponseView {
  const _CalendarInvitationRecurringOccurrenceResponseViewImpl({
    required _irmbkh1p.CalendarInvitationResponseView response,
    required _is.UuidValue openedInvitationId,
    required int openedInvitationRevision,
    required _is.UuidValue masterInvitationId,
    required int masterInvitationRevision,
    _is.UuidValue? membershipSourceId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _is.UuidValue selectionHeadId,
    required int selectionRevision,
    _is.UuidValue? selectionEvidenceId,
    String? selectionDigest,
    required bool canSend,
    String? blockedReason,
    _is.UuidValue? controllingInvitationId,
    _is.UuidValue? controllingSourceId,
    String? controllingRole,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion,
  }) : super._(
         response: response,
         openedInvitationId: openedInvitationId,
         openedInvitationRevision: openedInvitationRevision,
         masterInvitationId: masterInvitationId,
         masterInvitationRevision: masterInvitationRevision,
         membershipSourceId: membershipSourceId,
         originalStart: originalStart,
         selectionHeadId: selectionHeadId,
         selectionRevision: selectionRevision,
         selectionEvidenceId: selectionEvidenceId,
         selectionDigest: selectionDigest,
         canSend: canSend,
         blockedReason: blockedReason,
         controllingInvitationId: controllingInvitationId,
         controllingSourceId: controllingSourceId,
         controllingRole: controllingRole,
         componentVersion: componentVersion,
       );

  /// Returns a shallow copy of this [CalendarInvitationRecurringOccurrenceResponseView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationRecurringOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    _is.UuidValue? openedInvitationId,
    int? openedInvitationRevision,
    _is.UuidValue? masterInvitationId,
    int? masterInvitationRevision,
    _is.UuidValue? membershipSourceId = const _is.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? originalStart,
    _is.UuidValue? selectionHeadId,
    int? selectionRevision,
    _is.UuidValue? selectionEvidenceId = const _is.$UndefinedUuidValue(),
    Object? selectionDigest = _Undefined,
    bool? canSend,
    Object? blockedReason = _Undefined,
    _is.UuidValue? controllingInvitationId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? controllingSourceId = const _is.$UndefinedUuidValue(),
    Object? controllingRole = _Undefined,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion =
        const _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion(),
  }) {
    return CalendarInvitationRecurringOccurrenceResponseView(
      response: response ?? this.response.copyWith(),
      openedInvitationId: openedInvitationId ?? this.openedInvitationId,
      openedInvitationRevision:
          openedInvitationRevision ?? this.openedInvitationRevision,
      masterInvitationId: masterInvitationId ?? this.masterInvitationId,
      masterInvitationRevision:
          masterInvitationRevision ?? this.masterInvitationRevision,
      membershipSourceId: membershipSourceId is _is.UndefinedSentinel
          ? this.membershipSourceId
          : membershipSourceId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      selectionHeadId: selectionHeadId ?? this.selectionHeadId,
      selectionRevision: selectionRevision ?? this.selectionRevision,
      selectionEvidenceId: selectionEvidenceId is _is.UndefinedSentinel
          ? this.selectionEvidenceId
          : selectionEvidenceId,
      selectionDigest: selectionDigest is String?
          ? selectionDigest
          : this.selectionDigest,
      canSend: canSend ?? this.canSend,
      blockedReason: blockedReason is String?
          ? blockedReason
          : this.blockedReason,
      controllingInvitationId: controllingInvitationId is _is.UndefinedSentinel
          ? this.controllingInvitationId
          : controllingInvitationId,
      controllingSourceId: controllingSourceId is _is.UndefinedSentinel
          ? this.controllingSourceId
          : controllingSourceId,
      controllingRole: controllingRole is String?
          ? controllingRole
          : this.controllingRole,
      componentVersion: componentVersion is _is.UndefinedSentinel
          ? this.componentVersion?.copyWith()
          : componentVersion,
    );
  }
}
