/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_calendar_client/serverpod_calendar_client.dart'
    as _imrxcdin;
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_credential_view.dart'
    as _igll1u2j;
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_view.dart'
    as _i8pso0cp;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_notifications_client/serverpod_notifications_client.dart'
    as _i9wvmat7;
import 'calendar_feed_created_credential.dart' as _i6l7w5f5;
import 'calendar_feed_credential_view.dart' as _i9qbm9qw;
import 'calendar_feed_exception.dart' as _iqqb7mk1;
import 'calendar_feed_failure_code.dart' as _iuwqxkhl;
import 'calendar_feed_settings.dart' as _i7sjkcc2;
import 'calendar_feed_view.dart' as _ibxmw9q3;
export 'calendar_feed_created_credential.dart';
export 'calendar_feed_credential_view.dart';
export 'calendar_feed_exception.dart';
export 'calendar_feed_failure_code.dart';
export 'calendar_feed_settings.dart';
export 'calendar_feed_view.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_isc.SerializationManager> _hostProtocols = {};

  void registerHostProtocol(
    String projectName,
    _isc.SerializationManager protocol,
  ) {
    _hostProtocols.add(protocol);
  }

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('serverpod_calendar_feed.')) return className;
    return className.substring(24);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6l7w5f5.CalendarFeedCreatedCredential) {
      return _i6l7w5f5.CalendarFeedCreatedCredential.fromJson(data) as T;
    }
    if (t == _i9qbm9qw.CalendarFeedCredentialView) {
      return _i9qbm9qw.CalendarFeedCredentialView.fromJson(data) as T;
    }
    if (t == _iqqb7mk1.CalendarFeedException) {
      return _iqqb7mk1.CalendarFeedException.fromJson(data) as T;
    }
    if (t == _iuwqxkhl.CalendarFeedFailureCode) {
      return _iuwqxkhl.CalendarFeedFailureCode.fromJson(data) as T;
    }
    if (t == _i7sjkcc2.CalendarFeedSettings) {
      return _i7sjkcc2.CalendarFeedSettings.fromJson(data) as T;
    }
    if (t == _ibxmw9q3.CalendarFeedView) {
      return _ibxmw9q3.CalendarFeedView.fromJson(data) as T;
    }
    if (t == _isc.getType<_i6l7w5f5.CalendarFeedCreatedCredential?>()) {
      return (data != null
              ? _i6l7w5f5.CalendarFeedCreatedCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i9qbm9qw.CalendarFeedCredentialView?>()) {
      return (data != null
              ? _i9qbm9qw.CalendarFeedCredentialView.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iqqb7mk1.CalendarFeedException?>()) {
      return (data != null
              ? _iqqb7mk1.CalendarFeedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_iuwqxkhl.CalendarFeedFailureCode?>()) {
      return (data != null
              ? _iuwqxkhl.CalendarFeedFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i7sjkcc2.CalendarFeedSettings?>()) {
      return (data != null
              ? _i7sjkcc2.CalendarFeedSettings.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ibxmw9q3.CalendarFeedView?>()) {
      return (data != null ? _ibxmw9q3.CalendarFeedView.fromJson(data) : null)
          as T;
    }
    if (t == List<_isc.UuidValue>) {
      return (data as List).map((e) => deserialize<_isc.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i8pso0cp.CalendarFeedView>) {
      return (data as List)
              .map((e) => deserialize<_i8pso0cp.CalendarFeedView>(e))
              .toList()
          as T;
    }
    if (t == List<_igll1u2j.CalendarFeedCredentialView>) {
      return (data as List)
              .map((e) => deserialize<_igll1u2j.CalendarFeedCredentialView>(e))
              .toList()
          as T;
    }
    try {
      return _imrxcdin.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i9wvmat7.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6l7w5f5.CalendarFeedCreatedCredential =>
        'CalendarFeedCreatedCredential',
      _i9qbm9qw.CalendarFeedCredentialView => 'CalendarFeedCredentialView',
      _iqqb7mk1.CalendarFeedException => 'CalendarFeedException',
      _iuwqxkhl.CalendarFeedFailureCode => 'CalendarFeedFailureCode',
      _i7sjkcc2.CalendarFeedSettings => 'CalendarFeedSettings',
      _ibxmw9q3.CalendarFeedView => 'CalendarFeedView',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_calendar_feed.',
        '',
      );
    }

    switch (data) {
      case _i6l7w5f5.CalendarFeedCreatedCredential():
        return 'CalendarFeedCreatedCredential';
      case _i9qbm9qw.CalendarFeedCredentialView():
        return 'CalendarFeedCredentialView';
      case _iqqb7mk1.CalendarFeedException():
        return 'CalendarFeedException';
      case _iuwqxkhl.CalendarFeedFailureCode():
        return 'CalendarFeedFailureCode';
      case _i7sjkcc2.CalendarFeedSettings():
        return 'CalendarFeedSettings';
      case _ibxmw9q3.CalendarFeedView():
        return 'CalendarFeedView';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CalendarFeedCreatedCredential') {
      return deserialize<_i6l7w5f5.CalendarFeedCreatedCredential>(data['data']);
    }
    if (dataClassName == 'CalendarFeedCredentialView') {
      return deserialize<_i9qbm9qw.CalendarFeedCredentialView>(data['data']);
    }
    if (dataClassName == 'CalendarFeedException') {
      return deserialize<_iqqb7mk1.CalendarFeedException>(data['data']);
    }
    if (dataClassName == 'CalendarFeedFailureCode') {
      return deserialize<_iuwqxkhl.CalendarFeedFailureCode>(data['data']);
    }
    if (dataClassName == 'CalendarFeedSettings') {
      return deserialize<_i7sjkcc2.CalendarFeedSettings>(data['data']);
    }
    if (dataClassName == 'CalendarFeedView') {
      return deserialize<_ibxmw9q3.CalendarFeedView>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  Object? dynamicFieldToJson(
    Object? object, {
    bool forProtocol = false,
  }) {
    if ((object is List || object is Set || object is Map) ||
        getClassNameForObject(object) != null) {
      return super.dynamicFieldToJson(object, forProtocol: forProtocol);
    }
    for (final protocol in _hostProtocols) {
      final className = protocol.getClassNameForObject(object);
      if (className == null) continue;
      final host = protocol.getModuleName();
      final wrapped = {
        'className': className.contains('.') ? className : '$host.$className',
        'data': object,
      };
      return forProtocol
          ? _isc.SerializationManager.toEncodableForProtocol(wrapped)
          : _isc.SerializationManager.toEncodable(wrapped);
    }
    return super.dynamicFieldToJson(object, forProtocol: forProtocol);
  }

  @override
  dynamic deserializeDynamicFieldValue(Object? value) {
    if (value == null) return null;
    if (value is! Map<String, dynamic> || value['className'] is! String) {
      throw FormatException(
        'Dynamic fields are encoded as a Map with className and data, but got '
        '${value.runtimeType} instead.',
      );
    }
    final className = value['className'] as String;
    for (final protocol in _hostProtocols) {
      final host = protocol.getModuleName();
      final hostPrefix = '$host.';
      if (className.startsWith(hostPrefix)) {
        final strippedClassName = className.substring(hostPrefix.length);
        if (strippedClassName.contains('.')) {
          throw FormatException(
            'Dynamic field className must not use multiple prefixes: $className',
          );
        }
        final hostData = Map<String, dynamic>.from(value);
        hostData['className'] = strippedClassName;
        return protocol.deserializeByClassName(hostData);
      }
    }
    if (className.contains('.')) {
      for (final protocol in _hostProtocols) {
        try {
          return protocol.deserializeByClassName(value);
        } on _isc.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  String getModuleName() => 'serverpod_calendar_feed';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _imrxcdin.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i9wvmat7.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
