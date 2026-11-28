import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'package:crypto/crypto.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart';

import 'feed_policy.dart';
import 'feed_values.dart';
import 'feed_log_redaction.dart';
import 'generated/protocol.dart';

part 'feed_http.dart';

const _maxRevision = 9007199254740991;
CalendarFeedException feedFailure(CalendarFeedFailureCode code) =>
    CalendarFeedException(code: code, message: 'Calendar feed ${code.name}.');

final class CalendarFeedOptions {
  CalendarFeedOptions({
    required this.publicBaseUri,
    required this.requiredGuarantee,
    this.allowInsecureLoopback = false,
    this.retention = const Duration(days: 30),
    this.policyTimeout = const Duration(seconds: 5),
    this.contentLanguage,
  }) {
    if (contentLanguage != null) validateCalendarLanguageTag(contentLanguage!);
    if ((!publicBaseUri.isScheme('https') &&
            !(allowInsecureLoopback &&
                publicBaseUri.isScheme('http') &&
                const [
                  'localhost',
                  '127.0.0.1',
                  '::1',
                ].contains(publicBaseUri.host))) ||
        publicBaseUri.host.isEmpty ||
        publicBaseUri.userInfo.isNotEmpty ||
        publicBaseUri.hasQuery ||
        publicBaseUri.hasFragment ||
        !publicBaseUri.path.endsWith('/') ||
        retention < const Duration(days: 1) ||
        retention > const Duration(days: 3650) ||
        policyTimeout <= Duration.zero ||
        policyTimeout > const Duration(seconds: 30)) {
      throw ArgumentError('Invalid calendar feed configuration');
    }
  }
  final Uri publicBaseUri;
  final CalendarAuthorizationGuarantee requiredGuarantee;
  final bool allowInsecureLoopback;
  final Duration retention, policyTimeout;
  final String? contentLanguage;
}

final class _Runtime {
  const _Runtime(this.policy, this.options);
  final CalendarFeedHostPolicy policy;
  final CalendarFeedOptions options;
}

abstract final class CalendarFeedModule {
  static final _installed = Expando<_Runtime>();
  static void install(
    Serverpod pod, {
    required CalendarFeedHostPolicy policy,
    required CalendarFeedOptions options,
    required CalendarFeedDependencies dependencies,
  }) {
    final publicationGuarantee = CalendarModule.publicationGuarantee(
      pod,
      dependencies,
    );
    if (publicationGuarantee == null) {
      throw ArgumentError(
        'Install calendar publication policy and the same feed dependency provider first',
      );
    }
    if (options.requiredGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        (policy.guarantee != CalendarAuthorizationGuarantee.coordinated ||
            publicationGuarantee !=
                CalendarAuthorizationGuarantee.coordinated)) {
      throw ArgumentError('Feed policy cannot supply the required guarantee');
    }
    _installed[pod] = _Runtime(policy, options);
  }

  static CalendarFeedService service(Session session) {
    final runtime = _installed[session.serverpod];
    if (runtime == null || session.authenticated == null) {
      throw feedFailure(CalendarFeedFailureCode.accessDenied);
    }
    return CalendarFeedService._(session, runtime);
  }

