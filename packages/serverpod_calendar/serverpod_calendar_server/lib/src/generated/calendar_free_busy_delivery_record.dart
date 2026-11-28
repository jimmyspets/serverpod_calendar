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

abstract class CalendarFreeBusyDeliveryRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusyDeliveryRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.commandId,
    this.recipientAddress,
    this.routeRef,
    this.authorityRef,
    required this.generation,
    required this.state,
    int? attemptCount,
    required this.nextAttemptAt,
    this.leaseOwner,
    this.leaseToken,
    int? leaseFence,
    this.leaseUntil,
    required this.createdAt,
    required this.expiresAt,
    this.terminalAt,
    this.providerReceipt,
  }) : attemptCount = attemptCount ?? 0,
       leaseFence = leaseFence ?? 0;

  factory CalendarFreeBusyDeliveryRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    String? recipientAddress,
    String? routeRef,
    String? authorityRef,
    required int generation,
    required String state,
    int? attemptCount,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? terminalAt,
    String? providerReceipt,
  }) = _CalendarFreeBusyDeliveryRecordImpl;

  factory CalendarFreeBusyDeliveryRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyDeliveryRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      recipientAddress: jsonSerialization['recipientAddress'] as String?,
      routeRef: jsonSerialization['routeRef'] as String?,
      authorityRef: jsonSerialization['authorityRef'] as String?,
      generation: jsonSerialization['generation'] as int,
      state: jsonSerialization['state'] as String,
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      providerReceipt: jsonSerialization['providerReceipt'] as String?,
    );
  }

  static final t = CalendarFreeBusyDeliveryRecordTable();

  static const db = CalendarFreeBusyDeliveryRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  _is.UuidValue commandId;

  String? recipientAddress;

  String? routeRef;

  String? authorityRef;

  int generation;

  String state;

  int attemptCount;

  DateTime nextAttemptAt;

  _is.UuidValue? leaseOwner;

  _is.UuidValue? leaseToken;

  int leaseFence;

  DateTime? leaseUntil;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? terminalAt;

  String? providerReceipt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyDeliveryRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    String? recipientAddress,
    String? routeRef,
    String? authorityRef,
    int? generation,
    String? state,
    int? attemptCount,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseOwner = const _is.$UndefinedUuidValue(),
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    int? leaseFence,
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    String? providerReceipt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyDeliveryRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'commandId': commandId.toJson(),
      if (recipientAddress != null) 'recipientAddress': recipientAddress,
      if (routeRef != null) 'routeRef': routeRef,
      if (authorityRef != null) 'authorityRef': authorityRef,
      'generation': generation,
      'state': state,
      'attemptCount': attemptCount,
      'nextAttemptAt': nextAttemptAt.toJson(),
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken?.toJson(),
      'leaseFence': leaseFence,
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (providerReceipt != null) 'providerReceipt': providerReceipt,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusyDeliveryRecordInclude include() {
    return CalendarFreeBusyDeliveryRecordInclude._();
  }

  static CalendarFreeBusyDeliveryRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    CalendarFreeBusyDeliveryRecordInclude? include,
  }) {
    return CalendarFreeBusyDeliveryRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyDeliveryRecordImpl
    extends CalendarFreeBusyDeliveryRecord {
  _CalendarFreeBusyDeliveryRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    String? recipientAddress,
    String? routeRef,
    String? authorityRef,
    required int generation,
    required String state,
    int? attemptCount,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? terminalAt,
    String? providerReceipt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         commandId: commandId,
         recipientAddress: recipientAddress,
         routeRef: routeRef,
         authorityRef: authorityRef,
         generation: generation,
         state: state,
         attemptCount: attemptCount,
         nextAttemptAt: nextAttemptAt,
         leaseOwner: leaseOwner,
         leaseToken: leaseToken,
         leaseFence: leaseFence,
         leaseUntil: leaseUntil,
         createdAt: createdAt,
         expiresAt: expiresAt,
         terminalAt: terminalAt,
         providerReceipt: providerReceipt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyDeliveryRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    Object? recipientAddress = _Undefined,
    Object? routeRef = _Undefined,
    Object? authorityRef = _Undefined,
    int? generation,
    String? state,
    int? attemptCount,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseOwner = const _is.$UndefinedUuidValue(),
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    int? leaseFence,
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    Object? providerReceipt = _Undefined,
  }) {
    return CalendarFreeBusyDeliveryRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      commandId: commandId ?? this.commandId,
      recipientAddress: recipientAddress is String?
          ? recipientAddress
          : this.recipientAddress,
      routeRef: routeRef is String? ? routeRef : this.routeRef,
      authorityRef: authorityRef is String? ? authorityRef : this.authorityRef,
      generation: generation ?? this.generation,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseOwner: leaseOwner is _is.UndefinedSentinel
          ? this.leaseOwner
          : leaseOwner,
      leaseToken: leaseToken is _is.UndefinedSentinel
          ? this.leaseToken
          : leaseToken,
      leaseFence: leaseFence ?? this.leaseFence,
      leaseUntil: leaseUntil is _is.UndefinedSentinel
          ? this.leaseUntil
          : leaseUntil,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
      providerReceipt: providerReceipt is String?
          ? providerReceipt
          : this.providerReceipt,
    );
  }
}

class CalendarFreeBusyDeliveryRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusyDeliveryRecordTable> {
  CalendarFreeBusyDeliveryRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> recipientAddress(String? value) =>
      _is.ColumnValue(
        table.recipientAddress,
        value,
      );

  _is.ColumnValue<String, String> routeRef(String? value) => _is.ColumnValue(
    table.routeRef,
    value,
  );

  _is.ColumnValue<String, String> authorityRef(String? value) =>
      _is.ColumnValue(
        table.authorityRef,
        value,
      );

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> state(String value) => _is.ColumnValue(
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

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
        value,
      );

  _is.ColumnValue<String, String> providerReceipt(String? value) =>
      _is.ColumnValue(
        table.providerReceipt,
        value,
      );
}

class CalendarFreeBusyDeliveryRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusyDeliveryRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_delivery') {
    updateTable = CalendarFreeBusyDeliveryRecordUpdateTable(this);
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
    recipientAddress = _is.ColumnString(
      'recipientAddress',
      this,
    );
    routeRef = _is.ColumnString(
      'routeRef',
      this,
    );
    authorityRef = _is.ColumnString(
      'authorityRef',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    state = _is.ColumnString(
      'state',
      this,
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
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
      this,
    );
    providerReceipt = _is.ColumnString(
      'providerReceipt',
      this,
    );
  }

  late final CalendarFreeBusyDeliveryRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString recipientAddress;

  late final _is.ColumnString routeRef;

  late final _is.ColumnString authorityRef;

  late final _is.ColumnInt generation;

  late final _is.ColumnString state;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnString providerReceipt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    commandId,
    recipientAddress,
    routeRef,
    authorityRef,
    generation,
    state,
    attemptCount,
    nextAttemptAt,
    leaseOwner,
    leaseToken,
    leaseFence,
    leaseUntil,
    createdAt,
    expiresAt,
    terminalAt,
    providerReceipt,
  ];
}

class CalendarFreeBusyDeliveryRecordInclude extends _is.IncludeObject {
  CalendarFreeBusyDeliveryRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyDeliveryRecord.t;
}

class CalendarFreeBusyDeliveryRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusyDeliveryRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusyDeliveryRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyDeliveryRecord.t;
}

class CalendarFreeBusyDeliveryRecordRepository {
  const CalendarFreeBusyDeliveryRecordRepository._();

  /// Returns a list of [CalendarFreeBusyDeliveryRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusyDeliveryRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusyDeliveryRecord>(
      where: where?.call(CalendarFreeBusyDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusyDeliveryRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusyDeliveryRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusyDeliveryRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusyDeliveryRecord>(
      where: where?.call(CalendarFreeBusyDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusyDeliveryRecord] matching the given query parameters.
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
  Future<CalendarFreeBusyDeliveryRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusyDeliveryRecord>(
      where: where?.call(CalendarFreeBusyDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusyDeliveryRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusyDeliveryRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusyDeliveryRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusyDeliveryRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusyDeliveryRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusyDeliveryRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyDeliveryRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusyDeliveryRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusyDeliveryRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusyDeliveryRecord] will have its `id` field set.
  Future<CalendarFreeBusyDeliveryRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusyDeliveryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusyDeliveryRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusyDeliveryRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyDeliveryRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyDeliveryRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusyDeliveryRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusyDeliveryRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyDeliveryRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusyDeliveryRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusyDeliveryRecord] will have its `id` field set.
  Future<CalendarFreeBusyDeliveryRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyDeliveryRecord row, {
    required _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusyDeliveryRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusyDeliveryRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyDeliveryRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyDeliveryRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyDeliveryRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusyDeliveryRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusyDeliveryRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusyDeliveryRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusyDeliveryRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusyDeliveryRecord row, {
    _is.ColumnSelections<CalendarFreeBusyDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusyDeliveryRecord>(
      row,
      columns: columns?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusyDeliveryRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusyDeliveryRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyDeliveryRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusyDeliveryRecord>(
      id,
      columnValues: columnValues(CalendarFreeBusyDeliveryRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyDeliveryRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyDeliveryRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyDeliveryRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusyDeliveryRecord>(
      columnValues: columnValues(CalendarFreeBusyDeliveryRecord.t.updateTable),
      where: where(CalendarFreeBusyDeliveryRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusyDeliveryRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusyDeliveryRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusyDeliveryRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusyDeliveryRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusyDeliveryRecord].
  Future<CalendarFreeBusyDeliveryRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusyDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusyDeliveryRecord>(
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
  Future<List<CalendarFreeBusyDeliveryRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>
    where,
    _is.OrderByBuilder<CalendarFreeBusyDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusyDeliveryRecord>(
      where: where(CalendarFreeBusyDeliveryRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyDeliveryRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusyDeliveryRecord>(
      where: where?.call(CalendarFreeBusyDeliveryRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusyDeliveryRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyDeliveryRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusyDeliveryRecord>(
      where: where(CalendarFreeBusyDeliveryRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
