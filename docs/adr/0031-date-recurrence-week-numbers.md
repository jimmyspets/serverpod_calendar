# ADR 0031: DATE-only recurrence week-number generation

Status: **Implementation proposed within the selected BYWEEKNO/WKST scope; pure-core evidence recorded separately from protocol support**. Date: 2026-10-20.

## Context and source evidence

[ADR 0010](0010-rfc5545-property-decisions.md) selected yearly BYWEEKNO and every WKST. The initial generator under [ADR 0030](0030-bounded-date-recurrence-generation.md) explicitly rejected week-number rules. This increment lifts that implementation restriction without adding timed recurrence, recurrence sets or interchange.

RFC 5545 [section 3.3.10](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10) defines week one using the four-day rule and the supplied week start, limits week selectors to yearly rules and prohibits ordinal BYDAY in combination with BYWEEKNO. Its week-20 Monday example provides a fixture. The [dateutil source](https://dateutil.readthedocs.io/en/stable/_modules/dateutil/rrule.html) was inspected as comparative evidence for calendar-year candidate periods and missing-field defaults, not copied or added as a dependency. No general compatibility with that engine is claimed; its source contains an unresolved negative-selector boundary TODO.

## Proposed implementation contract

Continue advancing YEARLY frequency/interval over **calendar-year** candidate periods anchored to DTSTART's calendar year. For each date, determine its actual week-year using WKST and the week containing January 4. Near New Year the week-year can differ from the date's calendar year. Match positive week numbers and negative ordinals against that week-year's actual 52/53-week length. Evaluating negative boundary selectors against the actual week-year, rather than the cadence period's year, is an explicit implementation interpretation; it keeps positive/negative aliases consistent at boundaries.

A week-number filter expands day selection: without BYDAY or additional day filters, retain all matching days instead of inheriting DTSTART's month/day/weekday. Other filters still apply to the actual calendar date. BYMONTH and BYYEARDAY do not use a shifted week-year date. BYSETPOS selects from the filtered **calendar-year** period; a YEARLY interval does not become a week-year interval. Keep distinct concepts explicit rather than shifting the entire candidate period into an adjacent year.

Missing week 53 yields no matching dates and consumes no COUNT. Overlapping positive/negative selections still produce one candidate per date. Existing mismatched-start rejection, COUNT/UNTIL, immutable sorted output and work/result failure semantics remain unchanged. Rule-level prohibitions on non-yearly BYWEEKNO and ordinal BYDAY combinations remain enforced.

## Date and coverage safeguards

Use bounded Gregorian integer day indices to calculate week-one boundaries, without timestamps or timezone lookup. Dates remain within 0001–9999. Adjacent week-year labels 0 and 10000 are private arithmetic labels only; calculations may inspect the next integer boundary to determine the length. They never construct or expose unsupported dates, expand accepted years or relax the named-zone 1900–2037 limit. The year-zero boundary uses the proleptic Gregorian leap-year length explicitly, avoiding truncating negative integer division.

Calendar-year periods remain complete inside the date profile, so BYWEEKNO does not require out-of-profile candidate dates for position selection. The existing rejection of clipped **weekly** BYSETPOS periods remains separate. Every examined date still consumes the existing caller-supplied work budget; numeric week calculations add bounded constant work, without an unbounded search.

## Alternatives and consequences

Treating every January date as week one or clamping week 53 would change recurrence meaning. Treating every year as 52 weeks would break negative selectors. Reanchoring YEARLY intervals to the week-year would change calendar-year cadence for a December DTSTART. Keeping all these distinctions in the existing date engine preserves the selected profile while leaving parser/client interoperability unverified.

## Validation and acceptance

Run the RFC week-20 date fixture, week 53 skipping/count behavior, December/January membership, actual-week-year negative aliases, calendar-year interval anchoring, month/position intersections, duplicate collapse, all seven January boundary cases, both date-profile edges and budget failures. Independently compare first/last-week membership across all 146097 days of a Gregorian 400-year cycle for each WKST, using a fourth-day-of-week construction distinct from the implementation's January-4 boundaries. Record VM/Chrome, analysis and reload results in [temporal core validation](../temporal-core.md).

This evidence covers date-only calculation. Timed/UTC/zoned recurrence, DST-generated gap rules in an engine, RDATE/EXDATE, overrides/tasks, spans, production budgets, parser/export and external-client interoperability remain pending. No broader ADR acceptance follows automatically.
