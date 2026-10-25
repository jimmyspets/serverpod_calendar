# ADR 0113: Native personal alarm actions

Status: action policies and additive storage approved on 2026-10-25; API mechanics and implementation under review. Date: 2026-10-25.

## Context and confirmed decisions

[ADR 0112](0112-bounded-durable-alarm-planning.md) implemented bounded planning and guarded handoff, but no native action commands. Imported ACKNOWLEDGED/SNOOZE remains inert source data. Provider acceptance never acknowledges a native reminder.

The maintainer confirmed acknowledgement/dismissal persistence for the same alarm and exact original occurrence, suppression of remaining automatic repeats for that original, and an explicit reset. Snooze acknowledges that original and replaces one pending snooze, without chains. Snooze requires an existing due or accepted firing, a still-active parent/original without cancellation or task completion signals, and a future whole-second UTC instant at most seven days after shared database time. Reset restores only future firing eligibility, cancels the pending snooze, and must not replay already due or accepted reminders.

## Approved additive storage

Reuse the approved action/firing/plan tables. Add no delivery/provider table in this batch.

| Source model | Proposed addition | Purpose and upgrade |
| --- | --- | --- |
| `CalendarAlarmActionRecord` | Nullable `resetAt: DateTime` | Persistent exclusive replay cutoff: automatic firings with `dueAt <= resetAt` remain suppressed after reset, generation changes and terminal-history pruning. Existing rows receive null, never an invented reset. Operational UTC database precision is retained; this is not a calendar DATE-TIME value. |
| `CalendarCursorRecord` | Nullable `alarmActivityId: UuidValue` and `alarmActivityKind: CalendarAlarmActivityKind` | Bind an opaque server-stored continuation to one private alarm and either firing history or persistent actions. Existing cursors receive null. All other cursor consumers must explicitly reject these discriminators. Existing scope/principal/policy revision/page size/after-ID/expiry fields remain authoritative. |

The new enum has `firings` and `actions`. These columns are server-only; new immutable request/response DTOs expose no recipient, scope, leases, source baseline or arbitrary client-selected original identity. The maintainer explicitly approved these additive fields on 2026-10-25 under the repository model gate. Generate both module and example migrations, then test fresh and populated upgrade behavior without resetting development data.

A reset row remains even with cleared acknowledgement/dismissal/snooze fields: deleting it would lose the replay cutoff. Later resets advance, never decrease, `resetAt`. Action retention remains until explicit alarm/parent deletion; a reset clears suppression state but retains this minimal private operational cutoff. No source/protocol version or public scope generation changes.

## Proposed API and authorization

Use distinct host operations for acknowledgement, dismissal, snooze, reset and reading private activity; hosts may map them to the same rule. Resolve actor/scope/recipient through the existing host adapter and load the actual alarm, parent and action/firing under the trusted scope lock. Recheck recipient/context and final authority before commit. Do not trust a request's claimed parent, firing-to-alarm relationship or recipient.

Commands identify an existing firing UUID, or an existing persistent action UUID for reset. The server derives the exact original key. This preserves reset after terminal firing history is pruned or an original is removed, without allowing an arbitrary key to create state. A command carries expected alarm revision and expected action revision (0 for absent action); reject stale state atomically. Action changes advance their own revision, not the definition revision. Return a nullable action receipt honoring the existing hidden-receipt contract.

Host context includes actual calendar/event/task/alarm, recipient, immutable selected firing and current action, plus validated proposed action state. Preliminary and final decisions use that context. Read permission is independent of action permission; no hidden state leaks through a mutation receipt. All unavailable/denied cross-recipient references fail closed.

Acknowledgement/dismissal clear a pending snooze and suppress remaining automatic firings for that original. Dismissal is recorded separately from acknowledgement; snooze records acknowledgement. Reset clears both and pending snooze, advances the replay cutoff, and never retargets a removed original. An already accepted notification cannot be recalled; downstream retries must still validate current action state.

