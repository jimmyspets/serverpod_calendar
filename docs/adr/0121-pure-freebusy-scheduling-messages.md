# ADR 0121: Pure free/busy scheduling messages

Status: **Previously selected first-release methods; concrete pure-profile mechanics under draft review**. Date: 2026-10-26.

## Boundary

Implement the selected VFREEBUSY PUBLISH/REQUEST/REPLY message codecs from [RFC 5546 section 3.3](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.3), independently of the VEVENT envelope and ordinary authenticated snapshot output. This adds no tables, native queries, mail, automatic replies or standalone VFREEBUSY import.

Each component requires UID, UTC DTSTAMP, positive UTC DTSTART/DTEND bounds and ORGANIZER. PUBLISH permits multiple components, each with its own identity/window, and forbids ATTENDEE and REQUEST-STATUS. REQUEST requires exactly one component and at least one ATTENDEE, and forbids FREEBUSY, URL and REQUEST-STATUS. REPLY requires exactly one component and one ATTENDEE and permits REQUEST-STATUS. CONTACT is optional and singular; COMMENT repeats. URL uses the existing bounded HTTP/HTTPS metadata profile and is never fetched. ATTENDEE accepts no parameters under RFC 5545 section 3.8.4.1's VFREEBUSY restriction; organizer annotations use the existing source-address profile. No address proves identity or authority.

FREEBUSY retains repeated property groups, comma-separated periods, explicit end versus positive duration, source order, duplicates and overlaps. Every period is UTC and within the supported temporal horizon. Source periods outside the advertised window are preserved rather than clipped; no complete partition is inferred. FBTYPE omission remains distinct from explicit BUSY. Preserve bounded extension tokens, with unknown values classified as BUSY only in the source-level interpretation required by RFC 5545 section 3.2.9. Even an explicit FREE claim never establishes authorized free time. Numeric REQUEST-STATUS values remain inert reports.

Reject all nested components, VTIMEZONE, SEQUENCE, recurrence, event/task properties, arbitrary extension properties and unprofiled parameters. Defaults: at most 32 published components, 1,000 total periods and 64 attendees per component; existing syntax, metadata, explicit-value and work budgets also apply across the whole message. Configurable component/period limits have finite upper bounds. Manually constructed syntax is bounded too. Ordinary snapshot output retains its stricter complete-partition and 31-day rules; this source reader does not weaken them.

## Later reconciliation

A parsed request triggers no lookup. A parsed reply establishes no matching request, verified respondent, disclosure permission, freshness or coverage. Empty periods and success-like codes cannot label time free. Trusted reconciliation must correlate the actual request/recipient/window, enforce the host's query/source/export permissions and coverage policy, and decide whether a response is permitted. No incoming data creates a host calendar, resource or booking.

## Validation

Test all three method tables, grouped end/duration periods and FBTYPE omissions/extensions, independently identified publications, UTC/profile/boundary rejection, participant parameters, result claims, aggregate limits and unchanged ordinary/event adapters. Run focused tests first, then complete pure VM/Chrome suites and relevant host regressions before one batch check-in. No full RFC, mail or external-client conformance claim follows from codec tests.
