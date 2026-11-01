# ADR 0151: Explicit single-instance invitation application

Status: **Proposed 2026-10-31. Clean entire-series conflict protection is confirmed; the storage, API, retention and composition guards below require explicit review.**

## Context and confirmed decisions

Accepted [ADR 0149](0149-trusted-single-instance-invitation-review.md) receives private known-series REQUEST/CANCEL notices without calendar changes. Accepted [ADR 0150](0150-pure-instance-invitation-projection.md) now supplies a tested [pure projection](../instance-invitation-projection.md), preserving source omissions separately from canonical retained cancellation values. The maintainer confirmed that explicit application must reject any local change anywhere in the linked series. That policy does not approve new persistence automatically.

The existing master application checkpoint binds its own source version and baseline. An instance must not overwrite that version or turn a minimal cancellation into a complete source event. Existing clean-baseline checks compare the full normalized event, including overrides and protocol state; personal alarms and private participation state remain independent. The existing primary-source references and narrower REQUEST/CANCEL profile are documented in ADR 0150 and [the message guide](../itip-message-profile.md).

## Proposed bounded workflow

Add separate explicit **Apply occurrence update** and **Apply occurrence cancellation** commands, plus a protected preview. Resolve the actual trusted recipient, instance entry, master link, destination calendar/event and typed original on the server. Require the current selected pending source, the existing recurring link mode, supported projection, exact correlation/recipient/membership and a clean complete accepted series. Reject local changes, missing/deleted evidence, stale revisions, cancelled masters, RANGE, single/future anchor collisions and unrepresentable differences atomically. Receiving or dismissing a notice remains review-only.

Use the approved pure helper against the accepted canonical values. REQUEST replaces only its selected single component. CANCEL retains timing/content/inheritance, compares supplied fields and sets only its cancellation flag; startless duration remains separately retained source data. Update the event's complete private baseline to the newly accepted canonical projection. Preserve master protocol version, unrelated overrides/versions, API identity/origin, native assignments/associations and personal alarm/action state. No outgoing invitation, attendee REPLY or imported alarm activation follows.

The command carries invitation/source/link IDs and expected invitation, calendar, event, master-application and occurrence-checkpoint revisions. An absent occurrence checkpoint has revision zero. All actual writes use the shared scope transaction and database time: event/API audit/revision, scope generation, feed invalidation, accepted checkpoint and dismissal of exactly the selected source commit together. Calendar metadata timestamps/revision stay unchanged. Source component timestamps/omissions remain exact, without native automatic-version allocation.

## Proposed independent acceptance storage

Add **one server-only table**, `CalendarInvitationOccurrenceApplicationRecord`, unique by link ID, with scope/recipient/link, UUID, revision, bounded versioned state JSON, event revision and database modification time. No occurrence source version is installed into `CalendarInvitationApplicationRecord` or the immutable creation receipt.

The version-one state contains:

- A frozen complete normalized master-acceptance baseline from immediately before the first occurrence application, plus a digest binding the original creation/latest master checkpoint. This permits validation of that unchanged master checkpoint without pretending its baseline is the newer composed series.
- The current complete accepted-baseline digest, validated against the active event's private import baseline. Current native values must still equal that baseline before any new application.
- Up to **128 exact typed original targets**, each retaining its latest accepted source kind/IDs, normalized source bytes/digest, independently optional component version, acceptance time and canonical component fingerprint. This is current acceptance state, not an append-only message history. Replace only the selected target's accepted source; preserve siblings.
- One latest command digest and result receipt **per link**, spanning both occurrence actions and all originals. The receipt records action, original, source/link/event identities, committed revisions and database application time. It does not replace any existing master receipt.

Defaults and initial hard ceilings: **4 MiB encoded state per link, 16 MiB per recipient and 64 MiB per scope**, with trusted host configuration allowed to lower them. Each source remains within the existing **256 KiB** stored-source ceiling. Count and byte limits are independent: 128 targets is an upper bound, not a promise every maximum-size source fits. Charge/validate before allocation and commit; quota exhaustion never prunes accepted targets silently. Use the shared scope lock for competing-host capacity checks.

This private state intentionally retains the latest accepted source even after the ordinary review queue prunes its body. No automatic 30-day pruning applies while the linked event remains active, because losing independent version/omission evidence would make later application ambiguous. Event deletion atomically scrubs this row and its copied source/baseline content; the existing content-free link/deletion markers remain under their existing policy. No archive/restore or relink is introduced. Explicit link purge and broader history remain separate designs.

