# serverpod_calendar

> [!WARNING]
> **SUPPORTED CALENDAR DATES: 1970-01-01 inclusive to 2100-01-01 exclusive.** The final ordinary date is **2099-12-31**. Calendar timing accepts **whole seconds only**; nonzero fractions are rejected, never rounded.
>
> **2100 is excluded**, except for an explicit midnight boundary used as an exclusive event/query end. Necessary UTC spillover is calculation padding, not permission to store out-of-range calendar dates. Named-zone data now includes calculated future transitions through the supported horizon; the former 2037 restriction is superseded by generated coverage. Future results assume the pinned IANA rules continue to apply, and unknown-offset periods still fail explicitly. See [timezone limits and updates](docs/timezone-data.md) and [ADR 0041](docs/adr/0041-whole-second-1970-2100-profile.md). **Do not remove or bypass these profile/coverage guards.**

A reusable calendar module intended for Serverpod projects, providing calendar, free/busy, availability-search, scheduling, task and alarm services. Host Flutter clients provide most of the GUI.

**Calendar system:** Gregorian only. Recurring events and tasks are included; time zones initially use known named zones with validated matching definitions.

**Week convention:** ISO 8601: Monday is the first day; week 1 contains January 4, equivalently the year's first Thursday. Use the ISO week-year at New Year. Honor explicit RFC 5545 WKST values for recurrence, including their rule-specific week numbers. See [ISO weeks and recurrence WKST](docs/week-conventions.md).

**Authorization:** the modules enforce access; hosts provide replaceable rules using trusted caller, operation and requested collection/object context. No fixed ownership/role model is required. See the [authorization contract](docs/host-authorization.md) and [first implemented CRUD slice](docs/calendar-crud-implementation.md).

**HTTP subscriptions:** iCalendar feeds belong to a separate optional Serverpod module under [ADR 0042](docs/adr/0042-optional-http-feed-module.md). Hosts can use authenticated calendar APIs without installing feeds; the feed module itself is not implemented yet.

**Platform target:** Serverpod 4.x and later. The initial scaffold pins Serverpod 4.0.4, Flutter 3.47.7 and Dart 3.13.5; additional supported versions require separate verification.

**Status:** executable workspace/authentication scaffold with a tested pure Dart [temporal foundations and a bounded named-zone resolver](docs/temporal-core.md); the first calendar CRUD/association slice now has module storage, replaceable host-policy enforcement and a Flutter example. The example uses private demo-user scopes; production hosts supply their own rules. Native descriptions/RGB colors and scoped iCalendar text-metadata editing now extend that slice; see [metadata behavior and limits](docs/calendar-metadata.md). Native [links, categories, images and refresh hints](docs/calendar-links-and-categories.md) now extend this with authorized exact category filtering. Read-only [protocol UID and modification time](docs/calendar-protocol-identity.md) provide stable native identity and automatic timestamps. The first [non-recurring event CRUD slice](docs/native-single-events.md) adds typed timing and host-authorized event/lifecycle operations. Native [recurrence storage and bounded occurrence previews](docs/native-event-recurrence.md) extend event CRUD. Native [single/future occurrence timing edits and single cancellation/restoration](docs/native-occurrence-timing.md) extend saved series. The first [per-calendar free/busy service](docs/calendar-free-busy.md) calculates privacy-safe booking/fallback intervals with complete/unknown coverage. Native [working-hours definitions and priority composition](docs/native-working-hours.md) now extend free/busy. Native [person/resource availability and common-free search](docs/subject-availability-search.md) now resolve complete host-selected contributors within one trusted scope. Native [opening-occurrence edits and scoped availability metadata](docs/availability-occurrences-and-metadata.md) now extend those calculations. Native [availability organizer, text annotations and private extensions](docs/availability-publication-metadata.md) now add dedicated host approval and bounded metadata validation. Native [availability protocol lifecycle and envelope durations](docs/availability-protocol-lifecycle.md) now add read-only versions/timestamps and preserved duration bounds. Pure Dart [bounded iCalendar syntax foundations](docs/icalendar-syntax.md), [temporal value codecs](docs/icalendar-temporal-values.md) and [the first standalone non-recurring VEVENT/VTIMEZONE adapter](docs/icalendar-event-adapter.md) now provide scoped wire-to-core mapping without database import or publication. [Recurring masters](docs/icalendar-recurring-masters.md) extend this with typed rule/inclusion/exclusion sets. Authenticated [create-only availability import](docs/availability-import.md#implemented-create-only-operation) now retains supported CONTACT and source protocol data. Per-occurrence content overrides, future cancellation, remaining wire interchange, cross-scope aggregation and task/feed services remain pending. First-release scope remains planned; see the [development guide](docs/development.md), [scaffolding plan](docs/scaffolding-plan.md) and [validation evidence](docs/scaffold-validation.md). Detailed domain designs remain under review. This repository retains its Apache 2.0 [license](LICENSE).

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
