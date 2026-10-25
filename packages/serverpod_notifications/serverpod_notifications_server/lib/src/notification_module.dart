import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:serverpod/serverpod.dart';

import 'generated/protocol.dart';
import 'notification_runtime.dart';
import 'notification_work_store.dart';
part 'notification_worker.dart';

NotificationException _failure(NotificationFailureCode code) =>
    NotificationException(
      code: code,
      message: 'Notification operation could not be completed (${code.name}).',
    );

final class _Runtime {
  _Runtime(this.policy, this.sources, this.publication, this.options);
  final NotificationHostPolicy policy;
  final Map<(String, int), NotificationSourceAdapter> sources;
  final NotificationPublicationPort publication;
  final NotificationOptions options;
}

abstract final class NotificationModule {
  static final _installed = Expando<_Runtime>();
  static void install(
    Serverpod pod, {
    required NotificationHostPolicy policy,
    required List<NotificationSourceAdapter> sources,
    required NotificationPublicationPort publication,
    NotificationOptions? options,
  }) {
    final settings = options ?? NotificationOptions();
    if (sources.isEmpty || sources.length > 32) {
      throw ArgumentError('Bounded source registry required');
    }
    final registered = <(String, int), NotificationSourceAdapter>{};
    for (final source in sources) {
      notificationOpaque(source.namespace);
      if (source.version < 1 ||
          source.version > 9007199254740991 ||
          registered.containsKey((source.namespace, source.version))) {
        throw ArgumentError('Invalid source registration');
      }
      registered[(source.namespace, source.version)] = source;
    }
    if (settings.requiredGuarantee == NotificationGuarantee.coordinated &&
        (policy.guarantee != NotificationGuarantee.coordinated ||
            registered.values.any(
              (s) => s.guarantee != NotificationGuarantee.coordinated,
            ))) {
      throw ArgumentError('Notification guarantees cannot be downgraded');
    }
    _installed[pod] = _Runtime(
      policy,
      Map.unmodifiable(registered),
      publication,
      settings,
    );
  }

  static NotificationService service(Session session) {
    final runtime = _installed[session.serverpod];
    if (runtime == null) throw _failure(NotificationFailureCode.unavailable);
    return NotificationService._(session, runtime);
  }

  /// Trusted producer API; never exposed as an unauthenticated enqueue endpoint.
  static Future<UuidValue> accept(
    Session session,
    NotificationEnvelope request,
  ) => service(session)._accept(request);
  static Future<void> runMaintenance(Session session) =>
      _NotificationWorker(service(session)).run();
}

final class NotificationService {
  NotificationService._(this._session, this._runtime);
  final Session _session;
  final _Runtime _runtime;
  NotificationOptions get _options => _runtime.options;
  static const maxCounter = 9007199254740991;

  Future<DateTime> _now(Transaction tx) async =>
      ((await _session.db.unsafeQuery(
                'SELECT clock_timestamp()',
                transaction: tx,
              )).single.single
              as DateTime)
          .toUtc();
  Future<T> _bounded<T>(Future<T> Function() callback) async {
    try {
      return await callback().timeout(_options.callbackTimeout);
    } catch (_) {
      throw _failure(NotificationFailureCode.unavailable);
    }
  }

  void _guarantee(NotificationGuarantee guarantee) {
    if (_options.requiredGuarantee == NotificationGuarantee.coordinated &&
        guarantee != NotificationGuarantee.coordinated) {
      throw _failure(NotificationFailureCode.unavailable);
    }
  }

  Future<T> _scope<T>(String scope, Future<T> Function(Transaction) body) =>
      _session.db.transaction((tx) async {
        await NotificationScopeRecord.db.insert(
          _session,
          [NotificationScopeRecord(scopeKey: scope)],
          ignoreConflicts: true,
          noReturn: true,
          transaction: tx,
        );
        final lock = await NotificationScopeRecord.db.findFirstRow(
          _session,
          where: (t) => t.scopeKey.equals(scope),
          lockMode: LockMode.forUpdate,
          transaction: tx,
        );
        if (lock == null) throw _failure(NotificationFailureCode.unavailable);
        return body(tx);
      });
  Future<NotificationActor> _actor() async {
    if (_session.authenticated == null) {
      throw _failure(NotificationFailureCode.accessDenied);
    }
    return _bounded(() => _runtime.policy.resolveContext(_session));
  }

  Future<void> _authorize(
    NotificationActor actor,
    NotificationPermission operation,
    Transaction tx,
    NotificationPhase phase,
  ) async {
    _guarantee(_runtime.policy.guarantee);
    final current = await _actor();
    if (!actor.same(current)) {
      throw _failure(NotificationFailureCode.unavailable);
    }
    final verdict = await _bounded(
      () => _runtime.policy.authorize(_session, actor, operation, tx, phase),
    );
    _guarantee(_runtime.policy.guarantee);
    if (!actor.same(await _actor())) {
      throw _failure(NotificationFailureCode.unavailable);
    }
    _guarantee(_runtime.policy.guarantee);
    if (verdict != NotificationVerdict.allow) {
      throw _failure(
        verdict == NotificationVerdict.deny
            ? NotificationFailureCode.accessDenied
            : NotificationFailureCode.unavailable,
      );
    }
  }

