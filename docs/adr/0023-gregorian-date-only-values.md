# ADR 0023: Gregorian date-only values and year range

Status: **Year-range choice explicitly confirmed; implementation locally verified; broader ADR acceptance remains under review**. Date: 2026-10-19.

## Context and selected scope

Gregorian-only dates and separation from UTC instants are existing requirements. The maintainer selected years **0001–9999** for the date-only native/interchange profile after being offered 0000–9999 and a broader native range. Reject year zero and out-of-range years explicitly; do not clamp, wrap or silently discard them.

RFC 5545 section 3.3.4 specifies a four-digit year grammar. The lower bound of 0001 is the selected product profile, not a claim that the RFC grammar itself excludes 0000. This decision concerns `CalendarDate` and future date-only interchange validation; it does not change the `UtcWindow` instant range or claim that an iCalendar adapter already exists.

## Implementation

Add immutable `CalendarDate(year, month, day)` semantic values to the independent Dart core. Validate years 1–9999, months 1–12 and each month's actual Gregorian day range. Apply Gregorian leap rules: divisible by four, excluding centuries unless divisible by 400. Reject invalid fields with `RangeError` before returning a value; never normalize February 30 into March.

Keep only integer date fields. Do not construct midnight UTC/local timestamps, attach a timezone, calculate an elapsed duration or offer an implicit instant conversion. Date comparison, equality/hashing, leap-year/month-length inspection and diagnostic YYYY-MM-DD text operate on those fields. The diagnostic string is not a parser, interchange serializer or wire contract. No calendar reform cutover is introduced; Gregorian rules are applied consistently within the selected range.

## Alternatives

Including year zero follows the full lexical four-digit range but was not selected. A broader native range would require a separate interchange restriction and explicit export rejection. Using `DateTime` as a stored date risks accidental timezone/instant semantics and constructor normalization. Field validation keeps dates independent of DST and the device timezone.

## Consequences and acceptance

Native callers get valid comparable dates in the selected range. Later adapter/endpoint validators must reject unsupported date-only years atomically; the pure value alone does not establish those protocol or persistence paths. Civil-time precision, leap seconds, named-zone resolution, DST gap/fold policies, recurrence and nominal duration arithmetic remain separate contracts. Date-only event end semantics are still enforced by future event/span services, not this single-date value.

Tests cover year/profile boundaries, invalid fields and month overflow, Gregorian leap centuries, a complete 400-year cycle, date ordering, equality/hash behavior and diagnostic text. See [temporal core validation](../temporal-core.md), [model catalog](../models.md#shared-temporal-and-identity-values), [FR-05](../requirements.md), [ADR 0013](0013-gregorian-only.md) and [RFC 5545 DATE](../rfc/rfc-5545.md). Keep proposed schemas and remaining ADRs unaccepted until their explicit review.

Source: [RFC 5545 section 3.3.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.4).
