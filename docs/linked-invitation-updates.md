# Explicit linked invitation updates

Accepted [ADR 0139](adr/0139-explicit-linked-invitation-updates.md) extends [calendar addition](invitation-calendar-adoption.md) with explicit Apply update for a linked non-recurring REQUEST. The scoped implementation and batch validation are complete; see [the validation record](scaffold-validation.md). Receipt still only reopens private review. Applying sends no participation reply, creates no second event and grants no organizer authority.

## API and source ordering

`calendarInvitation.application(invitationId)` returns an independently authorized current view: actual calendar/event revisions, accepted source/version and application revision, local-change indication, current basic content/version, complete incoming source text and its native content projection, eligibility and the latest result. Ordinary event detail APIs supply the other native field groups. Incoming text is inert and is not fetched or rendered as links. The view never includes the private normalized baseline.

Application revision zero means the initial accepted creation source and does not create a checkpoint row. It is separate from a source's independently optional SEQUENCE. `canApply` describes current source/content eligibility; permissions, capacity, revisions and authority must still pass during the write.

`calendarInvitation.applyUpdate` takes an immutable request with invitation/source/link UUIDs and expected invitation/event/calendar/application revisions. The destination event/calendar comes from the stored link. No client recipient, authority flag, replacement event or overwrite option is accepted.

A new application requires the exact pending current source and a strictly newer version than the accepted descriptor: compare effective SEQUENCE (omission means zero for ordering), then DTSTAMP for equal sequences. Preserve the source omission and timestamp exactly. A higher SEQUENCE can carry an earlier DTSTAMP. Lower/tied versions, hidden or unavailable evidence, different correlation and stale selections reject. A repeated accepted version is not a new update; ordinary dismissal remains separate.

The same complete supported REQUEST-to-VEVENT conversion as calendar addition removes only METHOD. Preserve UID/organizer agreement, DATE/UTC/named-zone timing/end forms, source units, metadata, annotations, versions and omissions. Unsupported conversion rejects without discarding properties. Native imported origin and UUID remain unchanged; no participant address becomes a host identity. The ordinary omission defaults remain application defaults rather than new RFC claims.

## Local changes and atomic writes

Compare current normalized native content/overrides/protocol state with its accepted private import baseline. Local changes reject even a source with a much larger SEQUENCE. An identical normalized native save can advance its API revision without inventing a content conflict; the caller must still supply that new revision. There is no automatic overwrite or merge.

Event content/protocol state, the new private baseline, current checkpoint/latest result and dismissal of exactly that source version commit together under the shared database scope lock. Recheck complete host authority after proposed writes within the transaction. Denial, unavailable policy, changed actor/mapping, budget/revision overflow or guarantee downgrade rolls back every change. Multiple instances use the same lock and durable result, without process-local correctness assumptions.

Native API revision advances; database audit time remains nondecreasing and separate from exact source timestamps. Calendar metadata time/revision is unchanged. Scope generation and optional feed invalidation advance with the actual event change. Personal definitions/actions remain separate, survive the update and are replanned normally; incompatible anchors need attention. No incoming alarm is armed, and no notification or scheduling message is queued by application.

## Original creation versus current acceptance

The immutable creation link/receipt and its original source descriptor never change. A server-only `CalendarInvitationApplicationRecord` stores one checkpoint per link: trusted scope/recipient, application revision, accepted historical inbox/source references and digest/version, accepted baseline digest, creation-descriptor digest, created event/invitation revisions, application time and latest request/result UUID/digest. It contains no copied body/title/location or second canonical snapshot. The full current baseline remains only in active event data.

Before the first update, validate the initial baseline/version against the creation link. After an update, validate the current accepted baseline/version and stable UID/organizer through the checkpoint. Missing/corrupt/incompatible state fails unavailable, including a missing checkpoint after a newer accepted source. Do not silently fall back to an initial source or infer accepted history from native edits. Creation retries still return their original receipt after subsequent updates and local edits, subject to fresh authority.

## Latest result and expiry

The immutable `CalendarInvitationApplyReceipt` identifies the result/link/source/event/calendar, created application/event/invitation revisions and application time. Those revisions describe that result, not the event's later current state.

An exact retry of the latest complete request reauthorizes current link/event/source access and returns the same result. It makes no writes, replays no content, dismisses no newer review, changes no personal action and advances no revision/generation. It may succeed after later local edits because it reports an already accepted result rather than replacing them.

Only one latest command/result is retained. After another different application commits, older requests reject as stale/conflicting. Reload the protected application view to resolve uncertainty. This is not an arbitrary historical receipt ledger.

Inbox bodies/history keep their existing independent retention. After body expiry, host context marks the evidence unavailable and supplies the accepted descriptor/current native state; it never reconstructs the prior message. A host needing unavailable original evidence can fail unavailable. Source SEQUENCE omission stays distinct from zero even in retained descriptors.

## Host permissions and complete context

Independent invitation apply and application-read operations complement summary/source/link access. Native import/replacement plus full ordinary event disclosure and event-source read are required. Actual replacements additionally require the applicable native content, text/descriptive metadata and lifecycle permissions. Final write decisions must permit their mutation receipts; the first profile rejects blind results. Latest no-op retries recheck apply/import/replacement/full-read/source authority and receipt disclosure; they do not invent new field-change intents for a past write.

`CalendarInvitationPolicyContext` separates original `linkSource`, current/proposed `CalendarInvitationApplicationState`, incoming source/message, current/proposed native snapshots, immutable request/result and proposed baseline. Current queue state stays separate from proposed dismissal. Native replacement contexts retain the actual prior snapshot/version. Registry/address/source claims alone establish no authority. Coordinated/fresh-check guarantees remain explicit, including the external after-check revocation race.

Generic file replacements remain blocked for linked events on every host, even with invitation ingress disabled. Ordinary native edits/deletion and canonical export retain their own gates. The example verifies only its synthetic namespace/organizer/current recipient, not real mailboxes.

## Bounds, deployment and remaining work

One checkpoint per bounded link adds no unbounded history. The existing default 1,024 links per recipient includes retained deletion markers. Native deletion scrubs active event content/baseline/personal alarms; content-minimal link/checkpoint references remain and cannot recreate the event. Inbox/source references are historical, without FK pins. Link purge/relink and retention removal still need separate review before release.

Upgrade all participating module hosts before enabling checkpoint updates; mixed old/new rolling behavior is not claimed. Generated fresh/populated migrations add an empty checkpoint table and invent no application history. APIs are unpublished.

The example shows current content, complete incoming source and explicit Apply update, retains the request for uncertain retry, reloads stale state explicitly and blocks local conflicts. Reviewed overwrite/merge, recurring/CANCEL intake, participation responses, organizer adoption, mail and external-client conformance remain separate required work.
