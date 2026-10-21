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
import 'calendar_free_busy_coverage.dart' as _ia3n9q23;
import 'calendar_free_busy_period.dart' as _i82zcrxb;

abstract class CalendarFreeBusyView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarFreeBusyView._({
    required this.calendarId,
    required this.fromUtc,
    required this.untilUtc,
    required this.coverage,
    required this.periods,
  });

  factory CalendarFreeBusyView({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _ia3n9q23.CalendarFreeBusyCoverage coverage,
    required List<_i82zcrxb.CalendarFreeBusyPeriod> periods,
  }) = _CalendarFreeBusyViewImpl;

  factory CalendarFreeBusyView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyView(
      calendarId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      fromUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['fromUtc'],
      ),
      untilUtc: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['untilUtc'],
      ),
      coverage: _ia3n9q23.CalendarFreeBusyCoverage.fromJson(
        (jsonSerialization['coverage'] as String),
      ),
      periods: _ie4a1wrz.Protocol()
          .deserialize<List<_i82zcrxb.CalendarFreeBusyPeriod>>(
            jsonSerialization['periods'],
          ),
    );
  }

  _isc.UuidValue calendarId;

  DateTime fromUtc;

  DateTime untilUtc;

  _ia3n9q23.CalendarFreeBusyCoverage coverage;

  List<_i82zcrxb.CalendarFreeBusyPeriod> periods;

  /// Returns a shallow copy of this [CalendarFreeBusyView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarFreeBusyView copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _ia3n9q23.CalendarFreeBusyCoverage? coverage,
    List<_i82zcrxb.CalendarFreeBusyPeriod>? periods,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyView',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'coverage': coverage.toJson(),
      'periods': periods.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyView',
      'calendarId': calendarId.toJson(),
      'fromUtc': fromUtc.toJson(),
      'untilUtc': untilUtc.toJson(),
      'coverage': coverage.toJson(),
      'periods': periods.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyViewImpl extends CalendarFreeBusyView {
  _CalendarFreeBusyViewImpl({
    required _isc.UuidValue calendarId,
    required DateTime fromUtc,
    required DateTime untilUtc,
    required _ia3n9q23.CalendarFreeBusyCoverage coverage,
    required List<_i82zcrxb.CalendarFreeBusyPeriod> periods,
  }) : super._(
         calendarId: calendarId,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         coverage: coverage,
         periods: periods,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarFreeBusyView copyWith({
    _isc.UuidValue? calendarId,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _ia3n9q23.CalendarFreeBusyCoverage? coverage,
    List<_i82zcrxb.CalendarFreeBusyPeriod>? periods,
  }) {
    return CalendarFreeBusyView(
      calendarId: calendarId ?? this.calendarId,
      fromUtc: fromUtc ?? this.fromUtc,
      untilUtc: untilUtc ?? this.untilUtc,
      coverage: coverage ?? this.coverage,
      periods: periods ?? this.periods.map((e0) => e0.copyWith()).toList(),
    );
  }
}
