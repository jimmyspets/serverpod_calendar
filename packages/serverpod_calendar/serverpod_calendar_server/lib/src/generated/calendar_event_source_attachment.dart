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
abstract class CalendarEventSourceAttachment
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSourceAttachment._({
    required this.uri,
    this.mediaType,
    required this.explicitUri,
  });

  const factory CalendarEventSourceAttachment({
    required String uri,
    String? mediaType,
    required bool explicitUri,
  }) = _CalendarEventSourceAttachmentImpl;

  factory CalendarEventSourceAttachment.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventSourceAttachment(
      uri: jsonSerialization['uri'] as String,
      mediaType: jsonSerialization['mediaType'] as String?,
      explicitUri: _is.BoolJsonExtension.fromJson(
        jsonSerialization['explicitUri'],
      ),
    );
  }

  final String uri;

  final String? mediaType;

  final bool explicitUri;

  /// Returns a shallow copy of this [CalendarEventSourceAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSourceAttachment copyWith({
    String? uri,
    String? mediaType,
    bool? explicitUri,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventSourceAttachment &&
            (identical(
                  other.uri,
                  uri,
                ) ||
                other.uri == uri) &&
            (identical(
                  other.mediaType,
                  mediaType,
                ) ||
                other.mediaType == mediaType) &&
            (identical(
                  other.explicitUri,
                  explicitUri,
                ) ||
                other.explicitUri == explicitUri);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      uri,
      mediaType,
      explicitUri,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSourceAttachment',
      'uri': uri,
      if (mediaType != null) 'mediaType': mediaType,
      'explicitUri': explicitUri,
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

class _CalendarEventSourceAttachmentImpl extends CalendarEventSourceAttachment {
  const _CalendarEventSourceAttachmentImpl({
    required String uri,
    String? mediaType,
    required bool explicitUri,
  }) : super._(
         uri: uri,
         mediaType: mediaType,
         explicitUri: explicitUri,
       );

  /// Returns a shallow copy of this [CalendarEventSourceAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSourceAttachment copyWith({
    String? uri,
    Object? mediaType = _Undefined,
    bool? explicitUri,
  }) {
    return CalendarEventSourceAttachment(
      uri: uri ?? this.uri,
      mediaType: mediaType is String? ? mediaType : this.mediaType,
      explicitUri: explicitUri ?? this.explicitUri,
    );
  }
}
