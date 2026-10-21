# Native event recurrence and occurrence previews

This increment extends [single-event CRUD](native-single-events.md) under [ADR 0054](adr/0054-native-event-recurrence-and-previews.md). The [ADR 0055 timing extension](native-occurrence-timing.md) now implements single/future timing edits and single cancellation/restoration; per-occurrence content and future cancellation remain pending. The maintainer approved this batch and preservation behavior; API/budget mechanics remain reviewable.

## Models and stored meaning

`CalendarEventContent.recurrence` optionally contains `CalendarEventRecurrence`: one optional `CalendarEventRule` and required inclusion/exclusion lists (use empty lists when absent). `CalendarEventRule` requires its filter lists as well; Serverpod list defaults are unsupported. No raw RRULE string is accepted. The obsolete `recurring` boolean is removed from the unpublished API. Old stored content without recurrence remains a single event; `recurring:false` is ignored on deserialization. Existing event JSON storage accommodates the new definition without a new SQL table/column.

| Model | Purpose |
| --- | --- |
| `CalendarEventFrequency` | MINUTELY/HOURLY/DAILY/WEEKLY/MONTHLY/YEARLY; DATE permits DAILY and coarser |
| `CalendarEventByDay` | Monday=1 through Sunday=7, optional ordinal subject to core legality |
| `CalendarEventRule` | Frequency/interval, optional COUNT or inclusive UNTIL, WKST and supported filters |
| `CalendarEventRecurrence` | Optional rule plus explicit inclusion/exclusion starts |
| `CalendarEventOccurrenceQuery` | Event UUID/revision and exactly one appropriate pair of half-open bounds |
| `CalendarEventOccurrence` | Original civil identity, effective civil start and DATE end or resolved UTC endpoints |
| `CalendarEventOccurrencePreview` | Event UUID/revision, timing kind/zone and a complete bounded result |

DATE UNTIL is `untilDate` with zero clock fields; timed UNTIL is `untilUtc`, including for named-zone rules. COUNT and UNTIL cannot coexist. Filters are BYDAY, BYMONTHDAY, BYYEARDAY, BYWEEKNO, BYMONTH, BYHOUR/BYMINUTE (timed only), and BYSETPOS, within the existing core's combination rules. SECONDLY, BYSECOND, floating times and PERIOD additions are outside this DTO profile. Timed ordinary seconds come from DTSTART; nonzero fractions and leap seconds reject. The whole-second [1970,2100) profile and [timezone guards/update procedure](timezone-data.md) remain in force.

Explicit inclusion/exclusion entries use `CalendarEventTiming` with a start only: no end/duration, same kind and exact zone identifier as the master. DATE stays zone-free. Canonical lists are sorted/deduplicated, but raw entries consume input limits. Inclusions before DTSTART are retained; exclusions win, including over DTSTART and inclusions, without replenishing rule COUNT. DTSTART must match its rule even when excluded. Explicit gaps use the selected offset-before-gap rule; recurrence-generated gaps are skipped without consuming COUNT; folds select the first occurrence.

WKST defaults to Monday. Explicit Sunday/other values affect recurrence cadence and BYWEEKNO week-year numbering. Native calendar presentation and labels remain ISO 8601, Monday-first, with week 1 containing January 4. Never label a rule-specific Sunday week number as an ISO week number. See [examples](week-conventions.md).

## Pattern edits and explicit dates

`update` still replaces native content, but preserves existing explicit dates by default. The server merges them before validation and host authorization. Omitting recurrence/removing its rule does not clear existing dates. An incompatible kind/zone change rejects without changing revision/content/time. Existing nonempty dates supplied differently require explicit replacement intent rather than being ignored.

Set `CalendarEventUpdateRequest.replaceRecurrenceDates=true` only for deliberate replacement/clearing of both lists. Supply the desired complete recurrence definition; null clears it. This uses normal event editing authority and the actual merged proposed content; status changes still require the separate lifecycle permission. Series UUID/protocol UID remain stable, and the event revision/scope generation advance transactionally. Parent metadata time does not advance. The separate ADR 0055 action API handles timing edits; this master update cannot clear its retained override state.

## Authorized previews

Call `client.modules.serverpod_calendar.calendarEvent.preview(query)`. Supply `eventId` and the saved `expectedRevision`. For DATE use only `fromDate`/`untilDate`; for UTC/named-zone events use only `fromUtc`/`untilUtc`. Bounds are increasing and end-exclusive. DATE ends alone may use 2100-01-01 midnight; UTC endpoints obey the ordinary UTC profile with the approved exclusive end. Necessary zone spillover remains internal calculation padding, not permission to submit out-of-profile bounds.

The host must allow `readEvent` and `previewEventOccurrences`, disclosing the timing group for both. Requests carry actual parent/event snapshots and `occurrenceQuery`, including its bounds. Existing actor/scope, callback deadline, failure and context revalidation behavior applies. Ordinary event views disclose recurrence only with timing. A stale revision rejects; reload the saved event before retrying. Previews do not modify data/timestamps.

Results contain full overlapping occurrences, including starts before the query; spans are not clipped. Omitted timed ends produce point markers with equal UTC endpoints and no positive busy interval. DATE results have civil dates and no UTC projection. Original identity is scoped by event UUID plus the original civil start/profile. A future moved override must preserve that identity. Cancelled/transparent series still appear in detail previews; no status-based availability conclusion follows.

| Trusted cap | Limit |
| --- | --- |
| Explicit inclusion + exclusion entries, before deduplication | 256 |
| Rule filter entries, combined before deduplication | 512 |
| Query width | 366 days |
| Candidate work, including history | 200000 |
| Raw/base occurrences before exclusions | 10000 |
| Final preview results | 500 |

Caps are fixed in this increment. Failures return no partial preview or continuation. Long histories can exceed work/base caps even for a narrow window. Validation errors, stale revisions, denied/unavailable authorization, work limits and unavailable zone coverage remain explicit failures. Do not derive free time from previews or authorized detail lists; dedicated complete/unknown availability coverage is pending.

## Example and evidence

The example event editor adds basic frequency, interval, COUNT, WKST and inclusion/exclusion controls. It preserves advanced filters and UNTIL; edit those through the typed API for now. Editing either explicit-date control deliberately replaces both lists in the selected profile; otherwise existing exact profiles remain preserved. Pattern changes alone never reinterpret stored explicit dates into a new zone. Preview requires a saved, clean revision and explicit DATE or UTC query bounds. Result lengths shown in a single authorized preview are not calendar totals.

See [validation evidence](scaffold-validation.md). Pure computation, service/native transport and Flutter behavior are separate evidence from future ICS parsing/serialization, feeds, external calendar UI, occurrence editing, availability, scheduling and alarm execution.
