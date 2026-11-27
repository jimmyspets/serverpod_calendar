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
import 'package:serverpod_calendar_server/src/generated/calendar_field_group.dart'
    as _i3d02yxy;
import 'package:serverpod_calendar_server/src/generated/calendar_subject_view.dart'
    as _iwx7nyid;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import 'calendar_category.dart' as _icnza73c;
import 'calendar_category_filter.dart' as _i9j129by;
import 'calendar_create_request.dart' as _i8chn2wc;
import 'calendar_cursor_record.dart' as _iptr9vfe;
import 'calendar_data_record.dart' as _ix6i00tg;
import 'calendar_exception.dart' as _ioicq9ju;
import 'calendar_failure_code.dart' as _i7h2f30k;
import 'calendar_field_group.dart' as _i73hgz1s;
import 'calendar_identity_record.dart' as _ibccnfmr;
import 'calendar_image_link.dart' as _igf45b52;
import 'calendar_metadata_update_request.dart' as _i759fw3a;
import 'calendar_mutation_receipt.dart' as _iq0eskk0;
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_page.dart' as _i0jfcg0j;
import 'calendar_presentation_update_request.dart' as _i9m9yk5s;
import 'calendar_protocol_identity.dart' as _iyrimg3m;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_protocol_metadata_update_request.dart' as _iyawor89;
import 'calendar_refresh_hint.dart' as _ifsfk5xq;
import 'calendar_scope_record.dart' as _i9mvj7kq;
import 'calendar_settings_update_request.dart' as _i66us6t1;
import 'calendar_subject_action.dart' as _i41idnki;
import 'calendar_subject_change_request.dart' as _iuzjb8ji;
import 'calendar_subject_record.dart' as _i76vfrve;
import 'calendar_subject_view.dart' as _ir7mv910;
import 'calendar_supplemental_metadata.dart' as _ixppc388;
import 'calendar_supplemental_metadata_update_request.dart' as _iqx8dg15;
import 'calendar_text_variant.dart' as _itcy22f3;
import 'calendar_view.dart' as _ivspd2q7;
export 'calendar_category.dart';
export 'calendar_category_filter.dart';
export 'calendar_create_request.dart';
export 'calendar_cursor_record.dart';
export 'calendar_data_record.dart';
export 'calendar_exception.dart';
export 'calendar_failure_code.dart';
export 'calendar_field_group.dart';
export 'calendar_identity_record.dart';
export 'calendar_image_link.dart';
export 'calendar_metadata_update_request.dart';
export 'calendar_mutation_receipt.dart';
export 'calendar_no_rule_fallback.dart';
export 'calendar_page.dart';
export 'calendar_presentation_update_request.dart';
export 'calendar_protocol_identity.dart';
export 'calendar_protocol_metadata.dart';
export 'calendar_protocol_metadata_update_request.dart';
export 'calendar_refresh_hint.dart';
export 'calendar_scope_record.dart';
export 'calendar_settings_update_request.dart';
export 'calendar_subject_action.dart';
export 'calendar_subject_change_request.dart';
export 'calendar_subject_record.dart';
export 'calendar_subject_view.dart';
export 'calendar_supplemental_metadata.dart';
export 'calendar_supplemental_metadata_update_request.dart';
export 'calendar_text_variant.dart';
export 'calendar_view.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  final Set<_is.SerializationManager> _hostProtocols = {};

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'serverpod_calendar_cursor',
      dartName: 'CalendarCursorRecord',
      schema: 'public',
      module: 'serverpod_calendar',
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
          name: 'dataRevision',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
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
          name: 'fieldGroups',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<protocol:CalendarFieldGroup>',
        ),
        _isp.ColumnDefinition(
          name: 'categoryFilter',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarCategoryFilter?',
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
          indexName: 'calendar_cursor_token_unique',
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
          indexName: 'calendar_cursor_expiry_idx',
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
      name: 'serverpod_calendar_data',
      dartName: 'CalendarDataRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'protocolUid',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'description',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'color',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'availabilityZoneId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'noRuleFallback',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CalendarNoRuleFallback',
        ),
        _isp.ColumnDefinition(
          name: 'protocolMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarProtocolMetadata?',
        ),
        _isp.ColumnDefinition(
          name: 'supplementalMetadata',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarSupplementalMetadata?',
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
          constraintName: 'serverpod_calendar_data_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_data_protocol_uid_unique',
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
        _isp.IndexDefinition(
          indexName: 'calendar_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
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
      name: 'serverpod_calendar_identity',
      dartName: 'CalendarIdentityRecord',
      schema: 'public',
      module: 'serverpod_calendar',
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
          indexName: 'calendar_identity_scope_idx',
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
      name: 'serverpod_calendar_scope',
      dartName: 'CalendarScopeRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
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
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_scope_key_unique',
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
    _isp.TableDefinition(
      name: 'serverpod_calendar_subject',
      dartName: 'CalendarSubjectRecord',
      schema: 'public',
      module: 'serverpod_calendar',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'namespace',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'externalId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'contributesAvailability',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_subject_fk_0',
          columns: ['calendarId'],
          referenceTable: 'serverpod_calendar_identity',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_subject_tuple_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'namespace',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'kind',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'externalId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
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
    if (!className.startsWith('serverpod_calendar.')) return className;
    return className.substring(19);
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

    if (t == _icnza73c.CalendarCategory) {
      return _icnza73c.CalendarCategory.fromJson(data) as T;
    }
    if (t == _i9j129by.CalendarCategoryFilter) {
      return _i9j129by.CalendarCategoryFilter.fromJson(data) as T;
    }
    if (t == _i8chn2wc.CalendarCreateRequest) {
      return _i8chn2wc.CalendarCreateRequest.fromJson(data) as T;
    }
    if (t == _iptr9vfe.CalendarCursorRecord) {
      return _iptr9vfe.CalendarCursorRecord.fromJson(data) as T;
    }
    if (t == _ix6i00tg.CalendarDataRecord) {
      return _ix6i00tg.CalendarDataRecord.fromJson(data) as T;
    }
    if (t == _ioicq9ju.CalendarException) {
      return _ioicq9ju.CalendarException.fromJson(data) as T;
    }
    if (t == _i7h2f30k.CalendarFailureCode) {
      return _i7h2f30k.CalendarFailureCode.fromJson(data) as T;
    }
    if (t == _i73hgz1s.CalendarFieldGroup) {
      return _i73hgz1s.CalendarFieldGroup.fromJson(data) as T;
    }
    if (t == _ibccnfmr.CalendarIdentityRecord) {
      return _ibccnfmr.CalendarIdentityRecord.fromJson(data) as T;
    }
    if (t == _igf45b52.CalendarImageLink) {
      return _igf45b52.CalendarImageLink.fromJson(data) as T;
    }
    if (t == _i759fw3a.CalendarMetadataUpdateRequest) {
      return _i759fw3a.CalendarMetadataUpdateRequest.fromJson(data) as T;
    }
    if (t == _iq0eskk0.CalendarMutationReceipt) {
      return _iq0eskk0.CalendarMutationReceipt.fromJson(data) as T;
    }
    if (t == _itts4qyp.CalendarNoRuleFallback) {
      return _itts4qyp.CalendarNoRuleFallback.fromJson(data) as T;
    }
    if (t == _i0jfcg0j.CalendarPage) {
      return _i0jfcg0j.CalendarPage.fromJson(data) as T;
    }
    if (t == _i9m9yk5s.CalendarPresentationUpdateRequest) {
      return _i9m9yk5s.CalendarPresentationUpdateRequest.fromJson(data) as T;
    }
    if (t == _iyrimg3m.CalendarProtocolIdentity) {
      return _iyrimg3m.CalendarProtocolIdentity.fromJson(data) as T;
    }
    if (t == _itchuj1l.CalendarProtocolMetadata) {
      return _itchuj1l.CalendarProtocolMetadata.fromJson(data) as T;
    }
    if (t == _iyawor89.CalendarProtocolMetadataUpdateRequest) {
      return _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
          as T;
    }
    if (t == _ifsfk5xq.CalendarRefreshHint) {
      return _ifsfk5xq.CalendarRefreshHint.fromJson(data) as T;
    }
    if (t == _i9mvj7kq.CalendarScopeRecord) {
      return _i9mvj7kq.CalendarScopeRecord.fromJson(data) as T;
    }
    if (t == _i66us6t1.CalendarSettingsUpdateRequest) {
      return _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data) as T;
    }
    if (t == _i41idnki.CalendarSubjectAction) {
      return _i41idnki.CalendarSubjectAction.fromJson(data) as T;
    }
    if (t == _iuzjb8ji.CalendarSubjectChangeRequest) {
      return _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data) as T;
    }
    if (t == _i76vfrve.CalendarSubjectRecord) {
      return _i76vfrve.CalendarSubjectRecord.fromJson(data) as T;
    }
    if (t == _ir7mv910.CalendarSubjectView) {
      return _ir7mv910.CalendarSubjectView.fromJson(data) as T;
    }
    if (t == _ixppc388.CalendarSupplementalMetadata) {
      return _ixppc388.CalendarSupplementalMetadata.fromJson(data) as T;
    }
    if (t == _iqx8dg15.CalendarSupplementalMetadataUpdateRequest) {
      return _iqx8dg15.CalendarSupplementalMetadataUpdateRequest.fromJson(data)
          as T;
    }
    if (t == _itcy22f3.CalendarTextVariant) {
      return _itcy22f3.CalendarTextVariant.fromJson(data) as T;
    }
    if (t == _ivspd2q7.CalendarView) {
      return _ivspd2q7.CalendarView.fromJson(data) as T;
    }
    if (t == _is.getType<_icnza73c.CalendarCategory?>()) {
      return (data != null ? _icnza73c.CalendarCategory.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9j129by.CalendarCategoryFilter?>()) {
      return (data != null
              ? _i9j129by.CalendarCategoryFilter.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i8chn2wc.CalendarCreateRequest?>()) {
      return (data != null
              ? _i8chn2wc.CalendarCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iptr9vfe.CalendarCursorRecord?>()) {
      return (data != null
              ? _iptr9vfe.CalendarCursorRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ix6i00tg.CalendarDataRecord?>()) {
      return (data != null ? _ix6i00tg.CalendarDataRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ioicq9ju.CalendarException?>()) {
      return (data != null ? _ioicq9ju.CalendarException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7h2f30k.CalendarFailureCode?>()) {
      return (data != null
              ? _i7h2f30k.CalendarFailureCode.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i73hgz1s.CalendarFieldGroup?>()) {
      return (data != null ? _i73hgz1s.CalendarFieldGroup.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibccnfmr.CalendarIdentityRecord?>()) {
      return (data != null
              ? _ibccnfmr.CalendarIdentityRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_igf45b52.CalendarImageLink?>()) {
      return (data != null ? _igf45b52.CalendarImageLink.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i759fw3a.CalendarMetadataUpdateRequest?>()) {
      return (data != null
              ? _i759fw3a.CalendarMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iq0eskk0.CalendarMutationReceipt?>()) {
      return (data != null
              ? _iq0eskk0.CalendarMutationReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itts4qyp.CalendarNoRuleFallback?>()) {
      return (data != null
              ? _itts4qyp.CalendarNoRuleFallback.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0jfcg0j.CalendarPage?>()) {
      return (data != null ? _i0jfcg0j.CalendarPage.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i9m9yk5s.CalendarPresentationUpdateRequest?>()) {
      return (data != null
              ? _i9m9yk5s.CalendarPresentationUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyrimg3m.CalendarProtocolIdentity?>()) {
      return (data != null
              ? _iyrimg3m.CalendarProtocolIdentity.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_itchuj1l.CalendarProtocolMetadata?>()) {
      return (data != null
              ? _itchuj1l.CalendarProtocolMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iyawor89.CalendarProtocolMetadataUpdateRequest?>()) {
      return (data != null
              ? _iyawor89.CalendarProtocolMetadataUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ifsfk5xq.CalendarRefreshHint?>()) {
      return (data != null
              ? _ifsfk5xq.CalendarRefreshHint.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i9mvj7kq.CalendarScopeRecord?>()) {
      return (data != null
              ? _i9mvj7kq.CalendarScopeRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i66us6t1.CalendarSettingsUpdateRequest?>()) {
      return (data != null
              ? _i66us6t1.CalendarSettingsUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i41idnki.CalendarSubjectAction?>()) {
      return (data != null
              ? _i41idnki.CalendarSubjectAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuzjb8ji.CalendarSubjectChangeRequest?>()) {
      return (data != null
              ? _iuzjb8ji.CalendarSubjectChangeRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i76vfrve.CalendarSubjectRecord?>()) {
      return (data != null
              ? _i76vfrve.CalendarSubjectRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ir7mv910.CalendarSubjectView?>()) {
      return (data != null
              ? _ir7mv910.CalendarSubjectView.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixppc388.CalendarSupplementalMetadata?>()) {
      return (data != null
              ? _ixppc388.CalendarSupplementalMetadata.fromJson(data)
              : null)
          as T;
    }
    if (t ==
        _is.getType<_iqx8dg15.CalendarSupplementalMetadataUpdateRequest?>()) {
      return (data != null
              ? _iqx8dg15.CalendarSupplementalMetadataUpdateRequest.fromJson(
                  data,
                )
              : null)
          as T;
    }
    if (t == _is.getType<_itcy22f3.CalendarTextVariant?>()) {
      return (data != null
              ? _itcy22f3.CalendarTextVariant.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivspd2q7.CalendarView?>()) {
      return (data != null ? _ivspd2q7.CalendarView.fromJson(data) : null) as T;
    }
    if (t == List<_i73hgz1s.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i73hgz1s.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_ivspd2q7.CalendarView>) {
      return (data as List)
              .map((e) => deserialize<_ivspd2q7.CalendarView>(e))
              .toList()
          as T;
    }
    if (t == List<_itcy22f3.CalendarTextVariant>) {
      return (data as List)
              .map((e) => deserialize<_itcy22f3.CalendarTextVariant>(e))
              .toList()
          as T;
    }
    if (t == List<_icnza73c.CalendarCategory>) {
      return (data as List)
              .map((e) => deserialize<_icnza73c.CalendarCategory>(e))
              .toList()
          as T;
    }
    if (t == List<_igf45b52.CalendarImageLink>) {
      return (data as List)
              .map((e) => deserialize<_igf45b52.CalendarImageLink>(e))
              .toList()
          as T;
    }
    if (t == List<_i3d02yxy.CalendarFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_i3d02yxy.CalendarFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == List<_iwx7nyid.CalendarSubjectView>) {
      return (data as List)
              .map((e) => deserialize<_iwx7nyid.CalendarSubjectView>(e))
              .toList()
          as T;
    }
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
      _icnza73c.CalendarCategory => 'CalendarCategory',
      _i9j129by.CalendarCategoryFilter => 'CalendarCategoryFilter',
      _i8chn2wc.CalendarCreateRequest => 'CalendarCreateRequest',
      _iptr9vfe.CalendarCursorRecord => 'CalendarCursorRecord',
      _ix6i00tg.CalendarDataRecord => 'CalendarDataRecord',
      _ioicq9ju.CalendarException => 'CalendarException',
      _i7h2f30k.CalendarFailureCode => 'CalendarFailureCode',
      _i73hgz1s.CalendarFieldGroup => 'CalendarFieldGroup',
      _ibccnfmr.CalendarIdentityRecord => 'CalendarIdentityRecord',
      _igf45b52.CalendarImageLink => 'CalendarImageLink',
      _i759fw3a.CalendarMetadataUpdateRequest =>
        'CalendarMetadataUpdateRequest',
      _iq0eskk0.CalendarMutationReceipt => 'CalendarMutationReceipt',
      _itts4qyp.CalendarNoRuleFallback => 'CalendarNoRuleFallback',
      _i0jfcg0j.CalendarPage => 'CalendarPage',
      _i9m9yk5s.CalendarPresentationUpdateRequest =>
        'CalendarPresentationUpdateRequest',
      _iyrimg3m.CalendarProtocolIdentity => 'CalendarProtocolIdentity',
      _itchuj1l.CalendarProtocolMetadata => 'CalendarProtocolMetadata',
      _iyawor89.CalendarProtocolMetadataUpdateRequest =>
        'CalendarProtocolMetadataUpdateRequest',
      _ifsfk5xq.CalendarRefreshHint => 'CalendarRefreshHint',
      _i9mvj7kq.CalendarScopeRecord => 'CalendarScopeRecord',
      _i66us6t1.CalendarSettingsUpdateRequest =>
        'CalendarSettingsUpdateRequest',
      _i41idnki.CalendarSubjectAction => 'CalendarSubjectAction',
      _iuzjb8ji.CalendarSubjectChangeRequest => 'CalendarSubjectChangeRequest',
      _i76vfrve.CalendarSubjectRecord => 'CalendarSubjectRecord',
      _ir7mv910.CalendarSubjectView => 'CalendarSubjectView',
      _ixppc388.CalendarSupplementalMetadata => 'CalendarSupplementalMetadata',
      _iqx8dg15.CalendarSupplementalMetadataUpdateRequest =>
        'CalendarSupplementalMetadataUpdateRequest',
      _itcy22f3.CalendarTextVariant => 'CalendarTextVariant',
      _ivspd2q7.CalendarView => 'CalendarView',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_calendar.',
        '',
      );
    }

    switch (data) {
      case _icnza73c.CalendarCategory():
        return 'CalendarCategory';
      case _i9j129by.CalendarCategoryFilter():
        return 'CalendarCategoryFilter';
      case _i8chn2wc.CalendarCreateRequest():
        return 'CalendarCreateRequest';
      case _iptr9vfe.CalendarCursorRecord():
        return 'CalendarCursorRecord';
      case _ix6i00tg.CalendarDataRecord():
        return 'CalendarDataRecord';
      case _ioicq9ju.CalendarException():
        return 'CalendarException';
      case _i7h2f30k.CalendarFailureCode():
        return 'CalendarFailureCode';
      case _i73hgz1s.CalendarFieldGroup():
        return 'CalendarFieldGroup';
      case _ibccnfmr.CalendarIdentityRecord():
        return 'CalendarIdentityRecord';
      case _igf45b52.CalendarImageLink():
        return 'CalendarImageLink';
      case _i759fw3a.CalendarMetadataUpdateRequest():
        return 'CalendarMetadataUpdateRequest';
      case _iq0eskk0.CalendarMutationReceipt():
        return 'CalendarMutationReceipt';
      case _itts4qyp.CalendarNoRuleFallback():
        return 'CalendarNoRuleFallback';
      case _i0jfcg0j.CalendarPage():
        return 'CalendarPage';
      case _i9m9yk5s.CalendarPresentationUpdateRequest():
        return 'CalendarPresentationUpdateRequest';
      case _iyrimg3m.CalendarProtocolIdentity():
        return 'CalendarProtocolIdentity';
      case _itchuj1l.CalendarProtocolMetadata():
        return 'CalendarProtocolMetadata';
      case _iyawor89.CalendarProtocolMetadataUpdateRequest():
        return 'CalendarProtocolMetadataUpdateRequest';
      case _ifsfk5xq.CalendarRefreshHint():
        return 'CalendarRefreshHint';
      case _i9mvj7kq.CalendarScopeRecord():
        return 'CalendarScopeRecord';
      case _i66us6t1.CalendarSettingsUpdateRequest():
        return 'CalendarSettingsUpdateRequest';
      case _i41idnki.CalendarSubjectAction():
        return 'CalendarSubjectAction';
      case _iuzjb8ji.CalendarSubjectChangeRequest():
        return 'CalendarSubjectChangeRequest';
      case _i76vfrve.CalendarSubjectRecord():
        return 'CalendarSubjectRecord';
      case _ir7mv910.CalendarSubjectView():
        return 'CalendarSubjectView';
      case _ixppc388.CalendarSupplementalMetadata():
        return 'CalendarSupplementalMetadata';
      case _iqx8dg15.CalendarSupplementalMetadataUpdateRequest():
        return 'CalendarSupplementalMetadataUpdateRequest';
      case _itcy22f3.CalendarTextVariant():
        return 'CalendarTextVariant';
      case _ivspd2q7.CalendarView():
        return 'CalendarView';
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
    if (dataClassName == 'CalendarCategory') {
      return deserialize<_icnza73c.CalendarCategory>(data['data']);
    }
    if (dataClassName == 'CalendarCategoryFilter') {
      return deserialize<_i9j129by.CalendarCategoryFilter>(data['data']);
    }
    if (dataClassName == 'CalendarCreateRequest') {
      return deserialize<_i8chn2wc.CalendarCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarCursorRecord') {
      return deserialize<_iptr9vfe.CalendarCursorRecord>(data['data']);
    }
    if (dataClassName == 'CalendarDataRecord') {
      return deserialize<_ix6i00tg.CalendarDataRecord>(data['data']);
    }
    if (dataClassName == 'CalendarException') {
      return deserialize<_ioicq9ju.CalendarException>(data['data']);
    }
    if (dataClassName == 'CalendarFailureCode') {
      return deserialize<_i7h2f30k.CalendarFailureCode>(data['data']);
    }
    if (dataClassName == 'CalendarFieldGroup') {
      return deserialize<_i73hgz1s.CalendarFieldGroup>(data['data']);
    }
    if (dataClassName == 'CalendarIdentityRecord') {
      return deserialize<_ibccnfmr.CalendarIdentityRecord>(data['data']);
    }
    if (dataClassName == 'CalendarImageLink') {
      return deserialize<_igf45b52.CalendarImageLink>(data['data']);
    }
    if (dataClassName == 'CalendarMetadataUpdateRequest') {
      return deserialize<_i759fw3a.CalendarMetadataUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarMutationReceipt') {
      return deserialize<_iq0eskk0.CalendarMutationReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarNoRuleFallback') {
      return deserialize<_itts4qyp.CalendarNoRuleFallback>(data['data']);
    }
    if (dataClassName == 'CalendarPage') {
      return deserialize<_i0jfcg0j.CalendarPage>(data['data']);
    }
    if (dataClassName == 'CalendarPresentationUpdateRequest') {
      return deserialize<_i9m9yk5s.CalendarPresentationUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarProtocolIdentity') {
      return deserialize<_iyrimg3m.CalendarProtocolIdentity>(data['data']);
    }
    if (dataClassName == 'CalendarProtocolMetadata') {
      return deserialize<_itchuj1l.CalendarProtocolMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarProtocolMetadataUpdateRequest') {
      return deserialize<_iyawor89.CalendarProtocolMetadataUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarRefreshHint') {
      return deserialize<_ifsfk5xq.CalendarRefreshHint>(data['data']);
    }
    if (dataClassName == 'CalendarScopeRecord') {
      return deserialize<_i9mvj7kq.CalendarScopeRecord>(data['data']);
    }
    if (dataClassName == 'CalendarSettingsUpdateRequest') {
      return deserialize<_i66us6t1.CalendarSettingsUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectAction') {
      return deserialize<_i41idnki.CalendarSubjectAction>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectChangeRequest') {
      return deserialize<_iuzjb8ji.CalendarSubjectChangeRequest>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectRecord') {
      return deserialize<_i76vfrve.CalendarSubjectRecord>(data['data']);
    }
    if (dataClassName == 'CalendarSubjectView') {
      return deserialize<_ir7mv910.CalendarSubjectView>(data['data']);
    }
    if (dataClassName == 'CalendarSupplementalMetadata') {
      return deserialize<_ixppc388.CalendarSupplementalMetadata>(data['data']);
    }
    if (dataClassName == 'CalendarSupplementalMetadataUpdateRequest') {
      return deserialize<_iqx8dg15.CalendarSupplementalMetadataUpdateRequest>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarTextVariant') {
      return deserialize<_itcy22f3.CalendarTextVariant>(data['data']);
    }
    if (dataClassName == 'CalendarView') {
      return deserialize<_ivspd2q7.CalendarView>(data['data']);
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
      case _iptr9vfe.CalendarCursorRecord:
        return _iptr9vfe.CalendarCursorRecord.t;
      case _ix6i00tg.CalendarDataRecord:
        return _ix6i00tg.CalendarDataRecord.t;
      case _ibccnfmr.CalendarIdentityRecord:
        return _ibccnfmr.CalendarIdentityRecord.t;
      case _i9mvj7kq.CalendarScopeRecord:
        return _i9mvj7kq.CalendarScopeRecord.t;
      case _i76vfrve.CalendarSubjectRecord:
        return _i76vfrve.CalendarSubjectRecord.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'serverpod_calendar';

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
      return _ik9lwgjh.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
