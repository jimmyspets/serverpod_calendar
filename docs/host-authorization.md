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

## Native availability organizer approval

[ADR 0060](adr/0060-availability-publication-metadata.md) adds required host-policy `approveAvailabilityOrganizer` alongside ordinary operation authorization. Both preliminary and final content writes invoke it when current or proposed organizer exists, including removal. It receives trusted context, actual parent/current definition, final validated proposed content and retained edits, transaction and phase. Denial/errors/timeouts fail atomically; approval grants no ordinary metadata rights or scheduling authority. The declared coordination guarantee covers this adapter too. An external fresh check still has the documented revocation race. See [native metadata limits and examples](availability-publication-metadata.md).

## Availability protocol lifecycle context

[ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md) adds immutable `currentAvailability.protocolState` and final `proposedAvailabilityProtocolState` for native create/content/occurrence writes. The proposal can be absent before server timestamp allocation; final checks receive the exact state to persist, including unchanged versions on identical saves. This grants no additional authority. API revision remains the optimistic-concurrency value; internal updatedAt and scope generation still advance on accepted identical writes, while protocol stamps/SEQUENCE do not. Raw rules retain all-or-nothing disclosure and busy summaries expose none of this metadata. See [native lifecycle guarantees and legacy baseline](availability-protocol-lifecycle.md).

## Proposed availability import boundary

[The create-only import contract](availability-import.md) records confirmed distinct import authority plus per-definition create authority and proposes actual destination/parent context, source UID/protocol state and full source-preserving validated proposals. Dedicated organizer approval and current private registration remain required at preliminary/final phases. This interface is not implemented. Existing external fresh-check limitations remain unchanged; source metadata and parsed objects never carry authorization.

## Implemented storage follow-up

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the implementation guide](availability-storage.md) supersede storage-pending wording for the scoped prerequisite/native behaviors. They document exact UID/group/CONTACT/PERIOD and component-version representations, retention, policy context, query caps and upgrade behavior. Authenticated import remains pending; conversion is not authorization or publication.

Source-preserving native writes under ADR 0072 gate echoed read-only CONTACT/opening protocol UIDs with readAvailability before equality checks and at final write. Correct/incorrect guesses both deny when raw read is unavailable. Write-only clients may omit these fields for server-side retention. Write-operation decisions continue to control receipt disclosure independently.


## Create-only availability import, 2026-10-22

