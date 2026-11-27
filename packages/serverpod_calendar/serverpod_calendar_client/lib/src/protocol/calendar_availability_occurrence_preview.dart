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
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_time_kind.dart' as _idbnuf6y;

@_isc.immutable
abstract class CalendarAvailabilityOccurrencePreview
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarAvailabilityOccurrencePreview._({
    required this.availabilityId,
    required this.openingUid,
    required this.revision,
    required this.kind,
    this.zoneId,
    required this.occurrences,
  });

  const factory CalendarAvailabilityOccurrencePreview({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue openingUid,
    required int revision,
    required _idbnuf6y.CalendarEventTimeKind kind,
    String? zoneId,
    required List<_isyqnyev.CalendarEventOccurrence> occurrences,
  }) = _CalendarAvailabilityOccurrencePreviewImpl;

  factory CalendarAvailabilityOccurrencePreview.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityOccurrencePreview(
      availabilityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      openingUid: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['openingUid'],
      ),
      revision: jsonSerialization['revision'] as int,
      kind: _idbnuf6y.CalendarEventTimeKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      zoneId: jsonSerialization['zoneId'] as String?,
      occurrences: _ie4a1wrz.Protocol()
          .deserialize<List<_isyqnyev.CalendarEventOccurrence>>(
            jsonSerialization['occurrences'],
          ),
    );
  }

  final _isc.UuidValue availabilityId;

  final _isc.UuidValue openingUid;

  final int revision;

  final _idbnuf6y.CalendarEventTimeKind kind;

  final String? zoneId;

  final List<_isyqnyev.CalendarEventOccurrence> occurrences;

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarAvailabilityOccurrencePreview copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? openingUid,
    int? revision,
    _idbnuf6y.CalendarEventTimeKind? kind,
    String? zoneId,
    List<_isyqnyev.CalendarEventOccurrence>? occurrences,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilityOccurrencePreview &&
            (identical(
                  other.availabilityId,
                  availabilityId,
                ) ||
                other.availabilityId == availabilityId) &&
            (identical(
                  other.openingUid,
                  openingUid,
                ) ||
                other.openingUid == openingUid) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            (identical(
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
            (identical(
                  other.zoneId,
                  zoneId,
                ) ||
                other.zoneId == zoneId) &&
            const _iss.DeepCollectionEquality().equals(
              other.occurrences,
              occurrences,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      availabilityId,
      openingUid,
      revision,
      kind,
      zoneId,
      const _iss.DeepCollectionEquality().hash(occurrences),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOccurrencePreview',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'revision': revision,
      'kind': kind.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAvailabilityOccurrencePreview',
      'availabilityId': availabilityId.toJson(),
      'openingUid': openingUid.toJson(),
      'revision': revision,
      'kind': kind.toJson(),
      if (zoneId != null) 'zoneId': zoneId,
      'occurrences': occurrences.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityOccurrencePreviewImpl
    extends CalendarAvailabilityOccurrencePreview {
  const _CalendarAvailabilityOccurrencePreviewImpl({
    required _isc.UuidValue availabilityId,
    required _isc.UuidValue openingUid,
    required int revision,
    required _idbnuf6y.CalendarEventTimeKind kind,
    String? zoneId,
    required List<_isyqnyev.CalendarEventOccurrence> occurrences,
  }) : super._(
         availabilityId: availabilityId,
         openingUid: openingUid,
         revision: revision,
         kind: kind,
         zoneId: zoneId,
         occurrences: occurrences,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarAvailabilityOccurrencePreview copyWith({
    _isc.UuidValue? availabilityId,
    _isc.UuidValue? openingUid,
    int? revision,
    _idbnuf6y.CalendarEventTimeKind? kind,
    Object? zoneId = _Undefined,
    List<_isyqnyev.CalendarEventOccurrence>? occurrences,
  }) {
    return CalendarAvailabilityOccurrencePreview(
      availabilityId: availabilityId ?? this.availabilityId,
      openingUid: openingUid ?? this.openingUid,
      revision: revision ?? this.revision,
      kind: kind ?? this.kind,
      zoneId: zoneId is String? ? zoneId : this.zoneId,
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
    );
  }
}
