# First native calendar CRUD contract

Status: **three maintainer-confirmed product rules; API/storage details proposed, not implemented**. See [ADR 0046](adr/0046-first-native-calendar-crud-contract.md) and the [proposed authorization interfaces](authorization-adapter-contract.md).

## Confirmed product rules

The maintainer selected:

- Reject calendar deletion while events, tasks, availability definitions, feed selections or other active dependencies remain. Do not cascade-delete them or substitute archive behavior.
- Native calendar creation requires an **explicit named availability timezone**, validated and stored by the server. The example may prefill it, but the server does not infer it from a device/server locale or omitted host default.
- Native calendar creation requires a **nonempty display name**. This is a native command requirement, not a new requirement on legal iCalendar files or their optional NAME metadata.

The existing per-calendar no-applicable-rule fallback defaults to free under ADR 0012, only for completely known unbooked time without an applicable definition. Unavailable remains the selected alternative. Missing/denied/unknown coverage is never free. Separate metadata/settings/association permissions and expected revisions remain required.

## Proposed command/view surface

Names and ID/patch representations below are proposals, not generation-ready Serverpod models:

| Command/query | Inputs and authorization | Proposed outcome |
| --- | --- | --- |
| `CalendarCreate` | Required nonempty native display name and exact named availability zone; optional supported description/color and explicit fallback. Resolve trusted scope; authorize create plus requested capability/reference intents | Stable server-controlled identity, initial revision and only the authorized result/receipt. No client-defined owner role or implicit association |
| `CalendarGet` | Calendar reference and requested supported disclosure groups; resolve actual scope/record and authorize metadata/settings projection | Authorized view; inaccessible/nonexistent errors must not disclose hidden existence |
| `CalendarList` | Bounded page size, protected cursor, supported filters/order/requested groups; host scope/constraints and per-object decisions | Authorized views and opaque continuation, without totals or mixed busy placeholders |
| `CalendarUpdateMetadata` | Calendar reference, expected revision and typed native name/description/color changes; metadata permission and relevant proposed-state context | Atomic metadata change/revision and authorized receipt/view |
| `CalendarUpdateAvailabilitySettings` | Calendar reference, expected revision and explicit zone/fallback changes; distinct settings permission | Atomic setting/revision change and affected calculation/publication/work invalidation as dependent features exist |
| `CalendarSubjectChange` | Calendar reference/revision, typed add/remove/change intent and validated opaque subject/contribution references; distinct association permission | Atomic link/revision change with host validation, no implicit identity directory or access grant |
| `CalendarDelete` | Calendar reference, expected revision, delete permission and transactionally validated absence of active dependencies | Delete outcome/receipt, or safe dependency conflict with no partial changes |

Keep command fields separate: a metadata request cannot smuggle settings/association changes through a nested generic serializer. If supporting a combined command later, require all affected gates before one atomic commit. Omitted patch fields remain unchanged; explicit clearing is distinct and allowed only for nullable writable fields. Native rename should preserve a usable nonempty label; precise text limits, whitespace/normalization and error codes need final review.

Under [ADR 0047](adr/0047-calendar-names-identifiers-and-deletion-storage.md), native `displayName` is separate from preserved protocol NAME metadata and feed-owned names; edits/imports do not silently synchronize those roles. Native API calendar IDs are server-generated UUIDs without a version mandate. The [storage contract](calendar-storage.md) records these choices; exact field/table normalization still needs pinned generation review. Importing valid content into an existing calendar must not reject it because an ICS NAME is absent, invent protocol properties, or silently overwrite the native label. Creating a calendar from imported metadata, if later offered, must obtain an explicitly validated native name/zone through its own command contract.

Validate timezone keys using the selected exact, case-sensitive named-zone/alias profile; preserve the supplied accepted key. Reject unknown names/abbreviations/case guesses. Unknown-offset calculation periods still fail explicitly; accepting a known key does not promise known offsets for every historical period. Changing a calendar's availability zone affects all-day occupancy/derived results, not the canonical DATE fields or an event's own named-zone identity. Detailed data-recalculation transactions remain a prerequisite when those dependencies are implemented.

## Dependency-safe deletion proposal

The dependency check and delete must form one effective database consistency boundary across instances. A preliminary count/read followed by an unrelated delete is insufficient. Concurrent creation/linking must either establish its parent while the calendar still exists or lose the race and reject; never create an orphan. Use appropriate schema constraints and an explicitly reviewed locking/serialization protocol.

Dependencies include contained events/tasks/rules and their active children, feed selections, active scheduling/worker/alarm/publication references and required host-defined active relationships. Availability-contributing subject links must not silently disappear and make a person/resource look free. An empty calendar with active association references is still referenced; remove/change those links explicitly through authorized operations before deleting it. No archive, cleanup workflow or automatic detachment is selected.

The delete permission does not grant discovery of hidden dependencies. Return a safe conflict; expose dependency summaries only when independently authorized. ADR 0047 additionally selects a minimal UUID/scope/revision/deletion-time marker with no calendar label/content and no archive/restore behavior. Deleted calendars are hidden from ordinary APIs. Physical layout, independent audit/history/receipt retention and privacy-safe retry mapping remain schema decisions; rejecting active dependencies is unchanged. Do not block deletion solely because an internal audit reference is designed to survive it, or erase necessary replay/reconciliation history to make deletion pass.

## First implementation batch boundary

Implement native calendars and association management, reusable host-adapter enforcement, real module migrations/generated clients and a Flutter calendar-list/create/edit/delete journey. Keep events, raw availability rules, feeds, scheduling and alarms in their following feature batches. The calendar module must remain installable without the optional feed module.

Only existing/implemented dependencies are tested as real module data in this first batch. Define how later modules participate in the delete transaction without a reverse calendar-to-feed package dependency; do not claim a fake dependency test proves future feed/worker semantics. Once each dependent module exists, extend migration and cross-instance deletion races with its real tables/services.

Proposed acceptance:

- [ ] Native creation rejects empty names, missing/invalid zones, forged scope and unauthorized proposed fields; UI prefill remains explicit validated input.
- [ ] Metadata, settings and associations use independent gates; mixed/forged changes fail without partial commits. Host policies replace the example rules without changing module code.
- [ ] Stale updates/deletes reject; all returned fields and pages obey the selected group/cursor/no-total contract.
- [ ] Dependency conflicts do not cascade, detach links or disclose hidden objects. Two hosts race a parent delete against dependent creation/linking without orphaned records.
- [ ] Real generated clients, fresh migrations and Flutter calendar journeys pass; the module works without the feed module. Authorization consistency tests prove only their configured guarantees.

Before implementation, settle adapter/result types, label limits/normalization, physical UUID/marker schema/indexes, patch/receipt/error shapes, concrete query/cursor mechanics and coordinated policy/delete protocols. No calendar-domain runtime or schema is implemented by this proposal.
