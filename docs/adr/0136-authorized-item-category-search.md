# ADR 0136: Authorized event and task category search

Status: **Proposed. Searchable free-form event/task categories and exact text matching are already selected. The concrete query/disclosure/cursor/API mechanics below require explicit agreement.**

## Context

ADRs 0091/0107 preserve source category groups; accepted ADR 0135 adds native master editing and independent category disclosure. Event/task lists still cannot filter them. Calendar-level category queries under ADR 0051 already require membership disclosure and bind criteria to opaque continuation state. Reuse that bounded pattern rather than inferring permissions or availability from labels.

This increment searches series/item master categories in one actual calendar and trusted host scope. Existing occurrence metadata is either omitted/inherited or explicitly matching, so no occurrence expansion is needed. Multi-category Boolean expressions, full text, cross-calendar search, relationship/directory resolution and booking remain separate.

## Proposed API and matching

Add an optional CalendarCategoryFilter to event/task list service/endpoints, reusing its value and optional language shape. Validate and copy the mutable transport DTO synchronously before awaits into existing immutable IcalendarCategory/CalendarCategoryQuery values. A present filter must be nonblank single-line text up to 256 Unicode code points and a valid optional language tag. Preserve text exactly, including outer/internal spacing and Unicode spelling; do not trim, case-fold, normalize Unicode or split commas. An omitted filter retains existing unfiltered behavior; empty text rejects rather than silently clearing it.

Match exact case-sensitive category text in any master category group. An omitted language matches that text in any language; a supplied tag compares case-insensitively as in the existing category profile, preserving stored source spelling. Duplicate values/groups never duplicate a result. No source label establishes actor, membership, ownership or resource identity. API output remains an authorized page/cursor without totals or occurrence counts.

## Proposed authorization and privacy

For filtered lists, evaluate category disclosure in addition to requested output groups, mirroring ADR 0051. Each candidate must pass ordinary item read authority and disclose the categories group before its membership can qualify it. If category membership is withheld, omit that candidate even if an unfiltered list could show its summary. Response fields still use only the originally requested output groups; internal evaluation does not automatically emit category lists.

Pass the immutable categoryFilter through list/read authorization requests with actual scope/calendar/item/current state. Add the optional named query context to planEventQuery/planTaskQuery, as planQuery already does. Hosts may narrow candidates but cannot replace per-object checks. A host that denies categories cannot use filtered names/pages/cursors to disclose membership. This first profile does not add a weaker membership-only privilege; that would require separate review.

Authorize candidates before applying the predicate. Charge raw scanned candidates before text matching, including denied/nonmatching rows, under existing scan/policy/time budgets. Policy unavailable/errors fail the request; never return a partial page as a successful complete search. No free/busy or reservation conclusion follows from empty detail results.

## Proposed cursor and storage behavior

Reuse CalendarCursorRecord.categoryFilter JSON for event/task continuations, distinguished by the existing eventCalendarId/taskCalendarId and field-group/list-kind fields. No new table/column/index or migration is expected; verify schema stability through the pinned generator. Do not weaken existing calendar/alarm/history/cross-family cursor exclusions.

Bind exact text and language-equivalent criteria alongside actor, scope, actual calendar/list family, output groups, page size, policy revision, data generation, position and expiry. Changing/adding/removing the filter invalidates a continuation; language case alone may remain equivalent under existing _sameCategoryFilter semantics. Criteria must be resupplied on continuation. Metadata edits and permission/data epoch changes retain existing invalidation behavior; never continue a mixed-policy snapshot. Tokens remain random opaque references with existing caps/cleanup and no totals.

Keep bounded ordered scanning/authorized lookahead; no new source index or SQL JSON shortcut is claimed. Scan-budget failure remains explicit and independent of whether hidden labels match. Native/imported/metadata-only task storage yields the same validated master category projection. Marker flags, source participants and private contacts are irrelevant to matching and remain hidden.

## Alternatives and consequences

Requiring the existing categories disclosure avoids adding a weaker membership-only permission: a matching title is itself evidence about a category. A separate search-only privilege could be useful later but needs its own disclosure policy. Scanning bounded authorized candidates reuses current storage and transaction fencing; a new category index would add schema and synchronization work without removing per-object authorization. Group flattening, substring matching and Unicode normalization would change the selected exact-label semantics.

The adapter gains optional named query context and generated endpoints/clients gain an optional filter. Existing policy implementations must adopt the signature together with regenerated clients. This unpublished API change is permitted; mixed-version hosts are not an upgrade guarantee. No mutation, source-version change, feed change or notification follows from a search.

## Example and acceptance

Add one exact category text/language filter and explicit Apply/Clear actions to event/task lists. Changing criteria resets continuation. Explain authorized category membership and that empty results do not describe hidden items or availability. Editors retain grouped labels/annotations; search does not modify them or fetch anything.

Review endpoint/query adapter and cursor-field reuse before implementation. Test exact case/spacing/Unicode/language behavior, duplicates and source/native task representations, independently withheld categories/output groups, hostile mutable input, foreign/missing parents, budget/unavailable failures, cursor criteria/list-family/principal/policy/generation/expiry binding, cross-host continuation and metadata-update races, and connected Flutter Apply/Clear journeys. Regenerate clients/test tools, verify no SQL drift, use focused tests during development and broader checks before one feature-batch commit. Existing unfiltered APIs, busy semantics, feeds, scheduling and CONTACT policy remain unchanged.

This is a documentation-only proposal following completed implementation draft PR #100. Inspection confirms existing calendar-level category matching and categoryFilter cursor storage; it does not prove the proposed item query integration. Open-PR review found the older calendar-level metadata PR #5, with no overlapping event/task category-search implementation. No source model, endpoint, generated file or SQL changes are authorized by merging this proposal alone.
