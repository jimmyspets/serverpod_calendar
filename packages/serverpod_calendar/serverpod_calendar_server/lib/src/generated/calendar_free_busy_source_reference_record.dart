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

abstract class CalendarFreeBusySourceReferenceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusySourceReferenceRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.commandId,
    required this.sourceKey,
    this.eventId,
    this.availabilityId,
    required this.revision,
    required this.contentDigest,
  });

  factory CalendarFreeBusySourceReferenceRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    required String sourceKey,
    _is.UuidValue? eventId,
    _is.UuidValue? availabilityId,
    required int revision,
    required String contentDigest,
  }) = _CalendarFreeBusySourceReferenceRecordImpl;

  factory CalendarFreeBusySourceReferenceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusySourceReferenceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      sourceKey: jsonSerialization['sourceKey'] as String,
      eventId: jsonSerialization['eventId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['eventId']),
      availabilityId: jsonSerialization['availabilityId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['availabilityId'],
            ),
      revision: jsonSerialization['revision'] as int,
      contentDigest: jsonSerialization['contentDigest'] as String,
    );
  }

  static final t = CalendarFreeBusySourceReferenceRecordTable();

  static const db = CalendarFreeBusySourceReferenceRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  _is.UuidValue commandId;

  String sourceKey;

  _is.UuidValue? eventId;

  _is.UuidValue? availabilityId;

  int revision;

  String contentDigest;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusySourceReferenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusySourceReferenceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    String? sourceKey,
    _is.UuidValue? eventId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? availabilityId = const _is.$UndefinedUuidValue(),
    int? revision,
    String? contentDigest,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarFreeBusySourceReferenceRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'commandId': commandId.toJson(),
      'sourceKey': sourceKey,
      if (eventId != null) 'eventId': eventId?.toJson(),
      if (availabilityId != null) 'availabilityId': availabilityId?.toJson(),
      'revision': revision,
      'contentDigest': contentDigest,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusySourceReferenceRecordInclude include() {
    return CalendarFreeBusySourceReferenceRecordInclude._();
  }

  static CalendarFreeBusySourceReferenceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    CalendarFreeBusySourceReferenceRecordInclude? include,
  }) {
    return CalendarFreeBusySourceReferenceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarFreeBusySourceReferenceRecordImpl
    extends CalendarFreeBusySourceReferenceRecord {
  _CalendarFreeBusySourceReferenceRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    required String sourceKey,
    _is.UuidValue? eventId,
    _is.UuidValue? availabilityId,
    required int revision,
    required String contentDigest,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         commandId: commandId,
         sourceKey: sourceKey,
         eventId: eventId,
         availabilityId: availabilityId,
         revision: revision,
         contentDigest: contentDigest,
       );

  /// Returns a shallow copy of this [CalendarFreeBusySourceReferenceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusySourceReferenceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    String? sourceKey,
    _is.UuidValue? eventId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? availabilityId = const _is.$UndefinedUuidValue(),
    int? revision,
    String? contentDigest,
  }) {
    return CalendarFreeBusySourceReferenceRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      commandId: commandId ?? this.commandId,
      sourceKey: sourceKey ?? this.sourceKey,
      eventId: eventId is _is.UndefinedSentinel ? this.eventId : eventId,
      availabilityId: availabilityId is _is.UndefinedSentinel
          ? this.availabilityId
          : availabilityId,
      revision: revision ?? this.revision,
      contentDigest: contentDigest ?? this.contentDigest,
    );
  }
}

class CalendarFreeBusySourceReferenceRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusySourceReferenceRecordTable> {
  CalendarFreeBusySourceReferenceRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> ownerKey(String value) => _is.ColumnValue(
    table.ownerKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> commandId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.commandId,
    value,
  );

