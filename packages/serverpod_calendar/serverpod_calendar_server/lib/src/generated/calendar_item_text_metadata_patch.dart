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
import 'calendar_item_category_group.dart' as _i3iolgr8;
import 'calendar_item_comment.dart' as _itx19m90;
import 'calendar_item_text_metadata_field.dart' as _i12tuyl5;

@_is.immutable
abstract class CalendarItemTextMetadataPatch
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarItemTextMetadataPatch._({
    required this.selectedFields,
    this.url,
    this.classification,
    this.categoryGroups,
    this.comments,
  });

  const factory CalendarItemTextMetadataPatch({
    required List<_i12tuyl5.CalendarItemTextMetadataField> selectedFields,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  }) = _CalendarItemTextMetadataPatchImpl;

  factory CalendarItemTextMetadataPatch.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarItemTextMetadataPatch(
      selectedFields: _ix00hwbf.Protocol()
          .deserialize<List<_i12tuyl5.CalendarItemTextMetadataField>>(
            jsonSerialization['selectedFields'],
          ),
      url: jsonSerialization['url'] as String?,
      classification: jsonSerialization['classification'] as String?,
      categoryGroups: jsonSerialization['categoryGroups'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_i3iolgr8.CalendarItemCategoryGroup>>(
                  jsonSerialization['categoryGroups'],
                ),
      comments: jsonSerialization['comments'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_itx19m90.CalendarItemComment>>(
                  jsonSerialization['comments'],
                ),
    );
  }

  final List<_i12tuyl5.CalendarItemTextMetadataField> selectedFields;

  final String? url;

  final String? classification;

  final List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups;

  final List<_itx19m90.CalendarItemComment>? comments;

  /// Returns a shallow copy of this [CalendarItemTextMetadataPatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarItemTextMetadataPatch copyWith({
    List<_i12tuyl5.CalendarItemTextMetadataField>? selectedFields,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarItemTextMetadataPatch &&
            const _iss.DeepCollectionEquality().equals(
              other.selectedFields,
              selectedFields,
            ) &&
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
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(selectedFields),
      url,
      classification,
      const _iss.DeepCollectionEquality().hash(categoryGroups),
      const _iss.DeepCollectionEquality().hash(comments),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarItemTextMetadataPatch',
      'selectedFields': selectedFields.toJson(valueToJson: (v) => v.toJson()),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarItemTextMetadataPatch',
      'selectedFields': selectedFields.toJson(valueToJson: (v) => v.toJson()),
      if (url != null) 'url': url,
      if (classification != null) 'classification': classification,
      if (categoryGroups != null)
        'categoryGroups': categoryGroups?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarItemTextMetadataPatchImpl extends CalendarItemTextMetadataPatch {
  const _CalendarItemTextMetadataPatchImpl({
    required List<_i12tuyl5.CalendarItemTextMetadataField> selectedFields,
    String? url,
    String? classification,
    List<_i3iolgr8.CalendarItemCategoryGroup>? categoryGroups,
    List<_itx19m90.CalendarItemComment>? comments,
  }) : super._(
         selectedFields: selectedFields,
         url: url,
         classification: classification,
         categoryGroups: categoryGroups,
         comments: comments,
       );

  /// Returns a shallow copy of this [CalendarItemTextMetadataPatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarItemTextMetadataPatch copyWith({
    List<_i12tuyl5.CalendarItemTextMetadataField>? selectedFields,
    Object? url = _Undefined,
    Object? classification = _Undefined,
    Object? categoryGroups = _Undefined,
    Object? comments = _Undefined,
  }) {
    return CalendarItemTextMetadataPatch(
      selectedFields:
          selectedFields ?? this.selectedFields.map((e0) => e0).toList(),
      url: url is String? ? url : this.url,
      classification: classification is String?
          ? classification
          : this.classification,
      categoryGroups:
          categoryGroups is List<_i3iolgr8.CalendarItemCategoryGroup>?
          ? categoryGroups
          : this.categoryGroups?.map((e0) => e0.copyWith()).toList(),
      comments: comments is List<_itx19m90.CalendarItemComment>?
          ? comments
          : this.comments?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
