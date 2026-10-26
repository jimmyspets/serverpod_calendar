import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:crypto/crypto.dart';
import 'package:serverpod_calendar_core/serverpod_calendar_core.dart';
import 'package:serverpod_calendar_icalendar/serverpod_calendar_icalendar.dart';

import 'calendar_authorization.dart';
import 'alarm_values.dart';
import 'alarm_runtime.dart';
import 'scheduling_runtime.dart';
import 'alarm_work_store.dart';
import 'generated/protocol.dart';
import 'native_calendar_name.dart';
import 'event_values.dart';
import 'task_values.dart';
import 'task_source_values.dart';
import 'task_recurrence_values.dart';
import 'task_content_values.dart';
import 'event_protocol_values.dart';
import 'event_wire_storage.dart';
import 'event_wire_output.dart';
import 'availability_values.dart';
import 'availability_protocol_values.dart';
import 'availability_storage_values.dart';
import 'availability_wire_storage.dart';
import 'availability_wire_output.dart';
import 'availability_import_baseline.dart';

part 'calendar_publication.dart';
part 'calendar_alarms.dart';
part 'calendar_alarm_adoption.dart';
part 'calendar_alarm_actions.dart';
part 'calendar_alarm_worker.dart';
part 'calendar_events.dart';
part 'calendar_scheduling.dart';
part 'calendar_scheduling_bundle.dart';
part 'calendar_scheduling_worker.dart';
part 'calendar_event_occurrence_content.dart';
part 'calendar_tasks.dart';
part 'calendar_task_occurrences.dart';
part 'calendar_task_occurrence_content.dart';
part 'calendar_event_import.dart';
part 'calendar_task_import.dart';
part 'calendar_task_export.dart';
part 'calendar_task_replace.dart';
part 'calendar_event_export.dart';
part 'calendar_event_replace.dart';
part 'calendar_free_busy.dart';
part 'calendar_availability_search.dart';
part 'calendar_availability.dart';
part 'calendar_availability_import.dart';
part 'calendar_availability_export.dart';
part 'calendar_availability_replace.dart';

/// Configuration is per Serverpod instance, never an allow-decision cache.
abstract final class CalendarModule {
  static final _installed = Expando<_Runtime>();
  static CalendarAuthorizationGuarantee? publicationGuarantee(
    Serverpod pod,
    CalendarDependencyProvider dependency,
  ) {
    final runtime = _installed[pod];
    return runtime != null && runtime.dependencies.contains(dependency)
        ? runtime.publicationPolicy?.guarantee
        : null;
  }

  static void install(
    Serverpod pod, {
    required CalendarHostPolicy policy,
    required CalendarModuleOptions options,
    CalendarAlarmRuntime? alarms,
    CalendarSchedulingRuntime? scheduling,
    CalendarPublicationPolicy? publicationPolicy,
    List<CalendarDependencyProvider> dependencies = const [],
    List<CalendarAvailabilityExtensionRegistration> availabilityExtensions =
        const [],
  }) {
    for (final n in [
      options.maxPageSize,
      options.maxScannedCalendars,
      options.maxScannedEvents,
      options.maxScannedTasks,
      options.policyBatchSize,
      options.maxAssociations,
      options.maxCursorsPerScope,
    ]) {
      if (n < 1 || n > 10000) throw ArgumentError('Invalid calendar limit');
    }
    if (dependencies.length > 16 ||
        options.policyTimeout <= Duration.zero ||
        options.policyTimeout > const Duration(seconds: 30) ||
        options.cursorLifetime <= Duration.zero ||
        options.cursorLifetime > const Duration(hours: 1)) {
      throw ArgumentError('Invalid calendar configuration');
    }
    if (options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        policy.guarantee != CalendarAuthorizationGuarantee.coordinated) {
      throw ArgumentError('Host cannot supply required coordinated guarantee');
    }
    if (alarms != null &&
        options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        alarms.policy.guarantee != CalendarAuthorizationGuarantee.coordinated) {
      throw ArgumentError(
        'Alarm policy cannot supply required coordinated guarantee',
      );
    }
    if (publicationPolicy != null &&
        options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        publicationPolicy.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw ArgumentError(
        'Publication policy cannot supply required guarantee',
      );
    }
    if (scheduling != null &&
        options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        scheduling.host.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw ArgumentError('Scheduling host cannot supply required guarantee');
    }
    final registry = <String, CalendarAvailabilityExtensionRegistration>{};
    if (availabilityExtensions.length > 32) {
      throw ArgumentError('Too many extension registrations');
    }
    for (final registration in availabilityExtensions) {
      validateAvailabilityExtensionName(registration.name);
      if (registration.contexts.isEmpty ||
          registry.containsKey(registration.name.toUpperCase())) {
        throw ArgumentError('Invalid or duplicate extension registration');
      }
      registry[registration.name.toUpperCase()] = registration;
    }
    _installed[pod] = _Runtime(
      policy,
      options,
      List.unmodifiable(dependencies),
      Map.unmodifiable(registry),
      alarms,
      publicationPolicy,
      scheduling,
    );
  }

