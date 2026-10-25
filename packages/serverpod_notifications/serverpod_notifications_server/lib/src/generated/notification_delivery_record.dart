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
import 'notification_delivery_state.dart' as _is3a40pv;

abstract class NotificationDeliveryRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  NotificationDeliveryRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientNamespace,
    required this.recipientKey,
    required this.sourceNamespace,
    required this.sourceVersion,
    required this.sourceRequestId,
    required this.requestDigest,
    required this.sourceReference,
    required this.dueAt,
    required this.expiresAt,
    _is3a40pv.NotificationDeliveryState? state,
    this.reason,
    required this.nextAttemptAt,
    int? attemptCount,
    this.leaseOwner,
    this.leaseUntil,
    int? leaseFence,
    this.publishedAt,
    this.terminalAt,
    required this.createdAt,
    required this.updatedAt,
  }) : state = state ?? _is3a40pv.NotificationDeliveryState.queued,
       attemptCount = attemptCount ?? 0,
       leaseFence = leaseFence ?? 0;

  factory NotificationDeliveryRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientNamespace,
    required String recipientKey,
    required String sourceNamespace,
    required int sourceVersion,
    required String sourceRequestId,
    required String requestDigest,
    required String sourceReference,
    required DateTime dueAt,
    required DateTime expiresAt,
    _is3a40pv.NotificationDeliveryState? state,
    String? reason,
    required DateTime nextAttemptAt,
    int? attemptCount,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    DateTime? publishedAt,
    DateTime? terminalAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NotificationDeliveryRecordImpl;

  factory NotificationDeliveryRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return NotificationDeliveryRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientNamespace: jsonSerialization['recipientNamespace'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      sourceNamespace: jsonSerialization['sourceNamespace'] as String,
      sourceVersion: jsonSerialization['sourceVersion'] as int,
      sourceRequestId: jsonSerialization['sourceRequestId'] as String,
      requestDigest: jsonSerialization['requestDigest'] as String,
      sourceReference: jsonSerialization['sourceReference'] as String,
      dueAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      state: jsonSerialization['state'] == null
          ? null
          : _is3a40pv.NotificationDeliveryState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      reason: jsonSerialization['reason'] as String?,
      nextAttemptAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextAttemptAt'],
      ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      leaseOwner: jsonSerialization['leaseOwner'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseOwner'],
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      leaseFence: jsonSerialization['leaseFence'] as int?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
    );
  }

  static final t = NotificationDeliveryRecordTable();

  static const db = NotificationDeliveryRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientNamespace;

  String recipientKey;

  String sourceNamespace;

  int sourceVersion;

  String sourceRequestId;

  String requestDigest;

  String sourceReference;

  DateTime dueAt;

  DateTime expiresAt;

  _is3a40pv.NotificationDeliveryState state;

  String? reason;

  DateTime nextAttemptAt;

  int attemptCount;

  _is.UuidValue? leaseOwner;

  DateTime? leaseUntil;

  int leaseFence;

  DateTime? publishedAt;

  DateTime? terminalAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [NotificationDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotificationDeliveryRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientNamespace,
    String? recipientKey,
    String? sourceNamespace,
    int? sourceVersion,
    String? sourceRequestId,
    String? requestDigest,
    String? sourceReference,
    DateTime? dueAt,
    DateTime? expiresAt,
    _is3a40pv.NotificationDeliveryState? state,
    String? reason,
    DateTime? nextAttemptAt,
    int? attemptCount,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    DateTime? publishedAt,
    DateTime? terminalAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_notifications.NotificationDeliveryRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientNamespace': recipientNamespace,
      'recipientKey': recipientKey,
      'sourceNamespace': sourceNamespace,
      'sourceVersion': sourceVersion,
      'sourceRequestId': sourceRequestId,
      'requestDigest': requestDigest,
      'sourceReference': sourceReference,
      'dueAt': dueAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'state': state.toJson(),
      if (reason != null) 'reason': reason,
      'nextAttemptAt': nextAttemptAt.toJson(),
      'attemptCount': attemptCount,
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'leaseFence': leaseFence,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static NotificationDeliveryRecordInclude include() {
    return NotificationDeliveryRecordInclude._();
  }

  static NotificationDeliveryRecordIncludeList includeList({
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    NotificationDeliveryRecordInclude? include,
  }) {
    return NotificationDeliveryRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _NotificationDeliveryRecordImpl extends NotificationDeliveryRecord {
  _NotificationDeliveryRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientNamespace,
    required String recipientKey,
    required String sourceNamespace,
    required int sourceVersion,
    required String sourceRequestId,
    required String requestDigest,
    required String sourceReference,
    required DateTime dueAt,
    required DateTime expiresAt,
    _is3a40pv.NotificationDeliveryState? state,
    String? reason,
    required DateTime nextAttemptAt,
    int? attemptCount,
    _is.UuidValue? leaseOwner,
    DateTime? leaseUntil,
    int? leaseFence,
    DateTime? publishedAt,
    DateTime? terminalAt,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientNamespace: recipientNamespace,
         recipientKey: recipientKey,
         sourceNamespace: sourceNamespace,
         sourceVersion: sourceVersion,
         sourceRequestId: sourceRequestId,
         requestDigest: requestDigest,
         sourceReference: sourceReference,
         dueAt: dueAt,
         expiresAt: expiresAt,
         state: state,
         reason: reason,
         nextAttemptAt: nextAttemptAt,
         attemptCount: attemptCount,
         leaseOwner: leaseOwner,
         leaseUntil: leaseUntil,
         leaseFence: leaseFence,
         publishedAt: publishedAt,
         terminalAt: terminalAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [NotificationDeliveryRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotificationDeliveryRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientNamespace,
    String? recipientKey,
    String? sourceNamespace,
    int? sourceVersion,
    String? sourceRequestId,
    String? requestDigest,
    String? sourceReference,
    DateTime? dueAt,
    DateTime? expiresAt,
    _is3a40pv.NotificationDeliveryState? state,
    Object? reason = _Undefined,
    DateTime? nextAttemptAt,
    int? attemptCount,
    Object? leaseOwner = _Undefined,
    Object? leaseUntil = _Undefined,
    int? leaseFence,
    Object? publishedAt = _Undefined,
    Object? terminalAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationDeliveryRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientNamespace: recipientNamespace ?? this.recipientNamespace,
      recipientKey: recipientKey ?? this.recipientKey,
      sourceNamespace: sourceNamespace ?? this.sourceNamespace,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      sourceRequestId: sourceRequestId ?? this.sourceRequestId,
      requestDigest: requestDigest ?? this.requestDigest,
      sourceReference: sourceReference ?? this.sourceReference,
      dueAt: dueAt ?? this.dueAt,
      expiresAt: expiresAt ?? this.expiresAt,
      state: state ?? this.state,
      reason: reason is String? ? reason : this.reason,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      attemptCount: attemptCount ?? this.attemptCount,
      leaseOwner: leaseOwner is _is.UuidValue? ? leaseOwner : this.leaseOwner,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      leaseFence: leaseFence ?? this.leaseFence,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      terminalAt: terminalAt is DateTime? ? terminalAt : this.terminalAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationDeliveryRecordUpdateTable
    extends _is.UpdateTable<NotificationDeliveryRecordTable> {
  NotificationDeliveryRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientNamespace(String value) =>
      _is.ColumnValue(
        table.recipientNamespace,
        value,
      );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<String, String> sourceNamespace(String value) =>
      _is.ColumnValue(
        table.sourceNamespace,
        value,
      );

  _is.ColumnValue<int, int> sourceVersion(int value) => _is.ColumnValue(
    table.sourceVersion,
    value,
  );

  _is.ColumnValue<String, String> sourceRequestId(String value) =>
      _is.ColumnValue(
        table.sourceRequestId,
        value,
      );

  _is.ColumnValue<String, String> requestDigest(String value) =>
      _is.ColumnValue(
        table.requestDigest,
        value,
      );

  _is.ColumnValue<String, String> sourceReference(String value) =>
      _is.ColumnValue(
        table.sourceReference,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> dueAt(DateTime value) => _is.ColumnValue(
    table.dueAt,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<
    _is3a40pv.NotificationDeliveryState,
    _is3a40pv.NotificationDeliveryState
  >
  state(_is3a40pv.NotificationDeliveryState value) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<String, String> reason(String? value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<int, int> attemptCount(int value) => _is.ColumnValue(
    table.attemptCount,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseOwner(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseOwner,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<int, int> leaseFence(int value) => _is.ColumnValue(
    table.leaseFence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _is.ColumnValue(
        table.publishedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
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

class NotificationDeliveryRecordTable extends _is.Table<_is.UuidValue?> {
  NotificationDeliveryRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_notifications_delivery') {
    updateTable = NotificationDeliveryRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientNamespace = _is.ColumnString(
      'recipientNamespace',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    sourceNamespace = _is.ColumnString(
      'sourceNamespace',
      this,
    );
    sourceVersion = _is.ColumnInt(
      'sourceVersion',
      this,
    );
    sourceRequestId = _is.ColumnString(
      'sourceRequestId',
      this,
    );
    requestDigest = _is.ColumnString(
      'requestDigest',
      this,
    );
    sourceReference = _is.ColumnString(
      'sourceReference',
      this,
    );
    dueAt = _is.ColumnDateTime(
      'dueAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    attemptCount = _is.ColumnInt(
      'attemptCount',
      this,
      hasDefault: true,
    );
    leaseOwner = _is.ColumnUuid(
      'leaseOwner',
      this,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    leaseFence = _is.ColumnInt(
      'leaseFence',
      this,
      hasDefault: true,
    );
    publishedAt = _is.ColumnDateTime(
      'publishedAt',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
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

  late final NotificationDeliveryRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientNamespace;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnString sourceNamespace;

  late final _is.ColumnInt sourceVersion;

  late final _is.ColumnString sourceRequestId;

  late final _is.ColumnString requestDigest;

  late final _is.ColumnString sourceReference;

  late final _is.ColumnDateTime dueAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnEnum<_is3a40pv.NotificationDeliveryState> state;

  late final _is.ColumnString reason;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime publishedAt;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientNamespace,
    recipientKey,
    sourceNamespace,
    sourceVersion,
    sourceRequestId,
    requestDigest,
    sourceReference,
    dueAt,
    expiresAt,
    state,
    reason,
    nextAttemptAt,
    attemptCount,
    leaseOwner,
    leaseUntil,
    leaseFence,
    publishedAt,
    terminalAt,
    createdAt,
    updatedAt,
  ];
}

class NotificationDeliveryRecordInclude extends _is.IncludeObject {
  NotificationDeliveryRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => NotificationDeliveryRecord.t;
}

class NotificationDeliveryRecordIncludeList extends _is.IncludeList {
  NotificationDeliveryRecordIncludeList._({
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(NotificationDeliveryRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => NotificationDeliveryRecord.t;
}

class NotificationDeliveryRecordRepository {
  const NotificationDeliveryRecordRepository._();

  /// Returns a list of [NotificationDeliveryRecord]s matching the given query parameters.
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
  Future<List<NotificationDeliveryRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<NotificationDeliveryRecord>(
      where: where?.call(NotificationDeliveryRecord.t),
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [NotificationDeliveryRecord] matching the given query parameters.
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
  Future<NotificationDeliveryRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<NotificationDeliveryRecord>(
      where: where?.call(NotificationDeliveryRecord.t),
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [NotificationDeliveryRecord] by its [id] or null if no such row exists.
  Future<NotificationDeliveryRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<NotificationDeliveryRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [NotificationDeliveryRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [NotificationDeliveryRecord]s will have their `id` fields set.
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
  Future<List<NotificationDeliveryRecord>> insert(
    _is.DatabaseSession session,
    List<NotificationDeliveryRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<NotificationDeliveryRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [NotificationDeliveryRecord] and returns the inserted row.
  ///
  /// The returned [NotificationDeliveryRecord] will have its `id` field set.
  Future<NotificationDeliveryRecord> insertRow(
    _is.DatabaseSession session,
    NotificationDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<NotificationDeliveryRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [NotificationDeliveryRecord]s in the list and returns the resulting rows.
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
  /// The returned [NotificationDeliveryRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationDeliveryRecord>> upsert(
    _is.DatabaseSession session,
    List<NotificationDeliveryRecord> rows, {
    required _is.ColumnSelections<NotificationDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<NotificationDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<NotificationDeliveryRecord>(
      rows,
      conflictColumns: conflictColumns(NotificationDeliveryRecord.t),
      updateColumns: updateColumns?.call(NotificationDeliveryRecord.t),
      updateWhere: updateWhere?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [NotificationDeliveryRecord] and returns the resulting row.
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
  /// The returned [NotificationDeliveryRecord] will have its `id` field set.
  Future<NotificationDeliveryRecord?> upsertRow(
    _is.DatabaseSession session,
    NotificationDeliveryRecord row, {
    required _is.ColumnSelections<NotificationDeliveryRecordTable>
    conflictColumns,
    _is.ColumnSelections<NotificationDeliveryRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<NotificationDeliveryRecord>(
      row,
      conflictColumns: conflictColumns(NotificationDeliveryRecord.t),
      updateColumns: updateColumns?.call(NotificationDeliveryRecord.t),
      updateWhere: updateWhere?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationDeliveryRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationDeliveryRecord>> update(
    _is.DatabaseSession session,
    List<NotificationDeliveryRecord> rows, {
    _is.ColumnSelections<NotificationDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<NotificationDeliveryRecord>(
      rows,
      columns: columns?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [NotificationDeliveryRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<NotificationDeliveryRecord> updateRow(
    _is.DatabaseSession session,
    NotificationDeliveryRecord row, {
    _is.ColumnSelections<NotificationDeliveryRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<NotificationDeliveryRecord>(
      row,
      columns: columns?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [NotificationDeliveryRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<NotificationDeliveryRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<NotificationDeliveryRecordUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<NotificationDeliveryRecord>(
      id,
      columnValues: columnValues(NotificationDeliveryRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [NotificationDeliveryRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<NotificationDeliveryRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<NotificationDeliveryRecordUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<NotificationDeliveryRecordTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<NotificationDeliveryRecord>(
      columnValues: columnValues(NotificationDeliveryRecord.t.updateTable),
      where: where(NotificationDeliveryRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [NotificationDeliveryRecord]s in the list and returns the deleted rows.
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
  Future<List<NotificationDeliveryRecord>> delete(
    _is.DatabaseSession session,
    List<NotificationDeliveryRecord> rows, {
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<NotificationDeliveryRecord>(
      rows,
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [NotificationDeliveryRecord].
  Future<NotificationDeliveryRecord> deleteRow(
    _is.DatabaseSession session,
    NotificationDeliveryRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<NotificationDeliveryRecord>(
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
  Future<List<NotificationDeliveryRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationDeliveryRecordTable> where,
    _is.OrderByBuilder<NotificationDeliveryRecordTable>? orderBy,
    _is.OrderByListBuilder<NotificationDeliveryRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<NotificationDeliveryRecord>(
      where: where(NotificationDeliveryRecord.t),
      orderBy: orderBy?.call(NotificationDeliveryRecord.t),
      orderByList: orderByList?.call(NotificationDeliveryRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<NotificationDeliveryRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<NotificationDeliveryRecord>(
      where: where?.call(NotificationDeliveryRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [NotificationDeliveryRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<NotificationDeliveryRecordTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<NotificationDeliveryRecord>(
      where: where(NotificationDeliveryRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
