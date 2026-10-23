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
import 'dart:typed_data' as _idt;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_create_request.dart'
    as _iys46g3v;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_export_request.dart'
    as _imnneju4;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_import_request.dart'
    as _itxm78f7;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_import_result.dart'
    as _imwaqqth;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_occurrence_change.dart'
    as _ihzf1dkn;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_occurrence_preview.dart'
    as _i2fqfjcg;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_occurrence_query.dart'
    as _idgpm5rc;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_receipt.dart'
    as _i6vowhmw;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_replace_request.dart'
    as _iu4nsjvo;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_replace_result.dart'
    as _ibom5eka;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_search_query.dart'
    as _iirwhdxv;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_search_view.dart'
    as _i5d3khya;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_update_request.dart'
    as _i2zdh4d8;
import 'package:serverpod_calendar_server/src/generated/calendar_availability_view.dart'
    as _i6fuga80;
import 'package:serverpod_calendar_server/src/generated/calendar_category_filter.dart'
    as _ith8xeb5;
import 'package:serverpod_calendar_server/src/generated/calendar_create_request.dart'
    as _i287wpc6;
import 'package:serverpod_calendar_server/src/generated/calendar_event_create_request.dart'
    as _ixcfd9h0;
import 'package:serverpod_calendar_server/src/generated/calendar_event_export_request.dart'
    as _i6dxskz2;
import 'package:serverpod_calendar_server/src/generated/calendar_event_field_group.dart'
    as _il5gdr09;
import 'package:serverpod_calendar_server/src/generated/calendar_event_import_request.dart'
    as _iqjmvy9m;
import 'package:serverpod_calendar_server/src/generated/calendar_event_import_result.dart'
    as _iaw5gnbe;
import 'package:serverpod_calendar_server/src/generated/calendar_event_occurrence_change.dart'
    as _ixyxs14v;
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
import 'package:serverpod_calendar_server/src/generated/calendar_free_busy_query.dart'
    as _imwtl5fr;
import 'package:serverpod_calendar_server/src/generated/calendar_free_busy_view.dart'
    as _i3y4q8eh;
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
import 'package:serverpod_calendar_server/src/generated/calendar_task_assignments_request.dart'
    as _iuliypfa;
import 'package:serverpod_calendar_server/src/generated/calendar_task_create_request.dart'
    as _i9cxsmu8;
import 'package:serverpod_calendar_server/src/generated/calendar_task_export_request.dart'
    as _iqudlnxz;
import 'package:serverpod_calendar_server/src/generated/calendar_task_field_group.dart'
    as _ik0gz7r1;
import 'package:serverpod_calendar_server/src/generated/calendar_task_history_page.dart'
    as _iqgurf9e;
import 'package:serverpod_calendar_server/src/generated/calendar_task_history_query.dart'
    as _issl6zlo;
import 'package:serverpod_calendar_server/src/generated/calendar_task_import_request.dart'
    as _in2ug0m6;
import 'package:serverpod_calendar_server/src/generated/calendar_task_import_result.dart'
    as _imwandrw;
import 'package:serverpod_calendar_server/src/generated/calendar_task_occurrence_content_request.dart'
    as _ien69b9c;
import 'package:serverpod_calendar_server/src/generated/calendar_task_occurrence_preview.dart'
    as _i8v6r7o6;
import 'package:serverpod_calendar_server/src/generated/calendar_task_occurrence_progress_request.dart'
    as _ingyryea;
import 'package:serverpod_calendar_server/src/generated/calendar_task_occurrence_query.dart'
    as _i3q14sij;
import 'package:serverpod_calendar_server/src/generated/calendar_task_occurrence_timing_request.dart'
    as _i4pulpcp;
import 'package:serverpod_calendar_server/src/generated/calendar_task_page.dart'
    as _ig64r97r;
import 'package:serverpod_calendar_server/src/generated/calendar_task_progress_request.dart'
    as _ilb9fjz5;
import 'package:serverpod_calendar_server/src/generated/calendar_task_receipt.dart'
    as _ix5y5076;
import 'package:serverpod_calendar_server/src/generated/calendar_task_update_request.dart'
    as _ifljty0a;
import 'package:serverpod_calendar_server/src/generated/calendar_task_view.dart'
    as _iz0gxasm;
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
  late final _CalendarAvailabilityEndpoint calendarAvailability;

  late final _CalendarAvailabilitySearchEndpoint calendarAvailabilitySearch;

  late final _CalendarDiagnosticsEndpoint calendarDiagnostics;

  late final _CalendarEndpoint calendar;

  late final _CalendarEventEndpoint calendarEvent;

  late final _CalendarTaskEndpoint calendarTask;
}

