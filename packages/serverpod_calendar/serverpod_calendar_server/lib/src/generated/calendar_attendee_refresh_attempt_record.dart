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
import 'dart:async' as _ida;

import 'package:serverpod/serverpod.dart' as _is;

abstract class CalendarAttendeeRefreshAttemptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAttendeeRefreshAttemptRecord._({
    this.id,
    required this.deliveryId,
    required this.attemptNumber,
    required this.leaseToken,
    required this.startedAt,
    this.finishedAt,
    required this.outcome,
  });

  factory CalendarAttendeeRefreshAttemptRecord({
    _is.UuidValue? id,
    required _is.UuidValue deliveryId,
    required int attemptNumber,
    required _is.UuidValue leaseToken,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String outcome,
  }) = _CalendarAttendeeRefreshAttemptRecordImpl;

  factory CalendarAttendeeRefreshAttemptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAttendeeRefreshAttemptRecord(
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
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      outcome: jsonSerialization['outcome'] as String,
    );
  }

  static final t = CalendarAttendeeRefreshAttemptRecordTable();

  static const db = CalendarAttendeeRefreshAttemptRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue deliveryId;

  int attemptNumber;

  _is.UuidValue leaseToken;

  DateTime startedAt;

  DateTime? finishedAt;

  String outcome;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAttendeeRefreshAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAttendeeRefreshAttemptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? deliveryId,
    int? attemptNumber,
    _is.UuidValue? leaseToken,
    DateTime? startedAt,
    DateTime? finishedAt = const _is.$UndefinedDateTime(),
    String? outcome,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarAttendeeRefreshAttemptRecord',
      if (id != null) 'id': id?.toJson(),
      'deliveryId': deliveryId.toJson(),
      'attemptNumber': attemptNumber,
      'leaseToken': leaseToken.toJson(),
      'startedAt': startedAt.toJson(),
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      'outcome': outcome,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAttendeeRefreshAttemptRecordInclude include() {
    return CalendarAttendeeRefreshAttemptRecordInclude._();
  }

  static CalendarAttendeeRefreshAttemptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    CalendarAttendeeRefreshAttemptRecordInclude? include,
  }) {
    return CalendarAttendeeRefreshAttemptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarAttendeeRefreshAttemptRecordImpl
    extends CalendarAttendeeRefreshAttemptRecord {
  _CalendarAttendeeRefreshAttemptRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue deliveryId,
    required int attemptNumber,
    required _is.UuidValue leaseToken,
    required DateTime startedAt,
    DateTime? finishedAt,
    required String outcome,
  }) : super._(
         id: id,
         deliveryId: deliveryId,
         attemptNumber: attemptNumber,
         leaseToken: leaseToken,
         startedAt: startedAt,
         finishedAt: finishedAt,
         outcome: outcome,
       );

  /// Returns a shallow copy of this [CalendarAttendeeRefreshAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAttendeeRefreshAttemptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? deliveryId,
    int? attemptNumber,
    _is.UuidValue? leaseToken,
    DateTime? startedAt,
    DateTime? finishedAt = const _is.$UndefinedDateTime(),
    String? outcome,
  }) {
    return CalendarAttendeeRefreshAttemptRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      deliveryId: deliveryId ?? this.deliveryId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      leaseToken: leaseToken ?? this.leaseToken,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt is _is.UndefinedSentinel
          ? this.finishedAt
          : finishedAt,
      outcome: outcome ?? this.outcome,
    );
  }
}

class CalendarAttendeeRefreshAttemptRecordUpdateTable
    extends _is.UpdateTable<CalendarAttendeeRefreshAttemptRecordTable> {
  CalendarAttendeeRefreshAttemptRecordUpdateTable(super.table);

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
}

class CalendarAttendeeRefreshAttemptRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarAttendeeRefreshAttemptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_attendee_refresh_attempt') {
    updateTable = CalendarAttendeeRefreshAttemptRecordUpdateTable(this);
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
  }

  late final CalendarAttendeeRefreshAttemptRecordUpdateTable updateTable;

  late final _is.ColumnUuid deliveryId;

  late final _is.ColumnInt attemptNumber;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnDateTime startedAt;

  late final _is.ColumnDateTime finishedAt;

  late final _is.ColumnString outcome;

  @override
  List<_is.Column> get columns => [
    id,
    deliveryId,
    attemptNumber,
    leaseToken,
    startedAt,
    finishedAt,
    outcome,
  ];
}

