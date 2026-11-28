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
import 'calendar_event_timing.dart' as _ieswiaty;
import 'calendar_task_progress.dart' as _ikcsq95s;

abstract class CalendarTaskOccurrenceRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarTaskOccurrenceRecord._({
    this.id,
    required this.taskId,
    required this.originalKey,
    required this.originalStart,
    required this.progress,
  });

  factory CalendarTaskOccurrenceRecord({
    int? id,
    required _is.UuidValue taskId,
    required String originalKey,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) = _CalendarTaskOccurrenceRecordImpl;

  factory CalendarTaskOccurrenceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskOccurrenceRecord(
      id: jsonSerialization['id'] as int?,
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      originalKey: jsonSerialization['originalKey'] as String,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      progress: _ix00hwbf.Protocol()
          .deserialize<_ikcsq95s.CalendarTaskProgress>(
            jsonSerialization['progress'],
          ),
    );
  }

  static final t = CalendarTaskOccurrenceRecordTable();

  static const db = CalendarTaskOccurrenceRecordRepository._();

  @override
  int? id;

  _is.UuidValue taskId;

  String originalKey;

  _ieswiaty.CalendarEventTiming originalStart;

  _ikcsq95s.CalendarTaskProgress progress;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarTaskOccurrenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskOccurrenceRecord copyWith({
    int? id,
    _is.UuidValue? taskId,
    String? originalKey,
    _ieswiaty.CalendarEventTiming? originalStart,
    _ikcsq95s.CalendarTaskProgress? progress,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskOccurrenceRecord',
      if (id != null) 'id': id,
      'taskId': taskId.toJson(),
      'originalKey': originalKey,
      'originalStart': originalStart.toJson(),
      'progress': progress.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarTaskOccurrenceRecordInclude include() {
    return CalendarTaskOccurrenceRecordInclude._();
  }

  static CalendarTaskOccurrenceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    CalendarTaskOccurrenceRecordInclude? include,
  }) {
    return CalendarTaskOccurrenceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskOccurrenceRecordImpl extends CalendarTaskOccurrenceRecord {
  _CalendarTaskOccurrenceRecordImpl({
    int? id,
    required _is.UuidValue taskId,
    required String originalKey,
    required _ieswiaty.CalendarEventTiming originalStart,
    required _ikcsq95s.CalendarTaskProgress progress,
  }) : super._(
         id: id,
         taskId: taskId,
         originalKey: originalKey,
         originalStart: originalStart,
         progress: progress,
       );

  /// Returns a shallow copy of this [CalendarTaskOccurrenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskOccurrenceRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? taskId,
    String? originalKey,
    _ieswiaty.CalendarEventTiming? originalStart,
    _ikcsq95s.CalendarTaskProgress? progress,
  }) {
    return CalendarTaskOccurrenceRecord(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      originalKey: originalKey ?? this.originalKey,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      progress: progress ?? this.progress.copyWith(),
    );
  }
}

class CalendarTaskOccurrenceRecordUpdateTable
    extends _is.UpdateTable<CalendarTaskOccurrenceRecordTable> {
  CalendarTaskOccurrenceRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> taskId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.taskId,
        value,
      );

  _is.ColumnValue<String, String> originalKey(String value) => _is.ColumnValue(
    table.originalKey,
    value,
  );

  _is.ColumnValue<_ieswiaty.CalendarEventTiming, _ieswiaty.CalendarEventTiming>
  originalStart(_ieswiaty.CalendarEventTiming value) => _is.ColumnValue(
    table.originalStart,
    value,
  );

  _is.ColumnValue<
    _ikcsq95s.CalendarTaskProgress,
    _ikcsq95s.CalendarTaskProgress
  >
  progress(_ikcsq95s.CalendarTaskProgress value) => _is.ColumnValue(
    table.progress,
    value,
  );
}

class CalendarTaskOccurrenceRecordTable extends _is.Table<int?> {
  CalendarTaskOccurrenceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_task_occurrence') {
    updateTable = CalendarTaskOccurrenceRecordUpdateTable(this);
    taskId = _is.ColumnUuid(
      'taskId',
      this,
    );
    originalKey = _is.ColumnString(
      'originalKey',
      this,
    );
    originalStart = _is.ColumnSerializable<_ieswiaty.CalendarEventTiming>(
      'originalStart',
      this,
    );
    progress = _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress>(
      'progress',
      this,
    );
  }

  late final CalendarTaskOccurrenceRecordUpdateTable updateTable;

  late final _is.ColumnUuid taskId;

  late final _is.ColumnString originalKey;

  late final _is.ColumnSerializable<_ieswiaty.CalendarEventTiming>
  originalStart;

  late final _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress> progress;

  @override
  List<_is.Column> get columns => [
    id,
    taskId,
    originalKey,
    originalStart,
    progress,
  ];
}

