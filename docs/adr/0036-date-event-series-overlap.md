# ADR 0036: Bounded DATE-only event-series overlap queries

Status: **Scoped implementation proposal; full recurrence, service and schema contracts remain under review**. Date: 2026-10-20.

## Context and sources

[ADR 0033](0033-date-recurrence-sets.md) returns unique recurrence start dates. [ADR 0035](0035-date-only-event-spans.md) validates one all-day event span. A query over starts alone misses an event beginning before the requested range while still occupying dates inside it.

RFC 5545 [section 3.8.5.3](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.3) distinguishes recurrence length derived from an explicit end from nominal DURATION and allows per-instance changes in other representations. This increment handles only DATE starts with a uniform calendar-day length and preserves end/duration/default form. It does not calculate elapsed timed durations or support PERIOD inclusions/overrides.

## Implementation proposal

Expose immutable `DateEventSeries(recurrence: DateRecurrenceSet, span: DateEventSpan)`. Reject differing recurrence DTSTART and template start. Keep the existing immutable values and structural equality/hash; no persisted series identifier or transport model is introduced.

`expandOverlapping(from, until, maxCandidateDays, maxRuleOccurrences, maxResults)` accepts a nonempty half-open date query `[from, until)`. Return immutable, start-sorted complete `DateEventSpan` values, retaining separate occurrences even when their spans overlap. Do not merge or clip them. Each returned start is its original recurrence start in this no-override subset; it is not a globally scoped occurrence key.

For a positive fixed length L, overlap requires a start at or after `from - (L - 1)` and before `until`. Bound the earlier search by the first supported date and call the existing set engine over the closed start range ending at `until - 1`. This bounds arithmetic without skipping any representable earlier start. A start exactly L days before `from` ends at the lower boundary and is excluded; a start exactly at `until` is also excluded.

Apply the template independently at every selected start: shift an explicit end by the same calendar-day distance, retain the same original duration units/object, or retain the omitted one-day default. COUNT/UNTIL continue to constrain rule starts, not span ends. Earlier inclusions remain additions and exclusions remove the entire corresponding span without replenishing COUNT. WKST and ISO presentation remain independent and unchanged.

## Limits and failures

All three expansion budgets remain required, positive portable integers. `maxRuleOccurrences` covers raw rule starts in the widened lookback range before exclusions; `maxResults` covers selected overlapping starts after exclusions, including those before `from`. Candidate work still includes earlier recurrence history and full-period selection under the existing generator. Constructor explicit-input caps continue to apply independently. Hosts must choose trusted practical limits; there is no endpoint accepting untrusted operational budgets here.

Budget failures propagate without partial successful output. Any selected occurrence whose effective exclusive end leaves date years 0001–9999 fails the entire query with `RangeError`, even if its start/query bounds are supported. Never shorten it, drop it or fabricate free coverage. Excluded occurrences are not materialized. Starts at the query's exclusive upper bound are outside the query and are not materialized either. The API does not validate unrelated future occurrences outside the bounded query.

## Alternatives and consequences

Querying starts only would miss long events. Always expanding from the first supported date would waste query-output capacity while rule history already has its own work budget. A derived length-based lookback includes precisely the possible overlapping start range for this fixed-length DATE subset. This optimization is not valid for arbitrary moved overrides or instance-specific lengths; those require a separate algorithm and tests.

No timezone is attached to these date spans. Named-zone coverage, the 2037 README warning, task rules, authorization, busy status/transparency, UTC occupancy, multi-calendar availability, persistence, timed recurrence, moved/cancelled overrides and parser/export are unchanged or pending. An empty successful result describes this one native series/date query only and must not be promoted into a complete free/busy answer.

## Validation and acceptance

Test touching boundaries, earlier starts, unclipped results and every template form; COUNT/UNTIL history, additions/exclusions and immutable sorted output; widened raw/final limits and candidate work; mismatched starts/rules; profile-edge lookback and occurrence overflow; explicit Sunday WKST with an independent ISO label. Compare many short query/length combinations with an independent occupied-date enumeration. Run VM/Chrome tests, analysis and MCP reload; record actual results in [temporal core validation](../temporal-core.md#date-event-series-overlap-validation). The API shape remains proposed; this is not a claim of complete RFC, scheduling or external-client compatibility.
