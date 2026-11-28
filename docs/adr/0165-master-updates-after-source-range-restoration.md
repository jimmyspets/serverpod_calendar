# ADR 0165: Master updates after accepted source range restoration

Status: **Accepted — explicit maintainer agreement on 2026-11-02 covering bounded frozen v7/baseline/master evidence, v8 composition, independent authority and stable retries. Actual implementation evidence is recorded separately.**

## Context and bounded scope

[ADR 0164](0164-first-durable-source-range-restoration.md), implemented in PR #159, adds first explicit source restoration with private v7 evidence and guards all subsequent source applications. Its grouped local, two-host, client/feed and connected Flutter checks passed; implementation-head hosted CI is tracked separately. The maintainer selected active-master REQUEST composition next: preserve restored state and individual cancellations, and reject removal of the restoration original. Whole-series lifecycle and new range transitions follow separately.

Lift only the explicit master `applyUpdate` guard for active accepted and proposed master REQUESTs. Retain ordinary intake/source ordering and expected calendar/event/master/occurrence/invitation revisions. No master CANCEL/reopen, new single/range REQUEST/CANCEL/restoration cycle or ordinary source replacement is enabled. Review/dismissal, native edits and retained retries keep their boundaries. Reject a proposed CANCELLED master in this first active-only profile rather than treating it as the deferred lifecycle flow.

## Preserve canonical and source layers

The current entire event must match its verified expected restored state. A local cutoff, content/protocol change or exception edit remains a conflict. Compose the incoming cutoff-free master with retained canonical single/future targets using the existing composition rules. Preserve independent target versions, source omissions, own/inherited distinctions and individual cancellations; do not reinsert the historical cutoff or turn restoration into a new canonical component.

Require exact restoration-original kind/zone/civil identity and membership in the proposed recurrence set, including earlier/PERIOD additions and EXDATE precedence. Reject removing/excluding that anchor, changing its profile, orphaning any accepted component, unsupported collisions or exhausted work. This retains the original for future reviewed source transitions even though it need not be an active exception. No implicit purge/adoption follows.

Compare a new master only with its accepted master SEQUENCE/DTSTAMP under existing ordering. The accepted restoration keeps its independent version and original source clock/omissions; a later master may legitimately have a lower SEQUENCE than that restoration. Do not replay restoration freshness/content matching against newly changed master fields. Its original acceptance is validated against its frozen historical basis. Future lifecycle/range source floors must separately account for restoration, so those paths remain guarded here.

## Existing-table v8 frozen evidence

On the first eligible v7 composition, freeze one complete restoration checkpoint descriptor (its v7 state, revision, eventRevision and updatedAt), the actual cutoff-free event import baseline at that acceptance, and the nullable actual accepted master-application record. The master snapshot carries only its existing server-only fields; a null record retains the original adoption binding. Validate these live inputs and their link/scope/recipient/creation/master/baseline bindings before freezing them.

Store those values once in a bounded v8 envelope in the existing JSON column. Subsequent master updates retain exactly that frozen acceptance rather than nesting v8 or accumulating snapshots. The original v7 descriptor already contains the single nonrecursive v4/v5/v6 predecessor and restoration evidence. Keep canonical targets, restoration source text/version and original occurrence receipt there once; derive their current read projections rather than duplicating them in persistent root fields.

The frozen ordinary baseline may retain superseded event content, and the master descriptor preserves historical version/binding metadata until linked event deletion. This is additional private active-data retention within current caps, not an ordinary view/export/history service. No SQL table/column, generated field, dependency, retention-duration or cap expansion is proposed.

Decode the frozen v7 acceptance strictly against its recorded baseline/master snapshots, then verify the current accepted master binding, current master baseline and composed canonical baseline independently. Bind current expected unmasked native digest, composition digest and historical restoration receipt with distinct v8 domains tied to the actual link/scope/recipient/calendar/event. Reconstruct current composition from the accepted master plus retained targets and require the restoration original still to be an exact member. Marker-only v8, altered/missing snapshots, inconsistent old/current/receipt bindings, nested v8 and unknown versions fail unavailable without fallback.

Ordinary event import baselines remain valid cutoff-free canonical state. The original source restoration is neither reaccepted nor rewritten. Preserve strict legacy v4/v5/v6/v7 reads and exact v7 retries; there is no lazy upgrade on reads. Charge complete frozen-plus-current JSON against existing 4 MiB/link, 16 MiB/recipient, 64 MiB/scope and configurable lower byte ceilings, with existing source/slot/work limits. Reject atomically if the frozen snapshot cannot fit; never drop evidence to fit.

## Authority, atomicity and retry identity

Add independent host operation `composeAcceptedRangeRestoration`, alongside ordinary master application, source/link/raw detail, native import/replacement/update and existing accepted-occurrence/composition rights. A host may map these to one rule. Freshly authorize actual retained cancellation/restoration sources by their own descriptors and bodies at preliminary/final stages, including after inbox pruning. Give the host immutable current/proposed private checkpoints and canonical current/final native states separately. Existing coordinated/external fresh-check guarantees and races remain explicit.

Protected read previews check the applicable composition/native rights, exact membership, clean state and limits without upgrading storage. Reuse existing master/occurrence history flags: cancellation and restoration history can both remain true while the native cutoff stays absent. Eligible master previews clear occurrenceCompositionBlocked; no new flag or endpoint is needed. Flutter must not label this history an active cancelled suffix.

Atomically save the proposed composed event, current master acceptance and v8 checkpoint, advance event/master/occurrence revisions and database audit state, dismiss only the selected source notice and invalidate scope/feed/alarm generations and leases. Parent metadata time, personal actions and accepted-firing non-replay remain unchanged; preserve active expiry/access checks. Actual independent source protocol versions are retained, not manufactured from audit time. No reply, alarm adoption or transport follows.

The latest master-command slot follows existing supersession. Its expected occurrence revision fences concurrent composition. The original restoration command remains the latest occurrence receipt: exact retries reauthorize and return that original result without touching later master edits, local cutoffs/drafts, notice dismissal or generations. Earlier occurrence/cancellation commands remain superseded. Preserve latest-only master retries and same-command race convergence; process loss before/after commit cannot reapply or partially expose evidence.

## Validation and acceptance

After approval, cover v7-to-v8 and continuing v8 REQUESTs for DATE/UTC/named zones/DST, same/different master-versus-restoration sequences, exact source clocks/omissions and retained canonical exceptions/individual cancellations. Verify orphan/exclusion/profile conflicts, local cutoff/content/protocol conflicts, native/host/preliminary/final authority, snapshot/current/receipt corruption, nested/unknown formats, limits, pruning/deletion and unchanged legacy reads/retries.

Exercise same/competing master sources, occurrence-revision fencing, atomic cross-host visibility and actual loss before/after commit. Verify original restoration retries after master composition and local drafts, generated-client/Flutter history labels, fresh feed validators, busy/query projections and reminder action/dedup fencing. Use focused tests, grouped checks before one code commit and full implementation-head repository CI before readiness. The maintainer explicitly approved these v8 mechanics; see [the scoped implementation](../restoration-master-composition.md) and actual validation.
