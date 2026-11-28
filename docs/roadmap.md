# Delivery roadmap

Status reconciled **2026-10-23**, through durable recurring-task previews, independent progress and retained history under ADR 0086, following native task CRUD and authenticated VEVENT export/import. The pure VTODO master adapter now follows under ADR 0088; task wire occurrence/metadata and authenticated import/export remain next, along with timing/content exceptions. Source replacement remains separate. The bounded temporal core and scoped native calendar/event services have local validation evidence; the full first release remains incomplete. The [RFC tables](rfc/README.md) are the latest feature-scope source. [Requirements](requirements.md) define stable FR/NFR acceptance targets; [ADRs](adr/README.md) distinguish confirmed scope from proposed implementation details.

This roadmap tracks the implementation represented by the current branch, including stacked draft PRs; an implemented checkbox does not mean the change is merged into main, released, or that every ADR mechanic is accepted. Check existing GitHub work before filing issues, and link each implementation issue to the relevant requirements and roadmap section.

Checked items describe only the stated implemented slice or explicitly selected product boundary. Unchecked items remain delivery/review gates. A broader requirement stays incomplete when only part of it has evidence. [Scaffold validation](scaffold-validation.md) records actual commands/results; [temporal validation](temporal-core.md) retains historical increments whose older precision/range choices are superseded by ADR 0041.

## Current delivery position

| Area | Implemented and locally validated | Remaining for the first release |
| --- | --- | --- |
| Workspace and example | Pinned SDKs, module/client packages, JWT sign-in, local setup/generation/check scripts | CI and broader feature integration |
| Temporal core | Selected bounded Gregorian/ISO, timezone, duration, recurrence, exception/range timing and task-timing calculations | Durable upgrade/recalculation integration; pure full-horizon wire-zone validation is implemented under ADR 0065 |
| Calendars and authorization | CRUD/associations, native/protocol metadata separation, UID/time, host policy, disclosure, revisions and cursors | Retention/cleanup, production coordinated-policy evidence and enforcement for remaining services |
| Events | DATE/UTC/zoned CRUD, separate lifecycle rights, recurrence storage, bounded previews and single/future timing edits/cancellation, stored PERIODs/annotations and independent component versions | Per-occurrence content, future cancellation, richer metadata and calendar-wide occurrence queries |
| Tasks | Durable CRUD/assignments, recurrence/previews, independent occurrence progress/history, orphan protection and Flutter example | Timing/content exceptions, richer filtered queries, VTODO interchange and alarms |
| Availability | Per-calendar complete/unknown free/busy; scoped rule CRUD, recurring openings, priority/range/fallback composition, explicit opening zones, scoped subject/common-free search, opening edits/metadata, duration envelopes and source-preserving UID/group/CONTACT/PERIOD/component-version storage | Indexed larger calendars and cross-scope/group-expansion coordination; scoped create/export/replacement APIs exist under ADRs 0073-0076 |
| iCalendar and HTTP feeds | Bounded strict syntax/value codecs; scoped VEVENT recurrence/PERIOD/timing components and VTIMEZONE validation; availability timing/composition/publication metadata adapters and scoped authenticated import/export; optional feed-module boundary selected | Remaining selected wire properties/components, remaining component imports/exports (create-only VEVENT import now exists), feed module and external-client evidence |
| Scheduling and alarms | Selected scope; notification package scaffold | Scheduling/mail state and outbox; alarm workers/actions and connected Flutter delivery |
| Validation and release | Local unit/browser/database/upgrade checks, two real hosts and Flutter journeys for implemented features | CI, remaining protocol/worker/recovery journeys, interoperability and publication readiness |

The timing-only single/future batch is implemented under [ADR 0055](adr/0055-native-occurrence-timing-edits.md). The first per-calendar booking/fallback free/busy increment is implemented under [ADR 0056](adr/0056-first-calendar-free-busy.md), including the accepted tentative-blocking classification. Scoped RFC 7953 working-hours rules and host-resolved person/resource/common-slot search are implemented under ADRs 0057–0058; source-preserving wire adaptation follows under ADRs 0069–0070. Scoped availability create/export/replacement APIs now exist; scoped event import/export now exist; remaining profiles and concrete mechanics still need implementation/review. Review and merge the draft PR stack separately; passing local checks does not approve unresolved design mechanics.

## Work packages and dependencies

