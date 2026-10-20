# ADR 0040: Complete the bounded native temporal core

Status: **Implementation proposal; batch authorized, APIs and native conflict policies remain reviewable**. Date: 2026-10-20.

Current-profile note: [ADR 0041](0041-whole-second-1970-2100-profile.md) supersedes this record's earlier date-range/precision/zone-envelope choices. Ordinary calendar dates are now 1970 inclusive to 2100 exclusive, with whole seconds and a special exclusive endpoint. The original increment and validation history below is preserved.

## Context and sources

The maintainer asked to finish the temporal core, then stop for questions. This group completes native computation within the selected bounded zone profile. It does not promote the module's planned wire, storage or lifecycle designs to accepted decisions. Earlier accepted precision, Gregorian/ISO, WKST, gap/fold, date-range and duration policies are retained.

RFC 5545 [recurrence](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10), [event durations](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1), [tasks](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.2), [range changes](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.2.13) and [recurrence additions](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.2) inform this implementation. These native APIs do not parse those properties or establish interchange conformance.

## Timed values, recurrence and spans

`TimedValue` explicitly contains UTC or exact named-zone civil fields, resolved instant and pinned version. UTC recurrence values use civil years 0001–9999; standalone `UtcEventSpan`/`UtcWindow` retain their broader existing instant bounds. Zoned values remain 1900–2037 with potentially narrower per-zone coverage. Native microseconds and ordinary seconds are preserved. A bare civil value is not floating-time acceptance. Profile equality retains the exact supplied zone alias; cross-profile native sets/ends/overrides are rejected rather than guessed or canonicalized.

`TimedRecurrenceRule` covers MINUTELY through YEARLY, interval/count or inclusive UTC until, WKST and selected date/hour/minute/position filters. SECONDLY/BYSECOND have no native representation; future adapters must reject them explicitly. Lists are immutable, sorted and deduplicated. RFC legality, including hourly/minutely BYYEARDAY, is checked. Existing DATE matching is extracted and reused, retaining all WKST week-number behavior and ISO presentation independence.

`TimedRecurrenceGenerator` expands complete civil cadence periods, removes generated gaps, applies BYSETPOS, then COUNT/UNTIL and a half-open UTC query. Explicit gap DTSTART uses the selected pre-gap rule and remains an occurrence; later generated gaps are omitted without consuming COUNT. Folds select the first instant. Start alignment remains mandatory. Seconds/fractions come from DTSTART. Each visited date and considered clock candidate consumes shared work, including pre-query history and rejected candidates. Output caps throw without returning partial lists. Sorting uses resolved instant then original civil identity, including distinct original starts that resolve to the same instant around an explicit gap.

`TimedEventSpan` preserves explicit end, nominal duration or omitted-end point. Explicit end and duration are exclusive, endpoints must increase, and duration is positive. Recurrences inherit an explicit end's exact elapsed length; DURATION retains calendar-first units and can vary in elapsed length across DST. Resolved projections preserve later-fold endpoints without re-resolving them. Original templates remain available independently of the UTC projection. `DateEventSpan.occupiedWindowIn` explicitly projects date boundaries in a supplied zone. A wholly skipped date can have empty geometry (null); it remains a DATE value and is never implicitly midnight UTC.

## Sets and edits

`TimedRecurrenceSet` unions start/rule with explicit additions and positive PERIOD additions, then applies exclusions. Earlier additions do not rebase DTSTART or COUNT. PERIOD supplies the complete span at its original identity; conflicting PERIOD forms at one identity are rejected. The supplied master profile is required throughout. These are native policies; an import reconciler must validate component/property contexts independently.

`TimedEventSeries` validates single/range anchors against the effective set in one bounded membership scan. Duplicate, orphan, excluded and same-anchor single/range collisions are rejected. Single cancellation/replacement preserves original identity and is independent of moved-in/out query position. THISANDFUTURE applies an absolute civil-field shift and replacement span from each original anchor, in original order; subsequent changes replace that shift, and separate singles are preserved. Active range timing also applies to base PERIOD instances. Arbitrary pattern edits and range cancellation are outside this timing API. Replacing the complete immutable master is possible; durable whole-series edits remain a service concern.

Queries scan historical original candidates once under shared work/raw-rule/base/final limits. An inverse bound includes future originals moved backwards; zoned offset extrema supply a conservative envelope. This intentionally favors complete-or-failure results over fast unproven skipping. Long histories, large inverse envelopes or complete BYSETPOS periods can exceed budgets/coverage even when the final output is small. Such queries fail explicitly. There is no pagination token, cache or partial-success/free result. Host APIs must select practical budgets and design stable pagination separately.

## Tasks and zone evidence

`DateTaskTiming` and `TimedTaskTiming` permit undated/start-only/due-only forms. DUE and DURATION are exclusive; duration needs DTSTART and positive legal units, and effective DUE follows DTSTART. DATE timing allows day/week units only. Omitted due stays absent; it never inherits an event's one-day or point-occupancy policy. Recurring projections use matching DTSTART and existing recurrence sets, returning original identity plus projected start/due milestones. Explicit timed DUE propagates exact elapsed length, while DURATION remains nominal. PERIOD RDATE is rejected by this task projection profile. Task completion, reopening, per-occurrence status/edit reconciliation and alarms remain task services/model review, not inferred workflows or booking intervals.

`NamedZoneResolver.snapshot` proves every offset segment within a finite UTC horizon, retaining normalized transitions, initial offset, exact zone key and data version. `ZoneRulesSnapshot.matchesOffsets` requires equal horizons and equal offset functions; labels/version strings do not prove equivalence. `matchesDefinition` compares supplied already-expanded evidence with guarded pinned data. A future VTIMEZONE adapter must first validate syntax, observance expansion and coverage; a matching snapshot cannot establish behavior outside its horizon. Custom-zone acceptance is not implemented. Version assertions are separate (`calculatedWith`); changed pinned data requires host-side recalculation of projections/bookings/alarms under reviewed transactions before publishing or executing them. Durable migration/worker coordination is not implemented in this pure package.

The main README's **NOT SAFE AFTER 2037** warning and resolver guards remain unchanged. Replacing/enriching the truncated data is future work before any general all-zone/year claim. Unsupported histories and unknown offsets continue to throw, never silently becoming UTC or free time.

## Alternatives and consequences

Separate UTC and zoned generators would duplicate the selection ordering most likely to drift. Sharing civil selection while requiring explicit profiles preserves their different meanings. Flattening to UTC would lose recurrence identity, nominal-day behavior and alias provenance. Unbounded expansion or silently dropping gaps/unsupported data could create false completeness; all calculations use explicit caller budgets and fail atomically.

No Serverpod/Flutter dependency, parser, schema, migration, service, scheduling, authorization or external-client compatibility is added. Persistent identities/revisions, task lifecycle, range cancellation, protocol rejection/round trips, availability policy, feeds and durable alarms are separate work. Finishing this bounded computation milestone does not finish the calendar module or approve all proposed model contracts.

## Validation

Focused tests cover UTC/zoned cadences, clock/date filters, canonicalization, COUNT/UNTIL, history/caps, WKST, gap/fold/positions, interval overflow, spans/points, PERIOD precedence, moved/cancelled/range identities, shared validation limits, task milestones, snapshots and mismatches. Cross-feature cases include Stockholm, Lord Howe and Apia, explicit gap reordering, 23/25/23.5-hour days, a skipped whole date and distant odd microseconds. Run final formatting/analysis and complete VM/Chrome suites after all changes; record actual results in [temporal core](../temporal-core.md#bounded-temporal-core-completion).
