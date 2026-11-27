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
import 'package:serverpod_calendar_server/src/generated/calendar_event_field_group.dart'
    as _il5gdr09;
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
import 'calendar_event_by_day.dart' as _iq7751s4;
import 'calendar_event_civil.dart' as _i1bb5k1r;
import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_create_request.dart' as _i0orp171;
import 'calendar_event_data_record.dart' as _i23wc83s;
import 'calendar_event_duration.dart' as _idn2i48l;
import 'calendar_event_field_group.dart' as _iftiwkuj;
import 'calendar_event_frequency.dart' as _i2q54gr5;
import 'calendar_event_future_override.dart' as _imbjv41e;
import 'calendar_event_occurrence.dart' as _isyqnyev;
import 'calendar_event_occurrence_action.dart' as _icnciyzp;
import 'calendar_event_occurrence_change.dart' as _i7imxrlz;
import 'calendar_event_occurrence_preview.dart' as _i1a4s0rt;
import 'calendar_event_occurrence_query.dart' as _ivs4ir3j;
import 'calendar_event_page.dart' as _iaayjmj1;
import 'calendar_event_receipt.dart' as _i500bvo7;
import 'calendar_event_record.dart' as _ilvoe14z;
import 'calendar_event_recurrence.dart' as _iqxs44bf;
import 'calendar_event_rule.dart' as _iovyzq1q;
import 'calendar_event_single_override.dart' as _iq1kxi25;
import 'calendar_event_status.dart' as _ivzxk9bc;
import 'calendar_event_status_request.dart' as _i3kbbl30;
import 'calendar_event_time_kind.dart' as _idbnuf6y;
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_event_timing_overrides.dart' as _ijijze99;
import 'calendar_event_transparency.dart' as _iwjkdwy7;
import 'calendar_event_update_request.dart' as _i3ofr0ug;
import 'calendar_event_view.dart' as _iqr733fy;
import 'calendar_exception.dart' as _ioicq9ju;
import 'calendar_failure_code.dart' as _i7h2f30k;
import 'calendar_field_group.dart' as _i73hgz1s;
import 'calendar_free_busy_coverage.dart' as _ia3n9q23;
import 'calendar_free_busy_kind.dart' as _izms466b;
import 'calendar_free_busy_period.dart' as _i82zcrxb;
import 'calendar_free_busy_query.dart' as _idid5g6i;
import 'calendar_free_busy_view.dart' as _i3b615hg;
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
export 'calendar_event_by_day.dart';
export 'calendar_event_civil.dart';
export 'calendar_event_content.dart';
export 'calendar_event_create_request.dart';
export 'calendar_event_data_record.dart';
export 'calendar_event_duration.dart';
export 'calendar_event_field_group.dart';
export 'calendar_event_frequency.dart';
export 'calendar_event_future_override.dart';
export 'calendar_event_occurrence.dart';
export 'calendar_event_occurrence_action.dart';
export 'calendar_event_occurrence_change.dart';
export 'calendar_event_occurrence_preview.dart';
export 'calendar_event_occurrence_query.dart';
export 'calendar_event_page.dart';
export 'calendar_event_receipt.dart';
export 'calendar_event_record.dart';
export 'calendar_event_recurrence.dart';
export 'calendar_event_rule.dart';
export 'calendar_event_single_override.dart';
export 'calendar_event_status.dart';
export 'calendar_event_status_request.dart';
export 'calendar_event_time_kind.dart';
export 'calendar_event_timing.dart';
export 'calendar_event_timing_overrides.dart';
export 'calendar_event_transparency.dart';
export 'calendar_event_update_request.dart';
export 'calendar_event_view.dart';
export 'calendar_exception.dart';
export 'calendar_failure_code.dart';
export 'calendar_field_group.dart';
export 'calendar_free_busy_coverage.dart';
export 'calendar_free_busy_kind.dart';
export 'calendar_free_busy_period.dart';
export 'calendar_free_busy_query.dart';
export 'calendar_free_busy_view.dart';
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
          name: 'eventCalendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'eventFieldGroups',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'List<protocol:CalendarEventFieldGroup>?',
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
      name: 'serverpod_calendar_event',
      dartName: 'CalendarEventRecord',
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
          name: 'calendarId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
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
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'serverpod_calendar_event_fk_0',
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
          indexName: 'calendar_event_parent_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'calendarId',
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
      name: 'serverpod_calendar_event_data',
      dartName: 'CalendarEventDataRecord',
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
          name: 'eventId',
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
          name: 'timingOverrides',
          columnType: _isp.ColumnType.json,
          isNullable: true,
          dartType: 'protocol:CalendarEventTimingOverrides?',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:CalendarEventContent',
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
          constraintName: 'serverpod_calendar_event_data_fk_0',
          columns: ['eventId'],
          referenceTable: 'serverpod_calendar_event',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'calendar_event_data_identity_unique',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'eventId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'calendar_event_data_uid_unique',
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
    if (t == _iq7751s4.CalendarEventByDay) {
      return _iq7751s4.CalendarEventByDay.fromJson(data) as T;
    }
    if (t == _i1bb5k1r.CalendarEventCivil) {
      return _i1bb5k1r.CalendarEventCivil.fromJson(data) as T;
    }
    if (t == _id4cvk34.CalendarEventContent) {
      return _id4cvk34.CalendarEventContent.fromJson(data) as T;
    }
    if (t == _i0orp171.CalendarEventCreateRequest) {
      return _i0orp171.CalendarEventCreateRequest.fromJson(data) as T;
    }
    if (t == _i23wc83s.CalendarEventDataRecord) {
      return _i23wc83s.CalendarEventDataRecord.fromJson(data) as T;
    }
    if (t == _idn2i48l.CalendarEventDuration) {
      return _idn2i48l.CalendarEventDuration.fromJson(data) as T;
    }
    if (t == _iftiwkuj.CalendarEventFieldGroup) {
      return _iftiwkuj.CalendarEventFieldGroup.fromJson(data) as T;
    }
    if (t == _i2q54gr5.CalendarEventFrequency) {
      return _i2q54gr5.CalendarEventFrequency.fromJson(data) as T;
    }
    if (t == _imbjv41e.CalendarEventFutureOverride) {
      return _imbjv41e.CalendarEventFutureOverride.fromJson(data) as T;
    }
    if (t == _isyqnyev.CalendarEventOccurrence) {
      return _isyqnyev.CalendarEventOccurrence.fromJson(data) as T;
    }
    if (t == _icnciyzp.CalendarEventOccurrenceAction) {
      return _icnciyzp.CalendarEventOccurrenceAction.fromJson(data) as T;
    }
    if (t == _i7imxrlz.CalendarEventOccurrenceChange) {
      return _i7imxrlz.CalendarEventOccurrenceChange.fromJson(data) as T;
    }
    if (t == _i1a4s0rt.CalendarEventOccurrencePreview) {
      return _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data) as T;
    }
    if (t == _ivs4ir3j.CalendarEventOccurrenceQuery) {
      return _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data) as T;
    }
    if (t == _iaayjmj1.CalendarEventPage) {
      return _iaayjmj1.CalendarEventPage.fromJson(data) as T;
    }
    if (t == _i500bvo7.CalendarEventReceipt) {
      return _i500bvo7.CalendarEventReceipt.fromJson(data) as T;
    }
    if (t == _ilvoe14z.CalendarEventRecord) {
      return _ilvoe14z.CalendarEventRecord.fromJson(data) as T;
    }
    if (t == _iqxs44bf.CalendarEventRecurrence) {
      return _iqxs44bf.CalendarEventRecurrence.fromJson(data) as T;
    }
    if (t == _iovyzq1q.CalendarEventRule) {
      return _iovyzq1q.CalendarEventRule.fromJson(data) as T;
    }
    if (t == _iq1kxi25.CalendarEventSingleOverride) {
      return _iq1kxi25.CalendarEventSingleOverride.fromJson(data) as T;
    }
    if (t == _ivzxk9bc.CalendarEventStatus) {
      return _ivzxk9bc.CalendarEventStatus.fromJson(data) as T;
    }
    if (t == _i3kbbl30.CalendarEventStatusRequest) {
      return _i3kbbl30.CalendarEventStatusRequest.fromJson(data) as T;
    }
    if (t == _idbnuf6y.CalendarEventTimeKind) {
      return _idbnuf6y.CalendarEventTimeKind.fromJson(data) as T;
    }
    if (t == _ieswiaty.CalendarEventTiming) {
      return _ieswiaty.CalendarEventTiming.fromJson(data) as T;
    }
    if (t == _ijijze99.CalendarEventTimingOverrides) {
      return _ijijze99.CalendarEventTimingOverrides.fromJson(data) as T;
    }
    if (t == _iwjkdwy7.CalendarEventTransparency) {
      return _iwjkdwy7.CalendarEventTransparency.fromJson(data) as T;
    }
    if (t == _i3ofr0ug.CalendarEventUpdateRequest) {
      return _i3ofr0ug.CalendarEventUpdateRequest.fromJson(data) as T;
    }
    if (t == _iqr733fy.CalendarEventView) {
      return _iqr733fy.CalendarEventView.fromJson(data) as T;
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
    if (t == _ia3n9q23.CalendarFreeBusyCoverage) {
      return _ia3n9q23.CalendarFreeBusyCoverage.fromJson(data) as T;
    }
    if (t == _izms466b.CalendarFreeBusyKind) {
      return _izms466b.CalendarFreeBusyKind.fromJson(data) as T;
    }
    if (t == _i82zcrxb.CalendarFreeBusyPeriod) {
      return _i82zcrxb.CalendarFreeBusyPeriod.fromJson(data) as T;
    }
    if (t == _idid5g6i.CalendarFreeBusyQuery) {
      return _idid5g6i.CalendarFreeBusyQuery.fromJson(data) as T;
    }
    if (t == _i3b615hg.CalendarFreeBusyView) {
      return _i3b615hg.CalendarFreeBusyView.fromJson(data) as T;
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
    if (t == _is.getType<_iq7751s4.CalendarEventByDay?>()) {
      return (data != null ? _iq7751s4.CalendarEventByDay.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1bb5k1r.CalendarEventCivil?>()) {
      return (data != null ? _i1bb5k1r.CalendarEventCivil.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_id4cvk34.CalendarEventContent?>()) {
      return (data != null
              ? _id4cvk34.CalendarEventContent.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i0orp171.CalendarEventCreateRequest?>()) {
      return (data != null
              ? _i0orp171.CalendarEventCreateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i23wc83s.CalendarEventDataRecord?>()) {
      return (data != null
              ? _i23wc83s.CalendarEventDataRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idn2i48l.CalendarEventDuration?>()) {
      return (data != null
              ? _idn2i48l.CalendarEventDuration.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iftiwkuj.CalendarEventFieldGroup?>()) {
      return (data != null
              ? _iftiwkuj.CalendarEventFieldGroup.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i2q54gr5.CalendarEventFrequency?>()) {
      return (data != null
              ? _i2q54gr5.CalendarEventFrequency.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_imbjv41e.CalendarEventFutureOverride?>()) {
      return (data != null
              ? _imbjv41e.CalendarEventFutureOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_isyqnyev.CalendarEventOccurrence?>()) {
      return (data != null
              ? _isyqnyev.CalendarEventOccurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_icnciyzp.CalendarEventOccurrenceAction?>()) {
      return (data != null
              ? _icnciyzp.CalendarEventOccurrenceAction.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i7imxrlz.CalendarEventOccurrenceChange?>()) {
      return (data != null
              ? _i7imxrlz.CalendarEventOccurrenceChange.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1a4s0rt.CalendarEventOccurrencePreview?>()) {
      return (data != null
              ? _i1a4s0rt.CalendarEventOccurrencePreview.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivs4ir3j.CalendarEventOccurrenceQuery?>()) {
      return (data != null
              ? _ivs4ir3j.CalendarEventOccurrenceQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iaayjmj1.CalendarEventPage?>()) {
      return (data != null ? _iaayjmj1.CalendarEventPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i500bvo7.CalendarEventReceipt?>()) {
      return (data != null
              ? _i500bvo7.CalendarEventReceipt.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ilvoe14z.CalendarEventRecord?>()) {
      return (data != null
              ? _ilvoe14z.CalendarEventRecord.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqxs44bf.CalendarEventRecurrence?>()) {
      return (data != null
              ? _iqxs44bf.CalendarEventRecurrence.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iovyzq1q.CalendarEventRule?>()) {
      return (data != null ? _iovyzq1q.CalendarEventRule.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq1kxi25.CalendarEventSingleOverride?>()) {
      return (data != null
              ? _iq1kxi25.CalendarEventSingleOverride.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivzxk9bc.CalendarEventStatus?>()) {
      return (data != null
              ? _ivzxk9bc.CalendarEventStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3kbbl30.CalendarEventStatusRequest?>()) {
      return (data != null
              ? _i3kbbl30.CalendarEventStatusRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idbnuf6y.CalendarEventTimeKind?>()) {
      return (data != null
              ? _idbnuf6y.CalendarEventTimeKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ieswiaty.CalendarEventTiming?>()) {
      return (data != null
              ? _ieswiaty.CalendarEventTiming.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ijijze99.CalendarEventTimingOverrides?>()) {
      return (data != null
              ? _ijijze99.CalendarEventTimingOverrides.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iwjkdwy7.CalendarEventTransparency?>()) {
      return (data != null
              ? _iwjkdwy7.CalendarEventTransparency.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3ofr0ug.CalendarEventUpdateRequest?>()) {
      return (data != null
              ? _i3ofr0ug.CalendarEventUpdateRequest.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iqr733fy.CalendarEventView?>()) {
      return (data != null ? _iqr733fy.CalendarEventView.fromJson(data) : null)
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
    if (t == _is.getType<_ia3n9q23.CalendarFreeBusyCoverage?>()) {
      return (data != null
              ? _ia3n9q23.CalendarFreeBusyCoverage.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izms466b.CalendarFreeBusyKind?>()) {
      return (data != null
              ? _izms466b.CalendarFreeBusyKind.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i82zcrxb.CalendarFreeBusyPeriod?>()) {
      return (data != null
              ? _i82zcrxb.CalendarFreeBusyPeriod.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_idid5g6i.CalendarFreeBusyQuery?>()) {
      return (data != null
              ? _idid5g6i.CalendarFreeBusyQuery.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i3b615hg.CalendarFreeBusyView?>()) {
      return (data != null
              ? _i3b615hg.CalendarFreeBusyView.fromJson(data)
              : null)
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
    if (t == List<_iftiwkuj.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_iftiwkuj.CalendarEventFieldGroup>(e))
              .toList()
          as T;
    }
    if (t == _is.getType<List<_iftiwkuj.CalendarEventFieldGroup>?>()) {
      return (data != null
              ? (data as List)
                    .map(
                      (e) => deserialize<_iftiwkuj.CalendarEventFieldGroup>(e),
                    )
                    .toList()
              : null)
          as T;
    }
    if (t == List<_isyqnyev.CalendarEventOccurrence>) {
      return (data as List)
              .map((e) => deserialize<_isyqnyev.CalendarEventOccurrence>(e))
              .toList()
          as T;
    }
    if (t == List<_iqr733fy.CalendarEventView>) {
      return (data as List)
              .map((e) => deserialize<_iqr733fy.CalendarEventView>(e))
              .toList()
          as T;
    }
    if (t == List<_ieswiaty.CalendarEventTiming>) {
      return (data as List)
              .map((e) => deserialize<_ieswiaty.CalendarEventTiming>(e))
              .toList()
          as T;
    }
    if (t == List<_iq7751s4.CalendarEventByDay>) {
      return (data as List)
              .map((e) => deserialize<_iq7751s4.CalendarEventByDay>(e))
              .toList()
          as T;
    }
    if (t == List<int>) {
      return (data as List).map((e) => deserialize<int>(e)).toList() as T;
    }
    if (t == List<_iq1kxi25.CalendarEventSingleOverride>) {
      return (data as List)
              .map((e) => deserialize<_iq1kxi25.CalendarEventSingleOverride>(e))
              .toList()
          as T;
    }
    if (t == List<_imbjv41e.CalendarEventFutureOverride>) {
      return (data as List)
              .map((e) => deserialize<_imbjv41e.CalendarEventFutureOverride>(e))
              .toList()
          as T;
    }
    if (t == List<_i82zcrxb.CalendarFreeBusyPeriod>) {
      return (data as List)
              .map((e) => deserialize<_i82zcrxb.CalendarFreeBusyPeriod>(e))
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
    if (t == List<_il5gdr09.CalendarEventFieldGroup>) {
      return (data as List)
              .map((e) => deserialize<_il5gdr09.CalendarEventFieldGroup>(e))
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
      _iq7751s4.CalendarEventByDay => 'CalendarEventByDay',
      _i1bb5k1r.CalendarEventCivil => 'CalendarEventCivil',
      _id4cvk34.CalendarEventContent => 'CalendarEventContent',
      _i0orp171.CalendarEventCreateRequest => 'CalendarEventCreateRequest',
      _i23wc83s.CalendarEventDataRecord => 'CalendarEventDataRecord',
      _idn2i48l.CalendarEventDuration => 'CalendarEventDuration',
      _iftiwkuj.CalendarEventFieldGroup => 'CalendarEventFieldGroup',
      _i2q54gr5.CalendarEventFrequency => 'CalendarEventFrequency',
      _imbjv41e.CalendarEventFutureOverride => 'CalendarEventFutureOverride',
      _isyqnyev.CalendarEventOccurrence => 'CalendarEventOccurrence',
      _icnciyzp.CalendarEventOccurrenceAction =>
        'CalendarEventOccurrenceAction',
      _i7imxrlz.CalendarEventOccurrenceChange =>
        'CalendarEventOccurrenceChange',
      _i1a4s0rt.CalendarEventOccurrencePreview =>
        'CalendarEventOccurrencePreview',
      _ivs4ir3j.CalendarEventOccurrenceQuery => 'CalendarEventOccurrenceQuery',
      _iaayjmj1.CalendarEventPage => 'CalendarEventPage',
      _i500bvo7.CalendarEventReceipt => 'CalendarEventReceipt',
      _ilvoe14z.CalendarEventRecord => 'CalendarEventRecord',
      _iqxs44bf.CalendarEventRecurrence => 'CalendarEventRecurrence',
      _iovyzq1q.CalendarEventRule => 'CalendarEventRule',
      _iq1kxi25.CalendarEventSingleOverride => 'CalendarEventSingleOverride',
      _ivzxk9bc.CalendarEventStatus => 'CalendarEventStatus',
      _i3kbbl30.CalendarEventStatusRequest => 'CalendarEventStatusRequest',
      _idbnuf6y.CalendarEventTimeKind => 'CalendarEventTimeKind',
      _ieswiaty.CalendarEventTiming => 'CalendarEventTiming',
      _ijijze99.CalendarEventTimingOverrides => 'CalendarEventTimingOverrides',
      _iwjkdwy7.CalendarEventTransparency => 'CalendarEventTransparency',
      _i3ofr0ug.CalendarEventUpdateRequest => 'CalendarEventUpdateRequest',
      _iqr733fy.CalendarEventView => 'CalendarEventView',
      _ioicq9ju.CalendarException => 'CalendarException',
      _i7h2f30k.CalendarFailureCode => 'CalendarFailureCode',
      _i73hgz1s.CalendarFieldGroup => 'CalendarFieldGroup',
      _ia3n9q23.CalendarFreeBusyCoverage => 'CalendarFreeBusyCoverage',
      _izms466b.CalendarFreeBusyKind => 'CalendarFreeBusyKind',
      _i82zcrxb.CalendarFreeBusyPeriod => 'CalendarFreeBusyPeriod',
      _idid5g6i.CalendarFreeBusyQuery => 'CalendarFreeBusyQuery',
      _i3b615hg.CalendarFreeBusyView => 'CalendarFreeBusyView',
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
      case _iq7751s4.CalendarEventByDay():
        return 'CalendarEventByDay';
      case _i1bb5k1r.CalendarEventCivil():
        return 'CalendarEventCivil';
      case _id4cvk34.CalendarEventContent():
        return 'CalendarEventContent';
      case _i0orp171.CalendarEventCreateRequest():
        return 'CalendarEventCreateRequest';
      case _i23wc83s.CalendarEventDataRecord():
        return 'CalendarEventDataRecord';
      case _idn2i48l.CalendarEventDuration():
        return 'CalendarEventDuration';
      case _iftiwkuj.CalendarEventFieldGroup():
        return 'CalendarEventFieldGroup';
      case _i2q54gr5.CalendarEventFrequency():
        return 'CalendarEventFrequency';
      case _imbjv41e.CalendarEventFutureOverride():
        return 'CalendarEventFutureOverride';
      case _isyqnyev.CalendarEventOccurrence():
        return 'CalendarEventOccurrence';
      case _icnciyzp.CalendarEventOccurrenceAction():
        return 'CalendarEventOccurrenceAction';
      case _i7imxrlz.CalendarEventOccurrenceChange():
        return 'CalendarEventOccurrenceChange';
      case _i1a4s0rt.CalendarEventOccurrencePreview():
        return 'CalendarEventOccurrencePreview';
      case _ivs4ir3j.CalendarEventOccurrenceQuery():
        return 'CalendarEventOccurrenceQuery';
      case _iaayjmj1.CalendarEventPage():
        return 'CalendarEventPage';
      case _i500bvo7.CalendarEventReceipt():
        return 'CalendarEventReceipt';
      case _ilvoe14z.CalendarEventRecord():
        return 'CalendarEventRecord';
      case _iqxs44bf.CalendarEventRecurrence():
        return 'CalendarEventRecurrence';
      case _iovyzq1q.CalendarEventRule():
        return 'CalendarEventRule';
      case _iq1kxi25.CalendarEventSingleOverride():
        return 'CalendarEventSingleOverride';
      case _ivzxk9bc.CalendarEventStatus():
        return 'CalendarEventStatus';
      case _i3kbbl30.CalendarEventStatusRequest():
        return 'CalendarEventStatusRequest';
      case _idbnuf6y.CalendarEventTimeKind():
        return 'CalendarEventTimeKind';
      case _ieswiaty.CalendarEventTiming():
        return 'CalendarEventTiming';
      case _ijijze99.CalendarEventTimingOverrides():
        return 'CalendarEventTimingOverrides';
      case _iwjkdwy7.CalendarEventTransparency():
        return 'CalendarEventTransparency';
      case _i3ofr0ug.CalendarEventUpdateRequest():
        return 'CalendarEventUpdateRequest';
      case _iqr733fy.CalendarEventView():
        return 'CalendarEventView';
      case _ioicq9ju.CalendarException():
        return 'CalendarException';
      case _i7h2f30k.CalendarFailureCode():
        return 'CalendarFailureCode';
      case _i73hgz1s.CalendarFieldGroup():
        return 'CalendarFieldGroup';
      case _ia3n9q23.CalendarFreeBusyCoverage():
        return 'CalendarFreeBusyCoverage';
      case _izms466b.CalendarFreeBusyKind():
        return 'CalendarFreeBusyKind';
      case _i82zcrxb.CalendarFreeBusyPeriod():
        return 'CalendarFreeBusyPeriod';
      case _idid5g6i.CalendarFreeBusyQuery():
        return 'CalendarFreeBusyQuery';
      case _i3b615hg.CalendarFreeBusyView():
        return 'CalendarFreeBusyView';
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
    if (dataClassName == 'CalendarEventByDay') {
      return deserialize<_iq7751s4.CalendarEventByDay>(data['data']);
    }
    if (dataClassName == 'CalendarEventCivil') {
      return deserialize<_i1bb5k1r.CalendarEventCivil>(data['data']);
    }
    if (dataClassName == 'CalendarEventContent') {
      return deserialize<_id4cvk34.CalendarEventContent>(data['data']);
    }
    if (dataClassName == 'CalendarEventCreateRequest') {
      return deserialize<_i0orp171.CalendarEventCreateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventDataRecord') {
      return deserialize<_i23wc83s.CalendarEventDataRecord>(data['data']);
    }
    if (dataClassName == 'CalendarEventDuration') {
      return deserialize<_idn2i48l.CalendarEventDuration>(data['data']);
    }
    if (dataClassName == 'CalendarEventFieldGroup') {
      return deserialize<_iftiwkuj.CalendarEventFieldGroup>(data['data']);
    }
    if (dataClassName == 'CalendarEventFrequency') {
      return deserialize<_i2q54gr5.CalendarEventFrequency>(data['data']);
    }
    if (dataClassName == 'CalendarEventFutureOverride') {
      return deserialize<_imbjv41e.CalendarEventFutureOverride>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrence') {
      return deserialize<_isyqnyev.CalendarEventOccurrence>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrenceAction') {
      return deserialize<_icnciyzp.CalendarEventOccurrenceAction>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrenceChange') {
      return deserialize<_i7imxrlz.CalendarEventOccurrenceChange>(data['data']);
    }
    if (dataClassName == 'CalendarEventOccurrencePreview') {
      return deserialize<_i1a4s0rt.CalendarEventOccurrencePreview>(
        data['data'],
      );
    }
    if (dataClassName == 'CalendarEventOccurrenceQuery') {
      return deserialize<_ivs4ir3j.CalendarEventOccurrenceQuery>(data['data']);
    }
    if (dataClassName == 'CalendarEventPage') {
      return deserialize<_iaayjmj1.CalendarEventPage>(data['data']);
    }
    if (dataClassName == 'CalendarEventReceipt') {
      return deserialize<_i500bvo7.CalendarEventReceipt>(data['data']);
    }
    if (dataClassName == 'CalendarEventRecord') {
      return deserialize<_ilvoe14z.CalendarEventRecord>(data['data']);
    }
    if (dataClassName == 'CalendarEventRecurrence') {
      return deserialize<_iqxs44bf.CalendarEventRecurrence>(data['data']);
    }
    if (dataClassName == 'CalendarEventRule') {
      return deserialize<_iovyzq1q.CalendarEventRule>(data['data']);
    }
    if (dataClassName == 'CalendarEventSingleOverride') {
      return deserialize<_iq1kxi25.CalendarEventSingleOverride>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatus') {
      return deserialize<_ivzxk9bc.CalendarEventStatus>(data['data']);
    }
    if (dataClassName == 'CalendarEventStatusRequest') {
      return deserialize<_i3kbbl30.CalendarEventStatusRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventTimeKind') {
      return deserialize<_idbnuf6y.CalendarEventTimeKind>(data['data']);
    }
    if (dataClassName == 'CalendarEventTiming') {
      return deserialize<_ieswiaty.CalendarEventTiming>(data['data']);
    }
    if (dataClassName == 'CalendarEventTimingOverrides') {
      return deserialize<_ijijze99.CalendarEventTimingOverrides>(data['data']);
    }
    if (dataClassName == 'CalendarEventTransparency') {
      return deserialize<_iwjkdwy7.CalendarEventTransparency>(data['data']);
    }
    if (dataClassName == 'CalendarEventUpdateRequest') {
      return deserialize<_i3ofr0ug.CalendarEventUpdateRequest>(data['data']);
    }
    if (dataClassName == 'CalendarEventView') {
      return deserialize<_iqr733fy.CalendarEventView>(data['data']);
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
    if (dataClassName == 'CalendarFreeBusyCoverage') {
      return deserialize<_ia3n9q23.CalendarFreeBusyCoverage>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyKind') {
      return deserialize<_izms466b.CalendarFreeBusyKind>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyPeriod') {
      return deserialize<_i82zcrxb.CalendarFreeBusyPeriod>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyQuery') {
      return deserialize<_idid5g6i.CalendarFreeBusyQuery>(data['data']);
    }
    if (dataClassName == 'CalendarFreeBusyView') {
      return deserialize<_i3b615hg.CalendarFreeBusyView>(data['data']);
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
      case _i23wc83s.CalendarEventDataRecord:
        return _i23wc83s.CalendarEventDataRecord.t;
      case _ilvoe14z.CalendarEventRecord:
        return _ilvoe14z.CalendarEventRecord.t;
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
