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
import 'dart:typed_data' as _idt;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_create_request.dart'
    as _i2zcamh9;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_export_request.dart'
    as _izvtbziu;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_import_request.dart'
    as _ilq73ar1;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_import_result.dart'
    as _iraz2mny;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_occurrence_change.dart'
    as _izaew8o2;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_occurrence_preview.dart'
    as _iv2k157u;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_occurrence_query.dart'
    as _iafnzhwk;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_receipt.dart'
    as _izuu9p5h;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_search_query.dart'
    as _inwpo91l;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_search_view.dart'
    as _ieqmn71v;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_update_request.dart'
    as _ifcp60op;
import 'package:serverpod_calendar_client/src/protocol/calendar_availability_view.dart'
    as _imwdhk62;
import 'package:serverpod_calendar_client/src/protocol/calendar_category_filter.dart'
    as _in004d9w;
import 'package:serverpod_calendar_client/src/protocol/calendar_create_request.dart'
    as _i3j5a5bv;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_create_request.dart'
    as _iwlxheag;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_field_group.dart'
    as _icxx5h8a;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_occurrence_change.dart'
    as _ir37u2ww;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_occurrence_preview.dart'
    as _iz6iah5n;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_occurrence_query.dart'
    as _iejw8qh7;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_page.dart'
    as _i8kstbs4;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_receipt.dart'
    as _ieh64e0q;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_status_request.dart'
    as _ignysrxk;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_update_request.dart'
    as _itsbll8l;
import 'package:serverpod_calendar_client/src/protocol/calendar_event_view.dart'
    as _ixldy3zv;
import 'package:serverpod_calendar_client/src/protocol/calendar_field_group.dart'
    as _ioi1smgh;
import 'package:serverpod_calendar_client/src/protocol/calendar_free_busy_query.dart'
    as _isyn5yvo;
import 'package:serverpod_calendar_client/src/protocol/calendar_free_busy_view.dart'
    as _i2cb1v6y;
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
import 'package:serverpod_calendar_client/src/protocol/calendar_supplemental_metadata_update_request.dart'
    as _i18zqkab;
import 'package:serverpod_calendar_client/src/protocol/calendar_view.dart'
    as _i6qyw4e7;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// {@category Endpoint}
