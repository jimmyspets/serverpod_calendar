# Explicit occurrence invitation application

Accepted [ADR 0151](adr/0151-explicit-single-instance-invitation-application.md) adds explicit recipient calendar application after [private instance review](single-instance-invitation-review.md). Receipt and dismissal remain review-only. Applying a notice sends no participation response or invitation and never arms an imported alarm. This is a bounded recipient workflow, not complete scheduling reconciliation.

The authenticated `calendarInvitation` endpoint exposes `occurrenceApplication`, `applyOccurrenceUpdate` and `applyOccurrenceCancellation`. The preview resolves the actual host recipient and stored correlation/link/calendar/event; clients supply no trusted parentage. An instance must already have a linked recurring master. Master-only APIs still reject instance entries.

## Application and conflicts

An explicit command identifies the invitation, source and link plus expected invitation, calendar, event, master-application and occurrence-checkpoint revisions. A missing occurrence checkpoint has revision zero. The server verifies exact original identity/profile/membership, source correlation, supported [pure projection](instance-invitation-projection.md), current pending selection and independent authority.

**The entire linked series must match its accepted normalized source baseline.** Any actual local master or occurrence change blocks application. An identical normalized native save may advance API revisions while remaining clean; the command must use the new revision. No overwrite, merge, retargeting or lost-local-edit fallback is implemented.

REQUEST replaces only the selected single occurrence's supported timing and own text. CANCEL sets only its cancellation flag, retaining accepted timing, content and inheritance; supplied fields must agree. Minimal or duration-only cancellation remains separately preserved source data without an invented DTSTART. Reopening requires an explicit newer REQUEST and lifecycle authority. Master protocol values and unrelated originals/versions stay unchanged.

Accepted versions use the exact single component, otherwise its active future timing component, otherwise the master. Omitted SEQUENCE compares as zero but stays absent. REQUEST must be strictly later by SEQUENCE then DTSTAMP; cancellation and reopening must also increase SEQUENCE over the accepted component. Review-queue ordering alone is insufficient.

Event content/protocol state, complete baseline, event revision/audit time, scope/feed invalidation, private checkpoint and dismissal of exactly the selected source commit together under the shared scope transaction. Calendar metadata revision/time and personal alarm/action state are preserved. Reminder workers continue their ordinary generation/access/cancellation revalidation.

## Acceptance storage, retention and retries

`CalendarInvitationOccurrenceApplicationRecord` is a server-only row unique by link. Its version-one JSON retains frozen master acceptance and checksum, a digest binding the unchanged master checkpoint/creation link, current composed-baseline digest, up to 128 typed original targets and one latest occurrence-command result per link. Each target keeps its latest normalized accepted source, independent optional protocol values and canonical component fingerprint. It is current acceptance state, not an append-only history.

| Bound | Default and initial hard ceiling |
| --- | --- |
| Encoded checkpoint per link | 4 MiB |
| Checkpoints per recipient | 16 MiB |
| Checkpoints per host scope | 64 MiB |
| One retained normalized source | 256 KiB |
| Retained exact original targets per link | 128, also constrained by bytes and native override capacity |

Trusted `CalendarInvitationOptions` can lower the three checkpoint byte limits. Quota checks share the scope lock across hosts; exhaustion rejects atomically without pruning accepted originals. Source bytes count within the aggregate JSON ceiling, including encoding overhead and the frozen baseline.

Latest accepted sources survive ordinary inbox-body pruning while the linked event is active. Ordinary 30-day queue cleanup does not expire this acceptance evidence. Replacement overwrites only the selected target's previous accepted source. Event deletion atomically scrubs this row, copied source and frozen baseline; the existing invitation link and content-free native event deletion marker remain under their prior policies. There is no archive/restore, relink or new permanent history promise.

An exact latest command retry is recognized before new-source/revision eligibility and reauthorized using retained accepted evidence and actual current context. It returns the same result without replay, revision/generation change or dismissal of newer notices. Another successful occurrence application, including a sibling original, supersedes that single per-link retry slot. Older commands then reject stale. Existing master and creation receipts remain separate and retain their non-mutating retry behavior.

## Master composition and authorization

**New master Apply update/Apply cancellation is guarded once an occurrence acceptance checkpoint exists.** A complete replacement would otherwise discard accepted exceptions. The master preview reports `occurrenceCompositionBlocked`; it does not misclassify that state as a local edit or corrupt checkpoint. Master intake/review, participation actions, retained exact retries and native local edits remain available. Master/instance composition is the next separate required batch; this guard does not complete that reconciliation requirement.

Independent invitation operations protect reading occurrence application, applying an update and applying cancellation, in addition to summary/source/link/master-application access. Native full event/detail/source disclosure, import/replacement/update and applicable metadata/lifecycle rights also apply. Reopening requires lifecycle permission even though the master stays active. Preliminary checks precede private conflict/version/quota classification; final checks include immutable actual current/proposed event, source, link, master acceptance, complete checkpoint and receipt. Host context owns trusted recipient/scope resolution and the declared coordinated or fresh-external guarantee; a final external check retains its documented revocation race.

The client preview shows the selected original, current native and proposed effective occurrence, accepted/incoming versions, protected selected source text, revisions and apply flag. It exposes neither sibling source bodies nor totals. Cancellation remains explicit in current/proposed occurrence status. All source text is inert: no URI fetching, participant authority, source alarm execution or automatic reply follows.

## Example, upgrade and evidence

The Flutter invitation list opens **Preview / apply occurrence notice**. The screen separates original from replacement timing, explains clean-series conflicts and the master-composition guard, retains uncertain command fields for retry and offers an explicit reload. Synthetic simulators use the same authenticated endpoints and host MIME boundary.

The generated module migration is `20261031120611007-instance-invitation-application`; the example migration is `20261031120641063-instance-invitation-application`. Existing links acquire no acceptance row or invented history. Upgrade all hosts and generated clients together; mixed old/new writers are unsupported.

Focused database tests, populated upgrades, independent-host/process-loss probes, generated-client and connected Flutter journeys are wired into `tool/check.ps1`. [Validation](scaffold-validation.md) records actual outcomes and any deferred checks. Instance replies, master/instance composition, RANGE, participant changes, overwrite/merge and real mail remain separate release work.

For focused UI work after the normal host/browser setup, run `dart run tool/host_smoke.dart --browser-only --flutter --occurrence-applications`. The complete root check still runs the full connected journey. Progress remains visible in the app bar while long source text is scrolled; Reload and uncertain-command retries wait for the current request to finish.