  NotificationSourceAdapter _adapter(NotificationEnvelope e) {
    final adapter = _runtime.sources[(e.sourceNamespace, e.sourceVersion)];
    if (adapter == null ||
        adapter.namespace != e.sourceNamespace ||
        adapter.version != e.sourceVersion) {
      throw _failure(NotificationFailureCode.unavailable);
    }
    _guarantee(adapter.guarantee);
    return adapter;
  }

  Future<NotificationVerdict> _source(
    NotificationEnvelope e,
    NotificationSourceOperation operation,
    Transaction tx,
    NotificationPhase phase,
  ) async {
    final verdict = await _bounded(
      () => _adapter(e).check(_session, e, operation, tx, phase),
    );
    _adapter(e); // Recheck a live capability downgrade after slow callbacks.
    return verdict;
  }

  void _eligible(NotificationEnvelope e, DateTime now) {
    if (e.dueAt.isAfter(now) || !e.expiresAt.isAfter(now)) {
      throw _failure(NotificationFailureCode.validation);
    }
  }

  NotificationEnvelope _envelope(NotificationDeliveryRecord r) =>
      NotificationEnvelope(
        scopeKey: r.scopeKey,
        recipient: NotificationRecipient(r.recipientNamespace, r.recipientKey),
        sourceNamespace: r.sourceNamespace,
        sourceVersion: r.sourceVersion,
        requestId: r.sourceRequestId,
        reference: r.sourceReference,
        dueAt: r.dueAt,
        expiresAt: r.expiresAt,
      );

