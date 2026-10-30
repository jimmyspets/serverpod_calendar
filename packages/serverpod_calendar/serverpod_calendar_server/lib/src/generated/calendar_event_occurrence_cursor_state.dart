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

@_is.immutable
abstract class CalendarEventOccurrenceCursorState
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventOccurrenceCursorState._({
    required this.version,
    required this.fromUtc,
    required this.untilUtc,
    required this.includeCancelled,
    required this.afterStartUtc,
    required this.afterOriginalKey,
    required this.timezoneIdentity,
  });

  const factory CalendarEventOccurrenceCursorState({
    required int version,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required bool includeCancelled,
    required DateTime afterStartUtc,
    required String afterOriginalKey,
    required String timezoneIdentity,
  }) = _CalendarEventOccurrenceCursorStateImpl;

  factory CalendarEventOccurrenceCursorState.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventOccurrenceCursorState(
      version: jsonSerialization['version'] as int,
      fromUtc: _is.DateTimeJsonExtension.fromJson(jsonSerialization['fromUtc']),
      untilUtc: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
      includeCancelled: _is.BoolJsonExtension.fromJson(
        jsonSerialization['includeCancelled'],
      ),
      afterStartUtc: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['afterStartUtc'],
      ),
      afterOriginalKey: jsonSerialization['afterOriginalKey'] as String,
      timezoneIdentity: jsonSerialization['timezoneIdentity'] as String,
    );
  }

  final int version;

  final DateTime fromUtc;

  final DateTime untilUtc;

  final bool includeCancelled;

  final DateTime afterStartUtc;

  final String afterOriginalKey;

  final String timezoneIdentity;

  /// Returns a shallow copy of this [CalendarEventOccurrenceCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventOccurrenceCursorState copyWith({
    int? version,
    DateTime? fromUtc,
    DateTime? untilUtc,
    bool? includeCancelled,
    DateTime? afterStartUtc,
    String? afterOriginalKey,
    String? timezoneIdentity,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventOccurrenceCursorState &&
            (identical(
                  other.version,
                  version,
                ) ||
                other.version == version) &&
            (identical(
                  other.fromUtc,
                  fromUtc,
                ) ||
                other.fromUtc == fromUtc) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc) &&
            (identical(
                  other.includeCancelled,
                  includeCancelled,
                ) ||
                other.includeCancelled == includeCancelled) &&
            (identical(
                  other.afterStartUtc,
                  afterStartUtc,
                ) ||
                other.afterStartUtc == afterStartUtc) &&
            (identical(
                  other.afterOriginalKey,
                  afterOriginalKey,
                ) ||
                other.afterOriginalKey == afterOriginalKey) &&
            (identical(
                  other.timezoneIdentity,
                  timezoneIdentity,
                ) ||
                other.timezoneIdentity == timezoneIdentity);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      version,
      fromUtc,
      untilUtc,
      includeCancelled,
      afterStartUtc,
      afterOriginalKey,
      timezoneIdentity,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventOccurrenceCursorState',
      'version': version,
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'includeCancelled': includeCancelled,
      'afterStartUtc': afterStartUtc.toJson(),
      'afterOriginalKey': afterOriginalKey,
      'timezoneIdentity': timezoneIdentity,
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

class _CalendarEventOccurrenceCursorStateImpl
    extends CalendarEventOccurrenceCursorState {
  const _CalendarEventOccurrenceCursorStateImpl({
    required int version,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required bool includeCancelled,
    required DateTime afterStartUtc,
    required String afterOriginalKey,
    required String timezoneIdentity,
  }) : super._(
         version: version,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         includeCancelled: includeCancelled,
         afterStartUtc: afterStartUtc,
         afterOriginalKey: afterOriginalKey,
         timezoneIdentity: timezoneIdentity,
       );

  /// Returns a shallow copy of this [CalendarEventOccurrenceCursorState]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventOccurrenceCursorState copyWith({
    int? version,
    DateTime? fromUtc,
    DateTime? untilUtc,
    bool? includeCancelled,
    DateTime? afterStartUtc,
    String? afterOriginalKey,
    String? timezoneIdentity,
  }) {
    return CalendarEventOccurrenceCursorState(
      version: version ?? this.version,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      includeCancelled: includeCancelled ?? this.includeCancelled,
      afterStartUtc: afterStartUtc ?? this.afterStartUtc,
      afterOriginalKey: afterOriginalKey ?? this.afterOriginalKey,
      timezoneIdentity: timezoneIdentity ?? this.timezoneIdentity,
    );
  }
}
