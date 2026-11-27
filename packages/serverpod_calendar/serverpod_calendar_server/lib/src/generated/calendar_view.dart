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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_field_group.dart' as _i73hgz1s;
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_protocol_identity.dart' as _iyrimg3m;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_supplemental_metadata.dart' as _ixppc388;

abstract class CalendarView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarView._({
    required this.id,
    required this.revision,
    required this.disclosedGroups,
    this.displayName,
    this.description,
    this.color,
    this.availabilityZoneId,
    this.noRuleFallback,
    this.protocolIdentity,
    this.protocolMetadata,
    this.supplementalMetadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarView({
    required _is.UuidValue id,
    required int revision,
    required List<_i73hgz1s.CalendarFieldGroup> disclosedGroups,
    String? displayName,
    String? description,
    String? color,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
    _iyrimg3m.CalendarProtocolIdentity? protocolIdentity,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CalendarViewImpl;

  factory CalendarView.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      revision: jsonSerialization['revision'] as int,
      disclosedGroups: _ix00hwbf.Protocol()
          .deserialize<List<_i73hgz1s.CalendarFieldGroup>>(
            jsonSerialization['disclosedGroups'],
          ),
      displayName: jsonSerialization['displayName'] as String?,
      description: jsonSerialization['description'] as String?,
      color: jsonSerialization['color'] as String?,
      availabilityZoneId: jsonSerialization['availabilityZoneId'] as String?,
      noRuleFallback: jsonSerialization['noRuleFallback'] == null
          ? null
          : _itts4qyp.CalendarNoRuleFallback.fromJson(
              (jsonSerialization['noRuleFallback'] as String),
            ),
      protocolIdentity: jsonSerialization['protocolIdentity'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_iyrimg3m.CalendarProtocolIdentity>(
                  jsonSerialization['protocolIdentity'],
                ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_itchuj1l.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ixppc388.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  _is.UuidValue id;

  int revision;

  List<_i73hgz1s.CalendarFieldGroup> disclosedGroups;

  String? displayName;

  String? description;

  String? color;

  String? availabilityZoneId;

  _itts4qyp.CalendarNoRuleFallback? noRuleFallback;

  _iyrimg3m.CalendarProtocolIdentity? protocolIdentity;

  _itchuj1l.CalendarProtocolMetadata? protocolMetadata;

  _ixppc388.CalendarSupplementalMetadata? supplementalMetadata;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [CalendarView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarView copyWith({
    _is.UuidValue? id,
    int? revision,
    List<_i73hgz1s.CalendarFieldGroup>? disclosedGroups,
    String? displayName,
    String? description,
    String? color,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
    _iyrimg3m.CalendarProtocolIdentity? protocolIdentity,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarView',
      'id': id.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (displayName != null) 'displayName': displayName,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (availabilityZoneId != null) 'availabilityZoneId': availabilityZoneId,
      if (noRuleFallback != null) 'noRuleFallback': noRuleFallback?.toJson(),
      if (protocolIdentity != null)
        'protocolIdentity': protocolIdentity?.toJson(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarView',
      'id': id.toJson(),
      'revision': revision,
      'disclosedGroups': disclosedGroups.toJson(valueToJson: (v) => v.toJson()),
      if (displayName != null) 'displayName': displayName,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      if (availabilityZoneId != null) 'availabilityZoneId': availabilityZoneId,
      if (noRuleFallback != null) 'noRuleFallback': noRuleFallback?.toJson(),
      if (protocolIdentity != null)
        'protocolIdentity': protocolIdentity?.toJsonForProtocol(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJsonForProtocol(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJsonForProtocol(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarViewImpl extends CalendarView {
  _CalendarViewImpl({
    required _is.UuidValue id,
    required int revision,
    required List<_i73hgz1s.CalendarFieldGroup> disclosedGroups,
    String? displayName,
    String? description,
    String? color,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
    _iyrimg3m.CalendarProtocolIdentity? protocolIdentity,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         revision: revision,
         disclosedGroups: disclosedGroups,
         displayName: displayName,
         description: description,
         color: color,
         availabilityZoneId: availabilityZoneId,
         noRuleFallback: noRuleFallback,
         protocolIdentity: protocolIdentity,
         protocolMetadata: protocolMetadata,
         supplementalMetadata: supplementalMetadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarView copyWith({
    _is.UuidValue? id,
    int? revision,
    List<_i73hgz1s.CalendarFieldGroup>? disclosedGroups,
    Object? displayName = _Undefined,
    Object? description = _Undefined,
    Object? color = _Undefined,
    Object? availabilityZoneId = _Undefined,
    Object? noRuleFallback = _Undefined,
    Object? protocolIdentity = _Undefined,
    Object? protocolMetadata = _Undefined,
    Object? supplementalMetadata = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CalendarView(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      disclosedGroups:
          disclosedGroups ?? this.disclosedGroups.map((e0) => e0).toList(),
      displayName: displayName is String? ? displayName : this.displayName,
      description: description is String? ? description : this.description,
      color: color is String? ? color : this.color,
      availabilityZoneId: availabilityZoneId is String?
          ? availabilityZoneId
          : this.availabilityZoneId,
      noRuleFallback: noRuleFallback is _itts4qyp.CalendarNoRuleFallback?
          ? noRuleFallback
          : this.noRuleFallback,
      protocolIdentity: protocolIdentity is _iyrimg3m.CalendarProtocolIdentity?
          ? protocolIdentity
          : this.protocolIdentity?.copyWith(),
      protocolMetadata: protocolMetadata is _itchuj1l.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _ixppc388.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
