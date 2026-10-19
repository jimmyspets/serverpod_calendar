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

The maintainer authorized consolidating superseded uncommitted drafts and renumbering the remaining records consecutively before the first commit. Relevant guidance is retained in the availability and metadata records and the current RFC tables. Filenames, titles, index entries and references follow the current numbering.

Use the next consecutive number for a new ADR covering a material decision. Include context, proposal/decision, alternatives, consequences, and acceptance conditions. Preserve committed/accepted decision history; supersede accepted decisions with a linked ADR. Superseded uncommitted drafts may be removed under the maintainer-authorized cleanup. Mark an ADR accepted only after explicit maintainer agreement recorded in the PR or issue.
