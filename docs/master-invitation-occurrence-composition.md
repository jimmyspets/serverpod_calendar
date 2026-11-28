# Master invitation application with accepted occurrences

Accepted [ADR 0152](adr/0152-master-invitation-application-with-accepted-occurrences.md) extends the [explicit occurrence application](instance-invitation-application.md) workflow. A pending master REQUEST, whole-series CANCEL or later REQUEST reopening can now be applied while preserving accepted occurrence updates and cancellations. Receipt remains review-only. Applying a source sends no participation response or scheduling message.

The entire linked series must still match its accepted baseline. Local edits block application; there is no implicit overwrite or merge. Each command selects the actual recipient link, pending source and expected calendar, event, master and occurrence revisions. Host-derived identities and server-side checks establish authority; source addresses do not.

## Preserved layers

A new REQUEST is validated independently, then composed with the retained canonical single-occurrence edits and their independent protocol checkpoints. Original DATE/UTC/named-zone identities, own replacement timing/end forms, selected text/annotations, cancellation flags and source omissions remain intact. Inherited values follow the new master. Historical cancellation text is retained as evidence, rather than replayed against a changed master or converted into an own field.

Every retained original must remain a member of the new pattern, including PERIOD additions and exclusions. Incompatible kind/zone, removed membership, unsupported metadata inheritance, range collisions, validation work exhaustion or byte/capacity limits reject atomically. The service never drops, retargets or pins an exception to make a replacement fit.

Whole-series CANCEL retains the accepted master layer's content and timing, applies its exact source version/status, and preserves the independent occurrence layer. Reopening with a newer REQUEST leaves individually cancelled occurrences cancelled. Those require their own explicit newer occurrence REQUEST to restore.

Master REQUEST versions are ordered against the accepted master, independently of larger instance versions. As a conservative application policy, a whole-series CANCEL must have a SEQUENCE strictly greater than both the master and every retained target (omission compares as zero). This cross-component floor is **not a universal RFC 5546 requirement**. Rejected sources remain available for protected review.

## Checkpoints, retries and authorization

No SQL migration is added. Version-two JSON in the existing private occurrence table stores the latest accepted master layer separately from the composed event baseline. It retains the existing target sources/fingerprints and binds the actual master checkpoint. Version-one reads remain supported without writes; an actual authorized master composition converts the row. Unknown or corrupt state fails unavailable. The existing 4 MiB/link, 16 MiB/recipient, 64 MiB/scope and 128-target ceilings are unchanged and hosts may lower the byte limits.

`CalendarInvitationApplyRequest.expectedOccurrenceRevision` defaults to zero for existing zero-state commands. A master preview exposes `occurrenceRevision`; a new composed command must supply that exact value. Composed command digests have an explicit version prefix and include it. Legacy zero-state command hashes and retained retries remain valid. Upgrade all hosts and generated clients together; mixed writers are unsupported.

One transaction advances event, master and occurrence checkpoint revisions once, updates the composed accepted baseline and selected review state, and invalidates scope/feed results. It preserves calendar metadata time, personal alarms/actions, native origin and independent source protocol versions. The immutable creation receipt and separate latest master result retain their existing meanings.

Master composition preserves the latest occurrence-command retry slot. Its receipt can refer to older event/checkpoint revisions and audit time. Version-two state checks its request/source/result binding and acceptance time; an exact retry reauthorizes and returns that historical result without replay, new revisions or dismissal of newer notices. A different successful occurrence action still supersedes that one per-link slot. Queue pruning does not remove active acceptance evidence; event deletion scrubs it.

New composed writes require independent `composeAcceptedOccurrences` and `readOccurrenceApplication` host permissions alongside the existing master/native/full-source/lifecycle gates. Preliminary and final contexts contain immutable current/proposed master acceptance, complete private occurrence snapshots and composed native overrides. Protected master previews require occurrence-read access, expose no sibling raw source bodies or totals, and report blocked composition separately from local edits or absent newer sources. Fresh external checks retain their documented revocation race.

## Example and validation

The existing Flutter update/cancellation screen supplies the occurrence revision, explains preservation and independent restoration, and keeps uncertain command fields for retries. Its progress indicator stays visible while source text is scrolled. Synthetic generated-client, Flutter and independent-host/process-loss journeys exercise the same service and generated models.

Run focused database coverage with `dart test test/integration/instance_invitation_application_test.dart --concurrency=1` from the example server. The root `tool/check.ps1` includes those tests, the extended `--occurrence-applications` process probes and full connected journey. [The validation record](scaffold-validation.md) distinguishes actual results from pending checks and external-client evidence. Instance participation responses, RANGE reconciliation, wider participant/source profiles, overwrite/merge and real mail remain separate requirements.
