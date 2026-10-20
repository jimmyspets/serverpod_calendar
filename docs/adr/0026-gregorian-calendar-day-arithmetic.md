# ADR 0026: Gregorian calendar-day arithmetic

Status: **Proposed implementation of the selected Gregorian date profile; broader acceptance remains under review**. Date: 2026-10-20.

## Context

Recurrence needs date navigation without converting date-only values into timestamps. The selected profile already uses proleptic Gregorian years 0001–9999 under [ADR 0023](0023-gregorian-date-only-values.md). This increment supplies date arithmetic, not recurrence generation or event duration semantics.

## Implementation proposal

Expose `CalendarDate.addDays(int)`, signed `daysUntil(CalendarDate)` and `weekday` (Monday 1 through Sunday 7). Positive additions move forward; negative additions move backward. Reject additions outside the selected year range with `RangeError`, checking bounds before addition. Use bounded Gregorian integer day counts internally; retain only date fields in returned values. No timestamps, device timezone or elapsed `Duration` enter these operations.

A calendar-day count does not specify elapsed hours across DST, an all-day event end, an RFC duration, a week number or recurrence week start. Month/year addition and month-end clamping are outside this increment; recurrence must eventually skip invalid generated dates according to its own rules.

The named-zone envelope remains 1900–2037 with narrower per-zone coverage under [ADR 0025](0025-bounded-named-zone-resolution.md). Arithmetic outside that envelope produces valid dates only; it cannot authorize timezone resolution. The main README warning and resolver guards remain unchanged.

## Alternatives

Timestamp arithmetic would attach unwanted instant semantics and could confuse calendar days with elapsed 24-hour periods. Iterating one day at a time scales with the requested offset. Bounded integer day arithmetic and a binary search for the result year support the complete date profile without those dependencies.

## Consequences and acceptance conditions

Validate leap/non-leap centuries, positive/negative month and year crossings, full-profile distances and overflow, known weekdays, and every successive day in a Gregorian 400-year cycle. Exercise both Dart VM and Chrome. Document commands/results in [temporal core validation](../temporal-core.md). No schema, generated client, recurrence engine, timezone coverage or protocol support is established by these tests. This record does not mark other proposed temporal contracts accepted.
