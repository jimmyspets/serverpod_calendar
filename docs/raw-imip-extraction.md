# Host-owned raw iMIP MIME extraction

Accepted [ADR 0144](adr/0144-bounded-host-raw-imip-mime.md) adds `parseHostImipMime` to the example server, using the already pinned enough_mail 3.0.0 provider library. It returns the existing immutable [decoded calendar part](imip-calendar-parts.md). Successful parsing establishes no sender identity, stored membership or native authority. No database, endpoint, new dependency, archive, response or network transport is added.

```dart
final part = parseHostImipMime(
  completeRawMessageBytes,
  outerProtection: ImipProtection.none, // Actual context, not a source claim.
);
// part is untrusted calendar data. Native ingress requires separate host proof.
```

## Framing and ambiguity

The input must be a complete original raw message with its actual outer protection context. Unknown/signed/encrypted markers reject. Actual protected MIME types reject even when a caller supplies none. The helper cannot prove that a trusted provider did not remove an outer layer beforehand. It neither verifies signatures nor decrypts/strips protection.

Raw length/byte values, header prefixes, names and counts are checked before library copying/unfolding. Public BinaryMimeData framing uses a nonrecursive octet-stream parsing instruction; actual source headers are unchanged and inspected separately. The instruction never becomes the accepted source type. The helper never invokes automatic recursive parsing or parseFromText.

Root MIME-Version:1.0 and Content-Type are explicit. Child Content-Type is explicit; child MIME-Version, if present, must be 1.0. Content-Type, Content-Transfer-Encoding, MIME-Version, From, Date and Message-ID duplicates reject case-insensitively, including empty duplicates. Raw field names/counts must agree with the library's header list, so ignored/merged fields cannot hide ambiguity. Other bounded ordinary headers are opaque; From/To/Reply-To/Sender/Subject/Date/Message-ID do not identify a native actor, route, scope or trusted delivery key.

A strict raw parameter allowlist runs before trusting the library's normalized map. Calendar type permits method/charset/component; human text permits charset; alternative permits boundary. Names must be unique and values simple tokens or unescaped quoted tokens. Quoted boundaries may additionally contain equals. Comments, quoted-pair escapes, extended/continuation aliases and unknown parameters reject. Accepted parameter order/name/value spelling is retained in the calendar carrier. This deliberately narrower grammar is application policy, not a complete MIME parameter parser.

## Selected shapes

Accept a single text/calendar body, or one flat multipart/alternative with one to three leaves: exactly one calendar, optional one text/plain and optional one text/html, in any order. Every leaf is checked; duplicate/unknown parts, nesting, message/rfc822 and binary attachments reject the whole container. Human bytes are bounded/charset-checked but never returned or rendered. No scripts, links, images or Content-ID references are executed/resolved. Filename/presentation headers do not determine calendar type or create file access.

Boundary matching is case-sensitive, with a one-to-70-character ASCII letters/digits/dot/underscore/equals/plus/hyphen subset. Delimiters/closing marker and part count are checked before the library's flat splitter. Preamble/epilogue are inert bounded ASCII presentation. Exactly the one MIME separator CRLF retained by that splitter is removed from each raw leaf; decoded calendar whitespace is never trimmed and a missing calendar CRLF is never invented.

## Transfer decoding and calendar semantics

Support absent/7bit, base64 and quoted-printable. The alternative container itself permits only absent/7bit. Unknown/empty encodings, 8bit and binary reject explicitly. Physical line breaks are CRLF, without inventing a final encoded-wire newline. Raw accepted data is ASCII; non-ASCII text must use the selected transfer encodings and explicit UTF-8 charset.

Base64 is checked for alphabet/whitespace, complete canonical quanta, terminal padding and zero unused bits before the permissive library decoder. Quoted-printable is checked for literal bytes, valid hex escapes and CRLF soft breaks. Its trailing SP/HT transport padding is removed under MIME encoding semantics; encoded =20/=09 remain actual data. Encoded lines after padding handling are at most 76 bytes. Padding scanning is linear, including whitespace-heavy inputs. The checked decoded byte count must match the library result.

Calendar and auxiliary charsets are UTF-8/US-ASCII only; absence requires ASCII. No charset guessing, HTML sniffing or transcoding. Auxiliary malformed UTF-8 rejects. Calendar decoding delegates to the existing strict UTF-8/CRLF/no-BOM and VEVENT/VFREEBUSY scheduling validators, preserving optional versions/timing, exact originals, recurrence, periods and zone validation. Ordinary 1970–2099/whole-second/floating-time rules are unchanged. All eight pure event methods and three pure free/busy methods remain source data; this helper does not implement their native reconciliation.

## Fixed limits and errors

| Resource | First-profile maximum |
| --- | --- |
| Complete raw bytes | 1 MiB |
| Aggregate header blocks / fields | 16 KiB / 64 |
| Field name / parameter name / parameter value | 64 ASCII characters / 64 / 1,024 bytes |
| Raw parameters per type | 16, charged before normalization |
| Physical raw line / line count | 998 bytes excluding CRLF / 16,384 |
| Calendar / each human body after decoding | 512 KiB / 64 KiB |
| MIME structure | One root and at most three non-nested leaves |
| Boundary / each preamble or epilogue | 70 characters / 4 KiB |

These are fixed application limits, not RFC maxima or client-adjustable budgets. Raw caps also bound the library's temporary allocation; decoded caps do not promise zero scratch allocation. Count/grammar checks precede transfer decoding, and no partial result escapes after an invalid later part.

`HostImipMimeException` contains only profile/protection/limitExceeded/calendar/unavailable. Neither nested library errors nor private fragments are echoed. Malformed base64 is rejected before the library can repair it or print decoder diagnostics. Input/returned bytes are defensively copied/frozen through existing carriers.

## Evidence and remaining work

The host unit group covers independent golden decoding vectors, outgoing round trips, all selected methods/kinds, flat orders, boundary framing, hidden duplicate/extended parameters, critical-header duplicates, actual and claimed protection, charset/temporal/zone rules, raw/aggregate/decoded caps, immutable data and no-echo failures. The real worker probe parses composed MIME with this helper and compares its calendar digest with the exact retained payload through independent-host races/crashes. Exact commands/results and broader phases are in [validation](scaffold-validation.md).

Verified provider ingress, native dispatch/intake/reply handling, recipient/sender authority, wider MIME forms/encodings, actual transport and external interoperability remain separate required work. No source header, parser success or MIME Message-ID substitutes for those checks. Reusable modules remain MIME-provider independent.
