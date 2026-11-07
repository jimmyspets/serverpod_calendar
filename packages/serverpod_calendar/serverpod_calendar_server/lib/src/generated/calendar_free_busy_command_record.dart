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

abstract class CalendarFreeBusyCommandRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarFreeBusyCommandRecord._({
    this.id,
    required this.scopeKey,
    required this.ownerKey,
    required this.commandId,
    required this.criteriaDigest,
    required this.method,
    required this.action,
    this.sourceId,
    this.calendarId,
    required this.stamp,
    this.timezoneIdentity,
    this.calculationProfile,
    this.parentSettingsDigest,
    this.arguments,
    this.payload,
    required this.payloadDigest,
    required this.byteCount,
    required this.generation,
    required this.receipt,
    required this.createdAt,
    required this.expiresAt,
    this.correlatableUntil,
    this.terminalAt,
    this.scrubbedAt,
  });

  factory CalendarFreeBusyCommandRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    required String criteriaDigest,
    required String method,
    required String action,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    required DateTime stamp,
    String? timezoneIdentity,
    int? calculationProfile,
    String? parentSettingsDigest,
    String? arguments,
    String? payload,
    required String payloadDigest,
    required int byteCount,
    required int generation,
    required String receipt,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? correlatableUntil,
    DateTime? terminalAt,
    DateTime? scrubbedAt,
  }) = _CalendarFreeBusyCommandRecordImpl;

  factory CalendarFreeBusyCommandRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFreeBusyCommandRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      ownerKey: jsonSerialization['ownerKey'] as String,
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      criteriaDigest: jsonSerialization['criteriaDigest'] as String,
      method: jsonSerialization['method'] as String,
      action: jsonSerialization['action'] as String,
      sourceId: jsonSerialization['sourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['sourceId']),
      calendarId: jsonSerialization['calendarId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['calendarId'],
            ),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      timezoneIdentity: jsonSerialization['timezoneIdentity'] as String?,
      calculationProfile: jsonSerialization['calculationProfile'] as int?,
      parentSettingsDigest:
          jsonSerialization['parentSettingsDigest'] as String?,
      arguments: jsonSerialization['arguments'] as String?,
      payload: jsonSerialization['payload'] as String?,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      byteCount: jsonSerialization['byteCount'] as int,
      generation: jsonSerialization['generation'] as int,
      receipt: jsonSerialization['receipt'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      correlatableUntil: jsonSerialization['correlatableUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['correlatableUntil'],
            ),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      scrubbedAt: jsonSerialization['scrubbedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['scrubbedAt']),
    );
  }

  static final t = CalendarFreeBusyCommandRecordTable();

  static const db = CalendarFreeBusyCommandRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String ownerKey;

  _is.UuidValue commandId;

  String criteriaDigest;

  String method;

  String action;

  _is.UuidValue? sourceId;

  _is.UuidValue? calendarId;

  DateTime stamp;

  String? timezoneIdentity;

  int? calculationProfile;

  String? parentSettingsDigest;

  String? arguments;

  String? payload;

  String payloadDigest;

  int byteCount;

  int generation;

  String receipt;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? correlatableUntil;

  DateTime? terminalAt;

  DateTime? scrubbedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarFreeBusyCommandRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFreeBusyCommandRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    String? criteriaDigest,
    String? method,
    String? action,
    _is.UuidValue? sourceId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? calendarId = const _is.$UndefinedUuidValue(),
    DateTime? stamp,
    String? timezoneIdentity,
    int? calculationProfile,
    String? parentSettingsDigest,
    String? arguments,
    String? payload,
    String? payloadDigest,
    int? byteCount,
    int? generation,
    String? receipt,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? correlatableUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    DateTime? scrubbedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarFreeBusyCommandRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'ownerKey': ownerKey,
      'commandId': commandId.toJson(),
      'criteriaDigest': criteriaDigest,
      'method': method,
      'action': action,
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      if (calendarId != null) 'calendarId': calendarId?.toJson(),
      'stamp': stamp.toJson(),
      if (timezoneIdentity != null) 'timezoneIdentity': timezoneIdentity,
      if (calculationProfile != null) 'calculationProfile': calculationProfile,
      if (parentSettingsDigest != null)
        'parentSettingsDigest': parentSettingsDigest,
      if (arguments != null) 'arguments': arguments,
      if (payload != null) 'payload': payload,
      'payloadDigest': payloadDigest,
      'byteCount': byteCount,
      'generation': generation,
      'receipt': receipt,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (correlatableUntil != null)
        'correlatableUntil': correlatableUntil?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (scrubbedAt != null) 'scrubbedAt': scrubbedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFreeBusyCommandRecordInclude include() {
    return CalendarFreeBusyCommandRecordInclude._();
  }

  static CalendarFreeBusyCommandRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    CalendarFreeBusyCommandRecordInclude? include,
  }) {
    return CalendarFreeBusyCommandRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFreeBusyCommandRecordImpl extends CalendarFreeBusyCommandRecord {
  _CalendarFreeBusyCommandRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String ownerKey,
    required _is.UuidValue commandId,
    required String criteriaDigest,
    required String method,
    required String action,
    _is.UuidValue? sourceId,
    _is.UuidValue? calendarId,
    required DateTime stamp,
    String? timezoneIdentity,
    int? calculationProfile,
    String? parentSettingsDigest,
    String? arguments,
    String? payload,
    required String payloadDigest,
    required int byteCount,
    required int generation,
    required String receipt,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? correlatableUntil,
    DateTime? terminalAt,
    DateTime? scrubbedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         ownerKey: ownerKey,
         commandId: commandId,
         criteriaDigest: criteriaDigest,
         method: method,
         action: action,
         sourceId: sourceId,
         calendarId: calendarId,
         stamp: stamp,
         timezoneIdentity: timezoneIdentity,
         calculationProfile: calculationProfile,
         parentSettingsDigest: parentSettingsDigest,
         arguments: arguments,
         payload: payload,
         payloadDigest: payloadDigest,
         byteCount: byteCount,
         generation: generation,
         receipt: receipt,
         createdAt: createdAt,
         expiresAt: expiresAt,
         correlatableUntil: correlatableUntil,
         terminalAt: terminalAt,
         scrubbedAt: scrubbedAt,
       );

  /// Returns a shallow copy of this [CalendarFreeBusyCommandRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFreeBusyCommandRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? ownerKey,
    _is.UuidValue? commandId,
    String? criteriaDigest,
    String? method,
    String? action,
    _is.UuidValue? sourceId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? calendarId = const _is.$UndefinedUuidValue(),
    DateTime? stamp,
    Object? timezoneIdentity = _Undefined,
    Object? calculationProfile = _Undefined,
    Object? parentSettingsDigest = _Undefined,
    Object? arguments = _Undefined,
    Object? payload = _Undefined,
    String? payloadDigest,
    int? byteCount,
    int? generation,
    String? receipt,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? correlatableUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    DateTime? scrubbedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarFreeBusyCommandRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      ownerKey: ownerKey ?? this.ownerKey,
      commandId: commandId ?? this.commandId,
      criteriaDigest: criteriaDigest ?? this.criteriaDigest,
      method: method ?? this.method,
      action: action ?? this.action,
      sourceId: sourceId is _is.UndefinedSentinel ? this.sourceId : sourceId,
      calendarId: calendarId is _is.UndefinedSentinel
          ? this.calendarId
          : calendarId,
      stamp: stamp ?? this.stamp,
      timezoneIdentity: timezoneIdentity is String?
          ? timezoneIdentity
          : this.timezoneIdentity,
      calculationProfile: calculationProfile is int?
          ? calculationProfile
          : this.calculationProfile,
      parentSettingsDigest: parentSettingsDigest is String?
          ? parentSettingsDigest
          : this.parentSettingsDigest,
      arguments: arguments is String? ? arguments : this.arguments,
      payload: payload is String? ? payload : this.payload,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      byteCount: byteCount ?? this.byteCount,
      generation: generation ?? this.generation,
      receipt: receipt ?? this.receipt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      correlatableUntil: correlatableUntil is _is.UndefinedSentinel
          ? this.correlatableUntil
          : correlatableUntil,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
      scrubbedAt: scrubbedAt is _is.UndefinedSentinel
          ? this.scrubbedAt
          : scrubbedAt,
    );
  }
}

