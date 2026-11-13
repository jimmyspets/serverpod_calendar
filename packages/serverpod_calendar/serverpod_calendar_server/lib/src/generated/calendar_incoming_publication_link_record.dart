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

abstract class CalendarIncomingPublicationLinkRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarIncomingPublicationLinkRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.entryId,
    required this.correlationDigest,
    required this.calendarId,
    required this.eventId,
    this.creationSourceId,
    required this.creationActorId,
    required this.creationCommandId,
    required this.creationDigest,
    required this.creationReceipt,
    this.acceptedSourceId,
    this.basisSourceId,
    this.baselineDigest,
    this.acceptedAt,
    this.lastActorId,
    this.lastCommandId,
    this.lastCommandDigest,
    this.lastReceipt,
    this.deletedAt,
  });

  factory CalendarIncomingPublicationLinkRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required String correlationDigest,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    _is.UuidValue? creationSourceId,
    required String creationActorId,
    required _is.UuidValue creationCommandId,
    required String creationDigest,
    required String creationReceipt,
    _is.UuidValue? acceptedSourceId,
    _is.UuidValue? basisSourceId,
    String? baselineDigest,
    DateTime? acceptedAt,
    String? lastActorId,
    _is.UuidValue? lastCommandId,
    String? lastCommandDigest,
    String? lastReceipt,
    DateTime? deletedAt,
  }) = _CalendarIncomingPublicationLinkRecordImpl;

  factory CalendarIncomingPublicationLinkRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarIncomingPublicationLinkRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      creationSourceId: jsonSerialization['creationSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['creationSourceId'],
            ),
      creationActorId: jsonSerialization['creationActorId'] as String,
      creationCommandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['creationCommandId'],
      ),
      creationDigest: jsonSerialization['creationDigest'] as String,
      creationReceipt: jsonSerialization['creationReceipt'] as String,
      acceptedSourceId: jsonSerialization['acceptedSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['acceptedSourceId'],
            ),
      basisSourceId: jsonSerialization['basisSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['basisSourceId'],
            ),
      baselineDigest: jsonSerialization['baselineDigest'] as String?,
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      lastActorId: jsonSerialization['lastActorId'] as String?,
      lastCommandId: jsonSerialization['lastCommandId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['lastCommandId'],
            ),
      lastCommandDigest: jsonSerialization['lastCommandDigest'] as String?,
      lastReceipt: jsonSerialization['lastReceipt'] as String?,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = CalendarIncomingPublicationLinkRecordTable();

  static const db = CalendarIncomingPublicationLinkRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  _is.UuidValue entryId;

  String correlationDigest;

  _is.UuidValue calendarId;

  _is.UuidValue eventId;

  _is.UuidValue? creationSourceId;

  String creationActorId;

  _is.UuidValue creationCommandId;

  String creationDigest;

  String creationReceipt;

  _is.UuidValue? acceptedSourceId;

  _is.UuidValue? basisSourceId;

  String? baselineDigest;

  DateTime? acceptedAt;

  String? lastActorId;

  _is.UuidValue? lastCommandId;

  String? lastCommandDigest;

  String? lastReceipt;

  DateTime? deletedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarIncomingPublicationLinkRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarIncomingPublicationLinkRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    String? correlationDigest,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    _is.UuidValue? creationSourceId = const _is.$UndefinedUuidValue(),
    String? creationActorId,
    _is.UuidValue? creationCommandId,
    String? creationDigest,
    String? creationReceipt,
    _is.UuidValue? acceptedSourceId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? basisSourceId = const _is.$UndefinedUuidValue(),
    String? baselineDigest,
    DateTime? acceptedAt = const _is.$UndefinedDateTime(),
    String? lastActorId,
    _is.UuidValue? lastCommandId = const _is.$UndefinedUuidValue(),
    String? lastCommandDigest,
    String? lastReceipt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarIncomingPublicationLinkRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'entryId': entryId.toJson(),
      'correlationDigest': correlationDigest,
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      if (creationSourceId != null)
        'creationSourceId': creationSourceId?.toJson(),
      'creationActorId': creationActorId,
      'creationCommandId': creationCommandId.toJson(),
      'creationDigest': creationDigest,
      'creationReceipt': creationReceipt,
      if (acceptedSourceId != null)
        'acceptedSourceId': acceptedSourceId?.toJson(),
      if (basisSourceId != null) 'basisSourceId': basisSourceId?.toJson(),
      if (baselineDigest != null) 'baselineDigest': baselineDigest,
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (lastActorId != null) 'lastActorId': lastActorId,
      if (lastCommandId != null) 'lastCommandId': lastCommandId?.toJson(),
      if (lastCommandDigest != null) 'lastCommandDigest': lastCommandDigest,
      if (lastReceipt != null) 'lastReceipt': lastReceipt,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarIncomingPublicationLinkRecordInclude include() {
    return CalendarIncomingPublicationLinkRecordInclude._();
  }

  static CalendarIncomingPublicationLinkRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    CalendarIncomingPublicationLinkRecordInclude? include,
  }) {
    return CalendarIncomingPublicationLinkRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarIncomingPublicationLinkRecordImpl
    extends CalendarIncomingPublicationLinkRecord {
  _CalendarIncomingPublicationLinkRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required String correlationDigest,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    _is.UuidValue? creationSourceId,
    required String creationActorId,
    required _is.UuidValue creationCommandId,
    required String creationDigest,
    required String creationReceipt,
    _is.UuidValue? acceptedSourceId,
    _is.UuidValue? basisSourceId,
    String? baselineDigest,
    DateTime? acceptedAt,
    String? lastActorId,
    _is.UuidValue? lastCommandId,
    String? lastCommandDigest,
    String? lastReceipt,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         entryId: entryId,
         correlationDigest: correlationDigest,
         calendarId: calendarId,
         eventId: eventId,
         creationSourceId: creationSourceId,
         creationActorId: creationActorId,
         creationCommandId: creationCommandId,
         creationDigest: creationDigest,
         creationReceipt: creationReceipt,
         acceptedSourceId: acceptedSourceId,
         basisSourceId: basisSourceId,
         baselineDigest: baselineDigest,
         acceptedAt: acceptedAt,
         lastActorId: lastActorId,
         lastCommandId: lastCommandId,
         lastCommandDigest: lastCommandDigest,
         lastReceipt: lastReceipt,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [CalendarIncomingPublicationLinkRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarIncomingPublicationLinkRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    String? correlationDigest,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    _is.UuidValue? creationSourceId = const _is.$UndefinedUuidValue(),
    String? creationActorId,
    _is.UuidValue? creationCommandId,
    String? creationDigest,
    String? creationReceipt,
    _is.UuidValue? acceptedSourceId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? basisSourceId = const _is.$UndefinedUuidValue(),
    Object? baselineDigest = _Undefined,
    DateTime? acceptedAt = const _is.$UndefinedDateTime(),
    Object? lastActorId = _Undefined,
    _is.UuidValue? lastCommandId = const _is.$UndefinedUuidValue(),
    Object? lastCommandDigest = _Undefined,
    Object? lastReceipt = _Undefined,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
  }) {
    return CalendarIncomingPublicationLinkRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      entryId: entryId ?? this.entryId,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      creationSourceId: creationSourceId is _is.UndefinedSentinel
          ? this.creationSourceId
          : creationSourceId,
      creationActorId: creationActorId ?? this.creationActorId,
      creationCommandId: creationCommandId ?? this.creationCommandId,
      creationDigest: creationDigest ?? this.creationDigest,
      creationReceipt: creationReceipt ?? this.creationReceipt,
      acceptedSourceId: acceptedSourceId is _is.UndefinedSentinel
          ? this.acceptedSourceId
          : acceptedSourceId,
      basisSourceId: basisSourceId is _is.UndefinedSentinel
          ? this.basisSourceId
          : basisSourceId,
      baselineDigest: baselineDigest is String?
          ? baselineDigest
          : this.baselineDigest,
      acceptedAt: acceptedAt is _is.UndefinedSentinel
          ? this.acceptedAt
          : acceptedAt,
      lastActorId: lastActorId is String? ? lastActorId : this.lastActorId,
      lastCommandId: lastCommandId is _is.UndefinedSentinel
          ? this.lastCommandId
          : lastCommandId,
      lastCommandDigest: lastCommandDigest is String?
          ? lastCommandDigest
          : this.lastCommandDigest,
      lastReceipt: lastReceipt is String? ? lastReceipt : this.lastReceipt,
      deletedAt: deletedAt is _is.UndefinedSentinel
          ? this.deletedAt
          : deletedAt,
    );
  }
}

