# ADR 0161: Master updates with accepted range cancellation

Status: **Proposed. The maintainer confirmed preserve-cutoff/reject-orphan behavior; the concrete checkpoint, authority and view mechanics below require explicit approval.**

## Problem and bounded scope

[ADR 0160](0160-first-range-cancellation-acceptance.md) implements first incoming range-CANCEL acceptance in PR #151. Its grouped local, generated-client and Flutter checks passed; implementation-head hosted inspect passed and runtime remains in progress. It deliberately blocks every new source application after acceptance. A newer master cannot currently update the retained event, even when its original cancellation anchor still exists.

The maintainer confirmed that a newer master update must preserve the accepted cutoff and reject a recurrence/profile change that removes its exact original anchor. A higher master SEQUENCE alone must never reopen the range. This is an application policy, not a universal claim about iTIP source ordering.

Implement only explicit master REQUEST composition through the existing `applyUpdate` command, with an already active accepted master REQUEST. A cancelled accepted master still requires a separately reviewed reopening workflow. Keep new whole-series CANCEL/reopen, single/range REQUEST/CANCEL and source-restoration commands blocked while an accepted cutoff exists. Review/dismissal and ordinary native edits retain their existing boundaries. Outgoing range cancellation, masked wire/feed mapping, participation responses and broader reconciliation remain separate required work.

## Preserve the source layers

Continue the current master REQUEST ordering, explicit selection and expected revision rules. A master source version is compared with the accepted master version; the historical range cancellation keeps its independent version. It is not rewritten or newly compared with a later master's SEQUENCE.

Compose the proposed cutoff-free master with the existing canonical accepted single/future targets. Preserve those targets, source omissions, original identities, independent versions and own/inherited field distinctions. Then validate and apply the exact retained cutoff to the proposed native candidate. Require the same DATE/UTC/named-zone profile and exact membership in the proposed recurrence set, including EXDATE precedence and explicit additions. Removing/excluding the anchor, changing its profile, colliding with accepted components or exhausting bounded membership work rejects the entire update. Later exceptions remain suppressed under the cutoff, with their data retained.

The current native series must match the complete verified expected state, as under ADR 0160. A local cutoff restoration or any other local content/protocol change is a conflict. It must not be silently overwritten or converted into a source reopening. New master input never supplies or clears the private cutoff.

## Existing checkpoint JSON v5

Reuse the existing checkpoint table and ordinary cutoff-free import baseline; add no SQL columns, tables, index or history store. Valid v1/v2/v3/v4 reads stay supported. V4 remains strict and is not rewritten on reads or retries. Upgrade hosts/clients together; mixed old/new writers are unsupported.

At the first authorized master update after v4 acceptance, write v5 with these distinct pieces:

- Preserve the original `rangeCancellation` source text/IDs, recipient, version, required sequence floor, basis digest, acceptance time and original binding unchanged.
- Add one private `cancellationBasis`: the exact cutoff-free accepted baseline used for that original cancellation, obtained from the verified v4 state before replacing the ordinary baseline. Add `cancellationNativeDigest`, retaining its original expected-native digest. Reconstruct the original pure cancellation against this frozen basis and verify its source/version/floor/original binding independently.
- Advance the current cutoff-free `masterBaseline`, master checkpoint binding and composed ordinary import baseline under the existing master-composition rules. Retain canonical accepted targets unchanged.
- Reconstruct the current masked candidate from that current composed basis plus the retained exact cutoff. Verify a current `expectedNativeDigest`, excluding API revisions/audit fields. Add a domain-separated `compositionDigest` binding actual scope/recipient/link/calendar/event/UID/organizer, current basis/master checkpoint, original cancellation binding and current expected state.
- Retain the original latest cancellation command criteria and receipt. A distinct v5 receipt binding includes the current composition digest, original cancellation binding, original criteria and immutable receipt. Its acceptance revisions/time may precede the advanced checkpoint, with the established historical-receipt constraints; no newer source command is invented for that cancellation.

V5 decoding validates both frozen historical acceptance and current composition. It must not replay the old CANCEL as a fresh command against the new master or weaken its originally required sequence floor. It must not accept a marker-only upgrade, trust a stored boolean as proof, invent a missing frozen basis or fall back after corruption. Missing/inconsistent source, basis, native, composition or receipt bindings fail unavailable. The actual current event may differ through local edits; that is reported as a conflict against the verified expected candidate rather than treating every local edit as checkpoint corruption.

