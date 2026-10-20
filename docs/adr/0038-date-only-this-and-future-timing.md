# ADR 0038: DATE-only THISANDFUTURE timing batch

Status: **THISANDFUTURE scope previously selected; native timing API and policies proposed for review; timed/task, service and wire behavior remain pending**. Date: 2026-10-20.

## Context and source boundary

The next implementation batch adds native DATE-only range timing over the single-occurrence values in [ADR 0037](0037-date-only-single-occurrence-exceptions.md). It covers anchor/shift values, subsequent timing and span application, preservation of separate exceptions, bounded overlap queries and validation. The maintainer requested successive feature batches with focused iteration and one check-in after each completed group.

[ADR 0010](0010-rfc5545-property-decisions.md#confirmed-batch-8) selects RANGE=THISANDFUTURE. RFC 5545 [section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) orders subsequent instances by original recurrence identity, applies a start difference and changed duration, and preserves separately defined instances. This increment implements only native DATE timing. It does not claim full range-edit interchange, scheduling or client compatibility.

## Native values and policies

`DateEventRangeChange(originalStart, replacement)` retains the original DATE anchor and a complete validated `DateEventSpan` at that anchor. Its signed `dayShift` is the difference from the original date to the replacement start. The replacement length and explicit-end/duration/default form apply to subsequent original occurrences. No recurrence filters, COUNT, UNTIL, RDATE or EXDATE values are rewritten.

`DateEventRangeSet(base, changes, ...)` layers timing changes over an immutable validated `DateEventExceptionSet`. Snapshot and sort changes by original anchor. Reject duplicate anchors and any anchor outside the effective native DTSTART/RRULE/RDATE minus EXDATE set. Earlier inclusions remain valid anchors. Reuse one shared bounded membership expansion for all range anchors, under the existing `maxValidationCandidateDays`, `maxValidationRuleOccurrences` and `maxValidationResults` names. The base's single exceptions have already been validated separately. `maxRangeChanges` checks combined raw range-input length before copying; zero permits none. Budgets are operation parameters, not semantic fields.

A range starts at its original anchor and stops before the next original anchor. Each anchor's shift is relative to its original date, not cumulative with earlier changes. A later native range governs its own segment. Separate single replacements/cancellations retain their own meaning, even if moved across an anchor in actual time. Reject a single exception and a range at the identical original anchor as ambiguous native input; callers must replace the old representation explicitly. These multiple-anchor/collision policies are native implementation proposals; imported component reconciliation remains separate.

## Bounded overlap algorithm

For each original-date segment, invert the nonempty half-open query by that segment's signed shift and positive calendar-day length. Intersect the resulting possible start range with the segment's original boundaries and the existing date profile. Combine the nonempty inverse ranges into one original-date envelope and expand recurrence once, sharing all query budgets. Intermediate original dates between inverse ranges consume capacity even when they are later filtered out. This conservative envelope can fail a practical budget on sparse, widely separated ranges; it never resets limits per segment or returns truncated success.

For each selected original start, find its active segment in original-date order. Suppress separately overridden targets before endpoint construction. Compute shifted integer start/end positions, filter non-overlap under that segment, then materialize complete supported spans using its preserved template form. Do not materialize unrelated overflowing endpoints merely because they fall in an envelope gap. Independently include overlapping single replacements; their effective span is not altered by a range.

Return immutable `DateEventOccurrence` values sorted by actual start then original date. Preserve distinct original identities sharing an actual start, and never clip or merge returned spans. A positive shift can bring an earlier original into the query; a negative shift can bring a later original into it. Range length changes also participate in inverse lookback.

## Limits and profile edges

Query budgets are positive `maxCandidateDays`, `maxRuleOccurrences`, `maxBaseOccurrences` and `maxResults`. The first three bound original recurrence history, raw rule output and selected base starts in the whole envelope, respectively. Base capacity is counted before segment filtering or single suppression; cancellation cannot bypass it. Final capacity includes all emitted base/range/single occurrences. Membership and query budgets are separate; trusted hosts must choose practical caps. Any invalid anchor, duplicate, limit or selected endpoint overflow fails without partial successful output.

All dates and effective exclusive ends remain within 0001–9999. Integer shifts/range bounds are computed before constructing dates, allowing valid inverse bounds near the profile ends. A selected unsupported end fails with `RangeError`; an unrelated future occurrence outside the query is not validated or silently clipped. Named-zone coverage remains 1900–2037 with narrower per-zone limits; the main README warning is unchanged.

## Alternatives and remaining work

Expanding and shifting only starts already in the actual query misses moved-in and long occurrences. Shifting rules or rebasing DTSTART changes original identity and cadence. Applying range changes to separate single exceptions violates their independent meaning. Independent per-range expansion would need shared work accounting; a single bounded envelope supplies that accounting now, at the cost of extra candidates in gaps.

This timing-only API does not represent range cancellation, THISANDPRIOR, arbitrary pattern/weekday edits, sparse descriptive changes, tasks, timed/PERIOD recurrence, UTC occupancy or complete availability. Revisions, transactions, booking/alarm invalidation, authorization, persistence, generated clients, parser/export and iTIP reconciliation remain required service/adapter work. None is implied by the native API or date-only tests.

## Validation and acceptance

Focused VM tests cover signed/unchanged shifts, month/year/leap boundaries, original ordering, multiple anchors, single-exception precedence, changes to length/form, original COUNT/UNTIL and exclusions, monthly invalid-date skipping, duplicate/orphan/collision rejection, shared validation/query budgets and profile-edge failures. A finite occupied-date oracle independently checks identity, actual span and ordering across mixed ranges, singles and query windows. At completion run formatting, workspace analysis and the complete core VM/Chrome suites once; record actual commands/results in [temporal core validation](../temporal-core.md#date-only-range-timing-batch-validation). Commit the completed batch together; broader API/protocol approval remains separate.
