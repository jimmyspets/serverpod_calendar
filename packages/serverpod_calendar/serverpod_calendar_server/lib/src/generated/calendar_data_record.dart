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
import 'calendar_no_rule_fallback.dart' as _itts4qyp;
import 'calendar_protocol_metadata.dart' as _itchuj1l;
import 'calendar_supplemental_metadata.dart' as _ixppc388;

abstract class CalendarDataRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarDataRecord._({
    this.id,
    required this.calendarId,
    _is.UuidValue? protocolUid,
    required this.displayName,
    this.description,
    this.color,
    required this.availabilityZoneId,
    required this.noRuleFallback,
    this.protocolMetadata,
    this.supplementalMetadata,
    required this.createdAt,
    required this.updatedAt,
  }) : protocolUid = protocolUid ?? const _is.Uuid().v4obj();

  factory CalendarDataRecord({
    int? id,
    required _is.UuidValue calendarId,
    _is.UuidValue? protocolUid,
    required String displayName,
    String? description,
    String? color,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarDataRecordImpl;

  factory CalendarDataRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return CalendarDataRecord(
      id: jsonSerialization['id'] as int?,
      calendarId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['calendarId'],
      ),
      protocolUid: jsonSerialization['protocolUid'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['protocolUid'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      description: jsonSerialization['description'] as String?,
      color: jsonSerialization['color'] as String?,
      availabilityZoneId: jsonSerialization['availabilityZoneId'] as String,
      noRuleFallback: _itts4qyp.CalendarNoRuleFallback.fromJson(
        (jsonSerialization['noRuleFallback'] as String),
      ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_itchuj1l.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _ix00hwbf.Protocol()
                .deserialize<_ixppc388.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarDataRecordTable();

  static const db = CalendarDataRecordRepository._();

  @override
  int? id;

  _is.UuidValue calendarId;

  /// Native calendar protocol UID, separate from API and imported/feed identities.
  _is.UuidValue protocolUid;

  String displayName;

  String? description;

  String? color;

  String availabilityZoneId;

  _itts4qyp.CalendarNoRuleFallback noRuleFallback;

  _itchuj1l.CalendarProtocolMetadata? protocolMetadata;

  _ixppc388.CalendarSupplementalMetadata? supplementalMetadata;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarDataRecord copyWith({
    int? id,
    _is.UuidValue? calendarId,
    _is.UuidValue? protocolUid,
    String? displayName,
    String? description,
    String? color,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarDataRecord',
      if (id != null) 'id': id,
      'calendarId': calendarId.toJson(),
      'protocolUid': protocolUid.toJson(),
      'displayName': displayName,
      if (description != null) 'description': description,
      if (color != null) 'color': color,
      'availabilityZoneId': availabilityZoneId,
      'noRuleFallback': noRuleFallback.toJson(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarDataRecordInclude include() {
    return CalendarDataRecordInclude._();
  }

  static CalendarDataRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    CalendarDataRecordInclude? include,
  }) {
    return CalendarDataRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarDataRecordImpl extends CalendarDataRecord {
  _CalendarDataRecordImpl({
    int? id,
    required _is.UuidValue calendarId,
    _is.UuidValue? protocolUid,
    required String displayName,
    String? description,
    String? color,
    required String availabilityZoneId,
    required _itts4qyp.CalendarNoRuleFallback noRuleFallback,
    _itchuj1l.CalendarProtocolMetadata? protocolMetadata,
    _ixppc388.CalendarSupplementalMetadata? supplementalMetadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         calendarId: calendarId,
         protocolUid: protocolUid,
         displayName: displayName,
         description: description,
         color: color,
         availabilityZoneId: availabilityZoneId,
         noRuleFallback: noRuleFallback,
         protocolMetadata: protocolMetadata,
         supplementalMetadata: supplementalMetadata,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarDataRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? calendarId,
    _is.UuidValue? protocolUid,
    String? displayName,
    Object? description = _Undefined,
    Object? color = _Undefined,
    String? availabilityZoneId,
    _itts4qyp.CalendarNoRuleFallback? noRuleFallback,
    Object? protocolMetadata = _Undefined,
    Object? supplementalMetadata = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarDataRecord(
      id: id is int? ? id : this.id,
      calendarId: calendarId ?? this.calendarId,
      protocolUid: protocolUid ?? this.protocolUid,
      displayName: displayName ?? this.displayName,
      description: description is String? ? description : this.description,
      color: color is String? ? color : this.color,
      availabilityZoneId: availabilityZoneId ?? this.availabilityZoneId,
      noRuleFallback: noRuleFallback ?? this.noRuleFallback,
      protocolMetadata: protocolMetadata is _itchuj1l.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _ixppc388.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarDataRecordUpdateTable
    extends _is.UpdateTable<CalendarDataRecordTable> {
  CalendarDataRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> calendarId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.calendarId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> protocolUid(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<String, String> description(String? value) => _is.ColumnValue(
    table.description,
    value,
  );

  _is.ColumnValue<String, String> color(String? value) => _is.ColumnValue(
    table.color,
    value,
  );

  _is.ColumnValue<String, String> availabilityZoneId(String value) =>
      _is.ColumnValue(
        table.availabilityZoneId,
        value,
      );

  _is.ColumnValue<
    _itts4qyp.CalendarNoRuleFallback,
    _itts4qyp.CalendarNoRuleFallback
  >
  noRuleFallback(_itts4qyp.CalendarNoRuleFallback value) => _is.ColumnValue(
    table.noRuleFallback,
    value,
  );

  _is.ColumnValue<
    _itchuj1l.CalendarProtocolMetadata,
    _itchuj1l.CalendarProtocolMetadata
  >
  protocolMetadata(_itchuj1l.CalendarProtocolMetadata? value) =>
      _is.ColumnValue(
        table.protocolMetadata,
        value,
      );

  _is.ColumnValue<
    _ixppc388.CalendarSupplementalMetadata,
    _ixppc388.CalendarSupplementalMetadata
  >
  supplementalMetadata(_ixppc388.CalendarSupplementalMetadata? value) =>
      _is.ColumnValue(
        table.supplementalMetadata,
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

class CalendarDataRecordTable extends _is.Table<int?> {
  CalendarDataRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_data') {
    updateTable = CalendarDataRecordUpdateTable(this);
    calendarId = _is.ColumnUuid(
      'calendarId',
      this,
    );
    protocolUid = _is.ColumnUuid(
      'protocolUid',
      this,
      hasDefault: true,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    description = _is.ColumnString(
      'description',
      this,
    );
    color = _is.ColumnString(
      'color',
      this,
    );
    availabilityZoneId = _is.ColumnString(
      'availabilityZoneId',
      this,
    );
    noRuleFallback = _is.ColumnEnum(
      'noRuleFallback',
      this,
      _is.EnumSerialization.byName,
    );
    protocolMetadata =
        _is.ColumnSerializable<_itchuj1l.CalendarProtocolMetadata>(
          'protocolMetadata',
          this,
        );
    supplementalMetadata =
        _is.ColumnSerializable<_ixppc388.CalendarSupplementalMetadata>(
          'supplementalMetadata',
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
  }

  late final CalendarDataRecordUpdateTable updateTable;

  late final _is.ColumnUuid calendarId;

  /// Native calendar protocol UID, separate from API and imported/feed identities.
  late final _is.ColumnUuid protocolUid;

  late final _is.ColumnString displayName;

  late final _is.ColumnString description;

  late final _is.ColumnString color;

  late final _is.ColumnString availabilityZoneId;

  late final _is.ColumnEnum<_itts4qyp.CalendarNoRuleFallback> noRuleFallback;

  late final _is.ColumnSerializable<_itchuj1l.CalendarProtocolMetadata>
  protocolMetadata;

  late final _is.ColumnSerializable<_ixppc388.CalendarSupplementalMetadata>
  supplementalMetadata;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    calendarId,
    protocolUid,
    displayName,
    description,
    color,
    availabilityZoneId,
    noRuleFallback,
    protocolMetadata,
    supplementalMetadata,
    createdAt,
    updatedAt,
  ];
}

class CalendarDataRecordInclude extends _is.IncludeObject {
  CalendarDataRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarDataRecord.t;
}

class CalendarDataRecordIncludeList extends _is.IncludeList {
  CalendarDataRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarDataRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarDataRecord.t;
}

class CalendarDataRecordRepository {
  const CalendarDataRecordRepository._();

  /// Returns a list of [CalendarDataRecord]s matching the given query parameters.
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
  Future<List<CalendarDataRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarDataRecord>(
      where: where?.call(CalendarDataRecord.t),
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarDataRecord] matching the given query parameters.
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
  Future<CalendarDataRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarDataRecord>(
      where: where?.call(CalendarDataRecord.t),
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarDataRecord] by its [id] or null if no such row exists.
  Future<CalendarDataRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarDataRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarDataRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarDataRecord]s will have their `id` fields set.
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
  Future<List<CalendarDataRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarDataRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarDataRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarDataRecord] and returns the inserted row.
  ///
  /// The returned [CalendarDataRecord] will have its `id` field set.
  Future<CalendarDataRecord> insertRow(
    _is.DatabaseSession session,
    CalendarDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarDataRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarDataRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarDataRecord> rows, {
    required _is.ColumnSelections<CalendarDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarDataRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarDataRecord.t),
      updateColumns: updateColumns?.call(CalendarDataRecord.t),
      updateWhere: updateWhere?.call(CalendarDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarDataRecord] and returns the resulting row.
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
  /// The returned [CalendarDataRecord] will have its `id` field set.
  Future<CalendarDataRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarDataRecord row, {
    required _is.ColumnSelections<CalendarDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarDataRecord>(
      row,
      conflictColumns: conflictColumns(CalendarDataRecord.t),
      updateColumns: updateColumns?.call(CalendarDataRecord.t),
      updateWhere: updateWhere?.call(CalendarDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarDataRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarDataRecord>> update(
    _is.DatabaseSession session,
    List<CalendarDataRecord> rows, {
    _is.ColumnSelections<CalendarDataRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarDataRecord>(
      rows,
      columns: columns?.call(CalendarDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarDataRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarDataRecord> updateRow(
    _is.DatabaseSession session,
    CalendarDataRecord row, {
    _is.ColumnSelections<CalendarDataRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarDataRecord>(
      row,
      columns: columns?.call(CalendarDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarDataRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarDataRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarDataRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarDataRecord>(
      id,
      columnValues: columnValues(CalendarDataRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarDataRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarDataRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarDataRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarDataRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarDataRecord>(
      columnValues: columnValues(CalendarDataRecord.t.updateTable),
      where: where(CalendarDataRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarDataRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarDataRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarDataRecord> rows, {
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarDataRecord>(
      rows,
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarDataRecord].
  Future<CalendarDataRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarDataRecord>(
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
  Future<List<CalendarDataRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarDataRecordTable> where,
    _is.OrderByBuilder<CalendarDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarDataRecord>(
      where: where(CalendarDataRecord.t),
      orderBy: orderBy?.call(CalendarDataRecord.t),
      orderByList: orderByList?.call(CalendarDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarDataRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarDataRecord>(
      where: where?.call(CalendarDataRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarDataRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarDataRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarDataRecord>(
      where: where(CalendarDataRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