The frozen basis retains source values superseded by subsequent master updates until event deletion. It remains server-only active data: ordinary responses/exports never return it, and deletion scrubs it with the checkpoint. This is additional retained content within the existing active-data lifetime. The unchanged 4 MiB/link, 16 MiB/recipient and 64 MiB/scope caps include it; configured lower limits still apply. Keep one frozen basis, not one per update. Existing slot, raw-source and per-projection work ceilings remain, with bounded frozen/current validation and no unbounded replay. If the additional snapshot does not fit, reject atomically without dropping evidence or expanding limits.

## Authority, atomicity and retries

Require all existing master import/replacement/update/full-detail/source permissions and `composeAcceptedOccurrences`. Add independent host operation `composeAcceptedRangeCancellation`, even when the ordinary accepted target list is empty. Preliminary/final contexts distinguish the incoming master, current/proposed native cutoff, current/proposed checkpoint JSON and cutoff-free baseline. Keep independent fresh source-read authority over the actual retained cancellation IDs/body before exposing its existence or allowing composition; never substitute the currently selected master source.

Atomically replace the master baseline/current native candidate, advance event/master/checkpoint revisions and database audit time, dismiss only the selected current notice, and update scope/feed generation and alarm plan/lease invalidation. Preserve the original cancellation's version/time/receipt and all independent occurrence versions. A final denial or quota/membership/version failure rolls everything back. No messages, alarm activation or real transport follows.

The latest exact cancellation retry remains write-free after any number of successful master compositions, newer notices and local edits. The separate latest master receipt remains retryable under existing rules. Reauthorize both current native state and the actual retained cancellation source. Retrying must not reapply a cutoff, change any revision/generation, dismiss a newer notice or create another frozen snapshot. Older occurrence commands retain their existing latest-only supersession boundary.

Only eligible new master REQUESTs are unblocked by this batch. Keep new whole/single/range cancellation, occurrence updates and source-restoration guards after authorization and retained-retry recognition, including when a local native edit clears the cutoff. Do not reinterpret an ordinary master update as an implicit restoration action.

## Protected views and example

Add derived default-false `hasAcceptedRangeCancellation` to the existing master application view. It is independent of `occurrenceCompositionBlocked`: an eligible update can have a retained cancellation while composition is allowed. Authorize the actual accepted source before either field reveals its existence. The occurrence application's existing flag remains true for validated v4/v5 state.

Master previews retain the existing incoming source-content fields; the separate flag describes the retained mask rather than inserting it into source content. Report `canApply` only after validating the complete masked candidate and the same membership, conflict, quota and permission checks. Flutter explains that Apply update retains the cancelled suffix and cannot restore it, retains the same command across uncertain responses, and leaves range application/restoration controls guarded. Existing masked export/feed/new organizer REQUEST rejection and no-stale-304 behavior remain.

## Alternatives and consequences

Keeping all source applications blocked is the current safe behavior, but does not allow the requested master updates. Replaying the historical CANCEL against each later master would incorrectly apply a new-command version floor to old acceptance. Keeping only a cutoff marker or rewriting the cancellation version would weaken its source evidence. Including restoration, whole-series lifecycle and every range transition in the same batch would expand the unreviewed protocol state space.

The proposed frozen/current separation allows bounded master updates with verifiable historical evidence and unchanged SQL. It costs additional private retained content and bytes, requires coordinated writer upgrades, and may reject an otherwise valid update at an existing quota. Those costs are explicit; there is no truncation, silent evidence loss or limit increase.

## Validation and approval boundary

After explicit approval, cover DATE/UTC/named zones/DST, earlier/PERIOD anchors, singles/later ranges, inheritance, independent source versions, v4-to-v5 and repeated master composition, clean/dirty native state, excluded/orphaned/profile-changed anchors, immutable/final authority and rollback. Exercise every frozen/current/receipt binding, quotas, source pruning, deletion and historical exact cancellation/master retries after newer notices/local restoration.

Run actual two-host same/different-master races and process loss before/after atomic composition, current reminder withdrawal/lease fencing, generated clients and HTTP feed/no-304 behavior, plus connected Flutter. Use focused tests during implementation and grouped checks before one batch code commit; full implementation-head CI remains required before readiness. No model-source/API/runtime change is authorized merely by merging this proposal; explicit maintainer agreement is required.
