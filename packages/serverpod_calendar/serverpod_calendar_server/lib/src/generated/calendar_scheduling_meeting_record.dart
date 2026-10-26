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

abstract class CalendarSchedulingMeetingRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingMeetingRecord._({
    this.id,
    required this.scopeKey,
    required this.calendarId,
    required this.eventId,
    required this.organizerAddress,
    required this.authorityRef,
    required this.revision,
    required this.generation,
    this.latestPublicationId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarSchedulingMeetingRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required String organizerAddress,
    required String authorityRef,
    required int revision,
    required int generation,
    _is.UuidValue? latestPublicationId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarSchedulingMeetingRecordImpl;

  factory CalendarSchedulingMeetingRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingMeetingRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      organizerAddress: jsonSerialization['organizerAddress'] as String,
      authorityRef: jsonSerialization['authorityRef'] as String,
      revision: jsonSerialization['revision'] as int,
      generation: jsonSerialization['generation'] as int,
      latestPublicationId: jsonSerialization['latestPublicationId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['latestPublicationId'],
            ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarSchedulingMeetingRecordTable();

  static const db = CalendarSchedulingMeetingRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue calendarId;

  _is.UuidValue eventId;

  String organizerAddress;

  String authorityRef;

  int revision;

  int generation;

  _is.UuidValue? latestPublicationId;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingMeetingRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingMeetingRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    String? organizerAddress,
    String? authorityRef,
    int? revision,
    int? generation,
    _is.UuidValue? latestPublicationId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingMeetingRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'organizerAddress': organizerAddress,
      'authorityRef': authorityRef,
      'revision': revision,
      'generation': generation,
      if (latestPublicationId != null)
        'latestPublicationId': latestPublicationId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingMeetingRecordInclude include() {
    return CalendarSchedulingMeetingRecordInclude._();
  }

  static CalendarSchedulingMeetingRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    CalendarSchedulingMeetingRecordInclude? include,
  }) {
    return CalendarSchedulingMeetingRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingMeetingRecordImpl
    extends CalendarSchedulingMeetingRecord {
  _CalendarSchedulingMeetingRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required String organizerAddress,
    required String authorityRef,
    required int revision,
    required int generation,
    _is.UuidValue? latestPublicationId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         calendarId: calendarId,
         eventId: eventId,
         organizerAddress: organizerAddress,
         authorityRef: authorityRef,
         revision: revision,
         generation: generation,
         latestPublicationId: latestPublicationId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarSchedulingMeetingRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingMeetingRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    String? organizerAddress,
    String? authorityRef,
    int? revision,
    int? generation,
    Object? latestPublicationId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarSchedulingMeetingRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      organizerAddress: organizerAddress ?? this.organizerAddress,
      authorityRef: authorityRef ?? this.authorityRef,
      revision: revision ?? this.revision,
      generation: generation ?? this.generation,
      latestPublicationId: latestPublicationId is _is.UuidValue?
          ? latestPublicationId
          : this.latestPublicationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarSchedulingMeetingRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingMeetingRecordTable> {
  CalendarSchedulingMeetingRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> eventId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.eventId,
        value,
      );

  _is.ColumnValue<String, String> organizerAddress(String value) =>
      _is.ColumnValue(
        table.organizerAddress,
        value,
      );

  _is.ColumnValue<String, String> authorityRef(String value) => _is.ColumnValue(
    table.authorityRef,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> latestPublicationId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.latestPublicationId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class CalendarSchedulingMeetingRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingMeetingRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_meeting') {
    updateTable = CalendarSchedulingMeetingRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    organizerAddress = _is.ColumnString(
      'organizerAddress',
      this,
    );
    authorityRef = _is.ColumnString(
      'authorityRef',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    latestPublicationId = _is.ColumnUuid(
      'latestPublicationId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CalendarSchedulingMeetingRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnUuid eventId;

  late final _is.ColumnString organizerAddress;

  late final _is.ColumnString authorityRef;

  late final _is.ColumnInt revision;

  late final _is.ColumnInt generation;

  late final _is.ColumnUuid latestPublicationId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    calendarId,
    eventId,
    organizerAddress,
    authorityRef,
    revision,
    generation,
    latestPublicationId,
    createdAt,
    updatedAt,
  ];
}

class CalendarSchedulingMeetingRecordInclude extends _is.IncludeObject {
  CalendarSchedulingMeetingRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingMeetingRecord.t;
}

class CalendarSchedulingMeetingRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingMeetingRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingMeetingRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingMeetingRecord.t;
}

class CalendarSchedulingMeetingRecordRepository {
  const CalendarSchedulingMeetingRecordRepository._();

  /// Returns a list of [CalendarSchedulingMeetingRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingMeetingRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingMeetingRecord>(
      where: where?.call(CalendarSchedulingMeetingRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingMeetingRecord] matching the given query parameters.
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
  Future<CalendarSchedulingMeetingRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingMeetingRecord>(
      where: where?.call(CalendarSchedulingMeetingRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingMeetingRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingMeetingRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingMeetingRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingMeetingRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingMeetingRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingMeetingRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingMeetingRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingMeetingRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingMeetingRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingMeetingRecord] will have its `id` field set.
  Future<CalendarSchedulingMeetingRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingMeetingRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingMeetingRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingMeetingRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingMeetingRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingMeetingRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingMeetingRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingMeetingRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingMeetingRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingMeetingRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingMeetingRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingMeetingRecord] will have its `id` field set.
  Future<CalendarSchedulingMeetingRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingMeetingRecord row, {
    required _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingMeetingRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingMeetingRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingMeetingRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingMeetingRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingMeetingRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingMeetingRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingMeetingRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingMeetingRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingMeetingRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingMeetingRecord row, {
    _is.ColumnSelections<CalendarSchedulingMeetingRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingMeetingRecord>(
      row,
      columns: columns?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingMeetingRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingMeetingRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingMeetingRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingMeetingRecord>(
      id,
      columnValues: columnValues(CalendarSchedulingMeetingRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingMeetingRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingMeetingRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingMeetingRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingMeetingRecord>(
      columnValues: columnValues(CalendarSchedulingMeetingRecord.t.updateTable),
      where: where(CalendarSchedulingMeetingRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingMeetingRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingMeetingRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingMeetingRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingMeetingRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingMeetingRecord].
  Future<CalendarSchedulingMeetingRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingMeetingRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingMeetingRecord>(
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
  Future<List<CalendarSchedulingMeetingRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>
    where,
    _is.OrderByBuilder<CalendarSchedulingMeetingRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingMeetingRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingMeetingRecord>(
      where: where(CalendarSchedulingMeetingRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingMeetingRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingMeetingRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingMeetingRecord>(
      where: where?.call(CalendarSchedulingMeetingRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingMeetingRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingMeetingRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingMeetingRecord>(
      where: where(CalendarSchedulingMeetingRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
