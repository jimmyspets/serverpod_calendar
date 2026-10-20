# ADR 0039: Exact UTC durations, event spans and query lengths

Status: **Native implementation proposal; timed recurrence, adapters and service contracts remain under review**. Date: 2026-10-20.

Current-profile note: [ADR 0041](0041-whole-second-1970-2100-profile.md) supersedes this record's earlier date-range/precision/zone-envelope choices. Ordinary calendar dates are now 1970 inclusive to 2100 exclusive, with whole seconds and a special exclusive endpoint. The original increment and validation history below is preserved.

## Context and sources

After the DATE-only recurrence batches, timed recurrence needs UTC duration and span foundations. This batch adds exact signed UTC duration application, preserved event bounds/defaults, point-versus-interval queries and a related correction for long UTC-window elapsed lengths. Focused iteration precedes broader batch checks and one completed-group commit.

RFC 5545 [section 3.6.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1) supplies event end/duration cardinality and omitted-end DATE-TIME defaults; [section 3.8.2.5](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.2.5) requires positive event duration. Native computation is not wire acceptance. [Dart's epoch-microsecond documentation](https://api.dart.dev/dart-core/DateTime/microsecondsSinceEpoch.html) warns of JavaScript rounding away from the epoch. The pinned Dart 3.13.5 SDK stores milliseconds and the microsecond remainder separately on JavaScript; inspected `lib/_internal/js_shared/lib/date_time_patch.dart` and `lib/_internal/vm_shared/lib/date_patch.dart` establish floored millisecond/remainder behavior on both targets.

## Exact UTC duration application

Add `CalendarDuration.addToUtc(DateTime)`. Require explicit UTC even for signed zero; reject local input instead of converting it. In UTC, weeks/days contribute seven/one 24-hour days; aggregate them and clock/fraction fields with `BigInt`. Retain the original unit-preserving value. This does not change the selected calendar-first named-zone operation or introduce leap-second handling.

Reconstruct exact epoch microseconds internally from `millisecondsSinceEpoch * 1000 + microsecond`, performing multiplication in `BigInt`. Never aggregate through the potentially rounded epoch-microsecond getter. Check the resulting instant against Dart's existing bounds before narrowing to exact epoch milliseconds. Use a nonnegative remainder and floored quotient, including before 1970, then add only the sub-millisecond remainder. Large signed components and valid deltas wider than signed 64-bit integers must not wrap before the final bound check.

These explicit UTC operations retain the existing `UtcWindow`/Dart instant range, including its endpoints at +/-100000000 days from 1970. This is not a new interchange-year profile or an extension of CalendarDate/civil years 0001–9999. Arbitrary UTC instants outside a future adapter's supported profile require explicit adapter rejection. Named-zone years remain 1900–2037 with potentially narrower coverage; the main README warning is unchanged.

## UTC event spans and points

`UtcEventSpan(start, end?, duration?)` retains original explicit-end, duration or jointly omitted form. Require UTC bounds, reject simultaneous fields, require an explicit end strictly after start and an explicit duration positive/nonzero. Derive `endExclusive` by exact duration application or the supplied end; joint omission yields a point at start. Unlike a DATE event's one-day default, this UTC point has no positive occupied interval. A supplied equal end or zero duration is rejected rather than treated as the omitted default.

Expose `isPoint`, exact `elapsedMicroseconds: BigInt`, `occupiedWindow: UtcWindow?` and `occursIn(UtcWindow)`. Positive spans use half-open overlap. Point markers are included at the query's lower bound and excluded at its upper bound, while `occupiedWindow` remains null. Geometry does not decide transparency/status, authorization or whether a booking blocks time. Structural equality/hash retain form and duration units even when effective bounds match.

The last representable Dart instant can be a point, but no supported nonempty half-open window can include it because its exclusive end would have to be later. Do not fabricate a sentinel or make the upper bound inclusive. Endpoint overflow for a positive span fails explicitly. A DateTime value cannot reveal whether its caller previously normalized invalid lexical fields; future adapters must validate years, fractions and leap seconds before constructing values.

## Related window precision correction

Add exact `UtcWindow.elapsedMicroseconds: BigInt`. Preserve the existing `duration: Duration` API for elapsed lengths up to 2^53−1 microseconds; beyond that portable exact integer magnitude, throw `RangeError` and direct callers to the BigInt getter. This is an intentional correction: very long differences could previously round on JavaScript or overflow a native Duration. Do not narrow silently, and do not restrict the geometric window bounds. Short differences at distant epochs remain valid and exact; the check concerns relative length, not absolute epoch position.

## Alternatives and consequences

Using `DateTime.microsecondsSinceEpoch` as a general int loses distant fractions on JavaScript; narrowing a large duration before adding its negative origin can overflow even when the final instant is valid. Timestamp-field reconstruction and arbitrary-precision intermediate arithmetic avoid both. Replacing the old window getter's return type would break ordinary callers, so retain it with an explicit limit and add a separately typed exact alternative. No global zone state, date-only conversion or host timezone is involved.

Timed/zoned recurrence and spans, UTC recurrence exceptions, tasks, free/busy policy, persistence/authorization, generated clients, alarm execution, parser/export and scheduling remain pending. Native microseconds do not authorize fractional iCalendar syntax; future export must still reject nonzero fractions. This batch adds no schema, transport or full RFC/client compatibility claim.

## Validation and acceptance

Test signed/mixed/zero UTC durations, leap/year boundaries, negative-epoch fractions, exact distant fractions, maximum components and full Dart instant endpoints. Exercise a valid full-range movement whose intermediate delta exceeds signed 64-bit capacity. Span cases cover default points, preserved forms, strict input constraints, half-open geometry, independent tick-set queries and exact full-range lengths. Window cases cover exact portable-limit acceptance, explicit excessive-length rejection and distant short differences. Run focused VM tests during development, then formatting, analysis and complete core VM/Chrome suites for the completed batch. Record commands/results in [temporal core validation](../temporal-core.md#utc-event-foundation-batch-validation) before one group commit. Wider runtime/schema approval remains separate.
