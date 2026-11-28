# ADR 0168: Range REQUEST application after source restoration

Status: **Proposed. The maintainer confirmed that a new THISANDFUTURE timing update must have SEQUENCE greater than both the effective anchor component and the historical restoration. The v11, authority, retry and composition mechanics below require explicit agreement before implementation.**

## Context and bounded scope

[ADR 0167](0167-single-instance-applications-after-source-range-restoration.md), implemented in PR #165, permits explicit single REQUEST/CANCEL after restoration with current v10 targets beside unchanged historical proof. Its recorded local grouped, two-host, client/feed and Flutter checks passed; implementation-head hosted CI remains separate. New range source applications still reject.

Next permit explicit RANGE=THISANDFUTURE REQUEST through existing range preview/apply APIs after verified v7/v8/v9/v10 restoration history, with continued range/single commands and master composition/lifecycle. Require an active accepted master, absent native cutoff and a clean complete accepted native series. Receiving/reviewing a source changes nothing and sends no reply. New range CANCEL, another source cancellation/restoration cycle, range replies, overwrite/merge and real mail remain separate.

Reuse the existing pure range REQUEST projection and its bounded wire profile: timing propagates using the established original-relative civil shift and replacement end/duration policy; supported content differences remain local to the anchor. Preserve later independent single/future components, individual cancellations, independent protocol versions and source omissions. A later range replaces the active shift rather than compounding it. Exact DATE/UTC/named-zone profile and original recurrence membership remain mandatory, including PERIOD/exclusion/DST rules. Reject a same-anchor single/range collision rather than deleting or retargeting either component.

## Confirmed source-version policy

For a new post-restoration range REQUEST, require explicit incoming SEQUENCE strictly greater than both the effective canonical component at the anchor and the independently retained historical restoration SEQUENCE. Resolve the effective component by exact single, then applicable range, then master. Missing retained sequence compares as zero without rewriting its omission. Equal sequence with a later DTSTAMP cannot waive either strict sequence floor; no implicit increment is allocated, and maximum exhaustion rejects atomically.

This is a conservative application policy selected by the maintainer, not a universal RFC requirement. It differs from ADR 0167's single-message freshness, which can accept a sequence below the historical restoration when fresh for its effective component. Later exceptions retain their own versions and are not rewritten merely to satisfy the new range's floors. Whole-master CANCEL retains its separately approved floor over current master, all canonical components and both historical cancellation/restoration versions.

## Existing-table v11 checkpoint

Extend the current target representation with v11 in the existing JSON column. Keep the same one frozen v7 acceptance/baseline/nullable-master descriptor; do not wrap v8/v9/v10/v11 or add another complete historical snapshot. Preserve strict legacy v1-v10 reads and their retained receipts before a new range commits; never upgrade on read.

Use explicit single-versus-range latest-target keys, source-kind/target checks and distinct v11 composition/receipt digest namespaces. A range latest target must be an exact validated THISANDFUTURE REQUEST; do not infer it from a marker alone. Validate original/source method/UID/participant/profile/version/body digest and canonical component bindings separately from historical replay and current master kind/status/composition. Continue validating adoption when no master-application row exists. Provisional previews carry the explicit proposed master kind rather than inventing a row or using a default kind for a cancellation candidate.

Replacing a current range descriptor replaces that target in place; unrelated targets and independent versions remain. Preserve the original restoration/cancellation source evidence separately from the latest receipt. Any additional source-floor evidence must be derived from validated current/frozen data, not a new client-claimed baseline or trusted timestamp. Missing/contradictory/tampered bindings, unknown formats and nesting fail unavailable without flattening or fallback.

Later single commands after v11 retain v11 and their ADR 0167 freshness rules. Master REQUEST/CANCEL/reopening also retain v11, the current target ledger, clear cutoff and individual cancellations. Recompose against the verified current master and reject recurrence/profile changes that orphan a current target or the historical restoration original. Never reinstate the old cutoff because the latest target now names a range.

