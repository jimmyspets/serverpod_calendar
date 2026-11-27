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
import 'calendar_event_rule.dart' as _iovyzq1q;
import 'calendar_event_timing.dart' as _ieswiaty;

@_is.immutable
abstract class CalendarEventRecurrence
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventRecurrence._({
    this.rule,
    required this.inclusions,
    required this.exclusions,
  });

  const factory CalendarEventRecurrence({
    _iovyzq1q.CalendarEventRule? rule,
    required List<_ieswiaty.CalendarEventTiming> inclusions,
    required List<_ieswiaty.CalendarEventTiming> exclusions,
  }) = _CalendarEventRecurrenceImpl;

  factory CalendarEventRecurrence.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventRecurrence(
      rule: jsonSerialization['rule'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_iovyzq1q.CalendarEventRule>(
              jsonSerialization['rule'],
            ),
      inclusions: _ix00hwbf.Protocol()
          .deserialize<List<_ieswiaty.CalendarEventTiming>>(
            jsonSerialization['inclusions'],
          ),
      exclusions: _ix00hwbf.Protocol()
          .deserialize<List<_ieswiaty.CalendarEventTiming>>(
            jsonSerialization['exclusions'],
          ),
    );
  }

  final _iovyzq1q.CalendarEventRule? rule;

  final List<_ieswiaty.CalendarEventTiming> inclusions;

  final List<_ieswiaty.CalendarEventTiming> exclusions;

  /// Returns a shallow copy of this [CalendarEventRecurrence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventRecurrence copyWith({
    _iovyzq1q.CalendarEventRule? rule,
    List<_ieswiaty.CalendarEventTiming>? inclusions,
    List<_ieswiaty.CalendarEventTiming>? exclusions,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventRecurrence &&
            (identical(
                  other.rule,
                  rule,
                ) ||
                other.rule == rule) &&
            const _iss.DeepCollectionEquality().equals(
              other.inclusions,
              inclusions,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.exclusions,
              exclusions,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      rule,
      const _iss.DeepCollectionEquality().hash(inclusions),
      const _iss.DeepCollectionEquality().hash(exclusions),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventRecurrence',
      if (rule != null) 'rule': rule?.toJson(),
      'inclusions': inclusions.toJson(valueToJson: (v) => v.toJson()),
      'exclusions': exclusions.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventRecurrence',
      if (rule != null) 'rule': rule?.toJsonForProtocol(),
      'inclusions': inclusions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'exclusions': exclusions.toJson(
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

class _CalendarEventRecurrenceImpl extends CalendarEventRecurrence {
  const _CalendarEventRecurrenceImpl({
    _iovyzq1q.CalendarEventRule? rule,
    required List<_ieswiaty.CalendarEventTiming> inclusions,
    required List<_ieswiaty.CalendarEventTiming> exclusions,
  }) : super._(
         rule: rule,
         inclusions: inclusions,
         exclusions: exclusions,
       );

  /// Returns a shallow copy of this [CalendarEventRecurrence]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventRecurrence copyWith({
    Object? rule = _Undefined,
    List<_ieswiaty.CalendarEventTiming>? inclusions,
    List<_ieswiaty.CalendarEventTiming>? exclusions,
  }) {
    return CalendarEventRecurrence(
      rule: rule is _iovyzq1q.CalendarEventRule? ? rule : this.rule?.copyWith(),
      inclusions:
          inclusions ?? this.inclusions.map((e0) => e0.copyWith()).toList(),
      exclusions:
          exclusions ?? this.exclusions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
