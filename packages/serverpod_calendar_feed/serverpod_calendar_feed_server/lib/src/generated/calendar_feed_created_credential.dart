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
import 'package:serverpod_calendar_feed_server/src/generated/protocol.dart'
    as _i0kswevi;
import 'calendar_feed_credential_view.dart' as _i9qbm9qw;

@_is.immutable
abstract class CalendarFeedCreatedCredential
    implements _is.SerializableModel, _is.ProtocolSerialization {
  const CalendarFeedCreatedCredential._({
    required this.credential,
    required this.url,
  });

  const factory CalendarFeedCreatedCredential({
    required _i9qbm9qw.CalendarFeedCredentialView credential,
    required String url,
  }) = _CalendarFeedCreatedCredentialImpl;

  factory CalendarFeedCreatedCredential.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedCreatedCredential(
      credential: _i0kswevi.Protocol()
          .deserialize<_i9qbm9qw.CalendarFeedCredentialView>(
            jsonSerialization['credential'],
          ),
      url: jsonSerialization['url'] as String,
    );
  }

  final _i9qbm9qw.CalendarFeedCredentialView credential;

  final String url;

  /// Returns a shallow copy of this [CalendarFeedCreatedCredential]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedCreatedCredential copyWith({
    _i9qbm9qw.CalendarFeedCredentialView? credential,
    String? url,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarFeedCreatedCredential &&
            (identical(
                  other.credential,
                  credential,
                ) ||
                other.credential == credential) &&
            (identical(
                  other.url,
                  url,
                ) ||
                other.url == url);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      credential,
      url,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedCreatedCredential',
      'credential': credential.toJson(),
      'url': url,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedCreatedCredential',
      'credential': credential.toJsonForProtocol(),
      'url': url,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFeedCreatedCredentialImpl extends CalendarFeedCreatedCredential {
  const _CalendarFeedCreatedCredentialImpl({
    required _i9qbm9qw.CalendarFeedCredentialView credential,
    required String url,
  }) : super._(
         credential: credential,
         url: url,
       );

  /// Returns a shallow copy of this [CalendarFeedCreatedCredential]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedCreatedCredential copyWith({
    _i9qbm9qw.CalendarFeedCredentialView? credential,
    String? url,
  }) {
    return CalendarFeedCreatedCredential(
      credential: credential ?? this.credential.copyWith(),
      url: url ?? this.url,
    );
  }
}
