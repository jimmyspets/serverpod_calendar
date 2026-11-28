# Event and task category search

Accepted [ADR 0136](adr/0136-authorized-item-category-search.md) adds exact master-category filtering to per-calendar event and task lists. This is a detail query, not an availability, membership, booking or full-text query.

## API and matching

`listEvents` / `listTasks` and generated `calendarEvent.list` / `calendarTask.list` accept optional `categoryFilter: CalendarCategoryFilter(value: ..., language: ...)`. Omit the filter for the ordinary list. Resupply it with every continuation. A present blank/multiline/over-256-code-point value or invalid language tag rejects; values are never trimmed, split, Unicode-normalized or case-folded.

Match exact text in any category group on the item/series master. Outer/internal spacing, commas, Unicode spelling and text case matter. Omitted language matches that text in any language; a supplied language tag compares case-insensitively. Source groups, duplicate values and native metadata-only task state share these matching rules; duplicates never duplicate an item. Occurrence expansion and occurrence-specific metadata search are not performed.

Example: `value: ' Team A ', language: 'sv'` matches the same text in a group tagged `SV`. It does not match `Team A`, ` team a ` or the same text tagged `en`. Omitting language would match either language. No query modifies metadata, protocol versions, feeds or notifications.

## Host authorization and disclosure

Input is validated and copied before the first await. The immutable `CalendarCategoryQuery` accompanies list and per-item read requests, actual trusted scope/calendar/current item context, and optional named `categoryFilter` on `planEventQuery` / `planTaskQuery`. Evaluation groups include categories when filtering. Host policy implementations must adopt these signatures with the regenerated clients; unpublished APIs provide no mixed-version upgrade guarantee.

Each candidate must pass ordinary read authority and disclose `categories` before its label can qualify it. Denied/withheld candidates are omitted even if an unfiltered query could show their titles. The predicate runs only after authorization. Candidate planning can narrow the set but cannot bypass per-item checks. Policy exceptions/unavailability fail the request instead of reporting a successful partial search.

Returned fields still use only the original requested groups intersected with the grant. Requesting summary alone can return matching summaries without category values; internal evaluation does not add categories to the response. Hosts wanting a weaker search-membership-only permission need a separate policy design. Labels never establish actor, scope, ownership or resource identity.

## Continuation and limits

Existing opaque cursor rows retain a copied filter in their existing JSON field; pinned migration generation detects no SQL changes. Continuations bind exact text, language-equivalent criteria, actor/scope, actual calendar/list family, original output groups, page size, policy/data revisions, position and expiry. Adding/removing/changing a filter invalidates a cursor. Language tag case alone is equivalent. Cross-family, foreign-parent/principal, expired and stale continuations reject. Ordinary writes invalidate cursors through the existing scope generation.

Ordered raw candidate scanning, authorization batching/timeouts, lookahead, page/cursor caps and cleanup remain bounded. Charge denied/nonmatching/plan-excluded raw rows before predicate evaluation; an exhausted budget fails explicitly. There are no total counts. There is no new category index or unbounded fallback, and an empty result says nothing about hidden items or free time.

## Example and verification

The event/task list screens provide separate exact category and optional language fields with Apply/Clear. They preserve entered spelling and reset continuation/results when applying new criteria or clearing. Editing the draft criteria alone does not change the currently applied query. Controls are disabled during requests; server validation and stale-cursor errors remain visible.

Focused database tests cover exact text/language/group behavior, imported/native/absent metadata, hidden membership, mutable transport, immutable host context, invalid input, cursor binding/expiry, policy/data epochs, scan limits and unavailable authorization. Real two-host clients exercise continuation, competing metadata writes and stale-cursor fencing; Flutter journeys exercise both list filters and Clear. Batch evidence and any deferred release checks are recorded in [validation](scaffold-validation.md). Boolean/multiple-category, substring, cross-calendar and full-text search remain separate.