| Work package | Requirements / decisions | Prerequisites |
| --- | --- | --- |
| [Design contracts](#design-contracts) | Selected RFC profiles and detailed ADR review | Current scope is available; earlier-source recovery is optional |
| [Scaffolding](#scaffolding) | FR-01; NFR-03/06; ADR 0001 | Package/boundary decisions |
| [Temporal core](#temporal-core) | FR-03/04/05/06; ADRs 0002/0013/0017 | Scaffolding and temporal contracts |
| [Persistence and authorization](#persistence-and-authorization) | FR-02/03/04/07/08/09; ADRs 0003/0005 | Scaffolding and core types |
| [iCalendar and metadata](#icalendar-and-metadata) | FR-06/07/08/24; ADRs 0010/0014 | Core, persistence and legal profile constraints |
| [Tasks](#tasks) | FR-25/27; ADRs 0008/0011/0017 | Core, persistence and task lifecycle/interchange contracts |
| [Feeds](#feeds) | FR-10/11/12/13/14; NFR-04/07/08; ADRs 0004/0016 | Persistence and iCalendar output |
| [Availability](#availability) | FR-15/16/17/18/19/26/27; NFR-09; ADRs 0006/0008/0012 | Core, persistence and bounded interchange |
| [Scheduling](#scheduling) | FR-20/21/22/23; NFR-10/11; ADRs 0007/0011/0015 | Core, persistence, interchange and availability |
| [Alarms and notifications](#alarms-and-push) | FR-28/29/30/31; NFR-12/13; ADRs 0009/0020 | Core, persistence, task lifecycle and notification-port contract |
| [Automated deployment tests](#automated-deployment-tests) | NFR-14/15; ADR 0018 | Scaffolded real host/app; extend tests as each feature is delivered |
| [Release evidence](#release-evidence) | All FR/NFR evidence; NFR-05 | Required work packages and automated deployment tests complete |

Independent packages can progress in parallel after their contracts are defined. Finalize relevant field, lifecycle and authorization contracts before dependent schema/API implementation. Feature selection does not require every legal RFC combination. Keep architecture PRs draft while material design questions remain.

## Design contracts

Confirmed product choices and implemented interfaces are distinct from acceptance of every physical/API detail. [ADRs 0043–0054](adr/README.md) and their implementation guides refine the earlier [model catalog](models.md); that catalog is not a blanket implementation claim.

- [x] Record the host-owned identity/policy boundary, actual collection/object/parent context, separate permissions, predefined disclosure groups and no-total detail pages under ADRs 0043/0044. Calendar/event enforcement is implemented; see [host authorization](host-authorization.md), [operation catalog](authorization-operations.md) and the service checklists below.
- [x] Record declared coordinated/external authorization guarantees without silent downgrade under [ADR 0045](adr/0045-authorization-consistency-guarantees.md). Installation capability checks, bounded callbacks and final checks exist; production host coordination and revocation ordering remain open below.
- [x] Implement the selected native calendar creation/name/storage/deletion slice under [ADRs 0046–0049](adr/0049-first-calendar-crud-implementation.md): explicit named zone, nonempty trimmed single-line name up to 256 Unicode code points, duplicate labels, server UUIDs, separate identity/active rows and dependency-blocked content deletion. [Storage](calendar-storage.md), [schema](calendar-schema.md) and [the implementation guide](calendar-crud-implementation.md) distinguish the selected boundary from reviewable mechanics.
- [x] Record native/protocol/feed name separation and implement distinct native/protocol calendar metadata, protocol UID/time and scoped event/recurrence contracts under ADRs 0050–0054. This does not implement feed metadata or ICS interchange.
- [x] Select a separate optional HTTP feed module under [ADR 0042](adr/0042-optional-http-feed-module.md); implementation is tracked under [feeds](#feeds).
- [ ] Review concrete API/storage/limit mechanics in the [adapter interfaces](authorization-adapter-contract.md), [CRUD contract](calendar-crud-contract.md), [query design](authorization-queries.md) and [consistency guide](authorization-consistency.md) against the implemented slices. Add production coordinated-policy and two-host revocation/commit-order evidence without implying that a final external check closes its residual race.
- [ ] Decide deletion-marker retention/purge, global cursor/scope cleanup and publication/dependency removal for remaining item families. Existing minimal markers do not select indefinite retention or archive/restore behavior.
- [x] Implement the confirmed timing-only single/future event actions, single cancellation/restoration and preserved-override/orphan-rejection policy under ADR 0055.
- [ ] Finalize per-occurrence content, future cancellation and task occurrence/completion/history contracts before their storage/endpoints. Timing-only support does not settle those lifecycle/permission semantics.
- [ ] Review remaining model fields, ownership, component cardinalities, physical constraints, typed changes, identity mappings, limits and diagnostics against [ADR 0019](adr/0019-model-contracts.md) and the selected RFC tables before dependent schema/parser implementation.
- [ ] Specify imported known-zone VTIMEZONE matching, transactional zone upgrades, publication/scheduling trust, resource blocking/exclusivity/capacity and external client variants. Existing native alias/DST/duration rules are already implemented; do not reopen them as unselected scope.
- [ ] Finalize structured-component nesting/shared fields, DERIVED update authority, graph/reference scope, cycles/missing/filtered targets and privacy-aware UID mapping. Selected relationships remain metadata; they do not execute workflows.
- [ ] Define private alarm UID/acknowledgement/snooze wire/lifecycle constraints and notification-port cancellation/retry contracts. Keep requirements, compatibility and implementation acceptance criteria aligned. Recover earlier discussion only as optional additional evidence.

## Scaffolding

The initial workspace/authentication milestone under [ADR 0021](adr/0021-initial-workspace-scaffold.md) is implemented and locally validated. See [the scaffold plan](scaffolding-plan.md), [development guide](development.md) and [validation record](scaffold-validation.md). Notification and iCalendar scaffolds are not evidence of their complete services.

- [x] Pin and validate Serverpod 4.0.4, Flutter 3.47.7 and Dart 3.13.5 with workspace dependencies, the module template and repeatable generated-code workflow. Other SDK versions need separate evidence.
- [x] Scaffold independent core/iCalendar packages, calendar and notification Serverpod server/client pairs, and the authenticated host/Flutter example. Keep Serverpod/Flutter/provider dependencies out of the pure calendar core.
- [x] Implement synthetic seeded host authentication using Serverpod JWT, generated-client module connection checks and host-resolved private demo scopes. Calendar stores opaque associations; the host owns users/membership.
- [x] Supply local setup, synthetic database seed/reset, generation, formatting/analysis, database/upgrade and real generated-client/Flutter checks. Namespaced calendar/event tables and fresh/upgrade migrations are exercised.
- [x] Run two independent local host processes sharing test storage with distinct ports and real cross-instance operations. This foundation now exercises calendar/event features as well as JWT.
- [ ] Add CI orchestration for the existing local checks and single-/two-host topologies. CI remains a release requirement, not completed by local execution.
- [ ] Evaluate and pin the remaining ICS/MIME/parser dependencies, licenses and host mail/notification adapters before implementing those services. Native recurrence and timezone calculation choices already have scoped validation; the optional HTTP feed package still needs scaffolding.

## Temporal core

The **bounded pure-core calculation milestone is complete** under [ADR 0040](adr/0040-bounded-temporal-core-completion.md), with the current precision/range/data profile defined by [ADR 0041](adr/0041-whole-second-1970-2100-profile.md). [Temporal validation](temporal-core.md) and [timezone data/update guidance](timezone-data.md) contain evidence and historical increments. This is calculation support, not complete service or wire support.

- [x] Validate Gregorian date-only and civil time fields with whole seconds, explicit leap-second/nonzero-fraction rejection and ordinary dates **1970-01-01 inclusive to 2100-01-01 exclusive**. Only approved midnight exclusive endpoints may reach 2100; UTC padding does not extend ordinary storage.
- [x] Implement calendar-day arithmetic, weekday and ISO week-year/week projection. Native labels/presentation use Monday-first ISO weeks; recurrence honors explicit WKST and its rule-specific week numbers. See [week conventions](week-conventions.md) and ADRs 0023/0026/0032/0034.
- [x] Generate pinned IANA coverage for the supported horizon, including calculated future transitions and exclusive-end padding. Preserve exact names/aliases, explicit gap/fold policies, generated-gap skipping and unknown-offset rejection; the former 2037 restriction is superseded, not a current limit. Document reproducible updates and independent reference validation.
- [x] Preserve DATE, UTC and named-zone civil meanings, resolved instants and version evidence; provide no floating-time factory. Support finite zone snapshots and equal-horizon offset-function comparison without claiming to parse VTIMEZONE.
- [x] Implement half-open UTC windows, exact arithmetic and unit-preserving signed durations. Apply named-zone weeks/days in civil fields before elapsed clock units, retaining P1D versus PT24H semantics across DST.
- [x] Preserve DATE/UTC/zoned event end/duration/default forms, one-day DATE defaults, omitted timed points, overlap/lookback, explicit DATE-to-zone occupancy and endpoint/coverage failures.
- [x] Implement the selected bounded DATE/timed recurrence profile, canonical filters, start alignment, COUNT/UNTIL, all WKST values, RDATE/EXDATE and core timed PERIOD additions. Earlier inclusions remain additions and exclusions do not replenish COUNT. SECONDLY/BYSECOND remain outside the native profile.
- [x] Implement pure-core original occurrence identities, single cancellation/replacement and THISANDFUTURE timing projections with moved-in/out/changed-length overlap and shared validation/query budgets. These are not durable occurrence edit APIs.
- [x] Implement pure-core DATE/timed task milestones and recurring projections, including undated/start-only/due-only forms and legal due/duration combinations. Task completion, assignment and history remain service work.
- [x] Test supported boundaries, ISO/WKST, Stockholm/Lord Howe/Apia gaps/folds/skipped dates, nominal/exact durations, recurrence/exception/range projections and atomic limit failures on VM and Chrome.
- [x] Validate/expand the bounded explicit/yearly known-zone VTIMEZONE profile before full-horizon comparison under ADR 0065; reject custom/mismatched/floating wire forms atomically. Calculation evidence alone does not authorize database import or unprofiled observance forms.
- [ ] Module follow-up: implement transactional zone-data upgrade/recalculation for durable projections, bookings and future alarm work. No existing version label alone supplies that migration.
- [x] Persist single/future occurrence timing and single cancellation/restoration with stable event identity/revisions under ADR 0055.
- [ ] Module follow-up: implement per-occurrence content, task lifecycle and dependent alarm invalidation. Whole-series definitions/previews and native timing edits exist; service PERIOD additions and future cancellation remain separate gates.
- [ ] Query follow-up: add calendar-wide occurrence queries and complete/unknown availability results. Existing UUID detail pagination and per-event previews are scoped services; no limit failure may be reported free.

## Persistence and authorization

[Calendar implementation](calendar-crud-implementation.md), [native events](native-single-events.md) and [recurrence/previews](native-event-recurrence.md) now provide the slices below. Requirements FR-02/03/04/07/08/09 remain broader than these completed items.

- [x] Persist namespaced calendar UUID identities/active data, settings and opaque subject links; enforce host-owned identity/membership and separate management associations from availability contributors.
- [x] Implement calendar CRUD/association permissions, trusted actual object/proposal context, predefined group disclosure, immutable adapter snapshots, expected revisions, final authorization checks and declared no-downgrade capability checks. The shipped demo supplies fresh-check policy, not production coordinated authorization.
- [x] Implement native/protocol metadata permissions and isolated values, exact authorized category filtering, independently disclosed stable protocol UID and automatic whole-second modification projection using shared database time.
- [x] Implement DATE/UTC/named-zone event CRUD, optional summary, separate lifecycle authority, cancellation/reopening versus content deletion and actual parent/event policy context. Active events block parent deletion; child edits do not advance parent metadata time.
- [x] Persist optional recurrence rules/inclusion/exclusion dates in existing event JSON. Preserve and validate explicit dates during pattern edits unless deliberately replaced; preview saved revisions with separate preview/read authority and timing disclosure under ADR 0054.
- [x] Provide bounded authorized UUID detail pages with no totals and opaque continuations bound to actor/scope/policy/data/query. Per-event overlap previews are complete-or-failure; neither interface establishes free time.
- [x] Use durable scope-row transaction coordination across independent hosts. Test stale writes, isolation/forged references, immutable callbacks, denied/failing-policy rollback, cursor invalidation, calendar delete/attach and parent delete/event-create races, and competing event/pattern edits. Process-local locks/sticky routing are not correctness mechanisms.
- [x] Delete active calendar/event payloads while retaining only their approved minimal internal markers. Test dependency-blocked deletion, stable identities through edits and populated upgrades, including prior non-recurring JSON.
- [x] Persist single/future timing and independent single cancellation state outside master content. Reject orphaning/incompatible master edits, preserve original identity, expose actual action/proposal context and test two-host stale writes/rollback under ADR 0055.
- [ ] Implement per-occurrence content, future cancellation, richer event metadata and calendar-wide occurrence queries with corresponding authorization/revision/concurrency evidence.
- [ ] Extend durable CRUD/query authorization and active-parent dependency coordination to tasks, availability rules, imports/exports, feeds, scheduling and alarm/worker families. Existing endpoints do not establish those services' enforcement.
- [ ] Validate real host-coordinated revocation/commit ordering, external-policy residual races/retries and instance-loss recovery for dependent workflows. Database scope serialization coordinates module data, not arbitrary host-policy revokers.
- [ ] Implement atomic imports and source/scheduling/publication identity mapping. Masters and valid overrides sharing a UID are not duplicates; ordinary imports must not silently become scheduling updates.
- [ ] Complete marker retention/purge, global cursor/scope cleanup and publication/dependency deletion effects. Scope-local expired-cursor cleanup already exists; no global cleanup worker or archive/restore feature is implied.

## iCalendar and metadata

Native metadata editing is partial evidence for FR-24, not ICS interoperability. The remaining wire/profile requirements retain their selected [RFC scope](rfc/README.md).

- [x] Implement separate native description/RGB and decoded language-specific NAME/DESCRIPTION/CSS3 COLOR values under ADR 0050; HTTP/HTTPS links, exact categories, URI-only images and unit-preserving refresh hints under ADR 0051; stable native calendar protocol UID/time under ADR 0052. Validate/disclose these through generated APIs and Flutter, without fetching images/URIs or starting polling.
- [ ] Implement the selected property/parameter/component profiles from the RFC tables and [ADR 0010](adr/0010-rfc5545-property-decisions.md)/[ADR 0014](adr/0014-rfc-extension-decisions.md). Keep native services, standalone interchange, scheduling and feed projections distinct.
- [ ] Preserve supported metadata through edits and semantic round trips: URI-only attachments/content, host-validated labels/classification, import-only CONTACT, language/display metadata, legal structured nesting and DERIVED read-only behavior. Reject invalid/unknown/inline/over-limit input atomically; do not fetch content, create directory entries or infer bookings/authority from metadata.
- [ ] Implement selected relationship search/grouping, legal UID/URI forms, allowlisted relations, signed GAP and cross-calendar links. Test private/ambiguous/missing/cyclic targets, independent authorization, collection-scoped LINK UIDs, publication mapping and rejection of XML-REFERENCE. Relationship edits alone cannot change dates, task state, bookings or alarms.
- [ ] Add ICS round trips/publication for stored calendar metadata and remaining selected RFC 7986 fields, including source/property-parameter preservation and aggregate-feed metadata/identity. SOURCE stays private, images stay URI-only and refresh hints do not create polling jobs. Validate language/multiplicity and moderator-link disclosure; native editing already exists as scoped above.
- [x] Add bounded generic syntax parsing/serialization with strict UTF-8/CRLF, byte-aware unfolding, ordered immutable trees, TEXT/RFC 6868 parameter codecs and rune-safe folding under [ADR 0062](adr/0062-bounded-icalendar-syntax-foundations.md). Syntax retention is not profile acceptance or domain import/export.
- [x] Add pure DATE, UTC/named-zone DATE-TIME and signed DURATION wire codecs under [ADR 0063](adr/0063-icalendar-temporal-value-codecs.md), preserving whole seconds, explicit endpoint gating, exact zone keys and duration units. Value conversion does not validate a component or authorize import/export.
- [x] Implement the first pure non-recurring VEVENT wire-to-core adapter including DATE/UTC/named-zone timing and full-horizon VTIMEZONE validation under [ADRs 0064](adr/0064-first-vevent-and-zone-validation-contract.md)/[0065](adr/0065-first-vevent-wire-adapter.md). Earlier observance seeds and UTC edge padding are calculation-only; ordinary event storage stays unchanged. This does not implement authorized database import/export.
- [x] Add recurring VEVENT masters with typed RRULE/start-only RDATE/EXDATE, first-period start validation, retained source and aggregate work limits under [ADR 0066](adr/0066-recurring-vevent-master-adapter.md). PERIOD additions and separate occurrence-override components follow under ADRs 0067–0068 below.
- [x] Add pure timed RDATE PERIOD start/end or positive-duration pairs under [ADR 0067](adr/0067-vevent-period-additions.md), retaining core exceptional spans/conflict rules and combined raw caps. Native PERIOD storage/import remains pending; pure occurrence components follow under ADR 0068 below.
- [x] Add pure single timing/cancellation and timing-only THISANDFUTURE components under [ADR 0068](adr/0068-vevent-occurrence-components.md), with exact original membership and shared work caps. In-file master/content-inheritance choices are confirmed; API mechanics remain under review, and content/future cancellation and native import/export remain pending.
- [x] Add pure standalone VAVAILABILITY/AVAILABLE timing/recurrence/overrides, priority/basic text/source stamps and bounded composition projection under [ADR 0069](adr/0069-first-availability-wire-adapter.md). Positive openings are selected; rich wire metadata follows under ADR 0070 below and authenticated import/export remains pending.
- [ ] Validate supported envelopes/component/property/value profiles above syntax and map native domain data. Emit approved UTF-8/CRLF/escaped/folded output through authorized projections. Test Gregorian defaults/rejection, equal source UIDs in separate calendars, conflicting zone definitions, synthetic negative fixtures and work limits. Defer standalone VFREEBUSY import while retaining generated output and authorized iTIP exchanges.

- [x] Add pure availability publication metadata under [ADR 0070](adr/0070-availability-wire-metadata.md), preserving repeated source groups and legal annotations with a bounded trusted private registry. Organizer syntax is not host approval; CONTACT remains source-only.
- [x] Record the selected create-only import and prerequisite storage choices under [ADR 0071](adr/0071-create-only-availability-import.md): full supported wire shape preservation, destination-calendar active UID conflicts initial source protocol versions distinct from database audit times, separate import/create permissions, and opening UUID/protocol UID separation.
- [x] Implement [source-preserving availability storage](availability-storage.md) under ADR 0072, including separate opening UUID/protocol UID, grouped categories/read-only CONTACT/PERIODs, source component protocol state, populated migration and native editor retention. Detailed representations remain under draft review.
- [x] Implement [create-only authenticated availability import](availability-import.md#implemented-create-only-operation) under ADR 0073: full-file atomic writes, separate import/create and organizer authority, exact destination-active UID conflict checks, source version retention, authorized minimal receipts and example import journey.
- [x] Implement [authenticated current-state availability export](availability-export.md) under ADR 0074: explicit single-calendar selection, independent export/raw-read rights, complete-or-failure output, source versions/metadata and generated full-horizon VTIMEZONE. Unsupported native state rejects rather than losing data.
- [x] Record the confirmed [explicit availability replacement choices](availability-update.md) under ADR 0075: revision-bound existing targets, local-conflict rejection, recorded import baselines, source sequence checks, stable matching opening identities, true no-ops, separate replacement authority and exact source timestamps.
- [x] Implement [baseline-aware explicit availability replacement](availability-update.md#implemented-operation) under ADR 0076, including private active-data snapshots, current raw-read authority, source conflict/no-op handling, opening identity remapping and scoped end-to-end checks. Concrete mechanics remain under draft PR review.
- [ ] Design adoption/overwrite, mixed upsert and broader source reconciliation separately; other component import/export and feeds remain pending.
- [x] Record [create-only VEVENT import/storage choices](event-import.md) under ADR 0078, including source preservation, independent permissions, private baseline, native defaults/version lifecycle and source envelope normalization.
- [x] Implement source-preserving event storage under [ADR 0079](adr/0079-source-preserving-event-storage.md): exact text UID candidates, PERIODs/annotations, independent component versions/presence, private baseline representation and data-preserving upgrades.
- [x] Implement [authenticated create-only VEVENT import](event-import.md#implemented-create-only-operation) under ADR 0080 with independent import/create/lifecycle authority, exact destination UID conflicts, private baseline persistence and full-batch atomicity.
- [x] Record the confirmed [event export boundary](adr/0081-authenticated-event-export-contract.md): explicit complete series from one calendar, all-or-nothing availability/authorization, separate export permission and full supported field disclosure.
- [x] Implement [current-state event export](event-export.md) under ADR 0082 with full disclosure, atomic selection, current semantic validation, regenerated zones and explicit unrepresentable-state rejection. Event replacement/adoption remains separate.
- [ ] Review the concrete ADR 0079 representation, limits and migration mechanics in the draft PR before accepting them as final contracts.


## Tasks

Pure-core task timing and recurrence projections are complete. [ADR 0083](adr/0083-first-native-task-contract.md) now confirms non-recurring task CRUD/assignments first, completion at 100 percent with server UTC time, reopening at 0 percent, and cancellation preserving percentage while clearing active completion time. [Non-recurring durable tasks](native-tasks.md) now implement CRUD, assignments and current progress under ADR 0084; [recurring task progress/history](recurring-tasks.md) now extend that slice under ADR 0086, implementing the confirmed ADR 0085 choices. The [pure VTODO master adapter](icalendar-task-adapter.md) now follows under ADR 0088, preserving the independently optional source progress confirmed in ADR 0087. Task occurrence/metadata wire profiles and database import/export remain pending.

- [x] Implement authorized non-recurring task CRUD, external assignment, opaque pagination, optional typed dates, progress/priority/current completion and expected revisions under ADR 0084.
- [x] Extend durable tasks with recurrence, bounded previews, independent occurrence progress/history and orphan protection under ADR 0086.
- [x] Add the pure bounded VTODO master wire profile under ADR 0088.
- [ ] Add VTODO occurrence/metadata profiles and source-preserving authenticated task import/export, plus disclosure-safe task filters and timing/content exceptions.
- [x] Define and test independent per-occurrence progress/history, original identity, safe pattern edits, due/duration semantics and bounded queries under ADR 0086.
- [ ] Add task timing/content exceptions, restart/recovery evidence, alarm invalidation and no-loss standalone VTODO interchange using known zones; undated native tasks already work.
- [x] Expose the first non-recurring generated-client task management in Flutter under ADR 0084.
- [x] Extend Flutter with recurring task previews, independent progress and history under ADR 0086.
- [ ] Extend Flutter with task exceptions/interchange. Task dates do not automatically block availability; explicit event reservations need the approved booking policy. Reject all VTODO iTIP/mail scheduling without mutation, automatic replies or outbound queueing; native assignment/interchange/alarms remain required.

## Feeds

The separate optional module boundary is selected under [ADR 0042](adr/0042-optional-http-feed-module.md); feed package scaffolding, storage/routes and installation tests with/without feeds remain pending. Calendar APIs must continue to work without that module.

- [ ] Implement authorized feed/calendar selection and multiple independent URL credentials. Generate at least 256 CSPRNG bits per secret under the proposed token policy, store only digests and management metadata, return raw secrets only on creation and redact URLs through application/proxy/APM logs.
- [ ] Publish deterministic complete VEVENT/calendar-description projections with stable publication UIDs and zone definitions. Revalidate current publication authority before content or validators; test independent revocation, aggregation, selection edits, tenant isolation, missing calendars, snapshot races and no silent truncation.
- [ ] Implement [ADR 0016](adr/0016-subscription-http-profile.md): read-only GET/HEAD, fixed ICS, ETag-only validation, strong If-Match/412 then If-None-Match with RFC precedence/weak comparison/lists/wildcards, bodyless HEAD/304, optional audience Content-Language and no subscription redirects. Defer date validators and partial responses; ignore unsupported ranges without altering normal conditional behavior.
- [ ] Test privacy-safe errors, opaque credential 404, no-store on every error/denial and no negative caching. Successful responses use private, no-cache, max-age=0, must-revalidate; omit proxy-revalidate/Expires. Verify enabled encoding variants, correct Vary/ETags and host/proxy cache behavior.
- [ ] Test equal feed bytes/ETags on different instances and warm-cache conditional fetches after committed revocation/publication withdrawal elsewhere. Stale local state must not return successful content or 304.
- [ ] Record subscription setup, updates/deletes, all-day/UTC/zoned recurrence/DST/exceptions, aggregation and URL lifecycle in Apple Calendar/iOS, Google Calendar From URL and the selected Outlook web/account variant. Record exact client/account/version/date/fixtures, metadata rendering, refresh delays and retained downloaded copies; additional client variants require separate evidence.

## Availability

- [x] Implement the first per-calendar booking/fallback query under [ADR 0056](adr/0056-first-calendar-free-busy.md), with separate source busy authority, no detail-list filtering, tentative blocking/classification and complete/unknown merged UTC periods. This is not full rule/subject availability or VFREEBUSY serialization.
- [x] Store each calendar's explicit named availability zone and free/unavailable no-rule fallback, with distinct settings authority and opaque subject associations. The implemented free/busy/rule services use these settings; they do not provide exclusive reservations.
- [ ] Add proven time-indexed event candidates for larger calendars; the first free/busy increment scans all active source records and returns unknown above its bounded source cap.
- [x] Resolve complete host-selected person/resource contributors within one trusted scope under [ADR 0058](adr/0058-subject-availability-search.md), independently of direct calendar/detail permissions. Reuse per-calendar recurrence/overrides/zones/rules/bookings; reject incomplete, empty, denied, foreign or stale resolution as unknown/failure. Explicit group-member expansion and cross-scope coordination remain separate work.
- [x] Implement scoped native rule CRUD, optional validity bounds, explicit opening zones, recurrence/inclusion/exclusion dates and RFC 7953 priority/range composition under [ADR 0057](adr/0057-native-working-hours.md), integrated into per-calendar free/busy. Keep raw disclosure independent from projection; unknown never means free.
- [x] Add opening single/future timing, skip/restore/clear, preview and orphan-safe retention, plus legal native text/categories/comments/definition URL/CLASS under [ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md). Keep metadata authority separate and source projections private.
- [x] Add native organizer with dedicated host approval, legal LANGUAGE/ALTREP annotations and bounded host-validated private X-properties under [ADR 0060](adr/0060-availability-publication-metadata.md); registered IANA extensions require individual profiles.
- [x] Add native definition/opening protocol stamps, actual-change definition SEQUENCE and preserved envelope duration under [ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md), with explicit legacy baselines and stable state on identical saves.
- [x] Preserve CONTACT and repeated metadata source groups in the pure wire adapter under [ADR 0070](adr/0070-availability-wire-metadata.md); native CONTACT editing/storage is not added.
- [x] Implement the selected bounded create-only availability import and explicit authenticated export under ADRs 0073/0074.
- [ ] Extend availability wire coverage deliberately beyond this profile where required; source reconciliation, occurrence text and future cancellation remain separate. Native calculation does not imply full RFC/client compatibility.
- [x] Apply per-calendar no-rule fallback (default free, unavailable alternative) only where no definition applies, including bounded/unbounded definitions and explicit closures.
- [x] Return host-selected subject summaries by intersecting independently evaluated contributor calendars after their rules, fallback and bookings; calendar priorities do not override one another. Summary projection has independent authority and no source calendar IDs/counts.
- [x] Implement bounded list-based per-target/common-free search with elapsed-second minimum, exact target deduplication, response snapshot metadata and complete/unknown coverage. Common-free requires every target complete; shared source/evaluation limits never manufacture free time.
- [ ] Design cross-scope/group-member expansion and production indexed contributor resolution as needed, preserving complete source coverage and declared policy coordination.
- [x] Export [authorized per-calendar VFREEBUSY UTC snapshots](freebusy-export.md) under ADR 0077, independently of subscriptions and detail/raw-rule reads, with complete-or-failure coverage, final source checks, private-data exclusion, committed cross-host changes and generated-client/Flutter evidence. Reads are not reservations.
- [ ] Design subject/common-free VFREEBUSY export and scheduling messages separately; raw rules remain authenticated-only and out of bearer event feeds.

## Scheduling

- [ ] Implement all selected VEVENT and VFREEBUSY methods from [RFC 5546](rfc/rfc-5546.md), with exact roles/properties, host-verified address/delegate/SENT-BY authority and resource acceptance policy. Imported metadata, DNS checks or feed credentials never authorize scheduling.
- [ ] Separate protocol UID/SEQUENCE/DTSTAMP/RECURRENCE-ID from app revisions and publication/mail identities. Reconcile updates/replies/cancellations, range/instance changes and counter proposals; deduplicate/reject stale or replayed messages without resurrecting cancelled invitations.
- [ ] Commit event/state/inbound-ledger/outbound intent atomically and use durable observable retries. Test all methods, MIME/METHOD mismatches, forged/revoked authority, response loops, recipient/input bounds and crash recovery. VTODO methods remain excluded inbound/outbound, including mixed-component rejection without partial processing.
- [ ] Provide maintained MIME and trusted inbound/outbound host mail adapters under [ADR 0015](adr/0015-restricted-imip-profile.md). Validate/emit component hints; defer S/MIME signing/encryption, reject unsupported protection and avoid plaintext downgrade or full RFC 6047 conformance claims.
- [ ] Run duplicate ingress and competing outbox consumers across active host instances; stop a claim holder around commit/submission and verify durable deduplication, takeover/stale-owner safety and stable retry identity without exactly-once transport claims.
- [ ] Test native Flutter scheduling and controlled mail directions independently from feed clients. Select external scheduling/mail targets separately and record invitation/reply/update/cancel/recurring-instance results; no mail server or identity directory is embedded. Real mail requires explicit authorization and configured recipients.

## Alarms and push

[ADR 0020](adr/0020-notification-delivery-scope.md) supersedes direct mobile push implementation: the required example uses authenticated Serverpod server events/streaming. iOS/Android/provider delivery remains illustrative/external, with no FCM/APNs or OS background-delivery gate.

- [x] Scaffold the reusable notification server/client package and authenticated module connection check. Durable delivery, streaming/reconnect and alarm execution remain pending; the package scaffold is not a notification runtime.
- [ ] Implement authorized personal event/task alarms with selected time triggers, UID/acknowledgement/snooze/DISPLAY and capped REPEAT/DURATION. Define multiple-recipient/reminder rules, legal anchors, date-only/DST, dismissal, expiry and missed/action interactions. Imported alarms require authorized activation; private state stays out of feeds.
- [ ] Persist generation/occurrence identity, bounded planning/refill, transactional claims, recovery scans and reminder outbox. Recalculate/invalidate on edits, exceptions, cancellation/deletion, task occurrence completion, recipient/access changes and snooze; test races, restart, duplicate/stale work and repeat deduplication.
- [ ] Revalidate current authorization/generation/expiry before dispatch and retries. Define cancellation/supersession across the notification port. Calendar owns timing/state; the reusable notification module owns generic delivery intent/adapters, while platform device/provider implementation belongs to external integrations. Provider acceptance is distinct from display or acknowledgement.
- [ ] Exercise planners, claiming and retries on at least two active hosts; test duplicate wake-ups, process interruption, expired lease takeover and stale-owner rejection using shared durable state and controlled timing. Validate cancellation/access/expiry across the notification-port boundary, including uncertain provider-acceptance outcomes.
- [ ] Build the reusable notification module and an example host adapter using Serverpod server events and authenticated streaming to Flutter under [ADR 0020](adr/0020-notification-delivery-scope.md). Keep recipient/scope routing host-verified and payloads minimal. No direct iOS/Android/FCM/APNs implementation is required.
- [ ] Demonstrate connected Flutter receipt, authenticated actions, multi-session consistency, logout/access revocation, stream disconnection/resubscription and authorized missed-notification recovery. Verify cross-instance server-event transport with the pinned toolchain; persist intent independently of transient events and distinguish submission, receipt and acknowledgement.

## Automated deployment tests

The local harness already satisfies scoped parts of NFR-14/NFR-15 for implemented features. CI and future protocol/worker/recovery coverage remain required. See [the validation record](scaffold-validation.md) for commands, pinned versions and actual results; do not treat unchecked future journeys as unrun existing tests.

- [x] Run stable generation, formatting, fatal-info analysis, core VM/Chrome, module unit, Flutter widget, real database/policy, populated-upgrade and web-release checks through local scripts. Use focused tests during features and broader checks after a complete feature batch.
- [x] Run two independent Serverpod host processes concurrently against shared synthetic test storage, with distinct ports/identities. Exercise cross-host generated-client reads/cursors, JWT refresh/logout semantics, stale writes and calendar/event/recurrence races.
- [x] Drive real generated-client APIs and Flutter browser journeys for calendar CRUD/associations, native/protocol metadata, UID/time, event lifecycle/stale edits and recurrence inclusion/exclusion previews. Keep pure core tests independent from Serverpod/Flutter.
- [x] Provide isolated synthetic identities, database seed/reset and local recording authentication-mail behavior. Keep local controls/credentials/logs outside production endpoints and committed secrets.
- [ ] Put the real module/migration/generated-client/Flutter and two-host suites in CI, including reliable launch/teardown, clean-checkout setup and recorded topology/version evidence. Extend existing local scripts rather than substituting mocks for actual hosts.
- [ ] Extend cross-instance checks to task changes, rule occurrence overrides/imports, HTTP feeds and warm-cache revocation/publication changes as each feature arrives. One host with two clients remains insufficient.
- [ ] Race scheduling ingress, alarm planners and outbox workers; interrupt/restart claim holders and assert durable recovery, logical uniqueness, idempotent handoff and stale-owner suppression. Specify time/lease/skew boundaries and recovery timeouts using controlled clocks/observable state and bounded waits.
- [ ] Add deterministic scheduling-mail/notification adapters and Flutter availability/search, task completion, scheduling, reminder actions and disconnect/reconnect/instance-switch journeys. Existing authentication-mail recording does not test scheduling mail or reminder delivery.
- [ ] Gather separate external feed-client and selected scheduling-client evidence. Local browser/native tests do not establish Apple/Google/Outlook interoperability; optional platform delivery needs its own evidence.

## Release evidence

Local runtime evidence exists for the implemented native slices under [scaffold validation](scaffold-validation.md) and [temporal validation](temporal-core.md). The full release gates below remain open; no full ICS/external-client compatibility or production worker-recovery claim is made.

- [x] Record local SDK pins, executable setup/check instructions and passing scoped unit/database/two-host/Flutter evidence through ADR 0056. This is the current baseline, not complete FR/NFR acceptance.
- [ ] A clean checkout starts the pinned Serverpod/Flutter host with fresh migrations, synthetic host identities/resources and verified setup. Demonstrate calendars, recurring tasks/events, scheduling, rules/search, secret feeds and connected Flutter notifications through generated clients.
- [ ] Gather evidence for FR-01 through FR-31 and NFR-01 through NFR-15, including authorization, stale revisions, restart/rollback, protocol/negative fixtures, cache isolation and alarm/mail crash recovery. Automated real-host/Flutter journeys and multiple-active-instance failure/recovery checks are required; feed-subset compatibility and connected notification example evidence remain independent release checks.
- [ ] Record versions, directions, fixtures, known gaps, operational limits and best-effort delivery/refresh/downloaded-copy limitations. Verify licenses, package metadata, changelog, version policy and publication dry run; publication is a separate decision. Reuse existing local native evidence and supply the missing protocol, worker/recovery, CI and external-client evidence.

## Later scope

VTODO iTIP/inbound-outbound scheduling mail, CalDAV/CalDAV scheduling, general upstream synchronization, arbitrary custom zones, standalone VFREEBUSY import, VJOURNAL, proximity/geofencing, arbitrary audio/email alarm actions and an independently reusable Flutter UI package remain deferred or outside the selected first-release contract. Exact exclusions follow the RFC tables. Native recurring tasks, time-based alarms and the reusable notification module/connected streaming example remain first-release work.

## First calendar CRUD increment

The first name/settings/association slice is implemented under [ADR 0049](adr/0049-first-calendar-crud-implementation.md), with generated module/host migrations and replaceable host policy. Duplicate labels, private demo scopes and the basic-batch boundary are maintainer-confirmed. [The implementation guide](calendar-crud-implementation.md) records concrete API/storage/limits and remaining work. Broader persistence/authorization checks above remain open for remaining event lifecycle/metadata, task/rule/feed/worker families, production coordinated policy and retention/cleanup. Descriptions/colors and scoped protocol metadata editing are now implemented under ADRs 0050–0052 below; no availability calculation or interoperability is claimed by storing a fallback/subject link.

## Native presentation and protocol text increment

[ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md) records maintainer-confirmed separation of native/protocol values, RGB versus CSS3 colors, preserved multiline native descriptions with a 16,384-code-point cap, and a first NAME/DESCRIPTION/COLOR editing batch. [The implementation guide](calendar-metadata.md) distinguishes scoped native editing/storage from pending parsing/export/feed publication. Native URLs, categories, images and refresh hints are implemented in the ADR 0051 increment below; source/property-parameter preservation and wire support remain pending.

## Links, categories, images and refresh increment

The maintainer selected HTTP/HTTPS links without user information, exact case-sensitive category text matching with optional language tags, and positive unit-preserving refresh hints with a one-year editing cap. [ADR 0051](adr/0051-calendar-links-categories-images-refresh.md) defines the cap as 365-day equivalent and keeps schema/limit/query mechanics under review. [The guide](calendar-links-and-categories.md) records this limited native FR-02/08/24 increment, including group-authorized category filtering, no link/image fetching or polling and pending parser/export/feed work.

## Native calendar protocol identity/time increment

The maintainer confirmed separate generated native calendar protocol UIDs and automatic whole-second UTC modification time for calendar metadata/settings/association changes. [ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md) and [the guide](calendar-protocol-identity.md) describe read-only independent disclosure, shared database time, stable UID/backfilled upgrades and unchanged minimal deletion markers. This limited FR-02/08/24 increment does not implement imported-source identity, full VCALENDAR change tracking or feed validators; event/task and publication changes require separate handling.

## First native event increment

The maintainer selected non-recurring CRUD first, optional/empty summary with an example-only placeholder, separate cancellation/content deletion and separate lifecycle permission. [ADR 0053](adr/0053-first-native-single-events.md) and [the guide](native-single-events.md) describe this scoped FR-03/04/08/27 implementation, typed core timing, actual parent/event host context, bounded authorized lists, transactional revisions and minimal deletion markers. Recurrence definitions and previews now extend this slice under ADR 0054 below; individual/future occurrence edits, full metadata, free/busy, scheduling, alarms and ICS/feed interoperability remain pending; event changes do not update the parent calendar's metadata time.

## Native event recurrence increment, 2026-10-21

The maintainer selected recurrence storage/bounded API and example previews first, preserving and validating explicit inclusion/exclusion dates during pattern replacement. [ADR 0054](adr/0054-native-event-recurrence-and-previews.md) and [the native guide](native-event-recurrence.md) describe the FR-03/04/08 increment: DATE/UTC/named-zone definitions, sorted filters/dates, actual parent/event/query policy context, separate preview authority/timing disclosure and complete-or-failure overlap queries. Individual/future occurrence editing, cross-event chronological queries and complete availability, ICS/feed and external-client interoperability remain pending. Existing temporal/ISO/WKST/profile guards remain unchanged. This updates earlier statements that all recurring event persistence remains pending; it does not complete recurrence edit lifecycle or the first release.

## Native occurrence timing increment, 2026-10-21

[ADR 0055](adr/0055-native-occurrence-timing-edits.md) and [the guide](native-occurrence-timing.md) cover the accepted timing-only batch: dedicated single/future timing actions, single cancellation/restoration preserving prior timing, orphan-rejecting master edits and deferred future cancellation. The service uses separate nullable override storage, actual immutable host context, transactional event revisions and effective previews. Per-occurrence content and future cancellation remain pending; availability follows next. The validation record distinguishes focused tests from the broader completed-batch checks.

## First per-calendar free/busy increment, 2026-10-21

[ADR 0056](adr/0056-first-calendar-free-busy.md) and [the guide](calendar-free-busy.md) record the accepted partial availability order and tentative policy. The native service evaluates effective event/occurrence timing, calendar-zone DATE occupancy and saved fallback under independent busy authority, returning only complete partitions or unknown/failure without partial free time. Working-hours rules, host-selected contributors/common-free search, protocol output and exclusive reservation remain open; storing those future rule definitions must not bypass their integration here.

## Availability wire metadata increment, 2026-10-22

[Availability wire publication metadata](icalendar-availability-metadata.md) under [ADR 0070](adr/0070-availability-wire-metadata.md) now validates and preserves organizer, legal URL/class, repeated category/comment/contact groups and bounded trusted private extensions. This supersedes earlier pending/rejection wording only for this pure adapter slice. CONTACT remains source-only; authenticated database import/export, current host approval and feeds remain pending. The next selected import increment is create-only, rejecting existing protocol UIDs; updates/reconciliation remain separate.


## Event storage prerequisite, 2026-10-23

[ADR 0079](./adr/0079-source-preserving-event-storage.md) and [the storage guide](event-storage.md) extend native events with stored PERIOD additions, retained text annotations, source property presence, independent component versions and a private baseline representation. Native edits, previews and occupied-time calculations use the retained values. Source conversion is pure and grants no authority; create-only VEVENT import now follows under ADR 0080; event export, source updates, feeds and scheduling remain pending. ADR 0080 now implements the selected create-only import. Current-state event export is the next recommended area.


## Event import increment, 2026-10-23

[ADR 0080](adr/0080-authenticated-create-only-event-import.md) implements the [create-only event endpoint](event-import.md#implemented-create-only-operation), preserving supported source state and private baselines under independent full-batch authority. Two-host UID/delete races and the Flutter import workflow are scoped integration gates. Event export/replacement, richer content, scheduling, feeds, tasks and alarm execution remain pending.


## Event export increment, 2026-10-23

[ADR 0082](adr/0082-authenticated-current-event-export.md) implements the confirmed explicit complete-series export boundary and the selected cancellation-restoration rejection. Read-only current-state output rechecks complete authority after serialization and excludes historical baselines. Native tasks and their progress/assignment/recurrence contracts are the next recommended major area; source replacement remains a separate reconciliation increment.