class _InternalTestEndpoints extends TestEndpoints
    implements _ist.InternalTestEndpoints {
  @override
  void initialize(
    _is.SerializationManager serializationManager,
    _is.EndpointDispatch endpoints,
  ) {
    calendarAvailability = _CalendarAvailabilityEndpoint(
      endpoints,
      serializationManager,
    );
    calendarAvailabilitySearch = _CalendarAvailabilitySearchEndpoint(
      endpoints,
      serializationManager,
    );
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
    calendarTask = _CalendarTaskEndpoint(
      endpoints,
      serializationManager,
    );
  }
}

class _CalendarAvailabilityEndpoint {
  _CalendarAvailabilityEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_ibom5eka.CalendarAvailabilityReplaceResult> replaceFromImport(
    _ist.TestSessionBuilder sessionBuilder,
    _iu4nsjvo.CalendarAvailabilityReplaceRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'replaceFromImport',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'replaceFromImport',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ibom5eka.CalendarAvailabilityReplaceResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_idt.ByteData> exportCalendar(
    _ist.TestSessionBuilder sessionBuilder,
    _imnneju4.CalendarAvailabilityExportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'exportCalendar',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'exportCalendar',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idt.ByteData>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_imwaqqth.CalendarAvailabilityImportResult> importCalendar(
    _ist.TestSessionBuilder sessionBuilder,
    _itxm78f7.CalendarAvailabilityImportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'importCalendar',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'importCalendar',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_imwaqqth.CalendarAvailabilityImportResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?> create(
    _ist.TestSessionBuilder sessionBuilder,
    _iys46g3v.CalendarAvailabilityCreateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'create',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6fuga80.CalendarAvailabilityView> getRule(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue availabilityId,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'getRule',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'getRule',
          parameters: _ist.testObjectToJson({'availabilityId': availabilityId}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6fuga80.CalendarAvailabilityView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<List<_i6fuga80.CalendarAvailabilityView>> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId, {
    String? category,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'list',
          parameters: _ist.testObjectToJson({
            'calendarId': calendarId,
            'category': category,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<List<_i6fuga80.CalendarAvailabilityView>>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?> update(
    _ist.TestSessionBuilder sessionBuilder,
    _i2zdh4d8.CalendarAvailabilityUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'update',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?> updateMetadata(
    _ist.TestSessionBuilder sessionBuilder,
    _i2zdh4d8.CalendarAvailabilityUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'updateMetadata',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'updateMetadata',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?> changeOccurrence(
    _ist.TestSessionBuilder sessionBuilder,
    _ihzf1dkn.CalendarAvailabilityOccurrenceChange request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'changeOccurrence',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'changeOccurrence',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i2fqfjcg.CalendarAvailabilityOccurrencePreview> preview(
    _ist.TestSessionBuilder sessionBuilder,
    _idgpm5rc.CalendarAvailabilityOccurrenceQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'preview',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'preview',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<
                  _i2fqfjcg.CalendarAvailabilityOccurrencePreview
                >);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?> deleteRule(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue availabilityId,
    int expectedRevision,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailability',
            method: 'deleteRule',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailability',
          methodName: 'deleteRule',
          parameters: _ist.testObjectToJson({
            'availabilityId': availabilityId,
            'expectedRevision': expectedRevision,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i6vowhmw.CalendarAvailabilityReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}

class _CalendarAvailabilitySearchEndpoint {
  _CalendarAvailabilitySearchEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_i5d3khya.CalendarAvailabilitySearchView> search(
    _ist.TestSessionBuilder sessionBuilder,
    _iirwhdxv.CalendarAvailabilitySearchQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarAvailabilitySearch',
            method: 'search',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarAvailabilitySearch',
          methodName: 'search',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i5d3khya.CalendarAvailabilitySearchView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
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

  _ida.Future<_idt.ByteData> exportFreeBusy(
    _ist.TestSessionBuilder sessionBuilder,
    _imwtl5fr.CalendarFreeBusyQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'exportFreeBusy',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'exportFreeBusy',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idt.ByteData>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i3y4q8eh.CalendarFreeBusyView> freeBusy(
    _ist.TestSessionBuilder sessionBuilder,
    _imwtl5fr.CalendarFreeBusyQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendar',
            method: 'freeBusy',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendar',
          methodName: 'freeBusy',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i3y4q8eh.CalendarFreeBusyView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

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

  _ida.Future<_idt.ByteData> exportEvents(
    _ist.TestSessionBuilder sessionBuilder,
    _i6dxskz2.CalendarEventExportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'exportEvents',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'exportEvents',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idt.ByteData>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iaw5gnbe.CalendarEventImportResult> importEvents(
    _ist.TestSessionBuilder sessionBuilder,
    _iqjmvy9m.CalendarEventImportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'importEvents',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'importEvents',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iaw5gnbe.CalendarEventImportResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

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

  _ida.Future<_irjxy316.CalendarEventReceipt?> changeOccurrence(
    _ist.TestSessionBuilder sessionBuilder,
    _ixyxs14v.CalendarEventOccurrenceChange request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarEvent',
            method: 'changeOccurrence',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarEvent',
          methodName: 'changeOccurrence',
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

class _CalendarTaskEndpoint {
  _CalendarTaskEndpoint(
    this._endpointDispatch,
    this._serializationManager,
  );

  final _is.EndpointDispatch _endpointDispatch;

  final _is.SerializationManager _serializationManager;

  _ida.Future<_idt.ByteData> exportTasks(
    _ist.TestSessionBuilder sessionBuilder,
    _iqudlnxz.CalendarTaskExportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'exportTasks',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'exportTasks',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_idt.ByteData>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_imwandrw.CalendarTaskImportResult> importTasks(
    _ist.TestSessionBuilder sessionBuilder,
    _in2ug0m6.CalendarTaskImportRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'importTasks',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'importTasks',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_imwandrw.CalendarTaskImportResult>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> create(
    _ist.TestSessionBuilder sessionBuilder,
    _i9cxsmu8.CalendarTaskCreateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'create',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'create',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iz0gxasm.CalendarTaskView> getTask(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue taskId,
    List<_ik0gz7r1.CalendarTaskFieldGroup> groups,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'getTask',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'getTask',
          parameters: _ist.testObjectToJson({
            'taskId': taskId,
            'groups': groups,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iz0gxasm.CalendarTaskView>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ig64r97r.CalendarTaskPage> list(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue calendarId, {
    required int pageSize,
    required List<_ik0gz7r1.CalendarTaskFieldGroup> fieldGroups,
    String? cursor,
  }) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'list',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
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
                as _ida.Future<_ig64r97r.CalendarTaskPage>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> update(
    _ist.TestSessionBuilder sessionBuilder,
    _ifljty0a.CalendarTaskUpdateRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'update',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'update',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> changeProgress(
    _ist.TestSessionBuilder sessionBuilder,
    _ilb9fjz5.CalendarTaskProgressRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'changeProgress',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'changeProgress',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> changeAssignments(
    _ist.TestSessionBuilder sessionBuilder,
    _iuliypfa.CalendarTaskAssignmentsRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'changeAssignments',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'changeAssignments',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> deleteTask(
    _ist.TestSessionBuilder sessionBuilder,
    _is.UuidValue taskId,
    int expectedRevision,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'deleteTask',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'deleteTask',
          parameters: _ist.testObjectToJson({
            'taskId': taskId,
            'expectedRevision': expectedRevision,
          }),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_i8v6r7o6.CalendarTaskOccurrencePreview> previewOccurrences(
    _ist.TestSessionBuilder sessionBuilder,
    _i3q14sij.CalendarTaskOccurrenceQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'previewOccurrences',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'previewOccurrences',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_i8v6r7o6.CalendarTaskOccurrencePreview>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> changeOccurrenceTiming(
    _ist.TestSessionBuilder sessionBuilder,
    _i4pulpcp.CalendarTaskOccurrenceTimingRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'changeOccurrenceTiming',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'changeOccurrenceTiming',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> changeOccurrenceProgress(
    _ist.TestSessionBuilder sessionBuilder,
    _ingyryea.CalendarTaskOccurrenceProgressRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'changeOccurrenceProgress',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'changeOccurrenceProgress',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_ix5y5076.CalendarTaskReceipt?> changeOccurrenceContent(
    _ist.TestSessionBuilder sessionBuilder,
    _ien69b9c.CalendarTaskOccurrenceContentRequest request,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'changeOccurrenceContent',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'changeOccurrenceContent',
          parameters: _ist.testObjectToJson({'request': request}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_ix5y5076.CalendarTaskReceipt?>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }

  _ida.Future<_iqgurf9e.CalendarTaskHistoryPage> occurrenceHistory(
    _ist.TestSessionBuilder sessionBuilder,
    _issl6zlo.CalendarTaskHistoryQuery query,
  ) async {
    return _ist.callAwaitableFunctionAndHandleExceptions(() async {
      var _localUniqueSession =
          (sessionBuilder as _ist.InternalTestSessionBuilder).internalBuild(
            endpoint: 'calendarTask',
            method: 'occurrenceHistory',
          );
      try {
        var _localCallContext = await _endpointDispatch.getMethodCallContext(
          createSessionCallback: (_) => _localUniqueSession,
          endpointPath: 'calendarTask',
          methodName: 'occurrenceHistory',
          parameters: _ist.testObjectToJson({'query': query}),
          serializationManager: _serializationManager,
        );
        var _localReturnValue =
            await (_localCallContext.method.call(
                  _localUniqueSession,
                  _localCallContext.arguments,
                )
                as _ida.Future<_iqgurf9e.CalendarTaskHistoryPage>);
        return _localReturnValue;
      } finally {
        await _localUniqueSession.close();
      }
    });
  }
}
