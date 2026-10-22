# Documentation

The maintainer has specified first-release capabilities in [requirements](requirements.md). The workspace/authentication scaffold and scoped native calendar CRUD/metadata increments have local implementation evidence. Broader domain designs remain proposals; pure wire adapters are limited to the explicitly documented profile and no external-client compatibility is claimed.

| Document | Purpose |
| --- | --- |
| [Discussion migration](discussion-migration.md) | Source evidence, current instructions and remaining gaps |
| [Timezone data](timezone-data.md) | Whole-second range limits, future-rule generation and database update/recalculation procedure |
| [Requirements](requirements.md) | First-release capabilities and acceptance evidence |
| [Calendar schema](calendar-schema.md) | Selected native name validation and identity/active-data layout; proposed fields and transactional invariants |
| [Calendar storage](calendar-storage.md) | Separate native/protocol names, UUID identity, minimal deletion markers and proposed physical layout |
| [Calendar CRUD contract](calendar-crud-contract.md) | Confirmed creation/deletion rules and proposed first native command/view batch |
| [Authorization interfaces](authorization-adapter-contract.md) | Concrete proposals for context resolution, batch decisions, queries and commit guards |
| [Authorization consistency](authorization-consistency.md) | Declared coordinated/external guarantees, revocation races and proposed transaction/retry handling |
| [Authorized queries](authorization-queries.md) | Separate detail/free-busy results, field groups, no-total pages and proposed filtering/cursors |
| [Authorization operations](authorization-operations.md) | Proposed action/target matrix, confirmed permission separations and composition examples |
| [Host authorization](host-authorization.md) | Host-supplied rules, module enforcement and trusted collection/object/change context |
| [Resource availability](adr/0006-resource-availability.md) | Proposed resource associations, free/busy semantics and privacy |
| [Alarm and notification boundaries](adr/0009-alarms-and-notification-boundaries.md) | Recommended calendar/notification/Flutter ownership and first-release alarm scope |
| [Architecture](architecture.md) | Module boundaries, proposed relationships and request flows |
| [ISO weeks and recurrence WKST](week-conventions.md) | Confirmed native ISO presentation, explicit RFC week starts and week-number examples |
| [Temporal core](temporal-core.md) | Implemented temporal foundations and bounded named-zone resolver, remaining temporal scope and validation |
| [Model catalog](models.md) | Proposed fields, relationships, storage/API boundaries, invariants and requirement coverage for all model areas |
| [Local development](development.md) | Pinned workspace, local setup/run/check commands and example boundaries |
| [Scaffold validation](scaffold-validation.md) | Commands actually run and limits of the initial milestone evidence |
| [Scaffolding plan](scaffolding-plan.md) | Confirmed walkthrough choices, installed-tool evidence and the first buildable milestone |
| [Compatibility](compatibility.md) | Full module/interchange profiles, subset feeds and independent scheduling evidence |
| [Standards scope](standards.md) | First-release RFCs, considered extensions and component/method boundaries |
| [RFC property coverage](rfc/README.md) | Latest feature-scope source: per-RFC properties, purpose, planned support and detailed constraints |
| [Automated tests and multiple instances](adr/0018-automated-example-and-multiple-instances.md) | Example host/app acceptance and concurrent Serverpod-instance requirements |
| [Roadmap](roadmap.md) | Delivery work packages, dependencies and acceptance checks |
| [ADRs](adr/README.md) | Confirmed scope selections, rationale and proposed implementation details |
| [Documentation review](documentation-review.md) | Removed obsolete artifacts, reconciled conflicts and remaining design work |

Use the RFC tables as the latest feature-scope source when older narratives conflict; explicit newer maintainer instructions take precedence. The migration note records source limitations and is not a transcript. Requirements use stable identifiers so issues and tests can trace back to them.

## Diagram convention

Use Mermaid for documentation diagrams, including architecture, relationships, and request flows. Store diagram source directly in Markdown fenced code blocks labeled `mermaid` so it can be reviewed alongside the text. Keep diagrams consistent with the accompanying documentation and clearly label proposed designs.

- [First native calendar CRUD implementation and host integration](calendar-crud-implementation.md)

- [Calendar native presentation and scoped protocol text metadata](calendar-metadata.md)

- [Calendar links, categories, images and refresh hints](calendar-links-and-categories.md)

See [native protocol UID and modification time](calendar-protocol-identity.md) for the read-only identity/time increment under ADR 0052.

See [first native non-recurring events](native-single-events.md) for typed timing, separate lifecycle permissions, event storage and example behavior under ADR 0053.

See [native recurrence and occurrence previews](native-event-recurrence.md) for the next event increment under ADR 0054.

See [native occurrence timing editing](native-occurrence-timing.md) for single/future timing changes and single cancellation/restoration under ADR 0055.

See [per-calendar free/busy](calendar-free-busy.md) for the first bounded booking/fallback calculation under ADR 0056, with broader search scope still pending.

See [native working hours](native-working-hours.md) for scoped rule CRUD, recurring openings and integrated per-calendar composition under ADR 0057.

See [person/resource availability and common-free search](subject-availability-search.md) for host-resolved contributors, independent summary authority, bounded modes and unknown coverage under ADR 0058.

See [opening-occurrence edits and scoped availability metadata](availability-occurrences-and-metadata.md) for original-identity timing/skip/restore controls, exact categories and legal metadata contexts under ADR 0059.

See [native availability organizer, text parameters and private extensions](availability-publication-metadata.md) for scoped native editing and independent host approval under ADR 0060; interchange remains pending.

See [native availability versions, timestamps and envelope duration](availability-protocol-lifecycle.md) for ADR 0061, legacy baselines and unchanged-save behavior.

See [bounded iCalendar syntax foundations](icalendar-syntax.md) for strict input, immutable syntax, separate escaping and serialization limits under ADR 0062.

See [typed temporal wire values](icalendar-temporal-values.md) and [the first standalone VEVENT/VTIMEZONE adapter](icalendar-event-adapter.md) for the ADR 0063/0065 pure adaptation increments; authorized import/export and feeds remain pending.

See [recurring VEVENT masters](icalendar-recurring-masters.md) for ADR 0066 rule/set mapping, source/output normalization and shared candidate-work limits.

See [PERIOD-valued event additions](icalendar-recurring-masters.md#period-valued-rdate-additions) for ADR 0067 timed exceptional spans and their native-storage boundary.

See [occurrence timing and cancellation components](icalendar-occurrence-components.md) for ADR 0068 grouped master/override source-to-core adaptation and its proposed snapshot/inheritance profile.
