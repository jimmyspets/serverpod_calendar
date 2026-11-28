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
import 'calendar_alarm_firing_kind.dart' as _i8okwxwj;
import 'calendar_alarm_firing_state.dart' as _ihos0r46;

abstract class CalendarAlarmFiringRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAlarmFiringRecord._({
    this.id,
    required this.alarmId,
    required this.generation,
    required this.originalKey,
    required this.kind,
    required this.repeatOrdinal,
    int? snoozeRevision,
    required this.dueAt,
    required this.expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    this.reason,
    required this.nextAttemptAt,
    int? attemptCount,
    this.acceptedAt,
    this.terminalAt,
    this.leaseOwner,
    this.leaseUntil,
    int? leaseFence,
    required this.createdAt,
    required this.updatedAt,
  }) : snoozeRevision = snoozeRevision ?? 0,
       state = state ?? _ihos0r46.CalendarAlarmFiringState.pending,
       attemptCount = attemptCount ?? 0,
       leaseFence = leaseFence ?? 0;

  factory CalendarAlarmFiringRecord({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required int generation,
    required String originalKey,
    required _i8okwxwj.CalendarAlarmFiringKind kind,
    required int repeatOrdinal,
    int? snoozeRevision,
    required DateTime dueAt,
    required DateTime expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    String? reason,
    required DateTime nextAttemptAt,
    int? attemptCount,
    DateTime? acceptedAt,
    DateTime? terminalAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarAlarmFiringRecordImpl;

  factory CalendarAlarmFiringRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAlarmFiringRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      alarmId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['alarmId'],
      ),
      generation: jsonSerialization['generation'] as int,
      originalKey: jsonSerialization['originalKey'] as String,
      kind: _i8okwxwj.CalendarAlarmFiringKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      repeatOrdinal: jsonSerialization['repeatOrdinal'] as int,
      snoozeRevision: jsonSerialization['snoozeRevision'] as int?,
      dueAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      state: jsonSerialization['state'] == null
          ? null
          : _ihos0r46.CalendarAlarmFiringState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      reason: jsonSerialization['reason'] as String?,
      nextAttemptAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextAttemptAt'],
      ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      leaseOwner: jsonSerialization['leaseOwner'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseOwner'],
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      leaseFence: jsonSerialization['leaseFence'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarAlarmFiringRecordTable();

  static const db = CalendarAlarmFiringRecordRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue alarmId;

  int generation;

  String originalKey;

  _i8okwxwj.CalendarAlarmFiringKind kind;

  int repeatOrdinal;

  int snoozeRevision;

  DateTime dueAt;

  DateTime expiresAt;

  _ihos0r46.CalendarAlarmFiringState state;

  String? reason;

  DateTime nextAttemptAt;

  int attemptCount;

  DateTime? acceptedAt;

  DateTime? terminalAt;

  _is.UuidValue? leaseOwner;

  DateTime? leaseUntil;

  int leaseFence;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAlarmFiringRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAlarmFiringRecord copyWith({
    _is.UuidValue? id,
    _is.UuidValue? alarmId,
    int? generation,
    String? originalKey,
    _i8okwxwj.CalendarAlarmFiringKind? kind,
    int? repeatOrdinal,
    int? snoozeRevision,
    DateTime? dueAt,
    DateTime? expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    String? reason,
    DateTime? nextAttemptAt,
    int? attemptCount,
    DateTime? acceptedAt,
    DateTime? terminalAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAlarmFiringRecord',
      if (id != null) 'id': id?.toJson(),
      'alarmId': alarmId.toJson(),
      'generation': generation,
      'originalKey': originalKey,
      'kind': kind.toJson(),
      'repeatOrdinal': repeatOrdinal,
      'snoozeRevision': snoozeRevision,
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'state': state.toJson(),
      if (reason != null) 'reason': reason,
      'nextAttemptAt': nextAttemptAt.toJson(),
      'attemptCount': attemptCount,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'leaseFence': leaseFence,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAlarmFiringRecordInclude include() {
    return CalendarAlarmFiringRecordInclude._();
  }

  static CalendarAlarmFiringRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    CalendarAlarmFiringRecordInclude? include,
  }) {
    return CalendarAlarmFiringRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAlarmFiringRecordImpl extends CalendarAlarmFiringRecord {
  _CalendarAlarmFiringRecordImpl({
    _is.UuidValue? id,
    required _is.UuidValue alarmId,
    required int generation,
    required String originalKey,
    required _i8okwxwj.CalendarAlarmFiringKind kind,
    required int repeatOrdinal,
    int? snoozeRevision,
    required DateTime dueAt,
    required DateTime expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    String? reason,
    required DateTime nextAttemptAt,
    int? attemptCount,
    DateTime? acceptedAt,
    DateTime? terminalAt,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         alarmId: alarmId,
         generation: generation,
         originalKey: originalKey,
         kind: kind,
         repeatOrdinal: repeatOrdinal,
         snoozeRevision: snoozeRevision,
         dueAt: dueAt,
         expiresAt: expiresAt,
         state: state,
         reason: reason,
         nextAttemptAt: nextAttemptAt,
         attemptCount: attemptCount,
         acceptedAt: acceptedAt,
         terminalAt: terminalAt,
         leaseOwner: leaseOwner,
         leaseUntil: leaseUntil,
         leaseFence: leaseFence,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarAlarmFiringRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAlarmFiringRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? alarmId,
    int? generation,
    String? originalKey,
    _i8okwxwj.CalendarAlarmFiringKind? kind,
    int? repeatOrdinal,
    int? snoozeRevision,
    DateTime? dueAt,
    DateTime? expiresAt,
    _ihos0r46.CalendarAlarmFiringState? state,
    Object? reason = _Undefined,
    DateTime? nextAttemptAt,
    int? attemptCount,
    Object? acceptedAt = _Undefined,
    Object? terminalAt = _Undefined,
    Object? leaseOwner = _Undefined,
    Object? leaseUntil = _Undefined,
    int? leaseFence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarAlarmFiringRecord(
      id: id is _is.UuidValue? ? id : this.id,
      alarmId: alarmId ?? this.alarmId,
      generation: generation ?? this.generation,
      originalKey: originalKey ?? this.originalKey,
      kind: kind ?? this.kind,
      repeatOrdinal: repeatOrdinal ?? this.repeatOrdinal,
      snoozeRevision: snoozeRevision ?? this.snoozeRevision,
      dueAt: dueAt ?? this.dueAt,
      expiresAt: expiresAt ?? this.expiresAt,
      state: state ?? this.state,
      reason: reason is String? ? reason : this.reason,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      terminalAt: terminalAt is DateTime? ? terminalAt : this.terminalAt,
      leaseOwner: leaseOwner is _is.UuidValue? ? leaseOwner : this.leaseOwner,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      leaseFence: leaseFence ?? this.leaseFence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarAlarmFiringRecordUpdateTable
    extends _is.UpdateTable<CalendarAlarmFiringRecordTable> {
  CalendarAlarmFiringRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> alarmId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.alarmId,
        value,
      );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> originalKey(String value) => _is.ColumnValue(
    table.originalKey,
    value,
  );

  _is.ColumnValue<
    _i8okwxwj.CalendarAlarmFiringKind,
    _i8okwxwj.CalendarAlarmFiringKind
  >
  kind(_i8okwxwj.CalendarAlarmFiringKind value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<int, int> repeatOrdinal(int value) => _is.ColumnValue(
    table.repeatOrdinal,
    value,
  );

  _is.ColumnValue<int, int> snoozeRevision(int value) => _is.ColumnValue(
    table.snoozeRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dueAt(DateTime value) => _is.ColumnValue(
    table.dueAt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<
    _ihos0r46.CalendarAlarmFiringState,
    _ihos0r46.CalendarAlarmFiringState
  >
  state(_ihos0r46.CalendarAlarmFiringState value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> reason(String? value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<int, int> attemptCount(int value) => _is.ColumnValue(
    table.attemptCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
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

class CalendarAlarmFiringRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAlarmFiringRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_alarm_firing') {
    updateTable = CalendarAlarmFiringRecordUpdateTable(this);
    alarmId = _is.ColumnUuid(
      'alarmId',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    originalKey = _is.ColumnString(
      'originalKey',
      this,
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    repeatOrdinal = _is.ColumnInt(
      'repeatOrdinal',
      this,
    );
    snoozeRevision = _is.ColumnInt(
      'snoozeRevision',
      this,
      hasDefault: true,
    );
    dueAt = _is.ColumnDateTime(
      'dueAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    attemptCount = _is.ColumnInt(
      'attemptCount',
      this,
      hasDefault: true,
    );
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
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
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final CalendarAlarmFiringRecordUpdateTable updateTable;

  late final _is.ColumnUuid alarmId;

  late final _is.ColumnInt generation;

  late final _is.ColumnString originalKey;

  late final _is.ColumnEnum<_i8okwxwj.CalendarAlarmFiringKind> kind;

  late final _is.ColumnInt repeatOrdinal;

  late final _is.ColumnInt snoozeRevision;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnEnum<_ihos0r46.CalendarAlarmFiringState> state;

  late final _is.ColumnString reason;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime acceptedAt;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    alarmId,
    generation,
    originalKey,
    kind,
    repeatOrdinal,
    snoozeRevision,
    dueAt,
    expiresAt,
    state,
    reason,
    nextAttemptAt,
    attemptCount,
    acceptedAt,
    terminalAt,
    leaseOwner,
    leaseUntil,
    leaseFence,
    createdAt,
    updatedAt,
  ];
}

class CalendarAlarmFiringRecordInclude extends _is.IncludeObject {
  CalendarAlarmFiringRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmFiringRecord.t;
}

class CalendarAlarmFiringRecordIncludeList extends _is.IncludeList {
  CalendarAlarmFiringRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAlarmFiringRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAlarmFiringRecord.t;
}

class CalendarAlarmFiringRecordRepository {
  const CalendarAlarmFiringRecordRepository._();

  /// Returns a list of [CalendarAlarmFiringRecord]s matching the given query parameters.
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
  Future<List<CalendarAlarmFiringRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAlarmFiringRecord>(
      where: where?.call(CalendarAlarmFiringRecord.t),
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarAlarmFiringRecord] matching the given query parameters.
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
  Future<CalendarAlarmFiringRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAlarmFiringRecord>(
      where: where?.call(CalendarAlarmFiringRecord.t),
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAlarmFiringRecord] by its [id] or null if no such row exists.
  Future<CalendarAlarmFiringRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAlarmFiringRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAlarmFiringRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAlarmFiringRecord]s will have their `id` fields set.
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
  Future<List<CalendarAlarmFiringRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAlarmFiringRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAlarmFiringRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAlarmFiringRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAlarmFiringRecord] will have its `id` field set.
  Future<CalendarAlarmFiringRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAlarmFiringRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAlarmFiringRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAlarmFiringRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAlarmFiringRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmFiringRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAlarmFiringRecord> rows, {
    required _is.ColumnSelections<CalendarAlarmFiringRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAlarmFiringRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAlarmFiringRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAlarmFiringRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmFiringRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAlarmFiringRecord] and returns the resulting row.
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
  /// The returned [CalendarAlarmFiringRecord] will have its `id` field set.
  Future<CalendarAlarmFiringRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAlarmFiringRecord row, {
    required _is.ColumnSelections<CalendarAlarmFiringRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAlarmFiringRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAlarmFiringRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAlarmFiringRecord.t),
      updateColumns: updateColumns?.call(CalendarAlarmFiringRecord.t),
      updateWhere: updateWhere?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmFiringRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmFiringRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAlarmFiringRecord> rows, {
    _is.ColumnSelections<CalendarAlarmFiringRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAlarmFiringRecord>(
      rows,
      columns: columns?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAlarmFiringRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAlarmFiringRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAlarmFiringRecord row, {
    _is.ColumnSelections<CalendarAlarmFiringRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAlarmFiringRecord>(
      row,
      columns: columns?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAlarmFiringRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAlarmFiringRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarAlarmFiringRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAlarmFiringRecord>(
      id,
      columnValues: columnValues(CalendarAlarmFiringRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAlarmFiringRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAlarmFiringRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarAlarmFiringRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAlarmFiringRecord>(
      columnValues: columnValues(CalendarAlarmFiringRecord.t.updateTable),
      where: where(CalendarAlarmFiringRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAlarmFiringRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAlarmFiringRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAlarmFiringRecord> rows, {
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAlarmFiringRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAlarmFiringRecord].
  Future<CalendarAlarmFiringRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAlarmFiringRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAlarmFiringRecord>(
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
  Future<List<CalendarAlarmFiringRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable> where,
    _is.OrderByBuilder<CalendarAlarmFiringRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAlarmFiringRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAlarmFiringRecord>(
      where: where(CalendarAlarmFiringRecord.t),
      orderBy: orderBy?.call(CalendarAlarmFiringRecord.t),
      orderByList: orderByList?.call(CalendarAlarmFiringRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAlarmFiringRecord>(
      where: where?.call(CalendarAlarmFiringRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAlarmFiringRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAlarmFiringRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAlarmFiringRecord>(
      where: where(CalendarAlarmFiringRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
