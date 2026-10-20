# Temporal core implementation

Status: **temporal values, bounded named-zone operations and initial bounded date-only recurrence**, 2026-10-20. The pure Dart core exports `UtcWindow`, `UtcEventSpan`, `CalendarDate`, `DateEventSpan`, `DateEventSeries`, native DATE exception/occurrence/range values, `CivilDateTime`, `CalendarDuration`, `NamedZoneResolver`, `IsoWeekDate` and DATE-only recurrence parameter/generator/set types. Full recurrence expansion, calendar/task services, imported-zone validation and wire/storage representations remain unimplemented; no complete temporal or RFC support is claimed. See ADRs [0022](adr/0022-utc-query-window-foundation.md), [0023](adr/0023-gregorian-date-only-values.md), [0024](adr/0024-civil-date-time-values.md) and [0025](adr/0025-bounded-named-zone-resolution.md).

## ISO 8601 week convention

The native convention is ISO 8601: Monday first (1–7), week 1 containing January 4 (equivalently, the first Thursday), and a separate ISO week-year. The current recurrence default of Monday uses this convention. Explicit RFC WKST values are honored, including non-Monday starts and their rule-specific week numbers; those calculations are not ISO display labels. See [the behavior and examples](week-conventions.md) and [ADR 0032](adr/0032-iso-week-convention.md). `IsoWeekDate.fromDate(CalendarDate)` now exposes immutable native `weekYear`, `week` and `weekday` fields under [ADR 0034](adr/0034-native-iso-week-fields.md). For 2021-01-03 they are 2020, 53 and 7; for 2024-12-30 they are 2025, 1 and 1. Pair the ISO week-year with the week number. The pure date projection never consults timestamps, locale, zones or recurrence WKST. Diagnostic `YYYY-Www-D` text is not a parser or adapter format. Flutter presentation remains pending.

## Gregorian date-only values

```dart
final date = CalendarDate(year: 2024, month: 2, day: 29);
```

The maintainer selected years 0001–9999. Construction rejects year zero, out-of-range years/months/days and impossible Gregorian dates with `RangeError`; values are never normalized. Dates retain only integer fields, with no `DateTime`, timezone or instant conversion. Gregorian leap rules apply consistently throughout the range, with no historical calendar cutover. Month lengths, leap-year inspection, chronological comparison and equality/hashing are available. `toString()` produces diagnostic YYYY-MM-DD text, not an iCalendar serialization contract.

`addDays(int)` moves forward or backward by calendar days and rejects results outside 0001–9999. `daysUntil(other)` returns the signed calendar-day count from this date to the other; `weekday` uses Monday 1 through Sunday 7. These operations use Gregorian integer arithmetic without timestamps. Calendar days do not imply elapsed 24-hour durations, recurrence week numbers or month-end clamping. The named-zone 1900–2037 envelope and narrower coverage guards are unchanged. See [ADR 0026](adr/0026-gregorian-calendar-day-arithmetic.md).

This single-date value is not a generated request/storage model or interchange parser. Scoped all-day event spans now exist separately under [ADR 0035](adr/0035-date-only-event-spans.md). Later adapters must enforce the selected date-only year range explicitly and atomically; RFC 5545's four-digit year grammar alone does not require the selected lower bound. UTC query windows continue to have their own instant contract. Civil precision and leap-second policy are selected under ADR 0024; zones and recurrence remain separate review gates.

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

The value retains wall-clock fields without timezone lookup, normalization or instant conversion. It can hold potential gap/fold fields, but does not validate or resolve them. It does not authorize floating event/task values or provide elapsed-time ordering across zones/folds. Explicit conversion is available through the bounded `NamedZoneResolver` below; a bare civil value still implies no zone or instant.

The maintainer selected native microseconds, future iCalendar export rejection for nonzero fractions and initial leap-second rejection. RFC 5545 supports whole-second syntax and positive leap seconds; these choices define a narrower profile where applicable. The adapter must eventually enforce rejection atomically with diagnostics; the core value alone is not a tested import/export implementation. See [ADR 0024](adr/0024-civil-date-time-values.md).

## Unit-preserving duration values

```dart
final reminderOffset = CalendarDuration(sign: -1, minutes: 15, microsecond: 123456);
final nominalDay = CalendarDuration(days: 1);
final clockHours = CalendarDuration(hours: 24);
```

`CalendarDuration` retains sign (+1/-1), nonnegative week/day/hour/minute/second magnitudes and a full fractional-second `microsecond` magnitude 0–999999. Each whole unit accepts 0 through 9007199254740991 for exact VM/web representation; this is not a permitted operational horizon. Nonzero weeks cannot mix with other nonzero units. Invalid magnitudes throw `RangeError`; invalid signs and mixed weeks throw `ArgumentError`. Nothing is carried or normalized. Structural equality/hashing retain sign and every unit: the day and clock-hour examples remain distinct. Zero is permitted by the generic value (`isZero`), with a supplied negative sign retained.

The maintainer selected microseconds and future iCalendar export rejection for nonzero fractions. The wire adapter must reject fractional duration input and lossy output atomically; those paths remain unimplemented. Explicit date/zoned application is described below; the value has no context-free elapsed total and does not validate event/task/alarm constraints. Consumer-specific positivity, wire DATE-only syntax, repeat pairing and practical limits remain separate work. See [ADR 0027](adr/0027-calendar-duration-values.md).

## Duration application

```dart
final nextDate = CalendarDuration(weeks: 1).addToDate(date);
final end = CalendarDuration(days: 1, hours: 1).addToZoned(
  civil,
  zoneId: 'Europe/Stockholm',
  resolver: NamedZoneResolver(),
);
```

