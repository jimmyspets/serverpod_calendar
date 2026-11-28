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

abstract class CalendarInvitationResponseSelectionEvidenceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseSelectionEvidenceRecord._({
    this.id,
    required this.headId,
    required this.revision,
    required this.evidenceJson,
    required this.digest,
    required this.byteCount,
    required this.createdAt,
    this.retiredAt,
  });

  factory CalendarInvitationResponseSelectionEvidenceRecord({
    _is.UuidValue? id,
    required _is.UuidValue headId,
    required int revision,
    required String evidenceJson,
    required String digest,
    required int byteCount,
    required DateTime createdAt,
    DateTime? retiredAt,
  }) = _CalendarInvitationResponseSelectionEvidenceRecordImpl;

  factory CalendarInvitationResponseSelectionEvidenceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseSelectionEvidenceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      headId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['headId']),
      revision: jsonSerialization['revision'] as int,
      evidenceJson: jsonSerialization['evidenceJson'] as String,
      digest: jsonSerialization['digest'] as String,
      byteCount: jsonSerialization['byteCount'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      retiredAt: jsonSerialization['retiredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['retiredAt']),
    );
  }

  static final t = CalendarInvitationResponseSelectionEvidenceRecordTable();

  static const db =
      CalendarInvitationResponseSelectionEvidenceRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue headId;

  int revision;

  String evidenceJson;

  String digest;

  int byteCount;

  DateTime createdAt;

  DateTime? retiredAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionEvidenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseSelectionEvidenceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? headId,
    int? revision,
    String? evidenceJson,
    String? digest,
    int? byteCount,
    DateTime? createdAt,
    DateTime? retiredAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseSelectionEvidenceRecord',
      if (id != null) 'id': id?.toJson(),
      'headId': headId.toJson(),
      'revision': revision,
      'evidenceJson': evidenceJson,
      'digest': digest,
      'byteCount': byteCount,
      'createdAt': createdAt.toJson(),
      if (retiredAt != null) 'retiredAt': retiredAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationResponseSelectionEvidenceRecordInclude include() {
    return CalendarInvitationResponseSelectionEvidenceRecordInclude._();
  }

  static CalendarInvitationResponseSelectionEvidenceRecordIncludeList
  includeList({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    CalendarInvitationResponseSelectionEvidenceRecordInclude? include,
  }) {
    return CalendarInvitationResponseSelectionEvidenceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseSelectionEvidenceRecordImpl
    extends CalendarInvitationResponseSelectionEvidenceRecord {
  _CalendarInvitationResponseSelectionEvidenceRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue headId,
    required int revision,
    required String evidenceJson,
    required String digest,
    required int byteCount,
    required DateTime createdAt,
    DateTime? retiredAt,
  }) : super._(
         id: id,
         headId: headId,
         revision: revision,
         evidenceJson: evidenceJson,
         digest: digest,
         byteCount: byteCount,
         createdAt: createdAt,
         retiredAt: retiredAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionEvidenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseSelectionEvidenceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? headId,
    int? revision,
    String? evidenceJson,
    String? digest,
    int? byteCount,
    DateTime? createdAt,
    DateTime? retiredAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarInvitationResponseSelectionEvidenceRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      headId: headId ?? this.headId,
      revision: revision ?? this.revision,
      evidenceJson: evidenceJson ?? this.evidenceJson,
      digest: digest ?? this.digest,
      byteCount: byteCount ?? this.byteCount,
      createdAt: createdAt ?? this.createdAt,
      retiredAt: retiredAt is _is.UndefinedSentinel
          ? this.retiredAt
          : retiredAt,
    );
  }
}

class CalendarInvitationResponseSelectionEvidenceRecordUpdateTable
    extends
        _is.UpdateTable<
          CalendarInvitationResponseSelectionEvidenceRecordTable
        > {
  CalendarInvitationResponseSelectionEvidenceRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> headId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.headId,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> evidenceJson(String value) => _is.ColumnValue(
    table.evidenceJson,
    value,
  );

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );

  _is.ColumnValue<int, int> byteCount(int value) => _is.ColumnValue(
    table.byteCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> retiredAt(DateTime? value) =>
      _is.ColumnValue(
        table.retiredAt,
        value,
      );
}

class CalendarInvitationResponseSelectionEvidenceRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseSelectionEvidenceRecordTable({super.tableRelation})
    : super(tableName: 'calendar_inv_response_selection_evidence') {
    updateTable = CalendarInvitationResponseSelectionEvidenceRecordUpdateTable(
      this,
    );
    headId = _is.ColumnUuid(
      'headId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    evidenceJson = _is.ColumnString(
      'evidenceJson',
      this,
    );
    digest = _is.ColumnString(
      'digest',
      this,
    );
    byteCount = _is.ColumnInt(
      'byteCount',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    retiredAt = _is.ColumnDateTime(
      'retiredAt',
      this,
    );
  }

  late final CalendarInvitationResponseSelectionEvidenceRecordUpdateTable
  updateTable;

  late final _is.ColumnUuid headId;

  late final _is.ColumnInt revision;

  late final _is.ColumnString evidenceJson;

  late final _is.ColumnString digest;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime retiredAt;

  @override
  List<_is.Column> get columns => [
    id,
    headId,
    revision,
    evidenceJson,
    digest,
    byteCount,
    createdAt,
    retiredAt,
  ];
}

