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

abstract class CalendarAvailabilityRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAvailabilityRecord._({
    this.id,
    required this.calendarId,
    required this.revision,
    this.deletedAt,
  });

  factory CalendarAvailabilityRecord({
    _is.UuidValue? id,
    required _is.UuidValue calendarId,
    required int revision,
    DateTime? deletedAt,
  }) = _CalendarAvailabilityRecordImpl;

  factory CalendarAvailabilityRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityRecord(
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

  static final t = CalendarAvailabilityRecordTable();

  static const db = CalendarAvailabilityRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue calendarId;

  int revision;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAvailabilityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? calendarId,
    int? revision,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityRecord',
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

  static CalendarAvailabilityRecordInclude include() {
    return CalendarAvailabilityRecordInclude._();
  }

  static CalendarAvailabilityRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    CalendarAvailabilityRecordInclude? include,
  }) {
    return CalendarAvailabilityRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityRecordImpl extends CalendarAvailabilityRecord {
  _CalendarAvailabilityRecordImpl({
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

  /// Returns a shallow copy of this [CalendarAvailabilityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? calendarId,
    int? revision,
    Object? deletedAt = _Undefined,
  }) {
    return CalendarAvailabilityRecord(
      id: id is _is.UuidValue? ? id : this.id,
      calendarId: calendarId ?? this.calendarId,
      revision: revision ?? this.revision,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CalendarAvailabilityRecordUpdateTable
    extends _is.UpdateTable<CalendarAvailabilityRecordTable> {
  CalendarAvailabilityRecordUpdateTable(super.table);

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

class CalendarAvailabilityRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAvailabilityRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_availability') {
    updateTable = CalendarAvailabilityRecordUpdateTable(this);
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

  late final CalendarAvailabilityRecordUpdateTable updateTable;

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

class CalendarAvailabilityRecordInclude extends _is.IncludeObject {
  CalendarAvailabilityRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAvailabilityRecord.t;
}

class CalendarAvailabilityRecordIncludeList extends _is.IncludeList {
  CalendarAvailabilityRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAvailabilityRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAvailabilityRecord.t;
}

class CalendarAvailabilityRecordRepository {
  const CalendarAvailabilityRecordRepository._();

  /// Returns a list of [CalendarAvailabilityRecord]s matching the given query parameters.
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
  Future<List<CalendarAvailabilityRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAvailabilityRecord>(
      where: where?.call(CalendarAvailabilityRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAvailabilityRecord] matching the given query parameters.
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
  Future<CalendarAvailabilityRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAvailabilityRecord>(
      where: where?.call(CalendarAvailabilityRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAvailabilityRecord] by its [id] or null if no such row exists.
  Future<CalendarAvailabilityRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAvailabilityRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAvailabilityRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAvailabilityRecord]s will have their `id` fields set.
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
  Future<List<CalendarAvailabilityRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAvailabilityRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAvailabilityRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAvailabilityRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAvailabilityRecord] will have its `id` field set.
  Future<CalendarAvailabilityRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAvailabilityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAvailabilityRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAvailabilityRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAvailabilityRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAvailabilityRecord> rows, {
    required _is.ColumnSelections<CalendarAvailabilityRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAvailabilityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAvailabilityRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAvailabilityRecord.t),
      updateColumns: updateColumns?.call(CalendarAvailabilityRecord.t),
      updateWhere: updateWhere?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAvailabilityRecord] and returns the resulting row.
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
  /// The returned [CalendarAvailabilityRecord] will have its `id` field set.
  Future<CalendarAvailabilityRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAvailabilityRecord row, {
    required _is.ColumnSelections<CalendarAvailabilityRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAvailabilityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAvailabilityRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAvailabilityRecord.t),
      updateColumns: updateColumns?.call(CalendarAvailabilityRecord.t),
      updateWhere: updateWhere?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAvailabilityRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAvailabilityRecord> rows, {
    _is.ColumnSelections<CalendarAvailabilityRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAvailabilityRecord>(
      rows,
      columns: columns?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAvailabilityRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAvailabilityRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAvailabilityRecord row, {
    _is.ColumnSelections<CalendarAvailabilityRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAvailabilityRecord>(
      row,
      columns: columns?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAvailabilityRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAvailabilityRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarAvailabilityRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAvailabilityRecord>(
      id,
      columnValues: columnValues(CalendarAvailabilityRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAvailabilityRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarAvailabilityRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAvailabilityRecord>(
      columnValues: columnValues(CalendarAvailabilityRecord.t.updateTable),
      where: where(CalendarAvailabilityRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAvailabilityRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAvailabilityRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAvailabilityRecord> rows, {
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAvailabilityRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAvailabilityRecord].
  Future<CalendarAvailabilityRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAvailabilityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAvailabilityRecord>(
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
  Future<List<CalendarAvailabilityRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable> where,
    _is.OrderByBuilder<CalendarAvailabilityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAvailabilityRecord>(
      where: where(CalendarAvailabilityRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAvailabilityRecord>(
      where: where?.call(CalendarAvailabilityRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAvailabilityRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAvailabilityRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAvailabilityRecord>(
      where: where(CalendarAvailabilityRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