  /// Trusted bounded scheduling worker; no client or fabricated login.
  static Future<void> runSchedulingMaintenance(Session session) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.scheduling == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _SchedulingWorker(CalendarService._(session, runtime!)).run();
  }

  /// Trusted server maintenance entry point; never a client endpoint.
  static Future<void> runAlarmMaintenance(Session session) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.alarms == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _AlarmWorker(CalendarService._(session, runtime!)).run();
  }

  /// Delivery modules revalidate stored source references before each retry.
  static Future<bool> validateAlarmDelivery(
    Session session,
    CalendarAlarmDeliveryIntent intent,
  ) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.alarms == null) return false;
    return _AlarmWorker(CalendarService._(session, runtime!))
        .validateDelivery(intent);
  }

  static Future<CalendarAlarmDeliveryCheck> checkAlarmDelivery(
    Session session,
    CalendarAlarmDeliveryIntent intent, {
    bool forProjection = false,
  }) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.alarms == null) return CalendarAlarmDeliveryCheck.unavailable;
    return _AlarmWorker(CalendarService._(session, runtime!)).checkDelivery(
      intent,
      operation: forProjection
          ? CalendarAlarmBackgroundOperation.project
          : CalendarAlarmBackgroundOperation.dispatch,
    );
  }

  /// Explicit recipient projection authority is additional to dispatch authority.
  static Future<CalendarAlarmNotificationPresentation?>
  projectAlarmNotification(
    Session session,
    CalendarAlarmDeliveryIntent intent,
  ) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.alarms == null) return null;
    return _AlarmWorker(CalendarService._(session, runtime!))
        .projectNotification(intent);
  }

  /// Trusted optional-module port. This is never an RPC endpoint.
  /// Every selected source is authorized by the installed publication policy.
  static Future<T> publicationTransaction<T>(
    Session session,
    String scopeKey,
    Future<T> Function(CalendarPublicationTransaction) action,
  ) async {
    final runtime = _installed[session.serverpod];
    if (runtime?.publicationPolicy == null) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final service = CalendarService._(session, runtime!);
    service._opaque(scopeKey);
    return service._scopeTransaction(scopeKey, (tx, _) async {
      final publication = CalendarPublicationTransaction._(
        service,
        scopeKey,
        tx,
      );
      try {
        final result = await action(publication);
        for (final check in publication._checks) {
          await publication._authorize(check, finalCheck: true);
        }
        return result;
      } finally {
        publication._open = false;
      }
    });
  }

  static CalendarService service(Session session) {
    final runtime = _installed[session.serverpod];
    if (runtime == null || session.authenticated == null) {
      throw _failure(CalendarFailureCode.accessDenied);
    }
    return CalendarService._(session, runtime);
  }
}

CalendarException _failure(CalendarFailureCode code) => CalendarException(
  code: code,
  message: switch (code) {
    CalendarFailureCode.validation => 'Invalid calendar request.',
    CalendarFailureCode.accessDenied => 'Calendar operation is not permitted.',
    CalendarFailureCode.staleRevision => 'Calendar revision has changed.',
    CalendarFailureCode.dependencyConflict =>
      'Calendar change has active dependencies or conflicts.',
    CalendarFailureCode.limitExceeded =>
      'Calendar operation exceeds its work limit.',
    CalendarFailureCode.invalidCursor =>
      'Calendar continuation is no longer valid; restart the query.',
    _ => 'Calendar operation is temporarily unavailable.',
  },
);

final class _Runtime {
  _Runtime(
    this.policy,
    this.options,
    this.dependencies,
    this.availabilityExtensions,
    this.alarms,
    this.publicationPolicy,
    this.scheduling,
  );
  final Map<String, CalendarAvailabilityExtensionRegistration>
  availabilityExtensions;
  final CalendarSchedulingRuntime? scheduling;
  final CalendarAlarmRuntime? alarms;
  final CalendarPublicationPolicy? publicationPolicy;
  final CalendarHostPolicy policy;
  final CalendarModuleOptions options;
  final List<CalendarDependencyProvider> dependencies;
}

/// Every entry point resolves trusted context and enforces policy itself.
final class CalendarService {
  CalendarService._(this._session, this._runtime);
  final Session _session;
  final _Runtime _runtime;
  CalendarModuleOptions get _options => _runtime.options;
  static const _maxRevision = 9007199254740991;

