# ADR 0030: Bounded initial date-only recurrence generation

Status: **Mismatched DTSTART rejection explicitly confirmed; generator API and budget contracts proposed; initial subset locally tested**. Date: 2026-10-20.

## Context and selected policy

The DATE-only rule validator under [ADR 0029](0029-date-recurrence-rule-values.md) now supplies immutable parameters. The maintainer selected explicit rejection of DTSTART values that do not match the rule; always including a mismatched DTSTART was offered and not selected. This choice covers first-period set-position selection as well as ordinary filters. The implementation also rejects an UNTIL earlier than DTSTART rather than returning a series whose first instance is excluded.

RFC 5545 [section 3.3.10](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10) defines filter ordering, set positions and occurrence bounds; [section 3.8.5.3](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.3) leaves unsynchronized starts undefined. This native rejection policy is explicit product behavior, not a claim of a mandated RFC error response.

## Initial engine contract

`DateRecurrenceGenerator.expand` accepts a start, one DATE-only rule, required `from`/`through` dates and required positive `maxCandidateDays`/`maxResults` budgets. It returns immutable, sorted unique **start dates** in the inclusive closed query range. A closed date range includes 9999-12-31 without inventing a year-10000 sentinel value in the public API. This is not an event-overlap query or an event's end: all-day event ends remain exclusive in the eventual span contract.

Implement daily/weekly/monthly/yearly cadence and intervals; BYMONTH, signed BYMONTHDAY/BYYEARDAY, plain/ordinal BYDAY, BYSETPOS, every WKST, inclusive UNTIL and COUNT from DTSTART. Weekly defaults inherit the start weekday; monthly/yearly inherit omitted date fields where applicable. Yearly weekday ordinals operate within selected months when BYMONTH is present, otherwise within the year. Monthly ordinals operate within the month.

Enumerate actual Gregorian dates in each cadence period, apply date filters and defaults, then choose set positions from that full sorted candidate set. Invalid nominal dates therefore contribute no occurrence or COUNT; they are not clamped into another date. Overlapping selections are deduplicated before counting. First-period candidates before DTSTART are not occurrences; earlier in-range series history still consumes COUNT even when outside the requested output range. UNTIL/query cutoffs are applied after period selection, so a partial output window cannot change BYSETPOS meaning.

Validate the first period and start even when the query would otherwise be empty. Clamp ordinary candidate traversal to the selected 0001–9999 date profile, but reject a BYSETPOS period crossing either profile edge: selecting from a clipped week could change its meaning. Check cadence step capacity before multiplying or adding large portable scalar intervals. Internal integer boundaries may represent a period edge; no out-of-profile date is constructed.

## Work and result limits

Every valid calendar date examined in a cadence period consumes `maxCandidateDays`, including rejected dates, pre-query history and full-period work required for position selection. Reaching the limit before proof of a complete answer throws `RecurrenceLimitException`. Attempting to append another output date beyond `maxResults` throws the same typed exception. No partially accumulated result list is returned. Exactly filling a result budget succeeds only when remaining evaluation proves completion within the query/COUNT/UNTIL bounds.

The caller supplies both budgets explicitly, within positive portable integer representation bounds. This does not select production maxima or permit clients to choose trusted server limits. Host/service input, work and output policies must be defined before endpoint exposure. This initial engine scans from DTSTART; an old series may exhaust work even for a narrow recent query. No unproved fast-forward or falsely complete/free result is introduced.

Follow-up: [ADR 0031](0031-date-recurrence-week-numbers.md) lifts the BYWEEKNO implementation restriction with scoped date-only week-year calculations. The restriction below records this original increment.

## Explicit unsupported scope

Reject every BYWEEKNO rule with `UnsupportedError` before generation, including COUNT=1 and empty-range cases. The rule validator can retain these planned selectors, but this first engine does not yet calculate week-year boundaries. This is an incremental implementation limit, not a first-release deferral or permission to drop the selector.

Timed/UTC/zoned recurrence, DST-generated gap skipping, multiple-rule sets, RDATE/EXDATE, PERIOD inclusions, moved/cancelled exceptions, original occurrence keys, tasks' completion lifecycle, spans/overlap queries, pagination, parser/export and subscription interoperability remain pending. Date-only arithmetic introduces no zone calculation; the named-zone 1900–2037 envelope and README warning remain unchanged.

## Alternatives and consequences

Treating each nominal month as a clamped date would change month-end/leap meaning and COUNT. Returning on a full result buffer would hide truncation. Applying positions only within the query would change the series. A single-date-per-period shortcut could not support the selected filters. Full valid-date period scans are simple and bounded but trade speed for explicit work accounting; optimize only with equivalent tests and proven COUNT/position semantics.

## Validation

Test cadence/defaults, all WKST values and a two-week boundary example, month-end/leap-century skipping, signed selectors, ordinal scope, complete-period position selection, duplicate collapse, historical COUNT, inclusive limits, mismatched start/end rejection, unsupported filters, exact/failed budgets, huge intervals and both date-profile edges. Run VM/Chrome tests, analysis and MCP reload. See [temporal core validation](../temporal-core.md). No full recurrence/RFC or client compatibility claim follows from this subset.
