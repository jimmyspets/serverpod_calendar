part of 'calendar_module.dart';

extension CalendarInvitationOccurrenceOperations on CalendarService {
  Future<CalendarInvitationOccurrenceBasis> _invOccurrenceBasis(
    CalendarInvitationRecipient recipient,
    List<CalendarInvitationRecord> entries,
    String correlation,
    String uid,
    String organizer,
    CalendarEventTiming original,
    Transaction tx,
  ) async {
    try {
      final master = entries
          .where(
            (e) =>
                e.correlationDigest == correlation && e.targetKey == 'master',
          )
          .firstOrNull;
      if (master != null &&
          (master.uid != uid || master.organizer != organizer)) {
        throw _failure(CalendarFailureCode.unavailable);
      }
      if (master != null &&
          (master.kind != CalendarInvitationSourceKind.request ||
              !master.recurring)) {
        throw _failure(CalendarFailureCode.validation);
      }
      CalendarInvitationOccurrenceBasis? basis;
      if (master?.currentSourceId != null) {
        final view = await _invView(master!, tx);
        final source = await CalendarInvitationSourceRecord.db.findById(
          _session,
          master.currentSourceId!,
          transaction: tx,
        );
        if (source == null) throw _failure(CalendarFailureCode.unavailable);
        final message = _invStored(source, master);
        final content = _invRequestProposal(message).content;
        basis = CalendarInvitationOccurrenceBasis(
          kind: CalendarInvitationOccurrenceBasisKind.retainedMaster,
          originalStart: original,
          content: content,
          sequence: source.sequence,
          stamp: source.stamp,
          sourceId: source.id,
          master: view,
          message: message,
        );
        if (!message.events.single.participants.attendees.any(
          (a) => a.address == recipient.calendarAddress,
        )) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
      } else {
        final candidate = await CalendarInvitationLinkRecord.db.findFirstRow(
          _session,
          where: (t) =>
              t.scopeKey.equals(recipient.scopeKey) &
              t.recipientKey.equals(recipient.key) &
              t.correlationDigest.equals(correlation),
          transaction: tx,
        );
        if (candidate == null) throw _failure(CalendarFailureCode.accessDenied);
        final link = await _invFindLink(
          candidate.invitationId,
          master,
          recipient,
          tx,
        );
        if (link == null || link.uid != uid || link.organizer != organizer) {
          throw _failure(CalendarFailureCode.unavailable);
        }
        final event = await _invLinkedEventScope(link, recipient.scopeKey, tx);
        final accepted = _invApplicationState(
          link,
          event,
          await _invCheckpoint(link, event, tx),
        );
        if (accepted.kind != CalendarInvitationSourceKind.request) {
          throw _failure(CalendarFailureCode.validation);
        }
        final baseline = event.data.importBaseline!;
        final (content, roster) = _eventProtocolValue(() {
          validateEventImportBaseline(baseline, link.uid);
          final decoded =
              jsonDecode(baseline.canonicalValue) as Map<String, dynamic>;
          final protocol = decoded['protocol'] as Map<String, dynamic>;
          final metadata = protocol['sourceMetadata'] as Map<String, dynamic>;
          return (
            CalendarEventContent.fromJson(
              decoded['content'] as Map<String, dynamic>,
            ),
            (metadata['attendees'] as List? ?? []).cast<Map<String, dynamic>>(),
          );
        });
        if (!roster.any((a) => a['address'] == recipient.calendarAddress)) {
          throw _failure(CalendarFailureCode.accessDenied);
        }
        basis = CalendarInvitationOccurrenceBasis(
          kind: CalendarInvitationOccurrenceBasisKind.acceptedBaseline,
          originalStart: original,
          content: content,
          sequence: accepted.sequence,
          stamp: accepted.stamp,
          master: master == null ? null : await _invView(master, tx),
          link: _invLinkReceipt(link),
          accepted: accepted,
          baseline: baseline,
        );
      }
      if (basis.content.recurrence == null ||
          !_eventReplacementValue(
            () => eventSchedulingMember(
              basis!.content,
              original,
              sharedWorkBudget: RecurrenceWorkBudget(
                maxWork: eventMaxCandidateWork,
              ),
            ),
          )) {
        throw _failure(CalendarFailureCode.validation);
      }
      return basis;
    } on CalendarException {
      rethrow;
    } catch (_) {
      throw _failure(CalendarFailureCode.unavailable);
    }
  }
}
