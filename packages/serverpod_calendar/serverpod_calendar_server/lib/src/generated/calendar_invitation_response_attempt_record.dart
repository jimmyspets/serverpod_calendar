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

abstract class CalendarInvitationResponseAttemptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseAttemptRecord._({
    this.id,
    required this.responseId,
    required this.attemptNumber,
    required this.leaseToken,
    required this.leaseFence,
    required this.startedAt,
    this.finishedAt,
    required this.outcome,
    this.adapterReceipt,
    this.resultCode,
  });

  factory CalendarInvitationResponseAttemptRecord({
    _is.UuidValue? id,
    required _is.UuidValue responseId,
    required int attemptNumber,
    required _is.UuidValue leaseToken,
    required int leaseFence,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String outcome,
    String? adapterReceipt,
    String? resultCode,
  }) = _CalendarInvitationResponseAttemptRecordImpl;

  factory CalendarInvitationResponseAttemptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseAttemptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      responseId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['responseId'],
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

  static final t = CalendarInvitationResponseAttemptRecordTable();

  static const db = CalendarInvitationResponseAttemptRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue responseId;

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

  /// Returns a shallow copy of this [CalendarInvitationResponseAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseAttemptRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? responseId,
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
      '__className__':
          'serverpod_calendar.CalendarInvitationResponseAttemptRecord',
      if (id != null) 'id': id?.toJson(),
      'responseId': responseId.toJson(),
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

  static CalendarInvitationResponseAttemptRecordInclude include() {
    return CalendarInvitationResponseAttemptRecordInclude._();
  }

  static CalendarInvitationResponseAttemptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    CalendarInvitationResponseAttemptRecordInclude? include,
  }) {
    return CalendarInvitationResponseAttemptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationResponseAttemptRecordImpl
    extends CalendarInvitationResponseAttemptRecord {
  _CalendarInvitationResponseAttemptRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue responseId,
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
         responseId: responseId,
         attemptNumber: attemptNumber,
         leaseToken: leaseToken,
         leaseFence: leaseFence,
         startedAt: startedAt,
         finishedAt: finishedAt,
         outcome: outcome,
         adapterReceipt: adapterReceipt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseAttemptRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? responseId,
    int? attemptNumber,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? startedAt,
    Object? finishedAt = _Undefined,
    String? outcome,
    Object? adapterReceipt = _Undefined,
    Object? resultCode = _Undefined,
  }) {
    return CalendarInvitationResponseAttemptRecord(
      id: id is _is.UuidValue? ? id : this.id,
      responseId: responseId ?? this.responseId,
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

class CalendarInvitationResponseAttemptRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationResponseAttemptRecordTable> {
  CalendarInvitationResponseAttemptRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> responseId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.responseId,
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

class CalendarInvitationResponseAttemptRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseAttemptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_response_attempt') {
    updateTable = CalendarInvitationResponseAttemptRecordUpdateTable(this);
    responseId = _is.ColumnUuid(
      'responseId',
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

  late final CalendarInvitationResponseAttemptRecordUpdateTable updateTable;

  late final _is.ColumnUuid responseId;

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
    responseId,
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

class CalendarInvitationResponseAttemptRecordInclude extends _is.IncludeObject {
  CalendarInvitationResponseAttemptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseAttemptRecord.t;
}

class CalendarInvitationResponseAttemptRecordIncludeList
    extends _is.IncludeList {
  CalendarInvitationResponseAttemptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationResponseAttemptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseAttemptRecord.t;
}

class CalendarInvitationResponseAttemptRecordRepository {
  const CalendarInvitationResponseAttemptRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseAttemptRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseAttemptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseAttemptRecord>(
      where: where?.call(CalendarInvitationResponseAttemptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseAttemptRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseAttemptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationResponseAttemptRecord>(
      where: where?.call(CalendarInvitationResponseAttemptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationResponseAttemptRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseAttemptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationResponseAttemptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationResponseAttemptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseAttemptRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseAttemptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseAttemptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationResponseAttemptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationResponseAttemptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseAttemptRecord] will have its `id` field set.
  Future<CalendarInvitationResponseAttemptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationResponseAttemptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationResponseAttemptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseAttemptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseAttemptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseAttemptRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationResponseAttemptRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarInvitationResponseAttemptRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseAttemptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationResponseAttemptRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseAttemptRecord] will have its `id` field set.
  Future<CalendarInvitationResponseAttemptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseAttemptRecord row, {
    required _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationResponseAttemptRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarInvitationResponseAttemptRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseAttemptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseAttemptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseAttemptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseAttemptRecord> rows, {
    _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationResponseAttemptRecord>(
      rows,
      columns: columns?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationResponseAttemptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseAttemptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseAttemptRecord row, {
    _is.ColumnSelections<CalendarInvitationResponseAttemptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationResponseAttemptRecord>(
      row,
      columns: columns?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationResponseAttemptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseAttemptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseAttemptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationResponseAttemptRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationResponseAttemptRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseAttemptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseAttemptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseAttemptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseAttemptRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationResponseAttemptRecord>(
      columnValues: columnValues(
        CalendarInvitationResponseAttemptRecord.t.updateTable,
      ),
      where: where(CalendarInvitationResponseAttemptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationResponseAttemptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseAttemptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseAttemptRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationResponseAttemptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationResponseAttemptRecord].
  Future<CalendarInvitationResponseAttemptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationResponseAttemptRecord>(
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
  Future<List<CalendarInvitationResponseAttemptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseAttemptRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationResponseAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationResponseAttemptRecord>(
      where: where(CalendarInvitationResponseAttemptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseAttemptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseAttemptRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseAttemptRecord>(
      where: where?.call(CalendarInvitationResponseAttemptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseAttemptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseAttemptRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationResponseAttemptRecord>(
      where: where(CalendarInvitationResponseAttemptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
