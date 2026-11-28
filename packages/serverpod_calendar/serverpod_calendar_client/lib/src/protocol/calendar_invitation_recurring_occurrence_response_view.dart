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

import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_invitation_bundle_component_version.dart' as _iu3tvjvj;
import 'calendar_invitation_response_view.dart' as _irmbkh1p;

@_isc.immutable
abstract class CalendarInvitationRecurringOccurrenceResponseView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    required _isc.UuidValue openedInvitationId,
    required int openedInvitationRevision,
    required _isc.UuidValue masterInvitationId,
    required int masterInvitationRevision,
    _isc.UuidValue? membershipSourceId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isc.UuidValue selectionHeadId,
    required int selectionRevision,
    _isc.UuidValue? selectionEvidenceId,
    String? selectionDigest,
    required bool canSend,
    String? blockedReason,
    _isc.UuidValue? controllingInvitationId,
    _isc.UuidValue? controllingSourceId,
    String? controllingRole,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion,
  }) = _CalendarInvitationRecurringOccurrenceResponseViewImpl;

  factory CalendarInvitationRecurringOccurrenceResponseView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationRecurringOccurrenceResponseView(
      response: _ie4a1wrz.Protocol()
          .deserialize<_irmbkh1p.CalendarInvitationResponseView>(
            jsonSerialization['response'],
          ),
      openedInvitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['openedInvitationId'],
      ),
      openedInvitationRevision:
          jsonSerialization['openedInvitationRevision'] as int,
      masterInvitationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['masterInvitationId'],
      ),
      masterInvitationRevision:
          jsonSerialization['masterInvitationRevision'] as int,
      membershipSourceId: jsonSerialization['membershipSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['membershipSourceId'],
            ),
      originalStart: _ie4a1wrz.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      selectionHeadId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['selectionHeadId'],
      ),
      selectionRevision: jsonSerialization['selectionRevision'] as int,
      selectionEvidenceId: jsonSerialization['selectionEvidenceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['selectionEvidenceId'],
            ),
      selectionDigest: jsonSerialization['selectionDigest'] as String?,
      canSend: _isc.BoolJsonExtension.fromJson(jsonSerialization['canSend']),
      blockedReason: jsonSerialization['blockedReason'] as String?,
      controllingInvitationId:
          jsonSerialization['controllingInvitationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['controllingInvitationId'],
            ),
      controllingSourceId: jsonSerialization['controllingSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['controllingSourceId'],
            ),
      controllingRole: jsonSerialization['controllingRole'] as String?,
      componentVersion: jsonSerialization['componentVersion'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<
              _iu3tvjvj.CalendarInvitationBundleComponentVersion
            >(jsonSerialization['componentVersion']),
    );
  }

  final _irmbkh1p.CalendarInvitationResponseView response;

  final _isc.UuidValue openedInvitationId;

  final int openedInvitationRevision;

  final _isc.UuidValue masterInvitationId;

  final int masterInvitationRevision;

  final _isc.UuidValue? membershipSourceId;

  final _ieswiaty.CalendarEventTiming originalStart;

  final _isc.UuidValue selectionHeadId;

  final int selectionRevision;

  final _isc.UuidValue? selectionEvidenceId;

  final String? selectionDigest;

  final bool canSend;

  final String? blockedReason;

  final _isc.UuidValue? controllingInvitationId;

  final _isc.UuidValue? controllingSourceId;

  final String? controllingRole;

  final _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion;

  /// Returns a shallow copy of this [CalendarInvitationRecurringOccurrenceResponseView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationRecurringOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    _isc.UuidValue? openedInvitationId,
    int? openedInvitationRevision,
    _isc.UuidValue? masterInvitationId,
    int? masterInvitationRevision,
    _isc.UuidValue? membershipSourceId = const _isc.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? originalStart,
    _isc.UuidValue? selectionHeadId,
    int? selectionRevision,
    _isc.UuidValue? selectionEvidenceId = const _isc.$UndefinedUuidValue(),
    String? selectionDigest,
    bool? canSend,
    String? blockedReason,
    _isc.UuidValue? controllingInvitationId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? controllingSourceId = const _isc.$UndefinedUuidValue(),
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion
    extends _isc.UndefinedSentinel
    implements _iu3tvjvj.CalendarInvitationBundleComponentVersion {
  const _UndefinedCalendarInvitationRecurringOccurrenceResponseView$componentVersion();
}

class _CalendarInvitationRecurringOccurrenceResponseViewImpl
    extends CalendarInvitationRecurringOccurrenceResponseView {
  const _CalendarInvitationRecurringOccurrenceResponseViewImpl({
    required _irmbkh1p.CalendarInvitationResponseView response,
    required _isc.UuidValue openedInvitationId,
    required int openedInvitationRevision,
    required _isc.UuidValue masterInvitationId,
    required int masterInvitationRevision,
    _isc.UuidValue? membershipSourceId,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _isc.UuidValue selectionHeadId,
    required int selectionRevision,
    _isc.UuidValue? selectionEvidenceId,
    String? selectionDigest,
    required bool canSend,
    String? blockedReason,
    _isc.UuidValue? controllingInvitationId,
    _isc.UuidValue? controllingSourceId,
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
  @_isc.useResult
  @override
  CalendarInvitationRecurringOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    _isc.UuidValue? openedInvitationId,
    int? openedInvitationRevision,
    _isc.UuidValue? masterInvitationId,
    int? masterInvitationRevision,
    _isc.UuidValue? membershipSourceId = const _isc.$UndefinedUuidValue(),
    _ieswiaty.CalendarEventTiming? originalStart,
    _isc.UuidValue? selectionHeadId,
    int? selectionRevision,
    _isc.UuidValue? selectionEvidenceId = const _isc.$UndefinedUuidValue(),
    Object? selectionDigest = _Undefined,
    bool? canSend,
    Object? blockedReason = _Undefined,
    _isc.UuidValue? controllingInvitationId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? controllingSourceId = const _isc.$UndefinedUuidValue(),
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
      membershipSourceId: membershipSourceId is _isc.UndefinedSentinel
          ? this.membershipSourceId
          : membershipSourceId,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      selectionHeadId: selectionHeadId ?? this.selectionHeadId,
      selectionRevision: selectionRevision ?? this.selectionRevision,
      selectionEvidenceId: selectionEvidenceId is _isc.UndefinedSentinel
          ? this.selectionEvidenceId
          : selectionEvidenceId,
      selectionDigest: selectionDigest is String?
          ? selectionDigest
          : this.selectionDigest,
      canSend: canSend ?? this.canSend,
      blockedReason: blockedReason is String?
          ? blockedReason
          : this.blockedReason,
      controllingInvitationId: controllingInvitationId is _isc.UndefinedSentinel
          ? this.controllingInvitationId
          : controllingInvitationId,
      controllingSourceId: controllingSourceId is _isc.UndefinedSentinel
          ? this.controllingSourceId
          : controllingSourceId,
      controllingRole: controllingRole is String?
          ? controllingRole
          : this.controllingRole,
      componentVersion: componentVersion is _isc.UndefinedSentinel
          ? this.componentVersion?.copyWith()
          : componentVersion,
    );
  }
}
