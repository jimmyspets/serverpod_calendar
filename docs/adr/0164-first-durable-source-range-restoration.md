# ADR 0164: First durable source range restoration

Status: **Proposed. Restore-only/same-cutoff/preserve-retained-values policy and the ADR 0163 pure validator are approved; the following storage/API/retry mechanics require explicit agreement.**

## Context and first scope

[ADR 0163](0163-pure-restore-only-range-source-projection.md), implemented in PR #157, adds pure matching of a newer THISANDFUTURE REQUEST at the saved cancellation original. Its local grouped checks passed; full implementation-head CI is tracked separately. It clears only the cutoff in a candidate while preserving exceptions, nominal timing forms and native versions. Current durable services deliberately reject that source restoration.

Add an explicit first `applyRangeRestoration` command and protected `rangeRestorationApplication` preview, using the existing occurrence apply request/receipt and view types. Require an accepted v4/v5/v6 source cancellation, an active accepted master REQUEST, and a current exact same-cutoff REQUEST that passes the pure matcher. A cancelled whole master must first use the existing explicit newer master reopening. Different anchors, rescheduling, replacement cancellation, multiple restoration cycles and broader range composition remain separate.

Receipt/review still changes no calendar and sends no reply. Native local restore remains a local edit, not source acceptance. Do not infer accepted cancellation history from the event's native cutoff or an ordinary import baseline.

## Authority, clean state and versions

Introduce independent host operations `readRangeRestorationApplication` and `applyRangeRestoration`. Retain the applicable existing source/link/master/range-read and composition authority, including `composeAcceptedRangeCancellation` and `composeAcceptedOccurrences`. Require native importEvents, replaceEventsFromImport, updateEvent, changeEventStatus, full detail disclosure and readEventSource. A host may map these operations to one policy, but the module must keep them distinct.

Authorize actual current restoration and accepted cancellation source identities separately, with preliminary/final immutable current/proposed context. Accepted evidence remains private when queue bodies are pruned; use its real stored descriptors and bytes, never a fabricated current-notice identity. Preserve the declared coordinated/external-fresh-check guarantee and fail unavailable when source evidence cannot be validated.

Require the entire current native series to match the verified expected masked state, including protocol state and individual edits. A local cutoff clear, content edit or recurrence change is a conflict. A coincidentally matching title or timing at the selected original cannot prove a clean series. Use expected calendar/event/master/occurrence/invitation revisions and the existing shared scope transaction/fencing.

Validate the current checkpoint and replay its original cancellation against its original frozen basis before deriving the current retained masked candidate. Pass the independently verified cancellation version and current canonical protocol versions to the ADR 0163 helper. Require exact original/profile/membership, matching retained uncancelled values and a strictly greater restoration SEQUENCE than its conservative floor. Later timestamps do not waive that floor. Keep restoration source versions separate from unchanged native master/single/future versions.

## Bounded private v7 checkpoint

Reuse the existing occurrence-application table and its JSON column. Propose a v7 envelope containing one `preRestoration` checkpoint descriptor (prior revision, eventRevision, updatedAt and complete validated v4/v5/v6 state), one restoration layer, current master/baseline/expected-native bindings, and the current command/receipt bindings. Store the predecessor state once, not a recursive history chain or duplicated target list. Reject a v7 predecessor, unexpected nesting, missing fields, marker-only upgrades or fallback to a cutoff-free legacy interpretation.

The predecessor retains the existing original cancellation source, source version, frozen basis where applicable, canonical accepted targets and historical receipt evidence. Replay its strict existing validation using its recorded row revision/time and current unchanged ordinary baseline/master binding. Its expected masked candidate must equal the restoration input. Historical source/basis data remains private until linked event deletion within the current caps; it is not exposed in ordinary event views/exports.

The new layer binds exact typed range original/key, invitation/source IDs, normalized source text/digest, verified recipient address, independent source version, required comparison floor, predecessor digest, accepted database time and expected cleared native digest. Use distinct v7 command, evidence and receipt hash domains tied to scope/recipient/link/calendar/event/UID/organizer. Recompute the pure restoration from the verified predecessor candidate and compare the full candidate/evidence/receipt bindings on every decode. Do not merely trust a stored `restored` marker.

Keep the ordinary event import baseline unchanged and cutoff-free. The restored native candidate matches that canonical content/protocol state; restoration neither adds a source component nor overwrites the master protocol version. The v7 envelope remains the authoritative independent restoration source checkpoint for later reviewed composition, not an ordinary imported file baseline.

