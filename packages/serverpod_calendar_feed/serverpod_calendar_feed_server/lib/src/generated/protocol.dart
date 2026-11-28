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
import 'package:serverpod_calendar_feed_server/src/generated/calendar_feed_credential_view.dart'
    as _ixq1vi9c;
import 'package:serverpod_calendar_feed_server/src/generated/calendar_feed_view.dart'
    as _it96frn4;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as _ipn35bcd;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import 'calendar_feed_created_credential.dart' as _i6l7w5f5;
import 'calendar_feed_credential_record.dart' as _i6jsk1k3;
import 'calendar_feed_credential_view.dart' as _i9qbm9qw;
import 'calendar_feed_data_record.dart' as _iah1koag;
import 'calendar_feed_exception.dart' as _iqqb7mk1;
import 'calendar_feed_failure_code.dart' as _iuwqxkhl;
import 'calendar_feed_identity_record.dart' as _iwfghpln;
import 'calendar_feed_selection_record.dart' as _ioqsxar9;
import 'calendar_feed_settings.dart' as _i7sjkcc2;
import 'calendar_feed_view.dart' as _ibxmw9q3;
export 'calendar_feed_created_credential.dart';
export 'calendar_feed_credential_record.dart';
export 'calendar_feed_credential_view.dart';
export 'calendar_feed_data_record.dart';
export 'calendar_feed_exception.dart';
export 'calendar_feed_failure_code.dart';
export 'calendar_feed_identity_record.dart';
export 'calendar_feed_selection_record.dart';
export 'calendar_feed_settings.dart';
export 'calendar_feed_view.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_is.SerializationManager> _hostProtocols = {};

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'serverpod_calendar_feed_credential',
      dartName: 'CalendarFeedCredentialRecord',
      schema: 'public',
      module: 'serverpod_calendar_feed',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'feedId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'digestVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'digest',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'revokedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_feed_credential_fk_0',
          columns: ['feedId'],
          referenceTable: 'serverpod_calendar_feed_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_feed_credential_digest_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'digestVersion',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'digest',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_feed_credential_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'feedId',
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
      name: 'serverpod_calendar_feed_data',
      dartName: 'CalendarFeedDataRecord',
      schema: 'public',
      module: 'serverpod_calendar_feed',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'feedId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'protocolMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'module:serverpod_calendar:CalendarProtocolMetadata?',
        ),
        _isp.ColumnDefinition(
          name: 'supplementalMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'module:serverpod_calendar:CalendarSupplementalMetadata?',
        ),
        _isp.ColumnDefinition(
          name: 'protocolModifiedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'authorityReference',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'profileVersion',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
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
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_feed_data_fk_0',
          columns: ['feedId'],
          referenceTable: 'serverpod_calendar_feed_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_feed_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'feedId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_feed_protocol_uid_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'protocolUid',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_feed_identity',
      dartName: 'CalendarFeedIdentityRecord',
      schema: 'public',
      module: 'serverpod_calendar_feed',
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
          name: 'revision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'deletedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_feed_identity_scope_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scopeKey',
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
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'serverpod_calendar_feed_selection',
      dartName: 'CalendarFeedSelectionRecord',
      schema: 'public',
      module: 'serverpod_calendar_feed',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'feedId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_feed_selection_fk_0',
          columns: ['feedId'],
          referenceTable: 'serverpod_calendar_feed_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_feed_selection_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'feedId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_feed_selection_calendar_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._ipn35bcd.Protocol.targetTableDefinitions,
    ..._ik9lwgjh.Protocol.targetTableDefinitions,
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
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i6l7w5f5.CalendarFeedCreatedCredential) {
      return _i6l7w5f5.CalendarFeedCreatedCredential.fromJson(data) as T;
    }
    if (t == _i6jsk1k3.CalendarFeedCredentialRecord) {
      return _i6jsk1k3.CalendarFeedCredentialRecord.fromJson(data) as T;
    }
    if (t == _i9qbm9qw.CalendarFeedCredentialView) {
      return _i9qbm9qw.CalendarFeedCredentialView.fromJson(data) as T;
    }
    if (t == _iah1koag.CalendarFeedDataRecord) {
      return _iah1koag.CalendarFeedDataRecord.fromJson(data) as T;
    }
    if (t == _iqqb7mk1.CalendarFeedException) {
      return _iqqb7mk1.CalendarFeedException.fromJson(data) as T;
    }
    if (t == _iuwqxkhl.CalendarFeedFailureCode) {
      return _iuwqxkhl.CalendarFeedFailureCode.fromJson(data) as T;
    }
    if (t == _iwfghpln.CalendarFeedIdentityRecord) {
      return _iwfghpln.CalendarFeedIdentityRecord.fromJson(data) as T;
    }
    if (t == _ioqsxar9.CalendarFeedSelectionRecord) {
      return _ioqsxar9.CalendarFeedSelectionRecord.fromJson(data) as T;
    }
    if (t == _i7sjkcc2.CalendarFeedSettings) {
      return _i7sjkcc2.CalendarFeedSettings.fromJson(data) as T;
    }
    if (t == _ibxmw9q3.CalendarFeedView) {
      return _ibxmw9q3.CalendarFeedView.fromJson(data) as T;
    }
    if (t == _is.getType<_i6l7w5f5.CalendarFeedCreatedCredential?>()) {
      return (data != null
              ? _i6l7w5f5.CalendarFeedCreatedCredential.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i6jsk1k3.CalendarFeedCredentialRecord?>()) {
      return (data != null
              ? _i6jsk1k3.CalendarFeedCredentialRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9qbm9qw.CalendarFeedCredentialView?>()) {
      return (data != null
              ? _i9qbm9qw.CalendarFeedCredentialView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iah1koag.CalendarFeedDataRecord?>()) {
      return (data != null
              ? _iah1koag.CalendarFeedDataRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqqb7mk1.CalendarFeedException?>()) {
      return (data != null
              ? _iqqb7mk1.CalendarFeedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuwqxkhl.CalendarFeedFailureCode?>()) {
      return (data != null
              ? _iuwqxkhl.CalendarFeedFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwfghpln.CalendarFeedIdentityRecord?>()) {
      return (data != null
              ? _iwfghpln.CalendarFeedIdentityRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ioqsxar9.CalendarFeedSelectionRecord?>()) {
      return (data != null
              ? _ioqsxar9.CalendarFeedSelectionRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7sjkcc2.CalendarFeedSettings?>()) {
      return (data != null
              ? _i7sjkcc2.CalendarFeedSettings.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ibxmw9q3.CalendarFeedView?>()) {
      return (data != null ? _ibxmw9q3.CalendarFeedView.fromJson(data) : null)
          as T;
    }
    if (t == List<_is.UuidValue>) {
      return (data as List).map((e) => deserialize<_is.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_it96frn4.CalendarFeedView>) {
      return (data as List)
              .map((e) => deserialize<_it96frn4.CalendarFeedView>(e))
              .toList()
          as T;
    }
    if (t == List<_ixq1vi9c.CalendarFeedCredentialView>) {
      return (data as List)
              .map((e) => deserialize<_ixq1vi9c.CalendarFeedCredentialView>(e))
              .toList()
          as T;
    }
    try {
      return _ipn35bcd.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _ik9lwgjh.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i6l7w5f5.CalendarFeedCreatedCredential =>
        'CalendarFeedCreatedCredential',
      _i6jsk1k3.CalendarFeedCredentialRecord => 'CalendarFeedCredentialRecord',
      _i9qbm9qw.CalendarFeedCredentialView => 'CalendarFeedCredentialView',
      _iah1koag.CalendarFeedDataRecord => 'CalendarFeedDataRecord',
      _iqqb7mk1.CalendarFeedException => 'CalendarFeedException',
      _iuwqxkhl.CalendarFeedFailureCode => 'CalendarFeedFailureCode',
      _iwfghpln.CalendarFeedIdentityRecord => 'CalendarFeedIdentityRecord',
      _ioqsxar9.CalendarFeedSelectionRecord => 'CalendarFeedSelectionRecord',
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
      case _i6jsk1k3.CalendarFeedCredentialRecord():
        return 'CalendarFeedCredentialRecord';
      case _i9qbm9qw.CalendarFeedCredentialView():
        return 'CalendarFeedCredentialView';
      case _iah1koag.CalendarFeedDataRecord():
        return 'CalendarFeedDataRecord';
      case _iqqb7mk1.CalendarFeedException():
        return 'CalendarFeedException';
      case _iuwqxkhl.CalendarFeedFailureCode():
        return 'CalendarFeedFailureCode';
      case _iwfghpln.CalendarFeedIdentityRecord():
        return 'CalendarFeedIdentityRecord';
      case _ioqsxar9.CalendarFeedSelectionRecord():
        return 'CalendarFeedSelectionRecord';
      case _i7sjkcc2.CalendarFeedSettings():
        return 'CalendarFeedSettings';
      case _ibxmw9q3.CalendarFeedView():
        return 'CalendarFeedView';
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
    if (dataClassName == 'CalendarFeedCreatedCredential') {
      return deserialize<_i6l7w5f5.CalendarFeedCreatedCredential>(data['data']);
    }
    if (dataClassName == 'CalendarFeedCredentialRecord') {
      return deserialize<_i6jsk1k3.CalendarFeedCredentialRecord>(data['data']);
    }
    if (dataClassName == 'CalendarFeedCredentialView') {
      return deserialize<_i9qbm9qw.CalendarFeedCredentialView>(data['data']);
    }
    if (dataClassName == 'CalendarFeedDataRecord') {
      return deserialize<_iah1koag.CalendarFeedDataRecord>(data['data']);
    }
    if (dataClassName == 'CalendarFeedException') {
      return deserialize<_iqqb7mk1.CalendarFeedException>(data['data']);
    }
    if (dataClassName == 'CalendarFeedFailureCode') {
      return deserialize<_iuwqxkhl.CalendarFeedFailureCode>(data['data']);
    }
    if (dataClassName == 'CalendarFeedIdentityRecord') {
      return deserialize<_iwfghpln.CalendarFeedIdentityRecord>(data['data']);
    }
    if (dataClassName == 'CalendarFeedSelectionRecord') {
      return deserialize<_ioqsxar9.CalendarFeedSelectionRecord>(data['data']);
    }
    if (dataClassName == 'CalendarFeedSettings') {
      return deserialize<_i7sjkcc2.CalendarFeedSettings>(data['data']);
    }
    if (dataClassName == 'CalendarFeedView') {
      return deserialize<_ibxmw9q3.CalendarFeedView>(data['data']);
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
      var table = _ipn35bcd.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _ik9lwgjh.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i6jsk1k3.CalendarFeedCredentialRecord:
        return _i6jsk1k3.CalendarFeedCredentialRecord.t;
      case _iah1koag.CalendarFeedDataRecord:
        return _iah1koag.CalendarFeedDataRecord.t;
      case _iwfghpln.CalendarFeedIdentityRecord:
        return _iwfghpln.CalendarFeedIdentityRecord.t;
      case _ioqsxar9.CalendarFeedSelectionRecord:
        return _ioqsxar9.CalendarFeedSelectionRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

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
      return _ipn35bcd.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _ik9lwgjh.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
