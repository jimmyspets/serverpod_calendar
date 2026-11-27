# Host authorization and requested resource context

**Current implementation:** the first native calendar CRUD/association slice is described in [the implementation guide](calendar-crud-implementation.md) and [ADR 0049](adr/0049-first-calendar-crud-implementation.md). Broader model/interface proposals below remain future design unless explicitly covered there; this adds no iCalendar/feed-client compatibility.


Status: **maintainer-confirmed responsibility boundary; first calendar slice implemented under ADR 0049, broader API/data structures proposed**. The host supplies replaceable authorization rules; the calendar and optional feed modules enforce them. The host policy must receive information about the collection or object being requested. See [ADR 0043](adr/0043-host-authorization-context.md).

This is an integration adapter, not a required new authorization package, identity directory or fixed owner/role model. A host can use its existing ACLs, organization roles, membership service or custom business rules. The example will supply a simple synthetic policy; applications can replace it without changing the calendar module. Authentication identifies the caller; it does not grant calendar permissions by itself.

## Responsibilities

| Calendar/feed module enforces | Host policy decides |
| --- | --- |
| Invoke authorization on every operation and internal service path | Whether the authenticated caller may perform that operation |
| Resolve scope, containment and target identities from authoritative records | Current users, groups, roles, tenants and custom business rules |
| Provide the requested operation and minimal target/change context | Object-specific access, permitted fields and any explicit inheritance |
| Apply authorized query constraints and response disclosure | Which collections/objects are visible, editable or available for free/busy |
| Reject absent, denied or unresolved authorization | Continuing publication authority and legitimate background-work recipients |

No configured policy means no domain access. A timeout/error cannot become an allow decision or a partial successful result. Existing diagnostic endpoints only prove authenticated wiring; their `requireLogin` flag alone does not implement this contract; the new native service applies host-policy checks separately.

## What collection means

Use explicit typed references rather than an ambiguous collection name or a bare object ID. A **calendar is the containing collection for its events, tasks and availability definitions**. A collection-level operation identifies that calendar; an object operation identifies both the object and its containing calendar. Listing or creating calendars instead targets a server-resolved host scope, because the new calendar has no ID yet.

UI folders/groups, feed selections and person/resource availability contributors are distinct concepts. They do not grant access to their member calendars or become authorization containers automatically. General-purpose calendar collections have not been selected. If introduced later, give them their own typed identity and explicit membership/policy rules. The separate protocol meaning of UID collection scope also does not establish permission.

## Permission granularity

The maintainer confirmed separate permissions for calendar presentation versus availability changes, and for task content versus progress versus assignment changes. Hosts can map these distinct operations to the same business rule. Mixed requests require every applicable permission before an atomic commit. The [operation catalog](authorization-operations.md) gives the proposed actions, targets, composition rules and examples; exact API names and unreviewed operation details remain proposals.

## Context supplied to the adapter

The following are candidate server-only contracts, not generated-client request types or final Dart interfaces:

| Context | Information available to the policy |
| --- | --- |
| Trusted actor | Host-authenticated principal and trusted execution kind: interactive caller, background service or publication context. No client-asserted roles/membership; no raw JWT or feed secret |
| Isolation scope | Host-resolved scope/tenant key and trusted host context. A subject namespace is not a substitute for this scope |
| Operation | Specific action, such as list calendars, read event details, query free/busy, create/update/delete item, manage associations, import/export or publish |
| Collection target | Typed calendar reference, or host-scope reference for calendar listing/creation; authoritative parent/containment context |
| Object target | Typed object kind and internal ID when one exists: calendar, event series, task, availability rule, feed or credential management record; relevant parent chain |
| Occurrence target | Series identity plus original typed recurrence identity for an occurrence operation, distinct from a moved occurrence's effective start |
| Current snapshot | Relevant server-loaded revision, lifecycle/classification and association references needed by policy. Minimal policy input, not unrestricted raw records |
| Proposed change | Validated intent/changed fields and resolved new references for creates, moves, association edits or publication changes; current and proposed states remain distinguishable |
| Query/disclosure | Requested detail versus free/busy/publication projection, bounded selection/window and pagination context, where relevant |

For example, reading an event can present: authenticated caller Alice, scope Acme, action `readEventDetails`, calendar Work, event Meeting-42 and its current revision. Editing it also presents the validated proposed change. Reading its busy interval is a different operation and can be permitted without revealing its title or attendees. These labels are synthetic illustrations, not literal API values or a default permission policy.

The module loads target metadata through trusted internal scope-limited lookups before constructing context. That internal lookup is not permission to disclose the record to the caller. Policy evaluation can inspect the necessary metadata without first granting detail access. Invalid IDs, foreign parents and scope mismatches must not leak inaccessible object existence through responses, errors, counts or logs. Exact error mapping remains to be specified.

The module verifies client-supplied IDs and parent relationships; it does not copy the request's claimed calendar ID into trusted context. The host authenticates identity/roles and resolves trusted scope. The module verifies all object references within that scope. Never send credentials or full bearer URLs as policy context or log them.

## Operation-specific behavior