class CalendarFreeBusyCommandRecordUpdateTable
    extends _is.UpdateTable<CalendarFreeBusyCommandRecordTable> {
  CalendarFreeBusyCommandRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> criteriaDigest(String value) =>
      _is.ColumnValue(
        table.criteriaDigest,
        value,
      );

  _is.ColumnValue<String, String> method(String value) => _is.ColumnValue(
    table.method,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.sourceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
    value,
  );

  _is.ColumnValue<String, String> timezoneIdentity(String? value) =>
      _is.ColumnValue(
        table.timezoneIdentity,
        value,
      );

  _is.ColumnValue<int, int> calculationProfile(int? value) => _is.ColumnValue(
    table.calculationProfile,
    value,
  );

  _is.ColumnValue<String, String> parentSettingsDigest(String? value) =>
      _is.ColumnValue(
        table.parentSettingsDigest,
        value,
      );

  _is.ColumnValue<String, String> arguments(String? value) => _is.ColumnValue(
    table.arguments,
    value,
  );

  _is.ColumnValue<String, String> payload(String? value) => _is.ColumnValue(
    table.payload,
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

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> receipt(String value) => _is.ColumnValue(
    table.receipt,
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

  _is.ColumnValue<DateTime, DateTime> correlatableUntil(DateTime? value) =>
      _is.ColumnValue(
        table.correlatableUntil,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> scrubbedAt(DateTime? value) =>
      _is.ColumnValue(
        table.scrubbedAt,
        value,
      );
}

class CalendarFreeBusyCommandRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarFreeBusyCommandRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_fb_command') {
    updateTable = CalendarFreeBusyCommandRecordUpdateTable(this);
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
    criteriaDigest = _is.ColumnString(
      'criteriaDigest',
      this,
    );
    method = _is.ColumnString(
      'method',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
      this,
    );
    timezoneIdentity = _is.ColumnString(
      'timezoneIdentity',
      this,
    );
    calculationProfile = _is.ColumnInt(
      'calculationProfile',
      this,
    );
    parentSettingsDigest = _is.ColumnString(
      'parentSettingsDigest',
      this,
    );
    arguments = _is.ColumnString(
      'arguments',
      this,
    );
    payload = _is.ColumnString(
      'payload',
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
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    receipt = _is.ColumnString(
      'receipt',
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
    correlatableUntil = _is.ColumnDateTime(
      'correlatableUntil',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
      this,
    );
    scrubbedAt = _is.ColumnDateTime(
      'scrubbedAt',
      this,
    );
  }

  late final CalendarFreeBusyCommandRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString ownerKey;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString criteriaDigest;

  late final _is.ColumnString method;

  late final _is.ColumnString action;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString timezoneIdentity;

  late final _is.ColumnInt calculationProfile;

  late final _is.ColumnString parentSettingsDigest;

  late final _is.ColumnString arguments;

  late final _is.ColumnString payload;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnInt generation;

  late final _is.ColumnString receipt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime correlatableUntil;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnDateTime scrubbedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    ownerKey,
    commandId,
    criteriaDigest,
    method,
    action,
    sourceId,
    calendarId,
    stamp,
    timezoneIdentity,
    calculationProfile,
    parentSettingsDigest,
    arguments,
    payload,
    payloadDigest,
    byteCount,
    generation,
    receipt,
    createdAt,
    expiresAt,
    correlatableUntil,
    terminalAt,
    scrubbedAt,
  ];
}

class CalendarFreeBusyCommandRecordInclude extends _is.IncludeObject {
  CalendarFreeBusyCommandRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyCommandRecord.t;
}

class CalendarFreeBusyCommandRecordIncludeList extends _is.IncludeList {
  CalendarFreeBusyCommandRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFreeBusyCommandRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarFreeBusyCommandRecord.t;
}

class CalendarFreeBusyCommandRecordRepository {
  const CalendarFreeBusyCommandRecordRepository._();

  /// Returns a list of [CalendarFreeBusyCommandRecord]s matching the given query parameters.
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
  Future<List<CalendarFreeBusyCommandRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFreeBusyCommandRecord>(
      where: where?.call(CalendarFreeBusyCommandRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarFreeBusyCommandRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarFreeBusyCommandRecord.t`.
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
  _ida.Stream<List<CalendarFreeBusyCommandRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarFreeBusyCommandRecord>(
      where: where?.call(CalendarFreeBusyCommandRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarFreeBusyCommandRecord] matching the given query parameters.
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
  Future<CalendarFreeBusyCommandRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFreeBusyCommandRecord>(
      where: where?.call(CalendarFreeBusyCommandRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFreeBusyCommandRecord] by its [id] or null if no such row exists.
  Future<CalendarFreeBusyCommandRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFreeBusyCommandRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFreeBusyCommandRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFreeBusyCommandRecord]s will have their `id` fields set.
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
  Future<List<CalendarFreeBusyCommandRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyCommandRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFreeBusyCommandRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFreeBusyCommandRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFreeBusyCommandRecord] will have its `id` field set.
  Future<CalendarFreeBusyCommandRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyCommandRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFreeBusyCommandRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFreeBusyCommandRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFreeBusyCommandRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyCommandRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFreeBusyCommandRecord> rows, {
    required _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFreeBusyCommandRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFreeBusyCommandRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyCommandRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFreeBusyCommandRecord] and returns the resulting row.
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
  /// The returned [CalendarFreeBusyCommandRecord] will have its `id` field set.
  Future<CalendarFreeBusyCommandRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFreeBusyCommandRecord row, {
    required _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFreeBusyCommandRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFreeBusyCommandRecord.t),
      updateColumns: updateColumns?.call(CalendarFreeBusyCommandRecord.t),
      updateWhere: updateWhere?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyCommandRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyCommandRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFreeBusyCommandRecord> rows, {
    _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFreeBusyCommandRecord>(
      rows,
      columns: columns?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFreeBusyCommandRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFreeBusyCommandRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFreeBusyCommandRecord row, {
    _is.ColumnSelections<CalendarFreeBusyCommandRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFreeBusyCommandRecord>(
      row,
      columns: columns?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFreeBusyCommandRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFreeBusyCommandRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyCommandRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFreeBusyCommandRecord>(
      id,
      columnValues: columnValues(CalendarFreeBusyCommandRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFreeBusyCommandRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFreeBusyCommandRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarFreeBusyCommandRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFreeBusyCommandRecord>(
      columnValues: columnValues(CalendarFreeBusyCommandRecord.t.updateTable),
      where: where(CalendarFreeBusyCommandRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFreeBusyCommandRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFreeBusyCommandRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFreeBusyCommandRecord> rows, {
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFreeBusyCommandRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFreeBusyCommandRecord].
  Future<CalendarFreeBusyCommandRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFreeBusyCommandRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFreeBusyCommandRecord>(
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
  Future<List<CalendarFreeBusyCommandRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>
    where,
    _is.OrderByBuilder<CalendarFreeBusyCommandRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFreeBusyCommandRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFreeBusyCommandRecord>(
      where: where(CalendarFreeBusyCommandRecord.t),
      orderBy: orderBy?.call(CalendarFreeBusyCommandRecord.t),
      orderByList: orderByList?.call(CalendarFreeBusyCommandRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFreeBusyCommandRecord>(
      where: where?.call(CalendarFreeBusyCommandRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFreeBusyCommandRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFreeBusyCommandRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFreeBusyCommandRecord>(
      where: where(CalendarFreeBusyCommandRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
