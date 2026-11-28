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
import 'dart:async' as _ida;

import 'package:serverpod/serverpod.dart' as _is;

import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;

abstract class CalendarAttendeeRefreshRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarAttendeeRefreshRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.entryId,
    required this.commandId,
    required this.actorId,
    required this.sourceId,
    required this.sourceRevision,
    required this.sourceDigest,
    this.sourceSequence,
    required this.sourceStamp,
    required this.attendeeAddress,
    required this.organizerAddress,
    required this.authorityRef,
    required this.routeRef,
    required this.payload,
    required this.payloadDigest,
    required this.stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required this.createdAt,
    required this.expiresAt,
    required this.nextAttemptAt,
    this.leaseToken,
    this.leaseUntil,
    this.terminalAt,
    this.resultCode,
  }) : state =
           state ?? _iw51ozry.CalendarInvitationResponseDeliveryState.queued,
       attemptCount = attemptCount ?? 0;

  factory CalendarAttendeeRefreshRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required _is.UuidValue commandId,
    required String actorId,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required String attendeeAddress,
    required String organizerAddress,
    required String authorityRef,
    required String routeRef,
    required String payload,
    required String payloadDigest,
    required DateTime stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseToken,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) = _CalendarAttendeeRefreshRecordImpl;

  factory CalendarAttendeeRefreshRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarAttendeeRefreshRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      actorId: jsonSerialization['actorId'] as String,
      sourceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['sourceId'],
      ),
      sourceRevision: jsonSerialization['sourceRevision'] as int,
      sourceDigest: jsonSerialization['sourceDigest'] as String,
      sourceSequence: jsonSerialization['sourceSequence'] as int?,
      sourceStamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['sourceStamp'],
      ),
      attendeeAddress: jsonSerialization['attendeeAddress'] as String,
      organizerAddress: jsonSerialization['organizerAddress'] as String,
      authorityRef: jsonSerialization['authorityRef'] as String,
      routeRef: jsonSerialization['routeRef'] as String,
      payload: jsonSerialization['payload'] as String,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      state: jsonSerialization['state'] == null
          ? null
          : _iw51ozry.CalendarInvitationResponseDeliveryState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      attemptCount: jsonSerialization['attemptCount'] as int?,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      nextAttemptAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['nextAttemptAt'],
      ),
      leaseToken: jsonSerialization['leaseToken'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseToken'],
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  static final t = CalendarAttendeeRefreshRecordTable();

  static const db = CalendarAttendeeRefreshRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  _is.UuidValue entryId;

  _is.UuidValue commandId;

  String actorId;

  _is.UuidValue sourceId;

  int sourceRevision;

  String sourceDigest;

  int? sourceSequence;

  DateTime sourceStamp;

  String attendeeAddress;

  String organizerAddress;

  String authorityRef;

  String routeRef;

  String payload;

  String payloadDigest;

  DateTime stamp;

  _iw51ozry.CalendarInvitationResponseDeliveryState state;

  int attemptCount;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime nextAttemptAt;

  _is.UuidValue? leaseToken;

  DateTime? leaseUntil;

  DateTime? terminalAt;

  String? resultCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarAttendeeRefreshRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarAttendeeRefreshRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    _is.UuidValue? commandId,
    String? actorId,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    int? sourceSequence,
    DateTime? sourceStamp,
    String? attendeeAddress,
    String? organizerAddress,
    String? authorityRef,
    String? routeRef,
    String? payload,
    String? payloadDigest,
    DateTime? stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarAttendeeRefreshRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'entryId': entryId.toJson(),
      'commandId': commandId.toJson(),
      'actorId': actorId,
      'sourceId': sourceId.toJson(),
      'sourceRevision': sourceRevision,
      'sourceDigest': sourceDigest,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'attendeeAddress': attendeeAddress,
      'organizerAddress': organizerAddress,
      'authorityRef': authorityRef,
      'routeRef': routeRef,
      'payload': payload,
      'payloadDigest': payloadDigest,
      'stamp': stamp.toJson(),
      'state': state.toJson(),
      'attemptCount': attemptCount,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'nextAttemptAt': nextAttemptAt.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken?.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarAttendeeRefreshRecordInclude include() {
    return CalendarAttendeeRefreshRecordInclude._();
  }

  static CalendarAttendeeRefreshRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    CalendarAttendeeRefreshRecordInclude? include,
  }) {
    return CalendarAttendeeRefreshRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarAttendeeRefreshRecordImpl extends CalendarAttendeeRefreshRecord {
  _CalendarAttendeeRefreshRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue entryId,
    required _is.UuidValue commandId,
    required String actorId,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required String attendeeAddress,
    required String organizerAddress,
    required String authorityRef,
    required String routeRef,
    required String payload,
    required String payloadDigest,
    required DateTime stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseToken,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         entryId: entryId,
         commandId: commandId,
         actorId: actorId,
         sourceId: sourceId,
         sourceRevision: sourceRevision,
         sourceDigest: sourceDigest,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         attendeeAddress: attendeeAddress,
         organizerAddress: organizerAddress,
         authorityRef: authorityRef,
         routeRef: routeRef,
         payload: payload,
         payloadDigest: payloadDigest,
         stamp: stamp,
         state: state,
         attemptCount: attemptCount,
         createdAt: createdAt,
         expiresAt: expiresAt,
         nextAttemptAt: nextAttemptAt,
         leaseToken: leaseToken,
         leaseUntil: leaseUntil,
         terminalAt: terminalAt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarAttendeeRefreshRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarAttendeeRefreshRecord copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? entryId,
    _is.UuidValue? commandId,
    String? actorId,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    Object? sourceSequence = _Undefined,
    DateTime? sourceStamp,
    String? attendeeAddress,
    String? organizerAddress,
    String? authorityRef,
    String? routeRef,
    String? payload,
    String? payloadDigest,
    DateTime? stamp,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseToken = const _is.$UndefinedUuidValue(),
    DateTime? leaseUntil = const _is.$UndefinedDateTime(),
    DateTime? terminalAt = const _is.$UndefinedDateTime(),
    Object? resultCode = _Undefined,
  }) {
    return CalendarAttendeeRefreshRecord(
      id: id is _is.UndefinedSentinel ? this.id : id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      entryId: entryId ?? this.entryId,
      commandId: commandId ?? this.commandId,
      actorId: actorId ?? this.actorId,
      sourceId: sourceId ?? this.sourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      sourceDigest: sourceDigest ?? this.sourceDigest,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      attendeeAddress: attendeeAddress ?? this.attendeeAddress,
      organizerAddress: organizerAddress ?? this.organizerAddress,
      authorityRef: authorityRef ?? this.authorityRef,
      routeRef: routeRef ?? this.routeRef,
      payload: payload ?? this.payload,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      stamp: stamp ?? this.stamp,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseToken: leaseToken is _is.UndefinedSentinel
          ? this.leaseToken
          : leaseToken,
      leaseUntil: leaseUntil is _is.UndefinedSentinel
          ? this.leaseUntil
          : leaseUntil,
      terminalAt: terminalAt is _is.UndefinedSentinel
          ? this.terminalAt
          : terminalAt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}

class CalendarAttendeeRefreshRecordUpdateTable
    extends _is.UpdateTable<CalendarAttendeeRefreshRecordTable> {
  CalendarAttendeeRefreshRecordUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> commandId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.commandId,
    value,
  );

  _is.ColumnValue<String, String> actorId(String value) => _is.ColumnValue(
    table.actorId,
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

  _is.ColumnValue<String, String> attendeeAddress(String value) =>
      _is.ColumnValue(
        table.attendeeAddress,
        value,
      );

  _is.ColumnValue<String, String> organizerAddress(String value) =>
      _is.ColumnValue(
        table.organizerAddress,
        value,
      );

  _is.ColumnValue<String, String> authorityRef(String value) => _is.ColumnValue(
    table.authorityRef,
    value,
  );

  _is.ColumnValue<String, String> routeRef(String value) => _is.ColumnValue(
    table.routeRef,
    value,
  );

  _is.ColumnValue<String, String> payload(String value) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<String, String> payloadDigest(String value) =>
      _is.ColumnValue(
        table.payloadDigest,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
    value,
  );

  _is.ColumnValue<
    _iw51ozry.CalendarInvitationResponseDeliveryState,
    _iw51ozry.CalendarInvitationResponseDeliveryState
  >
  state(_iw51ozry.CalendarInvitationResponseDeliveryState value) =>
      _is.ColumnValue(
        table.state,
        value,
      );

  _is.ColumnValue<int, int> attemptCount(int value) => _is.ColumnValue(
    table.attemptCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> nextAttemptAt(DateTime value) =>
      _is.ColumnValue(
        table.nextAttemptAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseToken(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> terminalAt(DateTime? value) =>
      _is.ColumnValue(
        table.terminalAt,
        value,
      );

  _is.ColumnValue<String, String> resultCode(String? value) => _is.ColumnValue(
    table.resultCode,
    value,
  );
}

class CalendarAttendeeRefreshRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarAttendeeRefreshRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_attendee_refresh') {
    updateTable = CalendarAttendeeRefreshRecordUpdateTable(this);
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
    commandId = _is.ColumnUuid(
      'commandId',
      this,
    );
    actorId = _is.ColumnString(
      'actorId',
      this,
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
    attendeeAddress = _is.ColumnString(
      'attendeeAddress',
      this,
    );
    organizerAddress = _is.ColumnString(
      'organizerAddress',
      this,
    );
    authorityRef = _is.ColumnString(
      'authorityRef',
      this,
    );
    routeRef = _is.ColumnString(
      'routeRef',
      this,
    );
    payload = _is.ColumnString(
      'payload',
      this,
    );
    payloadDigest = _is.ColumnString(
      'payloadDigest',
      this,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
      this,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    attemptCount = _is.ColumnInt(
      'attemptCount',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    nextAttemptAt = _is.ColumnDateTime(
      'nextAttemptAt',
      this,
    );
    leaseToken = _is.ColumnUuid(
      'leaseToken',
      this,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    terminalAt = _is.ColumnDateTime(
      'terminalAt',
      this,
    );
    resultCode = _is.ColumnString(
      'resultCode',
      this,
    );
  }

  late final CalendarAttendeeRefreshRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString actorId;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnInt sourceRevision;

  late final _is.ColumnString sourceDigest;

  late final _is.ColumnInt sourceSequence;

  late final _is.ColumnDateTime sourceStamp;

  late final _is.ColumnString attendeeAddress;

  late final _is.ColumnString organizerAddress;

  late final _is.ColumnString authorityRef;

  late final _is.ColumnString routeRef;

  late final _is.ColumnString payload;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnEnum<_iw51ozry.CalendarInvitationResponseDeliveryState>
  state;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnString resultCode;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    entryId,
    commandId,
    actorId,
    sourceId,
    sourceRevision,
    sourceDigest,
    sourceSequence,
    sourceStamp,
    attendeeAddress,
    organizerAddress,
    authorityRef,
    routeRef,
    payload,
    payloadDigest,
    stamp,
    state,
    attemptCount,
    createdAt,
    expiresAt,
    nextAttemptAt,
    leaseToken,
    leaseUntil,
    terminalAt,
    resultCode,
  ];
}

class CalendarAttendeeRefreshRecordInclude extends _is.IncludeObject {
  CalendarAttendeeRefreshRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAttendeeRefreshRecord.t;
}

class CalendarAttendeeRefreshRecordIncludeList extends _is.IncludeList {
  CalendarAttendeeRefreshRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarAttendeeRefreshRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarAttendeeRefreshRecord.t;
}

class CalendarAttendeeRefreshRecordRepository {
  const CalendarAttendeeRefreshRecordRepository._();

  /// Returns a list of [CalendarAttendeeRefreshRecord]s matching the given query parameters.
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
  Future<List<CalendarAttendeeRefreshRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarAttendeeRefreshRecord>(
      where: where?.call(CalendarAttendeeRefreshRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CalendarAttendeeRefreshRecord]s matching the given query parameters every time the
  /// source tables are modified.
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
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `CalendarAttendeeRefreshRecord.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<CalendarAttendeeRefreshRecord>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CalendarAttendeeRefreshRecord>(
      where: where?.call(CalendarAttendeeRefreshRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CalendarAttendeeRefreshRecord] matching the given query parameters.
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
  Future<CalendarAttendeeRefreshRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarAttendeeRefreshRecord>(
      where: where?.call(CalendarAttendeeRefreshRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarAttendeeRefreshRecord] by its [id] or null if no such row exists.
  Future<CalendarAttendeeRefreshRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarAttendeeRefreshRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarAttendeeRefreshRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarAttendeeRefreshRecord]s will have their `id` fields set.
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
  Future<List<CalendarAttendeeRefreshRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarAttendeeRefreshRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarAttendeeRefreshRecord] and returns the inserted row.
  ///
  /// The returned [CalendarAttendeeRefreshRecord] will have its `id` field set.
  Future<CalendarAttendeeRefreshRecord> insertRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarAttendeeRefreshRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarAttendeeRefreshRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarAttendeeRefreshRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshRecord> rows, {
    required _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarAttendeeRefreshRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarAttendeeRefreshRecord.t),
      updateColumns: updateColumns?.call(CalendarAttendeeRefreshRecord.t),
      updateWhere: updateWhere?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarAttendeeRefreshRecord] and returns the resulting row.
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
  /// The returned [CalendarAttendeeRefreshRecord] will have its `id` field set.
  Future<CalendarAttendeeRefreshRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshRecord row, {
    required _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarAttendeeRefreshRecord>(
      row,
      conflictColumns: conflictColumns(CalendarAttendeeRefreshRecord.t),
      updateColumns: updateColumns?.call(CalendarAttendeeRefreshRecord.t),
      updateWhere: updateWhere?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAttendeeRefreshRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshRecord>> update(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshRecord> rows, {
    _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarAttendeeRefreshRecord>(
      rows,
      columns: columns?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarAttendeeRefreshRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarAttendeeRefreshRecord> updateRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshRecord row, {
    _is.ColumnSelections<CalendarAttendeeRefreshRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarAttendeeRefreshRecord>(
      row,
      columns: columns?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarAttendeeRefreshRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarAttendeeRefreshRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarAttendeeRefreshRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarAttendeeRefreshRecord>(
      id,
      columnValues: columnValues(CalendarAttendeeRefreshRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarAttendeeRefreshRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarAttendeeRefreshRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarAttendeeRefreshRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarAttendeeRefreshRecord>(
      columnValues: columnValues(CalendarAttendeeRefreshRecord.t.updateTable),
      where: where(CalendarAttendeeRefreshRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarAttendeeRefreshRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarAttendeeRefreshRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarAttendeeRefreshRecord> rows, {
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarAttendeeRefreshRecord>(
      rows,
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarAttendeeRefreshRecord].
  Future<CalendarAttendeeRefreshRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarAttendeeRefreshRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarAttendeeRefreshRecord>(
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
  Future<List<CalendarAttendeeRefreshRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>
    where,
    _is.OrderByBuilder<CalendarAttendeeRefreshRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarAttendeeRefreshRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarAttendeeRefreshRecord>(
      where: where(CalendarAttendeeRefreshRecord.t),
      orderBy: orderBy?.call(CalendarAttendeeRefreshRecord.t),
      orderByList: orderByList?.call(CalendarAttendeeRefreshRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarAttendeeRefreshRecord>(
      where: where?.call(CalendarAttendeeRefreshRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarAttendeeRefreshRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarAttendeeRefreshRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarAttendeeRefreshRecord>(
      where: where(CalendarAttendeeRefreshRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
