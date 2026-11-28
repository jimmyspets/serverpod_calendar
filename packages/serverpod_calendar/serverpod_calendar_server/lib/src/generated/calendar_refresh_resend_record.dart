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

import 'calendar_scheduling_delivery_state.dart' as _it5jr5tm;

abstract class CalendarRefreshResendRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarRefreshResendRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.requestId,
    required this.commandId,
    required this.actorId,
    required this.publicationId,
    required this.generation,
    required this.payloadDigest,
    required this.recipientAddress,
    required this.routeRef,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required this.createdAt,
    required this.expiresAt,
    required this.nextAttemptAt,
    this.leaseToken,
    this.leaseUntil,
    this.terminalAt,
    this.resultCode,
  }) : state = state ?? _it5jr5tm.CalendarSchedulingDeliveryState.pending,
       attemptCount = attemptCount ?? 0;

  factory CalendarRefreshResendRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required _is.UuidValue requestId,
    required _is.UuidValue commandId,
    required String actorId,
    required _is.UuidValue publicationId,
    required int generation,
    required String payloadDigest,
    required String recipientAddress,
    required String routeRef,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseToken,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) = _CalendarRefreshResendRecordImpl;

  factory CalendarRefreshResendRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarRefreshResendRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      requestId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['requestId'],
      ),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      actorId: jsonSerialization['actorId'] as String,
      publicationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['publicationId'],
      ),
      generation: jsonSerialization['generation'] as int,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      recipientAddress: jsonSerialization['recipientAddress'] as String,
      routeRef: jsonSerialization['routeRef'] as String,
      state: jsonSerialization['state'] == null
          ? null
          : _it5jr5tm.CalendarSchedulingDeliveryState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      nextAttemptAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextAttemptAt'],
      ),
      leaseToken: jsonSerialization['leaseToken'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseToken'],
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  static final t = CalendarRefreshResendRecordTable();

  static const db = CalendarRefreshResendRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  _is.UuidValue requestId;

  _is.UuidValue commandId;

  String actorId;

  _is.UuidValue publicationId;

  int generation;

  String payloadDigest;

  String recipientAddress;

  String routeRef;

  _it5jr5tm.CalendarSchedulingDeliveryState state;

  int attemptCount;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime nextAttemptAt;

  _is.UuidValue? leaseToken;

  DateTime? leaseUntil;

  DateTime? terminalAt;

  String? resultCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarRefreshResendRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarRefreshResendRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    _is.UuidValue? meetingId,
    _is.UuidValue? requestId,
    _is.UuidValue? commandId,
    String? actorId,
    _is.UuidValue? publicationId,
    int? generation,
    String? payloadDigest,
    String? recipientAddress,
    String? routeRef,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarRefreshResendRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'requestId': requestId.toJson(),
      'commandId': commandId.toJson(),
      'actorId': actorId,
      'publicationId': publicationId.toJson(),
      'generation': generation,
      'payloadDigest': payloadDigest,
      'recipientAddress': recipientAddress,
      'routeRef': routeRef,
      'state': state.toJson(),
      'attemptCount': attemptCount,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'nextAttemptAt': nextAttemptAt.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken?.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarRefreshResendRecordInclude include() {
    return CalendarRefreshResendRecordInclude._();
  }

  static CalendarRefreshResendRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    CalendarRefreshResendRecordInclude? include,
  }) {
    return CalendarRefreshResendRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarRefreshResendRecordImpl extends CalendarRefreshResendRecord {
  _CalendarRefreshResendRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required _is.UuidValue requestId,
    required _is.UuidValue commandId,
    required String actorId,
    required _is.UuidValue publicationId,
    required int generation,
    required String payloadDigest,
    required String recipientAddress,
    required String routeRef,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseToken,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         requestId: requestId,
         commandId: commandId,
         actorId: actorId,
         publicationId: publicationId,
         generation: generation,
         payloadDigest: payloadDigest,
         recipientAddress: recipientAddress,
         routeRef: routeRef,
         state: state,
         attemptCount: attemptCount,
         createdAt: createdAt,
         expiresAt: expiresAt,
         nextAttemptAt: nextAttemptAt,
         leaseToken: leaseToken,
         leaseUntil: leaseUntil,
         terminalAt: terminalAt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarRefreshResendRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarRefreshResendRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    _is.UuidValue? meetingId,
    _is.UuidValue? requestId,
    _is.UuidValue? commandId,
    String? actorId,
    _is.UuidValue? publicationId,
    int? generation,
    String? payloadDigest,
    String? recipientAddress,
    String? routeRef,
    _it5jr5tm.CalendarSchedulingDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    Object? resultCode = _Undefined,
  }) {
    return CalendarRefreshResendRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      requestId: requestId ?? this.requestId,
      commandId: commandId ?? this.commandId,
      actorId: actorId ?? this.actorId,
      publicationId: publicationId ?? this.publicationId,
      generation: generation ?? this.generation,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      routeRef: routeRef ?? this.routeRef,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseToken: leaseToken is _is.UndefinedSentinel
          ? this.leaseToken
          : leaseToken,
      leaseUntil: leaseUntil is _is.UndefinedSentinel
          ? this.leaseUntil
          : leaseUntil,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}

