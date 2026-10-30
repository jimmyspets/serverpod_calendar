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
import 'calendar_invitation_response_choice.dart' as _il64jj9v;
import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;

abstract class CalendarInvitationResponseStateRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseStateRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.entryId,
    required this.recipientAddress,
    required this.revision,
    required this.latestResponseId,
    required this.lastStamp,
    required this.choice,
    required this.sourceId,
    required this.sourceRevision,
    required this.sourceDigest,
    this.sourceSequence,
    required this.sourceStamp,
    required this.outcome,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CalendarInvitationResponseStateRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required String recipientAddress,
    required int revision,
    required _is.UuidValue latestResponseId,
    required DateTime lastStamp,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required _iw51ozry.CalendarInvitationResponseDeliveryState outcome,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarInvitationResponseStateRecordImpl;

  factory CalendarInvitationResponseStateRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseStateRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      recipientAddress: jsonSerialization['recipientAddress'] as String,
      revision: jsonSerialization['revision'] as int,
      latestResponseId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['latestResponseId'],
      ),
      lastStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['lastStamp'],
      ),
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sourceRevision: jsonSerialization['sourceRevision'] as int,
      sourceDigest: jsonSerialization['sourceDigest'] as String,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      outcome: _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarInvitationResponseStateRecordTable();

  static const db = CalendarInvitationResponseStateRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  _is.UuidValue entryId;

  String recipientAddress;

  int revision;

  _is.UuidValue latestResponseId;

  DateTime lastStamp;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  _is.UuidValue sourceId;

  int sourceRevision;

  String sourceDigest;

  int? sourceSequence;

  DateTime sourceStamp;

  _iw51ozry.CalendarInvitationResponseDeliveryState outcome;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationResponseStateRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseStateRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    String? recipientAddress,
    int? revision,
    _is.UuidValue? latestResponseId,
    DateTime? lastStamp,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    int? sourceSequence,
    DateTime? sourceStamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? outcome,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarInvitationResponseStateRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'entryId': entryId.toJson(),
      'recipientAddress': recipientAddress,
      'revision': revision,
      'latestResponseId': latestResponseId.toJson(),
      'lastStamp': lastStamp.toJson(),
      'choice': choice.toJson(),
      'sourceId': sourceId.toJson(),
      'sourceRevision': sourceRevision,
      'sourceDigest': sourceDigest,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'outcome': outcome.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationResponseStateRecordInclude include() {
    return CalendarInvitationResponseStateRecordInclude._();
  }

  static CalendarInvitationResponseStateRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    CalendarInvitationResponseStateRecordInclude? include,
  }) {
    return CalendarInvitationResponseStateRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationResponseStateRecordImpl
    extends CalendarInvitationResponseStateRecord {
  _CalendarInvitationResponseStateRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required String recipientAddress,
    required int revision,
    required _is.UuidValue latestResponseId,
    required DateTime lastStamp,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required _iw51ozry.CalendarInvitationResponseDeliveryState outcome,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         entryId: entryId,
         recipientAddress: recipientAddress,
         revision: revision,
         latestResponseId: latestResponseId,
         lastStamp: lastStamp,
         choice: choice,
         sourceId: sourceId,
         sourceRevision: sourceRevision,
         sourceDigest: sourceDigest,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         outcome: outcome,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseStateRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseStateRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    String? recipientAddress,
    int? revision,
    _is.UuidValue? latestResponseId,
    DateTime? lastStamp,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    Object? sourceSequence = _Undefined,
    DateTime? sourceStamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? outcome,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarInvitationResponseStateRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      entryId: entryId ?? this.entryId,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      revision: revision ?? this.revision,
      latestResponseId: latestResponseId ?? this.latestResponseId,
      lastStamp: lastStamp ?? this.lastStamp,
      choice: choice ?? this.choice,
      sourceId: sourceId ?? this.sourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      sourceDigest: sourceDigest ?? this.sourceDigest,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      outcome: outcome ?? this.outcome,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarInvitationResponseStateRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationResponseStateRecordTable> {
  CalendarInvitationResponseStateRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> recipientAddress(String value) =>
      _is.ColumnValue(
        table.recipientAddress,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> latestResponseId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.latestResponseId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastStamp(DateTime value) =>
      _is.ColumnValue(
        table.lastStamp,
        value,
      );

  _is.ColumnValue<
    _il64jj9v.CalendarInvitationResponseChoice,
    _il64jj9v.CalendarInvitationResponseChoice
  >
  choice(_il64jj9v.CalendarInvitationResponseChoice value) => _is.ColumnValue(
    table.choice,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
        value,
      );

  _is.ColumnValue<int, int> sourceRevision(int value) => _is.ColumnValue(
    table.sourceRevision,
    value,
  );

  _is.ColumnValue<String, String> sourceDigest(String value) => _is.ColumnValue(
    table.sourceDigest,
    value,
  );

  _is.ColumnValue<int, int> sourceSequence(int? value) => _is.ColumnValue(
    table.sourceSequence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> sourceStamp(DateTime value) =>
      _is.ColumnValue(
        table.sourceStamp,
        value,
      );

  _is.ColumnValue<
    _iw51ozry.CalendarInvitationResponseDeliveryState,
    _iw51ozry.CalendarInvitationResponseDeliveryState
  >
  outcome(_iw51ozry.CalendarInvitationResponseDeliveryState value) =>
      _is.ColumnValue(
        table.outcome,
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

class CalendarInvitationResponseStateRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseStateRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_response_state') {
    updateTable = CalendarInvitationResponseStateRecordUpdateTable(this);
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
    recipientAddress = _is.ColumnString(
      'recipientAddress',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    latestResponseId = _is.ColumnUuid(
      'latestResponseId',
      this,
    );
    lastStamp = _is.ColumnDateTime(
      'lastStamp',
      this,
    );
    choice = _is.ColumnEnum(
      'choice',
      this,
      _is.EnumSerialization.byName,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
      this,
    );
    sourceRevision = _is.ColumnInt(
      'sourceRevision',
      this,
    );
    sourceDigest = _is.ColumnString(
      'sourceDigest',
      this,
    );
    sourceSequence = _is.ColumnInt(
      'sourceSequence',
      this,
    );
    sourceStamp = _is.ColumnDateTime(
      'sourceStamp',
      this,
    );
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
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

  late final CalendarInvitationResponseStateRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnString recipientAddress;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid latestResponseId;

  late final _is.ColumnDateTime lastStamp;

  late final _is.ColumnEnum<_il64jj9v.CalendarInvitationResponseChoice> choice;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnInt sourceRevision;

  late final _is.ColumnString sourceDigest;

  late final _is.ColumnInt sourceSequence;

  late final _is.ColumnDateTime sourceStamp;

  late final _is.ColumnEnum<_iw51ozry.CalendarInvitationResponseDeliveryState>
  outcome;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    entryId,
    recipientAddress,
    revision,
    latestResponseId,
    lastStamp,
    choice,
    sourceId,
    sourceRevision,
    sourceDigest,
    sourceSequence,
    sourceStamp,
    outcome,
    createdAt,
    updatedAt,
  ];
}

class CalendarInvitationResponseStateRecordInclude extends _is.IncludeObject {
  CalendarInvitationResponseStateRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseStateRecord.t;
}

class CalendarInvitationResponseStateRecordIncludeList extends _is.IncludeList {
  CalendarInvitationResponseStateRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationResponseStateRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarInvitationResponseStateRecord.t;
}

class CalendarInvitationResponseStateRecordRepository {
  const CalendarInvitationResponseStateRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseStateRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseStateRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseStateRecord>(
      where: where?.call(CalendarInvitationResponseStateRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseStateRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseStateRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationResponseStateRecord>(
      where: where?.call(CalendarInvitationResponseStateRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationResponseStateRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseStateRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationResponseStateRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationResponseStateRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseStateRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseStateRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseStateRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationResponseStateRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationResponseStateRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseStateRecord] will have its `id` field set.
  Future<CalendarInvitationResponseStateRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseStateRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationResponseStateRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationResponseStateRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseStateRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseStateRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseStateRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationResponseStateRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationResponseStateRecord.t),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseStateRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationResponseStateRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseStateRecord] will have its `id` field set.
  Future<CalendarInvitationResponseStateRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseStateRecord row, {
    required _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationResponseStateRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationResponseStateRecord.t),
      updateColumns: updateColumns?.call(
        CalendarInvitationResponseStateRecord.t,
      ),
      updateWhere: updateWhere?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseStateRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseStateRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseStateRecord> rows, {
    _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationResponseStateRecord>(
      rows,
      columns: columns?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationResponseStateRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseStateRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseStateRecord row, {
    _is.ColumnSelections<CalendarInvitationResponseStateRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationResponseStateRecord>(
      row,
      columns: columns?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationResponseStateRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseStateRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseStateRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationResponseStateRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationResponseStateRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseStateRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseStateRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseStateRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseStateRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationResponseStateRecord>(
      columnValues: columnValues(
        CalendarInvitationResponseStateRecord.t.updateTable,
      ),
      where: where(CalendarInvitationResponseStateRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationResponseStateRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseStateRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseStateRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationResponseStateRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationResponseStateRecord].
  Future<CalendarInvitationResponseStateRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseStateRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationResponseStateRecord>(
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
  Future<List<CalendarInvitationResponseStateRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseStateRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationResponseStateRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseStateRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationResponseStateRecord>(
      where: where(CalendarInvitationResponseStateRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseStateRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseStateRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseStateRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseStateRecord>(
      where: where?.call(CalendarInvitationResponseStateRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseStateRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationResponseStateRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationResponseStateRecord>(
      where: where(CalendarInvitationResponseStateRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
