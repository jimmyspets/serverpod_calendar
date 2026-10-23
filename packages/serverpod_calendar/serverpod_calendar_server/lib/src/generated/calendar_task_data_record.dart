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
import 'calendar_task_assignee.dart' as _ih5e3u6u;
import 'calendar_task_content.dart' as _if7nbvl8;
import 'calendar_task_import_baseline.dart' as _iqsm27bn;
import 'calendar_task_progress.dart' as _ikcsq95s;
import 'calendar_task_protocol_version.dart' as _iz9t6x1i;
import 'calendar_task_source_state.dart' as _it1pm24a;

abstract class CalendarTaskDataRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarTaskDataRecord._({
    this.id,
    required this.taskId,
    required this.calendarId,
    required this.protocolUid,
    required this.uidDigest,
    required this.protocolVersion,
    required this.content,
    required this.progress,
    required this.assignees,
    required this.createdAt,
    required this.updatedAt,
    this.hasRecordedProgress,
    this.sourceState,
    this.importBaseline,
  });

  factory CalendarTaskDataRecord({
    int? id,
    required _is.UuidValue taskId,
    required _is.UuidValue calendarId,
    required String protocolUid,
    required String uidDigest,
    required _iz9t6x1i.CalendarTaskProtocolVersion protocolVersion,
    required _if7nbvl8.CalendarTaskContent content,
    required _ikcsq95s.CalendarTaskProgress progress,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool? hasRecordedProgress,
    _it1pm24a.CalendarTaskSourceState? sourceState,
    _iqsm27bn.CalendarTaskImportBaseline? importBaseline,
  }) = _CalendarTaskDataRecordImpl;

  factory CalendarTaskDataRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarTaskDataRecord(
      id: jsonSerialization['id'] as int?,
      taskId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['taskId']),
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      protocolUid: jsonSerialization['protocolUid'] as String,
      uidDigest: jsonSerialization['uidDigest'] as String,
      protocolVersion: _ix00hwbf.Protocol()
          .deserialize<_iz9t6x1i.CalendarTaskProtocolVersion>(
            jsonSerialization['protocolVersion'],
          ),
      content: _ix00hwbf.Protocol().deserialize<_if7nbvl8.CalendarTaskContent>(
        jsonSerialization['content'],
      ),
      progress: _ix00hwbf.Protocol()
          .deserialize<_ikcsq95s.CalendarTaskProgress>(
            jsonSerialization['progress'],
          ),
      assignees: _ix00hwbf.Protocol()
          .deserialize<List<_ih5e3u6u.CalendarTaskAssignee>>(
            jsonSerialization['assignees'],
          ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      hasRecordedProgress: jsonSerialization['hasRecordedProgress'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['hasRecordedProgress'],
            ),
      sourceState: jsonSerialization['sourceState'] == null
          ? null
          : _ix00hwbf.Protocol().deserialize<_it1pm24a.CalendarTaskSourceState>(
              jsonSerialization['sourceState'],
            ),
      importBaseline: jsonSerialization['importBaseline'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_iqsm27bn.CalendarTaskImportBaseline>(
                  jsonSerialization['importBaseline'],
                ),
    );
  }

  static final t = CalendarTaskDataRecordTable();

  static const db = CalendarTaskDataRecordRepository._();

  @override
  int? id;

  _is.UuidValue taskId;

  _is.UuidValue calendarId;

  String protocolUid;

  String uidDigest;

  _iz9t6x1i.CalendarTaskProtocolVersion protocolVersion;

  _if7nbvl8.CalendarTaskContent content;

  _ikcsq95s.CalendarTaskProgress progress;

  List<_ih5e3u6u.CalendarTaskAssignee> assignees;

  DateTime createdAt;

  DateTime updatedAt;

  bool? hasRecordedProgress;

  _it1pm24a.CalendarTaskSourceState? sourceState;

  _iqsm27bn.CalendarTaskImportBaseline? importBaseline;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarTaskDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarTaskDataRecord copyWith({
    int? id,
    _is.UuidValue? taskId,
    _is.UuidValue? calendarId,
    String? protocolUid,
    String? uidDigest,
    _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion,
    _if7nbvl8.CalendarTaskContent? content,
    _ikcsq95s.CalendarTaskProgress? progress,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? hasRecordedProgress,
    _it1pm24a.CalendarTaskSourceState? sourceState,
    _iqsm27bn.CalendarTaskImportBaseline? importBaseline,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarTaskDataRecord',
      if (id != null) 'id': id,
      'taskId': taskId.toJson(),
      'calendarId': calendarId.toJson(),
      'protocolUid': protocolUid,
      'uidDigest': uidDigest,
      'protocolVersion': protocolVersion.toJson(),
      'content': content.toJson(),
      'progress': progress.toJson(),
      'assignees': assignees.toJson(valueToJson: (v) => v.toJson()),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (hasRecordedProgress != null)
        'hasRecordedProgress': hasRecordedProgress,
      if (sourceState != null) 'sourceState': sourceState?.toJson(),
      if (importBaseline != null) 'importBaseline': importBaseline?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarTaskDataRecordInclude include() {
    return CalendarTaskDataRecordInclude._();
  }

  static CalendarTaskDataRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    CalendarTaskDataRecordInclude? include,
  }) {
    return CalendarTaskDataRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarTaskDataRecordImpl extends CalendarTaskDataRecord {
  _CalendarTaskDataRecordImpl({
    int? id,
    required _is.UuidValue taskId,
    required _is.UuidValue calendarId,
    required String protocolUid,
    required String uidDigest,
    required _iz9t6x1i.CalendarTaskProtocolVersion protocolVersion,
    required _if7nbvl8.CalendarTaskContent content,
    required _ikcsq95s.CalendarTaskProgress progress,
    required List<_ih5e3u6u.CalendarTaskAssignee> assignees,
    required DateTime createdAt,
    required DateTime updatedAt,
    bool? hasRecordedProgress,
    _it1pm24a.CalendarTaskSourceState? sourceState,
    _iqsm27bn.CalendarTaskImportBaseline? importBaseline,
  }) : super._(
         id: id,
         taskId: taskId,
         calendarId: calendarId,
         protocolUid: protocolUid,
         uidDigest: uidDigest,
         protocolVersion: protocolVersion,
         content: content,
         progress: progress,
         assignees: assignees,
         createdAt: createdAt,
         updatedAt: updatedAt,
         hasRecordedProgress: hasRecordedProgress,
         sourceState: sourceState,
         importBaseline: importBaseline,
       );

  /// Returns a shallow copy of this [CalendarTaskDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarTaskDataRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? taskId,
    _is.UuidValue? calendarId,
    String? protocolUid,
    String? uidDigest,
    _iz9t6x1i.CalendarTaskProtocolVersion? protocolVersion,
    _if7nbvl8.CalendarTaskContent? content,
    _ikcsq95s.CalendarTaskProgress? progress,
    List<_ih5e3u6u.CalendarTaskAssignee>? assignees,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? hasRecordedProgress = _Undefined,
    Object? sourceState = _Undefined,
    Object? importBaseline = _Undefined,
  }) {
    return CalendarTaskDataRecord(
      id: id is int? ? id : this.id,
      taskId: taskId ?? this.taskId,
      calendarId: calendarId ?? this.calendarId,
      protocolUid: protocolUid ?? this.protocolUid,
      uidDigest: uidDigest ?? this.uidDigest,
      protocolVersion: protocolVersion ?? this.protocolVersion.copyWith(),
      content: content ?? this.content.copyWith(),
      progress: progress ?? this.progress.copyWith(),
      assignees:
          assignees ?? this.assignees.map((e0) => e0.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      hasRecordedProgress: hasRecordedProgress is bool?
          ? hasRecordedProgress
          : this.hasRecordedProgress,
      sourceState: sourceState is _it1pm24a.CalendarTaskSourceState?
          ? sourceState
          : this.sourceState?.copyWith(),
      importBaseline: importBaseline is _iqsm27bn.CalendarTaskImportBaseline?
          ? importBaseline
          : this.importBaseline?.copyWith(),
    );
  }
}

