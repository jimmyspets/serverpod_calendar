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
  });

  const factory CalendarTaskSourceState({
    required _ivqadd6c.CalendarTaskSourceComponent master,
    required List<_ivqadd6c.CalendarTaskSourceComponent> occurrences,
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
    );
  }

  final _ivqadd6c.CalendarTaskSourceComponent master;

  final List<_ivqadd6c.CalendarTaskSourceComponent> occurrences;

  /// Returns a shallow copy of this [CalendarTaskSourceState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceState copyWith({
    _ivqadd6c.CalendarTaskSourceComponent? master,
    List<_ivqadd6c.CalendarTaskSourceComponent>? occurrences,
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
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      master,
      const _iss.DeepCollectionEquality().hash(occurrences),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskSourceState',
      'master': master.toJson(),
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
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

class _CalendarTaskSourceStateImpl extends CalendarTaskSourceState {
  const _CalendarTaskSourceStateImpl({
    required _ivqadd6c.CalendarTaskSourceComponent master,
    required List<_ivqadd6c.CalendarTaskSourceComponent> occurrences,
  }) : super._(
         master: master,
         occurrences: occurrences,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceState copyWith({
    _ivqadd6c.CalendarTaskSourceComponent? master,
    List<_ivqadd6c.CalendarTaskSourceComponent>? occurrences,
  }) {
    return CalendarTaskSourceState(
      master: master ?? this.master.copyWith(),
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
    );
  }
}
