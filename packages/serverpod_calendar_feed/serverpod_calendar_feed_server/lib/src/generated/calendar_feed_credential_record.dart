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

abstract class CalendarFeedCredentialRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFeedCredentialRecord._({
    this.id,
    required this.feedId,
    required this.digestVersion,
    required this.digest,
    this.label,
    required this.revision,
    required this.createdAt,
    this.revokedAt,
  });

  factory CalendarFeedCredentialRecord({
    _is.UuidValue? id,
    required _is.UuidValue feedId,
    required int digestVersion,
    required String digest,
    String? label,
    required int revision,
    required DateTime createdAt,
    DateTime? revokedAt,
  }) = _CalendarFeedCredentialRecordImpl;

  factory CalendarFeedCredentialRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedCredentialRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      feedId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['feedId']),
      digestVersion: jsonSerialization['digestVersion'] as int,
      digest: jsonSerialization['digest'] as String,
      label: jsonSerialization['label'] as String?,
      revision: jsonSerialization['revision'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = CalendarFeedCredentialRecordTable();

  static const db = CalendarFeedCredentialRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue feedId;

  int digestVersion;

  String digest;

  String? label;

  int revision;

  DateTime createdAt;

  DateTime? revokedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFeedCredentialRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedCredentialRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? feedId,
    int? digestVersion,
    String? digest,
    String? label,
    int? revision,
    DateTime? createdAt,
    DateTime? revokedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedCredentialRecord',
      if (id != null) 'id': id?.toJson(),
      'feedId': feedId.toJson(),
      'digestVersion': digestVersion,
      'digest': digest,
      if (label != null) 'label': label,
      'revision': revision,
      'createdAt': createdAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFeedCredentialRecordInclude include() {
    return CalendarFeedCredentialRecordInclude._();
  }

  static CalendarFeedCredentialRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    CalendarFeedCredentialRecordInclude? include,
  }) {
    return CalendarFeedCredentialRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedCredentialRecordImpl extends CalendarFeedCredentialRecord {
  _CalendarFeedCredentialRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue feedId,
    required int digestVersion,
    required String digest,
    String? label,
    required int revision,
    required DateTime createdAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         feedId: feedId,
         digestVersion: digestVersion,
         digest: digest,
         label: label,
         revision: revision,
         createdAt: createdAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [CalendarFeedCredentialRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedCredentialRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? feedId,
    int? digestVersion,
    String? digest,
    Object? label = _Undefined,
    int? revision,
    DateTime? createdAt,
    Object? revokedAt = _Undefined,
  }) {
    return CalendarFeedCredentialRecord(
      id: id is _is.UuidValue? ? id : this.id,
      feedId: feedId ?? this.feedId,
      digestVersion: digestVersion ?? this.digestVersion,
      digest: digest ?? this.digest,
      label: label is String? ? label : this.label,
      revision: revision ?? this.revision,
      createdAt: createdAt ?? this.createdAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}

class CalendarFeedCredentialRecordUpdateTable
    extends _is.UpdateTable<CalendarFeedCredentialRecordTable> {
  CalendarFeedCredentialRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> feedId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.feedId,
        value,
      );

  _is.ColumnValue<int, int> digestVersion(int value) => _is.ColumnValue(
    table.digestVersion,
    value,
  );

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );

  _is.ColumnValue<String, String> label(String? value) => _is.ColumnValue(
    table.label,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class CalendarFeedCredentialRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFeedCredentialRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_feed_credential') {
    updateTable = CalendarFeedCredentialRecordUpdateTable(this);
    feedId = _is.ColumnUuid(
      'feedId',
      this,
    );
    digestVersion = _is.ColumnInt(
      'digestVersion',
      this,
    );
    digest = _is.ColumnString(
      'digest',
      this,
    );
    label = _is.ColumnString(
      'label',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
  }

  late final CalendarFeedCredentialRecordUpdateTable updateTable;

  late final _is.ColumnUuid feedId;

  late final _is.ColumnInt digestVersion;

  late final _is.ColumnString digest;

  late final _is.ColumnString label;

  late final _is.ColumnInt revision;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime revokedAt;

  @override
  List<_is.Column> get columns => [
    id,
    feedId,
    digestVersion,
    digest,
    label,
    revision,
    createdAt,
    revokedAt,
  ];
}

class CalendarFeedCredentialRecordInclude extends _is.IncludeObject {
  CalendarFeedCredentialRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedCredentialRecord.t;
}

class CalendarFeedCredentialRecordIncludeList extends _is.IncludeList {
  CalendarFeedCredentialRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFeedCredentialRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFeedCredentialRecord.t;
}

class CalendarFeedCredentialRecordRepository {
  const CalendarFeedCredentialRecordRepository._();

  /// Returns a list of [CalendarFeedCredentialRecord]s matching the given query parameters.
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
  Future<List<CalendarFeedCredentialRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFeedCredentialRecord>(
      where: where?.call(CalendarFeedCredentialRecord.t),
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarFeedCredentialRecord] matching the given query parameters.
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
  Future<CalendarFeedCredentialRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFeedCredentialRecord>(
      where: where?.call(CalendarFeedCredentialRecord.t),
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFeedCredentialRecord] by its [id] or null if no such row exists.
  Future<CalendarFeedCredentialRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFeedCredentialRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFeedCredentialRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFeedCredentialRecord]s will have their `id` fields set.
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
  Future<List<CalendarFeedCredentialRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFeedCredentialRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFeedCredentialRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFeedCredentialRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFeedCredentialRecord] will have its `id` field set.
  Future<CalendarFeedCredentialRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFeedCredentialRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFeedCredentialRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFeedCredentialRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFeedCredentialRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedCredentialRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFeedCredentialRecord> rows, {
    required _is.ColumnSelections<CalendarFeedCredentialRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedCredentialRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFeedCredentialRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFeedCredentialRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedCredentialRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFeedCredentialRecord] and returns the resulting row.
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
  /// The returned [CalendarFeedCredentialRecord] will have its `id` field set.
  Future<CalendarFeedCredentialRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFeedCredentialRecord row, {
    required _is.ColumnSelections<CalendarFeedCredentialRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFeedCredentialRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFeedCredentialRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFeedCredentialRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedCredentialRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedCredentialRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedCredentialRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFeedCredentialRecord> rows, {
    _is.ColumnSelections<CalendarFeedCredentialRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFeedCredentialRecord>(
      rows,
      columns: columns?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFeedCredentialRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFeedCredentialRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFeedCredentialRecord row, {
    _is.ColumnSelections<CalendarFeedCredentialRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFeedCredentialRecord>(
      row,
      columns: columns?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFeedCredentialRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFeedCredentialRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarFeedCredentialRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFeedCredentialRecord>(
      id,
      columnValues: columnValues(CalendarFeedCredentialRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedCredentialRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedCredentialRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarFeedCredentialRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFeedCredentialRecord>(
      columnValues: columnValues(CalendarFeedCredentialRecord.t.updateTable),
      where: where(CalendarFeedCredentialRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFeedCredentialRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFeedCredentialRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFeedCredentialRecord> rows, {
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFeedCredentialRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFeedCredentialRecord].
  Future<CalendarFeedCredentialRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFeedCredentialRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFeedCredentialRecord>(
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
  Future<List<CalendarFeedCredentialRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>
    where,
    _is.OrderByBuilder<CalendarFeedCredentialRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedCredentialRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFeedCredentialRecord>(
      where: where(CalendarFeedCredentialRecord.t),
      orderBy: orderBy?.call(CalendarFeedCredentialRecord.t),
      orderByList: orderByList?.call(CalendarFeedCredentialRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFeedCredentialRecord>(
      where: where?.call(CalendarFeedCredentialRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFeedCredentialRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedCredentialRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFeedCredentialRecord>(
      where: where(CalendarFeedCredentialRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
