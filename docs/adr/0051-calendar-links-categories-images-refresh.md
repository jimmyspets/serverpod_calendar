# ADR 0051: Calendar links, categories, images and refresh hints

Status: **Accepted URI/category/refresh boundaries; implementation mechanics under review**. Date: 2026-10-21.

## Confirmed scope and evidence

The maintainer selected an initial absolute HTTP/HTTPS URL/image profile without embedded usernames/passwords, exact case-sensitive category matching with optional language tags, and positive whole-second refresh durations preserving units with a one-year native editing cap. Links are stored without fetching or automatically loading images; a refresh hint does not start polling. This follows the selected RFC 7986 profile in ADR 0014 and the separate native/protocol boundaries in ADRs 0047/0050.

[RFC 7986](https://www.rfc-editor.org/rfc/rfc7986.html) sections 5.5–5.10 and 6.1 distinguish alternative URL, categories, positive DURATION refresh hints, URI images and multi-valued DISPLAY hints. Missing DISPLAY defaults to BADGE; unknown tokens require suppressing image display, rather than substituting BADGE. Wire required parameters, imported SOURCE privacy and raw property preservation remain future adapter work, not implemented by decoded native editing.

## Implemented choices

Keep this property set in a separate nullable typed `CalendarSupplementalMetadata` JSON field on active calendar data. The name is an API grouping, not arbitrary extension storage. The original text-metadata command remains scoped to NAME/DESCRIPTION/COLOR and cannot clear these new fields. Add independent `updateSupplementalMetadata` permission and `supplementalMetadata` disclosure group. Host policies receive actual calendar identity plus immutable current/proposed values. Full replacement, clearing, expected revisions, final authorization, independent receipts and scope-generation invalidation follow the existing service contract.

The native URI profile is ASCII, absolute HTTP/HTTPS, at most 4096 characters, with a nonempty authority, valid escapes/components, no user-info delimiter, and explicit ports 1–65535 when present. Retain accepted spelling, escapes, query and fragment; do not normalize or resolve hosts. Other schemes/IRIs need an explicit profile later. This is a narrower editing profile than all legal RFC URIs. It cannot itself identify secret bearer URLs in arbitrary link values; the host must reject inappropriate/private publication references. No URI is access authority or permission to dereference it.

Categories preserve nonblank single-line text up to 256 code points plus an optional well-formed language tag under ADR 0050. Allow 64 entries; reject duplicate exact-text/case-insensitive-language tuples without trimming, case-folding text or normalizing Unicode. Category search matches exact text; omitted query language means any language, supplied language matches tags case-insensitively. No membership, ownership, label inheritance, directory or availability contribution follows from a category.

Allow 16 image links with optional image/* media-type tokens (127 characters, no parameter list) and nullable DISPLAY token lists. Omitted DISPLAY stays absent with an effective BADGE default; an explicitly empty list rejects. Allow up to eight distinct case-insensitive ASCII tokens, 32 characters each, preserving case/order. Known standard hints may guide future rendering; any unknown token makes the whole image non-renderable in the helper. The example renders no remote image, even with known hints. Binary images, ALTREP and arbitrary parameters are not accepted in this slice. No content sniffing or media-type truth/registry check is claimed.

Refresh hint fields retain weeks/days/hours/minutes/seconds. Zero/negative input rejects; weeks cannot mix with other units. The selected one-year cap is implemented as a **365-day (31,536,000-second) equivalent bound**, with seven-day weeks and 24-hour days used only to bound metadata size. It is not zoned duration application or a poll scheduler. PT24H and P1D remain different native unit records. No fractions, years or months are accepted.

A separate 65,536-byte decoded-value budget covers this property set, including categories/tags, links, image hints/media types and refresh-unit digits. These count/string/byte bounds are native editing limits, not universal RFC maxima or transport ingress limits.

## Authorized category queries and cursors

Extend the bounded calendar list with an optional typed exact category filter. The host sees immutable filter context in query authorization, candidate planning and per-object reads. Category matching occurs only after an object read is allowed and the host grants the supplemental group for that filtering purpose. Returned views still contain only the groups the caller requested. A caller without category disclosure cannot probe private category membership through ordinary visible calendar names, counts or continuation handles.

The initial implementation scans the existing bounded candidate stream and applies matching after authorization; it has no category index, fuzzy search or global label discovery. Keep no-total pages and lookahead for another authorized match. Scan/authority failures fail the whole operation; lists never establish free time. Durable cursors now bind exact text and case-insensitive query language alongside the existing actor/scope/query/policy/data/expiry bindings. A changed filter rejects; omission is not a wildcard for an existing cursor. Old unfiltered cursors gain null filter fields in migration. The expanded demo policy uses epoch v3.

## Consequences and validation

Separate JSON storage and method/group boundaries preserve older text/native commands without silently clearing new fields. Coarse scope locks remain the data boundary across hosts; external fresh-check authorization retains its documented revocation race. Future parser/feed work must preserve accepted legal parameters and apply deliberate output/credential policies, not infer conformance from these models.

The example edits this property set separately, preserves other drafts and applies the existing stale/reload safeguards. Category filtering can be cleared; creation returns to an unfiltered list. [The guide](../calendar-links-and-categories.md) records exact models and limits. Validate pure profiles on VM/Chrome, atomic/denied/stale/nested writes and filtered privacy/cursors, populated upgrades, two hosts and Flutter journeys before completion. Actual results belong in [validation evidence](../scaffold-validation.md).
