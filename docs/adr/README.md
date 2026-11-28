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
| [0068](0068-vevent-occurrence-components.md) | VEVENT occurrence timing and cancellation components | Accepted scope/master requirement/inheritance; API/limits under review |
| [0069](0069-first-availability-wire-adapter.md) | First availability wire adapter | Accepted timing/composition/positive openings; API/limits under review |
| [0070](0070-availability-wire-metadata.md) | Availability wire publication metadata | Accepted batch/registry/source groups; API/limits under review |
| [0071](0071-create-only-availability-import.md) | Create-only availability import and storage prerequisites | Accepted scope/identity/source-version choices; schema/API mechanics proposed |
| [0072](0072-source-preserving-availability-storage.md) | Source-preserving availability storage | Implemented scoped ADR 0071 prerequisites; representation/migration mechanics under review |
| [0073](0073-authenticated-create-only-availability-import.md) | Authenticated create-only availability import | Accepted scope; concrete API/transaction mechanics under draft review |
| [0074](0074-authenticated-availability-export.md) | Authenticated current-state availability export | Accepted explicit selection/all-or-nothing; API/serialization mechanics under draft review |
| [0075](0075-availability-update-reconciliation-contract.md) | Explicit availability replacement and conflict detection | Accepted scope/baseline/conflict/version/identity/no-op/permission/timestamp choices; implementation mechanics proposed |
| [0076](0076-availability-replacement-implementation.md) | Baseline-aware availability replacement implementation | Accepted private active-row snapshot/raw-read choices; scoped implementation, concrete mechanics under draft review |
| [0077](0077-privacy-safe-calendar-freebusy-export.md) | Privacy-safe per-calendar VFREEBUSY export | Accepted per-calendar-first and separate export authority; concrete mechanics under draft review |
| [0078](0078-create-only-event-import-and-storage.md) | Create-only event import and storage prerequisites | Accepted scope/identity/version/permissions/default/baseline/normalization/native lifecycle/legacy choices; schema/API mechanics proposed |
| [0079](0079-source-preserving-event-storage.md) | Source-preserving event storage implementation | Scoped ADR 0078 prerequisite; concrete representation/migration mechanics under draft review |
| [0080](0080-authenticated-create-only-event-import.md) | Authenticated create-only event import | Confirmed ADR 0078 scope; scoped implementation with concrete API/transaction mechanics under draft review |
| [0081](0081-authenticated-event-export-contract.md) | Authenticated event export contract | Accepted explicit selection/full-series/all-or-nothing/separate export and full disclosure; API/adapter mechanics proposed |
| [0082](0082-authenticated-current-event-export.md) | Authenticated current-state event export | Scoped ADR 0081 implementation; accepted rejection of unrepresentable cancellation; mechanics under draft review |
| [0083](0083-first-native-task-contract.md) | First durable native task contract | Accepted non-recurring CRUD/assignments first and completion/reopen/cancellation rules; schema/API/query mechanics proposed |
| [0084](0084-first-native-task-implementation.md) | First native task implementation | Scoped ADR 0083 choices; concrete schema/API/query mechanics under draft review |
| [0085](0085-recurring-task-progress-and-history.md) | Recurring task progress and history | Accepted independent original-occurrence progress and preservation/rejection of orphaning rule edits; mechanics proposed |
| [0086](0086-durable-task-recurrence-implementation.md) | Durable task recurrence implementation | Scoped ADR 0085 recurrence/progress/history implementation; concrete mechanics under draft review |
| [0087](0087-vtodo-wire-master-contract.md) | Standalone VTODO wire master contract | Accepted independent source progress values; first pure master adapter mechanics proposed |
| [0088](0088-vtodo-wire-master-implementation.md) | Bounded VTODO wire master implementation | Scoped ADR 0087 pure adapter implementation; concrete mechanics under draft review |
| [0089](0089-vtodo-occurrence-component-contract.md) | VTODO occurrence component contract | Accepted in-file master and progress-only profile with inherited omissions; concrete mechanics proposed |
| [0090](0090-vtodo-occurrence-component-implementation.md) | VTODO occurrence component implementation | Scoped ADR 0089 linked source/projection implementation; mechanics under draft review |
| [0091](0091-vtodo-text-and-link-metadata.md) | VTODO text and link metadata | Scoped confirmed metadata batch implementation; concrete representation/limits under draft review |
| [0092](0092-vtodo-source-participants.md) | VTODO source participants | Scoped confirmed source/assignment separation implementation; concrete profile under draft review |
| [0093](0093-vtodo-source-references.md) | VTODO source relationships and attachments | Scoped confirmed inert source-reference implementation; concrete profile under draft review |
| [0094](0094-vtodo-display-alarm-source-profile.md) | VTODO DISPLAY alarm source profile | Scoped confirmed DISPLAY source-profile implementation; concrete mechanics under draft review |
| [0095](0095-vtodo-snooze-source-profile.md) | VTODO snooze source profile | Scoped confirmed bounded sibling snooze implementation; concrete mechanics under draft review |
| [0096](0096-source-preserving-native-task-progress.md) | Source-preserving native task progress | Scoped confirmed optional progress/master-default implementation; concrete mechanics under draft review |
| [0097](0097-create-only-task-import-contract.md) | Create-only task import contract | Accepted create-only/gates/source versions/private baseline; concrete storage/service mechanics proposed |
| [0098](0098-task-source-storage-model.md) | Task source storage model | Scoped confirmed source-retention/assignment-version storage implementation; concrete mechanics under draft review |

| [0099](0099-authenticated-create-only-task-import.md) | Authenticated create-only task import | Scoped confirmed contract implementation; concrete mechanics under draft review |

| [0100](0100-authenticated-current-task-export.md) | Authenticated current task export | Confirmed separate source-read gate; concrete mechanics under draft review |

| [0101](0101-single-task-occurrence-timing.md) | Single task occurrence timing | Confirmed single scope, complete replacements and completed-history preservation; captured progress and complete explicit timing confirmed |

| [0102](0102-task-future-timing.md) | Task this-and-future timing | Scoped implementation of confirmed range timing and anchor-only progress; concrete mechanics under draft review |
| [0103](0103-single-task-content-overrides.md) | Selected single-task content overrides | Scoped implementation of confirmed per-field/anchor-local content; mechanics under draft review |

| [0104](0104-task-source-replacements.md) | Explicit task source replacements | Confirmed reuse of baseline/conflict/no-op policy; concrete mechanics under draft review |

| [0105](0105-event-source-replacements.md) | Explicit event source replacements | Confirmed baseline/conflict/no-op policy and lifecycle gates; concrete mechanics under draft review |

| [0106](0106-single-event-content-overrides.md) | Selected single-event content overrides | Confirmed field/anchor-only content and preserved timing inheritance; mechanics under draft review |

| [0107](0107-read-only-event-source-metadata.md) | Read-only event source metadata | Confirmed source-first preservation, independent source-read and bounded occurrence matching; mechanics under draft review |

The maintainer authorized consolidating superseded uncommitted drafts and renumbering the remaining records consecutively before the first commit. Relevant guidance is retained in the availability and metadata records and the current RFC tables. Filenames, titles, index entries and references follow the current numbering.

Use the next consecutive number for a new ADR covering a material decision. Include context, proposal/decision, alternatives, consequences, and acceptance conditions. Preserve committed/accepted decision history; supersede accepted decisions with a linked ADR. Superseded uncommitted drafts may be removed under the maintainer-authorized cleanup. Mark an ADR accepted only after explicit maintainer agreement recorded in the PR or issue.
