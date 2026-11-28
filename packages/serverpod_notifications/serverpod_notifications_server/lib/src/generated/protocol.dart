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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'notification_cursor_record.dart' as _iivbetmh;
import 'notification_delivery_record.dart' as _i0qtwtk5;
import 'notification_delivery_state.dart' as _is3a40pv;
import 'notification_exception.dart' as _i299pw2t;
import 'notification_failure_code.dart' as _i909e29g;
import 'notification_hint.dart' as _i6bnr478;
import 'notification_page.dart' as _iw4dnqzf;
import 'notification_scope_record.dart' as _i48objlk;
import 'notification_view.dart' as _i86vfscw;
export 'notification_cursor_record.dart';
export 'notification_delivery_record.dart';
export 'notification_delivery_state.dart';
export 'notification_exception.dart';
export 'notification_failure_code.dart';
export 'notification_hint.dart';
export 'notification_page.dart';
export 'notification_scope_record.dart';
export 'notification_view.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_is.SerializationManager> _hostProtocols = {};

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'serverpod_notifications_cursor',
      dartName: 'NotificationCursorRecord',
      schema: 'public',
      module: 'serverpod_notifications',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'token',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'principalId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'policyRevision',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'afterId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'pageSize',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'notification_cursor_token_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'token',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'notification_cursor_expiry_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_notifications_delivery',
      dartName: 'NotificationDeliveryRecord',
      schema: 'public',
      module: 'serverpod_notifications',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'recipientKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceNamespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sourceRequestId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'requestDigest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sourceReference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'dueAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expiresAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:NotificationDeliveryState',
          columnDefault: '\'queued\'',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'nextAttemptAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'attemptCount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'leaseOwner',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'leaseFence',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'publishedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'terminalAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'notification_request_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceNamespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sourceRequestId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'notification_due_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'nextAttemptAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'leaseUntil',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'notification_recipient_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientNamespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'recipientKey',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'notification_terminal_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'terminalAt',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'expiresAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_notifications_scope',
      dartName: 'NotificationScopeRecord',
      schema: 'public',
      module: 'serverpod_notifications',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'scopeKey',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'notification_scope_key_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
  ];

  void registerHostProtocol(
    String projectName,
    _is.SerializationManager protocol,
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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iivbetmh.NotificationCursorRecord) {
      return _iivbetmh.NotificationCursorRecord.fromJson(data) as T;
    }
    if (t == _i0qtwtk5.NotificationDeliveryRecord) {
      return _i0qtwtk5.NotificationDeliveryRecord.fromJson(data) as T;
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
    if (t == _i48objlk.NotificationScopeRecord) {
      return _i48objlk.NotificationScopeRecord.fromJson(data) as T;
    }
    if (t == _i86vfscw.NotificationView) {
      return _i86vfscw.NotificationView.fromJson(data) as T;
    }
    if (t == _is.getType<_iivbetmh.NotificationCursorRecord?>()) {
      return (data != null
              ? _iivbetmh.NotificationCursorRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0qtwtk5.NotificationDeliveryRecord?>()) {
      return (data != null
              ? _i0qtwtk5.NotificationDeliveryRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_is3a40pv.NotificationDeliveryState?>()) {
      return (data != null
              ? _is3a40pv.NotificationDeliveryState.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i299pw2t.NotificationException?>()) {
      return (data != null
              ? _i299pw2t.NotificationException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i909e29g.NotificationFailureCode?>()) {
      return (data != null
              ? _i909e29g.NotificationFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6bnr478.NotificationHint?>()) {
      return (data != null ? _i6bnr478.NotificationHint.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iw4dnqzf.NotificationPage?>()) {
      return (data != null ? _iw4dnqzf.NotificationPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i48objlk.NotificationScopeRecord?>()) {
      return (data != null
              ? _i48objlk.NotificationScopeRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i86vfscw.NotificationView?>()) {
      return (data != null ? _i86vfscw.NotificationView.fromJson(data) : null)
          as T;
    }
    if (t == List<_i86vfscw.NotificationView>) {
      return (data as List)
              .map((e) => deserialize<_i86vfscw.NotificationView>(e))
              .toList()
          as T;
    }
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iivbetmh.NotificationCursorRecord => 'NotificationCursorRecord',
      _i0qtwtk5.NotificationDeliveryRecord => 'NotificationDeliveryRecord',
      _is3a40pv.NotificationDeliveryState => 'NotificationDeliveryState',
      _i299pw2t.NotificationException => 'NotificationException',
      _i909e29g.NotificationFailureCode => 'NotificationFailureCode',
      _i6bnr478.NotificationHint => 'NotificationHint',
      _iw4dnqzf.NotificationPage => 'NotificationPage',
      _i48objlk.NotificationScopeRecord => 'NotificationScopeRecord',
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
      case _iivbetmh.NotificationCursorRecord():
        return 'NotificationCursorRecord';
      case _i0qtwtk5.NotificationDeliveryRecord():
        return 'NotificationDeliveryRecord';
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
      case _i48objlk.NotificationScopeRecord():
        return 'NotificationScopeRecord';
      case _i86vfscw.NotificationView():
        return 'NotificationView';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'NotificationCursorRecord') {
      return deserialize<_iivbetmh.NotificationCursorRecord>(data['data']);
    }
    if (dataClassName == 'NotificationDeliveryRecord') {
      return deserialize<_i0qtwtk5.NotificationDeliveryRecord>(data['data']);
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
    if (dataClassName == 'NotificationScopeRecord') {
      return deserialize<_i48objlk.NotificationScopeRecord>(data['data']);
    }
    if (dataClassName == 'NotificationView') {
      return deserialize<_i86vfscw.NotificationView>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
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
          ? _is.SerializationManager.toEncodableForProtocol(wrapped)
          : _is.SerializationManager.toEncodable(wrapped);
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
        } on _is.DeserializationClassNameNotFoundException catch (_) {}
      }
    }
    return deserializeByClassName(value);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iivbetmh.NotificationCursorRecord:
        return _iivbetmh.NotificationCursorRecord.t;
      case _i0qtwtk5.NotificationDeliveryRecord:
        return _i0qtwtk5.NotificationDeliveryRecord.t;
      case _i48objlk.NotificationScopeRecord:
        return _i48objlk.NotificationScopeRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
    try {
      return _isp.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
