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
import 'calendar_event_origin.dart' as _ipbrznp8;
import 'calendar_scheduling_delivery_view.dart' as _i63ky642;

@_isc.immutable
abstract class CalendarSchedulingView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarSchedulingView._({
    required this.eventId,
    required this.eventRevision,
    required this.origin,
    this.organizerAddress,
    this.publicationId,
    this.publishedAt,
    this.method,
    required this.hasLocalChanges,
    required this.deliveries,
  });

  const factory CalendarSchedulingView({
    required _isc.UuidValue eventId,
    required int eventRevision,
    required _ipbrznp8.CalendarEventOrigin origin,
    String? organizerAddress,
    _isc.UuidValue? publicationId,
    DateTime? publishedAt,
    String? method,
    required bool hasLocalChanges,
    required List<_i63ky642.CalendarSchedulingDeliveryView> deliveries,
  }) = _CalendarSchedulingViewImpl;

  factory CalendarSchedulingView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingView(
      eventId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      eventRevision: jsonSerialization['eventRevision'] as int,
      origin: _ipbrznp8.CalendarEventOrigin.fromJson(
        (jsonSerialization['origin'] as String),
      ),
      organizerAddress: jsonSerialization['organizerAddress'] as String?,
      publicationId: jsonSerialization['publicationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['publicationId'],
            ),
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      method: jsonSerialization['method'] as String?,
      hasLocalChanges: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['hasLocalChanges'],
      ),
      deliveries: _ie4a1wrz.Protocol()
          .deserialize<List<_i63ky642.CalendarSchedulingDeliveryView>>(
            jsonSerialization['deliveries'],
          ),
    );
  }

  final _isc.UuidValue eventId;

  final int eventRevision;

  final _ipbrznp8.CalendarEventOrigin origin;

  final String? organizerAddress;

  final _isc.UuidValue? publicationId;

  final DateTime? publishedAt;

  final String? method;

  final bool hasLocalChanges;

  final List<_i63ky642.CalendarSchedulingDeliveryView> deliveries;

  /// Returns a shallow copy of this [CalendarSchedulingView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSchedulingView copyWith({
    _isc.UuidValue? eventId,
    int? eventRevision,
    _ipbrznp8.CalendarEventOrigin? origin,
    String? organizerAddress,
    _isc.UuidValue? publicationId,
    DateTime? publishedAt,
    String? method,
    bool? hasLocalChanges,
    List<_i63ky642.CalendarSchedulingDeliveryView>? deliveries,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarSchedulingView &&
            (identical(
                  other.eventId,
                  eventId,
                ) ||
                other.eventId == eventId) &&
            (identical(
                  other.eventRevision,
                  eventRevision,
                ) ||
                other.eventRevision == eventRevision) &&
            (identical(
                  other.origin,
                  origin,
                ) ||
                other.origin == origin) &&
            (identical(
                  other.organizerAddress,
                  organizerAddress,
                ) ||
                other.organizerAddress == organizerAddress) &&
            (identical(
                  other.publicationId,
                  publicationId,
                ) ||
                other.publicationId == publicationId) &&
            (identical(
                  other.publishedAt,
                  publishedAt,
                ) ||
                other.publishedAt == publishedAt) &&
            (identical(
                  other.method,
                  method,
                ) ||
                other.method == method) &&
            (identical(
                  other.hasLocalChanges,
                  hasLocalChanges,
                ) ||
                other.hasLocalChanges == hasLocalChanges) &&
            const _iss.DeepCollectionEquality().equals(
              other.deliveries,
              deliveries,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      eventId,
      eventRevision,
      origin,
      organizerAddress,
      publicationId,
      publishedAt,
      method,
      hasLocalChanges,
      const _iss.DeepCollectionEquality().hash(deliveries),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingView',
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'origin': origin.toJson(),
      if (organizerAddress != null) 'organizerAddress': organizerAddress,
      if (publicationId != null) 'publicationId': publicationId?.toJson(),
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (method != null) 'method': method,
      'hasLocalChanges': hasLocalChanges,
      'deliveries': deliveries.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingView',
      'eventId': eventId.toJson(),
      'eventRevision': eventRevision,
      'origin': origin.toJson(),
      if (organizerAddress != null) 'organizerAddress': organizerAddress,
      if (publicationId != null) 'publicationId': publicationId?.toJson(),
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (method != null) 'method': method,
      'hasLocalChanges': hasLocalChanges,
      'deliveries': deliveries.toJson(
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

class _CalendarSchedulingViewImpl extends CalendarSchedulingView {
  const _CalendarSchedulingViewImpl({
    required _isc.UuidValue eventId,
    required int eventRevision,
    required _ipbrznp8.CalendarEventOrigin origin,
    String? organizerAddress,
    _isc.UuidValue? publicationId,
    DateTime? publishedAt,
    String? method,
    required bool hasLocalChanges,
    required List<_i63ky642.CalendarSchedulingDeliveryView> deliveries,
  }) : super._(
         eventId: eventId,
         eventRevision: eventRevision,
         origin: origin,
         organizerAddress: organizerAddress,
         publicationId: publicationId,
         publishedAt: publishedAt,
         method: method,
         hasLocalChanges: hasLocalChanges,
         deliveries: deliveries,
       );

  /// Returns a shallow copy of this [CalendarSchedulingView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSchedulingView copyWith({
    _isc.UuidValue? eventId,
    int? eventRevision,
    _ipbrznp8.CalendarEventOrigin? origin,
    Object? organizerAddress = _Undefined,
    Object? publicationId = _Undefined,
    Object? publishedAt = _Undefined,
    Object? method = _Undefined,
    bool? hasLocalChanges,
    List<_i63ky642.CalendarSchedulingDeliveryView>? deliveries,
  }) {
    return CalendarSchedulingView(
      eventId: eventId ?? this.eventId,
      eventRevision: eventRevision ?? this.eventRevision,
      origin: origin ?? this.origin,
      organizerAddress: organizerAddress is String?
          ? organizerAddress
          : this.organizerAddress,
      publicationId: publicationId is _isc.UuidValue?
          ? publicationId
          : this.publicationId,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      method: method is String? ? method : this.method,
      hasLocalChanges: hasLocalChanges ?? this.hasLocalChanges,
      deliveries:
          deliveries ?? this.deliveries.map((e0) => e0.copyWith()).toList(),
    );
  }
}
