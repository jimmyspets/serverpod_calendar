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
import 'calendar_scheduling_delivery_state.dart' as _it5jr5tm;

abstract class CalendarSchedulingDeliveryRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingDeliveryRecord._({
    this.id,
    required this.scopeKey,
    required this.publicationId,
    required this.recipientAddress,
    required this.routeRef,
    _is.UuidValue? deliveryKey,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required this.nextAttemptAt,
    this.leaseOwner,
    this.leaseToken,
    int? leaseFence,
    this.leaseUntil,
    this.terminalAt,
    this.resultCode,
  }) : deliveryKey = deliveryKey ?? const _is.Uuid().v4obj(),
       state = state ?? _it5jr5tm.CalendarSchedulingDeliveryState.pending,
       attemptCount = attemptCount ?? 0,
       leaseFence = leaseFence ?? 0;

  factory CalendarSchedulingDeliveryRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue publicationId,
    required String recipientAddress,
    required String routeRef,
    _is.UuidValue? deliveryKey,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) = _CalendarSchedulingDeliveryRecordImpl;

  factory CalendarSchedulingDeliveryRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingDeliveryRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      publicationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      recipientAddress: jsonSerialization['recipientAddress'] as String,
      routeRef: jsonSerialization['routeRef'] as String,
      deliveryKey: jsonSerialization['deliveryKey'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['deliveryKey'],
            ),
      state: jsonSerialization['state'] == null
          ? null
          : _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      nextAttemptAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextAttemptAt'],
      ),
      leaseOwner: jsonSerialization['leaseOwner'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseOwner'],
            ),
      leaseToken: jsonSerialization['leaseToken'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseToken'],
            ),
      leaseFence: jsonSerialization['leaseFence'] as int?,
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  static final t = CalendarSchedulingDeliveryRecordTable();

  static const db = CalendarSchedulingDeliveryRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue publicationId;

  String recipientAddress;

  String routeRef;

  _is.UuidValue deliveryKey;

  _it5jr5tm.CalendarSchedulingDeliveryState state;

  int attemptCount;

  DateTime nextAttemptAt;

  _is.UuidValue? leaseOwner;

  _is.UuidValue? leaseToken;

  int leaseFence;

  DateTime? leaseUntil;

  DateTime? terminalAt;

  String? resultCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingDeliveryRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? publicationId,
    String? recipientAddress,
    String? routeRef,
    _is.UuidValue? deliveryKey,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingDeliveryRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'publicationId': publicationId.toJson(),
      'recipientAddress': recipientAddress,
      'routeRef': routeRef,
      'deliveryKey': deliveryKey.toJson(),
      'state': state.toJson(),
      'attemptCount': attemptCount,
      'nextAttemptAt': nextAttemptAt.toJson(),
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken?.toJson(),
      'leaseFence': leaseFence,
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingDeliveryRecordInclude include() {
    return CalendarSchedulingDeliveryRecordInclude._();
  }

  static CalendarSchedulingDeliveryRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    CalendarSchedulingDeliveryRecordInclude? include,
  }) {
    return CalendarSchedulingDeliveryRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingDeliveryRecordImpl
    extends CalendarSchedulingDeliveryRecord {
  _CalendarSchedulingDeliveryRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue publicationId,
    required String recipientAddress,
    required String routeRef,
    _is.UuidValue? deliveryKey,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         publicationId: publicationId,
         recipientAddress: recipientAddress,
         routeRef: routeRef,
         deliveryKey: deliveryKey,
         state: state,
         attemptCount: attemptCount,
         nextAttemptAt: nextAttemptAt,
         leaseOwner: leaseOwner,
         leaseToken: leaseToken,
         leaseFence: leaseFence,
         leaseUntil: leaseUntil,
         terminalAt: terminalAt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarSchedulingDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingDeliveryRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? publicationId,
    String? recipientAddress,
    String? routeRef,
    _is.UuidValue? deliveryKey,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    DateTime? nextAttemptAt,
    Object? leaseOwner = _Undefined,
    Object? leaseToken = _Undefined,
    int? leaseFence,
    Object? leaseUntil = _Undefined,
    Object? terminalAt = _Undefined,
    Object? resultCode = _Undefined,
  }) {
    return CalendarSchedulingDeliveryRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      publicationId: publicationId ?? this.publicationId,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      routeRef: routeRef ?? this.routeRef,
      deliveryKey: deliveryKey ?? this.deliveryKey,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseOwner: leaseOwner is _is.UuidValue? ? leaseOwner : this.leaseOwner,
      leaseToken: leaseToken is _is.UuidValue? ? leaseToken : this.leaseToken,
      leaseFence: leaseFence ?? this.leaseFence,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      terminalAt: terminalAt is DateTime? ? terminalAt : this.terminalAt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}

class CalendarSchedulingDeliveryRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingDeliveryRecordTable> {
  CalendarSchedulingDeliveryRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> publicationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.publicationId,
    value,
  );

  _is.ColumnValue<String, String> recipientAddress(String value) =>
      _is.ColumnValue(
        table.recipientAddress,
        value,
      );

  _is.ColumnValue<String, String> routeRef(String value) => _is.ColumnValue(
    table.routeRef,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deliveryKey(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.deliveryKey,
    value,
  );

  _is.ColumnValue<
    _it5jr5tm.CalendarSchedulingDeliveryState,
    _it5jr5tm.CalendarSchedulingDeliveryState
  >
  state(_it5jr5tm.CalendarSchedulingDeliveryState value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<int, int> attemptCount(int value) => _is.ColumnValue(
    table.attemptCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseOwner(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseOwner,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseToken(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<int, int> leaseFence(int value) => _is.ColumnValue(
    table.leaseFence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
        value,
      );

  _is.ColumnValue<String, String> resultCode(String? value) => _is.ColumnValue(
    table.resultCode,
    value,
  );
}

class CalendarSchedulingDeliveryRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingDeliveryRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_delivery') {
    updateTable = CalendarSchedulingDeliveryRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    publicationId = _is.ColumnUuid(
      'publicationId',
      this,
    );
    recipientAddress = _is.ColumnString(
      'recipientAddress',
      this,
    );
    routeRef = _is.ColumnString(
      'routeRef',
      this,
    );
    deliveryKey = _is.ColumnUuid(
      'deliveryKey',
      this,
      hasDefault: true,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    attemptCount = _is.ColumnInt(
      'attemptCount',
      this,
      hasDefault: true,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    leaseOwner = _is.ColumnUuid(
      'leaseOwner',
      this,
    );
    leaseToken = _is.ColumnUuid(
      'leaseToken',
      this,
    );
    leaseFence = _is.ColumnInt(
      'leaseFence',
      this,
      hasDefault: true,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
      this,
    );
    resultCode = _is.ColumnString(
      'resultCode',
      this,
    );
  }

  late final CalendarSchedulingDeliveryRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid publicationId;

  late final _is.ColumnString recipientAddress;

  late final _is.ColumnString routeRef;

  late final _is.ColumnUuid deliveryKey;

  late final _is.ColumnEnum<_it5jr5tm.CalendarSchedulingDeliveryState> state;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnString resultCode;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    publicationId,
    recipientAddress,
    routeRef,
    deliveryKey,
    state,
    attemptCount,
    nextAttemptAt,
    leaseOwner,
    leaseToken,
    leaseFence,
    leaseUntil,
    terminalAt,
    resultCode,
  ];
}

class CalendarSchedulingDeliveryRecordInclude extends _is.IncludeObject {
  CalendarSchedulingDeliveryRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingDeliveryRecord.t;
}

class CalendarSchedulingDeliveryRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingDeliveryRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingDeliveryRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingDeliveryRecord.t;
}

class CalendarSchedulingDeliveryRecordRepository {
  const CalendarSchedulingDeliveryRecordRepository._();

  /// Returns a list of [CalendarSchedulingDeliveryRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingDeliveryRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingDeliveryRecord>(
      where: where?.call(CalendarSchedulingDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingDeliveryRecord] matching the given query parameters.
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
  Future<CalendarSchedulingDeliveryRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingDeliveryRecord>(
      where: where?.call(CalendarSchedulingDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingDeliveryRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingDeliveryRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingDeliveryRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingDeliveryRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingDeliveryRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingDeliveryRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingDeliveryRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingDeliveryRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingDeliveryRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingDeliveryRecord] will have its `id` field set.
  Future<CalendarSchedulingDeliveryRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingDeliveryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingDeliveryRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingDeliveryRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingDeliveryRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingDeliveryRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingDeliveryRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingDeliveryRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingDeliveryRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingDeliveryRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingDeliveryRecord] will have its `id` field set.
  Future<CalendarSchedulingDeliveryRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingDeliveryRecord row, {
    required _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingDeliveryRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingDeliveryRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingDeliveryRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingDeliveryRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingDeliveryRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingDeliveryRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingDeliveryRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingDeliveryRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingDeliveryRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingDeliveryRecord row, {
    _is.ColumnSelections<CalendarSchedulingDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingDeliveryRecord>(
      row,
      columns: columns?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingDeliveryRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingDeliveryRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingDeliveryRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingDeliveryRecord>(
      id,
      columnValues: columnValues(
        CalendarSchedulingDeliveryRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingDeliveryRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingDeliveryRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingDeliveryRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingDeliveryRecord>(
      columnValues: columnValues(
        CalendarSchedulingDeliveryRecord.t.updateTable,
      ),
      where: where(CalendarSchedulingDeliveryRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingDeliveryRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingDeliveryRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingDeliveryRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingDeliveryRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingDeliveryRecord].
  Future<CalendarSchedulingDeliveryRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingDeliveryRecord>(
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
  Future<List<CalendarSchedulingDeliveryRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>
    where,
    _is.OrderByBuilder<CalendarSchedulingDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingDeliveryRecord>(
      where: where(CalendarSchedulingDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingDeliveryRecord>(
      where: where?.call(CalendarSchedulingDeliveryRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingDeliveryRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarSchedulingDeliveryRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingDeliveryRecord>(
      where: where(CalendarSchedulingDeliveryRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
