# ADR 0063: iCalendar temporal value codecs

Status: **Proposed adapter API/mechanics; existing temporal policy unchanged**. Date: 2026-10-22.

## Context and sources

The maintainer requested continued implementation in the recommended order after the [syntax foundation](0062-bounded-icalendar-syntax-foundations.md). Before component mapping, provide explicit typed codecs for [RFC 5545 DATE, DATE-TIME and DURATION](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.4). Existing [ADR 0041](0041-whole-second-1970-2100-profile.md) and named-zone/duration decisions remain authoritative: whole seconds, ordinary dates in [1970-01-01, 2100-01-01), explicit exclusive midnight endpoints, exact pinned zone keys and calendar-first duration application.

## Proposed implementation boundary

Add six pure functions in serverpod_calendar_icalendar: parse/serialize DATE to CalendarDate, DATE-TIME to TimedValue, and DURATION to CalendarDuration. Do not add database models, migrations, endpoints, import transactions or publication projections. The API adapts individual raw syntax property values to existing framework-independent core types; it does not approve property names, parameters, component contexts, cardinalities or a complete calendar.

DATE accepts exactly eight ASCII digits. DATE-TIME accepts basic uppercase T/Z forms with seconds; UTC forbids a supplied zoneId, while local fields require an explicit zoneId. Reject fractions including .000, numeric UTC offsets, leap seconds, invalid fields, alternate ISO spellings, lists, escapes and surrounding/trailing data. Lowercase designators reject in this strict profile. Validate fields before constructing Dart DateTime to prevent normalization.

Permit the sole additional date 2100-01-01 only with explicit exclusiveEnd opt-in on parsing and serialization; a timed endpoint must be midnight. This flag is not general permission to store 2100 values: the enclosing property/span adapter must justify exclusive semantics and validate ordering.

Named values retain supplied civil fields and exact IANA names/aliases through the core resolver, including gap fields and first-fold resolution. Reject unknown/case-mismatched keys; propagate unprovable coverage as a typed failure. Output retains local fields without Z; callers must separately emit the exact TZID and validate the required zone definition/context. This low-level named-zone function does not validate supplied VTIMEZONE definitions and must not be used to bypass their matching gate.

DURATION accepts signed weeks, days and clock magnitudes under the RFC grammar. Preserve nonzero units and negative zero, without carrying minutes or converting days to hours. Deterministic output drops leading plus, redundant leading zeroes and zero-unit spellings; zero becomes PT0S (or -PT0S). Emit a zero-minute slot between nonzero hours and seconds as required by the grammar. Reject years/months, fractional values, mixed week/day forms and invalid ordering. Positivity, date-only restrictions, legal property context and application horizon are enforced by the future component adapter/core operation, not the generic value codec.

## Bounds, alternatives and consequences

DATE and DATE-TIME have fixed wire lengths. Cap duration input at 128 UTF-16 code units before regex/BigInt work and zone identifiers at 255 before resolution. These are resource bounds, not RFC maxima. Check each duration magnitude exactly against the core portable integer maximum 9007199254740991 using BigInt before conversion, including on Chrome. Do not treat representable magnitudes as a permitted scheduling horizon. Errors carry a structured kind and never echo values, zone identifiers or nested resolver exceptions.

Keeping raw strings everywhere would defer invalid input and encourage lossy DateTime parsing. Implementing VEVENT/availability import at this step would conflate value conversion with unresolved source/property preservation and transaction authority. Retain the generic syntax tree for original spelling where needed; core values preserve temporal meaning rather than a byte archive. Unsupported component/property input still requires atomic explicit rejection at the future domain boundary.

## Acceptance and remaining work

Verify invalid/over-limit input, native/browser exact-integer boundaries, the exclusive endpoint in both directions, DST gaps/folds/aliases, unit preservation and deterministic generated round trips. Integrate syntax values without claiming a component import. Run focused tests while implementing and broader checks once this batch is complete. Full component semantic validation, recurrence wire values, VTIMEZONE matching, source-preserving mapping, authorized import/export and feeds remain separate work.
