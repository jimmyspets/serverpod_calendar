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
import 'calendar_invitation_source_kind.dart' as _ilccsff7;

abstract class CalendarInvitationRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationRecord._({
    this.id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.scopeKey,
    required this.recipientKey,
    required this.correlationDigest,
    required this.uid,
    required this.organizer,
    required this.revision,
    this.currentSourceId,
    this.sequence,
    required this.stamp,
    required this.digest,
    required this.createdAt,
    required this.updatedAt,
    this.dismissedAt,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  factory CalendarInvitationRecord({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required String uid,
    required String organizer,
    required int revision,
    _is.UuidValue? currentSourceId,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dismissedAt,
  }) = _CalendarInvitationRecordImpl;

  factory CalendarInvitationRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      kind: jsonSerialization['kind'] == null
          ? null
          : _ilccsff7.CalendarInvitationSourceKind.fromJson(
              (jsonSerialization['kind'] as String),
            ),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      correlationDigest: jsonSerialization['correlationDigest'] as String,
      uid: jsonSerialization['uid'] as String,
      organizer: jsonSerialization['organizer'] as String,
      revision: jsonSerialization['revision'] as int,
      currentSourceId: jsonSerialization['currentSourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['currentSourceId'],
            ),
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      digest: jsonSerialization['digest'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      dismissedAt: jsonSerialization['dismissedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['dismissedAt'],
            ),
    );
  }

  static final t = CalendarInvitationRecordTable();

  static const db = CalendarInvitationRecordRepository._();

  @override
  _is.UuidValue? id;

  _ilccsff7.CalendarInvitationSourceKind kind;

  String scopeKey;

  String recipientKey;

  String correlationDigest;

  String uid;

  String organizer;

  int revision;

  _is.UuidValue? currentSourceId;

  int? sequence;

  DateTime stamp;

  String digest;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? dismissedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationRecord copyWith({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    String? uid,
    String? organizer,
    int? revision,
    _is.UuidValue? currentSourceId,
    int? sequence,
    DateTime? stamp,
    String? digest,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dismissedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationRecord',
      if (id != null) 'id': id?.toJson(),
      'kind': kind.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'correlationDigest': correlationDigest,
      'uid': uid,
      'organizer': organizer,
      'revision': revision,
      if (currentSourceId != null) 'currentSourceId': currentSourceId?.toJson(),
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'digest': digest,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (dismissedAt != null) 'dismissedAt': dismissedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationRecordInclude include() {
    return CalendarInvitationRecordInclude._();
  }

  static CalendarInvitationRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    CalendarInvitationRecordInclude? include,
  }) {
    return CalendarInvitationRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationRecordImpl extends CalendarInvitationRecord {
  _CalendarInvitationRecordImpl({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required String scopeKey,
    required String recipientKey,
    required String correlationDigest,
    required String uid,
    required String organizer,
    required int revision,
    _is.UuidValue? currentSourceId,
    int? sequence,
    required DateTime stamp,
    required String digest,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? dismissedAt,
  }) : super._(
         id: id,
         kind: kind,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         correlationDigest: correlationDigest,
         uid: uid,
         organizer: organizer,
         revision: revision,
         currentSourceId: currentSourceId,
         sequence: sequence,
         stamp: stamp,
         digest: digest,
         createdAt: createdAt,
         updatedAt: updatedAt,
         dismissedAt: dismissedAt,
       );

  /// Returns a shallow copy of this [CalendarInvitationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationRecord copyWith({
    Object? id = _Undefined,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    String? scopeKey,
    String? recipientKey,
    String? correlationDigest,
    String? uid,
    String? organizer,
    int? revision,
    Object? currentSourceId = _Undefined,
    Object? sequence = _Undefined,
    DateTime? stamp,
    String? digest,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? dismissedAt = _Undefined,
  }) {
    return CalendarInvitationRecord(
      id: id is _is.UuidValue? ? id : this.id,
      kind: kind ?? this.kind,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      correlationDigest: correlationDigest ?? this.correlationDigest,
      uid: uid ?? this.uid,
      organizer: organizer ?? this.organizer,
      revision: revision ?? this.revision,
      currentSourceId: currentSourceId is _is.UuidValue?
          ? currentSourceId
          : this.currentSourceId,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      digest: digest ?? this.digest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dismissedAt: dismissedAt is DateTime? ? dismissedAt : this.dismissedAt,
    );
  }
}

class CalendarInvitationRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationRecordTable> {
  CalendarInvitationRecordUpdateTable(super.table);

  _is.ColumnValue<
    _ilccsff7.CalendarInvitationSourceKind,
    _ilccsff7.CalendarInvitationSourceKind
  >
  kind(_ilccsff7.CalendarInvitationSourceKind value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<String, String> correlationDigest(String value) =>
      _is.ColumnValue(
        table.correlationDigest,
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

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> currentSourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.currentSourceId,
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

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
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

  _is.ColumnValue<DateTime, DateTime> dismissedAt(DateTime? value) =>
      _is.ColumnValue(
        table.dismissedAt,
        value,
      );
}

class CalendarInvitationRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarInvitationRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation') {
    updateTable = CalendarInvitationRecordUpdateTable(this);
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    correlationDigest = _is.ColumnString(
      'correlationDigest',
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
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    currentSourceId = _is.ColumnUuid(
      'currentSourceId',
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
    digest = _is.ColumnString(
      'digest',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    dismissedAt = _is.ColumnDateTime(
      'dismissedAt',
      this,
    );
  }

  late final CalendarInvitationRecordUpdateTable updateTable;

  late final _is.ColumnEnum<_ilccsff7.CalendarInvitationSourceKind> kind;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString correlationDigest;

  late final _is.ColumnString uid;

  late final _is.ColumnString organizer;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid currentSourceId;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString digest;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime dismissedAt;

  @override
  List<_is.Column> get columns => [
    id,
    kind,
    scopeKey,
    recipientKey,
    correlationDigest,
    uid,
    organizer,
    revision,
    currentSourceId,
    sequence,
    stamp,
    digest,
    createdAt,
    updatedAt,
    dismissedAt,
  ];
}

class CalendarInvitationRecordInclude extends _is.IncludeObject {
  CalendarInvitationRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationRecord.t;
}

class CalendarInvitationRecordIncludeList extends _is.IncludeList {
  CalendarInvitationRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationRecord.t;
}

class CalendarInvitationRecordRepository {
  const CalendarInvitationRecordRepository._();

  /// Returns a list of [CalendarInvitationRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationRecord>(
      where: where?.call(CalendarInvitationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationRecord] matching the given query parameters.
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
  Future<CalendarInvitationRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationRecord>(
      where: where?.call(CalendarInvitationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationRecord] will have its `id` field set.
  Future<CalendarInvitationRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationRecord] will have its `id` field set.
  Future<CalendarInvitationRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationRecord row, {
    required _is.ColumnSelections<CalendarInvitationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationRecord> rows, {
    _is.ColumnSelections<CalendarInvitationRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationRecord>(
      rows,
      columns: columns?.call(CalendarInvitationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationRecord row, {
    _is.ColumnSelections<CalendarInvitationRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationRecord>(
      row,
      columns: columns?.call(CalendarInvitationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CalendarInvitationRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationRecord>(
      id,
      columnValues: columnValues(CalendarInvitationRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarInvitationRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarInvitationRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationRecord>(
      columnValues: columnValues(CalendarInvitationRecord.t.updateTable),
      where: where(CalendarInvitationRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationRecord].
  Future<CalendarInvitationRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationRecord>(
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
  Future<List<CalendarInvitationRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationRecordTable> where,
    _is.OrderByBuilder<CalendarInvitationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationRecord>(
      where: where(CalendarInvitationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationRecord>(
      where: where?.call(CalendarInvitationRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationRecord>(
      where: where(CalendarInvitationRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
