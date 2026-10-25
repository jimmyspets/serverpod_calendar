# Documentation

The maintainer has specified first-release capabilities in [requirements](requirements.md). The workspace/authentication scaffold and scoped native calendar CRUD/metadata increments have local implementation evidence. Broader domain designs remain proposals; pure wire adapters are limited to the explicitly documented profile and no external-client compatibility is claimed.

| Document | Purpose |
| --- | --- |
| [Discussion migration](discussion-migration.md) | Source evidence, current instructions and remaining gaps |
| [Timezone data](timezone-data.md) | Whole-second range limits, future-rule generation and database update/recalculation procedure |
| [Requirements](requirements.md) | First-release capabilities and acceptance evidence |
| [Calendar schema](calendar-schema.md) | Selected native name validation and identity/active-data layout; proposed fields and transactional invariants |
| [Calendar storage](calendar-storage.md) | Separate native/protocol names, UUID identity, minimal deletion markers and proposed physical layout |
| [Calendar CRUD contract](calendar-crud-contract.md) | Confirmed creation/deletion rules and proposed first native command/view batch |
| [Authorization interfaces](authorization-adapter-contract.md) | Concrete proposals for context resolution, batch decisions, queries and commit guards |
| [Authorization consistency](authorization-consistency.md) | Declared coordinated/external guarantees, revocation races and proposed transaction/retry handling |
| [Authorized queries](authorization-queries.md) | Separate detail/free-busy results, field groups, no-total pages and proposed filtering/cursors |
| [Authorization operations](authorization-operations.md) | Proposed action/target matrix, confirmed permission separations and composition examples |
| [Host authorization](host-authorization.md) | Host-supplied rules, module enforcement and trusted collection/object/change context |
| [Resource availability](adr/0006-resource-availability.md) | Proposed resource associations, free/busy semantics and privacy |
| [Alarm and notification boundaries](adr/0009-alarms-and-notification-boundaries.md) | Recommended calendar/notification/Flutter ownership and first-release alarm scope |
| [Architecture](architecture.md) | Module boundaries, proposed relationships and request flows |
| [ISO weeks and recurrence WKST](week-conventions.md) | Confirmed native ISO presentation, explicit RFC week starts and week-number examples |
| [Temporal core](temporal-core.md) | Implemented temporal foundations and bounded named-zone resolver, remaining temporal scope and validation |
| [Model catalog](models.md) | Proposed fields, relationships, storage/API boundaries, invariants and requirement coverage for all model areas |
| [Optional event feeds](http-event-feeds.md) | Approved optional module, publication policy/storage, secret URL lifecycle and HTTP profile |
| [Local development](development.md) | Pinned workspace, local setup/run/check commands and example boundaries |
| [Scaffold validation](scaffold-validation.md) | Commands actually run and limits of the initial milestone evidence |
| [Scaffolding plan](scaffolding-plan.md) | Confirmed walkthrough choices, installed-tool evidence and the first buildable milestone |
| [Compatibility](compatibility.md) | Full module/interchange profiles, subset feeds and independent scheduling evidence |
| [Standards scope](standards.md) | First-release RFCs, considered extensions and component/method boundaries |
| [RFC property coverage](rfc/README.md) | Latest feature-scope source: per-RFC properties, purpose, planned support and detailed constraints |
| [Automated tests and multiple instances](adr/0018-automated-example-and-multiple-instances.md) | Example host/app acceptance and concurrent Serverpod-instance requirements |
| [Roadmap](roadmap.md) | Delivery work packages, dependencies and acceptance checks |
| [ADRs](adr/README.md) | Confirmed scope selections, rationale and proposed implementation details |
| [Documentation review](documentation-review.md) | Removed obsolete artifacts, reconciled conflicts and remaining design work |

Use the RFC tables as the latest feature-scope source when older narratives conflict; explicit newer maintainer instructions take precedence. The migration note records source limitations and is not a transcript. Requirements use stable identifiers so issues and tests can trace back to them.

## Diagram convention