  /// Trusted bounded maintenance; never expose as a client endpoint.
  static Future<void> runMaintenance(Session session) async {
    final runtime = _installed[session.serverpod];
    if (runtime == null) throw feedFailure(CalendarFeedFailureCode.unavailable);
    final clock = await session.db.unsafeQuery('SELECT clock_timestamp()');
    final cutoff = (clock.single.single as DateTime).toUtc().subtract(
      runtime.options.retention,
    );
    final revoked = await CalendarFeedCredentialRecord.db.find(
      session,
      where: (t) => t.revokedAt.notEquals(null) & (t.revokedAt < cutoff),
      orderBy: (t) => t.revokedAt,
      limit: 128,
    );
    final markers = await CalendarFeedIdentityRecord.db.find(
      session,
      where: (t) => t.deletedAt.notEquals(null) & (t.deletedAt < cutoff),
      orderBy: (t) => t.deletedAt,
      limit: 128,
    );
    final scopes = <String>{...markers.map((m) => m.scopeKey)};
    final parents = <UuidValue, CalendarFeedIdentityRecord>{};
    for (final row in revoked) {
      final parent = await CalendarFeedIdentityRecord.db.findById(
        session,
        row.feedId,
      );
      if (parent != null) {
        parents[row.feedId] = parent;
        scopes.add(parent.scopeKey);
      }
    }
    for (final scope in scopes) {
      await CalendarModule.publicationTransaction(session, scope, (port) async {
        for (final row in revoked.where(
          (r) => parents[r.feedId]?.scopeKey == scope,
        )) {
          await CalendarFeedCredentialRecord.db.deleteWhere(
            session,
            where: (t) =>
                t.id.equals(row.id!) &
                t.revokedAt.notEquals(null) &
                (t.revokedAt < cutoff),
            transaction: port.transaction,
          );
        }
        for (final marker in markers.where((m) => m.scopeKey == scope)) {
          await CalendarFeedIdentityRecord.db.deleteWhere(
            session,
            where: (t) =>
                t.id.equals(marker.id!) &
                t.deletedAt.notEquals(null) &
                (t.deletedAt < cutoff),
            transaction: port.transaction,
          );
        }
      });
    }
  }
}

final class _Loaded {
  _Loaded(this.identity, this.data, this.settings);
  final CalendarFeedIdentityRecord identity;
  final CalendarFeedDataRecord data;
  final CalendarFeedSettings settings;
  CalendarFeedView get view => CalendarFeedView(
    id: identity.id!,
    revision: identity.revision,
    displayName: settings.displayName,
    calendarIds: settings.calendarIds,
    protocolUid: data.protocolUid,
    protocolModifiedAt: data.protocolModifiedAt,
    protocolMetadata: settings.protocolMetadata,
    supplementalMetadata: settings.supplementalMetadata,
  );
  CalendarFeedPolicyState state({
    CalendarFeedCredentialRecord? credential,
    int? revision,
  }) => CalendarFeedPolicyState(
    id: identity.id!,
    revision: revision ?? identity.revision,
    authorityReference: data.authorityReference,
    settingsJson: jsonEncode(settings.toJson()),
    calendarIds: settings.calendarIds,
    credentialId: credential?.id,
    credentialRevision: credential?.revision,
    credentialRevokedAt: credential?.revokedAt,
    credentialLabel: credential?.label,
    credentialCreatedAt: credential?.createdAt,
  );
}

final class _Check {
  const _Check(this.operation, this.current, this.proposed);
  final CalendarFeedOperation operation;
  final CalendarFeedPolicyState? current, proposed;
}

final class _Work {
  _Work(this.service, this.context, this.port);
  final CalendarFeedService service;
  final CalendarFeedHostContext context;
  final CalendarPublicationTransaction port;
  final checks = <_Check>[];
  Transaction get tx => port.transaction;
  Future<bool> allow(
    CalendarFeedOperation operation, {
    CalendarFeedPolicyState? current,
    CalendarFeedPolicyState? proposed,
    bool filterDenied = false,
  }) async {
    final check = _Check(operation, current, proposed);
    final allowed = await service._authorize(this, check, false);
    if (!allowed) {
      if (filterDenied) return false;
      throw feedFailure(CalendarFeedFailureCode.accessDenied);
    }
    checks.add(check);
    return true;
  }
}

final class CalendarFeedService {
  CalendarFeedService._(this._session, this._runtime);
  final Session _session;
  final _Runtime _runtime;

