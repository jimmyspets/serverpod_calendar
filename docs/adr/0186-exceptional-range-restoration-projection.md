# ADR 0186: Pure restoration projection for exceptional range anchors

Status: **Accepted by explicit maintainer agreement; the bounded pure implementation and focused/batch unit validation are complete.** Full exact-commit hosted validation remains separate. This is not a durable cancellation or transport change.

## Problem and evidence

[ADR 0172](0172-durable-published-range-controls.md) rejects an anchor with a published single override or individual cancellation; the existing helper also rejects a PERIOD anchor without an active range. These guards prevent a restored exceptional duration or moved start from being applied to the whole suffix. See [the investigation](../range-anchor-restoration-investigation.md).

[RFC 5545 section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) orders subsequent instances by original RECURRENCE-ID, describes the range shift and duration effect, and says separately defined instances are not affected. [RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) specifies range cancellation. The projection and rejection policies below are application choices, not claims of universal client behavior.

## Proposed bounded pure batch

Add a pure candidate builder for the already published, unmasked REQUEST basis and one exact original anchor. It must validate the complete basis, anchor membership, DATE/UTC/exact named-zone profile, fixed organizer/attendee claims, retained identities and the existing shared work/64-original/byte limits. Its inputs and output prove neither host authority nor a real previous cancellation. It changes no stored/native state, endpoint, worker, authorization, schema, or delivery.

For an anchor with an active published single override, keep its effective published timing and selected content as a single component. Find the next valid original in original-identity order, respecting exclusions, additions and recurrence-generated DST gaps. If there is one, construct the earliest faithfully representable future projection there from the underlying series/range state, preserving later explicit exceptions and their independent content and duration. Do not derive the suffix from the moved anchor. A retained future component at that next original is reused only if the complete resulting candidate has identical effective published timing and content; otherwise reject explicitly. PERIOD occurrences keep their individual end/duration forms through finite explicit projections, within the same slot limit.

If the anchor is the last provable original, retain the single without inventing a future component. If exhaustion, the supported horizon, or the budget cannot establish whether another original exists, fail closed rather than claiming it is the last. A separately cancelled anchor remains cancelled: omit its active projection and retain the existing cancellation/exclusion representation, while restoring later active originals. Never erase or retarget an individual cancellation. Any collision, unsupported profile or inability to prove an equivalent result rejects the whole candidate.

Require validation of the resulting REQUEST using the existing scheduling and native projection profiles, including exact original membership, component identities, inherited fields, PERIODs, exclusive ends and named-zone rules. Compare the candidate against the retained published basis over every affected segment and finite exception using shared bounded work. An unbounded rule must be proven symbolically or rejected; it must never be truncated or enumerated as if complete. Source/native versions and inheritance are not changed by a pure candidate, and a wire-valid candidate does not itself prove that a remote client deletes an exception.

## Test and delivery gate

Test moved/lengthened/content-overridden singles, individually cancelled anchors, ordinary and already-ranged next originals, collisions, moved exceptions crossing the anchor, finite last originals, unbounded rules, inclusion/exclusion/PERIOD dates, DATE/UTC/zones/DST, horizon boundaries and shared-work/slot exhaustion. Assert the complete effective values before and after projection, not just component counts. Run focused VM tests while developing and the affected pure VM/Chrome suites at batch end.

Durable cancel/restore admission, published component versions, retained checkpoints, current-authority checks, retries, native cutoff cleanup, example UI, actual delivery and external interoperability remain guarded until a separate concrete contract is approved. If faithful representation cannot be proved for a case, rejection remains valid and explicit.