class CalendarIncomingPublicationLinkRecordUpdateTable
    extends _is.UpdateTable<CalendarIncomingPublicationLinkRecordTable> {
  CalendarIncomingPublicationLinkRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entryId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entryId,
        value,
      );

  _is.ColumnValue<String, String> correlationDigest(String value) =>
      _is.ColumnValue(
        table.correlationDigest,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> eventId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.eventId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> creationSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.creationSourceId,
    value,
  );

  _is.ColumnValue<String, String> creationActorId(String value) =>
      _is.ColumnValue(
        table.creationActorId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> creationCommandId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.creationCommandId,
    value,
  );

  _is.ColumnValue<String, String> creationDigest(String value) =>
      _is.ColumnValue(
        table.creationDigest,
        value,
      );

  _is.ColumnValue<String, String> creationReceipt(String value) =>
      _is.ColumnValue(
        table.creationReceipt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> acceptedSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.acceptedSourceId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> basisSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.basisSourceId,
    value,
  );

  _is.ColumnValue<String, String> baselineDigest(String? value) =>
      _is.ColumnValue(
        table.baselineDigest,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _is.ColumnValue(
        table.acceptedAt,
        value,
      );

  _is.ColumnValue<String, String> lastActorId(String? value) => _is.ColumnValue(
    table.lastActorId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> lastCommandId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.lastCommandId,
    value,
  );

  _is.ColumnValue<String, String> lastCommandDigest(String? value) =>
      _is.ColumnValue(
        table.lastCommandDigest,
        value,
      );

  _is.ColumnValue<String, String> lastReceipt(String? value) => _is.ColumnValue(
    table.lastReceipt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );
}

class CalendarIncomingPublicationLinkRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarIncomingPublicationLinkRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_incoming_publication_link') {
    updateTable = CalendarIncomingPublicationLinkRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    entryId = _is.ColumnUuid(
      'entryId',
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
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    creationSourceId = _is.ColumnUuid(
      'creationSourceId',
      this,
    );
    creationActorId = _is.ColumnString(
      'creationActorId',
      this,
    );
    creationCommandId = _is.ColumnUuid(
      'creationCommandId',
      this,
    );
    creationDigest = _is.ColumnString(
      'creationDigest',
      this,
    );
    creationReceipt = _is.ColumnString(
      'creationReceipt',
      this,
    );
    acceptedSourceId = _is.ColumnUuid(
      'acceptedSourceId',
      this,
    );
    basisSourceId = _is.ColumnUuid(
      'basisSourceId',
      this,
    );
    baselineDigest = _is.ColumnString(
      'baselineDigest',
      this,
    );
    acceptedAt = _is.ColumnDateTime(
      'acceptedAt',
      this,
    );
    lastActorId = _is.ColumnString(
      'lastActorId',
      this,
    );
    lastCommandId = _is.ColumnUuid(
      'lastCommandId',
      this,
    );
    lastCommandDigest = _is.ColumnString(
      'lastCommandDigest',
      this,
    );
    lastReceipt = _is.ColumnString(
      'lastReceipt',
      this,
    );
    deletedAt = _is.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final CalendarIncomingPublicationLinkRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnUuid eventId;

  late final _is.ColumnUuid creationSourceId;

  late final _is.ColumnString creationActorId;

  late final _is.ColumnUuid creationCommandId;

  late final _is.ColumnString creationDigest;

  late final _is.ColumnString creationReceipt;

  late final _is.ColumnUuid acceptedSourceId;

  late final _is.ColumnUuid basisSourceId;

  late final _is.ColumnString baselineDigest;

  late final _is.ColumnDateTime acceptedAt;

  late final _is.ColumnString lastActorId;

  late final _is.ColumnUuid lastCommandId;

  late final _is.ColumnString lastCommandDigest;

  late final _is.ColumnString lastReceipt;

  late final _is.ColumnDateTime deletedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    entryId,
    correlationDigest,
    calendarId,
    eventId,
    creationSourceId,
    creationActorId,
    creationCommandId,
    creationDigest,
    creationReceipt,
    acceptedSourceId,
    basisSourceId,
    baselineDigest,
    acceptedAt,
    lastActorId,
    lastCommandId,
    lastCommandDigest,
    lastReceipt,
    deletedAt,
  ];
}

class CalendarIncomingPublicationLinkRecordInclude extends _is.IncludeObject {
  CalendarIncomingPublicationLinkRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationLinkRecord.t;
}

class CalendarIncomingPublicationLinkRecordIncludeList extends _is.IncludeList {
  CalendarIncomingPublicationLinkRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarIncomingPublicationLinkRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarIncomingPublicationLinkRecord.t;
}