Snooze additionally requires the alarm to be armed and its current plan ready/clean with matching generation/source digest. A due firing means a pending, currently eligible firing (`dueAt <= databaseNow < expiresAt`); accepted history may establish the prior reminder even after its delivery eligibility expired, provided its original still belongs to the current generation/plan and remains active. Old-generation references reject; users may act on a newly validated current reference instead. Future, expired unaccepted or unrelated suppressed firings cannot establish snooze eligibility. A due unaccepted automatic origin suppressed by creation of the currently selected snooze can be reused to reschedule that selection; clearing the selection removes this exception. A snooze firing cannot be used to build a snooze chain; rescheduling uses the original automatic firing reference and increments the action's snooze revision.

Validate the seven-day bound and calendar profile against database time again after final policy checks. Counter exhaustion, invalid/fractional/non-UTC time, incompatible/unknown source, denied authority and capacity exhaustion reject without partial action or firing changes.

## Planning and concurrency

An action transaction fences any in-flight plan computation, marks its own plan dirty/wakeable and fences affected pending firing leases. It does not change unrelated originals or public item state. Do not bump the definition generation merely to acknowledge an original: that could regenerate accepted work for other originals.

Replanning applies acknowledgement/dismissal and the reset cutoff before exposing dispatchable work. Reset permits only future automatic firings; suppressed future rows for that original must be reevaluated against current timing/lifecycle, while accepted/previously due rows remain terminal. A matching pending snooze is the sole exception to acknowledgement suppression; match alarm, original, snooze revision and exact UTC due time. Cancelled/completed/removed originals never dispatch a snooze.

Snooze work remains part of the complete-plan and retained-work budgets. Replanning after timing/settings changes preserves the selected snooze instant and original identity, but revalidates membership, lifecycle and authority. Action state must not silently disappear on planning failure. Recovery coalescing must exclude action-ineligible work before choosing the latest eligible reminder, so one acknowledged original cannot suppress another original's valid reminder.

Fresh validation is required before handoff and every downstream retry. Fences cannot recall a port acceptance already in progress; document the external-check race and do not promise exactly-once human delivery.

## Private activity and example

Return authorized pages and opaque continuations without totals, separately for retained firing history and persistent actions. Use bounded UUID keyset scans and bind continuations to the actual private alarm, list kind, recipient/current principal, host policy epoch, scope, page size and expiry. Reauthorize each page. This is a live listing, not a frozen snapshot: pruning/concurrent inserts can change later pages; refresh starts a new traversal. UUID order is deterministic, not chronological. No parent text is included automatically.

The example exposes these pages and explicit commands with stale-state refresh, pending snooze/reset state and clear acceptance-versus-acknowledgement labels. It must allow reset from the action list after firing history is pruned. It continues to state that notification delivery is unconnected until the separate reusable notification/streaming batch is implemented.

## Alternatives and consequences

Deleting action rows on reset would lose the replay cutoff after a later replan. Reusing `updatedAt` would conflate reset with later snooze/action writes. Retaining firing history forever would conflict with the approved retention policy. Dedicated nullable `resetAt` records the necessary meaning without retaining message content.

Separate cursor discriminator columns avoid overloading task-history fields or accepting another API's continuation. Reusing the existing cursor store keeps expiry/capacity and actor binding consistent, at the cost of updating every cursor consumer's rejection tests.

## Acceptance evidence required before completion

Test independent permissions, actual parent/recipient isolation, hidden receipts, final denial and recipient changes, stale action/alarm revisions and counter bounds. Test due/future/expired/accepted/old-generation snooze eligibility, fractional/UTC/seven-day boundaries using database time after a slow policy check, snooze replacement, no chains, lifecycle changes and atomic capacity rejection.

Test exact-original repeat suppression, reset without overdue replay, generation changes, terminal pruning, removed originals, unrelated-original non-replay, stale plan/firing owners, simultaneous snooze/reset and two-host recovery. Test cursor kind/alarm/principal/policy binding, pruning between pages and reset after history deletion. Run focused tests during development and the broader agreed batch checks before committing. The scoped implementation follows these mechanics; focused tests cover the native commands and replay/cursor boundaries. See [the implementation guide](../native-alarm-actions.md) and [actual batch validation](../scaffold-validation.md). Notification delivery remains unconnected.
