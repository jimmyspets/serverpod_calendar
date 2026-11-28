# serverpod_calendar

> [!WARNING]
> **SUPPORTED CALENDAR DATES: 1970-01-01 inclusive to 2100-01-01 exclusive.** The final ordinary date is **2099-12-31**. Calendar timing accepts **whole seconds only**; nonzero fractions are rejected, never rounded.
>
> **2100 is excluded**, except for an explicit midnight boundary used as an exclusive event/query end. Necessary UTC spillover is calculation padding, not permission to store out-of-range calendar dates. Named-zone data now includes calculated future transitions through the supported horizon; the former 2037 restriction is superseded by generated coverage. Future results assume the pinned IANA rules continue to apply, and unknown-offset periods still fail explicitly. See [timezone limits and updates](docs/timezone-data.md) and [ADR 0041](docs/adr/0041-whole-second-1970-2100-profile.md). **Do not remove or bypass these profile/coverage guards.**

A reusable calendar module intended for Serverpod projects, providing calendar, free/busy, availability-search, scheduling, task and alarm services. Host Flutter clients provide most of the GUI.

**Calendar system:** Gregorian only. Recurring events and tasks are included; time zones initially use known named zones with validated matching definitions.

**Week convention:** ISO 8601: Monday is the first day; week 1 contains January 4, equivalently the year's first Thursday. Use the ISO week-year at New Year. Honor explicit RFC 5545 WKST values for recurrence, including their rule-specific week numbers. See [ISO weeks and recurrence WKST](docs/week-conventions.md).

**Authorization:** the modules enforce access; hosts provide replaceable rules using trusted caller, operation and requested collection/object context. No fixed ownership/role model is required. See the [authorization contract](docs/host-authorization.md) and [first implemented CRUD slice](docs/calendar-crud-implementation.md).

**HTTP subscriptions:** iCalendar feeds belong to a separate optional Serverpod module under [ADR 0042](docs/adr/0042-optional-http-feed-module.md). Hosts can use authenticated calendar APIs without installing feeds. The first optional [event-subscription profile](docs/http-event-feeds.md) now has scoped implementation under ADR 0116; full batch validation and external-client evidence remain separate.

**Platform target:** Serverpod 4.x and later. The initial scaffold pins Serverpod 4.0.4, Flutter 3.47.7 and Dart 3.13.5; additional supported versions require separate verification.