Date-only application accepts signed days/weeks and zero; any nonzero clock magnitude throws `ArgumentError`. Check result capacity before multiplying weeks, and reject dates outside 0001–9999 with `RangeError`. No timestamp is constructed.

The maintainer selected calendar-units-first zoned application: resolve the start, move weeks/days in its requested local fields, resolve the intermediate with RFC explicit gap/fold rules, then apply clock units as elapsed time. The result is UTC. A gap start's requested fields remain the basis for calendar movement; clock-only/zero application uses its resolved instant. Negative operations follow the same order and are not guaranteed inverse operations across discontinuities. Clock aggregation uses arbitrary precision and checks bounds before narrowing to an instant.

`NamedZoneResolver.localAt(utc, zoneId: ...)` projects a known UTC instant to civil fields without choosing a new fold instant. Non-UTC input and unknown exact keys fail; unknown offsets/coverage throw `ZoneCoverageException`. The final local year must be 1900–2037, allowing only UTC spillover that still projects into that local envelope. Zoned application checks the start, calendar intermediate and final projection, even for zero durations. It preserves a later-fold elapsed endpoint instead of re-resolving its fields to an earlier instant. See [ADR 0028](adr/0028-duration-application.md).

These methods do not establish legal event/task/alarm lengths, span defaults, UTC-only application, query budgets, recurrence or iCalendar support. Wire adapters must validate syntax before constructing semantic values, because zero-component lexical presence is not retained.

## Date-only recurrence rule parameters

```dart
final rule = DateRecurrenceRule(
  frequency: DateRecurrenceFrequency.monthly,
  byDay: [ByDayValue(weekday: Weekday.friday, ordinal: -1)],
  count: 12,
);
```

This stores and validates a DATE-only rule; it does not generate the last Fridays. Supported parameter cadence is daily/weekly/monthly/yearly. Interval defaults to one; count and a typed `CalendarDate` until are mutually exclusive. Positive interval/count values use the exact portable 1…2^53−1 representation range, not a work budget. Week start accepts every weekday and defaults to Monday. Weekday identity is independent of Flutter display preferences.

Validate selector ranges and RFC combinations: signed nonzero month-day/year-day/week-number/set-position selectors; months 1–12; optional nonzero BYDAY ordinal −53…53. Weekly rules reject month days; DATE-only year-day and week-number filters require yearly cadence; ordinal weekdays require monthly/yearly and cannot mix with yearly week-number filters. Set positions require another BY part. Invalid ranges throw `RangeError`; invalid combinations throw `ArgumentError`.

Native filter lists are snapshotted, sorted and deduplicated by exact value, and returned unmodifiable. The maintainer explicitly confirmed sorting filters and removing duplicates on 2026-10-20. BYDAY sorts Monday–Sunday, then ordinal with omission at zero; unnumbered and numbered weekdays remain distinct. Equality/hashing retain every field. Empty lists mean absent filters. Structurally legal selections that may yield no dates remain unchanged.

No start/rule alignment, inclusive UNTIL evaluation, COUNT execution, invalid-date skipping, week-number calculation, timed rule/UNTIL support, bounded expansion or adapter is implemented here. Future adapters must reject malformed/unsupported syntax before constructing a narrower value; they cannot strip timed filters or confuse empty native lists with valid empty wire parts. The named-zone 2037 guard remains unchanged. See [ADR 0029](adr/0029-date-recurrence-rule-values.md).

## Initial bounded date-only generation

```dart
final dates = DateRecurrenceGenerator().expand(
  start: CalendarDate(year: 2026, month: 1, day: 30),
  rule: rule,
  from: CalendarDate(year: 2026, month: 1, day: 1),
  through: CalendarDate(year: 2026, month: 12, day: 31),
  maxCandidateDays: 400,
  maxResults: 20,
);
```

This returns immutable sorted start dates within an **inclusive** date range. It is not an event overlap query or event-end convention. Support daily/weekly/monthly/yearly intervals, date filters including yearly BYWEEKNO, all week starts, COUNT and inclusive UNTIL. Invalid month-end/leap dates are omitted without consuming COUNT; missing fields inherit the start where appropriate. Position selection uses the full cadence period, then applies query/end bounds. Earlier occurrences still consume COUNT.

The maintainer selected rejecting starts that do not match their rule, including first-period BYSETPOS; UNTIL before the start is also rejected. Validate starts even for empty output ranges. Each date examined in a period consumes the required work budget, including rejected/pre-query/full-period dates. Exceeding work or output limits throws `RecurrenceLimitException` without returning a partial list; an exactly full output limit requires proof of completion. Practical trusted server limits remain to be defined before any endpoint exposes this API.

Yearly BYWEEKNO uses the week containing January 4 under the supplied WKST. Dates near New Year may carry an adjacent week-year; negative selectors use that actual week-year's 52/53-week length. Without BYDAY, retain all matching week days. Yearly cadence and BYSETPOS remain anchored to calendar-year periods, while other filters apply to actual calendar dates. Missing week 53 is skipped without consuming COUNT. See [ADR 0031](adr/0031-date-recurrence-week-numbers.md).

Private adjacent week-year labels 0/10000 are integer boundaries, never additional accepted dates. BYSETPOS on a week clipped by date-profile year 0001/9999 throws `RangeError`. Cadence arithmetic checks large intervals before multiplication. The implementation scans from DTSTART rather than fast-forwarding with unproved COUNT semantics. DATE-only additions/exclusions are implemented separately under [ADR 0033](adr/0033-date-recurrence-sets.md). Timed/PERIOD values, range/task exceptions, timed spans and adapters remain pending. Native DATE-only exceptions are separate under [ADR 0037](adr/0037-date-only-single-occurrence-exceptions.md). See [ADR 0030](adr/0030-bounded-date-recurrence-generation.md).

