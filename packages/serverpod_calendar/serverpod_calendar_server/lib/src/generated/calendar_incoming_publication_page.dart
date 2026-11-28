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

import 'calendar_incoming_publication_view.dart' as _i2n6sv2t;

@_is.immutable
abstract class CalendarIncomingPublicationPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarIncomingPublicationPage._({
    required this.entries,
    this.continuation,
  });

  const factory CalendarIncomingPublicationPage({
    required List<_i2n6sv2t.CalendarIncomingPublicationView> entries,
    String? continuation,
  }) = _CalendarIncomingPublicationPageImpl;

  factory CalendarIncomingPublicationPage.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationPage(
      entries: _ix00hwbf.Protocol()
          .deserialize<List<_i2n6sv2t.CalendarIncomingPublicationView>>(
            jsonSerialization['entries'],
          ),
      continuation: jsonSerialization['continuation'] as String?,
    );
  }

  final List<_i2n6sv2t.CalendarIncomingPublicationView> entries;

  final String? continuation;

  /// Returns a shallow copy of this [CalendarIncomingPublicationPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationPage copyWith({
    List<_i2n6sv2t.CalendarIncomingPublicationView>? entries,
    String? continuation,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarIncomingPublicationPage &&
            const _iss.DeepCollectionEquality().equals(
              other.entries,
              entries,
            ) &&
            (identical(
                  other.continuation,
                  continuation,
                ) ||
                other.continuation == continuation);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      const _iss.DeepCollectionEquality().hash(entries),
      continuation,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJson()),
      if (continuation != null) 'continuation': continuation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationPage',
      'entries': entries.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (continuation != null) 'continuation': continuation,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationPageImpl
    extends CalendarIncomingPublicationPage {
  const _CalendarIncomingPublicationPageImpl({
    required List<_i2n6sv2t.CalendarIncomingPublicationView> entries,
    String? continuation,
  }) : super._(
         entries: entries,
         continuation: continuation,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationPage copyWith({
    List<_i2n6sv2t.CalendarIncomingPublicationView>? entries,
    Object? continuation = _Undefined,
  }) {
    return CalendarIncomingPublicationPage(
      entries: entries ?? this.entries.map((e0) => e0.copyWith()).toList(),
      continuation: continuation is String? ? continuation : this.continuation,
    );
  }
}
