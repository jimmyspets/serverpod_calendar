# ADR 0102: Task this-and-future timing

Status: **scoped implementation of maintainer-confirmed event-style range policy and anchor-only progress; concrete mechanics under draft review**. Date: 2026-10-23.

## Confirmed behavior

Extend ADR 0101 with this-and-future timing. A range is ordered by exact original recurrence identity, not moved start or completion time. Shift later starts by the anchor's absolute civil/date difference and apply its complete replacement deadline form. A later range replaces the active shift, without compounding. Explicit single timing replacements remain independent. Keep every occurrence's progress and history untouched, including completed originals. If a new anchor component is needed, capture current effective anchor progress without adding history, as for singles.

The maintainer also confirmed a bounded VTODO RANGE=THISANDFUTURE profile: supplied STATUS/PERCENT-COMPLETE/COMPLETED describe only the anchor; timing alone propagates. This is an explicit supported application profile, not a claim of universal client interpretation. RANGE must supply complete same-profile DTSTART timing; no future progress/cancellation operation is inferred. RFC 5545 [section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) supplies original-identity ordering and separate-instance/start-shift context.

## Scoped model/service integration under review

Add nullable `futureTiming: CalendarTaskTiming` to original occurrence storage and preview, plus effective nominal `duration` on previews so the example preserves the deadline form without guessing civil folds. Extend the immutable timing request with `thisAndFuture: bool` default false. Null replacement clears only the selected single/range timing. Preserve current progress/history/metadata and master versions; version only the changed anchor component. Reject a single timing and future timing at the same original anchor until the old representation is explicitly cleared, matching the selected event policy. Progress-only anchor rows remain valid.

The source component gains nullable `thisAndFuture: bool`, set only to true for range source components. Null preserves old canonical JSON exactly; reject noncanonical false values. Existing v2 baselines remain valid for unchanged non-range sources; no profile adoption or new baseline is invented. Source import/export/metadata/native progress edits preserve the flag and per-anchor protocol version. Create-only import retains independent source progress and creates no history; native range actions preserve current effective progress.

Use existing updateTask authority, actual parent/task/original and immutable current/final proposal with retained records, under durable scope/stale/final checks. Current/final host occurrence state includes both timing scopes. Preserve ranges through pattern edits and reject orphan/profile changes. No booking, network access, scheduling or alarm activation follows. Reject retained END alarms without a valid deadline.

Core DATE/timed expansion snapshots single/range maps, validates all anchors with shared membership/query work, rejects collisions, and inverts bounded effective-start windows conservatively. Sort actual starts with original tie-breaking; skip irrelevant out-of-profile shifted starts before materializing them, but fail on selected invalid dues. Preserve elapsed DUE versus nominal DURATION across DST, exact zone names and the whole-second [1970,2100) profile. Native capacity remains 1,000 recorded originals; source/file caps remain separately enforced without truncation.

## Acceptance

Generate APIs/nullable module+host migrations with pinned tools. Verify unchanged v2 canonical baselines, source RANGE acceptance/rejection/anchor-only progress and round trips, DATE/UTC/zoned shifts/multiple ranges/singles/moved-in queries/DST/budgets, independent authority/immutable actual context/stale/final/overflow rollback, completed history preservation, clear/pattern/orphan behavior, populated upgrades, two-host competing range/progress writes and Flutter range/clear journeys. Run focused development checks then full batch validation before one commit/push. Future cancellation/content, source reconciliation and interoperability remain separate.
