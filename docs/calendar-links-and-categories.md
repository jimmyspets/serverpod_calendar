# Calendar links, categories, images and refresh hints

This extends [calendar text metadata](calendar-metadata.md) under [ADR 0051](adr/0051-calendar-links-categories-images-refresh.md). It implements authenticated native editing/storage and authorized category filtering. There is no ICS parser/exporter, feed publication, URL fetching, image loading or polling job. SOURCE remains outside native editing; secret feed URLs must never become alternative/publication links.

## Models and API

| Model | Fields / role |
| --- | --- |
| `CalendarCategory` | Exact nonblank single-line text and optional LANGUAGE tag |
| `CalendarCategoryFilter` | Exact text; omitted language matches any, supplied tag matches case-insensitively |
| `CalendarImageLink` | Absolute HTTP/HTTPS URI, nullable DISPLAY token list, optional declared image media type |
| `CalendarRefreshHint` | Nonnegative integer weeks/days/hours/minutes/seconds, defaulting to zero per field; aggregate must be positive |
| `CalendarSupplementalMetadata` | Optional alternative URL, required category/image lists, optional refresh hint |
| `CalendarSupplementalMetadataUpdateRequest` | UUID, expected revision and complete replacement metadata |

`client.modules.serverpod_calendar.calendar.updateSupplementalMetadata(request)` replaces this property set atomically. Null URL/hint and empty lists clear their respective values; all-empty metadata stores null. It does not alter native presentation, protocol text/color, availability settings or associations. The active data row gains a nullable typed JSON column; deleting the active payload removes it without adding content to the minimal identity marker.

`CalendarView.supplementalMetadata` is disclosed through its own group. A granted empty group returns empty lists/null scalar fields; a denied/unrequested group is null. Host `CalendarPermission.updateSupplementalMetadata` is separate from text/native edits. Immutable snapshots/proposals include current and validated proposed data; generated nested lists/refresh objects are frozen before asynchronous policy calls. Existing stale-revision/final-check/receipt rules and data-generation invalidation apply. This adds no stronger external-authorization guarantee.

## Supported editing profile

- URLs/image links: absolute ASCII HTTP/HTTPS, 1–4096 characters, valid URI escapes/components, nonempty host, no user information; explicit port 1–65535. Accepted case/escapes/spelling remain unchanged. Unicode IRIs require an appropriate encoded URI; unsupported schemes reject. No DNS/network/content operation or implicit access grant occurs.
- Categories: up to 64 entries; 1–256-code-point nonblank single-line text, preserving outer/internal spacing and Unicode spelling. No NFC/case-folding. An exact duplicate with the same case-insensitive language tag rejects. Language-tag syntax/255-character limit follows the text profile, without IANA registry validation or alias inference.
- Images: up to 16 URI links; optional declared image/* token type up to 127 characters, without parameters or content inspection. DISPLAY can be absent or contain 1–8 distinct token values (32 characters each). Missing means effective BADGE; preserve recognized/unknown token spelling and order. The immutable helper suppresses rendering if any token is unknown. This example never loads remote images. No binary, ALTREP or arbitrary property parameters are modeled yet.
- Refresh hint: positive whole units within a 365-day equivalent cap; weeks stand alone. Preserve fields, so one day is not rewritten to 24 hours. This cap uses 7-day weeks/24-hour days only for metadata bounding, with no date/time/DST application, background timer or guaranteed client refresh. Values shorter than a day remain hints; hosts/future consumers control throttling and publication policy.
- Aggregate supplemental values: at most 65,536 decoded UTF-8 bytes including language tags, image tokens/media declarations and refresh-unit digits. This is separate from text-metadata limits and does not replace host transport limits.

The URI profile cannot recognize another application's bearer token embedded in arbitrary query/path text. Hosts must validate references and future feed projections to avoid credential disclosure. A valid link or declared media type is not proof of access or safe content. The example shows text controls only; it does not render HTML or dereference links.

## Category queries

The list API adds `categoryFilter: CalendarCategoryFilter?`. Text matching is exact and case-sensitive; an omitted language matches any language, supplied tag matches case-insensitively. No substring, normalization, alias or category-count/discovery API is provided. Tags do not imply host roles, membership, scheduling authority or booked time.

The host receives `CalendarCategoryQuery` on query/object authorization and an optional named `categoryFilter` argument on `planQuery`. Existing host adapters must accept this new argument. The module requests supplemental disclosure for filter evaluation even when the output requests only native metadata. Each result must pass object authorization and supplemental disclosure before matching; the returned view still uses only requested/granted output groups. Visible calendar names cannot be used to probe categories the host has withheld.

This first implementation filters after authorization within the existing bounded scan. Insufficient budget or policy failure is explicit failure, never false exhaustion or free time. A continuation exists only after another authorized matching result is known. No totals or hidden-category placeholders are returned. Data/policy/actor/page/groups and exact filter are bound to a durable opaque cursor; changing or dropping the filter rejects and requires restarting. All calendar mutations invalidate scope continuations as before.

## Example and remaining work

The Flutter example has separate controls for alternative URL, individual category/language values, image link/hints/type and optional refresh units. Saved text/native values and other drafts remain independent. It uses the existing expected-revision/reload guards. Category search takes exact text and optional language; clear both to list all calendars. Starting creation clears the list filter so the new calendar can be found.

Native profile validation lives in the pure iCalendar adapter package, not Serverpod/Flutter. These models do not implement URI/property wire escaping, VALUE=URI/VALUE=DURATION generation, category property grouping, source/private metadata import or deterministic feed bytes/ETags. Those need explicit adapter and publication decisions. See [RFC 7986](https://www.rfc-editor.org/rfc/rfc7986.html), [the ADR](adr/0051-calendar-links-categories-images-refresh.md) and [actual checks](scaffold-validation.md).
