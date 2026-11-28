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

import 'calendar_incoming_publication_component_version.dart' as _ifx9uy7a;
import 'calendar_incoming_publication_link_view.dart' as _iojcncoe;

@_is.immutable
abstract class CalendarIncomingPublicationBundleLinkView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationBundleLinkView._({
    required this.link,
    this.acceptedComponentVersions,
    this.acceptedCancellationVersion,
    this.currentComponentVersions,
    bool? acceptedSourceUnavailable,
    bool? currentSourceUnavailable,
  }) : acceptedSourceUnavailable = acceptedSourceUnavailable ?? false,
       currentSourceUnavailable = currentSourceUnavailable ?? false;

  const factory CalendarIncomingPublicationBundleLinkView({
    required _iojcncoe.CalendarIncomingPublicationLinkView link,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    acceptedComponentVersions,
    _ifx9uy7a.CalendarIncomingPublicationComponentVersion?
    acceptedCancellationVersion,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    currentComponentVersions,
    bool? acceptedSourceUnavailable,
    bool? currentSourceUnavailable,
  }) = _CalendarIncomingPublicationBundleLinkViewImpl;

  factory CalendarIncomingPublicationBundleLinkView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationBundleLinkView(
      link: _ix00hwbf.Protocol()
          .deserialize<_iojcncoe.CalendarIncomingPublicationLinkView>(
            jsonSerialization['link'],
          ),
      acceptedComponentVersions:
          jsonSerialization['acceptedComponentVersions'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
            >(jsonSerialization['acceptedComponentVersions']),
      acceptedCancellationVersion:
          jsonSerialization['acceptedCancellationVersion'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              _ifx9uy7a.CalendarIncomingPublicationComponentVersion
            >(jsonSerialization['acceptedCancellationVersion']),
      currentComponentVersions:
          jsonSerialization['currentComponentVersions'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<
              List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>
            >(jsonSerialization['currentComponentVersions']),
      acceptedSourceUnavailable:
          jsonSerialization['acceptedSourceUnavailable'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['acceptedSourceUnavailable'],
            ),
      currentSourceUnavailable:
          jsonSerialization['currentSourceUnavailable'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['currentSourceUnavailable'],
            ),
    );
  }

  final _iojcncoe.CalendarIncomingPublicationLinkView link;

  final List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
  acceptedComponentVersions;

  final _ifx9uy7a.CalendarIncomingPublicationComponentVersion?
  acceptedCancellationVersion;

  final List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
  currentComponentVersions;

  final bool acceptedSourceUnavailable;

  final bool currentSourceUnavailable;

  /// Returns a shallow copy of this [CalendarIncomingPublicationBundleLinkView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationBundleLinkView copyWith({
    _iojcncoe.CalendarIncomingPublicationLinkView? link,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
        acceptedComponentVersions =
        const _is.$UndefinedList<
          _ifx9uy7a.CalendarIncomingPublicationComponentVersion
        >(),
    _ifx9uy7a.CalendarIncomingPublicationComponentVersion?
        acceptedCancellationVersion =
        const _UndefinedCalendarIncomingPublicationBundleLinkView$acceptedCancellationVersion(),
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
        currentComponentVersions =
        const _is.$UndefinedList<
          _ifx9uy7a.CalendarIncomingPublicationComponentVersion
        >(),
    bool? acceptedSourceUnavailable,
    bool? currentSourceUnavailable,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationBundleLinkView &&
            (identical(
                  other.link,
                  link,
                ) ||
                other.link == link) &&
            const _iss.DeepCollectionEquality().equals(
              other.acceptedComponentVersions,
              acceptedComponentVersions,
            ) &&
            (identical(
                  other.acceptedCancellationVersion,
                  acceptedCancellationVersion,
                ) ||
                other.acceptedCancellationVersion ==
                    acceptedCancellationVersion) &&
            const _iss.DeepCollectionEquality().equals(
              other.currentComponentVersions,
              currentComponentVersions,
            ) &&
            (identical(
                  other.acceptedSourceUnavailable,
                  acceptedSourceUnavailable,
                ) ||
                other.acceptedSourceUnavailable == acceptedSourceUnavailable) &&
            (identical(
                  other.currentSourceUnavailable,
                  currentSourceUnavailable,
                ) ||
                other.currentSourceUnavailable == currentSourceUnavailable);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      link,
      const _iss.DeepCollectionEquality().hash(acceptedComponentVersions),
      acceptedCancellationVersion,
      const _iss.DeepCollectionEquality().hash(currentComponentVersions),
      acceptedSourceUnavailable,
      currentSourceUnavailable,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationBundleLinkView',
      'link': link.toJson(),
      if (acceptedComponentVersions != null)
        'acceptedComponentVersions': acceptedComponentVersions?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      if (acceptedCancellationVersion != null)
        'acceptedCancellationVersion': acceptedCancellationVersion?.toJson(),
      if (currentComponentVersions != null)
        'currentComponentVersions': currentComponentVersions?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      'acceptedSourceUnavailable': acceptedSourceUnavailable,
      'currentSourceUnavailable': currentSourceUnavailable,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationBundleLinkView',
      'link': link.toJsonForProtocol(),
      if (acceptedComponentVersions != null)
        'acceptedComponentVersions': acceptedComponentVersions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      if (acceptedCancellationVersion != null)
        'acceptedCancellationVersion': acceptedCancellationVersion
            ?.toJsonForProtocol(),
      if (currentComponentVersions != null)
        'currentComponentVersions': currentComponentVersions?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
      'acceptedSourceUnavailable': acceptedSourceUnavailable,
      'currentSourceUnavailable': currentSourceUnavailable,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _UndefinedCalendarIncomingPublicationBundleLinkView$acceptedCancellationVersion
    extends _is.UndefinedSentinel
    implements _ifx9uy7a.CalendarIncomingPublicationComponentVersion {
  const _UndefinedCalendarIncomingPublicationBundleLinkView$acceptedCancellationVersion();
}

class _CalendarIncomingPublicationBundleLinkViewImpl
    extends CalendarIncomingPublicationBundleLinkView {
  const _CalendarIncomingPublicationBundleLinkViewImpl({
    required _iojcncoe.CalendarIncomingPublicationLinkView link,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    acceptedComponentVersions,
    _ifx9uy7a.CalendarIncomingPublicationComponentVersion?
    acceptedCancellationVersion,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
    currentComponentVersions,
    bool? acceptedSourceUnavailable,
    bool? currentSourceUnavailable,
  }) : super._(
         link: link,
         acceptedComponentVersions: acceptedComponentVersions,
         acceptedCancellationVersion: acceptedCancellationVersion,
         currentComponentVersions: currentComponentVersions,
         acceptedSourceUnavailable: acceptedSourceUnavailable,
         currentSourceUnavailable: currentSourceUnavailable,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationBundleLinkView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationBundleLinkView copyWith({
    _iojcncoe.CalendarIncomingPublicationLinkView? link,
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
        acceptedComponentVersions =
        const _is.$UndefinedList<
          _ifx9uy7a.CalendarIncomingPublicationComponentVersion
        >(),
    _ifx9uy7a.CalendarIncomingPublicationComponentVersion?
        acceptedCancellationVersion =
        const _UndefinedCalendarIncomingPublicationBundleLinkView$acceptedCancellationVersion(),
    List<_ifx9uy7a.CalendarIncomingPublicationComponentVersion>?
        currentComponentVersions =
        const _is.$UndefinedList<
          _ifx9uy7a.CalendarIncomingPublicationComponentVersion
        >(),
    bool? acceptedSourceUnavailable,
    bool? currentSourceUnavailable,
  }) {
    return CalendarIncomingPublicationBundleLinkView(
      link: link ?? this.link.copyWith(),
      acceptedComponentVersions:
          acceptedComponentVersions is _is.UndefinedSentinel
          ? this.acceptedComponentVersions?.map((e0) => e0.copyWith()).toList()
          : acceptedComponentVersions,
      acceptedCancellationVersion:
          acceptedCancellationVersion is _is.UndefinedSentinel
          ? this.acceptedCancellationVersion?.copyWith()
          : acceptedCancellationVersion,
      currentComponentVersions:
          currentComponentVersions is _is.UndefinedSentinel
          ? this.currentComponentVersions?.map((e0) => e0.copyWith()).toList()
          : currentComponentVersions,
      acceptedSourceUnavailable:
          acceptedSourceUnavailable ?? this.acceptedSourceUnavailable,
      currentSourceUnavailable:
          currentSourceUnavailable ?? this.currentSourceUnavailable,
    );
  }
}
