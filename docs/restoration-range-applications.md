# Range REQUEST application after source restoration

Later [ADR 0170](adr/0170-bounded-repeated-source-range-cycles.md) implements [bounded repeated source range cycles](bounded-source-range-cycles.md). Its verified v12 path supersedes earlier temporary repeated-cycle guards below while preserving strict legacy reads/retries and all stated source, authority and retention boundaries. Historical validation remains evidence for its original batch.


Accepted [ADR 0168](adr/0168-range-request-applications-after-source-restoration.md) permits explicit THISANDFUTURE REQUEST application after verified restoration history. Receiving a notice remains review-only. Applying it requires an active accepted master, no native cutoff, a clean entire series and exact original/profile membership.

Incoming SEQUENCE must be explicit and strictly greater than both the effective anchor component and the historical restoration version. Missing retained sequence compares as zero without rewriting its omission. A later DTSTAMP cannot waive either sequence floor. This is our conservative application policy, not a universal RFC requirement. Single-instance commands retain their separate effective-component freshness rule.

Timing propagates using the existing civil shift and replacement deadline policy; supported own content remains local to the anchor. Later independent singles, ranges, individual cancellations and versions remain intact. A same-anchor single/range collision rejects. Master composition rejects orphaning the historical restoration original or any current target.

Existing checkpoint JSON v11 retains current typed targets and a separate latest occurrence receipt beside one unchanged frozen v7 proof. It does not nest subsequent checkpoints. Each new or replaced post-restoration range records a server-derived requiredAfterSequence from the verified pre-write maximum of the two floors. The current composition digest binds that evidence; decoding rejects missing, contradictory or tampered evidence. Exact inherited pre-restoration range descriptors retain their original source versions.

A new occurrence command supersedes the previous restoration/single/range receipt while preserving private evidence. Master changes preserve the latest occurrence receipt and maintain a separate latest-master receipt. Exact current retries reauthorize and return their original result without reapplying over drafts or newer notices. Dedicated restoration views never return a new range command's receipt, including at the same original.

Independent range read/apply, actual historical/current source, native import/replacement/update/lifecycle and all applicable composition rights remain required. Eligibility previews check the actual proposed native member and overrides; writes recheck immutable preliminary/final context. Sources remain authorized by their real IDs after queue pruning. Permission failures never imply absence or free time.

Native content, cutoff-free accepted baseline, checkpoint, notice dismissal and revision/scope/feed/alarm invalidation commit atomically. Personal definitions/actions, accepted-firing deduplication and parent metadata time remain independent. Whole-master cancellation/reopening preserves the cleared cutoff and individual flags; later singles/ranges retain v11.

Existing byte ceilings remain 4 MiB/link, 16 MiB/recipient and 64 MiB/scope, with configurable lower limits. Current targets plus one history slot cannot exceed 128. Deletion scrubs all private evidence. No SQL, generated API signature, dependency or retention expansion is added. Existing strict legacy reads and retry authorization remain; no read upgrades stored state.

The example reuses explicit range application controls and explains both strict sequence floors. New range CANCEL/restoration cycles, range replies, broader scheduling and real mail remain separate. See [actual validation](scaffold-validation.md).
