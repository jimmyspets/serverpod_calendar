# ADR 0028: Date-only and calendar-first zoned duration application

Status: **Calendar-units-first zoned policy explicitly confirmed; API implementation proposed; broader span/adapter contracts remain under review**. Date: 2026-10-20.

## Context and selected policy

[ADR 0027](0027-calendar-duration-values.md) implemented unit-preserving native durations. The maintainer now selected moving weeks/days in local calendar fields, resolving the intermediate time with the existing RFC explicit gap/fold rules, then applying clock units as elapsed time. One calendar day can therefore differ from 24 hours across DST. Rejecting all day/week arithmetic across DST was offered and not selected.

RFC 5545 [section 3.3.6](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.6) distinguishes nominal and accurate units and requires larger units first. The existing explicit-time policy follows [section 3.3.5](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.5). Applying those resolution rules to the calendar intermediate is the selected product policy, not a claim that the RFC specifies this API or every ambiguous input case.

## Implementation contract

`CalendarDuration.addToDate(CalendarDate)` accepts signed day/week magnitudes, including zero, and rejects any nonzero clock component with `ArgumentError`. Apply Gregorian calendar days without timestamps. Compute available days in the requested direction and validate days/weeks before multiplying weeks by seven; out-of-range results throw `RangeError`. The date profile remains 0001–9999. This generic arithmetic does not authorize negative/zero event durations or choose an exclusive span end.

`CalendarDuration.addToZoned(CivilDateTime, zoneId, resolver)` returns a UTC instant. Resolve the explicit start even for zero durations, so unknown names, unsupported years and coverage failures cannot be bypassed. For nonzero weeks/days, move the date while retaining the **requested** hour/minute/second/fraction fields; resolve this intermediate explicitly, choosing the first fold instant or pre-gap offset. If the supplied start itself lies in a gap, calendar movement uses its requested fields rather than replacing them with its normalized effective fields. Clock-only/zero application starts from the resolved start instant. These are explicit local inputs, not recurrence-generated candidates.

Aggregate hour/minute/second/fraction magnitudes with `BigInt`, apply sign to the elapsed total, check broad UTC bounds before narrowing, then validate the actual final local year and coverage by inverse projection. This preserves native microseconds without overflow/rounding even when a valid structural component is too large to apply. Sign applies to calendar and clock portions in the same order; subtraction is not promised to invert addition across gap/fold normalization.

`NamedZoneResolver.localAt(UTC instant, zoneId)` projects directly through the pinned rules snapshot. It rejects non-UTC input, unknown exact names, unknown offsets, unsupported local years and unproved coverage. Unlike forward resolution, projection of a known instant does not need to prove every possible offset candidate. It does not re-resolve the resulting local tuple: an elapsed endpoint in the later fold retains its original instant. Both fold instants may share local fields, so callers must retain the UTC instant and zone rather than reconstruct identity from those fields alone.

## Coverage safeguards

The final local year remains **1900–2037** and per-zone coverage may be narrower. A small UTC spillover into 1899 or 2038 is allowed only when it projects into a supported local year. Loose preliminary UTC bounds are not expanded local-year support. Start, calendar intermediate and final projection each fail explicitly when unsupported. The main README warning and existing forward guards are unchanged. No recurrence gap skipping, partial result or false-free fallback is introduced.

## Alternatives and consequences

Flattening a nominal day/week into elapsed hours would lose the selected semantics. Re-resolving an elapsed endpoint's local fields could move a later-fold instant to the first occurrence. Implicitly using normalized gap-start fields would discard requested-field meaning. Separate explicit application and inverse projection retain these distinctions, but property/component rules, native UTC-only application, event/task defaults, practical query/work budgets, imported VTIMEZONE matching and interchange validation still require their own contracts. No all-day event, alarm runtime or scheduling service is established here.

## Validation

Test signed date-only boundaries, clock rejection, safe maximum-component failure, Stockholm spring/fall differences, intermediate gaps/folds, negative mixed durations, gap-start requested fields, Lord Howe half-hour changes, Apia skipped dates/weeks, exact fractions across the UTC epoch, later-fold endpoints, aliases, historical failures at intermediate/final times and local-year envelope spillover. Run VM/Chrome tests, workspace analysis and MCP reload; record results in [temporal core validation](../temporal-core.md). Broader ADR acceptance and protocol/client evidence remain separate.