  Future<T> _bounded<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(_runtime.options.policyTimeout);
    } on CalendarFeedException {
      rethrow;
    } catch (_) {
      throw feedFailure(CalendarFeedFailureCode.unavailable);
    }
  }

  Future<CalendarFeedHostContext> _context() async {
    final c = await _bounded(() => _runtime.policy.resolveContext(_session));
    for (final value in [
      c.actor,
      c.scopeKey,
      c.policyRevision,
      c.authorityReference,
    ]) {
      validateCalendarOpaqueText(value, maxUtf8Bytes: 512);
    }
    return c;
  }

  Future<void> _verify(CalendarFeedHostContext c) async {
    final now = await _context();
    if (now.actor != c.actor ||
        now.scopeKey != c.scopeKey ||
        now.policyRevision != c.policyRevision ||
        now.authorityReference != c.authorityReference) {
      throw feedFailure(CalendarFeedFailureCode.unavailable);
    }
  }

  Future<bool> _authorize(_Work w, _Check check, bool finalCheck) => _bounded(
    () => _runtime.policy.authorize(
      _session,
      w.context,
      check.operation,
      w.tx,
      current: check.current,
      proposed: check.proposed,
      finalCheck: finalCheck,
    ),
  );

  Future<T> _transaction<T>(Future<T> Function(_Work) action) async {
    try {
      final c = await _context();
      return await CalendarModule.publicationTransaction(_session, c.scopeKey, (
        port,
      ) async {
        final w = _Work(this, c, port);
        final result = await action(w);
        await _verify(c);
        for (final check in w.checks) {
          if (!await _authorize(w, check, true)) {
            throw feedFailure(CalendarFeedFailureCode.accessDenied);
          }
        }
        await _verify(c);
        return result;
      });
    } on CalendarFeedException {
      rethrow;
    } on CalendarException catch (e) {
      throw feedFailure(switch (e.code) {
        CalendarFailureCode.accessDenied =>
          CalendarFeedFailureCode.accessDenied,
        CalendarFailureCode.validation => CalendarFeedFailureCode.validation,
        CalendarFailureCode.limitExceeded =>
          CalendarFeedFailureCode.limitExceeded,
        CalendarFailureCode.staleRevision =>
          CalendarFeedFailureCode.staleRevision,
        _ => CalendarFeedFailureCode.unavailable,
      });
    } on ArgumentError {
      throw feedFailure(CalendarFeedFailureCode.validation);
    } catch (_) {
      throw feedFailure(CalendarFeedFailureCode.unavailable);
    }
  }

  Future<_Loaded> _load(_Work w, UuidValue id) =>
      _loadFeed(_session, w.context.scopeKey, id, w.tx);
  void _revision(int expected, int actual) {
    if (expected < 1 || expected > _maxRevision) {
      throw feedFailure(CalendarFeedFailureCode.validation);
    }
    if (expected != actual) {
      throw feedFailure(CalendarFeedFailureCode.staleRevision);
    }
    if (actual >= _maxRevision) {
      throw feedFailure(CalendarFeedFailureCode.limitExceeded);
    }
  }

  Future<void> _select(_Work w, UuidValue id, List<UuidValue> ids) async {
    await CalendarFeedSelectionRecord.db.deleteWhere(
      _session,
      where: (t) => t.feedId.equals(id),
      transaction: w.tx,
    );
    await CalendarFeedSelectionRecord.db.insert(_session, [
      for (final calendar in ids)
        CalendarFeedSelectionRecord(feedId: id, calendarId: calendar),
    ], transaction: w.tx);
  }

  Future<List<CalendarFeedView>> list() => _transaction((w) async {
    await w.allow(CalendarFeedOperation.list);
    final rows = await CalendarFeedIdentityRecord.db.find(
      _session,
      where: (t) =>
          t.scopeKey.equals(w.context.scopeKey) & t.deletedAt.equals(null),
      orderBy: (t) => t.id,
      limit: 65,
      transaction: w.tx,
    );
    if (rows.length > 64) {
      throw feedFailure(CalendarFeedFailureCode.limitExceeded);
    }
    final result = <CalendarFeedView>[];
    for (final row in rows) {
      final value = await _load(w, row.id!);
      if (await w.allow(
        CalendarFeedOperation.read,
        current: value.state(),
        filterDenied: true,
      )) {
        result.add(value.view);
      }
    }
    return result;
  });
  Future<CalendarFeedView> read(UuidValue id) => _transaction((w) async {
    final value = await _load(w, id);
    await w.allow(CalendarFeedOperation.read, current: value.state());
    return value.view;
  });
  Future<CalendarFeedView> create(CalendarFeedSettings input) =>
      _transaction((w) async {
        final settings = validateFeedSettings(input);
        final id = const Uuid().v4obj();
        final proposed = CalendarFeedPolicyState(
          id: id,
          revision: 1,
          authorityReference: w.context.authorityReference,
          settingsJson: jsonEncode(settings.toJson()),
          calendarIds: settings.calendarIds,
        );
        await w.allow(CalendarFeedOperation.create, proposed: proposed);
        final rows = await CalendarFeedIdentityRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(w.context.scopeKey) & t.deletedAt.equals(null),
          limit: 64,
          transaction: w.tx,
        );
        if (rows.length >= 64) {
          throw feedFailure(CalendarFeedFailureCode.limitExceeded);
        }
        await w.port.requireSelection(
          settings.calendarIds,
          w.context.authorityReference,
        );
        final now = await w.port.databaseTime();
        await CalendarFeedIdentityRecord.db.insertRow(
          _session,
          CalendarFeedIdentityRecord(
            id: id,
            scopeKey: w.context.scopeKey,
            revision: 1,
          ),
          transaction: w.tx,
        );
        await CalendarFeedDataRecord.db.insertRow(
          _session,
          CalendarFeedDataRecord(
            feedId: id,
            displayName: settings.displayName,
            protocolMetadata: settings.protocolMetadata,
            supplementalMetadata: settings.supplementalMetadata,
            protocolModifiedAt: _seconds(now),
            authorityReference: w.context.authorityReference,
            profileVersion: 1,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: w.tx,
        );
        await _select(w, id, settings.calendarIds);
        return (await _load(w, id)).view;
      });
  Future<CalendarFeedView> update(
    UuidValue id,
    int expectedRevision,
    CalendarFeedSettings input,
  ) => _transaction((w) async {
    final current = await _load(w, id);
    final settings = validateFeedSettings(input);
    final proposed = CalendarFeedPolicyState(
      id: id,
      revision: current.identity.revision + 1,
      authorityReference: w.context.authorityReference,
      settingsJson: jsonEncode(settings.toJson()),
      calendarIds: settings.calendarIds,
    );
    await w.allow(
      CalendarFeedOperation.update,
      current: current.state(),
      proposed: proposed,
    );
    _revision(expectedRevision, current.identity.revision);
    await w.port.requireSelection(
      settings.calendarIds,
      w.context.authorityReference,
    );
    final now = await w.port.databaseTime();
    current.identity.revision++;
    await CalendarFeedIdentityRecord.db.updateRow(
      _session,
      current.identity,
      transaction: w.tx,
    );
    final changed =
        feedPublicationSettingsKey(current.settings) !=
        feedPublicationSettingsKey(settings);
    final modified = _seconds(now).isBefore(current.data.protocolModifiedAt)
        ? current.data.protocolModifiedAt
        : _seconds(now);
    await CalendarFeedDataRecord.db.updateRow(
      _session,
      current.data.copyWith(
        displayName: settings.displayName,
        protocolMetadata: settings.protocolMetadata,
        supplementalMetadata: settings.supplementalMetadata,
        authorityReference: w.context.authorityReference,
        updatedAt: now,
        protocolModifiedAt: changed
            ? modified
            : current.data.protocolModifiedAt,
      ),
      transaction: w.tx,
    );
    await _select(w, id, settings.calendarIds);
    return (await _load(w, id)).view;
  });
  Future<void> delete(UuidValue id, int expectedRevision) =>
      _transaction((w) async {
        final current = await _load(w, id);
        await w.allow(
          CalendarFeedOperation.delete,
          current: current.state(),
          proposed: CalendarFeedPolicyState(
            id: id,
            revision: current.identity.revision + 1,
            authorityReference: '',
            settingsJson: '{}',
            calendarIds: [],
            deleted: true,
          ),
        );
        _revision(expectedRevision, current.identity.revision);
        await CalendarFeedCredentialRecord.db.deleteWhere(
          _session,
          where: (t) => t.feedId.equals(id),
          transaction: w.tx,
        );
        await CalendarFeedSelectionRecord.db.deleteWhere(
          _session,
          where: (t) => t.feedId.equals(id),
          transaction: w.tx,
        );
        await CalendarFeedDataRecord.db.deleteRow(
          _session,
          current.data,
          transaction: w.tx,
        );
        current.identity.revision++;
        current.identity.deletedAt = await w.port.databaseTime();
        await CalendarFeedIdentityRecord.db.updateRow(
          _session,
          current.identity,
          transaction: w.tx,
        );
      });

  Future<List<CalendarFeedCredentialView>> credentials(UuidValue feedId) =>
      _transaction((w) async {
        final current = await _load(w, feedId);
        await w.allow(
          CalendarFeedOperation.listCredentials,
          current: current.state(),
        );
        final rows = await _credentials(w, feedId);
        return rows.map(_credentialView).toList();
      });
  Future<List<CalendarFeedCredentialRecord>> _credentials(
    _Work w,
    UuidValue id,
  ) async {
    final rows = await CalendarFeedCredentialRecord.db.find(
      _session,
      where: (t) => t.feedId.equals(id),
      orderBy: (t) => t.id,
      limit: 65,
      transaction: w.tx,
    );
    if (rows.length > 64) {
      throw feedFailure(CalendarFeedFailureCode.limitExceeded);
    }
    return rows;
  }

  Future<CalendarFeedCreatedCredential> createCredential(
    UuidValue id,
    int expectedFeedRevision,
    String? label,
  ) => _transaction((w) async {
    final current = await _load(w, id);
    final validatedLabel = validateFeedCredentialLabel(label);
    final proposedCredential = CalendarFeedCredentialRecord(
      id: const Uuid().v4obj(),
      feedId: id,
      digestVersion: 1,
      digest: '',
      label: validatedLabel,
      revision: 1,
      createdAt: await w.port.databaseTime(),
    );
    await w.allow(
      CalendarFeedOperation.createCredential,
      current: current.state(),
      proposed: current.state(
        credential: proposedCredential,
        revision: current.identity.revision + 1,
      ),
    );
    _revision(expectedFeedRevision, current.identity.revision);
    final rows = await _credentials(w, id);
    if (rows.length >= 64 ||
        rows.where((r) => r.revokedAt == null).length >= 16) {
      throw feedFailure(CalendarFeedFailureCode.limitExceeded);
    }
    // Reconfirm publication eligibility when granting another bearer URL.
    await w.port.requireSelection(
      current.settings.calendarIds,
      current.data.authorityReference,
    );
    final random = Random.secure();
    final token = base64UrlEncode(
      List<int>.generate(32, (_) => random.nextInt(256)),
    ).replaceAll('=', '');
    final row = await CalendarFeedCredentialRecord.db.insertRow(
      _session,
      proposedCredential.copyWith(
        digest: sha256.convert(utf8.encode(token)).toString(),
      ),
      transaction: w.tx,
    );
    current.identity.revision++;
    await CalendarFeedIdentityRecord.db.updateRow(
      _session,
      current.identity,
      transaction: w.tx,
    );
    return CalendarFeedCreatedCredential(
      credential: _credentialView(row),
      url: _runtime.options.publicBaseUri
          .resolve('calendar-feed/$token.ics')
          .toString(),
    );
  });
  Future<void> revokeCredential(
    UuidValue feedId,
    int expectedFeedRevision,
    UuidValue credentialId,
    int expectedRevision,
  ) => _transaction((w) async {
    final current = await _load(w, feedId);
    final row = await CalendarFeedCredentialRecord.db.findById(
      _session,
      credentialId,
      transaction: w.tx,
    );
    if (row == null || row.feedId != feedId) {
      throw feedFailure(CalendarFeedFailureCode.accessDenied);
    }
    final proposedRow = row.revokedAt != null
        ? row
        : row.copyWith(
            revision: row.revision + 1,
            revokedAt: await w.port.databaseTime(),
          );
    await w.allow(
      CalendarFeedOperation.revokeCredential,
      current: current.state(credential: row),
      proposed: current.state(
        credential: proposedRow,
        revision: current.identity.revision + (row.revokedAt == null ? 1 : 0),
      ),
    );
    _revision(expectedFeedRevision, current.identity.revision);
    _revision(expectedRevision, row.revision);
    if (row.revokedAt != null) return;
    await CalendarFeedCredentialRecord.db.updateRow(
      _session,
      proposedRow,
      transaction: w.tx,
    );
    current.identity.revision++;
    await CalendarFeedIdentityRecord.db.updateRow(
      _session,
      current.identity,
      transaction: w.tx,
    );
  });
}

