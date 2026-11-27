part of 'calendar_module.dart';

extension CalendarAvailabilityExportOperations on CalendarService {
  Future<ByteData> exportAvailability(
    CalendarAvailabilityExportRequest input,
  ) async {
    if (input.selection.isEmpty ||
        input.selection.length > availabilityMaxDefinitions) {
      throw _failure(CalendarFailureCode.limitExceeded);
    }
    final selection = List<CalendarAvailabilityExportSelection>.unmodifiable(
      input.selection,
    );
    if (selection.map((s) => s.availabilityId).toSet().length !=
            selection.length ||
        input.expectedRevision < 1 ||
        input.expectedRevision > CalendarService._maxRevision ||
        selection.any(
          (s) =>
              s.expectedRevision < 1 ||
              s.expectedRevision > CalendarService._maxRevision,
        )) {
      throw _failure(CalendarFailureCode.validation);
    }
    final c = await _context();
    return _transaction(c, (tx, _) async {
      final parent = await _active(c, input.calendarId, tx);
      // Authorize the actual destination before resolving selected object IDs.
      await _decide(
        c,
        [_ar(parent, CalendarPermission.exportAvailability)],
        tx,
        CalendarAuthorizationPhase.read,
      );
      final members = <_Availability>[];
      for (final target in selection) {
        final member = await _availability(c, target.availabilityId, tx);
        if (member.identity.calendarId != parent.identity.id) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        members.add(member);
      }
      members.sort((a, b) => a.data.protocolUid.compareTo(b.data.protocolUid));
      final intent = CalendarAvailabilityExportIntent(
        members.map((m) => m.snapshot),
      );
      CalendarAuthorizationRequest request(
        CalendarPermission op, [
        _Availability? member,
      ]) => CalendarAuthorizationRequest(
        key: '${op.name}:${member?.identity.id ?? parent.identity.id}',
        operation: op,
        calendarId: parent.identity.id,
        current: parent.snapshot,
        availabilityId: member?.identity.id,
        currentAvailability: member?.snapshot,
        availabilityExport: intent,
      );
      final requests = [
        request(CalendarPermission.exportAvailability),
        for (final member in members) ...[
          request(CalendarPermission.exportAvailability, member),
          request(CalendarPermission.readAvailability, member),
        ],
      ];
      Future<void> authorize() async {
        await _verifyContext(c);
        for (var i = 0; i < requests.length; i += _options.policyBatchSize) {
          await _decide(
            c,
            requests.sublist(
              i,
              min(i + _options.policyBatchSize, requests.length),
            ),
            tx,
            CalendarAuthorizationPhase.read,
          );
        }
        await _verifyContext(c);
      }

      await authorize();
      if (parent.identity.revision != input.expectedRevision ||
          members.any(
            (m) =>
                m.identity.revision !=
                selection
                    .singleWhere((s) => s.availabilityId == m.identity.id)
                    .expectedRevision,
          )) {
        throw _failure(CalendarFailureCode.staleRevision);
      }
      late final Uint8List bytes;
      try {
        bytes = availabilityExportBytes(
          members.map((m) => m.view).toList(),
          extensions: IcalendarAvailabilityExtensionRegistry([
            for (final r in _runtime.availabilityExtensions.values)
              IcalendarAvailabilityExtensionRegistration(
                name: r.name,
                contexts: r.contexts.map(
                  (v) => switch (v) {
                    CalendarAvailabilityExtensionContext.definition =>
                      IcalendarAvailabilityExtensionContext.definition,
                    CalendarAvailabilityExtensionContext.opening =>
                      IcalendarAvailabilityExtensionContext.opening,
                  },
                ),
                validateText: (_) => true,
              ),
          ]),
        );
      } on IcalendarSyntaxException catch (e) {
        throw _failure(
          e.kind == IcalendarSyntaxError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on IcalendarComponentException catch (e) {
        throw _failure(
          e.kind == IcalendarComponentError.limitExceeded
              ? CalendarFailureCode.limitExceeded
              : CalendarFailureCode.validation,
        );
      } on RecurrenceLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      } on AvailabilityLimitException {
        throw _failure(CalendarFailureCode.limitExceeded);
      } on ArgumentError {
        throw _failure(CalendarFailureCode.validation);
      } on ZoneCoverageException {
        throw _failure(CalendarFailureCode.validation);
      }
      // No publication/organizer ownership is implied by exporting stored data.
      // Current installed extension validators still govern emitted private data.
      for (final member in members) {
        for (final source in [
          (
            CalendarAvailabilityExtensionContext.definition,
            member.data.content.extensions,
          ),
          for (final o in member.data.content.openings)
            (CalendarAvailabilityExtensionContext.opening, o.extensions),
        ]) {
          for (final value in source.$2 ?? <CalendarAvailabilityExtension>[]) {
            final registration =
                _runtime.availabilityExtensions[value.name.toUpperCase()];
            if (registration == null ||
                !registration.contexts.contains(source.$1)) {
              throw _failure(CalendarFailureCode.validation);
            }
            if (!await _bounded(
              () async => registration.validate(value.value),
            )) {
              throw _failure(CalendarFailureCode.validation);
            }
          }
        }
      }
      // Reauthorize after serialization; no partial bytes are streamed or cached.
      await authorize();
      return ByteData.sublistView(bytes);
    });
  }
}
