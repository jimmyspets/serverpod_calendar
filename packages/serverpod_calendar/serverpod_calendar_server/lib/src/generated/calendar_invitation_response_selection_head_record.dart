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

abstract class CalendarInvitationResponseSelectionHeadRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseSelectionHeadRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.correlationDigest,
    required this.masterEntryId,
    required this.revision,
    this.currentEvidenceId,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    this.inactiveAt,
    this.purgedAt,
  });

  factory CalendarInvitationResponseSelectionHeadRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required _is.UuidValue masterEntryId,
    required int revision,
    _is.UuidValue? currentEvidenceId,
    required String state,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? inactiveAt,
    DateTime? purgedAt,
  }) = _CalendarInvitationResponseSelectionHeadRecordImpl;

  factory CalendarInvitationResponseSelectionHeadRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseSelectionHeadRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      masterEntryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['masterEntryId'],
      ),
      revision: jsonSerialization['revision'] as int,
      currentEvidenceId: jsonSerialization['currentEvidenceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentEvidenceId'],
            ),
      state: jsonSerialization['state'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      inactiveAt: jsonSerialization['inactiveAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['inactiveAt']),
      purgedAt: jsonSerialization['purgedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['purgedAt']),
    );
  }

  static final t = CalendarInvitationResponseSelectionHeadRecordTable();

  static const db = CalendarInvitationResponseSelectionHeadRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  String correlationDigest;

  _is.UuidValue masterEntryId;

  int revision;

  _is.UuidValue? currentEvidenceId;

  String state;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? inactiveAt;

  DateTime? purgedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionHeadRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseSelectionHeadRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    _is.UuidValue? masterEntryId,
    int? revision,
    _is.UuidValue? currentEvidenceId = const _is.$UndefinedUuidValue(),
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? inactiveAt = const _is.$UndefinedDateTime(),
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationResponseSelectionHeadRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'correlationDigest': correlationDigest,
      'masterEntryId': masterEntryId.toJson(),
      'revision': revision,
      if (currentEvidenceId != null)
        'currentEvidenceId': currentEvidenceId?.toJson(),
      'state': state,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (inactiveAt != null) 'inactiveAt': inactiveAt?.toJson(),
      if (purgedAt != null) 'purgedAt': purgedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationResponseSelectionHeadRecordInclude include() {
    return CalendarInvitationResponseSelectionHeadRecordInclude._();
  }

  static CalendarInvitationResponseSelectionHeadRecordIncludeList includeList({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    CalendarInvitationResponseSelectionHeadRecordInclude? include,
  }) {
    return CalendarInvitationResponseSelectionHeadRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CalendarInvitationResponseSelectionHeadRecordImpl
    extends CalendarInvitationResponseSelectionHeadRecord {
  _CalendarInvitationResponseSelectionHeadRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required _is.UuidValue masterEntryId,
    required int revision,
    _is.UuidValue? currentEvidenceId,
    required String state,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? inactiveAt,
    DateTime? purgedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         correlationDigest: correlationDigest,
         masterEntryId: masterEntryId,
         revision: revision,
         currentEvidenceId: currentEvidenceId,
         state: state,
         createdAt: createdAt,
         updatedAt: updatedAt,
         inactiveAt: inactiveAt,
         purgedAt: purgedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseSelectionHeadRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseSelectionHeadRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    _is.UuidValue? masterEntryId,
    int? revision,
    _is.UuidValue? currentEvidenceId = const _is.$UndefinedUuidValue(),
    String? state,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? inactiveAt = const _is.$UndefinedDateTime(),
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarInvitationResponseSelectionHeadRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      masterEntryId: masterEntryId ?? this.masterEntryId,
      revision: revision ?? this.revision,
      currentEvidenceId: currentEvidenceId is _is.UndefinedSentinel
          ? this.currentEvidenceId
          : currentEvidenceId,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      inactiveAt: inactiveAt is _is.UndefinedSentinel
          ? this.inactiveAt
          : inactiveAt,
      purgedAt: purgedAt is _is.UndefinedSentinel ? this.purgedAt : purgedAt,
    );
  }
}

