# ADR 0013: Gregorian calendar system only

Status: **Maintainer-confirmed scope; implementation pending**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and decision

The maintainer explicitly instructed that the project only support the Gregorian calendar. This resolves accepted CALSCALE values in the RFC 5545 profile and narrows the baseline approved in the RFC tables.

Use Gregorian dates and recurrence throughout native calendar/task/availability services and supported interchange, scheduling and feed projections. Accept CALSCALE:GREGORIAN and an omitted CALSCALE, whose RFC 5545 default is Gregorian. Reject other calendar systems explicitly before mutation or scheduling reconciliation; never silently convert them or interpret their dates as Gregorian.

Non-Gregorian recurrence/calendar-system extensions are outside the supported profile. Host extension registration cannot bypass this boundary. This does not approve additional recurrence extensions merely because their values name Gregorian.

## Boundaries and consequences

The calendar system is independent of time zones, languages and display preferences. Retain existing distinctions between date-only values, UTC instants and named-zone local times, and keep the RFC 7953 date-time restrictions. No alternative calendar arithmetic, automatic conversion or calendar-system selector is part of the module contract.

Gregorian is the only supported system, rather than a configurable default. A future alternative requires a separate scope decision and semantic/interoperability evidence.

## Alternatives and acceptance conditions

Treating Gregorian as only a default would leave unsupported calendar systems ambiguous. Explicit rejection preserves the existing no-silent-loss and atomic import discipline.

Test explicit Gregorian and omitted CALSCALE, reject non-Gregorian/unknown values atomically, and verify leap-year/date and recurrence behavior across native APIs and supported interchange. Outbound representations must use Gregorian semantics and must not advertise another system. Verify host extensions cannot enable unsupported calendar arithmetic. Documentation checks do not establish runtime behavior.

Source: [RFC 5545 section 3.7.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.7.1).

Traceability: [requirements](../requirements.md), [RFC 5545 matrix](../rfc/rfc-5545.md), [compatibility](../compatibility.md), [ADR 0002](0002-compatibility-and-time.md), [interchange work](../roadmap.md#icalendar-and-metadata).
