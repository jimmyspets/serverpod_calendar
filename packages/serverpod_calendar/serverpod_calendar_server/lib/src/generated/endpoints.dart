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
import 'package:serverpod_calendar_server/src/generated/calendar_category_filter.dart'
    as _ith8xeb5;
import 'package:serverpod_calendar_server/src/generated/calendar_create_request.dart'
    as _i287wpc6;
import 'package:serverpod_calendar_server/src/generated/calendar_event_create_request.dart'
    as _ixcfd9h0;
import 'package:serverpod_calendar_server/src/generated/calendar_event_field_group.dart'
    as _il5gdr09;
import 'package:serverpod_calendar_server/src/generated/calendar_event_occurrence_query.dart'
    as _i7o3kzld;
import 'package:serverpod_calendar_server/src/generated/calendar_event_status_request.dart'
    as _ib916yyf;
import 'package:serverpod_calendar_server/src/generated/calendar_event_update_request.dart'
    as _iabs06xo;
import 'package:serverpod_calendar_server/src/generated/calendar_field_group.dart'
    as _i3d02yxy;
import 'package:serverpod_calendar_server/src/generated/calendar_metadata_update_request.dart'
    as _io29vhgw;
import 'package:serverpod_calendar_server/src/generated/calendar_presentation_update_request.dart'
    as _i1sjay6c;
import 'package:serverpod_calendar_server/src/generated/calendar_protocol_metadata_update_request.dart'
    as _i53ouodu;
import 'package:serverpod_calendar_server/src/generated/calendar_settings_update_request.dart'
    as _i3f5mgyk;
import 'package:serverpod_calendar_server/src/generated/calendar_subject_change_request.dart'
    as _ib1wmljm;
import 'package:serverpod_calendar_server/src/generated/calendar_supplemental_metadata_update_request.dart'
    as _ito4h8gf;
import 'package:serverpod_notifications_server/serverpod_notifications_server.dart'
    as _ik9lwgjh;
