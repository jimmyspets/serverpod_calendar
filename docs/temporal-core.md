# Temporal core implementation

Status: **UTC query windows and Gregorian date-only/civil values**, 2026-10-19. The pure Dart core exports `UtcWindow`, `CalendarDate` and `CivilDateTime`. Named-zone values, recurrence, calendar/task services and wire/storage representations remain unimplemented; no complete temporal or RFC support is claimed. See ADRs [0022](adr/0022-utc-query-window-foundation.md), [0023](adr/0023-gregorian-date-only-values.md) and [0024](adr/0024-civil-date-time-values.md).

## Gregorian date-only values

```dart
final date = CalendarDate(year: 2024, month: 2, day: 29);
```

The maintainer selected years 0001–9999. Construction rejects year zero, out-of-range years/months/days and impossible Gregorian dates with `RangeError`; values are never normalized. Dates retain only integer fields, with no `DateTime`, timezone or instant conversion. Gregorian leap rules apply consistently throughout the range, with no historical calendar cutover. Month lengths, leap-year inspection, chronological comparison and equality/hashing are available. `toString()` produces diagnostic YYYY-MM-DD text, not an iCalendar serialization contract.

This is not yet a generated request/storage model, all-day event span or interchange parser. Later adapters must enforce the selected date-only year range explicitly and atomically; RFC 5545's four-digit year grammar alone does not require the selected lower bound. UTC query windows continue to have their own instant contract. Civil precision and leap-second policy are selected under ADR 0024; zones and recurrence remain separate review gates.

## Civil date/time fields

```dart
final civil = CivilDateTime(
  date: CalendarDate(year: 2026, month: 10, day: 19),
  hour: 9,
  minute: 30,
  second: 5,
  microsecond: 123456,
);
```

Hours are 0–23, minutes/seconds 0–59 and the `microsecond` field is a complete fractional-second count 0–999999 (not Dart's microsecond-within-millisecond field). Seconds/fractions default to zero. Invalid fields, including leap second 60, throw `RangeError`. Comparison orders date/time fields; equality/hashing preserve all fields. Diagnostic text retains fractions without a zone suffix and is not a serializer.

The value retains wall-clock fields without timezone lookup, normalization or instant conversion. It can hold potential gap/fold fields, but does not validate or resolve them. It does not authorize floating event/task values or provide elapsed-time ordering across zones/folds. Named-zone policy remains required before converting a civil value to an instant.

The maintainer selected native microseconds, future iCalendar export rejection for nonzero fractions and initial leap-second rejection. RFC 5545 supports whole-second syntax and positive leap seconds; these choices define a narrower profile where applicable. The adapter must eventually enforce rejection atomically with diagnostics; the core value alone is not a tested import/export implementation. See [ADR 0024](adr/0024-civil-date-time-values.md).

## UTC windows

```dart
final window = UtcWindow(
  start: DateTime.utc(2026, 10, 19, 9),
  end: DateTime.utc(2026, 10, 19, 10),
);
```

The start belongs to the window; the end does not. Construction rejects local, equal or reversed bounds with `ArgumentError`, and membership rejects a local instant. `overlaps` and `intersection` treat touching intervals as disjoint. `duration` is elapsed UTC time. Values compare by both bounds and support hash-based collections.

This is a calculation primitive, not a public Serverpod request model or an event representation. It does not convert civil/date-only values to UTC, enforce a product-specific query horizon, determine coverage/permissions or declare a period free. Date-only ends, DST handling, recurrence expansion and task lifecycle require their separate contracts before dependent implementation. Generated clients, tables and migrations are unchanged.

## Initial UTC-window validation

Commands actually run with pinned Dart 3.13.5 / Serverpod 4.0.4:

- `flutter pub get --enforce-lockfile`: passed; existing workspace test dependencies resolved without a lockfile change.
- `dart format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: completed.
- `dart analyze --fatal-infos`: passed for the workspace.
- `dart test`, from `packages/serverpod_calendar_core`: fourteen tests passed, covering local/invalid bounds, leap-day rollover at microsecond precision, membership edges, adjacent/separated/partial/contained/equal intersections and equality/hashing.
- Serverpod MCP `hot_reload`: completed successfully. The core has no running endpoint consumer yet; reload confirms the example still accepts development tooling operations, not runtime coverage of core methods.
- PowerShell script syntax, relative documentation links, changed-file review and `git diff --check`: passed.

`tool/check.ps1` now runs the core tests alongside its existing checks. The complete database/browser/two-host suite was not rerun for this isolated pure-Dart increment: it changes no endpoint, generated output, database schema, authentication or Flutter UI. Prior scaffold/JWT evidence remains in [scaffold validation](scaffold-validation.md).

## Date-only increment validation

Commands actually run with the same pinned toolchain:

- `dart format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: five files checked, one formatted.
- `dart analyze --fatal-infos`: workspace analysis passed.
- `dart test`, from `packages/serverpod_calendar_core`: all **51** tests passed (37 date-only tests plus the 14 UTC-window tests). Date coverage includes the selected year boundaries, every non-leap month length/overflow, invalid fields, leap/non-leap centuries, 97 leap years and 146097 days in a Gregorian 400-year cycle, ordering and equality/hashing.
- Serverpod MCP `hot_reload`: completed successfully. Core methods are exercised by unit tests; there is still no endpoint consumer of these values.
- Relative documentation links/anchors, ADR index consistency, changed-file review and `git diff --check`: passed.

No dependencies, generated sources, migrations, database configuration, endpoints or Flutter UI changed. The existing root check script already includes these core tests. The complete database/browser/two-host suite was not repeated for this pure-Dart addition; no protocol/client interoperability is inferred from its tests.

## Civil date/time increment validation

Commands actually run with pinned Dart 3.13.5 / Serverpod 4.0.4:

- `dart format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: seven files checked, two formatted.
- `dart analyze --fatal-infos`: workspace analysis passed.
- `dart test`, from `packages/serverpod_calendar_core`: all **71** tests passed, including twenty new civil tests. New coverage includes defaults, exact microsecond fractions, time boundaries, invalid fields, leap-second rejection, ordering/equality, diagnostics and retaining potential gap/fold tuples without resolving them.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes the new value yet; core correctness evidence comes from the unit tests.
- Relative documentation links/anchors, ADR index consistency, changed-file review and `git diff --check`: passed.

No dependency, generated code, endpoint, schema, migration or Flutter UI changed. The root check script already discovers the new core tests. The complete database/browser/two-host suite was not repeated for this isolated core increment. Named-zone conversion, DST behavior, recurrence and iCalendar rejection/atomicity remain unimplemented and unverified.
