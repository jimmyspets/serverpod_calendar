# ADR 0147: Bounded calendar-wide event occurrence queries

Status: **Accepted by explicit maintainer approval on 2026-10-30 for the complete query, disclosure, limits and nullable cursor-storage batch. The scoped implementation and complete feature-batch validation finished on 2026-10-30; see the implementation guide and validation record.**

## Context and inspected evidence

[FR-04](../requirements.md) requires authorized overlapping event/occurrence pages. Native event-definition lists and revision-bound per-event previews exist, but there is no calendar-wide occurrence query. Callers currently have to discover series and expand them individually. This remains required under the original release scope; the limited-alpha discussion did not remove requirements.

[ADR 0044](0044-authorized-query-projections-and-pagination.md) confirms separate detail/free-busy responses, predefined disclosure groups, opaque pagination and no totals. [The query guide](../authorization-queries.md) requires filtering before the visible page boundary and genuine exhaustion. Source inspection of `listEvents`, `previewOccurrences`, `CalendarModuleOptions` and `CalendarCursorRecord` shows reusable actual-parent authorization, field groups, scope-generation fencing and server-side cursors. Existing defaults are 100 visible rows, 1,000 scanned events, 64 cursors per scope and a 10-minute cursor lifetime. Existing cursor rows have no occurrence-window/ordering state.

## Proposed complete feature batch

Add one-calendar event occurrence queries, generated-client APIs and a bounded Flutter example view together. Cover non-recurring and recurring DATE, UTC and named-zone events, RRULE/RDATE/EXDATE/PERIOD, single/future timing changes, inherited/overridden text and cancellation state. Keep tasks, multi-calendar aggregation, category/text search, reusable calendar widgets, scheduling and availability calculation outside this batch. Existing APIs retain their meaning.

The immutable request selects a calendar UUID, whole-second UTC half-open window, page size, optional cursor, `includeCancelled` (default true) and optional summary/description/location groups. Timing and state disclosure are mandatory for returned rows; richer ordinary fields can be added separately. Resolve the actual calendar in the trusted host scope. Clients supply no scope, actor, timezone override or candidate IDs.

Return a page of series UUID, calendar UUID, series revision, exact typed original occurrence identity, effective timing, effective status/transparency/cancellation and independently disclosed text groups. Preserve explicit empty text versus inherited text. Return only the authorized page and opaque continuation; no total, denied count, raw count or protocol/source UID is added. Omitted text groups remain distinguishable from disclosed absent values. A row is a read projection, not an editable copy of canonical source state.

## Proposed overlap and temporal rules

- Positive intervals overlap when start is before query end and end is after query start. Return full effective spans without clipping them to the window.
- Point events match when their instant is at or after query start and before query end.
- DATE spans retain civil dates and exclusive ends. Use the actual calendar's stored availability zone solely for instant-window matching and ordering, as the native free/busy projection already does; never turn their public meaning into midnight UTC or infer a device/server zone.
- Preserve UTC/named-zone profiles and original identities while matching effective times. Include moved-in exceptions whose originals lie outside the requested window; exclude moved-out intervals. Apply existing recurrence/DST and nominal-duration semantics with shared bounded work.
- With `includeCancelled=true`, include cancelled masters and individual cancelled originals with their retained effective timing and an explicit cancellation state. This may require a separate read-only projection of retained cancellation state; never mutate native overrides, restore an occurrence, strip cancellation from scheduling output or invent membership. With false, omit those rows after state authorization. Transparent events remain detail-query results.

Ordinary stored values remain in [1970-01-01, 2100-01-01), with existing explicit exclusive-end rules. Calculation-only padding does not extend storage. Native presentation remains ISO Monday-first/ISO week numbering; recurrence-specific WKST remains independent. No new week-number interpretation is introduced by a UTC window.

## Proposed host policy and privacy

Require a separate collection-level occurrence-query permission, plus actual event read/occurrence-preview authority. Supply immutable window/options and the actual calendar/event/current override state to policy; candidate planning is host-controlled and cannot trust client parentage. Reuse bounded policy batches and actual-object verification.

Timing/state must be authorized before using them to select/disclose an occurrence. Denied objects or mandatory groups contribute no visible row; optional text may be withheld independently and is labelled through disclosed groups. This first contract uses the same per-series preview authority as existing previews; it does not claim mixed per-occurrence authorization inside one series. Hosts can deny the query for a series whose policy cannot safely be represented by that contract.

Apply current authorization on every page and verify the declared policy context before returning. Keep coordinated versus external fresh-check guarantees explicit, including the external after-check revocation race. A detail page, including an empty one, establishes no complete availability or free time.

## Proposed ordering, limits and cursor storage

Order by effective UTC start (using the calendar-zone calculation for DATE), then native event UUID and canonical typed original identity. These keys must be deterministic and unique. Do not order by hidden text, protocol UID or client offsets.

Initial hard/default limits: 366 elapsed days per query, existing 100-row page and 1,000-event scan caps, 100,000 aggregate recurrence/zone candidate-work units and 10,000 materialized matching occurrences before pagination. Charge raw work before deduplication/output filtering; count cancelled materializations too. Hosts may lower these limits. If complete authorized paging/end cannot be proved within budget, fail explicitly without returning a partial page or misleading null cursor. This bounded scan profile is not an indexed large-calendar scalability claim.

Recompute the bounded authorized result under the current scope transaction for each page rather than persisting event text snapshots. Continue strictly after the saved unique key. Bind tokens to principal, host scope, calendar, operation, normalized window/options/groups/page size, data generation, policy revision and exact pinned timezone-data identity. Changed data/policy/timezone identity requires restart; no cursor grants permission or silently downgrades consistency.

Propose **one nullable server-only nested JSON field on the existing CalendarCursorRecord**, containing a versioned occurrence-family marker, normalized window/options, last effective-start/original key and timezone identity. Reuse existing parent, actor, generation, projection, page-size, last event UUID and expiry fields. No new table or copied event/source payload is proposed. Validate family/field combinations; existing calendar/event/task/alarm/history cursor handlers must reject occurrence tokens. Unknown/malformed versions reject. Keep the existing 64-cursor/10-minute defaults and cleanup; upgrade preserves ordinary cursor rows with the new field absent and invents no query state.

## Proposed example and validation

Add explicit window inputs, authorized occurrence rows, refresh and Load more. Show original versus moved timing and cancellation clearly; retain DATE/zone distinctions. Do not add a reusable GUI package, totals, automatic free-time inference or subscription-client claims.

Test boundary/point/multi-day/DST cases, all temporal profiles, moved-in/out and future changes, PERIOD lengths, cancellations, content inheritance/clears, stable ties, interleaved denial, mandatory/optional disclosure, true exhaustion, dense-work rejection and immutable policy input. Exercise cursor family/criteria/principal/revision/zone-data isolation, revocation and cross-host changes. Generate the approved nullable-column migration and verify fresh/populated upgrades; run real generated clients, two hosts and Flutter, then the complete batch checks before one code commit.

## Decision gate and remaining scope

The maintainer explicitly approved the complete query/disclosure/cancellation, bounds and one-field cursor storage batch on 2026-10-30, satisfying the AGENTS.md model/ADR gate. Implementation and validation remain separate from approval. This does not change the original release scope or approve subsequent multi-calendar/task queries, indexed scale, timezone-upgrade coordination or broader scheduling work.