  _is.ColumnValue<String, String> sourceKey(String value) => _is.ColumnValue(
    table.sourceKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> eventId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.eventId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> availabilityId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.availabilityId,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<String, String> contentDigest(String value) =>
      _is.ColumnValue(
        table.contentDigest,
        value,
      );
}

class CalendarFreeBusySourceReferenceRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusySourceReferenceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_source_ref') {
    updateTable = CalendarFreeBusySourceReferenceRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    ownerKey = _is.ColumnString(
      'ownerKey',
      this,
    );
    commandId = _is.ColumnUuid(
      'commandId',
      this,
    );
    sourceKey = _is.ColumnString(
      'sourceKey',
      this,
    );
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    availabilityId = _is.ColumnUuid(
      'availabilityId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    contentDigest = _is.ColumnString(
      'contentDigest',
      this,
    );
  }

  late final CalendarFreeBusySourceReferenceRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString sourceKey;

  late final _is.ColumnUuid eventId;

  late final _is.ColumnUuid availabilityId;

  late final _is.ColumnInt revision;

  late final _is.ColumnString contentDigest;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    commandId,
    sourceKey,
    eventId,
    availabilityId,
    revision,
    contentDigest,
  ];
}

class CalendarFreeBusySourceReferenceRecordInclude extends _is.IncludeObject {
  CalendarFreeBusySourceReferenceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarFreeBusySourceReferenceRecord.t;
}

class CalendarFreeBusySourceReferenceRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusySourceReferenceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusySourceReferenceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarFreeBusySourceReferenceRecord.t;
}

class CalendarFreeBusySourceReferenceRecordRepository {
  const CalendarFreeBusySourceReferenceRecordRepository._();

  /// Returns a list of [CalendarFreeBusySourceReferenceRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusySourceReferenceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusySourceReferenceRecord>(
      where: where?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusySourceReferenceRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusySourceReferenceRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusySourceReferenceRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusySourceReferenceRecord>(
      where: where?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusySourceReferenceRecord] matching the given query parameters.
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
  Future<CalendarFreeBusySourceReferenceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusySourceReferenceRecord>(
      where: where?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusySourceReferenceRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusySourceReferenceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusySourceReferenceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusySourceReferenceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusySourceReferenceRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusySourceReferenceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceReferenceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusySourceReferenceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusySourceReferenceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusySourceReferenceRecord] will have its `id` field set.
  Future<CalendarFreeBusySourceReferenceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceReferenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusySourceReferenceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusySourceReferenceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusySourceReferenceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceReferenceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceReferenceRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusySourceReferenceRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusySourceReferenceRecord.t),
      updateColumns: updateColumns?.call(
        CalendarFreeBusySourceReferenceRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusySourceReferenceRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusySourceReferenceRecord] will have its `id` field set.
  Future<CalendarFreeBusySourceReferenceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceReferenceRecord row, {
    required _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusySourceReferenceRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusySourceReferenceRecord.t),
      updateColumns: updateColumns?.call(
        CalendarFreeBusySourceReferenceRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusySourceReferenceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceReferenceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceReferenceRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusySourceReferenceRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusySourceReferenceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusySourceReferenceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceReferenceRecord row, {
    _is.ColumnSelections<CalendarFreeBusySourceReferenceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusySourceReferenceRecord>(
      row,
      columns: columns?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusySourceReferenceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusySourceReferenceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusySourceReferenceRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusySourceReferenceRecord>(
      id,
      columnValues: columnValues(
        CalendarFreeBusySourceReferenceRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusySourceReferenceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceReferenceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusySourceReferenceRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarFreeBusySourceReferenceRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusySourceReferenceRecord>(
      columnValues: columnValues(
        CalendarFreeBusySourceReferenceRecord.t.updateTable,
      ),
      where: where(CalendarFreeBusySourceReferenceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusySourceReferenceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusySourceReferenceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceReferenceRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusySourceReferenceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusySourceReferenceRecord].
  Future<CalendarFreeBusySourceReferenceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceReferenceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusySourceReferenceRecord>(
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
  Future<List<CalendarFreeBusySourceReferenceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarFreeBusySourceReferenceRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarFreeBusySourceReferenceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusySourceReferenceRecord>(
      where: where(CalendarFreeBusySourceReferenceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceReferenceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceReferenceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceReferenceRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusySourceReferenceRecord>(
      where: where?.call(CalendarFreeBusySourceReferenceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusySourceReferenceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarFreeBusySourceReferenceRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusySourceReferenceRecord>(
      where: where(CalendarFreeBusySourceReferenceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
