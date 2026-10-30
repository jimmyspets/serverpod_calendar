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
import 'calendar_event_occurrence_list_item.dart' as _i6x6hm0f;

@_is.immutable
abstract class CalendarEventOccurrencePage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrencePage._({
    required this.occurrences,
    this.nextCursor,
  });

  const factory CalendarEventOccurrencePage({
    required List<_i6x6hm0f.CalendarEventOccurrenceListItem> occurrences,
    String? nextCursor,
  }) = _CalendarEventOccurrencePageImpl;

  factory CalendarEventOccurrencePage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrencePage(
      occurrences: _ix00hwbf.Protocol()
          .deserialize<List<_i6x6hm0f.CalendarEventOccurrenceListItem>>(
            jsonSerialization['occurrences'],
          ),
      nextCursor: jsonSerialization['nextCursor'] as String?,
    );
  }

  final List<_i6x6hm0f.CalendarEventOccurrenceListItem> occurrences;

  final String? nextCursor;

  /// Returns a shallow copy of this [CalendarEventOccurrencePage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrencePage copyWith({
    List<_i6x6hm0f.CalendarEventOccurrenceListItem>? occurrences,
    String? nextCursor,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrencePage &&
            const _iss.DeepCollectionEquality().equals(
              other.occurrences,
              occurrences,
            ) &&
            (identical(
                  other.nextCursor,
                  nextCursor,
                ) ||
                other.nextCursor == nextCursor);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(occurrences),
      nextCursor,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrencePage',
      'occurrences': occurrences.toJson(valueToJson: (v) => v.toJson()),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrencePage',
      'occurrences': occurrences.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (nextCursor != null) 'nextCursor': nextCursor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventOccurrencePageImpl extends CalendarEventOccurrencePage {
  const _CalendarEventOccurrencePageImpl({
    required List<_i6x6hm0f.CalendarEventOccurrenceListItem> occurrences,
    String? nextCursor,
  }) : super._(
         occurrences: occurrences,
         nextCursor: nextCursor,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrencePage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrencePage copyWith({
    List<_i6x6hm0f.CalendarEventOccurrenceListItem>? occurrences,
    Object? nextCursor = _Undefined,
  }) {
    return CalendarEventOccurrencePage(
      occurrences:
          occurrences ?? this.occurrences.map((e0) => e0.copyWith()).toList(),
      nextCursor: nextCursor is String? ? nextCursor : this.nextCursor,
    );
  }
}
