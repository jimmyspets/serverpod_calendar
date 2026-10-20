# ADR 0043: Host-defined authorization with collection and object context

Status: **Accepted responsibility and context requirement; implementation contracts proposed**. Date: 2026-10-20.

## Context and confirmed instruction

The maintainer confirmed that calendar modules enforce authorization while hosts supply their own replaceable rules, and explicitly requested clear documentation and information about the collection or object being requested. This refines ADR 0005; it does not select a mandatory module identity directory, role/ownership model or separate authorization package.

## Decision

Require a server-side host authorization adapter. The module invokes it for every relevant operation using trusted actor/scope, specific operation and authoritative collection/object context. Missing policy or unresolved/denied decisions cannot grant access. Authentication alone is insufficient.

A calendar is the containing collection for its items; object context includes its type/ID, actual calendar and relevant ancestors. Calendar creation/listing targets the host-resolved scope instead. Occurrence operations include original recurrence identity. Validated proposed changes and destination/reference context allow the policy to distinguish current state from requested changes. Client-claimed IDs, membership or parentage are never authority. UI groups, feed selections and availability contributors remain distinct and do not confer access.

Host applications can supply existing ACL, organization/group or custom object policies. The example supplies synthetic rules through the same contract. Enforce within server services, including queries and background paths; keep policy independent of temporal core and client code. Separate event details, busy projection, writes, association management and publication. Query integration must preserve privacy and correct bounded pagination; availability never treats missing contributors as free.

Detailed context, operation cases and future acceptance tests are in [host authorization](../host-authorization.md). The listed field/type names and interfaces are proposals, not generated schemas or implemented APIs. Permission evaluation must participate in the mutation snapshot/revision protocol. External policy services require an explicit consistency/revocation contract; a module transaction alone cannot make remote decisions atomic.

## Confirmed granularity refinement, 2026-10-20

During the operation review, the maintainer explicitly chose separate permissions for calendar name/description changes versus availability zone/working-hours/no-rule fallback changes. They also chose separate permissions for task content, completion/reopening/progress and assignment changes. Hosts may map multiple actions to the same rule. Mixed requests require all applicable checks without partial commit or silently ignored fields.

The [operation catalog](../authorization-operations.md) documents proposed action families/targets and examples. These two permission separations are confirmed; the rest of the identifiers, query/result/transaction contracts, deletion behavior and task lifecycle remain proposed. This refinement does not implement authorization or introduce required roles.

## Alternatives and consequences

A built-in fixed owner/role scheme prevents hosts from reusing their business rules. A caller-only callback lacks the target information needed for object-specific decisions. Client-side enforcement or endpoint-only checks miss internal jobs and other entry points. A replaceable host adapter preserves customization but requires careful query, transaction, disclosure and outage contracts.

This records the agreed boundary without implementing calendar CRUD or selecting final adapter signatures, query constraints, error mapping, ownership, deletion or caching protocols. Raw policy inputs are server-only; no credentials are forwarded as context. The optional feed module retains its own lifecycle and calls the same host policy boundary under ADR 0042.

## Acceptance conditions

Before dependent endpoint/schema work, finalize target/snapshot/change types, supported operation set, query/batch integration and transaction/external-policy consistency behavior. Implement replacement-policy tests, authoritative target/containment checks, forged-reference and tenant isolation tests, complete/unknown availability, stale writes, cross-instance behavior and worker/publication revalidation. Documentation approval alone provides no runtime authorization evidence.
