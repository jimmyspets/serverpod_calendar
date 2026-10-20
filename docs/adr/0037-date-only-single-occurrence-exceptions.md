# ADR 0037: DATE-only single-occurrence exception batch

Status: **Batch scope authorized by the maintainer; native implementation/policy details proposed for review; timed/range/task and service contracts remain pending**. Date: 2026-10-20.

## Context and source boundary

The maintainer authorized a batch covering original occurrence identity, cancellation/replacement of one DATE-only occurrence, correct overlap queries and bounded invalid-target rejection. The batch follows [ADR 0036](0036-date-event-series-overlap.md). It is checked in only after the whole group and its broader validation are complete.

RFC 5545 [section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) identifies a modified instance using its original start, even when its actual start changes. The native values below preserve that distinction within one series context. This is not a globally scoped UID/RECURRENCE-ID key, wire representation or scheduling reconciliation implementation.

## Values and native target policy

- `DateEventException.cancel(originalStart)` removes one occurrence.
- `DateEventException.replace(originalStart, replacement)` supplies a complete validated `DateEventSpan`, including its new start and explicit-end/duration/default form. It is not a sparse field patch.
- `DateEventOccurrence(originalStart, span)` exposes original identity separately from effective bounds. Equal actual dates do not collapse different original identities.
- `DateEventExceptionSet` binds an immutable `DateEventSeries` to immutable exceptions sorted by original start. Structural equality excludes operation budgets.

Reject duplicate targets, even identical duplicates, rather than choosing a last writer. Require every original target to belong to the effective native recurrence set: DTSTART/RRULE/RDATE after EXDATE. This conservative native policy rejects excluded targets, starts outside COUNT/UNTIL unless independently included, and nonexistent rule dates. Earlier RDATE additions are valid targets; a replacement itself can move before DTSTART or beyond UNTIL without altering the rule. Never revive an excluded occurrence. These are scoped native implementation policies, not assertions that all external master/exception combinations follow the same encoding. Future adapters must reconcile supported imported forms explicitly or reject atomically; none exists here.

Construction first validates scalar budgets and checks raw input length against `maxExceptions` before copying/sorting. Zero permits no exceptions. Other budgets must be positive. After duplicate rejection, validate all targets in one recurrence expansion from the earliest to the latest target. Shared `maxValidationCandidateDays`, `maxValidationRuleOccurrences` and `maxValidationResults` bound history, raw output and selected dates respectively, including intervening dates. Never reset a budget per target. Return no object on invalid target or limit failure; exception names identify the corresponding validation budget. No endpoint permits untrusted clients to select trusted practical limits.

## Correct overlap with exceptions

`expandOverlapping(from, until, ...)` accepts the existing nonempty half-open DATE query. Use the uniform template lookback only for base starts, then suppress every exception target before constructing a base span. This allows a cancellation or valid complete replacement to remove a base endpoint that would otherwise overflow the selected date profile. An unsuppressed overflowing base still fails the entire query.

Independently inspect every bounded replacement span for overlap, regardless of its original date or template length. This finds occurrences moved into the query, removes those moved out, and includes unchanged-start replacements whose longer span reaches the query. Replacements are already validated spans; no clipping or changed length inference is needed. Cancelled entries produce no result and never replenish rule COUNT.

Return immutable complete occurrences sorted by actual start, then original start for deterministic ties. Distinct original dates remain separate even if moved onto a natural occurrence or another replacement. Within a series, identify an occurrence by its original date, not its list position or new start.

## Query limits and failures

Require positive `maxCandidateDays`, `maxRuleOccurrences`, `maxBaseOccurrences` and `maxResults`. Raw/work budgets retain their existing widened-range/history meaning. `maxBaseOccurrences` bounds selected base starts after EXDATE but before exception suppression; cancellations cannot bypass it. `maxResults` bounds final base/replacement output after suppression. Replacement scan cost is bounded by the constructor's raw exception cap. Constructor validation and query execution have separate explicitly named budgets; immutable values do not need per-query membership revalidation.

Failures throw with no partial successful list. A successful empty result is only this series/date calculation, not complete free/busy coverage. No UTC or named-zone calculation is introduced. Years remain 0001–9999 for dates and effective span ends; named-zone coverage remains 1900–2037 with potentially narrower per-zone coverage. The main README warning is unchanged.

## Alternatives and consequences

Applying exceptions after materializing all base spans would unnecessarily fail on an overridden invalid endpoint. Limiting replacements to base lookback would lose moved-in or lengthened occurrences. Deduplicating actual start dates would destroy original identities. Validating targets independently would allow aggregate work to exceed intended limits. The selected bounded validation can reject widely separated targets until the host supplies adequate practical budgets; it never guesses that an unvalidated target exists.

This batch leaves the no-exception `DateEventSeries` API intact and shares only internal template arithmetic. Timed/PERIOD recurrence, THISANDFUTURE, task lifecycle, sparse descriptive patches, persisted/global keys, revisions, authorization, bookings/alarms, parser/export, iTIP/mail and full availability remain pending. No schema, generated client or migration changes are approved or made.

## Validation and acceptance

Run focused VM tests during the group: five identity/value tests, then the new exception-set tests plus directly affected series regressions. At batch completion run the complete core VM/Chrome suite, formatting and workspace analysis once; record actual commands, failures and results in [temporal core validation](../temporal-core.md#date-only-exception-batch-validation). Independent finite occupied-date enumeration checks movement, length changes, cancellations, identity and ordering. Other cases exercise membership, EXDATE conflicts, shared validation/query budgets, duplicate rejection, immutable collections, profile edges and WKST/ISO separation. Broader server/database/browser journeys remain separate because no such consumer changes.