class CalendarTaskOccurrenceRecordInclude extends _is.IncludeObject {
  CalendarTaskOccurrenceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarTaskOccurrenceRecord.t;
}

class CalendarTaskOccurrenceRecordIncludeList extends _is.IncludeList {
  CalendarTaskOccurrenceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarTaskOccurrenceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarTaskOccurrenceRecord.t;
}

class CalendarTaskOccurrenceRecordRepository {
  const CalendarTaskOccurrenceRecordRepository._();

  /// Returns a list of [CalendarTaskOccurrenceRecord]s matching the given query parameters.
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
  Future<List<CalendarTaskOccurrenceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarTaskOccurrenceRecord>(
      where: where?.call(CalendarTaskOccurrenceRecord.t),
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarTaskOccurrenceRecord] matching the given query parameters.
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
  Future<CalendarTaskOccurrenceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarTaskOccurrenceRecord>(
      where: where?.call(CalendarTaskOccurrenceRecord.t),
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarTaskOccurrenceRecord] by its [id] or null if no such row exists.
  Future<CalendarTaskOccurrenceRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarTaskOccurrenceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarTaskOccurrenceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarTaskOccurrenceRecord]s will have their `id` fields set.
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
  Future<List<CalendarTaskOccurrenceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarTaskOccurrenceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarTaskOccurrenceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarTaskOccurrenceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarTaskOccurrenceRecord] will have its `id` field set.
  Future<CalendarTaskOccurrenceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarTaskOccurrenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarTaskOccurrenceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarTaskOccurrenceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarTaskOccurrenceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskOccurrenceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarTaskOccurrenceRecord> rows, {
    required _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarTaskOccurrenceRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarTaskOccurrenceRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskOccurrenceRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarTaskOccurrenceRecord] and returns the resulting row.
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
  /// The returned [CalendarTaskOccurrenceRecord] will have its `id` field set.
  Future<CalendarTaskOccurrenceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarTaskOccurrenceRecord row, {
    required _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarTaskOccurrenceRecord>(
      row,
      conflictColumns: conflictColumns(CalendarTaskOccurrenceRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskOccurrenceRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskOccurrenceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskOccurrenceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarTaskOccurrenceRecord> rows, {
    _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarTaskOccurrenceRecord>(
      rows,
      columns: columns?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarTaskOccurrenceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarTaskOccurrenceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarTaskOccurrenceRecord row, {
    _is.ColumnSelections<CalendarTaskOccurrenceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarTaskOccurrenceRecord>(
      row,
      columns: columns?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarTaskOccurrenceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarTaskOccurrenceRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarTaskOccurrenceRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarTaskOccurrenceRecord>(
      id,
      columnValues: columnValues(CalendarTaskOccurrenceRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskOccurrenceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskOccurrenceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarTaskOccurrenceRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarTaskOccurrenceRecord>(
      columnValues: columnValues(CalendarTaskOccurrenceRecord.t.updateTable),
      where: where(CalendarTaskOccurrenceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarTaskOccurrenceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarTaskOccurrenceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarTaskOccurrenceRecord> rows, {
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarTaskOccurrenceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarTaskOccurrenceRecord].
  Future<CalendarTaskOccurrenceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarTaskOccurrenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarTaskOccurrenceRecord>(
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
  Future<List<CalendarTaskOccurrenceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>
    where,
    _is.OrderByBuilder<CalendarTaskOccurrenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskOccurrenceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarTaskOccurrenceRecord>(
      where: where(CalendarTaskOccurrenceRecord.t),
      orderBy: orderBy?.call(CalendarTaskOccurrenceRecord.t),
      orderByList: orderByList?.call(CalendarTaskOccurrenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarTaskOccurrenceRecord>(
      where: where?.call(CalendarTaskOccurrenceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarTaskOccurrenceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskOccurrenceRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarTaskOccurrenceRecord>(
      where: where(CalendarTaskOccurrenceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
