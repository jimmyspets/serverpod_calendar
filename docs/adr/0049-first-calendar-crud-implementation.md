# ADR 0049: First calendar CRUD implementation

Status: **Accepted duplicate-name/private-demo/basic-batch scope; concrete implementation mechanics under review**. Date: 2026-10-20.

## Confirmed scope

The maintainer selected duplicate native display names, private scopes per signed-in demo user, and a first working batch covering names, named availability zones, free/unavailable fallback and subject associations. Descriptions, colors and iCalendar metadata editing follow separately. Private scopes are an example host policy, never a required module ownership model.

## Implemented slice and review choices

The module now defines generated request/view/error models, UUID identity plus unique active-data rows, subject links, durable scope generations and opaque cursor records. Its service enforces trusted host context, independent operation permissions, object snapshots, group disclosure, expected revisions and final write checks. The example supplies a replaceable `freshCheck` policy. Module installation explicitly selects its required guarantee; a weaker adapter is rejected without fallback.

All first-slice operations lock a database scope row in their transaction. This deliberately coarse first implementation serializes reads/writes within a scope across host processes. It provides calendar data coordination, not host-policy coordination. The `coordinated` contract requires the host's final authorization callback and every relevant revoker to coordinate until actual transaction commit. No production coordinated adapter ships in this batch. External services can revoke immediately after the last fresh check; this residual race is explicit.

Pagination uses ascending UUID order and server-stored random handles, bound to actor, trusted scope, query groups/page size, authoritative policy epoch and scope data generation. Any scope mutation invalidates old continuations; clients restart explicitly. Per-object authorization and lookahead prevent a hidden-only cursor or false exhaustion. Work-limit/authorization failures fail the whole query. There are no total counts, search filters or locale ordering in this slice.

Creation/deletion are atomic. Deletion rejects real subject dependencies and registered dependency-provider conflicts/errors, removes the active payload, and retains exactly UUID/scope/revision/deletion time. Later event/feed/rule/worker modules must implement the same active-parent/delete coordination before integration; an extension interface is not evidence for those future tables. Marker retention and global cursor/scope cleanup remain undecided.

See [the implemented API, validation rules and limits](../calendar-crud-implementation.md). Native labels never become protocol NAME values. Neither fallback storage nor subject links implement availability calculation.

## Alternatives and consequences

Per-calendar locks would improve concurrency but need additional list/generation coordination. Stateless cursors avoid cursor rows but still require integrity, actor/policy/data binding and privacy-aware exhaustion; the first bounded implementation instead uses durable handles. Duplicate labels avoid treating presentation as identity. The fixed demo self-association restriction shows trusted reference validation without imposing a production identity directory.

## Validation

Use the focused module text tests and real example database tests during feature work, then the root batch check for regeneration, analysis, VM/Chrome, fresh migrations, two-host generated-client races and Flutter journeys. Results belong in [validation evidence](../scaffold-validation.md), with limitations distinguished from future acceptance work. Merging this implementation does not accept every proposed architecture detail or imply event/feed/scheduling interoperability.