class CalendarInvitationResponseSelectionHeadRecordUpdateTable
    extends
        _is.UpdateTable<CalendarInvitationResponseSelectionHeadRecordTable> {
  CalendarInvitationResponseSelectionHeadRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<String, String> correlationDigest(String value) =>
      _is.ColumnValue(
        table.correlationDigest,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> masterEntryId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.masterEntryId,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> currentEvidenceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.currentEvidenceId,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
    table.state,
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

  _is.ColumnValue<DateTime, DateTime> inactiveAt(DateTime? value) =>
      _is.ColumnValue(
        table.inactiveAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> purgedAt(DateTime? value) =>
      _is.ColumnValue(
        table.purgedAt,
        value,
      );
}

class CalendarInvitationResponseSelectionHeadRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseSelectionHeadRecordTable({super.tableRelation})
    : super(tableName: 'calendar_inv_response_selection_head') {
    updateTable = CalendarInvitationResponseSelectionHeadRecordUpdateTable(
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
    correlationDigest = _is.ColumnString(
      'correlationDigest',
      this,
    );
    masterEntryId = _is.ColumnUuid(
      'masterEntryId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    currentEvidenceId = _is.ColumnUuid(
      'currentEvidenceId',
      this,
    );
    state = _is.ColumnString(
      'state',
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
    inactiveAt = _is.ColumnDateTime(
      'inactiveAt',
      this,
    );
    purgedAt = _is.ColumnDateTime(
      'purgedAt',
      this,
    );
  }

  late final CalendarInvitationResponseSelectionHeadRecordUpdateTable
  updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnUuid masterEntryId;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid currentEvidenceId;

  late final _is.ColumnString state;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime inactiveAt;

  late final _is.ColumnDateTime purgedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    correlationDigest,
    masterEntryId,
    revision,
    currentEvidenceId,
    state,
    createdAt,
    updatedAt,
    inactiveAt,
    purgedAt,
  ];
}

class CalendarInvitationResponseSelectionHeadRecordInclude
    extends _is.IncludeObject {
  CalendarInvitationResponseSelectionHeadRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionHeadRecord.t;
}

class CalendarInvitationResponseSelectionHeadRecordIncludeList
    extends _is.IncludeList {
  CalendarInvitationResponseSelectionHeadRecordIncludeList._({
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationResponseSelectionHeadRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseSelectionHeadRecord.t;
}

class CalendarInvitationResponseSelectionHeadRecordRepository {
  const CalendarInvitationResponseSelectionHeadRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseSelectionHeadRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseSelectionHeadRecord>(
      where: where?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarInvitationResponseSelectionHeadRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarInvitationResponseSelectionHeadRecord.t`.
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
  _ida.Stream<List<CalendarInvitationResponseSelectionHeadRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarInvitationResponseSelectionHeadRecord>(
      where: where?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseSelectionHeadRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseSelectionHeadRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db
        .findFirstRow<CalendarInvitationResponseSelectionHeadRecord>(
          where: where?.call(CalendarInvitationResponseSelectionHeadRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
          ),
          offset: offset,
          transaction: transaction,
          lockMode: lockMode,
          lockBehavior: lockBehavior,
        );
  }

  /// Finds a single [CalendarInvitationResponseSelectionHeadRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseSelectionHeadRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationResponseSelectionHeadRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationResponseSelectionHeadRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseSelectionHeadRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionHeadRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationResponseSelectionHeadRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationResponseSelectionHeadRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseSelectionHeadRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionHeadRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionHeadRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationResponseSelectionHeadRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationResponseSelectionHeadRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseSelectionHeadRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionHeadRecord> rows, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionHeadRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseSelectionHeadRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationResponseSelectionHeadRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationResponseSelectionHeadRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseSelectionHeadRecord] will have its `id` field set.
  Future<CalendarInvitationResponseSelectionHeadRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionHeadRecord row, {
    required _is.ColumnSelections<
      CalendarInvitationResponseSelectionHeadRecordTable
    >
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseSelectionHeadRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationResponseSelectionHeadRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseSelectionHeadRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionHeadRecord> rows, {
    _is.ColumnSelections<CalendarInvitationResponseSelectionHeadRecordTable>?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationResponseSelectionHeadRecord>(
      rows,
      columns: columns?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationResponseSelectionHeadRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseSelectionHeadRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionHeadRecord row, {
    _is.ColumnSelections<CalendarInvitationResponseSelectionHeadRecordTable>?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationResponseSelectionHeadRecord>(
      row,
      columns: columns?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationResponseSelectionHeadRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseSelectionHeadRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionHeadRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationResponseSelectionHeadRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationResponseSelectionHeadRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseSelectionHeadRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseSelectionHeadRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .updateWhere<CalendarInvitationResponseSelectionHeadRecord>(
          columnValues: columnValues(
            CalendarInvitationResponseSelectionHeadRecord.t.updateTable,
          ),
          where: where(CalendarInvitationResponseSelectionHeadRecord.t),
          limit: limit,
          offset: offset,
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
          ),
          transaction: transaction,
          noReturn: noReturn,
        );
  }

  /// Deletes all [CalendarInvitationResponseSelectionHeadRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseSelectionHeadRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationResponseSelectionHeadRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      orderByList: orderByList?.call(
        CalendarInvitationResponseSelectionHeadRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationResponseSelectionHeadRecord].
  Future<CalendarInvitationResponseSelectionHeadRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseSelectionHeadRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationResponseSelectionHeadRecord>(
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
  Future<List<CalendarInvitationResponseSelectionHeadRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseSelectionHeadRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db
        .deleteWhere<CalendarInvitationResponseSelectionHeadRecord>(
          where: where(CalendarInvitationResponseSelectionHeadRecord.t),
          orderBy: orderBy?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
          ),
          orderByList: orderByList?.call(
            CalendarInvitationResponseSelectionHeadRecord.t,
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
      CalendarInvitationResponseSelectionHeadRecordTable
    >?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseSelectionHeadRecord>(
      where: where?.call(CalendarInvitationResponseSelectionHeadRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseSelectionHeadRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseSelectionHeadRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationResponseSelectionHeadRecord>(
      where: where(CalendarInvitationResponseSelectionHeadRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
