# ADR 0189: Whole-series lifecycle with a published cutoff

Status: **Draft investigation; not approved for implementation.**

## Problem

The approved pure projection in [ADR 0188](0188-published-whole-series-lifecycle-with-active-range.md)
can construct a bounded finite-suffix REQUEST candidate, but does not establish
published history or delivery. Current v7 checkpoint validation requires an
active range control to have the `rangeCancel` publication kind and verifies
its exact CANCEL payload. Version 8 additionally binds exceptional-anchor proof
to that state. The current whole-series and reopening paths also reject active
range controls. Removing only the API guard would therefore invalidate or lose
the proof needed for later restoration.

## Proposed bounded direction

Allow an explicit whole-series CANCEL for an active published cutoff only after
proving that a later complete reopening can be represented by the approved
finite-suffix projection within current limits. Retain the last active published
REQUEST basis, original cutoff and range-control version, exceptional-anchor
proof where present, independent individual-cancellation state, and private
native drafts. Reject unbounded, unproved, unsupported or over-budget cases
before committing. This does not widen ADR 0188 to unbounded series.

For explicit reopening, construct one complete REQUEST from that retained
published basis, add the finite suffix masks and existing module-owned individual
masks with distinct provenance, omit suppressed occurrence components, and
advance actual outgoing versions beyond applicable prior CANCEL and component
floors. It must not restore the suffix or publish a newer native draft. Ordinary
source EXDATEs remain separate. A later explicit range restoration must remove
only the suffix masks while retaining individual masks and source exclusions;
it must use the preserved active basis and keep the existing native cutoff
ownership/revision checks. No assumption is made that a recipient has deleted
old exceptions or applied any message.

## Decisions and proof still needed

The durable contract must specify a bounded, self-contained checkpoint that
distinguishes the active range's CANCEL, whole-series CANCEL, masked reopening
and subsequent range restore, including old v7/v8 reads and exceptional-anchor
proof. A single frozen predecessor may be a candidate; its size, permitted
versions, validation and prevention of recursive history must be made explicit
before selecting it. Existing payload/slot/work/retention limits cannot be
silently widened, and pruning must not destroy the only restoration proof.

The existing reply-target path checks membership in `publication.wire.content`
when classifying a range-cancelled original. A reopened REQUEST with generated
suffix EXDATEs can make that membership check fail even for an original known
to the retained unmasked basis. A future implementation must use validated
retained membership evidence for this state while preserving source exclusions;
it must not regard a generated mask as proof that an arbitrary original exists.
This observation is an implementation constraint, not a completed reply change.

One candidate for review is a version-9 envelope in the existing bounded
snapshot columns with a single immutable predecessor containing an actual,
validated active v7 or v8 range-CANCEL record, and separate current whole-series
kind, actual payload/projection, version ledger, mask manifest and native
comparison. The predecessor may not itself be v9; all predecessor bytes,
including any v8 proof, count against the existing 512 KiB bound. This would
permit bounded repeated whole-cancel/reopen transitions without recursively
embedding successive envelopes, but only if each reader can reconstruct and
compare the exact payload, masks, versions, identity and original basis. A
prototype must demonstrate that all currently supported v7/v8 states fit or
reject explicitly; no capacity increase or historical-proof deletion follows.

For an initial serialized workflow, require prior deliveries to be terminal
before a new whole-series cancellation, reopening or later range restoration.
This proposed restriction is stronger than the existing ordinary whole-series
supersession policy. It avoids introducing an ordered multi-message transport
group and keeps uncertain earlier sends from being silently superseded. Exact
retained command retries remain available after fresh authorization without
reapplying native edits. A current-state no-op must still verify the revision,
source proof and action authority. New complete/partial publication while the
cutoff is active stays blocked in this first profile.

The proposed whole CANCEL sequence must exceed the active cutoff, retained
master and component/individual versions, and current/final native protocol
floors. A reopening master and every emitted component must exceed the whole
CANCEL and relevant prior component floors; later range restoration must exceed
both the reopening's actual versions and the original cutoff. Use the existing
nondecreasing whole-second database stamp and fail atomically on overflow. These
are conservative application rules, not general RFC requirements.

Native cutoff ownership needs an explicit transition rule: rebind an owned
cutoff to a new revision only when the immediately preceding revision and
canonical key match the saved ownership evidence and the transaction's own
only native difference is the authorized master-status change. Otherwise retain
the old evidence without claiming ownership of later edits. Restoration clears
the native cutoff only when the resulting saved ownership still exactly matches;
a private intervening edit or replacement remains untouched.

Specify exact component-version and stamp floors, published reply-target
invalidation and restoration, final complete-message host approval, independent
action/lifecycle/full-read authority, actor-free dispatch rechecks, transaction
fences, pending-delivery supersession and stable retained retries. The v7/v8
readers' active-kind and payload invariants must not be weakened for legacy
records. Failure to reconstruct or authorize the exact projection must fail
closed without mutating drafts, native flags, generation or deliveries.

The first profile should continue to guard unrelated partial and overlapping
commands while the suffix is active. Whether complete REQUESTs after reopening
can safely update that basis without losing mask provenance needs an explicit
composition contract. Real mail and external-client compatibility remain
separate.

## Review and validation before implementation

Complete the checkpoint, transition and version contract and obtain explicit
maintainer agreement. Test normal and exceptional anchors, individually
cancelled originals, source EXDATEs, COUNT/UNTIL and exhaustion, DATE/UTC/exact
zones and DST, stale/private native edits, malformed proof, caps and overflow,
pruning, retained retries, two-host races and worker loss around each commit.
Exercise generated-client/Flutter and synthetic transport journeys separately
from pure wire and external-client evidence.
