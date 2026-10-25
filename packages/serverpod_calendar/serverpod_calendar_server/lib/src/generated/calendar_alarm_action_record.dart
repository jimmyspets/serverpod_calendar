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

abstract class CalendarAlarmActionRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAlarmActionRecord._({
    this.id,
    required this.alarmId,
    required this.originalKey,
    required this.revision,
    this.acknowledgedAt,
    this.dismissedAt,
    this.pendingSnoozeAt,
    int? snoozeRevision,
    required this.createdAt,
    required this.updatedAt,
  }) : snoozeRevision = snoozeRevision ?? 0;

  factory CalendarAlarmActionRecord({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required String originalKey,
    required int revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    int? snoozeRevision,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarAlarmActionRecordImpl;

  factory CalendarAlarmActionRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmActionRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      alarmId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      originalKey: jsonSerialization['originalKey'] as String,
      revision: jsonSerialization['revision'] as int,
      acknowledgedAt: jsonSerialization['acknowledgedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['acknowledgedAt'],
            ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
      pendingSnoozeAt: jsonSerialization['pendingSnoozeAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['pendingSnoozeAt'],
            ),
      snoozeRevision: jsonSerialization['snoozeRevision'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarAlarmActionRecordTable();

  static const db = CalendarAlarmActionRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue alarmId;

  String originalKey;

  int revision;

  DateTime? acknowledgedAt;

  DateTime? dismissedAt;

  DateTime? pendingSnoozeAt;

  int snoozeRevision;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAlarmActionRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmActionRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? alarmId,
    String? originalKey,
    int? revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    int? snoozeRevision,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmActionRecord',
      if (id != null) 'id': id?.toJson(),
      'alarmId': alarmId.toJson(),
      'originalKey': originalKey,
      'revision': revision,
      if (acknowledgedAt != null) 'acknowledgedAt': acknowledgedAt?.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (pendingSnoozeAt != null) 'pendingSnoozeAt': pendingSnoozeAt?.toJson(),
      'snoozeRevision': snoozeRevision,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAlarmActionRecordInclude include() {
    return CalendarAlarmActionRecordInclude._();
  }

  static CalendarAlarmActionRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    CalendarAlarmActionRecordInclude? include,
  }) {
    return CalendarAlarmActionRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmActionRecordImpl extends CalendarAlarmActionRecord {
  _CalendarAlarmActionRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required String originalKey,
    required int revision,
    DateTime? acknowledgedAt,
    DateTime? dismissedAt,
    DateTime? pendingSnoozeAt,
    int? snoozeRevision,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         alarmId: alarmId,
         originalKey: originalKey,
         revision: revision,
         acknowledgedAt: acknowledgedAt,
         dismissedAt: dismissedAt,
         pendingSnoozeAt: pendingSnoozeAt,
         snoozeRevision: snoozeRevision,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmActionRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmActionRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? alarmId,
    String? originalKey,
    int? revision,
    Object? acknowledgedAt = _Undefined,
    Object? dismissedAt = _Undefined,
    Object? pendingSnoozeAt = _Undefined,
    int? snoozeRevision,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarAlarmActionRecord(
      id: id is _is.UuidValue? ? id : this.id,
      alarmId: alarmId ?? this.alarmId,
      originalKey: originalKey ?? this.originalKey,
      revision: revision ?? this.revision,
      acknowledgedAt: acknowledgedAt is DateTime?
          ? acknowledgedAt
          : this.acknowledgedAt,
      dismissedAt: dismissedAt is DateTime? ? dismissedAt : this.dismissedAt,
      pendingSnoozeAt: pendingSnoozeAt is DateTime?
          ? pendingSnoozeAt
          : this.pendingSnoozeAt,
      snoozeRevision: snoozeRevision ?? this.snoozeRevision,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarAlarmActionRecordUpdateTable
    extends _is.UpdateTable<CalendarAlarmActionRecordTable> {
  CalendarAlarmActionRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> alarmId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.alarmId,
        value,
      );

  _is.ColumnValue<String, String> originalKey(String value) => _is.ColumnValue(
    table.originalKey,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> acknowledgedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acknowledgedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dismissedAt(DateTime? value) =>
      _is.ColumnValue(
        table.dismissedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> pendingSnoozeAt(DateTime? value) =>
      _is.ColumnValue(
        table.pendingSnoozeAt,
        value,
      );

  _is.ColumnValue<int, int> snoozeRevision(int value) => _is.ColumnValue(
    table.snoozeRevision,
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

class CalendarAlarmActionRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAlarmActionRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_alarm_action') {
    updateTable = CalendarAlarmActionRecordUpdateTable(this);
    alarmId = _is.ColumnUuid(
      'alarmId',
      this,
    );
    originalKey = _is.ColumnString(
      'originalKey',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    acknowledgedAt = _is.ColumnDateTime(
      'acknowledgedAt',
      this,
    );
    dismissedAt = _is.ColumnDateTime(
      'dismissedAt',
      this,
    );
    pendingSnoozeAt = _is.ColumnDateTime(
      'pendingSnoozeAt',
      this,
    );
    snoozeRevision = _is.ColumnInt(
      'snoozeRevision',
      this,
      hasDefault: true,
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

  late final CalendarAlarmActionRecordUpdateTable updateTable;

  late final _is.ColumnUuid alarmId;

  late final _is.ColumnString originalKey;

  late final _is.ColumnInt revision;

  late final _is.ColumnDateTime acknowledgedAt;

  late final _is.ColumnDateTime dismissedAt;

  late final _is.ColumnDateTime pendingSnoozeAt;

  late final _is.ColumnInt snoozeRevision;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    alarmId,
    originalKey,
    revision,
    acknowledgedAt,
    dismissedAt,
    pendingSnoozeAt,
    snoozeRevision,
    createdAt,
    updatedAt,
  ];
}

class CalendarAlarmActionRecordInclude extends _is.IncludeObject {
  CalendarAlarmActionRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmActionRecord.t;
}

class CalendarAlarmActionRecordIncludeList extends _is.IncludeList {
  CalendarAlarmActionRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAlarmActionRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmActionRecord.t;
}

class CalendarAlarmActionRecordRepository {
  const CalendarAlarmActionRecordRepository._();

  /// Returns a list of [CalendarAlarmActionRecord]s matching the given query parameters.
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
  Future<List<CalendarAlarmActionRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAlarmActionRecord>(
      where: where?.call(CalendarAlarmActionRecord.t),
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAlarmActionRecord] matching the given query parameters.
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
  Future<CalendarAlarmActionRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAlarmActionRecord>(
      where: where?.call(CalendarAlarmActionRecord.t),
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAlarmActionRecord] by its [id] or null if no such row exists.
  Future<CalendarAlarmActionRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAlarmActionRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAlarmActionRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAlarmActionRecord]s will have their `id` fields set.
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
  Future<List<CalendarAlarmActionRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAlarmActionRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAlarmActionRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAlarmActionRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAlarmActionRecord] will have its `id` field set.
  Future<CalendarAlarmActionRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAlarmActionRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAlarmActionRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAlarmActionRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAlarmActionRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmActionRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAlarmActionRecord> rows, {
    required _is.ColumnSelections<CalendarAlarmActionRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAlarmActionRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAlarmActionRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAlarmActionRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmActionRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAlarmActionRecord] and returns the resulting row.
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
  /// The returned [CalendarAlarmActionRecord] will have its `id` field set.
  Future<CalendarAlarmActionRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAlarmActionRecord row, {
    required _is.ColumnSelections<CalendarAlarmActionRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAlarmActionRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAlarmActionRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAlarmActionRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmActionRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmActionRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmActionRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAlarmActionRecord> rows, {
    _is.ColumnSelections<CalendarAlarmActionRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAlarmActionRecord>(
      rows,
      columns: columns?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAlarmActionRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAlarmActionRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAlarmActionRecord row, {
    _is.ColumnSelections<CalendarAlarmActionRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAlarmActionRecord>(
      row,
      columns: columns?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAlarmActionRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAlarmActionRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarAlarmActionRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAlarmActionRecord>(
      id,
      columnValues: columnValues(CalendarAlarmActionRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmActionRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmActionRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarAlarmActionRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAlarmActionRecord>(
      columnValues: columnValues(CalendarAlarmActionRecord.t.updateTable),
      where: where(CalendarAlarmActionRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAlarmActionRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAlarmActionRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAlarmActionRecord> rows, {
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAlarmActionRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAlarmActionRecord].
  Future<CalendarAlarmActionRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAlarmActionRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAlarmActionRecord>(
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
  Future<List<CalendarAlarmActionRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable> where,
    _is.OrderByBuilder<CalendarAlarmActionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmActionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAlarmActionRecord>(
      where: where(CalendarAlarmActionRecord.t),
      orderBy: orderBy?.call(CalendarAlarmActionRecord.t),
      orderByList: orderByList?.call(CalendarAlarmActionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAlarmActionRecord>(
      where: where?.call(CalendarAlarmActionRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAlarmActionRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmActionRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAlarmActionRecord>(
      where: where(CalendarAlarmActionRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
