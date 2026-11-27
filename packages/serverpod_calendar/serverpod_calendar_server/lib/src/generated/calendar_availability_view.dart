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
import 'calendar_availability_content.dart' as _ifxxil5c;

@_is.immutable
abstract class CalendarAvailabilityView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilityView._({
    required this.id,
    required this.calendarId,
    required this.revision,
    required this.protocolUid,
    required this.lastModified,
    required this.content,
  });

  const factory CalendarAvailabilityView({
    required _is.UuidValue id,
    required _is.UuidValue calendarId,
    required int revision,
    required _is.UuidValue protocolUid,
    required DateTime lastModified,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) = _CalendarAvailabilityViewImpl;

  factory CalendarAvailabilityView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      protocolUid: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['protocolUid'],
      ),
      lastModified: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastModified'],
      ),
      content: _ix00hwbf.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
    );
  }

  final _is.UuidValue id;

  final _is.UuidValue calendarId;

  final int revision;

  final _is.UuidValue protocolUid;

  final DateTime lastModified;

  final _ifxxil5c.CalendarAvailabilityContent content;

  /// Returns a shallow copy of this [CalendarAvailabilityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? calendarId,
    int? revision,
    _is.UuidValue? protocolUid,
    DateTime? lastModified,
    _ifxxil5c.CalendarAvailabilityContent? content,
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
            (identical(
                  other.content,
                  content,
                ) ||
                other.content == content);
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
      content,
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
      'content': content.toJson(),
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
      'content': content.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAvailabilityViewImpl extends CalendarAvailabilityView {
  const _CalendarAvailabilityViewImpl({
    required _is.UuidValue id,
    required _is.UuidValue calendarId,
    required int revision,
    required _is.UuidValue protocolUid,
    required DateTime lastModified,
    required _ifxxil5c.CalendarAvailabilityContent content,
  }) : super._(
         id: id,
         calendarId: calendarId,
         revision: revision,
         protocolUid: protocolUid,
         lastModified: lastModified,
         content: content,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityView copyWith({
    _is.UuidValue? id,
    _is.UuidValue? calendarId,
    int? revision,
    _is.UuidValue? protocolUid,
    DateTime? lastModified,
    _ifxxil5c.CalendarAvailabilityContent? content,
  }) {
    return CalendarAvailabilityView(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      protocolUid: protocolUid ?? this.protocolUid,
      lastModified: lastModified ?? this.lastModified,
      content: content ?? this.content.copyWith(),
    );
  }
}
