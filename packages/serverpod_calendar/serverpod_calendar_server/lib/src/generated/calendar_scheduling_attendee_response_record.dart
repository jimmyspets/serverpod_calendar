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
import 'calendar_scheduling_participation.dart' as _iot0xi24;

abstract class CalendarSchedulingAttendeeResponseRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingAttendeeResponseRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.attendeeAddress,
    required this.revision,
    required this.sourceId,
    required this.sequence,
    required this.stamp,
    this.sourceParticipation,
    required this.effectiveParticipation,
    required this.receivedAt,
  });

  factory CalendarSchedulingAttendeeResponseRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String attendeeAddress,
    required int revision,
    required _is.UuidValue sourceId,
    required int sequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required DateTime receivedAt,
  }) = _CalendarSchedulingAttendeeResponseRecordImpl;

  factory CalendarSchedulingAttendeeResponseRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingAttendeeResponseRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      revision: jsonSerialization['revision'] as int,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sequence: jsonSerialization['sequence'] as int,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      sourceParticipation: jsonSerialization['sourceParticipation'] == null
          ? null
          : _iot0xi24.CalendarSchedulingParticipation.fromJson(
              (jsonSerialization['sourceParticipation'] as String),
            ),
      effectiveParticipation:
          _iot0xi24.CalendarSchedulingParticipation.fromJson(
            (jsonSerialization['effectiveParticipation'] as String),
          ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
    );
  }

  static final t = CalendarSchedulingAttendeeResponseRecordTable();

  static const db = CalendarSchedulingAttendeeResponseRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  String attendeeAddress;

  int revision;

  _is.UuidValue sourceId;

  int sequence;

  DateTime stamp;

  _iot0xi24.CalendarSchedulingParticipation? sourceParticipation;

  _iot0xi24.CalendarSchedulingParticipation effectiveParticipation;

  DateTime receivedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingAttendeeResponseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingAttendeeResponseRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? attendeeAddress,
    int? revision,
    _is.UuidValue? sourceId,
    int? sequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__':
          'serverpod_calendar.CalendarSchedulingAttendeeResponseRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'attendeeAddress': attendeeAddress,
      'revision': revision,
      'sourceId': sourceId.toJson(),
      'sequence': sequence,
      'stamp': stamp.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      'effectiveParticipation': effectiveParticipation.toJson(),
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingAttendeeResponseRecordInclude include() {
    return CalendarSchedulingAttendeeResponseRecordInclude._();
  }

  static CalendarSchedulingAttendeeResponseRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    CalendarSchedulingAttendeeResponseRecordInclude? include,
  }) {
    return CalendarSchedulingAttendeeResponseRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingAttendeeResponseRecordImpl
    extends CalendarSchedulingAttendeeResponseRecord {
  _CalendarSchedulingAttendeeResponseRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String attendeeAddress,
    required int revision,
    required _is.UuidValue sourceId,
    required int sequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required DateTime receivedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         attendeeAddress: attendeeAddress,
         revision: revision,
         sourceId: sourceId,
         sequence: sequence,
         stamp: stamp,
         sourceParticipation: sourceParticipation,
         effectiveParticipation: effectiveParticipation,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [CalendarSchedulingAttendeeResponseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingAttendeeResponseRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? attendeeAddress,
    int? revision,
    _is.UuidValue? sourceId,
    int? sequence,
    DateTime? stamp,
    Object? sourceParticipation = _Undefined,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    DateTime? receivedAt,
  }) {
    return CalendarSchedulingAttendeeResponseRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      revision: revision ?? this.revision,
      sourceId: sourceId ?? this.sourceId,
      sequence: sequence ?? this.sequence,
      stamp: stamp ?? this.stamp,
      sourceParticipation:
          sourceParticipation is _iot0xi24.CalendarSchedulingParticipation?
          ? sourceParticipation
          : this.sourceParticipation,
      effectiveParticipation:
          effectiveParticipation ?? this.effectiveParticipation,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class CalendarSchedulingAttendeeResponseRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingAttendeeResponseRecordTable> {
  CalendarSchedulingAttendeeResponseRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> attendeeAddress(String value) =>
      _is.ColumnValue(
        table.attendeeAddress,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.sourceId,
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

  _is.ColumnValue<
    _iot0xi24.CalendarSchedulingParticipation,
    _iot0xi24.CalendarSchedulingParticipation
  >
  sourceParticipation(_iot0xi24.CalendarSchedulingParticipation? value) =>
      _is.ColumnValue(
        table.sourceParticipation,
        value,
      );

  _is.ColumnValue<
    _iot0xi24.CalendarSchedulingParticipation,
    _iot0xi24.CalendarSchedulingParticipation
  >
  effectiveParticipation(_iot0xi24.CalendarSchedulingParticipation value) =>
      _is.ColumnValue(
        table.effectiveParticipation,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class CalendarSchedulingAttendeeResponseRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingAttendeeResponseRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_attendee_response') {
    updateTable = CalendarSchedulingAttendeeResponseRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    meetingId = _is.ColumnUuid(
      'meetingId',
      this,
    );
    attendeeAddress = _is.ColumnString(
      'attendeeAddress',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
      this,
    );
    sourceId = _is.ColumnUuid(
      'sourceId',
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
    sourceParticipation = _is.ColumnEnum(
      'sourceParticipation',
      this,
      _is.EnumSerialization.byName,
    );
    effectiveParticipation = _is.ColumnEnum(
      'effectiveParticipation',
      this,
      _is.EnumSerialization.byName,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
  }

  late final CalendarSchedulingAttendeeResponseRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnString attendeeAddress;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnEnum<_iot0xi24.CalendarSchedulingParticipation>
  sourceParticipation;

  late final _is.ColumnEnum<_iot0xi24.CalendarSchedulingParticipation>
  effectiveParticipation;

  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    attendeeAddress,
    revision,
    sourceId,
    sequence,
    stamp,
    sourceParticipation,
    effectiveParticipation,
    receivedAt,
  ];
}

class CalendarSchedulingAttendeeResponseRecordInclude
    extends _is.IncludeObject {
  CalendarSchedulingAttendeeResponseRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarSchedulingAttendeeResponseRecord.t;
}

class CalendarSchedulingAttendeeResponseRecordIncludeList
    extends _is.IncludeList {
  CalendarSchedulingAttendeeResponseRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingAttendeeResponseRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table =>
      CalendarSchedulingAttendeeResponseRecord.t;
}

class CalendarSchedulingAttendeeResponseRecordRepository {
  const CalendarSchedulingAttendeeResponseRecordRepository._();

  /// Returns a list of [CalendarSchedulingAttendeeResponseRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingAttendeeResponseRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingAttendeeResponseRecord>(
      where: where?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingAttendeeResponseRecord] matching the given query parameters.
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
  Future<CalendarSchedulingAttendeeResponseRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingAttendeeResponseRecord>(
      where: where?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingAttendeeResponseRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingAttendeeResponseRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingAttendeeResponseRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingAttendeeResponseRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingAttendeeResponseRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingAttendeeResponseRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttendeeResponseRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingAttendeeResponseRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingAttendeeResponseRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingAttendeeResponseRecord] will have its `id` field set.
  Future<CalendarSchedulingAttendeeResponseRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttendeeResponseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingAttendeeResponseRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingAttendeeResponseRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingAttendeeResponseRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttendeeResponseRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttendeeResponseRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingAttendeeResponseRecord>(
      rows,
      conflictColumns: conflictColumns(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingAttendeeResponseRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingAttendeeResponseRecord] will have its `id` field set.
  Future<CalendarSchedulingAttendeeResponseRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttendeeResponseRecord row, {
    required _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingAttendeeResponseRecord>(
      row,
      conflictColumns: conflictColumns(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      updateColumns: updateColumns?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      updateWhere: updateWhere?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingAttendeeResponseRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttendeeResponseRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttendeeResponseRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>?
    columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingAttendeeResponseRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingAttendeeResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingAttendeeResponseRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingAttendeeResponseRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttendeeResponseRecord row, {
    _is.ColumnSelections<CalendarSchedulingAttendeeResponseRecordTable>?
    columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingAttendeeResponseRecord>(
      row,
      columns: columns?.call(CalendarSchedulingAttendeeResponseRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingAttendeeResponseRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingAttendeeResponseRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingAttendeeResponseRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingAttendeeResponseRecord>(
      id,
      columnValues: columnValues(
        CalendarSchedulingAttendeeResponseRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingAttendeeResponseRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingAttendeeResponseRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingAttendeeResponseRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarSchedulingAttendeeResponseRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingAttendeeResponseRecord>(
      columnValues: columnValues(
        CalendarSchedulingAttendeeResponseRecord.t.updateTable,
      ),
      where: where(CalendarSchedulingAttendeeResponseRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingAttendeeResponseRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingAttendeeResponseRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingAttendeeResponseRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingAttendeeResponseRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingAttendeeResponseRecord].
  Future<CalendarSchedulingAttendeeResponseRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingAttendeeResponseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingAttendeeResponseRecord>(
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
  Future<List<CalendarSchedulingAttendeeResponseRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingAttendeeResponseRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarSchedulingAttendeeResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingAttendeeResponseRecord>(
      where: where(CalendarSchedulingAttendeeResponseRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingAttendeeResponseRecord.t),
      orderByList: orderByList?.call(
        CalendarSchedulingAttendeeResponseRecord.t,
      ),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingAttendeeResponseRecordTable>?
    where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingAttendeeResponseRecord>(
      where: where?.call(CalendarSchedulingAttendeeResponseRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingAttendeeResponseRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingAttendeeResponseRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingAttendeeResponseRecord>(
      where: where(CalendarSchedulingAttendeeResponseRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
