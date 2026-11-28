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

import 'calendar_incoming_publication_outcome.dart' as _ireg3hht;

abstract class CalendarIncomingPublicationReceiptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarIncomingPublicationReceiptRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.ingressDigest,
    required this.originDigest,
    required this.sourceId,
    required this.entryId,
    required this.outcome,
    required this.entryRevision,
    required this.receivedAt,
    required this.expiresAt,
  });

  factory CalendarIncomingPublicationReceiptRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String ingressDigest,
    required String originDigest,
    required _is.UuidValue sourceId,
    required _is.UuidValue entryId,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
    required DateTime expiresAt,
  }) = _CalendarIncomingPublicationReceiptRecordImpl;

  factory CalendarIncomingPublicationReceiptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationReceiptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      ingressDigest: jsonSerialization['ingressDigest'] as String,
      originDigest: jsonSerialization['originDigest'] as String,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      outcome: _ireg3hht.CalendarIncomingPublicationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      entryRevision: jsonSerialization['entryRevision'] as int,
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = CalendarIncomingPublicationReceiptRecordTable();

  static const db = CalendarIncomingPublicationReceiptRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  String ingressDigest;

  String originDigest;

  _is.UuidValue sourceId;

  _is.UuidValue entryId;

  _ireg3hht.CalendarIncomingPublicationOutcome outcome;

  int entryRevision;

  DateTime receivedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarIncomingPublicationReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationReceiptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? ingressDigest,
    String? originDigest,
    _is.UuidValue? sourceId,
    _is.UuidValue? entryId,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationReceiptRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'ingressDigest': ingressDigest,
      'originDigest': originDigest,
      'sourceId': sourceId.toJson(),
      'entryId': entryId.toJson(),
      'outcome': outcome.toJson(),
      'entryRevision': entryRevision,
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarIncomingPublicationReceiptRecordInclude include() {
    return CalendarIncomingPublicationReceiptRecordInclude._();
  }

  static CalendarIncomingPublicationReceiptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    CalendarIncomingPublicationReceiptRecordInclude? include,
  }) {
    return CalendarIncomingPublicationReceiptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarIncomingPublicationReceiptRecordImpl
    extends CalendarIncomingPublicationReceiptRecord {
  _CalendarIncomingPublicationReceiptRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String ingressDigest,
    required String originDigest,
    required _is.UuidValue sourceId,
    required _is.UuidValue entryId,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         ingressDigest: ingressDigest,
         originDigest: originDigest,
         sourceId: sourceId,
         entryId: entryId,
         outcome: outcome,
         entryRevision: entryRevision,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationReceiptRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? ingressDigest,
    String? originDigest,
    _is.UuidValue? sourceId,
    _is.UuidValue? entryId,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
    DateTime? expiresAt,
  }) {
    return CalendarIncomingPublicationReceiptRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      ingressDigest: ingressDigest ?? this.ingressDigest,
      originDigest: originDigest ?? this.originDigest,
      sourceId: sourceId ?? this.sourceId,
      entryId: entryId ?? this.entryId,
      outcome: outcome ?? this.outcome,
      entryRevision: entryRevision ?? this.entryRevision,
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CalendarIncomingPublicationReceiptRecordUpdateTable
    extends _is.UpdateTable<CalendarIncomingPublicationReceiptRecordTable> {
  CalendarIncomingPublicationReceiptRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<String, String> ingressDigest(String value) =>
      _is.ColumnValue(
        table.ingressDigest,
        value,
      );

  _is.ColumnValue<String, String> originDigest(String value) => _is.ColumnValue(
    table.originDigest,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entryId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entryId,
        value,
      );

  _is.ColumnValue<
    _ireg3hht.CalendarIncomingPublicationOutcome,
    _ireg3hht.CalendarIncomingPublicationOutcome
  >
  outcome(_ireg3hht.CalendarIncomingPublicationOutcome value) =>
      _is.ColumnValue(
        table.outcome,
        value,
      );

  _is.ColumnValue<int, int> entryRevision(int value) => _is.ColumnValue(
    table.entryRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class CalendarIncomingPublicationReceiptRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarIncomingPublicationReceiptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_incoming_publication_receipt') {
    updateTable = CalendarIncomingPublicationReceiptRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    ingressDigest = _is.ColumnString(
      'ingressDigest',
      this,
    );
    originDigest = _is.ColumnString(
      'originDigest',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    entryId = _is.ColumnUuid(
      'entryId',
      this,
    );
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
    );
    entryRevision = _is.ColumnInt(
      'entryRevision',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final CalendarIncomingPublicationReceiptRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString ingressDigest;

  late final _is.ColumnString originDigest;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnEnum<_ireg3hht.CalendarIncomingPublicationOutcome>
  outcome;

  late final _is.ColumnInt entryRevision;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    ingressDigest,
    originDigest,
    sourceId,
    entryId,
    outcome,
    entryRevision,
    receivedAt,
    expiresAt,
  ];
}

class CalendarIncomingPublicationReceiptRecordInclude
    extends _is.IncludeObject {
  CalendarIncomingPublicationReceiptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationReceiptRecord.t;
}

class CalendarIncomingPublicationReceiptRecordIncludeList
    extends _is.IncludeList {
  CalendarIncomingPublicationReceiptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarIncomingPublicationReceiptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationReceiptRecord.t;
}

class CalendarIncomingPublicationReceiptRecordRepository {
  const CalendarIncomingPublicationReceiptRecordRepository._();

  /// Returns a list of [CalendarIncomingPublicationReceiptRecord]s matching the given query parameters.
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
  Future<List<CalendarIncomingPublicationReceiptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarIncomingPublicationReceiptRecord>(
      where: where?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarIncomingPublicationReceiptRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarIncomingPublicationReceiptRecord.t`.
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
  _ida.Stream<List<CalendarIncomingPublicationReceiptRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarIncomingPublicationReceiptRecord>(
      where: where?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarIncomingPublicationReceiptRecord] matching the given query parameters.
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
  Future<CalendarIncomingPublicationReceiptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarIncomingPublicationReceiptRecord>(
      where: where?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarIncomingPublicationReceiptRecord] by its [id] or null if no such row exists.
  Future<CalendarIncomingPublicationReceiptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarIncomingPublicationReceiptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarIncomingPublicationReceiptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarIncomingPublicationReceiptRecord]s will have their `id` fields set.
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
  Future<List<CalendarIncomingPublicationReceiptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationReceiptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarIncomingPublicationReceiptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarIncomingPublicationReceiptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarIncomingPublicationReceiptRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationReceiptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarIncomingPublicationReceiptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarIncomingPublicationReceiptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarIncomingPublicationReceiptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationReceiptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationReceiptRecord> rows, {
    required _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarIncomingPublicationReceiptRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarIncomingPublicationReceiptRecord] and returns the resulting row.
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
  /// The returned [CalendarIncomingPublicationReceiptRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationReceiptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationReceiptRecord row, {
    required _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarIncomingPublicationReceiptRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationReceiptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationReceiptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationReceiptRecord> rows, {
    _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarIncomingPublicationReceiptRecord>(
      rows,
      columns: columns?.call(CalendarIncomingPublicationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarIncomingPublicationReceiptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarIncomingPublicationReceiptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationReceiptRecord row, {
    _is.ColumnSelections<CalendarIncomingPublicationReceiptRecordTable>?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarIncomingPublicationReceiptRecord>(
      row,
      columns: columns?.call(CalendarIncomingPublicationReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarIncomingPublicationReceiptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarIncomingPublicationReceiptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationReceiptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarIncomingPublicationReceiptRecord>(
      id,
      columnValues: columnValues(
        CalendarIncomingPublicationReceiptRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationReceiptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationReceiptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationReceiptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationReceiptRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarIncomingPublicationReceiptRecord>(
      columnValues: columnValues(
        CalendarIncomingPublicationReceiptRecord.t.updateTable,
      ),
      where: where(CalendarIncomingPublicationReceiptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarIncomingPublicationReceiptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarIncomingPublicationReceiptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationReceiptRecord> rows, {
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarIncomingPublicationReceiptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarIncomingPublicationReceiptRecord].
  Future<CalendarIncomingPublicationReceiptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarIncomingPublicationReceiptRecord>(
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
  Future<List<CalendarIncomingPublicationReceiptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationReceiptRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarIncomingPublicationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarIncomingPublicationReceiptRecord>(
      where: where(CalendarIncomingPublicationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationReceiptRecord.t),
      orderByList: orderByList?.call(
        CalendarIncomingPublicationReceiptRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationReceiptRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarIncomingPublicationReceiptRecord>(
      where: where?.call(CalendarIncomingPublicationReceiptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarIncomingPublicationReceiptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationReceiptRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarIncomingPublicationReceiptRecord>(
      where: where(CalendarIncomingPublicationReceiptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
