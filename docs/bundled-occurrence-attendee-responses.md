# Responses to individual originals in invitation bundles

[Accepted ADR 0177](adr/0177-bundled-occurrence-attendee-responses.md) extends [bundle master responses](bundled-master-attendee-responses.md) with independent personal Accept/Tentative/Decline choices for any validated original occurrence. Implementation validation is recorded separately in [the validation record](scaffold-validation.md); this is a bounded scheduling profile, not complete interoperability.

## Selection and versions

Select the original DATE or civil UTC/named-zone start before any move. It need not have its own exception component. The server validates the complete supported packet, exact kind/zone, recurrence membership, RDATE/PERIOD additions and exclusions under a shared work budget. It rejects nonmembers, fractional timing, unsupported source data and exhausted work rather than guessing or returning partial proof. ISO/native recurrence and explicit WKST rules remain unchanged.

The controlling component is the exact single override, otherwise the latest applicable future component, otherwise the master. Its exact optional SEQUENCE and DTSTAMP determine the invitation version being answered. A future component can control an original later than its anchor. The source's largest sequence, moved DTSTART, native adopted event and device timezone do not choose the target/version.

One minimal REPLY carries that original RECURRENCE-ID, no RANGE, exact optional controlling SEQUENCE, an actual whole database-second DTSTAMP and the approved organizer/one verified attendee. A named original keeps its exact zone identifier and required validated timezone definition. It contains no source text, timing replacement, attachments or alarms. Replying changes no calendar, booking, native occurrence, private reminder or sibling/master participation.

## APIs and current versus recorded proof

| API | Result |
| --- | --- |
| bundleOccurrenceResponse(id, originalStart) | Atomic current packet/revision/component proof plus personal response state |
| bundleOccurrenceResponseActivity(id, originalStart) | Bounded private activity for that target, without totals |
| sendBundleOccurrenceResponse(request) | Explicit durable target response and immutable retry receipt |

The immutable read wrapper contains response, invitationRevision, currentSourceId and componentVersion. componentVersion describes the currently validated source component, including before the first response; its own original is null for a master or can be an earlier range anchor. response.originalStart always identifies the requested original. Recorded response/activity sourceSequence/sourceStamp describe the component actually answered, while their sourceId/sourceRevision pin its complete packet. Do not confuse a current component version with a historical choice.

The immutable send wrapper contains the existing CalendarInvitationResponseRequest and required start-only originalStart. The service snapshots nested command/typed identity before awaiting; host callbacks receive detached command/receipt copies. Old command JSON and ordinary/master criteria families remain unchanged.

A zero-state read needs valid current membership. Retained history can remain readable after a new packet removes the original, with canSend=false. Whole cancellation similarly prevents a new send, while retained authorized retries/history can remain available. Missing evidence fails unavailable; retries never reactivate withdrawn work.

## Host authorization

Enforce ordinary response read/send/dispatch plus readBundleOccurrence/sendBundleOccurrence/dispatchBundleOccurrence. Master permissions are separate; hosts may map the operations to the same rule if desired. Current private summary/raw-source access, trusted recipient/attendee identity and approved organizer route remain required. Native calendar rights neither grant reply rights nor become an adoption prerequisite.

The host receives the actual private invitation/complete source, explicit responseOriginalStart and responseComponentVersion, separately from the minimal outgoing message. Workers have no fabricated actor and recheck source, target, authority, generation, expiry and fenced leases. Coordinated versus external fresh-check guarantees and after-check revocation races remain declared as before. Source participant claims grant no authority.

## State, concurrency and retention

| Identity | Binding |
| --- | --- |
| Complete packet | sourceId/sourceDigest and the recorded invitation revision |
| Personal target | private targetKey and responseOriginalStart under the invitation entry |
| Answered component | exact independently optional sourceSequence and sourceStamp |

The existing state/delivery tables each add targetKey and nullable typed responseOriginalStart. The state unique index is scope/recipient/entry/target. Legacy rows receive entry/null defaults, including old detached-instance and bundle-master states; their original identity, payload/receipt/hash, revisions and retries remain intact. New originals use a distinct canonical namespace. Unknown or mismatched stored keys/typed originals fail unavailable, without guessing another family. No synthetic inbox entries or inferred per-original choices are created.

Each target has its own CAS revision, latest intent and strictly advancing actual database-second stamp. A new choice supersedes only that target's pending work. Other originals and the master stay independent. A different complete selected packet withdraws unsent work for every target pinned to the previous body, even when only an unrelated child changed. This whole-source freshness rule is conservative application policy. Add/Apply/dismiss with an unchanged source leave pending replies eligible despite inbox revision changes.

Defaults remain shared: 128 states per recipient/4,096 per scope, 16 pending replies per recipient, 512 retained responses per recipient/4,096 per scope and existing byte/attempt/expiry limits. The existing maxResponsesPerState bound also remains an aggregate 32-retained-response ceiling per invitation across master and occurrence targets. Capacity exhaustion rejects without automatic eviction. Pending admission excludes only the exact intent being superseded, counting siblings in the same entry.

Retained deliveries pin the complete source body. Terminal delivery/attempt history defaults to 30 days; each target's revision/stamp/choice survives until entry pruning. Retained ingress receipts and other approved references can also pin the source. Once all retention/reference conditions permit entry deletion, all of its target states are scrubbed. Pruning never turns a stale command into a new send. Uncertain acceptance retries keep the same delivery UUID and payload/MIME bytes; transport acceptance is not organizer application or display.

## Migration and example

Generated migrations are module 20261105201702355-bundle-occurrence-responses and example 20261105201822738-bundle-occurrence-responses. They add four columns and replace one index, without deleting legacy data or inventing occurrence history. The CLI's new-unique-index warning was reviewed: the old uniqueness constraint already guarantees uniqueness after the entry default is applied. Populated synthetic upgrade checks preserve prior source/command/receipt/hash/lease/attempt values and verify distinct versus duplicate targets. Fresh SDK storage is checked separately. Development storage is not reset by these tests.

The Flutter selector pre-fills known source civil fields, permits an explicit original/profile/zone selection and validates it server-side. It shows the exact original and effective invitation version before separate response/activity controls. A response need not add the invitation to a calendar. Refresh does not create another command; uncertain retries keep the original UUID and target.

All example MIME remains synthetic. RANGE replies, response fan-out, partial bundle reconciliation, delegation/source-participant changes, VALARM-bearing scheduling messages, real mail and external-client interoperability remain separate required work. No FCM/APNs or platform delivery is introduced.

Actual commands, counts and failed/repeated checks are recorded in [the validation record](scaffold-validation.md#adr-0177-grouped-occurrence-responses-2026-11-05).
