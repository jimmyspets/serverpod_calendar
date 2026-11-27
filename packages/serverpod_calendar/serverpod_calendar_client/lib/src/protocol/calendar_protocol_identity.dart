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

/// Read-only native calendar identity and whole-second UTC revision time.
@_isc.immutable
abstract class CalendarProtocolIdentity
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CalendarProtocolIdentity._({
    required this.uid,
    required this.lastModified,
  });

  const factory CalendarProtocolIdentity({
    required String uid,
    required DateTime lastModified,
  }) = _CalendarProtocolIdentityImpl;

  factory CalendarProtocolIdentity.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarProtocolIdentity(
      uid: jsonSerialization['uid'] as String,
      lastModified: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastModified'],
      ),
    );
  }

  final String uid;

  final DateTime lastModified;

  /// Returns a shallow copy of this [CalendarProtocolIdentity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CalendarProtocolIdentity copyWith({
    String? uid,
    DateTime? lastModified,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CalendarProtocolIdentity &&
            (identical(
                  other.uid,
                  uid,
                ) ||
                other.uid == uid) &&
            (identical(
                  other.lastModified,
                  lastModified,
                ) ||
                other.lastModified == lastModified);
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      uid,
      lastModified,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarProtocolIdentity',
      'uid': uid,
      'lastModified': lastModified.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_calendar.CalendarProtocolIdentity',
      'uid': uid,
      'lastModified': lastModified.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CalendarProtocolIdentityImpl extends CalendarProtocolIdentity {
  const _CalendarProtocolIdentityImpl({
    required String uid,
    required DateTime lastModified,
  }) : super._(
         uid: uid,
         lastModified: lastModified,
       );

  /// Returns a shallow copy of this [CalendarProtocolIdentity]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CalendarProtocolIdentity copyWith({
    String? uid,
    DateTime? lastModified,
  }) {
    return CalendarProtocolIdentity(
      uid: uid ?? this.uid,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