Use Mermaid for documentation diagrams, including architecture, relationships, and request flows. Store diagram source directly in Markdown fenced code blocks labeled `mermaid` so it can be reviewed alongside the text. Keep diagrams consistent with the accompanying documentation and clearly label proposed designs.

- [First native calendar CRUD implementation and host integration](calendar-crud-implementation.md)

- [Calendar native presentation and scoped protocol text metadata](calendar-metadata.md)

- [Calendar links, categories, images and refresh hints](calendar-links-and-categories.md)

See [native protocol UID and modification time](calendar-protocol-identity.md) for the read-only identity/time increment under ADR 0052.

See [first native non-recurring events](native-single-events.md) for typed timing, separate lifecycle permissions, event storage and example behavior under ADR 0053.

See [native recurrence and occurrence previews](native-event-recurrence.md) for the next event increment under ADR 0054.

See [native occurrence timing editing](native-occurrence-timing.md) for single/future timing changes and single cancellation/restoration under ADR 0055.

See [per-calendar free/busy](calendar-free-busy.md) for the first bounded booking/fallback calculation under ADR 0056, with broader search scope still pending.

See [native working hours](native-working-hours.md) for scoped rule CRUD, recurring openings and integrated per-calendar composition under ADR 0057.

See [person/resource availability and common-free search](subject-availability-search.md) for host-resolved contributors, independent summary authority, bounded modes and unknown coverage under ADR 0058.

See [opening-occurrence edits and scoped availability metadata](availability-occurrences-and-metadata.md) for original-identity timing/skip/restore controls, exact categories and legal metadata contexts under ADR 0059.

See [native availability organizer, text parameters and private extensions](availability-publication-metadata.md) for scoped native editing and independent host approval under ADR 0060; interchange remains pending.

See [native availability versions, timestamps and envelope duration](availability-protocol-lifecycle.md) for ADR 0061, legacy baselines and unchanged-save behavior.

See [bounded iCalendar syntax foundations](icalendar-syntax.md) for strict input, immutable syntax, separate escaping and serialization limits under ADR 0062.

See [typed temporal wire values](icalendar-temporal-values.md) and [the first standalone VEVENT/VTIMEZONE adapter](icalendar-event-adapter.md) for the ADR 0063/0065 pure adaptation increments; authorized import/export and feeds remain pending.

See [recurring VEVENT masters](icalendar-recurring-masters.md) for ADR 0066 rule/set mapping, source/output normalization and shared candidate-work limits.

See [PERIOD-valued event additions](icalendar-recurring-masters.md#period-valued-rdate-additions) for ADR 0067 timed exceptional spans and their native-storage boundary.

See [occurrence timing and cancellation components](icalendar-occurrence-components.md) for ADR 0068 grouped master/override source-to-core adaptation and its proposed snapshot/inheritance profile.

See [standalone availability wire adaptation](icalendar-availability-adapter.md) for ADR 0069 source/profile validation, positive openings and bounded core composition inputs.

## Availability wire metadata increment, 2026-10-22

[Availability wire publication metadata](icalendar-availability-metadata.md) under [ADR 0070](adr/0070-availability-wire-metadata.md) now validates and preserves organizer, legal URL/class, repeated category/comment/contact groups and bounded trusted private extensions. This supersedes earlier pending/rejection wording only for this pure adapter slice. CONTACT remains source-only; authenticated database import/export, current host approval and feeds remain pending. The next selected import increment is create-only, rejecting existing protocol UIDs; updates/reconciliation remain separate.

## Availability import storage decisions, 2026-10-22

[ADR 0071](adr/0071-create-only-availability-import.md) records confirmed create-only availability import choices: extend storage to preserve the supported wire profile first, detect active UID conflicts within the destination calendar, retain source protocol versions separately from database import time/API revisions, require separate import authority plus per-definition create authority, and keep native opening UUIDs distinct from text protocol UIDs. [The storage/import contract](availability-import.md) proposes models, migration, authorization, atomicity and validation gates. These extensions and the import endpoint remain unimplemented; physical/API mechanics still require review.

## Availability storage prerequisite increment, 2026-10-22

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the storage guide](availability-storage.md) implement source-preserving availability prerequisites: text protocol UIDs with native UUID separation, grouped categories/read-only CONTACT, availability PERIODs, source component versions and data-preserving upgrades. Native edits/calculation enforce the expanded state; pure conversion supplies no host authority or database import. Authenticated create-only import remains the next batch under ADR 0071.


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


