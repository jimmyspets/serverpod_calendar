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
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'calendar_event_source_category_group.dart' as _iui013s0;
import 'calendar_event_source_text.dart' as _iwa6orjz;

@_is.immutable
abstract class CalendarEventSourceMetadata
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarEventSourceMetadata._({
    this.url,
    this.classification,
    required this.categoryGroups,
    required this.comments,
    required this.contacts,
  });

  const factory CalendarEventSourceMetadata({
    String? url,
    String? classification,
    required List<_iui013s0.CalendarEventSourceCategoryGroup> categoryGroups,
    required List<_iwa6orjz.CalendarEventSourceText> comments,
    required List<_iwa6orjz.CalendarEventSourceText> contacts,
  }) = _CalendarEventSourceMetadataImpl;

  factory CalendarEventSourceMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventSourceMetadata(
      url: jsonSerialization['url'] as String?,
      classification: jsonSerialization['classification'] as String?,
      categoryGroups: _ix00hwbf.Protocol()
          .deserialize<List<_iui013s0.CalendarEventSourceCategoryGroup>>(
            jsonSerialization['categoryGroups'],
          ),
      comments: _ix00hwbf.Protocol()
          .deserialize<List<_iwa6orjz.CalendarEventSourceText>>(
            jsonSerialization['comments'],
          ),
      contacts: _ix00hwbf.Protocol()
          .deserialize<List<_iwa6orjz.CalendarEventSourceText>>(
            jsonSerialization['contacts'],
          ),
    );
  }

  final String? url;

  final String? classification;

  final List<_iui013s0.CalendarEventSourceCategoryGroup> categoryGroups;

  final List<_iwa6orjz.CalendarEventSourceText> comments;

  final List<_iwa6orjz.CalendarEventSourceText> contacts;

  /// Returns a shallow copy of this [CalendarEventSourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventSourceMetadata copyWith({
    String? url,
    String? classification,
    List<_iui013s0.CalendarEventSourceCategoryGroup>? categoryGroups,
    List<_iwa6orjz.CalendarEventSourceText>? comments,
    List<_iwa6orjz.CalendarEventSourceText>? contacts,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarEventSourceMetadata &&
            (identical(
                  other.url,
                  url,
                ) ||
                other.url == url) &&
            (identical(
                  other.classification,
                  classification,
                ) ||
                other.classification == classification) &&
            const _iss.DeepCollectionEquality().equals(
              other.categoryGroups,
              categoryGroups,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.comments,
              comments,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.contacts,
              contacts,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      url,
      classification,
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(comments),
      const _iss.DeepCollectionEquality().hash(contacts),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventSourceMetadata',
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      'categoryGroups': categoryGroups.toJson(valueToJson: (v) => v.toJson()),
      'comments': comments.toJson(valueToJson: (v) => v.toJson()),
      'contacts': contacts.toJson(valueToJson: (v) => v.toJson()),
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

class _CalendarEventSourceMetadataImpl extends CalendarEventSourceMetadata {
  const _CalendarEventSourceMetadataImpl({
    String? url,
    String? classification,
    required List<_iui013s0.CalendarEventSourceCategoryGroup> categoryGroups,
    required List<_iwa6orjz.CalendarEventSourceText> comments,
    required List<_iwa6orjz.CalendarEventSourceText> contacts,
  }) : super._(
         url: url,
         classification: classification,
         categoryGroups: categoryGroups,
         comments: comments,
         contacts: contacts,
       );

  /// Returns a shallow copy of this [CalendarEventSourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventSourceMetadata copyWith({
    Object? url = _Undefined,
    Object? classification = _Undefined,
    List<_iui013s0.CalendarEventSourceCategoryGroup>? categoryGroups,
    List<_iwa6orjz.CalendarEventSourceText>? comments,
    List<_iwa6orjz.CalendarEventSourceText>? contacts,
  }) {
    return CalendarEventSourceMetadata(
      url: url is String? ? url : this.url,
      classification: classification is String?
          ? classification
          : this.classification,
      categoryGroups:
          categoryGroups ??
          this.categoryGroups.map((e0) => e0.copyWith()).toList(),
      comments: comments ?? this.comments.map((e0) => e0.copyWith()).toList(),
      contacts: contacts ?? this.contacts.map((e0) => e0.copyWith()).toList(),
    );
  }
}
