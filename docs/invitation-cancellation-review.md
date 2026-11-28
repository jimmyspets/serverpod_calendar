# Incoming whole-meeting cancellation review

Accepted [ADR 0140](adr/0140-trusted-cancellation-intake-and-review.md) extends trusted invitation intake with bounded non-recurring whole-meeting CANCEL notices. The scoped implementation and batch validation are complete; see [the evidence](scaffold-validation.md). Receipt and dismissal affect private review only. They do not cancel the linked event, change its busy time, replace its baseline/checkpoint, change personal alarms or queue a reply/notification.

## Accepted source and authority

The durable profile accepts exactly one non-recurring CANCEL with explicit STATUS:CANCELLED and source UID, ORGANIZER, SEQUENCE and DTSTAMP. An ATTENDEE must match the actual host-verified transport recipient. No missing participant, summary, start or span is invented. The pure adapter is broader: attendee removal without STATUS, detached/range/recurring messages and other methods remain outside this durable slice. Delegation/SENT-BY remains rejected.

A known queue entry/retained marker or stable creation link must match trusted scope/recipient and exact UID/organizer correlation. Unknown cancellation rejects without creating a queue marker or calendar event. Participant strings, transport carriers and guessed UIDs do not establish authority. The host verifies sender/actual target and mapping again at final transaction checks.

Both ordinary receive and independent receiveCancellation operations must permit intake, including exact/equivalent retries. Private list/summary/source/dismiss permissions stay independent. Linked source context contains the actual creation descriptor, accepted REQUEST checkpoint and current native snapshot, without manufacturing an authenticated actor from a transport recipient. Missing/deleted/corrupt required linked evidence is marked unavailable and rejects; no weaker fallback is used. Read-only transport review does not grant native event access to a user.

## Versions, duplicate handling and transactions

A genuinely new cancellation must increment every known correlated REQUEST SEQUENCE, including the accepted source behind a stable link after queue expiry. An equal sequence with a later DTSTAMP cannot cancel that REQUEST. Competing cancellation notices otherwise use SEQUENCE then DTSTAMP ordering; source omissions/spelling remain preserved. Later REQUEST intake retains its existing ordering and review-only behavior.

Retained exact delivery keys return their original receipt after fresh authority. Equivalent sources reuse source identity with a duplicate result. Neither path reopens dismissed review or dismisses a newer pending source. Same-version differing bodies conflict. A stale new source cannot manufacture a replacement queue after expiry. A digest-only marker without a retained body cannot establish exact duplicate text equality and fails unavailable.

The shared database scope transaction coordinates intake, update application and native writes across instances. Selected cancellation source/receipt, current kind, invitation revision and dismissal reset commit together. Final policy denial, unavailable evidence and bounds roll back all changes. Event revisions, accepted application rows, scope/feed generation, alarms and outbound intent are untouched by cancellation receipt/dismissal.

## Storage and protected views

CalendarInvitationSourceKind contains request and meetingCancellation. CalendarInvitationRecord stores the selected kind even after body pruning. Its generated migration defaults legacy rows to request because the previously supported durable profile admitted only REQUEST; this is not a guess about arbitrary historical files. No new table or copied event-content snapshot is added. Summary, source-history, source-document and incoming application views expose the appropriate kind.

Historical sources validate their own method independently of the current selected kind. Current bodies must agree with the entry kind. Cancellation without DTSTART has no CalendarEventTiming; an independently supplied DTEND stays in the protected raw source. Missing summary does not acquire a placeholder in storage. Ordinary date/zone/whole-second profile checks and raw-source budgets remain in force.

Existing link reads/application review still show the current accepted REQUEST and local event separately from the incoming cancellation. Incoming kind/text remain available through independent source authority; canApply is false and incomingContent is absent for CANCEL. Add to calendar and Apply update retain explicit REQUEST guards before METHOD removal. Original creation and latest accepted REQUEST retry receipts remain unchanged and do not dismiss newer cancellation review. This is not explicit cancellation application or automatic reopening.

## Example, migration and remaining work

The development/test-only simulator generates a minimal cancellation for a known synthetic invitation with a stable command key. Queue/source/link review labels cancellation and omitted timing explicitly; the linked-event view says that the calendar event is unchanged and offers no Apply cancellation control. Raw source is inert text; no links are fetched. A failed simulation retains its original command/body selection for retry.

Pinned generation produced module migration 20261029170456299-cancellation-review and example migration 20261029170510929-cancellation-review. Fresh and populated upgrades must retain prior rows and classify legacy markers without invented history. Upgrade every participating host before enabling the new kind; mixed old/new operation is not supported. Development data is not reset.

Explicit cancellation application/reopening, attendee removal, recurring/instance/range intake, participation responses, link purge/relink, RFC 6047 mail and external-client conformance remain separate required work. The existing queue/link/source/checkpoint capacities and retention policies remain unchanged.
