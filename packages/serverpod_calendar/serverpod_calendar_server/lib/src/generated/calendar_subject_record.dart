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

abstract class CalendarSubjectRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarSubjectRecord._({
    this.id,
    required this.calendarId,
    required this.namespace,
    required this.kind,
    required this.externalId,
    required this.contributesAvailability,
  });

  factory CalendarSubjectRecord({
    int? id,
    required _is.UuidValue calendarId,
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) = _CalendarSubjectRecordImpl;

  factory CalendarSubjectRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSubjectRecord(
      id: jsonSerialization['id'] as int?,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      namespace: jsonSerialization['namespace'] as String,
      kind: jsonSerialization['kind'] as String,
      externalId: jsonSerialization['externalId'] as String,
      contributesAvailability: _is.BoolJsonExtension.fromJson(
        jsonSerialization['contributesAvailability'],
      ),
    );
  }

  static final t = CalendarSubjectRecordTable();

  static const db = CalendarSubjectRecordRepository._();

  @override
  int? id;

  _is.UuidValue calendarId;

  String namespace;

  String kind;

  String externalId;

  bool contributesAvailability;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarSubjectRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSubjectRecord copyWith({
    int? id,
    _is.UuidValue? calendarId,
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSubjectRecord',
      if (id != null) 'id': id,
      'calendarId': calendarId.toJson(),
      'namespace': namespace,
      'kind': kind,
      'externalId': externalId,
      'contributesAvailability': contributesAvailability,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSubjectRecordInclude include() {
    return CalendarSubjectRecordInclude._();
  }

  static CalendarSubjectRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    CalendarSubjectRecordInclude? include,
  }) {
    return CalendarSubjectRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSubjectRecordImpl extends CalendarSubjectRecord {
  _CalendarSubjectRecordImpl({
    int? id,
    required _is.UuidValue calendarId,
    required String namespace,
    required String kind,
    required String externalId,
    required bool contributesAvailability,
  }) : super._(
         id: id,
         calendarId: calendarId,
         namespace: namespace,
         kind: kind,
         externalId: externalId,
         contributesAvailability: contributesAvailability,
       );

  /// Returns a shallow copy of this [CalendarSubjectRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSubjectRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? calendarId,
    String? namespace,
    String? kind,
    String? externalId,
    bool? contributesAvailability,
  }) {
    return CalendarSubjectRecord(
      id: id is int? ? id : this.id,
      calendarId: calendarId ?? this.calendarId,
      namespace: namespace ?? this.namespace,
      kind: kind ?? this.kind,
      externalId: externalId ?? this.externalId,
      contributesAvailability:
          contributesAvailability ?? this.contributesAvailability,
    );
  }
}

class CalendarSubjectRecordUpdateTable
    extends _is.UpdateTable<CalendarSubjectRecordTable> {
  CalendarSubjectRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<String, String> namespace(String value) => _is.ColumnValue(
    table.namespace,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> externalId(String value) => _is.ColumnValue(
    table.externalId,
    value,
  );

  _is.ColumnValue<bool, bool> contributesAvailability(bool value) =>
      _is.ColumnValue(
        table.contributesAvailability,
        value,
      );
}

class CalendarSubjectRecordTable extends _is.Table<int?> {
  CalendarSubjectRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_subject') {
    updateTable = CalendarSubjectRecordUpdateTable(this);
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    namespace = _is.ColumnString(
      'namespace',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    externalId = _is.ColumnString(
      'externalId',
      this,
    );
    contributesAvailability = _is.ColumnBool(
      'contributesAvailability',
      this,
    );
  }

  late final CalendarSubjectRecordUpdateTable updateTable;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnString namespace;

  late final _is.ColumnString kind;

  late final _is.ColumnString externalId;

  late final _is.ColumnBool contributesAvailability;

  @override
  List<_is.Column> get columns => [
    id,
    calendarId,
    namespace,
    kind,
    externalId,
    contributesAvailability,
  ];
}

class CalendarSubjectRecordInclude extends _is.IncludeObject {
  CalendarSubjectRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarSubjectRecord.t;
}

class CalendarSubjectRecordIncludeList extends _is.IncludeList {
  CalendarSubjectRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSubjectRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarSubjectRecord.t;
}

class CalendarSubjectRecordRepository {
  const CalendarSubjectRecordRepository._();

  /// Returns a list of [CalendarSubjectRecord]s matching the given query parameters.
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
  Future<List<CalendarSubjectRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSubjectRecord>(
      where: where?.call(CalendarSubjectRecord.t),
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSubjectRecord] matching the given query parameters.
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
  Future<CalendarSubjectRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSubjectRecord>(
      where: where?.call(CalendarSubjectRecord.t),
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSubjectRecord] by its [id] or null if no such row exists.
  Future<CalendarSubjectRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSubjectRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSubjectRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSubjectRecord]s will have their `id` fields set.
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
  Future<List<CalendarSubjectRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSubjectRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSubjectRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSubjectRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSubjectRecord] will have its `id` field set.
  Future<CalendarSubjectRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSubjectRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSubjectRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSubjectRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSubjectRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSubjectRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSubjectRecord> rows, {
    required _is.ColumnSelections<CalendarSubjectRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarSubjectRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSubjectRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSubjectRecord.t),
      updateColumns: updateColumns?.call(CalendarSubjectRecord.t),
      updateWhere: updateWhere?.call(CalendarSubjectRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSubjectRecord] and returns the resulting row.
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
  /// The returned [CalendarSubjectRecord] will have its `id` field set.
  Future<CalendarSubjectRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSubjectRecord row, {
    required _is.ColumnSelections<CalendarSubjectRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarSubjectRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSubjectRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSubjectRecord.t),
      updateColumns: updateColumns?.call(CalendarSubjectRecord.t),
      updateWhere: updateWhere?.call(CalendarSubjectRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSubjectRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSubjectRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSubjectRecord> rows, {
    _is.ColumnSelections<CalendarSubjectRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSubjectRecord>(
      rows,
      columns: columns?.call(CalendarSubjectRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSubjectRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSubjectRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSubjectRecord row, {
    _is.ColumnSelections<CalendarSubjectRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSubjectRecord>(
      row,
      columns: columns?.call(CalendarSubjectRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSubjectRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSubjectRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarSubjectRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSubjectRecord>(
      id,
      columnValues: columnValues(CalendarSubjectRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSubjectRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSubjectRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarSubjectRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarSubjectRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSubjectRecord>(
      columnValues: columnValues(CalendarSubjectRecord.t.updateTable),
      where: where(CalendarSubjectRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSubjectRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSubjectRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSubjectRecord> rows, {
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSubjectRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSubjectRecord].
  Future<CalendarSubjectRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSubjectRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSubjectRecord>(
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
  Future<List<CalendarSubjectRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSubjectRecordTable> where,
    _is.OrderByBuilder<CalendarSubjectRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSubjectRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSubjectRecord>(
      where: where(CalendarSubjectRecord.t),
      orderBy: orderBy?.call(CalendarSubjectRecord.t),
      orderByList: orderByList?.call(CalendarSubjectRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSubjectRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSubjectRecord>(
      where: where?.call(CalendarSubjectRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSubjectRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSubjectRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSubjectRecord>(
      where: where(CalendarSubjectRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
