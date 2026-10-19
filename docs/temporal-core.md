# Temporal core implementation

Status: **UTC query-window foundation only**, 2026-10-19. The pure Dart core now exports `UtcWindow`. Date-only and named-zone values, recurrence, calendar/task services and wire/storage representations remain unimplemented; no complete temporal or RFC support is claimed. See [ADR 0022](adr/0022-utc-query-window-foundation.md).

## UTC windows

```dart
final window = UtcWindow(
  start: DateTime.utc(2026, 10, 19, 9),
  end: DateTime.utc(2026, 10, 19, 10),
);
```

The start belongs to the window; the end does not. Construction rejects local, equal or reversed bounds with `ArgumentError`, and membership rejects a local instant. `overlaps` and `intersection` treat touching intervals as disjoint. `duration` is elapsed UTC time. Values compare by both bounds and support hash-based collections.

This is a calculation primitive, not a public Serverpod request model or an event representation. It does not convert civil/date-only values to UTC, enforce a product-specific query horizon, determine coverage/permissions or declare a period free. Date-only ends, DST handling, recurrence expansion and task lifecycle require their separate contracts before dependent implementation. Generated clients, tables and migrations are unchanged.

## Validation

Commands actually run with pinned Dart 3.13.5 / Serverpod 4.0.4:

- `flutter pub get --enforce-lockfile`: passed; existing workspace test dependencies resolved without a lockfile change.
- `dart format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: completed.
- `dart analyze --fatal-infos`: passed for the workspace.
- `dart test`, from `packages/serverpod_calendar_core`: fourteen tests passed, covering local/invalid bounds, leap-day rollover at microsecond precision, membership edges, adjacent/separated/partial/contained/equal intersections and equality/hashing.
- Serverpod MCP `hot_reload`: completed successfully. The core has no running endpoint consumer yet; reload confirms the example still accepts development tooling operations, not runtime coverage of core methods.
- PowerShell script syntax, relative documentation links, changed-file review and `git diff --check`: passed.

`tool/check.ps1` now runs the core tests alongside its existing checks. The complete database/browser/two-host suite was not rerun for this isolated pure-Dart increment: it changes no endpoint, generated output, database schema, authentication or Flutter UI. Prior scaffold/JWT evidence remains in [scaffold validation](scaffold-validation.md).