Future<_Loaded> _loadFeed(
  Session session,
  String scopeKey,
  UuidValue id,
  Transaction transaction,
) async {
  final identity = await CalendarFeedIdentityRecord.db.findById(
    session,
    id,
    transaction: transaction,
  );
  if (identity == null ||
      identity.deletedAt != null ||
      identity.scopeKey != scopeKey) {
    throw feedFailure(CalendarFeedFailureCode.accessDenied);
  }
  final data = await CalendarFeedDataRecord.db.findFirstRow(
    session,
    where: (t) => t.feedId.equals(id),
    transaction: transaction,
  );
  if (data == null || data.profileVersion != 1) {
    throw feedFailure(CalendarFeedFailureCode.unavailable);
  }
  final selections = await CalendarFeedSelectionRecord.db.find(
    session,
    where: (t) => t.feedId.equals(id),
    orderBy: (t) => t.calendarId,
    limit: 17,
    transaction: transaction,
  );
  final settings = validateFeedSettings(
    CalendarFeedSettings(
      displayName: data.displayName,
      calendarIds: selections.map((s) => s.calendarId).toList(),
      protocolMetadata: data.protocolMetadata,
      supplementalMetadata: data.supplementalMetadata,
    ),
  );
  return _Loaded(identity, data, settings);
}

