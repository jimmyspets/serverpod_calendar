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
import 'calendar_scheduling_reply_outcome.dart' as _ikqvfn4d;

abstract class CalendarSchedulingReplySourceRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarSchedulingReplySourceRecord._({
    this.id,
    required this.scopeKey,
    required this.meetingId,
    required this.attendeeAddress,
    required this.digest,
    required this.normalizedSource,
    this.sequence,
    required this.stamp,
    this.sourceParticipation,
    required this.effectiveParticipation,
    required this.outcome,
    required this.publishedSequence,
    required this.publishedCancelled,
    required this.receivedAt,
    this.inactiveAt,
  });

  factory CalendarSchedulingReplySourceRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String attendeeAddress,
    required String digest,
    required String normalizedSource,
    int? sequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int publishedSequence,
    required bool publishedCancelled,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) = _CalendarSchedulingReplySourceRecordImpl;

  factory CalendarSchedulingReplySourceRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarSchedulingReplySourceRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      meetingId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['meetingId'],
      ),
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      digest: jsonSerialization['digest'] as String,
      normalizedSource: jsonSerialization['normalizedSource'] as String,
      sequence: jsonSerialization['sequence'] as int?,
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
      outcome: _ikqvfn4d.CalendarSchedulingReplyOutcome.fromJson(
        (jsonSerialization['outcome'] as String),
      ),
      publishedSequence: jsonSerialization['publishedSequence'] as int,
      publishedCancelled: _is.BoolJsonExtension.fromJson(
        jsonSerialization['publishedCancelled'],
      ),
      receivedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['receivedAt'],
      ),
      inactiveAt: jsonSerialization['inactiveAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['inactiveAt']),
    );
  }

  static final t = CalendarSchedulingReplySourceRecordTable();

  static const db = CalendarSchedulingReplySourceRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  _is.UuidValue meetingId;

  String attendeeAddress;

  String digest;

  String normalizedSource;

  int? sequence;

  DateTime stamp;

  _iot0xi24.CalendarSchedulingParticipation? sourceParticipation;

  _iot0xi24.CalendarSchedulingParticipation effectiveParticipation;

  _ikqvfn4d.CalendarSchedulingReplyOutcome outcome;

  int publishedSequence;

  bool publishedCancelled;

  DateTime receivedAt;

  DateTime? inactiveAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarSchedulingReplySourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarSchedulingReplySourceRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? attendeeAddress,
    String? digest,
    String? normalizedSource,
    int? sequence,
    DateTime? stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? publishedSequence,
    bool? publishedCancelled,
    DateTime? receivedAt,
    DateTime? inactiveAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarSchedulingReplySourceRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'meetingId': meetingId.toJson(),
      'attendeeAddress': attendeeAddress,
      'digest': digest,
      'normalizedSource': normalizedSource,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      if (sourceParticipation != null)
        'sourceParticipation': sourceParticipation?.toJson(),
      'effectiveParticipation': effectiveParticipation.toJson(),
      'outcome': outcome.toJson(),
      'publishedSequence': publishedSequence,
      'publishedCancelled': publishedCancelled,
      'receivedAt': receivedAt.toJson(),
      if (inactiveAt != null) 'inactiveAt': inactiveAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarSchedulingReplySourceRecordInclude include() {
    return CalendarSchedulingReplySourceRecordInclude._();
  }

  static CalendarSchedulingReplySourceRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    CalendarSchedulingReplySourceRecordInclude? include,
  }) {
    return CalendarSchedulingReplySourceRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarSchedulingReplySourceRecordImpl
    extends CalendarSchedulingReplySourceRecord {
  _CalendarSchedulingReplySourceRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required _is.UuidValue meetingId,
    required String attendeeAddress,
    required String digest,
    required String normalizedSource,
    int? sequence,
    required DateTime stamp,
    _iot0xi24.CalendarSchedulingParticipation? sourceParticipation,
    required _iot0xi24.CalendarSchedulingParticipation effectiveParticipation,
    required _ikqvfn4d.CalendarSchedulingReplyOutcome outcome,
    required int publishedSequence,
    required bool publishedCancelled,
    required DateTime receivedAt,
    DateTime? inactiveAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         meetingId: meetingId,
         attendeeAddress: attendeeAddress,
         digest: digest,
         normalizedSource: normalizedSource,
         sequence: sequence,
         stamp: stamp,
         sourceParticipation: sourceParticipation,
         effectiveParticipation: effectiveParticipation,
         outcome: outcome,
         publishedSequence: publishedSequence,
         publishedCancelled: publishedCancelled,
         receivedAt: receivedAt,
         inactiveAt: inactiveAt,
       );

  /// Returns a shallow copy of this [CalendarSchedulingReplySourceRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarSchedulingReplySourceRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    _is.UuidValue? meetingId,
    String? attendeeAddress,
    String? digest,
    String? normalizedSource,
    Object? sequence = _Undefined,
    DateTime? stamp,
    Object? sourceParticipation = _Undefined,
    _iot0xi24.CalendarSchedulingParticipation? effectiveParticipation,
    _ikqvfn4d.CalendarSchedulingReplyOutcome? outcome,
    int? publishedSequence,
    bool? publishedCancelled,
    DateTime? receivedAt,
    Object? inactiveAt = _Undefined,
  }) {
    return CalendarSchedulingReplySourceRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      meetingId: meetingId ?? this.meetingId,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      digest: digest ?? this.digest,
      normalizedSource: normalizedSource ?? this.normalizedSource,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      sourceParticipation:
          sourceParticipation is _iot0xi24.CalendarSchedulingParticipation?
          ? sourceParticipation
          : this.sourceParticipation,
      effectiveParticipation:
          effectiveParticipation ?? this.effectiveParticipation,
      outcome: outcome ?? this.outcome,
      publishedSequence: publishedSequence ?? this.publishedSequence,
      publishedCancelled: publishedCancelled ?? this.publishedCancelled,
      receivedAt: receivedAt ?? this.receivedAt,
      inactiveAt: inactiveAt is DateTime? ? inactiveAt : this.inactiveAt,
    );
  }
}

