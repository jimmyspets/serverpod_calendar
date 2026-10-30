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
import 'calendar_invitation_response_choice.dart' as _il64jj9v;
import 'calendar_invitation_response_delivery_state.dart' as _iw51ozry;
import 'calendar_invitation_response_receipt.dart' as _ig6twu0d;
import 'calendar_invitation_response_request.dart' as _iw3qnr12;

abstract class CalendarInvitationResponseRecord
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CalendarInvitationResponseRecord._({
    this.id,
    required this.scopeKey,
    required this.recipientKey,
    required this.stateId,
    required this.entryId,
    required this.commandId,
    required this.criteriaDigest,
    required this.request,
    required this.receipt,
    required this.sourceId,
    required this.sourceRevision,
    required this.sourceDigest,
    this.sourceSequence,
    required this.sourceStamp,
    required this.recipientAddress,
    required this.organizerAddress,
    required this.authorityRef,
    required this.routeRef,
    required this.generation,
    required this.choice,
    required this.stamp,
    required this.payload,
    required this.payloadDigest,
    required this.byteCount,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required this.createdAt,
    required this.expiresAt,
    required this.nextAttemptAt,
    this.leaseOwner,
    this.leaseToken,
    int? leaseFence,
    this.leaseUntil,
    this.terminalAt,
    this.resultCode,
  }) : state =
           state ?? _iw51ozry.CalendarInvitationResponseDeliveryState.queued,
       attemptCount = attemptCount ?? 0,
       leaseFence = leaseFence ?? 0;

  factory CalendarInvitationResponseRecord({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue stateId,
    required _is.UuidValue entryId,
    required _is.UuidValue commandId,
    required String criteriaDigest,
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _ig6twu0d.CalendarInvitationResponseReceipt receipt,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required String recipientAddress,
    required String organizerAddress,
    required String authorityRef,
    required String routeRef,
    required int generation,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required DateTime stamp,
    required String payload,
    required String payloadDigest,
    required int byteCount,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) = _CalendarInvitationResponseRecordImpl;

  factory CalendarInvitationResponseRecord.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CalendarInvitationResponseRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      recipientKey: jsonSerialization['recipientKey'] as String,
      stateId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['stateId'],
      ),
      entryId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entryId'],
      ),
      commandId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['commandId'],
      ),
      criteriaDigest: jsonSerialization['criteriaDigest'] as String,
      request: _ix00hwbf.Protocol()
          .deserialize<_iw3qnr12.CalendarInvitationResponseRequest>(
            jsonSerialization['request'],
          ),
      receipt: _ix00hwbf.Protocol()
          .deserialize<_ig6twu0d.CalendarInvitationResponseReceipt>(
            jsonSerialization['receipt'],
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
      recipientAddress: jsonSerialization['recipientAddress'] as String,
      organizerAddress: jsonSerialization['organizerAddress'] as String,
      authorityRef: jsonSerialization['authorityRef'] as String,
      routeRef: jsonSerialization['routeRef'] as String,
      generation: jsonSerialization['generation'] as int,
      choice: _il64jj9v.CalendarInvitationResponseChoice.fromJson(
        (jsonSerialization['choice'] as String),
      ),
      stamp: _is.DateTimeJsonExtension.fromJson(jsonSerialization['stamp']),
      payload: jsonSerialization['payload'] as String,
      payloadDigest: jsonSerialization['payloadDigest'] as String,
      byteCount: jsonSerialization['byteCount'] as int,
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
      leaseOwner: jsonSerialization['leaseOwner'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseOwner'],
            ),
      leaseToken: jsonSerialization['leaseToken'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['leaseToken'],
            ),
      leaseFence: jsonSerialization['leaseFence'] as int?,
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      terminalAt: jsonSerialization['terminalAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['terminalAt']),
      resultCode: jsonSerialization['resultCode'] as String?,
    );
  }

  static final t = CalendarInvitationResponseRecordTable();

  static const db = CalendarInvitationResponseRecordRepository._();

  @override
  _is.UuidValue? id;

  String scopeKey;

  String recipientKey;

  _is.UuidValue stateId;

  _is.UuidValue entryId;

  _is.UuidValue commandId;

  String criteriaDigest;

  _iw3qnr12.CalendarInvitationResponseRequest request;

  _ig6twu0d.CalendarInvitationResponseReceipt receipt;

  _is.UuidValue sourceId;

  int sourceRevision;

  String sourceDigest;

  int? sourceSequence;

  DateTime sourceStamp;

  String recipientAddress;

  String organizerAddress;

  String authorityRef;

  String routeRef;

  int generation;

  _il64jj9v.CalendarInvitationResponseChoice choice;

  DateTime stamp;

  String payload;

  String payloadDigest;

  int byteCount;

  _iw51ozry.CalendarInvitationResponseDeliveryState state;

  int attemptCount;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime nextAttemptAt;

  _is.UuidValue? leaseOwner;

  _is.UuidValue? leaseToken;

  int leaseFence;

  DateTime? leaseUntil;

  DateTime? terminalAt;

  String? resultCode;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CalendarInvitationResponseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CalendarInvitationResponseRecord copyWith({
    _is.UuidValue? id,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? stateId,
    _is.UuidValue? entryId,
    _is.UuidValue? commandId,
    String? criteriaDigest,
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _ig6twu0d.CalendarInvitationResponseReceipt? receipt,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    int? sourceSequence,
    DateTime? sourceStamp,
    String? recipientAddress,
    String? organizerAddress,
    String? authorityRef,
    String? routeRef,
    int? generation,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    String? payload,
    String? payloadDigest,
    int? byteCount,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_calendar.CalendarInvitationResponseRecord',
      if (id != null) 'id': id?.toJson(),
      'scopeKey': scopeKey,
      'recipientKey': recipientKey,
      'stateId': stateId.toJson(),
      'entryId': entryId.toJson(),
      'commandId': commandId.toJson(),
      'criteriaDigest': criteriaDigest,
      'request': request.toJson(),
      'receipt': receipt.toJson(),
      'sourceId': sourceId.toJson(),
      'sourceRevision': sourceRevision,
      'sourceDigest': sourceDigest,
      if (sourceSequence != null) 'sourceSequence': sourceSequence,
      'sourceStamp': sourceStamp.toJson(),
      'recipientAddress': recipientAddress,
      'organizerAddress': organizerAddress,
      'authorityRef': authorityRef,
      'routeRef': routeRef,
      'generation': generation,
      'choice': choice.toJson(),
      'stamp': stamp.toJson(),
      'payload': payload,
      'payloadDigest': payloadDigest,
      'byteCount': byteCount,
      'state': state.toJson(),
      'attemptCount': attemptCount,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'nextAttemptAt': nextAttemptAt.toJson(),
      if (leaseOwner != null) 'leaseOwner': leaseOwner?.toJson(),
      if (leaseToken != null) 'leaseToken': leaseToken?.toJson(),
      'leaseFence': leaseFence,
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      if (terminalAt != null) 'terminalAt': terminalAt?.toJson(),
      if (resultCode != null) 'resultCode': resultCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static CalendarInvitationResponseRecordInclude include() {
    return CalendarInvitationResponseRecordInclude._();
  }

  static CalendarInvitationResponseRecordIncludeList includeList({
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    CalendarInvitationResponseRecordInclude? include,
  }) {
    return CalendarInvitationResponseRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CalendarInvitationResponseRecordImpl
    extends CalendarInvitationResponseRecord {
  _CalendarInvitationResponseRecordImpl({
    _is.UuidValue? id,
    required String scopeKey,
    required String recipientKey,
    required _is.UuidValue stateId,
    required _is.UuidValue entryId,
    required _is.UuidValue commandId,
    required String criteriaDigest,
    required _iw3qnr12.CalendarInvitationResponseRequest request,
    required _ig6twu0d.CalendarInvitationResponseReceipt receipt,
    required _is.UuidValue sourceId,
    required int sourceRevision,
    required String sourceDigest,
    int? sourceSequence,
    required DateTime sourceStamp,
    required String recipientAddress,
    required String organizerAddress,
    required String authorityRef,
    required String routeRef,
    required int generation,
    required _il64jj9v.CalendarInvitationResponseChoice choice,
    required DateTime stamp,
    required String payload,
    required String payloadDigest,
    required int byteCount,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    required DateTime createdAt,
    required DateTime expiresAt,
    required DateTime nextAttemptAt,
    _is.UuidValue? leaseOwner,
    _is.UuidValue? leaseToken,
    int? leaseFence,
    DateTime? leaseUntil,
    DateTime? terminalAt,
    String? resultCode,
  }) : super._(
         id: id,
         scopeKey: scopeKey,
         recipientKey: recipientKey,
         stateId: stateId,
         entryId: entryId,
         commandId: commandId,
         criteriaDigest: criteriaDigest,
         request: request,
         receipt: receipt,
         sourceId: sourceId,
         sourceRevision: sourceRevision,
         sourceDigest: sourceDigest,
         sourceSequence: sourceSequence,
         sourceStamp: sourceStamp,
         recipientAddress: recipientAddress,
         organizerAddress: organizerAddress,
         authorityRef: authorityRef,
         routeRef: routeRef,
         generation: generation,
         choice: choice,
         stamp: stamp,
         payload: payload,
         payloadDigest: payloadDigest,
         byteCount: byteCount,
         state: state,
         attemptCount: attemptCount,
         createdAt: createdAt,
         expiresAt: expiresAt,
         nextAttemptAt: nextAttemptAt,
         leaseOwner: leaseOwner,
         leaseToken: leaseToken,
         leaseFence: leaseFence,
         leaseUntil: leaseUntil,
         terminalAt: terminalAt,
         resultCode: resultCode,
       );

  /// Returns a shallow copy of this [CalendarInvitationResponseRecord]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CalendarInvitationResponseRecord copyWith({
    Object? id = _Undefined,
    String? scopeKey,
    String? recipientKey,
    _is.UuidValue? stateId,
    _is.UuidValue? entryId,
    _is.UuidValue? commandId,
    String? criteriaDigest,
    _iw3qnr12.CalendarInvitationResponseRequest? request,
    _ig6twu0d.CalendarInvitationResponseReceipt? receipt,
    _is.UuidValue? sourceId,
    int? sourceRevision,
    String? sourceDigest,
    Object? sourceSequence = _Undefined,
    DateTime? sourceStamp,
    String? recipientAddress,
    String? organizerAddress,
    String? authorityRef,
    String? routeRef,
    int? generation,
    _il64jj9v.CalendarInvitationResponseChoice? choice,
    DateTime? stamp,
    String? payload,
    String? payloadDigest,
    int? byteCount,
    _iw51ozry.CalendarInvitationResponseDeliveryState? state,
    int? attemptCount,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? nextAttemptAt,
    Object? leaseOwner = _Undefined,
    Object? leaseToken = _Undefined,
    int? leaseFence,
    Object? leaseUntil = _Undefined,
    Object? terminalAt = _Undefined,
    Object? resultCode = _Undefined,
  }) {
    return CalendarInvitationResponseRecord(
      id: id is _is.UuidValue? ? id : this.id,
      scopeKey: scopeKey ?? this.scopeKey,
      recipientKey: recipientKey ?? this.recipientKey,
      stateId: stateId ?? this.stateId,
      entryId: entryId ?? this.entryId,
      commandId: commandId ?? this.commandId,
      criteriaDigest: criteriaDigest ?? this.criteriaDigest,
      request: request ?? this.request.copyWith(),
      receipt: receipt ?? this.receipt.copyWith(),
      sourceId: sourceId ?? this.sourceId,
      sourceRevision: sourceRevision ?? this.sourceRevision,
      sourceDigest: sourceDigest ?? this.sourceDigest,
      sourceSequence: sourceSequence is int?
          ? sourceSequence
          : this.sourceSequence,
      sourceStamp: sourceStamp ?? this.sourceStamp,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      organizerAddress: organizerAddress ?? this.organizerAddress,
      authorityRef: authorityRef ?? this.authorityRef,
      routeRef: routeRef ?? this.routeRef,
      generation: generation ?? this.generation,
      choice: choice ?? this.choice,
      stamp: stamp ?? this.stamp,
      payload: payload ?? this.payload,
      payloadDigest: payloadDigest ?? this.payloadDigest,
      byteCount: byteCount ?? this.byteCount,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      leaseOwner: leaseOwner is _is.UuidValue? ? leaseOwner : this.leaseOwner,
      leaseToken: leaseToken is _is.UuidValue? ? leaseToken : this.leaseToken,
      leaseFence: leaseFence ?? this.leaseFence,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      terminalAt: terminalAt is DateTime? ? terminalAt : this.terminalAt,
      resultCode: resultCode is String? ? resultCode : this.resultCode,
    );
  }
}

class CalendarInvitationResponseRecordUpdateTable
    extends _is.UpdateTable<CalendarInvitationResponseRecordTable> {
  CalendarInvitationResponseRecordUpdateTable(super.table);

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> recipientKey(String value) => _is.ColumnValue(
    table.recipientKey,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> stateId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.stateId,
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

  _is.ColumnValue<String, String> criteriaDigest(String value) =>
      _is.ColumnValue(
        table.criteriaDigest,
        value,
      );

  _is.ColumnValue<
    _iw3qnr12.CalendarInvitationResponseRequest,
    _iw3qnr12.CalendarInvitationResponseRequest
  >
  request(_iw3qnr12.CalendarInvitationResponseRequest value) => _is.ColumnValue(
    table.request,
    value,
  );

  _is.ColumnValue<
    _ig6twu0d.CalendarInvitationResponseReceipt,
    _ig6twu0d.CalendarInvitationResponseReceipt
  >
  receipt(_ig6twu0d.CalendarInvitationResponseReceipt value) => _is.ColumnValue(
    table.receipt,
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

  _is.ColumnValue<String, String> recipientAddress(String value) =>
      _is.ColumnValue(
        table.recipientAddress,
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

  _is.ColumnValue<int, int> generation(int value) => _is.ColumnValue(
    table.generation,
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

  _is.ColumnValue<DateTime, DateTime> stamp(DateTime value) => _is.ColumnValue(
    table.stamp,
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

  _is.ColumnValue<int, int> byteCount(int value) => _is.ColumnValue(
    table.byteCount,
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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseOwner(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseOwner,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> leaseToken(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.leaseToken,
    value,
  );

  _is.ColumnValue<int, int> leaseFence(int value) => _is.ColumnValue(
    table.leaseFence,
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

class CalendarInvitationResponseRecordTable extends _is.Table<_is.UuidValue?> {
  CalendarInvitationResponseRecordTable({super.tableRelation})
    : super(tableName: 'serverpod_calendar_invitation_response') {
    updateTable = CalendarInvitationResponseRecordUpdateTable(this);
    scopeKey = _is.ColumnString(
      'scopeKey',
      this,
    );
    recipientKey = _is.ColumnString(
      'recipientKey',
      this,
    );
    stateId = _is.ColumnUuid(
      'stateId',
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
    criteriaDigest = _is.ColumnString(
      'criteriaDigest',
      this,
    );
    request =
        _is.ColumnSerializable<_iw3qnr12.CalendarInvitationResponseRequest>(
          'request',
          this,
        );
    receipt =
        _is.ColumnSerializable<_ig6twu0d.CalendarInvitationResponseReceipt>(
          'receipt',
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
    recipientAddress = _is.ColumnString(
      'recipientAddress',
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
    generation = _is.ColumnInt(
      'generation',
      this,
    );
    choice = _is.ColumnEnum(
      'choice',
      this,
      _is.EnumSerialization.byName,
    );
    stamp = _is.ColumnDateTime(
      'stamp',
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
    byteCount = _is.ColumnInt(
      'byteCount',
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
    leaseOwner = _is.ColumnUuid(
      'leaseOwner',
      this,
    );
    leaseToken = _is.ColumnUuid(
      'leaseToken',
      this,
    );
    leaseFence = _is.ColumnInt(
      'leaseFence',
      this,
      hasDefault: true,
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

  late final CalendarInvitationResponseRecordUpdateTable updateTable;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString recipientKey;

  late final _is.ColumnUuid stateId;

  late final _is.ColumnUuid entryId;

  late final _is.ColumnUuid commandId;

  late final _is.ColumnString criteriaDigest;

  late final _is.ColumnSerializable<_iw3qnr12.CalendarInvitationResponseRequest>
  request;

  late final _is.ColumnSerializable<_ig6twu0d.CalendarInvitationResponseReceipt>
  receipt;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnInt sourceRevision;

  late final _is.ColumnString sourceDigest;

  late final _is.ColumnInt sourceSequence;

  late final _is.ColumnDateTime sourceStamp;

  late final _is.ColumnString recipientAddress;

  late final _is.ColumnString organizerAddress;

  late final _is.ColumnString authorityRef;

  late final _is.ColumnString routeRef;

  late final _is.ColumnInt generation;

  late final _is.ColumnEnum<_il64jj9v.CalendarInvitationResponseChoice> choice;

  late final _is.ColumnDateTime stamp;

  late final _is.ColumnString payload;

  late final _is.ColumnString payloadDigest;

  late final _is.ColumnInt byteCount;

  late final _is.ColumnEnum<_iw51ozry.CalendarInvitationResponseDeliveryState>
  state;

  late final _is.ColumnInt attemptCount;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime nextAttemptAt;

  late final _is.ColumnUuid leaseOwner;

  late final _is.ColumnUuid leaseToken;

  late final _is.ColumnInt leaseFence;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnDateTime terminalAt;

  late final _is.ColumnString resultCode;

  @override
  List<_is.Column> get columns => [
    id,
    scopeKey,
    recipientKey,
    stateId,
    entryId,
    commandId,
    criteriaDigest,
    request,
    receipt,
    sourceId,
    sourceRevision,
    sourceDigest,
    sourceSequence,
    sourceStamp,
    recipientAddress,
    organizerAddress,
    authorityRef,
    routeRef,
    generation,
    choice,
    stamp,
    payload,
    payloadDigest,
    byteCount,
    state,
    attemptCount,
    createdAt,
    expiresAt,
    nextAttemptAt,
    leaseOwner,
    leaseToken,
    leaseFence,
    leaseUntil,
    terminalAt,
    resultCode,
  ];
}

class CalendarInvitationResponseRecordInclude extends _is.IncludeObject {
  CalendarInvitationResponseRecordInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationResponseRecord.t;
}

class CalendarInvitationResponseRecordIncludeList extends _is.IncludeList {
  CalendarInvitationResponseRecordIncludeList._({
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CalendarInvitationResponseRecord.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CalendarInvitationResponseRecord.t;
}

class CalendarInvitationResponseRecordRepository {
  const CalendarInvitationResponseRecordRepository._();

  /// Returns a list of [CalendarInvitationResponseRecord]s matching the given query parameters.
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
  Future<List<CalendarInvitationResponseRecord>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CalendarInvitationResponseRecord>(
      where: where?.call(CalendarInvitationResponseRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CalendarInvitationResponseRecord] matching the given query parameters.
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
  Future<CalendarInvitationResponseRecord?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>? where,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CalendarInvitationResponseRecord>(
      where: where?.call(CalendarInvitationResponseRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CalendarInvitationResponseRecord] by its [id] or null if no such row exists.
  Future<CalendarInvitationResponseRecord?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CalendarInvitationResponseRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CalendarInvitationResponseRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [CalendarInvitationResponseRecord]s will have their `id` fields set.
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
  Future<List<CalendarInvitationResponseRecord>> insert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseRecord> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CalendarInvitationResponseRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CalendarInvitationResponseRecord] and returns the inserted row.
  ///
  /// The returned [CalendarInvitationResponseRecord] will have its `id` field set.
  Future<CalendarInvitationResponseRecord> insertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CalendarInvitationResponseRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CalendarInvitationResponseRecord]s in the list and returns the resulting rows.
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
  /// The returned [CalendarInvitationResponseRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseRecord>> upsert(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseRecord> rows, {
    required _is.ColumnSelections<CalendarInvitationResponseRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CalendarInvitationResponseRecord>(
      rows,
      conflictColumns: conflictColumns(CalendarInvitationResponseRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationResponseRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CalendarInvitationResponseRecord] and returns the resulting row.
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
  /// The returned [CalendarInvitationResponseRecord] will have its `id` field set.
  Future<CalendarInvitationResponseRecord?> upsertRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseRecord row, {
    required _is.ColumnSelections<CalendarInvitationResponseRecordTable>
    conflictColumns,
    _is.ColumnSelections<CalendarInvitationResponseRecordTable>? updateColumns,
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>?
    updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CalendarInvitationResponseRecord>(
      row,
      conflictColumns: conflictColumns(CalendarInvitationResponseRecord.t),
      updateColumns: updateColumns?.call(CalendarInvitationResponseRecord.t),
      updateWhere: updateWhere?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseRecord>> update(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseRecord> rows, {
    _is.ColumnSelections<CalendarInvitationResponseRecordTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CalendarInvitationResponseRecord>(
      rows,
      columns: columns?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CalendarInvitationResponseRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CalendarInvitationResponseRecord> updateRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseRecord row, {
    _is.ColumnSelections<CalendarInvitationResponseRecordTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CalendarInvitationResponseRecord>(
      row,
      columns: columns?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CalendarInvitationResponseRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CalendarInvitationResponseRecord?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseRecordUpdateTable
    >
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CalendarInvitationResponseRecord>(
      id,
      columnValues: columnValues(
        CalendarInvitationResponseRecord.t.updateTable,
      ),
      transaction: transaction,
    );
  }

  /// Updates all [CalendarInvitationResponseRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CalendarInvitationResponseRecord>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<
      CalendarInvitationResponseRecordUpdateTable
    >
    columnValues,
    required _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>
    where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CalendarInvitationResponseRecord>(
      columnValues: columnValues(
        CalendarInvitationResponseRecord.t.updateTable,
      ),
      where: where(CalendarInvitationResponseRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CalendarInvitationResponseRecord]s in the list and returns the deleted rows.
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
  Future<List<CalendarInvitationResponseRecord>> delete(
    _is.DatabaseSession session,
    List<CalendarInvitationResponseRecord> rows, {
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CalendarInvitationResponseRecord>(
      rows,
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CalendarInvitationResponseRecord].
  Future<CalendarInvitationResponseRecord> deleteRow(
    _is.DatabaseSession session,
    CalendarInvitationResponseRecord row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CalendarInvitationResponseRecord>(
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
  Future<List<CalendarInvitationResponseRecord>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>
    where,
    _is.OrderByBuilder<CalendarInvitationResponseRecordTable>? orderBy,
    _is.OrderByListBuilder<CalendarInvitationResponseRecordTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CalendarInvitationResponseRecord>(
      where: where(CalendarInvitationResponseRecord.t),
      orderBy: orderBy?.call(CalendarInvitationResponseRecord.t),
      orderByList: orderByList?.call(CalendarInvitationResponseRecord.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CalendarInvitationResponseRecord>(
      where: where?.call(CalendarInvitationResponseRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CalendarInvitationResponseRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CalendarInvitationResponseRecordTable>
    where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CalendarInvitationResponseRecord>(
      where: where(CalendarInvitationResponseRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
