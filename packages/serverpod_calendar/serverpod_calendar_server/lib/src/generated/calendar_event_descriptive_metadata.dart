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
import 'calendar_event_geographic_position.dart' as _iloy79hd;
import 'calendar_event_resource_group.dart' as _iiajf89w;

@_is.immutable
abstract class CalendarEventDescriptiveMetadata
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventDescriptiveMetadata._({
    this.priority,
    this.geographicPosition,
    required this.resourceGroups,
  });

  const factory CalendarEventDescriptiveMetadata({
    int? priority,
    _iloy79hd.CalendarEventGeographicPosition? geographicPosition,
    required List<_iiajf89w.CalendarEventResourceGroup> resourceGroups,
  }) = _CalendarEventDescriptiveMetadataImpl;

  factory CalendarEventDescriptiveMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventDescriptiveMetadata(
      priority: jsonSerialization['priority'] as int?,
      geographicPosition: jsonSerialization['geographicPosition'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_iloy79hd.CalendarEventGeographicPosition>(
                  jsonSerialization['geographicPosition'],
                ),
      resourceGroups: _ix00hwbf.Protocol()
          .deserialize<List<_iiajf89w.CalendarEventResourceGroup>>(
            jsonSerialization['resourceGroups'],
          ),
    );
  }

  final int? priority;

  final _iloy79hd.CalendarEventGeographicPosition? geographicPosition;

  final List<_iiajf89w.CalendarEventResourceGroup> resourceGroups;

  /// Returns a shallow copy of this [CalendarEventDescriptiveMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventDescriptiveMetadata copyWith({
    int? priority,
    _iloy79hd.CalendarEventGeographicPosition? geographicPosition,
    List<_iiajf89w.CalendarEventResourceGroup>? resourceGroups,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventDescriptiveMetadata &&
            (identical(
                  other.priority,
                  priority,
                ) ||
                other.priority == priority) &&
            (identical(
                  other.geographicPosition,
                  geographicPosition,
                ) ||
                other.geographicPosition == geographicPosition) &&
            const _iss.DeepCollectionEquality().equals(
              other.resourceGroups,
              resourceGroups,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      priority,
      geographicPosition,
      const _iss.DeepCollectionEquality().hash(resourceGroups),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDescriptiveMetadata',
      if (priority != null) 'priority': priority,
      if (geographicPosition != null)
        'geographicPosition': geographicPosition?.toJson(),
      'resourceGroups': resourceGroups.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDescriptiveMetadata',
      if (priority != null) 'priority': priority,
      if (geographicPosition != null)
        'geographicPosition': geographicPosition?.toJsonForProtocol(),
      'resourceGroups': resourceGroups.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventDescriptiveMetadataImpl
    extends CalendarEventDescriptiveMetadata {
  const _CalendarEventDescriptiveMetadataImpl({
    int? priority,
    _iloy79hd.CalendarEventGeographicPosition? geographicPosition,
    required List<_iiajf89w.CalendarEventResourceGroup> resourceGroups,
  }) : super._(
         priority: priority,
         geographicPosition: geographicPosition,
         resourceGroups: resourceGroups,
       );

  /// Returns a shallow copy of this [CalendarEventDescriptiveMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventDescriptiveMetadata copyWith({
    Object? priority = _Undefined,
    Object? geographicPosition = _Undefined,
    List<_iiajf89w.CalendarEventResourceGroup>? resourceGroups,
  }) {
    return CalendarEventDescriptiveMetadata(
      priority: priority is int? ? priority : this.priority,
      geographicPosition:
          geographicPosition is _iloy79hd.CalendarEventGeographicPosition?
          ? geographicPosition
          : this.geographicPosition?.copyWith(),
      resourceGroups:
          resourceGroups ??
          this.resourceGroups.map((e0) => e0.copyWith()).toList(),
    );
  }
}