  Future<T> _bounded<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(_options.policyTimeout);
    } on CalendarException {
      rethrow;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  void _opaque(String value, {int maxUtf8Bytes = 512}) {
    try {
      validateCalendarOpaqueText(value, maxUtf8Bytes: maxUtf8Bytes);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  Future<CalendarHostContext> _context() async {
    final c = await _bounded(() => _runtime.policy.resolveContext(_session));
    for (final s in [c.principalId, c.scopeKey, c.policyRevision]) {
      _opaque(s);
    }
    return c;
  }

  Future<void> _verifyContext(CalendarHostContext c) async {
    final now = await _context();
    if (c.principalId != now.principalId ||
        c.scopeKey != now.scopeKey ||
        c.policyRevision != now.policyRevision) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }

  Future<Map<String, CalendarAuthorizationDecision>> _decide(
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
    CalendarAuthorizationPhase phase, {
    bool filterDenied = false,
  }) async {
    if (requests.length > _options.policyBatchSize) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final expected = requests.map((r) => r.key).toSet();
    if (expected.length != requests.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    final decisions = await _bounded(
      () => _runtime.policy.authorizeBatch(
        _session,
        c,
        List.unmodifiable(requests),
        tx,
        phase,
      ),
    );
    final result = <String, CalendarAuthorizationDecision>{};
    for (final d in decisions) {
      if (!expected.contains(d.key) || result.containsKey(d.key)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      result[d.key] = d;
    }
    if (result.length != expected.length) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    for (final d in result.values) {
      if (d.verdict == CalendarAuthorizationVerdict.unavailable) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (!filterDenied && d.verdict != CalendarAuthorizationVerdict.allow) {
        throw _failure(CalendarFailureCode.accessDenied);
      }
    }
    return result;
  }

  Future<Map<String, CalendarAuthorizationDecision>> _final(
    CalendarHostContext c,
    List<CalendarAuthorizationRequest> requests,
    Transaction tx,
  ) async {
    if (_options.requiredWriteGuarantee ==
            CalendarAuthorizationGuarantee.coordinated &&
        _runtime.policy.guarantee !=
            CalendarAuthorizationGuarantee.coordinated) {
      throw _failure(CalendarFailureCode.unavailable);
    }
    await _verifyContext(c);
    return _decide(c, requests, tx, CalendarAuthorizationPhase.finalWrite);
  }

  /// Scope-row locking serializes this first bounded API across processes.
  /// Policy coordination is a distinct host responsibility, not this data lock.
  Future<T> _transaction<T>(
    CalendarHostContext c,
    Future<T> Function(Transaction, CalendarScopeRecord) action,
  ) => _scopeTransaction(c.scopeKey, action);
  Future<T> _scopeTransaction<T>(
    String scopeKey,
    Future<T> Function(Transaction, CalendarScopeRecord) action,
  ) => _session.db.transaction((tx) async {
    await CalendarScopeRecord.db.insert(
      _session,
      [CalendarScopeRecord(scopeKey: scopeKey, revision: 1)],
      transaction: tx,
      ignoreConflicts: true,
      noReturn: true,
    );
    final scope = await CalendarScopeRecord.db.findFirstRow(
      _session,
      where: (t) => t.scopeKey.equals(scopeKey),
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (scope == null) throw _failure(CalendarFailureCode.unavailable);
    return action(tx, scope);
  });
  // Shared database time avoids ordering changes from independent host clocks.
  // Revisions distinguish writes within one second and during clock correction.
  Future<DateTime> _revisionTime(Transaction tx, {DateTime? previous}) async {
    final rows = await _session.db.unsafeQuery(
      'SELECT clock_timestamp()',
      transaction: tx,
    );
    final now = (rows.single.single as DateTime).toUtc();
    return previous != null && now.isBefore(previous) ? previous.toUtc() : now;
  }

  Future<void> _bump(
    CalendarScopeRecord scope,
    Transaction tx, {
    UuidValue? publishedEventCalendar,
  }) async {
    if (scope.revision >= _maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    if (publishedEventCalendar != null) {
      for (final observer
          in _runtime.dependencies
              .whereType<CalendarPublicationChangeObserver>()) {
        await _bounded(
          () => observer.eventsChanged(
            _session,
            scope.scopeKey,
            publishedEventCalendar,
            tx,
          ),
        );
      }
    }
    // A shared write records durable wake-up/invalidation in this transaction.
    // Private definitions never block it through recipient policy or list caps.
    await _session.db.unsafeExecute(
      'UPDATE serverpod_calendar_alarm_plan SET dirty=true, '
      '"nextScanAt"=clock_timestamp(), "leaseOwner"=NULL, "leaseUntil"=NULL, '
      '"leaseFence"=CASE WHEN "leaseFence"<9007199254740991 THEN "leaseFence"+1 ELSE "leaseFence" END WHERE "scopeKey"=@scope',
      parameters: QueryParameters.named({'scope': scope.scopeKey}),
      transaction: tx,
    );
    scope.revision++;
    await CalendarScopeRecord.db.updateRow(_session, scope, transaction: tx);
  }

  Future<CalendarIdentityRecord> _identityInScope(
    String scopeKey,
    UuidValue id,
    Transaction tx,
  ) async {
    final row = await CalendarIdentityRecord.db.findFirstRow(
      _session,
      where: (t) =>
          t.id.equals(id) &
          t.scopeKey.equals(scopeKey) &
          t.deletedAt.equals(null),
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    if (row == null) throw _failure(CalendarFailureCode.accessDenied);
    return row;
  }

  Future<_Active> _active(
    CalendarHostContext c,
    UuidValue id,
    Transaction tx,
  ) => _activeInScope(c.scopeKey, id, tx);
  Future<_Active> _activeInScope(
    String scopeKey,
    UuidValue id,
    Transaction tx,
  ) async {
    final identity = await _identityInScope(scopeKey, id, tx);
    final data = await CalendarDataRecord.db.findFirstRow(
      _session,
      where: (t) => t.calendarId.equals(id),
      transaction: tx,
    );
    if (data == null) throw _failure(CalendarFailureCode.unavailable);
    final links = await CalendarSubjectRecord.db.find(
      _session,
      where: (t) => t.calendarId.equals(id),
      transaction: tx,
      orderBy: (t) => t.id,
      limit: _options.maxAssociations + 1,
    );
    if (links.length > _options.maxAssociations) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    return _Active(identity, data, links);
  }

  CalendarAuthorizationRequest _request(
    CalendarPermission op,
    _Active active, {
    CalendarProposedChange? proposed,
    Set<CalendarFieldGroup> groups = const {},
    CalendarCategoryQuery? categoryFilter,
  }) => CalendarAuthorizationRequest(
    key: active.identity.id.toString(),
    operation: op,
    calendarId: active.identity.id,
    current: active.snapshot,
    proposed: proposed,
    requestedGroups: groups,
    categoryFilter: categoryFilter,
  );
  void _revision(_Active a, int expected) {
    if (expected < 1 || expected > _maxRevision) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (a.identity.revision != expected) {
      throw _failure(CalendarFailureCode.staleRevision);
    }
    if (expected == _maxRevision) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
  }

  String _name(String value) {
    try {
      return normalizeCalendarDisplayName(value);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  void _zone(String value) {
    if (value.length > 255 || !NamedZoneResolver().zoneIds.contains(value)) {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  Set<CalendarFieldGroup> _groups(List<CalendarFieldGroup> groups) {
    if (groups.length > CalendarFieldGroup.values.length) {
      throw _failure(CalendarFailureCode.validation);
    }
    return Set.unmodifiable(groups.toSet());
  }

  CalendarView _view(
    _Active a,
    Set<CalendarFieldGroup> requested,
    CalendarAuthorizationDecision decision,
  ) {
    final groups = requested.intersection(decision.disclosedGroups).toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final metadata = groups.contains(CalendarFieldGroup.metadata);
    final settings = groups.contains(CalendarFieldGroup.availabilitySettings);
    return CalendarView(
      id: a.identity.id!,
      revision: a.identity.revision,
      disclosedGroups: groups,
      displayName: metadata ? a.data.displayName : null,
      description: metadata ? a.data.description : null,
      color: metadata ? a.data.color : null,
      supplementalMetadata:
          groups.contains(CalendarFieldGroup.supplementalMetadata)
          ? _supplementalModel(a.supplementalMetadata)
          : null,
      protocolIdentity: groups.contains(CalendarFieldGroup.protocolIdentity)
          ? a.protocolIdentity
          : null,
      protocolMetadata: groups.contains(CalendarFieldGroup.protocolMetadata)
          ? _protocolModel(a.protocolMetadata)
          : null,
      createdAt: metadata ? a.data.createdAt : null,
      updatedAt: metadata ? a.data.updatedAt : null,
      availabilityZoneId: settings ? a.data.availabilityZoneId : null,
      noRuleFallback: settings ? a.data.noRuleFallback : null,
    );
  }

  CalendarMutationReceipt? _receipt(
    UuidValue id,
    int revision,
    bool deleted,
    Iterable<CalendarAuthorizationDecision> decisions,
  ) => decisions.every((d) => d.discloseMutationReceipt)
      ? CalendarMutationReceipt(
          calendarId: id,
          revision: revision,
          deleted: deleted,
        )
      : null;

  Future<CalendarMutationReceipt?> create(CalendarCreateRequest input) async {
    // Generated requests are mutable; hold a private validated command snapshot.
    input = input.copyWith();
    final c = await _context();
    final name = _name(input.displayName);
    final description = _description(input.description);
    final color = _color(input.color);
    _zone(input.availabilityZoneId);
    final request = CalendarAuthorizationRequest(
      key: 'create',
      operation: CalendarPermission.create,
      proposed: CalendarProposedChange(
        displayName: name,
        presentation: CalendarPresentationIntent(name, description, color),
        availabilityZoneId: input.availabilityZoneId,
        noRuleFallback: input.noRuleFallback,
      ),
    );
    return _transaction(c, (tx, scope) async {
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      final decisions = await _final(c, [request], tx);
      final now = await _revisionTime(tx);
      final identity = await CalendarIdentityRecord.db.insertRow(
        _session,
        CalendarIdentityRecord(scopeKey: c.scopeKey, revision: 1),
        transaction: tx,
      );
      await CalendarDataRecord.db.insertRow(
        _session,
        CalendarDataRecord(
          calendarId: identity.id!,
          displayName: name,
          description: description,
          color: color,
          availabilityZoneId: input.availabilityZoneId,
          noRuleFallback: input.noRuleFallback,
          createdAt: now,
          updatedAt: now,
        ),
        transaction: tx,
      );
      await _bump(scope, tx);
      return _receipt(identity.id!, 1, false, decisions.values);
    });
  }

  Future<CalendarView> get(
    UuidValue id,
    List<CalendarFieldGroup> fieldGroups,
  ) async {
    final c = await _context();
    final groups = _groups(fieldGroups);
    return _transaction(c, (tx, _) async {
      final a = await _active(c, id, tx);
      final request = _request(CalendarPermission.read, a, groups: groups);
      final decisions = await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _verifyContext(c);
      return _view(a, groups, decisions[request.key]!);
    });
  }

  Future<CalendarMutationReceipt?> updateMetadata(
    CalendarMetadataUpdateRequest input,
  ) async {
    // Generated requests are mutable; hold a private validated command snapshot.
    input = input.copyWith();
    final c = await _context();
    final name = _name(input.displayName);
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, input.calendarId, tx);
      final request = _request(
        CalendarPermission.updateMetadata,
        a,
        proposed: CalendarProposedChange(displayName: name),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, input.expectedRevision);
      final decisions = await _final(c, [request], tx);
      a.data.displayName = name;
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<CalendarMutationReceipt?> updatePresentation(
    CalendarPresentationUpdateRequest input,
  ) async {
    input = input.copyWith();
    final name = _name(input.displayName);
    final description = _description(input.description);
    final color = _color(input.color);
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, input.calendarId, tx);
      final request = _request(
        CalendarPermission.updateMetadata,
        a,
        proposed: CalendarProposedChange(
          displayName: name,
          presentation: CalendarPresentationIntent(name, description, color),
        ),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, input.expectedRevision);
      final decisions = await _final(c, [request], tx);
      a.data.displayName = name;
      a.data.description = description;
      a.data.color = color;
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<CalendarMutationReceipt?> updateProtocolMetadata(
    CalendarProtocolMetadataUpdateRequest input,
  ) async {
    // Freeze nested lists and values before any asynchronous policy callback.
    final id = input.calendarId;
    final expectedRevision = input.expectedRevision;
    late final IcalendarCalendarTextMetadata metadata;
    try {
      metadata = _protocolValue(input.metadata);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, id, tx);
      final request = _request(
        CalendarPermission.updateProtocolMetadata,
        a,
        proposed: CalendarProposedChange(protocolMetadata: metadata),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, expectedRevision);
      final decisions = await _final(c, [request], tx);
      a.data.protocolMetadata = metadata.isEmpty
          ? null
          : _protocolModel(metadata);
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<CalendarMutationReceipt?> updateSupplementalMetadata(
    CalendarSupplementalMetadataUpdateRequest input,
  ) async {
    final id = input.calendarId;
    final expected = input.expectedRevision;
    late final IcalendarSupplementalMetadata value;
    try {
      value = _supplementalValue(input.metadata);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, id, tx);
      final request = _request(
        CalendarPermission.updateSupplementalMetadata,
        a,
        proposed: CalendarProposedChange(supplementalMetadata: value),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, expected);
      final decisions = await _final(c, [request], tx);
      a.data.supplementalMetadata = value.isEmpty
          ? null
          : _supplementalModel(value);
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<CalendarMutationReceipt?> _saveMetadata(
    _Active a,
    CalendarScopeRecord scope,
    Transaction tx,
    Iterable<CalendarAuthorizationDecision> decisions,
  ) async {
    a.data.updatedAt = await _revisionTime(tx, previous: a.data.updatedAt);
    a.identity.revision++;
    await CalendarDataRecord.db.updateRow(_session, a.data, transaction: tx);
    await CalendarIdentityRecord.db.updateRow(
      _session,
      a.identity,
      transaction: tx,
    );
    await _bump(scope, tx);
    return _receipt(a.identity.id!, a.identity.revision, false, decisions);
  }

  String? _description(String? value) {
    try {
      return normalizeCalendarDescription(value);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  String? _color(String? value) {
    try {
      return normalizeCalendarNativeColor(value);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
  }

  Future<CalendarMutationReceipt?> updateSettings(
    CalendarSettingsUpdateRequest input,
  ) async {
    // Generated requests are mutable; hold a private validated command snapshot.
    input = input.copyWith();
    final c = await _context();
    _zone(input.availabilityZoneId);
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, input.calendarId, tx);
      final request = _request(
        CalendarPermission.updateAvailabilitySettings,
        a,
        proposed: CalendarProposedChange(
          availabilityZoneId: input.availabilityZoneId,
          noRuleFallback: input.noRuleFallback,
        ),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, input.expectedRevision);
      final decisions = await _final(c, [request], tx);
      a.data.availabilityZoneId = input.availabilityZoneId;
      a.data.noRuleFallback = input.noRuleFallback;
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<List<CalendarSubjectView>> subjects(UuidValue id) async {
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final a = await _active(c, id, tx);
      await _decide(
        c,
        [_request(CalendarPermission.readAssociations, a)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      await _verifyContext(c);
      return [
        for (final s in a.links)
          CalendarSubjectView(
            namespace: s.namespace,
            kind: s.kind,
            externalId: s.externalId,
            contributesAvailability: s.contributesAvailability,
          ),
      ];
    });
  }

  Future<CalendarMutationReceipt?> changeSubject(
    CalendarSubjectChangeRequest input,
  ) async {
    // Generated requests are mutable; hold a private validated command snapshot.
    input = input.copyWith();
    final c = await _context();
    _opaque(input.namespace, maxUtf8Bytes: 128);
    _opaque(input.kind, maxUtf8Bytes: 64);
    _opaque(input.externalId, maxUtf8Bytes: 512);
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, input.calendarId, tx);
      final intent = CalendarSubjectIntent(
        input.action,
        CalendarSubjectReference(input.namespace, input.kind, input.externalId),
        input.contributesAvailability,
      );
      final request = _request(
        CalendarPermission.changeAssociations,
        a,
        proposed: CalendarProposedChange(subject: intent),
      );
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, input.expectedRevision);
      final matching = a.links
          .where(
            (s) =>
                s.namespace == input.namespace &&
                s.kind == input.kind &&
                s.externalId == input.externalId,
          )
          .toList();
      if ((input.action == CalendarSubjectAction.attach &&
              matching.isNotEmpty) ||
          (input.action != CalendarSubjectAction.attach && matching.isEmpty)) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      if (input.action == CalendarSubjectAction.attach &&
          a.links.length >= _options.maxAssociations) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      final decisions = await _final(c, [request], tx);
      switch (input.action) {
        case CalendarSubjectAction.attach:
          await CalendarSubjectRecord.db.insertRow(
            _session,
            CalendarSubjectRecord(
              calendarId: input.calendarId,
              namespace: input.namespace,
              kind: input.kind,
              externalId: input.externalId,
              contributesAvailability: input.contributesAvailability,
            ),
            transaction: tx,
          );
        case CalendarSubjectAction.detach:
          await CalendarSubjectRecord.db.deleteRow(
            _session,
            matching.single,
            transaction: tx,
          );
        case CalendarSubjectAction.setContribution:
          matching.single.contributesAvailability =
              input.contributesAvailability;
          await CalendarSubjectRecord.db.updateRow(
            _session,
            matching.single,
            transaction: tx,
          );
      }
      return _saveMetadata(a, scope, tx, decisions.values);
    });
  }

  Future<CalendarMutationReceipt?> delete(
    UuidValue id,
    int expectedRevision,
  ) async {
    final c = await _context();
    return _transaction(c, (tx, scope) async {
      final a = await _active(c, id, tx);
      final request = _request(CalendarPermission.delete, a);
      await _decide(
        c,
        [request],
        tx,
        CalendarAuthorizationPhase.preliminaryWrite,
      );
      _revision(a, expectedRevision);
      if (a.links.isNotEmpty ||
          await CalendarAvailabilityRecord.db.count(
                _session,
                where: (t) =>
                    t.calendarId.equals(id) & t.deletedAt.equals(null),
                transaction: tx,
                limit: 1,
              ) >
              0 ||
          await CalendarTaskRecord.db.count(
                _session,
                where: (t) =>
                    t.calendarId.equals(id) & t.deletedAt.equals(null),
                transaction: tx,
                limit: 1,
              ) >
              0 ||
          await CalendarEventRecord.db.count(
                _session,
                where: (t) =>
                    t.calendarId.equals(id) & t.deletedAt.equals(null),
                transaction: tx,
                limit: 1,
              ) >
              0) {
        throw _failure(CalendarFailureCode.dependencyConflict);
      }
      for (final dependency in _runtime.dependencies) {
        if (await _bounded(
          () => dependency.hasActiveDependencies(_session, id, tx),
        )) {
          throw _failure(CalendarFailureCode.dependencyConflict);
        }
      }
      final decisions = await _final(c, [request], tx);
      await CalendarDataRecord.db.deleteRow(_session, a.data, transaction: tx);
      a.identity.revision++;
      a.identity.deletedAt = DateTime.now().toUtc();
      await CalendarIdentityRecord.db.updateRow(
        _session,
        a.identity,
        transaction: tx,
      );
      await _bump(scope, tx);
      return _receipt(id, a.identity.revision, true, decisions.values);
    });
  }

  Future<CalendarPage> list({
    required int pageSize,
    required List<CalendarFieldGroup> fieldGroups,
    String? cursor,
    CalendarCategoryFilter? categoryFilter,
  }) async {
    IcalendarCategory? filter;
    try {
      if (categoryFilter != null) {
        filter = IcalendarCategory(
          categoryFilter.value,
          language: categoryFilter.language,
        );
      }
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    final queryFilter = filter == null
        ? null
        : CalendarCategoryQuery(filter.value, filter.language);
    final c = await _context();
    final groups = _groups(fieldGroups);
    final evaluationGroups = Set<CalendarFieldGroup>.unmodifiable({
      ...groups,
      if (filter != null) CalendarFieldGroup.supplementalMetadata,
    });
    if (pageSize < 1 || pageSize > _options.maxPageSize) {
      throw _failure(CalendarFailureCode.validation);
    }
    if (cursor != null && !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
      throw _failure(CalendarFailureCode.invalidCursor);
    }
    return _transaction(c, (tx, scope) async {
      final query = CalendarAuthorizationRequest(
        key: 'query',
        operation: CalendarPermission.list,
        requestedGroups: evaluationGroups,
        categoryFilter: queryFilter,
      );
      await _decide(c, [query], tx, CalendarAuthorizationPhase.read);
      final plan = await _bounded(
        () => _runtime.policy.planQuery(
          _session,
          c,
          evaluationGroups,
          categoryFilter: queryFilter,
        ),
      );
      if (plan.calendarIds != null &&
          plan.calendarIds!.length > _options.maxScannedCalendars) {
        throw _failure(CalendarFailureCode.limitExceeded);
      }
      UuidValue? after;
      final canonicalGroups = groups.toList()
        ..sort((a, b) => a.index.compareTo(b.index));
      if (cursor != null) {
        final saved = await CalendarCursorRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.token.equals(cursor) &
              t.scopeKey.equals(c.scopeKey) &
              t.principalId.equals(c.principalId),
          transaction: tx,
        );
        if (saved == null ||
            saved.alarmActivityId != null ||
            saved.alarmActivityKind != null ||
            saved.taskHistoryTaskId != null ||
            saved.taskHistoryOriginalKey != null ||
            saved.taskHistoryAfterRevision != null ||
            saved.taskCalendarId != null ||
            saved.taskFieldGroups != null ||
            saved.eventCalendarId != null ||
            saved.eventFieldGroups != null ||
            !saved.expiresAt.isAfter(DateTime.now().toUtc()) ||
            saved.policyRevision != c.policyRevision ||
            saved.dataRevision != scope.revision ||
            saved.pageSize != pageSize ||
            !_sameCategoryFilter(saved.categoryFilter, filter) ||
            saved.fieldGroups.length != canonicalGroups.length ||
            !Iterable<int>.generate(canonicalGroups.length)
                .every((i) => saved.fieldGroups[i] == canonicalGroups[i])) {
          throw _failure(CalendarFailureCode.invalidCursor);
        }
        after = saved.afterId;
      }
      final visible = <CalendarView>[];
      var scanned = 0;
      while (visible.length <= pageSize) {
        final remaining = _options.maxScannedCalendars - scanned;
        final rows = await CalendarIdentityRecord.db.find(
          _session,
          where: (t) {
            var predicate =
                t.scopeKey.equals(c.scopeKey) & t.deletedAt.equals(null);
            if (after != null) predicate = predicate & (t.id > after);
            if (plan.calendarIds != null) {
              predicate = predicate & t.id.inSet(plan.calendarIds!);
            }
            return predicate;
          },
          orderBy: (t) => t.id,
          transaction: tx,
          limit: min(_options.policyBatchSize, remaining + 1),
        );
        if (rows.isEmpty) break;
        if (rows.length > remaining) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        scanned += rows.length;
        final active = <_Active>[];
        for (final row in rows) {
          active.add(await _active(c, row.id!, tx));
        }
        final requests = [
          for (final a in active)
            _request(
              CalendarPermission.read,
              a,
              groups: evaluationGroups,
              categoryFilter: queryFilter,
            ),
        ];
        final decisions = await _decide(
          c,
          requests,
          tx,
          CalendarAuthorizationPhase.read,
          filterDenied: true,
        );
        for (final a in active) {
          final d = decisions[a.identity.id.toString()]!;
          if (d.verdict == CalendarAuthorizationVerdict.allow &&
              (filter == null ||
                  (d.disclosedGroups.contains(
                        CalendarFieldGroup.supplementalMetadata,
                      ) &&
                      a.supplementalMetadata.categories.any(
                        (v) => v.matches(filter!),
                      )))) {
            visible.add(_view(a, groups, d));
          }
          if (visible.length > pageSize) break;
        }
        after = rows.last.id;
        if (visible.length > pageSize) break;
      }
      await _verifyContext(c);
      String? continuation;
      if (visible.length > pageSize) {
        final expired = await CalendarCursorRecord.db.find(
          _session,
          where: (t) =>
              t.scopeKey.equals(c.scopeKey) &
              (t.expiresAt < DateTime.now().toUtc()),
          transaction: tx,
          limit: _options.maxCursorsPerScope,
        );
        if (expired.isNotEmpty) {
          await CalendarCursorRecord.db.delete(
            _session,
            expired,
            transaction: tx,
          );
        }
        if (await CalendarCursorRecord.db.count(
              _session,
              where: (t) => t.scopeKey.equals(c.scopeKey),
              transaction: tx,
              limit: _options.maxCursorsPerScope,
            ) >=
            _options.maxCursorsPerScope) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final random = Random.secure();
        continuation = base64UrlEncode(
          List.generate(32, (_) => random.nextInt(256)),
        ).replaceAll('=', '');
        await CalendarCursorRecord.db.insertRow(
          _session,
          CalendarCursorRecord(
            token: continuation,
            scopeKey: c.scopeKey,
            principalId: c.principalId,
            policyRevision: c.policyRevision,
            dataRevision: scope.revision,
            afterId: visible[pageSize - 1].id,
            pageSize: pageSize,
            categoryFilter: filter == null
                ? null
                : CalendarCategoryFilter(
                    value: filter.value,
                    language: filter.language,
                  ),
            fieldGroups: canonicalGroups,
            expiresAt: DateTime.now().toUtc().add(_options.cursorLifetime),
          ),
          transaction: tx,
        );
      }
      return CalendarPage(
        calendars: visible.take(pageSize).toList(),
        nextCursor: continuation,
      );
    });
  }
}

final class _Active {
  _Active(this.identity, this.data, this.links) {
    try {
      supplementalMetadata = data.supplementalMetadata == null
          ? IcalendarSupplementalMetadata()
          : _supplementalValue(data.supplementalMetadata!);
      protocolMetadata = data.protocolMetadata == null
          ? IcalendarCalendarTextMetadata()
          : _protocolValue(data.protocolMetadata!);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
  CalendarProtocolIdentity get protocolIdentity {
    final utc = data.updatedAt.toUtc();
    return CalendarProtocolIdentity(
      uid: data.protocolUid.toString(),
      lastModified: DateTime.utc(
        utc.year,
        utc.month,
        utc.day,
        utc.hour,
        utc.minute,
        utc.second,
      ),
    );
  }

  late final IcalendarCalendarTextMetadata protocolMetadata;
  late final IcalendarSupplementalMetadata supplementalMetadata;
  final CalendarIdentityRecord identity;
  final CalendarDataRecord data;
  final List<CalendarSubjectRecord> links;
  CalendarPolicySnapshot get snapshot => CalendarPolicySnapshot(
    calendarId: identity.id!,
    revision: identity.revision,
    displayName: data.displayName,
    description: data.description,
    color: data.color,
    protocolIdentity: protocolIdentity,
    protocolMetadata: protocolMetadata,
    supplementalMetadata: supplementalMetadata,
    availabilityZoneId: data.availabilityZoneId,
    noRuleFallback: data.noRuleFallback,
    subjects: links.map(
      (s) => CalendarPolicySubject(
        CalendarSubjectReference(s.namespace, s.kind, s.externalId),
        s.contributesAvailability,
      ),
    ),
  );
}

IcalendarCalendarTextMetadata _protocolValue(CalendarProtocolMetadata model) =>
    IcalendarCalendarTextMetadata(
      names: model.names.map(
        (v) => IcalendarTextVariant(v.value, language: v.language),
      ),
      descriptions: model.descriptions.map(
        (v) => IcalendarTextVariant(v.value, language: v.language),
      ),
      color: model.color,
    );
CalendarProtocolMetadata _protocolModel(IcalendarCalendarTextMetadata value) =>
    CalendarProtocolMetadata(
      names: [
        for (final v in value.names)
          CalendarTextVariant(value: v.value, language: v.language),
      ],
      descriptions: [
        for (final v in value.descriptions)
          CalendarTextVariant(value: v.value, language: v.language),
      ],
      color: value.color,
    );

bool _sameCategoryFilter(
  CalendarCategoryFilter? stored,
  IcalendarCategory? value,
) =>
    stored?.value == value?.value &&
    stored?.language?.toLowerCase() == value?.language?.toLowerCase();
IcalendarSupplementalMetadata _supplementalValue(
  CalendarSupplementalMetadata v,
) => IcalendarSupplementalMetadata(
  url: v.url,
  categories: v.categories.map(
    (c) => IcalendarCategory(c.value, language: c.language),
  ),
  images: v.images.map(
    (i) =>
        IcalendarImageLink(i.uri, display: i.display, mediaType: i.mediaType),
  ),
  refreshHint: v.refreshHint == null
      ? null
      : IcalendarRefreshHint(
          weeks: v.refreshHint!.weeks,
          days: v.refreshHint!.days,
          hours: v.refreshHint!.hours,
          minutes: v.refreshHint!.minutes,
          seconds: v.refreshHint!.seconds,
        ),
);
CalendarSupplementalMetadata _supplementalModel(
  IcalendarSupplementalMetadata v,
) => CalendarSupplementalMetadata(
  url: v.url,
  categories: [
    for (final c in v.categories)
      CalendarCategory(value: c.value, language: c.language),
  ],
  images: [
    for (final i in v.images)
      CalendarImageLink(
        uri: i.uri,
        display: i.display?.toList(),
        mediaType: i.mediaType,
      ),
  ],
  refreshHint: v.refreshHint == null
      ? null
      : CalendarRefreshHint(
          weeks: v.refreshHint!.duration.weeks,
          days: v.refreshHint!.duration.days,
          hours: v.refreshHint!.duration.hours,
          minutes: v.refreshHint!.duration.minutes,
          seconds: v.refreshHint!.duration.seconds,
        ),
);
