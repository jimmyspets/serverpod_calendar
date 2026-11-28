# ADR 0157: Pure event future-cancellation cutoff

Status: **Proposed; cancel-all/preserve-exceptions policy is confirmed. Concrete core APIs and validation mechanics await explicit approval.**

## Context and inspected evidence

ADR 0156 implements explicit range REQUEST application and canonical master composition; range CANCEL remains review-only. The maintainer selected cancellation of every original from the anchor onward, including later moved/edited exceptions, while retaining timing/content for a later explicit restoration. This policy alone does not approve persistence or reconciliation mechanics.

Inspected `DateEventRangeSet`, `DateEventExceptionSet`, `TimedEventSeries`, `TimedValue.compareTo`, membership/work budgets and the native future-override carrier. Existing timing ranges preserve singles and have no cancellation cutoff. A bounded pure cancellation layer is the next prerequisite before durable state, workers, queries or publication change.

[RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) describes THISANDFUTURE cancellation of the specified instance and later instances. [RFC 5545 section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) orders instances by original RECURRENCE-ID and discusses separately defined components under rescheduling. Our cancel-all policy is explicit; do not substitute timing-range single-exception precedence for cancellation or claim external-client behavior from pure tests.

## Proposed grouped core increment

Add optional immutable `cancelledFrom` original identity to `DateEventRangeSet` (`CalendarDate?`) and `TimedEventSeries` (`TimedValue?`). Omitted values preserve existing behavior. This is one effective open-ended cutoff, not a source-message ledger or restoration history.

Require an ordinary supported value and exact membership in the effective DTSTART/RRULE/RDATE/PERIOD minus EXDATE recurrence set. Timed values require the same exact UTC/named-zone profile. Membership uses the original recurrence set, so individually cancelled originals remain valid anchors. Excluded/orphaned/foreign-profile/exclusive-end anchors reject.

Active expansion suppresses every original greater than or equal to the cutoff. DATE uses original date order; timed values use original civil order within the exact profile, never actual moved starts or resolved instant order. Filter generated occurrences and explicit replacements, including moved-in singles. Later timing ranges and separate exceptions never reopen the cancelled suffix. Earlier originals moved after the cutoff remain eligible; later originals moved before it remain suppressed.

Retain the complete immutable recurrence, timing ranges and singles. The cutoff may coincide with a single or timing-range anchor because cancellation is a separate lifecycle dimension. Existing single-versus-timing-range collision rules stay unchanged. Do not rewrite COUNT/UNTIL, append EXDATEs, synthesize individual cancellations or remove PERIODs/replacements. The core has no content to edit; later module integration must retain content separately.

Reconstructing the same pure series without the cutoff recovers its previous active timing projection, including pre-existing single cancellations. This value property is not a native restoration command, scheduling reopening, alarm reset or permission to replay reminders. Multiple accepted cancellation notices and partial restoration need later durable review; their distinct identities must not be discarded merely because their active union can use an earliest cutoff.

## Bounds and failures

Count a non-null cutoff as one change against DATE `maxRangeChanges` or timed `maxChanges`, even at an existing anchor. Charge before membership deduplication; zero capacity rejects it. DATE single-exception capacity remains separately enforced by the base set. Validate membership with existing local caps and aggregate `RecurrenceWorkBudget`; same-anchor membership may be shared without refunding consumed work.

Keep expansion work/raw-rule/base-occurrence caps and complete-or-failure behavior. Cancelled candidates do not consume final active-result capacity, but cancellation must not bypass raw/history/candidate/base checks. Validate retained changes and input/query budgets even when all results are suppressed. Filter cancelled originals before materializing their shifted spans so irrelevant cancelled projections need not overflow endpoints; construction still validates every supplied replacement. Add no optimization, partial-success result, cache, pagination or horizon expansion.

Include the cutoff in DATE equality/hash semantics. Keep collection immutability, whole-second `[1970-01-01, 2100-01-01)` limits, explicit endpoint rules, DST resolution and active timing precedence.

## Boundaries and follow-up

This batch changes only pure event core, tests and documentation. No Serverpod model, SQL, generated client, endpoint, source checkpoint, free/busy service, feed, alarm plan or Flutter action changes. Durable range CANCEL guards remain. Tasks and availability openings gain no cancellation capability through this increment.

Following work must review durable cancellation identities/versions, complete cancellation-aware views, authority/context, clean-baseline source application/master composition, wire/feed representability, alarm invalidation, exact retries and two-host recovery. Restoration remains explicit and separately reviewed; a newer timing change must never silently restore a cancelled original. Organizer outgoing cancellation and attendee range replies remain separate requirements.

## Alternatives and consequences

A cancellation flag on timing changes mixes lifecycle with timing and risks later timing changes reopening the suffix. Materializing future singles is unbounded. Truncating recurrence discards originals and complicates restoration. An independent cutoff establishes bounded semantics while retaining all timing data, but later adapters must still preserve independent source identities and versions.

## Acceptance conditions

After explicit maintainer agreement, implement DATE and UTC/named-zone behavior together. Test inclusive cutoff, moved earlier/later originals, singles/later ranges, same-anchor coexistence, existing single cancellation, earlier RDATE/PERIOD, EXDATE/orphan/profile rejection, DST gaps/folds and supported horizon boundaries. Verify reconstruction without a cutoff, immutability/equality, change/work/raw/base/result limits, shared budgets, unchanged no-cutoff results and no partial output. Include an independently calculated finite expected-occurrence oracle.

Use focused core VM tests during development; at batch completion run formatting/workspace analysis, complete core/iCalendar VM+Chrome and directly affected module regressions. Full repository CI remains required before readiness. Record actual/deferred checks and commit only the completed batch. Approval enables only these pure mechanics, not later persistence, restoration, reconciliation or publication designs.