class CalendarInvitationResponseSelectionEvidenceRecordInclude
    extends _is.IncludeObject {
  CalendarInvitationResponseSelectionEvidenceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionEvidenceRecord.t;
}

class CalendarInvitationResponseSelectionEvidenceRecordIncludeList
    extends _is.IncludeList {
  CalendarInvitationResponseSelectionEvidenceRecordIncludeList._({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(
      CalendarInvitationResponseSelectionEvidenceRecord.t,
    );
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionEvidenceRecord.t;
}

class CalendarInvitationResponseSelectionEvidenceRecordRepository {
  const CalendarInvitationResponseSelectionEvidenceRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseSelectionEvidenceRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseSelectionEvidenceRecord>(
      where: where?.call(CalendarInvitationResponseSelectionEvidenceRecord.t),
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarInvitationResponseSelectionEvidenceRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarInvitationResponseSelectionEvidenceRecord.t`.
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
  _ida.Stream<List<CalendarInvitationResponseSelectionEvidenceRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarInvitationResponseSelectionEvidenceRecord>(
      where: where?.call(CalendarInvitationResponseSelectionEvidenceRecord.t),
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseSelectionEvidenceRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseSelectionEvidenceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findFirstRow<CalendarInvitationResponseSelectionEvidenceRecord>(
          where: where?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          offset: offset,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Finds a single [CalendarInvitationResponseSelectionEvidenceRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseSelectionEvidenceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findById<CalendarInvitationResponseSelectionEvidenceRecord>(
          id,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Inserts all [CalendarInvitationResponseSelectionEvidenceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseSelectionEvidenceRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionEvidenceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationResponseSelectionEvidenceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationResponseSelectionEvidenceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseSelectionEvidenceRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionEvidenceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionEvidenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db
        .insertRow<CalendarInvitationResponseSelectionEvidenceRecord>(
          row,
          transaction: transaction,
        );
  }

  /// Upserts all [CalendarInvitationResponseSelectionEvidenceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseSelectionEvidenceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionEvidenceRecord> rows, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationResponseSelectionEvidenceRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationResponseSelectionEvidenceRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseSelectionEvidenceRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionEvidenceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionEvidenceRecord row, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .upsertRow<CalendarInvitationResponseSelectionEvidenceRecord>(
          row,
          conflictColumns: conflictColumns(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          updateColumns: updateColumns?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          updateWhere: updateWhere?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          transaction: transaction,
        );
  }

  /// Updates all [CalendarInvitationResponseSelectionEvidenceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionEvidenceRecord> rows, {
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationResponseSelectionEvidenceRecord>(
      rows,
      columns: columns?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationResponseSelectionEvidenceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseSelectionEvidenceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionEvidenceRecord row, {
    _is.ColumnSelections<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .updateRow<CalendarInvitationResponseSelectionEvidenceRecord>(
          row,
          columns: columns?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          transaction: transaction,
        );
  }

  /// Updates a single [CalendarInvitationResponseSelectionEvidenceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseSelectionEvidenceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db
        .updateById<CalendarInvitationResponseSelectionEvidenceRecord>(
          id,
          columnValues: columnValues(
            CalendarInvitationResponseSelectionEvidenceRecord.t.updateTable,
          ),
          transaction: transaction,
        );
  }

  /// Updates all [CalendarInvitationResponseSelectionEvidenceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .updateWhere<CalendarInvitationResponseSelectionEvidenceRecord>(
          columnValues: columnValues(
            CalendarInvitationResponseSelectionEvidenceRecord.t.updateTable,
          ),
          where: where(CalendarInvitationResponseSelectionEvidenceRecord.t),
          limit: limit,
          offset: offset,
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Deletes all [CalendarInvitationResponseSelectionEvidenceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionEvidenceRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationResponseSelectionEvidenceRecord>(
      rows,
      orderBy: orderBy?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionEvidenceRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationResponseSelectionEvidenceRecord].
  Future<CalendarInvitationResponseSelectionEvidenceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionEvidenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db
        .deleteRow<CalendarInvitationResponseSelectionEvidenceRecord>(
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
  Future<List<CalendarInvitationResponseSelectionEvidenceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionEvidenceRecordTable>?
    orderBy,
    _is.OrderByListBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .deleteWhere<CalendarInvitationResponseSelectionEvidenceRecord>(
          where: where(CalendarInvitationResponseSelectionEvidenceRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionEvidenceRecord.t,
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
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseSelectionEvidenceRecord>(
      where: where?.call(CalendarInvitationResponseSelectionEvidenceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseSelectionEvidenceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionEvidenceRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db
        .lockRows<CalendarInvitationResponseSelectionEvidenceRecord>(
          where: where(CalendarInvitationResponseSelectionEvidenceRecord.t),
          lockMode: lockMode,
          lockBehavior: lockBehavior,
          transaction: transaction,
        );
  }
}
