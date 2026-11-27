# ADR 0005: External subjects and host authorization

Status: **Proposed**. Date: 2026-10-19. The maintainer requires flexible external user/group associations and calendars for rooms, venues and equipment. Users and groups are not stored in this project; resource catalog integration is proposed at the host boundary. The adapter and association schema below are proposed.

Confirmed refinement: [ADR 0043](0043-host-authorization-context.md) selects module enforcement with host-defined replaceable rules and trusted collection/object context. The [authorization guide](../host-authorization.md) describes current/proposed state, query and execution cases; detailed signatures/schema remain proposed. This does not accept the remaining association/role proposals below.

## Proposal

Store only calendar-to-subject associations using opaque `(namespace, kind, externalId)` references. Kind distinguishes users, groups, rooms, venues and equipment, with host-defined extensions; namespace scopes host/tenant references. Allow several subjects on one calendar and one subject on many calendars. Resource catalog ownership is proposed at the host boundary. ADR 0006 distinguishes availability-contributing links from management/access links. Never add module user/group profiles, credentials or membership tables, or foreign keys to a mandatory host identity schema.

The host supplies authenticated caller context, current group membership and per-operation read/write/manage/publish/free-busy decisions through an adapter. A client-supplied association or group ID is not proof of permission. A simple subject link does not itself define a role; exact role/grant semantics are a host policy contract to approve before implementation. Check access for reads, writes, list queries, import/export, association edits and all feed management. For aggregation, require publication authority over every selected calendar.

Feed publication stores a host-defined authorization context/reference, not a snapshot of subscriber group membership. Revalidate the host's continuing publication authority before serving any URL, even conditional requests; deny on withdrawal or unresolved identity. The URL remains a bearer credential: it does not identify its subscriber. Removing an association, group membership or host identity must have documented effects on management rights and affected publications; proposed behavior is fail closed until repaired.

## Alternatives and consequences

A module-owned identity directory duplicates host concerns and conflicts with the requested boundary. A single owner ID cannot represent flexible user/group ties. Resolving authorization only at URL creation allows stale publication after rights are removed.

The module stores association references but does not manage the external identities. Host integration and policy availability are part of its operational contract. Example identities are synthetic host-side fixtures, not production identity tables in the module.

## Acceptance conditions

Approve the adapter, namespaces/tenant boundary, roles and publication-revocation lifecycle. Demonstrate multiple subjects per calendar, direct-user and group access, association updates, group membership/identity removal, forged references, tenant collisions and policy outages. Confirm the module schema contains no users, groups or membership directory. Review room/venue/equipment references and distinct free/busy visibility under [ADR 0006](0006-resource-availability.md).
