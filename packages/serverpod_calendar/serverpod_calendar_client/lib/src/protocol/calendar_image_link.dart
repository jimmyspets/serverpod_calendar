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

abstract class CalendarImageLink
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarImageLink._({
    required this.uri,
    this.display,
    this.mediaType,
  });

  factory CalendarImageLink({
    required String uri,
    List<String>? display,
    String? mediaType,
  }) = _CalendarImageLinkImpl;

  factory CalendarImageLink.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarImageLink(
      uri: jsonSerialization['uri'] as String,
      display: jsonSerialization['display'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<List<String>>(
              jsonSerialization['display'],
            ),
      mediaType: jsonSerialization['mediaType'] as String?,
    );
  }

  String uri;

  List<String>? display;

  String? mediaType;

  /// Returns a shallow copy of this [CalendarImageLink]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarImageLink copyWith({
    String? uri,
    List<String>? display,
    String? mediaType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarImageLink',
      'uri': uri,
      if (display != null) 'display': display?.toJson(),
      if (mediaType != null) 'mediaType': mediaType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarImageLink',
      'uri': uri,
      if (display != null) 'display': display?.toJson(),
      if (mediaType != null) 'mediaType': mediaType,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarImageLinkImpl extends CalendarImageLink {
  _CalendarImageLinkImpl({
    required String uri,
    List<String>? display,
    String? mediaType,
  }) : super._(
         uri: uri,
         display: display,
         mediaType: mediaType,
       );

  /// Returns a shallow copy of this [CalendarImageLink]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarImageLink copyWith({
    String? uri,
    Object? display = _Undefined,
    Object? mediaType = _Undefined,
  }) {
    return CalendarImageLink(
      uri: uri ?? this.uri,
      display: display is List<String>?
          ? display
          : this.display?.map((e0) => e0).toList(),
      mediaType: mediaType is String? ? mediaType : this.mediaType,
    );
  }
}
