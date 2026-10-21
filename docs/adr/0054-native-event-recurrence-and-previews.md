# ADR 0054: Native event recurrence storage and bounded previews

Status: **Accepted batch and explicit-date preservation policy; API/storage/query mechanics proposed for review**. Date: 2026-10-21.

## Context and decisions

The maintainer selected recurrence rule/inclusion/exclusion storage and bounded API/example previews first. Individual occurrence editing and THISANDFUTURE editing follow in a dedicated batch. Pattern replacement preserves existing inclusion/exclusion dates, validates their compatibility with the new timing profile and rejects incompatible changes rather than silently clearing dates.

The independent core already implements the selected recurrence profile under [ADR 0040](0040-bounded-temporal-core-completion.md), with [ADR 0041](0041-whole-second-1970-2100-profile.md) superseding historical precision/range limits. [RFC 5545 recurrence sets](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.3) inform the native behavior; DTOs are not an ICS parser or interoperability evidence. This supersedes ADR 0053's temporary recurrence rejection without changing its lifecycle boundaries.

## Implementation proposal

Store an optional immutable recurrence definition in the existing typed JSON event content: one optional rule, explicit inclusion starts and explicit exclusion starts. Canonicalize supported filter/date lists and freeze collections before host callbacks. Preserve DATE, UTC and exact named-zone profiles. Explicit dates carry their own kind/zone, contain no end/duration, and must match the master exactly. Reject floating times and PERIOD additions in this service increment; core PERIOD support remains available independently. SECONDLY/BYSECOND have no native representation. Do not infer unknown JSON rejection from typed model deserialization.

Full updates retain existing explicit dates by default, even when the new recurrence field is null or its lists empty. Nonempty different lists require explicit replacement intent (`replaceRecurrenceDates=true`). That flag permits deliberate replacement/clearing of both lists under ordinary event edit authorization. The host receives the validated, merged proposal, not an unmerged client view. Changing the master kind/zone with incompatible retained dates rejects transactionally. Removing only the rule does not remove retained additions/exclusions. No single/range override records are added or silently discarded.

One event preview requires both read-event and separate preview authority, timing disclosure on both decisions, actual parent/event snapshots, immutable query context and a matching event revision. Recheck trusted context before returning. DATE uses half-open civil-date bounds; timed uses half-open whole-second UTC bounds, preserving original civil identities and exact zone names. Return complete overlapping spans/point membership without clipping; budget/coverage failures return no partial result or cursor. A preview is not a privacy-filtered calendar search, free/busy result, reservation or scheduling action. Cancellation/transparency do not suppress detail previews.

Trusted fixed caps: 256 raw explicit dates combined, 512 raw rule filter entries, 366 query days, 200000 candidate work, 10000 raw/base occurrences and 500 final results. History before the window counts toward work/base budgets. Unsupported lengths/coverage fail explicitly. A narrower window can still fail on long history. No occurrence materialization, process-local cache, new table/index or unbounded background work is introduced. Existing JSON without recurrence reads as a single event; previous `recurring:false` is obsolete. No SQL schema migration is needed; migration tooling must confirm this.

## Alternatives and consequences

Flattening a series into rows loses original identity and bounded recurrence semantics. Implicitly clearing dates loses data. Requiring explicit list replacement for every pattern edit is error-prone for existing clients. The preservation default plus explicit replacement flag makes clearing deliberate. Per-event complete-or-failure previews avoid inventing chronological pagination guarantees before cross-event query design.

The example edits basic cadence/count/WKST and explicit dates, preserves existing advanced filters/UNTIL through basic edits, and previews saved revisions. ISO display week numbers remain independent of explicit WKST; see [week conventions](../week-conventions.md). Optional summary, UID/revisions, separate lifecycle rights and parent timestamp behavior remain unchanged.

## Validation gates

Exercise DTO canonicalization/start alignment, earlier inclusions/exclusion precedence, generated gaps and nominal DST duration, overlap/point/boundary behavior, explicit budgets, immutable policy context/disclosure, preserved versus explicitly cleared dates, rollback/stale revisions and old JSON. Run focused tests during work; complete broader suites, real generated clients on two hosts and Flutter browser journeys after the batch. Record actual results in [validation](../scaffold-validation.md). No ICS/feed/client conformance or complete recurrence edit lifecycle is claimed.