- **List/query:** authorize the scope/collection query and apply host-authorized visibility/disclosure to its objects. Calendar access does not imply every item can be disclosed. Use bounded query integration with correct pagination/counts; never page first and silently filter away denied objects while claiming complete results. The typed query-constraint or batch-policy mechanism remains an implementation decision; arbitrary client-provided predicates are not trusted policy.
- **Create:** authorize creation in the resolved scope/parent against validated proposed fields. There is no existing object ID. A requested association, owner label or role is input to validate, not authority to grant itself access.
- **Read/update/delete:** supply the actual containing collection and target object. Authorization and disclosure can differ by operation and field. A calendar grant implies child access only when the host explicitly chooses that rule. Child edits include the ancestor context needed by policy.
- **Moves, links and association changes:** where the operation is supported, authorize the source, destination, referenced targets and intended change separately. Reading the source does not authorize moving it or granting someone access. Cross-scope references remain rejected unless a future explicit contract permits them.
- **Imports/batches:** validate and authorize all affected parents, objects and references before an atomic commit. One denied target cannot leave partial imported changes. Export authorizes the requested projection as well as its sources.
- **Availability:** the host resolves the complete contributing calendar set. Check calendar/object disclosure independently from permission to obtain a privacy-safe busy projection. Denied or unresolved contributing coverage is unknown, never apparently free.
- **Feeds:** the optional feed module identifies the feed and all selected calendars, authorizes management separately and revalidates continuing publication authority before content or 304. A bearer URL is read-only capability, not a caller identity or query/management grant. Use a trusted host publication authority reference, not the secret, for policy evaluation.
- **Workers/notifications/scheduling:** use a trusted purpose-specific execution/publication/participant context, not a fabricated interactive session or blanket bypass. Revalidate recipient access, generation, cancellation and expiry before dispatch/retries and on stream reconnection. Incoming mail identity still requires the separate verified scheduling ingress contract.

## Query disclosure and pagination

The maintainer selected separate detail/free-busy responses, predefined field-group disclosure and authorized initial pages with opaque continuation but no total counts under [ADR 0044](adr/0044-authorized-query-projections-and-pagination.md). A filtered detail list cannot establish availability. Hosts choose permitted typed groups per object; requested groups cannot grant themselves access. Exact group mappings, query/batch integration and cursor/snapshot mechanics remain proposed in [the query design](authorization-queries.md).

## Consistency and integration rules

Keep the adapter on the server integration boundary; the pure temporal core and generated Dart clients do not make policy decisions. Endpoints and background jobs call services that enforce checks; a second internal entry point must not bypass policy.

For a mutation, use a consistent authoritative target snapshot, enforce authorization against it and the proposed change, verify revisions, and commit the write/invalidation transactionally. Pass transaction/snapshot context through the eventual adapter API where needed. Reject stale revisions rather than overwriting. A database transaction cannot make an external authorization service atomic: the host/module contract must define its consistency, revocation/version and outage behavior before implementation. No cross-system atomicity is claimed here.

Do not cache allow decisions by process alone or assume JWT logout instantly revokes an already-issued access token. Current host permissions and feed revocation remain separate checks. Any policy caching must have an explicit bounded invalidation/version contract that works across active hosts and satisfies required revocation behavior.

## Declared consistency guarantees

The maintainer selected support for both transaction-coordinated policies and external fresh checks, with guarantees explicitly declared and no silent downgrade under [ADR 0045](adr/0045-authorization-consistency-guarantees.md). External permission can change after its final check and before commit unless the host supplies effective coordination; same-database reads alone do not prove coordination either. Defaults, per-operation requirements, deadlines and mechanisms remain proposed in [the consistency guide](authorization-consistency.md). Required current feed/worker/cursor checks are not weakened.

## Concrete interface proposals

[Adapter contracts](authorization-adapter-contract.md) propose separate trusted context resolvers, guarantee declaration, keyed batch decisions, candidate query planning and a commit guard. These are reviewable responsibility/method contracts, not implemented or accepted final Dart signatures. [The first calendar CRUD contract](calendar-crud-contract.md) applies those paths to creation, reads, metadata/settings/associations and dependency-safe deletion.

## Implementation acceptance checklist

- [ ] Verify presentation permission cannot change availability settings/rules; task content, progress and assignment permissions remain independent, including mixed requests and alternate/nested payloads.
- [ ] Register two different host policies without changing module code: a simple synthetic policy and a custom object-level policy.
- [ ] Verify the adapter receives scope, actual collection/object/ancestor identities, operation and validated proposed changes for each service path, including create and occurrence operations.
- [ ] Test absent adapter, deny/error/timeout, forged caller/parent IDs, colliding IDs across scopes and child-specific detail restrictions.
- [ ] Test group disclosure and authorized pagination without totals, mixed permitted/denied objects and separate privacy-safe complete/unknown free/busy coverage under [ADR 0044](adr/0044-authorized-query-projections-and-pagination.md).
- [ ] Test stale revisions and permission changes during writes; specify external-policy consistency limits explicitly.
- [ ] Test atomic imports, source/destination authorization, association changes, publication revocation before 304 and worker/stream revalidation as those features are implemented.
- [ ] Exercise two independent host processes sharing storage; confirm no local allow cache or internal service bypass changes outcomes.

