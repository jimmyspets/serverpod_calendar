# ADR 0029: Validated date-only recurrence rule values

Status: **Sorted, duplicate-free filter representation explicitly confirmed; broader API implementation remains proposed**. Date: 2026-10-20.

## Context and scope

The selected recurrence features need an immutable rule contract before an expansion engine. Implement DATE-only parameter validation first, keeping timed rules, occurrence generation and wire parsing separate. This does not narrow the required first-release hourly/minutely and zoned capabilities under [ADR 0010](0010-rfc5545-property-decisions.md); those remain planned.

Source: RFC 5545 [section 3.3.10](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10) defines recurrence fields, ranges and combination constraints. The existing profile excludes SECONDLY/BYSECOND and floating event times. Native dates retain selected years 0001–9999 under [ADR 0023](0023-gregorian-date-only-values.md).

## Proposed native contract

Expose `Weekday`, `ByDayValue`, `DateRecurrenceFrequency` and `DateRecurrenceRule` in the independent Dart core. Weekdays are Monday through Sunday, with `isoNumber` 1–7 matching `CalendarDate.weekday`. `ByDayValue` retains a weekday and optional signed nonzero ordinal in −53…53, with value equality/hashing. Rule context validates whether an ordinal is legal.

The DATE-only rule accepts daily/weekly/monthly/yearly frequency, positive interval (default 1), optional positive count or a typed inclusive `CalendarDate` until, all seven week starts (Monday default), and BYDAY/BYMONTHDAY/BYYEARDAY/BYWEEKNO/BYMONTH/BYSETPOS lists. COUNT and UNTIL cannot coexist. Whole scalars accept 1 through 2^53−1 for exact VM/web representation, consistently with the core's portable integer policy. This is a representation bound, not an RFC wire limit, allowed occurrence count, horizon or expansion budget.

Validate month/day/year/week/position ranges, reject zero signed selectors, reject weekly month-day filters, restrict DATE-only year-day/week-number filters to yearly rules, restrict ordinal weekdays to monthly/yearly, prohibit yearly ordinal weekdays with week-number filters, and require another BY part for set-position selection. Bad ranges throw `RangeError`; illegal combinations throw `ArgumentError`. Valid selectors can describe an empty candidate set (such as February 30) without being clamped into another date. Context-specific ordinal existence is determined during future generation.

Snapshot input lists and expose them as unmodifiable. The maintainer selected sorting filter lists and removing duplicates. The implementation sorts numeric lists and removes exact duplicate values; BYDAY sorts by weekday Monday–Sunday, then signed ordinal with omission occupying the zero position. Unnumbered Monday and first Monday remain distinct selections. Equality/hashing compare the resulting value fields. Canonicalization does not collapse overlapping selectors, prove that arbitrary different rules generate the same dates or authorize dropping unsupported parts. The maintainer explicitly selected “Sort and remove duplicates” on 2026-10-20; preserving supplied order/duplicates was offered and not selected.

## Boundaries and safeguards

Empty native lists mean no filter, not an accepted empty wire rule part. No parser/serializer, timed frequency/filter representation, UTC/zoned UNTIL contract, start alignment check, inclusive-end evaluation, invalid-date skipping, COUNT execution, week-number calculation, candidate evaluation order, RDATE/EXDATE or override identity is implemented. An adapter must validate unsupported/malformed syntax before constructing a narrower native value; it must never drop clock/deferred parts to make an input fit this class. Repeated rule properties/parts are separate from duplicate values inside a filter.

Task occurrence lifecycle, undefined start/rule combinations, protocol integer limits, practical input/work/result limits and incomplete-query behavior still require explicit contracts before endpoints/generation. The pure constructor does not authorize unlimited work or establish complete coverage. Date-only parameters can span the date profile; the named-zone 1900–2037 envelope and narrower coverage safeguards remain unchanged.

## Alternatives and consequences

Building the full engine before its rule validator would mix syntax/structural errors with candidate work. One nullable union for date and timed ends risks mixing temporal types; a DATE-specific rule avoids that while the timed contract is pending. Retaining supplied duplicate/order syntax was offered as the alternative to canonical native lists; source-lexical preservation belongs to a separate adapter model if required. The implementation remains reviewable without treating the broader proposed schema as accepted.

## Validation and acceptance

Check scalar and selector bounds, legal/illegal combinations, every week start, signed weekday ordinals, count/until exclusion, date-bound retention, exact duplicate handling, immutable snapshots and every equality/hash field on VM and Chrome. Record actual commands/results in [temporal core validation](../temporal-core.md). No generated-client, recurrence expansion, protocol or client compatibility is inferred from these tests.
