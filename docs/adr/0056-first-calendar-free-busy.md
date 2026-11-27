# ADR 0056: First bounded per-calendar free/busy service

Status: **Accepted per-calendar-first increment and tentative-blocking policy; API/budget/classification mechanics under review**. Date: 2026-10-21.

## Confirmed boundary

After the ADR 0055 timing batch, the maintainer selected bounded per-calendar free/busy over all required booking data and the saved no-rule fallback. RFC 7953 working-hours rules and host-resolved person/resource/common-slot search follow in separate batches. Opaque tentative events block time like confirmed events, retaining a distinct tentative classification. Cancelled masters, individually cancelled occurrences and transparent events do not block time.

This is a partial implementation of the selected availability scope under [ADRs 0006](0006-resource-availability.md)/[0012](0012-calendar-availability-policy.md) and FR-16/17. Booking-only calculation is not completion of RFC 7953, subject composition, VFREEBUSY interchange, exclusive reservation or first-release acceptance. No rule storage/provider exists in this increment. Once supported availability definitions can be stored, this service must apply them or return unknown/failure rather than ignore them.

## API and coverage proposal

Add `CalendarFreeBusyQuery(calendarId, fromUtc, untilUtc)` and a `calendar.freeBusy` generated-client endpoint. Require explicit whole-second increasing UTC bounds in the current [1970,2100) UTC profile, with the approved midnight exclusive end and a fixed maximum width of 31 days. Return the actual authorized calendar ID, echoed bounds, `complete`/`unknown` coverage and chronological `CalendarFreeBusyPeriod` values. There are no event IDs, titles, participants, locations, source counts, raw rules or scope-generation values in the response.

A complete result partitions the whole query into disjoint clipped positive intervals classified free/tentative/busy/unavailable, merging adjacent identical classes and hiding private source boundaries. Native precedence is unavailable over busy over tentative over free. This is a native booking/fallback partition, not RFC 7953 definition-priority composition. Unavailable no-rule fallback masks the whole query; bookings remain stored and no free time is manufactured. The default free fallback leaves only unbooked intervals free. Unknown has no periods at all: empty periods cannot mean free. Query-level denial/invalid input/unavailable infrastructure can fail explicitly instead.

## Authorization, snapshots and calculation

Require `readFreeBusy` on the actual calendar and `projectEventBusy` on every inspected active event, with immutable `freeBusyQuery` and actual parent/event snapshots. These rights are independent of calendar metadata, event-read/list/disclosure groups and the privacy-filtered detail candidate plan. Never reuse that plan or omit denied sources. If any required event projection is denied/unavailable, return unknown without partial periods. Denied calendar query authority fails before inspecting events. Revalidate trusted context before returning any result, including unknown.

Use the existing durable scope-row transaction for a consistent module-data snapshot across compatible active instances. Do not change event/calendar revisions/time or introduce a process-local cache. Host external-policy races and coordinated guarantees retain their existing declared limits; the snapshot is not a reservation or promise that permissions/data remain unchanged afterwards.

Expand effective native recurrence and ADR 0055 timing/cancellation state. Ignore cancelled/transparent masters only after source coverage has been inspected/authorized. Project DATE occupancy through the stored explicit calendar availability zone, proving query-horizon zone coverage and preserving DST/skipped-date behavior. Timed points have no positive occupied interval. UTC/zoned spans retain exact-end versus nominal-duration semantics. Any expansion/coverage/limit failure produces unknown/failure, not partial successful free intervals.

Trusted caps: at most min(configured `maxScannedEvents`,256) active source records, policy batches using existing configured limits, 500 occurrences per event under current 200000 candidate/10000 raw/base and override-membership budgets, at most 5000 projected booking intervals combined, at most 1000 final partition periods and 256 DATE-zone horizon transitions. Per-event work limits are not a claimed global 200000-work cap; total processing is bounded by source and projection caps. Cancelled/transparent/point records still consume scan/authorization capacity. No time index exists yet: all active calendar event records consume the source cap, even outside the query, so larger calendars yield unknown until a proven indexed candidate strategy exists. No pagination or total counts are added. Widely separated history can yield unknown even for short windows.

## Independence, UI and alternatives

Keep UTC interval partition/classification in the pure Dart core. The Serverpod adapter owns persistence/policy and event/DATE projection. A Flutter screen accepts UTC bounds and shows only authorized coverage/classified periods, clearing stale results before every query. Unknown is prominent and never rendered as an empty free calendar. The example does not render private event text or make reservations.

Filtering detail lists would omit hidden bookings. Treating tentative as free contradicts the selected policy. Returning partial intervals after a denied/over-limit source could falsely establish free time. A complete-or-unknown one-calendar increment makes the boundary explicit while leaving full rules/search/scheduling separate. No table/SQL migration is needed for query DTOs and computation; confirm with migration tooling.

## Validation

Test the independent partition with clipping, adjacency, precedence, finite tick coverage and raw/output caps on VM/Chrome. Test DATE DST projection, points, transparent/cancelled masters and retained single timing. Database tests cover hidden detail plans, independent busy rights, denied-source unknown, scopes, tentative classification, no-rule fallback, precision/window validation, recurrence limits and unchanged read timestamps. Compare two real hosts and committed remote lifecycle/transparency changes; drive the Flutter screen without leaking synthetic private text. Run focused checks during work and broader checks after the batch, recording actual commands/results in [validation](../scaffold-validation.md).