These are future acceptance tests, not test results. Detailed role/grant semantics, method/type names, query integration, deletion policy and policy-revision protocols remain design work. See [models](models.md), [requirements](requirements.md), [external subjects](adr/0005-external-subjects.md) and [availability composition](adr/0012-calendar-availability-policy.md).

## Native occurrence previews

[ADR 0054](adr/0054-native-event-recurrence-and-previews.md) adds `previewEventOccurrences`, checked together with `readEvent`. Both must disclose the timing group. The request includes `occurrenceQuery` with the actual requested event UUID, saved revision and DATE/UTC bounds, alongside resolved parent/calendar and current event snapshots. Actor and scope remain host-derived. The preview returns only bounded geometry/original identities for that authorized event, not hidden titles/other groups or complete calendar availability. Ordinary timing disclosure also controls the recurrence definition in event views.

Pattern updates authorize the fully merged and validated proposal: explicit dates survive by default; incompatible profiles reject, while `replaceRecurrenceDates=true` expresses deliberate replacement/clearing of both lists. Recurrence collections exposed to callbacks are frozen by adapter validation; generated immutable DTO declarations alone do not freeze incoming lists. No process-local permission cache is introduced. The private-scope example epoch becomes v6; it is still a replaceable example fresh-check policy.

## Occurrence timing action context

[ADR 0055](adr/0055-native-occurrence-timing-edits.md) supplies `occurrenceChange` with exact single/future action and original start, `currentEvent.timingOverrides`, and final validated `proposedTimingOverrides`. Preliminary intent authorization precedes target-specific validation; null proposed overrides at that phase is not a clearing command. Timing replace/clear actions use `updateEvent`; single cancel/restore uses `changeEventStatus`, retaining timing independently. Ordinary master updates preserve/revalidate separate override state. Timing-group disclosure controls override reads, while mutation receipts remain independently disclosable. No read grant, scheduling authority or fixed host role is inferred. The demo epoch is v7; production coordinated-policy/revocation guarantees remain host responsibilities.

## Independent calendar free/busy authority

[ADR 0056](adr/0056-first-calendar-free-busy.md) adds calendar-level `readFreeBusy` and required-source `projectEventBusy`, with immutable `freeBusyQuery` and actual parent/event snapshots. Detail permissions/disclosure and `planEventQuery` cannot hide bookings from complete coverage. Denied/unavailable required projections produce unknown with no periods; denied query authority fails before source inspection. Revalidate context even for unknown results. Responses contain no event IDs/content/source counts or scope-generation values. Scope-row snapshot coordination is not a reservation or a host external-policy revocation guarantee. The example epoch is v8.

## Native availability definition authority

[ADR 0057](adr/0057-native-working-hours.md) adds independent `listAvailability`, `readAvailability`, `createAvailability`, `updateAvailability`, `deleteAvailability` and `projectAvailability` operations. Requests include actual calendar/definition UUIDs, frozen `currentAvailability`, full validated `proposedAvailability` and projection `freeBusyQuery`. Raw reads are all-or-nothing in this slice; receipts remain independently disclosable. Filtered management lists cannot supply coverage. Denied required projection yields unknown with no periods, while raw details can remain denied during successful projection. Expected revisions, final authorization and parent dependencies use the durable scope transaction across hosts. The private demo epoch is v9; host guarantees remain explicitly declared.

## Subject resolution and summary projection

[ADR 0058](adr/0058-subject-availability-search.md) adds `resolveAvailabilitySubject`, returning a complete authoritative in-scope contributor set plus private revision, and separate `readSubjectAvailability` / `projectCalendarAvailability` permissions. Raw calendar/free-busy/detail access is independent; event/rule projection remains required. Frozen `availabilitySearchQuery` / `availabilityTarget` accompany actual source context. Summary denial yields unknown without distinguishing target existence. Recheck successful target rights and resolver revision/set after calculation; host context changes fail. The supplied scope transaction coordinates module data, not external directories/ACLs automatically. External after-check races remain declared; snapshot IDs are not leases. The demo epoch is v10. See [host integration, limits and privacy](subject-availability-search.md).

## Availability opening actions and metadata

[ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md) adds `previewAvailabilityOccurrences` (plus raw read), `changeAvailabilityOccurrence` and `updateAvailabilityMetadata`. Current snapshots contain retained opening edits; requests expose `availabilityOccurrenceChange`, `availabilityOccurrenceQuery`, `proposedAvailabilityEdits` and `availabilityCategoryFilter`. Preliminary actions authorize intent before target validation; final checks receive the validated proposal. Metadata-only updates reject structural changes; ordinary full updates require both applicable gates when metadata/identity-order projection changes. CLASS labels grant nothing. Raw rules remain all-or-nothing disclosure, and filtered categories never supply source coverage. The demo policy epoch is v11; coordinated/external guarantee limits are unchanged.
