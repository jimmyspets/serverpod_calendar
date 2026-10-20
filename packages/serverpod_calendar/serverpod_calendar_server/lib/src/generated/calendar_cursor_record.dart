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
import 'calendar_field_group.dart' as _i73hgz1s;

abstract class CalendarCursorRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarCursorRecord._({
    this.id,
    required this.token,
    required this.scopeKey,
    required this.principalId,
    required this.policyRevision,
    required this.dataRevision,
    required this.afterId,
    required this.pageSize,
    required this.fieldGroups,
    required this.expiresAt,
  });

  factory CalendarCursorRecord({
    int? id,
    required String token,
    required String scopeKey,
    required String principalId,
    required String policyRevision,
    required int dataRevision,
    required _is.UuidValue afterId,
    required int pageSize,
    required List<_i73hgz1s.CalendarFieldGroup> fieldGroups,
    required DateTime expiresAt,
  }) = _CalendarCursorRecordImpl;

  factory CalendarCursorRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarCursorRecord(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      scopeKey: jsonSerialization['scopeKey'] as String,
      principalId: jsonSerialization['principalId'] as String,
      policyRevision: jsonSerialization['policyRevision'] as String,
      dataRevision: jsonSerialization['dataRevision'] as int,
      afterId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['afterId'],
      ),
      pageSize: jsonSerialization['pageSize'] as int,
      fieldGroups: _ix00hwbf.Protocol()
          .deserialize<List<_i73hgz1s.CalendarFieldGroup>>(
            jsonSerialization['fieldGroups'],
          ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = CalendarCursorRecordTable();

  static const db = CalendarCursorRecordRepository._();

  @override
  int? id;

  String token;

  String scopeKey;

  String principalId;

  String policyRevision;

  int dataRevision;

  _is.UuidValue afterId;

  int pageSize;

  List<_i73hgz1s.CalendarFieldGroup> fieldGroups;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarCursorRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarCursorRecord copyWith({
    int? id,
    String? token,
    String? scopeKey,
    String? principalId,
    String? policyRevision,
    int? dataRevision,
    _is.UuidValue? afterId,
    int? pageSize,
    List<_i73hgz1s.CalendarFieldGroup>? fieldGroups,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarCursorRecord',
      if (id != null) 'id': id,
      'token': token,
      'scopeKey': scopeKey,
      'principalId': principalId,
      'policyRevision': policyRevision,
      'dataRevision': dataRevision,
      'afterId': afterId.toJson(),
      'pageSize': pageSize,
      'fieldGroups': fieldGroups.toJson(valueToJson: (v) => v.toJson()),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarCursorRecordInclude include() {
    return CalendarCursorRecordInclude._();
  }

  static CalendarCursorRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    CalendarCursorRecordInclude? include,
  }) {
    return CalendarCursorRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarCursorRecordImpl extends CalendarCursorRecord {
  _CalendarCursorRecordImpl({
    int? id,
    required String token,
    required String scopeKey,
    required String principalId,
    required String policyRevision,
    required int dataRevision,
    required _is.UuidValue afterId,
    required int pageSize,
    required List<_i73hgz1s.CalendarFieldGroup> fieldGroups,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         scopeKey: scopeKey,
         principalId: principalId,
         policyRevision: policyRevision,
         dataRevision: dataRevision,
         afterId: afterId,
         pageSize: pageSize,
         fieldGroups: fieldGroups,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [CalendarCursorRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarCursorRecord copyWith({
    Object? id = _Undefined,
    String? token,
    String? scopeKey,
    String? principalId,
    String? policyRevision,
    int? dataRevision,
    _is.UuidValue? afterId,
    int? pageSize,
    List<_i73hgz1s.CalendarFieldGroup>? fieldGroups,
    DateTime? expiresAt,
  }) {
    return CalendarCursorRecord(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      scopeKey: scopeKey ?? this.scopeKey,
      principalId: principalId ?? this.principalId,
      policyRevision: policyRevision ?? this.policyRevision,
      dataRevision: dataRevision ?? this.dataRevision,
      afterId: afterId ?? this.afterId,
      pageSize: pageSize ?? this.pageSize,
      fieldGroups: fieldGroups ?? this.fieldGroups.map((e0) => e0).toList(),
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CalendarCursorRecordUpdateTable
    extends _is.UpdateTable<CalendarCursorRecordTable> {
  CalendarCursorRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> principalId(String value) => _is.ColumnValue(
    table.principalId,
    value,
  );

  _is.ColumnValue<String, String> policyRevision(String value) =>
      _is.ColumnValue(
        table.policyRevision,
        value,
      );

  _is.ColumnValue<int, int> dataRevision(int value) => _is.ColumnValue(
    table.dataRevision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> afterId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.afterId,
        value,
      );

  _is.ColumnValue<int, int> pageSize(int value) => _is.ColumnValue(
    table.pageSize,
    value,
  );

  _is.ColumnValue<
    List<_i73hgz1s.CalendarFieldGroup>,
    List<_i73hgz1s.CalendarFieldGroup>
  >
  fieldGroups(List<_i73hgz1s.CalendarFieldGroup> value) => _is.ColumnValue(
    table.fieldGroups,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class CalendarCursorRecordTable extends _is.Table<int?> {
  CalendarCursorRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_cursor') {
    updateTable = CalendarCursorRecordUpdateTable(this);
    token = _is.ColumnString(
      'token',
      this,
    );
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    principalId = _is.ColumnString(
      'principalId',
      this,
    );
    policyRevision = _is.ColumnString(
      'policyRevision',
      this,
    );
    dataRevision = _is.ColumnInt(
      'dataRevision',
      this,
    );
    afterId = _is.ColumnUuid(
      'afterId',
      this,
    );
    pageSize = _is.ColumnInt(
      'pageSize',
      this,
    );
    fieldGroups = _is.ColumnSerializable<List<_i73hgz1s.CalendarFieldGroup>>(
      'fieldGroups',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final CalendarCursorRecordUpdateTable updateTable;

  late final _is.ColumnString token;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString principalId;

  late final _is.ColumnString policyRevision;

  late final _is.ColumnInt dataRevision;

  late final _is.ColumnUuid afterId;

  late final _is.ColumnInt pageSize;

  late final _is.ColumnSerializable<List<_i73hgz1s.CalendarFieldGroup>>
  fieldGroups;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    token,
    scopeKey,
    principalId,
    policyRevision,
    dataRevision,
    afterId,
    pageSize,
    fieldGroups,
    expiresAt,
  ];
}

class CalendarCursorRecordInclude extends _is.IncludeObject {
  CalendarCursorRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarCursorRecord.t;
}

class CalendarCursorRecordIncludeList extends _is.IncludeList {
  CalendarCursorRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarCursorRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarCursorRecord.t;
}

class CalendarCursorRecordRepository {
  const CalendarCursorRecordRepository._();

  /// Returns a list of [CalendarCursorRecord]s matching the given query parameters.
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
  Future<List<CalendarCursorRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarCursorRecord>(
      where: where?.call(CalendarCursorRecord.t),
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarCursorRecord] matching the given query parameters.
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
  Future<CalendarCursorRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarCursorRecord>(
      where: where?.call(CalendarCursorRecord.t),
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarCursorRecord] by its [id] or null if no such row exists.
  Future<CalendarCursorRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarCursorRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarCursorRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarCursorRecord]s will have their `id` fields set.
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
  Future<List<CalendarCursorRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarCursorRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarCursorRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarCursorRecord] and returns the inserted row.
  ///
  /// The returned [CalendarCursorRecord] will have its `id` field set.
  Future<CalendarCursorRecord> insertRow(
    _is.DatabaseSession session,
    CalendarCursorRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarCursorRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarCursorRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarCursorRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarCursorRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarCursorRecord> rows, {
    required _is.ColumnSelections<CalendarCursorRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarCursorRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarCursorRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarCursorRecord.t),
      updateColumns: updateColumns?.call(CalendarCursorRecord.t),
      updateWhere: updateWhere?.call(CalendarCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarCursorRecord] and returns the resulting row.
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
  /// The returned [CalendarCursorRecord] will have its `id` field set.
  Future<CalendarCursorRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarCursorRecord row, {
    required _is.ColumnSelections<CalendarCursorRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarCursorRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarCursorRecord>(
      row,
      conflictColumns: conflictColumns(CalendarCursorRecord.t),
      updateColumns: updateColumns?.call(CalendarCursorRecord.t),
      updateWhere: updateWhere?.call(CalendarCursorRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarCursorRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarCursorRecord>> update(
    _is.DatabaseSession session,
    List<CalendarCursorRecord> rows, {
    _is.ColumnSelections<CalendarCursorRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarCursorRecord>(
      rows,
      columns: columns?.call(CalendarCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarCursorRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarCursorRecord> updateRow(
    _is.DatabaseSession session,
    CalendarCursorRecord row, {
    _is.ColumnSelections<CalendarCursorRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarCursorRecord>(
      row,
      columns: columns?.call(CalendarCursorRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarCursorRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarCursorRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarCursorRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarCursorRecord>(
      id,
      columnValues: columnValues(CalendarCursorRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarCursorRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarCursorRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarCursorRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarCursorRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarCursorRecord>(
      columnValues: columnValues(CalendarCursorRecord.t.updateTable),
      where: where(CalendarCursorRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarCursorRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarCursorRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarCursorRecord> rows, {
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarCursorRecord>(
      rows,
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarCursorRecord].
  Future<CalendarCursorRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarCursorRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarCursorRecord>(
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
  Future<List<CalendarCursorRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarCursorRecordTable> where,
    _is.OrderByBuilder<CalendarCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarCursorRecord>(
      where: where(CalendarCursorRecord.t),
      orderBy: orderBy?.call(CalendarCursorRecord.t),
      orderByList: orderByList?.call(CalendarCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarCursorRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarCursorRecord>(
      where: where?.call(CalendarCursorRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarCursorRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarCursorRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarCursorRecord>(
      where: where(CalendarCursorRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
