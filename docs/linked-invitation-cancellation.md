# Explicit linked cancellation application and reopening

Accepted [ADR 0148](adr/0148-recurring-master-invitation-workflow.md) extends this workflow to the bounded [recurring-master recipient profile](recurring-master-invitations.md). Its earlier non-recurring-only statements below are superseded for that slice; instance/range/bundled reconciliation and real mail remain separate. Actual batch checks are recorded in the validation guide.

Accepted [ADR 0141](adr/0141-explicit-linked-cancellation-application.md) adds a dedicated cancellation action and later explicit REQUEST reopening to the existing [linked update flow](linked-invitation-updates.md). Implementation is under batch validation; see [the evidence](scaffold-validation.md). [Receipt/private review](invitation-cancellation-review.md) still changes no calendar event and sends no participation reply.

## Command, projection and source distinctions

`calendarInvitation.applyCancellation` accepts the existing immutable CalendarInvitationApplyRequest: actual invitation/source/link UUIDs and expected invitation/event/calendar/application revisions. The server resolves the actual destination and trusted actor/recipient. It requires the exact pending current supported non-recurring whole-meeting CANCEL, matching UID/organizer/correlation and a strictly newer accepted source version. Cancellation must increment a known REQUEST SEQUENCE; later cancellation versions are ordered against accepted cancellation using SEQUENCE then DTSTAMP.

The current normalized native content/overrides/protocol state must equal its accepted private baseline. Local text, timing or lifecycle edits reject. An identical normalized native save can advance API revision without creating a content conflict, but the caller must reload its expected revision. No overwrite or merge is inferred.

Application retains event UUID/UID, imported origin, timing/end/duration meaning, text/descriptive fields, source participants/references and unarmed source alarms. It sets status CANCELLED, marks STATUS present and installs the cancellation's exact source protocol version. Omitted CREATED/LAST-MODIFIED become absent protocol values; database creation/audit times remain separate. Optional non-lifecycle cancellation properties remain protected raw source-review data and do not replace canonical event fields. No standalone event is manufactured from missing timing or METHOD removal.

The new baseline records this complete agreed native projection. It does not claim that the source supplied a complete standalone VEVENT. Ordinary export/feed serialization represents current canonical event state; protected source review preserves the normalized CANCEL separately under its existing bounded retention. Source addresses never become host identities or organizer authority.

## Atomic acceptance and retries

Event projection, private baseline, kind-aware acceptance checkpoint/latest receipt and dismissal of exactly the selected source commit together under the shared database scope lock. Final complete policy checks run after proposed writes within the transaction, followed by actor/recipient/guarantee validation. Denial, unavailable evidence, changed source/revisions, budget/revision overflow or policy downgrade rolls back all changes.

Event/API revision and nondecreasing database audit time advance; parent calendar metadata/revision stays unchanged. Scope generation and optional feed invalidation advance. Source protocol timestamps retain exact values, including permitted regressions. Personal alarm definitions/actions remain unchanged; ordinary fresh source/generation checks withdraw cancelled reminders. No notification, scheduling publication or mail is queued by this action.

CalendarInvitationApplicationRecord adds kind to its existing one-per-link table. Legacy rows default to request because the previous accepted commands handled REQUEST only. Kind must agree with the validated saved projection/baseline; it is not inferred from a later native status edit. No new table, copied body, second snapshot or expanded history/retention is added.

CalendarInvitationApplicationView exposes acceptedKind and canApplyCancellation; incoming kind/text, current content and accepted source remain separate. canApply/canApplyCancellation describe eligibility, not guaranteed permission. CalendarInvitationApplyReceipt and host-only immutable application state carry accepted kind. Native API revision, application revision and independently optional source SEQUENCE remain separate.

REQUEST digests retain their existing encoding. Cancellation digests use a literal action prefix in the length-framed encoding, disjoint from the UUID-led REQUEST form. The single latest accepted command/result now spans both actions. An exact latest retry reauthorizes and returns the same kind/result without replaying content, dismissing a newer source, changing alarms or advancing revisions/generation. It may report a past result after later local edits. Cross-action calls cannot alias a receipt. After another application commits, older commands reject; this is not a historical receipt ledger.

When a later inbox epoch has been pruned, the frozen command's durable link ID is loaded only within the actual trusted scope/recipient and fully revalidated. Exact digest/kind/native/source authority still gates result recovery; a missing entry cannot authorize a new write. For protected current views after pruning, the immutable original creation invitation ID remains a stable lookup. Historical accepted bodies are explicitly unavailable when pruned, never reconstructed; a host requiring missing evidence may fail unavailable.

## Authority and reopening

Require independent applyCancellation plus summary/source/link/application-read permission. Native import/replacement/update/full-detail/source-read and lifecycle rights are required for every cancellation command, including a new cancellation version on an already-cancelled item and retained no-op retries. Final mutation receipts must be disclosed; blind cancellation is outside this first profile. REQUEST updates retain their existing applicable field/lifecycle checks.

Host context contains the actual collection/current event, immutable original creation descriptor, current/proposed kind-aware acceptance, incoming source, validated proposed native projection/baseline and action result. Transport receipt never fabricates a native actor. Coordinated and external fresh-check guarantees remain explicit, including the latter's after-check revocation race.

A later strictly newer current REQUEST may reopen only through explicit Apply update with a clean baseline, matching revisions and lifecycle authority. It replaces complete supported contents from that REQUEST; receipt alone changes nothing. Ordinary local reopen sends nothing and makes the accepted baseline dirty. Generic file replacement of linked events remains blocked on every host.

## Example, rollout and remaining work

The example distinguishes received cancellation, current native status and last accepted source kind. Apply cancellation previews retained content plus status/version change. Pending retries keep both request and action stable; explicit Refresh reloads current source/state. Later eligible REQUESTs offer Apply update / reopen. Local conflicts disable both source-write actions.

Pinned generated migrations are module `20261029183429540-cancellation-application` and example `20261029183508485-cancellation-application`. Upgrade every participating host before enabling the kind-aware actions; mixed old/new hosts are unsupported. Development data is not reset. Focused and populated-upgrade evidence is recorded separately from broader checks.

Recurring/instance/range inbound lifecycle, attendee removal, participation responses, reviewed overwrite/merge, organizer adoption, link purge/relink, RFC 6047 mail and external-client conformance remain separate required work.