Keep existing 4 MiB/link, 16 MiB/recipient and 64 MiB/scope hard ceilings and configurable lower limits; count all historical/current duplication. Current targets plus one retained range-history slot must remain within 128. Existing source/work limits and private deletion scrubbing apply. Reject capacity failures without dropping proof or raising caps. No SQL/table/column, generated model/endpoint signature, dependency or retention expansion is proposed.

## Authority, views and atomicity

Require existing independent readRangeApplication/applyRangeUpdate, source/summary/link/application/raw detail and native import/replacement/update rights, plus accepted-occurrence/cancellation/restoration composition authority when accepting or composing the new state. Lifecycle rights remain independently required where an actual lifecycle change participates. Preserve prior restoration retry authorization before any new range commits, as ADR 0167 does for legacy receipts. Authorize real historical/current source IDs and bodies after ordinary queue pruning; private evidence and participant claims grant no authority.

Protected previews check both strict sequence floors, actual eligibility and applicable rights without mutation. Existing incoming/accepted version fields retain their established meanings; do not relabel historical restoration as a canonical component version to fit the response. Reuse existing history flags and range Flutter controls, explaining the stricter range policy without adding a response field. Actual commands recheck preliminary/final immutable current/proposed event, complete override state and checkpoint context under the host's declared consistency guarantee.

Fence actual event/calendar/master/source/checkpoint revisions. Atomically write the range projection, ordinary cutoff-free baseline, v11 acceptance and selected notice dismissal; advance revisions/audit state and invalidate scope/feed/alarm generations and leases once. Keep parent metadata time, personal definitions/actions and accepted-firing deduplication independent. Preserve existing export/feed representability checks, continuing authorization and no-stale-304 behavior; never strip unsupported state to manufacture output. Source alarms stay unarmed and no participation message is sent.

## Latest-only receipts and races

Reuse the maintainer-confirmed latest-only occurrence slot: the new range command supersedes a prior restoration, single or range command receipt while retaining required private proof. Exact current retries reauthorize and return their original result without touching later drafts/notices/generations. Superseded occurrence commands reject without reapplication. Master changes preserve the latest occurrence receipt; the separate latest-master receipt retains its current behavior.

Same-command competitors must converge on one receipt; competing single/range/master commands must respect the actual revision fence, without silent rebase. Process loss before/after commit must expose no partial native/checkpoint/source state and recovery cannot duplicate a transition.

## Alternatives and consequences

Keeping the current guard leaves selected range reconciliation incomplete. Effective-component-only freshness would accept some messages older than the restoration; the maintainer selected both strict floors instead, accepting that additional sender-compatibility limit. Rewriting later exceptions or flattening recurrence would violate confirmed preservation. Nesting whole checkpoints would accumulate private content; replacing current descriptors beside one frozen proof preserves a fixed storage boundary.

## Validation and acceptance

After explicit approval cover direct v7/v8/v9 and current v10 to v11, continuing single/range/master lifecycle, DATE/UTC/named zones/DST, PERIOD originals, unchanged later exceptions/versions and exact original/profile/orphan protection. Test each floor independently: below/equal/above effective and historical versions, later timestamp with equal sequence, missing sequence, zero/maximum bounds, and the contrasting retained single freshness policy.

Cover read/preliminary/final/native/action/composition authority, legacy retry permissions, latest-only supersession and current retries after drafts/newer notices, every frozen/current/kind/range-key/source/receipt binding, unknown/nested formats, byte/work/slot limits, pruning/deletion and unchanged old reads. Exercise actual two-host same/competing single-range-master commands, atomic visibility and process loss before/after commit; generated clients/Flutter; busy/query/feed validators and reminder suppression/actions/deduplication. Use focused tests during development, grouped checks before one complete-batch code commit and full implementation-head repository CI before readiness.
