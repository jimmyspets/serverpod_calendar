# Published range cancellation and restoration

[Accepted ADR 0172](adr/0172-durable-published-range-controls.md) adds explicit organizer `cancelFutureAndNotify` and `restoreFutureAndNotify` actions. Local grouped validation passed; full exact-head hosted checks remain the readiness gate. See [actual results](scaffold-validation.md). These actions are separate from ordinary native edits, authenticated file import/export, feeds and recipient-side source acceptance. The example records synthetic MIME only; it sends no real email.

Published state means the latest committed outgoing intent. Delivery states are reported separately; it does not assert that an attendee received or applied the message.

## Supported actions and anchors

Use a native-created, already published recurring event with active native/published masters and its existing fixed host-approved organizer and recipients. Supply the event UUID, expected native revision, command UUID and exact published original DATE/UTC/named-zone point. Identity is the original occurrence, not its moved start. Whole-second dates and the ordinary [1970-01-01, 2100-01-01) profile remain unchanged.

The initial anchor can be an ordinary original or an existing future-timing anchor. Its own published single override, retained single reset or individual cancellation/restoration history rejects. A special PERIOD anchor without a governing range rejects. Before admitting cancellation, the service validates a faithful complete restoration projection and its capacity. Finite PERIOD additions may need retained single projections so their exceptional lengths never propagate across a suffix. Unsupported source, collision, membership, version or limit failures reject the entire command.

The first durable controls require current v3–v6 publication facts or a closed v7 state. Earlier records remain readable; an explicit newer complete Save and notify must establish the current profile before these controls. A partial action never invents missing history or silently upgrades legacy instance-reply identity.

Cancellation sends one minimal CANCEL bundle: the primary THISANDFUTURE target and all later explicit components, ordered by original identity. Earlier components remain unaffected even if moved across the cutoff. It retains last-active values and independent individual cancellation state. It publishes no private form edits or source alarm state.

Restoration names the exact active cutoff and sends one complete REQUEST, including an explicit active range projection and the needed later components. It clears the whole outgoing cutoff, preserves individual cancellations through module-owned publication EXDATE masks, and preserves ordinary source exclusions. It does not claim to delete a remote exception record or infer that a newer master alone removed range state. Added publication identities remain bounded and are re-projected on later explicit publications without pinning native inheritance.

Only one outgoing cutoff may be active. Restore it before a new complete REQUEST, individual control, whole-series cancel/reopen or another range cancellation. Retained exact retries remain available and reauthorize without queueing or advancing generation. Ordinary native edits remain private. After restoration, existing publication/lifecycle operations and subsequent eligible cycles continue; retained identity/profile/orphan and representability guards still apply.

## Native state versus what attendees were sent

Cancellation installs a native cutoff only when the exact original still matches the current native kind/zone/membership and no native cutoff already exists. Otherwise it leaves native state untouched. It never replaces a private cutoff to obtain a match.

Restoration clears that publication-installed native cutoff only when its saved revision, comparison and exact cutoff still match. Any intervening accepted native edit, including a revision-advancing no-op or clear/re-cancel, preserves the current native cutoff and drafts. Remote restoration can therefore succeed while a local cutoff remains. The example displays published range state separately and warns about local cutoff retention. Individual cancellations and canonical timing/content/version state are not erased.

The private checkpoint distinguishes the actual final native snapshot from the expected native meaning of published values. Publication-only projections do not become native overrides, and status comparisons must not label retained private drafts as published. Existing native query/free-busy/reminder behavior follows any actual cutoff write; ordinary export/feed guards still reject unrepresentable native cutoffs.

## Versions, storage and retries

Allocate independent outgoing versions transactionally, separately from canonical source versions. CANCEL exceeds all retained components/control facts and relevant current/final native protocol versions. Use whole-second database time with known nondecreasing stamp floors. Restoration advances the complete master/emitted components past the cancellation; retained individual masks keep independent last-active facts for later restoration. Overflow and fractions reject without partial writes. These conservative floors are application policy.

Outgoing v7 uses the existing publication snapshot/projection columns. It stores flat current facts, a complete unmasked source basis, actual component ledger, individual states/masks, the current active/closed range control and native comparison/installation bindings. Existing v3–v6 facts are normalized; v6 individual facts are expanded rather than embedding a v6 or predecessor v7 envelope. Readers reconstruct and validate the ordinary projection transiently. There is no recursively growing cycle chain or permanent all-cycle audit guarantee. The latest checkpoint remains self-contained when eligible superseded receipts are pruned.

Keep the current 512 KiB snapshot/projection/payload ceilings, shared 64-original slots, 64 recipients, outbox limits, retries/leases/expiry and configurable 30-day superseded terminal history. New restoration identities consume slots. Restoration planning and cancellation/output validation share bounded recurrence work. Limit failures never evict an identity or silently omit an exception. Source values/comparisons remain private while the binding is active; existing deletion restrictions and scrubbing apply. No SQL migration or dependency change is added.

Commands serialize under existing database scope/binding fences and revision checks. Earlier deliveries must be terminal before a new range control; no global generation change withdraws unrelated pending work. Native changes, immutable publication, recipient intents and current checkpoint commit atomically. Exact command retries verify actor/input/target and return the retained receipt without replaying state. A synchronized fresh no-op requires the expected current state; it does not silently begin another cycle. Pruned historical command receipts are not promised indefinitely.

## Authority, delivery and replies

Require independent `cancelFutureScheduling`/`restoreFutureScheduling` permission plus scheduling read, full event/source disclosure and lifecycle permission even when native state stays unchanged. Trusted host context includes actual collection/event, exact published original, separate native/published candidates, complete immutable message/digest and approved fixed routes. Preliminary/final checks preserve the declared coordinated or fresh-external guarantee and its revocation race. Source participant claims grant no authority.

Workers revalidate current generation, parent lifecycle, recipient/organizer authority, routes and expiry with fenced leases. Ambiguous acceptance retries the same transport ID and exact MIME/calendar bytes. Acceptance is not display or acknowledgement. Current reply resolution treats covered originals as cancelled while retaining prefix component versions and historical reply evidence. Restoration establishes new actual invitation versions; old RSVP values do not automatically become current. No imported alarm is armed and no real transport/provider trust is added.

## Remaining boundaries

Arbitrary single-only anchors, active-cutoff whole-series lifecycle, overlapping/partial suffix controls, bundled recipient reconciliation, RANGE replies, wider selected scheduling methods, organizer adoption/recipient changes and external-client interoperability remain separate roadmap work. Existing pure codecs do not establish those runtime capabilities.
