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
import 'calendar_alarm_definition.dart' as _irif99jb;
import 'calendar_alarm_parent_kind.dart' as _ig3zti62;

abstract class CalendarAlarmRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAlarmRecord._({
    this.id,
    required this.scopeKey,
    required this.calendarId,
    required this.parentKind,
    required this.parentId,
    required this.recipientNamespace,
    required this.recipientKey,
    required this.revision,
    required this.definition,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarAlarmRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue calendarId,
    required _ig3zti62.CalendarAlarmParentKind parentKind,
    required _is.UuidValue parentId,
    required String recipientNamespace,
    required String recipientKey,
    required int revision,
    required _irif99jb.CalendarAlarmDefinition definition,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarAlarmRecordImpl;

  factory CalendarAlarmRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarAlarmRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      parentKind: _ig3zti62.CalendarAlarmParentKind.fromJson(
        (jsonSerialization['parentKind'] as String),
      ),
      parentId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['parentId'],
      ),
      recipientNamespace: jsonSerialization['recipientNamespace'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      revision: jsonSerialization['revision'] as int,
      definition: _ix00hwbf.Protocol()
          .deserialize<_irif99jb.CalendarAlarmDefinition>(
            jsonSerialization['definition'],
          ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarAlarmRecordTable();

  static const db = CalendarAlarmRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue calendarId;

  _ig3zti62.CalendarAlarmParentKind parentKind;

  _is.UuidValue parentId;

  String recipientNamespace;

  String recipientKey;

  int revision;

  _irif99jb.CalendarAlarmDefinition definition;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAlarmRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? calendarId,
    _ig3zti62.CalendarAlarmParentKind? parentKind,
    _is.UuidValue? parentId,
    String? recipientNamespace,
    String? recipientKey,
    int? revision,
    _irif99jb.CalendarAlarmDefinition? definition,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'calendarId': calendarId.toJson(),
      'parentKind': parentKind.toJson(),
      'parentId': parentId.toJson(),
      'recipientNamespace': recipientNamespace,
      'recipientKey': recipientKey,
      'revision': revision,
      'definition': definition.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAlarmRecordInclude include() {
    return CalendarAlarmRecordInclude._();
  }

  static CalendarAlarmRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    CalendarAlarmRecordInclude? include,
  }) {
    return CalendarAlarmRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmRecordImpl extends CalendarAlarmRecord {
  _CalendarAlarmRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue calendarId,
    required _ig3zti62.CalendarAlarmParentKind parentKind,
    required _is.UuidValue parentId,
    required String recipientNamespace,
    required String recipientKey,
    required int revision,
    required _irif99jb.CalendarAlarmDefinition definition,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         calendarId: calendarId,
         parentKind: parentKind,
         parentId: parentId,
         recipientNamespace: recipientNamespace,
         recipientKey: recipientKey,
         revision: revision,
         definition: definition,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? calendarId,
    _ig3zti62.CalendarAlarmParentKind? parentKind,
    _is.UuidValue? parentId,
    String? recipientNamespace,
    String? recipientKey,
    int? revision,
    _irif99jb.CalendarAlarmDefinition? definition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarAlarmRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      calendarId: calendarId ?? this.calendarId,
      parentKind: parentKind ?? this.parentKind,
      parentId: parentId ?? this.parentId,
      recipientNamespace: recipientNamespace ?? this.recipientNamespace,
      recipientKey: recipientKey ?? this.recipientKey,
      revision: revision ?? this.revision,
      definition: definition ?? this.definition.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarAlarmRecordUpdateTable
    extends _is.UpdateTable<CalendarAlarmRecordTable> {
  CalendarAlarmRecordUpdateTable(super.table);

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

  _is.ColumnValue<
    _ig3zti62.CalendarAlarmParentKind,
    _ig3zti62.CalendarAlarmParentKind
  >
  parentKind(_ig3zti62.CalendarAlarmParentKind value) => _is.ColumnValue(
    table.parentKind,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> parentId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.parentId,
        value,
      );

  _is.ColumnValue<String, String> recipientNamespace(String value) =>
      _is.ColumnValue(
        table.recipientNamespace,
        value,
      );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<
    _irif99jb.CalendarAlarmDefinition,
    _irif99jb.CalendarAlarmDefinition
  >
  definition(_irif99jb.CalendarAlarmDefinition value) => _is.ColumnValue(
    table.definition,
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

class CalendarAlarmRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAlarmRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_alarm') {
    updateTable = CalendarAlarmRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    parentKind = _is.ColumnEnum(
      'parentKind',
      this,
      _is.EnumSerialization.byName,
    );
    parentId = _is.ColumnUuid(
      'parentId',
      this,
    );
    recipientNamespace = _is.ColumnString(
      'recipientNamespace',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    definition = _is.ColumnSerializable<_irif99jb.CalendarAlarmDefinition>(
      'definition',
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

  late final CalendarAlarmRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnEnum<_ig3zti62.CalendarAlarmParentKind> parentKind;

  late final _is.ColumnUuid parentId;

  late final _is.ColumnString recipientNamespace;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnInt revision;

  late final _is.ColumnSerializable<_irif99jb.CalendarAlarmDefinition>
  definition;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    calendarId,
    parentKind,
    parentId,
    recipientNamespace,
    recipientKey,
    revision,
    definition,
    createdAt,
    updatedAt,
  ];
}

class CalendarAlarmRecordInclude extends _is.IncludeObject {
  CalendarAlarmRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmRecord.t;
}

class CalendarAlarmRecordIncludeList extends _is.IncludeList {
  CalendarAlarmRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAlarmRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmRecord.t;
}

class CalendarAlarmRecordRepository {
  const CalendarAlarmRecordRepository._();

  /// Returns a list of [CalendarAlarmRecord]s matching the given query parameters.
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
  Future<List<CalendarAlarmRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAlarmRecord>(
      where: where?.call(CalendarAlarmRecord.t),
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAlarmRecord] matching the given query parameters.
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
  Future<CalendarAlarmRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAlarmRecord>(
      where: where?.call(CalendarAlarmRecord.t),
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAlarmRecord] by its [id] or null if no such row exists.
  Future<CalendarAlarmRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAlarmRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAlarmRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAlarmRecord]s will have their `id` fields set.
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
  Future<List<CalendarAlarmRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAlarmRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAlarmRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAlarmRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAlarmRecord] will have its `id` field set.
  Future<CalendarAlarmRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAlarmRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAlarmRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAlarmRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAlarmRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAlarmRecord> rows, {
    required _is.ColumnSelections<CalendarAlarmRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarAlarmRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAlarmRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAlarmRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAlarmRecord] and returns the resulting row.
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
  /// The returned [CalendarAlarmRecord] will have its `id` field set.
  Future<CalendarAlarmRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAlarmRecord row, {
    required _is.ColumnSelections<CalendarAlarmRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarAlarmRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAlarmRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAlarmRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAlarmRecord> rows, {
    _is.ColumnSelections<CalendarAlarmRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAlarmRecord>(
      rows,
      columns: columns?.call(CalendarAlarmRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAlarmRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAlarmRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAlarmRecord row, {
    _is.ColumnSelections<CalendarAlarmRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAlarmRecord>(
      row,
      columns: columns?.call(CalendarAlarmRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAlarmRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAlarmRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarAlarmRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAlarmRecord>(
      id,
      columnValues: columnValues(CalendarAlarmRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarAlarmRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAlarmRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAlarmRecord>(
      columnValues: columnValues(CalendarAlarmRecord.t.updateTable),
      where: where(CalendarAlarmRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAlarmRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAlarmRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAlarmRecord> rows, {
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAlarmRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAlarmRecord].
  Future<CalendarAlarmRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAlarmRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAlarmRecord>(
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
  Future<List<CalendarAlarmRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmRecordTable> where,
    _is.OrderByBuilder<CalendarAlarmRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAlarmRecord>(
      where: where(CalendarAlarmRecord.t),
      orderBy: orderBy?.call(CalendarAlarmRecord.t),
      orderByList: orderByList?.call(CalendarAlarmRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAlarmRecord>(
      where: where?.call(CalendarAlarmRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAlarmRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAlarmRecord>(
      where: where(CalendarAlarmRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
