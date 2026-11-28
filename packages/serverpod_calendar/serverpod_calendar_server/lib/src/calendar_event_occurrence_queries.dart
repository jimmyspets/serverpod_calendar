part of 'calendar_module.dart';

final _occurrenceTimezoneIdentity = sha256
    .convert(utf8.encode(NamedZoneResolver.dataIdentityMaterial))
    .toString();
const _occurrenceRequiredGroups = {
  CalendarEventFieldGroup.timing,
  CalendarEventFieldGroup.state,
};

final class _CalendarOccurrenceRow {
  const _CalendarOccurrenceRow(this.item, this.start, this.originalKey);
  final CalendarEventOccurrenceListItem item;
  final DateTime start;
  final String originalKey;
}

extension CalendarEventOccurrenceQueries on CalendarService {
  Future<CalendarEventOccurrencePage> listEventOccurrences(
    CalendarEventOccurrenceListQuery input,
  ) async {
    final cursor = input.cursor;
    final extras = input.fieldGroups;
    if (extras.length > 3 ||
        !eventOccurrenceContentGroups.containsAll(extras) ||
        input.pageSize < 1 ||
        input.pageSize > min(100, _options.maxPageSize)) {
      throw _failure(CalendarFailureCode.validation);
    }
    final canonical = {..._occurrenceRequiredGroups, ...extras}.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final groups = Set<CalendarEventFieldGroup>.unmodifiable(canonical);
    final query = CalendarEventOccurrenceListQuery(
      calendarId: input.calendarId,
      fromUtc: input.fromUtc,
      untilUtc: input.untilUtc,
      pageSize: input.pageSize,
      includeCancelled: input.includeCancelled,
      fieldGroups: List.unmodifiable(
        extras.toSet().toList()..sort((a, b) => a.index.compareTo(b.index)),
      ),
    );
    late final UtcWindow window;
    try {
      TimedValue.utc(query.fromUtc);
      TimedValue.utcEnd(query.untilUtc);
      window = UtcWindow(start: query.fromUtc, end: query.untilUtc);
      if (window.duration > Duration(days: _options.maxOccurrenceQueryDays)) {
        throw ArgumentError('Query window too large');
      }
    } on ArgumentError {
      throw _failure(CalendarFailureCode.validation);
    }
    if (cursor != null && !RegExp(r'^[A-Za-z0-9_-]{43}$').hasMatch(cursor)) {
      throw _failure(CalendarFailureCode.invalidCursor);
    }
    final actor = await _context();
    try {
      return await _transaction(actor, (tx, scope) async {
        final parent = await _active(actor, query.calendarId, tx);
        final collection = _er(
          parent,
          CalendarPermission.listEventOccurrences,
          groups: groups,
          listQuery: query,
        );
        await _decide(actor, [collection], tx, CalendarAuthorizationPhase.read);
        CalendarCursorRecord? saved;
        if (cursor != null) {
          try {
            saved = await CalendarCursorRecord.db.findFirstRow(
              _session,
              where: (t) => t.token.equals(cursor),
              transaction: tx,
            );
          } on FormatException {
            throw _failure(CalendarFailureCode.invalidCursor);
          } on TypeError {
            throw _failure(CalendarFailureCode.invalidCursor);
          }
          final state = saved?.eventOccurrenceState;
          if (saved == null ||
              state == null ||
              state.version != 1 ||
              saved.scopeKey != actor.scopeKey ||
              saved.principalId != actor.principalId ||
              saved.policyRevision != actor.policyRevision ||
              saved.dataRevision != scope.revision ||
              saved.eventCalendarId != query.calendarId ||
              saved.pageSize != query.pageSize ||
              !saved.expiresAt.isAfter(await _revisionTime(tx)) ||
              saved.fieldGroups.isNotEmpty ||
              saved.taskCalendarId != null ||
              saved.taskFieldGroups != null ||
              saved.categoryFilter != null ||
              saved.alarmActivityId != null ||
              saved.alarmActivityKind != null ||
              saved.taskHistoryTaskId != null ||
              saved.taskHistoryOriginalKey != null ||
              saved.taskHistoryAfterRevision != null ||
              jsonEncode(saved.eventFieldGroups) != jsonEncode(canonical) ||
              state.fromUtc != query.fromUtc ||
              state.untilUtc != query.untilUtc ||
              !state.fromUtc.isUtc ||
              !state.untilUtc.isUtc ||
              !state.afterStartUtc.isUtc ||
              state.afterStartUtc.millisecond != 0 ||
              state.afterStartUtc.microsecond != 0 ||
              state.includeCancelled != query.includeCancelled ||
              state.timezoneIdentity != _occurrenceTimezoneIdentity) {
            throw _failure(CalendarFailureCode.invalidCursor);
          }
        }
        final plan = await _bounded(
          () => _runtime.policy.planEventOccurrenceQuery(
            _session,
            actor,
            parent.snapshot,
            query,
            groups,
            tx,
          ),
        );
        final scanCap = min(1000, _options.maxScannedEvents);
        if ((plan.eventIds?.length ?? 0) > scanCap) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final identities = await CalendarEventRecord.db.find(
          _session,
          where: (t) =>
              t.calendarId.equals(query.calendarId) & t.deletedAt.equals(null),
          orderBy: (t) => t.id,
          limit: scanCap + 1,
          transaction: tx,
        );
        if (identities.length > scanCap) {
          throw _failure(CalendarFailureCode.limitExceeded);
        }
        final work = EventOccurrenceQueryWork(
          maxWork: _options.maxOccurrenceCandidateWork,
          maxResults: _options.maxOccurrenceResults,
        );
        final visible = <_CalendarOccurrenceRow>[];
        final batchSize = max(1, _options.policyBatchSize ~/ 2);
        for (var offset = 0; offset < identities.length; offset += batchSize) {
          final events = <_Event>[];
          for (final identity in identities.skip(offset).take(batchSize)) {
            work.recurrence.charge();
            if (plan.eventIds != null &&
                !plan.eventIds!.contains(identity.id)) {
              continue;
            }
            // Historical import baselines are not part of ordinary detail
            // reads. Validate current state with the shared calculation budget.
            events.add(
              await _event(
                actor,
                identity.id!,
                tx,
                identity: identity,
                parent: parent,
                sharedWorkBudget: work.recurrence,
                validateImportBaseline: false,
              ),
            );
          }
          final requests = [
            for (final event in events) ...[
              _er(
                parent,
                CalendarPermission.readEvent,
                event: event,
                groups: groups,
                listQuery: query,
              ),
              _er(
                parent,
                CalendarPermission.previewEventOccurrences,
                event: event,
                groups: groups,
                listQuery: query,
              ),
            ],
          ];
          if (requests.isEmpty) continue;
          final decisions = <String, CalendarAuthorizationDecision>{};
          for (
            var offset = 0;
            offset < requests.length;
            offset += _options.policyBatchSize
          ) {
            decisions.addAll(
              await _decide(
                actor,
                requests.sublist(
                  offset,
                  min(offset + _options.policyBatchSize, requests.length),
                ),
                tx,
                CalendarAuthorizationPhase.read,
                filterDenied: true,
              ),
            );
          }
          for (final event in events) {
            final read =
                decisions['${CalendarPermission.readEvent.name}:${event.identity.id}']!;
            final preview =
                decisions['${CalendarPermission.previewEventOccurrences.name}:${event.identity.id}']!;
            final disclosed = groups
                .intersection(read.eventDisclosedGroups)
                .intersection(preview.eventDisclosedGroups);
            if (read.verdict != CalendarAuthorizationVerdict.allow ||
                preview.verdict != CalendarAuthorizationVerdict.allow ||
                !disclosed.containsAll(_occurrenceRequiredGroups)) {
              continue;
            }
            final projected = eventOccurrenceWindow(
              event.data.content,
              event.data.timingOverrides,
              window,
              dateZone: parent.data.availabilityZoneId,
              groups: disclosed,
              work: work,
            );
            for (final row in projected) {
              if (row.cancelled && !query.includeCancelled) continue;
              visible.add(
                _CalendarOccurrenceRow(
                  CalendarEventOccurrenceListItem(
                    eventId: event.identity.id!,
                    calendarId: query.calendarId,
                    revision: event.identity.revision,
                    originalStart: CalendarEventTiming(
                      kind: event.data.content.timing.kind,
                      zoneId: event.data.content.timing.zoneId,
                      start: row.occurrence.originalStart,
                    ),
                    occurrence: row.occurrence,
                    status: row.cancelled
                        ? CalendarEventStatus.cancelled
                        : event.data.content.status,
                    transparency: event.data.content.transparency,
                    cancelled: row.cancelled,
                    disclosedGroups: List.unmodifiable(
                      disclosed.toList()
                        ..sort((a, b) => a.index.compareTo(b.index)),
                    ),
                  ),
                  row.orderStart,
                  row.originalKey,
                ),
              );
            }
          }
        }
        visible.sort((a, b) {
          final time = a.start.compareTo(b.start);
          if (time != 0) return time;
          final id = a.item.eventId.toString().compareTo(
            b.item.eventId.toString(),
          );
          return id != 0 ? id : a.originalKey.compareTo(b.originalKey);
        });
        var begin = 0;
        if (saved != null) {
          final state = saved.eventOccurrenceState!;
          final index = visible.indexWhere(
            (v) =>
                v.item.eventId == saved!.afterId &&
                v.start == state.afterStartUtc &&
                v.originalKey == state.afterOriginalKey,
          );
          if (index < 0) throw _failure(CalendarFailureCode.invalidCursor);
          begin = index + 1;
        }
        await _decide(actor, [collection], tx, CalendarAuthorizationPhase.read);
        await _verifyContext(actor);
        final page = visible.skip(begin).take(query.pageSize).toList();
        String? next;
        if (visible.length > begin + page.length) {
          final now = await _revisionTime(tx);
          final expired = await CalendarCursorRecord.db.find(
            _session,
            where: (t) =>
                t.scopeKey.equals(actor.scopeKey) & (t.expiresAt < now),
            limit: _options.maxCursorsPerScope,
            transaction: tx,
          );
          if (expired.isNotEmpty) {
            await CalendarCursorRecord.db.delete(
              _session,
              expired,
              transaction: tx,
            );
          }
          if (await CalendarCursorRecord.db.count(
                _session,
                where: (t) => t.scopeKey.equals(actor.scopeKey),
                limit: _options.maxCursorsPerScope,
                transaction: tx,
              ) >=
              _options.maxCursorsPerScope) {
            throw _failure(CalendarFailureCode.limitExceeded);
          }
          final random = Random.secure();
          next = base64UrlEncode(List.generate(32, (_) => random.nextInt(256)))
              .replaceAll('=', '');
          final last = page.last;
          await CalendarCursorRecord.db.insertRow(
            _session,
            CalendarCursorRecord(
              token: next,
              scopeKey: actor.scopeKey,
              principalId: actor.principalId,
              policyRevision: actor.policyRevision,
              dataRevision: scope.revision,
              afterId: last.item.eventId,
              pageSize: query.pageSize,
              fieldGroups: [],
              eventCalendarId: query.calendarId,
              eventFieldGroups: canonical,
              eventOccurrenceState: CalendarEventOccurrenceCursorState(
                version: 1,
                fromUtc: query.fromUtc,
                untilUtc: query.untilUtc,
                includeCancelled: query.includeCancelled,
                afterStartUtc: last.start,
                afterOriginalKey: last.originalKey,
                timezoneIdentity: _occurrenceTimezoneIdentity,
              ),
              expiresAt: now.add(_options.cursorLifetime),
            ),
            transaction: tx,
          );
        }
        return CalendarEventOccurrencePage(
          occurrences: List.unmodifiable(page.map((v) => v.item)),
          nextCursor: next,
        );
      });
    } on RecurrenceLimitException {
      throw _failure(CalendarFailureCode.limitExceeded);
    } on ZoneCoverageException {
      throw _failure(CalendarFailureCode.unavailable);
    } on ArgumentError {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
}
