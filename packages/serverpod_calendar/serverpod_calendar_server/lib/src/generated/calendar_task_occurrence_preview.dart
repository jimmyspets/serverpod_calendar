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
import 'calendar_task_field_group.dart' as _isemqyyv;
import 'calendar_task_occurrence.dart' as _isgg83d3;

@_is.immutable
abstract class CalendarTaskOccurrencePreview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskOccurrencePreview._({
    required this.taskId,
    required this.revision,
    required this.disclosedGroups,
    required this.occurrences,
  });

  const factory CalendarTaskOccurrencePreview({
    required _is.UuidValue taskId,
    required int revision,
    required List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups,
    required List<_isgg83d3.CalendarTaskOccurrence> occurrences,
  }) = _CalendarTaskOccurrencePreviewImpl;

  factory CalendarTaskOccurrencePreview.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrencePreview(
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      revision: jsonSerialization['revision'] as int,
      disclosedGroups: _ix00hwbf.Protocol()
          .deserialize<List<_isemqyyv.CalendarTaskFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
      occurrences: _ix00hwbf.Protocol()
          .deserialize<List<_isgg83d3.CalendarTaskOccurrence>>(
            jsonSerialization['occurrences'],
          ),
    );
  }

  final _is.UuidValue taskId;

  final int revision;

  final List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups;

  final List<_isgg83d3.CalendarTaskOccurrence> occurrences;

  /// Returns a shallow copy of this [CalendarTaskOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskOccurrencePreview copyWith({
    _is.UuidValue? taskId,
    int? revision,
    List<_isemqyyv.CalendarTaskFieldGroup>? disclosedGroups,
    List<_isgg83d3.CalendarTaskOccurrence>? occurrences,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskOccurrencePreview &&
            (identical(
                  other.taskId,
                  taskId,
                ) ||
                other.taskId == taskId) &&
            (identical(
                  other.revision,
                  revision,
                ) ||
                other.revision == revision) &&
            const _iss.DeepCollectionEquality().equals(
              other.disclosedGroups,
              disclosedGroups,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.occurrences,
              occurrences,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      taskId,
      revision,
      const _iss.DeepCollectionEquality().hash(disclosedGroups),
      const _iss.DeepCollectionEquality().hash(occurrences),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrencePreview',
      'taskId': taskId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrencePreview',
      'taskId': taskId.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      'occurrences': occurrences.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarTaskOccurrencePreviewImpl extends CalendarTaskOccurrencePreview {
  const _CalendarTaskOccurrencePreviewImpl({
    required _is.UuidValue taskId,
    required int revision,
    required List<_isemqyyv.CalendarTaskFieldGroup> disclosedGroups,
    required List<_isgg83d3.CalendarTaskOccurrence> occurrences,
  }) : super._(
         taskId: taskId,
         revision: revision,
         disclosedGroups: disclosedGroups,
         occurrences: occurrences,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrencePreview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskOccurrencePreview copyWith({
    _is.UuidValue? taskId,
    int? revision,
    List<_isemqyyv.CalendarTaskFieldGroup>? disclosedGroups,
    List<_isgg83d3.CalendarTaskOccurrence>? occurrences,
  }) {
    return CalendarTaskOccurrencePreview(
      taskId: taskId ?? this.taskId,
      revision: revision ?? this.revision,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
    );
  }
}
