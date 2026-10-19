# ADR 0002: Explicit calendar profile and temporal types

Status: **Proposed; revised 2026-10-19**. The maintainer requires named zones and recurrence in the first release. This replaces the earlier UTC-only, non-recurring proposal; implementation details below await review.

Scope update: [RFC scope](../rfc/README.md) promoted the RFC baselines to planned; [ADR 0017](0017-profile-review-clarifications.md) includes recurring tasks and limits initial zones to known named zones with validated matching definitions. Arbitrary custom zones are deferred. Detailed temporal constraints remain proposed.

## Context

Read-only subscription feeds must preserve the meaning of recurring local times across daylight-saving changes in iOS, Google Calendar and Outlook. The unavailable earlier discussion is not evidence for this choice; the current maintainer instruction is.

## Proposal

The maintainer explicitly confirmed Gregorian as the only supported calendar system under [ADR 0013](0013-gregorian-only.md). Native dates/recurrence and all supported interchange use Gregorian semantics. Omitted CALSCALE means Gregorian; reject other calendar systems without conversion. Time-zone and date-only distinctions below remain independent.

Keep UTC instants, date-only values, and zoned local times distinct. Store local civil values and zone references for zoned events; pin time-zone data and define its update policy. Preserve recurrence masters, inclusion/exclusion dates and original occurrence identities for overrides/cancellations. Feed export emits masters, exceptions and required VTIMEZONE definitions. Bounded occurrence queries use a tested recurrence engine and explicit work limits.

Specify an accepted RRULE grammar with daily/weekly/monthly/yearly coverage and common interval/end/day filters. Define gap/fold and duration behavior against RFC 5545, including distinctions between explicit local times and generated recurrence instances. Unknown zones, unsupported rules and lossy imports fail explicitly before mutation. Floating local times remain unsupported unless separately approved.

Preserve source UIDs for ordinary round trips. Use a separate stable globally unique publication UID for each series in feeds; all overrides share it with RECURRENCE-ID distinguishing instances. This avoids collisions between independently imported calendars. Do not flatten recurring events or regenerate identities on each fetch.

The maintainer confirmed native/interchange RANGE=THISANDFUTURE edits in RFC 5545 review batch 8; see [ADR 0010](0010-rfc5545-property-decisions.md). Preserve occurrence identity, respect separate overrides and recalculate affected bookings/alarms. Arbitrary recurrence-pattern changes and split-series storage/identity rules still need a separate detailed design.

The maintainer also confirmed bounded hourly/minutely event recurrence and BYHOUR/BYMINUTE support in batch 9, deferring SECONDLY and BYSECOND. Ordinary timestamp precision is unaffected. Define work budgets and incomplete-coverage/error behavior before implementation; limit exhaustion cannot silently mark a target free or truncate published semantics. Recurring tasks are required under ADR 0017; their occurrence lifecycle and legal recurrence constraints need design.

Batch 10 confirmed bounded BYYEARDAY/BYWEEKNO/BYMONTH native/interchange event recurrence, including RFC-valid combinations, leap-year and week/year-boundary handling. Batch 11 subsequently confirmed bounded BYSETPOS and all WKST values with Monday when omitted; these choices do not add fiscal/school calendars or recurring task lifecycle semantics.

BYSETPOS selection does not calculate public holidays or host business days. Stored WKST controls recurrence semantics independently of Flutter week layout. Test candidate positions/order and week/year boundaries together with existing budgets, override identity, availability and alarm requirements. All listed RFC row statuses are selected; detailed temporal policies remain under review.

## Alternatives

- UTC-only/non-recurring MVP: no longer meets the maintainer's first-release scope.
- Expand recurrence into independent feed events: loses series/exception identity and cannot safely represent unbounded series.
- Claim full RFC support immediately: exceeds the explicit profile and available evidence.

## Consequences

Time-zone resolution, recurrence semantics, duration rules and exception edits are release-critical work. Zone-data or serialization changes can alter a feed and its validator. Query limits must not silently remove supported events.

## Acceptance conditions

Approve the exact profile, known-zone/alias validation policy (arbitrary custom zones deferred), DST gap/fold handling, zone-data version policy and series edit semantics. Test recurrence limits, month ends, leap dates, original RECURRENCE-ID after moves, cancellations, DST and semantic round trips. Pass the required [client matrix](../compatibility.md).
