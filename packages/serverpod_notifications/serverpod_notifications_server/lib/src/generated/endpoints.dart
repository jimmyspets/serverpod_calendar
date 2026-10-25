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
import '../endpoints/notification_endpoint.dart' as _ihb11yhk;
import '../endpoints/notifications_diagnostics_endpoint.dart' as _iikyohz9;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'notification': _ihb11yhk.NotificationEndpoint()
        ..initialize(
          server,
          'notification',
          'serverpod_notifications',
        ),
      'notificationDiagnostics': _iikyohz9.NotificationDiagnosticsEndpoint()
        ..initialize(
          server,
          'notificationDiagnostics',
          'serverpod_notifications',
        ),
    };
    connectors['notification'] = _is.EndpointConnector(
      name: 'notification',
      endpoint: endpoints['notification']!,
      methodConnectors: {
        'recover': _is.MethodConnector(
          name: 'recover',
          params: {
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'cursor': _is.ParameterDescription(
              name: 'cursor',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notification'] as _ihb11yhk.NotificationEndpoint)
                      .recover(
                        session,
                        params['pageSize'],
                        params['cursor'],
                      ),
        ),
      },
    );
    connectors['notificationDiagnostics'] = _is.EndpointConnector(
      name: 'notificationDiagnostics',
      endpoint: endpoints['notificationDiagnostics']!,
      methodConnectors: {
        'check': _is.MethodConnector(
          name: 'check',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notificationDiagnostics']
                          as _iikyohz9.NotificationDiagnosticsEndpoint)
                      .check(session),
        ),
      },
    );
  }
}
