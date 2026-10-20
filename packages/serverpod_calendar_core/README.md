# serverpod_calendar_core

Framework-independent Dart calendar semantics:

- `UtcWindow`: validated UTC bounds, half-open membership, overlap/intersection and value equality.
- `CalendarDate`: Gregorian date-only fields for years 0001–9999, strict date validation, leap-year/month lengths, calendar-day addition/distance, Monday-based weekdays, chronological ordering and value equality.
- `DateEventSpan`: DATE-only event bounds with preserved optional end/duration, exclusive-end membership/overlap, positive day/week durations and a one-day default. Effective end must remain within years 0001–9999; no task or UTC occupancy integration.
- `DateEventSeries`: bounded uniform-length DATE-only occurrence queries over half-open date ranges, including earlier overlapping starts. Preserves full spans and template form; no clipping, merged occurrences, moved overrides, UTC occupancy or availability decisions.
- `CivilDateTime`: validated Gregorian wall-clock fields, microsecond precision, leap-second rejection and field ordering/equality; no implicit zone or instant.
- `CalendarDuration`: signed, unit-preserving week/day/clock magnitudes and native microseconds; strict structural validation and explicit date/calendar-first zoned application. Property-specific constraints remain pending.
- `DateRecurrenceRule`, `DateRecurrenceFrequency`, `Weekday`, `ByDayValue`: immutable DATE-only recurrence parameters with range/combination validation and canonical filter lists; no expansion.
- `IsoWeekDate.fromDate`: native ISO week-year, week and weekday fields, independent of recurrence WKST, locale and timezone. Monday-first; week 1 contains January 4. No GUI or parser.
- `DateRecurrenceGenerator`: bounded initial DATE-only start-date generation with COUNT/UNTIL, period filters and explicit limit errors. Yearly BYWEEKNO honors all WKST values and adjacent week-years; timed recurrence remains pending; native DATE-only exceptions are separate below.
- `DateRecurrenceSet`: bounded DATE-only additions/exclusions, including earlier inclusions, with exclusion precedence and unchanged rule COUNT/UNTIL. Separate explicit-input, candidate, raw-rule and final-result limits; no timed/PERIOD values or overrides.
- `DateEventException` / `DateEventOccurrence`: original DATE identity independent of a complete replacement span; cancellation and structural equality. Identity is scoped to one series context.
- `DateEventExceptionSet`: immutable native single-occurrence exceptions with bounded effective-set membership validation, duplicate/EXDATE target rejection and moved/changed-length overlap queries. Separate raw exception, validation, base and final output budgets; no range/task/protocol or persistence behavior.
- `NamedZoneResolver`: pinned IANA names/aliases, RFC explicit gap/fold resolution, original-field preservation and explicit coverage failures, plus guarded UTC-to-local projection. Civil-year envelope 1900–2037; some zones/periods are conservatively unsupported.

The package has no runtime dependencies on Serverpod or Flutter. It pins the pure Dart `timezone` package at 0.11.2 with IANA 2026e data. Run `dart test` and `dart test --platform chrome` from this package. See the repository [temporal core contract and validation](../../docs/temporal-core.md). VTIMEZONE matching, general all-zone/year coverage, complete recurrence expansion, interchange and calendar services remain unimplemented.
