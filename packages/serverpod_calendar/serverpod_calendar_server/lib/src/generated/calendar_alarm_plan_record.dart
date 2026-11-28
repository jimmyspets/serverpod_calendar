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
import 'calendar_alarm_plan_status.dart' as _irtomk7p;

abstract class CalendarAlarmPlanRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAlarmPlanRecord._({
    this.id,
    required this.alarmId,
    required this.scopeKey,
    required this.generation,
    this.timingDigest,
    this.windowStart,
    this.windowEnd,
    _irtomk7p.CalendarAlarmPlanStatus? status,
    this.reason,
    bool? dirty,
    required this.nextScanAt,
    this.lastCompletedAt,
    this.leaseOwner,
    this.leaseUntil,
    int? leaseFence,
  }) : status = status ?? _irtomk7p.CalendarAlarmPlanStatus.pending,
       dirty = dirty ?? true,
       leaseFence = leaseFence ?? 0;

  factory CalendarAlarmPlanRecord({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required String scopeKey,
    required int generation,
    String? timingDigest,
    DateTime? windowStart,
    DateTime? windowEnd,
    _irtomk7p.CalendarAlarmPlanStatus? status,
    String? reason,
    bool? dirty,
    required DateTime nextScanAt,
    DateTime? lastCompletedAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
  }) = _CalendarAlarmPlanRecordImpl;

  factory CalendarAlarmPlanRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmPlanRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      alarmId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      scopeKey: jsonSerialization['scopeKey'] as String,
      generation: jsonSerialization['generation'] as int,
      timingDigest: jsonSerialization['timingDigest'] as String?,
      windowStart: jsonSerialization['windowStart'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['windowStart'],
            ),
      windowEnd: jsonSerialization['windowEnd'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['windowEnd']),
      status: jsonSerialization['status'] == null
          ? null
          : _irtomk7p.CalendarAlarmPlanStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      reason: jsonSerialization['reason'] as String?,
      dirty: jsonSerialization['dirty'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['dirty']),
      nextScanAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextScanAt'],
      ),
      lastCompletedAt: jsonSerialization['lastCompletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastCompletedAt'],
            ),
      leaseOwner: jsonSerialization['leaseOwner'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseOwner'],
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      leaseFence: jsonSerialization['leaseFence'] as int?,
    );
  }

  static final t = CalendarAlarmPlanRecordTable();

  static const db = CalendarAlarmPlanRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue alarmId;

  String scopeKey;

  int generation;

  String? timingDigest;

  DateTime? windowStart;

  DateTime? windowEnd;

  _irtomk7p.CalendarAlarmPlanStatus status;

  String? reason;

  bool dirty;

  DateTime nextScanAt;

  DateTime? lastCompletedAt;

  _is.UuidValue? leaseOwner;

  DateTime? leaseUntil;

  int leaseFence;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAlarmPlanRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmPlanRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? alarmId,
    String? scopeKey,
    int? generation,
    String? timingDigest,
    DateTime? windowStart,
    DateTime? windowEnd,
    _irtomk7p.CalendarAlarmPlanStatus? status,
    String? reason,
    bool? dirty,
    DateTime? nextScanAt,
    DateTime? lastCompletedAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmPlanRecord',
      if (id != null) 'id': id?.toJson(),
      'alarmId': alarmId.toJson(),
      'scopeKey': scopeKey,
      'generation': generation,
      if (timingDigest != null) 'timingDigest': timingDigest,
      if (windowStart != null) 'windowStart': windowStart?.toJson(),
      if (windowEnd != null) 'windowEnd': windowEnd?.toJson(),
      'status': status.toJson(),
      if (reason != null) 'reason': reason,
      'dirty': dirty,
      'nextScanAt': nextScanAt.toJson(),
      if (lastCompletedAt != null) 'lastCompletedAt': lastCompletedAt?.toJson(),
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'leaseFence': leaseFence,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAlarmPlanRecordInclude include() {
    return CalendarAlarmPlanRecordInclude._();
  }

  static CalendarAlarmPlanRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    CalendarAlarmPlanRecordInclude? include,
  }) {
    return CalendarAlarmPlanRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmPlanRecordImpl extends CalendarAlarmPlanRecord {
  _CalendarAlarmPlanRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required String scopeKey,
    required int generation,
    String? timingDigest,
    DateTime? windowStart,
    DateTime? windowEnd,
    _irtomk7p.CalendarAlarmPlanStatus? status,
    String? reason,
    bool? dirty,
    required DateTime nextScanAt,
    DateTime? lastCompletedAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
  }) : super._(
         id: id,
         alarmId: alarmId,
         scopeKey: scopeKey,
         generation: generation,
         timingDigest: timingDigest,
         windowStart: windowStart,
         windowEnd: windowEnd,
         status: status,
         reason: reason,
         dirty: dirty,
         nextScanAt: nextScanAt,
         lastCompletedAt: lastCompletedAt,
         leaseOwner: leaseOwner,
         leaseUntil: leaseUntil,
         leaseFence: leaseFence,
       );

  /// Returns a shallow copy of this [CalendarAlarmPlanRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmPlanRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? alarmId,
    String? scopeKey,
    int? generation,
    Object? timingDigest = _Undefined,
    Object? windowStart = _Undefined,
    Object? windowEnd = _Undefined,
    _irtomk7p.CalendarAlarmPlanStatus? status,
    Object? reason = _Undefined,
    bool? dirty,
    DateTime? nextScanAt,
    Object? lastCompletedAt = _Undefined,
    Object? leaseOwner = _Undefined,
    Object? leaseUntil = _Undefined,
    int? leaseFence,
  }) {
    return CalendarAlarmPlanRecord(
      id: id is _is.UuidValue? ? id : this.id,
      alarmId: alarmId ?? this.alarmId,
      scopeKey: scopeKey ?? this.scopeKey,
      generation: generation ?? this.generation,
      timingDigest: timingDigest is String? ? timingDigest : this.timingDigest,
      windowStart: windowStart is DateTime? ? windowStart : this.windowStart,
      windowEnd: windowEnd is DateTime? ? windowEnd : this.windowEnd,
      status: status ?? this.status,
      reason: reason is String? ? reason : this.reason,
      dirty: dirty ?? this.dirty,
      nextScanAt: nextScanAt ?? this.nextScanAt,
      lastCompletedAt: lastCompletedAt is DateTime?
          ? lastCompletedAt
          : this.lastCompletedAt,
      leaseOwner: leaseOwner is _is.UuidValue? ? leaseOwner : this.leaseOwner,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      leaseFence: leaseFence ?? this.leaseFence,
    );
  }
}

