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

import 'calendar_incoming_publication_component_version.dart' as _ifx9uy7a;
import 'calendar_incoming_publication_source_view.dart' as _ikrc1px6;

@_isc.immutable
abstract class CalendarIncomingPublicationBundleSourceView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarIncomingPublicationBundleSourceView._({
    required this.source,
    required this.componentVersions,
  });

  const factory CalendarIncomingPublicationBundleSourceView({
    required _ikrc1px6.CalendarIncomingPublicationSourceView source,
    required List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
    componentVersions,
  }) = _CalendarIncomingPublicationBundleSourceViewImpl;

  factory CalendarIncomingPublicationBundleSourceView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationBundleSourceView(
      source: _ie4a1wrz.Protocol()
          .deserialize<_ikrc1px6.CalendarIncomingPublicationSourceView>(
            jsonSerialization['source'],
          ),
      componentVersions: _ie4a1wrz.Protocol()
          .deserialize<
            List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
          >(jsonSerialization['componentVersions']),
    );
  }

  final _ikrc1px6.CalendarIncomingPublicationSourceView source;

  final List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
  componentVersions;

  /// Returns a shallow copy of this [CalendarIncomingPublicationBundleSourceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarIncomingPublicationBundleSourceView copyWith({
    _ikrc1px6.CalendarIncomingPublicationSourceView? source,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    componentVersions,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationBundleSourceView &&
            (identical(
                  other.source,
                  source,
                ) ||
                other.source == source) &&
            const _iss.DeepCollectionEquality().equals(
              other.componentVersions,
              componentVersions,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      source,
      const _iss.DeepCollectionEquality().hash(componentVersions),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationBundleSourceView',
      'source': source.toJson(),
      'componentVersions': componentVersions.toJson(
        valueToJson: (v) => v.toJson(),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationBundleSourceView',
      'source': source.toJsonForProtocol(),
      'componentVersions': componentVersions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationBundleSourceViewImpl
    extends CalendarIncomingPublicationBundleSourceView {
  const _CalendarIncomingPublicationBundleSourceViewImpl({
    required _ikrc1px6.CalendarIncomingPublicationSourceView source,
    required List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
    componentVersions,
  }) : super._(
         source: source,
         componentVersions: componentVersions,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationBundleSourceView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarIncomingPublicationBundleSourceView copyWith({
    _ikrc1px6.CalendarIncomingPublicationSourceView? source,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    componentVersions,
  }) {
    return CalendarIncomingPublicationBundleSourceView(
      source: source ?? this.source.copyWith(),
      componentVersions:
          componentVersions ??
          this.componentVersions.map((e0) => e0.copyWith()).toList(),
    );
  }
}
