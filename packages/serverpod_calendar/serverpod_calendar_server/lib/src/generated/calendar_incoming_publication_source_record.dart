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
import 'calendar_incoming_publication_outcome.dart' as _ireg3hht;

abstract class CalendarIncomingPublicationSourceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarIncomingPublicationSourceRecord._({
    this.id,
    required this.entryId,
    this.normalizedSource,
    required this.byteCount,
    required this.digest,
    this.basisSourceId,
    required this.kind,
    this.sequence,
    required this.stamp,
    required this.outcome,
    required this.receivedAt,
    this.inactiveAt,
  });

  factory CalendarIncomingPublicationSourceRecord({
    _is.UuidValue? id,
    required _is.UuidValue entryId,
    String? normalizedSource,
    required int byteCount,
    required String digest,
    _is.UuidValue? basisSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) = _CalendarIncomingPublicationSourceRecordImpl;

  factory CalendarIncomingPublicationSourceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationSourceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      normalizedSource: jsonSerialization['normalizedSource'] as String?,
      byteCount: jsonSerialization['byteCount'] as int,
      digest: jsonSerialization['digest'] as String,
      basisSourceId: jsonSerialization['basisSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['basisSourceId'],
            ),
      kind: _ing1vpo7.CalendarIncomingPublicationKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      outcome: _ireg3hht.CalendarIncomingPublicationOutcome.fromJson(
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

  static final t = CalendarIncomingPublicationSourceRecordTable();

  static const db = CalendarIncomingPublicationSourceRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue entryId;

  String? normalizedSource;

  int byteCount;

  String digest;

  _is.UuidValue? basisSourceId;

  _ing1vpo7.CalendarIncomingPublicationKind kind;

  int? sequence;

  DateTime stamp;

  _ireg3hht.CalendarIncomingPublicationOutcome outcome;

  DateTime receivedAt;

  DateTime? inactiveAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarIncomingPublicationSourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationSourceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entryId,
    String? normalizedSource,
    int? byteCount,
    String? digest,
    _is.UuidValue? basisSourceId = const _is.$UndefinedUuidValue(),
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    int? sequence,
    DateTime? stamp,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    DateTime? receivedAt,
    DateTime? inactiveAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationSourceRecord',
      if (id != null) 'id': id?.toJson(),
      'entryId': entryId.toJson(),
      if (normalizedSource != null) 'normalizedSource': normalizedSource,
      'byteCount': byteCount,
      'digest': digest,
      if (basisSourceId != null) 'basisSourceId': basisSourceId?.toJson(),
      'kind': kind.toJson(),
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

  static CalendarIncomingPublicationSourceRecordInclude include() {
    return CalendarIncomingPublicationSourceRecordInclude._();
  }

  static CalendarIncomingPublicationSourceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    CalendarIncomingPublicationSourceRecordInclude? include,
  }) {
    return CalendarIncomingPublicationSourceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationSourceRecordImpl
    extends CalendarIncomingPublicationSourceRecord {
  _CalendarIncomingPublicationSourceRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue entryId,
    String? normalizedSource,
    required int byteCount,
    required String digest,
    _is.UuidValue? basisSourceId,
    required _ing1vpo7.CalendarIncomingPublicationKind kind,
    int? sequence,
    required DateTime stamp,
    required _ireg3hht.CalendarIncomingPublicationOutcome outcome,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) : super._(
         id: id,
         entryId: entryId,
         normalizedSource: normalizedSource,
         byteCount: byteCount,
         digest: digest,
         basisSourceId: basisSourceId,
         kind: kind,
         sequence: sequence,
         stamp: stamp,
         outcome: outcome,
         receivedAt: receivedAt,
         inactiveAt: inactiveAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationSourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationSourceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? entryId,
    Object? normalizedSource = _Undefined,
    int? byteCount,
    String? digest,
    _is.UuidValue? basisSourceId = const _is.$UndefinedUuidValue(),
    _ing1vpo7.CalendarIncomingPublicationKind? kind,
    Object? sequence = _Undefined,
    DateTime? stamp,
    _ireg3hht.CalendarIncomingPublicationOutcome? outcome,
    DateTime? receivedAt,
    DateTime? inactiveAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarIncomingPublicationSourceRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      entryId: entryId ?? this.entryId,
      normalizedSource: normalizedSource is String?
          ? normalizedSource
          : this.normalizedSource,
      byteCount: byteCount ?? this.byteCount,
      digest: digest ?? this.digest,
      basisSourceId: basisSourceId is _is.UndefinedSentinel
          ? this.basisSourceId
          : basisSourceId,
      kind: kind ?? this.kind,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      outcome: outcome ?? this.outcome,
      receivedAt: receivedAt ?? this.receivedAt,
      inactiveAt: inactiveAt is _is.UndefinedSentinel
          ? this.inactiveAt
          : inactiveAt,
    );
  }
}

