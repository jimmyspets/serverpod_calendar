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
import 'calendar_task_source_component.dart' as _ivqadd6c;

@_is.immutable
abstract class CalendarTaskSourceState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceState._({
    required this.master,
    required this.occurrences,
    this.nativeMetadataOnly,
  });

  const factory CalendarTaskSourceState({
    required _ivqadd6c.CalendarTaskSourceComponent master,
    required List<_ivqadd6c.CalendarTaskSourceComponent> occurrences,
    bool? nativeMetadataOnly,
  }) = _CalendarTaskSourceStateImpl;

  factory CalendarTaskSourceState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceState(
      master: _ix00hwbf.Protocol()
          .deserialize<_ivqadd6c.CalendarTaskSourceComponent>(
            jsonSerialization['master'],
          ),
      occurrences: _ix00hwbf.Protocol()
          .deserialize<List<_ivqadd6c.CalendarTaskSourceComponent>>(
            jsonSerialization['occurrences'],
          ),
      nativeMetadataOnly: jsonSerialization['nativeMetadataOnly'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['nativeMetadataOnly'],
            ),
    );
  }

  final _ivqadd6c.CalendarTaskSourceComponent master;

  final List<_ivqadd6c.CalendarTaskSourceComponent> occurrences;

  final bool? nativeMetadataOnly;

  /// Returns a shallow copy of this [CalendarTaskSourceState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceState copyWith({
    _ivqadd6c.CalendarTaskSourceComponent? master,
    List<_ivqadd6c.CalendarTaskSourceComponent>? occurrences,
    bool? nativeMetadataOnly,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarTaskSourceState &&
            (identical(
                  other.master,
                  master,
                ) ||
                other.master == master) &&
            const _iss.DeepCollectionEquality().equals(
              other.occurrences,
              occurrences,
            ) &&
            (identical(
                  other.nativeMetadataOnly,
                  nativeMetadataOnly,
                ) ||
                other.nativeMetadataOnly == nativeMetadataOnly);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      master,
      const _iss.DeepCollectionEquality().hash(occurrences),
      nativeMetadataOnly,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceState',
      'master': master.toJson(),
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
      if (nativeMetadataOnly != null) 'nativeMetadataOnly': nativeMetadataOnly,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskSourceStateImpl extends CalendarTaskSourceState {
  const _CalendarTaskSourceStateImpl({
    required _ivqadd6c.CalendarTaskSourceComponent master,
    required List<_ivqadd6c.CalendarTaskSourceComponent> occurrences,
    bool? nativeMetadataOnly,
  }) : super._(
         master: master,
         occurrences: occurrences,
         nativeMetadataOnly: nativeMetadataOnly,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceState copyWith({
    _ivqadd6c.CalendarTaskSourceComponent? master,
    List<_ivqadd6c.CalendarTaskSourceComponent>? occurrences,
    Object? nativeMetadataOnly = _Undefined,
  }) {
    return CalendarTaskSourceState(
      master: master ?? this.master.copyWith(),
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
      nativeMetadataOnly: nativeMetadataOnly is bool?
          ? nativeMetadataOnly
          : this.nativeMetadataOnly,
    );
  }
}