## Bounded named-zone resolution

```dart
final resolver = NamedZoneResolver();
final result = resolver.resolve(civil, zoneId: 'Europe/Stockholm');
```

Use exact, case-sensitive keys from pinned `timezone` 0.11.2 / IANA 2026e `latest_all` data. Aliases such as `US/Eastern` retain their supplied spelling; no geographical meaning is guessed from a Windows label or abbreviation. Version/profile metadata identifies the calculation rules. See [ADR 0025](adr/0025-bounded-named-zone-resolution.md).

The selected outer envelope is civil years 1900–2037. **Per-zone coverage can be narrower, or unavailable for some tables.** The package overwrites its first transition timestamp with a sentinel and stops recording future transitions around 2038. The resolver rejects unprovable coverage rather than extrapolating: for example, Kathmandu in 1900 and the initial-only Africa/Abidjan table currently fail explicitly. Truly constant known-offset tables such as Etc/UTC work throughout the envelope; unknown-only Factory is not treated as UTC. A listed key does not promise coverage for an arbitrary date. `ZoneCoverageException` means unknown calculation coverage, never free time or an occurrence that may silently be omitted.

Explicit gaps use the pre-gap offset; folds select the first UTC instant. Results retain the requested civil fields and exact zone ID alongside the UTC instant, classification, interpretation/effective offsets, effective local fields and rules version. Gap resolution does not overwrite the original requested start. Non-hour and whole-day transitions are supported by the same offset arithmetic. `resolveRecurrenceCandidate` omits proved gaps only; actual recurrence generation, invalid-date skipping and COUNT semantics remain future work. Unknown/unsupported calculations still fail.

The rules snapshot is immutable and isolated from later timezone registry changes. Loading restores existing host registry/local settings (an uninitialized local setting receives UTC). No network, device timezone or current-time-dependent rules are used by calculations. `VTIMEZONE` matching, durable zone upgrades and wider data coverage remain required before claiming the complete named-zone feature.

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

## Named-zone increment validation

With pinned Dart 3.13.5 and timezone 0.11.2:

- `flutter pub get`, then `flutter pub get --enforce-lockfile`: passed; only timezone 0.11.2 was added to the root lockfile. `http`/`path` dependencies were already present.
- `dart format packages/serverpod_calendar_core/lib` and the new resolver test file: completed.
- `dart analyze --fatal-infos`: workspace analysis passed after adding the resolver tests.
- `dart test --reporter expanded`, from the core package: **101 tests passed** (71 existing, 30 zone tests).
- `dart test --platform chrome --reporter expanded`, from the core package: the same **101 tests passed in Chrome**. This verifies the actual pure-core web runtime, including negative-epoch and transition-edge microseconds; it is separate from the Flutter example journey.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes the resolver yet; tests exercise the resolver directly.
- The installed generated data header reported IANA 2026e. `Get-FileHash .../timezone-0.11.2/lib/data/latest_all.tzf -Algorithm SHA256` matched `86a4e2c9b047275d1948a98e5c5023b39bcae3fb2b440b3027cac7a3665fedfe`, recorded in toolchain.json. The embedded Dart byte payload was independently hashed and matched the same binary artifact. Pinned package APIs/source and LICENSE were inspected through Dart MCP.
- Documentation links/anchors, ADR numbering, PowerShell check-script syntax, changed-file review and `git diff --check`: passed.

The first root-level `dart test` attempt found no root test directory; rerunning from the core package passed as recorded above. Root `tool/check.ps1` now includes core Chrome tests unless `-SkipBrowser` is supplied. No endpoint, generated source, migration or Flutter UI changed, and the full database/browser-journey/two-host suite was not rerun for this core increment. VTIMEZONE matching, all-zone/year coverage, recurrence, duration semantics and persistence upgrade behavior remain unverified.

## Calendar-day arithmetic validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: ten files checked; the implementation formatted. The corrected test fixture was also checked with the formatter.
- `dart test --reporter expanded`, from the core package: **110 tests passed**, including nine arithmetic tests. Coverage includes leap centuries, positive/negative date crossings, full-profile bounds/distances, known weekdays and all 146097 successive days in a Gregorian 400-year cycle.
- `dart test --platform chrome --reporter expanded`, from the core package: the same **110 tests passed**.
- `dart analyze --fatal-infos`: workspace analysis passed. Dart MCP `analyze_files` for the core package also reported no errors.
- Serverpod MCP `hot_reload`: completed successfully; core methods still have no endpoint consumer.
- Changed documentation links/anchors, consecutive ADR numbering, unchanged README warning/LICENSE/lockfile, changed-file scope and `git diff --check`: passed.

The first Chrome run exposed a test fixture using a bit shift with different web integer semantics. Replacing it with the exact large integer tests the intended overflow input on both runtimes. The implementation required no change. The initial `dart` wrapper invocation did not complete, and direct SDK invocation without settings-directory access failed; verification uses the pinned SDK executable with local settings/cache access.

No dependencies, generated code, endpoint, schema, migration or Flutter UI changed. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. The README warning and named-zone coverage guards remain unchanged; recurrence and elapsed/nominal duration semantics remain future work.

## Duration-value validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: twelve files checked, two formatted.
- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe analyze --fatal-infos`: workspace analysis passed.
- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe test --reporter expanded`, from the core package: **140 tests passed**, including thirty new duration tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **140 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes this value yet.

New tests exercise negative/out-of-range magnitudes for every component, maximum exact portable whole-unit integers and fractions, invalid signs, each prohibited mixed-week form, signed zero, retained non-normalized values and all-field equality/hashing. Existing named-zone coverage/rejection tests also pass. No duration application, parsing/serialization, property restrictions or client interoperability is inferred.