class EndpointCalendarAvailability extends _isc.EndpointRef {
  EndpointCalendarAvailability(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_calendar.calendarAvailability';

  _ida.Future<_idt.ByteData> exportCalendar(
    _izvtbziu.CalendarAvailabilityExportRequest request,
  ) => caller.callServerEndpoint<_idt.ByteData>(
    'serverpod_calendar.calendarAvailability',
    'exportCalendar',
    {'request': request},
  );

  _ida.Future<_iraz2mny.CalendarAvailabilityImportResult> importCalendar(
    _ilq73ar1.CalendarAvailabilityImportRequest request,
  ) => caller.callServerEndpoint<_iraz2mny.CalendarAvailabilityImportResult>(
    'serverpod_calendar.calendarAvailability',
    'importCalendar',
    {'request': request},
  );

  _ida.Future<_izuu9p5h.CalendarAvailabilityReceipt?> create(
    _i2zcamh9.CalendarAvailabilityCreateRequest request,
  ) => caller.callServerEndpoint<_izuu9p5h.CalendarAvailabilityReceipt?>(
    'serverpod_calendar.calendarAvailability',
    'create',
    {'request': request},
  );

  _ida.Future<_imwdhk62.CalendarAvailabilityView> getRule(
    _isc.UuidValue availabilityId,
  ) => caller.callServerEndpoint<_imwdhk62.CalendarAvailabilityView>(
    'serverpod_calendar.calendarAvailability',
    'getRule',
    {'availabilityId': availabilityId},
  );

  _ida.Future<List<_imwdhk62.CalendarAvailabilityView>> list(
    _isc.UuidValue calendarId, {
    String? category,
  }) => caller.callServerEndpoint<List<_imwdhk62.CalendarAvailabilityView>>(
    'serverpod_calendar.calendarAvailability',
    'list',
    {
      'calendarId': calendarId,
      'category': category,
    },
  );

  _ida.Future<_izuu9p5h.CalendarAvailabilityReceipt?> update(
    _ifcp60op.CalendarAvailabilityUpdateRequest request,
  ) => caller.callServerEndpoint<_izuu9p5h.CalendarAvailabilityReceipt?>(
    'serverpod_calendar.calendarAvailability',
    'update',
    {'request': request},
  );

  _ida.Future<_izuu9p5h.CalendarAvailabilityReceipt?> updateMetadata(
    _ifcp60op.CalendarAvailabilityUpdateRequest request,
  ) => caller.callServerEndpoint<_izuu9p5h.CalendarAvailabilityReceipt?>(
    'serverpod_calendar.calendarAvailability',
    'updateMetadata',
    {'request': request},
  );

  _ida.Future<_izuu9p5h.CalendarAvailabilityReceipt?> changeOccurrence(
    _izaew8o2.CalendarAvailabilityOccurrenceChange request,
  ) => caller.callServerEndpoint<_izuu9p5h.CalendarAvailabilityReceipt?>(
    'serverpod_calendar.calendarAvailability',
    'changeOccurrence',
    {'request': request},
  );

  _ida.Future<_iv2k157u.CalendarAvailabilityOccurrencePreview> preview(
    _iafnzhwk.CalendarAvailabilityOccurrenceQuery query,
  ) => caller
      .callServerEndpoint<_iv2k157u.CalendarAvailabilityOccurrencePreview>(
        'serverpod_calendar.calendarAvailability',
        'preview',
        {'query': query},
      );

  _ida.Future<_izuu9p5h.CalendarAvailabilityReceipt?> deleteRule(
    _isc.UuidValue availabilityId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_izuu9p5h.CalendarAvailabilityReceipt?>(
    'serverpod_calendar.calendarAvailability',
    'deleteRule',
    {
      'availabilityId': availabilityId,
      'expectedRevision': expectedRevision,
    },
  );
}

/// {@category Endpoint}
class EndpointCalendarAvailabilitySearch extends _isc.EndpointRef {
  EndpointCalendarAvailabilitySearch(_isc.EndpointCaller caller)
    : super(caller);

  @override
  String get name => 'serverpod_calendar.calendarAvailabilitySearch';

  _ida.Future<_ieqmn71v.CalendarAvailabilitySearchView> search(
    _inwpo91l.CalendarAvailabilitySearchQuery query,
  ) => caller.callServerEndpoint<_ieqmn71v.CalendarAvailabilitySearchView>(
    'serverpod_calendar.calendarAvailabilitySearch',
    'search',
    {'query': query},
  );
}

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

  _ida.Future<_i2cb1v6y.CalendarFreeBusyView> freeBusy(
    _isyn5yvo.CalendarFreeBusyQuery query,
  ) => caller.callServerEndpoint<_i2cb1v6y.CalendarFreeBusyView>(
    'serverpod_calendar.calendar',
    'freeBusy',
    {'query': query},
  );

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
    _in004d9w.CalendarCategoryFilter? categoryFilter,
  }) => caller.callServerEndpoint<_iq8vfd61.CalendarPage>(
    'serverpod_calendar.calendar',
    'list',
    {
      'pageSize': pageSize,
      'fieldGroups': fieldGroups,
      'cursor': cursor,
      'categoryFilter': categoryFilter,
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

  _ida.Future<_ibyc2v98.CalendarMutationReceipt?> updateSupplementalMetadata(
    _i18zqkab.CalendarSupplementalMetadataUpdateRequest request,
  ) => caller.callServerEndpoint<_ibyc2v98.CalendarMutationReceipt?>(
    'serverpod_calendar.calendar',
    'updateSupplementalMetadata',
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

/// {@category Endpoint}
class EndpointCalendarEvent extends _isc.EndpointRef {
  EndpointCalendarEvent(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_calendar.calendarEvent';

  _ida.Future<_ieh64e0q.CalendarEventReceipt?> create(
    _iwlxheag.CalendarEventCreateRequest request,
  ) => caller.callServerEndpoint<_ieh64e0q.CalendarEventReceipt?>(
    'serverpod_calendar.calendarEvent',
    'create',
    {'request': request},
  );

  _ida.Future<_ixldy3zv.CalendarEventView> getEvent(
    _isc.UuidValue eventId,
    List<_icxx5h8a.CalendarEventFieldGroup> groups,
  ) => caller.callServerEndpoint<_ixldy3zv.CalendarEventView>(
    'serverpod_calendar.calendarEvent',
    'getEvent',
    {
      'eventId': eventId,
      'groups': groups,
    },
  );

  _ida.Future<_i8kstbs4.CalendarEventPage> list(
    _isc.UuidValue calendarId, {
    required int pageSize,
    required List<_icxx5h8a.CalendarEventFieldGroup> fieldGroups,
    String? cursor,
  }) => caller.callServerEndpoint<_i8kstbs4.CalendarEventPage>(
    'serverpod_calendar.calendarEvent',
    'list',
    {
      'calendarId': calendarId,
      'pageSize': pageSize,
      'fieldGroups': fieldGroups,
      'cursor': cursor,
    },
  );

  _ida.Future<_iz6iah5n.CalendarEventOccurrencePreview> preview(
    _iejw8qh7.CalendarEventOccurrenceQuery query,
  ) => caller.callServerEndpoint<_iz6iah5n.CalendarEventOccurrencePreview>(
    'serverpod_calendar.calendarEvent',
    'preview',
    {'query': query},
  );

  _ida.Future<_ieh64e0q.CalendarEventReceipt?> update(
    _itsbll8l.CalendarEventUpdateRequest request,
  ) => caller.callServerEndpoint<_ieh64e0q.CalendarEventReceipt?>(
    'serverpod_calendar.calendarEvent',
    'update',
    {'request': request},
  );

  _ida.Future<_ieh64e0q.CalendarEventReceipt?> changeStatus(
    _ignysrxk.CalendarEventStatusRequest request,
  ) => caller.callServerEndpoint<_ieh64e0q.CalendarEventReceipt?>(
    'serverpod_calendar.calendarEvent',
    'changeStatus',
    {'request': request},
  );

  _ida.Future<_ieh64e0q.CalendarEventReceipt?> changeOccurrence(
    _ir37u2ww.CalendarEventOccurrenceChange request,
  ) => caller.callServerEndpoint<_ieh64e0q.CalendarEventReceipt?>(
    'serverpod_calendar.calendarEvent',
    'changeOccurrence',
    {'request': request},
  );

  _ida.Future<_ieh64e0q.CalendarEventReceipt?> deleteEvent(
    _isc.UuidValue eventId,
    int expectedRevision,
  ) => caller.callServerEndpoint<_ieh64e0q.CalendarEventReceipt?>(
    'serverpod_calendar.calendarEvent',
    'deleteEvent',
    {
      'eventId': eventId,
      'expectedRevision': expectedRevision,
    },
  );
}

class Caller extends _isc.ModuleEndpointCaller {
  Caller(_isc.ServerpodClientShared client) : super(client) {
    calendarAvailability = EndpointCalendarAvailability(this);
    calendarAvailabilitySearch = EndpointCalendarAvailabilitySearch(this);
    calendarDiagnostics = EndpointCalendarDiagnostics(this);
    calendar = EndpointCalendar(this);
    calendarEvent = EndpointCalendarEvent(this);
  }

  late final EndpointCalendarAvailability calendarAvailability;

  late final EndpointCalendarAvailabilitySearch calendarAvailabilitySearch;

  late final EndpointCalendarDiagnostics calendarDiagnostics;

  late final EndpointCalendar calendar;

  late final EndpointCalendarEvent calendarEvent;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'serverpod_calendar.calendarAvailability': calendarAvailability,
    'serverpod_calendar.calendarAvailabilitySearch': calendarAvailabilitySearch,
    'serverpod_calendar.calendarDiagnostics': calendarDiagnostics,
    'serverpod_calendar.calendar': calendar,
    'serverpod_calendar.calendarEvent': calendarEvent,
  };
}
