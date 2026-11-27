# VEVENT occurrence timing components

The pure iCalendar adapter supports the scoped timing/single-cancellation profile under [ADR 0068](adr/0068-vevent-occurrence-components.md), extending [masters and PERIOD additions](icalendar-recurring-masters.md). The maintainer approved this feature batch, the matching in-file master requirement and omitted-content inheritance with supplied differences rejected. API/limit mechanics remain under review. This is source-to-core adaptation, not authenticated database import or scheduling reconciliation.

## Grouped API and source

`calendar.events` contains masters only. `calendar.series` provides immutable IcalendarEventSeries groups, each with `master`, typed source `overrides` and either core `dateSeries` (DateEventRangeSet) or `timedSeries` (TimedEventSeries). A group also exists for a non-recurring master. Use the master for common effective content, and the core series for bounded timing/overlap expansion. Timing projections alone do not apply master STATUS/TRANSP or authorize busy/detail publication.

An override exposes typed `recurrenceDate` or `recurrenceTime`, `originalStart`, `isOverride` and `isThisAndFuture`. Its dateSpan/timedSpan is its own complete parsed timing. Cancellation retains these values even though it removes the occurrence from core projection. Raw optional content remains raw: omitted properties are not fabricated on the source component. DTSTAMP/CREATED/LAST-MODIFIED/SEQUENCE remain component-local source metadata, not native revisions or proof of freshness.

All accepted source components retain their original order, spelling, omissions and parameters in `calendar.source`, including overrides preceding their master. Serialization retains them with the existing deterministic syntax/FREQ-first behavior; it is not a host-authorized export/feed projection.

## Identity and timing profile

| Input | Bounded profile |
| --- | --- |
| UID | Exact decoded value; one in-file master per UID; no detached components |
| Master | Must have supported recurrence properties when overrides exist |
| RECURRENCE-ID | Ordinary DATE or exact UTC/named master profile; original scheduled start |
| RANGE | Omitted for single changes; only THISANDFUTURE accepted |
| Component timing | UID/DTSTAMP/DTSTART required; explicit end, positive duration or standalone default |
| Single cancellation | Explicit STATUS:CANCELLED; typed timing/source retained |
| Ranges | Timing only; explicit CANCELLED range rejects |
| Pattern properties | RRULE/RDATE/EXDATE on overrides reject |

DATE-only and timed identities cannot mix. Named identity and replacement values require their own supplied, full-horizon-matched TZID, with the exact master alias; missing TZID is not inherited. Fractions, floating time, leap seconds and out-of-profile identities reject. Only an explicit exclusive replacement end or validated duration result may reach the existing midnight 2100 boundary. The ordinary profile remains [1970-01-01, 2100-01-01).

Every override anchor must belong to DTSTART/RRULE/RDATE/PERIOD minus EXDATE before timing changes. A moved start cannot retarget another change. Duplicate anchors, including single/range collisions or different SEQUENCE values at one anchor, reject. Excluded and orphan overrides reject rather than being discarded or resurrected. Earlier explicit inclusions retain their original identities and do not rebase DTSTART/COUNT.

A range uses its shift from the original anchor and its complete replacement span until the next original range anchor. Later shifts replace earlier shifts, not compound them; a separately overridden occurrence retains its own timing/cancellation. Nominal DURATION stays nominal across DST, and explicit ends propagate exact elapsed lengths through the core. Existing PERIOD/range precedence remains unchanged. Use overlap expansion rather than filtering original starts in the actual query window: an override can move into the window from either direction.

## Content, versions and limits

Omitted summary/description/location/status/transparency inherits from the master. Explicit text must match the master, including LANGUAGE and ALTREP. A supplied status must match its explicit master value, with single CANCELLED as the exception; opacity compares the ordinary default-opaque meaning. Content differences and future cancellation reject explicitly. The parser does not reconcile a prior cancellation or reopening message; it validates only the supplied snapshot. This prevents a timing-only import from silently losing content changes. An omitted end does **not** inherit master duration: it keeps the standalone one-day DATE or timed-point default.

The file uses the selected in-file master requirement; other snapshot/API mechanics remain reviewable. It does not choose among multiple versions, compare source timestamps, reconcile stale messages or find a missing master in storage. UID and source SEQUENCE are not authorization or concurrency credentials.

Defaults: **128 total raw VEVENT components**, **64 overrides per master UID**, and **10000 selected raw/final membership occurrences per scan**. Duplicates count before rejection. The existing **200000 shared candidate-work cap** covers VTIMEZONE, all master alignment and all override membership scans. DATE single/range validation can scan separately; both scans consume that shared object. Explicit dates/rule lists retain their own raw caps. Limit failure is complete-calendar failure, never partial success. Future bounded overlap queries choose their own limits and may still fail on long history or profile overflow.

The core's optional sharedWorkBudget is now propagated through recurrence sets and membership constructors; omitted budgets preserve existing native behavior. No host API/storage, generated client or schema changes are part of this increment. Per-occurrence content, future cancellation, authenticated import/export, scheduling, alarm activation, feeds and external-client interoperability require separate work.

Source: [RFC 5545 RECURRENCE-ID and RANGE](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4).
