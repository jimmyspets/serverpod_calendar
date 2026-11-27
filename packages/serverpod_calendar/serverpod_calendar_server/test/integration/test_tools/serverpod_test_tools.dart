/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: no_leading_underscores_for_local_identifiers

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:io' as _idi;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_calendar_server/src/generated/calendar_category_filter.dart'
    as _ith8xeb5;
import 'package:serverpod_calendar_server/src/generated/calendar_create_request.dart'
    as _i287wpc6;
import 'package:serverpod_calendar_server/src/generated/calendar_event_create_request.dart'
    as _ixcfd9h0;
import 'package:serverpod_calendar_server/src/generated/calendar_event_field_group.dart'
    as _il5gdr09;
import 'package:serverpod_calendar_server/src/generated/calendar_event_occurrence_preview.dart'
    as _i2qqvmw2;
import 'package:serverpod_calendar_server/src/generated/calendar_event_occurrence_query.dart'
    as _i7o3kzld;
import 'package:serverpod_calendar_server/src/generated/calendar_event_page.dart'
    as _i092pg3q;
import 'package:serverpod_calendar_server/src/generated/calendar_event_receipt.dart'
    as _irjxy316;
import 'package:serverpod_calendar_server/src/generated/calendar_event_status_request.dart'
    as _ib916yyf;
import 'package:serverpod_calendar_server/src/generated/calendar_event_update_request.dart'
    as _iabs06xo;
import 'package:serverpod_calendar_server/src/generated/calendar_event_view.dart'
    as _i6zsydj7;
import 'package:serverpod_calendar_server/src/generated/calendar_field_group.dart'
    as _i3d02yxy;
import 'package:serverpod_calendar_server/src/generated/calendar_metadata_update_request.dart'
    as _io29vhgw;
import 'package:serverpod_calendar_server/src/generated/calendar_mutation_receipt.dart'
    as _ied1lssg;
import 'package:serverpod_calendar_server/src/generated/calendar_page.dart'
    as _ibhixnze;
import 'package:serverpod_calendar_server/src/generated/calendar_presentation_update_request.dart'
    as _i1sjay6c;
import 'package:serverpod_calendar_server/src/generated/calendar_protocol_metadata_update_request.dart'
    as _i53ouodu;
import 'package:serverpod_calendar_server/src/generated/calendar_settings_update_request.dart'
    as _i3f5mgyk;
import 'package:serverpod_calendar_server/src/generated/calendar_subject_change_request.dart'
    as _ib1wmljm;
import 'package:serverpod_calendar_server/src/generated/calendar_subject_view.dart'
    as _iwx7nyid;
import 'package:serverpod_calendar_server/src/generated/calendar_supplemental_metadata_update_request.dart'
    as _ito4h8gf;
import 'package:serverpod_calendar_server/src/generated/calendar_view.dart'
    as _id91u9he;
import 'package:serverpod_test/serverpod_test.dart' as _ist;
import 'package:serverpod_calendar_server/src/generated/protocol.dart';
import 'package:serverpod_calendar_server/src/generated/endpoints.dart';
export 'package:serverpod_test/serverpod_test_public_exports.dart';

