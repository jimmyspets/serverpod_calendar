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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

@_isc.immutable
abstract class CalendarInvitationDocument
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarInvitationDocument._({
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.sourceId,
    required this.text,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  const factory CalendarInvitationDocument({
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue sourceId,
    required String text,
  }) = _CalendarInvitationDocumentImpl;

  factory CalendarInvitationDocument.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationDocument(
      kind: jsonSerialization['kind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      sourceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      text: jsonSerialization['text'] as String,
    );
  }

  final _ilccsff7.CalendarInvitationSourceKind kind;

  final _isc.UuidValue sourceId;

  final String text;

  /// Returns a shallow copy of this [CalendarInvitationDocument]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarInvitationDocument copyWith({
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? sourceId,
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
                  other.kind,
                  kind,
                ) ||
                other.kind == kind) &&
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
      kind,
      sourceId,
      text,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationDocument',
      'kind': kind.toJson(),
      'sourceId': sourceId.toJson(),
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationDocument',
      'kind': kind.toJson(),
      'sourceId': sourceId.toJson(),
      'text': text,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarInvitationDocumentImpl extends CalendarInvitationDocument {
  const _CalendarInvitationDocumentImpl({
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required _isc.UuidValue sourceId,
    required String text,
  }) : super._(
         kind: kind,
         sourceId: sourceId,
         text: text,
       );

  /// Returns a shallow copy of this [CalendarInvitationDocument]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarInvitationDocument copyWith({
    _ilccsff7.CalendarInvitationSourceKind? kind,
    _isc.UuidValue? sourceId,
    String? text,
  }) {
    return CalendarInvitationDocument(
      kind: kind ?? this.kind,
      sourceId: sourceId ?? this.sourceId,
      text: text ?? this.text,
    );
  }
}
