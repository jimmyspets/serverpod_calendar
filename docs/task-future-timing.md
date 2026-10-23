# Task this-and-future timing

Status: scoped implementation under [ADR 0102](adr/0102-task-future-timing.md). The maintainer confirmed event-style timing propagation and anchor-only source progress. Concrete mechanics remain under draft review. This extends [single timing](task-occurrence-timing.md); future cancellation, content exceptions, source reconciliation and external-client interoperability remain separate.

## Native behavior

`calendarTask.changeOccurrenceTiming` adds `thisAndFuture`, default false. With true, `replacement` defines a range at the exact original occurrence; null clears only that range. Single and range timing cannot coexist at the same anchor: clear the old scope first. Clearing an absent scope is an accepted native no-op; it does not erase the other scope or create a component. Accepted writes still advance API revision, audit time and scope generation, while unchanged component protocol versions stay stable.

Order ranges by original recurrence identity. Shift later starts by the anchor's absolute civil/date difference, using the replacement's complete deadline form. The next range replaces that shift without compounding. Explicit single replacements remain independent, including ones after a range. A completed occurrence may move. Preserve its original identity, progress, completion timestamp and every history entry; range timing never completes, reopens or cancels later tasks. A new anchor component captures only that anchor's effective progress without adding history.

For example, originals March 28–30 shifted at March 28 to March 29 become March 29–31. A second range at original March 30 moved to March 29 makes that original start March 29; it does not add the earlier one-day shift. A single replacement at original March 29 keeps its own timing through both changes.

Use existing independent `updateTask` permission and durable scope transaction, expected revision and final authorization checks. The trusted immutable host context contains actual parent/task/original, both stored timing scopes, current and final effective anchor timing, retained original records and independent component versions. Clearing a later range exposes the earlier range in the final effective projection. Progress and assignment permissions remain independent. External fresh checks retain their documented after-check revocation race.

Pattern edits preserve every recorded original and range; orphaning or profile changes reject. Starts and deadlines remain whole-second ordinary DATE, UTC or exact named-zone values in [1970,2100). Explicit DUE retains elapsed length for timed propagation; DURATION preserves nominal calendar units across DST. Removing a deadline required by retained source END alarms rejects atomically. Alarms stay unarmed.

## Previews and bounds

Previews filter actual starts, including moved-in originals and excluding moved-out ones, ordered by actual start then original. `originalStart` remains identity; `actualStart` is presentation, `futureTiming`/`replacementTiming` identify stored anchor state and optional `duration` retains the effective nominal deadline form. Resolved UTC due values are not converted into guessed civil fold values. DATE queries may end exclusively at 2100-01-01 midnight; starts and due values may not use that boundary.

The core snapshots maps, validates membership collectively and shares candidate work across membership/query generation. It conservatively inverts the query using civil shifts and bounded zone-offset variation. Irrelevant shifted starts outside the ordinary profile are skipped before materialization; selected invalid deadlines fail. Existing native caps of 1,000 recorded originals, 366-day windows and 500 results remain; source/file caps are independent. Limit failures return no partial results or saved changes.

## Supported VTODO profile and storage

`RECURRENCE-ID;RANGE=THISANDFUTURE` requires a matching in-file master and an exact original member, plus complete same-profile explicit DTSTART timing. Absent DUE/DURATION means no deadline. Source STATUS/PERCENT-COMPLETE/COMPLETED remain independently optional and apply **only to the anchor occurrence**. Timing alone propagates. Later originals use their own component progress or the complete master default; no sparse-field merge or future progress command is inferred. This is our bounded application profile, not a guarantee of universal client interpretation.

Current source state retains the true-or-absent range flag, metadata and independent component versions through native progress/master edits, create-only import and authorized complete-series export. Imported ranges create no progress history. Native source-free ranges export with the same anchor semantics. Private historical baselines remain private and unchanged by local actions.

Generated module migration `20261023203657658-task-future-timing` and example migration `20261023203819827-task-future-timing` add nullable JSON `futureTiming` without inventing ranges. Existing non-range v2 canonical source JSON omits the new nullable flag and remains valid. This increment does not bump the baseline profile or require reimport of valid v2 data; older v1 data remains unsupported under ADR 0101. No development data reset is performed.

## Example and evidence

The Flutter occurrence screen adds “This and future” and “Clear future timing,” preserving progress/history and disabling conflicting scope edits. The editor uses actual timing and the effective deadline form. Named-zone explicit deadlines still require entered civil values.

Focused core, wire, storage and database regressions cover composition, DST, anchor progress, clears, immutable authority, stale/final denial, orphan rejection and rollback. Full `./tool/check.ps1` passed: core 479 VM + 479 Chrome, wire 312 + 312, module 150 VM + 17 Chrome, widgets 3 and database 290, populated upgrades, two-host races/round trips, the complete Flutter journey and release Web build with successful Wasm dry run. Commands and limits are recorded in [the validation log](scaffold-validation.md). HTTP feeds, scheduling, alarm execution and external-client evidence do not follow from these checks.

## Selected task occurrence content, 2026-10-23

[ADR 0103](adr/0103-single-task-content-overrides.md) and [the content guide](task-occurrence-content.md) add selected-field set/clear/inherit for summary, description, location and priority. Omitted fields follow the series; explicit source values stay pinned. RANGE content/progress apply only to the anchor while timing propagates. Opt-in preview groups independently protect effective values and override presence. Preserve progress/history and own versions; source baselines advance to v3 for the changed repetition policy, with explicit recreation/reimport of older imports and no development reset. This supersedes earlier blanket task-content rejection/pending and v2 compatibility notes for this later scoped increment. Future content, source reconciliation, feeds/runtime and client evidence remain separate.