class CalendarSchedulingReplySourceRecordUpdateTable
    extends _is.UpdateTable<CalendarSchedulingReplySourceRecordTable> {
  CalendarSchedulingReplySourceRecordUpdateTable(super.table);

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

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
    value,
  );

  _is.ColumnValue<String, String> normalizedSource(String value) =>
      _is.ColumnValue(
        table.normalizedSource,
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

  _is.ColumnValue<
    _ikqvfn4d.CalendarSchedulingReplyOutcome,
    _ikqvfn4d.CalendarSchedulingReplyOutcome
  >
  outcome(_ikqvfn4d.CalendarSchedulingReplyOutcome value) => _is.ColumnValue(
    table.outcome,
    value,
  );

  _is.ColumnValue<int, int> publishedSequence(int value) => _is.ColumnValue(
    table.publishedSequence,
    value,
  );

  _is.ColumnValue<bool, bool> publishedCancelled(bool value) => _is.ColumnValue(
    table.publishedCancelled,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> inactiveAt(DateTime? value) =>
      _is.ColumnValue(
        table.inactiveAt,
        value,
      );
}

class CalendarSchedulingReplySourceRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarSchedulingReplySourceRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_scheduling_reply_source') {
    updateTable = CalendarSchedulingReplySourceRecordUpdateTable(this);
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
    digest = _is.ColumnString(
      'digest',
      this,
    );
    normalizedSource = _is.ColumnString(
      'normalizedSource',
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
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
    );
    publishedSequence = _is.ColumnInt(
      'publishedSequence',
      this,
    );
    publishedCancelled = _is.ColumnBool(
      'publishedCancelled',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'receivedAt',
      this,
    );
    inactiveAt = _is.ColumnDateTime(
      'inactiveAt',
      this,
    );
  }

  late final CalendarSchedulingReplySourceRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnUuid meetingId;

  late final _is.ColumnString attendeeAddress;

  late final _is.ColumnString digest;

  late final _is.ColumnString normalizedSource;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnEnum<_iot0xi24.CalendarSchedulingParticipation>
  sourceParticipation;

  late final _is.ColumnEnum<_iot0xi24.CalendarSchedulingParticipation>
  effectiveParticipation;

  late final _is.ColumnEnum<_ikqvfn4d.CalendarSchedulingReplyOutcome> outcome;

  late final _is.ColumnInt publishedSequence;

  late final _is.ColumnBool publishedCancelled;

  late final _is.ColumnDateTime receivedAt;

  late final _is.ColumnDateTime inactiveAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    meetingId,
    attendeeAddress,
    digest,
    normalizedSource,
    sequence,
    stamp,
    sourceParticipation,
    effectiveParticipation,
    outcome,
    publishedSequence,
    publishedCancelled,
    receivedAt,
    inactiveAt,
  ];
}