/// Creates a new test group that takes a callback that can be used to write tests.
/// The callback has two parameters: `sessionBuilder` and `endpoints`.
/// `sessionBuilder` is used to build a `Session` object that represents the server state during an endpoint call and is used to set up scenarios.
/// `endpoints` contains all your Serverpod endpoints and lets you call them:
/// ```dart
/// withServerpod('Given Example endpoint', (sessionBuilder, endpoints) {
///   test('when calling `hello` then should return greeting', () async {
///     final greeting = await endpoints.example.hello(sessionBuilder, 'Michael');
///     expect(greeting, 'Hello Michael');
///   });
/// });
/// ```
///
/// **Configuration options**
///
/// [applyMigrations] Whether pending migrations should be applied when starting Serverpod. Defaults to `true`
///
/// [enableSessionLogging] Whether session logging should be enabled. Defaults to `false`
///
/// [ephemeralDatabase] Whether this group gets its own empty database, created when the group starts and dropped when it finishes. Defaults to `true`.
/// Set this to `false` to use the database configured for [runMode], including a previously seeded database. [configOverride] can still replace that database. The configured database is not created or dropped, so groups that share it cannot run in parallel. [rollbackDatabase] still controls whether writes inside the group are rolled back.
///
/// [rollbackDatabase] Options for when to rollback the database during the test lifecycle.
/// By default `withServerpod` does all database operations inside a transaction that is rolled back after each `test` case.
/// Just like the following enum describes, the behavior of the automatic rollbacks can be configured:
/// ```dart
/// /// Options for when to rollback the database during the test lifecycle.
/// enum RollbackDatabase {
///   /// After each test. This is the default.
///   afterEach,
///
///   /// After all tests.
///   afterAll,
///
///   /// Disable rolling back the database.
///   disabled,
/// }
/// ```
///
/// [runMode] The run mode that Serverpod should be running in. Defaults to `test`.
///
/// [serverpodLoggingMode] The logging mode used when creating Serverpod. Defaults to `ServerpodLoggingMode.normal`
///
/// [serverpodStartTimeout] The timeout to use when starting Serverpod, which connects to the database among other things. Defaults to `Duration(seconds: 120)`.
///
/// [testServerOutputMode] Options for controlling test server output during test execution. Defaults to `TestServerOutputMode.normal`.
/// ```dart
/// /// Options for controlling test server output during test execution.
/// enum TestServerOutputMode {
///   /// Default mode - only stderr is printed (stdout suppressed).
///   /// This hides normal startup/shutdown logs while preserving error messages.
///   normal,
///
///   /// All logging - both stdout and stderr are printed.
///   /// Useful for debugging when you need to see all server output.
///   verbose,
///
///   /// No logging - both stdout and stderr are suppressed.
///   /// Completely silent mode, useful when you don't want any server output.
///   silent,
/// }
/// ```
///
/// [configOverride] A function to override the server configuration. This function is called with
/// the default server configuration after it is loaded from the config/ directory
/// and before it is used to start the server. Use this to override particular
/// settings in the server configuration.
///
/// [databaseInterceptor] Optional interceptor that replaces the default database for each session.
/// See [Serverpod.databaseInterceptor] for more information.
///
/// [testGroupTagsOverride] By default Serverpod test tools tags the `withServerpod` test group with `"integration"`.
/// This is to provide a simple way to only run unit or integration tests.
/// This property allows this tag to be overridden to something else. Defaults to `['integration']`.
///
/// [experimentalFeatures] Optionally specify experimental features. See [Serverpod] for more information.
///
/// [serverDirectory] The server package directory `config/<runMode>.yaml`, `config/passwords.yaml`,
/// and `migrations/<module>/...` are resolved against. Defaults to
/// [Directory.current] at the time the test boots. Pass this when the test
/// isolate's cwd is not the server package root (e.g. running tests from a
/// workspace parent directory) so config and migrations are still loaded
/// from the right place.
@_ist.isTestGroup
void withServerpod(
  String testGroupName,
  _ist.TestClosure<TestEndpoints> testClosure, {
  bool? applyMigrations,
  _is.ServerpodConfig Function(_is.ServerpodConfig)? configOverride,
  _is.DatabaseInterceptor? databaseInterceptor,
  bool? enableSessionLogging,
  bool? ephemeralDatabase,
  _is.ExperimentalFeatures? experimentalFeatures,
  _ist.RollbackDatabase? rollbackDatabase,
  String? runMode,
  _is.RuntimeParametersListBuilder? runtimeParametersBuilder,
  _idi.Directory? serverDirectory,
  _is.ServerpodLoggingMode? serverpodLoggingMode,
  Duration? serverpodStartTimeout,
  List<String>? testGroupTagsOverride,
  _ist.TestServerOutputMode? testServerOutputMode,
}) {
  _ist.buildWithServerpod<_InternalTestEndpoints>(
    testGroupName,
    _ist.TestServerpod(
      testEndpoints: _InternalTestEndpoints(),
      endpoints: Endpoints(),
      serializationManager: Protocol(),
      runMode: runMode,
      applyMigrations: applyMigrations,
      ephemeralDatabase: ephemeralDatabase,
      isDatabaseEnabled: true,
      serverpodLoggingMode: serverpodLoggingMode,
      testServerOutputMode: testServerOutputMode,
      serverDirectory: serverDirectory,
      experimentalFeatures: experimentalFeatures,
      configOverride: configOverride,
      runtimeParametersBuilder: runtimeParametersBuilder,
      databaseInterceptor: databaseInterceptor,
    ),
    maybeRollbackDatabase: rollbackDatabase,
    maybeEnableSessionLogging: enableSessionLogging,
    maybeTestGroupTagsOverride: testGroupTagsOverride,
    maybeServerpodStartTimeout: serverpodStartTimeout,
    maybeTestServerOutputMode: testServerOutputMode,
  )(testClosure);
}

class TestEndpoints {
  late final _CalendarDiagnosticsEndpoint calendarDiagnostics;

  late final _CalendarEndpoint calendar;

