# Master updates after source restoration

[Accepted ADR 0165](adr/0165-master-updates-after-source-range-restoration.md) extends the explicit master `applyUpdate` workflow after [source range restoration](source-range-restoration.md). Eligible active master REQUESTs preserve the cleared cutoff state and individual cancellations. Receiving a notice still changes no calendar. Whole-series CANCEL/reopening and new single/range transitions remain guarded.

The entire current series must match its verified expected restored state. Local timing, content, protocol, exception or cutoff edits are conflicts. Compose the incoming master with retained canonical single/future components and their independent versions, then require the exact restoration original to remain a member in the same DATE/UTC/named-zone profile. Earlier inclusions, PERIOD additions and EXDATE precedence apply. Orphaned/excluded originals, profile changes, component collisions, a proposed CANCELLED master or exhausted work reject without partial effects.

## Independent historical and current proof

A new master uses the existing accepted-master SEQUENCE/DTSTAMP ordering. Its SEQUENCE can be lower than the historical restoration SEQUENCE. Restoration is not reaccepted against a changed title, timing or later master version; its original matching/freshness proof is replayed against the values that were accepted then. Incoming master source timestamps and omissions remain exact, separate from native audit time.

On the first write, v8 JSON freezes one complete v7 checkpoint descriptor, its cutoff-free canonical event baseline and the nullable actual master-application record. A null master retains the original adoption binding. Historical master scope/recipient/link/creation/version/baseline bindings are validated with the same checks as live master records. The frozen v7 still contains its single bounded cancellation predecessor and independent restoration source evidence.

Later master updates retain that one frozen acceptance. They never nest v8 or accumulate history. Current master baseline/binding, composed baseline, expected unmasked native digest, composition digest and original restoration receipt binding are distinct. Canonical targets, restoration source and receipt are derived from the frozen acceptance rather than duplicated at the persistent root. Decoding strictly validates historical proof and reconstructs current composition independently. Missing/altered snapshots, markers, nested/unknown formats or inconsistent bindings fail unavailable without fallback or lazy upgrades.

The frozen baseline can retain superseded content privately until event deletion. Existing caps count the complete representation: 4 MiB/link, 16 MiB/recipient, 64 MiB/scope, configurable lower, plus existing source/slot/work limits. Evidence is never dropped to fit. Deletion scrubs the active checkpoint. Ordinary import baselines remain valid cutoff-free canonical state. No SQL, new endpoint/view field or dependency is added.

## Authority, writes and retries

Independent `composeAcceptedRangeRestoration` authority accompanies existing master application, accepted-occurrence/cancellation composition, source/link/raw detail and native import/replacement/update rights. Host adapters receive actual current/proposed event and private checkpoint snapshots separately. Accepted cancellation and restoration source bodies are freshly authorized by their real stored identities, including after queue pruning. Existing coordinated/external fresh-check guarantees and limitations remain explicit.

Protected previews check composition/native rights, membership, clean state and quotas without writing. Existing history flags can both be true while the native cutoff is absent. Eligible master previews clear `occurrenceCompositionBlocked`; Flutter describes restoration history separately from an active cancelled suffix.

One transaction updates the composed event, master acceptance and v8 checkpoint, advances their revisions/audit state, dismisses only the selected notice and invalidates scope/feed/alarm generations and leases. Parent calendar metadata time, individual cancellations and personal action/dedup state remain intact. Query/busy results and feeds use current canonical values and fresh validators; reminder expiry/access and accepted-firing non-replay rules still apply. No reply is sent and no imported alarm is armed.

The latest master command retains existing supersession and expected-occurrence-revision fencing. The original restoration remains the latest occurrence receipt across master updates: exact retries reauthorize and return its original result without changing a later master, local draft/cutoff, notice or generation. Older occurrence/cancellation commands stay superseded. Same-command races and process loss must produce one atomic effect with stable retry identity.

This batch lifts only active master REQUEST composition. Whole lifecycle, new occurrence/range messages and repeated cancellation/restoration cycles still need their own contracts. See [actual validation](scaffold-validation.md); local synthetic success is separate from implementation-head CI and external-client interoperability.

[ADR 0166](adr/0166-master-lifecycle-after-source-range-restoration.md) supersedes the active-only guard for the separately approved [whole-master lifecycle](restoration-master-lifecycle.md); new range transitions remain guarded.
