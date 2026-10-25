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

abstract class CalendarFeedIdentityRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFeedIdentityRecord._({
    this.id,
    required this.scopeKey,
    required this.revision,
    this.deletedAt,
  });

  factory CalendarFeedIdentityRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required int revision,
    DateTime? deletedAt,
  }) = _CalendarFeedIdentityRecordImpl;

  factory CalendarFeedIdentityRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedIdentityRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      revision: jsonSerialization['revision'] as int,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = CalendarFeedIdentityRecordTable();

  static const db = CalendarFeedIdentityRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  int revision;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFeedIdentityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedIdentityRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    int? revision,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedIdentityRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'revision': revision,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFeedIdentityRecordInclude include() {
    return CalendarFeedIdentityRecordInclude._();
  }

  static CalendarFeedIdentityRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    CalendarFeedIdentityRecordInclude? include,
  }) {
    return CalendarFeedIdentityRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedIdentityRecordImpl extends CalendarFeedIdentityRecord {
  _CalendarFeedIdentityRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required int revision,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         revision: revision,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [CalendarFeedIdentityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedIdentityRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    int? revision,
    Object? deletedAt = _Undefined,
  }) {
    return CalendarFeedIdentityRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      revision: revision ?? this.revision,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CalendarFeedIdentityRecordUpdateTable
    extends _is.UpdateTable<CalendarFeedIdentityRecordTable> {
  CalendarFeedIdentityRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
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

class CalendarFeedIdentityRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFeedIdentityRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_feed_identity') {
    updateTable = CalendarFeedIdentityRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
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

  late final CalendarFeedIdentityRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnInt revision;

  late final _is.ColumnDateTime deletedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    revision,
    deletedAt,
  ];
}

class CalendarFeedIdentityRecordInclude extends _is.IncludeObject {
  CalendarFeedIdentityRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedIdentityRecord.t;
}

class CalendarFeedIdentityRecordIncludeList extends _is.IncludeList {
  CalendarFeedIdentityRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFeedIdentityRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedIdentityRecord.t;
}

class CalendarFeedIdentityRecordRepository {
  const CalendarFeedIdentityRecordRepository._();

  /// Returns a list of [CalendarFeedIdentityRecord]s matching the given query parameters.
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
  Future<List<CalendarFeedIdentityRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFeedIdentityRecord>(
      where: where?.call(CalendarFeedIdentityRecord.t),
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarFeedIdentityRecord] matching the given query parameters.
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
  Future<CalendarFeedIdentityRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFeedIdentityRecord>(
      where: where?.call(CalendarFeedIdentityRecord.t),
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFeedIdentityRecord] by its [id] or null if no such row exists.
  Future<CalendarFeedIdentityRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFeedIdentityRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFeedIdentityRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFeedIdentityRecord]s will have their `id` fields set.
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
  Future<List<CalendarFeedIdentityRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFeedIdentityRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFeedIdentityRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFeedIdentityRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFeedIdentityRecord] will have its `id` field set.
  Future<CalendarFeedIdentityRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFeedIdentityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFeedIdentityRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFeedIdentityRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFeedIdentityRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedIdentityRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFeedIdentityRecord> rows, {
    required _is.ColumnSelections<CalendarFeedIdentityRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedIdentityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFeedIdentityRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFeedIdentityRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedIdentityRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFeedIdentityRecord] and returns the resulting row.
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
  /// The returned [CalendarFeedIdentityRecord] will have its `id` field set.
  Future<CalendarFeedIdentityRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFeedIdentityRecord row, {
    required _is.ColumnSelections<CalendarFeedIdentityRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedIdentityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFeedIdentityRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFeedIdentityRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedIdentityRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedIdentityRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedIdentityRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFeedIdentityRecord> rows, {
    _is.ColumnSelections<CalendarFeedIdentityRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFeedIdentityRecord>(
      rows,
      columns: columns?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFeedIdentityRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFeedIdentityRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFeedIdentityRecord row, {
    _is.ColumnSelections<CalendarFeedIdentityRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFeedIdentityRecord>(
      row,
      columns: columns?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFeedIdentityRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFeedIdentityRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarFeedIdentityRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFeedIdentityRecord>(
      id,
      columnValues: columnValues(CalendarFeedIdentityRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedIdentityRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedIdentityRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarFeedIdentityRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFeedIdentityRecord>(
      columnValues: columnValues(CalendarFeedIdentityRecord.t.updateTable),
      where: where(CalendarFeedIdentityRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFeedIdentityRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFeedIdentityRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFeedIdentityRecord> rows, {
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFeedIdentityRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFeedIdentityRecord].
  Future<CalendarFeedIdentityRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFeedIdentityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFeedIdentityRecord>(
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
  Future<List<CalendarFeedIdentityRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable> where,
    _is.OrderByBuilder<CalendarFeedIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFeedIdentityRecord>(
      where: where(CalendarFeedIdentityRecord.t),
      orderBy: orderBy?.call(CalendarFeedIdentityRecord.t),
      orderByList: orderByList?.call(CalendarFeedIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFeedIdentityRecord>(
      where: where?.call(CalendarFeedIdentityRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFeedIdentityRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedIdentityRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFeedIdentityRecord>(
      where: where(CalendarFeedIdentityRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
