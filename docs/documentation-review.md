# Documentation consistency review

Date: 2026-10-19. Scope: repository Markdown, imported bootstrap artifacts, issue drafts, RFC matrices, Git/editor configuration and LICENSE.

## Source precedence

The maintainer identifies the [RFC tables](rfc/README.md) as the latest feature-scope source. Explicit newer maintainer instructions take precedence and are reflected in those tables. Requirements, compatibility, architecture and issue drafts must follow selected statuses and notes. ADR rationale remains useful; formal ADR acceptance and implementation details are separate from selected feature scope.

## Removed obsolete artifacts

| Removed file | Reason |
| --- | --- |
| docs/bootstrap/CREATION-REPORT.md | Import is complete; the twelve-file/six-issue inventory and operational next steps were obsolete |
| docs/bootstrap/DRAFT-PR.md | Described the superseded UTC/date-only, non-recurring MVP and three-ADR bootstrap |
| docs/bootstrap/repository.patch | Reapplying the original bootstrap would restore superseded guidance and duplicate installed files |

Source-recovery limitations and reported historical GitHub outcomes are retained in [discussion migration](discussion-migration.md). LICENSE is unchanged. All nineteen issue drafts were reviewed and removed after their useful delivery checks were consolidated into the roadmap. The subsequent ADR cleanup consolidated still-relevant guidance and removed four superseded uncommitted drafts.

## Bootstrap folder removal

Reviewed every remaining bootstrap file: its index and nineteen issue drafts. The drafts repeated current requirements/RFC/ADR guidance; remaining useful CI/setup, dependency, failure-case and interoperability checks are consolidated in [the roadmap](roadmap.md). The entire folder was removed, and live references now point to named roadmap work packages. No implementation or feature scope was removed.

## Superseded uncommitted ADRs removed

| Removed ADR | Current home of relevant guidance |
| --- | --- |
| Availability rules | [ADR 0012](adr/0012-calendar-availability-policy.md): rule model, calculation, policy and validation |
| Shared RFC 5545/7953 profile | [ADR 0012](adr/0012-calendar-availability-policy.md): shared metadata/recurrence profile and legal component constraints |
| Initial metadata/extension review | [ADR 0014](adr/0014-rfc-extension-decisions.md): selected metadata profiles, feed identity and evidence |
| Promote Proposed RFC rows | [Current RFC scope](rfc/README.md): selected table statuses; a separate promotion-only ADR is no longer needed |

The maintainer explicitly authorized this cleanup before the first commit. At the maintainer request, the remaining ADRs were subsequently renumbered consecutively before the first commit; all references were updated. Other records cover distinct boundaries or decisions and were kept.

## Conflicts and stale guidance reconciled

| Finding | Resolution |
| --- | --- |
| Older narratives still treated alarm identity/acknowledgement/snooze and selected metadata as unapproved | Aligned current guidance with RFC tables and ADR 0014 and the RFC tables; kept detailed implementation constraints pending |
| SOURCE omission described as merely a proposed default | Confirmed exclusion from all subscription output; private authenticated interchange retained |
| Availability fallback and summary composition still listed as unresolved | Aligned with per-calendar default-free fallback, unavailable alternative and intersection of host-selected contributors under ADR 0012 |
| Architecture fetch flow omitted planned If-Match and final cache/error policy | Added RFC precondition ordering and ADR 0016 response-specific caching |
| Core recurrence draft listed only daily/weekly/monthly/yearly | Added selected hourly/minutely cadence, filters, WKST and THISANDFUTURE work |
| Repeated batch-by-batch narratives appeared to reopen decisions | Consolidated current RFC summaries; retained chronological rationale in ADRs with current-scope notes |
| Original source recovery appeared to block confirmed scope | Kept recovery optional; retained real implementation design dependencies |
| roadmap profile contracts mixed initial feature evaluation with implementation owned by other drafts | Reframed as final schema/validation contracts, with implementation in roadmap interchange/task/alarm work |
| ADR index was out of sequence and incompletely described confirmed selections | Renumbered consecutively and distinguished scope confirmation from proposed implementation |

## Questions answered by the maintainer

[ADR 0017](adr/0017-profile-review-clarifications.md) records the answers obtained during this review:

- Defer standalone VFREEBUSY file import; preserve generated output and supported iTIP exchanges.
- Include recurring tasks in native services and standalone VTODO interchange; task scheduling mail remains deferred.
- Initially support known named zones and validated matching VTIMEZONE definitions; defer arbitrary custom rules.

The RFC tables and dependent requirements, architecture, compatibility, ADRs and issue acceptance criteria reflect these decisions. No unanswered feature-scope conflict identified by this pass remains.

## Automated example and multiple-instance requirement

The maintainer requires the example host/Flutter app to be used for automated testing and the module to support multiple simultaneously active Serverpod instances. Consecutive [ADR 0018](adr/0018-automated-example-and-multiple-instances.md) records the confirmed requirements and proposed coordination/testing design. Added NFR-14/NFR-15 and aligned the requirements, roadmap, architecture, compatibility and relevant ADR boundaries. Automated real-host/app tests and cross-instance failure/recovery are first-release acceptance work; no runtime evidence is claimed.

## Remaining design work

Feature status selection does not complete the implementation specification. Recurring-task occurrence identity/completion/series edits, named-zone aliases and matching rules, DST/duration semantics, alarm action/expiry/retry interactions, graph validation, host authorization/trust contracts, booking exclusivity/capacity, deletion policy, package layout and numeric limits still need detailed design. These are retained as explicit work, not silently chosen by cleanup.

## Validation

Check all local Markdown links, table column counts, RFC feature-status vocabulary and implementation disclaimers, stable FR/NFR identifiers and links to ADRs. Confirm removed-artifact links are gone, LICENSE matches Git HEAD and only intended documents changed. There is no application or runtime/client evidence; documentation checks do not establish implementation or conformance.

Current validation: 42 Markdown documents, 325 local links including 35 section anchors, table column counts, 18 consecutive ADR filenames/titles/index entries and all 46 requirement identifiers passed checks. The 336 RFC feature rows and implementation disclaimers are retained. LICENSE matches Git HEAD under normal line-ending normalization; git diff --check passed. No runtime or multi-instance acceptance has been executed.

No runtime or external-client tests were run because no application exists.
