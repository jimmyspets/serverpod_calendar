# serverpod_calendar_core

Framework-independent Dart calendar semantics:

- `UtcWindow`: validated UTC bounds, half-open membership, overlap/intersection and value equality.
- `CalendarDate`: Gregorian date-only fields for years 0001–9999, strict date validation, leap-year/month lengths, chronological ordering and value equality.
- `CivilDateTime`: validated Gregorian wall-clock fields, microsecond precision, leap-second rejection and field ordering/equality; no implicit zone or instant.

The package has no runtime dependencies on Serverpod or Flutter. Run `dart test` from this package. See the repository [temporal core contract and validation](../../docs/temporal-core.md). Named zones, recurrence, interchange and calendar services remain unimplemented.
