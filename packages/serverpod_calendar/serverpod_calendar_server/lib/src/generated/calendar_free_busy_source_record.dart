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

abstract class CalendarFreeBusySourceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusySourceRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.method,
    this.headId,
    this.requestCommandId,
    required this.payloadDigest,
    required this.byteCount,
    this.payload,
    this.header,
    this.originRef,
    this.bindingRef,
    this.mailboxAddress,
    required this.sourceStamp,
    required this.receivedAt,
    required this.expiresAt,
    this.dismissedAt,
    this.purgedAt,
  });

  factory CalendarFreeBusySourceRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String method,
    _is.UuidValue? headId,
    _is.UuidValue? requestCommandId,
    required String payloadDigest,
    required int byteCount,
    String? payload,
    String? header,
    String? originRef,
    String? bindingRef,
    String? mailboxAddress,
    required DateTime sourceStamp,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
    DateTime? purgedAt,
  }) = _CalendarFreeBusySourceRecordImpl;

  factory CalendarFreeBusySourceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusySourceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      method: jsonSerialization['method'] as String,
      headId: jsonSerialization['headId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['headId']),
      requestCommandId: jsonSerialization['requestCommandId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['requestCommandId'],
            ),
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      byteCount: jsonSerialization['byteCount'] as int,
      payload: jsonSerialization['payload'] as String?,
      header: jsonSerialization['header'] as String?,
      originRef: jsonSerialization['originRef'] as String?,
      bindingRef: jsonSerialization['bindingRef'] as String?,
      mailboxAddress: jsonSerialization['mailboxAddress'] as String?,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
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
      purgedAt: jsonSerialization['purgedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['purgedAt']),
    );
  }

  static final t = CalendarFreeBusySourceRecordTable();

  static const db = CalendarFreeBusySourceRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  String method;

  _is.UuidValue? headId;

  _is.UuidValue? requestCommandId;

  String payloadDigest;

  int byteCount;

  String? payload;

  String? header;

  String? originRef;

  String? bindingRef;

  String? mailboxAddress;

  DateTime sourceStamp;

  DateTime receivedAt;

  DateTime expiresAt;

  DateTime? dismissedAt;

  DateTime? purgedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusySourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusySourceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? method,
    _is.UuidValue? headId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? requestCommandId = const _is.$UndefinedUuidValue(),
    String? payloadDigest,
    int? byteCount,
    String? payload,
    String? header,
    String? originRef,
    String? bindingRef,
    String? mailboxAddress,
    DateTime? sourceStamp,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusySourceRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'method': method,
      if (headId != null) 'headId': headId?.toJson(),
      if (requestCommandId != null)
        'requestCommandId': requestCommandId?.toJson(),
      'payloadDigest': payloadDigest,
      'byteCount': byteCount,
      if (payload != null) 'payload': payload,
      if (header != null) 'header': header,
      if (originRef != null) 'originRef': originRef,
      if (bindingRef != null) 'bindingRef': bindingRef,
      if (mailboxAddress != null) 'mailboxAddress': mailboxAddress,
      'sourceStamp': sourceStamp.toJson(),
      'receivedAt': receivedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
      if (purgedAt != null) 'purgedAt': purgedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusySourceRecordInclude include() {
    return CalendarFreeBusySourceRecordInclude._();
  }

  static CalendarFreeBusySourceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    CalendarFreeBusySourceRecordInclude? include,
  }) {
    return CalendarFreeBusySourceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusySourceRecordImpl extends CalendarFreeBusySourceRecord {
  _CalendarFreeBusySourceRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String method,
    _is.UuidValue? headId,
    _is.UuidValue? requestCommandId,
    required String payloadDigest,
    required int byteCount,
    String? payload,
    String? header,
    String? originRef,
    String? bindingRef,
    String? mailboxAddress,
    required DateTime sourceStamp,
    required DateTime receivedAt,
    required DateTime expiresAt,
    DateTime? dismissedAt,
    DateTime? purgedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         method: method,
         headId: headId,
         requestCommandId: requestCommandId,
         payloadDigest: payloadDigest,
         byteCount: byteCount,
         payload: payload,
         header: header,
         originRef: originRef,
         bindingRef: bindingRef,
         mailboxAddress: mailboxAddress,
         sourceStamp: sourceStamp,
         receivedAt: receivedAt,
         expiresAt: expiresAt,
         dismissedAt: dismissedAt,
         purgedAt: purgedAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusySourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusySourceRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? method,
    _is.UuidValue? headId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? requestCommandId = const _is.$UndefinedUuidValue(),
    String? payloadDigest,
    int? byteCount,
    Object? payload = _Undefined,
    Object? header = _Undefined,
    Object? originRef = _Undefined,
    Object? bindingRef = _Undefined,
    Object? mailboxAddress = _Undefined,
    DateTime? sourceStamp,
    DateTime? receivedAt,
    DateTime? expiresAt,
    DateTime? dismissedAt = const _is.$UndefinedDateTime(),
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarFreeBusySourceRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      method: method ?? this.method,
      headId: headId is _is.UndefinedSentinel ? this.headId : headId,
      requestCommandId: requestCommandId is _is.UndefinedSentinel
          ? this.requestCommandId
          : requestCommandId,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      byteCount: byteCount ?? this.byteCount,
      payload: payload is String? ? payload : this.payload,
      header: header is String? ? header : this.header,
      originRef: originRef is String? ? originRef : this.originRef,
      bindingRef: bindingRef is String? ? bindingRef : this.bindingRef,
      mailboxAddress: mailboxAddress is String?
          ? mailboxAddress
          : this.mailboxAddress,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      dismissedAt: dismissedAt is _is.UndefinedSentinel
          ? this.dismissedAt
          : dismissedAt,
      purgedAt: purgedAt is _is.UndefinedSentinel ? this.purgedAt : purgedAt,
    );
  }
}

class CalendarFreeBusySourceRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusySourceRecordTable> {
  CalendarFreeBusySourceRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> ownerKey(String value) => _is.ColumnValue(
    table.ownerKey,
    value,
  );

  _is.ColumnValue<String, String> method(String value) => _is.ColumnValue(
    table.method,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> headId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.headId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> requestCommandId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.requestCommandId,
    value,
  );

  _is.ColumnValue<String, String> payloadDigest(String value) =>
      _is.ColumnValue(
        table.payloadDigest,
        value,
      );

  _is.ColumnValue<int, int> byteCount(int value) => _is.ColumnValue(
    table.byteCount,
    value,
  );

  _is.ColumnValue<String, String> payload(String? value) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<String, String> header(String? value) => _is.ColumnValue(
    table.header,
    value,
  );

  _is.ColumnValue<String, String> originRef(String? value) => _is.ColumnValue(
    table.originRef,
    value,
  );

  _is.ColumnValue<String, String> bindingRef(String? value) => _is.ColumnValue(
    table.bindingRef,
    value,
  );

  _is.ColumnValue<String, String> mailboxAddress(String? value) =>
      _is.ColumnValue(
        table.mailboxAddress,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sourceStamp(DateTime value) =>
      _is.ColumnValue(
        table.sourceStamp,
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

  _is.ColumnValue<DateTime, DateTime> purgedAt(DateTime? value) =>
      _is.ColumnValue(
        table.purgedAt,
        value,
      );
}

class CalendarFreeBusySourceRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusySourceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_source') {
    updateTable = CalendarFreeBusySourceRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    ownerKey = _is.ColumnString(
      'ownerKey',
      this,
    );
    method = _is.ColumnString(
      'method',
      this,
    );
    headId = _is.ColumnUuid(
      'headId',
      this,
    );
    requestCommandId = _is.ColumnUuid(
      'requestCommandId',
      this,
    );
    payloadDigest = _is.ColumnString(
      'payloadDigest',
      this,
    );
    byteCount = _is.ColumnInt(
      'byteCount',
      this,
    );
    payload = _is.ColumnString(
      'payload',
      this,
    );
    header = _is.ColumnString(
      'header',
      this,
    );
    originRef = _is.ColumnString(
      'originRef',
      this,
    );
    bindingRef = _is.ColumnString(
      'bindingRef',
      this,
    );
    mailboxAddress = _is.ColumnString(
      'mailboxAddress',
      this,
    );
    sourceStamp = _is.ColumnDateTime(
      'sourceStamp',
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
    purgedAt = _is.ColumnDateTime(
      'purgedAt',
      this,
    );
  }

  late final CalendarFreeBusySourceRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnString method;

  late final _is.ColumnUuid headId;

  late final _is.ColumnUuid requestCommandId;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnString payload;

  late final _is.ColumnString header;

  late final _is.ColumnString originRef;

  late final _is.ColumnString bindingRef;

  late final _is.ColumnString mailboxAddress;

  late final _is.ColumnDateTime sourceStamp;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime dismissedAt;

  late final _is.ColumnDateTime purgedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    method,
    headId,
    requestCommandId,
    payloadDigest,
    byteCount,
    payload,
    header,
    originRef,
    bindingRef,
    mailboxAddress,
    sourceStamp,
    receivedAt,
    expiresAt,
    dismissedAt,
    purgedAt,
  ];
}