## Standalone VTODO master wire increment, 2026-10-23

[ADR 0088](adr/0088-vtodo-wire-master-implementation.md) and [the pure task adapter](icalendar-task-adapter.md) add bounded undated/DATE/UTC/named-zone VTODO masters with recurrence, basic annotated text/priority and independently optional source progress/checkpoints. Preserve source values rather than imposing native progress defaults; validate exact full-horizon zones and reject unsupported occurrence components, PERIODs, alarms, scheduling and unprofiled metadata. This is a pure parser/serializer, without native database import/export or assignment/history inference. Those services and richer task wire profiles remain pending.

## VTODO progress occurrence wire increment, 2026-10-23

[ADR 0090](adr/0090-vtodo-occurrence-component-implementation.md) implements the confirmed [ADR 0089](adr/0089-vtodo-occurrence-component-contract.md) same-file-master and progress-only profile. The [pure task adapter](icalendar-task-adapter.md) links exact retained original identities to projected milestones and inherited text/priority while preserving raw source omissions, independent optional progress/checkpoints and component order. Reject detached, duplicate, excluded/absent/profile-mismatched originals, timing/content differences and RANGE. Aggregate membership work is bounded per master and shared across the file. This supersedes older blanket occurrence-wire-pending notes only for this slice; richer task metadata, native exceptions, authenticated database import/export, alarms and scheduling remain separate. No native history is invented and no external-client interoperability is claimed.

## VTODO text/link wire increment, 2026-10-23