class CalendarRefreshResendRecordUpdateTable
    extends _is.UpdateTable<CalendarRefreshResendRecordTable> {
  CalendarRefreshResendRecordUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.requestId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> commandId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.commandId,
    value,
  );

  _is.ColumnValue<String, String> actorId(String value) => _is.ColumnValue(
    table.actorId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> publicationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.publicationId,
    value,
  );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> payloadDigest(String value) =>
      _is.ColumnValue(
        table.payloadDigest,
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

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseToken(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseToken,
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

class CalendarRefreshResendRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarRefreshResendRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_refresh_resend') {
    updateTable = CalendarRefreshResendRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    meetingId = _is.ColumnUuid(
      'meetingId',
      this,
    );
    requestId = _is.ColumnUuid(
      'requestId',
      this,
    );
    commandId = _is.ColumnUuid(
      'commandId',
      this,
    );
    actorId = _is.ColumnString(
      'actorId',
      this,
    );
    publicationId = _is.ColumnUuid(
      'publicationId',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    payloadDigest = _is.ColumnString(
      'payloadDigest',
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
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    leaseToken = _is.ColumnUuid(
      'leaseToken',
      this,
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

  late final CalendarRefreshResendRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnUuid requestId;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString actorId;

  late final _is.ColumnUuid publicationId;

  late final _is.ColumnInt generation;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnString recipientAddress;

  late final _is.ColumnString routeRef;

  late final _is.ColumnEnum<_it5jr5tm.CalendarSchedulingDeliveryState> state;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnString resultCode;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    requestId,
    commandId,
    actorId,
    publicationId,
    generation,
    payloadDigest,
    recipientAddress,
    routeRef,
    state,
    attemptCount,
    createdAt,
    expiresAt,
    nextAttemptAt,
    leaseToken,
    leaseUntil,
    terminalAt,
    resultCode,
  ];
}

class CalendarRefreshResendRecordInclude extends _is.IncludeObject {
  CalendarRefreshResendRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarRefreshResendRecord.t;
}

class CalendarRefreshResendRecordIncludeList extends _is.IncludeList {
  CalendarRefreshResendRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarRefreshResendRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarRefreshResendRecord.t;
}

class CalendarRefreshResendRecordRepository {
  const CalendarRefreshResendRecordRepository._();

  /// Returns a list of [CalendarRefreshResendRecord]s matching the given query parameters.
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
  Future<List<CalendarRefreshResendRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarRefreshResendRecord>(
      where: where?.call(CalendarRefreshResendRecord.t),
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarRefreshResendRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarRefreshResendRecord.t`.
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
  _ida.Stream<List<CalendarRefreshResendRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarRefreshResendRecord>(
      where: where?.call(CalendarRefreshResendRecord.t),
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarRefreshResendRecord] matching the given query parameters.
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
  Future<CalendarRefreshResendRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarRefreshResendRecord>(
      where: where?.call(CalendarRefreshResendRecord.t),
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarRefreshResendRecord] by its [id] or null if no such row exists.
  Future<CalendarRefreshResendRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarRefreshResendRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarRefreshResendRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarRefreshResendRecord]s will have their `id` fields set.
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
  Future<List<CalendarRefreshResendRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarRefreshResendRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarRefreshResendRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarRefreshResendRecord] and returns the inserted row.
  ///
  /// The returned [CalendarRefreshResendRecord] will have its `id` field set.
  Future<CalendarRefreshResendRecord> insertRow(
    _is.DatabaseSession session,
    CalendarRefreshResendRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarRefreshResendRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarRefreshResendRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarRefreshResendRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshResendRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarRefreshResendRecord> rows, {
    required _is.ColumnSelections<CalendarRefreshResendRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarRefreshResendRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarRefreshResendRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarRefreshResendRecord.t),
      updateColumns: updateColumns?.call(CalendarRefreshResendRecord.t),
      updateWhere: updateWhere?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarRefreshResendRecord] and returns the resulting row.
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
  /// The returned [CalendarRefreshResendRecord] will have its `id` field set.
  Future<CalendarRefreshResendRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarRefreshResendRecord row, {
    required _is.ColumnSelections<CalendarRefreshResendRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarRefreshResendRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarRefreshResendRecord>(
      row,
      conflictColumns: conflictColumns(CalendarRefreshResendRecord.t),
      updateColumns: updateColumns?.call(CalendarRefreshResendRecord.t),
      updateWhere: updateWhere?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarRefreshResendRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshResendRecord>> update(
    _is.DatabaseSession session,
    List<CalendarRefreshResendRecord> rows, {
    _is.ColumnSelections<CalendarRefreshResendRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarRefreshResendRecord>(
      rows,
      columns: columns?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarRefreshResendRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarRefreshResendRecord> updateRow(
    _is.DatabaseSession session,
    CalendarRefreshResendRecord row, {
    _is.ColumnSelections<CalendarRefreshResendRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarRefreshResendRecord>(
      row,
      columns: columns?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarRefreshResendRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarRefreshResendRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarRefreshResendRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarRefreshResendRecord>(
      id,
      columnValues: columnValues(CalendarRefreshResendRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarRefreshResendRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarRefreshResendRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarRefreshResendRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarRefreshResendRecord>(
      columnValues: columnValues(CalendarRefreshResendRecord.t.updateTable),
      where: where(CalendarRefreshResendRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarRefreshResendRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarRefreshResendRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarRefreshResendRecord> rows, {
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarRefreshResendRecord>(
      rows,
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarRefreshResendRecord].
  Future<CalendarRefreshResendRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarRefreshResendRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarRefreshResendRecord>(
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
  Future<List<CalendarRefreshResendRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable> where,
    _is.OrderByBuilder<CalendarRefreshResendRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarRefreshResendRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarRefreshResendRecord>(
      where: where(CalendarRefreshResendRecord.t),
      orderBy: orderBy?.call(CalendarRefreshResendRecord.t),
      orderByList: orderByList?.call(CalendarRefreshResendRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarRefreshResendRecord>(
      where: where?.call(CalendarRefreshResendRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarRefreshResendRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarRefreshResendRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarRefreshResendRecord>(
      where: where(CalendarRefreshResendRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
