# ADR 0012: Availability profile, fallback and calendar composition

Status: **Scope and summary intersection confirmed; implementation details proposed**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and source

This record consolidates the earlier availability-rule proposal and shared RFC 5545 profile into one current availability design. The RFC tables remain the latest feature-scope source.

The maintainer requested a configurable no-rule fallback that defaults to free and can change per calendar, confirmed authenticated-only rule access, and required multiple calendars to be returned separately. After examples, they confirmed separate calendar results plus an optional person/resource summary using host-selected contributing calendars. This resolves summary existence and booking aggregation; they then confirmed that every contributing calendar must allow a time for the summary to report it free.

## Rule model and calculation

Model availability rules separately from booked events. Retain VAVAILABILITY identity, revision, effective range, priority, BUSYTYPE and nested AVAILABLE periods with zone, recurrence and exceptions. Working hours, room opening hours, equipment availability and temporary overrides must not be encoded as fake appointments.

Apply RFC 7953 component-combination rules, including default/equal priorities and overlapping effective ranges, before overlaying bookings. Do not reduce precedence to a simple union of openings. Reuse pinned zone data and bounded temporal/recurrence evaluation. Rule changes participate in consistent query snapshots and invalidate affected calculations/representations after commit. This extends [ADR 0006](0006-resource-availability.md); schema/API details remain proposed.

## Shared profile

| Capability | Availability profile |
| --- | --- |
| Native services and interchange | Authorized rule management and supported import/export; independent of external feed UI |
| Text and labels | Editable SUMMARY/DESCRIPTION/LOCATION, searchable CATEGORIES with host validation and plain-text COMMENT; LOCATION never creates or reserves a host resource |
| Privacy | CLASS labels with host disclosure/masking; labels never grant access or publish rules |
| Contact | Preserve imported CONTACT through unrelated edits/round trips; no native contact creation/editing |
| Links and language | Editable URL without fetching; approved ALTREP/LANGUAGE and organizer name/directory metadata retain the earlier metadata-only and no-directory principles |
| Organizer | Host-validated calendar-address metadata, separate from ownership, access and scheduling authority |
| Persistent metadata | CREATED/LAST-MODIFIED/DTSTAMP and component identity retained; SEQUENCE where legal is separate from application revision and does not enable scheduling |
| Extensions | Explicit IANA property allowlist and trusted host X-property registration/validation; unknown data fails explicitly rather than disappearing |
| Recurrence | Shared bounded engine/profile, overrides and original occurrence identity; carry confirmed filters/WKST and HOURLY/MINUTELY support, defer SECONDLY/BYSECOND |
| Mutation and queries | Host authorization, atomic validated imports/edits, stale revision rejection, cache invalidation and no falsely free results from incomplete evaluation |

## Component-specific constraints

Follow the allowed property contexts and cardinality in [RFC 7953 section 3.1](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1). Shared support does not permit every property on every component. CLASS, URL, ORGANIZER and SEQUENCE belong to VAVAILABILITY; recurring periods belong to AVAILABLE. Use UTC or zoned DATE-TIME for starts/ends, not DATE or floating forms. Native all-day opening-hour UI can construct an explicit zoned interval; it cannot change the wire value type.

Do not add event/task-only properties or nested alarms merely because the module supports them elsewhere. Rule changes recalculate availability; they do not create task/event reminders. Keep PRIORITY/BUSYTYPE composition governed by RFC 7953 rather than event/task importance. No VAVAILABILITY iTIP methods or CalDAV transport are added.


## Confirmed scope

Each calendar has a host-authorized, revisioned no-applicable-rule policy. Its default treats unbooked time as free over complete known coverage. The alternative treats time with no applicable opening rule as unavailable. The unavailable alternative is selected in the RFC 7953 table; schema/enum names remain implementation details.

Fallback applies only to portions of the query with no applicable availability definition. Applicable rules retain their RFC 7953 composition semantics, and bookings still block time. Missing, denied or incomplete coverage is unknown regardless of setting. An availability definition that applies but has no AVAILABLE periods is not a missing rule and must not become free through fallback.

