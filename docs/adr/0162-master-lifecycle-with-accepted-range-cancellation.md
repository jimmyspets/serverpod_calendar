# ADR 0162: Master lifecycle with accepted range cancellation

Status: **Proposed; concrete lifecycle, version-floor and v6 checkpoint mechanics require explicit maintainer approval.**

## Context and scope

[ADR 0161](0161-master-updates-with-accepted-range-cancellation.md), implemented in PR #153, permits active-master REQUEST updates while preserving accepted range cancellation. Its grouped local/client/Flutter checks passed; exact-head hosted inspect passed and runtime remains in progress. New whole-series CANCEL and reopening are deliberately blocked when that private cancellation layer exists.

The maintainer confirmed that newer master updates must retain the cutoff rather than implicitly reopening the suffix. Extend that preservation policy to explicit whole-series cancellation and a subsequent explicit newer REQUEST reopening. The master status can change independently while the cutoff and individually cancelled occurrences remain intact. Receiving/reviewing a message still changes no calendar.

Primary source checked 2026-11-02: [RFC 5546 CANCEL](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) distinguishes whole-series cancellation without RECURRENCE-ID from instance/range targets. [Message sequencing](https://www.rfc-editor.org/rfc/rfc5546.html#section-2.1.5) correlates component identity and source versions. The cross-component floor and retained native mask below are project application choices, not universal RFC requirements.

Reuse `applyCancellation` for an explicitly selected whole-series notice and `applyUpdate` for an explicitly selected newer master REQUEST. Preserve existing expected revision/source/link/recipient checks and ordering. No new endpoint, SQL storage, view field, delivery mechanism or scheduling method profile is proposed. New occurrence applications, range cancellation replacement and source restoration remain guarded. Reopening the master must not be presented as restoring its cancelled suffix.

## Source versions and projections

A new whole-series CANCEL must have SEQUENCE strictly greater than the current accepted master, every retained accepted single/future component, and the independently stored original range-cancellation version. Omitted existing component SEQUENCE compares as zero without changing the stored omission. A later DTSTAMP does not relax this cancellation floor. A maximum accepted sequence can therefore prevent another new cancellation; exact retained retries remain available.

This extends the existing conservative whole-CANCEL floor to the accepted range source. It may reject senders whose component versions do not satisfy this project rule. Never silently raise the incoming version, overwrite an exception's version or replace the historical range version with the master version.

Reuse the current status/version-only whole-CANCEL projection: retain the last accepted cutoff-free master timing, recurrence, text and metadata, change master status/version under the existing source timestamp/omission policy, and retain other CANCEL payload properties as reviewable source data. Compose the canonical accepted targets and then the exact retained cutoff. A newer whole CANCEL may update an already cancelled master only under the same strict floor.

An explicit reopening REQUEST follows the existing master source ordering, including its established SEQUENCE/DTSTAMP tie-break behavior. It replaces the supported master source contents, composes retained canonical targets and reapplies the exact cutoff. The original anchor and accepted exception originals must still be members with matching profiles; orphaning/excluded/profile-changing proposals reject. Reopening restores eligible originals before the cutoff only; the suffix and individual cancellations remain cancelled. No historical snapshot is silently restored and no source response is sent.

The complete native state must match its verified expected source state before either transition. Native local cancellation/restoration or other local edits remain conflicts. Exhausted work, a higher master version or an inbox dismissal never proves a source restoration.

## Existing checkpoint JSON v6

V5 intentionally permits only an active current master REQUEST. Add explicit v6 support for a verified current master REQUEST or whole-meeting cancellation, preserving the same frozen-original/current-composition separation. Do not loosen legacy v4/v5 validation or reinterpret their markers.

When the first approved lifecycle command follows v4, freeze its verified original cutoff-free cancellation basis and original expected-native digest once, as under ADR 0161. When following v5/v6, retain that same original basis, source/version/floor/binding, acceptance time and cancellation receipt unchanged. Add no per-transition snapshot history. Current master/baseline bindings advance separately; the ordinary event import baseline remains cutoff-free even when its master status is CANCELLED.

Use explicit v6 composition/receipt hash domains bound to actual scope/recipient/link/parent/event/UID/organizer, verified current master checkpoint including its source kind, current cutoff-free basis, original cancellation binding and current expected native candidate. Validate that the current master source kind and projected status agree. Reconstruct original acceptance only against its frozen basis, never against a later master version. Reconstruct current state with the preserved cutoff and canonical targets independently.

Keep v6 after later successful active-master updates rather than downgrading its namespace to v5. Reads and exact retries never lazily upgrade. Missing/inconsistent frozen/current/source-kind/receipt evidence, marker-only upgrades and unsupported versions fail unavailable; do not invent a frozen basis or fall back after corruption. Valid legacy v1/v2/v3/v4/v5 behavior remains supported.

The unchanged active-data lifetime, 4 MiB/link, 16 MiB/recipient, 64 MiB/scope and configured lower byte caps include all frozen/current data. Existing slot, raw-source and validation-work ceilings remain. Deletion scrubs the private state; source-body pruning cannot destroy its retained evidence. No additional SQL, cap increase or extra retained-content category is proposed beyond the single original basis already approved in ADR 0161.

## Authority, atomic effects and retries

Require ordinary master import/replacement/full-event/source/update authority, `composeAcceptedOccurrences`, `composeAcceptedRangeCancellation` and the appropriate host application operation. Whole cancellation always requires lifecycle authority; reopening requires the existing status-change authority. Read eligibility checks the relevant cancellation/reopening permissions without mutating. Raw original cancellation data/flags remain independently authorized by their actual source identity, even when another master notice is selected.

Preliminary/final contexts distinguish incoming whole CANCEL/REQUEST, current/proposed native master status and preserved cutoff, cutoff-free basis and current/proposed private checkpoint. Never treat source participants as authority. Final denial or version/membership/quota failure rolls back the whole operation.

Atomically advance event/master/checkpoint revisions and database audit time, replace current accepted source state, dismiss only the selected notice and advance scope/feed/reminder generations and lease invalidation. Whole-master cancellation withdraws all affected live/retry/snooze eligibility; reopening follows existing future/current-source planning and accepted-firing deduplication rules. It must not replay an accepted reminder or remove persistent alarm actions. No imported alarm activation or real delivery follows.

The original latest exact range-cancellation retry remains write-free through cancellation/reopening and later edits, preserving its result and never reapplying the cutoff. The separate latest master command retry also reauthorizes and returns its original result without changing revisions, generations or a newer notice. Older master/occurrence commands retain their existing latest-only supersession boundaries. Independent actual-host races and process loss must preserve these guarantees without process-local locks or sticky routing.

## Views and example

Reuse protected `hasAcceptedRangeCancellation`, `occurrenceCompositionBlocked`, source kind, status and existing eligibility/result fields. A cancelled master still has an accepted range cutoff. Explicit Apply cancellation and Apply reopening controls explain that the cutoff/individual cancellations survive; source restoration remains unavailable. Preserve the same command across uncertain responses.

Active-cutoff ordinary export/feed/new organizer REQUEST rejection and no-stale-304 behavior remain, even while the whole master is cancelled. Do not erase the cutoff merely because the whole-series status makes it temporarily redundant. Calendar/source lifecycle, participation responses and outgoing organizer publication remain separate flows.

## Alternatives, consequences and validation

Keeping the current guard is safe but leaves the ordinary recipient lifecycle incomplete. Dropping the cutoff on whole cancellation would lose later reopening behavior. Revalidating an old range CANCEL as new would incorrectly apply current source floors. A single combined version would erase independent source evidence. The proposed explicit v6 binding preserves those distinctions at the cost of coordinated writer upgrades and the documented stricter whole-CANCEL floor; senders outside the profile can be rejected.

After approval, cover DATE/UTC/named zones/DST, singles/later ranges and added originals, independent versions, equal/lower/max/null floors, exact source timestamps/omissions, repeated cancellation/reopening, local conflicts and orphans. Verify v4/v5-to-v6 and continued v6 updates, every frozen/current/kind/receipt binding, quotas, pruning/deletion, read/final authority and atomic rollback. Exercise booking/reminder withdrawal and non-replay, actual two-host races and loss before/after commits, generated clients, HTTP feed/no-304 behavior and connected Flutter. Use focused development tests, grouped checks before one batch commit and full implementation-head CI before readiness.

Source-cutoff restoration/replacement, occurrence application, outgoing range CANCEL, faithful masked wire mapping, range replies and real mail remain separate required work. This documentation proposal authorizes no runtime/model implementation until explicit maintainer agreement.
