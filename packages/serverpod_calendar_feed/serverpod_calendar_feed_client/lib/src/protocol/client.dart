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
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_created_credential.dart'
    as _i5f8j021;
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_credential_view.dart'
    as _igll1u2j;
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_settings.dart'
    as _iqpq2qob;
import 'package:serverpod_calendar_feed_client/src/protocol/calendar_feed_view.dart'
    as _i8pso0cp;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// {@category Endpoint}
class EndpointCalendarFeed extends _isc.EndpointRef {
  EndpointCalendarFeed(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'serverpod_calendar_feed.calendarFeed';

  _ida.Future<List<_i8pso0cp.CalendarFeedView>> list() =>
      caller.callServerEndpoint<List<_i8pso0cp.CalendarFeedView>>(
        'serverpod_calendar_feed.calendarFeed',
        'list',
        {},
      );

  _ida.Future<_i8pso0cp.CalendarFeedView> read(_isc.UuidValue id) =>
      caller.callServerEndpoint<_i8pso0cp.CalendarFeedView>(
        'serverpod_calendar_feed.calendarFeed',
        'read',
        {'id': id},
      );

  _ida.Future<_i8pso0cp.CalendarFeedView> create(
    _iqpq2qob.CalendarFeedSettings settings,
  ) => caller.callServerEndpoint<_i8pso0cp.CalendarFeedView>(
    'serverpod_calendar_feed.calendarFeed',
    'create',
    {'settings': settings},
  );

  _ida.Future<_i8pso0cp.CalendarFeedView> update(
    _isc.UuidValue id,
    int expectedRevision,
    _iqpq2qob.CalendarFeedSettings settings,
  ) => caller.callServerEndpoint<_i8pso0cp.CalendarFeedView>(
    'serverpod_calendar_feed.calendarFeed',
    'update',
    {
      'id': id,
      'expectedRevision': expectedRevision,
      'settings': settings,
    },
  );

  _ida.Future<void> delete(
    _isc.UuidValue id,
    int expectedRevision,
  ) => caller.callServerEndpoint<void>(
    'serverpod_calendar_feed.calendarFeed',
    'delete',
    {
      'id': id,
      'expectedRevision': expectedRevision,
    },
  );

  _ida.Future<List<_igll1u2j.CalendarFeedCredentialView>> credentials(
    _isc.UuidValue feedId,
  ) => caller.callServerEndpoint<List<_igll1u2j.CalendarFeedCredentialView>>(
    'serverpod_calendar_feed.calendarFeed',
    'credentials',
    {'feedId': feedId},
  );

  _ida.Future<_i5f8j021.CalendarFeedCreatedCredential> createCredential(
    _isc.UuidValue feedId,
    int expectedFeedRevision,
    String? label,
  ) => caller.callServerEndpoint<_i5f8j021.CalendarFeedCreatedCredential>(
    'serverpod_calendar_feed.calendarFeed',
    'createCredential',
    {
      'feedId': feedId,
      'expectedFeedRevision': expectedFeedRevision,
      'label': label,
    },
  );

  _ida.Future<void> revokeCredential(
    _isc.UuidValue feedId,
    int expectedFeedRevision,
    _isc.UuidValue credentialId,
    int expectedRevision,
  ) => caller.callServerEndpoint<void>(
    'serverpod_calendar_feed.calendarFeed',
    'revokeCredential',
    {
      'feedId': feedId,
      'expectedFeedRevision': expectedFeedRevision,
      'credentialId': credentialId,
      'expectedRevision': expectedRevision,
    },
  );
}

class Caller extends _isc.ModuleEndpointCaller {
  Caller(_isc.ServerpodClientShared client) : super(client) {
    calendarFeed = EndpointCalendarFeed(this);
  }

  late final EndpointCalendarFeed calendarFeed;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'serverpod_calendar_feed.calendarFeed': calendarFeed,
  };
}
