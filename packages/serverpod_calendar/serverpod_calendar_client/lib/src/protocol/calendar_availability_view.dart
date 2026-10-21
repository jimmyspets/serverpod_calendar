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
import 'calendar_availability_content.dart' as _ifxxil5c;
import 'calendar_availability_opening_edits.dart' as _id5ke9r5;
import 'calendar_availability_protocol_state.dart' as _ib9yzivj;

@_isc.immutable
abstract class CalendarAvailabilityView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityView._({
    required this.id,
    required this.calendarId,
    required this.revision,
    required this.protocolUid,
    required this.lastModified,
    this.timingOverrides,
    required this.content,
    required this.protocolState,
  });

  const factory CalendarAvailabilityView({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required _isc.UuidValue protocolUid,
    required DateTime lastModified,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    required _ifxxil5c.CalendarAvailabilityContent content,
    required _ib9yzivj.CalendarAvailabilityProtocolState protocolState,
  }) = _CalendarAvailabilityViewImpl;

  factory CalendarAvailabilityView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityView(
      id: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      protocolUid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['protocolUid'],
      ),
      lastModified: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastModified'],
      ),
      timingOverrides: jsonSerialization['timingOverrides'] == null
          ? null
          : _ie4a1wrz.Protocol()
                .deserialize<List<_id5ke9r5.CalendarAvailabilityOpeningEdits>>(
                  jsonSerialization['timingOverrides'],
                ),
      content: _ie4a1wrz.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
      protocolState: _ie4a1wrz.Protocol()
          .deserialize<_ib9yzivj.CalendarAvailabilityProtocolState>(
            jsonSerialization['protocolState'],
          ),
    );
  }

  final _isc.UuidValue id;

  final _isc.UuidValue calendarId;

  final int revision;

  final _isc.UuidValue protocolUid;

  final DateTime lastModified;

  final List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides;

  final _ifxxil5c.CalendarAvailabilityContent content;

  final _ib9yzivj.CalendarAvailabilityProtocolState protocolState;

  /// Returns a shallow copy of this [CalendarAvailabilityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    _isc.UuidValue? protocolUid,
    DateTime? lastModified,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    _ifxxil5c.CalendarAvailabilityContent? content,
    _ib9yzivj.CalendarAvailabilityProtocolState? protocolState,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityView &&
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
            (identical(
                  other.protocolUid,
                  protocolUid,
                ) ||
                other.protocolUid == protocolUid) &&
            (identical(
                  other.lastModified,
                  lastModified,
                ) ||
                other.lastModified == lastModified) &&
            const _iss.DeepCollectionEquality().equals(
              other.timingOverrides,
              timingOverrides,
            ) &&
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content) &&
            (identical(
                  other.protocolState,
                  protocolState,
                ) ||
                other.protocolState == protocolState);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      calendarId,
      revision,
      protocolUid,
      lastModified,
      const _iss.DeepCollectionEquality().hash(timingOverrides),
      content,
      protocolState,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'protocolUid': protocolUid.toJson(),
      'lastModified': lastModified.toJson(),
      if (timingOverrides != null)
        'timingOverrides': timingOverrides?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      'content': content.toJson(),
      'protocolState': protocolState.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityView',
      'id': id.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      'protocolUid': protocolUid.toJson(),
      'lastModified': lastModified.toJson(),
      if (timingOverrides != null)
        'timingOverrides': timingOverrides?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      'content': content.toJsonForProtocol(),
      'protocolState': protocolState.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityViewImpl extends CalendarAvailabilityView {
  const _CalendarAvailabilityViewImpl({
    required _isc.UuidValue id,
    required _isc.UuidValue calendarId,
    required int revision,
    required _isc.UuidValue protocolUid,
    required DateTime lastModified,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    required _ifxxil5c.CalendarAvailabilityContent content,
    required _ib9yzivj.CalendarAvailabilityProtocolState protocolState,
  }) : super._(
         id: id,
         calendarId: calendarId,
         revision: revision,
         protocolUid: protocolUid,
         lastModified: lastModified,
         timingOverrides: timingOverrides,
         content: content,
         protocolState: protocolState,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityView copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? calendarId,
    int? revision,
    _isc.UuidValue? protocolUid,
    DateTime? lastModified,
    Object? timingOverrides = _Undefined,
    _ifxxil5c.CalendarAvailabilityContent? content,
    _ib9yzivj.CalendarAvailabilityProtocolState? protocolState,
  }) {
    return CalendarAvailabilityView(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      protocolUid: protocolUid ?? this.protocolUid,
      lastModified: lastModified ?? this.lastModified,
      timingOverrides:
          timingOverrides is List<_id5ke9r5.CalendarAvailabilityOpeningEdits>?
          ? timingOverrides
          : this.timingOverrides?.map((e0) => e0.copyWith()).toList(),
      content: content ?? this.content.copyWith(),
      protocolState: protocolState ?? this.protocolState.copyWith(),
    );
  }
}
