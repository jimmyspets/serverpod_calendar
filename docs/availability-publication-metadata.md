# Native availability publication metadata

[ADR 0060](adr/0060-availability-publication-metadata.md) extends native rule metadata with organizer approval, text parameters and host-validated private extensions. This is decoded native storage/editing, not ICS parsing/export, scheduling, publication or client interoperability.

## Text and parameter association

Definition and opening SUMMARY/DESCRIPTION/LOCATION keep their existing ordinary text and singular cardinality. Optional `textParameters` attaches LANGUAGE/ALTREP separately to each. COMMENT parameters align by position with the complete comment list; each entry can independently contain LANGUAGE/ALTREP or be null. When supplied, that list must have exactly the comment count. The example removes parameters with their comment and preserves them when unrelated text or timing changes. Invalid/orphan annotations reject instead of being silently discarded. To clear an annotated property in the example, clear its parameters too.

One optional `categoryLanguage` annotates the component's native category group; ALTREP is not enabled on CATEGORIES. Categories retain exact text matching, with no language-aware search added in this increment. This native group does not represent all possible repeated wire property groupings. LANGUAGE uses the existing BCP 47 well-formedness validator, preserves spelling and does not verify registry membership, translate text or select UI language.

ALTREP/DIR are absolute ASCII URI metadata, including references such as `cid:notes@example.invalid` or `ldap://example.invalid/people`, limited to 4096 characters. Relative references, spaces, malformed percent escapes and user information reject. No URI is fetched, opened or rendered. Existing definition URL editing retains its separate HTTP/HTTPS-only profile. The module retains ordinary text even when an alternative representation is present.

## Organizer and trusted host approval

Only definitions expose `organizer`: required address URI (up to 1024 characters), optional common name (4096 code points), optional language for that name and optional directory URI. Language without a name rejects. These fields are publication labels, never identity proof, calendar ownership, directory records, resource bookings or an instruction to send invitations. AVAILABLE openings have no organizer field. SENT-BY and scheduling authority are separate work.

Hosts implement `CalendarHostPolicy.approveAvailabilityOrganizer`. Ordinary metadata/create permission and dedicated approval are independently required. Checks run at preliminary/final content writes whenever current or proposed organizer exists, including removal and replacements preserving its address. The host receives trusted actor/scope, actual parent/calendar/definition, current and validated proposed state, retained opening edits, transaction and phase. It can approve against its own address directory without adopting the demo's identity scheme.

Deny returns access denied; unavailable, exceptions and timeout fail closed. No identity, content, revision or scope generation is written before approval. Stale revisions still reject. The method must meet the same declared coordination guarantee as ordinary policy checks, including commit coordination when promised. A final external approval still has an after-check revocation race; see [consistency guarantees](authorization-consistency.md). Retention through occurrence-only actions is not a publication grant; future export/feed/scheduling surfaces must check current authority separately.

The example accepts only `urn:calendar-example:user:<trusted principal>` or clearing. Its button obtains the principal from the authenticated host endpoint. It stores synthetic labels and sends no mail.

## Private extensions

Pass trusted `availabilityExtensions` registrations to `CalendarModule.install`. Each registration has a private `X-` name, a frozen set of allowed definition/opening contexts and a bounded side-effect-free validator of decoded TEXT. A client cannot register a property. Install supports 32 registrations, rejects duplicate names ignoring case, and freezes the registry. The demo registers only `X-CALENDAR-EXAMPLE-LABEL`, a single-line label of at most 256 code points in either context.

Each component accepts up to 32 distinct private names, case-insensitively unique while preserving spelling/order, at most 64 ASCII alphanumeric/hyphen characters per name and 4096 code points per value. Custom parameters and repeated instances of one name are unavailable in this native slice. The full proposal is checked against current registration/context/value rules before a content write; unknown names, wrong contexts and false validation reject atomically, while validator failures return unavailable. Removing a registration does not scrub stored data on reads; it prevents subsequent full-content writes retaining that unsupported extension until explicitly resolved. Occurrence timing actions retain metadata without treating it as behavior.

Registered IANA extensions remain unavailable until individually profiled. These private values have no built-in temporal, identity, permission, scheduling or alarm semantics. Hosts must not use registration to bypass implemented invariants. Existing raw rule authorization covers disclosure; busy/subject summaries contain none of these values. The shared raw metadata limit remains 65536 code points across a definition and its openings, counted before normalization and including all annotations, organizer values and extensions. Nested lists are frozen before host callbacks.

## Storage, example and remaining scope

All fields are nullable additions inside existing JSON content. Older rows decode with absent values, without rewriting content, protocol UIDs, revisions, timestamps or opening edits. Pinned generation and module/host migration checks report no relational schema change. The example edits these fields through existing revision-checked metadata endpoints and preserves them through its timing forms.

CONTACT stays import-preserved only; wire property grouping, parser/export, full protocol stamps/SEQUENCE, envelope duration shorthand, per-occurrence text/future cancellation, feeds and external-client evidence remain pending. See [validation evidence](scaffold-validation.md) and [roadmap](roadmap.md).

Subsequent native scope: [protocol lifecycle and envelope duration](availability-protocol-lifecycle.md) under [ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md) supersedes earlier pending wording for these native values. Wire/source histories, CONTACT and scheduling remain pending.

## Source-preserving storage follow-up

[ADR 0071](adr/0071-create-only-availability-import.md) confirms extending storage for repeated category groups and annotated CONTACT before create-only import. [The proposed contract](availability-import.md) keeps CONTACT read-only through native edits and preserves grouping/annotations without a new native contact editor. This is a future model change, not an implemented extension of the current DTOs.
