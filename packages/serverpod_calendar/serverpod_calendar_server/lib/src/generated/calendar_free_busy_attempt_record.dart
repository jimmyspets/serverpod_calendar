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

abstract class CalendarFreeBusyAttemptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusyAttemptRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.deliveryId,
    required this.generation,
    required this.ordinal,
    required this.leaseOwner,
    required this.startedAt,
    this.finishedAt,
    this.outcome,
    this.reasonCode,
    required this.payloadDigest,
    this.mimeDigest,
  });

  factory CalendarFreeBusyAttemptRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue deliveryId,
    required int generation,
    required int ordinal,
    required _is.UuidValue leaseOwner,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? outcome,
    String? reasonCode,
    required String payloadDigest,
    String? mimeDigest,
  }) = _CalendarFreeBusyAttemptRecordImpl;

  factory CalendarFreeBusyAttemptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyAttemptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      deliveryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deliveryId'],
      ),
      generation: jsonSerialization['generation'] as int,
      ordinal: jsonSerialization['ordinal'] as int,
      leaseOwner: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['leaseOwner'],
      ),
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      finishedAt: jsonSerialization['finishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['finishedAt']),
      outcome: jsonSerialization['outcome'] as String?,
      reasonCode: jsonSerialization['reasonCode'] as String?,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      mimeDigest: jsonSerialization['mimeDigest'] as String?,
    );
  }

  static final t = CalendarFreeBusyAttemptRecordTable();

  static const db = CalendarFreeBusyAttemptRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  _is.UuidValue deliveryId;

  int generation;

  int ordinal;

  _is.UuidValue leaseOwner;

  DateTime startedAt;

  DateTime? finishedAt;

  String? outcome;

  String? reasonCode;

  String payloadDigest;

  String? mimeDigest;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusyAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyAttemptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? deliveryId,
    int? generation,
    int? ordinal,
    _is.UuidValue? leaseOwner,
    DateTime? startedAt,
    DateTime? finishedAt = const _is.$UndefinedDateTime(),
    String? outcome,
    String? reasonCode,
    String? payloadDigest,
    String? mimeDigest,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyAttemptRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'deliveryId': deliveryId.toJson(),
      'generation': generation,
      'ordinal': ordinal,
      'leaseOwner': leaseOwner.toJson(),
      'startedAt': startedAt.toJson(),
      if (finishedAt != null) 'finishedAt': finishedAt?.toJson(),
      if (outcome != null) 'outcome': outcome,
      if (reasonCode != null) 'reasonCode': reasonCode,
      'payloadDigest': payloadDigest,
      if (mimeDigest != null) 'mimeDigest': mimeDigest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusyAttemptRecordInclude include() {
    return CalendarFreeBusyAttemptRecordInclude._();
  }

  static CalendarFreeBusyAttemptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    CalendarFreeBusyAttemptRecordInclude? include,
  }) {
    return CalendarFreeBusyAttemptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyAttemptRecordImpl extends CalendarFreeBusyAttemptRecord {
  _CalendarFreeBusyAttemptRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue deliveryId,
    required int generation,
    required int ordinal,
    required _is.UuidValue leaseOwner,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? outcome,
    String? reasonCode,
    required String payloadDigest,
    String? mimeDigest,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         deliveryId: deliveryId,
         generation: generation,
         ordinal: ordinal,
         leaseOwner: leaseOwner,
         startedAt: startedAt,
         finishedAt: finishedAt,
         outcome: outcome,
         reasonCode: reasonCode,
         payloadDigest: payloadDigest,
         mimeDigest: mimeDigest,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyAttemptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyAttemptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? deliveryId,
    int? generation,
    int? ordinal,
    _is.UuidValue? leaseOwner,
    DateTime? startedAt,
    DateTime? finishedAt = const _is.$UndefinedDateTime(),
    Object? outcome = _Undefined,
    Object? reasonCode = _Undefined,
    String? payloadDigest,
    Object? mimeDigest = _Undefined,
  }) {
    return CalendarFreeBusyAttemptRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      deliveryId: deliveryId ?? this.deliveryId,
      generation: generation ?? this.generation,
      ordinal: ordinal ?? this.ordinal,
      leaseOwner: leaseOwner ?? this.leaseOwner,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt is _is.UndefinedSentinel
          ? this.finishedAt
          : finishedAt,
      outcome: outcome is String? ? outcome : this.outcome,
      reasonCode: reasonCode is String? ? reasonCode : this.reasonCode,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      mimeDigest: mimeDigest is String? ? mimeDigest : this.mimeDigest,
    );
  }
}

class CalendarFreeBusyAttemptRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusyAttemptRecordTable> {
  CalendarFreeBusyAttemptRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> ownerKey(String value) => _is.ColumnValue(
    table.ownerKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deliveryId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.deliveryId,
    value,
  );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<int, int> ordinal(int value) => _is.ColumnValue(
    table.ordinal,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseOwner(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.leaseOwner,
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

  _is.ColumnValue<String, String> outcome(String? value) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<String, String> reasonCode(String? value) => _is.ColumnValue(
    table.reasonCode,
    value,
  );

  _is.ColumnValue<String, String> payloadDigest(String value) =>
      _is.ColumnValue(
        table.payloadDigest,
        value,
      );

  _is.ColumnValue<String, String> mimeDigest(String? value) => _is.ColumnValue(
    table.mimeDigest,
    value,
  );
}

class CalendarFreeBusyAttemptRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusyAttemptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_attempt') {
    updateTable = CalendarFreeBusyAttemptRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    ownerKey = _is.ColumnString(
      'ownerKey',
      this,
    );
    deliveryId = _is.ColumnUuid(
      'deliveryId',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    ordinal = _is.ColumnInt(
      'ordinal',
      this,
    );
    leaseOwner = _is.ColumnUuid(
      'leaseOwner',
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
    reasonCode = _is.ColumnString(
      'reasonCode',
      this,
    );
    payloadDigest = _is.ColumnString(
      'payloadDigest',
      this,
    );
    mimeDigest = _is.ColumnString(
      'mimeDigest',
      this,
    );
  }

  late final CalendarFreeBusyAttemptRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnUuid deliveryId;

  late final _is.ColumnInt generation;

  late final _is.ColumnInt ordinal;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnDateTime startedAt;

  late final _is.ColumnDateTime finishedAt;

  late final _is.ColumnString outcome;

  late final _is.ColumnString reasonCode;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnString mimeDigest;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    deliveryId,
    generation,
    ordinal,
    leaseOwner,
    startedAt,
    finishedAt,
    outcome,
    reasonCode,
    payloadDigest,
    mimeDigest,
  ];
}

class CalendarFreeBusyAttemptRecordInclude extends _is.IncludeObject {
  CalendarFreeBusyAttemptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyAttemptRecord.t;
}

class CalendarFreeBusyAttemptRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusyAttemptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusyAttemptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyAttemptRecord.t;
}

class CalendarFreeBusyAttemptRecordRepository {
  const CalendarFreeBusyAttemptRecordRepository._();

  /// Returns a list of [CalendarFreeBusyAttemptRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusyAttemptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusyAttemptRecord>(
      where: where?.call(CalendarFreeBusyAttemptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusyAttemptRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusyAttemptRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusyAttemptRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusyAttemptRecord>(
      where: where?.call(CalendarFreeBusyAttemptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusyAttemptRecord] matching the given query parameters.
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
  Future<CalendarFreeBusyAttemptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusyAttemptRecord>(
      where: where?.call(CalendarFreeBusyAttemptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusyAttemptRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusyAttemptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusyAttemptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusyAttemptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusyAttemptRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusyAttemptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyAttemptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusyAttemptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusyAttemptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusyAttemptRecord] will have its `id` field set.
  Future<CalendarFreeBusyAttemptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusyAttemptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusyAttemptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusyAttemptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyAttemptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyAttemptRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusyAttemptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusyAttemptRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyAttemptRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusyAttemptRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusyAttemptRecord] will have its `id` field set.
  Future<CalendarFreeBusyAttemptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyAttemptRecord row, {
    required _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusyAttemptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusyAttemptRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyAttemptRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyAttemptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyAttemptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusyAttemptRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusyAttemptRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusyAttemptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusyAttemptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusyAttemptRecord row, {
    _is.ColumnSelections<CalendarFreeBusyAttemptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusyAttemptRecord>(
      row,
      columns: columns?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusyAttemptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusyAttemptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyAttemptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusyAttemptRecord>(
      id,
      columnValues: columnValues(CalendarFreeBusyAttemptRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyAttemptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyAttemptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyAttemptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusyAttemptRecord>(
      columnValues: columnValues(CalendarFreeBusyAttemptRecord.t.updateTable),
      where: where(CalendarFreeBusyAttemptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusyAttemptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusyAttemptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusyAttemptRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusyAttemptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusyAttemptRecord].
  Future<CalendarFreeBusyAttemptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusyAttemptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusyAttemptRecord>(
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
  Future<List<CalendarFreeBusyAttemptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>
    where,
    _is.OrderByBuilder<CalendarFreeBusyAttemptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyAttemptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusyAttemptRecord>(
      where: where(CalendarFreeBusyAttemptRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyAttemptRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyAttemptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusyAttemptRecord>(
      where: where?.call(CalendarFreeBusyAttemptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusyAttemptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyAttemptRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusyAttemptRecord>(
      where: where(CalendarFreeBusyAttemptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