class CalendarAttendeeRefreshAttemptRecordInclude extends _is.IncludeObject {
  CalendarAttendeeRefreshAttemptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAttendeeRefreshAttemptRecord.t;
}

class CalendarAttendeeRefreshAttemptRecordIncludeList extends _is.IncludeList {
  CalendarAttendeeRefreshAttemptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAttendeeRefreshAttemptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAttendeeRefreshAttemptRecord.t;
}

class CalendarAttendeeRefreshAttemptRecordRepository {
  const CalendarAttendeeRefreshAttemptRecordRepository._();

  /// Returns a list of [CalendarAttendeeRefreshAttemptRecord]s matching the given query parameters.
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
  Future<List<CalendarAttendeeRefreshAttemptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAttendeeRefreshAttemptRecord>(
      where: where?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarAttendeeRefreshAttemptRecord]s matching the given query parameters every time the
  /// source tables are modified.
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
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `CalendarAttendeeRefreshAttemptRecord.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<CalendarAttendeeRefreshAttemptRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarAttendeeRefreshAttemptRecord>(
      where: where?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarAttendeeRefreshAttemptRecord] matching the given query parameters.
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
  Future<CalendarAttendeeRefreshAttemptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAttendeeRefreshAttemptRecord>(
      where: where?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAttendeeRefreshAttemptRecord] by its [id] or null if no such row exists.
  Future<CalendarAttendeeRefreshAttemptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAttendeeRefreshAttemptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAttendeeRefreshAttemptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAttendeeRefreshAttemptRecord]s will have their `id` fields set.
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
  Future<List<CalendarAttendeeRefreshAttemptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshAttemptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAttendeeRefreshAttemptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAttendeeRefreshAttemptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAttendeeRefreshAttemptRecord] will have its `id` field set.
  Future<CalendarAttendeeRefreshAttemptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAttendeeRefreshAttemptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAttendeeRefreshAttemptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAttendeeRefreshAttemptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshAttemptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshAttemptRecord> rows, {
    required _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAttendeeRefreshAttemptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAttendeeRefreshAttemptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarAttendeeRefreshAttemptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAttendeeRefreshAttemptRecord] and returns the resulting row.
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
  /// The returned [CalendarAttendeeRefreshAttemptRecord] will have its `id` field set.
  Future<CalendarAttendeeRefreshAttemptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshAttemptRecord row, {
    required _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAttendeeRefreshAttemptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAttendeeRefreshAttemptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarAttendeeRefreshAttemptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAttendeeRefreshAttemptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshAttemptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshAttemptRecord> rows, {
    _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAttendeeRefreshAttemptRecord>(
      rows,
      columns: columns?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAttendeeRefreshAttemptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAttendeeRefreshAttemptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshAttemptRecord row, {
    _is.ColumnSelections<CalendarAttendeeRefreshAttemptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAttendeeRefreshAttemptRecord>(
      row,
      columns: columns?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAttendeeRefreshAttemptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAttendeeRefreshAttemptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarAttendeeRefreshAttemptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAttendeeRefreshAttemptRecord>(
      id,
      columnValues: columnValues(
        CalendarAttendeeRefreshAttemptRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAttendeeRefreshAttemptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshAttemptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarAttendeeRefreshAttemptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarAttendeeRefreshAttemptRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAttendeeRefreshAttemptRecord>(
      columnValues: columnValues(
        CalendarAttendeeRefreshAttemptRecord.t.updateTable,
      ),
      where: where(CalendarAttendeeRefreshAttemptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAttendeeRefreshAttemptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAttendeeRefreshAttemptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshAttemptRecord> rows, {
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAttendeeRefreshAttemptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAttendeeRefreshAttemptRecord].
  Future<CalendarAttendeeRefreshAttemptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAttendeeRefreshAttemptRecord>(
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
  Future<List<CalendarAttendeeRefreshAttemptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarAttendeeRefreshAttemptRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarAttendeeRefreshAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAttendeeRefreshAttemptRecord>(
      where: where(CalendarAttendeeRefreshAttemptRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshAttemptRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshAttemptRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAttendeeRefreshAttemptRecord>(
      where: where?.call(CalendarAttendeeRefreshAttemptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAttendeeRefreshAttemptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarAttendeeRefreshAttemptRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAttendeeRefreshAttemptRecord>(
      where: where(CalendarAttendeeRefreshAttemptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
