# Standalone availability wire adapter

[ADR 0069](adr/0069-first-availability-wire-adapter.md) adds pure VAVAILABILITY/AVAILABLE parsing, source serialization and bounded core projection. The maintainer selected timing/composition before rich metadata, and positive opening intervals. This is separate from native availability CRUD, authenticated import, booking/free-busy authority and publication. API/limit mechanics remain under review.

## Profile and preserved meaning

`parseIcalendarAvailabilityCalendar` parses strict UTF-8/CRLF bytes; `validateIcalendarAvailabilityCalendar` also validates manually constructed syntax. The standalone VCALENDAR requires PRODID/VERSION and Gregorian CALSCALE or omission. Only VTIMEZONE and VAVAILABILITY children are accepted; mixed VEVENT/VTODO and METHOD reject. At least one definition is required; a definition may contain zero openings to express closure.

| Context | Accepted properties/meaning |
| --- | --- |
| Definition | Required UID/UTC DTSTAMP; optional DTSTART/DTEND or DTSTART+DURATION; PRIORITY/BUSYTYPE; CREATED/LAST-MODIFIED/SEQUENCE; SUMMARY/DESCRIPTION/LOCATION |
| AVAILABLE | Required UID/UTC DTSTAMP/DTSTART and positive explicit DTEND or DURATION; CREATED/LAST-MODIFIED; basic text; selected RRULE/RDATE/EXDATE; timing RECURRENCE-ID/RANGE |
| Basic text | Shared TEXT, optional legal LANGUAGE/ALTREP, source spelling/omission retained; no network retrieval |
| Not yet accepted | Organizer, URL/class, categories/comments/contact, extensions, unprofiled calendar metadata, other component types |

The positive-opening requirement is stricter than RFC 7953's optional-end grammar. Point openings, DATE/floating values, fractions and leap seconds reject. Every explicit named endpoint has its own exact matched TZID; no zone is inherited from its envelope or calendar. Supplied zones must match pinned IANA over the [full supported horizon](icalendar-event-adapter.md#vtimezone-matching). Existing gap/fold rules and 1970–2099 ordinary date limits remain unchanged. Only exclusive ends/validated duration results may reach the approved midnight 2100 boundary.

Envelopes retain independently specified start/end profiles; missing start is lower-unbounded and missing end/duration is upper-unbounded within bounded queries. DURATION needs a start, excludes an explicit end, and keeps units. P1D can differ from PT24H across DST. Positive explicit opening ends retain their exact elapsed span, while nominal durations retain calendar semantics.

PRIORITY is 0–9; omission means 0, lowest priority. BUSYTYPE omission means BUSY-UNAVAILABLE; accepted values are BUSY, BUSY-UNAVAILABLE and BUSY-TENTATIVE. Custom/unknown types reject. Source SEQUENCE is definition-only, nonnegative through 2147483647; it is not a native revision or proof of freshness. Integer grammar accepts a bounded nonnegative digit string with optional plus, not negative signs/fractions/implicit repair. All source components require DTSTAMP even where informal RFC examples omit it.

## Series, source and composition

`calendar.definitions` exposes immutable IcalendarAvailabilityDefinition objects with source UID/timestamps/text, preserved `start`, `end`, `duration`, effective `endExclusive`, priority/closed kind and grouped `openings`. Each IcalendarAvailableSeries has a typed `master`, `overrides` and core `timing`. IcalendarAvailable exposes its original AVAILABLE source, span, optional recurrence/identity/range and component-local source text/timestamps. Nothing invents protocol values or writes a database.

Openings reuse [master/PERIOD semantics](icalendar-recurring-masters.md) and [timing-component identity/inheritance rules](icalendar-occurrence-components.md). A matching recurring master must exist in the same parent definition; orphans, excluded identities, duplicates, mixed profiles and supplied content differences reject. Separate singles remain independent of timing ranges. In this bounded snapshot, opening master UIDs cannot be reused across definitions; no merging or reparenting follows. AVAILABLE forbids event STATUS/TRANSP and definition SEQUENCE: use EXDATE to omit an opening occurrence, not a cancelled event component.

`calendar.expand` takes a bounded ordinary/exclusive UTC window and explicit trusted limits. It returns core AvailabilityDefinition inputs with fully expanded positive openings clipped to envelope/query. Pass these to core `composeAvailability` to apply priority, equal-priority opening union/closed precedence and explicit fallback. Zero-opening effective definitions are closures, not missing rules. Outside-envelope definitions have no effect. Core composition does not create a reservation, check source permissions or overlay event bookings; those remain separate host/native responsibilities.

`serializeIcalendarAvailabilityCalendar` retains accepted original components/parameters/order/units/omissions with deterministic CRLF/folding and FREQ-first RRULE output. It is source serialization, not authenticated export or a bearer feed. Errors return no partial source calendar or successful partial projection, and diagnostics omit private source values.

## Work bounds and remaining scope

Default parse caps add **64 definitions**, **128 raw AVAILABLE components across the calendar** and **64 overrides per opening UID**. Duplicates consume raw caps. Shared explicit-date/rule-list limits, syntax ceilings and **200000 candidate work** across zone expansion, opening alignment and override membership remain active.

Expansion chooses fresh explicit limits. Candidate work and the total emitted occurrence cap are shared across all openings/definitions; occurrences count before merging. Rule/base occurrence ceilings remain per opening. Optional sharedWorkBudget propagation in core TimedEventSeries queries preserves existing callers without it. Parsing does not precompute all future occurrences: long history, moved ranges, large candidate sets or unsupported endpoints can still fail later queries, without truncation or implied free coverage.

Rich metadata, source-to-native reconciliation, host organizer/extension approval, authenticated import/export, native PERIOD storage, HTTP feeds, scheduling/alarms, CalDAV and external-client compatibility remain pending. No table/model migration, generated client or dependency change is required for this pure adapter.

Source: [RFC 7953](https://www.rfc-editor.org/rfc/rfc7953.html), sections 3–5.