Enforce existing complete JSON byte ceilings (4 MiB/link, 16 MiB/recipient, 64 MiB/scope, configurable downwards), source-body/work/native-slot limits and source retention rules. Charge the complete predecessor-plus-layer representation before writing. Reject atomically rather than pruning evidence to fit. No SQL table/column, migration, dependency, cap expansion or unbounded command history is proposed. Event deletion scrubs the whole active checkpoint; minimal markers/inbox retention retain their separate policies.

## Atomic effect and stable retries

Atomically clear only the cutoff, store v7 acceptance, advance event/checkpoint revisions and database audit time, dismiss only the selected current notice and invalidate scope/feed/alarm generations and outstanding leases. Retain calendar metadata time, native component protocol versions, all single cancellations, timing/content/annotations, personal alarm definitions/actions and native assignments/associations. Send no scheduling response and arm no source alarm.

Reuse existing native restoration query/free-busy/feed/reminder semantics. Representable feeds/exports may become available again under fresh authority; do not bypass other unrepresentable-state checks or permit stale 304 responses. Plans may use newly eligible current occurrences under existing grace/expiry rules. Preserve accepted-firing deduplication across generations, acknowledgements/dismissals/reset/snooze state and independent absolute item-level alarms; restoration does not authorize replay of accepted reminders.

Use the existing one latest occurrence-command slot with a distinct restoration criteria digest. An exact retained restoration retry reauthorizes current source/link/native/private access and returns its original receipt without re-clearing a cutoff, dismissing a newer notice, changing revisions/generations or rearming reminders. Later local edits do not turn a retry into a new apply. The prior occurrence command, including the original range cancellation, is superseded under latest-only semantics and cannot reapply its historical effect; its retained predecessor receipt is validation evidence only. Existing exact latest master-command retries remain separately recognized and write-free. Changed criteria or command-kind reuse rejects.

Before admitting a new command, lock and recheck current source/revisions/clean state/authority; same-command competitors converge on one receipt, different commands cannot both apply, and process loss before/after commit cannot produce a second effect. Preserve actual database time and shared-storage fencing rather than process-local coordination.

## Views, generated clients and temporary guard

Reuse `CalendarInvitationOccurrenceApplicationView` and add default-false derived `hasAcceptedRangeRestoration` to it and the master application view. Keep `hasAcceptedRangeCancellation` as protected evidence that a source cancellation was accepted; after restoration both flags may be true. Native cancellation state, rather than either history flag alone, determines which originals are currently suppressed. Update labels accordingly and disclose the flags only after required raw-source authority.

The new dedicated preview explains exact current/proposed occurrence, independent accepted/incoming versions, local conflicts, restoration eligibility and latest restoration result. Existing ordinary range update APIs do not silently become restoration commands. Flutter offers an explicit Apply range restoration action, preserves the command across uncertain retries and explains that individual cancellations survive.

For this first v7 profile, block every new master/single/range source application after restoration, including another cancellation/restoration, until the following composition contract carries its independent version/evidence forward. Apply these guards after authorization and retained-retry recognition. Ordinary native edits, review/dismissal and independent participation retain existing boundaries; do not label this guard as an active cancelled suffix. Later composition and restoration cycles remain required work, not implicitly supported by v7.

## Validation and acceptance

After explicit approval, regenerate the two derived view fields and new endpoint/client/test APIs using the pinned toolchain; no migration is expected. Test DATE/UTC/named zones/DST, earlier/PERIOD originals, single/future anchor forms, retained individual cancellations and independent/equal/lower/max/omitted versions. Cover clean/dirty/native-restored conflicts, actual source identity and preliminary/final authority, atomic rollback, v4/v5/v6 to v7, every predecessor/source/candidate/receipt binding, unsupported nesting, byte/work/slot limits, pruning/deletion and blocked new applications.

Verify exact restoration/master retries after newer notices and local edits, prior occurrence-command supersession, same/different-command races and process loss before/after commit across two hosts. Exercise generated clients, connected Flutter, fresh free/busy/query/feed/no-stale-304 behavior and reminder generation/action/non-replay boundaries using synthetic adapters. Use focused tests during development, grouped checks before one complete code commit and full repository CI before readiness. No real email, outgoing range restoration, ordinary masked wire mapping or broader reconciliation follows from approval.
