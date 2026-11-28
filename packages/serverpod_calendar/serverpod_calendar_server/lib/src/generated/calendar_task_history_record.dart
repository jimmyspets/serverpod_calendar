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
import 'calendar_task_progress_action.dart' as _i6s7yrua;

abstract class CalendarTaskHistoryRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarTaskHistoryRecord._({
    this.id,
    required this.taskId,
    required this.originalKey,
    required this.originalStart,
    required this.revision,
    required this.action,
    required this.before,
    required this.after,
    required this.recordedAt,
  });

  factory CalendarTaskHistoryRecord({
    int? id,
    required _is.UuidValue taskId,
    required String originalKey,
    required _ieswiaty.CalendarEventTiming originalStart,
    required int revision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    required _ikcsq95s.CalendarTaskProgress before,
    required _ikcsq95s.CalendarTaskProgress after,
    required DateTime recordedAt,
  }) = _CalendarTaskHistoryRecordImpl;

  factory CalendarTaskHistoryRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskHistoryRecord(
      id: jsonSerialization['id'] as int?,
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      originalKey: jsonSerialization['originalKey'] as String,
      originalStart: _ix00hwbf.Protocol()
          .deserialize<_ieswiaty.CalendarEventTiming>(
            jsonSerialization['originalStart'],
          ),
      revision: jsonSerialization['revision'] as int,
      action: _i6s7yrua.CalendarTaskProgressAction.fromJson(
        (jsonSerialization['action'] as String),
      ),
      before: _ix00hwbf.Protocol().deserialize<_ikcsq95s.CalendarTaskProgress>(
        jsonSerialization['before'],
      ),
      after: _ix00hwbf.Protocol().deserialize<_ikcsq95s.CalendarTaskProgress>(
        jsonSerialization['after'],
      ),
      recordedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['recordedAt'],
      ),
    );
  }

  static final t = CalendarTaskHistoryRecordTable();

  static const db = CalendarTaskHistoryRecordRepository._();

  @override
  int? id;

  _is.UuidValue taskId;

  String originalKey;

  _ieswiaty.CalendarEventTiming originalStart;

  int revision;

  _i6s7yrua.CalendarTaskProgressAction action;

  _ikcsq95s.CalendarTaskProgress before;

  _ikcsq95s.CalendarTaskProgress after;

  DateTime recordedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarTaskHistoryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskHistoryRecord copyWith({
    int? id,
    _is.UuidValue? taskId,
    String? originalKey,
    _ieswiaty.CalendarEventTiming? originalStart,
    int? revision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    _ikcsq95s.CalendarTaskProgress? before,
    _ikcsq95s.CalendarTaskProgress? after,
    DateTime? recordedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskHistoryRecord',
      if (id != null) 'id': id,
      'taskId': taskId.toJson(),
      'originalKey': originalKey,
      'originalStart': originalStart.toJson(),
      'revision': revision,
      'action': action.toJson(),
      'before': before.toJson(),
      'after': after.toJson(),
      'recordedAt': recordedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarTaskHistoryRecordInclude include() {
    return CalendarTaskHistoryRecordInclude._();
  }

  static CalendarTaskHistoryRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    CalendarTaskHistoryRecordInclude? include,
  }) {
    return CalendarTaskHistoryRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskHistoryRecordImpl extends CalendarTaskHistoryRecord {
  _CalendarTaskHistoryRecordImpl({
    int? id,
    required _is.UuidValue taskId,
    required String originalKey,
    required _ieswiaty.CalendarEventTiming originalStart,
    required int revision,
    required _i6s7yrua.CalendarTaskProgressAction action,
    required _ikcsq95s.CalendarTaskProgress before,
    required _ikcsq95s.CalendarTaskProgress after,
    required DateTime recordedAt,
  }) : super._(
         id: id,
         taskId: taskId,
         originalKey: originalKey,
         originalStart: originalStart,
         revision: revision,
         action: action,
         before: before,
         after: after,
         recordedAt: recordedAt,
       );

  /// Returns a shallow copy of this [CalendarTaskHistoryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskHistoryRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? taskId,
    String? originalKey,
    _ieswiaty.CalendarEventTiming? originalStart,
    int? revision,
    _i6s7yrua.CalendarTaskProgressAction? action,
    _ikcsq95s.CalendarTaskProgress? before,
    _ikcsq95s.CalendarTaskProgress? after,
    DateTime? recordedAt,
  }) {
    return CalendarTaskHistoryRecord(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      originalKey: originalKey ?? this.originalKey,
      originalStart: originalStart ?? this.originalStart.copyWith(),
      revision: revision ?? this.revision,
      action: action ?? this.action,
      before: before ?? this.before.copyWith(),
      after: after ?? this.after.copyWith(),
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

class CalendarTaskHistoryRecordUpdateTable
    extends _is.UpdateTable<CalendarTaskHistoryRecordTable> {
  CalendarTaskHistoryRecordUpdateTable(super.table);

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

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<
    _i6s7yrua.CalendarTaskProgressAction,
    _i6s7yrua.CalendarTaskProgressAction
  >
  action(_i6s7yrua.CalendarTaskProgressAction value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<
    _ikcsq95s.CalendarTaskProgress,
    _ikcsq95s.CalendarTaskProgress
  >
  before(_ikcsq95s.CalendarTaskProgress value) => _is.ColumnValue(
    table.before,
    value,
  );

  _is.ColumnValue<
    _ikcsq95s.CalendarTaskProgress,
    _ikcsq95s.CalendarTaskProgress
  >
  after(_ikcsq95s.CalendarTaskProgress value) => _is.ColumnValue(
    table.after,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> recordedAt(DateTime value) =>
      _is.ColumnValue(
        table.recordedAt,
        value,
      );
}

class CalendarTaskHistoryRecordTable extends _is.Table<int?> {
  CalendarTaskHistoryRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_task_history') {
    updateTable = CalendarTaskHistoryRecordUpdateTable(this);
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
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    action = _is.ColumnEnum(
      'action',
      this,
      _is.EnumSerialization.byName,
    );
    before = _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress>(
      'before',
      this,
    );
    after = _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress>(
      'after',
      this,
    );
    recordedAt = _is.ColumnDateTime(
      'recordedAt',
      this,
    );
  }

  late final CalendarTaskHistoryRecordUpdateTable updateTable;

  late final _is.ColumnUuid taskId;

  late final _is.ColumnString originalKey;

  late final _is.ColumnSerializable<_ieswiaty.CalendarEventTiming>
  originalStart;

  late final _is.ColumnInt revision;

  late final _is.ColumnEnum<_i6s7yrua.CalendarTaskProgressAction> action;

  late final _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress> before;

  late final _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress> after;

  late final _is.ColumnDateTime recordedAt;

  @override
  List<_is.Column> get columns => [
    id,
    taskId,
    originalKey,
    originalStart,
    revision,
    action,
    before,
    after,
    recordedAt,
  ];
}

class CalendarTaskHistoryRecordInclude extends _is.IncludeObject {
  CalendarTaskHistoryRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarTaskHistoryRecord.t;
}

class CalendarTaskHistoryRecordIncludeList extends _is.IncludeList {
  CalendarTaskHistoryRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarTaskHistoryRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarTaskHistoryRecord.t;
}

class CalendarTaskHistoryRecordRepository {
  const CalendarTaskHistoryRecordRepository._();

  /// Returns a list of [CalendarTaskHistoryRecord]s matching the given query parameters.
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
  Future<List<CalendarTaskHistoryRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarTaskHistoryRecord>(
      where: where?.call(CalendarTaskHistoryRecord.t),
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarTaskHistoryRecord] matching the given query parameters.
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
  Future<CalendarTaskHistoryRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarTaskHistoryRecord>(
      where: where?.call(CalendarTaskHistoryRecord.t),
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarTaskHistoryRecord] by its [id] or null if no such row exists.
  Future<CalendarTaskHistoryRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarTaskHistoryRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarTaskHistoryRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarTaskHistoryRecord]s will have their `id` fields set.
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
  Future<List<CalendarTaskHistoryRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarTaskHistoryRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarTaskHistoryRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarTaskHistoryRecord] and returns the inserted row.
  ///
  /// The returned [CalendarTaskHistoryRecord] will have its `id` field set.
  Future<CalendarTaskHistoryRecord> insertRow(
    _is.DatabaseSession session,
    CalendarTaskHistoryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarTaskHistoryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarTaskHistoryRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarTaskHistoryRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskHistoryRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarTaskHistoryRecord> rows, {
    required _is.ColumnSelections<CalendarTaskHistoryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarTaskHistoryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarTaskHistoryRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarTaskHistoryRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskHistoryRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarTaskHistoryRecord] and returns the resulting row.
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
  /// The returned [CalendarTaskHistoryRecord] will have its `id` field set.
  Future<CalendarTaskHistoryRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarTaskHistoryRecord row, {
    required _is.ColumnSelections<CalendarTaskHistoryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarTaskHistoryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarTaskHistoryRecord>(
      row,
      conflictColumns: conflictColumns(CalendarTaskHistoryRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskHistoryRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskHistoryRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskHistoryRecord>> update(
    _is.DatabaseSession session,
    List<CalendarTaskHistoryRecord> rows, {
    _is.ColumnSelections<CalendarTaskHistoryRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarTaskHistoryRecord>(
      rows,
      columns: columns?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarTaskHistoryRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarTaskHistoryRecord> updateRow(
    _is.DatabaseSession session,
    CalendarTaskHistoryRecord row, {
    _is.ColumnSelections<CalendarTaskHistoryRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarTaskHistoryRecord>(
      row,
      columns: columns?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarTaskHistoryRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarTaskHistoryRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarTaskHistoryRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarTaskHistoryRecord>(
      id,
      columnValues: columnValues(CalendarTaskHistoryRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskHistoryRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskHistoryRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarTaskHistoryRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarTaskHistoryRecord>(
      columnValues: columnValues(CalendarTaskHistoryRecord.t.updateTable),
      where: where(CalendarTaskHistoryRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarTaskHistoryRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarTaskHistoryRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarTaskHistoryRecord> rows, {
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarTaskHistoryRecord>(
      rows,
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarTaskHistoryRecord].
  Future<CalendarTaskHistoryRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarTaskHistoryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarTaskHistoryRecord>(
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
  Future<List<CalendarTaskHistoryRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable> where,
    _is.OrderByBuilder<CalendarTaskHistoryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskHistoryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarTaskHistoryRecord>(
      where: where(CalendarTaskHistoryRecord.t),
      orderBy: orderBy?.call(CalendarTaskHistoryRecord.t),
      orderByList: orderByList?.call(CalendarTaskHistoryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarTaskHistoryRecord>(
      where: where?.call(CalendarTaskHistoryRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarTaskHistoryRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskHistoryRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarTaskHistoryRecord>(
      where: where(CalendarTaskHistoryRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