class CalendarIncomingPublicationSourceRecordUpdateTable
    extends _is.UpdateTable<CalendarIncomingPublicationSourceRecordTable> {
  CalendarIncomingPublicationSourceRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entryId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entryId,
        value,
      );

  _is.ColumnValue<String, String> normalizedSource(String? value) =>
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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> basisSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.basisSourceId,
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

  _is.ColumnValue<
    _ireg3hht.CalendarIncomingPublicationOutcome,
    _ireg3hht.CalendarIncomingPublicationOutcome
  >
  outcome(_ireg3hht.CalendarIncomingPublicationOutcome value) =>
      _is.ColumnValue(
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

class CalendarIncomingPublicationSourceRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarIncomingPublicationSourceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_incoming_publication_source') {
    updateTable = CalendarIncomingPublicationSourceRecordUpdateTable(this);
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
    basisSourceId = _is.ColumnUuid(
      'basisSourceId',
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

  late final CalendarIncomingPublicationSourceRecordUpdateTable updateTable;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnString normalizedSource;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnString digest;

  late final _is.ColumnUuid basisSourceId;

  late final _is.ColumnEnum<_ing1vpo7.CalendarIncomingPublicationKind> kind;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnEnum<_ireg3hht.CalendarIncomingPublicationOutcome>
  outcome;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime inactiveAt;

  @override
  List<_is.Column> get columns => [
    id,
    entryId,
    normalizedSource,
    byteCount,
    digest,
    basisSourceId,
    kind,
    sequence,
    stamp,
    outcome,
    receivedAt,
    inactiveAt,
  ];
}

class CalendarIncomingPublicationSourceRecordInclude extends _is.IncludeObject {
  CalendarIncomingPublicationSourceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationSourceRecord.t;
}

class CalendarIncomingPublicationSourceRecordIncludeList
    extends _is.IncludeList {
  CalendarIncomingPublicationSourceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarIncomingPublicationSourceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationSourceRecord.t;
}

class CalendarIncomingPublicationSourceRecordRepository {
  const CalendarIncomingPublicationSourceRecordRepository._();

  /// Returns a list of [CalendarIncomingPublicationSourceRecord]s matching the given query parameters.
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
  Future<List<CalendarIncomingPublicationSourceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarIncomingPublicationSourceRecord>(
      where: where?.call(CalendarIncomingPublicationSourceRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarIncomingPublicationSourceRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarIncomingPublicationSourceRecord.t`.
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
  _ida.Stream<List<CalendarIncomingPublicationSourceRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarIncomingPublicationSourceRecord>(
      where: where?.call(CalendarIncomingPublicationSourceRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarIncomingPublicationSourceRecord] matching the given query parameters.
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
  Future<CalendarIncomingPublicationSourceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarIncomingPublicationSourceRecord>(
      where: where?.call(CalendarIncomingPublicationSourceRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarIncomingPublicationSourceRecord] by its [id] or null if no such row exists.
  Future<CalendarIncomingPublicationSourceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarIncomingPublicationSourceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarIncomingPublicationSourceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarIncomingPublicationSourceRecord]s will have their `id` fields set.
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
  Future<List<CalendarIncomingPublicationSourceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationSourceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarIncomingPublicationSourceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarIncomingPublicationSourceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarIncomingPublicationSourceRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationSourceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationSourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarIncomingPublicationSourceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarIncomingPublicationSourceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarIncomingPublicationSourceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationSourceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationSourceRecord> rows, {
    required _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarIncomingPublicationSourceRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarIncomingPublicationSourceRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationSourceRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarIncomingPublicationSourceRecord] and returns the resulting row.
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
  /// The returned [CalendarIncomingPublicationSourceRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationSourceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationSourceRecord row, {
    required _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarIncomingPublicationSourceRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarIncomingPublicationSourceRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationSourceRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationSourceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationSourceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationSourceRecord> rows, {
    _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarIncomingPublicationSourceRecord>(
      rows,
      columns: columns?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarIncomingPublicationSourceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarIncomingPublicationSourceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationSourceRecord row, {
    _is.ColumnSelections<CalendarIncomingPublicationSourceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarIncomingPublicationSourceRecord>(
      row,
      columns: columns?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarIncomingPublicationSourceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarIncomingPublicationSourceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationSourceRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarIncomingPublicationSourceRecord>(
      id,
      columnValues: columnValues(
        CalendarIncomingPublicationSourceRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationSourceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationSourceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationSourceRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationSourceRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarIncomingPublicationSourceRecord>(
      columnValues: columnValues(
        CalendarIncomingPublicationSourceRecord.t.updateTable,
      ),
      where: where(CalendarIncomingPublicationSourceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarIncomingPublicationSourceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarIncomingPublicationSourceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationSourceRecord> rows, {
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarIncomingPublicationSourceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarIncomingPublicationSourceRecord].
  Future<CalendarIncomingPublicationSourceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationSourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarIncomingPublicationSourceRecord>(
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
  Future<List<CalendarIncomingPublicationSourceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationSourceRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarIncomingPublicationSourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationSourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarIncomingPublicationSourceRecord>(
      where: where(CalendarIncomingPublicationSourceRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationSourceRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationSourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationSourceRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarIncomingPublicationSourceRecord>(
      where: where?.call(CalendarIncomingPublicationSourceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarIncomingPublicationSourceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationSourceRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarIncomingPublicationSourceRecord>(
      where: where(CalendarIncomingPublicationSourceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
