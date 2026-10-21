# Person/resource availability and common-free search

The native module resolves complete host-selected contributing calendars, calculates each calendar independently and combines their known free time under [ADR 0058](adr/0058-subject-availability-search.md). This increment supports **one trusted host scope**, such as an organization. It does not coordinate cross-scope aggregation, expand directory groups automatically or reserve a room.

## Generated client API

Call `client.modules.serverpod_calendar.calendarAvailabilitySearch.search(query)`:

| Input | Meaning |
| --- | --- |
| `targets` | Namespaced opaque `CalendarAvailabilityTarget(namespace, kind, externalId)` references; no caller-selected calendar subset |
| `fromUtc`, `untilUtc` | Whole-second increasing UTC interval, exclusive upper end, at most 31 days; current [1970,2100) guards apply |
| `mode` | `perTarget` or `commonFree` |
| `minimumSeconds` | Positive elapsed seconds, default 1, at most 31 days; apply after maximal free intervals merge |

Exact duplicate targets are evaluated once, preserving first-seen order. Namespace, kind, identifier spelling and case are preserved; no directory lookup, labels or membership are inferred from text. A minimum longer than the query is valid and simply produces no qualifying slots when coverage is complete.

`CalendarAvailabilitySearchView` contains the echoed bounds/mode/minimum, `results`, optional `commonCoverage`, `commonSlots`, a random response `snapshotId` and whole-second `calculatedAtUtc`. The timestamp and ID describe one calculation; neither promises future validity nor acts as a reservation/version token.

Each `CalendarSubjectAvailability` has the requested `target`, coverage, merged classified `periods` and qualifying `freeSlots`. **Complete with no slots** means no interval meets the minimum. **Unknown** has no periods or slots and establishes no free time. Unknown does not distinguish missing, denied, empty, unsupported or over-limit targets. The response does not expose contributing calendar IDs, event/rule IDs, text, source counts, scope generation or host resolver revisions.

In per-target mode, inspect each result separately; common coverage is null and common slots are empty. In common-free mode, common coverage is complete only if every target is complete. Intersect their free intervals and then filter by minimum duration. If any target is unknown, common coverage is unknown and common slots are empty; separately complete target results remain independently usable.

## Composition

Resolve all contributing calendars for each subject, including private calendars whose busy projections the host permits. Each calendar applies its own [working-hours priority/range rules](native-working-hours.md), no-rule fallback, DATE zone, recurrence/occurrence edits and booking status/transparency. Then intersect free time across contributors. An administrative link is not a booked subject relationship. Empty or unresolved contributor sets never imply an unbounded free calendar.

Example: Work opening hours 09:00–17:00 and Personal hours 10:00–18:00 give a subject free range of 10:00–17:00 before bookings. A booking in either calendar blocks that subject. Work's priority 1 does not override Personal's priority 0: priorities compose definitions within each calendar only. Native blocking classifications retain unavailable, busy, tentative, free precedence. For a meeting requiring several people/resources, common-free intersects every complete subject result.

All-day events retain each contributing calendar's explicit zone; openings retain their own zones. DST, nominal duration versus elapsed time, whole-second input, named-zone coverage and WKST follow the existing [temporal core](temporal-core.md), [week conventions](week-conventions.md) and [timezone update policy](timezone-data.md). Minimum duration itself uses elapsed seconds.

## Host integration and disclosure

Implement `CalendarHostPolicy.resolveAvailabilitySubject` using the supplied trusted context and transaction. Return `CalendarSubjectResolution(complete, revision, calendarIds)`. The host is responsible for the **complete authoritative contributor set**, not just visible calendars. It can resolve module availability associations or its own current mapping. Do not reuse `planQuery`, `planEventQuery` or privacy-filtered detail lists. Declare incomplete when required external/out-of-scope sources cannot be evaluated. No callback or client field can bypass the module's active-parent/scope checks.

Grant `readSubjectAvailability` independently of direct `readFreeBusy` and detail permissions. Each contributor also requires `projectCalendarAvailability`; each event/rule still requires `projectEventBusy`/`projectAvailability`. Requests include frozen `availabilitySearchQuery`, the requested `availabilityTarget` and actual object/parent snapshots. Hosts can grant summary projection while denying direct calendar queries and raw details. This does not grant association-management rights or scheduling authority.

Module reads use one durable scope transaction across compatible instances. Recheck successful targets' summary permission and resolver revision/set before returning; changed or incomplete mappings invalidate that target. Trusted caller/scope/policy-epoch changes fail the query. Coordinate host mapping and authorization updates using the supplied transaction where possible. An external resolver must change its revision with the mapping and retains an after-check race; repeated checks do not create a lease or stronger guarantee. Source snapshots do not provide exclusive booking.

The example host resolves the signed-in `demo/user` only, from active in-scope association rows marked `contributesAvailability=true`. It scans at most 256 active scope calendars, returning incomplete above that cap, and never uses a detail candidate plan. Unlinked calendars are not automatically assigned to the person. Production hosts replace this demo mapping and its private-user policy; the module has no user/group/resource directory.

## Limits and example UI

| Trusted cap | Value |
| --- | --- |
| Raw target entries / distinct targets | 32 / 8 |
| Raw contributor IDs per host resolution | 8, before deduplication |
| Calendar evaluations across the whole search | 16 |
| Event / definition / opening expansion budgets across the search | 256 / 64 / 64 |
| Projected bookings / opening intervals across the search | 5000 / 5000 |
| Source periods combined per target/common calculation | 8000 |
| Classified output periods per target/common calculation | 1000 |

Raw caps apply before duplicate removal. Repeated contributors evaluated for different targets consume work again; no cached authorization decision or projection is reused across targets. Per-source recurrence budgets and existing [free/busy limits](calendar-free-busy.md) also apply. These aggregate caps are charged before full query expansion; bounded identity lookahead and metadata validation used to detect overflow can inspect additional records. They are not a claim that all SQL result/probe rows across the search total at most 256. Earlier independently complete targets can remain complete when a later target exceeds aggregate limits; request order may affect which targets fit. A partial contributor set never becomes a successful target/common partition. Larger calendars still need the planned proven indexing strategy.

The Flutter example offers target fields, explicit UTC bounds, minimum duration and both modes. Input changes and failed/restarted requests clear old results. Complete/no qualifying interval and unknown are visibly distinct. The private demo supports its own signed-in user; arbitrary people/resources require the host's real adapter, not invented directory entries. See [validation evidence](scaffold-validation.md).

This increment uses existing associations and storage; it introduces no table/migration. VFREEBUSY serialization, external calendar-client evidence, cross-scope coordination and exclusive reservation remain separate work.