class CalendarIncomingPublicationLinkRecordRepository {
  const CalendarIncomingPublicationLinkRecordRepository._();

  /// Returns a list of [CalendarIncomingPublicationLinkRecord]s matching the given query parameters.
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
  Future<List<CalendarIncomingPublicationLinkRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarIncomingPublicationLinkRecord>(
      where: where?.call(CalendarIncomingPublicationLinkRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarIncomingPublicationLinkRecord]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CalendarIncomingPublicationLinkRecord.t`.
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
  _ida.Stream<List<CalendarIncomingPublicationLinkRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarIncomingPublicationLinkRecord>(
      where: where?.call(CalendarIncomingPublicationLinkRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarIncomingPublicationLinkRecord] matching the given query parameters.
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
  Future<CalendarIncomingPublicationLinkRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarIncomingPublicationLinkRecord>(
      where: where?.call(CalendarIncomingPublicationLinkRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarIncomingPublicationLinkRecord] by its [id] or null if no such row exists.
  Future<CalendarIncomingPublicationLinkRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarIncomingPublicationLinkRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarIncomingPublicationLinkRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarIncomingPublicationLinkRecord]s will have their `id` fields set.
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
  Future<List<CalendarIncomingPublicationLinkRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationLinkRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarIncomingPublicationLinkRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarIncomingPublicationLinkRecord] and returns the inserted row.
  ///
  /// The returned [CalendarIncomingPublicationLinkRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationLinkRecord> insertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationLinkRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarIncomingPublicationLinkRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarIncomingPublicationLinkRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarIncomingPublicationLinkRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationLinkRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationLinkRecord> rows, {
    required _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarIncomingPublicationLinkRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarIncomingPublicationLinkRecord.t),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationLinkRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarIncomingPublicationLinkRecord] and returns the resulting row.
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
  /// The returned [CalendarIncomingPublicationLinkRecord] will have its `id` field set.
  Future<CalendarIncomingPublicationLinkRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationLinkRecord row, {
    required _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarIncomingPublicationLinkRecord>(
      row,
      conflictColumns: conflictColumns(CalendarIncomingPublicationLinkRecord.t),
      updateColumns: updateColumns?.call(
        CalendarIncomingPublicationLinkRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationLinkRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationLinkRecord>> update(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationLinkRecord> rows, {
    _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarIncomingPublicationLinkRecord>(
      rows,
      columns: columns?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarIncomingPublicationLinkRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarIncomingPublicationLinkRecord> updateRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationLinkRecord row, {
    _is.ColumnSelections<CalendarIncomingPublicationLinkRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarIncomingPublicationLinkRecord>(
      row,
      columns: columns?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarIncomingPublicationLinkRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarIncomingPublicationLinkRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationLinkRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarIncomingPublicationLinkRecord>(
      id,
      columnValues: columnValues(
        CalendarIncomingPublicationLinkRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarIncomingPublicationLinkRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarIncomingPublicationLinkRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarIncomingPublicationLinkRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationLinkRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarIncomingPublicationLinkRecord>(
      columnValues: columnValues(
        CalendarIncomingPublicationLinkRecord.t.updateTable,
      ),
      where: where(CalendarIncomingPublicationLinkRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarIncomingPublicationLinkRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarIncomingPublicationLinkRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarIncomingPublicationLinkRecord> rows, {
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarIncomingPublicationLinkRecord>(
      rows,
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarIncomingPublicationLinkRecord].
  Future<CalendarIncomingPublicationLinkRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarIncomingPublicationLinkRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarIncomingPublicationLinkRecord>(
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
  Future<List<CalendarIncomingPublicationLinkRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationLinkRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarIncomingPublicationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarIncomingPublicationLinkRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarIncomingPublicationLinkRecord>(
      where: where(CalendarIncomingPublicationLinkRecord.t),
      orderBy: orderBy?.call(CalendarIncomingPublicationLinkRecord.t),
      orderByList: orderByList?.call(CalendarIncomingPublicationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarIncomingPublicationLinkRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarIncomingPublicationLinkRecord>(
      where: where?.call(CalendarIncomingPublicationLinkRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarIncomingPublicationLinkRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarIncomingPublicationLinkRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarIncomingPublicationLinkRecord>(
      where: where(CalendarIncomingPublicationLinkRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
