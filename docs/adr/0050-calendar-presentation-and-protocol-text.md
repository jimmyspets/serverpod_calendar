# ADR 0050: Native presentation and protocol text metadata

Status: **Accepted field separation, color/description rules and batch scope; implementation details under review**. Date: 2026-10-21.

## Maintainer decisions

Keep native description/color separate from protocol metadata, with explicit copy actions instead of silent synchronization. Implement NAME/DESCRIPTION language variants and RFC COLOR first; URLs, categories, images and refresh hints follow later. Native colors accept opaque RGB `#RRGGBB`; protocol colors use the CSS3 names required by RFC 7986. Native descriptions are optional preserved plain multiline text, capped at 16,384 Unicode code points; empty clears, over-limit rejects without truncation.

The existing native-name/UUID/marker and host-authorization decisions remain in force. Native presentation does not become feed metadata or imply permission to publish.

## Source evidence

[RFC 7986 sections 4, 5.1 and 5.2](https://www.rfc-editor.org/rfc/rfc7986.html#section-4) permit optional NAME/DESCRIPTION language variants with one per language. [Section 5.9](https://www.rfc-editor.org/rfc/rfc7986.html#section-5.9) defines COLOR as a case-insensitive name from [CSS Color 3 section 4.3, 2011 recommendation](https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color), rather than arbitrary RGB or later CSS keywords. [BCP 47 / RFC 5646](https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1) distinguishes syntax from registry validity and language matching. These sources establish protocol constraints, not completed wire support.

## Implementation choices

Add nullable native description/color and a typed nullable JSON text-metadata object to active calendar data. Existing rows keep their identity/revision/name/settings and acquire null new fields. Deletion removes all active fields; the marker remains exactly the approved four fields. Generated migrations add nullable columns only.

Native creation optionally sets description/color; a full `updatePresentation` command replaces name/description/color under the existing presentation permission. Null/empty description or color clears that field. The original `updateMetadata` remains name-only and preserves the new fields. Separate `updateProtocolMetadata` permission and `protocolMetadata` disclosure group let hosts independently restrict protocol editing/reading. Both families use trusted object context, stale-revision rejection, final write checks, atomic revision/scope generation updates and independent receipts.

The protocol command atomically replaces all currently supported NAME/DESCRIPTION variants and COLOR. Empty variant lists preserve absence. Decoded values, language spelling and order are retained. Each property permits one unspecified-language value and case-insensitively distinct tagged variants. No language guessing, alias matching, registry download, translation or Unicode normalization occurs. BCP47 well-formedness includes private use/grandfathered forms and rejects duplicate variants/extension singletons; registry validity is not claimed.

Pure protocol validation lives in the iCalendar adapter package, independent of Serverpod/Flutter. It does not parse/serialize ICS, accept arbitrary property parameters or publish a feed. ALTREP, extension parameters and other properties require explicit preservation/schema work before import accepts them; this slice cannot silently discard accepted imported data because import is not present. The current fixed metadata object must evolve before those inputs are enabled.

Use at most 16 variants per property, 4096 code points per protocol NAME, 16,384 per protocol DESCRIPTION, 255 ASCII characters per language tag and 65,536 aggregate UTF-8 bytes including tags/color. These are native editing profile limits, not universal RFC maxima. Plain decoded text preserves CR/LF/TAB and rejects other C0 controls, DEL, malformed Unicode and NUL. Native RGB writes normalize hex letters to uppercase; protocol COLOR preserves accepted spelling/case. Reject alpha/shorthand RGB, CSS4-only colors and unsupported CSS special keywords.

Immutable copies of nested protocol values are made before asynchronous callbacks. Host snapshots/proposals expose immutable values, not ORM/generated mutable lists. Protocol changes invalidate scope cursors even when native presentation is unchanged. Existing coarse database scope locks and explicit authorization guarantees remain unchanged.

## UI and consequences

The Flutter editor has separate native and protocol sections. Explicit copy buttons replace only the unspecified-language draft and preserve translated variants; copying is not saving. Arbitrary RGB is never approximated to a protocol color. Each save refreshes its own fields and the current revision without discarding drafts in other sections; explicit reload discards drafts. Text is displayed as plain text, without HTML rendering or network retrieval. Field visibility follows granted groups; server enforcement remains authoritative.

A single shared description/color would be smaller but overwrite source/publication metadata implicitly. Separate values add UI/API responsibility and require deliberate future export mappings. This batch does not implement calendar UID/LAST-MODIFIED protocol semantics, feeds, images, import/export or external-client rendering.

## Validation

Run focused text/profile tests and database isolation/authorization regressions during development, then batch-end regeneration, analysis, VM/Chrome, migrations, two-host generated-client and Flutter/release checks. Record actual results in [validation evidence](../scaffold-validation.md). The implementation guide is [calendar metadata](../calendar-metadata.md); broader RFC profiles remain planned.

Section saves account for exactly their own revision increment. If the subsequent read observes a different revision, the editor preserves drafts and requires explicit reload before further writes; it never rebases an old draft onto an unrelated concurrent change. A stale-response error also requires reload.