Generate table/client carriers and data-preserving fresh/upgrade migrations from approved sources. Existing links start with no occurrence checkpoint; never infer prior instance acceptance from edited native overrides. Mixed old/new writers are unsupported; upgrade all hosts and generated clients together before enabling the commands.

## Proposed versions, retries and master boundary

For an original without a target checkpoint, derive the accepted invitation floor from its effective accepted component: exact single first, otherwise active future timing component, otherwise master. Use the preserved source versions, not the native API revision. With a target checkpoint, use its independently accepted source version. Omitted SEQUENCE compares as zero but remains absent in storage. A new REQUEST must be strictly later by SEQUENCE then DTSTAMP; a CANCEL must also increase SEQUENCE over the accepted effective component, including an already accepted cancellation. A later REQUEST reopening an accepted cancellation must increase SEQUENCE over it. Queue ordering alone proves none of these conditions.

Before normal current-source/revision eligibility, recognize an exact **latest retained occurrence-command retry**, reauthorize historical/current access and return its original receipt without writing or dismissing a newer notice. A different successful occurrence application supersedes that retry slot, including applications to another original. Older command retries then reject stale. No receipt ledger or replay of accepted effects is added. Changed command fields cannot alias another action or target.

Initially **block new master Apply update/Apply cancellation operations once an occurrence acceptance checkpoint exists**. They would otherwise replace or conflate accepted exceptions. Master review/intake and separate participation actions remain available, and retained creation/master/occurrence exact retries retain their existing non-mutating semantics. Master views explicitly report the composition guard rather than falsely reporting corrupt data or a local edit. This is a temporary scoped guard, not completed master/instance reconciliation; composing later master updates/cancellations with accepted targets requires the following reviewed batch. Native local edits remain possible and make the complete baseline dirty.

## Proposed authority and disclosure

Add independent invitation read-occurrence-application, apply-occurrence-update and apply-occurrence-cancellation operations. Require existing invitation summary/source/link/application access plus native full event/detail/source disclosure, import/replacement/update and applicable occurrence timing/content permissions. Cancellation and reopening require lifecycle authority. Hosts may map gates together. No client-supplied calendar, recipient or original establishes parentage or rights.

Authorize before exposing dirty/version/capacity classifications, then recheck complete immutable current/proposed event, source, link, master acceptance, selected target and aggregate checkpoint/result at commit. Preserve declared coordinated versus fresh-external guarantees and their residual revocation race. Separate source-read authorization protects retained accepted bodies; ordinary event views/exports never expose the private checkpoint. Client preview shows only the selected original, accepted/incoming version, current/proposed effective occurrence, relevant revisions and guarded apply flags, not sibling source bodies or total counts.

## Example and validation

Add explicit Flutter preview/apply controls for the existing synthetic single-instance notices; source original and replacement timing remain distinct. Retain uncertain command fields for exact retry, reload stale selections explicitly, and explain whole-series local conflicts and the temporary master-composition guard. Personal response/calendar actions stay separate. No real mail or new transport is included.

Test DATE/UTC/zoned/DST and PERIOD originals, minimum cancellations and optional timing, selected inheritance/empty text, independent source versions, cancellation/reopening, all gates/final denial rollback, source expiry, clean/identical saves versus any local series/sibling edit, malformed checkpoint/source/baseline fingerprints, slot/byte quotas, deletion scrubbing, master guards and historical exact retries. Exercise fresh/populated upgrades, actual two-host races and process loss before/after commit, generated-client and connected Flutter journeys. Run focused tests while developing, complete agreed batch checks before one code commit, and hosted repository checks before readiness.

## Alternatives and review gate

Overwriting the master checkpoint loses component-version identity. Relying only on the prunable queue loses accepted minimal-source distinctions. Replacing complete master files immediately after instance application silently discards accepted exceptions. A per-target history table adds history/retention beyond this current-state requirement. The proposed one-row aggregate makes the whole-series concurrency and quota boundary explicit, at the cost of a temporary master-composition guard and bounded active copied source retention.

Approval is required for this complete concrete storage/API/authority/retention batch, including that temporary guard. [AGENTS.md](../../AGENTS.md) requires: “Proposed ADRs become accepted only after explicit maintainer agreement.” Approval of ADR 0150 or the clean-baseline policy alone does not approve this table. Instance replies, master/instance composition, RANGE, participant changes, overwrite/merge and real mail remain required separate work.
