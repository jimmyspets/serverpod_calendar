part of 'calendar_module.dart';

extension CalendarInvitationResponseOccurrenceOperations on CalendarService {
  Future<
    ({
      CalendarInvitationResponsePolicyContext context,
      CalendarFailureCode? error,
    })
  >
  _irEvidence(
    CalendarInvitationResponsePolicyContext context,
    Transaction tx,
  ) async {
    CalendarInvitationOccurrenceBasis? basis;
    CalendarFailureCode? error;
    final original = context.invitation.originalStart;
    if (original != null) {
      try {
        final entry = await _invEntry(
          context.invitation.id,
          context.recipient,
          tx,
        );
        _invNonRange(entry);
        final entries = await _invEntries(context.recipient, tx);
        final master = entries
            .where(
              (e) =>
                  e.correlationDigest == entry.correlationDigest &&
                  e.targetKey == 'master',
            )
            .firstOrNull;
        if (master == null ||
            master.kind == CalendarInvitationSourceKind.request &&
                master.recurring &&
                master.currentSourceId == null) {
          final link = await CalendarInvitationLinkRecord.db.findFirstRow(
            _session,
            where: (t) =>
                t.scopeKey.equals(context.recipient.scopeKey) &
                t.recipientKey.equals(context.recipient.key) &
                t.correlationDigest.equals(entry.correlationDigest),
            transaction: tx,
          );
          if (link == null) throw _failure(CalendarFailureCode.unavailable);
        }
        basis = await _invOccurrenceBasis(
          context.recipient,
          entries,
          entry.correlationDigest,
          entry.uid,
          entry.organizer,
          original,
          tx,
        );
      } on CalendarException catch (e) {
        // Budget exhaustion never proves that an original has disappeared.
        error = e.code == CalendarFailureCode.limitExceeded
            ? CalendarFailureCode.unavailable
            : e.code;
      }
    }
    final source = context.sourceMessage;
    final canSend =
        context.currentState.canSend &&
        source?.method == IcalendarSchedulingMethod.request &&
        source!.events.single.status != IcalendarEventStatus.cancelled &&
        (original == null || basis != null);
    return (
      context: context.withOccurrence(
        basis: basis,
        unavailable: error == CalendarFailureCode.unavailable,
        state: context.currentState.copyWith(canSend: canSend),
      ),
      error: error,
    );
  }
}
