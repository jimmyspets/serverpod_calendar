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

abstract class NotificationCursorRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  NotificationCursorRecord._({
    this.id,
    required this.token,
    required this.scopeKey,
    required this.principalId,
    required this.policyRevision,
    required this.recipientNamespace,
    required this.recipientKey,
    required this.afterId,
    required this.pageSize,
    required this.expiresAt,
  });

  factory NotificationCursorRecord({
    int? id,
    required String token,
    required String scopeKey,
    required String principalId,
    required String policyRevision,
    required String recipientNamespace,
    required String recipientKey,
    required _is.UuidValue afterId,
    required int pageSize,
    required DateTime expiresAt,
  }) = _NotificationCursorRecordImpl;

  factory NotificationCursorRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NotificationCursorRecord(
      id: jsonSerialization['id'] as int?,
      token: jsonSerialization['token'] as String,
      scopeKey: jsonSerialization['scopeKey'] as String,
      principalId: jsonSerialization['principalId'] as String,
      policyRevision: jsonSerialization['policyRevision'] as String,
      recipientNamespace: jsonSerialization['recipientNamespace'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      afterId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['afterId'],
      ),
      pageSize: jsonSerialization['pageSize'] as int,
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = NotificationCursorRecordTable();

  static const db = NotificationCursorRecordRepository._();

  @override
  int? id;

  String token;

  String scopeKey;

  String principalId;

  String policyRevision;

  String recipientNamespace;

  String recipientKey;

  _is.UuidValue afterId;

  int pageSize;

  DateTime expiresAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [NotificationCursorRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationCursorRecord copyWith({
    int? id,
    String? token,
    String? scopeKey,
    String? principalId,
    String? policyRevision,
    String? recipientNamespace,
    String? recipientKey,
    _is.UuidValue? afterId,
    int? pageSize,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationCursorRecord',
      if (id != null) 'id': id,
      'token': token,
      'scopeKey': scopeKey,
      'principalId': principalId,
      'policyRevision': policyRevision,
      'recipientNamespace': recipientNamespace,
      'recipientKey': recipientKey,
      'afterId': afterId.toJson(),
      'pageSize': pageSize,
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NotificationCursorRecordInclude include() {
    return NotificationCursorRecordInclude._();
  }

  static NotificationCursorRecordIncludeList includeList({
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    NotificationCursorRecordInclude? include,
  }) {
    return NotificationCursorRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationCursorRecordImpl extends NotificationCursorRecord {
  _NotificationCursorRecordImpl({
    int? id,
    required String token,
    required String scopeKey,
    required String principalId,
    required String policyRevision,
    required String recipientNamespace,
    required String recipientKey,
    required _is.UuidValue afterId,
    required int pageSize,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         token: token,
         scopeKey: scopeKey,
         principalId: principalId,
         policyRevision: policyRevision,
         recipientNamespace: recipientNamespace,
         recipientKey: recipientKey,
         afterId: afterId,
         pageSize: pageSize,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [NotificationCursorRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationCursorRecord copyWith({
    Object? id = _Undefined,
    String? token,
    String? scopeKey,
    String? principalId,
    String? policyRevision,
    String? recipientNamespace,
    String? recipientKey,
    _is.UuidValue? afterId,
    int? pageSize,
    DateTime? expiresAt,
  }) {
    return NotificationCursorRecord(
      id: id is int? ? id : this.id,
      token: token ?? this.token,
      scopeKey: scopeKey ?? this.scopeKey,
      principalId: principalId ?? this.principalId,
      policyRevision: policyRevision ?? this.policyRevision,
      recipientNamespace: recipientNamespace ?? this.recipientNamespace,
      recipientKey: recipientKey ?? this.recipientKey,
      afterId: afterId ?? this.afterId,
      pageSize: pageSize ?? this.pageSize,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class NotificationCursorRecordUpdateTable
    extends _is.UpdateTable<NotificationCursorRecordTable> {
  NotificationCursorRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> token(String value) => _is.ColumnValue(
    table.token,
    value,
  );

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> principalId(String value) => _is.ColumnValue(
    table.principalId,
    value,
  );

  _is.ColumnValue<String, String> policyRevision(String value) =>
      _is.ColumnValue(
        table.policyRevision,
        value,
      );

  _is.ColumnValue<String, String> recipientNamespace(String value) =>
      _is.ColumnValue(
        table.recipientNamespace,
        value,
      );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> afterId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.afterId,
        value,
      );

  _is.ColumnValue<int, int> pageSize(int value) => _is.ColumnValue(
    table.pageSize,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class NotificationCursorRecordTable extends _is.Table<int?> {
  NotificationCursorRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_notifications_cursor') {
    updateTable = NotificationCursorRecordUpdateTable(this);
    token = _is.ColumnString(
      'token',
      this,
    );
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    principalId = _is.ColumnString(
      'principalId',
      this,
    );
    policyRevision = _is.ColumnString(
      'policyRevision',
      this,
    );
    recipientNamespace = _is.ColumnString(
      'recipientNamespace',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    afterId = _is.ColumnUuid(
      'afterId',
      this,
    );
    pageSize = _is.ColumnInt(
      'pageSize',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final NotificationCursorRecordUpdateTable updateTable;

  late final _is.ColumnString token;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString principalId;

  late final _is.ColumnString policyRevision;

  late final _is.ColumnString recipientNamespace;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid afterId;

  late final _is.ColumnInt pageSize;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    token,
    scopeKey,
    principalId,
    policyRevision,
    recipientNamespace,
    recipientKey,
    afterId,
    pageSize,
    expiresAt,
  ];
}

class NotificationCursorRecordInclude extends _is.IncludeObject {
  NotificationCursorRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => NotificationCursorRecord.t;
}

class NotificationCursorRecordIncludeList extends _is.IncludeList {
  NotificationCursorRecordIncludeList._({
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NotificationCursorRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => NotificationCursorRecord.t;
}

class NotificationCursorRecordRepository {
  const NotificationCursorRecordRepository._();

  /// Returns a list of [NotificationCursorRecord]s matching the given query parameters.
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
  Future<List<NotificationCursorRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NotificationCursorRecord>(
      where: where?.call(NotificationCursorRecord.t),
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NotificationCursorRecord] matching the given query parameters.
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
  Future<NotificationCursorRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NotificationCursorRecord>(
      where: where?.call(NotificationCursorRecord.t),
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NotificationCursorRecord] by its [id] or null if no such row exists.
  Future<NotificationCursorRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NotificationCursorRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NotificationCursorRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [NotificationCursorRecord]s will have their `id` fields set.
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
  Future<List<NotificationCursorRecord>> insert(
    _is.DatabaseSession session,
    List<NotificationCursorRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NotificationCursorRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NotificationCursorRecord] and returns the inserted row.
  ///
  /// The returned [NotificationCursorRecord] will have its `id` field set.
  Future<NotificationCursorRecord> insertRow(
    _is.DatabaseSession session,
    NotificationCursorRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NotificationCursorRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NotificationCursorRecord]s in the list and returns the resulting rows.
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
  /// The returned [NotificationCursorRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationCursorRecord>> upsert(
    _is.DatabaseSession session,
    List<NotificationCursorRecord> rows, {
    required _is.ColumnSelections<NotificationCursorRecordTable>
    conflictColumns,
    _is.ColumnSelections<NotificationCursorRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NotificationCursorRecord>(
      rows,
      conflictColumns: conflictColumns(NotificationCursorRecord.t),
      updateColumns: updateColumns?.call(NotificationCursorRecord.t),
      updateWhere: updateWhere?.call(NotificationCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NotificationCursorRecord] and returns the resulting row.
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
  /// The returned [NotificationCursorRecord] will have its `id` field set.
  Future<NotificationCursorRecord?> upsertRow(
    _is.DatabaseSession session,
    NotificationCursorRecord row, {
    required _is.ColumnSelections<NotificationCursorRecordTable>
    conflictColumns,
    _is.ColumnSelections<NotificationCursorRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NotificationCursorRecord>(
      row,
      conflictColumns: conflictColumns(NotificationCursorRecord.t),
      updateColumns: updateColumns?.call(NotificationCursorRecord.t),
      updateWhere: updateWhere?.call(NotificationCursorRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationCursorRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationCursorRecord>> update(
    _is.DatabaseSession session,
    List<NotificationCursorRecord> rows, {
    _is.ColumnSelections<NotificationCursorRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NotificationCursorRecord>(
      rows,
      columns: columns?.call(NotificationCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NotificationCursorRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NotificationCursorRecord> updateRow(
    _is.DatabaseSession session,
    NotificationCursorRecord row, {
    _is.ColumnSelections<NotificationCursorRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NotificationCursorRecord>(
      row,
      columns: columns?.call(NotificationCursorRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NotificationCursorRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NotificationCursorRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<NotificationCursorRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NotificationCursorRecord>(
      id,
      columnValues: columnValues(NotificationCursorRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationCursorRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationCursorRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NotificationCursorRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<NotificationCursorRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NotificationCursorRecord>(
      columnValues: columnValues(NotificationCursorRecord.t.updateTable),
      where: where(NotificationCursorRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NotificationCursorRecord]s in the list and returns the deleted rows.
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
  Future<List<NotificationCursorRecord>> delete(
    _is.DatabaseSession session,
    List<NotificationCursorRecord> rows, {
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NotificationCursorRecord>(
      rows,
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NotificationCursorRecord].
  Future<NotificationCursorRecord> deleteRow(
    _is.DatabaseSession session,
    NotificationCursorRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NotificationCursorRecord>(
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
  Future<List<NotificationCursorRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationCursorRecordTable> where,
    _is.OrderByBuilder<NotificationCursorRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationCursorRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NotificationCursorRecord>(
      where: where(NotificationCursorRecord.t),
      orderBy: orderBy?.call(NotificationCursorRecord.t),
      orderByList: orderByList?.call(NotificationCursorRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationCursorRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NotificationCursorRecord>(
      where: where?.call(NotificationCursorRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NotificationCursorRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationCursorRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NotificationCursorRecord>(
      where: where(NotificationCursorRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
