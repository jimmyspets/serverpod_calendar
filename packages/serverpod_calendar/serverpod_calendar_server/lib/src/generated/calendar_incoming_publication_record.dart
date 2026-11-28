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

import 'calendar_incoming_publication_kind.dart' as _ing1vpo7;

abstract class CalendarIncomingPublicationRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarIncomingPublicationRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.correlationDigest,
    required this.uid,
    required this.organizer,
    required this.recurring,
    required this.revision,
    required this.currentSourceId,
    required this.kind,
    this.sequence,
    required this.stamp,
    required this.digest,
    required this.createdAt,
    required this.updatedAt,
    this.dismissedAt,
  });

  factory CalendarIncomingPublicationRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required String uid,
    required String organizer,
    required bool recurring,
    required int revision,
    required _is.UuidValue currentSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dismissedAt,
  }) = _CalendarIncomingPublicationRecordImpl;

  factory CalendarIncomingPublicationRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      uid: jsonSerialization['uid'] as String,
      organizer: jsonSerialization['organizer'] as String,
      recurring: _is.BoolJsonExtension.fromJson(jsonSerialization['recurring']),
      revision: jsonSerialization['revision'] as int,
      currentSourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['currentSourceId'],
      ),
      kind: _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      digest: jsonSerialization['digest'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  static final t = CalendarIncomingPublicationRecordTable();

  static const db = CalendarIncomingPublicationRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  String correlationDigest;

  String uid;

  String organizer;

  bool recurring;

  int revision;

  _is.UuidValue currentSourceId;

  _ing1vpo7.CalendarIncomingPublicationKind kind;

  int? sequence;

  DateTime stamp;

  String digest;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? dismissedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarIncomingPublicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    String? uid,
    String? organizer,
    bool? recurring,
    int? revision,
    _is.UuidValue? currentSourceId,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    int? sequence,
    DateTime? stamp,
    String? digest,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarIncomingPublicationRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'correlationDigest': correlationDigest,
      'uid': uid,
      'organizer': organizer,
      'recurring': recurring,
      'revision': revision,
      'currentSourceId': currentSourceId.toJson(),
      'kind': kind.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'digest': digest,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarIncomingPublicationRecordInclude include() {
    return CalendarIncomingPublicationRecordInclude._();
  }

  static CalendarIncomingPublicationRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    CalendarIncomingPublicationRecordInclude? include,
  }) {
    return CalendarIncomingPublicationRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationRecordImpl
    extends CalendarIncomingPublicationRecord {
  _CalendarIncomingPublicationRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required String uid,
    required String organizer,
    required bool recurring,
    required int revision,
    required _is.UuidValue currentSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         correlationDigest: correlationDigest,
         uid: uid,
         organizer: organizer,
         recurring: recurring,
         revision: revision,
         currentSourceId: currentSourceId,
         kind: kind,
         sequence: sequence,
         stamp: stamp,
         digest: digest,
         createdAt: createdAt,
         updatedAt: updatedAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    String? uid,
    String? organizer,
    bool? recurring,
    int? revision,
    _is.UuidValue? currentSourceId,
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    Object? sequence = _Undefined,
    DateTime? stamp,
    String? digest,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarIncomingPublicationRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      uid: uid ?? this.uid,
      organizer: organizer ?? this.organizer,
      recurring: recurring ?? this.recurring,
      revision: revision ?? this.revision,
      currentSourceId: currentSourceId ?? this.currentSourceId,
      kind: kind ?? this.kind,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      digest: digest ?? this.digest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dismissedAt: dismissedAt is _is.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
    );
  }
}

class CalendarIncomingPublicationRecordUpdateTable
    extends _is.UpdateTable<CalendarIncomingPublicationRecordTable> {
  CalendarIncomingPublicationRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> uid(String value) => _is.ColumnValue(
    table.uid,
    value,
  );

  _is.ColumnValue<String, String> organizer(String value) => _is.ColumnValue(
    table.organizer,
    value,
  );

  _is.ColumnValue<bool, bool> recurring(bool value) => _is.ColumnValue(
    table.recurring,
    value,
  );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> currentSourceId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.currentSourceId,
    value,
  );

  _is.ColumnValue<
    _ing1vpo7.CalendarIncomingPublicationKind,
    _ing1vpo7.CalendarIncomingPublicationKind
  >
  kind(_ing1vpo7.CalendarIncomingPublicationKind value) => _is.ColumnValue(
    table.kind,
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

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
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

  _is.ColumnValue<DateTime, DateTime> dismissedAt(DateTime? value) =>
      _is.ColumnValue(
        table.dismissedAt,
        value,
      );
}

class CalendarIncomingPublicationRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarIncomingPublicationRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_incoming_publication') {
    updateTable = CalendarIncomingPublicationRecordUpdateTable(this);
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
    uid = _is.ColumnString(
      'uid',
      this,
    );
    organizer = _is.ColumnString(
      'organizer',
      this,
    );
    recurring = _is.ColumnBool(
      'recurring',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    currentSourceId = _is.ColumnUuid(
      'currentSourceId',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
      this,
    );
    digest = _is.ColumnString(
      'digest',
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
    dismissedAt = _is.ColumnDateTime(
      'dismissedAt',
      this,
    );
  }

  late final CalendarIncomingPublicationRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnString uid;

  late final _is.ColumnString organizer;

  late final _is.ColumnBool recurring;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid currentSourceId;

  late final _is.ColumnEnum<_ing1vpo7.CalendarIncomingPublicationKind> kind;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString digest;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime dismissedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    correlationDigest,
    uid,
    organizer,
    recurring,
    revision,
    currentSourceId,
    kind,
    sequence,
    stamp,
    digest,
    createdAt,
    updatedAt,
    dismissedAt,
  ];
}

class CalendarIncomingPublicationRecordInclude extends _is.IncludeObject {
  CalendarIncomingPublicationRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarIncomingPublicationRecord.t;
}

class CalendarIncomingPublicationRecordIncludeList extends _is.IncludeList {
  CalendarIncomingPublicationRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarIncomingPublicationRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarIncomingPublicationRecord.t;
}

class CalendarIncomingPublicationRecordRepository {
  const CalendarIncomingPublicationRecordRepository._();

  /// Returns a list of [CalendarIncomingPublicationRecord]s matching the given query parameters.
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
  Future<List<CalendarIncomingPublicationRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarIncomingPublicationRecord>(
      where: where?.call(CalendarIncomingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarIncomingPublicationRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarIncomingPublicationRecord.t`.
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
  _ida.Stream<List<CalendarIncomingPublicationRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarIncomingPublicationRecord>(
      where: where?.call(CalendarIncomingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarIncomingPublicationRecord] matching the given query parameters.
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
  Future<CalendarIncomingPublicationRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarIncomingPublicationRecord>(
      where: where?.call(CalendarIncomingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarIncomingPublicationRecord] by its [id] or null if no such row exists.
  Future<CalendarIncomingPublicationRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarIncomingPublicationRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarIncomingPublicationRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarIncomingPublicationRecord]s will have their `id` fields set.
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
  Future<List<CalendarIncomingPublicationRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarIncomingPublicationRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarIncomingPublicationRecord] and returns the inserted row.
  ///
  /// The returned [CalendarIncomingPublicationRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationRecord> insertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarIncomingPublicationRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarIncomingPublicationRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarIncomingPublicationRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationRecord> rows, {
    required _is.ColumnSelections<CalendarIncomingPublicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarIncomingPublicationRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarIncomingPublicationRecord.t),
      updateColumns: updateColumns?.call(CalendarIncomingPublicationRecord.t),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarIncomingPublicationRecord] and returns the resulting row.
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
  /// The returned [CalendarIncomingPublicationRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationRecord row, {
    required _is.ColumnSelections<CalendarIncomingPublicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarIncomingPublicationRecord>(
      row,
      conflictColumns: conflictColumns(CalendarIncomingPublicationRecord.t),
      updateColumns: updateColumns?.call(CalendarIncomingPublicationRecord.t),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationRecord>> update(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationRecord> rows, {
    _is.ColumnSelections<CalendarIncomingPublicationRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarIncomingPublicationRecord>(
      rows,
      columns: columns?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarIncomingPublicationRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarIncomingPublicationRecord> updateRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationRecord row, {
    _is.ColumnSelections<CalendarIncomingPublicationRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarIncomingPublicationRecord>(
      row,
      columns: columns?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarIncomingPublicationRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarIncomingPublicationRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarIncomingPublicationRecord>(
      id,
      columnValues: columnValues(
        CalendarIncomingPublicationRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarIncomingPublicationRecord>(
      columnValues: columnValues(
        CalendarIncomingPublicationRecord.t.updateTable,
      ),
      where: where(CalendarIncomingPublicationRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarIncomingPublicationRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarIncomingPublicationRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationRecord> rows, {
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarIncomingPublicationRecord>(
      rows,
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarIncomingPublicationRecord].
  Future<CalendarIncomingPublicationRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarIncomingPublicationRecord>(
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
  Future<List<CalendarIncomingPublicationRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>
    where,
    _is.OrderByBuilder<CalendarIncomingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarIncomingPublicationRecord>(
      where: where(CalendarIncomingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarIncomingPublicationRecord>(
      where: where?.call(CalendarIncomingPublicationRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarIncomingPublicationRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarIncomingPublicationRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarIncomingPublicationRecord>(
      where: where(CalendarIncomingPublicationRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
