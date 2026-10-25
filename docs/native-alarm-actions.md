# Native personal alarm actions

Status: scoped native implementation under [ADR 0113](adr/0113-native-alarm-actions.md); additive storage approved on 2026-10-25. Focused database tests pass; broader batch evidence is recorded in [validation](scaffold-validation.md). This extends the [durable planner](durable-alarm-planning.md), without connecting notification delivery.

| Action | Behavior |
| --- | --- |
| Acknowledge | Record acknowledgement; cancel selected snooze and suppress remaining automatic repeats for the same alarm/original. Other originals retain their generation and accepted firing IDs. |
| Dismiss | Record dismissal separately, cancel selected snooze and suppress that original's remaining automatic repeats. |
| Snooze | Acknowledge the original and select one replacement whole-second UTC instant, strictly after database time and at most seven days ahead. Rescheduling replaces the selected snooze; it does not create a chain. |
| Reset | Clear acknowledgement/dismissal and selected snooze; record an exclusive database-time cutoff. Only later automatic firings may become eligible. Already due or accepted reminders never replay because of reset. |

## Commands and authority

`calendarAlarm.act(CalendarAlarmActionRequest)` identifies the actual parent/alarm and one existing firing UUID, or an existing persistent action UUID for reset. The server derives the exact original identity. Clients never choose a recipient or create arbitrary original keys. Reset remains possible from persistent actions after terminal firing history is pruned or the original is removed; it never retargets a removed original.

Supply the expected alarm definition revision and expected action revision (0 when absent). Each accepted action advances the action revision; it does not advance the alarm definition, parent/protocol revision, source baseline or public scope generation. Action rows are retained until alarm/parent deletion, including the reset cutoff. Audit/cutoff times retain operational database precision; calendar snooze times accept only whole seconds.

Hosts authorize independent `acknowledgePersonalAlarm`, `dismissPersonalAlarm`, `snoozePersonalAlarm`, `resetPersonalAlarm` and `readPersonalAlarmActivity` operations. They may map these to shared rules. Context contains trusted actor/scope/recipient, actual calendar/event/task/alarm, immutable selected firing/current action and proposed action state. Read-activity context also identifies the list kind. Final recipient/context checks, policy checks and optimistic revisions run under the shared scope transaction. Hidden mutation receipts return null; action permission does not grant read access.

Creation of a new persistent action is bounded by the host's retained-work capacity (default 10,000 per alarm). Counter exhaustion fails without mutation. Parent deletion removes every recipient's actions/work atomically; private permissions cannot block shared deletion.

## Snooze eligibility

The alarm must be armed with a ready, clean current plan and matching timing/lifecycle digest. Snooze must reference an automatic firing from the current generation:

- A pending firing must already be due and not expired: `dueAt <= databaseNow < expiresAt`.
- An accepted firing can establish the prior reminder after its eligibility expires, provided its original is still active in the current plan/generation.
- A previously due unaccepted firing used to create the selected snooze remains a valid rescheduling origin while that selection exists. Its internal suppression reason records that origin; acknowledgement/reset clearing the selection removes that exception.
- Future, expired unaccepted, unrelated, stale-generation and snooze-kind references reject. Reuse the automatic origin when changing a selected snooze.

Recheck original membership, event cancellation, and any task completion signal (completed/cancelled status, COMPLETED timestamp or 100%). Unknown/incompatible sources fail closed. Check the UTC profile, future/seven-day limits and complete-plan/retained-work budgets before commit, and time again after final host checks. A slow authorization service cannot make an already-past snooze valid.

The selected snooze shares the existing complete-window budget; no partial plan dispatches. Planning may later become unavailable/needs-attention after a parent/settings change. Keep the private selection, but skip invalid/cancelled/completed/removed originals. `pendingSnoozeAt` preserves the selected instant for identity/downstream checks; it alone is not proof that the firing is still pending. Inspect firing state for accepted/suppressed/expired outcomes. Accepted snooze revisions are not emitted again solely because settings advance the generation.

## Replanning and delivery races

Action writes fence in-flight plan computation and affected firing leases, dirty/wake the private plan, and leave unrelated originals unchanged. Workers apply acknowledgement/dismissal/reset cutoffs before coalescing eligible overdue work. The matching snooze revision and instant bypass automatic acknowledgement suppression only for that replacement; lifecycle and fresh access checks still apply.

Reset persists `resetAt`, so later generation changes and terminal-history pruning cannot resurrect overdue reminders. Future suppressed automatic firings for that original are reevaluated against current timing/lifecycle. Acknowledgement/dismissal survives ordinary timing/settings edits until reset. No imported ACKNOWLEDGED/SNOOZE or provider acceptance creates a native action.

Downstream queues must call `CalendarModule.validateAlarmDelivery` before every dispatch/retry. Action changes invalidate queued obsolete intents. An already accepted or in-flight external handoff cannot be recalled, and no exactly-once human display is promised.

## Private activity pages and Flutter example

`calendarAlarm.activity(parent, alarmId, kind, pageSize, cursor)` returns separately selected `firings` or `actions`, an opaque continuation and no total count. Page size uses the existing host limit (default 100). The server binds continuation state to alarm, list kind, current principal/scope/policy epoch, scope revision, page size and expiry, then reauthorizes every page. Recipient changes cannot widen the private alarm lookup. Other list APIs reject alarm continuations.

Pages use live UUID keyset order, not chronological order or a frozen snapshot. Concurrent inserts/pruning may change later pages; refresh starts a new traversal. Firing views disclose only private firing state and the current action for that original, without automatic parent text, leases, recipient references or baselines. Persistent action pages remain available after terminal-history pruning.

The example provides firing/action tabs, continuation controls, acknowledgement/dismissal, UTC snooze editing and reset. Stale or denied writes show an error and require refreshed state. Reset is reachable through persistent actions even when the corresponding firing is gone. The example still declares delivery unconnected; reusable notifications and connected Flutter streaming remain required separate work. Source alarm adoption, private alarm export and mobile provider implementations are outside this increment.
