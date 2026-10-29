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

abstract class CalendarInvitationSourceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationSourceRecord._({
    this.id,
    required this.entryId,
    required this.normalizedSource,
    required this.byteCount,
    required this.digest,
    this.sequence,
    required this.stamp,
    required this.outcome,
    required this.receivedAt,
    this.inactiveAt,
  });

  factory CalendarInvitationSourceRecord({
    _is.UuidValue? id,
    required _is.UuidValue entryId,
    required String normalizedSource,
    required int byteCount,
    required String digest,
    int? sequence,
    required DateTime stamp,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) = _CalendarInvitationSourceRecordImpl;

  factory CalendarInvitationSourceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationSourceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      normalizedSource: jsonSerialization['normalizedSource'] as String,
      byteCount: jsonSerialization['byteCount'] as int,
      digest: jsonSerialization['digest'] as String,
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      outcome: _i98zwsq8.CalendarInvitationOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      inactiveAt: jsonSerialization['inactiveAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['inactiveAt']),
    );
  }

  static final t = CalendarInvitationSourceRecordTable();

  static const db = CalendarInvitationSourceRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entryId;

  String normalizedSource;

  int byteCount;

  String digest;

  int? sequence;

  DateTime stamp;

  _i98zwsq8.CalendarInvitationOutcome outcome;

  DateTime receivedAt;

  DateTime? inactiveAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationSourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationSourceRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? entryId,
    String? normalizedSource,
    int? byteCount,
    String? digest,
    int? sequence,
    DateTime? stamp,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    DateTime? receivedAt,
    DateTime? inactiveAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationSourceRecord',
      if (id != null) 'id': id?.toJson(),
      'entryId': entryId.toJson(),
      'normalizedSource': normalizedSource,
      'byteCount': byteCount,
      'digest': digest,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'outcome': outcome.toJson(),
      'receivedAt': receivedAt.toJson(),
      if (inactiveAt != null) 'inactiveAt': inactiveAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationSourceRecordInclude include() {
    return CalendarInvitationSourceRecordInclude._();
  }

  static CalendarInvitationSourceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    CalendarInvitationSourceRecordInclude? include,
  }) {
    return CalendarInvitationSourceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationSourceRecordImpl
    extends CalendarInvitationSourceRecord {
  _CalendarInvitationSourceRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue entryId,
    required String normalizedSource,
    required int byteCount,
    required String digest,
    int? sequence,
    required DateTime stamp,
    required _i98zwsq8.CalendarInvitationOutcome outcome,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) : super._(
         id: id,
         entryId: entryId,
         normalizedSource: normalizedSource,
         byteCount: byteCount,
         digest: digest,
         sequence: sequence,
         stamp: stamp,
         outcome: outcome,
         receivedAt: receivedAt,
         inactiveAt: inactiveAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationSourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationSourceRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? entryId,
    String? normalizedSource,
    int? byteCount,
    String? digest,
    Object? sequence = _Undefined,
    DateTime? stamp,
    _i98zwsq8.CalendarInvitationOutcome? outcome,
    DateTime? receivedAt,
    Object? inactiveAt = _Undefined,
  }) {
    return CalendarInvitationSourceRecord(
      id: id is _is.UuidValue? ? id : this.id,
      entryId: entryId ?? this.entryId,
      normalizedSource: normalizedSource ?? this.normalizedSource,
      byteCount: byteCount ?? this.byteCount,
      digest: digest ?? this.digest,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      outcome: outcome ?? this.outcome,
      receivedAt: receivedAt ?? this.receivedAt,
      inactiveAt: inactiveAt is DateTime? ? inactiveAt : this.inactiveAt,
    );
  }
}

class CalendarInvitationSourceRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationSourceRecordTable> {
  CalendarInvitationSourceRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entryId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entryId,
        value,
      );

  _is.ColumnValue<String, String> normalizedSource(String value) =>
      _is.ColumnValue(
        table.normalizedSource,
        value,
      );

  _is.ColumnValue<int, int> byteCount(int value) => _is.ColumnValue(
    table.byteCount,
    value,
  );

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );

  _is.ColumnValue<int, int> sequence(int? value) => _is.ColumnValue(
    table.sequence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
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

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> inactiveAt(DateTime? value) =>
      _is.ColumnValue(
        table.inactiveAt,
        value,
      );
}

class CalendarInvitationSourceRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarInvitationSourceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_source') {
    updateTable = CalendarInvitationSourceRecordUpdateTable(this);
    entryId = _is.ColumnUuid(
      'entryId',
      this,
    );
    normalizedSource = _is.ColumnString(
      'normalizedSource',
      this,
    );
    byteCount = _is.ColumnInt(
      'byteCount',
      this,
    );
    digest = _is.ColumnString(
      'digest',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
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
    inactiveAt = _is.ColumnDateTime(
      'inactiveAt',
      this,
    );
  }

  late final CalendarInvitationSourceRecordUpdateTable updateTable;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnString normalizedSource;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnString digest;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnEnum<_i98zwsq8.CalendarInvitationOutcome> outcome;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime inactiveAt;

  @override
  List<_is.Column> get columns => [
    id,
    entryId,
    normalizedSource,
    byteCount,
    digest,
    sequence,
    stamp,
    outcome,
    receivedAt,
    inactiveAt,
  ];
}

class CalendarInvitationSourceRecordInclude extends _is.IncludeObject {
  CalendarInvitationSourceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationSourceRecord.t;
}

class CalendarInvitationSourceRecordIncludeList extends _is.IncludeList {
  CalendarInvitationSourceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationSourceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationSourceRecord.t;
}

class CalendarInvitationSourceRecordRepository {
  const CalendarInvitationSourceRecordRepository._();

  /// Returns a list of [CalendarInvitationSourceRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationSourceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationSourceRecord>(
      where: where?.call(CalendarInvitationSourceRecord.t),
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationSourceRecord] matching the given query parameters.
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
  Future<CalendarInvitationSourceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationSourceRecord>(
      where: where?.call(CalendarInvitationSourceRecord.t),
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationSourceRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationSourceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationSourceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationSourceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationSourceRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationSourceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationSourceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationSourceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationSourceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationSourceRecord] will have its `id` field set.
  Future<CalendarInvitationSourceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationSourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationSourceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationSourceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationSourceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationSourceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationSourceRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationSourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationSourceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationSourceRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationSourceRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationSourceRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationSourceRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationSourceRecord] will have its `id` field set.
  Future<CalendarInvitationSourceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationSourceRecord row, {
    required _is.ColumnSelections<CalendarInvitationSourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationSourceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationSourceRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationSourceRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationSourceRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationSourceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationSourceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationSourceRecord> rows, {
    _is.ColumnSelections<CalendarInvitationSourceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationSourceRecord>(
      rows,
      columns: columns?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationSourceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationSourceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationSourceRecord row, {
    _is.ColumnSelections<CalendarInvitationSourceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationSourceRecord>(
      row,
      columns: columns?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationSourceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationSourceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationSourceRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationSourceRecord>(
      id,
      columnValues: columnValues(CalendarInvitationSourceRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationSourceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationSourceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationSourceRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationSourceRecord>(
      columnValues: columnValues(CalendarInvitationSourceRecord.t.updateTable),
      where: where(CalendarInvitationSourceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationSourceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationSourceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationSourceRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationSourceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationSourceRecord].
  Future<CalendarInvitationSourceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationSourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationSourceRecord>(
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
  Future<List<CalendarInvitationSourceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>
    where,
    _is.OrderByBuilder<CalendarInvitationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationSourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationSourceRecord>(
      where: where(CalendarInvitationSourceRecord.t),
      orderBy: orderBy?.call(CalendarInvitationSourceRecord.t),
      orderByList: orderByList?.call(CalendarInvitationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationSourceRecord>(
      where: where?.call(CalendarInvitationSourceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationSourceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationSourceRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationSourceRecord>(
      where: where(CalendarInvitationSourceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
