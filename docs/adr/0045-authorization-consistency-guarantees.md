# ADR 0045: Declared authorization consistency guarantees

Status: **Accepted support for both coordinated and external policies with declared guarantees; mechanics/defaults proposed**. Date: 2026-10-20.

## Context and confirmed instruction

The maintainer selected support for transaction-coordinated host policies and external authorization services, with the supplied guarantee explicitly declared and no silent fallback to weaker checks. ADRs 0043/0044 leave transaction/external-policy consistency open; this refines that boundary without implementing it.

## Decision

Support a host-supplied coordinated guarantee that orders relevant revocation and calendar commits, and an external fresh-check guarantee that authorizes the exact attempted write before commit but can race with later revocation. Do not infer the stronger guarantee merely from policy storage location. External integrations may supply effective coordination to meet a stronger requirement; local policy reads without adequate coordination may not.

Host/module configuration must declare the supplied guarantee and reject unsupported operation requirements. No automatic downgrade is permitted on a failed coordinated check. This decision does not select a default mode, per-operation requirements, adapter signatures, numeric freshness/deadline limits or a locking/fencing protocol. Missing/denied/unavailable/unprovable authorization cannot grant the domain mutation.

The [consistency guide](../authorization-consistency.md) proposes snapshot/revision-bound checks, all-gate evaluation for mixed changes, active-attempt/final-check validation, atomic domain/invalidation/outbound intent and separately authorized response disclosure. Every transaction retry reestablishes authorization; stale revisions reject instead of silently rebasing user intent. Database transactions alone cannot eliminate a remote permission race.

Feed-token revocation/current publication checks, cursor reauthorization and worker recipient/generation checks remain required; the external write profile is not permission to weaken those independent boundaries or use stale cached grants. Two-host correctness cannot depend on process-local coordination.

## Alternatives and consequences

Requiring coordinated policy for every deployment would exclude useful host integrations with external authorization systems. Treating every pre-commit allow as atomic would promise a guarantee the module cannot provide. Declared capabilities permit both while making the remaining after-check race explicit. Hosts needing stronger revocation ordering must supply effective coordination and participating revocation paths.

Same-database policy reads, version labels and repeated remote checks do not by themselves close every commit race. The integration must specify actual snapshot/serialization/freshness behavior and fail when it cannot meet the selected operation requirement. Operational defaults and implementation details remain review gates.

Concrete [adapter method proposals](../authorization-adapter-contract.md) now identify a commit-guard responsibility alongside batch checks and query planning. They do not close the concrete coordination/freshness gates below. [ADR 0046](0046-first-native-calendar-crud-contract.md) selects the first calendar creation/deletion rules.

## Acceptance conditions

Review guarantee declarations/defaults, required operation profiles, authoritative freshness, protected target/change/attempt evidence, bounded failures, transaction/retry/receipt handling and the concrete coordination mechanism. Test two-host revocation/write ordering, external after-check races, late/expired/mismatched allows, stale revisions, crashes/retries, current feed/worker checks and no side effects before commit. Documentation approval provides no runtime or provider-specific guarantee.