class CalendarAlarmPlanRecordUpdateTable
    extends _is.UpdateTable<CalendarAlarmPlanRecordTable> {
  CalendarAlarmPlanRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> alarmId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.alarmId,
        value,
      );

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> timingDigest(String? value) =>
      _is.ColumnValue(
        table.timingDigest,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> windowStart(DateTime? value) =>
      _is.ColumnValue(
        table.windowStart,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> windowEnd(DateTime? value) =>
      _is.ColumnValue(
        table.windowEnd,
        value,
      );

  _is.ColumnValue<
    _irtomk7p.CalendarAlarmPlanStatus,
    _irtomk7p.CalendarAlarmPlanStatus
  >
  status(_irtomk7p.CalendarAlarmPlanStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> reason(String? value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<bool, bool> dirty(bool value) => _is.ColumnValue(
    table.dirty,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextScanAt(DateTime value) =>
      _is.ColumnValue(
        table.nextScanAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastCompletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastCompletedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseOwner(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseOwner,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<int, int> leaseFence(int value) => _is.ColumnValue(
    table.leaseFence,
    value,
  );
}

class CalendarAlarmPlanRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAlarmPlanRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_alarm_plan') {
    updateTable = CalendarAlarmPlanRecordUpdateTable(this);
    alarmId = _is.ColumnUuid(
      'alarmId',
      this,
    );
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    timingDigest = _is.ColumnString(
      'timingDigest',
      this,
    );
    windowStart = _is.ColumnDateTime(
      'windowStart',
      this,
    );
    windowEnd = _is.ColumnDateTime(
      'windowEnd',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    dirty = _is.ColumnBool(
      'dirty',
      this,
      hasDefault: true,
    );
    nextScanAt = _is.ColumnDateTime(
      'nextScanAt',
      this,
    );
    lastCompletedAt = _is.ColumnDateTime(
      'lastCompletedAt',
      this,
    );
    leaseOwner = _is.ColumnUuid(
      'leaseOwner',
      this,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    leaseFence = _is.ColumnInt(
      'leaseFence',
      this,
      hasDefault: true,
    );
  }

  late final CalendarAlarmPlanRecordUpdateTable updateTable;

  late final _is.ColumnUuid alarmId;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnInt generation;

  late final _is.ColumnString timingDigest;

  late final _is.ColumnDateTime windowStart;

  late final _is.ColumnDateTime windowEnd;

  late final _is.ColumnEnum<_irtomk7p.CalendarAlarmPlanStatus> status;

  late final _is.ColumnString reason;

  late final _is.ColumnBool dirty;

  late final _is.ColumnDateTime nextScanAt;

  late final _is.ColumnDateTime lastCompletedAt;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnInt leaseFence;

  @override
  List<_is.Column> get columns => [
    id,
    alarmId,
    scopeKey,
    generation,
    timingDigest,
    windowStart,
    windowEnd,
    status,
    reason,
    dirty,
    nextScanAt,
    lastCompletedAt,
    leaseOwner,
    leaseUntil,
    leaseFence,
  ];
}

class CalendarAlarmPlanRecordInclude extends _is.IncludeObject {
  CalendarAlarmPlanRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmPlanRecord.t;
}

class CalendarAlarmPlanRecordIncludeList extends _is.IncludeList {
  CalendarAlarmPlanRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAlarmPlanRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmPlanRecord.t;
}

class CalendarAlarmPlanRecordRepository {
  const CalendarAlarmPlanRecordRepository._();

  /// Returns a list of [CalendarAlarmPlanRecord]s matching the given query parameters.
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
  Future<List<CalendarAlarmPlanRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAlarmPlanRecord>(
      where: where?.call(CalendarAlarmPlanRecord.t),
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAlarmPlanRecord] matching the given query parameters.
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
  Future<CalendarAlarmPlanRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAlarmPlanRecord>(
      where: where?.call(CalendarAlarmPlanRecord.t),
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAlarmPlanRecord] by its [id] or null if no such row exists.
  Future<CalendarAlarmPlanRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAlarmPlanRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAlarmPlanRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAlarmPlanRecord]s will have their `id` fields set.
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
  Future<List<CalendarAlarmPlanRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAlarmPlanRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAlarmPlanRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAlarmPlanRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAlarmPlanRecord] will have its `id` field set.
  Future<CalendarAlarmPlanRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAlarmPlanRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAlarmPlanRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAlarmPlanRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAlarmPlanRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmPlanRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAlarmPlanRecord> rows, {
    required _is.ColumnSelections<CalendarAlarmPlanRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarAlarmPlanRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAlarmPlanRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAlarmPlanRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmPlanRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAlarmPlanRecord] and returns the resulting row.
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
  /// The returned [CalendarAlarmPlanRecord] will have its `id` field set.
  Future<CalendarAlarmPlanRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAlarmPlanRecord row, {
    required _is.ColumnSelections<CalendarAlarmPlanRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarAlarmPlanRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAlarmPlanRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAlarmPlanRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmPlanRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmPlanRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmPlanRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAlarmPlanRecord> rows, {
    _is.ColumnSelections<CalendarAlarmPlanRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAlarmPlanRecord>(
      rows,
      columns: columns?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAlarmPlanRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAlarmPlanRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAlarmPlanRecord row, {
    _is.ColumnSelections<CalendarAlarmPlanRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAlarmPlanRecord>(
      row,
      columns: columns?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAlarmPlanRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAlarmPlanRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarAlarmPlanRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAlarmPlanRecord>(
      id,
      columnValues: columnValues(CalendarAlarmPlanRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmPlanRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmPlanRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarAlarmPlanRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAlarmPlanRecord>(
      columnValues: columnValues(CalendarAlarmPlanRecord.t.updateTable),
      where: where(CalendarAlarmPlanRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAlarmPlanRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAlarmPlanRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAlarmPlanRecord> rows, {
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAlarmPlanRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAlarmPlanRecord].
  Future<CalendarAlarmPlanRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAlarmPlanRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAlarmPlanRecord>(
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
  Future<List<CalendarAlarmPlanRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable> where,
    _is.OrderByBuilder<CalendarAlarmPlanRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmPlanRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAlarmPlanRecord>(
      where: where(CalendarAlarmPlanRecord.t),
      orderBy: orderBy?.call(CalendarAlarmPlanRecord.t),
      orderByList: orderByList?.call(CalendarAlarmPlanRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAlarmPlanRecord>(
      where: where?.call(CalendarAlarmPlanRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAlarmPlanRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmPlanRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAlarmPlanRecord>(
      where: where(CalendarAlarmPlanRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