  late final _CalendarEventEndpoint calendarEvent;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    calendarDiagnostics = _CalendarDiagnosticsEndpoint(
      endpoints,
      serializationManager,
    );
    calendar = _CalendarEndpoint(
      endpoints,
      serializationManager,
    );
    calendarEvent = _CalendarEventEndpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _CalendarDiagnosticsEndpoint {
  _CalendarDiagnosticsEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<String> check(_ist.TestSessionBuilder sessionBuilder) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarDiagnostics',
            method: 'check',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarDiagnostics',
          methodName: 'check',
          parameters: _ist.testObjectToJson({}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<String>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _CalendarEndpoint {
  _CalendarEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> create(
    _ist.TestSessionBuilder sessionBuilder,
    _i287wpc6.CalendarCreateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'create',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_id91u9he.CalendarView> getCalendar(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId,
    List<_i3d02yxy.CalendarFieldGroup> fieldGroups,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'getCalendar',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'getCalendar',
          parameters: _ist.testObjectToJson({
            'calendarId': calendarId,
            'fieldGroups': fieldGroups,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_id91u9he.CalendarView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ibhixnze.CalendarPage> list(
    _ist.TestSessionBuilder sessionBuilder, {
    required int pageSize,
    required List<_i3d02yxy.CalendarFieldGroup> fieldGroups,
    String? cursor,
    _ith8xeb5.CalendarCategoryFilter? categoryFilter,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'list',
          parameters: _ist.testObjectToJson({
            'pageSize': pageSize,
            'fieldGroups': fieldGroups,
            'cursor': cursor,
            'categoryFilter': categoryFilter,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ibhixnze.CalendarPage>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> updateMetadata(
    _ist.TestSessionBuilder sessionBuilder,
    _io29vhgw.CalendarMetadataUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'updateMetadata',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'updateMetadata',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> updatePresentation(
    _ist.TestSessionBuilder sessionBuilder,
    _i1sjay6c.CalendarPresentationUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'updatePresentation',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'updatePresentation',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> updateProtocolMetadata(
    _ist.TestSessionBuilder sessionBuilder,
    _i53ouodu.CalendarProtocolMetadataUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'updateProtocolMetadata',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'updateProtocolMetadata',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> updateSupplementalMetadata(
    _ist.TestSessionBuilder sessionBuilder,
    _ito4h8gf.CalendarSupplementalMetadataUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'updateSupplementalMetadata',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'updateSupplementalMetadata',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> updateSettings(
    _ist.TestSessionBuilder sessionBuilder,
    _i3f5mgyk.CalendarSettingsUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'updateSettings',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'updateSettings',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_iwx7nyid.CalendarSubjectView>> subjects(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'subjects',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'subjects',
          parameters: _ist.testObjectToJson({'calendarId': calendarId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_iwx7nyid.CalendarSubjectView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> changeSubject(
    _ist.TestSessionBuilder sessionBuilder,
    _ib1wmljm.CalendarSubjectChangeRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'changeSubject',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'changeSubject',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ied1lssg.CalendarMutationReceipt?> delete(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId,
    int expectedRevision,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'delete',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'delete',
          parameters: _ist.testObjectToJson({
            'calendarId': calendarId,
            'expectedRevision': expectedRevision,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ied1lssg.CalendarMutationReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _CalendarEventEndpoint {
  _CalendarEventEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_irjxy316.CalendarEventReceipt?> create(
    _ist.TestSessionBuilder sessionBuilder,
    _ixcfd9h0.CalendarEventCreateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'create',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_irjxy316.CalendarEventReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6zsydj7.CalendarEventView> getEvent(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue eventId,
    List<_il5gdr09.CalendarEventFieldGroup> groups,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'getEvent',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'getEvent',
          parameters: _ist.testObjectToJson({
            'eventId': eventId,
            'groups': groups,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6zsydj7.CalendarEventView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i092pg3q.CalendarEventPage> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId, {
    required int pageSize,
    required List<_il5gdr09.CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'list',
          parameters: _ist.testObjectToJson({
            'calendarId': calendarId,
            'pageSize': pageSize,
            'fieldGroups': fieldGroups,
            'cursor': cursor,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i092pg3q.CalendarEventPage>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2qqvmw2.CalendarEventOccurrencePreview> preview(
    _ist.TestSessionBuilder sessionBuilder,
    _i7o3kzld.CalendarEventOccurrenceQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'preview',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'preview',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i2qqvmw2.CalendarEventOccurrencePreview>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_irjxy316.CalendarEventReceipt?> update(
    _ist.TestSessionBuilder sessionBuilder,
    _iabs06xo.CalendarEventUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'update',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_irjxy316.CalendarEventReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_irjxy316.CalendarEventReceipt?> changeStatus(
    _ist.TestSessionBuilder sessionBuilder,
    _ib916yyf.CalendarEventStatusRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'changeStatus',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'changeStatus',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_irjxy316.CalendarEventReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_irjxy316.CalendarEventReceipt?> deleteEvent(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue eventId,
    int expectedRevision,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'deleteEvent',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'deleteEvent',
          parameters: _ist.testObjectToJson({
            'eventId': eventId,
            'expectedRevision': expectedRevision,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_irjxy316.CalendarEventReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}
