# ADR 0065: First standalone VEVENT wire-to-core adapter

Status: **Accepted bounded observance scope; adapter API/limits under review**. Date: 2026-10-22.

## Context and confirmed choices

[ADR 0064](0064-first-vevent-and-zone-validation-contract.md) records the maintainer's selected first non-recurring VEVENT batch, including named zones, full supported-horizon VTIMEZONE matching and validation-only earlier seeds. The maintainer additionally selected explicit DTSTART/RDATE transitions and a bounded common YEARLY observance profile, with unsupported recurrence forms rejected until profiled. This increment implements a pure adapter; it does not introduce database import/export or HTTP endpoints.

Sources: [RFC 5545 event components](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1), [time-zone components](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.5) and their property/value definitions. [Existing syntax](0062-bounded-icalendar-syntax-foundations.md) and [temporal value codecs](0063-icalendar-temporal-value-codecs.md) remain separate layers.

## Implemented profile and proposed API mechanics

Accept one VCALENDAR with VERSION 2.0, nonempty PRODID, omitted/GREGORIAN CALSCALE and at least one VEVENT. METHOD, other components, extensions and not-yet-profiled calendar metadata reject. Each event requires nonempty source UID, UTC DTSTAMP and typed DTSTART. Accept optional DTEND or DURATION, SUMMARY/DESCRIPTION/LOCATION with legal LANGUAGE/ALTREP annotations, STATUS/TRANSP, UTC CREATED/LAST-MODIFIED and nonnegative 32-bit SEQUENCE. Reject unknown properties/parameters, invalid multiplicities and duplicate source UIDs within the source calendar before returning a result.

Project DATE or UTC/named-zone spans into existing DateEventSpan/TimedEventSpan, preserving end/duration/default form and nominal units. Both timed bounds require the same exact temporal profile; cross-zone flight-style ends and alias changes between bounds reject in this native-aligned slice even where legal in the broader RFC. DATE durations require the actual dur-day/dur-week wire grammar, not a zero-valued clock suffix. Preserve absent versus empty text and omitted status/transparency; omitted transparency retains opaque calculation meaning. Source protocol identifiers/version fields do not become native IDs, authorization or automatic scheduling state.

Expose parseIcalendarEventCalendar, validateIcalendarEventCalendar and serializeIcalendarEventCalendar, immutable typed event/text/zone projections, and the immutable accepted source syntax. Validate manually built syntax against syntax bounds too. Source serialization preserves accepted property spelling, values, parameters, order and explicit omission; syntax quoting/folding remains deterministic. It is not an authorization/disclosure projection or a byte-for-byte archive. Native field editing, imported identity reconciliation and transaction policy are separate work.

## Zone matching and calculation-only representation

Every named temporal property requires its exact supplied, validated VTIMEZONE; validate even unused definitions and reject duplicate TZIDs. Resolve known exact IANA names/aliases against the pinned data. Accept required TZID and STANDARD/DAYLIGHT DTSTART/TZOFFSETFROM/TZOFFSETTO, optional UTC LAST-MODIFIED/TZURL, repeated local RDATE and TZNAME/COMMENT text metadata, and at most one profiled RRULE per observance. Text labels and component names are not offset evidence; metadata is retained without fetching.

Read observance fields in a private wall-field encoding, separate from ordinary CalendarDate. Seeds/RDATE/UNTIL accept validated Gregorian years 0001–2100 for this bounded calculation profile; earlier years are seed evidence only and 2100 fields can affect UTC padding. This does not widen event dates or protocol timestamps. Local onset fields forbid Z/TZID/fractions/leap seconds; UNTIL requires UTC and must equal the last generated rule onset. Offsets require signed HHMM or HHMMSS, absolute magnitude below one day, valid fields and no negative zero.

YEARLY rules support optional INTERVAL 1–10000, UTC UNTIL, BYMONTH lists, signed BYMONTHDAY and BYDAY weekdays with optional single-digit ordinal ±1–5. Require BYMONTH when BYMONTHDAY/BYDAY is supplied so ordinal interpretation is month-based; without filters use seed month/day. Combine day filters by intersection, require seed alignment, skip invalid month dates and preserve independent RDATE additions. COUNT, other frequencies/filters, week numbering and other forms reject in this observance profile; this does not change native event recurrence support.

Expand onsets with TZOFFSETFROM before comparing instants. Deduplicate identical onsets only after charging raw budgets; reject conflicting simultaneous onsets or a broken FROM/previous-TO chain. Require an onset at/before the validation horizon, rather than inventing indefinite prehistory from a future onset. Compare the complete normalized offset function, including transitions and initial state.

Add NamedZoneResolver.calendarProfileSnapshot over fixed UTC **[1969-12-31, 2100-01-02)**. One day of padding on each side of the ordinary UTC profile covers all allowed offsets and the explicit exclusive endpoint. Prove known coverage directly in pinned rules, without constructing ordinary civil values from padding. Existing snapshot/localAt/value/storage guards remain unchanged. Matching only event dates, names, a few samples or a current offset is insufficient. Agreement is finite and pinned-version-specific, not approval of custom zones or future rule accuracy.

## Resource and failure contracts

Keep syntax byte/line/depth budgets in force. Component defaults across the whole calendar: 128 events, 32 zones, 128 observances, 8192 raw onsets and 200000 calendar-day candidates; configured ceilings are positive and at most 1000000 each. Charge duplicates before deduplication and candidates before filters. The reference snapshot also observes the configured transition cap. Duration/range arithmetic remains in the core.

Text limits are 4096 code points for UID/PRODID/SUMMARY/LOCATION and zone labels/comments, 16384 for event DESCRIPTION, and 255 for TZID. Retain separate syntax/escaped-wire limits; some maximum-sized decoded values need explicitly larger syntax budgets. Absolute ASCII URI metadata is capped at 4096, rejects credentials/malformed escapes/invalid characters and is never fetched; language uses existing BCP47 well-formedness checks. Limits are implementation profiles, not RFC maxima.

Return structured component error kinds without private property names, values, zones or nested exception payloads. Invalid input yields no semantic result and has no storage effects. Preserve unsupported data in the generic syntax layer only; reject it at this component boundary instead of silently dropping it.

## Alternatives, consequences and remaining work

Deferring named zones was offered and not selected. Full observance recurrence was offered and the bounded explicit/yearly profile was selected. Full-horizon comparison is deliberately stricter than accepting event-date-limited VTIMEZONE definitions; many otherwise useful client files will reject. Record real-client evidence separately before compatibility claims.

Test complete historical/yearly and explicit definitions, exotic offset changes, gap/fold fields, aliases, padding, late atomic failures, preserved source/text forms, conflicts, strict numeric grammar and aggregate work caps on VM/Chrome. Database identity/authority/import transactions, editable imported metadata, recurrence wire mapping, scheduling, alarms, RFC 7986 calendar mapping, authorized exports and bearer feeds remain pending.

## Recurring-master extension

[ADR 0066](0066-recurring-vevent-master-adapter.md) extends the original non-recurring checkpoint with RRULE and start-only RDATE/EXDATE. It supersedes recurrence rejection and raw RRULE part-order output below this checkpoint: source syntax is retained, but output emits FREQ first. PERIOD/override components and database import/export remain pending.
