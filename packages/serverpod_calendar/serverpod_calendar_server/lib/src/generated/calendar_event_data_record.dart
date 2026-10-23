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
import 'calendar_event_content.dart' as _id4cvk34;
import 'calendar_event_import_baseline.dart' as _iblybidp;
import 'calendar_event_protocol_state.dart' as _i8iqsbco;
import 'calendar_event_timing_overrides.dart' as _ijijze99;

abstract class CalendarEventDataRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarEventDataRecord._({
    this.id,
    required this.eventId,
    required this.calendarId,
    required this.protocolUid,
    required this.uidDigest,
    this.protocolState,
    this.importBaseline,
    this.timingOverrides,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarEventDataRecord({
    int? id,
    required _is.UuidValue eventId,
    required _is.UuidValue calendarId,
    required String protocolUid,
    required String uidDigest,
    _i8iqsbco.CalendarEventProtocolState? protocolState,
    _iblybidp.CalendarEventImportBaseline? importBaseline,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
    required _id4cvk34.CalendarEventContent content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarEventDataRecordImpl;

  factory CalendarEventDataRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarEventDataRecord(
      id: jsonSerialization['id'] as int?,
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      protocolUid: jsonSerialization['protocolUid'] as String,
      uidDigest: jsonSerialization['uidDigest'] as String,
      protocolState: jsonSerialization['protocolState'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_i8iqsbco.CalendarEventProtocolState>(
                  jsonSerialization['protocolState'],
                ),
      importBaseline: jsonSerialization['importBaseline'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_iblybidp.CalendarEventImportBaseline>(
                  jsonSerialization['importBaseline'],
                ),
      timingOverrides: jsonSerialization['timingOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ijijze99.CalendarEventTimingOverrides>(
                  jsonSerialization['timingOverrides'],
                ),
      content: _ix00hwbf.Protocol().deserialize<_id4cvk34.CalendarEventContent>(
        jsonSerialization['content'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarEventDataRecordTable();

  static const db = CalendarEventDataRecordRepository._();

  @override
  int? id;

  _is.UuidValue eventId;

  _is.UuidValue calendarId;

  String protocolUid;

  String uidDigest;

  _i8iqsbco.CalendarEventProtocolState? protocolState;

  _iblybidp.CalendarEventImportBaseline? importBaseline;

  _ijijze99.CalendarEventTimingOverrides? timingOverrides;

  _id4cvk34.CalendarEventContent content;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarEventDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventDataRecord copyWith({
    int? id,
    _is.UuidValue? eventId,
    _is.UuidValue? calendarId,
    String? protocolUid,
    String? uidDigest,
    _i8iqsbco.CalendarEventProtocolState? protocolState,
    _iblybidp.CalendarEventImportBaseline? importBaseline,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
    _id4cvk34.CalendarEventContent? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventDataRecord',
      if (id != null) 'id': id,
      'eventId': eventId.toJson(),
      'calendarId': calendarId.toJson(),
      'protocolUid': protocolUid,
      'uidDigest': uidDigest,
      if (protocolState != null) 'protocolState': protocolState?.toJson(),
      if (importBaseline != null) 'importBaseline': importBaseline?.toJson(),
      if (timingOverrides != null) 'timingOverrides': timingOverrides?.toJson(),
      'content': content.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarEventDataRecordInclude include() {
    return CalendarEventDataRecordInclude._();
  }

  static CalendarEventDataRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    CalendarEventDataRecordInclude? include,
  }) {
    return CalendarEventDataRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventDataRecordImpl extends CalendarEventDataRecord {
  _CalendarEventDataRecordImpl({
    int? id,
    required _is.UuidValue eventId,
    required _is.UuidValue calendarId,
    required String protocolUid,
    required String uidDigest,
    _i8iqsbco.CalendarEventProtocolState? protocolState,
    _iblybidp.CalendarEventImportBaseline? importBaseline,
    _ijijze99.CalendarEventTimingOverrides? timingOverrides,
    required _id4cvk34.CalendarEventContent content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         eventId: eventId,
         calendarId: calendarId,
         protocolUid: protocolUid,
         uidDigest: uidDigest,
         protocolState: protocolState,
         importBaseline: importBaseline,
         timingOverrides: timingOverrides,
         content: content,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarEventDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventDataRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? eventId,
    _is.UuidValue? calendarId,
    String? protocolUid,
    String? uidDigest,
    Object? protocolState = _Undefined,
    Object? importBaseline = _Undefined,
    Object? timingOverrides = _Undefined,
    _id4cvk34.CalendarEventContent? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventDataRecord(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      protocolUid: protocolUid ?? this.protocolUid,
      uidDigest: uidDigest ?? this.uidDigest,
      protocolState: protocolState is _i8iqsbco.CalendarEventProtocolState?
          ? protocolState
          : this.protocolState?.copyWith(),
      importBaseline: importBaseline is _iblybidp.CalendarEventImportBaseline?
          ? importBaseline
          : this.importBaseline?.copyWith(),
      timingOverrides:
          timingOverrides is _ijijze99.CalendarEventTimingOverrides?
          ? timingOverrides
          : this.timingOverrides?.copyWith(),
      content: content ?? this.content.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarEventDataRecordUpdateTable
    extends _is.UpdateTable<CalendarEventDataRecordTable> {
  CalendarEventDataRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> eventId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.eventId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<String, String> protocolUid(String value) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<String, String> uidDigest(String value) => _is.ColumnValue(
    table.uidDigest,
    value,
  );

  _is.ColumnValue<
    _i8iqsbco.CalendarEventProtocolState,
    _i8iqsbco.CalendarEventProtocolState
  >
  protocolState(_i8iqsbco.CalendarEventProtocolState? value) => _is.ColumnValue(
    table.protocolState,
    value,
  );

  _is.ColumnValue<
    _iblybidp.CalendarEventImportBaseline,
    _iblybidp.CalendarEventImportBaseline
  >
  importBaseline(_iblybidp.CalendarEventImportBaseline? value) =>
      _is.ColumnValue(
        table.importBaseline,
        value,
      );

  _is.ColumnValue<
    _ijijze99.CalendarEventTimingOverrides,
    _ijijze99.CalendarEventTimingOverrides
  >
  timingOverrides(_ijijze99.CalendarEventTimingOverrides? value) =>
      _is.ColumnValue(
        table.timingOverrides,
        value,
      );

  _is.ColumnValue<
    _id4cvk34.CalendarEventContent,
    _id4cvk34.CalendarEventContent
  >
  content(_id4cvk34.CalendarEventContent value) => _is.ColumnValue(
    table.content,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CalendarEventDataRecordTable extends _is.Table<int?> {
  CalendarEventDataRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_event_data') {
    updateTable = CalendarEventDataRecordUpdateTable(this);
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    protocolUid = _is.ColumnString(
      'protocolUid',
      this,
    );
    uidDigest = _is.ColumnString(
      'uidDigest',
      this,
    );
    protocolState =
        _is.ColumnSerializable<_i8iqsbco.CalendarEventProtocolState>(
          'protocolState',
          this,
        );
    importBaseline =
        _is.ColumnSerializable<_iblybidp.CalendarEventImportBaseline>(
          'importBaseline',
          this,
        );
    timingOverrides =
        _is.ColumnSerializable<_ijijze99.CalendarEventTimingOverrides>(
          'timingOverrides',
          this,
        );
    content = _is.ColumnSerializable<_id4cvk34.CalendarEventContent>(
      'content',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CalendarEventDataRecordUpdateTable updateTable;

  late final _is.ColumnUuid eventId;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnString protocolUid;

  late final _is.ColumnString uidDigest;

  late final _is.ColumnSerializable<_i8iqsbco.CalendarEventProtocolState>
  protocolState;

  late final _is.ColumnSerializable<_iblybidp.CalendarEventImportBaseline>
  importBaseline;

  late final _is.ColumnSerializable<_ijijze99.CalendarEventTimingOverrides>
  timingOverrides;

  late final _is.ColumnSerializable<_id4cvk34.CalendarEventContent> content;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    eventId,
    calendarId,
    protocolUid,
    uidDigest,
    protocolState,
    importBaseline,
    timingOverrides,
    content,
    createdAt,
    updatedAt,
  ];
}

class CalendarEventDataRecordInclude extends _is.IncludeObject {
  CalendarEventDataRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarEventDataRecord.t;
}

class CalendarEventDataRecordIncludeList extends _is.IncludeList {
  CalendarEventDataRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarEventDataRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarEventDataRecord.t;
}

class CalendarEventDataRecordRepository {
  const CalendarEventDataRecordRepository._();

  /// Returns a list of [CalendarEventDataRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<CalendarEventDataRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarEventDataRecord>(
      where: where?.call(CalendarEventDataRecord.t),
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarEventDataRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<CalendarEventDataRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarEventDataRecord>(
      where: where?.call(CalendarEventDataRecord.t),
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarEventDataRecord] by its [id] or null if no such row exists.
  Future<CalendarEventDataRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarEventDataRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarEventDataRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarEventDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarEventDataRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarEventDataRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarEventDataRecord] and returns the inserted row.
  ///
  /// The returned [CalendarEventDataRecord] will have its `id` field set.
  Future<CalendarEventDataRecord> insertRow(
    _is.DatabaseSession session,
    CalendarEventDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarEventDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarEventDataRecord]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [CalendarEventDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarEventDataRecord> rows, {
    required _is.ColumnSelections<CalendarEventDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarEventDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarEventDataRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarEventDataRecord.t),
      updateColumns: updateColumns?.call(CalendarEventDataRecord.t),
      updateWhere: updateWhere?.call(CalendarEventDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarEventDataRecord] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [CalendarEventDataRecord] will have its `id` field set.
  Future<CalendarEventDataRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarEventDataRecord row, {
    required _is.ColumnSelections<CalendarEventDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarEventDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarEventDataRecord>(
      row,
      conflictColumns: conflictColumns(CalendarEventDataRecord.t),
      updateColumns: updateColumns?.call(CalendarEventDataRecord.t),
      updateWhere: updateWhere?.call(CalendarEventDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEventDataRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> update(
    _is.DatabaseSession session,
    List<CalendarEventDataRecord> rows, {
    _is.ColumnSelections<CalendarEventDataRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarEventDataRecord>(
      rows,
      columns: columns?.call(CalendarEventDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarEventDataRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarEventDataRecord> updateRow(
    _is.DatabaseSession session,
    CalendarEventDataRecord row, {
    _is.ColumnSelections<CalendarEventDataRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarEventDataRecord>(
      row,
      columns: columns?.call(CalendarEventDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarEventDataRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarEventDataRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarEventDataRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarEventDataRecord>(
      id,
      columnValues: columnValues(CalendarEventDataRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEventDataRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarEventDataRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarEventDataRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarEventDataRecord>(
      columnValues: columnValues(CalendarEventDataRecord.t.updateTable),
      where: where(CalendarEventDataRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarEventDataRecord]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarEventDataRecord> rows, {
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarEventDataRecord>(
      rows,
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarEventDataRecord].
  Future<CalendarEventDataRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarEventDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarEventDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventDataRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventDataRecordTable> where,
    _is.OrderByBuilder<CalendarEventDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarEventDataRecord>(
      where: where(CalendarEventDataRecord.t),
      orderBy: orderBy?.call(CalendarEventDataRecord.t),
      orderByList: orderByList?.call(CalendarEventDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventDataRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarEventDataRecord>(
      where: where?.call(CalendarEventDataRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarEventDataRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventDataRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarEventDataRecord>(
      where: where(CalendarEventDataRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
