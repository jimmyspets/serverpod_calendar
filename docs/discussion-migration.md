# Discussion migration and scope evidence

Date: 2026-10-19. Earlier-source status: **partial reconstruction**. This document records provenance; current feature scope lives in the [RFC tables](rfc/README.md) and [requirements](requirements.md).

## Earlier sources and limitations

The earlier conversation was “Summarize iCalendar Compatibility”, conversation ID 6ad5c7e5-93a8-83eb-934a-41ffd5fb19e4. The supplied [shared conversation link](https://chatgpt.com/share/e/6ad5d8ae-3b28-83ed-b9b1-f8369fadb1e8) required sign-in; assistant architecture answers were not recovered. Accessible questions concerned module documentation, a first working project, public library publication, Serverpod versus Stalwart and repository migration. No earlier product comparison or architecture agreement is established here.

The imported creation report recorded inspection of a LICENSE-only repository at b13c228141112b371bfcbab2c56717129c81e450, no issues/PRs at that inspection, and GitHub write attempts rejected with HTTP 403. These are historical reported outcomes, not current GitHub inventory. No branch, commit, issue or PR was created by that import.

The original UTC-only/non-recurring, owner-only proposal and six-issue bootstrap were superseded by direct maintainer instructions. Its patch, PR draft and creation report were removed during cleanup; they are no longer planning inputs. The remaining bootstrap issue drafts were subsequently removed after consolidating useful delivery checks in [the roadmap](roadmap.md). The Apache 2.0 LICENSE is preserved.

## Confirmed scope and decision evidence

Direct instructions in the repository conversation establish Serverpod 4.x+, Mermaid documentation, Gregorian-only dates, external identity references, resource calendars, recurring events and tasks, named zones, free/busy/search, multi-calendar secret feeds with independently revocable URLs and ETags, scheduling, native tasks and first-release alarms/reusable notifications. Flutter provides most GUI; external feed clients consume a narrower declared subset.

Detailed selections are recorded without treating all ADR implementation proposals as accepted:

| Decisions | Record |
| --- | --- |
| RFC 5545 metadata, recurrence filters, host authority and bounded repeats | [ADR 0010](adr/0010-rfc5545-property-decisions.md) |
| Native tasks/interchange retained; all VTODO iTIP/mail deferred | [ADR 0011](adr/0011-defer-vtodo-scheduling.md) |
| RFC 5545 principles in legal availability contexts | [ADR 0012](adr/0012-calendar-availability-policy.md) |
| Per-calendar fallback default free, separate results, optional host-selected subject summaries using intersection, authenticated-only raw rules | [ADR 0012](adr/0012-calendar-availability-policy.md) |
| Promote all 35 formerly Proposed RFC rows to Yes — planned | [RFC scope](rfc/README.md) |
| Gregorian only | [ADR 0013](adr/0013-gregorian-only.md) |
| Selected RFC 7986/9073/9253 metadata and relationship profiles | [ADR 0014](adr/0014-rfc-extension-decisions.md) |
| Restricted iMIP profile; S/MIME deferred | [ADR 0015](adr/0015-restricted-imip-profile.md) |
| ETag-only fixed ICS HTTP profile, explicit errors and private success/no-store error caching | [ADR 0016](adr/0016-subscription-http-profile.md) |
| Recurring tasks included, known named zones initially, standalone VFREEBUSY import deferred | [ADR 0017](adr/0017-profile-review-clarifications.md) |
| Example host/app used for automated testing; more than one concurrently active Serverpod instance supported | [ADR 0018](adr/0018-automated-example-and-multiple-instances.md) |

## Package and notification walkthrough

The maintainer selected one repository for reusable packages and the example host/Flutter app. An optional Flutter calendar UI package is planned for later extraction from the example, without a first-release publication gate. Package names and responsibility boundaries are confirmed in the [scaffolding plan](scaffolding-plan.md), together with the stable SDK policy, Web-first example, local Docker services, self-contained host authentication, local checks before CI and the initial authentication/connection milestone. The maintainer selected a separate reusable notification module, clarified that iOS/Android delivery is illustrative and must not be implemented directly here, and suggested Serverpod server events/streaming for the example. [ADR 0020](adr/0020-notification-delivery-scope.md) supersedes the earlier required platform push path while preserving durable alarm semantics.

## Current interpretation and remaining work

The maintainer identifies the RFC tables as the latest feature-scope source. New explicit instructions take precedence; update the tables and dependent guidance together. Earlier “still under review” statements do not reopen subsequently selected features. No feature rows remain Undecided or Proposed, but row notes and ADRs still identify detailed design work.

Logical package names/responsibilities and the initial example milestone are selected in the scaffolding plan. Physical template layout, host authorization contracts, storage schema, task occurrence lifecycle, temporal validation details, alarm delivery policies, protocol limits and release evidence remain implementation design. Formal ADR acceptance is separate from confirmed feature scope. Recovery of the earlier conversation is optional evidence work and does not block the current requirements.

The initial workspace/authentication scaffold now exists under [ADR 0021](adr/0021-initial-workspace-scaffold.md). Calendar domain behavior and external client compatibility remain unimplemented/unverified; local auth/module smoke evidence is recorded separately. Do not copy personal calendar data or unrelated chat into this repository; use synthetic fixtures.

## Superseding temporal profile

The maintainer subsequently selected whole seconds and ordinary calendar dates from 1970-01-01 inclusive to 2100-01-01 exclusive, keeping the current timezone library and generating future transitions. Nonzero fractions reject without rounding, explicit exclusive endpoints and required UTC spillover are retained, and updates/limitations must be documented. Breaking unpublished APIs are authorized. [ADR 0041](adr/0041-whole-second-1970-2100-profile.md) supersedes the prior microsecond/broad-date/2037 profile; [timezone maintenance](timezone-data.md) records the generation and update process.
