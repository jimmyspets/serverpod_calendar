# ADR 0033: Bounded DATE-only recurrence sets

Status: **Preserving inclusions before DTSTART explicitly confirmed; DATE-only set/API implementation proposed; broader recurrence contracts remain under review**. Date: 2026-10-20.

## Context and sources

The bounded DATE-only generator handles one rule, but cannot express added or excluded dates. RFC 5545 sections [3.8.5.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.1), [3.8.5.2](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.2) and [3.8.5.3](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5.3) define recurrence exclusions, additions and rules. Set construction removes duplicates, gives exclusions precedence and retains the original DTSTART even if excluded. This increment implements native DATE values only, not wire parsing or full protocol support.

## Confirmed choice and proposed implementation

The maintainer explicitly selected preserving inclusion dates before DTSTART without moving DTSTART or changing RRULE COUNT. This is the selected native policy, not a claim that the RFC mandates that product choice.

`DateRecurrenceSet` retains `start`, an optional `DateRecurrenceRule`, and immutable sorted, duplicate-free inclusion/exclusion lists. Without a rule, DTSTART is the initial member. With a rule, the existing generator validates and generates its dates, including the selected mismatched-start rejection. Merge additions, then subtract exclusions. Excluding DTSTART does not erase its stored identity. COUNT and UNTIL constrain the rule alone: additions can precede DTSTART or follow UNTIL; exclusions never replenish COUNT. All explicit WKST semantics remain those of the supplied rule; native presentation remains ISO Monday-first under ADR 0032.

Construction requires `maxExplicitDates`, a combined raw input-length cap checked before copying or deduplication. Duplicates and out-of-query entries count; zero allows no explicit dates. It is an operation budget, not stored semantic state. Expansion requires three separate positive limits:

- `maxCandidateDays`: rule candidate work, including pre-query history and rejected candidates.
- `maxRuleOccurrences`: raw in-query rule results before exclusions. Excluding results cannot bypass this limit.
- `maxResults`: final unique results after exclusions.

All scalar budgets use the existing portable representation bound, not a recommended production allocation. The host must choose trusted practical caps; no endpoint or client authority over production budgets is introduced. Limit failures throw `RecurrenceLimitException` naming the failed limit, with no partial successful result. Sorted sources are merged without allocating their complete union; input lists and raw rule results remain separately bounded. The closed `from`/`through` query returns immutable sorted unique start dates, not event spans or availability coverage.

## Alternatives and consequences

Rejecting or dropping earlier additions would lose the selected native meaning. Rebasing DTSTART would change identity and rule cadence. Applying COUNT after exclusions would generate replacement dates and alter rule meaning. A single final-output limit would fail to bound excluded rule output or large duplicate input lists, so separate limits are required.

This value is independent of Serverpod and Flutter. Date years remain 0001–9999. Named-zone coverage remains 1900–2037 with potentially narrower per-zone coverage; no guard or main README warning changes. Timed/PERIOD values, moved/cancelled overrides, persistence, authorization, service integration and iCalendar adapters remain pending. The general proposed `RecurrenceSet` model is not replaced by this narrower native value.

## Acceptance and validation

Focused VM/Chrome tests cover earlier additions, union deduplication, exclusion precedence, retained start identity, COUNT/UNTIL independence, query bounds, immutable snapshots/equality, each budget failure, explicit Sunday week-number rules and date-profile boundaries. See [temporal core validation](../temporal-core.md#date-only-recurrence-set-validation) for commands and results. Broader API/representation decisions remain proposed; code evidence is not full RFC or external-client compatibility evidence.
