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

abstract class CalendarInvitationResponseSelectionSourcePinRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseSelectionSourcePinRecord._({
    this.id,
    required this.evidenceId,
    required this.sourceId,
  });

  factory CalendarInvitationResponseSelectionSourcePinRecord({
    _is.UuidValue? id,
    required _is.UuidValue evidenceId,
    required _is.UuidValue sourceId,
  }) = _CalendarInvitationResponseSelectionSourcePinRecordImpl;

  factory CalendarInvitationResponseSelectionSourcePinRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseSelectionSourcePinRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      evidenceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['evidenceId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
    );
  }

  static final t = CalendarInvitationResponseSelectionSourcePinRecordTable();

  static const db =
      CalendarInvitationResponseSelectionSourcePinRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue evidenceId;

  _is.UuidValue sourceId;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionSourcePinRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseSelectionSourcePinRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? evidenceId,
    _is.UuidValue? sourceId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseSelectionSourcePinRecord',
      if (id != null) 'id': id?.toJson(),
      'evidenceId': evidenceId.toJson(),
      'sourceId': sourceId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationResponseSelectionSourcePinRecordInclude include() {
    return CalendarInvitationResponseSelectionSourcePinRecordInclude._();
  }

  static CalendarInvitationResponseSelectionSourcePinRecordIncludeList
  includeList({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    CalendarInvitationResponseSelectionSourcePinRecordInclude? include,
  }) {
    return CalendarInvitationResponseSelectionSourcePinRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseSelectionSourcePinRecordImpl
    extends CalendarInvitationResponseSelectionSourcePinRecord {
  _CalendarInvitationResponseSelectionSourcePinRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue evidenceId,
    required _is.UuidValue sourceId,
  }) : super._(
         id: id,
         evidenceId: evidenceId,
         sourceId: sourceId,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionSourcePinRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseSelectionSourcePinRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? evidenceId,
    _is.UuidValue? sourceId,
  }) {
    return CalendarInvitationResponseSelectionSourcePinRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      evidenceId: evidenceId ?? this.evidenceId,
      sourceId: sourceId ?? this.sourceId,
    );
  }
}

class CalendarInvitationResponseSelectionSourcePinRecordUpdateTable
    extends
        _is.UpdateTable<
          CalendarInvitationResponseSelectionSourcePinRecordTable
        > {
  CalendarInvitationResponseSelectionSourcePinRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> evidenceId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.evidenceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );
}

class CalendarInvitationResponseSelectionSourcePinRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseSelectionSourcePinRecordTable({super.tableRelation})
    : super(tableName: 'calendar_inv_response_selection_pin') {
    updateTable = CalendarInvitationResponseSelectionSourcePinRecordUpdateTable(
      this,
    );
    evidenceId = _is.ColumnUuid(
      'evidenceId',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
  }

  late final CalendarInvitationResponseSelectionSourcePinRecordUpdateTable
  updateTable;

  late final _is.ColumnUuid evidenceId;

  late final _is.ColumnUuid sourceId;

  @override
  List<_is.Column> get columns => [
    id,
    evidenceId,
    sourceId,
  ];
}

class CalendarInvitationResponseSelectionSourcePinRecordInclude
    extends _is.IncludeObject {
  CalendarInvitationResponseSelectionSourcePinRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionSourcePinRecord.t;
}