Documentation links/anchors, consecutive ADR numbering, changed-file review and `git diff --check`: passed for this increment. Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README/2037 warning are unchanged. The full database/browser-journey/two-host suite was not rerun for this isolated core value; practical duration/work limits and temporal application remain future work.

## Duration-application validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: thirteen files checked; implementation/test formatting completed.
- The same executable with `analyze --fatal-infos`: workspace analysis passed after correcting one brace-style diagnostic in the initial run.
- The same executable with `test --reporter expanded`, from the core package: all **167 tests passed** (27 new application/projection tests).
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **167 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully; core correctness evidence comes from the direct tests, with no endpoint consumer yet.

Coverage includes signed date/week boundaries, nonzero clock rejection for dates, maximum-component overflow before narrowing, Stockholm 23/25-hour days, negative mixed durations, intermediate gaps/folds, requested gap-start fields, Lord Howe half-hour and Apia whole-day changes, negative-epoch fractions, non-normalized clock units, later-fold elapsed endpoint identity, exact aliases, historical intermediate/final failures, zero-operation validation and supported local-year/UTC spillover boundaries.

No dependencies, generated files, migration, endpoint, Flutter UI, LICENSE or main README warning changed. The full database/browser-journey/two-host suite was not repeated for these pure-core changes. Property-specific spans, UTC-only duration application, practical work limits, recurrence, iCalendar and client interoperability remain separate work. Documentation links/anchors, ADR numbering, changed-file review and `git diff --check`: passed.

## Date-only recurrence parameter validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: fifteen files checked, two formatted; later brace/comment corrections were checked with the same formatter.
- The same executable with `analyze --fatal-infos`: workspace analysis passed after correcting two brace-style diagnostics in the initial run.
- The same executable with `test --reporter expanded`, from the core package: all **218 tests passed**, including 51 new parameter-validation tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **218 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes these rule values yet.

New tests cover scalar bounds and count/until exclusion, every week start, weekday ordinal bounds, signed selector ranges, illegal combinations, potentially empty candidate selections without clamping, canonical equivalent lists/rules, immutable snapshots and every equality/hash field. They do not execute any recurrence or establish wire compatibility.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README/2037 warning are unchanged. The full database/browser-journey/two-host suite was not repeated for this pure-core parameter addition. Start matching, timed rules, bounded generation, RDATE/EXDATE, exceptions and protocol behavior remain future work. Documentation links/anchors, ADR numbering, changed-file review and `git diff --check`: passed.

## Initial bounded date-only generator validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: seventeen files checked; new implementation/fixture formatting completed.
- The same executable with `fix --apply --code=curly_braces_in_flow_control_structures lib/src`, from the core package: corrected nine brace-style diagnostics found by the initial analysis.
- The same executable with `analyze --fatal-infos`: workspace analysis passed.
- The same executable with `test --reporter expanded`, from the core package: all **247 tests passed**, including 29 new generator tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **247 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. There is no endpoint consumer of this generator yet.

New cases cover inclusive query/UNTIL boundaries, historical COUNT, cadence defaults, all week starts and a two-week boundary fixture, invalid month-end/leap-century skipping, signed and ordinal selectors, full-period positions, duplicate collapse, selected start rejection, unsupported week-number rejection, exact/failed budgets, safe huge-interval termination and profile-edge behavior. Date-only generation beyond 2037 does not imply expanded zone support; existing named-zone rejection tests pass unchanged.

No dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE or main README warning changed. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. Full week-number/timed/set/override semantics, spans, production limits and protocol/client interoperability remain pending. Documentation links/anchors, ADR numbering, changed-file scope and `git diff --check`: passed.

## Date-only week-number validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: eighteen files checked, three formatted.
- The same executable with `analyze --fatal-infos`: workspace analysis passed.
- The same executable with `test --reporter expanded`, from the core package: all **272 tests passed**. This adds 25 week-number tests and replaces the previous unsupported-BYWEEKNO test with the RFC week-20 fixture.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **272 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes the date recurrence engine yet.

Evidence includes week 53 missing-year skipping, positive/negative adjacent week-year membership, calendar-year interval anchoring, month/position combinations, duplicate collapse, all WKST boundary cases, both date-profile edges and explicit budget failures. For each of seven week starts, first/last-week membership across a complete 146097-day Gregorian cycle is compared with an independent fourth-day construction. The RFC fixture is compared as start dates, not as a timed/zone interchange claim. The existing 2037 zone rejection tests remain unchanged and pass.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README warning are unchanged. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. Timed/set/override semantics, production budgets, spans and protocol/client interoperability remain pending. Documentation links/anchors, ADR numbering, changed-file scope and `git diff --check`: passed.

## Bounded DATE-only recurrence sets

`DateRecurrenceSet` combines an optional rule with explicit additions and exclusions. For a daily rule starting 2026-01-01 with COUNT=3, adding January 5 and excluding January 2 yields January 1, 3 and 5. Exclusions take precedence over both sources; duplicates collapse. Excluding DTSTART retains its stored value. Earlier inclusions are preserved as explicitly selected, without rebasing DTSTART or changing COUNT. UNTIL constrains the rule, not additions; exclusions never replenish COUNT.

Construction requires `maxExplicitDates`, bounding the combined raw inclusion/exclusion lengths before copying or deduplication (zero permits neither). Expansion takes an inclusive `from`/`through` date range and separate `maxCandidateDays`, `maxRuleOccurrences` and `maxResults` limits. Candidate work includes pre-query rule history. Raw in-query rule output is capped before exclusions; final output is capped after exclusions. Limit failures name the exceeded budget and never return partial success. The sorted merge avoids allocating the complete union. Output and stored lists are immutable; constructor budgets are not semantic equality fields. Hosts still need trusted practical production limits.

