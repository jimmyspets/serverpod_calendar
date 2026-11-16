# Durable exceptional-anchor range controls

ADR 0187 extends the explicit organizer range cancellation and restoration
actions to a bounded class of published anchors that already have a single
occurrence component, a retained single reset or a module-owned individual
cancellation. It uses the last authorized published REQUEST as its source;
newer native drafts do not become outgoing content implicitly.

Before accepting a cancellation, the module constructs and validates a
complete restoration candidate. It distinguishes individual cancellations
proved by the publication ledger from source EXDATEs. Independent cancelled
originals and source exclusions remain excluded; exceptions, native inheritance
and individual cancellation state remain intact. Restoring the range clears
only the range cancellation and does not restore an individual cancellation.

Version-8 checkpoints retain bounded, validated source and candidate evidence
in existing publication storage. The serialized checkpoint must fit the
existing byte and occurrence limits. Malformed evidence, missing provenance,
unbounded recurrence, unsupported collisions, exhausted work or capacity and
unrepresentable candidates reject without silently dropping data. The first
profile does not claim support for every possible recurrence or exceptional
anchor; the pure projection's restrictions remain in
[its guide](exceptional-range-restoration-projection.md).

Both actions retain the existing independent host permissions and full-source
disclosure checks. The host approves the complete outgoing message and routes;
background dispatch must recheck current authority and the recipient route.
Retried commands are reauthorized, and delivery uses the existing fenced,
durable outbox and fixed-recipient transport. This feature does not send real
mail or change the host's responsibility for identity and authorization.

[Validation](validation-durable-exceptional-range.md) records the focused,
two-host, browser and broader checks separately. The 4.1.2 workspace remains
in draft because of the independent [feed 304 regression](feed-304-compatibility.md);
passing scheduling tests does not establish release readiness.
