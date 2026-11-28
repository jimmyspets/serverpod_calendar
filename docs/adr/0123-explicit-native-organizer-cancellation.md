# ADR 0123: Explicit native organizer cancellation

Status: **Accepted by explicit maintainer approval on 2026-10-26. Scoped implementation and validation are recorded in [the organizer guide](../native-organizer-scheduling.md).**

## Context and accepted scope

The accepted [ADR 0122](0122-explicit-native-organizer-publication.md) runtime can invite/update one non-recurring native event. Ordinary local cancellation sends nothing and blocks pending REQUEST dispatch. Complete that lifecycle increment next with an explicit **Cancel and notify** command for an existing organizer binding. Keep the verified organizer and complete fixed recipient set; do not add recipient-removal, recurrence, adoption, deletion or inbound reconciliation to this batch.

The command accepts only actual event UUID, expected API revision and a UUID command key. It sets the native event status to CANCELLED and queues a whole-event CANCEL for every previously selected recipient in the same scope-locked transaction. Existing ordinary cancellation remains local. Require independent scheduling-cancellation permission, lifecycle permission, complete ordinary/source disclosure and dedicated current organizer/recipient approval. Hosts may map these to shared rules, but ordinary edit authority cannot send a cancellation.

## Draft isolation and versions

Build the outgoing cancellation from the last published component, with STATUS:CANCELLED and a new protocol version. Do not publish unsent local title, description, location or timing edits as a side effect of cancellation. Preserve those native draft fields while changing their lifecycle status. The policy sees actual current state, validated proposed native state and the exact distinct outgoing cancellation snapshot. Canonical UID and fixed participants remain unchanged. Use whole-second nondecreasing database-clock version times and a SEQUENCE greater than both the current native component and previous publication; reject overflow atomically.

Cancelling again when the latest publication is CANCEL and the native event remains cancelled is an authorized no-op. Retained exact command retries return their original receipt after fresh checks; conflicting command reuse rejects. Shared command-key rules distinguish REQUEST from CANCEL. A later explicit Save and notify may reopen and publish a new REQUEST under existing lifecycle/publication authority, with a greater SEQUENCE. A local reopen sends nothing and does not implicitly retract an already published cancellation.

## Storage and dispatch

Reuse the four approved tables and their immutable payload, finite limits, retention, stable delivery keys, attempts and fencing. Publication.method records REQUEST or CANCEL; authorized status reports the latest method separately from local dirty state. No new table/column or retention expansion is required. Never rewrite an old publication into a cancellation. A newer publication supersedes older unsubmitted work; messages already submitted cannot be recalled. Current host authority must approve each exact cancellation and its recipients before dispatch/retry. An ordinary local reopen does not replace that published cancellation; only a new explicit publication changes the current generation.

Keep event deletion, binding removal, recurrence conversion, recipient changes and source replacement blocked. Design content scrubbing and minimal inbound correlation retention separately before permitting deletion; this proposal does not select indefinite tombstone retention. Real transport/MIME, recurring cancellation, inbound ordering and external clients remain required later. The example still records synthetic messages only.

## Alternatives and consequences

Cancelling from the current draft could expose edits the organizer never published. Sending implicitly on ordinary cancellation would violate the explicit-action decision. Removing the binding would lose retry/correlation state. Reusing the approved storage keeps message history private and bounded, but recipients can still observe uncertain duplicate submissions and messages can arrive out of order; protocol version comparisons and later inbound reconciliation remain necessary.

## Acceptance

Test independent permissions and final denial rollback, no disclosure of unsent drafts, DATE/UTC/named-zone cancellation through the existing pure validator, stable UID/roster and version overflow, stale revisions and cross-host command races, exact retry/no-op, local reopen versus explicit republish, supersession and authority withdrawal, timeout/loss/fenced retry before and after acceptance, status/read privacy, retention and Flutter explicit cancel/reopen publication journeys. Run focused tests while implementing and broader checks after the batch, with one code check-in. This does not establish recurring runtime, inbound reconciliation, real mail or full RFC 5546 conformance.
