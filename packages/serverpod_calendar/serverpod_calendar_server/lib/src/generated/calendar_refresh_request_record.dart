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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;

abstract class CalendarRefreshRequestRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarRefreshRequestRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.namespace,
    required this.deliveryKey,
    required this.originReference,
    required this.sourceDigest,
    required this.attendeeAddress,
    required this.sourceStamp,
    required this.comments,
    required this.receivedAt,
    required this.expiresAt,
    this.dismissedAt,
  });

  factory CalendarRefreshRequestRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String namespace,
    required String deliveryKey,
    required String originReference,
    required String sourceDigest,
    required String attendeeAddress,
    required DateTime sourceStamp,
    required List<String> comments,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
  }) = _CalendarRefreshRequestRecordImpl;

  factory CalendarRefreshRequestRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarRefreshRequestRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      namespace: jsonSerialization['namespace'] as String,
      deliveryKey: jsonSerialization['deliveryKey'] as String,
      originReference: jsonSerialization['originReference'] as String,
      sourceDigest: jsonSerialization['sourceDigest'] as String,
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      comments: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['comments'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  static final t = CalendarRefreshRequestRecordTable();

  static const db = CalendarRefreshRequestRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  String namespace;

  String deliveryKey;

  String originReference;

  String sourceDigest;

  String attendeeAddress;

  DateTime sourceStamp;

  List<String> comments;

  DateTime receivedAt;

  DateTime expiresAt;

  DateTime? dismissedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarRefreshRequestRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarRefreshRequestRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? namespace,
    String? deliveryKey,
    String? originReference,
    String? sourceDigest,
    String? attendeeAddress,
    DateTime? sourceStamp,
    List<String>? comments,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshRequestRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'namespace': namespace,
      'deliveryKey': deliveryKey,
      'originReference': originReference,
      'sourceDigest': sourceDigest,
      'attendeeAddress': attendeeAddress,
      'sourceStamp': sourceStamp.toJson(),
      'comments': comments.toJson(),
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarRefreshRequestRecordInclude include() {
    return CalendarRefreshRequestRecordInclude._();
  }

  static CalendarRefreshRequestRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    CalendarRefreshRequestRecordInclude? include,
  }) {
    return CalendarRefreshRequestRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarRefreshRequestRecordImpl extends CalendarRefreshRequestRecord {
  _CalendarRefreshRequestRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String namespace,
    required String deliveryKey,
    required String originReference,
    required String sourceDigest,
    required String attendeeAddress,
    required DateTime sourceStamp,
    required List<String> comments,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         namespace: namespace,
         deliveryKey: deliveryKey,
         originReference: originReference,
         sourceDigest: sourceDigest,
         attendeeAddress: attendeeAddress,
         sourceStamp: sourceStamp,
         comments: comments,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarRefreshRequestRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarRefreshRequestRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? namespace,
    String? deliveryKey,
    String? originReference,
    String? sourceDigest,
    String? attendeeAddress,
    DateTime? sourceStamp,
    List<String>? comments,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarRefreshRequestRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      namespace: namespace ?? this.namespace,
      deliveryKey: deliveryKey ?? this.deliveryKey,
      originReference: originReference ?? this.originReference,
      sourceDigest: sourceDigest ?? this.sourceDigest,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      comments: comments ?? this.comments.map((e0) => e0).toList(),
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      dismissedAt: dismissedAt is _is.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
    );
  }
}

class CalendarRefreshRequestRecordUpdateTable
    extends _is.UpdateTable<CalendarRefreshRequestRecordTable> {
  CalendarRefreshRequestRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> meetingId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.meetingId,
    value,
  );

  _is.ColumnValue<String, String> namespace(String value) => _is.ColumnValue(
    table.namespace,
    value,
  );

  _is.ColumnValue<String, String> deliveryKey(String value) => _is.ColumnValue(
    table.deliveryKey,
    value,
  );

  _is.ColumnValue<String, String> originReference(String value) =>
      _is.ColumnValue(
        table.originReference,
        value,
      );

  _is.ColumnValue<String, String> sourceDigest(String value) => _is.ColumnValue(
    table.sourceDigest,
    value,
  );

  _is.ColumnValue<String, String> attendeeAddress(String value) =>
      _is.ColumnValue(
        table.attendeeAddress,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sourceStamp(DateTime value) =>
      _is.ColumnValue(
        table.sourceStamp,
        value,
      );

  _is.ColumnValue<List<String>, List<String>> comments(List<String> value) =>
      _is.ColumnValue(
        table.comments,
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

  _is.ColumnValue<DateTime, DateTime> dismissedAt(DateTime? value) =>
      _is.ColumnValue(
        table.dismissedAt,
        value,
      );
}

class CalendarRefreshRequestRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarRefreshRequestRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_refresh_request') {
    updateTable = CalendarRefreshRequestRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    meetingId = _is.ColumnUuid(
      'meetingId',
      this,
    );
    namespace = _is.ColumnString(
      'namespace',
      this,
    );
    deliveryKey = _is.ColumnString(
      'deliveryKey',
      this,
    );
    originReference = _is.ColumnString(
      'originReference',
      this,
    );
    sourceDigest = _is.ColumnString(
      'sourceDigest',
      this,
    );
    attendeeAddress = _is.ColumnString(
      'attendeeAddress',
      this,
    );
    sourceStamp = _is.ColumnDateTime(
      'sourceStamp',
      this,
    );
    comments = _is.ColumnSerializable<List<String>>(
      'comments',
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
    dismissedAt = _is.ColumnDateTime(
      'dismissedAt',
      this,
    );
  }

  late final CalendarRefreshRequestRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnString namespace;

  late final _is.ColumnString deliveryKey;

  late final _is.ColumnString originReference;

  late final _is.ColumnString sourceDigest;

  late final _is.ColumnString attendeeAddress;

  late final _is.ColumnDateTime sourceStamp;

  late final _is.ColumnSerializable<List<String>> comments;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime dismissedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    namespace,
    deliveryKey,
    originReference,
    sourceDigest,
    attendeeAddress,
    sourceStamp,
    comments,
    receivedAt,
    expiresAt,
    dismissedAt,
  ];
}

