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
import 'package:serverpod_calendar_server/src/generated/protocol.dart'
    as _ix00hwbf;

abstract class CalendarSchedulingPublicationRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingPublicationRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.generation,
    required this.method,
    required this.protocolUid,
    required this.sequence,
    required this.stamp,
    required this.snapshot,
    required this.projection,
    required this.payload,
    required this.payloadDigest,
    required this.recipients,
    required this.commandId,
    required this.actorId,
    required this.requestDigest,
    required this.expectedRevision,
    required this.eventRevision,
    required this.createdAt,
    required this.expiresAt,
    this.completedAt,
    required this.outcome,
  });

  factory CalendarSchedulingPublicationRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required int generation,
    required String method,
    required String protocolUid,
    required int sequence,
    required DateTime stamp,
    required String snapshot,
    required String projection,
    required String payload,
    required String payloadDigest,
    required List<String> recipients,
    required _is.UuidValue commandId,
    required String actorId,
    required String requestDigest,
    required int expectedRevision,
    required int eventRevision,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? completedAt,
    required String outcome,
  }) = _CalendarSchedulingPublicationRecordImpl;

  factory CalendarSchedulingPublicationRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingPublicationRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      generation: jsonSerialization['generation'] as int,
      method: jsonSerialization['method'] as String,
      protocolUid: jsonSerialization['protocolUid'] as String,
      sequence: jsonSerialization['sequence'] as int,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      snapshot: jsonSerialization['snapshot'] as String,
      projection: jsonSerialization['projection'] as String,
      payload: jsonSerialization['payload'] as String,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      recipients: _ix00hwbf.Protocol().deserialize<List<String>>(
        jsonSerialization['recipients'],
      ),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      actorId: jsonSerialization['actorId'] as String,
      requestDigest: jsonSerialization['requestDigest'] as String,
      expectedRevision: jsonSerialization['expectedRevision'] as int,
      eventRevision: jsonSerialization['eventRevision'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      outcome: jsonSerialization['outcome'] as String,
    );
  }

  static final t = CalendarSchedulingPublicationRecordTable();

  static const db = CalendarSchedulingPublicationRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  int generation;

  String method;

  String protocolUid;

  int sequence;

  DateTime stamp;

  String snapshot;

  String projection;

  String payload;

  String payloadDigest;

  List<String> recipients;

  _is.UuidValue commandId;

  String actorId;

  String requestDigest;

  int expectedRevision;

  int eventRevision;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? completedAt;

  String outcome;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingPublicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingPublicationRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? meetingId,
    int? generation,
    String? method,
    String? protocolUid,
    int? sequence,
    DateTime? stamp,
    String? snapshot,
    String? projection,
    String? payload,
    String? payloadDigest,
    List<String>? recipients,
    _is.UuidValue? commandId,
    String? actorId,
    String? requestDigest,
    int? expectedRevision,
    int? eventRevision,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? completedAt,
    String? outcome,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingPublicationRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'generation': generation,
      'method': method,
      'protocolUid': protocolUid,
      'sequence': sequence,
      'stamp': stamp.toJson(),
      'snapshot': snapshot,
      'projection': projection,
      'payload': payload,
      'payloadDigest': payloadDigest,
      'recipients': recipients.toJson(),
      'commandId': commandId.toJson(),
      'actorId': actorId,
      'requestDigest': requestDigest,
      'expectedRevision': expectedRevision,
      'eventRevision': eventRevision,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'outcome': outcome,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingPublicationRecordInclude include() {
    return CalendarSchedulingPublicationRecordInclude._();
  }

  static CalendarSchedulingPublicationRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    CalendarSchedulingPublicationRecordInclude? include,
  }) {
    return CalendarSchedulingPublicationRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingPublicationRecordImpl
    extends CalendarSchedulingPublicationRecord {
  _CalendarSchedulingPublicationRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required int generation,
    required String method,
    required String protocolUid,
    required int sequence,
    required DateTime stamp,
    required String snapshot,
    required String projection,
    required String payload,
    required String payloadDigest,
    required List<String> recipients,
    required _is.UuidValue commandId,
    required String actorId,
    required String requestDigest,
    required int expectedRevision,
    required int eventRevision,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? completedAt,
    required String outcome,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         generation: generation,
         method: method,
         protocolUid: protocolUid,
         sequence: sequence,
         stamp: stamp,
         snapshot: snapshot,
         projection: projection,
         payload: payload,
         payloadDigest: payloadDigest,
         recipients: recipients,
         commandId: commandId,
         actorId: actorId,
         requestDigest: requestDigest,
         expectedRevision: expectedRevision,
         eventRevision: eventRevision,
         createdAt: createdAt,
         expiresAt: expiresAt,
         completedAt: completedAt,
         outcome: outcome,
       );

  /// Returns a shallow copy of this [CalendarSchedulingPublicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingPublicationRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? meetingId,
    int? generation,
    String? method,
    String? protocolUid,
    int? sequence,
    DateTime? stamp,
    String? snapshot,
    String? projection,
    String? payload,
    String? payloadDigest,
    List<String>? recipients,
    _is.UuidValue? commandId,
    String? actorId,
    String? requestDigest,
    int? expectedRevision,
    int? eventRevision,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? completedAt = _Undefined,
    String? outcome,
  }) {
    return CalendarSchedulingPublicationRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      generation: generation ?? this.generation,
      method: method ?? this.method,
      protocolUid: protocolUid ?? this.protocolUid,
      sequence: sequence ?? this.sequence,
      stamp: stamp ?? this.stamp,
      snapshot: snapshot ?? this.snapshot,
      projection: projection ?? this.projection,
      payload: payload ?? this.payload,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      recipients: recipients ?? this.recipients.map((e0) => e0).toList(),
      commandId: commandId ?? this.commandId,
      actorId: actorId ?? this.actorId,
      requestDigest: requestDigest ?? this.requestDigest,
      expectedRevision: expectedRevision ?? this.expectedRevision,
      eventRevision: eventRevision ?? this.eventRevision,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      outcome: outcome ?? this.outcome,
    );
  }
}

class CalendarSchedulingPublicationRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingPublicationRecordTable> {
  CalendarSchedulingPublicationRecordUpdateTable(super.table);

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

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
    value,
  );

  _is.ColumnValue<String, String> method(String value) => _is.ColumnValue(
    table.method,
    value,
  );

  _is.ColumnValue<String, String> protocolUid(String value) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<int, int> sequence(int value) => _is.ColumnValue(
    table.sequence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
    value,
  );

  _is.ColumnValue<String, String> snapshot(String value) => _is.ColumnValue(
    table.snapshot,
    value,
  );

  _is.ColumnValue<String, String> projection(String value) => _is.ColumnValue(
    table.projection,
    value,
  );

  _is.ColumnValue<String, String> payload(String value) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<String, String> payloadDigest(String value) =>
      _is.ColumnValue(
        table.payloadDigest,
        value,
      );

  _is.ColumnValue<List<String>, List<String>> recipients(List<String> value) =>
      _is.ColumnValue(
        table.recipients,
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

  _is.ColumnValue<String, String> requestDigest(String value) =>
      _is.ColumnValue(
        table.requestDigest,
        value,
      );

  _is.ColumnValue<int, int> expectedRevision(int value) => _is.ColumnValue(
    table.expectedRevision,
    value,
  );

  _is.ColumnValue<int, int> eventRevision(int value) => _is.ColumnValue(
    table.eventRevision,
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

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );

  _is.ColumnValue<String, String> outcome(String value) => _is.ColumnValue(
    table.outcome,
    value,
  );
}

class CalendarSchedulingPublicationRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingPublicationRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_publication') {
    updateTable = CalendarSchedulingPublicationRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    meetingId = _is.ColumnUuid(
      'meetingId',
      this,
    );
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    method = _is.ColumnString(
      'method',
      this,
    );
    protocolUid = _is.ColumnString(
      'protocolUid',
      this,
    );
    sequence = _is.ColumnInt(
      'sequence',
      this,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
      this,
    );
    snapshot = _is.ColumnString(
      'snapshot',
      this,
    );
    projection = _is.ColumnString(
      'projection',
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
    recipients = _is.ColumnSerializable<List<String>>(
      'recipients',
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
    requestDigest = _is.ColumnString(
      'requestDigest',
      this,
    );
    expectedRevision = _is.ColumnInt(
      'expectedRevision',
      this,
    );
    eventRevision = _is.ColumnInt(
      'eventRevision',
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
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
    outcome = _is.ColumnString(
      'outcome',
      this,
    );
  }

  late final CalendarSchedulingPublicationRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnInt generation;

  late final _is.ColumnString method;

  late final _is.ColumnString protocolUid;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString snapshot;

  late final _is.ColumnString projection;

  late final _is.ColumnString payload;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnSerializable<List<String>> recipients;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString actorId;

  late final _is.ColumnString requestDigest;

  late final _is.ColumnInt expectedRevision;

  late final _is.ColumnInt eventRevision;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime completedAt;

  late final _is.ColumnString outcome;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    generation,
    method,
    protocolUid,
    sequence,
    stamp,
    snapshot,
    projection,
    payload,
    payloadDigest,
    recipients,
    commandId,
    actorId,
    requestDigest,
    expectedRevision,
    eventRevision,
    createdAt,
    expiresAt,
    completedAt,
    outcome,
  ];
}

class CalendarSchedulingPublicationRecordInclude extends _is.IncludeObject {
  CalendarSchedulingPublicationRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingPublicationRecord.t;
}

class CalendarSchedulingPublicationRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingPublicationRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingPublicationRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingPublicationRecord.t;
}

class CalendarSchedulingPublicationRecordRepository {
  const CalendarSchedulingPublicationRecordRepository._();

  /// Returns a list of [CalendarSchedulingPublicationRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingPublicationRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingPublicationRecord>(
      where: where?.call(CalendarSchedulingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingPublicationRecord] matching the given query parameters.
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
  Future<CalendarSchedulingPublicationRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingPublicationRecord>(
      where: where?.call(CalendarSchedulingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingPublicationRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingPublicationRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingPublicationRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingPublicationRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingPublicationRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingPublicationRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingPublicationRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingPublicationRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingPublicationRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingPublicationRecord] will have its `id` field set.
  Future<CalendarSchedulingPublicationRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingPublicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingPublicationRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingPublicationRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingPublicationRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingPublicationRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingPublicationRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingPublicationRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingPublicationRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingPublicationRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingPublicationRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingPublicationRecord] will have its `id` field set.
  Future<CalendarSchedulingPublicationRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingPublicationRecord row, {
    required _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingPublicationRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingPublicationRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingPublicationRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingPublicationRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingPublicationRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingPublicationRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingPublicationRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingPublicationRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingPublicationRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingPublicationRecord row, {
    _is.ColumnSelections<CalendarSchedulingPublicationRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingPublicationRecord>(
      row,
      columns: columns?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingPublicationRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingPublicationRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingPublicationRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingPublicationRecord>(
      id,
      columnValues: columnValues(
        CalendarSchedulingPublicationRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingPublicationRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingPublicationRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingPublicationRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarSchedulingPublicationRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingPublicationRecord>(
      columnValues: columnValues(
        CalendarSchedulingPublicationRecord.t.updateTable,
      ),
      where: where(CalendarSchedulingPublicationRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingPublicationRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingPublicationRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingPublicationRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingPublicationRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingPublicationRecord].
  Future<CalendarSchedulingPublicationRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingPublicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingPublicationRecord>(
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
  Future<List<CalendarSchedulingPublicationRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingPublicationRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarSchedulingPublicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingPublicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingPublicationRecord>(
      where: where(CalendarSchedulingPublicationRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingPublicationRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingPublicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingPublicationRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingPublicationRecord>(
      where: where?.call(CalendarSchedulingPublicationRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingPublicationRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingPublicationRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingPublicationRecord>(
      where: where(CalendarSchedulingPublicationRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
