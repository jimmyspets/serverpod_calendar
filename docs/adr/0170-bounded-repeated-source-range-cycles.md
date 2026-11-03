# ADR 0170: Bounded repeated source range cycles

Status: **Proposed.** This groups authenticated re-cancellation, restore-only acceptance and continued composition/lifecycle into one reviewable feature batch. Existing storage/authority/retention constraints remain; the v12 mechanics and derived view fields below require explicit agreement.

## Context and scope

[ADR 0169](0169-pure-range-cancellation-after-source-restoration.md), implemented in PR #170, supplies the pure re-cancellation/version prerequisite and repeated pure round trips. Authenticated second cancellations remain guarded. Instead of separate reviews for each subsequent state transition, implement a bounded repeating cycle and its master/single/range integration together.

Permit a new explicit range CANCEL after verified restored v7/v8/v9/v10/v11 history, then explicit same-cutoff restore-only REQUEST, followed by further cycles. Preserve the full accepted history under existing hard limits. Use existing range preview/apply/restoration endpoints; receipt remains review-only and sends nothing. An active accepted master, clean complete series and correct exact original/source/revisions are mandatory. Overlapping active cutoffs, partial suffix restoration, restore-plus-reschedule, outgoing range messages, RANGE participation replies and real transport remain separate.

## Current state and cycle semantics

At most one accepted source cutoff is active. A new CANCEL may name any exact current original, independently of earlier cycle anchors. Reject a new cancellation while a source cutoff is active, while the master is cancelled, or after local divergence. Apply the confirmed cancel-all policy, preserving all canonical timing/content/inheritance, individual flags, unarmed alarms and component versions.

Restore only the active cycle: the REQUEST must name its exact cutoff and match current retained uncancelled timing/content under the existing pure restore profile. A master change accepted while masked can change these retained values; restoration therefore matches the current clean composition, not an invented historical copy. Clearing the whole active cutoff preserves individual cancellations. Neither source control rewrites canonical component versions or creates a canonical range component.

After restoration, single REQUEST/CANCEL and range REQUEST application continue under their approved freshness/profile rules. While a cutoff is active, new single/range source applications remain blocked, including before its anchor; no parallel partial application policy is introduced. Master REQUEST, whole CANCEL and reopening remain available with existing clean-state/lifecycle protections, preserving the active cutoff or restored state. A whole-cancelled master must reopen before a source restoration.

Master composition must retain exact kind/zone/profile and membership for every retained current target and every historical cycle anchor, including the original legacy restoration. Reject orphaning edits until a separately reviewed reconciliation/purge policy exists. Native local edits remain possible but dirty the accepted state; no source operation silently overwrites them.

## Sequence policy

For a new cycle use the approved pure re-cancellation helper with the latest verified restoration version. Require explicit CANCEL sequence above both that version and the affected canonical floor, including the underlying segment beneath an anchor single. Later restore-only REQUEST requires advancement above that cycle's cancellation and the current affected canonical floor. The validated history chain must therefore advance control versions strictly; equal sequence plus a newer timestamp never waives a floor.

Subsequent range REQUEST requires advancement above its effective canonical component and the latest verified restoration. Single commands keep effective-component freshness and may be below historical control versions. Whole-master CANCEL keeps the conservative floor over current master, canonical components and all retained cancellation/restoration controls. Preserve source timestamp corrections and optional omissions exactly, independently of native revisions/audit time. Exhaustion rejects atomically without allocating a source version. These are application policies, not universal RFC requirements.

## Flat existing-table v12 history

Reuse the private per-link checkpoint JSON column; add no SQL table/column. On the first new cancellation upgrade verified v7-v11 to v12. Retain one unchanged legacy frozen v7 acceptance/baseline/nullable-master descriptor, as existing v8-v11 composition does. Direct v7 entry freezes it once. Legacy v1-v11 readers/retained retries stay strict and never upgrade on read; the first-cycle v1-v3 path remains unchanged.

V12 separates current master kind/baseline, current typed canonical targets, expected native state and latest occurrence command from a flat append-only cycles array. Each new record has a deterministic private cycle key bound to the link and accepted cancellation source identity, its exact original, and typed cancellation evidence. A restored record also has restoration evidence. Preserve actual invitation/source IDs, normalized source text/digest, independently optional version fields, acceptance revision/time and validated comparison/basis/candidate bindings.

Capture a standalone cutoff-free accepted composition at each control acceptance: cancellationBasis and, when closed, restorationBasis. A basis includes its canonical baseline, then-current nullable master descriptor and canonical target/source descriptors sufficient for independent bounded reconstruction. A later master change can make the restoration basis differ from the cancellation basis; keep both when necessary. Count every persisted copy in byte limits. Superseded source content can remain private until event deletion, matching existing frozen-proof retention.

Do not store a v12/v11 checkpoint inside another cycle, copy the growing cycles array into a basis, or recursively wrap previous checkpoints. The unchanged legacy descriptor is the only old-format root. New cycle evidence contains explicit validated values and source descriptors, not nested history. It must be possible to validate each acceptance against its own recorded basis and predecessor restoration version while separately validating the current composition.

Bind root/history/current/receipt data with distinct v12 digest namespaces, actual scope/link/calendar/event/UID/organizer identities, typed target and operation, and source/body/basis/version/revision/time checks. Recompute historical pure candidates and comparison floors; do not trust stored scalar floors or hashes as substitutes for semantic validation. Validate current targets through their source/component bindings, including post-restoration range floor evidence. Reject unknown keys/formats, nested checkpoints, duplicate cycle keys, missing proof, broken links, contradictory kind/status/cutoff or tampered receipt/source/basis bindings without fallback.

