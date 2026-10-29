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

abstract class CalendarInvitationApplicationRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationApplicationRecord._({
    this.id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required this.scopeKey,
    required this.recipientKey,
    required this.linkId,
    required this.revision,
    required this.invitationId,
    required this.sourceId,
    required this.digest,
    this.sequence,
    required this.stamp,
    required this.baselineDigest,
    required this.creationDigest,
    required this.eventRevision,
    required this.invitationRevision,
    required this.appliedAt,
    required this.requestDigest,
    required this.resultId,
  }) : kind = kind ?? _ilccsff7.CalendarInvitationSourceKind.request;

  factory CalendarInvitationApplicationRecord({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue linkId,
    required int revision,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required String digest,
    int? sequence,
    required DateTime stamp,
    required String baselineDigest,
    required String creationDigest,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
    required String requestDigest,
    required _is.UuidValue resultId,
  }) = _CalendarInvitationApplicationRecordImpl;

  factory CalendarInvitationApplicationRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationApplicationRecord(
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
      linkId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['linkId']),
      revision: jsonSerialization['revision'] as int,
      invitationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitationId'],
      ),
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      digest: jsonSerialization['digest'] as String,
      sequence: jsonSerialization['sequence'] as int?,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      baselineDigest: jsonSerialization['baselineDigest'] as String,
      creationDigest: jsonSerialization['creationDigest'] as String,
      eventRevision: jsonSerialization['eventRevision'] as int,
      invitationRevision: jsonSerialization['invitationRevision'] as int,
      appliedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['appliedAt'],
      ),
      requestDigest: jsonSerialization['requestDigest'] as String,
      resultId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['resultId'],
      ),
    );
  }

  static final t = CalendarInvitationApplicationRecordTable();

  static const db = CalendarInvitationApplicationRecordRepository._();

  @override
  _is.UuidValue? id;

  _ilccsff7.CalendarInvitationSourceKind kind;

  String scopeKey;

  String recipientKey;

  _is.UuidValue linkId;

  int revision;

  _is.UuidValue invitationId;

  _is.UuidValue sourceId;

  String digest;

  int? sequence;

  DateTime stamp;

  String baselineDigest;

  String creationDigest;

  int eventRevision;

  int invitationRevision;

  DateTime appliedAt;

  String requestDigest;

  _is.UuidValue resultId;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationApplicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationApplicationRecord copyWith({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? linkId,
    int? revision,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    String? digest,
    int? sequence,
    DateTime? stamp,
    String? baselineDigest,
    String? creationDigest,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
    String? requestDigest,
    _is.UuidValue? resultId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationApplicationRecord',
      if (id != null) 'id': id?.toJson(),
      'kind': kind.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'linkId': linkId.toJson(),
      'revision': revision,
      'invitationId': invitationId.toJson(),
      'sourceId': sourceId.toJson(),
      'digest': digest,
      if (sequence != null) 'sequence': sequence,
      'stamp': stamp.toJson(),
      'baselineDigest': baselineDigest,
      'creationDigest': creationDigest,
      'eventRevision': eventRevision,
      'invitationRevision': invitationRevision,
      'appliedAt': appliedAt.toJson(),
      'requestDigest': requestDigest,
      'resultId': resultId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationApplicationRecordInclude include() {
    return CalendarInvitationApplicationRecordInclude._();
  }

  static CalendarInvitationApplicationRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    CalendarInvitationApplicationRecordInclude? include,
  }) {
    return CalendarInvitationApplicationRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationApplicationRecordImpl
    extends CalendarInvitationApplicationRecord {
  _CalendarInvitationApplicationRecordImpl({
    _is.UuidValue? id,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue linkId,
    required int revision,
    required _is.UuidValue invitationId,
    required _is.UuidValue sourceId,
    required String digest,
    int? sequence,
    required DateTime stamp,
    required String baselineDigest,
    required String creationDigest,
    required int eventRevision,
    required int invitationRevision,
    required DateTime appliedAt,
    required String requestDigest,
    required _is.UuidValue resultId,
  }) : super._(
         id: id,
         kind: kind,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         linkId: linkId,
         revision: revision,
         invitationId: invitationId,
         sourceId: sourceId,
         digest: digest,
         sequence: sequence,
         stamp: stamp,
         baselineDigest: baselineDigest,
         creationDigest: creationDigest,
         eventRevision: eventRevision,
         invitationRevision: invitationRevision,
         appliedAt: appliedAt,
         requestDigest: requestDigest,
         resultId: resultId,
       );

  /// Returns a shallow copy of this [CalendarInvitationApplicationRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationApplicationRecord copyWith({
    Object? id = _Undefined,
    _ilccsff7.CalendarInvitationSourceKind? kind,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? linkId,
    int? revision,
    _is.UuidValue? invitationId,
    _is.UuidValue? sourceId,
    String? digest,
    Object? sequence = _Undefined,
    DateTime? stamp,
    String? baselineDigest,
    String? creationDigest,
    int? eventRevision,
    int? invitationRevision,
    DateTime? appliedAt,
    String? requestDigest,
    _is.UuidValue? resultId,
  }) {
    return CalendarInvitationApplicationRecord(
      id: id is _is.UuidValue? ? id : this.id,
      kind: kind ?? this.kind,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      linkId: linkId ?? this.linkId,
      revision: revision ?? this.revision,
      invitationId: invitationId ?? this.invitationId,
      sourceId: sourceId ?? this.sourceId,
      digest: digest ?? this.digest,
      sequence: sequence is int? ? sequence : this.sequence,
      stamp: stamp ?? this.stamp,
      baselineDigest: baselineDigest ?? this.baselineDigest,
      creationDigest: creationDigest ?? this.creationDigest,
      eventRevision: eventRevision ?? this.eventRevision,
      invitationRevision: invitationRevision ?? this.invitationRevision,
      appliedAt: appliedAt ?? this.appliedAt,
      requestDigest: requestDigest ?? this.requestDigest,
      resultId: resultId ?? this.resultId,
    );
  }
}

class CalendarInvitationApplicationRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationApplicationRecordTable> {
  CalendarInvitationApplicationRecordUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> linkId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.linkId,
        value,
      );

  _is.ColumnValue<int, int> revision(int value) => _is.ColumnValue(
    table.revision,
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

  _is.ColumnValue<String, String> digest(String value) => _is.ColumnValue(
    table.digest,
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

  _is.ColumnValue<String, String> baselineDigest(String value) =>
      _is.ColumnValue(
        table.baselineDigest,
        value,
      );

  _is.ColumnValue<String, String> creationDigest(String value) =>
      _is.ColumnValue(
        table.creationDigest,
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

  _is.ColumnValue<DateTime, DateTime> appliedAt(DateTime value) =>
      _is.ColumnValue(
        table.appliedAt,
        value,
      );

  _is.ColumnValue<String, String> requestDigest(String value) =>
      _is.ColumnValue(
        table.requestDigest,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> resultId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.resultId,
        value,
      );
}

class CalendarInvitationApplicationRecordTable
    extends _is.Table<_is.UuidValue?> {
  CalendarInvitationApplicationRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_application') {
    updateTable = CalendarInvitationApplicationRecordUpdateTable(this);
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
    linkId = _is.ColumnUuid(
      'linkId',
      this,
    );
    revision = _is.ColumnInt(
      'revision',
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
    digest = _is.ColumnString(
      'digest',
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
    baselineDigest = _is.ColumnString(
      'baselineDigest',
      this,
    );
    creationDigest = _is.ColumnString(
      'creationDigest',
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
    appliedAt = _is.ColumnDateTime(
      'appliedAt',
      this,
    );
    requestDigest = _is.ColumnString(
      'requestDigest',
      this,
    );
    resultId = _is.ColumnUuid(
      'resultId',
      this,
    );
  }

  late final CalendarInvitationApplicationRecordUpdateTable updateTable;

  late final _is.ColumnEnum<_ilccsff7.CalendarInvitationSourceKind> kind;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid linkId;

  late final _is.ColumnInt revision;

  late final _is.ColumnUuid invitationId;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnString digest;

  late final _is.ColumnInt sequence;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString baselineDigest;

  late final _is.ColumnString creationDigest;

  late final _is.ColumnInt eventRevision;

  late final _is.ColumnInt invitationRevision;

  late final _is.ColumnDateTime appliedAt;

  late final _is.ColumnString requestDigest;

  late final _is.ColumnUuid resultId;

  @override
  List<_is.Column> get columns => [
    id,
    kind,
    scopeKey,
    recipientKey,
    linkId,
    revision,
    invitationId,
    sourceId,
    digest,
    sequence,
    stamp,
    baselineDigest,
    creationDigest,
    eventRevision,
    invitationRevision,
    appliedAt,
    requestDigest,
    resultId,
  ];
}

class CalendarInvitationApplicationRecordInclude extends _is.IncludeObject {
  CalendarInvitationApplicationRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationApplicationRecord.t;
}

class CalendarInvitationApplicationRecordIncludeList extends _is.IncludeList {
  CalendarInvitationApplicationRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationApplicationRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationApplicationRecord.t;
}

class CalendarInvitationApplicationRecordRepository {
  const CalendarInvitationApplicationRecordRepository._();

  /// Returns a list of [CalendarInvitationApplicationRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationApplicationRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationApplicationRecord>(
      where: where?.call(CalendarInvitationApplicationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationApplicationRecord] matching the given query parameters.
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
  Future<CalendarInvitationApplicationRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationApplicationRecord>(
      where: where?.call(CalendarInvitationApplicationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationApplicationRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationApplicationRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationApplicationRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationApplicationRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationApplicationRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationApplicationRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationApplicationRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationApplicationRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationApplicationRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationApplicationRecord] will have its `id` field set.
  Future<CalendarInvitationApplicationRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationApplicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationApplicationRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationApplicationRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationApplicationRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationApplicationRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationApplicationRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationApplicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationApplicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationApplicationRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationApplicationRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationApplicationRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationApplicationRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationApplicationRecord] will have its `id` field set.
  Future<CalendarInvitationApplicationRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationApplicationRecord row, {
    required _is.ColumnSelections<CalendarInvitationApplicationRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationApplicationRecordTable>?
    updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationApplicationRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationApplicationRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationApplicationRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationApplicationRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationApplicationRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationApplicationRecord> rows, {
    _is.ColumnSelections<CalendarInvitationApplicationRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationApplicationRecord>(
      rows,
      columns: columns?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationApplicationRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationApplicationRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationApplicationRecord row, {
    _is.ColumnSelections<CalendarInvitationApplicationRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationApplicationRecord>(
      row,
      columns: columns?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationApplicationRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationApplicationRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationApplicationRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationApplicationRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationApplicationRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationApplicationRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationApplicationRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationApplicationRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<
      CalendarInvitationApplicationRecordTable
    >
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationApplicationRecord>(
      columnValues: columnValues(
        CalendarInvitationApplicationRecord.t.updateTable,
      ),
      where: where(CalendarInvitationApplicationRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationApplicationRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationApplicationRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationApplicationRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationApplicationRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationApplicationRecord].
  Future<CalendarInvitationApplicationRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationApplicationRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationApplicationRecord>(
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
  Future<List<CalendarInvitationApplicationRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationApplicationRecordTable
    >
    where,
    _is.OrderByBuilder<CalendarInvitationApplicationRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationApplicationRecordTable>?
    orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationApplicationRecord>(
      where: where(CalendarInvitationApplicationRecord.t),
      orderBy: orderBy?.call(CalendarInvitationApplicationRecord.t),
      orderByList: orderByList?.call(CalendarInvitationApplicationRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationApplicationRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationApplicationRecord>(
      where: where?.call(CalendarInvitationApplicationRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationApplicationRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<
      CalendarInvitationApplicationRecordTable
    >
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationApplicationRecord>(
      where: where(CalendarInvitationApplicationRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
