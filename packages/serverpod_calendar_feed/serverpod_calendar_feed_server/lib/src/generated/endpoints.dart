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
import 'package:serverpod_calendar_feed_server/src/generated/calendar_feed_settings.dart'
    as _ih4wvagc;
import 'package:serverpod_calendar_server/serverpod_calendar_server.dart'
    as _ipn35bcd;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import '../endpoints/calendar_feed_endpoint.dart' as _ibvlwx2y;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'calendarFeed': _ibvlwx2y.CalendarFeedEndpoint()
        ..initialize(
          server,
          'calendarFeed',
          'serverpod_calendar_feed',
        ),
    };
    connectors['calendarFeed'] = _is.EndpointConnector(
      name: 'calendarFeed',
      endpoint: endpoints['calendarFeed']!,
      methodConnectors: {
        'list': _is.MethodConnector(
          name: 'list',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .list(session),
        ),
        'read': _is.MethodConnector(
          name: 'read',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .read(
                        session,
                        params['id'],
                      ),
        ),
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'settings': _is.ParameterDescription(
              name: 'settings',
              type: _is.getType<_ih4wvagc.CalendarFeedSettings>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .create(
                        session,
                        params['settings'],
                      ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'settings': _is.ParameterDescription(
              name: 'settings',
              type: _is.getType<_ih4wvagc.CalendarFeedSettings>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .update(
                        session,
                        params['id'],
                        params['expectedRevision'],
                        params['settings'],
                      ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'id': _is.ParameterDescription(
              name: 'id',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .delete(
                        session,
                        params['id'],
                        params['expectedRevision'],
                      ),
        ),
        'credentials': _is.MethodConnector(
          name: 'credentials',
          params: {
            'feedId': _is.ParameterDescription(
              name: 'feedId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .credentials(
                        session,
                        params['feedId'],
                      ),
        ),
        'createCredential': _is.MethodConnector(
          name: 'createCredential',
          params: {
            'feedId': _is.ParameterDescription(
              name: 'feedId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'expectedFeedRevision': _is.ParameterDescription(
              name: 'expectedFeedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'label': _is.ParameterDescription(
              name: 'label',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .createCredential(
                        session,
                        params['feedId'],
                        params['expectedFeedRevision'],
                        params['label'],
                      ),
        ),
        'revokeCredential': _is.MethodConnector(
          name: 'revokeCredential',
          params: {
            'feedId': _is.ParameterDescription(
              name: 'feedId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'expectedFeedRevision': _is.ParameterDescription(
              name: 'expectedFeedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'credentialId': _is.ParameterDescription(
              name: 'credentialId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'expectedRevision': _is.ParameterDescription(
              name: 'expectedRevision',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarFeed'] as _ibvlwx2y.CalendarFeedEndpoint)
                      .revokeCredential(
                        session,
                        params['feedId'],
                        params['expectedFeedRevision'],
                        params['credentialId'],
                        params['expectedRevision'],
                      ),
        ),
      },
    );
    modules['serverpod_calendar'] = _ipn35bcd.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_notifications'] = _ik9lwgjh.Endpoints()
      ..initializeEndpoints(server);
  }
}