DateTime _seconds(DateTime value) => DateTime.fromMicrosecondsSinceEpoch(
  value.toUtc().microsecondsSinceEpoch ~/ 1000000 * 1000000,
  isUtc: true,
);
CalendarFeedCredentialView _credentialView(CalendarFeedCredentialRecord row) =>
    CalendarFeedCredentialView(
      id: row.id!,
      feedId: row.feedId,
      revision: row.revision,
      label: row.label,
      createdAt: row.createdAt,
      revokedAt: row.revokedAt,
    );

/// Register with CalendarModule.install so active selections block deletion.
final class CalendarFeedDependencies
    implements CalendarDependencyProvider, CalendarPublicationChangeObserver {
  const CalendarFeedDependencies();
  @override
  Future<bool> hasActiveDependencies(
    Session session,
    UuidValue calendarId,
    Transaction transaction,
  ) async =>
      await CalendarFeedSelectionRecord.db.findFirstRow(
        session,
        where: (t) => t.calendarId.equals(calendarId),
        transaction: transaction,
      ) !=
      null;

  @override
  Future<void> eventsChanged(
    Session session,
    String scopeKey,
    UuidValue calendarId,
    Transaction transaction,
  ) async {
    final selections = await CalendarFeedSelectionRecord.db.find(
      session,
      where: (t) => t.calendarId.equals(calendarId),
      limit: 65,
      transaction: transaction,
    );
    if (selections.length > 64) {
      throw feedFailure(CalendarFeedFailureCode.limitExceeded);
    }
    if (selections.isEmpty) return;
    final clock = await session.db.unsafeQuery(
      'SELECT clock_timestamp()',
      transaction: transaction,
    );
    final now = _seconds(clock.single.single as DateTime);
    for (final selection in selections) {
      final identity = await CalendarFeedIdentityRecord.db.findById(
        session,
        selection.feedId,
        transaction: transaction,
      );
      final data = await CalendarFeedDataRecord.db.findFirstRow(
        session,
        where: (t) => t.feedId.equals(selection.feedId),
        transaction: transaction,
      );
      if (identity == null ||
          identity.scopeKey != scopeKey ||
          identity.deletedAt != null ||
          data == null) {
        throw feedFailure(CalendarFeedFailureCode.unavailable);
      }
      if (now.isAfter(data.protocolModifiedAt)) {
        await CalendarFeedDataRecord.db.updateRow(
          session,
          data.copyWith(protocolModifiedAt: now),
          transaction: transaction,
        );
      }
    }
  }
}
