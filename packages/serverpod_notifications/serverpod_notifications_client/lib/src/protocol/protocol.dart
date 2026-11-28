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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'notification_delivery_state.dart' as _is3a40pv;
import 'notification_exception.dart' as _i299pw2t;
import 'notification_failure_code.dart' as _i909e29g;
import 'notification_hint.dart' as _i6bnr478;
import 'notification_page.dart' as _iw4dnqzf;
import 'notification_view.dart' as _i86vfscw;
export 'notification_delivery_state.dart';
export 'notification_exception.dart';
export 'notification_failure_code.dart';
export 'notification_hint.dart';
export 'notification_page.dart';
export 'notification_view.dart';
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
    if (!className.startsWith('serverpod_notifications.')) return className;
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

    if (t == _is3a40pv.NotificationDeliveryState) {
      return _is3a40pv.NotificationDeliveryState.fromJson(data) as T;
    }
    if (t == _i299pw2t.NotificationException) {
      return _i299pw2t.NotificationException.fromJson(data) as T;
    }
    if (t == _i909e29g.NotificationFailureCode) {
      return _i909e29g.NotificationFailureCode.fromJson(data) as T;
    }
    if (t == _i6bnr478.NotificationHint) {
      return _i6bnr478.NotificationHint.fromJson(data) as T;
    }
    if (t == _iw4dnqzf.NotificationPage) {
      return _iw4dnqzf.NotificationPage.fromJson(data) as T;
    }
    if (t == _i86vfscw.NotificationView) {
      return _i86vfscw.NotificationView.fromJson(data) as T;
    }
    if (t == _isc.getType<_is3a40pv.NotificationDeliveryState?>()) {
      return (data != null
              ? _is3a40pv.NotificationDeliveryState.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i299pw2t.NotificationException?>()) {
      return (data != null
              ? _i299pw2t.NotificationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i909e29g.NotificationFailureCode?>()) {
      return (data != null
              ? _i909e29g.NotificationFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_i6bnr478.NotificationHint?>()) {
      return (data != null ? _i6bnr478.NotificationHint.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iw4dnqzf.NotificationPage?>()) {
      return (data != null ? _iw4dnqzf.NotificationPage.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i86vfscw.NotificationView?>()) {
      return (data != null ? _i86vfscw.NotificationView.fromJson(data) : null)
          as T;
    }
    if (t == List<_i86vfscw.NotificationView>) {
      return (data as List)
              .map((e) => deserialize<_i86vfscw.NotificationView>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _is3a40pv.NotificationDeliveryState => 'NotificationDeliveryState',
      _i299pw2t.NotificationException => 'NotificationException',
      _i909e29g.NotificationFailureCode => 'NotificationFailureCode',
      _i6bnr478.NotificationHint => 'NotificationHint',
      _iw4dnqzf.NotificationPage => 'NotificationPage',
      _i86vfscw.NotificationView => 'NotificationView',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_notifications.',
        '',
      );
    }

    switch (data) {
      case _is3a40pv.NotificationDeliveryState():
        return 'NotificationDeliveryState';
      case _i299pw2t.NotificationException():
        return 'NotificationException';
      case _i909e29g.NotificationFailureCode():
        return 'NotificationFailureCode';
      case _i6bnr478.NotificationHint():
        return 'NotificationHint';
      case _iw4dnqzf.NotificationPage():
        return 'NotificationPage';
      case _i86vfscw.NotificationView():
        return 'NotificationView';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'NotificationDeliveryState') {
      return deserialize<_is3a40pv.NotificationDeliveryState>(data['data']);
    }
    if (dataClassName == 'NotificationException') {
      return deserialize<_i299pw2t.NotificationException>(data['data']);
    }
    if (dataClassName == 'NotificationFailureCode') {
      return deserialize<_i909e29g.NotificationFailureCode>(data['data']);
    }
    if (dataClassName == 'NotificationHint') {
      return deserialize<_i6bnr478.NotificationHint>(data['data']);
    }
    if (dataClassName == 'NotificationPage') {
      return deserialize<_iw4dnqzf.NotificationPage>(data['data']);
    }
    if (dataClassName == 'NotificationView') {
      return deserialize<_i86vfscw.NotificationView>(data['data']);
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
  String getModuleName() => 'serverpod_notifications';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
