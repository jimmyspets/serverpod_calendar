# Authorization consistency during writes

Status: **maintainer-confirmed support for transaction-coordinated and external policies with explicit guarantees; implementation mechanics proposed**. No calendar domain adapter/transactions implement this yet. See [ADR 0045](adr/0045-authorization-consistency-guarantees.md), [host context](host-authorization.md) and [query disclosure](authorization-queries.md).

## Confirmed boundary

The maintainer selected support for both host-policy arrangements, with their guarantee explicitly declared and no silent downgrade. The host supplies its rules; module services enforce those rules against the actual operation/objects and validated proposed change. A transaction in the calendar database cannot by itself make a separate authorization service atomic.

| Arrangement | Guarantee required of the host integration | In-flight revocation meaning |
| --- | --- | --- |
| Transaction-coordinated policy | Permission evaluation/revalidation and all relevant revocation paths participate in a coordination protocol with the calendar commit | Write and revocation have a defined order: a revocation ordered before the write prevents it; a write ordered first can commit |
| External policy with a fresh pre-commit check | A fresh authoritative decision for this exact attempt/actor/targets/change is obtained before commit, within the declared freshness/deadline rules | Revocation after the final check can race with commit; a permitted in-flight write may finish unless the host provides additional effective coordination |

These are descriptive modes, not final enum names. An external provider can meet the stronger guarantee if the host supplies a real commit/revocation coordination mechanism; physical storage location alone does not determine the guarantee. Conversely, merely reading permission rows in the same transaction does not establish the stronger guarantee.

The host/module configuration declares which guarantee is supplied and which operations require it. An operation requiring coordinated authorization must reject an adapter that cannot provide it; do not silently retry it in fresh-check mode. Missing, unavailable, denied, expired or unprovable decisions cannot authorize the requested domain mutation. Numeric deadlines, required profiles per operation and configuration/API details remain design work; this decision selects neither a default mode nor an automatic weaker mode.

## Proposed write protocol

1. Derive trusted actor, host scope and operation. Resolve actual target/parent/reference identities; validate input and identify all permission gates, including mixed presentation/settings or task-content/progress/assignment changes.
2. Establish the calendar transaction and authoritative target/dependency snapshot. Validate expected revisions and containment. Optional earlier policy checks may reject cheaply, but are not reusable authority for changed data or a later attempt.
3. Evaluate all required permissions against that snapshot and the validated proposed change. In coordinated mode, acquire/prove the host's commit/revocation coordination. In external fresh-check mode, perform the final authoritative check for the exact attempt after its authorized state/change is established, with bounded network/transaction time.
4. Recheck/fence relevant revisions and coordination before committing the domain write, derived-state invalidation and any durable outbound intent together. Any target/change/context mismatch invalidates the decision; do not attach an old allow to a new write.
5. Return only an authorized result/receipt. A successful write does not grant full read access to its object. Actual mail/push/stream delivery is outside the transaction and requires its own current checks at handoff/retry.

This is a proposal, not a final transaction-isolation algorithm. The host integration must define the participating policy dependencies (including membership, roles, scope and publication authority), coordination boundaries and lock/serialization order. All relevant permission writers/revokers must participate; protecting only the calendar row cannot order an unrelated group-membership removal. Reading a policy version and then writing without an effective commit fence leaves a race. Same-database transactions or a remote version label are not sufficient proof on their own.

External calls must be bounded; do not hold database locks while waiting indefinitely for a remote service. A preliminary external check may optimize work, but cannot replace the declared final decision. Proposed decision evidence binds operation/actor/scope, all targets and relevant revisions, validated change, policy reference/version where available, attempt identity, guarantee and validity information. This evidence is server-only, not a bearer credential or authority supplied by clients. Exact digest/version/expiry types and whether evidence is persisted remain unselected.

A new RPC to a stale permission cache is not automatically a fresh authoritative check. Each host adapter must state and meet its provider's consistency/freshness contract. The remaining race is **after** the final check, not permission to reuse an already-revoked grant. If the provider cannot establish the required freshness, the adapter must fail or the operation must be unavailable under that integration; do not describe eventual cache reads as current authorization.

## Example interleavings

**Coordinated:** Alice's edit and a membership revocation compete through the same effective coordination. If revocation is ordered first, the edit cannot commit on the old permission. If the edit is ordered first, it may commit before revocation takes effect. The exact serialization mechanism remains proposed and must be tested across hosts.