**Status:** executable workspace/authentication scaffold with a tested pure Dart [temporal foundations and a bounded named-zone resolver](docs/temporal-core.md); the first calendar CRUD/association slice now has module storage, replaceable host-policy enforcement and a Flutter example. The example uses private demo-user scopes; production hosts supply their own rules. Native descriptions/RGB colors and scoped iCalendar text-metadata editing now extend that slice; see [metadata behavior and limits](docs/calendar-metadata.md). Native [links, categories, images and refresh hints](docs/calendar-links-and-categories.md) now extend this with authorized exact category filtering. Read-only [protocol UID and modification time](docs/calendar-protocol-identity.md) provide stable native identity and automatic timestamps. The first [non-recurring event CRUD slice](docs/native-single-events.md) adds typed timing and host-authorized event/lifecycle operations. Native [recurrence storage and bounded occurrence previews](docs/native-event-recurrence.md) extend event CRUD. Native [single/future occurrence timing edits and single cancellation/restoration](docs/native-occurrence-timing.md) extend saved series. The first [per-calendar free/busy service](docs/calendar-free-busy.md) calculates privacy-safe booking/fallback intervals with complete/unknown coverage. Native [working-hours definitions and priority composition](docs/native-working-hours.md) now extend free/busy. Native [person/resource availability and common-free search](docs/subject-availability-search.md) now resolve complete host-selected contributors within one trusted scope. Native [opening-occurrence edits and scoped availability metadata](docs/availability-occurrences-and-metadata.md) now extend those calculations. Native [availability organizer, text annotations and private extensions](docs/availability-publication-metadata.md) now add dedicated host approval and bounded metadata validation. Native [availability protocol lifecycle and envelope durations](docs/availability-protocol-lifecycle.md) now add read-only versions/timestamps and preserved duration bounds. Pure Dart [bounded iCalendar syntax foundations](docs/icalendar-syntax.md), [temporal value codecs](docs/icalendar-temporal-values.md) and [the first standalone non-recurring VEVENT/VTIMEZONE adapter](docs/icalendar-event-adapter.md) now provide scoped wire-to-core mapping without database import or publication. [Recurring masters](docs/icalendar-recurring-masters.md) extend this with typed rule/inclusion/exclusion sets. Authenticated [create-only availability import](docs/availability-import.md#implemented-create-only-operation) now retains supported CONTACT and source protocol data. Selected per-occurrence content and scoped task interchange now follow below. Future content/cancellation, remaining wire profiles, cross-scope aggregation and feeds remain pending. First-release scope remains planned; see the [development guide](docs/development.md), [scaffolding plan](docs/scaffolding-plan.md) and [validation evidence](docs/scaffold-validation.md). Detailed domain designs remain under review. This repository retains its Apache 2.0 [license](LICENSE).

Authenticated [create-only event import](docs/event-import.md#implemented-create-only-operation) now preserves the supported VEVENT/occurrence profile, independent source versions and private baselines under separate host import/create/lifecycle permissions. Authenticated [current-state event export](docs/event-export.md) now requires full disclosure and explicit complete-series selection. [Explicit source replacement](docs/event-source-replacement.md) is implemented; HTTP feeds remain separate work.

Native [non-recurring tasks](docs/native-tasks.md) now add durable CRUD, assignments, independent progress permissions and example screens. Cancellation keeps percentage and clears current completion time; recurrence, history and scoped VTODO interchange now follow below.

Native [recurring tasks and progress history](docs/recurring-tasks.md) now extend that slice with bounded previews, independent occurrence completion/cancellation and orphan protection. Single/future task timing, selected occurrence content and scoped VTODO interchange now follow below.

The pure [VTODO adapter](docs/icalendar-task-adapter.md) now preserves bounded task timing, recurrence and independently optional source progress, including progress-only occurrence components with a matching master in the file. Source CLASS/URL and grouped categories/comments/contact are now supported too. Source organizer/attendee claims are preserved separately from native assignments, without messages or authority. Basic unresolved source relationships and URI-only attachment references are preserved too. Unarmed DISPLAY alarm definitions now retain supported triggers, repeats and optional UID/ACKNOWLEDGED. Bounded unarmed sibling snooze links now require source identity, acknowledgement and absolute UTC timing. Native [source-preserving task progress](docs/task-source-progress.md) now retains optional fields and recurring master defaults while native commands keep explicit outcomes. Authenticated task import/export, replacements and selected timing/content exceptions now have scoped implementations below; extended profiles and alarm execution remain separate.

## Start here

- [Documentation index](docs/README.md)
- [First-project requirements](docs/requirements.md)
- [Architecture and module boundaries](docs/architecture.md)
- [Proposed model catalog](docs/models.md)
- [Local example setup and checks](docs/development.md)
- [iCalendar compatibility scope](docs/compatibility.md)
- [RFC property and feature coverage](docs/rfc/README.md)
- [Delivery plan and acceptance checks](docs/roadmap.md)
- [Proposed architecture decisions](docs/adr/README.md)
- [Discussion migration and source gaps](docs/discussion-migration.md)
- [Contributor and agent guidance](AGENTS.md)

The first release centers on authenticated Serverpod APIs and generated Dart clients for Flutter applications, including events, tasks, alarms with a reusable notification boundary and connected Flutter streaming example, scheduling, named zones/recurrence and availability search across lists of people or rooms. Read-only iCalendar subscription feeds expose a documented subset for Apple Calendar on iOS, Google Calendar and Microsoft Outlook; their feature sets do not constrain the module. A feed can publish one or several calendars through multiple independently revocable, long random URLs, with ETag support and no subscriber password. Authenticated host APIs manage calendars, events and publication. Calendars can reference users, groups, rooms, venues and equipment through external subject links. Free/busy queries show available or booked intervals across their calendars, with privacy-aware access. The host owns identities, membership and authorization; resource catalog integration is also proposed at the host boundary. These are requirements awaiting implementation and client verification.

See the [architecture](docs/architecture.md) for the proposed relationship diagram and the [compatibility profile](docs/compatibility.md) for release evidence. First-release scope also includes RFC 7953 availability rules, iTIP scheduling and a restricted iMIP-compatible email profile (S/MIME signatures/encryption deferred; no complete RFC 6047 conformance claim); see the [standards matrix](docs/standards.md). Calendar descriptions target RFC 7986; RFC 9074 has a selected time-based personal alarm profile; RFCs 9073/9253 have selected scoped metadata profiles under [ADR 0014](docs/adr/0014-rfc-extension-decisions.md); detailed alarm lifecycle/wire constraints remain pending, while proximity and arbitrary audio/email actions are deferred. The [alarm boundary proposal](docs/adr/0009-alarms-and-notification-boundaries.md) separates calendar timing/state, reusable notification delivery and Flutter platform integration. VTODO scheduling over iTIP and email is deferred; native tasks, standalone VTODO import/export and task alarms/notifications remain in scope. See [ADR 0011](docs/adr/0011-defer-vtodo-scheduling.md). CalDAV and general upstream-provider synchronization remain separate scope.

The example host/Flutter app must also serve as the automated integration-test application. The module must work with multiple concurrently active Serverpod instances, with cross-instance consistency, durable background-work coordination and recovery tested under [ADR 0018](docs/adr/0018-automated-example-and-multiple-instances.md).

Pinned tools and local setup/run/check commands are documented in the [development guide](docs/development.md). This includes the initial calendar CRUD milestone; the complete calendar first release and its client compatibility remain unimplemented and unverified.

## Repository formatting

[Git attributes](.gitattributes) keep text files in LF format on macOS and Windows, overriding platform-specific automatic line-ending conversion. Windows `.bat`/`.cmd` scripts use CRLF on checkout. `.ics` fixtures retain their original bytes for protocol testing. [EditorConfig](.editorconfig) sets UTF-8, two-space indentation and matching editor defaults; intentional Markdown trailing spaces are preserved. No global Git configuration changes are needed.

## Typed iCalendar temporal values, 2026-10-22

[ADR 0063](docs/adr/0063-icalendar-temporal-value-codecs.md) adds scoped pure DATE, UTC/named-zone DATE-TIME and DURATION wire-to-core codecs; [the guide](docs/icalendar-temporal-values.md) records strict forms, endpoint gating, exact integer/resource bounds and normalization. Existing temporal policy is unchanged. Complete component/property validation, VTIMEZONE matching, recurrence wire mapping, source-preserving database import, authorized export and HTTP feeds remain pending. Value acceptance alone establishes no domain authorization or client interoperability.

## Recurring event wire profile

The [recurring VEVENT master adapter](docs/icalendar-recurring-masters.md) extends the pure event/zone adapter with RRULE and start-only RDATE/EXDATE. Source retention, native temporal meaning and whole-calendar work limits are explicit. [PERIOD-valued RDATE additions](docs/icalendar-recurring-masters.md#period-valued-rdate-additions) now preserve exceptional timed spans. Separate occurrence components, database import/export and HTTP publication remain pending; this does not establish external-client compatibility.

## Occurrence wire timing profile

[ADR 0068](docs/adr/0068-vevent-occurrence-components.md) adds pure [single timing/cancellation and timing-only THISANDFUTURE components](docs/icalendar-occurrence-components.md). Grouped core projections retain original identities, source versions and bounded validation. Earlier blanket occurrence-component-pending notes are superseded for this subset; content/future cancellation, authenticated import/export and HTTP publication remain pending.

## Availability wire timing profile

[ADR 0069](docs/adr/0069-first-availability-wire-adapter.md) adds the pure [VAVAILABILITY/AVAILABLE timing and composition profile](docs/icalendar-availability-adapter.md), including bounded recurrence/overrides, exact zones and positive openings. Rich metadata, authenticated import/export and HTTP publication remain pending; no host authorization or external-client compatibility follows from parsing.

## Availability wire metadata increment, 2026-10-22

[Availability wire publication metadata](docs/icalendar-availability-metadata.md) under [ADR 0070](docs/adr/0070-availability-wire-metadata.md) now validates and preserves organizer, legal URL/class, repeated category/comment/contact groups and bounded trusted private extensions. This supersedes earlier pending/rejection wording only for this pure adapter slice. CONTACT remains source-only; authenticated database import/export, current host approval and feeds remain pending. The next selected import increment is create-only, rejecting existing protocol UIDs; updates/reconciliation remain separate.

## Availability import storage decisions, 2026-10-22

[ADR 0071](docs/adr/0071-create-only-availability-import.md) records confirmed create-only availability import choices: extend storage to preserve the supported wire profile first, detect active UID conflicts within the destination calendar, retain source protocol versions separately from database import time/API revisions, require separate import authority plus per-definition create authority, and keep native opening UUIDs distinct from text protocol UIDs. [The storage/import contract](docs/availability-import.md) proposes models, migration, authorization, atomicity and validation gates. These extensions and the import endpoint remain unimplemented; physical/API mechanics still require review.

## Availability storage prerequisite increment, 2026-10-22

[ADR 0072](docs/adr/0072-source-preserving-availability-storage.md) and [the storage guide](docs/availability-storage.md) implement source-preserving availability prerequisites: text protocol UIDs with native UUID separation, grouped categories/read-only CONTACT, availability PERIODs, source component versions and data-preserving upgrades. Native edits/calculation enforce the expanded state; pure conversion supplies no host authority or database import. Authenticated create-only import now follows under ADR 0073 below.


## Create-only availability import, 2026-10-22

[ADR 0073](docs/adr/0073-authenticated-create-only-availability-import.md) and [the import guide](docs/availability-import.md) now implement the bounded authenticated availability import profile after ADR 0072 storage. This supersedes earlier import-pending wording only for standalone supported VAVAILABILITY files: separate import/create authority, current organizer/private-extension checks, source versions, destination-active UID conflicts and full-file atomicity with authorized minimal receipts. FR-06/07/08/18 gain this scoped increment; authorized export, source reconciliation, other component import, HTTP feeds and external-client interoperability remain pending.


## Authenticated availability export, 2026-10-22

[ADR 0074](docs/adr/0074-authenticated-availability-export.md) and [the export guide](docs/availability-export.md) add current-state standalone availability output. The maintainer selected explicit definitions from one calendar and all-or-nothing authorization/availability. Require independent export and raw-read rights with full immutable selection context, reauthorize after serialization, preserve the supported component data and generate full-horizon pinned VTIMEZONE definitions. Native skip/restoration state, missing component checkpoints, duplicate opening source UIDs across selected definitions and over-limit/out-of-profile state reject explicitly. Export is a read with no revision/time changes and no HTTP feed or scheduling side effects. This supersedes export-pending wording only for the declared availability slice; source reconciliation, other component import/export, feeds and external-client interoperability remain pending.


## Availability replacement contract, 2026-10-22

[ADR 0075](docs/adr/0075-availability-update-reconciliation-contract.md) and [the update guide](docs/availability-update.md) record confirmed explicit replacement choices: only selected existing targets, reject local-edit conflicts, require a recorded import baseline, allow equal/reject lower source SEQUENCE, retain matching opening UUIDs, true authorized no-ops, separate replacement authority, and preserve exact source timestamps/omissions even when they regress. Baseline/schema/API/transaction/receipt mechanics remain proposed; no update endpoint or new storage exists yet. Create-only import and authenticated export remain implemented under ADRs 0073/0074. Overwrite/adoption, mixed upsert, source synchronization, feeds and scheduling remain separate.


[Privacy-safe VFREEBUSY export](docs/freebusy-export.md) now provides authenticated per-calendar UTC snapshots with complete coverage and independent export authority. It is separate from event subscriptions, subject/common-free export and scheduling messages.

## Task source storage prerequisite

[Source-preserving task storage](docs/task-source-storage.md) now retains supported decoded metadata, inert participants/references/attachments, unarmed alarms/snoozes and independent component versions. Native edits retain source values or reject incompatible changes; assignment-only edits preserve protocol versions. Historical baselines are private and scrubbed at deletion. Authenticated task import/export and rich metadata editors remain separate.

## Authenticated task import

[Create-only task import](docs/task-import.md#implemented-create-only-operation) now preserves the supported VTODO profile atomically under separate import/create/progress permissions, with destination-local UID conflicts, private baselines and source versions. Source participants assign nobody, alarms stay unarmed and no history is invented. The Flutter example explicitly normalizes pasted line endings while the byte API stays strict. Task export, source updates, native metadata editors and alarm runtime remain separate.

Authenticated [task export](docs/task-export.md) now complements create-only task import. Explicit complete-series output requires separate export, full task-detail and rich-source-read authority; participants/attachments/unarmed alarms remain inert source data. Source replacement, native exceptions, HTTP feeds and alarm runtime remain separate.

[Single task occurrence timing](docs/task-occurrence-timing.md) now preserves original identity and completion history while moving/resizing one occurrence or clearing its deadline. Explicit source DTSTART supplies complete occurrence timing; private source baselines advance to v2 and older imports require reimport. Future timing/content, source reconciliation and alarm runtime remain separate.

[Task future timing](docs/task-future-timing.md) now extends single timing across the core, storage, authenticated import/export and Flutter example. Timing alone propagates; progress/history stay attached to each original occurrence. See ADR 0102 for the bounded anchor-only VTODO progress profile and pending content/reconciliation/runtime scope.

[Selected task occurrence content](docs/task-occurrence-content.md) adds independent summary/description/location/priority overrides with explicit clear or series inheritance and protected preview groups. Source v3 requires explicit recreation/reimport of older imported tasks; development data is not reset. Future content propagation and runtime services remain separate.

[Explicit task source replacement](docs/task-source-replacement.md) now follows create-only import and export: replace selected imported series with baseline/local-conflict protection, preserved assignments and true no-op retries. Adoption/overwrite and broader synchronization remain separate.

[Explicit event source replacement](docs/event-source-replacement.md) now applies the same recorded-baseline/local-conflict and true no-op policy to selected imported event series, with independent lifecycle checks for status and cancellation changes. This is ordinary import replacement; scheduling reconciliation and adoption remain separate.

Selected event occurrence content is implemented under [ADR 0106](docs/adr/0106-single-event-content-overrides.md); [the guide](docs/event-occurrence-content.md) explains timing inheritance, explicit export rejection and the pre-beta v2 source-baseline boundary.

Read-only [event source metadata](docs/event-source-metadata.md) is implemented under ADR 0107, with independent source-read authorization; native metadata editors remain separate.

[Event source participants](docs/event-source-participants.md) now preserve bounded ORGANIZER/ATTENDEE claims through interchange and storage, without host identity mapping, authority or invitations. Native participant editing and scheduling remain separate.

[Event source relationships and URI attachments](docs/event-source-references.md) now round-trip as inert read-only data. They create no native links, fetch no files and grant no target access. Native graph/file editors and extended relationships remain separate.

## Unarmed event source alarms, 2026-10-24

[ADR 0110](docs/adr/0110-unarmed-event-source-alarms.md) now extends the supported source profile with [unarmed VEVENT DISPLAY alarms and bounded sibling snoozes](docs/event-source-alarms.md). Nullable immutable server-only alarm/duration DTOs use existing metadata JSON, without table changes or a migration. Existing event-source-v2 baselines remain compatible. Separate `readEventSource` authority protects export/replacement and final/no-op checks; ordinary projections hide this data. Native edits preserve definitions and reject incompatible explicit-END anchor changes atomically. Source UID/ACKNOWLEDGED/SNOOZE are unverified data, never recipients, authority or native actions. This supersedes earlier event-alarm rejection/pending wording only for this source-preservation slice. Native personal definitions/editors, adoption, planning, delivery, feeds and client interoperability remain separate requirements.


## Native personal alarm definitions, 2026-10-24

[ADR 0111](docs/adr/0111-native-personal-alarm-definitions.md) adds [private native event/task timing definitions and example editors](docs/native-personal-alarms.md). The host resolves the current recipient; requests cannot select another. Independent alarm permissions, actual parent/current/proposed context, final recipient checks and revisions protect one bounded private table. Shared edits retain incompatible definitions as needing attention; parent deletion scrubs all recipients atomically. Private writes leave item/protocol versions, source baselines and public scope generation unchanged. All definitions remain unarmed; imported-alarm adoption, actions, planning and delivery remain required separate work. Concrete mechanics remain draft review material.


## Durable alarm planning increment, 2026-10-25

[ADR 0112](docs/adr/0112-bounded-durable-alarm-planning.md) now adds [explicit arming, complete rolling plans and guarded durable handoff](docs/durable-alarm-planning.md), with separate background policy, database leases/fences, source/lifecycle checks, stable retry IDs and terminal-history pruning that preserves action state. This supersedes earlier unarmed-only/planner-pending wording for native definitions only. Imported alarms remain unarmed. Native action APIs, reusable notification delivery and connected streaming remain separate requirements; the example delivery port explicitly remains unconnected. First-release alarm requirements are not complete.

Native [personal alarm actions and private activity pages](docs/native-alarm-actions.md) now extend the planner with acknowledgement/dismissal, bounded replacement snooze and future-only reset. Notification delivery and connected streaming remain separate required work.


## Reusable live notification increment, 2026-10-25

[ADR 0114](docs/adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](docs/reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.


## Timing-only source alarm adoption, 2026-10-25

[ADR 0115](docs/adr/0115-timing-only-source-alarm-adoption.md) implements [explicit master-timing copying](docs/imported-alarm-adoption.md) into new unarmed personal definitions, using current authorized item text. It reuses existing storage without a migration and enforces source-read/adopt/create rights, actual parent revisions and trusted recipients. This supersedes earlier adoption-pending wording only for this bounded flow. Source text/UID/acknowledgement/snooze state stays inert; broader profiles, private exports and release gates remain separate. Full local batch validation passed; see the validation record for exact evidence.

## Optional event subscriptions, 2026-10-25

[ADR 0116](docs/adr/0116-optional-event-subscription-contract.md) adds the [separate optional feed module](docs/http-event-feeds.md), with explicit multi-calendar selection, stable event publication UIDs, independently revocable digest-only bearer URLs and freshly authorized GET/HEAD/ETag responses. The example includes settings and URL management. All alarms are excluded; authenticated source exports remain independent. Full local batch validation passed. External subscription-client compatibility, production infrastructure and coordinated timezone upgrades remain separate release gates.

## Pure scheduling-message increment, 2026-10-25

[ADR 0117](docs/adr/0117-first-itip-message-profile.md) adds a [bounded pure message adapter](docs/itip-message-profile.md) for PUBLISH, REQUEST, REPLY and CANCEL, with one non-recurring VEVENT, method-specific restrictions and preserved optional source timing/version fields. Focused tests passed; selected broader checks passed. Source participant claims remain untrusted. Reconciliation, recurring messages, the remaining selected methods/properties and email are still required separate work; parsing sends no messages and changes no stored event.

The ADR 0118 payload increment adds bounded reply-result, priority, exact coordinate and descriptive resource-group codecs to those pure messages. It preserves source spelling/omissions without native storage, resource reservations or executable status handling. Focused tests passed; selected broader extension checks passed.

ADR 0119 extends the [pure scheduling profile](docs/itip-message-profile.md) with bounded recurring masters and detached instance components. The unpublished API separates the envelope from `message.events`, preserving each component’s source versions/omissions and original/range identity. Selected broader checks passed. Parsing still proves no stored membership or authority and executes no scheduling transition or mail.

ADR 0120 extends pure event scheduling validation to ADD, REFRESH, COUNTER and DECLINECOUNTER. Each method has its own field/cardinality rules; source proposals and refresh requests cause no stored changes, lookups or automatic replies. Concrete profile mechanics remain draft review material; see the [message profile](docs/itip-message-profile.md).

ADR 0121 adds a separate [pure VFREEBUSY scheduling adapter](docs/itip-freebusy-profile.md) for PUBLISH/REQUEST/REPLY, retaining grouped UTC periods and unverified source annotations. It executes no availability query, automatic response or scheduling transition. Authorized snapshot output keeps its independent privacy/completeness rules.

The maintainer confirmed explicit **Save and notify**, committing event changes and outbound intent atomically, and **native-created organizer meetings first**. Ordinary edits stay local; imported meetings require later adoption. The approved [ADR 0122](docs/adr/0122-explicit-native-organizer-publication.md) batch now has [bounded non-recurring REQUEST publication](docs/native-organizer-scheduling.md), generated storage, fenced retries and a synthetic example transport/editor. Accepted [ADR 0123](docs/adr/0123-explicit-native-organizer-cancellation.md) extends it with explicit whole-event cancellation from the published snapshot and reopening through a newer REQUEST, preserving unsent native drafts. Accepted [ADR 0124](docs/adr/0124-recurring-organizer-masters.md) adds recurring-master pattern publication and whole-series cancellation, preserving saved native exceptions while rejecting their REQUEST component publication. It sends no real email; occurrence/instance scheduling, recipient changes, binding cleanup, inbound reconciliation and RFC 6047 mail remain required.

Accepted [ADR 0126](docs/adr/0126-independent-occurrence-publication-versions.md) now extends that workflow to complete representable occurrence REQUEST bundles with independent outgoing versions and explicit complete-message host authorization. Native inheritance/source versions stay separate, and whole-series cancellation/reopening retains the publication ledger in existing storage. Unsupported timing, individual cancellation and removal/retargeting of published exceptions reject without discarding saved edits. This supersedes the preceding master-only REQUEST restriction for the declared profile. See [the organizer guide](docs/native-organizer-scheduling.md#complete-occurrence-request-bundles) and [validation](docs/scaffold-validation.md) for actual behavior/evidence. Instance reset/CANCEL, broader lifecycle/participants, inbound reconciliation and real mail remain separate.

Accepted [ADR 0127](docs/adr/0127-retained-occurrence-reset-projections.md) adds follow-series reset publication for retained single/future originals. Current timing/text is projected into outgoing messages while native inheritance and ordinary export stay unchanged. Retained identities remain within the 64-slot profile; missing membership, kind changes and individual cancellation still reject. See [reset behavior](docs/native-organizer-scheduling.md#retained-occurrence-resets) and validation. This restores published values without claiming remote exception deletion; instance CANCEL, broader lifecycle/inbound scheduling and mail remain separate.


Accepted [ADR 0128](docs/adr/0128-explicit-single-occurrence-cancellation.md) adds explicit historical **Cancel occurrence and notify**. It sends a minimal detached CANCEL from the retained published series, preserves newer unpublished drafts and changes the native flag only for an exact current profile/member. New partial messages require earlier deliveries to be terminal; retries/no-ops reauthorize. Self-contained v4 checkpoints reuse existing tables, and generated status distinguishes instance versus whole-series cancellation. New REQUEST/reopen is blocked while individual cancellations remain. Individual restoration, range cancellation, concurrent partial coordination, inbound reconciliation and real mail remain separate; see the [organizer guide](docs/native-organizer-scheduling.md#historical-single-occurrence-cancellation) and [validation](docs/scaffold-validation.md).


Accepted [ADR 0129](docs/adr/0129-explicit-occurrence-restoration.md) adds **Restore published occurrence and notify**. It sends the last published values, preserves newer drafts and clears only an exact current native cancellation flag. Independent active/restored versions survive pruning in existing storage. Complete Save and notify can resume after all individual cancellations are restored and retained native identities validate. Cancelled-master reopening with remaining individual cancellations, range/parallel publication coordination, inbound reconciliation and real mail remain separate. See the [restoration guide](docs/native-organizer-scheduling.md#published-value-individual-restoration) and validation.


Accepted [ADR 0130](docs/adr/0130-preserved-cancellations-reopening.md) adds **Reopen published series and notify** while preserving individual cancellations and newer native drafts. Restoring one of these cancellations sends a complete published-series update and keeps every remaining cancellation. Publication-only exclusions stay separate from ordinary source exclusions and native flags; full native publication still requires all cancellations restored and retained originals valid. Existing tables are reused. Range/parallel coordination, attendee/inbound workflows, mail and external-client evidence remain separate; see the [reopening guide](docs/native-organizer-scheduling.md#retained-cancellation-reopening).

Accepted [ADR 0131](docs/adr/0131-first-authenticated-attendee-replies.md) adds [trusted non-recurring attendee REPLY processing](docs/authenticated-attendee-replies.md). Private response/source state preserves stale replies for authorized review without changing native drafts or outbound delivery state. The example provides a development/test-only synthetic simulator; instance/range replies, incoming invitations and mail remain separate requirements. See [validation](docs/scaffold-validation.md) for completed checks.

## Recurring master replies

Accepted [ADR 0132](docs/adr/0132-recurring-master-attendee-replies.md) extends trusted organizer-side REPLY to recurring masters. The runtime resolves the actual master from validated self-contained publication evidence, including partial messages and v6 exclusion masks; it preserves private native drafts, complete host context and source distinctions. Responses describe the whole series, never inferred instance acceptance. Master-changing commits update source inactivity atomically; unchanged master versions retain ordering across occurrence publications. Existing tables/caps are reused with no migration. Generated views add `recurring`; trusted adapters receive the complete published message, selected master and carrier kind. Validation evidence is recorded separately. Instance/range replies, other inbound methods and mail remain required separate work.

## Single-instance replies

Accepted [ADR 0133](docs/adr/0133-single-instance-attendee-replies.md) adds scoped trusted single-instance replies to any validated published original, with effective single/range/master versions and separate target response state. Existing reply tables gain source targetKey/originalStart/targetBasisKey and response targetKey, with a meeting/attendee/target uniqueness index. Legacy rows default to master; an explicit newer Save and notify upgrades legacy publication version profiles. New outgoing components cannot reuse earlier effective versions, range applicability changes advance affected versions, and native inheritance/source versions stay separate. Host contexts identify the exact original, selected component and effective occurrence; no source identity grants authority. Instance queries and private source review remain independently authorized. RANGE replies, broader inbound methods and mail remain separate. Validation evidence is recorded separately.

## Event descriptive fields

Accepted ADR 0134 adds the scoped native/ordinary VEVENT descriptive-field increment: exact decimal coordinates, optional priority and preserved resource groups, with separate editing/disclosure and effective scheduling versions. See [the implementation guide](docs/native-event-descriptive-fields.md) and validation evidence. Resource labels grant no booking or authority; external rendering/mail evidence remains separate.
