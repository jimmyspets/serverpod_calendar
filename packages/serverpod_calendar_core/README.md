# serverpod_calendar_core

Framework-independent Dart calendar semantics:

- `UtcWindow`: validated UTC bounds, half-open membership, overlap/intersection and value equality.
- `CalendarDate`: Gregorian date-only fields for years 0001–9999, strict date validation, leap-year/month lengths, calendar-day addition/distance, Monday-based weekdays, chronological ordering and value equality.
- `CivilDateTime`: validated Gregorian wall-clock fields, microsecond precision, leap-second rejection and field ordering/equality; no implicit zone or instant.
- `NamedZoneResolver`: pinned IANA names/aliases, RFC explicit gap/fold resolution, original-field preservation and explicit coverage failures. Civil-year envelope 1900–2037; some zones/periods are conservatively unsupported.

The package has no runtime dependencies on Serverpod or Flutter. It pins the pure Dart `timezone` package at 0.11.2 with IANA 2026e data. Run `dart test` and `dart test --platform chrome` from this package. See the repository [temporal core contract and validation](../../docs/temporal-core.md). VTIMEZONE matching, general all-zone/year coverage, recurrence, interchange and calendar services remain unimplemented.