[ADR 0073](adr/0073-authenticated-create-only-availability-import.md) and [the import guide](availability-import.md#implemented-create-only-operation) implement the bounded standalone availability import slice. `importAvailability` and per-definition `createAvailability` are independent, with full immutable batch context and actual parent/revision checks. Dedicated organizer and trusted extension validation run at both write phases. Exact active UID conflicts are destination-calendar scoped; the complete file commits atomically with source versions retained and final host-approved minimal receipts. This supersedes earlier pending-import wording only for this profile. Authorized export, source updates/reconciliation, other component import, feeds and external-client interoperability remain pending.


## Authenticated availability export, 2026-10-22

[ADR 0074](adr/0074-authenticated-availability-export.md) and [the export guide](availability-export.md) add current-state standalone availability output. The maintainer selected explicit definitions from one calendar and all-or-nothing authorization/availability. Require independent export and raw-read rights with full immutable selection context, reauthorize after serialization, preserve the supported component data and generate full-horizon pinned VTIMEZONE definitions. Native skip/restoration state, missing component checkpoints, duplicate opening source UIDs across selected definitions and over-limit/out-of-profile state reject explicitly. Export is a read with no revision/time changes and no HTTP feed or scheduling side effects. This supersedes export-pending wording only for the declared availability slice; source reconciliation, other component import/export, feeds and external-client interoperability remain pending.


## Availability replacement contract, 2026-10-22

[ADR 0076](adr/0076-availability-replacement-implementation.md) implements the scoped [availability replacement operation](availability-update.md#implemented-operation): private active-row source baselines, revision-bound explicit selections, exact source UID matching, local-conflict rejection, equal/lower source sequence handling, stable matching opening UUIDs and true authorized no-ops. Replacement requires import, dedicated replacement and current raw-read authority plus applicable edit rights, with final full-batch and organizer/extension checks. Changed members retain exact incoming protocol timestamps/omissions and atomically update their baseline/revision with one scope generation bump. Old/native-created rows have no assumed baseline. Adoption/overwrite, mixed upsert, broader source synchronization, feeds and scheduling remain separate.

## Privacy-safe VFREEBUSY export, 2026-10-22

[ADR 0077](adr/0077-privacy-safe-calendar-freebusy-export.md) and [the VFREEBUSY export guide](freebusy-export.md) add authenticated per-calendar UTC snapshots, using complete booking/working-hours coverage and independent export/query/source-projection authority. Unknown coverage rejects rather than appearing free. Output contains classified periods, fresh snapshot identity/time and bounds, without private source details or IDs. Current authority is repeated after serialization; stored state is unchanged. Subject/common-free export, scheduling, HTTP feeds and external-client interoperability remain separate.


## Event import contract, 2026-10-22

[ADR 0078](adr/0078-create-only-event-import-and-storage.md) and [the event import contract](event-import.md) confirm storage extension before create-only VEVENT import: destination-active exact UID conflicts, retained independent source versions/omissions, separate import/create/lifecycle rights, native CONFIRMED for omitted STATUS with source omission retained, and a private active-row source baseline from the first import. Decoded components are preserved while envelope/zone presentation is regenerated. Actual native component changes advance versions; identical normalized saves keep protocol state; annotations require explicit changes; legacy local initialization invents no import history. This is the historical contract record. ADRs 0079 and 0080 now implement scoped storage and create-only import; concrete mechanics remain under draft review, and event export/replacement remains separate.


## Create-only event import, 2026-10-23

[ADR 0080](adr/0080-authenticated-create-only-event-import.md) and [the implemented import guide](event-import.md#implemented-create-only-operation) add authenticated full-file create-only VEVENT import. Require separate import/create authority and lifecycle permission for cancelled masters/single occurrences, using immutable full-batch actual-parent context and final transaction checks. Preserve supported source semantics/versions and a private active-data baseline; exact active UID conflicts are destination-local. Return only final-approved minimal receipts, with no implied detail access. The schema is unchanged from ADR 0079. Event export, replacement/adoption, feeds, scheduling and alarms remain separate.


## Current-state event export, 2026-10-23

[ADR 0082](adr/0082-authenticated-current-event-export.md) and [the export guide](event-export.md) implement explicit revision-bound complete series from one calendar. Require separate export permission and all supported read-disclosure groups, with complete selection context and repeated post-serialization checks. Generate current supported semantics and pinned zones, excluding historical baseline/native storage metadata. Reject unrepresentable cancellation restoration state and any decoded current-state mismatch; never silently normalize or redact. Export is read-only; source replacement, feeds, scheduling and alarms remain separate.


## Native task increment, 2026-10-23

[ADR 0084](adr/0084-first-native-task-implementation.md) and [native task documentation](native-tasks.md) implement the confirmed ADR 0083 non-recurring CRUD/assignment/progress choices. Typed undated/DATE/UTC/named-zone tasks use independent host operations/disclosure, optimistic revisions, opaque pagination and content-free deletion markers. Completion is 100 percent with server whole-second UTC time; cancellation preserves percentage and clears current completion time; reopening resets to 0. Tasks never book time. Recurrence/history, task-specific filters, VTODO interchange, scheduling and alarms remain pending. This scoped increment supersedes earlier blanket statements that durable tasks are entirely unimplemented.


## Recurring task increment, 2026-10-23

[ADR 0086](adr/0086-durable-task-recurrence-implementation.md) and [recurring tasks](recurring-tasks.md) extend the initial native task slice with canonical recurrence, bounded start-based previews, independent original-occurrence progress and retained transition history. Reject orphaning pattern edits and ambiguous conversion from previously progressed or unknown legacy tasks. Retain history while active and scrub it at deletion. Preview/history have independent host operations/current timing/progress disclosure and isolated opaque history pages without totals. VTODO interchange, task timing/content exceptions, all-series lifecycle actions, scheduling and alarms remain separate. This scoped increment supersedes older non-recurring-only implementation statements.

## Explicit task source replacement, 2026-10-24

[ADR 0104](adr/0104-task-source-replacements.md) and [the replacement guide](task-source-replacement.md) extend create-only task import with explicit revision-matched, all-or-nothing existing-series replacements. Current v3 baselines protect local content/progress, native assignments survive, lower master SEQUENCE rejects, equal is allowed and exact source timestamps/omissions remain intact. Identical replacements are true no-ops without adopting local edits. Require independent import/replacement, full ordinary-detail and rich-source-read authority plus applicable update/progress gates; historical snapshots stay private and source alarms stay unarmed. Adoption/overwrite, mixed upsert, scheduling, feeds and runtime remain separate. This supersedes earlier task-replacement-pending statements only for this bounded slice.

## Explicit event source replacement, 2026-10-24

[ADR 0105](adr/0105-event-source-replacements.md) and [the replacement guide](event-source-replacement.md) add explicit atomic existing-series replacement under independent import/replacement/full-detail and applicable edit/lifecycle authority. Current recorded baselines protect local edits; lower master SEQUENCE rejects, equal is allowed and source timestamps/omissions stay exact. Identical retries change nothing and never adopt a dirty baseline. Lifecycle checks include master status transitions and changes to the exact set of cancelled originals, including removal. Historical snapshots stay private. This supersedes earlier event-replacement-pending statements only for this bounded slice; adoption/overwrite, mixed synchronization, richer profiles, scheduling and feeds remain separate.

## Selected event occurrence content

[ADR 0106](adr/0106-single-event-content-overrides.md) adds `calendarEvent.changeOccurrenceContent` under `updateEvent`, independently of lifecycle permission. Immutable `eventOccurrenceContentChange` identifies the exact original; currentEvent carries actual parent/current content/overrides, and final `proposedTimingOverrides`/`proposedEventProtocolState` carry the validated result. Expected revisions, durable scope coordination and final declared-guarantee checks remain required. Previews optionally request summary/description/location in addition to timing and require both read and preview disclosure of every requested group. Detail/nested fields and component-version lists hide undisclosed content-only nodes. See [the content guide](event-occurrence-content.md).

## Read-only event source metadata, 2026-10-24

[ADR 0107](adr/0107-read-only-event-source-metadata.md) and [the metadata guide](event-source-metadata.md) add source-preserved CLASS/URL and grouped CATEGORIES/COMMENT/CONTACT with legal annotations. Native editors retain these values; source-only values grant no authority and cause no retrieval. Independent `readEventSource` gates complete export and source replacement, including no-op/final paths. Omitted occurrence metadata inherits and explicit values must match the master; native metadata-only originals preserve timing inheritance and reject lossy export. Nullable server-only JSON fields preserve v2 baseline compatibility, with no new table columns or automatic reset. Broader/native metadata editors and other profiles remain separate. Broader batch verification is recorded in scaffold-validation.md.


### Event source participants — ADR 0108

[Inert event source participants](event-source-participants.md) now extend the bounded read-only source profile with ORGANIZER/ATTENDEE, preserved through storage, native edits and authorized import/export/replacement. They remain outside ordinary responses under independent source-read permission, with no host identity mapping, authority or invitations. Omitted own claims inherit; explicit claims must match the master. Native participant editors, richer profiles and scheduling remain separate.


### Inert event source references — ADR 0109

[The bounded source-reference profile](event-source-references.md) preserves unresolved RELATED-TO UIDs and URI-only ATTACH values through storage, native edits and authenticated import/export/replacement. Existing source-read authority protects disclosure; no native graph, target/file access, fetching, mail copying or scheduling follows. Extended relationships and native editors remain separate. Nullable source JSON adds no table columns/migration and preserves prior v2 snapshots; a narrow decoder correction handles omitted empty participant parameter maps without changing canonical bytes.

## Unarmed event source alarms, 2026-10-24

[ADR 0110](adr/0110-unarmed-event-source-alarms.md) now extends the supported source profile with [unarmed VEVENT DISPLAY alarms and bounded sibling snoozes](event-source-alarms.md). Nullable immutable server-only alarm/duration DTOs use existing metadata JSON, without table changes or a migration. Existing event-source-v2 baselines remain compatible. Separate `readEventSource` authority protects export/replacement and final/no-op checks; ordinary projections hide this data. Native edits preserve definitions and reject incompatible explicit-END anchor changes atomically. Source UID/ACKNOWLEDGED/SNOOZE are unverified data, never recipients, authority or native actions. This supersedes earlier event-alarm rejection/pending wording only for this source-preservation slice. Native personal definitions/editors, adoption, planning, delivery, feeds and client interoperability remain separate requirements.


## Native personal alarm definitions, 2026-10-24

[ADR 0111](adr/0111-native-personal-alarm-definitions.md) adds [private native event/task timing definitions and example editors](native-personal-alarms.md). The host resolves the current recipient; requests cannot select another. Independent alarm permissions, actual parent/current/proposed context, final recipient checks and revisions protect one bounded private table. Shared edits retain incompatible definitions as needing attention; parent deletion scrubs all recipients atomically. Private writes leave item/protocol versions, source baselines and public scope generation unchanged. All definitions remain unarmed; imported-alarm adoption, actions, planning and delivery remain required separate work. Concrete mechanics remain draft review material.

## Optional event-feed increment, 2026-10-25

[ADR 0116](adr/0116-optional-event-subscription-contract.md) records the approved separate module, stable publication UIDs, exclusion of all alarms and four-table/default choices. The [feed guide](http-event-feeds.md) describes scoped management/publication/HTTP implementation and the required whole-host logging guard. This supersedes blanket feed-not-implemented wording only for that bounded profile. Native and authenticated source behavior remain independent; full local batch validation passed and external subscription-client, scheduling and other release gates remain open.

## Complete scheduling-message disclosure

Accepted [ADR 0126](adr/0126-independent-occurrence-publication-versions.md) explicitly changes the unpublished scheduling port to `CalendarSchedulingHost.authorizeMessage`. Hosts receive actual current/final native snapshots, the complete canonical `publicationEvent`, typed complete `outgoingMessage`, exact `intent.payload` and its SHA-256 `payloadDigest`. Both dedicated command checks receive built candidates; ordinary preliminary authorization precedes private checkpoint/projection validation. Background checks receive the retained complete message and fresh current state, never a fabricated user or regenerated local draft. Approve every outgoing component for every recipient using trusted authority and routes; an old master-only implementation must be updated explicitly. Existing independent edit/lifecycle/publication/full-detail/source permissions and declared consistency guarantees still apply, including the external fresh-check revocation race. Source claims, projected fields and private version ledgers grant no authority.

Under accepted [ADR 0127](adr/0127-retained-occurrence-reset-projections.md), outgoing reset components can contain explicit current fields while canonical current/final/publication snapshots show absent native own values. Hosts must authorize that exact computed disclosure without treating it as a stored native override or sender authority. Final denial rolls back publication/checkpoint writes while preserving already saved local clear/inherit state. Existing full-message approval, fresh worker checks, route/generation fencing and the external revocation-race limit remain unchanged.

Accepted [ADR 0128](adr/0128-explicit-single-occurrence-cancellation.md) enforces `cancelOccurrenceScheduling`, `readScheduling`, full event/source read and lifecycle authority independently. Preliminary access precedes historical validation. Final checks receive actual current/proposed native state, historical `publishedRequest`, exact typed target and `exactNativeMatch`, plus complete immutable message/bytes/digest. Lifecycle approval applies even without native mutation. Workers recompute current native membership and approve the retained historical message; source claims grant no authority. Host interfaces and generated DTOs change without a table migration.

Accepted [ADR 0129](adr/0129-explicit-occurrence-restoration.md) independently enforces `restoreOccurrenceScheduling`, scheduling read, full event/source and lifecycle authority even without a native mutation. Preliminary access precedes historical decoding; final host phases and workers receive exact published basis/target, current native-match result, complete current/final native state and immutable outgoing restoration bytes/digest. Ordinary editing, REQUEST publication and whole/instance-cancellation permissions do not substitute. Current sender/routes/parent/origin/generation/expiry and declared consistency guarantees remain required; cancelled native/published masters are not silently reopened.

## Proposed retained-cancellation reopening

ADR 0130 proposes independent published-series reopening authority and immutable host context containing current/final native state, unprojected published basis, mask identities and exact complete outgoing bytes. Restoration of a masked original would require full-message approval. These mechanics are unapproved; existing guards and canonical authority boundaries remain. See [ADR 0130](adr/0130-preserved-cancellations-reopening.md).
