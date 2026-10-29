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

abstract class CalendarInvitationLinkRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationLinkRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.uid,
    required this.organizer,
    required this.correlationDigest,
    required this.invitationId,
    required this.sourceId,
    required this.sourceDigest,
    this.sequence,
    required this.stamp,
    required this.calendarId,
    required this.eventId,
    required this.requestDigest,
    required this.eventRevision,
    required this.invitationRevision,
    required this.adoptedAt,
  });

  factory CalendarInvitationLinkRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String uid,
    required String organizer,
    required String correlationDigest,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required String sourceDigest,
    int? sequence,
    required DateTime stamp,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required String requestDigest,
    required int eventRevision,
    required int invitationRevision,
    required DateTime adoptedAt,
  }) = _CalendarInvitationLinkRecordImpl;

  factory CalendarInvitationLinkRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationLinkRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      uid: jsonSerialization['uid'] as String,
      organizer: jsonSerialization['organizer'] as String,
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sourceDigest: jsonSerialization['sourceDigest'] as String,
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      eventId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['eventId'],
      ),
      requestDigest: jsonSerialization['requestDigest'] as String,
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      adoptedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['adoptedAt'],
      ),
    );
  }

  static final t = CalendarInvitationLinkRecordTable();

  static const db = CalendarInvitationLinkRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  String uid;

  String organizer;

  String correlationDigest;

  _is.UuidValue invitationId;

  _is.UuidValue sourceId;

  String sourceDigest;

  int? sequence;

  DateTime stamp;

  _is.UuidValue calendarId;

  _is.UuidValue eventId;

  String requestDigest;

  int eventRevision;

  int invitationRevision;

  DateTime adoptedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationLinkRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationLinkRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientKey,
    String? uid,
    String? organizer,
    String? correlationDigest,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    String? sourceDigest,
    int? sequence,
    DateTime? stamp,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    String? requestDigest,
    int? eventRevision,
    int? invitationRevision,
    DateTime? adoptedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationLinkRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'uid': uid,
      'organizer': organizer,
      'correlationDigest': correlationDigest,
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'sourceDigest': sourceDigest,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'calendarId': calendarId.toJson(),
      'eventId': eventId.toJson(),
      'requestDigest': requestDigest,
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'adoptedAt': adoptedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationLinkRecordInclude include() {
    return CalendarInvitationLinkRecordInclude._();
  }

  static CalendarInvitationLinkRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    CalendarInvitationLinkRecordInclude? include,
  }) {
    return CalendarInvitationLinkRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationLinkRecordImpl extends CalendarInvitationLinkRecord {
  _CalendarInvitationLinkRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required String uid,
    required String organizer,
    required String correlationDigest,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required String sourceDigest,
    int? sequence,
    required DateTime stamp,
    required _is.UuidValue calendarId,
    required _is.UuidValue eventId,
    required String requestDigest,
    required int eventRevision,
    required int invitationRevision,
    required DateTime adoptedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         uid: uid,
         organizer: organizer,
         correlationDigest: correlationDigest,
         invitationId: invitationId,
         sourceId: sourceId,
         sourceDigest: sourceDigest,
         sequence: sequence,
         stamp: stamp,
         calendarId: calendarId,
         eventId: eventId,
         requestDigest: requestDigest,
         eventRevision: eventRevision,
         invitationRevision: invitationRevision,
         adoptedAt: adoptedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationLinkRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationLinkRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientKey,
    String? uid,
    String? organizer,
    String? correlationDigest,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    String? sourceDigest,
    Object? sequence = _Undefined,
    DateTime? stamp,
    _is.UuidValue? calendarId,
    _is.UuidValue? eventId,
    String? requestDigest,
    int? eventRevision,
    int? invitationRevision,
    DateTime? adoptedAt,
  }) {
    return CalendarInvitationLinkRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      uid: uid ?? this.uid,
      organizer: organizer ?? this.organizer,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      sourceDigest: sourceDigest ?? this.sourceDigest,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      calendarId: calendarId ?? this.calendarId,
      eventId: eventId ?? this.eventId,
      requestDigest: requestDigest ?? this.requestDigest,
      eventRevision: eventRevision ?? this.eventRevision,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      adoptedAt: adoptedAt ?? this.adoptedAt,
    );
  }
}

class CalendarInvitationLinkRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationLinkRecordTable> {
  CalendarInvitationLinkRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<String, String> uid(String value) => _is.ColumnValue(
    table.uid,
    value,
  );

  _is.ColumnValue<String, String> organizer(String value) => _is.ColumnValue(
    table.organizer,
    value,
  );

