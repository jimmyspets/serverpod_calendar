# ADR 0176: Explicit master responses to bundled invitations

Status: **Accepted by explicit maintainer agreement on 2026-11-05**, including the grouped API, digest-family, authority and retention mechanics. Implementation and actual validation remain separate.

## Context and inspected evidence

[ADR 0175](0175-bundled-invitation-whole-lifecycle.md) implements scoped bundled whole-series cancellation/reopening, including its explicitly approved lossless baseline refinement. [Implementation PR #182](https://github.com/jimmyspets/serverpod_calendar/pull/182), commit `7bf530c7bd9e1ebb1cbb26f77916c583c6f873d1`, completed local pure, SDK, two-host/process-loss, generated-client and connected Flutter checks. The infrastructure-only aggregate-budget repair at `3aa493d00379dd6baa254bc8edc13011d140a4bf` ran a replacement [full hosted run](https://github.com/jimmyspets/serverpod_calendar/actions/runs/42051903920). Application sources were unchanged by that repair. The hosted run completed with failure in the final connected Flutter journey: its stale-update assertion did not find the lazily built error widget. Earlier runtime stages passed. This batch includes a post-frame list-layout wait refinement; local and replacement hosted conclusions must be recorded separately.

The private attendee response runtime already has personal state, immutable delivery/receipt and attempt tables, strict database-second ordering, pinned sources, fenced workers and synthetic MIME. It deliberately rejects bundle entries. Source evidence, authority selection, payload projection, stored-record validation, query eligibility and worker checks still use `events.single`. Selecting only a master without validating the complete bundle would bypass the accepted source profile and could confuse a master response with acceptance of independently versioned exceptions.

[RFC 5546 sections 2.1.5 and 3.2.3](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.3) describe attendee REPLY and component-version identity. This proposal targets the master only, without RECURRENCE-ID. It does not define responses to individual or future occurrences, or claim a single master version acknowledges every independent component version.

## Proposed complete group and user meaning

Add explicit private Accept/Tentative/Decline for the master of a current supported complete REQUEST bundle, with protected state/activity queries, durable synthetic delivery, generated clients and Flutter/recovery checks together. Allow responding before calendar adoption, or independently of later application/dismissal, as in the existing recipient response contract. Declining need not create an event. No action modifies native calendar contents, source participant parameters, private alarms or protocol versions.

Label this action **Respond to series master**. The record describes only that master's invitation version; do not fan out replies, set occurrence responses or label it acceptance of all exceptions. Individual/range bundle responses, delegation, other scheduling methods, provider trust and real sending remain separate required work. The existing ordinary and selected-instance response endpoints remain guarded for bundle profiles.

A new response must target the exact selected current REQUEST source and matching invitation/response revisions. A current whole CANCEL cannot receive a fresh participation response. Receiving a newer REQUEST may allow a new explicit reply even if its linked native event is still cancelled until Apply reopening; participation and native booking remain independent. Receipt/Add/Apply/dismiss/reopen never sends or changes a response automatically.

## Complete source validation and master projection

Validate the whole stored REQUEST bundle through the accepted syntax/semantic/component/participant/zone profile before selecting its one non-override master. Keep exact original/range membership, fixed participant claims and current VALARM/delegation/SENT-BY rejection; master-only output must not hide unsupported child data. Use existing source/component/byte limits and a shared bounded validation budget per read, explicit command, retry or worker source check. Exhaustion establishes no valid target or eligible delivery.

Generate one minimal REPLY from that master: exact UID, independently optional master SEQUENCE, actual new database-second DTSTAMP, the approved organizer and one host-verified attendee with the selected PARTSTAT. Omit RECURRENCE-ID and all child components, timing, recurrence, source text, attachments and alarms. Do not copy the largest child sequence, invent zero for omitted SEQUENCE, or modify the source. The complete immutable incoming bundle and separate actual outgoing REPLY remain available to host approval.

A child-only new REQUEST may keep its master's tuple unchanged. A fresh explicit response still pins the entire newly selected source ID/digest/revision; it uses that unchanged master SEQUENCE and a strictly later actual database-second response stamp. This source-level freshness rule is deliberately conservative and does not claim the RFC requires complete-bundle pinning.

## Proposed APIs, authority and state

Add dedicated `bundleResponse`, `bundleResponseActivity` and `sendBundleResponse` APIs, reusing the existing response view/activity/request/receipt DTOs. Their invocation supplies the explicit master-only intent; no new stored mode field, table, column, model field or retention cap is proposed. The existing invitation kind/source context identifies the bounded bundle profile. Old scalar/instance/range response paths must reject it before correlation fallback or retry lookup.

Add host operations `readBundleMaster`, `sendBundleMaster` and `dispatchBundleMaster` to the response adapter, supplementing ordinary read/send/dispatch, private summary/raw-source access and trusted recipient/attendee/organizer-route checks. Apply the extra operations to actual validated bundle sources and known bundle history, including activity/retries after a whole cancellation. No source participant address grants authority. Calendar detail or adoption permission is not required merely to reply, and does not imply reply authority.

Reuse one personal response state per recipient invitation entry and the existing immutable delivery/attempt records. A bundle entry already represents one master, so no occurrence target key or uniqueness-index change is needed for this increment. Give the new explicit send a `bundle-master-response-v1` criteria-digest family; preserve the existing ordinary family. Reused command IDs with different criteria/families reject. On validation/retry/dispatch, derive the family from the validated retained source profile, never from today's entry kind alone. Missing/corrupt profile evidence fails unavailable rather than guessing.

Preserve the actual database-second monotonic rule: if time has not advanced beyond the last personal response stamp, reject retryably rather than fabricating a future timestamp. One transaction saves personal state, immutable source/command/route/payload/receipt and durable intent. Final denial rolls back everything. Source SEQUENCE/DTSTAMP never prove sender authority, alter API revisions or establish local calendar acceptance.

## Freshness, history and delivery

Exact retained command retries reauthorize and return their immutable receipt without reactivating or replacing work. Queueing a newer response supersedes the prior personal intent under the current generation rules. A different selected source withdraws pending delivery, including child-only updates whose master tuple did not change. A whole CANCEL also withdraws pending delivery; later REQUEST receipt cannot automatically resend it.

Calendar adoption/application/dismissal which leaves the selected source unchanged must not withdraw a reply merely because the inbox revision advanced. These are independent actions. The returned personal state must clearly identify its pinned source and whether it still applies to the current selected source, without silently transferring a choice to another packet.

Workers retain fresh recipient/attendee/route/source checks, no fabricated actor, expiry/grace, generation and lease fencing, stable uncertain retry IDs and exact payload/MIME bytes. Transport acceptance is not organizer application or display. Reuse current source pinning, protected activity, state/delivery/attempt and 30-day terminal-history rules. Retained commands pin their actual complete source; pruning must not invent a source body, clean history or a different digest family. Ordinary and instance response histories remain readable under their existing rules; no limit is widened.

## Complete acceptance and consequences

Test DATE/UTC/exact zones, a child sequence above the master, omitted versus explicit-zero master sequence, child-only source changes, full-source rejection, separate authority/final-denied writes, timestamp retryability and immutable family/payload bindings. Prove no calendar adoption is needed and no source/native content changes; Add/Apply/dismiss with the same selected source must remain independent. Test whole CANCEL/new REQUEST withdrawal, stale-source/permission/route changes, source pinning/pruning/corruption and old endpoint guards.

Extend synthetic REPLY MIME examples and Flutter master-only labels/choice/activity/frozen retries. Race commands across two independent hosts and kill before/after command commit and synthetic transport acceptance, preserving one intent and exact receipts/keys/bytes. Retain existing organizer-side master versus occurrence version tests rather than treating a master REPLY as an exception response. Run focused iterations, then the complete affected pure/SDK/client/worker/browser group and exact-head hosted checks; commit code only after the entire approved local group is complete.

Rejecting all bundle responses leaves a common private invitation workflow incomplete. Fanning out to children would change response meaning and need target-specific state; treating the highest child version as the master's would reply to the wrong component. The bounded master-only flow reuses established durability and privacy without a new schema. If implementation needs new persisted fields, ambiguous profile inference or broader semantics, return with that concrete refinement for review.
