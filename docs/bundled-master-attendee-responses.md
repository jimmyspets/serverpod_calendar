# Bundled invitation master responses

Accepted [ADR 0176](adr/0176-bundled-master-attendee-responses.md) adds a dedicated master-response path for complete supported REQUEST bundles. The scoped implementation passed its complete affected local batch; exact-head full hosted checks remain a separate readiness gate. This does not establish complete scheduling interoperability.

`bundleResponse`, `bundleResponseActivity` and `sendBundleResponse` are separate from ordinary/instance response APIs. Accept, Tentative and Decline produce one minimal master REPLY using its exact optional SEQUENCE. They do not acknowledge independently versioned occurrence components or send one reply per component. The Flutter screen labels this boundary explicitly.

A response can precede calendar adoption, including a decline. Add, Apply and dismissal send nothing. With the same selected source, those calendar/review actions do not invalidate the response. A changed complete body, including a child-only change with an unchanged master tuple, makes the old response historical and withdraws unsent work. A cancellation prevents new responses; retained historical activity and exact authorized retries remain available. Retrying does not reactivate withdrawn work.

The host must approve ordinary response read/send/dispatch and the independent `readBundleMaster`, `sendBundleMaster` or `dispatchBundleMaster` operation. Private summary/raw-source access, verified recipient/attendee identity and approved organizer route remain required. Calendar adoption permission grants no response authority. Workers have no fabricated actor and recheck source, authority, generation, expiry and fenced leases.

The complete source bundle is validated and pinned under existing byte/component/work budgets. Host approval receives the complete immutable source separately from the actual single-component outgoing REPLY. Source addresses establish no authority. Unsupported child data must reject rather than disappear in a master-only projection.

The existing three response tables, retention and admission caps are unchanged. Commands use the separate `bundle-master-response-v1` criteria family; retained source validation determines the family on retries and dispatch. No stored mode flag is invented. Source omissions and native drafts remain intact. Actual database-second timestamps must strictly advance; the service returns a retryable unavailable result rather than inventing a future timestamp.

The example records deterministic synthetic attendee-sender MIME only. Transport acceptance does not prove organizer receipt, display or participation reconciliation. Instance/range bundle replies, broader reconciliation and real mail remain separate required work.