import '../endpoints/calendar_diagnostics_endpoint.dart' as _icr8drn5;
import '../endpoints/calendar_endpoint.dart' as _inx4l1vp;
import '../endpoints/calendar_event_endpoint.dart' as _ibwv0suj;

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
      'calendar': _inx4l1vp.CalendarEndpoint()
        ..initialize(
          server,
          'calendar',
          'serverpod_calendar',
        ),
      'calendarEvent': _ibwv0suj.CalendarEventEndpoint()
        ..initialize(
          server,
          'calendarEvent',
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
    connectors['calendar'] = _is.EndpointConnector(
      name: 'calendar',
      endpoint: endpoints['calendar']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_i287wpc6.CalendarCreateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint).create(
                    session,
                    params['request'],
                  ),
        ),
        'getCalendar': _is.MethodConnector(
          name: 'getCalendar',
          params: {
            'calendarId': _is.ParameterDescription(
              name: 'calendarId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'fieldGroups': _is.ParameterDescription(
              name: 'fieldGroups',
              type: _is.getType<List<_i3d02yxy.CalendarFieldGroup>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .getCalendar(
                    session,
                    params['calendarId'],
                    params['fieldGroups'],
                  ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fieldGroups': _is.ParameterDescription(
              name: 'fieldGroups',
              type: _is.getType<List<_i3d02yxy.CalendarFieldGroup>>(),
              nullable: false,
            ),
            'cursor': _is.ParameterDescription(
              name: 'cursor',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'categoryFilter': _is.ParameterDescription(
              name: 'categoryFilter',
              type: _is.getType<_ith8xeb5.CalendarCategoryFilter?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint).list(
                    session,
                    pageSize: params['pageSize'],
                    fieldGroups: params['fieldGroups'],
                    cursor: params['cursor'],
                    categoryFilter: params['categoryFilter'],
                  ),
        ),
        'updateMetadata': _is.MethodConnector(
          name: 'updateMetadata',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_io29vhgw.CalendarMetadataUpdateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updateMetadata(
                    session,
                    params['request'],
                  ),
        ),
        'updatePresentation': _is.MethodConnector(
          name: 'updatePresentation',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_i1sjay6c.CalendarPresentationUpdateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updatePresentation(
                    session,
                    params['request'],
                  ),
        ),
        'updateProtocolMetadata': _is.MethodConnector(
          name: 'updateProtocolMetadata',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is
                  .getType<_i53ouodu.CalendarProtocolMetadataUpdateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updateProtocolMetadata(
                    session,
                    params['request'],
                  ),
        ),
        'updateSupplementalMetadata': _is.MethodConnector(
          name: 'updateSupplementalMetadata',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is
                  .getType<
                    _ito4h8gf.CalendarSupplementalMetadataUpdateRequest
                  >(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updateSupplementalMetadata(
                    session,
                    params['request'],
                  ),
        ),
        'updateSettings': _is.MethodConnector(
          name: 'updateSettings',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_i3f5mgyk.CalendarSettingsUpdateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .updateSettings(
                    session,
                    params['request'],
                  ),
        ),
        'subjects': _is.MethodConnector(
          name: 'subjects',
          params: {
            'calendarId': _is.ParameterDescription(
              name: 'calendarId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .subjects(
                    session,
                    params['calendarId'],
                  ),
        ),
        'changeSubject': _is.MethodConnector(
          name: 'changeSubject',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ib1wmljm.CalendarSubjectChangeRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint)
                  .changeSubject(
                    session,
                    params['request'],
                  ),
        ),
        'delete': _is.MethodConnector(
          name: 'delete',
          params: {
            'calendarId': _is.ParameterDescription(
              name: 'calendarId',
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
                  (endpoints['calendar'] as _inx4l1vp.CalendarEndpoint).delete(
                    session,
                    params['calendarId'],
                    params['expectedRevision'],
                  ),
        ),
      },
    );
    connectors['calendarEvent'] = _is.EndpointConnector(
      name: 'calendarEvent',
      endpoint: endpoints['calendarEvent']!,
      methodConnectors: {
        'create': _is.MethodConnector(
          name: 'create',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ixcfd9h0.CalendarEventCreateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .create(
                        session,
                        params['request'],
                      ),
        ),
        'getEvent': _is.MethodConnector(
          name: 'getEvent',
          params: {
            'eventId': _is.ParameterDescription(
              name: 'eventId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'groups': _is.ParameterDescription(
              name: 'groups',
              type: _is.getType<List<_il5gdr09.CalendarEventFieldGroup>>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .getEvent(
                        session,
                        params['eventId'],
                        params['groups'],
                      ),
        ),
        'list': _is.MethodConnector(
          name: 'list',
          params: {
            'calendarId': _is.ParameterDescription(
              name: 'calendarId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'pageSize': _is.ParameterDescription(
              name: 'pageSize',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'fieldGroups': _is.ParameterDescription(
              name: 'fieldGroups',
              type: _is.getType<List<_il5gdr09.CalendarEventFieldGroup>>(),
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
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .list(
                        session,
                        params['calendarId'],
                        pageSize: params['pageSize'],
                        fieldGroups: params['fieldGroups'],
                        cursor: params['cursor'],
                      ),
        ),
        'preview': _is.MethodConnector(
          name: 'preview',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<_i7o3kzld.CalendarEventOccurrenceQuery>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .preview(
                        session,
                        params['query'],
                      ),
        ),
        'update': _is.MethodConnector(
          name: 'update',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_iabs06xo.CalendarEventUpdateRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .update(
                        session,
                        params['request'],
                      ),
        ),
        'changeStatus': _is.MethodConnector(
          name: 'changeStatus',
          params: {
            'request': _is.ParameterDescription(
              name: 'request',
              type: _is.getType<_ib916yyf.CalendarEventStatusRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .changeStatus(
                        session,
                        params['request'],
                      ),
        ),
        'deleteEvent': _is.MethodConnector(
          name: 'deleteEvent',
          params: {
            'eventId': _is.ParameterDescription(
              name: 'eventId',
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
                  (endpoints['calendarEvent']
                          as _ibwv0suj.CalendarEventEndpoint)
                      .deleteEvent(
                        session,
                        params['eventId'],
                        params['expectedRevision'],
                      ),
        ),
      },
    );
    modules['serverpod_notifications'] = _ik9lwgjh.Endpoints()
      ..initializeEndpoints(server);
  }
}
