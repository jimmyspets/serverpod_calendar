# ADR 0024: Civil date/time precision and leap-second profile

Status: **Precision/export and leap-second choices explicitly confirmed; core implementation locally verified; broader ADR acceptance remains under review**. Date: 2026-10-19.

Current-profile note: [ADR 0041](0041-whole-second-1970-2100-profile.md) supersedes this record's earlier date-range/precision/zone-envelope choices. Ordinary calendar dates are now 1970 inclusive to 2100 exclusive, with whole seconds and a special exclusive endpoint. The original increment and validation history below is preserved.

## Context and selected scope

The maintainer selected native microsecond precision and explicit rejection of lossy iCalendar export, rather than restricting native values to whole seconds. The maintainer also selected explicit leap-second rejection for the initial profile, rather than normalizing second 60 to 59 or expanding implementation to preserve leap seconds.

RFC 5545 TIME/DATE-TIME uses whole-second syntax and permits second 60 for positive leap seconds. Section 3.3.5 recommends interpreting 60 as 59 for implementations without leap-second support. Explicit rejection is the selected narrower product profile, not a claim that the RFC forbids leap seconds. Ordinary seconds 0–59 remain supported. Native fractions do not become a new iCalendar syntax extension.

## Implementation and boundaries

Add immutable `CivilDateTime` to the independent Dart core. It contains a validated `CalendarDate`, hour 0–23, minute/second 0–59 and a fractional-second microsecond count 0–999999. Seconds and fractions default to zero. Invalid fields throw `RangeError`; no rollover, truncation, rounding or leap-second normalization is performed. The date inherits selected years 0001–9999 from ADR 0023.

The field named `microsecond` denotes the entire fractional second; it is not Dart `DateTime.microsecond`'s remainder within a millisecond. Comparison is lexicographic wall-clock field ordering, not instant ordering across zones or a repeated local hour. Equality/hashing retain every field. Diagnostic text may include six fractional digits; it is not a wire serializer.

A civil tuple is not a supported floating event/task time. It stores no zone, UTC offset, instant or DST resolution. Potential gaps/folds can be represented as fields, but only a later named-zone resolver can determine whether a corresponding instant exists or is unique. Do not use civil comparison or subtraction as elapsed-time/availability calculations. Zone aliases, matching/version upgrades, gap/fold behavior and recurrence-generated versus explicit times remain review gates.

Future iCalendar export must reject nonzero native fractions explicitly before emitting lossy output. Future import must reject fractional TIME/DATE-TIME syntax and second 60 before mutation, with diagnostics. These adapter and atomicity paths are not implemented by the core constructor, and no parser/export support is claimed. No silent truncation, event omission or partial feed is authorized by this choice. Existing UTC-window precision remains unchanged.

## Alternatives and consequences

Whole-second native values simplify interchange but constrain native capability to a protocol limit. Microseconds preserve Dart-compatible native precision while requiring an explicit export failure for unrepresentable values. Preserving leap seconds requires dedicated validation/resolution rather than Dart constructor normalization; the RFC fallback was offered and not selected. Neither a standalone tuple nor diagnostic formatting enables floating input, arbitrary zones or implicit time conversions.

## Acceptance and evidence

Core tests cover default fields, time/fraction boundaries, invalid values, exact fractional preservation, leap-second rejection, all-field ordering/equality and diagnostic formatting. Tests also show that potential gap/fold tuples are retained without resolving zones; this is not DST correctness evidence. See [temporal validation](../temporal-core.md), [models](../models.md#shared-temporal-and-identity-values), [RFC profile](../rfc/rfc-5545.md), [ADR 0002](0002-compatibility-and-time.md), [ADR 0008](0008-module-clients-tasks-and-search.md) and [ADR 0023](0023-gregorian-date-only-values.md).

Sources: RFC 5545 [DATE-TIME](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.5) and [TIME](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.12). Keep schema and remaining temporal proposals subject to explicit review.
