# Calendar presentation and decoded protocol text

This batch extends [native CRUD](calendar-crud-implementation.md) under [ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md). It implements native description/RGB color and authenticated editing/storage/disclosure of decoded calendar NAME/DESCRIPTION language variants and RFC-compatible COLOR. It does **not** implement ICS parsing/serialization, feed output or external-client interoperability. URLs, categories, images, refresh hints and other metadata remain following work.

## Independent values

| Value | Meaning and write behavior |
| --- | --- |
| Native displayName | Required UI name, existing 256-code-point/trim rules; duplicates allowed |
| Native description | Optional plain multiline UI text; preserve spacing/newlines; empty/null clears; max 16,384 code points |
| Native color | Optional opaque RGB `#RRGGBB`; accept hex letters in either case, store uppercase; empty/null clears; no alpha/shorthand |
| Protocol names/descriptions | Optional decoded language variants; explicit protocol command only; no native-name/description fallback or automatic synchronization |
| Protocol color | Optional case-insensitive CSS3 section 4.3 color name, preserving supplied spelling; no arbitrary hex, transparent/currentColor or later rebeccapurple |
| Feed presentation | Still owned by the separate optional feed module; not inferred from native or protocol fields |

Text is plain data, never HTML. Nonempty whitespace descriptions remain unchanged. Native labels keep their stronger single-line/trim rules. Protocol TEXT can be empty/multiline and is not restricted to native-label length; raw content-line escaping/folding belongs to a future adapter. CR/LF/TAB are accepted as decoded text; other C0 controls, DEL, malformed Unicode and NUL reject.

## Generated API and models

The generated `client.modules.serverpod_calendar.calendar` adds:

- `updatePresentation(CalendarPresentationUpdateRequest)`: full replacement of native name/description/color with UUID and expected revision. Omitted nullable fields mean cleared, not unchanged. For a name-only update that preserves other fields, keep using `updateMetadata`.
- `updateProtocolMetadata(CalendarProtocolMetadataUpdateRequest)`: full replacement of supported protocol text/color with UUID and expected revision; empty lists/null color clear without inventing defaults.

`CalendarCreateRequest` optionally accepts native description/color. `CalendarView` includes native description/color in `metadata` and nullable protocol metadata in the separate `protocolMetadata` group. Requested-but-denied groups expose no values. A granted protocol group with no stored values returns an object with empty lists/null color; absence is not replaced from native text.

| New model | Contents |
| --- | --- |
| `CalendarPresentationUpdateRequest` | Calendar UUID, expected revision, displayName, nullable description/color; complete native replacement |
| `CalendarTextVariant` | Decoded value plus optional LANGUAGE tag; no raw ICS property or arbitrary parameter bag |
| `CalendarProtocolMetadata` | Required lists of names/descriptions and optional CSS3 color |
| `CalendarProtocolMetadataUpdateRequest` | Calendar UUID, expected revision and complete supported text metadata |

The active data record adds nullable `description`, `color` and typed JSON `protocolMetadata`. Generated migrations preserve existing rows; identity remains the sole revision authority. Empty protocol metadata is stored as null, and all new content disappears with active-payload deletion. No new content enters retained identity markers.

## Authorization and consistency

Native presentation uses `CalendarPermission.updateMetadata`; protocol replacement uses distinct `updateProtocolMetadata`. `CalendarFieldGroup.protocolMetadata` is separate from native `metadata` and availability settings. Hosts can map them together or enforce different rules. Current snapshots include immutable native/protocol data, and validated proposals distinguish name-only edits, complete native replacement and protocol replacement/clearing. The example private-scope policy grants its user's fields/operations and uses policy epoch `private-scope-v2` for the expanded contract.

Both commands validate, resolve actual scope/calendar, authorize, reject stale revisions, perform the configured final check and atomically persist data/revision/scope generation. Protocol writes invalidate existing continuations. Nested client lists/values cannot mutate a validated proposal during policy callbacks. Write permission alone does not disclose returned values; existing nullable mutation-receipt rules apply. `freshCheck` still has the documented after-check race; this batch adds no coordinated host provider.

## Language/text profile

Each names/descriptions list allows at most 16 variants, one per case-insensitive LANGUAGE tag plus at most one unspecified-language variant. Preserve spelling and ordering. No inferred language, locale matching, translation or deprecated-alias canonicalization is performed. LANGUAGE must be a syntactically well-formed BCP47 tag, including private-use/grandfathered forms, at most 255 ASCII characters. This is syntax validation, not IANA-registry/prefix validation; a well-formed unregistered tag can pass. Host policy remains free to narrow accepted language choices. Case-insensitive duplicates reject atomically; aliases are not silently treated as equivalent.

Protocol NAME/DESCRIPTION limits are respectively 4096/16,384 code points per value, with 65,536 aggregate UTF-8 bytes across all values, language tags and protocol color. These are native editing profile bounds, not limits specified universally by RFC 7986. Exceeding a bound rejects without truncating. No transport request-byte cap is implied; hosts still configure ingress limits.

The adapter package exposes immutable `IcalendarTextVariant` and `IcalendarCalendarTextMetadata`, well-formed language validation and the pinned CSS3 name set. It remains free of Serverpod/Flutter. Support for ALTREP, unknown/extension parameters, source UID/update metadata and raw property preservation must be designed before an import adapter accepts such content. No legal imported data is silently dropped by this limited editor; import is still unavailable.

## Example behavior

The example edits native and protocol sections separately. Copy buttons use the current native draft to create/replace only the unspecified-language protocol draft, keeping translations; saving remains explicit. Empty copied text is an explicit empty TEXT variant; remove a variant to represent absence. No RGB approximation or automatic source/feed changes occur. Unsaved drafts in other sections survive a successful section save; explicit reload resets saved values. Access-denied/stale/validation failures are shown without silent overwrite/retry.

See [RFC 7986](https://www.rfc-editor.org/rfc/rfc7986.html), the [CSS3 reference](https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color), [BCP47 syntax](https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1) and [actual validation evidence](scaffold-validation.md). Metadata storage does not prove serialization, ETag behavior or client rendering.

Section saves account for exactly their own revision increment. If the subsequent read observes a different revision, the editor preserves drafts and requires explicit reload before further writes; it never rebases an old draft onto an unrelated concurrent change. A stale-response error also requires reload.