Return each requested calendar as a separate result with its identity, coverage and intervals under server-side disclosure policy. Multiple calendars do not become one calendar merely because they refer to the same person/resource. Provide an optional derived person/resource summary using only calendars the host explicitly marks as contributing to that subject. A blocking booking in any contributing calendar blocks the summary; calendars merely administered by the subject do not automatically contribute. For example, Work booked 09:00–10:00 and Personal booked 10:00–11:00 produce a summary busy 09:00–11:00 while retaining both calendar results. A caller cannot choose an incomplete subset and claim complete subject availability. Enforce host disclosure independently for calendar detail and summary access; unknown/denied/incomplete contributing coverage cannot become free. The maintainer confirmed intersection of contributing calendars: evaluate each calendar independently using its RFC 7953 priority/range rules, no-applicable-rule fallback and blocking bookings; a summary time is free only if every contributing calendar reports it free with complete coverage. Work 09:00–17:00 and Personal 10:00–18:00 yield 10:00–17:00 before bookings. A restrictive fallback in any contributor constrains the summary; a permissive fallback cannot override another calendar. Do not combine opening hours by union or let one calendar's priority override another calendar's constraints. This subject summary policy is distinct from RFC component composition within one calendar. Empty or unresolved contributing coverage cannot establish that a subject is free.

Raw availability definitions are exposed only through authorized native APIs and authenticated import/export initially. Do not include them in bearer-URL event feeds or create separate bearer availability feeds. Authorized native/free-busy queries and supported iTIP VFREEBUSY exchanges can use calculated results without exposing raw definitions.

## Implementation proposal and boundaries

Validate and persist policy changes transactionally with revision checks and invalidate affected availability/search caches after commit. Enforce read/manage permissions server-side; clients cannot supply policy overrides to bypass stored settings or host coverage resolution.

The fallback is module configuration, not a new RFC property. Ordinary RFC 7953 export cannot silently claim to encode that setting; document configuration portability separately. An all-day closure can use a zoned interval under the approved availability profile, without DATE-valued starts/ends.

## Shared-profile validation

Test legal metadata edits and round trips, import-only CONTACT retention, host disclosure and organizer spoofing, extension validation/rejection, known-zone validation, DATE/floating rejection and legal bounded recurrence/overrides. Test RFC examples, conflicting/default/equal priorities, effective-range edges, recurring hours, holiday overrides, DST and bookings inside/outside openings. Rule definitions alone do not establish subscription-client rendering. No VAVAILABILITY iTIP method mapping or CalDAV transport is added.

## Alternatives and consequences

Booking-only free/busy does not meet the selected availability scope. Reusing RFC 5545 principles only in legal component contexts avoids inconsistent metadata behavior without copying the event/task schema into rules. Availability priority/range/recurrence state must be included in calculation snapshots and invalidation.

A global fixed fallback cannot express both unrestricted calendars and calendars requiring explicit openings. Per-calendar policy supports both while retaining shared evaluation rules. The confirmed derived summary preserves individual calendar identities and results. It intersects independently evaluated availability from host-selected contributors. A union or one designated opening-hours source was considered but not selected.

## Acceptance conditions

Test default free fallback, configured unavailable fallback, partial rule coverage and boundary segments, applicable definitions with no openings, bookings under both settings, authorization, stale writes and immediate cache invalidation. Test denied/unknown/over-limit coverage never becoming free. Verify separate calendar identity/results and absence of raw rule data from bearer feeds, while preserving authenticated rule interchange and calculated free/busy.

Test separate calendars plus optional summaries, host-selected contributors, admin-only links, bookings in either calendar, no subset-based false-free results and summary/detail disclosure isolation. Test overlapping/disjoint hours, differing fallback settings, cross-calendar priorities that must not override one another, bookings in either calendar and incomplete/empty coverage. Common-free search across subjects intersects their complete free results after each subject summary is calculated. No runtime or external-client evidence exists yet.

Traceability: [requirements](../requirements.md), [RFC 7953 matrix](../rfc/rfc-7953.md), ADRs [0006](0006-resource-availability.md), [0008](0008-module-clients-tasks-and-search.md), [0010](0010-rfc5545-property-decisions.md) and [0017](0017-profile-review-clarifications.md), [availability-rule work](../roadmap.md#availability).
