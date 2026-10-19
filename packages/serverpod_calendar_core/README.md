# serverpod_calendar_core

Framework-independent Dart calendar semantics. The initial implementation exports `UtcWindow`: validated UTC bounds, half-open membership, overlap/intersection and value equality. It has no runtime dependencies on Serverpod or Flutter.

Run `dart test` from this package. See the repository [temporal core contract and validation](../../docs/temporal-core.md). Date-only values, zones, recurrence and full calendar behavior remain unimplemented.