This is a pure DATE-only start-date set under [ADR 0033](adr/0033-date-recurrence-sets.md), not an event-span query, timed/PERIOD interchange model, override engine or service API. Explicit WKST remains honored; native ISO presentation and named-zone guards are unchanged.

## Date-only recurrence set validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: twenty files checked, two formatted.
- The same executable with `analyze --fatal-infos`: workspace analysis passed.
- The same executable with `test --reporter expanded`, from the core package: all **298 tests passed**, including 26 new set tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **298 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes this recurrence set yet.

New tests cover canonical immutable inputs/results, raw duplicate input caps, earlier additions, excluded DTSTART identity, union/exclusion precedence, COUNT/UNTIL independence, query boundaries/history, every limit failure, excluded mismatched starts, explicit Sunday BYWEEKNO and years 0001/9999. Existing named-zone coverage rejection tests remain unchanged and pass.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README/2037 warning are unchanged. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. Timed/PERIOD sets, overrides, spans, production budgets and protocol/client interoperability remain pending. Documentation links/anchors (193), consecutive ADR numbering, changed-file scope and `git diff --check`: passed.

## Native ISO week field validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: twenty-two files checked, no formatting changes needed.
- The same executable with `test --reporter expanded`, from the core package: all **329 tests passed**, including 31 new ISO projection tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **329 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No Flutter calendar GUI consumes these fields yet.

Python 3.11.9 `datetime.date.isocalendar()` independently supplied 24 exact fixtures and rolling fingerprints for 146097 dates in each of years 0001–0400 and 2000–2399, plus 39996 January/December boundary dates across years 0001–9999. To reproduce a fingerprint, begin with zero and update `(previous * 31 + iso_year * 1000 + iso_week * 10 + iso_weekday) % 2147483647` for each chronological date. Expected cycle values are 222650477 and 1784885802; the year-boundary sequence (January 1, January 4, December 28, December 31 for each ascending year) is 843918866. These portable arithmetic fingerprints supplement exact fixtures, not a claim of exhaustive proof.

A separate test constructs ISO-year Mondays from January 4 using Dart UTC Gregorian arithmetic as an independent test oracle, checks every date through the next boundary, and confirms 71 long week-years in 400 years. Production code never converts dates to timestamps. Tests also cover equality/hash, padded diagnostics and a Sunday-WKST recurrence whose native ISO label remains 2020-W53-7.

No dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE or main README warning changed. The full database/browser-journey/two-host suite was not repeated for this pure-core projection. Inverse conversion, week-date parsing, Flutter presentation and protocol/client interoperability remain pending. `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe analyze --fatal-infos`: workspace analysis passed. Documentation links/anchors (206), consecutive ADR numbering, changed-file scope and `git diff --check`: passed.

## DATE-only event spans

```dart
final event = DateEventSpan(
  start: CalendarDate(year: 2026, month: 1, day: 1),
  duration: CalendarDuration(weeks: 1),
);
// event.end == null; event.duration retains one week.
// event.endExclusive == CalendarDate(year: 2026, month: 1, day: 8)
// event.dayCount == 7; January 8 is not included.
```

`DateEventSpan` preserves an explicit end, a unit-preserving duration, or their joint omission. Its derived bounds are inclusive/exclusive. Conflicting fields, non-increasing ends, nonpositive durations and nonzero clock/fraction units are rejected. Omitting both end and duration means one calendar day. Equal occupied dates do not erase structural differences between forms. `contains` and `overlaps` compare dates only; they neither resolve instants nor decide authorization or busy status.

Every effective exclusive end must remain within the existing date profile. A default event on 9999-12-31 fails because its end would require year 10000; an event ending at 9999-12-31 excludes that date. No clipping, implicit sentinel or wider zone coverage is introduced. Scoped uniform-length DATE-only series overlap queries now exist under [ADR 0036](adr/0036-date-event-series-overlap.md). Timed/task spans, range/task exceptions and adapters remain pending; native DATE-only exceptions follow under [ADR 0037](adr/0037-date-only-single-occurrence-exceptions.md). See [ADR 0035](adr/0035-date-only-event-spans.md).

## Date-only event span validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: twenty-four files checked, one formatted initially; repeated after deterministic test-name cleanup with no further formatting changes.
- The same executable with `analyze --fatal-infos`: workspace analysis passed, including after the cleanup.
- The same executable with `test --reporter expanded`, from the core package: all **361 tests passed**, including 32 new event-span tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **361 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes these spans yet.

New evidence covers defaults, preserved end/day/week representations, conflicting/nonpositive/clock-valued input rejection, leap centuries, year crossings, membership, adjacency and symmetric overlap. Every pair of short synthetic spans is compared with independently enumerated occupied-date sets. Profile endpoints and huge durations fail explicitly; date-only spans after 2037 do not bypass named-zone rejection.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README warning are unchanged. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. Documentation links/anchors (207), consecutive ADR numbering, changed-file scope and `git diff --check`: passed.

## Bounded DATE-only event-series overlap

`DateEventSeries` pairs a `DateRecurrenceSet` with a `DateEventSpan` sharing its DTSTART. `expandOverlapping` accepts `from` inclusive and `until` exclusive, unlike the underlying set's closed start-date range. A three-day event queried for January 5–6 includes starts on January 3, 4 and 5; January 2 ends at the lower boundary and January 6 starts at the upper boundary, so both are excluded. Return complete spans, retaining dates outside the query and separate overlapping occurrences.