class CalendarInvitationResponseSelectionSourcePinRecordIncludeList
    extends _is.IncludeList {
  CalendarInvitationResponseSelectionSourcePinRecordIncludeList._({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(
      CalendarInvitationResponseSelectionSourcePinRecord.t,
    );
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionSourcePinRecord.t;
}

class CalendarInvitationResponseSelectionSourcePinRecordRepository {
  const CalendarInvitationResponseSelectionSourcePinRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseSelectionSourcePinRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseSelectionSourcePinRecord>(
      where: where?.call(CalendarInvitationResponseSelectionSourcePinRecord.t),
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarInvitationResponseSelectionSourcePinRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarInvitationResponseSelectionSourcePinRecord.t`.
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
  _ida.Stream<List<CalendarInvitationResponseSelectionSourcePinRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarInvitationResponseSelectionSourcePinRecord>(
      where: where?.call(CalendarInvitationResponseSelectionSourcePinRecord.t),
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionSourcePinRecord.t,
      ),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseSelectionSourcePinRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseSelectionSourcePinRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findFirstRow<CalendarInvitationResponseSelectionSourcePinRecord>(
          where: where?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          offset: offset,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Finds a single [CalendarInvitationResponseSelectionSourcePinRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseSelectionSourcePinRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findById<CalendarInvitationResponseSelectionSourcePinRecord>(
          id,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Inserts all [CalendarInvitationResponseSelectionSourcePinRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseSelectionSourcePinRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionSourcePinRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db
        .insert<CalendarInvitationResponseSelectionSourcePinRecord>(
          rows,
          transaction: transaction,
          ignoreConflicts: ignoreConflicts,
          noReturn: noReturn,
        );
  }

  /// Inserts a single [CalendarInvitationResponseSelectionSourcePinRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseSelectionSourcePinRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionSourcePinRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionSourcePinRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db
        .insertRow<CalendarInvitationResponseSelectionSourcePinRecord>(
          row,
          transaction: transaction,
        );
  }

  /// Upserts all [CalendarInvitationResponseSelectionSourcePinRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseSelectionSourcePinRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionSourcePinRecord> rows, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .upsert<CalendarInvitationResponseSelectionSourcePinRecord>(
          rows,
          conflictColumns: conflictColumns(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          updateColumns: updateColumns?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          updateWhere: updateWhere?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Upserts a single [CalendarInvitationResponseSelectionSourcePinRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseSelectionSourcePinRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionSourcePinRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionSourcePinRecord row, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .upsertRow<CalendarInvitationResponseSelectionSourcePinRecord>(
          row,
          conflictColumns: conflictColumns(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          updateColumns: updateColumns?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          updateWhere: updateWhere?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
        );
  }

  /// Updates all [CalendarInvitationResponseSelectionSourcePinRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionSourcePinRecord> rows, {
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .update<CalendarInvitationResponseSelectionSourcePinRecord>(
          rows,
          columns: columns?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Updates a single [CalendarInvitationResponseSelectionSourcePinRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseSelectionSourcePinRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionSourcePinRecord row, {
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .updateRow<CalendarInvitationResponseSelectionSourcePinRecord>(
          row,
          columns: columns?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
        );
  }

  /// Updates a single [CalendarInvitationResponseSelectionSourcePinRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseSelectionSourcePinRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .updateById<CalendarInvitationResponseSelectionSourcePinRecord>(
          id,
          columnValues: columnValues(
            CalendarInvitationResponseSelectionSourcePinRecord.t.updateTable,
          ),
          transaction: transaction,
        );
  }

  /// Updates all [CalendarInvitationResponseSelectionSourcePinRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .updateWhere<CalendarInvitationResponseSelectionSourcePinRecord>(
          columnValues: columnValues(
            CalendarInvitationResponseSelectionSourcePinRecord.t.updateTable,
          ),
          where: where(CalendarInvitationResponseSelectionSourcePinRecord.t),
          limit: limit,
          offset: offset,
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Deletes all [CalendarInvitationResponseSelectionSourcePinRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionSourcePinRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .delete<CalendarInvitationResponseSelectionSourcePinRecord>(
          rows,
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Deletes a single [CalendarInvitationResponseSelectionSourcePinRecord].
  Future<CalendarInvitationResponseSelectionSourcePinRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionSourcePinRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db
        .deleteRow<CalendarInvitationResponseSelectionSourcePinRecord>(
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
  Future<List<CalendarInvitationResponseSelectionSourcePinRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionSourcePinRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .deleteWhere<CalendarInvitationResponseSelectionSourcePinRecord>(
          where: where(CalendarInvitationResponseSelectionSourcePinRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionSourcePinRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseSelectionSourcePinRecord>(
      where: where?.call(CalendarInvitationResponseSelectionSourcePinRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseSelectionSourcePinRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionSourcePinRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db
        .lockRows<CalendarInvitationResponseSelectionSourcePinRecord>(
          where: where(CalendarInvitationResponseSelectionSourcePinRecord.t),
          lockMode: lockMode,
          lockBehavior: lockBehavior,
          transaction: transaction,
        );
  }
}
