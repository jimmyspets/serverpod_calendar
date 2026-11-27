# RFC implementation plan

Reviewed against the documented scope on **2026-10-19**. Scoped native module and syntax increments now have implementation evidence in the linked guides; table plans remain distinct from implemented wire semantics. These are property/feature planning matrices, not claims of full RFC conformance.

Each RFC has its own file with property/component/method/header, purpose, first-release plan and notes. Calendar RFCs enumerate their named properties/extensions; protocol RFCs use the relevant methods, headers and behavior. HTTP/CalDAV inventories are application-scoped, not exhaustive platform specifications. Supporting email/MIME/TLS dependencies are host/library responsibilities, not additional fully implemented RFC claims.

On 2026-10-19 the maintainer approved all 35 formerly Proposed rows across six RFC matrices as Yes — planned; those baselines are reflected directly in the tables. Other statuses retain their existing scope. Detailed implementation constraints still need validation.

All listed feature rows have selected statuses: none remain Undecided or Proposed. This describes row statuses only; notes still identify detailed constraints needing design. Recurring tasks, known-zone scope and standalone VFREEBUSY import are clarified in [ADR 0017](../adr/0017-profile-review-clarifications.md). Host/library responsibilities, deferred features and detailed implementation constraints still require validation; this does not establish full RFC conformance or accept every ADR.

## Status legend

| First-release plan | Meaning |
| --- | --- |
| Yes — planned | Required feature or necessary part of its selected component; no working implementation yet |
| Undecided | Considered or legal optional field with no selected support policy; not accepted implicitly |
| No — deferred | Outside the current release or execution scope |
| No — outside contract | Not provided by this interface/product, even if infrastructure has unrelated support |
| No — not defined | The cited standard does not define that combination |
| Host/library | Delegate to evaluated host/framework/library integration; still needs validation and configuration |

Do not read an undecided field as rejected forever or a planned row as support for every legal combination. Optional parameters, cardinalities, value forms, component contexts and method restrictions must be approved before accepting input. Unsupported input must fail explicitly; deliberate feed exclusions must not erase canonical data. Changing scope or a material policy requires consistent updates to requirements, ADRs, compatibility and issue drafts.

## One file per RFC

| RFC | Purpose | Overall first-release status |
| --- | --- | --- |
| [5545](rfc-5545.md) | Calendar/event/task format | Scoped property/recurrence profile selected; detailed constraints and implementation pending |
| [6868](rfc-6868.md) | Parameter value encoding update | Scoped syntax codecs implemented; property/component semantics remain separate |
| [5546](rfc-5546.md) | iTIP scheduling | Planned event/free-busy profile; task methods deferred |
| [6047](rfc-6047.md) | iMIP email binding | Restricted profile with host mail adapters; component hints planned, S/MIME deferred; no full RFC conformance |
| [7953](rfc-7953.md) | Availability rules | Planned calculation/interchange profile |
| [7986](rfc-7986.md) | Calendar descriptions | Scoped descriptive/URI metadata profile selected; detailed constraints and implementation pending |
| [9073](rfc-9073.md) | Structured event publishing | Scoped structured components/fields, URI metadata and bounded nesting planned; implementation pending |
| [9074](rfc-9074.md) | Extended alarms | Scoped time-based runtime required; personal UID/ack/snooze baseline planned; proximity deferred |
| [9253](rfc-9253.md) | Relationships | Scoped links/grouping/ordering/dependency metadata planned; XML references deferred; implementation pending |
| [9110](rfc-9110.md) | HTTP semantics | Planned feed semantics plus platform integration |
| [9111](rfc-9111.md) | HTTP caching | Planned private-feed policy plus infrastructure |
| [4791](rfc-4791.md) | CalDAV | Deferred |
| [6638](rfc-6638.md) | CalDAV scheduling | Deferred |

## Module versus feed scope

The Serverpod module and generated Dart APIs serve host Flutter GUIs for full calendar/task/scheduling/availability behavior. General interchange and scheduling use their own approved profiles. Apple/iOS, Google and Outlook subscription feeds expose a narrower explicit event/metadata projection; they do not need task/search/full scheduling GUI support. A row planned for the module is not automatically published in a feed. See [compatibility profiles](../compatibility.md).

## Document precedence

The maintainer identified these RFC tables as the latest feature-scope source during the documentation review. Use their statuses and notes when older narrative guidance conflicts; explicit newer maintainer decisions take precedence and must be reflected here. Requirements and compatibility explain the selected scope, while ADRs retain decision rationale and separate unapproved implementation details. A selected row does not establish every legal combination or runtime support.

## Deployment and automated evidence

The selected RFC profiles must hold with multiple active Serverpod instances. [ADR 0018](../adr/0018-automated-example-and-multiple-instances.md) requires automated tests through the real example host/Flutter app, including cross-instance ETag/revocation consistency and scheduling/alarm deduplication/recovery. This is a module deployment requirement, not a new RFC property or a claim of implemented protocol support.

## Sources of project decisions

Use [requirements](../requirements.md), [standards scope](../standards.md), and proposed [ADRs](../adr/README.md). The tables make existing scope and unresolved choices reviewable; they do not accept ADRs or invent verified behavior. Link implementation/test evidence to individual rows when code exists, then change the current implementation statement based on that evidence.

[Bounded syntax foundations](../icalendar-syntax.md) under [ADR 0062](../adr/0062-bounded-icalendar-syntax-foundations.md) preserve unknown syntax without approving it for import/export. Semantic profile validation and domain mapping remain pending.