The query searches back by template length minus one, bounded by year 0001, and applies the original explicit-end, duration or default form at each selected start. COUNT/UNTIL remain start constraints; earlier inclusions and exclusion precedence are unchanged. `maxRuleOccurrences` counts raw rule starts in this widened range before exclusions; `maxResults` includes all selected overlapping starts, including earlier ones. `maxCandidateDays` still bounds rule history and period work. Required budgets must be trusted and practical at future host boundaries.

Endpoint overflow in any selected span fails the entire query, with no clipping, skipping or partial result. The query does not validate unrelated future occurrences. This base API provides no UTC conversion, moved/variable-length override query, globally scoped occurrence key or complete availability result. Native DATE-only exception queries are separate under [ADR 0037](adr/0037-date-only-single-occurrence-exceptions.md). See [ADR 0036](adr/0036-date-event-series-overlap.md).

## Date event series overlap validation

With pinned Dart 3.13.5:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: twenty-six files checked, one formatted.
- The same executable with `analyze --fatal-infos`: workspace analysis passed.
- The same executable with `test --reporter expanded`, from the core package: all **387 tests passed**, including 26 new series tests.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **387 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully. No endpoint consumes these queries yet.

Tests cover lower/upper touching boundaries, earlier starts, unclipped spans and each input form, leap-boundary shifts, COUNT/UNTIL, earlier additions, duplicate/excluded dates, immutable sorted results, every widened-range/work budget, mismatched starts/rules, safe full-profile lookback, selected endpoint overflow and explicit Sunday WKST independent of ISO labels. A grid of short query windows and lengths is checked against independently enumerated occupied-date sets.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README warning are unchanged. The full database/browser-journey/two-host suite was not repeated for this pure-core increment. Documentation links/anchors (219), consecutive ADR numbering, changed-file scope and `git diff --check`: passed.

## DATE-only single-occurrence exception batch

`DateEventException.cancel(originalStart: ...)` removes one member. `DateEventException.replace(originalStart: ..., replacement: DateEventSpan(...))` supplies complete new bounds while retaining original identity. Bind exceptions to a `DateEventSeries` using `DateEventExceptionSet`. Query results are `DateEventOccurrence` values with separate `originalStart` and effective `span`, sorted by actual start then original date. Occurrences moved onto the same actual date remain distinct; spans are not merged or clipped.

Construction snapshots and sorts exceptions, rejects duplicate targets and checks every target against the effective DTSTART/RRULE/RDATE minus EXDATE set. Excluded/nonexistent targets fail rather than reviving a date; earlier inclusions remain valid. This conservative native policy does not establish imported master/exception reconciliation. Replacement dates may precede DTSTART or follow UNTIL without changing COUNT.

`maxExceptions` bounds raw input before copying (zero allows none). One shared expansion validates the full target range under positive `maxValidationCandidateDays`, `maxValidationRuleOccurrences` and `maxValidationResults`; intervening dates and rule history consume budgets. On construction failure no validated set is returned. Query budgets are separate: `maxCandidateDays` and `maxRuleOccurrences` retain existing meanings, `maxBaseOccurrences` bounds selected base starts before exception suppression, and `maxResults` bounds final output. Hosts must choose trusted practical caps.

The query suppresses base targets before constructing their endpoints and scans bounded replacement spans independently of template lookback. This includes moved-in and lengthened replacements, excludes moved-out/shortened/cancelled spans, and lets a valid replacement/cancellation remove an otherwise overflowing base span. An unsuppressed overflow or limit failure returns no partial successful list. Named-zone guards are unchanged. See [ADR 0037](adr/0037-date-only-single-occurrence-exceptions.md).

For an existing DATE-only `series`, a cancellation and a moved replacement can be supplied explicitly:

```dart
final changed = DateEventExceptionSet(
  series: series,
  exceptions: [
    DateEventException.cancel(
      originalStart: CalendarDate(year: 2026, month: 1, day: 2),
    ),
    DateEventException.replace(
      originalStart: CalendarDate(year: 2026, month: 1, day: 3),
      replacement: DateEventSpan(
        start: CalendarDate(year: 2026, month: 1, day: 20),
      ),
    ),
  ],
  maxExceptions: 10,
  maxValidationCandidateDays: 1000,
  maxValidationRuleOccurrences: 100,
  maxValidationResults: 100,
);
final occurrences = changed.expandOverlapping(
  from: CalendarDate(year: 2026, month: 1, day: 20),
  until: CalendarDate(year: 2026, month: 1, day: 21),
  maxCandidateDays: 1000,
  maxRuleOccurrences: 100,
  maxBaseOccurrences: 100,
  maxResults: 100,
);
// The moved result retains originalStart == 2026-01-03.
```

The sample assumes January 2 and 3 belong to the supplied series. Its budgets illustrate separate operations, not production defaults. Other natural/replacement occurrences may also appear in the query.

No global series identifier, sparse metadata patch, range/task exception, UTC occupancy, authorization, persistence, booking/alarm recalculation or wire/scheduling reconciliation is implemented by this batch. These remain separate work; the draft API/policy is reviewable independently of the authorized batch scope.

## Date-only exception batch validation