An explicit private active-cycle reference must identify only the final unclosed record. No active cycle means a clear accepted cutoff; history flags never determine current masking. Current ordinary import baselines remain cutoff-free. Historical records may show a prior native cutoff only through their distinct validated expected-native binding.

## Limits and deletion

Do not increase the 4 MiB/link, 16 MiB/recipient or 64 MiB/scope hard ceilings or host-configurable lower limits. Current canonical targets plus one legacy history slot plus one slot per additional cycle must fit the existing 128-slot cap. Opening and closing a cycle use the same history slot; all duplicated bases/source strings still count in UTF-8 byte budgets. Reject capacity exhaustion before any write. No old evidence is automatically dropped, compacted, replaced or retargeted to admit another cycle; a future retention/adoption policy needs separate review.

Charge bounded shared raw work for the complete root, every historical record/source and current reconstruction before filtering or deduplication. Do not restart independent recurrence budgets to bypass aggregate limits. Excess history/work is unavailable/limited, not partial success. Validate the complete proposed checkpoint under the same aggregate read/reconstruction limits before committing, including all old evidence; never persist a newly accepted state that already exceeds those limits. Pruning ordinary inbox bodies must not remove required private proof. Event deletion scrubs the entire active checkpoint; no cycle archive/restore feature or retention expansion follows.

## Authority and view contract

Reuse independent applyRangeCancellation/applyRangeRestoration, range/restoration reads, source/summary/link/application/full native disclosure, native import/replacement/update/lifecycle, composeAcceptedOccurrences, composeAcceptedRangeCancellation and composeAcceptedRangeRestoration rights as applicable. No new role scheme or weaker fallback. Historical/current source checks use actual IDs and bodies even after inbox pruning; private claims/evidence grant no authority. Recheck complete immutable current/proposed native and checkpoint context at preliminary/final phases under the declared host consistency guarantee. Pure prior-version arguments come only from verified stored history in the durable path.

Keep existing hasAcceptedRangeCancellation and hasAcceptedRangeRestoration as history flags. Add one derived protected hasActiveAcceptedRangeCancellation boolean to both occurrence-application and master-application views, default false in the DTO source but explicitly computed by the service. For verified legacy masked v4-v6 it is true; restored v7-v11 false; v12 derives it from validated active-cycle evidence. It describes an accepted suffix, not whether the master is active or whether a native local cutoff/dirty state exists. Compute/disclose only with existing actual-source/raw-read authority; it never authorizes a write. Unavailable or denied required proof must not become an inactive false flag; fail under the existing protected read policy. No count or historical body list is added to ordinary views.

Reuse existing explicit Flutter actions, explain history versus active accepted cutoff, and keep the same request object across uncertain responses. Regenerate DTO/client/test tools using CLI 4.1.0 after approval; no endpoint signature or SQL migration change is expected. UI flags cannot replace fresh canApply checks.

## Receipts, atomicity and recovery

Use one latest-only occurrence-command slot across canonical singles/ranges and all cycle controls, with a typed operation/layer/source/cycle binding. A new accepted command supersedes the prior occurrence receipt while preserving required proof. Matching only an anchor or invitation entry is insufficient. Master composition/lifecycle preserves the latest occurrence receipt and retains its separate latest-master slot. Older superseded commands reject; exact current retries reauthorize and return their original result without reapplying over drafts or newer notices. Historical evidence is not an active retry receipt.

Fence actual parent/event/master/source/checkpoint revisions. Commit candidate content/cutoff, cutoff-free baseline, cycle/current/receipt state, selected notice dismissal, native revision/audit and scope/feed/alarm invalidation atomically once. Keep parent metadata time, personal alarm definitions/actions and accepted-firing deduplication independent. Existing representability/revocation checks remain, including no stale 304 for masked states. Imported alarms stay unarmed, and restoring does not replay already accepted reminders.

Same-command competitors converge on one record/receipt. Competing control/master/canonical operations use the actual revision fence without silent rebase. Before/after-commit process loss cannot expose partial cycle/native state or duplicate a transition. Worker/source checks must observe the current accepted suffix, cancellation/completion, generation, access and expiry on every dispatch/retry.

## Alternatives and consequences

Keeping guards leaves repeated cycles incomplete. Dropping old evidence would change approved history retention and weaken reconstruction; recursively copying checkpoints grows depth and repeats growing history. A flat append-only history preserves proof with a fixed structural boundary, at the cost of eventual capacity rejection and bounded replay work. Accepting arbitrary rescheduling restoration or concurrent active cutoffs would need different semantics and is excluded.

## Validation and acceptance

After explicit approval cover direct v7/v8/v9/v10/v11 to v12, at least three same/different-anchor cycles, continued singles/ranges and master REQUEST/CANCEL/reopening in active/restored states, DATE/UTC/named zones/DST, PERIOD/exclusions, individual flags, exact source omissions/versions and all orphan/profile/floor failures. Test all source/native/action/composition rights at read/preliminary/final phases, history-only versus active flags, legacy retries, operation/source/cycle receipt collisions, latest supersession, pruned sources/deletion, byte/slot/shared-work limits, and every frozen/flat/current binding corruption.

Exercise actual two-host same/competing control/canonical/master races and loss before/after both cancellation/restoration commits; generated-client/Flutter flows; complete busy/occurrence queries, fresh feed validators, private actions, planner withdrawal and accepted-firing deduplication across repeated cycles. Use focused development tests and one broader related group at completion, deterministic generation/full analysis and appropriate VM/Chrome suites, then one complete-batch code commit. Full exact-head repository CI remains required before readiness. No real mail, external-client certification or publication is implied.
