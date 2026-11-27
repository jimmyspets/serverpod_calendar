# ADR 0047: Native calendar names, UUID identity and deletion storage

Status: **Accepted separate native label, server-generated UUID without version mandate and minimal deletion marker; remaining storage details proposed**. Date: 2026-10-20.

## Context and confirmed instruction

Following ADR 0046, the maintainer selected a native display label separate from preserved imported iCalendar NAME metadata. They selected server-generated UUID calendar identities and explicitly stated that a specific UUID version is unnecessary. They also selected a minimal deletion marker containing only UUID, scope, revision and deletion time, without calendar label/content or archive/restore behavior. Retention duration remains separate. These decisions refine native naming, identity and deletion retention, not the full physical schema or protocol parser.

## Decision

Keep native `displayName`, calendar protocol NAME metadata and optional feed presentation metadata separate with explicit change paths. Native rename/import does not implicitly rewrite another name namespace. A nonempty native label does not make NAME mandatory in ICS or invent a missing property on round trip. Feed metadata remains feed-owned; no implicit rename synchronization or publication fallback is selected.

Use immutable server-generated UUIDs for native calendar identities, without a client-visible version requirement. Clients cannot choose calendar IDs on create; referenced IDs still require trusted scope/parent lookup and authorization. Source/publication UIDs, recurrence identities, host references and bearer credentials remain distinct. Calendar label uniqueness and UUID-as-primary-key versus other physical details are not approved by choosing the public identity format.

The [storage proposal](../calendar-storage.md) gives active fields, name/identity boundaries and source/toolchain evidence. Local pinned UUID serialization/database support and official guides establish feasibility, not calendar-generation or database test results. After dependency-safe deletion, atomically remove calendar content and retain only the selected minimal marker; ordinary APIs hide it and IDs are never reused. Markers do not grant permission or define a sync protocol. Exact active/payload/marker layout, retention/purge and authorized retry/receipt handling remain implementation gates.

Schema refinement: [ADR 0048](0048-calendar-name-validation-and-row-layout.md) selects 256-code-point trimmed/nonempty/single-line native names and identity/active-data rows. It resolves those choices without approving final keys/indexes, low-level validation, coordination or indefinite marker retention.

## Alternatives and consequences

A single shared native/protocol name can let imports silently rename a UI calendar and complicates legal missing/multilingual metadata. Separate roles add explicit mappings but avoid accidental synchronization. Numeric API identifiers are compact but reveal ordering; server-generated UUIDs supply opaque stable references without becoming access credentials. Requiring one UUID version would add a constraint the maintainer does not need.

Exact name limits/normalization, collation, primary-key/index layout and metadata field normalization remain schema review gates. This does not select IDs for every other model or implement iCalendar/HTTP projection.

## Acceptance conditions

Review physical storage/retention and generate with the pinned toolchain. Test name separation, server UUID generation/serialization, scope/parent isolation, stable identities/revisions and two-host CRUD. Later adapters independently verify missing/multilingual NAME preservation, distinct source/publication UIDs and explicit feed-owned metadata changes.