class CalendarSchedulingReplySourceRecordInclude extends _is.IncludeObject {
  CalendarSchedulingReplySourceRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingReplySourceRecord.t;
}

class CalendarSchedulingReplySourceRecordIncludeList extends _is.IncludeList {
  CalendarSchedulingReplySourceRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarSchedulingReplySourceRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarSchedulingReplySourceRecord.t;
}

class CalendarSchedulingReplySourceRecordRepository {
  const CalendarSchedulingReplySourceRecordRepository._();

  /// Returns a list of [CalendarSchedulingReplySourceRecord]s matching the given query parameters.
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
  Future<List<CalendarSchedulingReplySourceRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarSchedulingReplySourceRecord>(
      where: where?.call(CalendarSchedulingReplySourceRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarSchedulingReplySourceRecord] matching the given query parameters.
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
  Future<CalendarSchedulingReplySourceRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarSchedulingReplySourceRecord>(
      where: where?.call(CalendarSchedulingReplySourceRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarSchedulingReplySourceRecord] by its [id] or null if no such row exists.
  Future<CalendarSchedulingReplySourceRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarSchedulingReplySourceRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarSchedulingReplySourceRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarSchedulingReplySourceRecord]s will have their `id` fields set.
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
  Future<List<CalendarSchedulingReplySourceRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplySourceRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarSchedulingReplySourceRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarSchedulingReplySourceRecord] and returns the inserted row.
  ///
  /// The returned [CalendarSchedulingReplySourceRecord] will have its `id` field set.
  Future<CalendarSchedulingReplySourceRecord> insertRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplySourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarSchedulingReplySourceRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarSchedulingReplySourceRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarSchedulingReplySourceRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplySourceRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplySourceRecord> rows, {
    required _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarSchedulingReplySourceRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarSchedulingReplySourceRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingReplySourceRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarSchedulingReplySourceRecord] and returns the resulting row.
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
  /// The returned [CalendarSchedulingReplySourceRecord] will have its `id` field set.
  Future<CalendarSchedulingReplySourceRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplySourceRecord row, {
    required _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarSchedulingReplySourceRecord>(
      row,
      conflictColumns: conflictColumns(CalendarSchedulingReplySourceRecord.t),
      updateColumns: updateColumns?.call(CalendarSchedulingReplySourceRecord.t),
      updateWhere: updateWhere?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingReplySourceRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplySourceRecord>> update(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplySourceRecord> rows, {
    _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarSchedulingReplySourceRecord>(
      rows,
      columns: columns?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarSchedulingReplySourceRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarSchedulingReplySourceRecord> updateRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplySourceRecord row, {
    _is.ColumnSelections<CalendarSchedulingReplySourceRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarSchedulingReplySourceRecord>(
      row,
      columns: columns?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarSchedulingReplySourceRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarSchedulingReplySourceRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingReplySourceRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarSchedulingReplySourceRecord>(
      id,
      columnValues: columnValues(
        CalendarSchedulingReplySourceRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarSchedulingReplySourceRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarSchedulingReplySourceRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarSchedulingReplySourceRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplySourceRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarSchedulingReplySourceRecord>(
      columnValues: columnValues(
        CalendarSchedulingReplySourceRecord.t.updateTable,
      ),
      where: where(CalendarSchedulingReplySourceRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarSchedulingReplySourceRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarSchedulingReplySourceRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarSchedulingReplySourceRecord> rows, {
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarSchedulingReplySourceRecord>(
      rows,
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarSchedulingReplySourceRecord].
  Future<CalendarSchedulingReplySourceRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarSchedulingReplySourceRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarSchedulingReplySourceRecord>(
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
  Future<List<CalendarSchedulingReplySourceRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplySourceRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarSchedulingReplySourceRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarSchedulingReplySourceRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarSchedulingReplySourceRecord>(
      where: where(CalendarSchedulingReplySourceRecord.t),
      orderBy: orderBy?.call(CalendarSchedulingReplySourceRecord.t),
      orderByList: orderByList?.call(CalendarSchedulingReplySourceRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarSchedulingReplySourceRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarSchedulingReplySourceRecord>(
      where: where?.call(CalendarSchedulingReplySourceRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarSchedulingReplySourceRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarSchedulingReplySourceRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarSchedulingReplySourceRecord>(
      where: where(CalendarSchedulingReplySourceRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
