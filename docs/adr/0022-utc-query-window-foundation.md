# ADR 0022: UTC query-window foundation

Status: **Proposed implementation; locally verified foundation only**. Date: 2026-10-19. The maintainer requested continued implementation after the scaffold. This record narrows the first temporal increment; it does not accept the entire model catalog or remaining temporal/storage proposals.

## Context

The model catalog already specifies a `UtcWindow` with finite, increasing UTC bounds and half-open query semantics. Date-only representations, civil precision, named-zone matching/upgrades, recurrence and task lifecycle still have review gates. Those policies are not needed to implement interval operations on explicit UTC instants.

## Implementation

Add an immutable, framework-independent `UtcWindow` to `serverpod_calendar_core`. Construction requires explicit UTC `DateTime` bounds and `end > start`; invalid input throws `ArgumentError`. Membership includes start and excludes end. Adjacent windows do not overlap; intersection returns the shared positive window or null. Equality/hashing use both bounds. Duration reports elapsed UTC time, not nominal calendar days/weeks.

Reject local `DateTime` input instead of silently converting it. Do not add event-time serialization, date-only conversion, zone interpretation or generated transport/storage classes. Finite bounds do not select an endpoint's maximum query horizon or expansion budget. An interval alone says nothing about authorization, availability coverage or whether time is free.

## Alternatives

Using pairs of unrestricted `DateTime` values everywhere permits local, empty or reversed bounds and inconsistent end handling. A general calendar span would require the unresolved date-only, named-zone and duration policies. Implementing a small UTC primitive keeps those remaining choices separate and reviewable.

## Consequences and acceptance

Core consumers get consistent interval operations without Serverpod, Flutter or runtime timezone dependencies. Tests exercise leap-day rollover at microsecond precision, invalid/local bounds, half-open membership, disjoint/adjacent/partial/contained/equal intersections and value equality/hashing. The local check script includes core unit tests. This does not establish event CRUD, recurrence, DST correctness, free/busy, interoperability or persistence behavior.

See [temporal core and validation](../temporal-core.md), the [model catalog](../models.md#shared-temporal-and-identity-values), [FR-04/FR-05](../requirements.md), [ADR 0002](0002-compatibility-and-time.md) and [ADR 0019](0019-model-contracts.md). Keep the architecture PR draft; material remaining contracts still require maintainer review.
