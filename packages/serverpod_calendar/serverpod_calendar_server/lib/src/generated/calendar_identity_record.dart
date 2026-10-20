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

abstract class CalendarIdentityRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarIdentityRecord._({
    this.id,
    required this.scopeKey,
    required this.revision,
    this.deletedAt,
  });

  factory CalendarIdentityRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required int revision,
    DateTime? deletedAt,
  }) = _CalendarIdentityRecordImpl;

  factory CalendarIdentityRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIdentityRecord(
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

  static final t = CalendarIdentityRecordTable();

  static const db = CalendarIdentityRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  int revision;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarIdentityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIdentityRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    int? revision,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIdentityRecord',
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

  static CalendarIdentityRecordInclude include() {
    return CalendarIdentityRecordInclude._();
  }

  static CalendarIdentityRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    CalendarIdentityRecordInclude? include,
  }) {
    return CalendarIdentityRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIdentityRecordImpl extends CalendarIdentityRecord {
  _CalendarIdentityRecordImpl({
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

  /// Returns a shallow copy of this [CalendarIdentityRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIdentityRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    int? revision,
    Object? deletedAt = _Undefined,
  }) {
    return CalendarIdentityRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      revision: revision ?? this.revision,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CalendarIdentityRecordUpdateTable
    extends _is.UpdateTable<CalendarIdentityRecordTable> {
  CalendarIdentityRecordUpdateTable(super.table);

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

class CalendarIdentityRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarIdentityRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_identity') {
    updateTable = CalendarIdentityRecordUpdateTable(this);
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

  late final CalendarIdentityRecordUpdateTable updateTable;

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

class CalendarIdentityRecordInclude extends _is.IncludeObject {
  CalendarIdentityRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarIdentityRecord.t;
}

class CalendarIdentityRecordIncludeList extends _is.IncludeList {
  CalendarIdentityRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarIdentityRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarIdentityRecord.t;
}

class CalendarIdentityRecordRepository {
  const CalendarIdentityRecordRepository._();

  /// Returns a list of [CalendarIdentityRecord]s matching the given query parameters.
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
  Future<List<CalendarIdentityRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarIdentityRecord>(
      where: where?.call(CalendarIdentityRecord.t),
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarIdentityRecord] matching the given query parameters.
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
  Future<CalendarIdentityRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarIdentityRecord>(
      where: where?.call(CalendarIdentityRecord.t),
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarIdentityRecord] by its [id] or null if no such row exists.
  Future<CalendarIdentityRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarIdentityRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarIdentityRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarIdentityRecord]s will have their `id` fields set.
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
  Future<List<CalendarIdentityRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarIdentityRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarIdentityRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarIdentityRecord] and returns the inserted row.
  ///
  /// The returned [CalendarIdentityRecord] will have its `id` field set.
  Future<CalendarIdentityRecord> insertRow(
    _is.DatabaseSession session,
    CalendarIdentityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarIdentityRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarIdentityRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarIdentityRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIdentityRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarIdentityRecord> rows, {
    required _is.ColumnSelections<CalendarIdentityRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarIdentityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarIdentityRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarIdentityRecord.t),
      updateColumns: updateColumns?.call(CalendarIdentityRecord.t),
      updateWhere: updateWhere?.call(CalendarIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarIdentityRecord] and returns the resulting row.
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
  /// The returned [CalendarIdentityRecord] will have its `id` field set.
  Future<CalendarIdentityRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarIdentityRecord row, {
    required _is.ColumnSelections<CalendarIdentityRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarIdentityRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarIdentityRecord>(
      row,
      conflictColumns: conflictColumns(CalendarIdentityRecord.t),
      updateColumns: updateColumns?.call(CalendarIdentityRecord.t),
      updateWhere: updateWhere?.call(CalendarIdentityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIdentityRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIdentityRecord>> update(
    _is.DatabaseSession session,
    List<CalendarIdentityRecord> rows, {
    _is.ColumnSelections<CalendarIdentityRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarIdentityRecord>(
      rows,
      columns: columns?.call(CalendarIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarIdentityRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarIdentityRecord> updateRow(
    _is.DatabaseSession session,
    CalendarIdentityRecord row, {
    _is.ColumnSelections<CalendarIdentityRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarIdentityRecord>(
      row,
      columns: columns?.call(CalendarIdentityRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarIdentityRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarIdentityRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarIdentityRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarIdentityRecord>(
      id,
      columnValues: columnValues(CalendarIdentityRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIdentityRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIdentityRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarIdentityRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarIdentityRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarIdentityRecord>(
      columnValues: columnValues(CalendarIdentityRecord.t.updateTable),
      where: where(CalendarIdentityRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarIdentityRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarIdentityRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarIdentityRecord> rows, {
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarIdentityRecord>(
      rows,
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarIdentityRecord].
  Future<CalendarIdentityRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarIdentityRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarIdentityRecord>(
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
  Future<List<CalendarIdentityRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarIdentityRecordTable> where,
    _is.OrderByBuilder<CalendarIdentityRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIdentityRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarIdentityRecord>(
      where: where(CalendarIdentityRecord.t),
      orderBy: orderBy?.call(CalendarIdentityRecord.t),
      orderByList: orderByList?.call(CalendarIdentityRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIdentityRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarIdentityRecord>(
      where: where?.call(CalendarIdentityRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarIdentityRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarIdentityRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarIdentityRecord>(
      where: where(CalendarIdentityRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
