# ADR 0048: Native calendar name validation and identity/data row layout

Status: **Accepted native name limit/trim rules and two-row layout; implementation details proposed**. Date: 2026-10-20.

## Context and confirmed instruction

The maintainer selected a 256-Unicode-code-point native name limit, trimming outer whitespace while rejecting blank/multiline values and preserving internal spacing/Unicode spelling, and separate identity/active-data rows. The identity survives deletion under ADR 0047; the term does not select indefinite retention. Marker retention duration remains undecided.

## Decision

Native display names are nonempty, single-line, outer-trimmed and at most 256 code points. Reject over-limit values without truncation. Do not silently case-fold or normalize Unicode spelling. These rules do not constrain imported protocol names/text or change exact zone/host-reference identifiers. Low-level Unicode/line-break/trim implementation, raw request-byte bounds and final error mapping still need tests/review.

Keep the native calendar identity in a small row with UUID, trusted scope, authoritative revision and nullable deletion time; keep active label/settings/metadata/timestamps in a separate row constrained to one active payload per identity. Atomic creation and deletion preserve the selected minimal marker without retaining content, archive or restore behavior. Do not duplicate aggregate revision authority or expose a payload surrogate key as another calendar identity.

[The schema proposal](../calendar-schema.md) defines candidate fields, lifecycle/parent-active checks, access paths and future validation. Exact table/index/key details, metadata normalization, isolation/coordination protocol, generated syntax and retention/purge remain implementation gates. A retained identity foreign key alone cannot prevent writes against deleted calendars.

## Alternatives and consequences

A single scrubbed row needs nullable active fields and can retain content accidentally when deletion misses one. Separate rows add a join and transactional lifecycle but give active data a clear removal boundary. Code-point limits are portable and explicit; they are not the same as visible grapheme counts. Trimming a native label is an explicitly chosen normalization, not permission to rewrite source metadata.

No native label uniqueness rule, locale-sensitive ordering, metadata parser or purge duration is selected here. Official relation documentation establishes feasibility only; actual pinned generation, migration and concurrency behavior remain unverified.

## Acceptance conditions

Verify text boundaries on VM/Chrome, name/protocol separation, generated UUID/one-to-one models, atomic identity/payload creation/removal and one aggregate revision. Test stale updates, active-parent/dependency deletion races and hidden markers on two hosts. Finalize remaining type/index/limit/protocol details before claiming implemented CRUD or schema safety.
