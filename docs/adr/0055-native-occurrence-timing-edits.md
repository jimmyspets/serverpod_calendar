# ADR 0055: Native single and future occurrence timing edits

Status: **Accepted timing-only/single-cancellation batch, override preservation and deferred future cancellation; implementation mechanics under review**. Date: 2026-10-21.

## Confirmed scope and sources

The maintainer selected moving/resizing one occurrence or this-and-future, plus cancelling/restoring one occurrence. Summary, description, location, series status and transparency stay on the master; per-occurrence content overrides follow separately. Preserve existing overrides through master edits, rejecting orphaned/incompatible targets until the relevant override is explicitly removed. Future cancellation/reopening is deferred.

This extends [ADR 0054](0054-native-event-recurrence-and-previews.md) using the pure-core timing policies of ADRs 0037/0038/0040 under the whole-second [1970,2100) profile of ADR 0041. [RFC 5545 recurrence identity/ranges](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) inform original-order and separate-instance semantics; native timing APIs and tests are not ICS parsing/export or scheduling evidence.

## Storage/API proposal

Add nullable typed JSON `timingOverrides` to the active event-data row, separate from ordinary master content. Null represents no overrides; existing rows migrate to null without rewriting content/UID/revision/time. The event identity and minimal deletion marker remain unchanged; deleting active data also scrubs overrides. No occurrence materialization table or process-local cache is introduced.

`CalendarEventTimingOverrides` contains sorted immutable lists of `CalendarEventSingleOverride` and `CalendarEventFutureOverride`, capped at 128 combined raw entries. Anchors are start-only `CalendarEventTiming` in the exact master kind/zone profile. Every anchor must belong to the effective DTSTART/RRULE/RDATE minus EXDATE set; reject duplicates, orphan/excluded anchors and single/future collisions at the same anchor. Earlier inclusions are valid targets. Full replacement timings retain end/duration/omitted forms and cannot change profile. No arbitrary future pattern rewrite, range cancellation or per-instance content/status/transparency field is added.

Single timing replaces one occurrence while preserving its original identity. A single's cancellation flag is independent of its optional retained timing: cancellation hides the occurrence without erasing its timing, restoration reveals that timing (or inherited timing), and clearing timing does not restore a cancelled occurrence. Drop an empty uncancelled single record. Single replacements/cancellations remain independent of future ranges. A future change applies its original-relative civil shift and span to originals from its anchor until a later range anchor; later ranges replace, not accumulate, the shift. Removing a range reveals the preceding range/master behavior. Same-anchor mode changes require explicitly clearing the conflicting representation first.

Use dedicated `changeOccurrence` with event UUID, expected event revision, start-only original anchor, action and replacement only for timing-replacement actions. Actions are replace/clear single timing, cancel/restore single, and replace/clear future timing. Ordinary master updates preserve/revalidate stored overrides even when explicit recurrence dates are deliberately replaced; no bulk clear flag can bypass this. Full content edits cannot clear override state because it is outside the master DTO.

## Authorization and transactions

Reuse `updateEvent` for timing changes/clears and `changeEventStatus` for single cancellation/restoration. Hosts receive immutable actual parent/event snapshots including current overrides, exact `occurrenceChange` action/anchor/replacement, and the validated `proposedTimingOverrides` at final checks. Preliminary checks carry intent before target-specific validation; null proposed state at that phase is not evidence of clearing. Hosts can distinguish whole-master, single and future scope without a required ownership model. No event-read grant is implied by mutation rights; receipt disclosure remains independently enforced.

All changes use the existing durable scope transaction, stale-revision rejection, final host checks and scope-generation bump across instances. Advance event revision/shared-database modification time, retain UID, and leave parent metadata time unchanged. Whole-series cancellation remains a separate master lifecycle action; restoring a single cannot reopen a cancelled master. The demo private-policy epoch becomes v7, still only a fresh-check example. No scheduling message, alarm worker or availability result is produced.

## Calculation limits and queries

Timing-group disclosure controls stored overrides as well as master timing/recurrence. Existing preview read/preview permissions and saved-revision checks apply. Previews return effective spans with original identities, omit individually cancelled occurrences, preserve moved-in/out and lengthened overlaps, and do not merge equal actual starts. A cancelled master can still have a detail preview; geometry does not establish booking status or free time.

Retain existing preview caps: 366 query days, 200000 candidate work, 10000 raw/base occurrences and 500 results. Membership validation is bounded separately from query work: DATE validates single and future sets in at most two passes, each with 200000 candidate days and 10000 occurrences; timed validates all anchors in one pass with the corresponding caps. These are fixed passes, never a reset per anchor. Every set has at most 128 total overrides. Widely separated targets/history or inverse query envelopes can reject even small results. Failure returns no partial preview or mutation. Reads validate/freeze stored state; there is no cache that bypasses guards.

## Alternatives, UI and acceptance

Putting override lists into the replaceable master command risks accidental clearing and lifecycle bypass. Persisting every occurrence loses recurrence meaning. Separate timing/cancellation state preserves intentional timing through lifecycle actions without per-occurrence text snapshots. Pattern changes reject incompatible/orphaned retained edits rather than guessing a new identity.

The example previews saved data, moves/resizes one/future occurrences, cancels/restores singles and explicitly clears timing overrides. Stale editor drafts remain visible without rebasing; close and reload saved series to retry. Timed explicit ends require user-entered civil fields instead of guessed zone conversion; DATE ends come from the preview. Re-read the event after returning to the master editor so subsequent status actions use the current revision.

Validate DTO/profile/original membership/caps, independent cancellation/timing, single precedence and absolute ranges, immutable policy intent/proposals, separate permissions, stale/final-denied/post-write rollback, orphaning master rejection, deletion and populated migration. Extend real two-host/generated-client races and Flutter stale/move/future/cancel/restore/clear journeys. Run focused tests while developing and broader checks only after the batch; record actual results in [validation](../scaffold-validation.md).

## Scoped supersession, 2026-10-24

[ADR 0106](0106-single-event-content-overrides.md) now adds selected event occurrence text/annotations and anchor-only content with timing inheritance and lossy-export rejection. It supersedes the earlier text-difference rejection/pending notes only for that scope. The private event-source-v2 baseline rejects older imported v1 data explicitly; no automatic reset/adoption occurs. The earlier timing, lifecycle and unsupported-feature boundaries otherwise remain in force.
