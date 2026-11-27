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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;
import 'calendar_availability_content.dart' as _ifxxil5c;
import 'calendar_availability_opening_edits.dart' as _id5ke9r5;

abstract class CalendarAvailabilityDataRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarAvailabilityDataRecord._({
    this.id,
    required this.availabilityId,
    _is.UuidValue? protocolUid,
    this.timingOverrides,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  }) : protocolUid = protocolUid ?? const _is.Uuid().v4obj();

  factory CalendarAvailabilityDataRecord({
    int? id,
    required _is.UuidValue availabilityId,
    _is.UuidValue? protocolUid,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    required _ifxxil5c.CalendarAvailabilityContent content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarAvailabilityDataRecordImpl;

  factory CalendarAvailabilityDataRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAvailabilityDataRecord(
      id: jsonSerialization['id'] as int?,
      availabilityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['availabilityId'],
      ),
      protocolUid: jsonSerialization['protocolUid'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['protocolUid'],
            ),
      timingOverrides: jsonSerialization['timingOverrides'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<List<_id5ke9r5.CalendarAvailabilityOpeningEdits>>(
                  jsonSerialization['timingOverrides'],
                ),
      content: _ix00hwbf.Protocol()
          .deserialize<_ifxxil5c.CalendarAvailabilityContent>(
            jsonSerialization['content'],
          ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarAvailabilityDataRecordTable();

  static const db = CalendarAvailabilityDataRecordRepository._();

  @override
  int? id;

  _is.UuidValue availabilityId;

  _is.UuidValue protocolUid;

  List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides;

  _ifxxil5c.CalendarAvailabilityContent content;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarAvailabilityDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAvailabilityDataRecord copyWith({
    int? id,
    _is.UuidValue? availabilityId,
    _is.UuidValue? protocolUid,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    _ifxxil5c.CalendarAvailabilityContent? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAvailabilityDataRecord',
      if (id != null) 'id': id,
      'availabilityId': availabilityId.toJson(),
      'protocolUid': protocolUid.toJson(),
      if (timingOverrides != null)
        'timingOverrides': timingOverrides?.toJson(
          valueToJson: (v) => v.toJson(),
        ),
      'content': content.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAvailabilityDataRecordInclude include() {
    return CalendarAvailabilityDataRecordInclude._();
  }

  static CalendarAvailabilityDataRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    CalendarAvailabilityDataRecordInclude? include,
  }) {
    return CalendarAvailabilityDataRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAvailabilityDataRecordImpl
    extends CalendarAvailabilityDataRecord {
  _CalendarAvailabilityDataRecordImpl({
    int? id,
    required _is.UuidValue availabilityId,
    _is.UuidValue? protocolUid,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? timingOverrides,
    required _ifxxil5c.CalendarAvailabilityContent content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         availabilityId: availabilityId,
         protocolUid: protocolUid,
         timingOverrides: timingOverrides,
         content: content,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAvailabilityDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAvailabilityDataRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? availabilityId,
    _is.UuidValue? protocolUid,
    Object? timingOverrides = _Undefined,
    _ifxxil5c.CalendarAvailabilityContent? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarAvailabilityDataRecord(
      id: id is int? ? id : this.id,
      availabilityId: availabilityId ?? this.availabilityId,
      protocolUid: protocolUid ?? this.protocolUid,
      timingOverrides:
          timingOverrides is List<_id5ke9r5.CalendarAvailabilityOpeningEdits>?
          ? timingOverrides
          : this.timingOverrides?.map((e0) => e0.copyWith()).toList(),
      content: content ?? this.content.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarAvailabilityDataRecordUpdateTable
    extends _is.UpdateTable<CalendarAvailabilityDataRecordTable> {
  CalendarAvailabilityDataRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> availabilityId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.availabilityId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> protocolUid(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>,
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>
  >
  timingOverrides(List<_id5ke9r5.CalendarAvailabilityOpeningEdits>? value) =>
      _is.ColumnValue(
        table.timingOverrides,
        value,
      );

  _is.ColumnValue<
    _ifxxil5c.CalendarAvailabilityContent,
    _ifxxil5c.CalendarAvailabilityContent
  >
  content(_ifxxil5c.CalendarAvailabilityContent value) => _is.ColumnValue(
    table.content,
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

class CalendarAvailabilityDataRecordTable extends _is.Table<int?> {
  CalendarAvailabilityDataRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_availability_data') {
    updateTable = CalendarAvailabilityDataRecordUpdateTable(this);
    availabilityId = _is.ColumnUuid(
      'availabilityId',
      this,
    );
    protocolUid = _is.ColumnUuid(
      'protocolUid',
      this,
      hasDefault: true,
    );
    timingOverrides =
        _is.ColumnSerializable<
          List<_id5ke9r5.CalendarAvailabilityOpeningEdits>
        >(
          'timingOverrides',
          this,
        );
    content = _is.ColumnSerializable<_ifxxil5c.CalendarAvailabilityContent>(
      'content',
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

  late final CalendarAvailabilityDataRecordUpdateTable updateTable;

  late final _is.ColumnUuid availabilityId;

  late final _is.ColumnUuid protocolUid;

  late final _is.ColumnSerializable<
    List<_id5ke9r5.CalendarAvailabilityOpeningEdits>
  >
  timingOverrides;

  late final _is.ColumnSerializable<_ifxxil5c.CalendarAvailabilityContent>
  content;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    availabilityId,
    protocolUid,
    timingOverrides,
    content,
    createdAt,
    updatedAt,
  ];
}

class CalendarAvailabilityDataRecordInclude extends _is.IncludeObject {
  CalendarAvailabilityDataRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarAvailabilityDataRecord.t;
}

class CalendarAvailabilityDataRecordIncludeList extends _is.IncludeList {
  CalendarAvailabilityDataRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAvailabilityDataRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarAvailabilityDataRecord.t;
}

class CalendarAvailabilityDataRecordRepository {
  const CalendarAvailabilityDataRecordRepository._();

  /// Returns a list of [CalendarAvailabilityDataRecord]s matching the given query parameters.
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
  Future<List<CalendarAvailabilityDataRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAvailabilityDataRecord>(
      where: where?.call(CalendarAvailabilityDataRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAvailabilityDataRecord] matching the given query parameters.
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
  Future<CalendarAvailabilityDataRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAvailabilityDataRecord>(
      where: where?.call(CalendarAvailabilityDataRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAvailabilityDataRecord] by its [id] or null if no such row exists.
  Future<CalendarAvailabilityDataRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAvailabilityDataRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAvailabilityDataRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAvailabilityDataRecord]s will have their `id` fields set.
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
  Future<List<CalendarAvailabilityDataRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAvailabilityDataRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAvailabilityDataRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAvailabilityDataRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAvailabilityDataRecord] will have its `id` field set.
  Future<CalendarAvailabilityDataRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAvailabilityDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAvailabilityDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAvailabilityDataRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAvailabilityDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityDataRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAvailabilityDataRecord> rows, {
    required _is.ColumnSelections<CalendarAvailabilityDataRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAvailabilityDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAvailabilityDataRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAvailabilityDataRecord.t),
      updateColumns: updateColumns?.call(CalendarAvailabilityDataRecord.t),
      updateWhere: updateWhere?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAvailabilityDataRecord] and returns the resulting row.
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
  /// The returned [CalendarAvailabilityDataRecord] will have its `id` field set.
  Future<CalendarAvailabilityDataRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAvailabilityDataRecord row, {
    required _is.ColumnSelections<CalendarAvailabilityDataRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAvailabilityDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAvailabilityDataRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAvailabilityDataRecord.t),
      updateColumns: updateColumns?.call(CalendarAvailabilityDataRecord.t),
      updateWhere: updateWhere?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAvailabilityDataRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityDataRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAvailabilityDataRecord> rows, {
    _is.ColumnSelections<CalendarAvailabilityDataRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAvailabilityDataRecord>(
      rows,
      columns: columns?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAvailabilityDataRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAvailabilityDataRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAvailabilityDataRecord row, {
    _is.ColumnSelections<CalendarAvailabilityDataRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAvailabilityDataRecord>(
      row,
      columns: columns?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAvailabilityDataRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAvailabilityDataRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<
      CalendarAvailabilityDataRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAvailabilityDataRecord>(
      id,
      columnValues: columnValues(CalendarAvailabilityDataRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAvailabilityDataRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAvailabilityDataRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarAvailabilityDataRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAvailabilityDataRecord>(
      columnValues: columnValues(CalendarAvailabilityDataRecord.t.updateTable),
      where: where(CalendarAvailabilityDataRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAvailabilityDataRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAvailabilityDataRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAvailabilityDataRecord> rows, {
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAvailabilityDataRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAvailabilityDataRecord].
  Future<CalendarAvailabilityDataRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAvailabilityDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAvailabilityDataRecord>(
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
  Future<List<CalendarAvailabilityDataRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>
    where,
    _is.OrderByBuilder<CalendarAvailabilityDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAvailabilityDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAvailabilityDataRecord>(
      where: where(CalendarAvailabilityDataRecord.t),
      orderBy: orderBy?.call(CalendarAvailabilityDataRecord.t),
      orderByList: orderByList?.call(CalendarAvailabilityDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAvailabilityDataRecord>(
      where: where?.call(CalendarAvailabilityDataRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAvailabilityDataRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAvailabilityDataRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAvailabilityDataRecord>(
      where: where(CalendarAvailabilityDataRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
