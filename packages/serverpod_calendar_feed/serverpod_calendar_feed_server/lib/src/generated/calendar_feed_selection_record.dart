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

abstract class CalendarFeedSelectionRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFeedSelectionRecord._({
    this.id,
    required this.feedId,
    required this.calendarId,
  });

  factory CalendarFeedSelectionRecord({
    _is.UuidValue? id,
    required _is.UuidValue feedId,
    required _is.UuidValue calendarId,
  }) = _CalendarFeedSelectionRecordImpl;

  factory CalendarFeedSelectionRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedSelectionRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      feedId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['feedId']),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
    );
  }

  static final t = CalendarFeedSelectionRecordTable();

  static const db = CalendarFeedSelectionRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue feedId;

  _is.UuidValue calendarId;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFeedSelectionRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedSelectionRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? feedId,
    _is.UuidValue? calendarId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedSelectionRecord',
      if (id != null) 'id': id?.toJson(),
      'feedId': feedId.toJson(),
      'calendarId': calendarId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFeedSelectionRecordInclude include() {
    return CalendarFeedSelectionRecordInclude._();
  }

  static CalendarFeedSelectionRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    CalendarFeedSelectionRecordInclude? include,
  }) {
    return CalendarFeedSelectionRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedSelectionRecordImpl extends CalendarFeedSelectionRecord {
  _CalendarFeedSelectionRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue feedId,
    required _is.UuidValue calendarId,
  }) : super._(
         id: id,
         feedId: feedId,
         calendarId: calendarId,
       );

  /// Returns a shallow copy of this [CalendarFeedSelectionRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedSelectionRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? feedId,
    _is.UuidValue? calendarId,
  }) {
    return CalendarFeedSelectionRecord(
      id: id is _is.UuidValue? ? id : this.id,
      feedId: feedId ?? this.feedId,
      calendarId: calendarId ?? this.calendarId,
    );
  }
}

class CalendarFeedSelectionRecordUpdateTable
    extends _is.UpdateTable<CalendarFeedSelectionRecordTable> {
  CalendarFeedSelectionRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> feedId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.feedId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );
}

class CalendarFeedSelectionRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFeedSelectionRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_feed_selection') {
    updateTable = CalendarFeedSelectionRecordUpdateTable(this);
    feedId = _is.ColumnUuid(
      'feedId',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
  }

  late final CalendarFeedSelectionRecordUpdateTable updateTable;

  late final _is.ColumnUuid feedId;

  late final _is.ColumnUuid calendarId;

  @override
  List<_is.Column> get columns => [
    id,
    feedId,
    calendarId,
  ];
}

class CalendarFeedSelectionRecordInclude extends _is.IncludeObject {
  CalendarFeedSelectionRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedSelectionRecord.t;
}

class CalendarFeedSelectionRecordIncludeList extends _is.IncludeList {
  CalendarFeedSelectionRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFeedSelectionRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedSelectionRecord.t;
}

class CalendarFeedSelectionRecordRepository {
  const CalendarFeedSelectionRecordRepository._();

  /// Returns a list of [CalendarFeedSelectionRecord]s matching the given query parameters.
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
  Future<List<CalendarFeedSelectionRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFeedSelectionRecord>(
      where: where?.call(CalendarFeedSelectionRecord.t),
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarFeedSelectionRecord] matching the given query parameters.
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
  Future<CalendarFeedSelectionRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFeedSelectionRecord>(
      where: where?.call(CalendarFeedSelectionRecord.t),
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFeedSelectionRecord] by its [id] or null if no such row exists.
  Future<CalendarFeedSelectionRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFeedSelectionRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFeedSelectionRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFeedSelectionRecord]s will have their `id` fields set.
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
  Future<List<CalendarFeedSelectionRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFeedSelectionRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFeedSelectionRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFeedSelectionRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFeedSelectionRecord] will have its `id` field set.
  Future<CalendarFeedSelectionRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFeedSelectionRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFeedSelectionRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFeedSelectionRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFeedSelectionRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedSelectionRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFeedSelectionRecord> rows, {
    required _is.ColumnSelections<CalendarFeedSelectionRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedSelectionRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFeedSelectionRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFeedSelectionRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedSelectionRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFeedSelectionRecord] and returns the resulting row.
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
  /// The returned [CalendarFeedSelectionRecord] will have its `id` field set.
  Future<CalendarFeedSelectionRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFeedSelectionRecord row, {
    required _is.ColumnSelections<CalendarFeedSelectionRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedSelectionRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFeedSelectionRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFeedSelectionRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedSelectionRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedSelectionRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedSelectionRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFeedSelectionRecord> rows, {
    _is.ColumnSelections<CalendarFeedSelectionRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFeedSelectionRecord>(
      rows,
      columns: columns?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFeedSelectionRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFeedSelectionRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFeedSelectionRecord row, {
    _is.ColumnSelections<CalendarFeedSelectionRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFeedSelectionRecord>(
      row,
      columns: columns?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFeedSelectionRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFeedSelectionRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarFeedSelectionRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFeedSelectionRecord>(
      id,
      columnValues: columnValues(CalendarFeedSelectionRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedSelectionRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedSelectionRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarFeedSelectionRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFeedSelectionRecord>(
      columnValues: columnValues(CalendarFeedSelectionRecord.t.updateTable),
      where: where(CalendarFeedSelectionRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFeedSelectionRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFeedSelectionRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFeedSelectionRecord> rows, {
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFeedSelectionRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFeedSelectionRecord].
  Future<CalendarFeedSelectionRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFeedSelectionRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFeedSelectionRecord>(
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
  Future<List<CalendarFeedSelectionRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable> where,
    _is.OrderByBuilder<CalendarFeedSelectionRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedSelectionRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFeedSelectionRecord>(
      where: where(CalendarFeedSelectionRecord.t),
      orderBy: orderBy?.call(CalendarFeedSelectionRecord.t),
      orderByList: orderByList?.call(CalendarFeedSelectionRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFeedSelectionRecord>(
      where: where?.call(CalendarFeedSelectionRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFeedSelectionRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedSelectionRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFeedSelectionRecord>(
      where: where(CalendarFeedSelectionRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
