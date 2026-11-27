# First native per-calendar free/busy

[ADR 0056](adr/0056-first-calendar-free-busy.md) implements the maintainer-selected first availability increment: one calendar, all required booking data and the stored no-rule fallback. [Native working-hours rules](native-working-hours.md) now extend this calculation under ADR 0057. [Person/resource contributor resolution and common-free search](subject-availability-search.md) now extend native queries within one trusted scope. A result is neither a reservation nor VFREEBUSY serialization or external calendar-client evidence.

## Generated API and result meaning

Call `client.modules.serverpod_calendar.calendar.freeBusy(CalendarFreeBusyQuery(...))` with calendar UUID and `fromUtc`/`untilUtc`. Bounds must be explicit whole-second UTC, increasing and end-exclusive, at most 31 days wide. The UTC [1970,2100) profile and approved exclusive midnight end remain guarded; calculation padding is not additional input range. Invalid input rejects, never rounds/normalizes.

| Model | Purpose |
| --- | --- |
| `CalendarFreeBusyQuery` | Calendar UUID and whole-second UTC bounds |
| `CalendarFreeBusyCoverage` | Complete or unknown |
| `CalendarFreeBusyKind` | Free, tentative, busy or unavailable |
| `CalendarFreeBusyPeriod` | Positive clipped UTC start/end and classification |
| `CalendarFreeBusyView` | Authorized target, bounds, coverage and chronological periods |

Complete results partition the query into disjoint positive intervals; adjacent equal classes merge, so periods are not private event boundaries or source counts. Confirmed opaque events block as busy; tentative opaque events block as tentative. Native precedence is unavailable, then busy, tentative, free. The stored unavailable fallback applies only where no definition is effective and can mask booking classifications; free fallback allows only unbooked intervals to be free. RFC 7953 definition priority and equal-priority BUSYTYPE composition happen first, as explained in [working hours](native-working-hours.md); native final precedence is a separate step.

Cancelled masters, individually cancelled occurrences, transparent events and omitted-end timed points do not create positive booking intervals. DATE is not UTC midnight: it projects through the calendar's stored named availability zone. Named-zone recurrence, original identities, independent singles/future timing and nominal/exact duration semantics follow the existing core. A wholly skipped DATE can occupy no instants; missing coverage fails instead of being guessed. See [timing edits](native-occurrence-timing.md) and [timezone updates/limits](timezone-data.md).

**Unknown coverage returns no periods. It never establishes free time.** A denied/unavailable source projection, insufficient work/scan/output budget or unsupported zone calculation can produce unknown. Calendar-query denial, invalid input or infrastructure/context failure can instead throw the normal failure. Treat both as inability to establish free time. Never use detail lists or per-event previews as a substitute for complete free/busy coverage.

## Host authorization and snapshots

The host must grant `readFreeBusy` for the actual calendar, `projectEventBusy` for every inspected active event and `projectAvailability` for every active definition. Requests include immutable `freeBusyQuery` and actual calendar/event snapshots. Calendar metadata, event-list/detail permissions and disclosure groups are independent; a host can deny all details while permitting a complete busy projection. The detail candidate plan is deliberately ignored. A denied required source is not silently omitted.

The response contains no source event UUIDs, titles, descriptions, locations, participants, counts, raw rules or private scope-generation metadata. It includes only the already-authorized requested calendar identity, bounds, coverage and merged periods. The shared scope transaction provides a consistent module-data snapshot across compatible hosts, rechecking trusted context before return. Reads do not update calendar/event revisions or timestamps. No cache or sticky routing supplies correctness. The shipped private-scope demo epoch becomes v9 and retains its declared fresh-check guarantee.

## Bounded first profile

| Limit | Value |
| --- | --- |
| Query width | 31 days |
| Inspected active source events | min(configured `maxScannedEvents`,256) |
| Final occurrences per event | 500 |
| Per-event expansion candidate / raw-base budgets | 200000 / 10000, plus separately bounded override membership validation |
| Combined projected booking intervals | 5000 |
| Final classified periods | 1000 |
| DATE zone-horizon transitions | 256 |

There is no time index in this increment: the source cap counts **all active event records in the calendar**, including records outside the query. Larger calendars return unknown until a proven indexed candidate strategy is added.

These are trusted implementation caps, not client parameters. Policy batches use the configured existing batch limit. Work is bounded per event and by source count; there is no claim of one global 200000-work budget. Even cancelled/transparent/point sources consume scan/authorization capacity. Long history or sparse movement can exhaust limits despite a small final answer. Failures never return a partial partition or continuation cursor.

## Example and remaining scope

The calendar editor opens a UTC-bound free/busy screen. It resets previous results on each request, clearly distinguishes unknown coverage and displays classifications without event text. Server checks remain authoritative; the example's private-user policy is replaceable.

The reusable core now exposes bounded `partitionFreeBusy` for **already complete** UTC booking inputs; it cannot establish authorization/source completeness. Server adapters perform native event projection and policy enforcement. The initial booking query required no storage migration; the subsequent working-hours slice adds separate rule tables. See [validation](scaffold-validation.md).

Scoped RFC 7953 rule CRUD/composition is now integrated, with additional limits in [working hours](native-working-hours.md). Rich rule metadata/interchange and cross-scope coordination follow separately; [scoped person/resource and common-free search](subject-availability-search.md) is now implemented. Supported stored definitions are applied or result in unknown/failure. Do not ignore external working-hours data and claim it was honored, or label one selected calendar as complete subject availability. Privacy-safe VFREEBUSY output, scheduling, alarms, exclusive reservations and feed interoperability remain separate work.

The calendar evaluator is reused internally under one subject-search transaction; direct `readFreeBusy` remains independent from summary authority. Subject search shares aggregate source/work caps across calendar evaluations and passes exact target/query context to required projections. Public per-calendar semantics and caps remain unchanged.
