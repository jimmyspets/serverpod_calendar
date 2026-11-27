# ADR 0057: Native recurring working hours and calendar composition

Status: **Accepted increment and timing choices; storage/API mechanics under review**. Date: 2026-10-21.

## Maintainer decisions and sources

The maintainer selected optional validity start/end bounds for ongoing definitions, with every calculation bounded to the existing 1970–2099 profile. Each opening stores explicit UTC or named-zone timing independently of the calendar's all-day-event zone; changing that setting does not reinterpret hours. They selected recurring openings with inclusion/exclusion dates, priority, closed-time type and optional validity bounds first, with rich metadata and opening-occurrence overrides following separately.

Apply [RFC 7953 sections 3–5](https://www.rfc-editor.org/rfc/rfc7953.html#section-3), [ADR 0012](0012-calendar-availability-policy.md), the shared temporal profile and the host authorization/transaction contracts. Native calculation is not iCalendar parsing, serialization, scheduling or CalDAV support.

## Implemented native slice

`calendarAvailability` provides authenticated create/get/list/update/delete through generated clients. Each definition has a server UUID, parent UUID and revision; a separate active-data row holds its generated stable protocol UID, frozen content and creation/update times. Deletion removes active data and retains only UUID/parent/revision/deletion time. Active definitions prevent parent deletion. Child writes and parent deletion share the existing durable scope transaction across instances; no local lock/cache establishes correctness.

Content contains optional plain summary, optional independent UTC/zoned start-only validity bounds, priority 0–9, a non-free closed-time kind and up to 16 openings. Each opening has server-issued stable UID, positive explicit end or duration, and optional shared recurrence/inclusion/exclusion values. Omitted bounds are unbounded only within a bounded query. Whole seconds, named zones, mismatch rejection, gap/fold behavior, explicit dates and limits retain the shared profile. DATE/floating openings, zero-length periods, fractions and invalid ranges reject. Native envelope duration shorthand is not exposed in this increment; an explicit upper bound is used instead.

Creation accepts no caller-chosen opening UIDs. Updates retain supplied UIDs only from that definition and allocate UIDs for null/new entries. Full content replacement explicitly replaces the opening list and each opening's inclusion/exclusion lists; omissions do not trigger an implicit merge. Clients must start from the saved content to preserve fields they are not editing. Removing an opening is deliberate deletion, without occurrence retargeting. No imported components or opening-occurrence overrides can yet be stored.

## Composition and fallback

For each elementary UTC interval, use the highest effective definition priority: 1 highest, then 2–9, and 0/omitted lowest. Higher priority replaces lower-priority hours over its effective envelope, including closed portions. Equal-priority openings form a union; if none opens a segment, closed-time precedence is BUSY, then BUSY-UNAVAILABLE, then BUSY-TENTATIVE. Clip openings to envelope and query. An effective definition with no openings is a closure, not a missing rule. The calendar fallback applies only where no definition is effective.

Then overlay bookings. Native final classification retains ADR 0056 precedence: unavailable over busy over tentative over free. This native final-result precedence is distinct from RFC equal-priority BUSYTYPE precedence. Both are blocking classifications; openings never erase bookings. All adjacent identical final classifications merge. Unknown has no periods and never establishes free time.

## Host and operational boundary

Separate `listAvailability`, `readAvailability`, `createAvailability`, `updateAvailability`, `deleteAvailability` and `projectAvailability` permissions. Requests carry actual calendar/definition identity, frozen current state and proposed complete content; projection additionally carries the bounded free/busy query. Raw definition read is all-or-nothing in this slice, with no inferred event/calendar detail grant. Write receipts retain independent host disclosure. Final checks, stale revisions, scope generation and declared authorization guarantee use existing transaction machinery. Child changes do not alter the calendar's own metadata timestamp/revision.

The management list is a bounded configuration collection: at most 64 active definitions per calendar, UUID order, per-object read filtering and no totals/cursor. It cannot establish calculation completeness. Free/busy scans every active definition, independently authorizes projection, and returns unknown for any denied/unavailable/corrupt/over-limit required source. It does not reuse the filtered management list.

Trusted query caps add 64 definitions, 64 source openings combined and 5000 expanded openings. Each opening uses existing 200000 candidate/10000 raw/base and 500-result limits. These are per-opening budgets, not one global 200000-work claim. Rule/background output and final output each cap at 1000 intervals; the booking overlay accepts at most 5000 bookings plus 1000 background intervals. Existing event scan caps remain. Above-cap configurations can be stored but cannot establish complete free/busy in this bounded increment.

## Validation and remaining work

Test priority/default/equal ordering, bounded/unbounded envelopes, closures, clipping, DST, recurrence additions/exclusions, booking overlay, immutable callbacks, independent raw/projection access, stale/denied writes, deletion dependencies, malformed stored state, caps and scope isolation. Exercise generated clients on two independent hosts, competing updates and parent deletion/creation; extend populated upgrade and Flutter journeys. Record actual results in [validation](../scaffold-validation.md).

The example editor intentionally handles a single explicit-end opening with simple daily/weekly recurrence or a closure, UTC optional validity bounds and explicit dates. Advanced native definitions remain read-only in this form rather than being flattened. Stale edits preserve the draft and require reopening; deletion uses the displayed revision.

Rich availability metadata, native envelope DURATION shorthand, opening-occurrence overrides, import/export, host-selected subject summaries/common-slot search, indexed large-calendar coverage and VFREEBUSY serialization remain separate work. Rules are authenticated-only; no bearer feed or real mail is added.
