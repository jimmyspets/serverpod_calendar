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
import 'calendar_event_by_day.dart' as _iq7751s4;
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_frequency.dart' as _i2q54gr5;

@_isc.immutable
abstract class CalendarEventRule
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarEventRule._({
    required this.frequency,
    int? interval,
    this.count,
    this.untilDate,
    this.untilUtc,
    int? weekStart,
    required this.byDay,
    required this.byMonthDay,
    required this.byYearDay,
    required this.byWeekNo,
    required this.byMonth,
    required this.byHour,
    required this.byMinute,
    required this.bySetPosition,
  }) : interval = interval ?? 1,
       weekStart = weekStart ?? 1;

  const factory CalendarEventRule({
    required _i2q54gr5.CalendarEventFrequency frequency,
    int? interval,
    int? count,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? untilUtc,
    int? weekStart,
    required List<_iq7751s4.CalendarEventByDay> byDay,
    required List<int> byMonthDay,
    required List<int> byYearDay,
    required List<int> byWeekNo,
    required List<int> byMonth,
    required List<int> byHour,
    required List<int> byMinute,
    required List<int> bySetPosition,
  }) = _CalendarEventRuleImpl;

  factory CalendarEventRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventRule(
      frequency: _i2q54gr5.CalendarEventFrequency.fromJson(
        (jsonSerialization['frequency'] as String),
      ),
      interval: jsonSerialization['interval'] as int?,
      count: jsonSerialization['count'] as int?,
      untilDate: jsonSerialization['untilDate'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_i1bb5k1r.CalendarEventCivil>(
              jsonSerialization['untilDate'],
            ),
      untilUtc: jsonSerialization['untilUtc'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['untilUtc']),
      weekStart: jsonSerialization['weekStart'] as int?,
      byDay: _ie4a1wrz.Protocol()
          .deserialize<List<_iq7751s4.CalendarEventByDay>>(
            jsonSerialization['byDay'],
          ),
      byMonthDay: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byMonthDay'],
      ),
      byYearDay: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byYearDay'],
      ),
      byWeekNo: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byWeekNo'],
      ),
      byMonth: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byMonth'],
      ),
      byHour: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byHour'],
      ),
      byMinute: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['byMinute'],
      ),
      bySetPosition: _ie4a1wrz.Protocol().deserialize<List<int>>(
        jsonSerialization['bySetPosition'],
      ),
    );
  }

  final _i2q54gr5.CalendarEventFrequency frequency;

  final int interval;

  final int? count;

  final _i1bb5k1r.CalendarEventCivil? untilDate;

  final DateTime? untilUtc;

  final int weekStart;

  final List<_iq7751s4.CalendarEventByDay> byDay;

  final List<int> byMonthDay;

  final List<int> byYearDay;

  final List<int> byWeekNo;

  final List<int> byMonth;

  final List<int> byHour;

  final List<int> byMinute;

  final List<int> bySetPosition;

  /// Returns a shallow copy of this [CalendarEventRule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarEventRule copyWith({
    _i2q54gr5.CalendarEventFrequency? frequency,
    int? interval,
    int? count,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? untilUtc,
    int? weekStart,
    List<_iq7751s4.CalendarEventByDay>? byDay,
    List<int>? byMonthDay,
    List<int>? byYearDay,
    List<int>? byWeekNo,
    List<int>? byMonth,
    List<int>? byHour,
    List<int>? byMinute,
    List<int>? bySetPosition,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventRule &&
            (identical(
                  other.frequency,
                  frequency,
                ) ||
                other.frequency == frequency) &&
            (identical(
                  other.interval,
                  interval,
                ) ||
                other.interval == interval) &&
            (identical(
                  other.count,
                  count,
                ) ||
                other.count == count) &&
            (identical(
                  other.untilDate,
                  untilDate,
                ) ||
                other.untilDate == untilDate) &&
            (identical(
                  other.untilUtc,
                  untilUtc,
                ) ||
                other.untilUtc == untilUtc) &&
            (identical(
                  other.weekStart,
                  weekStart,
                ) ||
                other.weekStart == weekStart) &&
            const _iss.DeepCollectionEquality().equals(
              other.byDay,
              byDay,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byMonthDay,
              byMonthDay,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byYearDay,
              byYearDay,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byWeekNo,
              byWeekNo,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byMonth,
              byMonth,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byHour,
              byHour,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.byMinute,
              byMinute,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.bySetPosition,
              bySetPosition,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      frequency,
      interval,
      count,
      untilDate,
      untilUtc,
      weekStart,
      const _iss.DeepCollectionEquality().hash(byDay),
      const _iss.DeepCollectionEquality().hash(byMonthDay),
      const _iss.DeepCollectionEquality().hash(byYearDay),
      const _iss.DeepCollectionEquality().hash(byWeekNo),
      const _iss.DeepCollectionEquality().hash(byMonth),
      const _iss.DeepCollectionEquality().hash(byHour),
      const _iss.DeepCollectionEquality().hash(byMinute),
      const _iss.DeepCollectionEquality().hash(bySetPosition),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventRule',
      'frequency': frequency.toJson(),
      'interval': interval,
      if (count != null) 'count': count,
      if (untilDate != null) 'untilDate': untilDate?.toJson(),
      if (untilUtc != null) 'untilUtc': untilUtc?.toJson(),
      'weekStart': weekStart,
      'byDay': byDay.toJson(valueToJson: (v) => v.toJson()),
      'byMonthDay': byMonthDay.toJson(),
      'byYearDay': byYearDay.toJson(),
      'byWeekNo': byWeekNo.toJson(),
      'byMonth': byMonth.toJson(),
      'byHour': byHour.toJson(),
      'byMinute': byMinute.toJson(),
      'bySetPosition': bySetPosition.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventRule',
      'frequency': frequency.toJson(),
      'interval': interval,
      if (count != null) 'count': count,
      if (untilDate != null) 'untilDate': untilDate?.toJsonForProtocol(),
      if (untilUtc != null) 'untilUtc': untilUtc?.toJson(),
      'weekStart': weekStart,
      'byDay': byDay.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'byMonthDay': byMonthDay.toJson(),
      'byYearDay': byYearDay.toJson(),
      'byWeekNo': byWeekNo.toJson(),
      'byMonth': byMonth.toJson(),
      'byHour': byHour.toJson(),
      'byMinute': byMinute.toJson(),
      'bySetPosition': bySetPosition.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventRuleImpl extends CalendarEventRule {
  const _CalendarEventRuleImpl({
    required _i2q54gr5.CalendarEventFrequency frequency,
    int? interval,
    int? count,
    _i1bb5k1r.CalendarEventCivil? untilDate,
    DateTime? untilUtc,
    int? weekStart,
    required List<_iq7751s4.CalendarEventByDay> byDay,
    required List<int> byMonthDay,
    required List<int> byYearDay,
    required List<int> byWeekNo,
    required List<int> byMonth,
    required List<int> byHour,
    required List<int> byMinute,
    required List<int> bySetPosition,
  }) : super._(
         frequency: frequency,
         interval: interval,
         count: count,
         untilDate: untilDate,
         untilUtc: untilUtc,
         weekStart: weekStart,
         byDay: byDay,
         byMonthDay: byMonthDay,
         byYearDay: byYearDay,
         byWeekNo: byWeekNo,
         byMonth: byMonth,
         byHour: byHour,
         byMinute: byMinute,
         bySetPosition: bySetPosition,
       );

  /// Returns a shallow copy of this [CalendarEventRule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarEventRule copyWith({
    _i2q54gr5.CalendarEventFrequency? frequency,
    int? interval,
    Object? count = _Undefined,
    Object? untilDate = _Undefined,
    Object? untilUtc = _Undefined,
    int? weekStart,
    List<_iq7751s4.CalendarEventByDay>? byDay,
    List<int>? byMonthDay,
    List<int>? byYearDay,
    List<int>? byWeekNo,
    List<int>? byMonth,
    List<int>? byHour,
    List<int>? byMinute,
    List<int>? bySetPosition,
  }) {
    return CalendarEventRule(
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      count: count is int? ? count : this.count,
      untilDate: untilDate is _i1bb5k1r.CalendarEventCivil?
          ? untilDate
          : this.untilDate?.copyWith(),
      untilUtc: untilUtc is DateTime? ? untilUtc : this.untilUtc,
      weekStart: weekStart ?? this.weekStart,
      byDay: byDay ?? this.byDay.map((e0) => e0.copyWith()).toList(),
      byMonthDay: byMonthDay ?? this.byMonthDay.map((e0) => e0).toList(),
      byYearDay: byYearDay ?? this.byYearDay.map((e0) => e0).toList(),
      byWeekNo: byWeekNo ?? this.byWeekNo.map((e0) => e0).toList(),
      byMonth: byMonth ?? this.byMonth.map((e0) => e0).toList(),
      byHour: byHour ?? this.byHour.map((e0) => e0).toList(),
      byMinute: byMinute ?? this.byMinute.map((e0) => e0).toList(),
      bySetPosition:
          bySetPosition ?? this.bySetPosition.map((e0) => e0).toList(),
    );
  }
}
