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
abstract class CalendarTaskSourceAttachment
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarTaskSourceAttachment._({
    required this.uri,
    this.mediaType,
    required this.explicitUri,
  });

  const factory CalendarTaskSourceAttachment({
    required String uri,
    String? mediaType,
    required bool explicitUri,
  }) = _CalendarTaskSourceAttachmentImpl;

  factory CalendarTaskSourceAttachment.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskSourceAttachment(
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

  /// Returns a shallow copy of this [CalendarTaskSourceAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskSourceAttachment copyWith({
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
            other is CalendarTaskSourceAttachment &&
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
      '__className__': 'serverpod_calendar.CalendarTaskSourceAttachment',
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

class _CalendarTaskSourceAttachmentImpl extends CalendarTaskSourceAttachment {
  const _CalendarTaskSourceAttachmentImpl({
    required String uri,
    String? mediaType,
    required bool explicitUri,
  }) : super._(
         uri: uri,
         mediaType: mediaType,
         explicitUri: explicitUri,
       );

  /// Returns a shallow copy of this [CalendarTaskSourceAttachment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskSourceAttachment copyWith({
    String? uri,
    Object? mediaType = _Undefined,
    bool? explicitUri,
  }) {
    return CalendarTaskSourceAttachment(
      uri: uri ?? this.uri,
      mediaType: mediaType is String? ? mediaType : this.mediaType,
      explicitUri: explicitUri ?? this.explicitUri,
    );
  }
}
