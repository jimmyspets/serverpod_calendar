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

abstract class CalendarScopeRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarScopeRecord._({
    this.id,
    required this.scopeKey,
    required this.revision,
  });

  factory CalendarScopeRecord({
    int? id,
    required String scopeKey,
    required int revision,
  }) = _CalendarScopeRecordImpl;

  factory CalendarScopeRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarScopeRecord(
      id: jsonSerialization['id'] as int?,
      scopeKey: jsonSerialization['scopeKey'] as String,
      revision: jsonSerialization['revision'] as int,
    );
  }

  static final t = CalendarScopeRecordTable();

  static const db = CalendarScopeRecordRepository._();

  @override
  int? id;

  String scopeKey;

  int revision;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarScopeRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarScopeRecord copyWith({
    int? id,
    String? scopeKey,
    int? revision,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarScopeRecord',
      if (id != null) 'id': id,
      'scopeKey': scopeKey,
      'revision': revision,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarScopeRecordInclude include() {
    return CalendarScopeRecordInclude._();
  }

  static CalendarScopeRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    CalendarScopeRecordInclude? include,
  }) {
    return CalendarScopeRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarScopeRecordImpl extends CalendarScopeRecord {
  _CalendarScopeRecordImpl({
    int? id,
    required String scopeKey,
    required int revision,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         revision: revision,
       );

  /// Returns a shallow copy of this [CalendarScopeRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarScopeRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    int? revision,
  }) {
    return CalendarScopeRecord(
      id: id is int? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      revision: revision ?? this.revision,
    );
  }
}

class CalendarScopeRecordUpdateTable
    extends _is.UpdateTable<CalendarScopeRecordTable> {
  CalendarScopeRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );
}

class CalendarScopeRecordTable extends _is.Table<int?> {
  CalendarScopeRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scope') {
    updateTable = CalendarScopeRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
  }

  late final CalendarScopeRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnInt revision;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    revision,
  ];
}

class CalendarScopeRecordInclude extends _is.IncludeObject {
  CalendarScopeRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarScopeRecord.t;
}

class CalendarScopeRecordIncludeList extends _is.IncludeList {
  CalendarScopeRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarScopeRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarScopeRecord.t;
}

class CalendarScopeRecordRepository {
  const CalendarScopeRecordRepository._();

  /// Returns a list of [CalendarScopeRecord]s matching the given query parameters.
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
  Future<List<CalendarScopeRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarScopeRecord>(
      where: where?.call(CalendarScopeRecord.t),
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarScopeRecord] matching the given query parameters.
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
  Future<CalendarScopeRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarScopeRecord>(
      where: where?.call(CalendarScopeRecord.t),
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarScopeRecord] by its [id] or null if no such row exists.
  Future<CalendarScopeRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarScopeRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarScopeRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarScopeRecord]s will have their `id` fields set.
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
  Future<List<CalendarScopeRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarScopeRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarScopeRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarScopeRecord] and returns the inserted row.
  ///
  /// The returned [CalendarScopeRecord] will have its `id` field set.
  Future<CalendarScopeRecord> insertRow(
    _is.DatabaseSession session,
    CalendarScopeRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarScopeRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarScopeRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarScopeRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarScopeRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarScopeRecord> rows, {
    required _is.ColumnSelections<CalendarScopeRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarScopeRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarScopeRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarScopeRecord.t),
      updateColumns: updateColumns?.call(CalendarScopeRecord.t),
      updateWhere: updateWhere?.call(CalendarScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarScopeRecord] and returns the resulting row.
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
  /// The returned [CalendarScopeRecord] will have its `id` field set.
  Future<CalendarScopeRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarScopeRecord row, {
    required _is.ColumnSelections<CalendarScopeRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarScopeRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarScopeRecord>(
      row,
      conflictColumns: conflictColumns(CalendarScopeRecord.t),
      updateColumns: updateColumns?.call(CalendarScopeRecord.t),
      updateWhere: updateWhere?.call(CalendarScopeRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarScopeRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarScopeRecord>> update(
    _is.DatabaseSession session,
    List<CalendarScopeRecord> rows, {
    _is.ColumnSelections<CalendarScopeRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarScopeRecord>(
      rows,
      columns: columns?.call(CalendarScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarScopeRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarScopeRecord> updateRow(
    _is.DatabaseSession session,
    CalendarScopeRecord row, {
    _is.ColumnSelections<CalendarScopeRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarScopeRecord>(
      row,
      columns: columns?.call(CalendarScopeRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarScopeRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarScopeRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarScopeRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarScopeRecord>(
      id,
      columnValues: columnValues(CalendarScopeRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarScopeRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarScopeRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarScopeRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarScopeRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarScopeRecord>(
      columnValues: columnValues(CalendarScopeRecord.t.updateTable),
      where: where(CalendarScopeRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarScopeRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarScopeRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarScopeRecord> rows, {
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarScopeRecord>(
      rows,
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarScopeRecord].
  Future<CalendarScopeRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarScopeRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarScopeRecord>(
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
  Future<List<CalendarScopeRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarScopeRecordTable> where,
    _is.OrderByBuilder<CalendarScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarScopeRecord>(
      where: where(CalendarScopeRecord.t),
      orderBy: orderBy?.call(CalendarScopeRecord.t),
      orderByList: orderByList?.call(CalendarScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarScopeRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarScopeRecord>(
      where: where?.call(CalendarScopeRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarScopeRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarScopeRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarScopeRecord>(
      where: where(CalendarScopeRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