With pinned Dart 3.13.5, feature iterations used focused VM checks:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe test test/date_event_exception_test.dart --reporter expanded`, from the core package: **5 tests passed**. The initial invocation from the repository root failed to locate that package-relative test path; rerunning from the correct directory passed without a code change.
- The same executable with `test test/date_event_exception_test.dart test/date_event_exception_set_test.dart test/date_event_series_test.dart --reporter expanded`, from the core package: **61 tests passed** (35 new exception tests plus 26 affected series regressions).
- Focused `format` over core `lib` plus the two new test files: eighteen files checked, four formatted.

At batch completion:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format --output=none --set-exit-if-changed packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: thirty-two files checked, no formatting changes.
- The same executable with `test --reporter expanded`, from the core package: all **422 tests passed**.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **422 tests passed in Chrome**.
- The same executable with `analyze --fatal-infos`: the initial batch-end run found one `prefer_initializing_formals` info diagnostic. The replacement constructor was changed to a typed non-null initializing formal; repeated workspace analysis passed with no issues.
- After that equivalent constructor cleanup, the focused 61 VM tests passed again; `test test/date_event_exception_test.dart test/date_event_exception_set_test.dart --platform chrome --reporter expanded` passed all **35 affected Chrome tests**. The unrelated complete suites were not repeated. Single-file formatting passed unchanged.
- Serverpod MCP `hot_reload`: completed successfully, including after the cleanup; no endpoint consumes this exception set yet.

New cases cover original/effective identity, cancellation, all replacement forms, movement in both directions, length changes, touching boundaries, actual-start ties, immutable canonical snapshots/equality, duplicate/orphan/EXDATE target rejection, earlier inclusions, COUNT/UNTIL, shared target-range validation, each query budget, profile endpoints and WKST/ISO independence. A finite occupied-date oracle independently checks output membership, original identity, length and ordering across a grid of changed spans and query windows.

No dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE or main README warning changed. The full database/browser-journey/two-host suite is deferred for this pure-core batch, as no such surface changed. Full repository checks remain required before PR readiness. Documentation links/anchors (246), consecutive ADR numbering, requirement/RFC/model consistency, changed-file scope and `git diff --check`: passed. No intermediate code commit was made; the completed batch is checked in together.

## DATE-only THISANDFUTURE timing batch

`DateEventRangeChange` pairs an original DATE anchor with a complete replacement span. `dayShift` measures replacement start minus original date. `DateEventRangeSet` layers sorted range changes over a validated `DateEventExceptionSet`. From an anchor through the date before the next original anchor, apply its shift and length/form. Later shifts are relative to their own originals, not accumulated; original rule cadence, COUNT/UNTIL and EXDATE membership remain unchanged. Separate single replacements/cancellations retain their own spans regardless of actual movement across an anchor.

Construction checks raw `maxRangeChanges` before copying, rejects duplicate/excluded/orphan anchors and single/range collisions at the same original date, and uses one shared target validation expansion. Validation budgets retain the names and semantics from the single-exception batch. These collision/multiple-anchor policies are scoped native proposals; imported component reconciliation remains pending.

For example, daily original starts January 1–7 with a range at January 3 moving it to January 8 and another at January 6 moving it to January 4 produce original/actual pairs 1/1, 2/2, 3/8, 4/9, 5/10, 6/4, 7/5. Results are sorted by actual start then original date; each occurrence keeps its original identity.

For overlap, invert the half-open actual date window through each segment's shift and length. Expand one envelope of candidate original dates, sharing `maxCandidateDays`, `maxRuleOccurrences` and `maxBaseOccurrences`. Starts in gaps between inverse ranges consume capacity before segment overlap filtering or single suppression. `maxResults` bounds final output. This trades extra bounded work for shared accounting; practical budget failures never become partial success or free coverage. Independent singles are scanned separately, and spans are returned complete without clipping/merging.

For an existing validated single-exception `base`, a timing range is explicit:

```dart
final timing = DateEventRangeSet(
  base: base,
  changes: [
    DateEventRangeChange(
      originalStart: CalendarDate(year: 2026, month: 1, day: 3),
      replacement: DateEventSpan(
        start: CalendarDate(year: 2026, month: 1, day: 8),
        duration: CalendarDuration(days: 2),
      ),
    ),
  ],
  maxRangeChanges: 10,
  maxValidationCandidateDays: 1000,
  maxValidationRuleOccurrences: 100,
  maxValidationResults: 100,
);
final occurrences = timing.expandOverlapping(
  from: CalendarDate(year: 2026, month: 1, day: 8),
  until: CalendarDate(year: 2026, month: 1, day: 9),
  maxCandidateDays: 1000,
  maxRuleOccurrences: 100,
  maxBaseOccurrences: 100,
  maxResults: 100,
);
```

The sample assumes January 3 is an effective member with no separate single exception at that anchor. Budgets illustrate operation separation, not production defaults.

Only materialize selected overlapping endpoints; selected overflow fails the whole query. Date and effective-end years remain 0001–9999, named zones remain bounded to 1900–2037 with potentially narrower coverage, and the main README warning is unchanged. This is native timing only: range cancellation, arbitrary pattern edits, timed/task spans, authorization, persistence, booking/alarm recalculation and wire/scheduling support remain pending. See [ADR 0038](adr/0038-date-only-this-and-future-timing.md).

## Date-only range timing batch validation

With pinned Dart 3.13.5, feature iterations used focused VM tests:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe test test/date_event_range_change_test.dart --reporter expanded`, from the core package: **4 value tests passed**.
- The same executable with `test test/date_event_range_change_test.dart test/date_event_range_set_test.dart test/date_event_exception_set_test.dart --reporter expanded`, from the core package: **64 tests passed** (34 new range tests and 30 affected single-exception regressions).
- Focused `format` over the two range source/test pairs: four files checked, three formatted.

At batch completion:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format --output=none --set-exit-if-changed packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: thirty-six files checked, no formatting changes.
- The same executable with `analyze --fatal-infos`: workspace analysis passed without diagnostics.
- The same executable with `test --reporter expanded`, from the core package: all **456 tests passed**.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **456 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully; no endpoint consumes range timing yet.

