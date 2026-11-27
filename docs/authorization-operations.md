# Authorization operation catalog

Status: **documentation proposal, not implemented operations or final enum names**. The maintainer confirmed the permission separations below; the remaining catalog makes the adapter contract concrete for review. This does not finalize query constraints, policy result types, deletion semantics or task lifecycle. See [the context guide](host-authorization.md) and [ADR 0043](adr/0043-host-authorization-context.md).

## Confirmed permission separations

The maintainer selected both refinements on 2026-10-20:

1. Editing calendar name/description is separate from changing availability zone, working-hours rules or no-rule fallback. Calendar presentation changes cannot bypass availability authorization.
2. Editing task content, completing/reopening a task and changing task assignments use separate permissions. A host may allow completion while denying reassignment or content editing.

Hosts may map several operations to one policy rule. Separating operations does not force distinct roles, ACL tables or a separate authorization package. A host can use the trusted object/change context to distinguish finer cases, such as completing versus reopening or adding versus removing an assignee. No operation automatically grants another operation.

## Proposed operation matrix

Identifiers below are illustrative adapter action names, not existing endpoints or generated-client methods. Each operation receives the trusted actor/isolation scope and authoritative target context described in the guide. Creates have no existing object ID; the resolved parent and validated proposed fields are supplied instead. Queries include requested projection and bounds.

| Operation family | Proposed actions | Authoritative target and purpose |
| --- | --- | --- |
| Calendar discovery | `calendar.list`, `calendar.readMetadata` | Host scope for list; each calendar for metadata disclosure. Listing does not grant item details |
| Calendar creation | `calendar.create` | Host scope plus validated new description/settings/associations; authorize each requested capability/reference |
| Calendar presentation | `calendar.updateMetadata` | Existing calendar/revision and proposed writable presentation changes, such as name/description |
| Calendar availability settings | `calendar.updateAvailabilitySettings` | Existing calendar/revision and proposed availability zone/no-rule fallback; separate from presentation |
| Calendar deletion | `calendar.delete` | Calendar/revision plus affected dependencies. Permission does not select cascade/retention behavior |
| Subject associations | `calendar.readAssociations`, `calendar.changeAssociations` | Calendar and validated added/removed/changed subject/contribution references; current and proposed links distinct |
| Event discovery/details | `event.list`, `event.readDetails` | Calendar for query; event/series and actual calendar for detail disclosure; occurrence identity when applicable |
| Event changes | `event.create`, `event.update`, `event.cancel`, `event.delete` | Parent/current/proposed event context. Whole-series/single/THISANDFUTURE scope is explicit; cancellation and deletion are distinct |
| Task discovery/details | `task.list`, `task.readDetails` | Calendar/query or task/current parent; detail access does not grant editing or reveal private alarm state |
| Task content | `task.create`, `task.updateContent`, `task.delete` | Parent/current/proposed task fields. Content editing excludes progress and assignments |
| Task progress | `task.changeProgress` | Task/occurrence, current progress and requested completion/reopen/progress transition; lifecycle legality remains separately validated |
| Task assignment | `task.changeAssignments` | Task/occurrence plus current/proposed host-validated assignee references; no automatic mail or booking |
| Availability calculation | `availability.query` | Requested calendar/subject targets, complete host-resolved contributor set, bounded window and per-target/common-free mode; privacy-safe result projection |
| Raw availability rules | `availabilityRule.list`, `availabilityRule.read`, `availabilityRule.create`, `availabilityRule.update`, `availabilityRule.delete` | Calendar and rule/opening/override context as relevant; raw rules require their own access, separate from calculated free/busy |
| Import | `calendar.import` | Target calendar and validated import plan, then required per-object create/change/reference permissions; atomic batch |
| Export | `calendar.export` | Calendar/selected objects and requested profile/projection, plus disclosure authorization on every exported source |
| Publication authority | `calendar.publish` | Each selected calendar and intended feed projection, under the current trusted management/publication authority context |
| Optional feed administration | `feed.create`, `feed.readMetadata`, `feed.updateMetadata`, `feed.changeSelection`, `feed.delete` | Scope/new feed or actual feed/revision and old/new selections. Selected calendars also require publication authority |
| Feed credentials | `feedCredential.list`, `feedCredential.create`, `feedCredential.revoke` | Actual parent feed and token-free management identity/validated change. Lists expose nonsecret metadata only; creation returns secret once |
| Scheduling | `scheduling.act` | Event/free-busy subject, specific method/participant action, original occurrence/version and trusted participant authority. Ordinary event editing does not authorize sending scheduling mail |
| Personal alarms | `alarm.list`, `alarm.read`, `alarm.create`, `alarm.update`, `alarm.delete`, `alarm.activate`, `alarm.act` | Actual item/alarm/recipient and occurrence/generation; action distinguishes acknowledge/dismiss/snooze. Event detail access alone does not disclose another recipient's private state |
| Notification state/stream | `notification.readState`, `notification.subscribe`, `notification.act` | Recipient and referenced notification/item/occurrence with purpose-specific disclosure/action context. Generic notification-module APIs remain a separate contract |

