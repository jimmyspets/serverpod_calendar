# First VEVENT wire-to-core adapter

The pure Dart serverpod_calendar_icalendar package now validates a bounded **standalone, non-recurring event-calendar profile** under [ADRs 0064](adr/0064-first-vevent-and-zone-validation-contract.md) and [0065](adr/0065-first-vevent-wire-adapter.md). It maps accepted timing to the existing core's DateEventSpan or TimedEventSpan and retains immutable source syntax. This is not a database import service, authenticated export API, scheduling processor or HTTP feed.

Current extension: [recurring masters](icalendar-recurring-masters.md) under ADR 0066 now adds RRULE/start-only RDATE/EXDATE and FREQ-first serialization. This supersedes the original recurrence-rejection statements below for that subset; PERIOD and occurrence-override components still reject. Protocol tokens use ASCII case folding; Unicode text remains supported.

## API and supported fields

Use parseIcalendarEventCalendar(bytes) for strict UTF-8/CRLF input, or validateIcalendarEventCalendar(syntaxDocument) for an existing/built tree. Both return IcalendarEventCalendar only after the complete supported source passes. serializeIcalendarEventCalendar(value) emits that accepted source with deterministic syntax quoting/folding, retaining metadata spelling/order and explicit omission. It performs no permission filtering.

| Context | Supported profile |
| --- | --- |
| Envelope | Exactly one VCALENDAR; required VERSION:2.0 and nonempty PRODID; omitted or GREGORIAN CALSCALE |
| Event identity/time | Required source UID, UTC DTSTAMP and DTSTART; optional UTC CREATED/LAST-MODIFIED and SEQUENCE 0–2147483647 |
| Event geometry | DATE, UTC or exact named-zone DTSTART; mutually exclusive DTEND/DURATION; end/duration/default form retained |
| Text | Optional SUMMARY, DESCRIPTION, LOCATION; optional single LANGUAGE/ALTREP annotations with plain text retained |
| State | Optional TENTATIVE/CONFIRMED/CANCELLED STATUS and OPAQUE/TRANSPARENT TRANSP |
| Zones | Exact known IANA TZID/alias plus an explicitly supplied matching VTIMEZONE, including full-horizon validation described below |

Repeated singular properties/parameters, multi-valued singular parameters and duplicate source UIDs within the source calendar reject. Separate calendars may use the same source UID; it never supplies a native UUID, actor or permission. Omitted and empty SUMMARY remain distinct; no placeholder is stored. Omitted status is retained, while omitted transparency has opaque meaning. Protocol timestamps and SEQUENCE are source metadata, not application revisions or automatic scheduling actions.

DATE remains a date, with a one-day default. An omitted timed end is a point. Positive durations retain weeks/days/clock units; a DATE event's wire duration must contain only the day/week grammar, so P1DT0S rejects. Both explicit timed bounds must use the same exact zone/profile in this first native-aligned slice: different-zone flight-style bounds and differing aliases reject. Ordinary dates/precision and explicit exclusive midnight endpoints follow [the temporal codecs](icalendar-temporal-values.md), without widening storage.

METHOD, recurrence/RECURRENCE-ID/RDATE/EXDATE on events, VALARM, VTODO/VFREEBUSY, CONTACT, attachments/participants, extensions and not-yet-profiled calendar metadata such as RFC 7986 NAME reject explicitly. Legal in the wider RFC does not mean implemented in this slice. Generic syntax can retain those values, but component validation must not silently discard them.

## VTIMEZONE matching

All supplied definitions, including unused ones, must pass; duplicate TZIDs reject. Every named event property must reference the exact accepted TZID. The validator recognizes pinned exact IANA names/aliases, expands source observances, then compares the **entire offset function** against the pinned database. It does not merely compare labels or event instants.

The comparison covers UTC **[1969-12-31, 2100-01-02)**, providing one day of calculation padding around the complete ordinary civil profile and its exclusive endpoint. A known onset at/before the horizon is required; a later first onset does not establish earlier coverage. Thus a modern definition that is correct around the event but wrong or incomplete historically rejects. This strict profile intentionally rejects many date-limited client definitions.

NamedZoneResolver.calendarProfileSnapshot provides the padded reference evidence without relaxing ordinary CalendarDate, localAt or event storage guards. The generated IANA data, unknown-offset failures and future-projection limits remain documented in [timezone data and updates](timezone-data.md). Agreement is pinned-version-specific; revalidate after a database upgrade before trusting persisted projections.

| Observance context | First accepted profile |
| --- | --- |
| Required | Local DTSTART, TZOFFSETFROM and TZOFFSETTO in STANDARD/DAYLIGHT |
| Additional onsets | Repeated local RDATE lists, optionally VALUE=DATE-TIME |
| Recurrence | One YEARLY RRULE with optional INTERVAL, UTC UNTIL, BYMONTH, BYMONTHDAY and BYDAY |
| Metadata | TZNAME with LANGUAGE; COMMENT with LANGUAGE/ALTREP; top-level UTC LAST-MODIFIED and absolute TZURL |

INTERVAL is 1–10000. BYMONTH supports 1–12; BYMONTHDAY supports signed nonzero 1–31; BYDAY supports weekdays and single-digit ordinals ±1–5. BYMONTH is required with either day filter; day filters intersect. Without filters, use the seed month/day. DTSTART must match its rule, invalid month dates skip, and UNTIL must equal the final generated onset in UTC. Unsupported frequencies, COUNT, other filters and parameters reject.

Earlier observance seeds may be read solely for validation. A private Gregorian wall-field representation accepts years 0001–2100 for onsets/UNTIL; 2100 fields serve calculation edges. These are not ordinary native event dates or permission to widen timestamp storage. Local onsets have no Z/TZID, fractions or leap seconds. Offset forms are signed HHMM/HHMMSS with magnitude below a day; negative zero rejects.

Onset UTC instants use TZOFFSETFROM. Exact duplicates are charged then deduplicated; conflicting simultaneous onsets and broken FROM/previous-TO continuity reject. TZNAME, COMMENT and STANDARD/DAYLIGHT labels do not independently determine offsets. Accepted source metadata is retained, with no lookup, download, rendering or identity inference.

## Limits, errors and remaining layers

The syntax limits still apply to manually built trees and input bytes. Default calendar-wide budgets are 128 events, 32 zones, 128 observances, 8192 raw onsets and 200000 day candidates. Limits are configurable from 1–1000000 each. Duplicates count before normalization; day candidates count before filtering. URI metadata is absolute ASCII, at most 4096 characters, without credentials or silent character repair; no content is fetched.

Decoded text caps are 4096 code points for UID/PRODID/SUMMARY/LOCATION and zone labels/comments, 16384 for DESCRIPTION, and 255 for TZID. Wire bytes/escapes/headers have separate syntax limits and may require larger explicitly configured budgets at the decoded maximum. No truncation occurs.

IcalendarComponentException exposes unsupportedComponent, unsupportedProperty, unsupportedParameter, duplicate, missing, invalidValue, limitExceeded, zoneMismatch or zoneCoverage. Diagnostics omit private source names/values and nested resolver payloads. Strict input syntax failures retain their syntax error type. Results and source collections are immutable; no partial event list is returned after a late failure.

The result is suitable for further host-authorized mapping. Transactional import, source-to-native identity reconciliation, imported field editing/preservation, recurrence/exception wire support, scheduling/alarm handling, full calendar metadata mapping, authorized export and optional HTTP feed routes remain separate work. Unit/browser fixtures do not establish Apple/Google/Outlook interoperability.

Sources: [RFC 5545 sections 3.6.1 and 3.6.5](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1).
