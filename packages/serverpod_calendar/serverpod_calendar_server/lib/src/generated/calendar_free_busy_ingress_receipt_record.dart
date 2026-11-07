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

abstract class CalendarFreeBusyIngressReceiptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusyIngressReceiptRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.namespace,
    required this.deliveryKey,
    required this.inputDigest,
    required this.sourceId,
    required this.result,
    required this.createdAt,
    required this.expiresAt,
  });

  factory CalendarFreeBusyIngressReceiptRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String namespace,
    required String deliveryKey,
    required String inputDigest,
    required _is.UuidValue sourceId,
    required String result,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) = _CalendarFreeBusyIngressReceiptRecordImpl;

  factory CalendarFreeBusyIngressReceiptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyIngressReceiptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      namespace: jsonSerialization['namespace'] as String,
      deliveryKey: jsonSerialization['deliveryKey'] as String,
      inputDigest: jsonSerialization['inputDigest'] as String,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      result: jsonSerialization['result'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = CalendarFreeBusyIngressReceiptRecordTable();

  static const db = CalendarFreeBusyIngressReceiptRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  String namespace;

  String deliveryKey;

  String inputDigest;

  _is.UuidValue sourceId;

  String result;

  DateTime createdAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusyIngressReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyIngressReceiptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? namespace,
    String? deliveryKey,
    String? inputDigest,
    _is.UuidValue? sourceId,
    String? result,
    DateTime? createdAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarFreeBusyIngressReceiptRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'namespace': namespace,
      'deliveryKey': deliveryKey,
      'inputDigest': inputDigest,
      'sourceId': sourceId.toJson(),
      'result': result,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusyIngressReceiptRecordInclude include() {
    return CalendarFreeBusyIngressReceiptRecordInclude._();
  }

  static CalendarFreeBusyIngressReceiptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    CalendarFreeBusyIngressReceiptRecordInclude? include,
  }) {
    return CalendarFreeBusyIngressReceiptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusyIngressReceiptRecordImpl
    extends CalendarFreeBusyIngressReceiptRecord {
  _CalendarFreeBusyIngressReceiptRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String namespace,
    required String deliveryKey,
    required String inputDigest,
    required _is.UuidValue sourceId,
    required String result,
    required DateTime createdAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         namespace: namespace,
         deliveryKey: deliveryKey,
         inputDigest: inputDigest,
         sourceId: sourceId,
         result: result,
         createdAt: createdAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyIngressReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyIngressReceiptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? namespace,
    String? deliveryKey,
    String? inputDigest,
    _is.UuidValue? sourceId,
    String? result,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return CalendarFreeBusyIngressReceiptRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      namespace: namespace ?? this.namespace,
      deliveryKey: deliveryKey ?? this.deliveryKey,
      inputDigest: inputDigest ?? this.inputDigest,
      sourceId: sourceId ?? this.sourceId,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CalendarFreeBusyIngressReceiptRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusyIngressReceiptRecordTable> {
  CalendarFreeBusyIngressReceiptRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> ownerKey(String value) => _is.ColumnValue(
    table.ownerKey,
    value,
  );

  _is.ColumnValue<String, String> namespace(String value) => _is.ColumnValue(
    table.namespace,
    value,
  );

  _is.ColumnValue<String, String> deliveryKey(String value) => _is.ColumnValue(
    table.deliveryKey,
    value,
  );

  _is.ColumnValue<String, String> inputDigest(String value) => _is.ColumnValue(
    table.inputDigest,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<String, String> result(String value) => _is.ColumnValue(
    table.result,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class CalendarFreeBusyIngressReceiptRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusyIngressReceiptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_ingress') {
    updateTable = CalendarFreeBusyIngressReceiptRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    ownerKey = _is.ColumnString(
      'ownerKey',
      this,
    );
    namespace = _is.ColumnString(
      'namespace',
      this,
    );
    deliveryKey = _is.ColumnString(
      'deliveryKey',
      this,
    );
    inputDigest = _is.ColumnString(
      'inputDigest',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    result = _is.ColumnString(
      'result',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final CalendarFreeBusyIngressReceiptRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnString namespace;

  late final _is.ColumnString deliveryKey;

  late final _is.ColumnString inputDigest;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnString result;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    namespace,
    deliveryKey,
    inputDigest,
    sourceId,
    result,
    createdAt,
    expiresAt,
  ];
}

class CalendarFreeBusyIngressReceiptRecordInclude extends _is.IncludeObject {
  CalendarFreeBusyIngressReceiptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyIngressReceiptRecord.t;
}

class CalendarFreeBusyIngressReceiptRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusyIngressReceiptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusyIngressReceiptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyIngressReceiptRecord.t;
}

class CalendarFreeBusyIngressReceiptRecordRepository {
  const CalendarFreeBusyIngressReceiptRecordRepository._();

  /// Returns a list of [CalendarFreeBusyIngressReceiptRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusyIngressReceiptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusyIngressReceiptRecord>(
      where: where?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusyIngressReceiptRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusyIngressReceiptRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusyIngressReceiptRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusyIngressReceiptRecord>(
      where: where?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusyIngressReceiptRecord] matching the given query parameters.
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
  Future<CalendarFreeBusyIngressReceiptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusyIngressReceiptRecord>(
      where: where?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusyIngressReceiptRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusyIngressReceiptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusyIngressReceiptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusyIngressReceiptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusyIngressReceiptRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusyIngressReceiptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyIngressReceiptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusyIngressReceiptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusyIngressReceiptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusyIngressReceiptRecord] will have its `id` field set.
  Future<CalendarFreeBusyIngressReceiptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyIngressReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusyIngressReceiptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusyIngressReceiptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusyIngressReceiptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyIngressReceiptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyIngressReceiptRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusyIngressReceiptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusyIngressReceiptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarFreeBusyIngressReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusyIngressReceiptRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusyIngressReceiptRecord] will have its `id` field set.
  Future<CalendarFreeBusyIngressReceiptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyIngressReceiptRecord row, {
    required _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusyIngressReceiptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusyIngressReceiptRecord.t),
      updateColumns: updateColumns?.call(
        CalendarFreeBusyIngressReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyIngressReceiptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyIngressReceiptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusyIngressReceiptRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusyIngressReceiptRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusyIngressReceiptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusyIngressReceiptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusyIngressReceiptRecord row, {
    _is.ColumnSelections<CalendarFreeBusyIngressReceiptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusyIngressReceiptRecord>(
      row,
      columns: columns?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusyIngressReceiptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusyIngressReceiptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyIngressReceiptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusyIngressReceiptRecord>(
      id,
      columnValues: columnValues(
        CalendarFreeBusyIngressReceiptRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyIngressReceiptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyIngressReceiptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyIngressReceiptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarFreeBusyIngressReceiptRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusyIngressReceiptRecord>(
      columnValues: columnValues(
        CalendarFreeBusyIngressReceiptRecord.t.updateTable,
      ),
      where: where(CalendarFreeBusyIngressReceiptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusyIngressReceiptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusyIngressReceiptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusyIngressReceiptRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusyIngressReceiptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusyIngressReceiptRecord].
  Future<CalendarFreeBusyIngressReceiptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusyIngressReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusyIngressReceiptRecord>(
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
  Future<List<CalendarFreeBusyIngressReceiptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarFreeBusyIngressReceiptRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarFreeBusyIngressReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusyIngressReceiptRecord>(
      where: where(CalendarFreeBusyIngressReceiptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyIngressReceiptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyIngressReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyIngressReceiptRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusyIngressReceiptRecord>(
      where: where?.call(CalendarFreeBusyIngressReceiptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusyIngressReceiptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarFreeBusyIngressReceiptRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusyIngressReceiptRecord>(
      where: where(CalendarFreeBusyIngressReceiptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
