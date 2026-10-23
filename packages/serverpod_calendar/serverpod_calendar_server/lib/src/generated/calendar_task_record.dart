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

abstract class CalendarTaskRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarTaskRecord._({
    this.id,
    required this.calendarId,
    required this.revision,
    this.deletedAt,
  });

  factory CalendarTaskRecord({
    _is.UuidValue? id,
    required _is.UuidValue calendarId,
    required int revision,
    DateTime? deletedAt,
  }) = _CalendarTaskRecordImpl;

  factory CalendarTaskRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarTaskRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      revision: jsonSerialization['revision'] as int,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = CalendarTaskRecordTable();

  static const db = CalendarTaskRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue calendarId;

  int revision;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarTaskRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? calendarId,
    int? revision,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskRecord',
      if (id != null) 'id': id?.toJson(),
      'calendarId': calendarId.toJson(),
      'revision': revision,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarTaskRecordInclude include() {
    return CalendarTaskRecordInclude._();
  }

  static CalendarTaskRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    CalendarTaskRecordInclude? include,
  }) {
    return CalendarTaskRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskRecordImpl extends CalendarTaskRecord {
  _CalendarTaskRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue calendarId,
    required int revision,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         calendarId: calendarId,
         revision: revision,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [CalendarTaskRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? calendarId,
    int? revision,
    Object? deletedAt = _Undefined,
  }) {
    return CalendarTaskRecord(
      id: id is _is.UuidValue? ? id : this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CalendarTaskRecordUpdateTable
    extends _is.UpdateTable<CalendarTaskRecordTable> {
  CalendarTaskRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );
}

class CalendarTaskRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarTaskRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_task') {
    updateTable = CalendarTaskRecordUpdateTable(this);
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    deletedAt = _is.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final CalendarTaskRecordUpdateTable updateTable;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnInt revision;

  late final _is.ColumnDateTime deletedAt;

  @override
  List<_is.Column> get columns => [
    id,
    calendarId,
    revision,
    deletedAt,
  ];
}

class CalendarTaskRecordInclude extends _is.IncludeObject {
  CalendarTaskRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarTaskRecord.t;
}

class CalendarTaskRecordIncludeList extends _is.IncludeList {
  CalendarTaskRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarTaskRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarTaskRecord.t;
}

class CalendarTaskRecordRepository {
  const CalendarTaskRecordRepository._();

  /// Returns a list of [CalendarTaskRecord]s matching the given query parameters.
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
  Future<List<CalendarTaskRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarTaskRecord>(
      where: where?.call(CalendarTaskRecord.t),
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarTaskRecord] matching the given query parameters.
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
  Future<CalendarTaskRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarTaskRecord>(
      where: where?.call(CalendarTaskRecord.t),
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarTaskRecord] by its [id] or null if no such row exists.
  Future<CalendarTaskRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarTaskRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarTaskRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarTaskRecord]s will have their `id` fields set.
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
  Future<List<CalendarTaskRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarTaskRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarTaskRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarTaskRecord] and returns the inserted row.
  ///
  /// The returned [CalendarTaskRecord] will have its `id` field set.
  Future<CalendarTaskRecord> insertRow(
    _is.DatabaseSession session,
    CalendarTaskRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarTaskRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarTaskRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarTaskRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarTaskRecord> rows, {
    required _is.ColumnSelections<CalendarTaskRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarTaskRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarTaskRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarTaskRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarTaskRecord] and returns the resulting row.
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
  /// The returned [CalendarTaskRecord] will have its `id` field set.
  Future<CalendarTaskRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarTaskRecord row, {
    required _is.ColumnSelections<CalendarTaskRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarTaskRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarTaskRecord>(
      row,
      conflictColumns: conflictColumns(CalendarTaskRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskRecord>> update(
    _is.DatabaseSession session,
    List<CalendarTaskRecord> rows, {
    _is.ColumnSelections<CalendarTaskRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarTaskRecord>(
      rows,
      columns: columns?.call(CalendarTaskRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarTaskRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarTaskRecord> updateRow(
    _is.DatabaseSession session,
    CalendarTaskRecord row, {
    _is.ColumnSelections<CalendarTaskRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarTaskRecord>(
      row,
      columns: columns?.call(CalendarTaskRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarTaskRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarTaskRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarTaskRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarTaskRecord>(
      id,
      columnValues: columnValues(CalendarTaskRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarTaskRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarTaskRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarTaskRecord>(
      columnValues: columnValues(CalendarTaskRecord.t.updateTable),
      where: where(CalendarTaskRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarTaskRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarTaskRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarTaskRecord> rows, {
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarTaskRecord>(
      rows,
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarTaskRecord].
  Future<CalendarTaskRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarTaskRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarTaskRecord>(
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
  Future<List<CalendarTaskRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskRecordTable> where,
    _is.OrderByBuilder<CalendarTaskRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarTaskRecord>(
      where: where(CalendarTaskRecord.t),
      orderBy: orderBy?.call(CalendarTaskRecord.t),
      orderByList: orderByList?.call(CalendarTaskRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarTaskRecord>(
      where: where?.call(CalendarTaskRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarTaskRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarTaskRecord>(
      where: where(CalendarTaskRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
