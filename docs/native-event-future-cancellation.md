# Native event future cancellation and restoration

Accepted [ADR 0158](adr/0158-native-event-future-cancellation.md) integrates the [pure core cutoff](event-future-cancellation-core.md) into native recurring events. It covers local actions, occurrence views, complete availability projections, reminders and Flutter. Incoming/outgoing range CANCEL reconciliation and a faithful standalone wire mapping remain separate.

## Actions and retained state

`CalendarEventTimingOverrides.cancelledFrom` is an optional start-only original identity in the existing active-data JSON column. A cutoff suppresses every original at/after it, including later moved singles and timing ranges. Comparison uses original DATE/civil fields in the exact UTC/named-zone profile. It never compares actual moved starts. Earlier originals moved later remain eligible; later originals moved earlier remain cancelled.

Use `calendarEvent.changeOccurrence` with `CalendarEventOccurrenceChange`, saved event revision and one of:

| Action | Behavior |
| --- | --- |
| `cancelFuture` | Validate the requested original and keep the earlier of it and any saved cutoff. Repeating/later cancellation cannot reopen an existing cancelled portion. |
| `restoreFuture` | Require the exact saved cutoff original and clear the complete cutoff. Use current retained timing/content and keep all individual cancellation flags. |

Neither action accepts replacement timing. Both require an explicit recurring profile and exact effective recurrence membership after exclusions, including earlier inclusions/PERIOD additions. Ordinary whole-second dates remain `[1970,2100)`. A cutoff may share a timing-component anchor but costs one of the combined 128 override slots. Existing single/future timing collisions remain invalid. Missing/wrong restoration targets, excluded/orphan/foreign-profile targets and invalid budgets reject.

Recurrence, timing, content, source annotations and individual flags remain retained. Timing/content edits and timing-clear actions preserve the cutoff. Pattern/profile edits reject if they orphan it. A single restore clears its individual flag only; a future cutoff or cancelled master can still suppress it. Restoring the cutoff does not reopen a cancelled master or restore an old historical snapshot. Partial suffix restoration is not implemented.

## Authorization, revisions and protocol state

Both actions use `changeEventStatus`, independently of `updateEvent`. Hosts receive the actual parent/event, typed occurrence intent and immutable current/final proposed override and protocol state. Existing preliminary/final checks, trusted scope, consistency guarantees and separate receipt disclosure apply. Timing disclosure alone exposes the saved cutoff; hidden timing readers receive no cutoff/content through ordinary views.

The shared database transaction writes event override/revision/audit/protocol state and scope/feed/alarm invalidation. The parent calendar metadata time and event protocol UID stay unchanged. An actual cutoff change advances the native master protocol SEQUENCE/nondecreasing whole-second timestamps. Retained unchanged occurrence components keep independent versions. An unchanged cancellation save retains protocol state while the existing accepted-native-write API revision/audit/scope behavior still applies. Overflow or late denial rolls back everything.

These actions use revision fencing rather than command-ID receipts. After an uncertain outcome, refresh saved state before deciding whether to issue another command. Concurrent writers using one expected revision have one winner.

No new SQL table/column/index, migration or history store was added. Legacy nullable JSON/source-baseline spelling stays unchanged. Upgrade hosts and generated clients together; older writers cannot safely retain the new field.

Native cutoff changes are local edits against imported/adopted source baselines. The private accepted source snapshot remains unchanged and mask-free. Clearing a cutoff does not undo protocol changes or automatically make a source baseline clean. Existing replacement/invitation application conflict checks continue protecting local work. No notice is accepted/dismissed, participation changed or mail sent by native cancellation/restoration.

## Queries and availability

Ordinary previews omit covered originals. The authorized saved cutoff remains available for restoration. Calendar occurrence pages with `includeCancelled=false` use the active cutoff; with true they materialize retained timing and mark effective cancellation, including masked singles and later ranges. Raw history/candidate/base work still counts before filtering. Complete spans, moved-in identities, original sort ties, disclosure and private cursor invalidation remain. Unrepresentable retained geometry or exhausted budgets fail without partial results.

Calendar/person/resource/common-free projections apply the complete cutoff-aware event data. They do not infer free time from hidden detail lists. Existing tentative/status/transparency, working-hours and complete-or-unknown rules remain.

## Reminders

Relative candidates omit covered originals. The cutoff participates in timing digests, and source changes invalidate plan/lease generations. Fresh dispatch, retry, snooze and live projection checks reject masked originals, including previously accepted notification references. Personal definitions and private actions remain retained; imported alarms stay unarmed.

Restoration retains acknowledgement/dismiss/reset/snooze state and uses existing grace/expiry rules. Retained automatic transport acceptance for the same alarm/original/repeat/due instant is deduplicated across plan generations, so restoring a cutoff does not submit that reminder again. A genuinely changed due instant is distinct. This remains transport acceptance, not proof of display or acknowledgement; existing bounded terminal-history retention applies.

Absolute alarms keep their established whole-item `item` identity and are not converted into occurrence alarms. Whole-master CANCELLED still suppresses them; the suffix cutoff does not remove their definitions or alter their absolute trigger. Replanning retains the same acceptance deduplication boundary.

## Export, feeds and scheduling boundary

A selected series with a cutoff rejects authenticated VEVENT export, subscription projection and new REQUEST publication until faithful wire mapping is implemented. No RRULE truncation, EXDATE flattening, dropped exceptions, invented whole-master cancellation or silent event omission is used. Feed generation advances on saved changes, and an old ETag cannot produce 304 for an unsupported current projection. Restoration may make export/feed valid again, subject to every other profile/permission check; preserved unrepresentable single exceptions still reject.

Historical scheduling commands using their already published snapshot retain their existing draft-preservation rules. Native cutoffs cannot be erased by a pure incoming projection to manufacture a supported replacement. Incoming range CANCEL application/master composition, outgoing range CANCEL, range replies, wire cancellation import/export, tasks/availability-opening future cancellation and real mail remain separate work. Shared action enums explicitly reject the new actions for openings.

## Example and validation

Flutter exposes cancel-future on active original rows and a restore-saved-cutoff control even when the suffix has no active rows. It explains retained state, separate individual flags and local-only actions, and refreshes after stale/uncertain outcomes.

Focused unit/database tests cover DATE/UTC/zoned values, moved/later exceptions, exact restoration, capacity/profile/orphan rejection, legacy JSON, protocol/source preservation, lifecycle/disclosure/final rollback, query/availability behavior and reminder suppression/deduplication. Actual two-host races and before/after commit process loss verify revision reconciliation. Generated clients test HTTP feed rejection/no stale 304/restored ETags; Flutter tests the explicit controls. See [actual commands/results](scaffold-validation.md) and [development](development.md). These synthetic/native checks establish no external-client scheduling compatibility.


## Proposed pure incoming range cancellation

The maintainer confirmed incoming range CANCEL must have a SEQUENCE newer than all affected accepted components. [Proposed ADR 0159](adr/0159-pure-range-cancellation-projection.md) profiles a separate pure candidate with an inclusive cutoff and independent cancellation source version, preserving retained master/occurrence versions. It explicitly proposes checking the underlying segment beneath an anchor single too. The concrete carrier/version-floor mechanics await approval and are unimplemented. No native write, accepted baseline, generated protocol, endpoint or wire export changes; durable range CANCEL/retry/composition/restoration remains separate.