class CalendarFreeBusySourceRecordInclude extends _is.IncludeObject {
  CalendarFreeBusySourceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusySourceRecord.t;
}

class CalendarFreeBusySourceRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusySourceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusySourceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusySourceRecord.t;
}

class CalendarFreeBusySourceRecordRepository {
  const CalendarFreeBusySourceRecordRepository._();

  /// Returns a list of [CalendarFreeBusySourceRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusySourceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusySourceRecord>(
      where: where?.call(CalendarFreeBusySourceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusySourceRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusySourceRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusySourceRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusySourceRecord>(
      where: where?.call(CalendarFreeBusySourceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusySourceRecord] matching the given query parameters.
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
  Future<CalendarFreeBusySourceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusySourceRecord>(
      where: where?.call(CalendarFreeBusySourceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusySourceRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusySourceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusySourceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusySourceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusySourceRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusySourceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusySourceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusySourceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusySourceRecord] will have its `id` field set.
  Future<CalendarFreeBusySourceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusySourceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusySourceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusySourceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusySourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusySourceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusySourceRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusySourceRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusySourceRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusySourceRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusySourceRecord] will have its `id` field set.
  Future<CalendarFreeBusySourceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceRecord row, {
    required _is.ColumnSelections<CalendarFreeBusySourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusySourceRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusySourceRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusySourceRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusySourceRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusySourceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusySourceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusySourceRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusySourceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusySourceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceRecord row, {
    _is.ColumnSelections<CalendarFreeBusySourceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusySourceRecord>(
      row,
      columns: columns?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusySourceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusySourceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarFreeBusySourceRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusySourceRecord>(
      id,
      columnValues: columnValues(CalendarFreeBusySourceRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusySourceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusySourceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarFreeBusySourceRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusySourceRecord>(
      columnValues: columnValues(CalendarFreeBusySourceRecord.t.updateTable),
      where: where(CalendarFreeBusySourceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusySourceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusySourceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusySourceRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusySourceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusySourceRecord].
  Future<CalendarFreeBusySourceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusySourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusySourceRecord>(
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
  Future<List<CalendarFreeBusySourceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>
    where,
    _is.OrderByBuilder<CalendarFreeBusySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusySourceRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusySourceRecord>(
      where: where(CalendarFreeBusySourceRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusySourceRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusySourceRecord>(
      where: where?.call(CalendarFreeBusySourceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusySourceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusySourceRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusySourceRecord>(
      where: where(CalendarFreeBusySourceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