class CalendarTaskDataRecordUpdateTable
    extends _is.UpdateTable<CalendarTaskDataRecordTable> {
  CalendarTaskDataRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> taskId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.taskId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<String, String> protocolUid(String value) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<String, String> uidDigest(String value) => _is.ColumnValue(
    table.uidDigest,
    value,
  );

  _is.ColumnValue<
    _iz9t6x1i.CalendarTaskProtocolVersion,
    _iz9t6x1i.CalendarTaskProtocolVersion
  >
  protocolVersion(_iz9t6x1i.CalendarTaskProtocolVersion value) =>
      _is.ColumnValue(
        table.protocolVersion,
        value,
      );

  _is.ColumnValue<_if7nbvl8.CalendarTaskContent, _if7nbvl8.CalendarTaskContent>
  content(_if7nbvl8.CalendarTaskContent value) => _is.ColumnValue(
    table.content,
    value,
  );

  _is.ColumnValue<
    _ikcsq95s.CalendarTaskProgress,
    _ikcsq95s.CalendarTaskProgress
  >
  progress(_ikcsq95s.CalendarTaskProgress value) => _is.ColumnValue(
    table.progress,
    value,
  );

  _is.ColumnValue<
    List<_ih5e3u6u.CalendarTaskAssignee>,
    List<_ih5e3u6u.CalendarTaskAssignee>
  >
  assignees(List<_ih5e3u6u.CalendarTaskAssignee> value) => _is.ColumnValue(
    table.assignees,
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

  _is.ColumnValue<bool, bool> hasRecordedProgress(bool? value) =>
      _is.ColumnValue(
        table.hasRecordedProgress,
        value,
      );

  _is.ColumnValue<
    _it1pm24a.CalendarTaskSourceState,
    _it1pm24a.CalendarTaskSourceState
  >
  sourceState(_it1pm24a.CalendarTaskSourceState? value) => _is.ColumnValue(
    table.sourceState,
    value,
  );

  _is.ColumnValue<
    _iqsm27bn.CalendarTaskImportBaseline,
    _iqsm27bn.CalendarTaskImportBaseline
  >
  importBaseline(_iqsm27bn.CalendarTaskImportBaseline? value) =>
      _is.ColumnValue(
        table.importBaseline,
        value,
      );
}

class CalendarTaskDataRecordTable extends _is.Table<int?> {
  CalendarTaskDataRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_task_data') {
    updateTable = CalendarTaskDataRecordUpdateTable(this);
    taskId = _is.ColumnUuid(
      'taskId',
      this,
    );
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    protocolUid = _is.ColumnString(
      'protocolUid',
      this,
    );
    uidDigest = _is.ColumnString(
      'uidDigest',
      this,
    );
    protocolVersion =
        _is.ColumnSerializable<_iz9t6x1i.CalendarTaskProtocolVersion>(
          'protocolVersion',
          this,
        );
    content = _is.ColumnSerializable<_if7nbvl8.CalendarTaskContent>(
      'content',
      this,
    );
    progress = _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress>(
      'progress',
      this,
    );
    assignees = _is.ColumnSerializable<List<_ih5e3u6u.CalendarTaskAssignee>>(
      'assignees',
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
    hasRecordedProgress = _is.ColumnBool(
      'hasRecordedProgress',
      this,
    );
    sourceState = _is.ColumnSerializable<_it1pm24a.CalendarTaskSourceState>(
      'sourceState',
      this,
    );
    importBaseline =
        _is.ColumnSerializable<_iqsm27bn.CalendarTaskImportBaseline>(
          'importBaseline',
          this,
        );
  }

  late final CalendarTaskDataRecordUpdateTable updateTable;

  late final _is.ColumnUuid taskId;

  late final _is.ColumnUuid calendarId;

  late final _is.ColumnString protocolUid;

  late final _is.ColumnString uidDigest;

  late final _is.ColumnSerializable<_iz9t6x1i.CalendarTaskProtocolVersion>
  protocolVersion;

  late final _is.ColumnSerializable<_if7nbvl8.CalendarTaskContent> content;

  late final _is.ColumnSerializable<_ikcsq95s.CalendarTaskProgress> progress;

  late final _is.ColumnSerializable<List<_ih5e3u6u.CalendarTaskAssignee>>
  assignees;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnBool hasRecordedProgress;

  late final _is.ColumnSerializable<_it1pm24a.CalendarTaskSourceState>
  sourceState;

  late final _is.ColumnSerializable<_iqsm27bn.CalendarTaskImportBaseline>
  importBaseline;

  @override
  List<_is.Column> get columns => [
    id,
    taskId,
    calendarId,
    protocolUid,
    uidDigest,
    protocolVersion,
    content,
    progress,
    assignees,
    createdAt,
    updatedAt,
    hasRecordedProgress,
    sourceState,
    importBaseline,
  ];
}

class CalendarTaskDataRecordInclude extends _is.IncludeObject {
  CalendarTaskDataRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarTaskDataRecord.t;
}

class CalendarTaskDataRecordIncludeList extends _is.IncludeList {
  CalendarTaskDataRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarTaskDataRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarTaskDataRecord.t;
}

class CalendarTaskDataRecordRepository {
  const CalendarTaskDataRecordRepository._();

  /// Returns a list of [CalendarTaskDataRecord]s matching the given query parameters.
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
  Future<List<CalendarTaskDataRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarTaskDataRecord>(
      where: where?.call(CalendarTaskDataRecord.t),
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarTaskDataRecord] matching the given query parameters.
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
  Future<CalendarTaskDataRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarTaskDataRecord>(
      where: where?.call(CalendarTaskDataRecord.t),
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarTaskDataRecord] by its [id] or null if no such row exists.
  Future<CalendarTaskDataRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarTaskDataRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarTaskDataRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarTaskDataRecord]s will have their `id` fields set.
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
  Future<List<CalendarTaskDataRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarTaskDataRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarTaskDataRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarTaskDataRecord] and returns the inserted row.
  ///
  /// The returned [CalendarTaskDataRecord] will have its `id` field set.
  Future<CalendarTaskDataRecord> insertRow(
    _is.DatabaseSession session,
    CalendarTaskDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarTaskDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarTaskDataRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarTaskDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskDataRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarTaskDataRecord> rows, {
    required _is.ColumnSelections<CalendarTaskDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarTaskDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarTaskDataRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarTaskDataRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskDataRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarTaskDataRecord] and returns the resulting row.
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
  /// The returned [CalendarTaskDataRecord] will have its `id` field set.
  Future<CalendarTaskDataRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarTaskDataRecord row, {
    required _is.ColumnSelections<CalendarTaskDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarTaskDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarTaskDataRecord>(
      row,
      conflictColumns: conflictColumns(CalendarTaskDataRecord.t),
      updateColumns: updateColumns?.call(CalendarTaskDataRecord.t),
      updateWhere: updateWhere?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskDataRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskDataRecord>> update(
    _is.DatabaseSession session,
    List<CalendarTaskDataRecord> rows, {
    _is.ColumnSelections<CalendarTaskDataRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarTaskDataRecord>(
      rows,
      columns: columns?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarTaskDataRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarTaskDataRecord> updateRow(
    _is.DatabaseSession session,
    CalendarTaskDataRecord row, {
    _is.ColumnSelections<CalendarTaskDataRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarTaskDataRecord>(
      row,
      columns: columns?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarTaskDataRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarTaskDataRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarTaskDataRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarTaskDataRecord>(
      id,
      columnValues: columnValues(CalendarTaskDataRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarTaskDataRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarTaskDataRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarTaskDataRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarTaskDataRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarTaskDataRecord>(
      columnValues: columnValues(CalendarTaskDataRecord.t.updateTable),
      where: where(CalendarTaskDataRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarTaskDataRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarTaskDataRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarTaskDataRecord> rows, {
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarTaskDataRecord>(
      rows,
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarTaskDataRecord].
  Future<CalendarTaskDataRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarTaskDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarTaskDataRecord>(
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
  Future<List<CalendarTaskDataRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskDataRecordTable> where,
    _is.OrderByBuilder<CalendarTaskDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarTaskDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarTaskDataRecord>(
      where: where(CalendarTaskDataRecord.t),
      orderBy: orderBy?.call(CalendarTaskDataRecord.t),
      orderByList: orderByList?.call(CalendarTaskDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarTaskDataRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarTaskDataRecord>(
      where: where?.call(CalendarTaskDataRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarTaskDataRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarTaskDataRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarTaskDataRecord>(
      where: where(CalendarTaskDataRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
