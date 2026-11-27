# Architecture decision records

The retained ADRs distinguish confirmed scope from proposed implementation details. The later retained ADRs record explicit maintainer scope selections separately; formal ADR acceptance remains pending. The RFC tables are the latest feature-scope source, with newer explicit maintainer instructions taking precedence. Current maintainer requirements are distinct from proposed implementation policies and the inaccessible earlier chat. ADRs 0002 and 0003 were revised on 2026-10-19 to replace the initial UTC-only/non-recurring and owner-only proposals.

| ADR | Topic | Status |
| --- | --- | --- |
| [0001](0001-module-boundaries.md) | Serverpod module with independent core and format adapter | Proposed |
| [0002](0002-compatibility-and-time.md) | Named zones, recurrence and explicit calendar profile | Proposed |
| [0003](0003-owned-storage-and-concurrency.md) | Authorized transactional storage and revision conflicts | Proposed |
| [0004](0004-subscription-feeds.md) | Secret subscription URLs, combined feeds and ETags | Proposed |
| [0005](0005-external-subjects.md) | External subjects and host authorization | Proposed |
| [0006](0006-resource-availability.md) | Resource calendars and free/busy availability | Proposed |
| [0007](0007-scheduling-and-email.md) | iTIP scheduling and iMIP mail adapters | Proposed |
| [0008](0008-module-clients-tasks-and-search.md) | Native module/Flutter interfaces, tasks, subset feeds and availability search | Proposed |
| [0009](0009-alarms-and-notification-boundaries.md) | Alarm semantics, reusable notifications and Flutter push integration | Proposed |
| [0010](0010-rfc5545-property-decisions.md) | Interactive RFC 5545 property decisions and implementation details | Proposed implementation; selected scope confirmed |
| [0011](0011-defer-vtodo-scheduling.md) | Defer VTODO iTIP/iMIP; retain native tasks and standalone interchange | Confirmed scope; implementation proposed |
| [0012](0012-calendar-availability-policy.md) | Availability profile, fallback, separate results and authenticated rule access | Scope and summary intersection confirmed; implementation proposed |
| [0013](0013-gregorian-only.md) | Gregorian calendar system only | Confirmed scope; implementation pending |
| [0014](0014-rfc-extension-decisions.md) | Calendar metadata and extension profiles | Selected scope confirmed; implementation pending |
| [0015](0015-restricted-imip-profile.md) | Restricted iMIP profile; defer S/MIME | Confirmed scope; implementation pending |
| [0016](0016-subscription-http-profile.md) | Subscription HTTP profile review | Selected scope confirmed; implementation pending |
| [0017](0017-profile-review-clarifications.md) | Recurring tasks, known zones and deferred standalone free/busy import | Confirmed scope; implementation pending |
| [0018](0018-automated-example-and-multiple-instances.md) | Automated example host/app testing and multiple active Serverpod instances | Confirmed requirements; implementation proposed |
| [0019](0019-model-contracts.md) | Logical model catalog, storage/API separation and durable lifecycle records | Proposed |
| [0020](0020-notification-delivery-scope.md) | Reusable notification module and example streaming; external platform providers | Maintainer-confirmed scope; implementation proposed |
| [0021](0021-initial-workspace-scaffold.md) | Concrete package workspace, local example authentication and test harness | Proposed implementation; walkthrough choices confirmed |
| [0022](0022-utc-query-window-foundation.md) | Pure Dart UTC query-window operations and bounded implementation scope | Proposed implementation; foundation verified |
| [0023](0023-gregorian-date-only-values.md) | Gregorian date-only values and selected 0001–9999 year range | Year range confirmed; foundation verified |
| [0024](0024-civil-date-time-values.md) | Native civil precision, fractional export rejection and leap-second profile | Precision/leap choices confirmed; core value verified |
| [0025](0025-bounded-named-zone-resolution.md) | Pinned, bounded named-zone resolution, DST policies and coverage errors | DST/identifier/envelope choices confirmed; bounded resolver verified |
| [0026](0026-gregorian-calendar-day-arithmetic.md) | Gregorian day addition, signed distances and weekdays | Proposed implementation; date profile unchanged |
| [0027](0027-calendar-duration-values.md) | Unit-preserving signed durations and native microsecond precision | Precision/export choice confirmed; value implementation proposed |
| [0028](0028-duration-application.md) | Date-only application and calendar-first zoned durations | Calendar-first policy confirmed; API implementation proposed |
| [0029](0029-date-recurrence-rule-values.md) | Immutable date-only recurrence rule parameters and validation | Filter normalization confirmed; broader API proposed; generator in ADR 0030 |
| [0030](0030-bounded-date-recurrence-generation.md) | Bounded initial DATE-only occurrence generation and explicit limits | Mismatched-start rejection confirmed; initial subset tested; API proposed |
| [0031](0031-date-recurrence-week-numbers.md) | DATE-only yearly week-number generation and boundary semantics | Implementation proposed; native evidence separate from protocol support |
| [0032](0032-iso-week-convention.md) | ISO 8601 native week numbering and Monday first day | ISO native convention and honoring explicit RFC WKST confirmed |
| [0033](0033-date-recurrence-sets.md) | Bounded DATE-only recurrence sets and inclusion/exclusion precedence | Earlier inclusions confirmed; set/API implementation proposed |
| [0034](0034-native-iso-week-fields.md) | Native ISO week-year, week and weekday projection | Confirmed convention; API implementation proposed |
| [0035](0035-date-only-event-spans.md) | DATE-only event bounds, exclusive ends and preserved duration/default intent | Scoped API implementation proposed; broader span contracts pending |
| [0036](0036-date-event-series-overlap.md) | Bounded DATE-only event-series overlap with earlier-start lookback | Scoped API implementation proposed; timed/override/service integration pending |
| [0037](0037-date-only-single-occurrence-exceptions.md) | DATE-only identity, cancellation/replacement and bounded overlap batch | Batch authorized; native policies/API proposed; timed/range/service work pending |
| [0038](0038-date-only-this-and-future-timing.md) | DATE-only THISANDFUTURE shifts, spans and bounded overlap batch | Selected range scope; native timing API/policies proposed; service/wire work pending |
| [0039](0039-exact-utc-duration-and-event-spans.md) | Exact UTC duration application, spans/points and query lengths | Native API/precision correction proposed; timed recurrence/service/wire pending |
| [0040](0040-bounded-temporal-core-completion.md) | Bounded UTC/zoned recurrence, spans/edits, task milestones and zone evidence | Batch authorized; native APIs/policies proposed; wire/storage/lifecycle separate |
| [0041](0041-whole-second-1970-2100-profile.md) | Whole-second timing, exclusive 2100 horizon, generated future zones and update policy | Accepted maintainer profile; supersedes earlier precision/range limits |
| [0042](0042-optional-http-feed-module.md) | Separate optional Serverpod module for iCalendar HTTP feeds | Accepted boundary; names, contracts and scaffolding pending |
| [0043](0043-host-authorization-context.md) | Host-defined authorization and trusted collection/object context | Accepted responsibility/context requirement; signatures, query and consistency contracts proposed |
| [0044](0044-authorized-query-projections-and-pagination.md) | Separate detail/free-busy, typed field groups and no-total initial pagination | Accepted response choices; filtering, cursor and schema mechanics proposed |
| [0045](0045-authorization-consistency-guarantees.md) | Declared coordinated/external authorization guarantees and commit/revocation boundary | Accepted support/declaration; defaults, operation requirements and mechanics proposed |
| [0046](0046-first-native-calendar-crud-contract.md) | First native calendar CRUD: dependent-delete rejection, explicit zone and nonempty name | Accepted product rules; commands, label/schema and adapter details proposed |
| [0047](0047-calendar-names-identifiers-and-deletion-storage.md) | Separate native names, version-independent UUID identity and minimal deletion marker | Accepted logical boundaries; physical layout, validation and retention duration proposed |
| [0048](0048-calendar-name-validation-and-row-layout.md) | Native 256-code-point/trim name rules and separate identity/active-data rows | Accepted validation/layout boundaries; generated constraints and protocols proposed |
| [0049](0049-first-calendar-crud-implementation.md) | First native CRUD, duplicate labels, private demo scopes and bounded storage/authorization mechanics | Accepted batch scope; implementation mechanics under review |
| [0050](0050-calendar-presentation-and-protocol-text.md) | Separate native description/RGB and language-specific protocol text/CSS3 color | Accepted product/batch boundaries; implementation mechanics under review |
| [0051](0051-calendar-links-categories-images-refresh.md) | HTTP links, exact category search, image hints and bounded unit-preserving refresh metadata | Accepted product profile; schema/query mechanics under review |
| [0052](0052-calendar-protocol-identity-and-revision-time.md) | Calendar protocol identity and revision time | Accepted generated UID/automatic timestamp; implementation mechanics under review |
| [0053](0053-first-native-single-events.md) | First native non-recurring event CRUD and separate lifecycle authority | Accepted batch/summary/lifecycle boundaries; mechanics under review |
| [0054](0054-native-event-recurrence-and-previews.md) | Native event recurrence storage and bounded previews | Accepted batch/date preservation; mechanics under review |
| [0055](0055-native-occurrence-timing-edits.md) | Native single/future occurrence timing edits | Accepted timing/cancellation/preservation scope; mechanics under review |
| [0056](0056-first-calendar-free-busy.md) | First bounded per-calendar free/busy | Accepted increment/tentative policy; mechanics under review |
| [0057](0057-native-working-hours.md) | Native working hours and calendar composition | Accepted increment/timing choices; mechanics under review |
| [0058](0058-subject-availability-search.md) | Host-resolved subject availability and common-free search | Accepted scope/access choices; mechanics under review |
| [0059](0059-availability-occurrence-edits-and-metadata.md) | Opening-occurrence edits and scoped availability metadata | Accepted scope; mechanics under review |
| [0060](0060-availability-publication-metadata.md) | Availability organizer, text parameters and private extensions | Accepted batch choices; mechanics under review |
| [0061](0061-availability-protocol-lifecycle-and-envelope-duration.md) | Availability protocol lifecycle and envelope duration | Accepted version/opening choices; mechanics under review |
| [0062](0062-bounded-icalendar-syntax-foundations.md) | Bounded iCalendar syntax foundations | Accepted strict input; syntax/limit mechanics under review |
| [0063](0063-icalendar-temporal-value-codecs.md) | iCalendar temporal value codecs | Proposed adapter API/mechanics; existing temporal policy unchanged |
| [0064](0064-first-vevent-and-zone-validation-contract.md) | First VEVENT adapter and zone-validation contract | Confirmed scope/full-horizon matching/earlier seeds; scoped adapter under ADR 0065 |
| [0065](0065-first-vevent-wire-adapter.md) | First standalone VEVENT wire-to-core adapter | Accepted bounded observances; API/limits under review |
| [0066](0066-recurring-vevent-master-adapter.md) | Recurring VEVENT master adapter | Accepted batch; API/limits under review |
| [0067](0067-vevent-period-additions.md) | VEVENT PERIOD additions | Accepted batch; adapter mechanics under review |

The maintainer authorized consolidating superseded uncommitted drafts and renumbering the remaining records consecutively before the first commit. Relevant guidance is retained in the availability and metadata records and the current RFC tables. Filenames, titles, index entries and references follow the current numbering.

Use the next consecutive number for a new ADR covering a material decision. Include context, proposal/decision, alternatives, consequences, and acceptance conditions. Preserve committed/accepted decision history; supersede accepted decisions with a linked ADR. Superseded uncommitted drafts may be removed under the maintainer-authorized cleanup. Mark an ADR accepted only after explicit maintainer agreement recorded in the PR or issue.
