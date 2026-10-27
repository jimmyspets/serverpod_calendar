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
import 'calendar_scheduling_reply_outcome.dart' as _ikqvfn4d;

abstract class CalendarSchedulingReplyReceiptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingReplyReceiptRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.sourceId,
    required this.ingressDigest,
    required this.outcome,
    required this.receivedAt,
  });

  factory CalendarSchedulingReplyReceiptRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required _is.UuidValue sourceId,
    required String ingressDigest,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required DateTime receivedAt,
  }) = _CalendarSchedulingReplyReceiptRecordImpl;

  factory CalendarSchedulingReplyReceiptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReplyReceiptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      ingressDigest: jsonSerialization['ingressDigest'] as String,
      outcome: _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  static final t = CalendarSchedulingReplyReceiptRecordTable();

  static const db = CalendarSchedulingReplyReceiptRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  _is.UuidValue sourceId;

  String ingressDigest;

  _ikqvfn4d.CalendarSchedulingReplyOutcome outcome;

  DateTime receivedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingReplyReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReplyReceiptRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? meetingId,
    _is.UuidValue? sourceId,
    String? ingressDigest,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingReplyReceiptRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'sourceId': sourceId.toJson(),
      'ingressDigest': ingressDigest,
      'outcome': outcome.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingReplyReceiptRecordInclude include() {
    return CalendarSchedulingReplyReceiptRecordInclude._();
  }

  static CalendarSchedulingReplyReceiptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    CalendarSchedulingReplyReceiptRecordInclude? include,
  }) {
    return CalendarSchedulingReplyReceiptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingReplyReceiptRecordImpl
    extends CalendarSchedulingReplyReceiptRecord {
  _CalendarSchedulingReplyReceiptRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required _is.UuidValue sourceId,
    required String ingressDigest,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         sourceId: sourceId,
         ingressDigest: ingressDigest,
         outcome: outcome,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReplyReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReplyReceiptRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? meetingId,
    _is.UuidValue? sourceId,
    String? ingressDigest,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    DateTime? receivedAt,
  }) {
    return CalendarSchedulingReplyReceiptRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      sourceId: sourceId ?? this.sourceId,
      ingressDigest: ingressDigest ?? this.ingressDigest,
      outcome: outcome ?? this.outcome,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class CalendarSchedulingReplyReceiptRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingReplyReceiptRecordTable> {
  CalendarSchedulingReplyReceiptRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> meetingId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.meetingId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<String, String> ingressDigest(String value) =>
      _is.ColumnValue(
        table.ingressDigest,
        value,
      );

  _is.ColumnValue<
    _ikqvfn4d.CalendarSchedulingReplyOutcome,
    _ikqvfn4d.CalendarSchedulingReplyOutcome
  >
  outcome(_ikqvfn4d.CalendarSchedulingReplyOutcome value) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class CalendarSchedulingReplyReceiptRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingReplyReceiptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_reply_receipt') {
    updateTable = CalendarSchedulingReplyReceiptRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    meetingId = _is.ColumnUuid(
      'meetingId',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    ingressDigest = _is.ColumnString(
      'ingressDigest',
      this,
    );
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
  }

  late final CalendarSchedulingReplyReceiptRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnString ingressDigest;

  late final _is.ColumnEnum<_ikqvfn4d.CalendarSchedulingReplyOutcome> outcome;

  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    sourceId,
    ingressDigest,
    outcome,
    receivedAt,
  ];
}

class CalendarSchedulingReplyReceiptRecordInclude extends _is.IncludeObject {
  CalendarSchedulingReplyReceiptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingReplyReceiptRecord.t;
}

class CalendarSchedulingReplyReceiptRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingReplyReceiptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingReplyReceiptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingReplyReceiptRecord.t;
}

class CalendarSchedulingReplyReceiptRecordRepository {
  const CalendarSchedulingReplyReceiptRecordRepository._();

  /// Returns a list of [CalendarSchedulingReplyReceiptRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingReplyReceiptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingReplyReceiptRecord>(
      where: where?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingReplyReceiptRecord] matching the given query parameters.
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
  Future<CalendarSchedulingReplyReceiptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingReplyReceiptRecord>(
      where: where?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingReplyReceiptRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingReplyReceiptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingReplyReceiptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingReplyReceiptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingReplyReceiptRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingReplyReceiptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplyReceiptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingReplyReceiptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingReplyReceiptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingReplyReceiptRecord] will have its `id` field set.
  Future<CalendarSchedulingReplyReceiptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplyReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingReplyReceiptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingReplyReceiptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingReplyReceiptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplyReceiptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplyReceiptRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingReplyReceiptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingReplyReceiptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarSchedulingReplyReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingReplyReceiptRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingReplyReceiptRecord] will have its `id` field set.
  Future<CalendarSchedulingReplyReceiptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplyReceiptRecord row, {
    required _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingReplyReceiptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingReplyReceiptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarSchedulingReplyReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingReplyReceiptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplyReceiptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplyReceiptRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingReplyReceiptRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingReplyReceiptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingReplyReceiptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplyReceiptRecord row, {
    _is.ColumnSelections<CalendarSchedulingReplyReceiptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingReplyReceiptRecord>(
      row,
      columns: columns?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingReplyReceiptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingReplyReceiptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingReplyReceiptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingReplyReceiptRecord>(
      id,
      columnValues: columnValues(
        CalendarSchedulingReplyReceiptRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingReplyReceiptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplyReceiptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingReplyReceiptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplyReceiptRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingReplyReceiptRecord>(
      columnValues: columnValues(
        CalendarSchedulingReplyReceiptRecord.t.updateTable,
      ),
      where: where(CalendarSchedulingReplyReceiptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingReplyReceiptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingReplyReceiptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplyReceiptRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingReplyReceiptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingReplyReceiptRecord].
  Future<CalendarSchedulingReplyReceiptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplyReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingReplyReceiptRecord>(
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
  Future<List<CalendarSchedulingReplyReceiptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplyReceiptRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarSchedulingReplyReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingReplyReceiptRecord>(
      where: where(CalendarSchedulingReplyReceiptRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplyReceiptRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplyReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplyReceiptRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingReplyReceiptRecord>(
      where: where?.call(CalendarSchedulingReplyReceiptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingReplyReceiptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplyReceiptRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingReplyReceiptRecord>(
      where: where(CalendarSchedulingReplyReceiptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
