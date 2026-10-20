# ADR 0035: DATE-only event spans

Status: **Scoped implementation proposal for DATE-only event bounds; broader span, schema and recurrence contracts remain under review**. Date: 2026-10-20.

## Context and source evidence

Recurrence currently returns start dates, not occupied event spans. The generic `CalendarDuration` intentionally permits signed/zero values because consumers have different constraints. A separate event-specific value must enforce its own rules without changing task or alarm semantics.

RFC 5545 [section 3.6.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1) defines an inclusive event start, an exclusive end and a one-day default when a DATE event omits both end and duration. DATE event durations use days or weeks. [Section 3.8.2.5](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.2.5) requires a positive event duration. Native computation evidence below does not establish wire parsing or complete VEVENT support.

## Implementation proposal

Expose immutable `DateEventSpan(start, end?, duration?)` in the independent Dart core. Retain the original optional `end` and unit-preserving `duration` rather than replacing both with resolved bounds. Supplying both is invalid, even if they imply the same end. Explicit end must follow start. Duration must be positive, nonzero and contain no nonzero clock/fraction fields; use existing bounded date arithmetic to apply days/weeks. Omitting both yields one calendar day.

Expose derived `endExclusive` and `dayCount`, half-open `contains(CalendarDate)` and symmetric `overlaps(DateEventSpan)`. Adjacent spans do not overlap. Day count is not an elapsed number of hours; calculations use dates only, with no UTC conversion, DST resolution or locale. Structural equality/hash retain start/end/duration intent: implicit one day, explicit next-day end and a one-day duration have equal occupied bounds but remain different values; one week is not rewritten to seven days.

## Profile boundary

Every effective exclusive end must itself be a `CalendarDate` in years 0001–9999. The selected date profile therefore cannot represent a nonempty event covering 9999-12-31: its end would require year 10000. Reject default/duration overflow with `RangeError`, never truncate, wrap, silently skip or introduce an end-of-time sentinel. An event ending exactly at 9999-12-31 is valid but does not include that date. This is a scoped representability limit, not a new RFC restriction or a reduction of standalone date support. A wider endpoint strategy would require another design change.

## Alternatives and consequences

Flattening duration/default forms into an explicit end would lose canonical input intent needed by future adapters. Attaching midnight UTC would introduce unwanted instant semantics. Treating a missing DATE end as a point would violate event defaults. Silent endpoint clipping would shorten events and could produce incorrect availability.

This value does not resolve UTC occupancy, infer busy status/transparency, authorize queries, create tasks/bookings or apply span lengths to recurrence occurrences. Timed spans, task due/default rules, moved/cancelled overrides, overlapping occurrence queries, service integration and parser/export remain pending. The main README warning and bounded named-zone coverage remain unchanged; valid dates after 2037 cannot bypass zone guards.

## Validation and acceptance

Test defaults and preserved forms, positive day/week duration application, rejected end/duration combinations, nonpositive and clock-valued duration rejection, leap centuries, year crossings, half-open boundaries, symmetric overlap and independent occupied-date set comparisons, equality/hash, maximum representable bounds and huge-component rejection. VM/Chrome tests include unchanged named-zone rejection. Record actual commands/results in [temporal core validation](../temporal-core.md#date-only-event-span-validation). The API remains proposed for review; no model/schema approval or interoperability claim follows from these tests.