  Future<UuidValue> _accept(NotificationEnvelope e) =>
      _scope(e.scopeKey, (tx) async {
        final preliminary = await _source(
          e,
          NotificationSourceOperation.accept,
          tx,
          NotificationPhase.preliminary,
        );
        if (preliminary != NotificationVerdict.allow) {
          throw _failure(
            preliminary == NotificationVerdict.deny
                ? NotificationFailureCode.accessDenied
                : NotificationFailureCode.unavailable,
          );
        }
        _eligible(e, await _now(tx));
        final previous = await NotificationDeliveryRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(e.scopeKey) &
              t.sourceNamespace.equals(e.sourceNamespace) &
              t.sourceRequestId.equals(e.requestId),
          transaction: tx,
        );
        if (previous != null && previous.requestDigest != e.digest) {
          throw _failure(NotificationFailureCode.conflict);
        }
        if (previous == null &&
            await NotificationDeliveryRecord.db.count(
                  _session,
                  where: (t) =>
                      t.scopeKey.equals(e.scopeKey) &
                      t.recipientNamespace.equals(e.recipient.namespace) &
                      t.recipientKey.equals(e.recipient.key),
                  limit: _options.maxRetainedPerRecipient,
                  transaction: tx,
                ) >=
                _options.maxRetainedPerRecipient) {
          throw _failure(NotificationFailureCode.limitExceeded);
        }
        final verdict = await _source(
          e,
          NotificationSourceOperation.accept,
          tx,
          NotificationPhase.finalCheck,
        );
        if (verdict != NotificationVerdict.allow) {
          throw _failure(
            verdict == NotificationVerdict.deny
                ? NotificationFailureCode.accessDenied
                : NotificationFailureCode.unavailable,
          );
        }
        final now = await _now(tx);
        _eligible(e, now);
        if (previous != null) return previous.id!;
        final row = await NotificationDeliveryRecord.db.insertRow(
          _session,
          NotificationDeliveryRecord(
            scopeKey: e.scopeKey,
            recipientNamespace: e.recipient.namespace,
            recipientKey: e.recipient.key,
            sourceNamespace: e.sourceNamespace,
            sourceVersion: e.sourceVersion,
            sourceRequestId: e.requestId,
            requestDigest: e.digest,
            sourceReference: e.reference,
            dueAt: e.dueAt,
            expiresAt: e.expiresAt,
            nextAttemptAt: now,
            createdAt: now,
            updatedAt: now,
          ),
          transaction: tx,
        );
        return row.id!;
      });

  /// Used by host streaming adapters. The returned identity is trusted, not a client selector.
  Future<NotificationActor> authorizeSubscription() async {
    final actor = await _actor();
    return _scope(actor.scopeKey, (tx) async {
      await _authorize(
        actor,
        NotificationPermission.subscribe,
        tx,
        NotificationPhase.finalCheck,
      );
      return actor;
    });
  }

  Future<NotificationPage> recover({
    required int pageSize,
    String? cursor,
  }) async {
    if (pageSize < 1 || pageSize > _options.maxPageSize) {
      throw _failure(NotificationFailureCode.validation);
    }
    final actor = await _actor();
    return _scope(actor.scopeKey, (tx) async {
      await _authorize(
        actor,
        NotificationPermission.recover,
        tx,
        NotificationPhase.preliminary,
      );
      UuidValue? after;
      if (cursor != null) {
        if (!RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
          throw _failure(NotificationFailureCode.invalidCursor);
        }
        final saved = await NotificationCursorRecord.db.findFirstRow(
          _session,
          where: (t) => t.token.equals(cursor),
          transaction: tx,
        );
        if (saved == null ||
            saved.scopeKey != actor.scopeKey ||
            saved.principalId != actor.principalId ||
            saved.policyRevision != actor.policyRevision ||
            saved.recipientNamespace != actor.recipient.namespace ||
            saved.recipientKey != actor.recipient.key ||
            saved.pageSize != pageSize ||
            !saved.expiresAt.isAfter(await _now(tx))) {
          throw _failure(NotificationFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final items = <NotificationView>[];
      var scanned = 0;
      while (items.length <= pageSize) {
        final now = await _now(tx);
        final rows = await NotificationDeliveryRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(actor.scopeKey) &
              t.recipientNamespace.equals(actor.recipient.namespace) &
              t.recipientKey.equals(actor.recipient.key) &
              t.state.inSet({
                NotificationDeliveryState.queued,
                NotificationDeliveryState.published,
              }) &
              (t.dueAt <= now) &
              (t.expiresAt > now) &
              (after == null ? Constant.bool(true) : t.id > after),
          orderBy: (t) => t.id,
          limit: 50,
          transaction: tx,
        );
        if (rows.isEmpty) break;
        for (final row in rows) {
          if (++scanned > _options.maxScanned) {
            throw _failure(NotificationFailureCode.limitExceeded);
          }
          final e = _envelope(row);
          if (e.digest != row.requestDigest) {
            throw _failure(NotificationFailureCode.unavailable);
          }
          final verdict = await _source(
            e,
            NotificationSourceOperation.recover,
            tx,
            NotificationPhase.preliminary,
          );
          if (verdict == NotificationVerdict.unavailable) {
            throw _failure(NotificationFailureCode.unavailable);
          }
          if (verdict == NotificationVerdict.deny) continue;
          final content = await _bounded(
            () => _adapter(e).project(_session, e, actor, tx),
          );
          final finalVerdict = await _source(
            e,
            NotificationSourceOperation.recover,
            tx,
            NotificationPhase.finalCheck,
          );
          if (finalVerdict == NotificationVerdict.unavailable) {
            throw _failure(NotificationFailureCode.unavailable);
          }
          if (finalVerdict == NotificationVerdict.deny ||
              content == null ||
              !e.expiresAt.isAfter(await _now(tx))) {
            continue;
          }
          items.add(
            NotificationView(
              id: row.id!,
              sourceNamespace: e.sourceNamespace,
              title: content.title,
              body: content.body,
              actionReference: content.actionReference,
              dueAt: e.dueAt,
              expiresAt: e.expiresAt,
            ),
          );
          if (items.length > pageSize) break;
        }
        after = rows.last.id;
      }
      await _authorize(
        actor,
        NotificationPermission.recover,
        tx,
        NotificationPhase.finalCheck,
      );
      // Expiry is checked again after the final host callback.
      final completedAt = await _now(tx);
      if (items.any((v) => !v.expiresAt.isAfter(completedAt))) {
        throw _failure(NotificationFailureCode.unavailable);
      }
      String? continuation;
      if (items.length > pageSize) {
        final expired = await NotificationCursorRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(actor.scopeKey) & (t.expiresAt <= completedAt),
          limit: _options.maxCursorsPerScope,
          transaction: tx,
        );
        if (expired.isNotEmpty) {
          await NotificationCursorRecord.db.delete(
            _session,
            expired,
            transaction: tx,
          );
        }
        if (await NotificationCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(actor.scopeKey),
              transaction: tx,
              limit: _options.maxCursorsPerScope,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(NotificationFailureCode.limitExceeded);
        }
        final random = Random.secure();
        continuation = base64UrlEncode(
          List.generate(32, (_) => random.nextInt(256)),
        ).replaceAll('=', '');
        await NotificationCursorRecord.db.insertRow(
          _session,
          NotificationCursorRecord(
            token: continuation,
            scopeKey: actor.scopeKey,
            principalId: actor.principalId,
            policyRevision: actor.policyRevision,
            recipientNamespace: actor.recipient.namespace,
            recipientKey: actor.recipient.key,
            afterId: items[pageSize - 1].id,
            pageSize: pageSize,
            expiresAt: completedAt.add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return NotificationPage(
        notifications: items.take(pageSize).toList(),
        nextCursor: continuation,
      );
    });
  }
}
