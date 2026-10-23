# ADR 0101: Single task occurrence timing

Status: **scoped implementation of confirmed single-occurrence timing, completed-history preservation, captured progress and complete explicit timing; concrete mechanics under draft review**. Date: 2026-10-23.

## Confirmed choices

After current task export, implement single-occurrence move/resize with native storage, bounded previews, VTODO round trips and the Flutter example in one batch. This-and-future timing, per-occurrence text changes and source reconciliation remain separate. A completed occurrence can move without reopening; its exact original identity, progress and completion history stay intact.

A replacement requires an explicit start in the same DATE, UTC or exact named-zone profile as the master. It may add/remove a deadline or switch between explicit DUE and positive DURATION. Preserve whole-second [1970,2100) timing and the existing elapsed explicit-due versus nominal duration semantics. Reject changes incompatible with retained source alarms; no source alarm is armed. Tasks never book time.

## Confirmed progress and wire boundaries

Creating a timing-only source component must not silently clear effective progress. The maintainer confirmed: capture the current effective progress into a new own component without adding a progress-history transition; subsequent source-master changes would not overwrite the capture. Do not infer inherited-progress state for a new timing component.

The maintainer confirmed the wire profile: an override with explicit DTSTART supplies its complete timing, including an absent deadline; omitting all timing continues to follow the master projection. The previous progress-only profile accepted repeated DTSTART while projecting the master's due value. This supersedes the progress-only projection policy: use source baseline profile v2 and reimport affected pre-beta source data. Do not claim the RFC specifies this application's inheritance policy or external-client behavior. Preserve or explicitly reject existing partial DUE-only repetitions rather than silently reinterpreting them.

## Scoped implementation mechanics under review

Keep timing replacement separate from progress: add nullable `replacementTiming: CalendarTaskTiming` to the active original-occurrence record, and expose actual typed timing in occurrence previews while retaining `originalStart`. A dedicated immutable request contains task UUID, expected revision, exact original identity and nullable complete replacement (null clears only the timing replacement). No client-supplied parent/actor is trusted.

Reuse content-edit authority for timing, independently of progress authority. Supply actual parent/task/original, current record, all retained originals, current/validated final proposed replacement and component version to the host. Recheck declared final authority and stale revision under the durable scope lock. A timing edit never creates a completion/history transition, changes assignments, renames original identities or changes master protocol version. Advance only the changed occurrence's protocol version; identical normalized saves retain protocol versions while keeping native accepted-write revision behavior.

Validate original membership collectively with retained progress/timing records, reject orphaning pattern/profile changes, and preserve explicit single replacements through ordinary master edits. Clear timing without deleting progress/history or source metadata. Keep private import baselines unchanged through local edits. Native source-free tasks retain independent native capacity; source-bearing/wire output limits remain explicit and never truncate data.

Core expansion must include moved-in originals, omit moved-out effective starts, preserve original identity, sort deterministic effective starts with original tie-breaking and fail atomically on shared membership/generation/result budgets. Due values remain ordinary task dates, not exclusive event endpoints. Regenerate matching pinned zones on wire output.

## Model and migration gates

Document request/preview/record/host-context fields in the model catalog before changing sources. Generate nullable column migration, clients and test tools with the pinned toolchain. Pre-beta breaking APIs and fresh databases are authorized, but do not reset development data or invent old timing/progress/version history. Define any source-profile transition explicitly before applying it.

## Acceptance

Focused core/wire/module/database tests must cover DATE/UTC/named-zone moves, DST gap/fold and duration/due forms, start-only/add/remove deadlines, original membership/orphans/collisions, moved-in/out queries and limits, completed progress/history stability, independent content/progress permissions, immutable actual/final host context, stale/final-denied rollback, no-op versions, source omission/baseline preservation and alarm-anchor rejection. Add populated/fresh migration checks, two-host competing timing/progress writes and Flutter stale/move/clear/export/reimport journeys. Run broad checks at the completed batch boundary; do not commit partial feature code.
