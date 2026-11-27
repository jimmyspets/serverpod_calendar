# Recurring VEVENT masters

The pure event-calendar adapter now accepts bounded recurrence masters under [ADR 0066](adr/0066-recurring-vevent-master-adapter.md). It extends [the first event/zone profile](icalendar-event-adapter.md); database import/export, scheduling and feed publication remain separate.

IcalendarEvent.recurrence is null when no recurrence properties exist. Otherwise it exposes a core DateRecurrenceSet or TimedRecurrenceSet, preserving typed DTSTART and immutable canonical rules/inclusion/exclusion values. Finite explicit-date sets without a rule are valid. The containing event's source syntax retains original spelling, ordering and duplicate representations.

| Property/part | Accepted master profile |
| --- | --- |
| RRULE | At most one; FREQ required; repeated/unknown parts reject |
| FREQ | DAILY/WEEKLY/MONTHLY/YEARLY for DATE; also HOURLY/MINUTELY for UTC/named values |
| Bounds | Positive INTERVAL; positive COUNT or inclusive UNTIL, never both |
| Date filters | BYDAY with legal ordinals, BYMONTHDAY, BYYEARDAY, BYWEEKNO, BYMONTH, BYSETPOS |
| Clock filters | BYHOUR/BYMINUTE for timed values only |
| WKST | Omitted means Monday; every explicit RFC weekday is honored |
| RDATE/EXDATE | Repeated start-only lists; timed RDATE also accepts explicit VALUE=PERIOD under ADR 0067. Exact master kind/zone and legal VALUE/TZID parameters required |

Protocol tokens use ASCII case folding: Unicode lookalikes reject, while ordinary calendar text remains Unicode. Core range/combination restrictions still apply: for example WEEKLY forbids BYMONTHDAY, ordinal BYDAY requires MONTHLY/YEARLY, YEARLY BYWEEKNO cannot combine with ordinal BYDAY, and BYSETPOS needs another supported BY part. Invalid DATE clock filters reject. SECONDLY/BYSECOND and RECURRENCE-ID/override components remain unsupported and reject explicitly.

UNTIL is an ordinary DATE for a DATE master, or UTC DATE-TIME for UTC/named masters. Floating/local named-zone UNTIL and the exclusive 2100 boundary reject. DTSTART must match the rule's first cadence period, including BYSETPOS, even when excluded by EXDATE. Validation uses the core generator with a tiny output window but may need a full cadence period to establish alignment; a small window does not remove work limits.

## Set and timezone meaning

RDATE may add starts before DTSTART without moving it or changing rule COUNT. EXDATE removes matching starts from the complete union, including DTSTART or an RDATE, without replenishing COUNT. Duplicates have no semantic effect but still consume raw input budgets.

Explicit dates require the same kind and exact supplied zone identifier as the master. A UTC suffix forbids TZID; a local value requires its own explicit matched TZID rather than inheriting it from DTSTART. All named definitions still pass the full supported-horizon [zone validation](icalendar-event-adapter.md#vtimezone-matching).

Generated nonexistent local times skip without consuming COUNT; explicit native/imported times retain the selected RFC gap/fold policy. Seconds are preserved, with fractions and leap seconds rejected. P1D remains a nominal day and can differ from PT24H across DST. Core spans retain the event's end/duration/default form; this increment does not flatten series.

Native calendar presentation and ISO week numbers stay Monday/January-4 based. Explicit WKST controls recurrence week boundaries and BYWEEKNO; those non-Monday recurrence week numbers are not ISO display labels. See [week conventions](week-conventions.md).

## Bounds, output and remaining work

Default raw caps are **256 combined raw RDATE values/EXDATE starts per event**, **512 BY-list values per rule**, and **4096 of each across the calendar**. Duplicates count before normalization. RECUR input is at most 4096 UTF-16 units; COUNT/INTERVAL are unsigned positive digit strings of at most 32 characters and must fit the core's exact portable integer bound. Numeric filter signs and digit widths follow the selected RFC grammar, not Dart's permissive number parsing.

The default **200000 candidate-work budget is shared** across VTIMEZONE expansion and all DTSTART-alignment checks in one calendar. Core generators accept optional RecurrenceWorkBudget to charge existing work units to an aggregate ceiling; their local caps still apply, and failures do not refund consumed work. Existing callers without that object retain their prior behavior. Other syntax/metadata/event/zone limits remain in force.

Serialization accepts input rule parts in any order but emits FREQ first, as required by RFC 5545. Original source syntax is unchanged; other part order/spelling and repeated explicit-date properties remain retained. This applies to accepted event and observance RRULE values. Deterministic syntax quoting/folding remains separate from host authorization or export projection.

Parsing returns no partial calendar after a late rule/date/limit failure. Future bounded queries can still fail on long history, large candidate sets or coverage; parsing does not precompute every occurrence or guarantee cheap queries. Separate occurrence components, source-to-native identity/transaction handling, scheduling/alarms and HTTP feeds follow in later batches.

Source: [RFC 5545 recurrence grammar and behavior](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10).

## PERIOD-valued RDATE additions

[ADR 0067](adr/0067-vevent-period-additions.md) extends timed masters with explicit `RDATE;VALUE=PERIOD`. Each pair is a start/end or start/positive-duration value; comma lists may mix these two forms. Separate RDATE properties may still contain start-only additions. For example:

```text
RDATE;VALUE=PERIOD:20261023T120000Z/20261023T140000Z,20261024T120000Z/PT3H
```

The immutable `timedSet.periods` map exposes preserved core TimedEventSpan values keyed by original start. The containing source retains raw signs, units, spelling, duplicate pairs and property order. Every pair consumes one combined raw explicit-date slot, including duplicates and excluded values; its two endpoints are not two occurrences. Existing calendar-wide caps also apply.

A pair must have positive resolved length. UTC/named profile and exact zone alias must match the master, and every local endpoint uses the RDATE property's own validated TZID. Missing TZID does not inherit DTSTART's zone. Full-horizon VTIMEZONE matching, explicit gap/fold rules and whole seconds remain required. DATE-only masters, PERIOD EXDATE, inferred/mixed value types, unknown parameters, negative/zero durations, fractions and leap seconds reject. An ordinary period start stays within 1970–2099; only its explicit exclusive end or validated duration result can reach the approved midnight 2100 boundary.

PERIOD supplies the full span when its original start also appears in DTSTART/RRULE/start-only RDATE. Earlier additions preserve DTSTART and COUNT; EXDATE wins over all additions. Identical canonical spans coalesce; conflicting spans/forms at one identity reject even if excluded. Equal end instants do not erase the distinction between explicit end and duration, or nominal P1D and elapsed PT24H. This conflict policy comes from the core profile rather than a new RFC requirement.

Use core TimedEventSeries overlap expansion with the returned recurrence and master span when calculating intervals: start-only set expansion returns identities, not occupied spans, and a long PERIOD can overlap a query whose start is later than its own start. Parsing does not flatten or precompute occurrences. Native module JSON/storage still rejects PERIOD input; authenticated database import, identity reconciliation and authorized export are separate work.

## Occurrence-component extension

[ADR 0068](adr/0068-vevent-occurrence-components.md) adds [grouped timing/single-cancellation components and timing-only THISANDFUTURE](icalendar-occurrence-components.md). This supersedes occurrence-component rejection above only for that subset. Master/event lists remain separate from grouped overrides; content/future cancellation and native import/export remain pending.