class CalendarRefreshRequestRecordInclude extends _is.IncludeObject {
  CalendarRefreshRequestRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarRefreshRequestRecord.t;
}

class CalendarRefreshRequestRecordIncludeList extends _is.IncludeList {
  CalendarRefreshRequestRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarRefreshRequestRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarRefreshRequestRecord.t;
}

class CalendarRefreshRequestRecordRepository {
  const CalendarRefreshRequestRecordRepository._();

  /// Returns a list of [CalendarRefreshRequestRecord]s matching the given query parameters.
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
  Future<List<CalendarRefreshRequestRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarRefreshRequestRecord>(
      where: where?.call(CalendarRefreshRequestRecord.t),
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarRefreshRequestRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarRefreshRequestRecord.t`.
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
  _ida.Stream<List<CalendarRefreshRequestRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarRefreshRequestRecord>(
      where: where?.call(CalendarRefreshRequestRecord.t),
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarRefreshRequestRecord] matching the given query parameters.
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
  Future<CalendarRefreshRequestRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarRefreshRequestRecord>(
      where: where?.call(CalendarRefreshRequestRecord.t),
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarRefreshRequestRecord] by its [id] or null if no such row exists.
  Future<CalendarRefreshRequestRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarRefreshRequestRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarRefreshRequestRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarRefreshRequestRecord]s will have their `id` fields set.
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
  Future<List<CalendarRefreshRequestRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarRefreshRequestRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarRefreshRequestRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarRefreshRequestRecord] and returns the inserted row.
  ///
  /// The returned [CalendarRefreshRequestRecord] will have its `id` field set.
  Future<CalendarRefreshRequestRecord> insertRow(
    _is.DatabaseSession session,
    CalendarRefreshRequestRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarRefreshRequestRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarRefreshRequestRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarRefreshRequestRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshRequestRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarRefreshRequestRecord> rows, {
    required _is.ColumnSelections<CalendarRefreshRequestRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarRefreshRequestRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarRefreshRequestRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarRefreshRequestRecord.t),
      updateColumns: updateColumns?.call(CalendarRefreshRequestRecord.t),
      updateWhere: updateWhere?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarRefreshRequestRecord] and returns the resulting row.
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
  /// The returned [CalendarRefreshRequestRecord] will have its `id` field set.
  Future<CalendarRefreshRequestRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarRefreshRequestRecord row, {
    required _is.ColumnSelections<CalendarRefreshRequestRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarRefreshRequestRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarRefreshRequestRecord>(
      row,
      conflictColumns: conflictColumns(CalendarRefreshRequestRecord.t),
      updateColumns: updateColumns?.call(CalendarRefreshRequestRecord.t),
      updateWhere: updateWhere?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarRefreshRequestRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshRequestRecord>> update(
    _is.DatabaseSession session,
    List<CalendarRefreshRequestRecord> rows, {
    _is.ColumnSelections<CalendarRefreshRequestRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarRefreshRequestRecord>(
      rows,
      columns: columns?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarRefreshRequestRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarRefreshRequestRecord> updateRow(
    _is.DatabaseSession session,
    CalendarRefreshRequestRecord row, {
    _is.ColumnSelections<CalendarRefreshRequestRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarRefreshRequestRecord>(
      row,
      columns: columns?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarRefreshRequestRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarRefreshRequestRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarRefreshRequestRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarRefreshRequestRecord>(
      id,
      columnValues: columnValues(CalendarRefreshRequestRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarRefreshRequestRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshRequestRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarRefreshRequestRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarRefreshRequestRecord>(
      columnValues: columnValues(CalendarRefreshRequestRecord.t.updateTable),
      where: where(CalendarRefreshRequestRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarRefreshRequestRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarRefreshRequestRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarRefreshRequestRecord> rows, {
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarRefreshRequestRecord>(
      rows,
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarRefreshRequestRecord].
  Future<CalendarRefreshRequestRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarRefreshRequestRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarRefreshRequestRecord>(
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
  Future<List<CalendarRefreshRequestRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>
    where,
    _is.OrderByBuilder<CalendarRefreshRequestRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshRequestRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarRefreshRequestRecord>(
      where: where(CalendarRefreshRequestRecord.t),
      orderBy: orderBy?.call(CalendarRefreshRequestRecord.t),
      orderByList: orderByList?.call(CalendarRefreshRequestRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarRefreshRequestRecord>(
      where: where?.call(CalendarRefreshRequestRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarRefreshRequestRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarRefreshRequestRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarRefreshRequestRecord>(
      where: where(CalendarRefreshRequestRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
