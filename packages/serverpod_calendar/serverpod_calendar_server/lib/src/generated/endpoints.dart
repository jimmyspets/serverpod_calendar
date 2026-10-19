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
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import '../endpoints/calendar_diagnostics_endpoint.dart' as _icr8drn5;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'calendarDiagnostics': _icr8drn5.CalendarDiagnosticsEndpoint()
        ..initialize(
          server,
          'calendarDiagnostics',
          'serverpod_calendar',
        ),
    };
    connectors['calendarDiagnostics'] = _is.EndpointConnector(
      name: 'calendarDiagnostics',
      endpoint: endpoints['calendarDiagnostics']!,
      methodConnectors: {
        'check': _is.MethodConnector(
          name: 'check',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarDiagnostics']
                          as _icr8drn5.CalendarDiagnosticsEndpoint)
                      .check(session),
        ),
      },
    );
    modules['serverpod_notifications'] = _ik9lwgjh.Endpoints()
      ..initializeEndpoints(server);
  }
}
