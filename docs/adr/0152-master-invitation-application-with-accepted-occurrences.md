# ADR 0152: Master invitation application with accepted occurrences

Status: **Proposed 2026-10-31. Preserve accepted occurrences and reject orphaning master updates is confirmed; the concrete composition/version/retry/API mechanics below require review.**

## Context and confirmed policy

Accepted [ADR 0151](0151-explicit-single-instance-invitation-application.md) applies selected occurrence REQUEST/CANCEL notices with a clean entire linked series, independent source acceptance and a temporary guard on new master applications. The maintainer confirmed that a newer master must preserve accepted occurrence updates/cancellations and reject recurrence changes that remove any accepted original. That policy does not approve the concrete mechanics below automatically.

Inspected the master checkpoint, private occurrence state, source baselines, lifecycle gates, source projection, native override validation and exact retry paths. RFC 5546 sections 2.1.5 and 3.7.1 describe identity/version handling per UID and original, while section 3.2.5 distinguishes whole and instance cancellation. Primary sources checked 2026-10-31: [message sequencing](https://www.rfc-editor.org/rfc/rfc5546.html#section-2.1.5), [recurrence instances](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.7.1) and [CANCEL](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5). The narrower safeguards here are application policies, not a claim that the RFC specifies this database design.

## Proposed grouped application

Lift the ADR 0151 guard only for representable, explicitly approved master REQUEST, whole-master CANCEL and later REQUEST reopening. Require the same current pending source, exact link/recipient/correlation, expected revisions, full source/native authority and clean complete baseline. Receiving a new master remains review-only; no implicit merge of local changes is added.

For REQUEST, validate the new master independently, then compose the existing accepted single overrides and their independent source versions over it. Preserve their exact original identities, own timing/end forms, selected text/annotations, cancellation flags and retained source distinctions. Inherited values follow the new master; an old cancellation's repeated optional text does not become a new own override. Retained source describes what was accepted at that earlier action, not a new claim that its optional values match every later inherited master value.

Validate every accepted original against the new pattern in one bounded combined scan, including PERIOD additions, exclusions, DATE/UTC/named-zone kind and exact zone. Reject orphaning, incompatible profiles, unsupported retained metadata, range/single collisions or exhausted work/capacity without changing anything. Do not retarget, pin inherited timing, normalize source versions, flatten recurrence or discard an accepted target. Participant/delegation changes outside existing profiles remain separate.

Whole-master CANCEL retains the accepted master layer's content/timing, projects its cancelled status/exact source version, and preserves the separate accepted occurrence layer. The master cancellation suppresses the whole series; it does not rewrite individual flags or erase accepted REQUEST data. A later explicit newer master REQUEST reopens the master while preserving individual cancellations. Restoring one accepted cancellation still requires its own explicit newer occurrence REQUEST.

One transaction writes the composed native event/baseline, updated master acceptance, occurrence composition checkpoint and exact selected review dismissal. Advance event/API revision, scope/feed invalidation and both relevant checkpoint revisions once, with database audit time; preserve calendar metadata time, personal alarm/action state, native origin and source component timestamps/omissions. No outgoing message, participation response or alarm adoption follows.

## Proposed independent versions and cancellation floor

Keep master source versions independent of retained occurrence versions. A newer master REQUEST is ordered against the accepted master; it does not renumber or implicitly replace accepted instances, including an instance with a larger SEQUENCE. Occurrence actions continue to use their accepted effective component/target floor.

For a whole-master CANCEL affecting the composed series, propose a stricter initial freshness guard: its SEQUENCE must exceed the accepted master's and every retained target's effective sequence (omission compares as zero), in addition to existing master ordering. Reject an older cancellation instead of letting it cancel a more recently accepted instance. This conservative cross-component guard is an explicit bounded application choice, not a quotation of a universal RFC requirement. A version at the supported maximum cannot be incremented by the application; source reconciliation remains explicit.

## Proposed checkpoint/API refinement

Reuse the existing table and byte/target/recipient/scope ceilings; no SQL table or column change is proposed. Introduce version-two state in the existing JSON. Its master baseline is now the latest accepted **master layer**, independent of the composed event baseline. Bind that layer to the actual master checkpoint and retain the exact current target sources/fingerprints. Validate legacy version-one state on read without inventing history; convert only on an authorized actual write. Unknown/corrupt formats fail unavailable.

Add expectedOccurrenceRevision (default zero for existing generated commands) to the master apply request and expose the current occurrence revision in its protected preview. A new master command with accepted targets must supply the actual revision. Preserve existing digest rules for legacy zero-state retained commands; new composed commands use an explicit versioned digest including this revision so changed targets/actions cannot alias earlier commands. Upgrade hosts/clients together; mixed writers remain unsupported.

Master application advances the occurrence checkpoint revision because its master/composed baselines changed, but preserves the latest **occurrence-command** retry slot. Its historical receipt may therefore reference an earlier checkpoint/event revision and application time; validation must bind it to the unchanged selected accepted source, not pretend it was applied again during master composition. Exact occurrence retries still reauthorize and return that historical result without replay or dismissing newer notices. A different occurrence action still supersedes the one per-link slot. The separate latest master receipt retains its existing semantics; the immutable creation receipt remains unchanged. No history ledger or new retention is added.

## Proposed host authority and previews

Require independent composeAcceptedOccurrences authorization and readOccurrenceApplication access whenever a master action composes retained targets, alongside all existing master/native/source/lifecycle gates. Preliminary and final host context includes immutable current/proposed master acceptance, complete private occurrence checkpoint and composed native overrides. Fresh external policy retains its documented revocation race; shared database locks do not imply an undeclared stronger guarantee.

The master preview reports the current occurrence checkpoint revision and whether the incoming master can preserve accepted occurrences. Keep explicit blocked state for orphan/profile/version/capacity failures; do not label them as an absent newer source or a local edit. The Flutter screen explains preservation, whole cancellation/reopening and independent instance restoration. Do not disclose sibling raw source bodies through ordinary master/event responses or add list totals.

## Validation and consequences

Test preserved moved/content/cancelled instances across newer master text/settings/patterns, inherited versus own values, DATE/zoned/DST/PERIOD originals, orphan/profile rejection, whole cancellation/reopening with independent cancellations, larger instance versions and the stricter cancellation floor. Verify all independent gates/final rollback, quotas and overflow, legacy/v2 validation/conversion, preserved historical occurrence/master retries, pruning/deletion and no personal/outbound side effects. Exercise generated clients, Flutter previews, actual two-host master/instance races and process loss before/after commit, then complete the agreed checks before one code commit. The preceding implementation is [PR #133](https://github.com/jimmyspets/serverpod_calendar/pull/133); its exact-head hosted conclusion remains separate from this documentation proposal.

Dropping exceptions violates the confirmed policy. Replacing the composed baseline without advancing the occurrence revision permits stale commands to ignore a changed master layer. Replaying old cancellation source as a new message would incorrectly reject legitimate inheritance changes or pin timing. Keeping a separate master layer and composed baseline preserves their meanings at the cost of additional validation and explicit refusal when the current native/wire profile cannot represent the combination.

Approval covers this complete JSON/API/authority/version/retry batch, including the conservative whole-cancellation floor. [AGENTS.md](../../AGENTS.md) requires: “Proposed ADRs become accepted only after explicit maintainer agreement.” Instance replies, RANGE, wider participant/source profiles, overwrite/merge and real transport remain separate requirements.
