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
import 'calendar_availability_category_group.dart' as _iywbqexh;
import 'calendar_availability_extension.dart' as _ip5gybl4;
import 'calendar_availability_text.dart' as _itw42wa3;

@_is.immutable
abstract class CalendarAvailabilitySourceMetadata
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarAvailabilitySourceMetadata._({
    this.summary,
    this.description,
    this.location,
    this.categories,
    this.comments,
    this.contacts,
    this.extensions,
  });

  const factory CalendarAvailabilitySourceMetadata({
    _itw42wa3.CalendarAvailabilityText? summary,
    _itw42wa3.CalendarAvailabilityText? description,
    _itw42wa3.CalendarAvailabilityText? location,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categories,
    List<_itw42wa3.CalendarAvailabilityText>? comments,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
  }) = _CalendarAvailabilitySourceMetadataImpl;

  factory CalendarAvailabilitySourceMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilitySourceMetadata(
      summary: jsonSerialization['summary'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_itw42wa3.CalendarAvailabilityText>(
                  jsonSerialization['summary'],
                ),
      description: jsonSerialization['description'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_itw42wa3.CalendarAvailabilityText>(
                  jsonSerialization['description'],
                ),
      location: jsonSerialization['location'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_itw42wa3.CalendarAvailabilityText>(
                  jsonSerialization['location'],
                ),
      categories: jsonSerialization['categories'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_iywbqexh.CalendarAvailabilityCategoryGroup>>(
                  jsonSerialization['categories'],
                ),
      comments: jsonSerialization['comments'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_itw42wa3.CalendarAvailabilityText>>(
                  jsonSerialization['comments'],
                ),
      contacts: jsonSerialization['contacts'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_itw42wa3.CalendarAvailabilityText>>(
                  jsonSerialization['contacts'],
                ),
      extensions: jsonSerialization['extensions'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_ip5gybl4.CalendarAvailabilityExtension>>(
                  jsonSerialization['extensions'],
                ),
    );
  }

  final _itw42wa3.CalendarAvailabilityText? summary;

  final _itw42wa3.CalendarAvailabilityText? description;

  final _itw42wa3.CalendarAvailabilityText? location;

  final List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categories;

  final List<_itw42wa3.CalendarAvailabilityText>? comments;

  final List<_itw42wa3.CalendarAvailabilityText>? contacts;

  final List<_ip5gybl4.CalendarAvailabilityExtension>? extensions;

  /// Returns a shallow copy of this [CalendarAvailabilitySourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilitySourceMetadata copyWith({
    _itw42wa3.CalendarAvailabilityText? summary,
    _itw42wa3.CalendarAvailabilityText? description,
    _itw42wa3.CalendarAvailabilityText? location,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categories,
    List<_itw42wa3.CalendarAvailabilityText>? comments,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarAvailabilitySourceMetadata &&
            (identical(
                  other.summary,
                  summary,
                ) ||
                other.summary == summary) &&
            (identical(
                  other.description,
                  description,
                ) ||
                other.description == description) &&
            (identical(
                  other.location,
                  location,
                ) ||
                other.location == location) &&
            const _iss.DeepCollectionEquality().equals(
              other.categories,
              categories,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.comments,
              comments,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.contacts,
              contacts,
            ) &&
            const _iss.DeepCollectionEquality().equals(
              other.extensions,
              extensions,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      summary,
      description,
      location,
      const _iss.DeepCollectionEquality().hash(categories),
      const _iss.DeepCollectionEquality().hash(comments),
      const _iss.DeepCollectionEquality().hash(contacts),
      const _iss.DeepCollectionEquality().hash(extensions),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySourceMetadata',
      if (summary != null) 'summary': summary?.toJson(),
      if (description != null) 'description': description?.toJson(),
      if (location != null) 'location': location?.toJson(),
      if (categories != null)
        'categories': categories?.toJson(valueToJson: (v) => v.toJson()),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJson()),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJson()),
      if (extensions != null)
        'extensions': extensions?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilitySourceMetadata',
      if (summary != null) 'summary': summary?.toJsonForProtocol(),
      if (description != null) 'description': description?.toJsonForProtocol(),
      if (location != null) 'location': location?.toJsonForProtocol(),
      if (categories != null)
        'categories': categories?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (contacts != null)
        'contacts': contacts?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (extensions != null)
        'extensions': extensions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilitySourceMetadataImpl
    extends CalendarAvailabilitySourceMetadata {
  const _CalendarAvailabilitySourceMetadataImpl({
    _itw42wa3.CalendarAvailabilityText? summary,
    _itw42wa3.CalendarAvailabilityText? description,
    _itw42wa3.CalendarAvailabilityText? location,
    List<_iywbqexh.CalendarAvailabilityCategoryGroup>? categories,
    List<_itw42wa3.CalendarAvailabilityText>? comments,
    List<_itw42wa3.CalendarAvailabilityText>? contacts,
    List<_ip5gybl4.CalendarAvailabilityExtension>? extensions,
  }) : super._(
         summary: summary,
         description: description,
         location: location,
         categories: categories,
         comments: comments,
         contacts: contacts,
         extensions: extensions,
       );

  /// Returns a shallow copy of this [CalendarAvailabilitySourceMetadata]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilitySourceMetadata copyWith({
    Object? summary = _Undefined,
    Object? description = _Undefined,
    Object? location = _Undefined,
    Object? categories = _Undefined,
    Object? comments = _Undefined,
    Object? contacts = _Undefined,
    Object? extensions = _Undefined,
  }) {
    return CalendarAvailabilitySourceMetadata(
      summary: summary is _itw42wa3.CalendarAvailabilityText?
          ? summary
          : this.summary?.copyWith(),
      description: description is _itw42wa3.CalendarAvailabilityText?
          ? description
          : this.description?.copyWith(),
      location: location is _itw42wa3.CalendarAvailabilityText?
          ? location
          : this.location?.copyWith(),
      categories:
          categories is List<_iywbqexh.CalendarAvailabilityCategoryGroup>?
          ? categories
          : this.categories?.map((e0) => e0.copyWith()).toList(),
      comments: comments is List<_itw42wa3.CalendarAvailabilityText>?
          ? comments
          : this.comments?.map((e0) => e0.copyWith()).toList(),
      contacts: contacts is List<_itw42wa3.CalendarAvailabilityText>?
          ? contacts
          : this.contacts?.map((e0) => e0.copyWith()).toList(),
      extensions: extensions is List<_ip5gybl4.CalendarAvailabilityExtension>?
          ? extensions
          : this.extensions?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
