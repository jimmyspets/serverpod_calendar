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

abstract class NotificationScopeRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  NotificationScopeRecord._({
    this.id,
    required this.scopeKey,
  });

  factory NotificationScopeRecord({
    _is.UuidValue? id,
    required String scopeKey,
  }) = _NotificationScopeRecordImpl;

  factory NotificationScopeRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NotificationScopeRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
    );
  }

  static final t = NotificationScopeRecordTable();

  static const db = NotificationScopeRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [NotificationScopeRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationScopeRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationScopeRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NotificationScopeRecordInclude include() {
    return NotificationScopeRecordInclude._();
  }

  static NotificationScopeRecordIncludeList includeList({
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    NotificationScopeRecordInclude? include,
  }) {
    return NotificationScopeRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationScopeRecordImpl extends NotificationScopeRecord {
  _NotificationScopeRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
       );

  /// Returns a shallow copy of this [NotificationScopeRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationScopeRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
  }) {
    return NotificationScopeRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
    );
  }
}

class NotificationScopeRecordUpdateTable
    extends _is.UpdateTable<NotificationScopeRecordTable> {
  NotificationScopeRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );
}

class NotificationScopeRecordTable extends _is.Table<_is.UuidValue?> {
  NotificationScopeRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_notifications_scope') {
    updateTable = NotificationScopeRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
  }

  late final NotificationScopeRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
  ];
}

class NotificationScopeRecordInclude extends _is.IncludeObject {
  NotificationScopeRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => NotificationScopeRecord.t;
}

class NotificationScopeRecordIncludeList extends _is.IncludeList {
  NotificationScopeRecordIncludeList._({
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NotificationScopeRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => NotificationScopeRecord.t;
}

class NotificationScopeRecordRepository {
  const NotificationScopeRecordRepository._();

  /// Returns a list of [NotificationScopeRecord]s matching the given query parameters.
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
  Future<List<NotificationScopeRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NotificationScopeRecord>(
      where: where?.call(NotificationScopeRecord.t),
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NotificationScopeRecord] matching the given query parameters.
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
  Future<NotificationScopeRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NotificationScopeRecord>(
      where: where?.call(NotificationScopeRecord.t),
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NotificationScopeRecord] by its [id] or null if no such row exists.
  Future<NotificationScopeRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NotificationScopeRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NotificationScopeRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [NotificationScopeRecord]s will have their `id` fields set.
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
  Future<List<NotificationScopeRecord>> insert(
    _is.DatabaseSession session,
    List<NotificationScopeRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NotificationScopeRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NotificationScopeRecord] and returns the inserted row.
  ///
  /// The returned [NotificationScopeRecord] will have its `id` field set.
  Future<NotificationScopeRecord> insertRow(
    _is.DatabaseSession session,
    NotificationScopeRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NotificationScopeRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NotificationScopeRecord]s in the list and returns the resulting rows.
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
  /// The returned [NotificationScopeRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationScopeRecord>> upsert(
    _is.DatabaseSession session,
    List<NotificationScopeRecord> rows, {
    required _is.ColumnSelections<NotificationScopeRecordTable> conflictColumns,
    _is.ColumnSelections<NotificationScopeRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NotificationScopeRecord>(
      rows,
      conflictColumns: conflictColumns(NotificationScopeRecord.t),
      updateColumns: updateColumns?.call(NotificationScopeRecord.t),
      updateWhere: updateWhere?.call(NotificationScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NotificationScopeRecord] and returns the resulting row.
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
  /// The returned [NotificationScopeRecord] will have its `id` field set.
  Future<NotificationScopeRecord?> upsertRow(
    _is.DatabaseSession session,
    NotificationScopeRecord row, {
    required _is.ColumnSelections<NotificationScopeRecordTable> conflictColumns,
    _is.ColumnSelections<NotificationScopeRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NotificationScopeRecord>(
      row,
      conflictColumns: conflictColumns(NotificationScopeRecord.t),
      updateColumns: updateColumns?.call(NotificationScopeRecord.t),
      updateWhere: updateWhere?.call(NotificationScopeRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationScopeRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationScopeRecord>> update(
    _is.DatabaseSession session,
    List<NotificationScopeRecord> rows, {
    _is.ColumnSelections<NotificationScopeRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NotificationScopeRecord>(
      rows,
      columns: columns?.call(NotificationScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NotificationScopeRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NotificationScopeRecord> updateRow(
    _is.DatabaseSession session,
    NotificationScopeRecord row, {
    _is.ColumnSelections<NotificationScopeRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NotificationScopeRecord>(
      row,
      columns: columns?.call(NotificationScopeRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NotificationScopeRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NotificationScopeRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<NotificationScopeRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NotificationScopeRecord>(
      id,
      columnValues: columnValues(NotificationScopeRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationScopeRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationScopeRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NotificationScopeRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<NotificationScopeRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NotificationScopeRecord>(
      columnValues: columnValues(NotificationScopeRecord.t.updateTable),
      where: where(NotificationScopeRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NotificationScopeRecord]s in the list and returns the deleted rows.
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
  Future<List<NotificationScopeRecord>> delete(
    _is.DatabaseSession session,
    List<NotificationScopeRecord> rows, {
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NotificationScopeRecord>(
      rows,
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NotificationScopeRecord].
  Future<NotificationScopeRecord> deleteRow(
    _is.DatabaseSession session,
    NotificationScopeRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NotificationScopeRecord>(
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
  Future<List<NotificationScopeRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationScopeRecordTable> where,
    _is.OrderByBuilder<NotificationScopeRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationScopeRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NotificationScopeRecord>(
      where: where(NotificationScopeRecord.t),
      orderBy: orderBy?.call(NotificationScopeRecord.t),
      orderByList: orderByList?.call(NotificationScopeRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationScopeRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NotificationScopeRecord>(
      where: where?.call(NotificationScopeRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NotificationScopeRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationScopeRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NotificationScopeRecord>(
      where: where(NotificationScopeRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
