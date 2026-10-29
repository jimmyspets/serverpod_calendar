# Pure decoded iMIP calendar parts

Accepted [ADR 0142](adr/0142-pure-decoded-imip-calendar-parts.md) adds a pure adapter in `serverpod_calendar_icalendar`. It accepts one already transfer-decoded `text/calendar` part for the existing VEVENT eight-method and VFREEBUSY PUBLISH/REQUEST/REPLY profiles. It does not process a whole email or establish sender authority. This is a restricted iMIP-compatible prerequisite, not complete RFC 6047 conformance.

## API and source preservation

`ImipDecodedPart` freezes media type, ordered `ImipParameter` name/value pairs, decoded body bytes and required `ImipProtection`. The host MIME library/provider supplies decoded parameters and actual outer protection context. Preserve the original calendar bytes; do not normalize line endings or transcode through a String. Parameter lists expose duplicate case variants; a Map that erased duplicates is insufficient input.

`parseImipCalendarPart` returns an immutable `ImipCalendarPart` containing that source and exactly one of `eventMessage` or `freeBusyMessage`. The `component` and `method` getters describe validated payloads. Existing independent timing/version omissions, detached identities, recurrence, periods and full-horizon zone checks remain unchanged. Ordinary file import remains separate. Unsupported/mixed primary components, VTODO scheduling and unknown calendar data reject explicitly. VTIMEZONE is not the primary MIME component hint.

`serializeImipSchedulingMessage` and `serializeImipFreeBusyMessage` take existing typed payloads and a required `requireProtection` choice. They serialize with the existing calendar codec, then revalidate the complete mail profile under caller budgets. Output has canonical `text/calendar` metadata with explicit UTF-8, method and component parameters. It contains decoded bytes, never email headers, transfer encoding, multipart boundaries or deliverable mail. Retained source syntax/omissions and normalized codec output are distinct from exact original-email preservation.

```dart
final decoded = ImipDecodedPart(
  mediaType: 'text/calendar',
  parameters: const [
    ImipParameter('method', 'REQUEST'),
    ImipParameter('charset', 'UTF-8'),
  ],
  body: decodedCalendarBytes,
  protection: ImipProtection.none,
);
final accepted = parseImipCalendarPart(decoded);
final output = serializeImipSchedulingMessage(
  accepted.eventMessage!, // This example expects a validated VEVENT.
  requireProtection: false,
);
```

## MIME, addresses and protection

Type, method and component use ASCII case-insensitive comparisons. Exactly one method must match the calendar METHOD; optional component must match actual VEVENT/VFREEBUSY. Duplicate parameter names, unknown parameters, controls, whitespace-bearing/empty tokens and unsupported charsets reject. UTF-8 is accepted explicitly. Missing charset or US-ASCII requires entirely ASCII bytes. Existing strict UTF-8, CRLF and no-BOM rules apply after transfer decoding; nothing repairs input silently.

The mail-specific ORGANIZER/ATTENDEE and SENT-BY/DELEGATED-TO/DELEGATED-FROM values require a single ASCII mailto mailbox. The local part consists of nonempty dot-separated RFC atom characters; domain labels are ASCII alphanumeric/hyphen, at most 63 characters each and 253 overall, with no leading/trailing hyphen. Percent escapes decode exactly once for validation; supplied URI spelling is preserved. URI query/fragment, malformed escapes, controls, multiple mailboxes, quoted local parts, domain literals and non-ASCII mailbox strings reject. ASCII punycode domains are accepted without conversion or DNS lookup. Unicode display text remains supported with UTF-8. These are stricter application limits, not a complete email-address implementation.

General calendar URI metadata, directory/alternative/attachment links and source membership metadata stay inert. They do not become delivery routes or host identities. Calendar addresses and MIME hints grant no organizer, attendee, delegation or native mutation authority.

Signed, encrypted and unknown outer protection reject; `requireProtection: true` rejects output. A host must inspect actual outer MIME context and never strip protection or mislabel extracted inner bytes. No signing, verification, encryption, decryption or plaintext downgrade is implemented.

## Budgets and errors

Default body size is 256 KiB; configurable hard ceiling is 1 MiB. Default parameter count is 16; hard ceiling is 64. Names are at most 64 ASCII token characters; decoded values at most 1,024 UTF-8 bytes. Every mailbox URI is bounded to 2,048 ASCII bytes before percent decoding. Raw count/size checks precede carrier copying or normalization; all source duplicates count. Invalid byte integers reject rather than truncate.

Parsing rechecks lower caller budgets. Syntax output is capped by the smaller syntax/body limit; component/recurrence/zone budgets remain those of the existing validators, with no widening. Serialization revalidates under the same supplied budgets. `ImipPartException` contains only an `ImipPartError` code; nested calendar/decoder diagnostics and private source values are not echoed. Invalid trusted limit configuration raises an argument error.

The host gateway must separately bound whole raw messages, MIME decoding allocations and aggregate parts before constructing a carrier. This API is not a multipart selector, header parser, transfer decoder, Content-ID resolver or complete source-document store.

## Validation and remaining work

Focused VM/Chrome coverage includes all selected methods/kinds, omissions, Unicode/ASCII, duplicates and ambiguity, malformed bytes/line endings, exact mailto spelling/rejections, all participant components/delegates, recurrence/zones, shared budgets, immutable carriers, output revalidation and protection rejection. Actual commands/results and broader checks are recorded in [validation](scaffold-validation.md).

Complete evaluated MIME/provider integration, raw message/part selection and encoding, trusted origin and role checks, durable routing/reconciliation, synthetic transport journeys, remaining participant lifecycle and external mail/calendar evidence remain required. No native storage/schema/endpoint, alarm action, notification, automatic response or real sending follows from part acceptance.
