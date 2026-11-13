# ADR 0184: Information-publication occurrence bundles

Status: **Accepted by explicit maintainer agreement, 2026-11-13.** The maintainer approved the complete grouped projection/checkpoint/version/lifecycle batch in PR #199. Implementation and actual validation remain separate.

## Context and inspected evidence

The completed local ADR 0183 group is commit `8a30329082b45bca8173ad952e4c4286210bee6d`, [draft PR #198](https://github.com/jimmyspets/serverpod_calendar/pull/198). Its [exact-head run 43449216068](https://github.com/jimmyspets/serverpod_calendar/actions/runs/43449216068) has successful inspection; runtime was still running at proposal preparation and subsequently failed on the Unix recovery-probe stop timeout. Repair `98159c2` uses forced process loss; [run 43489862190](https://github.com/jimmyspets/serverpod_calendar/actions/runs/43489862190) is tracked separately. The earlier parent runtime failure remains recorded. Resolve baseline failures before new runtime implementation, as the roadmap requires.

Current ADR 0182 information publication accepts native single events or recurring masters, but `_informationOutgoing` rejects every stored occurrence override/cutoff. Its separate flat version-1 checkpoint retains canonical/outgoing and last-active bases, purpose, lifecycle and stable command proof in existing columns. ADRs [0126](0126-independent-occurrence-publication-versions.md) and [0127](0127-retained-occurrence-reset-projections.md) already implement independent outgoing REQUEST component versions and bounded reset projections without changing native inheritance.

[RFC 5546 section 3.2.1](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.1), checked 2026-11-13, profiles PUBLISH with required organizer/start/summary, no attendees, optional recurrence identity and multiple VEVENT components. The same-UID complete-series restriction, checkpoint design, significance rules and fixed-recipient controls proposed here are application choices. No blanket RFC or external-client compatibility follows.

## Proposed complete feature batch

Extend native **Save and publish** to one complete supported recurring event: master plus representable single timing/content exceptions and timing-only THISANDFUTURE components, preserving exact original DATE/UTC/named-zone identities, supported text annotations, end/duration forms and recurrence/PERIOD meaning. Keep one native-created binding, one verified organizer, fixed routing recipients and the existing explicit actions. Ordinary edits still send nothing.

Use the existing REQUEST representability/reset policy as the initial boundary. A new component needs faithfully representable explicit timing. A new follow-series content-only exception remains rejected; do not invent or pin native timing to publish it. Once an original has been published, a reset can retain that original/kind and project its current effective values on every later explicit publication. This restores remote values without claiming to delete a remote exception.

Keep current rejection of individual cancellation flags, active future cutoffs, alarms, attendees, imported/unknown native origin, mode changes, unprofiled metadata and exhausted bounds. Never omit one of these fields to manufacture a valid packet. Individual/range information cancellation, incoming component-publication reconciliation and remaining selected methods stay separate required roadmap work.

Implement the pure projection, durable checkpoint/version/lifecycle integration, example controls and documentation, synthetic MIME, generated-client/Flutter and competing-worker/process-loss checks together. No intermediate feature-code check-ins.

## Required fields and native inheritance

Add a pure PUBLISH-specific required-field projection alongside the REQUEST helper. It copies the resolved effective summary and fixed host-approved organizer into outgoing components that require them, including explicit empty summary when needed. It neither allocates versions nor authenticates an address. Attendees remain forbidden, and source alarms are rejected rather than stripped.

Retained reset projections explicitly state current effective supported text/status/transparency; empty optional TEXT clears an old own value. Native absence/inheritance, canonical protocol versions and ordinary authenticated file-export representability stay unchanged. Preserve original single/range kind, validate membership/profile and reject orphaned or colliding originals. Later future-timing anchors continue to bound preceding range projections.

## Approved checkpoint and versions

Write a flat `informationVersion: 2` checkpoint in the existing private snapshot/projection columns. Retain existing purpose/action/event/parent/UID, canonical/outgoing, active canonical/outgoing, prior lifecycle floor and immutable command/recipient bindings. Add `projectionOriginals`: typed point-only `originalStart` plus `isThisAndFuture`, using the same canonical key rules as the REQUEST reset profile. The outgoing snapshot's existing per-component protocol-state list supplies the independent version vector; do not add a second redundant vector.

Bound the combined emitted/retained original set to **64 plus the master**, within unchanged snapshot/projection/payload, pooled delivery, recipient, work and retention limits. Charge one shared validation/projection budget. Capacity exhaustion rejects the entire transaction; never evict proof or flatten recurrence to fit.

Advance an outgoing component only when its effective supported published state changes, including inherited required-field projection. Unchanged components retain their versions. Keep collision-safe effective versions and nondecreasing whole-second stamps, reject overflow, and keep all outgoing versions separate from native/source protocol versions and API revisions. Version significance/collision rules are explicit application policy.

Continue strict version-1 reads, retries and worker dispatch. Upgrade only through a successful new explicit command; never guess component history or lazily rewrite a checkpoint on read. Validate exact typed identities, duplicate/profile/membership rules, canonical/outgoing correspondence, purpose/organizer/no-attendee constraints, payload digest and component-version/body consistency before use. Corruption fails unavailable without echoing private source.

No SQL table/column, larger quota, provider data or generated API model field is expected. The private checkpoint and pure helper are nevertheless model/protocol changes requiring this review. All active hosts/workers must understand the new checkpoint before component publication is enabled.

## Whole lifecycle, retries and authority

Whole Cancel and reopen continue using the last complete published basis while preserving newer native drafts. A whole cancellation uses a master CANCEL with SEQUENCE above the retained published component floor; the stronger floor is an application policy. Reopening sends the complete retained active PUBLISH packet. Preserve unchanged independent component versions through whole lifecycle, exact command keys/calendar/MIME bytes, purpose isolation, pooled limits and existing generation/lease fencing.

Existing publication/read/cancel/reopen permissions and actual native full-detail/source/edit/lifecycle rights remain mandatory. Host context includes complete current/final native overrides and the distinct complete outgoing message/digest; `authorizeMessage` must approve all components in command phases and actor-free dispatch. Organizer/route resolution alone does not approve publication. No native participant, assignment or mailbox ownership is inferred.

Keep incoming ADR 0183 master-only guards: its receiver must reject this new multi-component packet until a separately accepted component-reconciliation contract exists. Existing invitation bindings/commands must still reject information-purpose access before fallback.

## Validation and acceptance

Focused tests must cover DATE/UTC/zones, recurrence/PERIOD membership, single/future timing and selected content, required-field inheritance/annotations, unchanged/changed component versions, retained resets after later master/range edits, orphan/profile/collision/capacity rejection, independent permissions, complete-message denial/final rollback, version-1 compatibility, corrupted proof, no-op/retry stability and private-draft whole cancellation/reopening. Assert rejected alarms/cancellations/attendees are never silently removed.

Exercise real competing hosts/workers and loss before/after commit and synthetic acceptance, stale leases/generations, source/route withdrawal and exact MIME retry bytes. Test generated JWT clients and connected Flutter for component publication/update/reset and whole lifecycle. Retain negative incoming-master and invitation-purpose regressions. At group end run broader package VM/Chrome, generation stability, formatting/analysis/release-web and relevant integration checks; require full exact-head hosted success before readiness.

## Alternatives and consequences

Keeping master-only publication leaves a selected scheduling gap. Flattening occurrences changes recurrence meaning. Reusing REQUEST output would invent attendees. Adding separate publication tables duplicates the approved outbox without solving component identity/version proof. Copying values into native overrides would destroy inheritance.

The proposed reused bounded ledger keeps responsibilities separate and avoids SQL expansion, but retains published-original proof until binding retirement and can reject otherwise valid large/unrepresentable native state. Information binding retirement, arbitrary instance/range cancellation, incoming bundles, real transport and external-client evidence remain explicit follow-up work.
