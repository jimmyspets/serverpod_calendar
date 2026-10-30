# ADR 0148: Recurring-master invitation review, application and responses

Status: **Proposed on 2026-10-30. The complete workflow, storage and validation mechanics below require explicit maintainer agreement before implementation.**

## Context and inspected evidence

Accepted ADRs 0137–0141 implement private non-recurring REQUEST/CANCEL review, stable explicit calendar addition and clean-baseline source application/reopening. ADR 0146 adds independent explicit attendee responses and durable synthetic delivery. ADR 0147 completes its bounded calendar occurrence-query batch in implementation commit `5d57ae9` / PR #124. Original first-release scheduling requirements remain incomplete.

Source inspection found the current non-recurring restriction in `CalendarInvitationOperations._invParse`, cancellation checkpoint validation in `_invCheckpoint`, and application eligibility. Adoption already projects a REQUEST through the ordinary supported event adapter, while response payloads independently identify the source master and recipient. Extending only the parser would leave application, cancellation, review and worker assumptions inconsistent. This proposal groups the recurring-master path end to end, using focused checks during development and one full check/commit after the group.

Primary sources checked 2026-10-30: [RFC 5546 REQUEST](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.2), [REPLY](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.3), [CANCEL](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) and [message sequencing](https://www.rfc-editor.org/rfc/rfc5546.html#section-2.1.5). A whole-series cancellation omits RECURRENCE-ID; instance/range cancellation is a different target. The narrow message shape, immutable mode, review workflow and limits below are project profile choices, not claims that the RFC forbids wider messages.

## Proposed supported group

Accept one supported recurring VEVENT master in a trusted REQUEST, retaining the existing DATE/UTC/named-zone profile, RRULE, start-only or supported timed PERIOD RDATE, EXDATE, source text/metadata and independently optional source versions. Use the existing pure scheduling and standalone event adapters to validate the complete master and matching VTIMEZONE coverage. Preserve source distinctions and regenerate only the existing authorized envelope boundaries; never expand into stored individual events or drop unsupported input. Existing non-recurring messages remain supported.

Require exactly one master and no RECURRENCE-ID or occurrence components. Reject detached instances, bundled exceptions, RANGE messages, recurrence-mode conversion, delegation/SENT-BY and other currently unsupported profiles explicitly. PUBLISH/ADD/REFRESH/COUNTER/DECLINECOUNTER application, instance/range reconciliation and participant removal remain separately required. No real mail or automatic imported-alarm adoption follows.

The recurring classification follows the validated canonical recurrence profile, including supported explicit-date sets, rather than the visual number of occurrences or a client boolean. An explicitly bounded one-occurrence recurrence remains a recurring master. Do not infer recurrence from a minimal CANCEL.

## Proposed private mode field and compatibility

Add **one non-null `recurring` boolean, default false, to the existing server-only CalendarInvitationRecord**, plus a read-only boolean on CalendarInvitationView. No new SQL table, index, copied recurrence cache or response table is proposed. Generate module/example migrations and all clients/test tools from their sources. Existing rows are known non-recurring under the previous accepted profile, so the false upgrade value is evidence-based; it invents neither recurrence nor progress/response history.

Set the mode from the first validated REQUEST and keep it through newer sources, CANCEL, dismissal, pruning and retained correlation markers. Recompute and verify it against retained REQUEST bodies when present. A message proposing a different mode for an existing retained correlation rejects atomically, even if its SEQUENCE is higher; conversion needs a separate reviewed transition. A minimal whole-series CANCEL preserves the known mode. Correlation remains exact UID/organizer within trusted scope/recipient, with no authority inferred from those values.

A private calendar link may outlive its queue marker. Before recreating a correlated review entry, compare the incoming mode with the link's validated accepted-source baseline/checkpoint. Current locally edited content cannot supply that source-history proof. Missing or inconsistent proof fails unavailable rather than guessing. Existing deletion markers still prevent silent re-creation of a calendar event. This batch does not introduce a new purge/adoption policy.

All existing source/receipt byte/count limits, reference pinning, 30-day terminal retention, unique keys and stable retry receipts remain unchanged. No baseline/checkpoint digest format is changed merely to add an inbox presentation flag. Unknown/corrupt mode/body/checkpoint combinations fail closed.

## Proposed intake, calendar application and cancellation

Receipt remains private review only: it creates no calendar event, booking, response or alarm intent. Reuse verified organizer/recipient ingress, independent source/summary/action authority, immutable actual-source/current/proposed host context, scope transactions, version ordering and duplicate/stale/conflict handling. Final denial rolls back the whole command. External fresh checks retain their documented after-check revocation race.

Explicit Add to calendar creates one imported-origin recurring event series in one selected calendar through the existing stable link. Retain source UID, recurrence/date/PERIOD meaning, annotations and protocol versions in the existing event/source/baseline storage. Imported alarms stay unarmed. Retried addition returns the original event/receipt after fresh authorization; no additional copies or organizer binding are created.

Explicit Apply update replaces the complete supported master only when its selected source is current, strictly newer than the accepted source and the recorded baseline is clean. Existing expected revisions, independent permissions, atomic event/checkpoint/review writes and latest-result retry rules remain. Local master edits or occurrence timing/content/cancellation edits constitute conflicts; reject without clearing or retargeting them. A source pattern edit may change recurrence membership only after those checks. Receiving the update or saving a local edit sends nothing.

Accept a correlated whole-series CANCEL with the existing minimal cancellation profile, no RECURRENCE-ID and no recurrence pattern. Require the established accepted-version checks and verified sender/recipient authority. Explicit Apply cancellation requires a clean baseline, preserves the accepted recurring schedule/content, and projects cancelled status plus the supported incoming version/omissions. Receipt alone still changes nothing. A strictly newer current REQUEST reopens only through explicit Apply update; ordinary source receipt, response sending or local reopening cannot silently accept it.

The checkpoint validator must permit the preserved accepted recurrence on a cancellation baseline while continuing to verify UID, organizer, kind, source version, baseline digest and stable link. It must not treat any cancelled recurring baseline as proof of a known invitation. Personal alarms and free/busy use the existing parent-state revalidation; no new generation or dispatch shortcut is introduced.

## Proposed attendee sending and example

Accept/Tentative/Decline target the complete selected master invitation, independent of calendar addition/application. Emit the existing minimal master REPLY with no RECURRENCE-ID, no copied recurrence pattern and no invented timing. Echo source SEQUENCE presence/value, retain the strict later database-second command rule, and use the host-verified current recipient and organizer route. An old choice is not automatic acceptance of a changed recurring request.

Reuse response state/delivery/attempt rows, source pins, expected revisions, command UUID retries, bounded fenced workers and fresh source/route checks. A new current source or whole-series CANCEL withdraws pending work under existing rules; exact historical command retries remain protected receipt reads, never new sends. Synthetic MIME loopback must reach the existing recurring-master organizer reply handler without editing organizer drafts or per-instance responses.

Show a read-only **Recurring series** label on protected invitation views and explicit whole-series wording on response/cancellation/application controls. The existing first timing remains the master timing, not a claim that only one occurrence exists. Full source inspection retains its independent permission. After adoption the event screen and bounded occurrence query show the stored schedule. New synthetic fixtures and generated-client/Flutter journeys exercise the complete workflow, including declining without adopting. No reusable GUI package or real provider transport is added.

## Alternatives and consequences

A parser-only extension would admit sources that later actions and workers cannot safely handle. Implementing every detached/bundled instance and range transition together would require independently versioned recipient targets and membership/reconciliation rules beyond this master batch. A new recurring-invitation table would duplicate existing correlation, receipts and retention. The proposed boolean keeps known source mode after bodies are pruned, at the cost of an additive schema/client change and explicit rejection of mode conversions. Reusing complete-master replacement preserves existing conflict protection; it offers no automatic merge of local exceptions.

## Validation and decision gate

Test DATE, UTC, DST-sensitive named zones, RRULE/RDATE/EXDATE/PERIOD, source omissions and whole-series lifecycle; reject instance/range/bundle/delegation/mode conversion atomically. Verify privacy, immutable host context, independent authority, source/version conflicts, retained markers/links after pruning, malformed mode evidence, no implicit sends, clean-baseline local-exception protection, true retries and stale-source response withdrawal.

Generate the additive boolean migration after approval. Verify fresh databases and populated false-mode upgrades without changing previous sources, links, checkpoints or response state. Exercise two actual hosts racing intake/add/apply/respond/cancel, competing delivery leases and loss before/after commits or synthetic acceptance. Run focused tests during the grouped work, then stable generation, formatting/analysis, complete VM/Chrome/database/upgrade/recovery and connected Flutter checks before one implementation commit. External-client/mail evidence remains a separate release gate.

Open issues and PRs were checked: no standalone open issue or competing recurring-recipient implementation was found; existing invitation/response and occurrence-query PRs are prerequisites. AGENTS.md requires: “Proposed ADRs become accepted only after explicit maintainer agreement.” This document and its draft PR request that agreement; they add no model source or runtime support.
