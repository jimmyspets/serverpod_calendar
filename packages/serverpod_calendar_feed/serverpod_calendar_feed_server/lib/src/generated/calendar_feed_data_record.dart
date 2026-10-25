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
import 'package:serverpod_calendar_feed_server/src/generated/protocol.dart'
    as _i0kswevi;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as _ipn35bcd;

abstract class CalendarFeedDataRecord
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  CalendarFeedDataRecord._({
    this.id,
    required this.feedId,
    required this.displayName,
    _is.UuidValue? protocolUid,
    this.protocolMetadata,
    this.supplementalMetadata,
    required this.protocolModifiedAt,
    required this.authorityReference,
    required this.profileVersion,
    required this.createdAt,
    required this.updatedAt,
  }) : protocolUid = protocolUid ?? const _is.Uuid().v4obj();

  factory CalendarFeedDataRecord({
    int? id,
    required _is.UuidValue feedId,
    required String displayName,
    _is.UuidValue? protocolUid,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
    required DateTime protocolModifiedAt,
    required String authorityReference,
    required int profileVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CalendarFeedDataRecordImpl;

  factory CalendarFeedDataRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarFeedDataRecord(
      id: jsonSerialization['id'] as int?,
      feedId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['feedId']),
      displayName: jsonSerialization['displayName'] as String,
      protocolUid: jsonSerialization['protocolUid'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['protocolUid'],
            ),
      protocolMetadata: jsonSerialization['protocolMetadata'] == null
          ? null
          : _i0kswevi.Protocol()
                .deserialize<_ipn35bcd.CalendarProtocolMetadata>(
                  jsonSerialization['protocolMetadata'],
                ),
      supplementalMetadata: jsonSerialization['supplementalMetadata'] == null
          ? null
          : _i0kswevi.Protocol()
                .deserialize<_ipn35bcd.CalendarSupplementalMetadata>(
                  jsonSerialization['supplementalMetadata'],
                ),
      protocolModifiedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['protocolModifiedAt'],
      ),
      authorityReference: jsonSerialization['authorityReference'] as String,
      profileVersion: jsonSerialization['profileVersion'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = CalendarFeedDataRecordTable();

  static const db = CalendarFeedDataRecordRepository._();

  @override
  int? id;

  _is.UuidValue feedId;

  String displayName;

  _is.UuidValue protocolUid;

  _ipn35bcd.CalendarProtocolMetadata? protocolMetadata;

  _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata;

  DateTime protocolModifiedAt;

  String authorityReference;

  int profileVersion;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CalendarFeedDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarFeedDataRecord copyWith({
    int? id,
    _is.UuidValue? feedId,
    String? displayName,
    _is.UuidValue? protocolUid,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
    DateTime? protocolModifiedAt,
    String? authorityReference,
    int? profileVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar_feed.CalendarFeedDataRecord',
      if (id != null) 'id': id,
      'feedId': feedId.toJson(),
      'displayName': displayName,
      'protocolUid': protocolUid.toJson(),
      if (protocolMetadata != null)
        'protocolMetadata': protocolMetadata?.toJson(),
      if (supplementalMetadata != null)
        'supplementalMetadata': supplementalMetadata?.toJson(),
      'protocolModifiedAt': protocolModifiedAt.toJson(),
      'authorityReference': authorityReference,
      'profileVersion': profileVersion,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarFeedDataRecordInclude include() {
    return CalendarFeedDataRecordInclude._();
  }

  static CalendarFeedDataRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    CalendarFeedDataRecordInclude? include,
  }) {
    return CalendarFeedDataRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarFeedDataRecordImpl extends CalendarFeedDataRecord {
  _CalendarFeedDataRecordImpl({
    int? id,
    required _is.UuidValue feedId,
    required String displayName,
    _is.UuidValue? protocolUid,
    _ipn35bcd.CalendarProtocolMetadata? protocolMetadata,
    _ipn35bcd.CalendarSupplementalMetadata? supplementalMetadata,
    required DateTime protocolModifiedAt,
    required String authorityReference,
    required int profileVersion,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         feedId: feedId,
         displayName: displayName,
         protocolUid: protocolUid,
         protocolMetadata: protocolMetadata,
         supplementalMetadata: supplementalMetadata,
         protocolModifiedAt: protocolModifiedAt,
         authorityReference: authorityReference,
         profileVersion: profileVersion,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CalendarFeedDataRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarFeedDataRecord copyWith({
    Object? id = _Undefined,
    _is.UuidValue? feedId,
    String? displayName,
    _is.UuidValue? protocolUid,
    Object? protocolMetadata = _Undefined,
    Object? supplementalMetadata = _Undefined,
    DateTime? protocolModifiedAt,
    String? authorityReference,
    int? profileVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarFeedDataRecord(
      id: id is int? ? id : this.id,
      feedId: feedId ?? this.feedId,
      displayName: displayName ?? this.displayName,
      protocolUid: protocolUid ?? this.protocolUid,
      protocolMetadata: protocolMetadata is _ipn35bcd.CalendarProtocolMetadata?
          ? protocolMetadata
          : this.protocolMetadata?.copyWith(),
      supplementalMetadata:
          supplementalMetadata is _ipn35bcd.CalendarSupplementalMetadata?
          ? supplementalMetadata
          : this.supplementalMetadata?.copyWith(),
      protocolModifiedAt: protocolModifiedAt ?? this.protocolModifiedAt,
      authorityReference: authorityReference ?? this.authorityReference,
      profileVersion: profileVersion ?? this.profileVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CalendarFeedDataRecordUpdateTable
    extends _is.UpdateTable<CalendarFeedDataRecordTable> {
  CalendarFeedDataRecordUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> feedId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.feedId,
        value,
      );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> protocolUid(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.protocolUid,
    value,
  );

  _is.ColumnValue<
    _ipn35bcd.CalendarProtocolMetadata,
    _ipn35bcd.CalendarProtocolMetadata
  >
  protocolMetadata(_ipn35bcd.CalendarProtocolMetadata? value) =>
      _is.ColumnValue(
        table.protocolMetadata,
        value,
      );

  _is.ColumnValue<
    _ipn35bcd.CalendarSupplementalMetadata,
    _ipn35bcd.CalendarSupplementalMetadata
  >
  supplementalMetadata(_ipn35bcd.CalendarSupplementalMetadata? value) =>
      _is.ColumnValue(
        table.supplementalMetadata,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> protocolModifiedAt(DateTime value) =>
      _is.ColumnValue(
        table.protocolModifiedAt,
        value,
      );

  _is.ColumnValue<String, String> authorityReference(String value) =>
      _is.ColumnValue(
        table.authorityReference,
        value,
      );

  _is.ColumnValue<int, int> profileVersion(int value) => _is.ColumnValue(
    table.profileVersion,
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

class CalendarFeedDataRecordTable extends _is.Table<int?> {
  CalendarFeedDataRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_feed_data') {
    updateTable = CalendarFeedDataRecordUpdateTable(this);
    feedId = _is.ColumnUuid(
      'feedId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    protocolUid = _is.ColumnUuid(
      'protocolUid',
      this,
      hasDefault: true,
    );
    protocolMetadata =
        _is.ColumnSerializable<_ipn35bcd.CalendarProtocolMetadata>(
          'protocolMetadata',
          this,
        );
    supplementalMetadata =
        _is.ColumnSerializable<_ipn35bcd.CalendarSupplementalMetadata>(
          'supplementalMetadata',
          this,
        );
    protocolModifiedAt = _is.ColumnDateTime(
      'protocolModifiedAt',
      this,
    );
    authorityReference = _is.ColumnString(
      'authorityReference',
      this,
    );
    profileVersion = _is.ColumnInt(
      'profileVersion',
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

  late final CalendarFeedDataRecordUpdateTable updateTable;

  late final _is.ColumnUuid feedId;

  late final _is.ColumnString displayName;

  late final _is.ColumnUuid protocolUid;

  late final _is.ColumnSerializable<_ipn35bcd.CalendarProtocolMetadata>
  protocolMetadata;

  late final _is.ColumnSerializable<_ipn35bcd.CalendarSupplementalMetadata>
  supplementalMetadata;

  late final _is.ColumnDateTime protocolModifiedAt;

  late final _is.ColumnString authorityReference;

  late final _is.ColumnInt profileVersion;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    feedId,
    displayName,
    protocolUid,
    protocolMetadata,
    supplementalMetadata,
    protocolModifiedAt,
    authorityReference,
    profileVersion,
    createdAt,
    updatedAt,
  ];
}

class CalendarFeedDataRecordInclude extends _is.IncludeObject {
  CalendarFeedDataRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CalendarFeedDataRecord.t;
}

class CalendarFeedDataRecordIncludeList extends _is.IncludeList {
  CalendarFeedDataRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarFeedDataRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CalendarFeedDataRecord.t;
}

class CalendarFeedDataRecordRepository {
  const CalendarFeedDataRecordRepository._();

  /// Returns a list of [CalendarFeedDataRecord]s matching the given query parameters.
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
  Future<List<CalendarFeedDataRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarFeedDataRecord>(
      where: where?.call(CalendarFeedDataRecord.t),
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarFeedDataRecord] matching the given query parameters.
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
  Future<CalendarFeedDataRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarFeedDataRecord>(
      where: where?.call(CalendarFeedDataRecord.t),
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarFeedDataRecord] by its [id] or null if no such row exists.
  Future<CalendarFeedDataRecord?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarFeedDataRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarFeedDataRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarFeedDataRecord]s will have their `id` fields set.
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
  Future<List<CalendarFeedDataRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarFeedDataRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarFeedDataRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarFeedDataRecord] and returns the inserted row.
  ///
  /// The returned [CalendarFeedDataRecord] will have its `id` field set.
  Future<CalendarFeedDataRecord> insertRow(
    _is.DatabaseSession session,
    CalendarFeedDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarFeedDataRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarFeedDataRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarFeedDataRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedDataRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarFeedDataRecord> rows, {
    required _is.ColumnSelections<CalendarFeedDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarFeedDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarFeedDataRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarFeedDataRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedDataRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarFeedDataRecord] and returns the resulting row.
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
  /// The returned [CalendarFeedDataRecord] will have its `id` field set.
  Future<CalendarFeedDataRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarFeedDataRecord row, {
    required _is.ColumnSelections<CalendarFeedDataRecordTable> conflictColumns,
    _is.ColumnSelections<CalendarFeedDataRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarFeedDataRecord>(
      row,
      conflictColumns: conflictColumns(CalendarFeedDataRecord.t),
      updateColumns: updateColumns?.call(CalendarFeedDataRecord.t),
      updateWhere: updateWhere?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedDataRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedDataRecord>> update(
    _is.DatabaseSession session,
    List<CalendarFeedDataRecord> rows, {
    _is.ColumnSelections<CalendarFeedDataRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarFeedDataRecord>(
      rows,
      columns: columns?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarFeedDataRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarFeedDataRecord> updateRow(
    _is.DatabaseSession session,
    CalendarFeedDataRecord row, {
    _is.ColumnSelections<CalendarFeedDataRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarFeedDataRecord>(
      row,
      columns: columns?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarFeedDataRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarFeedDataRecord?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CalendarFeedDataRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarFeedDataRecord>(
      id,
      columnValues: columnValues(CalendarFeedDataRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarFeedDataRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarFeedDataRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CalendarFeedDataRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<CalendarFeedDataRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarFeedDataRecord>(
      columnValues: columnValues(CalendarFeedDataRecord.t.updateTable),
      where: where(CalendarFeedDataRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarFeedDataRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarFeedDataRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarFeedDataRecord> rows, {
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarFeedDataRecord>(
      rows,
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarFeedDataRecord].
  Future<CalendarFeedDataRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarFeedDataRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarFeedDataRecord>(
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
  Future<List<CalendarFeedDataRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedDataRecordTable> where,
    _is.OrderByBuilder<CalendarFeedDataRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarFeedDataRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarFeedDataRecord>(
      where: where(CalendarFeedDataRecord.t),
      orderBy: orderBy?.call(CalendarFeedDataRecord.t),
      orderByList: orderByList?.call(CalendarFeedDataRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarFeedDataRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarFeedDataRecord>(
      where: where?.call(CalendarFeedDataRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarFeedDataRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarFeedDataRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarFeedDataRecord>(
      where: where(CalendarFeedDataRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
