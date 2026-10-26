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

abstract class CalendarSchedulingAttemptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingAttemptRecord._({
    this.id,
    required this.deliveryId,
    required this.attemptNumber,
    required this.leaseToken,
    required this.leaseFence,
    required this.startedAt,
    this.finishedAt,
    required this.outcome,
    this.adapterReceipt,
    this.resultCode,
  });

  factory CalendarSchedulingAttemptRecord({
    _is.UuidValue? id,
    required _is.UuidValue deliveryId,
    required int attemptNumber,
    required _is.UuidValue leaseToken,
    required int leaseFence,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String outcome,
    String? adapterReceipt,
    String? resultCode,
  }) = _CalendarSchedulingAttemptRecordImpl;

  factory CalendarSchedulingAttemptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingAttemptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      deliveryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deliveryId'],
      ),
      attemptNumber: jsonSerialization['attemptNumber'] as int,
      leaseToken: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['leaseToken'],
      ),
      leaseFence: jsonSerialization['leaseFence'] as int,
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      outcome: jsonSerialization['outcome'] as String,
      adapterReceipt: jsonSerialization['adapterReceipt'] as String?,
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  static final t = CalendarSchedulingAttemptRecordTable();

  static const db = CalendarSchedulingAttemptRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue deliveryId;

  int attemptNumber;

  _is.UuidValue leaseToken;

  int leaseFence;

  DateTime startedAt;

  DateTime? finishedAt;

  String outcome;

  String? adapterReceipt;

  String? resultCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingAttemptRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? deliveryId,
    int? attemptNumber,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? outcome,
    String? adapterReceipt,
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingAttemptRecord',
      if (id != null) 'id': id?.toJson(),
      'deliveryId': deliveryId.toJson(),
      'attemptNumber': attemptNumber,
      'leaseToken': leaseToken.toJson(),
      'leaseFence': leaseFence,
      'startedAt': startedAt.toJson(),
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      'outcome': outcome,
      if (adapterReceipt != null) 'adapterReceipt': adapterReceipt,
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingAttemptRecordInclude include() {
    return CalendarSchedulingAttemptRecordInclude._();
  }

  static CalendarSchedulingAttemptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    CalendarSchedulingAttemptRecordInclude? include,
  }) {
    return CalendarSchedulingAttemptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingAttemptRecordImpl
    extends CalendarSchedulingAttemptRecord {
  _CalendarSchedulingAttemptRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue deliveryId,
    required int attemptNumber,
    required _is.UuidValue leaseToken,
    required int leaseFence,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String outcome,
    String? adapterReceipt,
    String? resultCode,
  }) : super._(
         id: id,
         deliveryId: deliveryId,
         attemptNumber: attemptNumber,
         leaseToken: leaseToken,
         leaseFence: leaseFence,
         startedAt: startedAt,
         finishedAt: finishedAt,
         outcome: outcome,
         adapterReceipt: adapterReceipt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarSchedulingAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingAttemptRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? deliveryId,
    int? attemptNumber,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? startedAt,
    Object? finishedAt = _Undefined,
    String? outcome,
    Object? adapterReceipt = _Undefined,
    Object? resultCode = _Undefined,
  }) {
    return CalendarSchedulingAttemptRecord(
      id: id is _is.UuidValue? ? id : this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      leaseToken: leaseToken ?? this.leaseToken,
      leaseFence: leaseFence ?? this.leaseFence,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt is DateTime? ? finishedAt : this.finishedAt,
      outcome: outcome ?? this.outcome,
      adapterReceipt: adapterReceipt is String?
          ? adapterReceipt
          : this.adapterReceipt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}

class CalendarSchedulingAttemptRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingAttemptRecordTable> {
  CalendarSchedulingAttemptRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deliveryId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.deliveryId,
    value,
  );

  _is.ColumnValue<int, int> attemptNumber(int value) => _is.ColumnValue(
    table.attemptNumber,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseToken(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<int, int> leaseFence(int value) => _is.ColumnValue(
    table.leaseFence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> startedAt(DateTime value) =>
      _is.ColumnValue(
        table.startedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> finishedAt(DateTime? value) =>
      _is.ColumnValue(
        table.finishedAt,
        value,
      );

  _is.ColumnValue<String, String> outcome(String value) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<String, String> adapterReceipt(String? value) =>
      _is.ColumnValue(
        table.adapterReceipt,
        value,
      );

  _is.ColumnValue<String, String> resultCode(String? value) => _is.ColumnValue(
    table.resultCode,
    value,
  );
}

class CalendarSchedulingAttemptRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingAttemptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_attempt') {
    updateTable = CalendarSchedulingAttemptRecordUpdateTable(this);
    deliveryId = _is.ColumnUuid(
      'deliveryId',
      this,
    );
    attemptNumber = _is.ColumnInt(
      'attemptNumber',
      this,
    );
    leaseToken = _is.ColumnUuid(
      'leaseToken',
      this,
    );
    leaseFence = _is.ColumnInt(
      'leaseFence',
      this,
    );
    startedAt = _is.ColumnDateTime(
      'startedAt',
      this,
    );
    finishedAt = _is.ColumnDateTime(
      'finishedAt',
      this,
    );
    outcome = _is.ColumnString(
      'outcome',
      this,
    );
    adapterReceipt = _is.ColumnString(
      'adapterReceipt',
      this,
    );
    resultCode = _is.ColumnString(
      'resultCode',
      this,
    );
  }

  late final CalendarSchedulingAttemptRecordUpdateTable updateTable;

  late final _is.ColumnUuid deliveryId;

  late final _is.ColumnInt attemptNumber;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime startedAt;

  late final _is.ColumnDateTime finishedAt;

  late final _is.ColumnString outcome;

  late final _is.ColumnString adapterReceipt;

  late final _is.ColumnString resultCode;

  @override
  List<_is.Column> get columns => [
    id,
    deliveryId,
    attemptNumber,
    leaseToken,
    leaseFence,
    startedAt,
    finishedAt,
    outcome,
    adapterReceipt,
    resultCode,
  ];
}

class CalendarSchedulingAttemptRecordInclude extends _is.IncludeObject {
  CalendarSchedulingAttemptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingAttemptRecord.t;
}

class CalendarSchedulingAttemptRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingAttemptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingAttemptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingAttemptRecord.t;
}

class CalendarSchedulingAttemptRecordRepository {
  const CalendarSchedulingAttemptRecordRepository._();

  /// Returns a list of [CalendarSchedulingAttemptRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingAttemptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingAttemptRecord>(
      where: where?.call(CalendarSchedulingAttemptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingAttemptRecord] matching the given query parameters.
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
  Future<CalendarSchedulingAttemptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingAttemptRecord>(
      where: where?.call(CalendarSchedulingAttemptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingAttemptRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingAttemptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingAttemptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingAttemptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingAttemptRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingAttemptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttemptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingAttemptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingAttemptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingAttemptRecord] will have its `id` field set.
  Future<CalendarSchedulingAttemptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingAttemptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingAttemptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingAttemptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttemptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttemptRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingAttemptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingAttemptRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingAttemptRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingAttemptRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingAttemptRecord] will have its `id` field set.
  Future<CalendarSchedulingAttemptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttemptRecord row, {
    required _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingAttemptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingAttemptRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingAttemptRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingAttemptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttemptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttemptRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingAttemptRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingAttemptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingAttemptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttemptRecord row, {
    _is.ColumnSelections<CalendarSchedulingAttemptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingAttemptRecord>(
      row,
      columns: columns?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingAttemptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingAttemptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingAttemptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingAttemptRecord>(
      id,
      columnValues: columnValues(CalendarSchedulingAttemptRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingAttemptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttemptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingAttemptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingAttemptRecord>(
      columnValues: columnValues(CalendarSchedulingAttemptRecord.t.updateTable),
      where: where(CalendarSchedulingAttemptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingAttemptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingAttemptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttemptRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingAttemptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingAttemptRecord].
  Future<CalendarSchedulingAttemptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingAttemptRecord>(
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
  Future<List<CalendarSchedulingAttemptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>
    where,
    _is.OrderByBuilder<CalendarSchedulingAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingAttemptRecord>(
      where: where(CalendarSchedulingAttemptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttemptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingAttemptRecord>(
      where: where?.call(CalendarSchedulingAttemptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingAttemptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingAttemptRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingAttemptRecord>(
      where: where(CalendarSchedulingAttemptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
