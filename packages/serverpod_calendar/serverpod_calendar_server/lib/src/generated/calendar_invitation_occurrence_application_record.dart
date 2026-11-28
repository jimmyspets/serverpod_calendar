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

abstract class CalendarInvitationOccurrenceApplicationRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationOccurrenceApplicationRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.linkId,
    required this.revision,
    required this.stateJson,
    required this.eventRevision,
    required this.updatedAt,
  });

  factory CalendarInvitationOccurrenceApplicationRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue linkId,
    required int revision,
    required String stateJson,
    required int eventRevision,
    required DateTime updatedAt,
  }) = _CalendarInvitationOccurrenceApplicationRecordImpl;

  factory CalendarInvitationOccurrenceApplicationRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationOccurrenceApplicationRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      linkId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      revision: jsonSerialization['revision'] as int,
      stateJson: jsonSerialization['stateJson'] as String,
      eventRevision: jsonSerialization['eventRevision'] as int,
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarInvitationOccurrenceApplicationRecordTable();

  static const db = CalendarInvitationOccurrenceApplicationRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  _is.UuidValue linkId;

  int revision;

  String stateJson;

  int eventRevision;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationOccurrenceApplicationRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? linkId,
    int? revision,
    String? stateJson,
    int? eventRevision,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationOccurrenceApplicationRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'linkId': linkId.toJson(),
      'revision': revision,
      'stateJson': stateJson,
      'eventRevision': eventRevision,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationOccurrenceApplicationRecordInclude include() {
    return CalendarInvitationOccurrenceApplicationRecordInclude._();
  }

  static CalendarInvitationOccurrenceApplicationRecordIncludeList includeList({
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    CalendarInvitationOccurrenceApplicationRecordInclude? include,
  }) {
    return CalendarInvitationOccurrenceApplicationRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationOccurrenceApplicationRecordImpl
    extends CalendarInvitationOccurrenceApplicationRecord {
  _CalendarInvitationOccurrenceApplicationRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue linkId,
    required int revision,
    required String stateJson,
    required int eventRevision,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         linkId: linkId,
         revision: revision,
         stateJson: stateJson,
         eventRevision: eventRevision,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationOccurrenceApplicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationOccurrenceApplicationRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? linkId,
    int? revision,
    String? stateJson,
    int? eventRevision,
    DateTime? updatedAt,
  }) {
    return CalendarInvitationOccurrenceApplicationRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      linkId: linkId ?? this.linkId,
      revision: revision ?? this.revision,
      stateJson: stateJson ?? this.stateJson,
      eventRevision: eventRevision ?? this.eventRevision,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarInvitationOccurrenceApplicationRecordUpdateTable
    extends
        _is.UpdateTable<CalendarInvitationOccurrenceApplicationRecordTable> {
  CalendarInvitationOccurrenceApplicationRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> linkId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.linkId,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> stateJson(String value) => _is.ColumnValue(
    table.stateJson,
    value,
  );

  _is.ColumnValue<int, int> eventRevision(int value) => _is.ColumnValue(
    table.eventRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CalendarInvitationOccurrenceApplicationRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationOccurrenceApplicationRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_occurrence_application') {
    updateTable = CalendarInvitationOccurrenceApplicationRecordUpdateTable(
      this,
    );
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    linkId = _is.ColumnUuid(
      'linkId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    stateJson = _is.ColumnString(
      'stateJson',
      this,
    );
    eventRevision = _is.ColumnInt(
      'eventRevision',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CalendarInvitationOccurrenceApplicationRecordUpdateTable
  updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid linkId;

  late final _is.ColumnInt revision;

  late final _is.ColumnString stateJson;

  late final _is.ColumnInt eventRevision;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    linkId,
    revision,
    stateJson,
    eventRevision,
    updatedAt,
  ];
}

class CalendarInvitationOccurrenceApplicationRecordInclude
    extends _is.IncludeObject {
  CalendarInvitationOccurrenceApplicationRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationOccurrenceApplicationRecord.t;
}

class CalendarInvitationOccurrenceApplicationRecordIncludeList
    extends _is.IncludeList {
  CalendarInvitationOccurrenceApplicationRecordIncludeList._({
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationOccurrenceApplicationRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationOccurrenceApplicationRecord.t;
}

class CalendarInvitationOccurrenceApplicationRecordRepository {
  const CalendarInvitationOccurrenceApplicationRecordRepository._();

  /// Returns a list of [CalendarInvitationOccurrenceApplicationRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationOccurrenceApplicationRecord>(
      where: where?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationOccurrenceApplicationRecord] matching the given query parameters.
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
  Future<CalendarInvitationOccurrenceApplicationRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findFirstRow<CalendarInvitationOccurrenceApplicationRecord>(
          where: where?.call(CalendarInvitationOccurrenceApplicationRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
          ),
          offset: offset,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Finds a single [CalendarInvitationOccurrenceApplicationRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationOccurrenceApplicationRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationOccurrenceApplicationRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationOccurrenceApplicationRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationOccurrenceApplicationRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationOccurrenceApplicationRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationOccurrenceApplicationRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationOccurrenceApplicationRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationOccurrenceApplicationRecord] will have its `id` field set.
  Future<CalendarInvitationOccurrenceApplicationRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationOccurrenceApplicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationOccurrenceApplicationRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationOccurrenceApplicationRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationOccurrenceApplicationRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationOccurrenceApplicationRecord> rows, {
    required _is.ColumnSelections<
      CalendarInvitationOccurrenceApplicationRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationOccurrenceApplicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationOccurrenceApplicationRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationOccurrenceApplicationRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationOccurrenceApplicationRecord] will have its `id` field set.
  Future<CalendarInvitationOccurrenceApplicationRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationOccurrenceApplicationRecord row, {
    required _is.ColumnSelections<
      CalendarInvitationOccurrenceApplicationRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationOccurrenceApplicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationOccurrenceApplicationRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationOccurrenceApplicationRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationOccurrenceApplicationRecord> rows, {
    _is.ColumnSelections<CalendarInvitationOccurrenceApplicationRecordTable>?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationOccurrenceApplicationRecord>(
      rows,
      columns: columns?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationOccurrenceApplicationRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationOccurrenceApplicationRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationOccurrenceApplicationRecord row, {
    _is.ColumnSelections<CalendarInvitationOccurrenceApplicationRecordTable>?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationOccurrenceApplicationRecord>(
      row,
      columns: columns?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationOccurrenceApplicationRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationOccurrenceApplicationRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationOccurrenceApplicationRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationOccurrenceApplicationRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationOccurrenceApplicationRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationOccurrenceApplicationRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationOccurrenceApplicationRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .updateWhere<CalendarInvitationOccurrenceApplicationRecord>(
          columnValues: columnValues(
            CalendarInvitationOccurrenceApplicationRecord.t.updateTable,
          ),
          where: where(CalendarInvitationOccurrenceApplicationRecord.t),
          limit: limit,
          offset: offset,
          orderBy: orderBy?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Deletes all [CalendarInvitationOccurrenceApplicationRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationOccurrenceApplicationRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationOccurrenceApplicationRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationOccurrenceApplicationRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationOccurrenceApplicationRecord].
  Future<CalendarInvitationOccurrenceApplicationRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationOccurrenceApplicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationOccurrenceApplicationRecord>(
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
  Future<List<CalendarInvitationOccurrenceApplicationRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationOccurrenceApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .deleteWhere<CalendarInvitationOccurrenceApplicationRecord>(
          where: where(CalendarInvitationOccurrenceApplicationRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationOccurrenceApplicationRecord.t,
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
      CalendarInvitationOccurrenceApplicationRecordTable
    >?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationOccurrenceApplicationRecord>(
      where: where?.call(CalendarInvitationOccurrenceApplicationRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationOccurrenceApplicationRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationOccurrenceApplicationRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationOccurrenceApplicationRecord>(
      where: where(CalendarInvitationOccurrenceApplicationRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