Opening periods/overrides use the containing availability definition and their own object identity in context. An item move or cross-item link, when supported, must authorize the actual source, destination and referenced targets; `event.update` or `task.updateContent` is not a blanket destination grant. More specific move/link action identifiers remain subject to the relevant service contract.

A future scheduling/alarm/notification action must identify its concrete method or action in trusted context; these family names are not catch-all permissions or an authorization to implement arbitrary actions. Only the selected RFC/native scope is eligible. Receiving untrusted mail or ICS is not permission to execute alarms or send mail.

## Composition rules

An operation describes **what the caller is asking to do**, while target/context describe **where and to which object**. The host decides how these map to its own rules. Object kind, field changes, recurrence edit scope and current/proposed states prevent a general permission from hiding a more sensitive action.

- An update containing both calendar presentation and availability changes must pass both permission checks against one consistent snapshot before commit. Deny the whole change if either fails; do not silently ignore denied fields.
- A task content update cannot smuggle progress/assignee changes through nested payloads or an alternate endpoint. Mixed requests need each applicable check, including progress/assignment intents during creation. Ordinary creation permission alone does not permit adding arbitrary assignees or importing forged completion history.
- Read/list permissions are independent from mutations. A host may allow a bounded update without general read access; only the authorized mutation result is returned. A write never implies unrestricted response fields.
- Query permission authorizes the query operation, not every resulting object's details. Apply current object visibility and the requested projection under a bounded query/pagination contract. A privacy-safe availability projection may be allowed while event details remain denied.
- Container/parent grants do not imply child grants unless the host explicitly implements inheritance. Display groups, feed selections and availability-contributing associations do not grant anything by themselves.
- Import/export/publication/management checks compose with source/destination/object checks; the more general action cannot bypass them. Sharing checks within one validated batch is possible, but must not lose target/change distinctions.
- A valid bearer token is checked by the feed module. It is not an authenticated user's `feed.readMetadata` grant. Before GET/HEAD content or 304, revalidate the feed/token and current publication authority over every selected calendar using the publication context. Token possession never grants `availability.query` or calendar management.
- Worker processing is a trusted execution context with a concrete purpose, not a universal `system.allowAll` operation. Revalidate recipient authority and current generation/cancellation/expiry before actual dispatch or retries.

## Examples

**Calendar administrator versus availability manager:** a host permits Alice to rename Work but denies changing its availability zone or no-rule fallback. A combined rename/settings request fails atomically. Editing working-hours definitions also requires the appropriate raw-rule mutation permission; renaming the calendar never enables it.

**Task assignee:** a host permits Bob to read and complete a task assigned to him, but denies editing its content or changing assignees. The module supplies task identity, containing calendar, original occurrence when relevant, current assignments/progress and requested transition. No built-in assignee role is mandated; this is one replaceable host rule.

**Room search:** a host permits searching Room A's busy projection while denying event details and raw working-hours rules. The module uses authorized complete contributors internally and returns intervals/coverage without titles or private source IDs. A denied contributor cannot be omitted to manufacture free time.

## Confirmed query/disclosure refinement

[ADR 0044](adr/0044-authorized-query-projections-and-pagination.md) records the selected separate detail/free-busy responses, predefined field groups and initial pages with opaque continuation and no totals. Query authorization does not turn hidden detail objects into free time or grant caller-requested groups. See [the proposed filtering and cursor contract](authorization-queries.md).

## Confirmed consistency boundary

[ADR 0045](adr/0045-authorization-consistency-guarantees.md) selects support for coordinated and external host policies with explicit guarantees and no silent downgrade. Configuration must reject an adapter that cannot supply an operation's required guarantee. Defaults, per-operation requirements, freshness limits and concrete coordination remain pending in [the consistency design](authorization-consistency.md).

## First calendar command/interface proposal

