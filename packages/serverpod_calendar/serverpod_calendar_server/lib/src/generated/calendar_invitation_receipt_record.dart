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
import 'calendar_invitation_outcome.dart' as _i98zwsq8;

abstract class CalendarInvitationReceiptRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationReceiptRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.ingressDigest,
    required this.sourceId,
    required this.originDigest,
    required this.outcome,
    required this.entryRevision,
    required this.receivedAt,
    required this.expiresAt,
  });

  factory CalendarInvitationReceiptRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String ingressDigest,
    required _is.UuidValue sourceId,
    required String originDigest,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
    required DateTime expiresAt,
  }) = _CalendarInvitationReceiptRecordImpl;

  factory CalendarInvitationReceiptRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationReceiptRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      ingressDigest: jsonSerialization['ingressDigest'] as String,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      originDigest: jsonSerialization['originDigest'] as String,
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
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

  static final t = CalendarInvitationReceiptRecordTable();

  static const db = CalendarInvitationReceiptRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  String ingressDigest;

  _is.UuidValue sourceId;

  String originDigest;

  _i98zwsq8.CalendarInvitationOutcome outcome;

  int entryRevision;

  DateTime receivedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationReceiptRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientKey,
    String? ingressDigest,
    _is.UuidValue? sourceId,
    String? originDigest,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationReceiptRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'ingressDigest': ingressDigest,
      'sourceId': sourceId.toJson(),
      'originDigest': originDigest,
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

  static CalendarInvitationReceiptRecordInclude include() {
    return CalendarInvitationReceiptRecordInclude._();
  }

  static CalendarInvitationReceiptRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    CalendarInvitationReceiptRecordInclude? include,
  }) {
    return CalendarInvitationReceiptRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationReceiptRecordImpl
    extends CalendarInvitationReceiptRecord {
  _CalendarInvitationReceiptRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String ingressDigest,
    required _is.UuidValue sourceId,
    required String originDigest,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required int entryRevision,
    required DateTime receivedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         ingressDigest: ingressDigest,
         sourceId: sourceId,
         originDigest: originDigest,
         outcome: outcome,
         entryRevision: entryRevision,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationReceiptRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationReceiptRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientKey,
    String? ingressDigest,
    _is.UuidValue? sourceId,
    String? originDigest,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    int? entryRevision,
    DateTime? receivedAt,
    DateTime? expiresAt,
  }) {
    return CalendarInvitationReceiptRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      ingressDigest: ingressDigest ?? this.ingressDigest,
      sourceId: sourceId ?? this.sourceId,
      originDigest: originDigest ?? this.originDigest,
      outcome: outcome ?? this.outcome,
      entryRevision: entryRevision ?? this.entryRevision,
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CalendarInvitationReceiptRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationReceiptRecordTable> {
  CalendarInvitationReceiptRecordUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<String, String> originDigest(String value) => _is.ColumnValue(
    table.originDigest,
    value,
  );

  _is.ColumnValue<
    _i98zwsq8.CalendarInvitationOutcome,
    _i98zwsq8.CalendarInvitationOutcome
  >
  outcome(_i98zwsq8.CalendarInvitationOutcome value) => _is.ColumnValue(
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

class CalendarInvitationReceiptRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarInvitationReceiptRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_receipt') {
    updateTable = CalendarInvitationReceiptRecordUpdateTable(this);
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
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    originDigest = _is.ColumnString(
      'originDigest',
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

  late final CalendarInvitationReceiptRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString ingressDigest;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnString originDigest;

  late final _is.ColumnEnum<_i98zwsq8.CalendarInvitationOutcome> outcome;

  late final _is.ColumnInt entryRevision;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    ingressDigest,
    sourceId,
    originDigest,
    outcome,
    entryRevision,
    receivedAt,
    expiresAt,
  ];
}

class CalendarInvitationReceiptRecordInclude extends _is.IncludeObject {
  CalendarInvitationReceiptRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationReceiptRecord.t;
}

class CalendarInvitationReceiptRecordIncludeList extends _is.IncludeList {
  CalendarInvitationReceiptRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationReceiptRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationReceiptRecord.t;
}

class CalendarInvitationReceiptRecordRepository {
  const CalendarInvitationReceiptRecordRepository._();

  /// Returns a list of [CalendarInvitationReceiptRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationReceiptRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationReceiptRecord>(
      where: where?.call(CalendarInvitationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationReceiptRecord] matching the given query parameters.
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
  Future<CalendarInvitationReceiptRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationReceiptRecord>(
      where: where?.call(CalendarInvitationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationReceiptRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationReceiptRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationReceiptRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationReceiptRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationReceiptRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationReceiptRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationReceiptRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationReceiptRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationReceiptRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationReceiptRecord] will have its `id` field set.
  Future<CalendarInvitationReceiptRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationReceiptRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationReceiptRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationReceiptRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationReceiptRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationReceiptRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationReceiptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationReceiptRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationReceiptRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationReceiptRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationReceiptRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationReceiptRecord] will have its `id` field set.
  Future<CalendarInvitationReceiptRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationReceiptRecord row, {
    required _is.ColumnSelections<CalendarInvitationReceiptRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationReceiptRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationReceiptRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationReceiptRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationReceiptRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationReceiptRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationReceiptRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationReceiptRecord> rows, {
    _is.ColumnSelections<CalendarInvitationReceiptRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationReceiptRecord>(
      rows,
      columns: columns?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationReceiptRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationReceiptRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationReceiptRecord row, {
    _is.ColumnSelections<CalendarInvitationReceiptRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationReceiptRecord>(
      row,
      columns: columns?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationReceiptRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationReceiptRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationReceiptRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationReceiptRecord>(
      id,
      columnValues: columnValues(CalendarInvitationReceiptRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationReceiptRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationReceiptRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationReceiptRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationReceiptRecord>(
      columnValues: columnValues(CalendarInvitationReceiptRecord.t.updateTable),
      where: where(CalendarInvitationReceiptRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationReceiptRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationReceiptRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationReceiptRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationReceiptRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationReceiptRecord].
  Future<CalendarInvitationReceiptRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationReceiptRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationReceiptRecord>(
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
  Future<List<CalendarInvitationReceiptRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>
    where,
    _is.OrderByBuilder<CalendarInvitationReceiptRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationReceiptRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationReceiptRecord>(
      where: where(CalendarInvitationReceiptRecord.t),
      orderBy: orderBy?.call(CalendarInvitationReceiptRecord.t),
      orderByList: orderByList?.call(CalendarInvitationReceiptRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationReceiptRecord>(
      where: where?.call(CalendarInvitationReceiptRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationReceiptRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationReceiptRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationReceiptRecord>(
      where: where(CalendarInvitationReceiptRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
