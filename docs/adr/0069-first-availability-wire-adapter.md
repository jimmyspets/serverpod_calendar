# ADR 0069: First availability wire adapter

Status: **Accepted timing/composition slice and positive-opening profile; API/limit mechanics under review**. Date: 2026-10-22.

## Maintainer decisions and sources

After [VEVENT occurrence components](0068-vevent-occurrence-components.md), the maintainer selected pure RFC 7953 VAVAILABILITY/AVAILABLE adaptation before authenticated database import. They selected timing, recurrence/timing overrides, PRIORITY/BUSYTYPE, basic text and protocol timestamps first; rich metadata follows separately and rejects meanwhile. They also explicitly require a positive explicit end or duration on every AVAILABLE master/override, matching native working hours. The RFC grammar permits omission: this is our stricter profile, not an RFC requirement.

Sources: RFC 7953 [component grammar and bounds](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1), [BUSYTYPE](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.2) and [composition](https://www.rfc-editor.org/rfc/rfc7953.html#section-4). Reuse [native composition](0057-native-working-hours.md), [versions/envelope durations](0061-availability-protocol-lifecycle-and-envelope-duration.md) and the whole-second [1970–2099 profile](0041-whole-second-1970-2100-profile.md). This adds no native storage, authority or CalDAV/iTIP transport.

## Implemented proposed adapter mechanics

Add parse/validate/serializeIcalendarAvailabilityCalendar with immutable source, definition, opening and grouped timing projections. Accept a standalone Gregorian VCALENDAR with PRODID/VERSION, VTIMEZONE and one or more VAVAILABILITY components; mixed event/task calendars and unprofiled envelope properties reject. Every source definition/opening requires UID and UTC DTSTAMP. CREATED/LAST-MODIFIED are optional UTC source metadata in both contexts; SEQUENCE is definition-only, 0–2147483647, independent of native revisions. Preserve optional omission/source values without choosing newer versions or manufacturing native creation times.

Definitions may omit either validity bound. Explicit bounds are UTC/named DATE-TIME, independently preserving their profiles and resolved ordering. DURATION requires DTSTART, excludes DTEND and retains positive nominal units; no end/duration means an unbounded end within bounded queries. Openings have positive UTC/named spans; DATE/floating/point/fraction/leap-second values reject. Existing exact zone aliases, explicit gap/fold rules and full-horizon VTIMEZONE validation remain required. Ordinary starts remain before 2100; only explicit exclusive ends/validated duration results reach the approved midnight boundary.

PRIORITY defaults to 0, accepts 0–9; BUSYTYPE defaults to BUSY-UNAVAILABLE and accepts BUSY/BUSY-UNAVAILABLE/BUSY-TENTATIVE only. Unknown/custom values reject rather than implying free. Integer input follows the existing bounded nonnegative/+digit profile (16 characters, exact BigInt bounds). Basic SUMMARY/DESCRIPTION/LOCATION uses shared TEXT/LANGUAGE/ALTREP decoding, limits and no-fetch validation. Source organizer, URL/class, categories/comments/contact, extensions and other unprofiled properties reject; they cannot confer authority.

AVAILABLE uses the shared selected RRULE/start/PERIOD additions/exclusion profile and original-identity timing overrides. Group exact UIDs within their actual parent with an in-file recurring master; no detached lookup. Reuse content omission inheritance and reject supplied differences, duplicate/orphan/excluded anchors and incompatible profiles. Only timing single/THISANDFUTURE components are supported. AVAILABLE has no STATUS/TRANSP/SEQUENCE: those properties reject; omissions/skips use EXDATE, not event cancellation components. Reject repeated master opening UIDs across definitions in this bounded snapshot profile instead of merging/reparenting them; source reconciliation is separate. Definitions also require unique master UIDs.

Expose preserved source bounds/units/protocol text separately from core TimedEventSeries projections. Keep source components named AVAILABLE, without fabricating event identity/timestamps. Reuse internal timing validation and shared text/integer decoding; do not round-trip through synthetic per-opening calendars or reset aggregate budgets. Serialization retains source with the existing FREQ-first normalization and deterministic syntax; it is not an authorized export/feed projection.

## Bounded projection and limits

IcalendarAvailabilityCalendar.expand accepts an ordinary/exclusive UTC query and explicit trusted work/rule/base/occurrence caps. Return immutable core AvailabilityDefinition inputs: expand each opening by overlap (including moved-in and long PERIOD spans), clip to envelope/query, and retain definition priority/closed kind. Existing core composeAvailability performs priority/equal-priority/fallback composition. Empty effective definitions remain closures; outside-envelope definitions have no effect. This does not add booking overlay, host authorization, source-completeness proof or a free/busy response.

Parsing shares existing 200000 default candidate work across zones, opening alignment and override membership; raw date/rule caps remain shared. Add defaults 64 definitions, 128 raw AVAILABLE components across the calendar and 64 raw overrides per opening UID. Existing positive/hard-maximum configuration validation applies. Source duplicates count before semantic rejection.

Query expansion uses a fresh shared RecurrenceWorkBudget across all opening series/definitions, plus one aggregate occurrence cap before interval merging. Raw-rule/base limits remain per opening and are not claimed global. Extend TimedEventSeries.expandOverlapping with optional sharedWorkBudget passed to recurrence expansion; omitted objects preserve existing native behavior, local limits remain active and failure consumption is retained. A query and parse have separate budgets; successful parsing does not guarantee cheap or in-range future expansion. Every failure is atomic and sanitized; no partial source/projection or falsely free result escapes.

## Alternatives and validation

Flattening openings or durations loses recurrence/original identity and nominal DST behavior. Treating empty definitions as missing manufactures free time. Separate per-opening parser/query work caps multiply total cost; reuse shared core accounting. Accepting metadata without context/authority would imply unimplemented import behavior, so keep the first profile explicit and reject unsupported data.

Test defaults/closures, independent optional bounds, preserved duration/metadata/source, positive opening rejection, recurrence/PERIOD/EXDATE, timing singles/ranges, priority/equal composition and clipping, named DST/full-horizon agreement, context/cardinality/grammar/profile rejection, source/query aggregate caps and sanitized late failure. Run focused affected VM checks during development and complete VM/Chrome/repository checks at batch completion. Rich metadata, authenticated import/export, native PERIOD storage, scheduling/alarms, feeds and external-client interoperability remain pending. No schema, migration, generated protocol/client or dependency changes follow.

## Scoped extension

[ADR 0070](0070-availability-wire-metadata.md) supersedes the metadata rejection boundary for the selected pure source-preserving profile. Other pending transport, authority and storage work remains unchanged.
