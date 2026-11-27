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

abstract class CalendarEventRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarEventRecord._({
    this.id,
    required this.calendarId,
    required this.revision,
    this.deletedAt,
  });

  factory CalendarEventRecord({
    _is.UuidValue? id,
    required _is.UuidValue calendarId,
    required int revision,
    DateTime? deletedAt,
  }) = _CalendarEventRecordImpl;

  factory CalendarEventRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarEventRecord(
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

  static final t = CalendarEventRecordTable();

  static const db = CalendarEventRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue calendarId;

  int revision;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarEventRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarEventRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? calendarId,
    int? revision,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarEventRecord',
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

  static CalendarEventRecordInclude include() {
    return CalendarEventRecordInclude._();
  }

  static CalendarEventRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    CalendarEventRecordInclude? include,
  }) {
    return CalendarEventRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarEventRecordImpl extends CalendarEventRecord {
  _CalendarEventRecordImpl({
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

  /// Returns a shallow copy of this [CalendarEventRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarEventRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? calendarId,
    int? revision,
    Object? deletedAt = _Undefined,
  }) {
    return CalendarEventRecord(
      id: id is _is.UuidValue? ? id : this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CalendarEventRecordUpdateTable
    extends _is.UpdateTable<CalendarEventRecordTable> {
  CalendarEventRecordUpdateTable(super.table);

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

class CalendarEventRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarEventRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_event') {
    updateTable = CalendarEventRecordUpdateTable(this);
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

  late final CalendarEventRecordUpdateTable updateTable;

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

class CalendarEventRecordInclude extends _is.IncludeObject {
  CalendarEventRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarEventRecord.t;
}

class CalendarEventRecordIncludeList extends _is.IncludeList {
  CalendarEventRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarEventRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarEventRecord.t;
}

class CalendarEventRecordRepository {
  const CalendarEventRecordRepository._();

  /// Returns a list of [CalendarEventRecord]s matching the given query parameters.
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
  Future<List<CalendarEventRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarEventRecord>(
      where: where?.call(CalendarEventRecord.t),
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarEventRecord] matching the given query parameters.
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
  Future<CalendarEventRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarEventRecord>(
      where: where?.call(CalendarEventRecord.t),
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarEventRecord] by its [id] or null if no such row exists.
  Future<CalendarEventRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarEventRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarEventRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarEventRecord]s will have their `id` fields set.
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
  Future<List<CalendarEventRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarEventRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarEventRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarEventRecord] and returns the inserted row.
  ///
  /// The returned [CalendarEventRecord] will have its `id` field set.
  Future<CalendarEventRecord> insertRow(
    _is.DatabaseSession session,
    CalendarEventRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarEventRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarEventRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarEventRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarEventRecord> rows, {
    required _is.ColumnSelections<CalendarEventRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarEventRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarEventRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarEventRecord.t),
      updateColumns: updateColumns?.call(CalendarEventRecord.t),
      updateWhere: updateWhere?.call(CalendarEventRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarEventRecord] and returns the resulting row.
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
  /// The returned [CalendarEventRecord] will have its `id` field set.
  Future<CalendarEventRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarEventRecord row, {
    required _is.ColumnSelections<CalendarEventRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarEventRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarEventRecord>(
      row,
      conflictColumns: conflictColumns(CalendarEventRecord.t),
      updateColumns: updateColumns?.call(CalendarEventRecord.t),
      updateWhere: updateWhere?.call(CalendarEventRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEventRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventRecord>> update(
    _is.DatabaseSession session,
    List<CalendarEventRecord> rows, {
    _is.ColumnSelections<CalendarEventRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarEventRecord>(
      rows,
      columns: columns?.call(CalendarEventRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarEventRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarEventRecord> updateRow(
    _is.DatabaseSession session,
    CalendarEventRecord row, {
    _is.ColumnSelections<CalendarEventRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarEventRecord>(
      row,
      columns: columns?.call(CalendarEventRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarEventRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarEventRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarEventRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarEventRecord>(
      id,
      columnValues: columnValues(CalendarEventRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarEventRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarEventRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarEventRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarEventRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarEventRecord>(
      columnValues: columnValues(CalendarEventRecord.t.updateTable),
      where: where(CalendarEventRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarEventRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarEventRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarEventRecord> rows, {
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarEventRecord>(
      rows,
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarEventRecord].
  Future<CalendarEventRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarEventRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarEventRecord>(
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
  Future<List<CalendarEventRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventRecordTable> where,
    _is.OrderByBuilder<CalendarEventRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarEventRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarEventRecord>(
      where: where(CalendarEventRecord.t),
      orderBy: orderBy?.call(CalendarEventRecord.t),
      orderByList: orderByList?.call(CalendarEventRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarEventRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarEventRecord>(
      where: where?.call(CalendarEventRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarEventRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarEventRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarEventRecord>(
      where: where(CalendarEventRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
