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

import 'calendar_invitation_bundle_component_version.dart' as _iu3tvjvj;
import 'calendar_invitation_response_view.dart' as _irmbkh1p;

@_isc.immutable
abstract class CalendarInvitationBundleOccurrenceResponseView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationBundleOccurrenceResponseView._({
    required this.response,
    required this.invitationRevision,
    this.currentSourceId,
    this.componentVersion,
  });

  const factory CalendarInvitationBundleOccurrenceResponseView({
    required _irmbkh1p.CalendarInvitationResponseView response,
    required int invitationRevision,
    _isc.UuidValue? currentSourceId,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion,
  }) = _CalendarInvitationBundleOccurrenceResponseViewImpl;

  factory CalendarInvitationBundleOccurrenceResponseView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationBundleOccurrenceResponseView(
      response: _ie4a1wrz.Protocol()
          .deserialize<_irmbkh1p.CalendarInvitationResponseView>(
            jsonSerialization['response'],
          ),
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      currentSourceId: jsonSerialization['currentSourceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentSourceId'],
            ),
      componentVersion: jsonSerialization['componentVersion'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<
              _iu3tvjvj.CalendarInvitationBundleComponentVersion
            >(jsonSerialization['componentVersion']),
    );
  }

  final _irmbkh1p.CalendarInvitationResponseView response;

  final int invitationRevision;

  final _isc.UuidValue? currentSourceId;

  final _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion;

  /// Returns a shallow copy of this [CalendarInvitationBundleOccurrenceResponseView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationBundleOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    int? invitationRevision,
    _isc.UuidValue? currentSourceId = const _isc.$UndefinedUuidValue(),
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion =
        const _UndefinedCalendarInvitationBundleOccurrenceResponseView$componentVersion(),
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationBundleOccurrenceResponseView &&
            (identical(
                  other.response,
                  response,
                ) ||
                other.response == response) &&
            (identical(
                  other.invitationRevision,
                  invitationRevision,
                ) ||
                other.invitationRevision == invitationRevision) &&
            (identical(
                  other.currentSourceId,
                  currentSourceId,
                ) ||
                other.currentSourceId == currentSourceId) &&
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
      invitationRevision,
      currentSourceId,
      componentVersion,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleOccurrenceResponseView',
      'response': response.toJson(),
      'invitationRevision': invitationRevision,
      if (currentSourceId != null) 'currentSourceId': currentSourceId?.toJson(),
      if (componentVersion != null)
        'componentVersion': componentVersion?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationBundleOccurrenceResponseView',
      'response': response.toJsonForProtocol(),
      'invitationRevision': invitationRevision,
      if (currentSourceId != null) 'currentSourceId': currentSourceId?.toJson(),
      if (componentVersion != null)
        'componentVersion': componentVersion?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UndefinedCalendarInvitationBundleOccurrenceResponseView$componentVersion
    extends _isc.UndefinedSentinel
    implements _iu3tvjvj.CalendarInvitationBundleComponentVersion {
  const _UndefinedCalendarInvitationBundleOccurrenceResponseView$componentVersion();
}

class _CalendarInvitationBundleOccurrenceResponseViewImpl
    extends CalendarInvitationBundleOccurrenceResponseView {
  const _CalendarInvitationBundleOccurrenceResponseViewImpl({
    required _irmbkh1p.CalendarInvitationResponseView response,
    required int invitationRevision,
    _isc.UuidValue? currentSourceId,
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion,
  }) : super._(
         response: response,
         invitationRevision: invitationRevision,
         currentSourceId: currentSourceId,
         componentVersion: componentVersion,
       );

  /// Returns a shallow copy of this [CalendarInvitationBundleOccurrenceResponseView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationBundleOccurrenceResponseView copyWith({
    _irmbkh1p.CalendarInvitationResponseView? response,
    int? invitationRevision,
    _isc.UuidValue? currentSourceId = const _isc.$UndefinedUuidValue(),
    _iu3tvjvj.CalendarInvitationBundleComponentVersion? componentVersion =
        const _UndefinedCalendarInvitationBundleOccurrenceResponseView$componentVersion(),
  }) {
    return CalendarInvitationBundleOccurrenceResponseView(
      response: response ?? this.response.copyWith(),
      invitationRevision: invitationRevision ?? this.invitationRevision,
      currentSourceId: currentSourceId is _isc.UndefinedSentinel
          ? this.currentSourceId
          : currentSourceId,
      componentVersion: componentVersion is _isc.UndefinedSentinel
          ? this.componentVersion?.copyWith()
          : componentVersion,
    );
  }
}
