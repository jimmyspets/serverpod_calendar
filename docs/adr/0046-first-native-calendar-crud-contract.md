# ADR 0046: First native calendar CRUD boundary

Status: **Accepted dependent-delete rejection, explicit creation zone and nonempty native creation name; interfaces/schema proposed**. Date: 2026-10-20.

## Context and confirmed instruction

During the first calendar CRUD review, the maintainer selected rejection of deletion while active dependencies remain, an explicit named availability zone at creation and a nonempty native display name. This refines FR-02 and the model catalog without approving final storage/endpoint contracts.

## Decision

Calendar deletion does not cascade or implicitly archive/detach active events, tasks, rules, feed selections or other dependent references. Prove the absence of active dependencies at the effective delete boundary across hosts; safe conflict errors do not disclose hidden objects. Historical identity/receipt retention may need tombstones; exact physical deletion remains a schema decision.

Native creation requires a nonempty display name and an explicit named availability zone. The example may prefill values, but the server validates them; no server/device timezone inference or omitted host-default substitution. These are native API rules, not a claim that iCalendar NAME is mandatory. Exact label/protocol-name mapping, text limits and patch rules remain proposed.

Keep presentation, availability settings and subject associations on distinct permission paths. Enforce host rules with authoritative context, expected revisions and the declared guarantee under ADRs 0043–0045. A calendar link never creates an implicit host role/identity directory or automatic booking permission.

[The CRUD contract](../calendar-crud-contract.md) proposes the first command/view surface, batch boundary and future tests. [Adapter interface proposals](../authorization-adapter-contract.md) make context resolution, batch decisions, query planning and commit-guard responsibilities reviewable. Method names and result/configuration/storage details are not accepted final interfaces or runtime implementation.

## Alternatives and consequences

Automatic cascade deletion expands risk and lifecycle requirements; archiving needs its own visibility/availability/retention semantics. Initially rejecting active dependencies avoids selecting either workflow. Explicit zone input prevents environment-dependent all-day projections. A nonempty native name supports usable lists without changing permitted ICS syntax or inventing imported properties.

The separate optional feed module must register/check its dependencies through an explicit transaction contract when implemented, without reversing package dependencies. Initial calendar-only tests cannot prove later feed/scheduling/alarm deletion behavior.

## Acceptance conditions

Finalize label mapping/limits, typed commands/views/results, physical schema/IDs, host-adapter/query contracts and concrete commit/delete coordination before YAML/endpoints. Test native validation, independent authorization gates, stale revisions, safe dependency conflicts, concurrent dependency creation/deletion, replacement host policies, generated clients/migrations and Flutter CRUD on two hosts. No domain/runtime evidence follows from documentation approval alone.
