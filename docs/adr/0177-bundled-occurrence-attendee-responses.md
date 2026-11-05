# ADR 0177: Independent occurrence responses to bundled invitations

Status: **Proposed mechanics; explicit maintainer agreement required before implementation.** The maintainer confirmed that any validated original occurrence may be selected, including one without an explicit exception, using the effective master/range/single version and keeping its response separate from the master. That policy approval does not yet approve the schema/API mechanics below.

## Context and inspected evidence

[ADR 0176](0176-bundled-master-attendee-responses.md) implements explicit bundle master replies in [PR #184](https://github.com/jimmyspets/serverpod_calendar/pull/184). Its complete affected local group passed, including 422 invitation/MIME integration tests, two-process loss recovery and connected Flutter. Application commit 3009c00 was followed by documentation-only UTF-8 repair faf354c. Replacement [hosted run 42090565471](https://github.com/jimmyspets/serverpod_calendar/actions/runs/42090565471) passed inspection; full runtime remains pending at proposal inspection. No full hosted runtime success is claimed.

Existing response state is unique by scope, recipient and invitation entry. This works for master replies and separately received instance entries under [ADR 0153](0153-explicit-single-instance-attendee-responses.md), but a complete bundle has one entry covering many originals. Reusing its master state would overwrite unrelated participation choices. Existing worker, retry, quota, pruning and source-version checks also assume one state per entry.

Inspected the three response table sources, command/view DTOs, foreground authorization/record validation, worker, complete-bundle validation and component-version helpers, ordinary instance basis resolver, synthetic MIME, generated-client and Flutter harnesses. Open PRs include prerequisite #184; no overlapping occurrence-response PR or open issue was returned.

[RFC 5546 section 3.2.3](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.3) describes REPLY component identity and versions; [section 3.7.1](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.7.1) distinguishes an occurrence's original identity from moved timing. The target selection, whole-packet freshness and bounded storage rules here are application policy, not a claim that the RFC prescribes this database design.

## One grouped implementation

Implement pure target/version resolution, durable per-original private state/delivery, dedicated APIs/host authority, generated clients, synthetic MIME/organizer reconciliation, Flutter controls, migration and recovery tests together. No intermediate feature code commits. Resolve prerequisite hosted failures before new runtime work is considered ready. No source/model/runtime changes are approved merely by merging this proposal.

## Original identity and effective version

Fully validate the pinned supported REQUEST bundle, including all components, participants, versions, zones and current property/VALARM rejections, before selecting a target. Use one shared bounded raw-byte/component/recurrence budget. Prove exact recurrence membership with the existing supported DATE/UTC/named-zone profile: include DTSTART/RRULE/RDATE/PERIOD additions and apply exclusions. Reject mismatched kind/exact zone, non-start-only identities, fractions, invalid/excluded originals and exhausted work without nearest-date matching, alias conversion or partial success.

The selected identity is the unmodified original, even when moved by a single or future timing change. Resolve the controlling source component: exact single first, otherwise the latest applicable future component, otherwise master. Preserve independently optional SEQUENCE and actual source DTSTAMP from that component; do not use the largest bundle sequence or the currently adopted native event's version. Select the single at an anchor when the existing supported profile permits both single and future timing to participate; retain all existing profile rejections otherwise. Reject a new send for an effectively cancelled target or cancelled master, unavailable source or unsupported ambiguous data. Retained authorized history/retries remain independent of current eligibility.

Generate one minimal REPLY for that original with RECURRENCE-ID, no RANGE, exact optional controlling SEQUENCE, actual new database-second DTSTAMP, approved organizer and one verified attendee/PARTSTAT. Preserve exact named-zone identity and supply the required validated zone envelope. Omit timing, recurrence, source text, attachments and alarms. This is a response to one original, including when its effective timing came from a range; it never accepts a suffix or acknowledges siblings.

## Proposed public API and host context

Add `CalendarInvitationBundleOccurrenceResponseRequest`, an immutable wrapper containing the existing `CalendarInvitationResponseRequest` as `request` and required start-only `CalendarEventTiming originalStart`. Snapshot both nested command and typed identity before awaiting; final wrapper fields alone do not freeze a mutable nested DTO. Do not add fields to the old command DTO or change retained ordinary/master command JSON hashes.

Add dedicated `bundleOccurrenceResponse(invitationId, originalStart)`, `bundleOccurrenceResponseActivity(invitationId, originalStart)` and `sendBundleOccurrenceResponse(request)` APIs. The read returns a new immutable `CalendarInvitationBundleOccurrenceResponseView` containing `response` (the existing protected response view), `invitationRevision`, nullable `currentSourceId` and nullable `componentVersion` (the existing immutable CalendarInvitationBundleComponentVersion). This separates the currently validated invitation component from the last recorded personal choice, including before the first reply. The current packet ID/revision and component proof come from one authorized transaction. A master component has no component original; a controlling range can have a different anchor from the selected response original. componentVersion is absent when current eligibility cannot be established; canSend is then false.

For this target, response.originalStart is the requested original; its recorded sourceSequence/sourceStamp and activity values describe the component actually answered, while sourceId/sourceRevision pin that complete packet. Reuse existing activity/receipt DTOs, with a bounded private activity list for the requested target and no totals or sibling content. A zero-state query requires current validated membership; missing current evidence cannot manufacture a valid target. Existing retained target history can remain readable when a later packet removes that original, while canSend is false. Missing retained evidence fails unavailable when needed for a retry. Neither new wrapper changes legacy command JSON or existing view fields.

Add `readBundleOccurrence`, `sendBundleOccurrence` and `dispatchBundleOccurrence` host operations in addition to ordinary response read/send/dispatch. The host receives the actual private invitation/whole source and an explicit response original plus controlling-component version, separately from the minimal outgoing reply. Keep raw-source/private-summary access, verified recipient/attendee and approved route checks. Native calendar adoption/read/edit rights neither grant response rights nor become prerequisites merely to respond. Background contexts contain no fabricated actor. Preserve preliminary/final checks and declared external-check races.

The example lets the user enter an original DATE or civil UTC/zoned start, validates it server-side and displays the exact original and effective invitation version before enabling an explicit choice/send. It must not substitute an exception's moved DTSTART. No new occurrence-list/cursor API is proposed; typed selection supports originals without a supplied exception. Keep no preselected participation, frozen uncertain commands, explicit refresh/new response and master controls separate.

## Proposed storage: existing tables, four columns and one index replacement

| Table | Proposed additions | Meaning |
| --- | --- | --- |
| CalendarInvitationResponseStateRecord | non-null `targetKey`, nullable `responseOriginalStart` | Stable private state identity within the invitation entry |
| CalendarInvitationResponseRecord | non-null `targetKey`, nullable `responseOriginalStart` | Immutable command/delivery target, separate from complete source identity |

`responseOriginalStart` uses the existing typed CalendarEventTiming value. Both tables default legacy targetKey to `entry`; legacy responseOriginalStart stays null. That namespace preserves existing ordinary, detached-instance and bundle-master identity exactly. A new bundle-occurrence target uses a distinct versioned prefix plus the canonical original key; its required typed original must match that key. Reject unknown namespaces/mismatches rather than guessing. Do not fabricate extra invitation entries or infer occurrence state from a master choice.

Replace the response-state unique index with `(scopeKey, recipientKey, entryId, targetKey)`. The global recipient command UUID uniqueness stays unchanged. Existing delivery/state references and attempts remain; no new table or attempt column is proposed. Generate the migration and verify fresh/upgrade databases. Existing rows retain IDs, revisions, stamps, source/receipt/payload hashes, delivery status and retry identity; upgrading sends nothing. Pre-beta breaking changes/fresh synthetic databases are authorized, but no reset of unidentified/development storage follows from this proposal.

For new bundle targets only, existing sourceSequence/sourceStamp fields record the controlling component tuple. Complete sourceId/sourceDigest still pin the entire packet; reconstruct and validate the controlling tuple from that retained bundle on retry/dispatch. Legacy `entry` targets keep their existing tuple semantics and hashes. No extra component-version column or copied source snapshot is needed.

Use a new `bundle-occurrence-response-v1` criteria family binding the old command JSON, canonical typed original and target key. Validate family from actual retained source/target evidence, not today's entry kind or an unchecked stored key. Same command UUID with different target/input/family rejects. Corrupt immutable evidence fails unavailable. Exact retained retries reauthorize and return the old receipt without reactivation, even when current source or native drafts changed.

## Independent choices, quotas and worker lifecycle

Revision/CAS, latest intent, actual strictly increasing database-second response stamps, supersession and lease fences apply per target. Master, different originals and separately received instance-entry responses stay independent; no implicit synchronization is proposed. Sending to one original withdraws only its prior pending intent. A changed complete selected packet, including unrelated child-only changes, withdraws unsent replies for every target pinned to the old packet, following ADR 0176's conservative freshness rule. Whole CANCEL likewise prevents new sends and withdraws pending work; later REQUEST receipt does not replay old choices.

Add/Apply/dismiss with the same selected source leave pending participation intent eligible despite inbox revision changes. Native content, adopted events, occurrence overrides, private reminders and calendar booking do not change when replying. Histories can report a recorded choice as historical without treating it as permission/current eligibility.

Keep all existing recipient/scope state, response, pending, byte, attempt, expiry and 30-day terminal-retention caps. All target states count toward the same 128-state recipient/4,096-state scope defaults; do not multiply those limits per invitation. Preserve the existing 32-retained-response ceiling per invitation entry as an aggregate across master and new targets, as well as the target's own limit; keep 512 per recipient/4,096 per scope. This intentionally conservative entry ceiling reuses the existing maxResponsesPerState bound rather than expanding admission. Overflow rejects, without automatic eviction or history loss. Pending admission counts other targets in the same entry toward the existing 16-recipient default; exclude only the exact intent being superseded, not every intent in that entry.

Audit all state lookups/updates, source pins, maintenance/pruning and entry deletion for multiple states per entry. Delivery-state updates use stateId plus generation; no `.single` or entry-wide supersession may clobber another target. Retained deliveries pin the complete source. Terminal history pruning preserves each target's revision/stamp/choice until entry pruning; entry pruning removes all target states only after retained references permit it. No retention/cap expansion, extra copied body or fabricated history is proposed.

Workers revalidate exact source/target/version/authority/generation/expiry and fenced leases before each submission/retry. Use stable delivery UUIDs and exact payload/MIME bytes across uncertain acceptance. Denial withdraws only the affected work; unavailable proof is bounded retryable. Provider acceptance does not prove organizer application/display. All transport remains synthetic.

## Complete acceptance

- Pure DATE/UTC/named-zone/DST, exact aliases, RRULE/RDATE/PERIOD/exclusions, moved single/range anchors, no explicit component, controlling optional-zero/omitted sequence and independent version tests; invalid membership/cancelled/unsupported inputs and shared-budget exhaustion.
- Fresh/upgrade schema tests preserving legacy rows, hashes, IDs, state/delivery/attempt references and exact retries; no inferred per-original response or migration-triggered send.
- Independent master/original/sibling state, per-target clocks/CAS/supersession, all permissions/final rollback, immutable nested callback/command/receipt snapshots, source/body/family/key corruption, stale/historical retries and per-entry/global state/pending/byte/retention bounds.
- Complete source changes versus unchanged-source Add/Apply/dismiss, native draft/booking/reminder isolation, deletion/pruning and source pins; no unknown result enabling a new send.
- Two real independent hosts with same/competing-target commands, simultaneous different targets, competing workers and actual loss before/after command commit and synthetic acceptance; stale-owner fencing, stable receipts/UUID/payload/MIME and cross-host source/access withdrawal.
- Trusted organizer MIME loopbacks resolving requested originals and their effective component versions, including no supplied exception and future timing; generated JWT clients and connected Flutter original selection/frozen retries.
- Focused feature iterations, then complete agreed pure VM/Chrome, SDK, migration, client, worker and Flutter checks before one code commit. Inspect actual exact-head full hosted conclusions before readiness. Preserve all existing complete CI coverage/read-only permissions.

## Alternatives and remaining scope

Only explicit exception targets would contradict the maintainer's any-original choice. Reusing master state would overwrite unrelated intent; creating artificial instance inbox entries would conflate source receipt and user selection. Per-target copied source bodies or larger caps are unnecessary. Master-first migration cannot infer occurrence acceptance from prior master replies.

RANGE responses, response fan-out, native participation synchronization, partial bundle reconciliation, source participant/delegation changes, VALARM-bearing scheduling messages, real mail and external-client interoperability remain separate required work. This proposed grouped increment does not claim full RFC 5546/6047 support.
