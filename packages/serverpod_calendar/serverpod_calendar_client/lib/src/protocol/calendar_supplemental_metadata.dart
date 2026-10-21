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
import 'calendar_category.dart' as _icnza73c;
import 'calendar_image_link.dart' as _igf45b52;
import 'calendar_refresh_hint.dart' as _ifsfk5xq;

abstract class CalendarSupplementalMetadata
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CalendarSupplementalMetadata._({
    this.url,
    required this.categories,
    required this.images,
    this.refreshHint,
  });

  factory CalendarSupplementalMetadata({
    String? url,
    required List<_icnza73c.CalendarCategory> categories,
    required List<_igf45b52.CalendarImageLink> images,
    _ifsfk5xq.CalendarRefreshHint? refreshHint,
  }) = _CalendarSupplementalMetadataImpl;

  factory CalendarSupplementalMetadata.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSupplementalMetadata(
      url: jsonSerialization['url'] as String?,
      categories: _ie4a1wrz.Protocol()
          .deserialize<List<_icnza73c.CalendarCategory>>(
            jsonSerialization['categories'],
          ),
      images: _ie4a1wrz.Protocol()
          .deserialize<List<_igf45b52.CalendarImageLink>>(
            jsonSerialization['images'],
          ),
      refreshHint: jsonSerialization['refreshHint'] == null
          ? null
          : _ie4a1wrz.Protocol().deserialize<_ifsfk5xq.CalendarRefreshHint>(
              jsonSerialization['refreshHint'],
            ),
    );
  }

  String? url;

  List<_icnza73c.CalendarCategory> categories;

  List<_igf45b52.CalendarImageLink> images;

  _ifsfk5xq.CalendarRefreshHint? refreshHint;

  /// Returns a shallow copy of this [CalendarSupplementalMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarSupplementalMetadata copyWith({
    String? url,
    List<_icnza73c.CalendarCategory>? categories,
    List<_igf45b52.CalendarImageLink>? images,
    _ifsfk5xq.CalendarRefreshHint? refreshHint,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSupplementalMetadata',
      if (url != null) 'url': url,
      'categories': categories.toJson(valueToJson: (v) => v.toJson()),
      'images': images.toJson(valueToJson: (v) => v.toJson()),
      if (refreshHint != null) 'refreshHint': refreshHint?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarSupplementalMetadata',
      if (url != null) 'url': url,
      'categories': categories.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'images': images.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (refreshHint != null) 'refreshHint': refreshHint?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSupplementalMetadataImpl extends CalendarSupplementalMetadata {
  _CalendarSupplementalMetadataImpl({
    String? url,
    required List<_icnza73c.CalendarCategory> categories,
    required List<_igf45b52.CalendarImageLink> images,
    _ifsfk5xq.CalendarRefreshHint? refreshHint,
  }) : super._(
         url: url,
         categories: categories,
         images: images,
         refreshHint: refreshHint,
       );

  /// Returns a shallow copy of this [CalendarSupplementalMetadata]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarSupplementalMetadata copyWith({
    Object? url = _Undefined,
    List<_icnza73c.CalendarCategory>? categories,
    List<_igf45b52.CalendarImageLink>? images,
    Object? refreshHint = _Undefined,
  }) {
    return CalendarSupplementalMetadata(
      url: url is String? ? url : this.url,
      categories:
          categories ?? this.categories.map((e0) => e0.copyWith()).toList(),
      images: images ?? this.images.map((e0) => e0.copyWith()).toList(),
      refreshHint: refreshHint is _ifsfk5xq.CalendarRefreshHint?
          ? refreshHint
          : this.refreshHint?.copyWith(),
    );
  }
}
