# Documentation

The maintainer has specified first-release capabilities in [requirements](requirements.md). The initial workspace/authentication scaffold is documented in the development guide; calendar domain designs remain proposals, with no calendar implementation or client compatibility verified.

| Document | Purpose |
| --- | --- |
| [Discussion migration](discussion-migration.md) | Source evidence, current instructions and remaining gaps |
| [Requirements](requirements.md) | First-release capabilities and acceptance evidence |
| [Resource availability](adr/0006-resource-availability.md) | Proposed resource associations, free/busy semantics and privacy |
| [Alarm and notification boundaries](adr/0009-alarms-and-notification-boundaries.md) | Recommended calendar/notification/Flutter ownership and first-release alarm scope |
| [Architecture](architecture.md) | Module boundaries, proposed relationships and request flows |
| [Temporal core](temporal-core.md) | Implemented UTC-window/date-only foundations, remaining temporal scope and validation |
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