[ADR 0091](adr/0091-vtodo-text-and-link-metadata.md) and [the task adapter](icalendar-task-adapter.md#text-and-link-metadata) now add source-preserving CLASS, HTTP/HTTPS URL and grouped CATEGORIES/COMMENT/CONTACT with legal annotations. Linked progress occurrences inherit omissions and reject explicit metadata differences; retain source grouping, duplicates and presence. Limits use the existing file-wide task budget and bounded per-component counts. No URI retrieval, host authority, native CONTACT editor or database import/export follows. Organizer/attendee, relationships, attachments and alarms remain separate profiles. This supersedes older metadata-pending notes only for this slice; native metadata editors/search and client interoperability remain unimplemented.

## VTODO source participant wire increment, 2026-10-23

[ADR 0092](adr/0092-vtodo-source-participants.md) and [the task adapter](icalendar-task-adapter.md#inert-source-participants) now preserve organizer/attendee source addresses and bounded standard parameters, ordered address lists, exact spelling and source presence. Explicitly named effective attendee defaults/fallbacks remain distinct from raw values and task progress. Occurrence omissions inherit; explicit differing participant state rejects. Source claims never map themselves to native assignees/host identities, prove membership/authority, fetch directories or send messages. This supersedes earlier participant-wire-pending notes only for this inert profile. Native participant editing, authenticated task interchange, relationships/attachments/alarms and all VTODO scheduling remain separate.

## VTODO source reference wire increment, 2026-10-23

[ADR 0093](adr/0093-vtodo-source-references.md) and [the task adapter](icalendar-task-adapter.md#unresolved-relationships-and-inert-attachments) now preserve basic unresolved RELATED-TO UID references and URI-only ATTACH/FMTTYPE metadata. Keep missing/self/cyclic references as data, source order/duplicates/presence and matching occurrence inheritance. No native graph edges, identity resolution, file access, fetching or workflow follows. Binary/data payloads and extended relationship semantics reject. This supersedes older basic relationship/attachment-wire-pending notes only for this pure task slice; native editors/graph rules, extended metadata, alarms and authenticated task import/export remain separate.

## VTODO DISPLAY alarm wire increment, 2026-10-23

[ADR 0094](adr/0094-vtodo-display-alarm-source-profile.md) and [the task adapter](icalendar-task-adapter.md#unarmed-display-alarm-definitions) now preserve unarmed DISPLAY source alarms, relative task start/due or absolute UTC triggers, bounded paired repeats and optional source UID/ACKNOWLEDGED. Validate typed anchor presence and matching occurrence inheritance, with shared file/text budgets and exact portable duration bounds. No native recipient/consent/action/history or delivery is inferred; no firing instants are generated. Snooze relationships, event alarms, activation authorization, native storage/runtime and notification integration remain separate. This supersedes older blanket task-VALARM rejection only for this source slice; no runtime/client interoperability follows.

## VTODO sibling snooze source increment, 2026-10-23

[ADR 0095](adr/0095-vtodo-snooze-source-profile.md) and [the task adapter](icalendar-task-adapter.md#bounded-source-snooze-links) extend unarmed DISPLAY definitions with exact same-VTODO sibling SNOOZE links: own UID, absolute UTC trigger, acknowledged original and no repeats/chains/detached borrowing. Preserve source state/order and occurrence inheritance without native actions, consent, delivery or history. This supersedes older blanket snooze-wire rejection only for this structural source slice; event/native snooze, activation/privacy/runtime and notification integration remain pending.

## Source-preserving native task progress prerequisite, 2026-10-23

[ADR 0096](adr/0096-source-preserving-native-task-progress.md) and [the progress guide](task-source-progress.md) now preserve independently optional status/percentage/completion in native JSON/API values. Native commands explicitly produce agreed states; read/content edits retain source combinations. Recurring originals without a row use the complete master progress; sparse rows replace it without merging. No imported history is invented. Generated clients and Flutter handle absence explicitly. Full task source metadata/version/baseline storage and authenticated import/export remain separate; this supersedes older mandatory-progress/neutral-master read claims only for this prerequisite.

## Task import contract and source-storage proposal

[ADR 0097](adr/0097-create-only-task-import-contract.md) records create-only import, independent gates/source versions/private baseline and the confirmed unknown prior-progress checkpoint. [ADR 0098](adr/0098-task-source-storage-model.md) and [the storage guide](task-source-storage.md) record the implemented typed source-retention prerequisite. [The import contract](task-import.md) remains distinct from an implemented endpoint; task import/export, native alarm activation and scheduling remain pending.

## Source-preserving task storage increment, 2026-10-23

[The storage guide](task-source-storage.md) records the ADR 0098 current source metadata/component-version and private-baseline prerequisite. Source values remain read-only, inert and unarmed; assignment-only edits keep protocol versions unchanged and occurrence progress versions its own component. Native projections must agree with source state, and incompatible edits reject. This supersedes the immediately preceding storage-pending/proposal notes only for the scoped storage increment; task import/export, native metadata editors, alarm runtime and external-client evidence remain separate.

## Create-only task import increment, 2026-10-23

[ADR 0099](adr/0099-authenticated-create-only-task-import.md) and [the import guide](task-import.md#implemented-create-only-operation) add authenticated atomic task import, independent import/create/progress gates, complete immutable source proposals, private baselines and final-approved minimal receipts. Preserve independent source progress/versions and unknown prior history; source participants/alarms remain inert. Task export/replacement, metadata editors and alarm activation remain separate.

## Current task export increment, 2026-10-23

[ADR 0100](adr/0100-authenticated-current-task-export.md) and [the task export guide](task-export.md) add read-only current-state standalone VTODO output with explicit revision-bound complete-series selection. Export requires independent export, full ordinary task disclosure and rich-source-read authority, checked again after serialization. Preserve supported source metadata/progress/versions; exclude private baselines, native assignments/history and alarm activation. Native exceptions, source replacement/adoption, feeds/runtime and external-client evidence remain separate. This supersedes older task-export-pending wording only for this bounded profile.

## Single task occurrence timing, 2026-10-23

[ADR 0101](adr/0101-single-task-occurrence-timing.md) and [the timing guide](task-occurrence-timing.md) extend the scoped native/wire task profile with single complete timing replacements, effective-start previews and progress/history preservation. Explicit DTSTART replaces complete occurrence timing; absent DUE/DURATION clears the deadline. Capture current progress for a new own component without adding history, and reject incompatible retained alarm anchors. Task source baselines advance to v2; older imports require explicit reimport, without automatic repair or development reset. This supersedes earlier progress-only/timing-pending wording for this slice only. Future timing/content, source reconciliation, feeds/runtime and client evidence remain separate.

## Task future timing, 2026-10-23

[ADR 0102](adr/0102-task-future-timing.md) and [the future timing guide](task-future-timing.md) extend single timing with absolute civil shifts, replacement deadline forms and independent single edits. VTODO RANGE=THISANDFUTURE propagates timing only; independently optional source progress belongs only to the anchor. Preserve every original/progress/history record, reject orphaning edits and conflicting timing scopes, and keep source alarms unarmed. Nullable storage and canonical true-or-absent source flags preserve valid non-range v2 baselines. This supersedes earlier future-timing-pending/RANGE-rejection notes for this bounded profile; content/future cancellation, reconciliation, feeds/runtime and client evidence remain separate.

## Selected task occurrence content, 2026-10-23

[ADR 0103](adr/0103-single-task-content-overrides.md) and [the content guide](task-occurrence-content.md) add selected-field set/clear/inherit for summary, description, location and priority. Omitted fields follow the series; explicit source values stay pinned. RANGE content/progress apply only to the anchor while timing propagates. Opt-in preview groups independently protect effective values and override presence. Preserve progress/history and own versions; source baselines advance to v3 for the changed repetition policy, with explicit recreation/reimport of older imports and no development reset. This supersedes earlier blanket task-content rejection/pending and v2 compatibility notes for this later scoped increment. Future content, source reconciliation, feeds/runtime and client evidence remain separate.

## Unarmed event source alarms, 2026-10-24

[ADR 0110](adr/0110-unarmed-event-source-alarms.md) now extends the supported source profile with [unarmed VEVENT DISPLAY alarms and bounded sibling snoozes](event-source-alarms.md). Nullable immutable server-only alarm/duration DTOs use existing metadata JSON, without table changes or a migration. Existing event-source-v2 baselines remain compatible. Separate `readEventSource` authority protects export/replacement and final/no-op checks; ordinary projections hide this data. Native edits preserve definitions and reject incompatible explicit-END anchor changes atomically. Source UID/ACKNOWLEDGED/SNOOZE are unverified data, never recipients, authority or native actions. This supersedes earlier event-alarm rejection/pending wording only for this source-preservation slice. Native personal definitions/editors, adoption, planning, delivery, feeds and client interoperability remain separate requirements.


## Native personal alarm definitions, 2026-10-24

[ADR 0111](adr/0111-native-personal-alarm-definitions.md) adds [private native event/task timing definitions and example editors](native-personal-alarms.md). The host resolves the current recipient; requests cannot select another. Independent alarm permissions, actual parent/current/proposed context, final recipient checks and revisions protect one bounded private table. Shared edits retain incompatible definitions as needing attention; parent deletion scrubs all recipients atomically. Private writes leave item/protocol versions, source baselines and public scope generation unchanged. All definitions remain unarmed; imported-alarm adoption, actions, planning and delivery remain required separate work. Concrete mechanics remain draft review material.

- [Native personal alarm actions and private activity pages](native-alarm-actions.md)


## Reusable live notification increment, 2026-10-25

[ADR 0114](adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.


## Timing-only source alarm adoption, 2026-10-25

[ADR 0115](adr/0115-timing-only-source-alarm-adoption.md) implements [explicit master-timing copying](imported-alarm-adoption.md) into new unarmed personal definitions, using current authorized item text. It reuses existing storage without a migration and enforces source-read/adopt/create rights, actual parent revisions and trusted recipients. This supersedes earlier adoption-pending wording only for this bounded flow. Source text/UID/acknowledgement/snooze state stays inert; broader profiles, private exports and release gates remain separate. Full local batch validation passed; see the validation record for exact evidence.
