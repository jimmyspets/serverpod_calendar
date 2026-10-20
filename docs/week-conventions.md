# ISO weeks and recurrence WKST

Status: **maintainer-confirmed behavior**. The native week display convention and explicit RFC WKST handling are confirmed under [ADR 0032](adr/0032-iso-week-convention.md). The core date-only recurrence calculations exist; the calendar GUI, standalone week-label API and iCalendar parser remain unimplemented.

## Native calendars use ISO 8601

Native calendars use Monday-first layout and ISO week labels. A week runs Monday through Sunday. Week 1 is the week containing January 4, equivalently the year's first Thursday. An ISO week-year has 52 or 53 weeks and can differ from the Gregorian year near New Year. Device locale does not change this convention. Native weekday numbers remain Monday 1 through Sunday 7.

## Recurrence rules honor WKST

`WKST` means the week start of an individual RFC 5545 recurrence rule. **If omitted, it defaults to Monday (`MO`). Explicit values are honored, including non-Monday values.** Preserve the supplied rule; never silently replace its WKST with Monday.

| WKST | Recurrence week boundaries | Week-number convention for BYWEEKNO |
| --- | --- | --- |
| Omitted or `MO` | Monday–Sunday | ISO-compatible Monday/four-day numbering |
| `SU` | Sunday–Saturday | Sunday/four-day numbering; not ISO week labels |
| `TU`, `WE`, `TH`, `FR`, `SA` | Named weekday through the day before it | Four-day numbering using that rule's start; not ISO week labels |

A rule's WKST controls recurrence grouping, not calendar-screen layout or the meanings of weekday identifiers such as `MO` and `SU`. Native presentation remains Monday-first with ISO labels even when an occurrence comes from a Sunday-start rule. Non-Monday WKST is permitted in native recurrence parameters as well as the future supported interchange profile.

WKST matters for weekly rules with `INTERVAL>1` and BYDAY, and yearly rules using BYWEEKNO. It does not mean an ordinary daily or fixed monthly-date rule must shift its dates. `BYWEEKNO` selects numbered weeks; without it, there is no week-number filter, although multi-week grouping can still matter. These semantics follow [RFC 5545 section 3.3.10](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10).

## Week numbers with a Sunday start

For each rule, week 1 contains at least four days in the new year; equivalently, it contains January 4. With `WKST=SU`, use Sunday–Saturday boundaries. The relevant week-year can therefore differ from both the Gregorian year and the ISO week-year.

| Date | Native ISO label / `WKST=MO` membership | `WKST=SU` recurrence membership |
| --- | --- | --- |
| 2021-01-01 (Friday) | 2020-W53 | Week 53 of 2020 |
| 2021-01-03 (Sunday) | 2020-W53 | Week 1 of 2021 |
| 2024-12-29 (Sunday) | 2024-W52 | Week 1 of 2025 |

For example, `BYWEEKNO=1;WKST=SU` can select 2021-01-03 even though the app displays that date in ISO week 2020-W53. A display label must not be substituted for rule-specific week membership.

Positive week selectors count from the start of the calculated week-year; negative selectors count from its end (`-1` is its last week). Use that week-year's actual 52/53-week length, including boundary dates. A missing week 53 produces no occurrence and consumes no COUNT. Yearly frequency/interval and BYSETPOS operate within calendar-year candidate periods, while week membership can refer to an adjacent year. See the precise native calculation contract in [ADR 0031](adr/0031-date-recurrence-week-numbers.md).

## Every two weeks can produce different dates

For a start of 1997-08-05, `FREQ=WEEKLY;INTERVAL=2;COUNT=4;BYDAY=TU,SU`, the explicit week start changes the first four occurrences:

| Rule week start | Generated start dates |
| --- | --- |
| `WKST=MO` or omitted | 1997-08-05, 1997-08-10, 1997-08-19, 1997-08-24 |
| `WKST=SU` | 1997-08-05, 1997-08-17, 1997-08-19, 1997-08-31 |

Changing WKST can move occurrences, so neither imports nor unrelated edits may rewrite it to match the screen layout. The synthetic date sequences are covered by the core generator fixtures; the rule text is explanatory, not evidence of an implemented parser or successful external-client import.

## Implementation and limits

The DATE-only core supports every WKST and yearly BYWEEKNO with explicit work/result limits. [Temporal core validation](temporal-core.md) records VM/Chrome tests, including all week starts and 400-year boundary checks. Timed recurrence, timed/PERIOD sets and moved/cancelled overrides, parsing/export and external-client behavior remain pending. These week conventions do not extend date years 0001–9999 or the **1900–2037 named-zone envelope**; the main README warning and coverage guards remain in force.