The [adapter methods](authorization-adapter-contract.md) and [CRUD contract](calendar-crud-contract.md) make the next batch concrete. [ADR 0046](adr/0046-first-native-calendar-crud-contract.md) confirms dependency-blocked deletion and explicit named zone/nonempty native name on creation; it does not finalize signatures, physical deletion, label mapping or query/coordination protocols.

## Decisions still needed before implementation

- Exact action identifiers, adapter signatures and allow/deny/error/projection result types.
- Query constraint/batch evaluation mechanism, field projections, pagination/continuation semantics without initial totals and fail-closed resource limits.
- Transaction/snapshot integration and consistency/revocation rules when the host policy lives outside the calendar database.
- Calendar deletion behavior, item move semantics, task lifecycle and recurrence mutation rules; a permission does not define their behavior.

These are review gates, not missing runtime checks in an otherwise implemented policy. No domain authorization adapter exists yet. Add tests for the confirmed separations and mixed-request atomic denial, together with the guide's per-object, forged-reference and two-host scenarios, when implementing the services.

## Implemented calendar text-metadata increment

[ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md) adds `updateProtocolMetadata` independently from native `updateMetadata` presentation permission, plus a separate `protocolMetadata` disclosure group. The original name-only endpoint preserves new fields; full native presentation and full protocol-text replacements have explicit clear semantics. Hosts receive immutable current/proposed data and actual calendar identity. See [the metadata API and limits](calendar-metadata.md); broader operation families above remain proposals.

[ADR 0051](adr/0051-calendar-links-categories-images-refresh.md) adds independent supplemental-metadata editing/disclosure and immutable category-query context for scope planning and object reads. Matching requires supplemental disclosure even when output requests other groups; cursors bind the exact filter. See [the query contract](calendar-links-and-categories.md#category-queries).

Read-only native protocol UID/LAST-MODIFIED disclosure uses a separate `protocolIdentity` field group under [ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md); no identity/time write command or permission is added. Hosts receive actual immutable identity/time snapshots. Modification-time disclosure can reveal calendar activity; it does not authorize feeds or expose event details.

The first native event implementation maps list/read/create/update/status/delete to dedicated `CalendarPermission` values with immutable actual parent/event/proposed context. Full updates changing status and cancelled creation also require lifecycle permission. Event field groups are independent of calendar groups. See [ADR 0053](adr/0053-first-native-single-events.md) and [the implemented contract](native-single-events.md); no scheduling action is implied.

The [ADR 0055 timing increment](native-occurrence-timing.md) maps single/future timing replacement/clearing to `updateEvent`, and single cancellation/restoration to `changeEventStatus`. Exact action/original anchor and current/final proposed overrides distinguish scope without inferring authority from the parent or ordinary event read access.

The [ADR 0056 per-calendar free/busy service](calendar-free-busy.md) requires `readFreeBusy` and every required `projectEventBusy` decision. It supplies actual parent/event and immutable query bounds, does not reuse detail candidate plans, and cannot turn denied coverage into free time.

## Native availability definition authority

[ADR 0057](adr/0057-native-working-hours.md) adds independent `listAvailability`, `readAvailability`, `createAvailability`, `updateAvailability`, `deleteAvailability` and `projectAvailability` operations. Requests include actual calendar/definition UUIDs, frozen `currentAvailability`, full validated `proposedAvailability` and projection `freeBusyQuery`. Raw reads are all-or-nothing in this slice; receipts remain independently disclosable. Filtered management lists cannot supply coverage. Denied required projection yields unknown with no periods, while raw details can remain denied during successful projection. Expected revisions, final authorization and parent dependencies use the durable scope transaction across hosts. The private demo epoch is v9; host guarantees remain explicitly declared.

## Subject resolution and summary projection

[ADR 0058](adr/0058-subject-availability-search.md) adds `resolveAvailabilitySubject`, returning a complete authoritative in-scope contributor set plus private revision, and separate `readSubjectAvailability` / `projectCalendarAvailability` permissions. Raw calendar/free-busy/detail access is independent; event/rule projection remains required. Frozen `availabilitySearchQuery` / `availabilityTarget` accompany actual source context. Summary denial yields unknown without distinguishing target existence. Recheck successful target rights and resolver revision/set after calculation; host context changes fail. The supplied scope transaction coordinates module data, not external directories/ACLs automatically. External after-check races remain declared; snapshot IDs are not leases. The demo epoch is v10. See [host integration, limits and privacy](subject-availability-search.md).