**External fresh-check:** the final authoritative check permits Alice's exact edit; permissions are then removed; the database commit follows. The edit can succeed under this declared check-time guarantee. Rechecking again only moves the last-check boundary; it does not eliminate that race. A host requiring revocation to defeat every not-yet-committed write must provide the coordinated guarantee.

**Stale calendar revision:** Alice expects revision 4, but another edit commits revision 5. Reject her stale edit regardless of a still-valid permission. Fresh authorization never authorizes silently overwriting another writer or automatically rebasing user intent.

## Failure, retry and result handling

- Denial rejects the requested operation without partial domain changes. Policy timeout/outage produces a safe temporary failure; do not turn it into a denial proof about a hidden object or an allow. Availability can report explicit unknown coverage under its separate contract.
- A late allow result after timeout/cancellation is not permission to start or complete an abandoned attempt. Commit must still belong to an active validated attempt and its declared deadline/coordination; exact cancellation/commit-boundary behavior needs implementation tests.
- Every new transaction attempt reestablishes its snapshot and authorization. Database retry callbacks may run more than once; they must not send mail, notify clients or perform other irreversible business actions. Stale user revisions remain explicit conflicts, not automatic edit replay.
- Outbound intent commits atomically with its domain change; transport happens afterward. A post-commit response/disclosure failure cannot undo an already committed write. Do not report that it rolled back; define safe mutation receipts/idempotent reconciliation without returning cached private views or bypassing current authority.
- If a permitted change removes the caller's own access, whether to allow that change is host policy based on current and proposed state. A commit does not preserve subsequent read rights. Exact receipt/disclosure behavior remains a contract gate.

## Other authorization boundaries remain in force

The declared write guarantee does not weaken feed-token revocation or ongoing publication rules. A request starting after committed revocation must not serve content or 304 through another host's stale cache. Feed/token state and every selected calendar's publication authority still require current validation; incompatible integrations cannot claim that behavior. The in-flight response boundary must be documented separately from write commit ordering.

Cursors and idempotency keys never carry permanent allow decisions. Reauthorize each page and result lookup. Worker planning-time authorization does not authorize later delivery: recheck recipients, generation, cancellation and expiry before dispatch/retries. Do not claim an external provider call or actual notification display is atomic with a calendar transaction. Copied access JWTs can remain valid until expiry after logout; current host rights and feed credentials are separate checks.

All coordination/evidence/cursor handling must work across independent Serverpod instances. No process-local allow cache, mutex, singleton callback or sticky routing can establish a shared commit/revocation order. Exact policy cache invalidation/version contracts remain pending; missing invalidation must not restore revoked authority.

The [adapter interface proposal](authorization-adapter-contract.md) assigns context, batch, query and commit-guard responsibilities without claiming that signatures prove the guarantee. The [calendar CRUD proposal](calendar-crud-contract.md) supplies the first concrete operations, including a separate dependency/delete coordination boundary.

## Future acceptance checks

- [ ] Validate declared adapter capabilities against required operation guarantees; absent/unsupported configuration rejects, with no fallback.
- [ ] Use barriers and two independent hosts to exercise both write-first and revocation-first coordinated interleavings, including group membership/policy changes outside calendar rows.
- [ ] Demonstrate/document the external after-check race without mislabeling it a coordinated guarantee; reject stale, mismatched or expired decision evidence.
- [ ] Fail/timeout/cancel a policy request, then deliver a late allow; verify no partial or abandoned domain commit.
- [ ] Change a target/revision/proposed change after a preliminary check; verify fresh authorization or rejection, not decision reuse.
- [ ] Retry a transaction and test lost responses/crashes; verify no duplicated external actions, no stale overwrite and authorized receipt recovery.
- [ ] Revoke a feed on one host and request content/304 on another; verify current token/publication checks and no cached success. Revoke recipient access before worker dispatch and verify suppression/unknown handling as appropriate.

These are future tests, not executable evidence. Final host adapter interfaces, guarantee defaults/operation requirements, timeouts, lock/serialization/fencing protocol, receipt behavior and external provider profiles must be reviewed before domain schema/API implementation. See [operation catalog](authorization-operations.md), [models](models.md) and [multi-instance requirements](adr/0018-automated-example-and-multiple-instances.md).
