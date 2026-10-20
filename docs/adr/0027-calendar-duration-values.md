# ADR 0027: Unit-preserving native duration values

Status: **Microsecond precision/export rejection explicitly confirmed; value implementation proposed; broader temporal policies remain under review**. Date: 2026-10-20.

## Context and source evidence

Calendar operations need durations that retain nominal calendar units independently of elapsed clock time. RFC 5545 [section 3.3.6](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.6) separates week-only syntax from day/clock syntax, excludes month/year units and specifies date-sensitive duration application. Its wire grammar has whole-second precision. Property/component constraints are separate from the general value grammar.

The maintainer explicitly selected native microsecond duration precision and rejection of lossy future iCalendar export. This extends the native precision choice recorded for civil values in [ADR 0024](0024-civil-date-time-values.md); it does not introduce fractional iCalendar syntax.

## Proposed value contract

Implement immutable `CalendarDuration` with `sign` (+1 or -1), nonnegative `weeks`, `days`, `hours`, `minutes`, `seconds`, and `microsecond` (the full fractional-second magnitude 0–999999). Sign defaults to +1; all magnitudes default to zero. Reject invalid signs, negative components and unsupported magnitudes. Nonzero weeks cannot coexist with any other nonzero unit. Zero-valued fields do not retain lexical presence; this is a semantic value, not a lossless syntax tree.

Preserve units without carrying or clamping: 25 hours remains 25 hours, 60 seconds is a duration magnitude rather than a leap-second timestamp, and one calendar day remains distinct from 24 clock hours. Equality/hashing are structural, including sign and all fields; no ordering or context-free elapsed-total conversion is provided. Zero magnitudes are allowed and identified by `isZero`; a supplied negative sign is retained even on zero. Consumers must inspect zero separately from sign and enforce their legal context.

Each whole-unit magnitude is bounded by `maxComponent = 9007199254740991` (2^53−1), the positive exact-integer representation ceiling shared by the selected Dart VM/web profile. See [Dart number documentation](https://dart.dev/language/built-in-types#numbers). This is an implementation representation bound, not an RFC duration limit or an approved scheduling horizon. Future operations must check aggregation, result range and work limits before arithmetic; no sum or product is computed by this value.

Future iCalendar export must reject a nonzero fractional magnitude, never truncate it; import must reject fractional duration syntax before mutation. No parser/exporter exists yet. Native precision remains independent of narrower feed projections.

## Deliberate boundaries

This increment does not apply durations to dates, civil times or instants, choose a DST endpoint policy, define event/task span defaults, permit negative event lengths or configure alarm-repeat intervals. Positive/nonzero requirements, DATE-only unit restrictions, pairing/cardinality rules, trigger policy, operational limits and transactional import validation remain consumer/adapter contracts. A generic zero or signed value does not bypass them. The named-zone 1900–2037 envelope and narrower coverage failures are unchanged.

## Alternatives and consequences

Flattening everything into Dart `Duration` loses nominal day/week meaning. Restricting native values to seconds was offered and not selected. Normalizing clock components or canonicalizing signed zero now would add representation changes without a reviewed adapter contract. Retaining components lets future operations apply the appropriate semantics explicitly, while requiring consumers to avoid structural equality as an elapsed-duration comparison.

## Acceptance conditions

Verify every component bound on VM and Chrome, invalid signs, prohibited mixed weeks, native fractions, zero/sign retention, non-normalization and all-field equality/hashing. Record actual commands/results in [temporal core validation](../temporal-core.md). Do not infer RFC property, DST arithmetic, generated-client or runtime alarm support from constructor tests.
