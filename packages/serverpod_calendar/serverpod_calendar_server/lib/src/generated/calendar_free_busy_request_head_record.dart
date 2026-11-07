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

abstract class CalendarFreeBusyRequestHeadRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusyRequestHeadRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.correlationDigest,
    this.calendarId,
    this.mailboxAddress,
    this.bindingRef,
    this.requesterAddress,
    this.fromUtc,
    this.untilUtc,
    this.currentSourceId,
    required this.sourceRevision,
    required this.replyRevision,
    this.lastReplyStamp,
    this.latestCommandId,
    bool? conflicted,
    required this.createdAt,
    required this.updatedAt,
    this.purgedAt,
    required this.expiresAt,
  }) : conflicted = conflicted ?? false;

  factory CalendarFreeBusyRequestHeadRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String correlationDigest,
    _is.UuidValue? calendarId,
    String? mailboxAddress,
    String? bindingRef,
    String? requesterAddress,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _is.UuidValue? currentSourceId,
    required int sourceRevision,
    required int replyRevision,
    DateTime? lastReplyStamp,
    _is.UuidValue? latestCommandId,
    bool? conflicted,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? purgedAt,
    required DateTime expiresAt,
  }) = _CalendarFreeBusyRequestHeadRecordImpl;

  factory CalendarFreeBusyRequestHeadRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyRequestHeadRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      calendarId: jsonSerialization['calendarId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['calendarId'],
            ),
      mailboxAddress: jsonSerialization['mailboxAddress'] as String?,
      bindingRef: jsonSerialization['bindingRef'] as String?,
      requesterAddress: jsonSerialization['requesterAddress'] as String?,
      fromUtc: jsonSerialization['fromUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['fromUtc']),
      untilUtc: jsonSerialization['untilUtc'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['untilUtc']),
      currentSourceId: jsonSerialization['currentSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentSourceId'],
            ),
      sourceRevision: jsonSerialization['sourceRevision'] as int,
      replyRevision: jsonSerialization['replyRevision'] as int,
      lastReplyStamp: jsonSerialization['lastReplyStamp'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastReplyStamp'],
            ),
      latestCommandId: jsonSerialization['latestCommandId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['latestCommandId'],
            ),
      conflicted: jsonSerialization['conflicted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['conflicted']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      purgedAt: jsonSerialization['purgedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['purgedAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  static final t = CalendarFreeBusyRequestHeadRecordTable();

  static const db = CalendarFreeBusyRequestHeadRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  String correlationDigest;

  _is.UuidValue? calendarId;

  String? mailboxAddress;

  String? bindingRef;

  String? requesterAddress;

  DateTime? fromUtc;

  DateTime? untilUtc;

  _is.UuidValue? currentSourceId;

  int sourceRevision;

  int replyRevision;

  DateTime? lastReplyStamp;

  _is.UuidValue? latestCommandId;

  bool conflicted;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? purgedAt;

  DateTime expiresAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusyRequestHeadRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyRequestHeadRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? correlationDigest,
    _is.UuidValue? calendarId = const _is.$UndefinedUuidValue(),
    String? mailboxAddress,
    String? bindingRef,
    String? requesterAddress,
    DateTime? fromUtc = const _is.$UndefinedDateTime(),
    DateTime? untilUtc = const _is.$UndefinedDateTime(),
    _is.UuidValue? currentSourceId = const _is.$UndefinedUuidValue(),
    int? sourceRevision,
    int? replyRevision,
    DateTime? lastReplyStamp = const _is.$UndefinedDateTime(),
    _is.UuidValue? latestCommandId = const _is.$UndefinedUuidValue(),
    bool? conflicted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyRequestHeadRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'correlationDigest': correlationDigest,
      if (calendarId != null) 'calendarId': calendarId?.toJson(),
      if (mailboxAddress != null) 'mailboxAddress': mailboxAddress,
      if (bindingRef != null) 'bindingRef': bindingRef,
      if (requesterAddress != null) 'requesterAddress': requesterAddress,
      if (fromUtc != null) 'fromUtc': fromUtc?.toJson(),
      if (untilUtc != null) 'untilUtc': untilUtc?.toJson(),
      if (currentSourceId != null) 'currentSourceId': currentSourceId?.toJson(),
      'sourceRevision': sourceRevision,
      'replyRevision': replyRevision,
      if (lastReplyStamp != null) 'lastReplyStamp': lastReplyStamp?.toJson(),
      if (latestCommandId != null) 'latestCommandId': latestCommandId?.toJson(),
      'conflicted': conflicted,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (purgedAt != null) 'purgedAt': purgedAt?.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusyRequestHeadRecordInclude include() {
    return CalendarFreeBusyRequestHeadRecordInclude._();
  }

  static CalendarFreeBusyRequestHeadRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    CalendarFreeBusyRequestHeadRecordInclude? include,
  }) {
    return CalendarFreeBusyRequestHeadRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyRequestHeadRecordImpl
    extends CalendarFreeBusyRequestHeadRecord {
  _CalendarFreeBusyRequestHeadRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required String correlationDigest,
    _is.UuidValue? calendarId,
    String? mailboxAddress,
    String? bindingRef,
    String? requesterAddress,
    DateTime? fromUtc,
    DateTime? untilUtc,
    _is.UuidValue? currentSourceId,
    required int sourceRevision,
    required int replyRevision,
    DateTime? lastReplyStamp,
    _is.UuidValue? latestCommandId,
    bool? conflicted,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? purgedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         correlationDigest: correlationDigest,
         calendarId: calendarId,
         mailboxAddress: mailboxAddress,
         bindingRef: bindingRef,
         requesterAddress: requesterAddress,
         fromUtc: fromUtc,
         untilUtc: untilUtc,
         currentSourceId: currentSourceId,
         sourceRevision: sourceRevision,
         replyRevision: replyRevision,
         lastReplyStamp: lastReplyStamp,
         latestCommandId: latestCommandId,
         conflicted: conflicted,
         createdAt: createdAt,
         updatedAt: updatedAt,
         purgedAt: purgedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyRequestHeadRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyRequestHeadRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    String? correlationDigest,
    _is.UuidValue? calendarId = const _is.$UndefinedUuidValue(),
    Object? mailboxAddress = _Undefined,
    Object? bindingRef = _Undefined,
    Object? requesterAddress = _Undefined,
    DateTime? fromUtc = const _is.$UndefinedDateTime(),
    DateTime? untilUtc = const _is.$UndefinedDateTime(),
    _is.UuidValue? currentSourceId = const _is.$UndefinedUuidValue(),
    int? sourceRevision,
    int? replyRevision,
    DateTime? lastReplyStamp = const _is.$UndefinedDateTime(),
    _is.UuidValue? latestCommandId = const _is.$UndefinedUuidValue(),
    bool? conflicted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? purgedAt = const _is.$UndefinedDateTime(),
    DateTime? expiresAt,
  }) {
    return CalendarFreeBusyRequestHeadRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      calendarId: calendarId is _is.UndefinedSentinel
          ? this.calendarId
          : calendarId,
      mailboxAddress: mailboxAddress is String?
          ? mailboxAddress
          : this.mailboxAddress,
      bindingRef: bindingRef is String? ? bindingRef : this.bindingRef,
      requesterAddress: requesterAddress is String?
          ? requesterAddress
          : this.requesterAddress,
      fromUtc: fromUtc is _is.UndefinedSentinel ? this.fromUtc : fromUtc,
      untilUtc: untilUtc is _is.UndefinedSentinel ? this.untilUtc : untilUtc,
      currentSourceId: currentSourceId is _is.UndefinedSentinel
          ? this.currentSourceId
          : currentSourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      replyRevision: replyRevision ?? this.replyRevision,
      lastReplyStamp: lastReplyStamp is _is.UndefinedSentinel
          ? this.lastReplyStamp
          : lastReplyStamp,
      latestCommandId: latestCommandId is _is.UndefinedSentinel
          ? this.latestCommandId
          : latestCommandId,
      conflicted: conflicted ?? this.conflicted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      purgedAt: purgedAt is _is.UndefinedSentinel ? this.purgedAt : purgedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class CalendarFreeBusyRequestHeadRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusyRequestHeadRecordTable> {
  CalendarFreeBusyRequestHeadRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> ownerKey(String value) => _is.ColumnValue(
    table.ownerKey,
    value,
  );

  _is.ColumnValue<String, String> correlationDigest(String value) =>
      _is.ColumnValue(
        table.correlationDigest,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<String, String> mailboxAddress(String? value) =>
      _is.ColumnValue(
        table.mailboxAddress,
        value,
      );

  _is.ColumnValue<String, String> bindingRef(String? value) => _is.ColumnValue(
    table.bindingRef,
    value,
  );

  _is.ColumnValue<String, String> requesterAddress(String? value) =>
      _is.ColumnValue(
        table.requesterAddress,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> fromUtc(DateTime? value) =>
      _is.ColumnValue(
        table.fromUtc,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> untilUtc(DateTime? value) =>
      _is.ColumnValue(
        table.untilUtc,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> currentSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.currentSourceId,
    value,
  );

  _is.ColumnValue<int, int> sourceRevision(int value) => _is.ColumnValue(
    table.sourceRevision,
    value,
  );

  _is.ColumnValue<int, int> replyRevision(int value) => _is.ColumnValue(
    table.replyRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastReplyStamp(DateTime? value) =>
      _is.ColumnValue(
        table.lastReplyStamp,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> latestCommandId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.latestCommandId,
    value,
  );

  _is.ColumnValue<bool, bool> conflicted(bool value) => _is.ColumnValue(
    table.conflicted,
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

  _is.ColumnValue<DateTime, DateTime> purgedAt(DateTime? value) =>
      _is.ColumnValue(
        table.purgedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );
}

class CalendarFreeBusyRequestHeadRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusyRequestHeadRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_request_head') {
    updateTable = CalendarFreeBusyRequestHeadRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    ownerKey = _is.ColumnString(
      'ownerKey',
      this,
    );
    correlationDigest = _is.ColumnString(
      'correlationDigest',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    mailboxAddress = _is.ColumnString(
      'mailboxAddress',
      this,
    );
    bindingRef = _is.ColumnString(
      'bindingRef',
      this,
    );
    requesterAddress = _is.ColumnString(
      'requesterAddress',
      this,
    );
    fromUtc = _is.ColumnDateTime(
      'fromUtc',
      this,
    );
    untilUtc = _is.ColumnDateTime(
      'untilUtc',
      this,
    );
    currentSourceId = _is.ColumnUuid(
      'currentSourceId',
      this,
    );
    sourceRevision = _is.ColumnInt(
      'sourceRevision',
      this,
    );
    replyRevision = _is.ColumnInt(
      'replyRevision',
      this,
    );
    lastReplyStamp = _is.ColumnDateTime(
      'lastReplyStamp',
      this,
    );
    latestCommandId = _is.ColumnUuid(
      'latestCommandId',
      this,
    );
    conflicted = _is.ColumnBool(
      'conflicted',
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
    purgedAt = _is.ColumnDateTime(
      'purgedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
  }

  late final CalendarFreeBusyRequestHeadRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnString mailboxAddress;

  late final _is.ColumnString bindingRef;

  late final _is.ColumnString requesterAddress;

  late final _is.ColumnDateTime fromUtc;

  late final _is.ColumnDateTime untilUtc;

  late final _is.ColumnUuid currentSourceId;

  late final _is.ColumnInt sourceRevision;

  late final _is.ColumnInt replyRevision;

  late final _is.ColumnDateTime lastReplyStamp;

  late final _is.ColumnUuid latestCommandId;

  late final _is.ColumnBool conflicted;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime purgedAt;

  late final _is.ColumnDateTime expiresAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    correlationDigest,
    calendarId,
    mailboxAddress,
    bindingRef,
    requesterAddress,
    fromUtc,
    untilUtc,
    currentSourceId,
    sourceRevision,
    replyRevision,
    lastReplyStamp,
    latestCommandId,
    conflicted,
    createdAt,
    updatedAt,
    purgedAt,
    expiresAt,
  ];
}

class CalendarFreeBusyRequestHeadRecordInclude extends _is.IncludeObject {
  CalendarFreeBusyRequestHeadRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyRequestHeadRecord.t;
}

class CalendarFreeBusyRequestHeadRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusyRequestHeadRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusyRequestHeadRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyRequestHeadRecord.t;
}

class CalendarFreeBusyRequestHeadRecordRepository {
  const CalendarFreeBusyRequestHeadRecordRepository._();

  /// Returns a list of [CalendarFreeBusyRequestHeadRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusyRequestHeadRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusyRequestHeadRecord>(
      where: where?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusyRequestHeadRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusyRequestHeadRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusyRequestHeadRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusyRequestHeadRecord>(
      where: where?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusyRequestHeadRecord] matching the given query parameters.
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
  Future<CalendarFreeBusyRequestHeadRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusyRequestHeadRecord>(
      where: where?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusyRequestHeadRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusyRequestHeadRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusyRequestHeadRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusyRequestHeadRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusyRequestHeadRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusyRequestHeadRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyRequestHeadRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusyRequestHeadRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusyRequestHeadRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusyRequestHeadRecord] will have its `id` field set.
  Future<CalendarFreeBusyRequestHeadRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyRequestHeadRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusyRequestHeadRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusyRequestHeadRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusyRequestHeadRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyRequestHeadRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyRequestHeadRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusyRequestHeadRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusyRequestHeadRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyRequestHeadRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusyRequestHeadRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusyRequestHeadRecord] will have its `id` field set.
  Future<CalendarFreeBusyRequestHeadRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyRequestHeadRecord row, {
    required _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusyRequestHeadRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusyRequestHeadRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyRequestHeadRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyRequestHeadRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyRequestHeadRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusyRequestHeadRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusyRequestHeadRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusyRequestHeadRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusyRequestHeadRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusyRequestHeadRecord row, {
    _is.ColumnSelections<CalendarFreeBusyRequestHeadRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusyRequestHeadRecord>(
      row,
      columns: columns?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusyRequestHeadRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusyRequestHeadRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyRequestHeadRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusyRequestHeadRecord>(
      id,
      columnValues: columnValues(
        CalendarFreeBusyRequestHeadRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyRequestHeadRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyRequestHeadRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyRequestHeadRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusyRequestHeadRecord>(
      columnValues: columnValues(
        CalendarFreeBusyRequestHeadRecord.t.updateTable,
      ),
      where: where(CalendarFreeBusyRequestHeadRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusyRequestHeadRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusyRequestHeadRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusyRequestHeadRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusyRequestHeadRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusyRequestHeadRecord].
  Future<CalendarFreeBusyRequestHeadRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusyRequestHeadRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusyRequestHeadRecord>(
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
  Future<List<CalendarFreeBusyRequestHeadRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>
    where,
    _is.OrderByBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyRequestHeadRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusyRequestHeadRecord>(
      where: where(CalendarFreeBusyRequestHeadRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyRequestHeadRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyRequestHeadRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusyRequestHeadRecord>(
      where: where?.call(CalendarFreeBusyRequestHeadRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusyRequestHeadRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyRequestHeadRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusyRequestHeadRecord>(
      where: where(CalendarFreeBusyRequestHeadRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