New cases cover signed shifts and length/form preservation; original-order multiple anchors and separate overrides moved across them; original COUNT/UNTIL, RDATE/EXDATE and monthly invalid-date skipping; duplicate/orphan/collision validation; each shared membership/query budget and intervening-envelope capacity; immutable equality; first/last date boundaries, selected overflow and unrelated future overflow. An independent finite occupied-date oracle compares identity, actual spans and output order across mixed ranges/singles and many query windows.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README warning are unchanged. Database/browser-journey/two-host checks are deferred because no such surface changed. Full repository checks remain required before PR readiness. Documentation links/anchors (244), consecutive ADR numbering, requirement/RFC/model consistency, changed-file scope and `git diff --check`: passed. No intermediate commit was made; the completed group is checked in together.

## Exact UTC duration and event foundations

`CalendarDuration.addToUtc` requires an explicit UTC instant and applies signed weeks/days/clock fields with arbitrary-precision intermediate arithmetic. UTC days are 24 hours; the existing named-zone calendar-first/DST operation remains separate. Preserve microseconds by combining exact epoch milliseconds and the sub-millisecond remainder before arithmetic, rather than using the rounded JavaScript epoch-microsecond getter. Reconstruct output only after checking Dart's instant bounds, including before 1970 and at the endpoints.

`UtcEventSpan` preserves an explicit end, a unit-preserving duration or joint omission. Explicit end must be UTC and strictly later; duration must be positive/nonzero; both cannot be supplied. Omission means a point at start, unlike a DATE event's one-day default. `occursIn(UtcWindow)` uses interval overlap or point membership with lower-inclusive/upper-exclusive queries. `occupiedWindow` is null for points; a marker found by a query does not occupy a positive interval or automatically block availability.

```dart
final span = UtcEventSpan(
  start: DateTime.utc(2026, 1, 1, 9),
  duration: CalendarDuration(hours: 1, microsecond: 1),
);
// span.elapsedMicroseconds == BigInt.from(3600000001)
final point = UtcEventSpan(start: DateTime.utc(2026, 1, 1, 9));
// point.isPoint == true; point.occupiedWindow == null
```

These native explicit UTC operations retain the existing Dart/UtcWindow instant bounds; they do not select a broader interchange-year profile or change date/civil years 0001–9999. A point at the last supported instant is representable, but a nonempty half-open supported query cannot include that terminal instant. Future adapters must validate lexical years, fractions and leap seconds before DateTime construction. No parser/export or floating-time acceptance is introduced.

`UtcWindow.elapsedMicroseconds` and `UtcEventSpan.elapsedMicroseconds` return exact BigInt lengths. The existing `UtcWindow.duration` getter now throws beyond the exact portable integer magnitude 2^53−1 microseconds; geometric window bounds remain unchanged. This corrects distant/long difference rounding or native overflow without changing ordinary short-window callers. Use the BigInt getter for longer intervals. Future generated transport models still need their own representation contract.

Named-zone support remains 1900–2037 with potentially narrower coverage; explicit UTC arithmetic after 2037 does not bypass resolver guards. Timed recurrence, zoned/task spans, native UTC exceptions, authorization, persistence, busy-status policy, alarms and interchange remain pending. See [ADR 0039](adr/0039-exact-utc-duration-and-event-spans.md).

## UTC event foundation batch validation

With pinned Dart 3.13.5, feature iterations used focused VM checks:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe test test/utc_duration_application_test.dart --reporter expanded`, from the core package: initial **17 tests passed**.
- The same executable with `test test/utc_duration_application_test.dart test/utc_event_span_test.dart test/utc_window_test.dart --reporter expanded`: **57 tests passed** (43 new UTC tests plus 14 existing window tests).
- Review then identified the related long-window Duration boundary. After its correction, `test test/utc_duration_application_test.dart test/utc_event_span_test.dart test/utc_window_test.dart test/utc_window_precision_test.dart --reporter expanded`: **64 tests passed** (50 new tests plus 14 existing regressions).
- Focused formatting checked five initial source/test files (three formatted), then two window source/test files (both formatted).

The initial 499-test VM/Chrome runs also passed. The related window correction changed executable code, so final broader validation includes its seven new precision cases:

- `K:/sources/flutter/bin/cache/dart-sdk/bin/dart.exe format --output=none --set-exit-if-changed packages/serverpod_calendar_core/lib packages/serverpod_calendar_core/test`: final forty-one files checked, no formatting changes.
- The same executable with `analyze --fatal-infos`: final workspace analysis passed without diagnostics.
- The same executable with `test --reporter expanded`, from the core package: all **506 tests passed**.
- The same executable with `test --platform chrome --reporter expanded`, from the core package: all **506 tests passed in Chrome**.
- Serverpod MCP `hot_reload`: completed successfully, including after the window correction. No endpoint consumes UTC event spans yet.

Tests cover signed/mixed/zero and enormous durations; Gregorian boundaries; negative epoch and distant odd fractions; valid full-range deltas wider than signed 64-bit; exact endpoints/overflow; all span forms; invalid local/conflicting/nonpositive inputs; point versus interval query boundaries; independent finite tick-set geometry; exact full-range BigInt lengths and guarded portable Duration conversion. Named-zone rejection after 2037 remains unchanged and passes.

Dependencies, generated files, migrations, endpoints, Flutter UI, LICENSE and the main README warning are unchanged. Database/browser-journey/two-host checks are deferred because no such surface changed; full repository checks remain required before PR readiness. Documentation links/anchors (248), consecutive ADR numbering, requirement/RFC/model consistency, changed-file scope and `git diff --check`: passed. No intermediate commit was made; the completed group is checked in together.
