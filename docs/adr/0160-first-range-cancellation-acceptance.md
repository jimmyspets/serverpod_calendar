# ADR 0160: First durable incoming range cancellation

Status: **Proposed; the maintainer confirmed cancel-all/preserve-exceptions and newer-than-all-affected version policies. Concrete acceptance, storage, API and temporary composition guards await explicit approval.**

## Context and scope

ADRs 0158/0159 implement native cutoffs and a pure first-cancellation proposal. PR #149 contains the pure implementation: grouped local checks passed; exact-head hosted runtime CI remains separate. An incoming range CANCEL still cannot be applied. Existing source baselines are deliberately cutoff-free, and canonical master/occurrence versions must not be overwritten by the cancellation's independent source version.

Inspected occurrence acceptance v1/v2/v3, typed targets/component/source/receipt hashes, current-state comparison, existing immutable views/request/receipt, host/native gates and cleanup/invalidation. Existing checkpoints retain canonical component data rather than replaying historical messages. This proposal adds a separate first cancellation layer in that same checkpoint.

Implement one accepted range cancellation per linked series in this first batch. It may coexist at the same original as a retained single or range REQUEST, because it suppresses rather than replaces that component. Keep later master/single/range messages reviewable but block new source application commands after acceptance until composition/reconciliation is designed. The latest cancellation receipt and independent master receipts remain retryable; older occurrence commands are superseded under the existing latest-only rule. This is a temporary explicit limitation, not completed range reconciliation.

## Explicit command and authority

Add `calendarInvitation.applyRangeCancellation`, reusing `CalendarInvitationOccurrenceApplyRequest` and its expected invitation/source/link/calendar/event/master-application/occurrence-checkpoint revisions. Require the selected actual notice to be a known-series THISANDFUTURE CANCEL; `applyRangeUpdate` still rejects CANCEL. Match actual parents, recipient, source digest and original rather than client-claimed relationships.

Add dedicated host operation `applyRangeCancellation`, alongside existing range-application/source/link/master/raw-read rights. Require the current single-cancellation native gates: importEvents, replaceEventsFromImport, updateEvent, changeEventStatus, full event disclosure and readEventSource. Ordinary source-projection/authorization guarantees, preliminary/final checks, immutable current/proposed snapshots, deadlines and receipt protection remain. The host sees the exact cancellation, retained basis, candidate native cutoff and proposed private checkpoint as distinct data. Reading accepted cancellation information requires fresh readSource authorization for its actual stored invitation/source, including when inspecting a different notice; do not disclose its existence before those checks.

Before first acceptance, require the entire current native series to match its accepted cutoff-free basis and have no native cutoff. Invoke the approved pure helper against that verified basis, under aggregate bounds, preserving strict source SEQUENCE rules including underlying and later components. Source timestamps remain exact and do not replace database audit time. Exhausted work is not proof of membership, absence or freshness.

## Existing-table version-four checkpoint

Reuse `CalendarInvitationOccurrenceApplicationRecord.stateJson`; add no SQL table/column/index, cancellation history store or retention expansion. First cancellation writes JSON v4. Valid v1/v2/v3 reads/hashes stay unchanged. Upgrade writers together.

Keep the existing cutoff-free `masterBaseline`, composed-basis digest, master binding and canonical `targets` unchanged. Add one `rangeCancellation` object binding the exact typed range original, invitation/source IDs, recorded recipient address, normalized source/digest, exact cancellation version, computed requiredAfterSequence and cutoff-free basis digest. Retain the bounded source copy so inbox body pruning does not destroy acceptance evidence.

Add `expectedNativeDigest`, calculated from validated candidate native content/overrides/protocol state, including the cutoff and source-presence distinctions but excluding API revision/audit time. Its binding includes link/parent/event/recipient identity, basis and cancellation source/version. Decoder must reconstruct the candidate from the retained cutoff-free basis and source using the pure helper, verify the version floor and binding, and then compare actual native state separately. Never treat a matching native cutoff as proof of source acceptance.

Keep the event's ordinary `importBaseline` cutoff-free and unchanged; do not store a masked candidate as an accepted file-import baseline or weaken its validator. The private layer supplies the expected native state for invitation-specific local-edit comparison. A clean accepted source cutoff therefore reports no local edits in those views. Ordinary file-replacement paths remain unable to overwrite this accepted cancellation without a separate reconciliation design.

