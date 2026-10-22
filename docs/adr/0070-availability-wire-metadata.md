# ADR 0070: Availability wire publication metadata

Status: **Accepted metadata batch, bounded registry and source-group preservation; API/limit mechanics under review**. Date: 2026-10-22.

## Context and maintainer decisions

After [ADR 0069](0069-first-availability-wire-adapter.md), the maintainer selected availability publication metadata before database import: ORGANIZER, URL/CLASS, categories/comments/contact, legal text annotations and private extensions. They explicitly confirmed reusing the bounded native private-property profile through a trusted pure registry and preserving repeated source groups and annotations rather than flattening them into native storage. CONTACT remains source-only. These decisions do not approve imported organizer authority or arbitrary extensions.

Primary sources: [RFC 7953 component grammar](https://www.rfc-editor.org/rfc/rfc7953.html#section-3.1), [RFC 5545 CATEGORIES](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.1.2), [ORGANIZER](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.3) and [CONTACT](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.2). Native organizer approval and private registration remain under [ADR 0060](0060-availability-publication-metadata.md).

## Implementation and consequences

The [wire metadata guide](../icalendar-availability-metadata.md) records exact contexts, types, limits, parameter handling and failure behavior. Preserve immutable typed source groups alongside original components; definition-only organizer/URL/class reject on openings. Timing overrides inherit omissions and reject supplied content differences. Private registry validation is pure and bounded, with unavailable callback failures distinct from rejected values and no private diagnostic leakage. Unknown X-properties and unprofiled IANA extensions reject.

All metadata contributes to a shared calendar-wide decoded code-point budget in addition to existing syntax/recurrence limits. URL/classification/address data has no authority or network side effects. Source serialization does not provide current authorization or registry revalidation. Native import/export must independently validate actual parent, current proposed state, organizer authority, extension policy, preservation and transactional consistency.

Flattening repeated properties loses source grouping and annotations; accepting arbitrary properties implies unsupported semantics. Treating parsed organizer syntax as host approval would cross the authorization boundary. Preserve source data explicitly and keep transport/storage adaptation separate instead.

## Validation and next work

Exercise escaping, groups, repeated parameters, legal contexts, strict limits, immutable registry inputs, callback rejection/unavailability, omission inheritance, content differences and unchanged core composition. Run focused checks during development and broader repository checks at batch completion; record actual results separately. No schema, dependency or generated-file changes are needed. The maintainer selected create-only authenticated availability import next, rejecting existing protocol UIDs; updates/reconciliation remain separately designed. This does not complete RFC 7953, import/export, feed or external-client interoperability.
