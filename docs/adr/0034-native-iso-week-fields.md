# ADR 0034: Native ISO week fields

Status: **Implementation proposal for the confirmed ISO convention; API shape remains subject to review**. Date: 2026-10-20.

## Context and confirmed convention

The maintainer requires ISO 8601 week numbers and Monday-first native calendars under [ADR 0032](0032-iso-week-convention.md). Recurrence supports explicit alternate WKST values, but its rule-specific membership must not supply native display labels. This increment exposes the confirmed native convention as a pure-core projection; it does not change recurrence rules.

[Python's primary ISO calendar documentation](https://docs.python.org/3/library/datetime.html#datetime.date.isocalendar) describes Monday-based weeks, week 1 containing the first Thursday and the separate ISO year/week/weekday fields. It supplies an independent test reference, not a runtime dependency or a claim of complete ISO 8601 format support.

## Implementation proposal

Expose immutable `IsoWeekDate.fromDate(CalendarDate)` with `weekYear`, `week` and `weekday`. Weekdays are Monday 1 through Sunday 7. Week 1 contains January 4; an ISO week-year has 52 or 53 weeks. A week's Thursday determines its ISO year. For example, 2021-01-03 projects to year 2020, week 53, weekday 7; 2024-12-30 projects to year 2025, week 1, weekday 1.

Use existing Gregorian integer date arithmetic, without timestamps, timezone conversion, device locale or a WKST argument. Project to the week's Thursday and count complete seven-day groups from January 1 of that Thursday's year. The supported profile begins on Monday 0001-01-01 and ends on Friday 9999-12-31, so even its boundary weeks have their Thursday inside years 0001–9999. No out-of-profile date or year is constructed. The projection returns validated derived fields only; arbitrary week-field construction, inverse conversion and parsing are outside this increment.

Equality/hash use all three fields. Diagnostic `toString()` returns padded `YYYY-Www-D`, such as `2020-W53-7`; this is not an iCalendar serializer, localized UI label or authorization to use week-date syntax in an adapter.

## Alternatives and consequences

Using Gregorian year alongside an ISO week number would mislabel New Year dates. Reusing arbitrary recurrence WKST would violate the selected native convention. Using locale-dependent first-day defaults would make native calendars inconsistent. Keep the projection distinct from recurrence membership instead.

The API supports the existing Gregorian date-only years 0001–9999. It does not expand the named-zone envelope of 1900–2037 or narrower per-zone coverage. The main README warning remains unchanged. Flutter layout, wire/storage models, timed recurrence and protocol interoperability remain pending; no generated clients or tables change.

## Acceptance and validation

Test known year/week boundaries, leap/non-leap centuries, both profile ends, value equality and diagnostics. Independently compute Python `datetime.date.isocalendar()` fixtures and rolling fingerprints for every day in cycles 0001–0400 and 2000–2399, plus January 1/4 and December 28/31 in every year 0001–9999. Fingerprints are regression checks, not cryptographic proofs. Also compare every day of 400 ISO years with independently constructed January 4/Monday boundaries; verify 71 long week-years. A Sunday-WKST recurrence fixture must retain its rule while receiving the separate native ISO label. Run VM/Chrome tests and record actual results in [temporal core validation](../temporal-core.md#native-iso-week-field-validation).
