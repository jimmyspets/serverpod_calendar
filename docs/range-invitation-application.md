# Explicit range REQUEST application

Accepted [ADR 0156](adr/0156-explicit-range-invitation-application.md) adds explicit range REQUEST preview/application and preservation of accepted ranges through master composition. [Range intake](range-invitation-review.md) still changes no calendar by itself. The [pure range projector](range-invitation-projection.md) remains a value helper, not proof of source authority, freshness or a clean database baseline.

## Explicit application and authority

The generated `rangeApplication` and `applyRangeUpdate` APIs operate on a selected received range notice and its existing linked event. They reuse the immutable occurrence request/receipt carriers; `expectedOccurrenceRevision` fences the same per-link checkpoint used by single and range commands. The protected immutable view derives `isThisAndFuture` from the verified stored target. A client mode flag cannot turn a single into a range: the dedicated endpoints validate the actual target before correlation fallback or application history lookup.

Require current source/invitation identity and expected calendar/event/master/checkpoint revisions. Every actual native master/occurrence change since the accepted source baseline blocks new source application. Local drafts are preserved, with no implicit adoption, relink, merge or overwrite. Exact retained command retries reauthorize and return their receipt without reapplying; they do not dismiss a newer notice.

Independent host `readRangeApplication` and `applyRangeUpdate` operations are required with existing source/link/application and full native read/applicable write gates. Range access does not require the single-only readOccurrenceApplication permission. Source/read authority precedes type-specific errors. Actual actor/scope/recipient/link/parent, source, native current/proposed overrides/protocol state and private checkpoint snapshots are supplied to the trusted host. Preliminary/final checks and declared consistency guarantees remain; external fresh checks still have their documented after-check revocation race.

## Preserved meaning and versions

Apply one validated range REQUEST through the approved pure helper. Only timing propagates; supported explicit text stays at the original anchor. Preserve master data, explicit singles/cancellations, other future components, source timing/end/duration forms and their independent protocol versions. Selected single/range collisions, missing/excluded originals, profile changes, unsupported claims and exhausted bounds reject without partial changes. Existing iTIP SUMMARY requirements and source VALARM rejection remain, and accepted unarmed metadata grants no authority or execution.

Source ordering uses the effective accepted component at the original: own range if present, otherwise the latest preceding range or master. REQUEST must be strictly newer under the existing SEQUENCE/DTSTAMP ordering; equal effective sequence needs a later stamp. Omitted SEQUENCE compares as zero but stays omitted in storage, distinct from explicit zero. A later separate component's sequence does not become the anchor's floor. Source timestamps/omissions are preserved, not trusted as authority or replaced by native clocks.

The transaction commits event values/protocol/baseline, private checkpoint, selected review state and native revisions/audit time together. Existing scope/publication generation and personal-alarm plan invalidation run in that transaction. Free/busy and feed results reflect committed timing; notice receipt or a retained retry does not repeat those effects. No participation response, organizer publication or alarm adoption is inferred.

## Version-three checkpoint and retries

Reuse the existing one-per-link active-data row/string column. Range acceptance writes v3 JSON; valid v1/v2 states remain readable without rewriting them. Single criteria/component hashes remain unchanged. Range criteria use their own domain; range component bindings include the exact typed range key, source digest, canonical future component and protocol state. Current/historical source RANGE/kind/original, UID/organizer/recipient and independently optional versions are checked. Legacy targets cannot become ranges by changing a version or prefix.

The v3 envelope retains separate master and composed baselines/digests and current master binding. `latestTargetKey` binds the latest receipt to its exact range/single target and source digest, preventing cross-kind retries. Existing latest-only per-link command semantics apply across both kinds: a later occurrence command makes older occurrence commands stale. Master commands/receipts remain separate. A master update preserves the historical occurrence receipt without replaying it.

At most 128 combined accepted targets/native slots are supported. The existing hard 4 MiB/link, 16 MiB/recipient and 64 MiB/scope byte ceilings and configurable lower limits remain. No table, SQL column/index, migration or retention expansion is added. Unknown namespaces, corrupt bindings, inconsistent receipt/source/component state or incompatible layers fail unavailable. Upgrade hosts/clients together; mixed old/new writers are unsupported. Accepted source survives inbox body pruning; event deletion scrubs the active accepted checkpoint/source copy, while independent inbox retention retains its own rules.

## Master composition and cancellation boundary

New master REQUESTs retain accepted canonical single and future components and their independent versions. They do not replay historical range messages against the new master. Orphaning recurrence/profile changes and colliding supplied components reject. Existing independent compose authority receives complete range context. Native inheritance remains inheritance: omitted anchor text can follow the new master, while explicit own text remains local.

Whole-master CANCEL/reopening preserves accepted layers and individual cancellations. The existing conservative whole-cancellation sequence floor includes every accepted range component; this is a native policy, not a universal RFC claim. Native preservation does not waive separate wire/export/feed representability or client compatibility requirements.

A range CANCEL remains review-only. The dedicated read view can show its accepted range and protected source, but `canApply` is false and applyRangeUpdate rejects it. Range participation APIs remain unavailable. Future cancellation/restoration, same-anchor conversion, arbitrary reconciliation and wider scheduling methods require separate policy/model review.

## Example and evidence

Flutter provides an explicit range preview/apply screen, explains timing propagation versus anchor-local text, retains the same command across uncertain retries and displays cancellation as read-only. Master update screens explain preservation of range edits. The example continues to use synthetic MIME and local test addresses; no real mail or platform delivery is added.

Tests cover DATE/UTC/named zones, stored DST shifts, earlier/PERIOD additions, source omissions/effective versions, collision/orphan/profile rejection, legacy/v3 state, authority rollback, pruning/deletion, quotas, booking results and durable alarm invalidation. Actual two-host process loss covers range and master commits; generated clients check atomic races, exact retries and feed ETags, and Flutter exercises the explicit flow. See [actual validation](scaffold-validation.md) for commands/results and deferred checks. These are scoped synthetic/native results, not external scheduling interoperability evidence.


## Proposed first durable range cancellation

[Proposed ADR 0160](adr/0160-first-range-cancellation-acceptance.md) adds explicit first incoming range-CANCEL acceptance using one private layer in existing checkpoint v4 JSON, keeping the ordinary accepted baseline cutoff-free and binding the complete expected native state separately. It proposes separate cancel authority/API, a protected derived view flag, exact latest receipt retries and native cutoff/query/reminder/feed effects. New source applications after acceptance would temporarily block until composition/restoration is designed. No new SQL or retention expansion is proposed. These mechanics are unapproved and unimplemented; current durable range CANCEL guards remain.
