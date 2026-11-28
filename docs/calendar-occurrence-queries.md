# Calendar-wide event occurrence queries

Accepted [ADR 0147](adr/0147-bounded-calendar-occurrence-queries.md) adds the bounded one-calendar portion of FR-04. The generated `calendarEvent.listOccurrences(CalendarEventOccurrenceListQuery)` API returns effective event occurrences across a calendar. Existing event-definition lists and per-series previews retain their meaning. This is a detail query: an empty result never establishes free time or complete availability.

## Request and response

Select a calendar UUID, whole-second UTC `fromUtc`/`untilUtc` half-open window, page size, `includeCancelled` (default true), optional continuation, and zero or more summary/description/location groups. Pass an empty group list for timing/state only. Timing and state disclosure are mandatory for every returned row. The first profile does not accept category/text filters, task queries or multi-calendar aggregation.

Each item includes native event/calendar UUIDs, series revision, exact typed original start, effective occurrence timing, effective status/transparency/cancellation, and actual disclosed groups. The occurrence contains independently disclosed effective/own text. An explicit empty override remains distinct from inheritance; withheld groups remain distinct from disclosed absent values. Protocol UIDs, rich source metadata and private import baselines are not returned.

The page contains `occurrences` and an optional opaque `nextCursor`, with no totals, estimates or hidden/raw counts. Load more using the same normalized criteria and page size. A null continuation means authorized exhaustion was proved; a budget failure is an error, not a short successful page. Results may span outside the requested window because matching never clips an event's effective interval.

## Temporal and cancellation behavior

Positive intervals overlap when their start precedes query end and their exclusive end follows query start. A point matches at query start, but never at query end. DATE events retain civil dates and exclusive ends, with no public midnight-UTC conversion. Matching/order uses the actual calendar's saved availability zone; neither client nor server/device locale supplies it. A wholly skipped local DATE with zero instant geometry does not match an instant window; its canonical event remains stored.

UTC/named-zone starts, nominal durations, RRULE/RDATE/EXDATE/PERIOD and single/future timing changes use the existing core. Moved-in originals outside the query window are included, moved-out intervals excluded, and original identities remain unchanged. DATE matching uses a conservative offset envelope clamped to ordinary civil dates; full occupied-span offset coverage is checked separately. This supports profile-edge UTC windows without constructing out-of-profile local dates.

Cancelled masters and individual originals are included by default with explicit cancellation state and retained effective timing. A cancelled original without its own replacement still follows current series/range timing. The detail projection temporarily materializes timing without its suppression flag; it neither mutates/restores canonical state nor manufactures a scheduling/export component. `includeCancelled=false` filters after state authority and materialization charging. Transparent events remain details. These rows do not themselves represent blocking reservations.

Ordinary native values and ordinary UTC query starts remain **[1970-01-01, 2100-01-01)** at whole-second precision; an explicit query end may be 2100-01-01 midnight UTC. Derived full spans can cross the UTC boundary within calculation padding when their civil values remain supported. Padding is not permission to submit an out-of-profile UTC window. Existing exclusive ends and calculation-only UTC padding remain separate from ordinary storage. ISO Monday-first weeks/ISO week numbering remain native presentation policy; recurrence WKST can independently change recurrence membership. No new week interpretation or timezone library is introduced.

## Host integration and privacy

Hosts must implement the new transaction-aware `planEventOccurrenceQuery` and decide `CalendarPermission.listEventOccurrences` for the actual calendar/window. The plan is a complete trusted eligibility set, not an incomplete optimization hint. Its optional event IDs cannot introduce another calendar or bypass read authority. The same transaction is available for coordinated host database reads; receiving a transaction alone does not prove commit coordination.

Each candidate also requires actual `readEvent` and `previewEventOccurrences` authority. Mandatory timing/state and optional text disclosure use the intersection of both decisions. Denied objects or withheld mandatory groups produce no row; optional text can be withheld independently. Host requests carry immutable normalized criteria/groups and actual parent/event/current override state. Normalized options are in CalendarAuthorizationRequest.occurrenceListQuery with the cursor omitted; eventGroups includes mandatory timing/state as well as requested text. The query fieldGroups itself contains only the optional text selection. This profile reuses per-series preview authority; hosts must deny a series query if their mixed per-occurrence rules cannot safely be expressed through it.

Every page performs fresh authorization and verifies the trusted principal/scope/policy revision before returning. Coordinated and external fresh-check guarantees retain their declared meaning; a final context check cannot eliminate an external after-check revocation race. Querying uses validated current content, overrides and protocol state with aggregate work charging. Unused private historical import baselines are not reparsed for this ordinary read; source export/replacement operations keep their existing baseline validation and permissions.

## Ordering, bounds and cursor state

Ordering is effective UTC start (calendar-zone calculation for DATE), native event UUID, then canonical typed original identity. It is independent of hidden text and protocol UID. Each continuation recomputes the complete bounded authorized result and resumes after its exact saved key. If that key is no longer authorized, continuation rejects rather than retargeting it.

Hard/default limits are 366 elapsed days, at most 100 visible rows/page, 1,000 scanned active definitions, 100,000 aggregate candidate-work units and 10,000 materialized matching occurrences. Existing page/scan options and the new occurrence options can lower these bounds. Work includes raw timing/explicit inputs, recurrence validation/expansion, projected candidates and raw timezone-transition checks before filtering/deduplication. Cancelled matches consume the materialization cap. A query-local cache reuses identical immutable DATE coverage proofs; it never caches access decisions or supplies cross-process correctness.

DATE series/exception/range expansion and named-zone snapshots now accept optional shared work budgets; callers that omit them retain their existing behavior. The resolver also exposes opaque exact database/profile identity material. The module hashes that material once, storing only the digest in cursor state. No dependency or generated timezone payload was changed.

One nullable server-only `eventOccurrenceState` JSON column extends `CalendarCursorRecord`. Its version-1 state stores normalized window/cancellation options, last effective start/original key and exact timezone identity. Existing columns bind parent, principal, scope, data/policy revisions, groups, page size, last native event UUID and expiry. It stores no event text or private source snapshot. Other cursor families reject these tokens, and this API rejects ordinary/future/unknown/malformed state. Data, policy or timezone-identity changes require restart. Scope-generation fencing is deliberately coarse and can invalidate a page after unrelated native writes in the same scope.

Existing defaults remain 64 cursor rows per scope and a ten-minute database-clock lifetime, with bounded cleanup/admission. Upgrade preserves ordinary cursor rows with the new field absent and invents no occurrence state. The additive generated module/example migrations are `20261030180331863` and `20261030180336464`.

## Example and validation

The calendar editor opens **Calendar occurrences** with explicit UTC window inputs, cancellation selection, Apply/Refresh and Load more. Rows distinguish DATE/zone/original/moved/cancelled meaning. Input accepts explicit UTC ISO fields with whole seconds or zero fractions; nonzero fractions are rejected before Dart parsing can discard nanoseconds. Stale/denied continuations clear the displayed page and require refresh. No total or free-time conclusion is shown.

Focused temporal, database, upgrade, generated-client and Flutter checks are recorded in [the validation guide](scaffold-validation.md). They exercise interval/point/DST/profile edges, cancellation projections, inherited text, raw/aggregate caps, disclosure, cursor family/criteria/version/identity/expiry/revocation and multiple active hosts. Full batch checks follow focused development before a single implementation commit. This does not implement task/multi-calendar queries, an indexed large-calendar service, a reusable GUI package, new wire profiles or external-client compatibility.
