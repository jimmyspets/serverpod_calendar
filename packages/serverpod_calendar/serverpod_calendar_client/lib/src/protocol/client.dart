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
import 'dart:async' as _ida;
import 'package:serverpod_calendar_client/src/protocol/calendar_create_request.dart'
    as _i3j5a5bv;
import 'package:serverpod_calendar_client/src/protocol/calendar_field_group.dart'
    as _ioi1smgh;
import 'package:serverpod_calendar_client/src/protocol/calendar_metadata_update_request.dart'
    as _imfz6psz;
import 'package:serverpod_calendar_client/src/protocol/calendar_mutation_receipt.dart'
    as _ibyc2v98;
import 'package:serverpod_calendar_client/src/protocol/calendar_page.dart'
    as _iq8vfd61;
import 'package:serverpod_calendar_client/src/protocol/calendar_presentation_update_request.dart'
    as _iju8myao;
import 'package:serverpod_calendar_client/src/protocol/calendar_protocol_metadata_update_request.dart'
    as _i3063onq;
import 'package:serverpod_calendar_client/src/protocol/calendar_settings_update_request.dart'
    as _ixxutfio;
import 'package:serverpod_calendar_client/src/protocol/calendar_subject_change_request.dart'
    as _i4hdn2j8;
import 'package:serverpod_calendar_client/src/protocol/calendar_subject_view.dart'
    as _iad1u4rm;
import 'package:serverpod_calendar_client/src/protocol/calendar_view.dart'
    as _i6qyw4e7;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Authenticated module wiring check; no calendar/notification domain behavior.
/// {@category Endpoint}
class EndpointCalendarDiagnostics extends _isc.EndpointRef {
  EndpointCalendarDiagnostics(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_calendar.calendarDiagnostics';

  _ida.Future<String> check() => caller.callServerEndpoint<String>(
    'serverpod_calendar.calendarDiagnostics',
    'check',
    {},
  );
}

/// Native calendar operations. Authorization also lives in the service layer.
/// {@category Endpoint}
class EndpointCalendar extends _isc.EndpointRef {
  EndpointCalendar(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_calendar.calendar';

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> create(
    _i3j5a5bv.CalendarCreateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'create',
    {'request': request},
  );

  _ida.Future<_i6qyw4e7.CalendarView> getCalendar(
    _isc.UuidValue calendarId,
    List<_ioi1smgh.CalendarFieldGroup> fieldGroups,
  ) => caller.callServerEndpoint<_i6qyw4e7.CalendarView>(
    'serverpod_calendar.calendar',
    'getCalendar',
    {
      'calendarId': calendarId,
      'fieldGroups': fieldGroups,
    },
  );

  _ida.Future<_iq8vfd61.CalendarPage> list({
    required int pageSize,
    required List<_ioi1smgh.CalendarFieldGroup> fieldGroups,
    String? cursor,
  }) => caller.callServerEndpoint<_iq8vfd61.CalendarPage>(
    'serverpod_calendar.calendar',
    'list',
    {
      'pageSize': pageSize,
      'fieldGroups': fieldGroups,
      'cursor': cursor,
    },
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> updateMetadata(
    _imfz6psz.CalendarMetadataUpdateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'updateMetadata',
    {'request': request},
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> updatePresentation(
    _iju8myao.CalendarPresentationUpdateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'updatePresentation',
    {'request': request},
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> updateProtocolMetadata(
    _i3063onq.CalendarProtocolMetadataUpdateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'updateProtocolMetadata',
    {'request': request},
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> updateSettings(
    _ixxutfio.CalendarSettingsUpdateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'updateSettings',
    {'request': request},
  );

  _ida.Future<List<_iad1u4rm.CalendarSubjectView>> subjects(
    _isc.UuidValue calendarId,
  ) => caller.callServerEndpoint<List<_iad1u4rm.CalendarSubjectView>>(
    'serverpod_calendar.calendar',
    'subjects',
    {'calendarId': calendarId},
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> changeSubject(
    _i4hdn2j8.CalendarSubjectChangeRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'changeSubject',
    {'request': request},
  );

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> delete(
    _isc.UuidValue calendarId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'delete',
    {
      'calendarId': calendarId,
      'expectedRevision': expectedRevision,
    },
  );
}

class Caller extends _isc.ModuleEndpointCaller {
  Caller(_isc.ServerpodClientShared client) : super(client) {
    calendarDiagnostics = EndpointCalendarDiagnostics(this);
    calendar = EndpointCalendar(this);
  }

  late final EndpointCalendarDiagnostics calendarDiagnostics;

  late final EndpointCalendar calendar;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'serverpod_calendar.calendarDiagnostics': calendarDiagnostics,
    'serverpod_calendar.calendar': calendar,
  };
}
