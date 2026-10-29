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
abstract class CalendarInvitationDocument
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarInvitationDocument._({
    required this.sourceId,
    required this.text,
  });

  const factory CalendarInvitationDocument({
    required _is.UuidValue sourceId,
    required String text,
  }) = _CalendarInvitationDocumentImpl;

  factory CalendarInvitationDocument.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationDocument(
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      text: jsonSerialization['text'] as String,
    );
  }

  final _is.UuidValue sourceId;

  final String text;

  /// Returns a shallow copy of this [CalendarInvitationDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationDocument copyWith({
    _is.UuidValue? sourceId,
    String? text,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarInvitationDocument &&
            (identical(
                  other.sourceId,
                  sourceId,
                ) ||
                other.sourceId == sourceId) &&
            (identical(
                  other.text,
                  text,
                ) ||
                other.text == text);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      sourceId,
      text,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationDocument',
      'sourceId': sourceId.toJson(),
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationDocument',
      'sourceId': sourceId.toJson(),
      'text': text,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationDocumentImpl extends CalendarInvitationDocument {
  const _CalendarInvitationDocumentImpl({
    required _is.UuidValue sourceId,
    required String text,
  }) : super._(
         sourceId: sourceId,
         text: text,
       );

  /// Returns a shallow copy of this [CalendarInvitationDocument]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationDocument copyWith({
    _is.UuidValue? sourceId,
    String? text,
  }) {
    return CalendarInvitationDocument(
      sourceId: sourceId ?? this.sourceId,
      text: text ?? this.text,
    );
  }
}