  _is.ColumnValue<String, String> correlationDigest(String value) =>
      _is.ColumnValue(
        table.correlationDigest,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> invitationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.invitationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<String, String> sourceDigest(String value) => _is.ColumnValue(
    table.sourceDigest,
    value,
  );

  _is.ColumnValue<int, int> sequence(int? value) => _is.ColumnValue(
    table.sequence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
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

  _is.ColumnValue<String, String> requestDigest(String value) =>
      _is.ColumnValue(
        table.requestDigest,
        value,
      );

  _is.ColumnValue<int, int> eventRevision(int value) => _is.ColumnValue(
    table.eventRevision,
    value,
  );

  _is.ColumnValue<int, int> invitationRevision(int value) => _is.ColumnValue(
    table.invitationRevision,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> adoptedAt(DateTime value) =>
      _is.ColumnValue(
        table.adoptedAt,
        value,
      );
}

class CalendarInvitationLinkRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarInvitationLinkRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_link') {
    updateTable = CalendarInvitationLinkRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    uid = _is.ColumnString(
      'uid',
      this,
    );
    organizer = _is.ColumnString(
      'organizer',
      this,
    );
    correlationDigest = _is.ColumnString(
      'correlationDigest',
      this,
    );
    invitationId = _is.ColumnUuid(
      'invitationId',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    sourceDigest = _is.ColumnString(
      'sourceDigest',
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
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    eventId = _is.ColumnUuid(
      'eventId',
      this,
    );
    requestDigest = _is.ColumnString(
      'requestDigest',
      this,
    );
    eventRevision = _is.ColumnInt(
      'eventRevision',
      this,
    );
    invitationRevision = _is.ColumnInt(
      'invitationRevision',
      this,
    );
    adoptedAt = _is.ColumnDateTime(
      'adoptedAt',
      this,
    );
  }

  late final CalendarInvitationLinkRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString uid;

  late final _is.ColumnString organizer;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnUuid invitationId;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnString sourceDigest;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnUuid eventId;

  late final _is.ColumnString requestDigest;

  late final _is.ColumnInt eventRevision;

  late final _is.ColumnInt invitationRevision;

  late final _is.ColumnDateTime adoptedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    uid,
    organizer,
    correlationDigest,
    invitationId,
    sourceId,
    sourceDigest,
    sequence,
    stamp,
    calendarId,
    eventId,
    requestDigest,
    eventRevision,
    invitationRevision,
    adoptedAt,
  ];
}

class CalendarInvitationLinkRecordInclude extends _is.IncludeObject {
  CalendarInvitationLinkRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationLinkRecord.t;
}

class CalendarInvitationLinkRecordIncludeList extends _is.IncludeList {
  CalendarInvitationLinkRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationLinkRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationLinkRecord.t;
}

class CalendarInvitationLinkRecordRepository {
  const CalendarInvitationLinkRecordRepository._();

  /// Returns a list of [CalendarInvitationLinkRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationLinkRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationLinkRecord>(
      where: where?.call(CalendarInvitationLinkRecord.t),
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationLinkRecord] matching the given query parameters.
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
  Future<CalendarInvitationLinkRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationLinkRecord>(
      where: where?.call(CalendarInvitationLinkRecord.t),
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationLinkRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationLinkRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationLinkRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationLinkRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationLinkRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationLinkRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationLinkRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationLinkRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationLinkRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationLinkRecord] will have its `id` field set.
  Future<CalendarInvitationLinkRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationLinkRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationLinkRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationLinkRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationLinkRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationLinkRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationLinkRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationLinkRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationLinkRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationLinkRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationLinkRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationLinkRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationLinkRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationLinkRecord] will have its `id` field set.
  Future<CalendarInvitationLinkRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationLinkRecord row, {
    required _is.ColumnSelections<CalendarInvitationLinkRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationLinkRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationLinkRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationLinkRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationLinkRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationLinkRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationLinkRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationLinkRecord> rows, {
    _is.ColumnSelections<CalendarInvitationLinkRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationLinkRecord>(
      rows,
      columns: columns?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationLinkRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationLinkRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationLinkRecord row, {
    _is.ColumnSelections<CalendarInvitationLinkRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationLinkRecord>(
      row,
      columns: columns?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationLinkRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationLinkRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarInvitationLinkRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationLinkRecord>(
      id,
      columnValues: columnValues(CalendarInvitationLinkRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationLinkRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationLinkRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarInvitationLinkRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationLinkRecord>(
      columnValues: columnValues(CalendarInvitationLinkRecord.t.updateTable),
      where: where(CalendarInvitationLinkRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationLinkRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationLinkRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationLinkRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationLinkRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationLinkRecord].
  Future<CalendarInvitationLinkRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationLinkRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationLinkRecord>(
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
  Future<List<CalendarInvitationLinkRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>
    where,
    _is.OrderByBuilder<CalendarInvitationLinkRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationLinkRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationLinkRecord>(
      where: where(CalendarInvitationLinkRecord.t),
      orderBy: orderBy?.call(CalendarInvitationLinkRecord.t),
      orderByList: orderByList?.call(CalendarInvitationLinkRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationLinkRecord>(
      where: where?.call(CalendarInvitationLinkRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationLinkRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationLinkRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationLinkRecord>(
      where: where(CalendarInvitationLinkRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
