# ADR 0017: Task recurrence, named zones and standalone free/busy import

Status: **Maintainer-confirmed scope; implementation pending**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and decisions

The documentation consistency review found a direct conflict between the RFC 5545 table's open standalone VFREEBUSY import note and the compatibility guide's exclusion. It also found unresolved task recurrence and custom-zone scope in table notes. The maintainer selected:

| Topic | First-release decision |
| --- | --- |
| Standalone VFREEBUSY file import | Defer; retain authorized calculated VFREEBUSY output and the planned iTIP publication/request/reply exchanges |
| Recurring tasks | Include native recurring tasks and supported standalone VTODO interchange; recurring events remain included |
| Time-zone definitions | Support known named zones and validated matching VTIMEZONE definitions; defer arbitrary custom zone rules |

These decisions update the RFC tables and supersede conflicting open-scope wording in earlier ADRs. Gregorian-only arithmetic, bounded expansion, atomic rejection and no silent data loss remain required.

## Boundaries and remaining design

Recurring tasks do not enable VTODO iTIP or inbound/outbound task scheduling mail. Task dates do not automatically block availability. Define occurrence identity, per-occurrence completion/progress, series edits, due/duration behavior, queries and alarm invalidation before schema/API approval; this decision selects the capability without choosing a completion or rollover algorithm. Preserve supported recurrence and exceptions in standalone interchange rather than flattening them. Reuse the selected bounded recurrence profile where legal for VTODO.

Resolve known zones against the pinned time-zone database; do not accept arbitrary custom rules merely because TZID text resembles a known zone. Validate supplied VTIMEZONE definitions against the accepted named-zone profile. Exact aliases, matching horizon/rule equivalence, database upgrades and conflict diagnostics remain implementation design. A mismatched or unsupported definition fails explicitly before mutation; no silent replacement that changes temporal meaning. The same named-zone scope applies to event/task and availability components. TZNAME/TZURL remain metadata; no remote rule fetching.

Standalone free/busy file import is distinct from supported iTIP VFREEBUSY processing, generated export and native availability/search. Do not route a standalone file through scheduling handlers to bypass the exclusion.

## Alternatives and consequences

Standalone VFREEBUSY import and arbitrary custom zones were offered and deferred. Deferring recurring tasks was offered and rejected. Recurring tasks add lifecycle/occurrence design work, but do not expand scheduling mail or feed-client requirements.

## Acceptance conditions

Test recurring-task creation, edits, exceptions, completion/progress and alarms under the subsequently defined lifecycle, with stable occurrence identity, bounded queries, atomic imports and restart/revision safety. Verify tasks remain nonblocking unless explicitly reserved through the approved booking policy.

Test known named zones and matching definitions, reject arbitrary/mismatched custom definitions atomically, and preserve DST/local recurrence semantics. Test deferred standalone VFREEBUSY input separately from supported native output and authorized iTIP exchanges. No runtime behavior or client compatibility is claimed.

Traceability: [RFC 5545](../rfc/rfc-5545.md), [RFC 7953](../rfc/rfc-7953.md), [requirements](../requirements.md), [compatibility](../compatibility.md), ADRs [0002](0002-compatibility-and-time.md), [0008](0008-module-clients-tasks-and-search.md) and [0011](0011-defer-vtodo-scheduling.md), work packages [temporal work](../roadmap.md#temporal-core), [interchange work](../roadmap.md#icalendar-and-metadata), [task work](../roadmap.md#tasks).