Version four requires `latestLayer=rangeCancellation`, the exact typed `latestTargetKey`, criteria digest and a receipt/source/basis/native binding. Keep the existing latest-only per-link occurrence-command slot across command kinds; accepting this cancellation supersedes older occurrence-command receipts normally. A marker-only upgrade, missing layer, wrong kind/original/profile/version/source/recipient/digest or inconsistent receipt fails unavailable, with no legacy/flattened fallback. Preserve canonical target hashes and independent source versions, including a REQUEST component at the same original.

Keep existing combined 128-slot native limit (the cutoff costs a slot), source/work limits and 4 MiB/link, 16 MiB/recipient, 64 MiB/scope checkpoint ceilings with configurable lower limits. Charge the complete v4 representation before writing; do not delete evidence to fit a quota. Event deletion scrubs the active checkpoint/source copy; inbox retention and minimal identity markers keep their separate rules.

## Atomic native effect and retry behavior

Atomically store the candidate cutoff/private acceptance, advance event and checkpoint revisions/database audit time, and dismiss only the selected current notice. Preserve master/exception content, timing, flags, UID, component protocol state and the event's cutoff-free import baseline. The source cancellation version lives in its separate layer; it is not copied onto the native master or an exception.

Advance scope/feed publication generation even though retained component protocol versions do not change. Invalidate alarm plans/leases and enforce current-source checks through ADR 0158's complete query/busy/reminder integration. Export/feed/new REQUEST rejection and no stale 304 remain. No scheduling response, notification text copy, alarm arming or real sending follows.

Use a distinct range-cancellation criteria domain. Exact retained retries reauthorize current actor/recipient/source/link/native/private state and return the original receipt without mutation, revision/generation changes, supersession or dismissing a newer notice. Local edits after acceptance do not let a retry reapply the cutoff. Master command receipts remain a separate retained slot: historical exact master retries also remain non-mutating and cannot clear the cancellation.

Native edits remain local drafts: changing/restoring the cutoff never changes the accepted source cancellation layer. Such state reports a local conflict against the complete expected native candidate. Native local restoration is not acceptance of a source reopening and sends no reply. New source commands remain blocked even if local edits happen to clear the cutoff.

## Views and temporary guards

Reuse `rangeApplication` for protected preview/application eligibility. Add derived default-false `hasAcceptedRangeCancellation` to `CalendarInvitationOccurrenceApplicationView`. At the accepted cancellation notice, existing acceptedVersion/kind/sourceText/latestResult fields describe its independent source layer; elsewhere preserve existing component fields and expose the derived guard only after required source authorization. Effective current/proposed occurrence status reflects cancellation without changing master status.

Master application views reuse `occurrenceCompositionBlocked` and compare local state against the verified complete private candidate. New master REQUEST/CANCEL/reopen, single update/cancellation and range update/cancellation applications reject while this layer exists. Guards apply after authorization and retained-retry recognition. No later source message, larger SEQUENCE or native cutoff removal implicitly restores or replaces the accepted cancellation. Reviews/dismissal and independent ordinary native editing retain their existing boundaries; no new range response operation is added.

Flutter offers an explicit Apply range cancellation action for an eligible first CANCEL, keeps the same command across uncertain retries, explains retained data/local-only actions and displays the protected composition limitation. It must not present new blocked source commands as restoration. Subsequent cancellation replacement, multiple cancellation anchors, master composition and explicit source restoration require the following contract.

## Validation and acceptance

After explicit maintainer approval, regenerate ordinary view/endpoint/client/test sources with the pinned toolchain. Test DATE/UTC/named zones, DST, earlier/PERIOD originals, co-located and later components, strict/equal/max/null source versions, clean/local-cutoff conflicts, immutable/final authority and complete rollback. Cover v1/v2/v3 to v4, every source/basis/native/receipt binding, quotas/pruning/deletion, clean expected-overlay comparison, native edits/restoration, blocked new commands and retained master/occurrence retries without notice dismissal.

Exercise actual two-host same-command/competing-command races and loss before/after commit, fresh reminder/live/snooze withdrawal, actual HTTP feed/no-304 behavior, generated clients and Flutter. Use focused development tests, broader grouped checks before one completed-batch commit and full repository CI before readiness. This batch does not implement source composition/restoration, outgoing range CANCEL, ordinary wire mapping, range replies, tasks/openings or real mail.
