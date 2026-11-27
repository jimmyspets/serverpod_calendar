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
import 'calendar_text_variant.dart' as _itcy22f3;

abstract class CalendarProtocolMetadata
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CalendarProtocolMetadata._({
    required this.names,
    required this.descriptions,
    this.color,
  });

  factory CalendarProtocolMetadata({
    required List<_itcy22f3.CalendarTextVariant> names,
    required List<_itcy22f3.CalendarTextVariant> descriptions,
    String? color,
  }) = _CalendarProtocolMetadataImpl;

  factory CalendarProtocolMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarProtocolMetadata(
      names: _ix00hwbf.Protocol()
          .deserialize<List<_itcy22f3.CalendarTextVariant>>(
            jsonSerialization['names'],
          ),
      descriptions: _ix00hwbf.Protocol()
          .deserialize<List<_itcy22f3.CalendarTextVariant>>(
            jsonSerialization['descriptions'],
          ),
      color: jsonSerialization['color'] as String?,
    );
  }

  List<_itcy22f3.CalendarTextVariant> names;

  List<_itcy22f3.CalendarTextVariant> descriptions;

  String? color;

  /// Returns a shallow copy of this [CalendarProtocolMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarProtocolMetadata copyWith({
    List<_itcy22f3.CalendarTextVariant>? names,
    List<_itcy22f3.CalendarTextVariant>? descriptions,
    String? color,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarProtocolMetadata',
      'names': names.toJson(valueToJson: (v) => v.toJson()),
      'descriptions': descriptions.toJson(valueToJson: (v) => v.toJson()),
      if (color != null) 'color': color,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarProtocolMetadata',
      'names': names.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'descriptions': descriptions.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (color != null) 'color': color,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarProtocolMetadataImpl extends CalendarProtocolMetadata {
  _CalendarProtocolMetadataImpl({
    required List<_itcy22f3.CalendarTextVariant> names,
    required List<_itcy22f3.CalendarTextVariant> descriptions,
    String? color,
  }) : super._(
         names: names,
         descriptions: descriptions,
         color: color,
       );

  /// Returns a shallow copy of this [CalendarProtocolMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarProtocolMetadata copyWith({
    List<_itcy22f3.CalendarTextVariant>? names,
    List<_itcy22f3.CalendarTextVariant>? descriptions,
    Object? color = _Undefined,
  }) {
    return CalendarProtocolMetadata(
      names: names ?? this.names.map((e0) => e0.copyWith()).toList(),
      descriptions:
          descriptions ?? this.descriptions.map((e0) => e0.copyWith()).toList(),
      color: color is String? ? color : this.color,
    );
  }
}
