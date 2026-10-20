# ADR 0016: Subscription HTTP profile decisions

Status: **Selected scope confirmed; implementation pending**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and first batch decisions

The maintainer selected an ETag-only initial feed profile, deferred byte-range responses and fixed ICS representations. This refines ADR 0004 without changing feed credentials, authorization or native Serverpod API contracts.

| Feature | Selected scope |
| --- | --- |
| Date validators | Defer HTTP Last-Modified, If-Modified-Since and If-Unmodified-Since; retain ETag/If-None-Match |
| Byte ranges | Defer Range, If-Range and Content-Range/206 responses; return normal complete representations or conditional responses |
| Media negotiation | Fixed text/calendar subscription output; no negotiated JSON/XML/alternate calendar format at that URL |

## Protocol boundaries

The feed adapter does not expose a representation modification-date contract initially. Calendar/component LAST-MODIFIED fields remain supported inside ICS and are not automatically an HTTP validator for the composed representation. Do not synthesize an HTTP Last-Modified from fetch time or an arbitrary component timestamp. Date conditions do not drive revalidation in this profile; apply the RFC's unavailable-modification-date handling and verify the selected framework/proxy does not silently introduce date validation.

Ignore range selection and If-Range when ranges are unsupported, while preserving ordinary conditional-request behavior. Do not advertise partial support or emit partial 206/Content-Range output. GET success returns the complete selected representation; HEAD and 304 remain bodyless. Valid credentials/current publication authority are checked before validators or cached output.

The URL serves its fixed ICS media representation, independent of Accept media preferences; no format conversion is added. Native/generated-client interfaces remain separate. This does not select HTTP content-encoding variants or language negotiation. Vary remains applicable to actual enabled variants, not nonexistent media formats. Encoding and validator handling must stay consistent through host infrastructure.

## Second batch: confirmed

| Feature | Selected scope | Boundary |
| --- | --- | --- |
| If-Match | Feed adapter evaluates read preconditions using strong comparison, with 412 when false | GET/HEAD remain read-only; current authority checks precede conditional handling; native revision contracts are independent |
| Content-Language | Optional host-configured intended-audience language metadata | Omit if unspecified; no text inference, translation, format changes or Accept-Language negotiation |
| Redirects / Location | Defer subscription redirects | No automatic replacement-URL, login or cross-origin redirect; revoked URLs fail without exposing new credentials |

Validate entity-tag list/wildcard syntax and RFC precedence, including If-Match versus If-None-Match. Weak tags cannot satisfy strong comparison. Invalid/revoked credentials receive the existing opaque denial, not successful content/304 or a conditional response exposing representation state. Malformed requests use the privacy-safe error policy below; exact malformed-header distinctions remain implementation details.

Validate host-declared language tags and preserve consistent GET/HEAD/conditional response metadata. Do not infer an audience from event text or claim the header lists every language used. Stored per-property LANGUAGE and host Flutter locale remain distinct.

Managers may create new URLs explicitly; revocation does not redirect old tokens to working replacements. Verify framework/proxy routes cannot inject a login/replacement redirect into the selected secret feed contract. This decision concerns subscription-route behavior, not a new general web hosting service.

Test If-Match matches/mismatches/weak tags/lists/wildcards and combined preconditions, authority changes, bodyless HEAD/304 and correct 412 handling, optional/invalid audience tags, no language negotiation and no Location credential disclosure.

## Final batch: confirmed

| Feature | Selected scope |
| --- | --- |
| Error mapping | Explicit privacy-safe failures: 400 malformed requests, 405 unsupported methods, 429 rate limiting, 503 temporary unavailability and generic 500 unexpected failures; retain opaque 404 for invalid/revoked credentials and 412 for failed If-Match |
| Error/denial caching | Cache-Control: no-store on every feed error/denial; prevent negative-response caching |
| Successful-response caching | Cache-Control: private, no-cache, max-age=0, must-revalidate; preserve appropriate metadata on HEAD and 304 |
| Initially omitted cache fields | Defer proxy-revalidate and Expires; shared cache reuse remains prohibited |

Error bodies/headers must not disclose private calendar details, bearer URLs/tokens or internal exception details. Credential failures retain a uniform opaque denial. Failures must not masquerade as an empty successful feed or an unchanged 304. Preserve required HTTP response headers, including Allow on 405, without exposing private state. Exact malformed-header distinctions and configured limits still need implementation specifications.

The cache policy is response-specific: successful feed representations can be stored privately subject to revalidation; every error, including 404 and 412, prohibits storage. Configure host middleware/proxies/CDNs consistently so they do not cache denials or override the private success policy. Authorization/revocation checks still precede successful content or 304. These directives neither erase previously downloaded client data nor determine client polling schedules.

Test each error category and its no-store policy, including malformed requests, unsupported methods, throttling, dependency/serialization failures, credential denials and precondition failures. Verify successful GET/HEAD/304 cache headers, omitted Expires/proxy-revalidate, no shared reuse and no negative caching through configured host infrastructure.

## Alternatives and remaining details

Date fallback, byte ranges and multiple media representations were offered but not selected. The remaining batches resolved If-Match, optional audience-language metadata, deferred redirects, explicit privacy-safe errors and response-specific caching. All listed RFC feature rows now have selected statuses. Exact header limits, stack integration and interoperability evidence still require implementation work.

## Acceptance conditions

Test no HTTP Last-Modified generation, date-only conditions following the selected profile, stable ETags and correct If-None-Match precedence, ignored ranges with full/bodyless status handling, fixed ICS responses under varied Accept headers and authorization/revocation before any successful reuse. Include framework/proxy configuration to prevent implicit range/date/format features from contradicting the profile.

No implementation, complete HTTP-stack conformance or client compatibility is claimed.

Sources: [RFC 9110 date conditions](https://www.rfc-editor.org/rfc/rfc9110.html#section-13.1.3), [ranges](https://www.rfc-editor.org/rfc/rfc9110.html#section-14), [Accept](https://www.rfc-editor.org/rfc/rfc9110.html#section-12.5.1), [RFC 9111 cache directives](https://www.rfc-editor.org/rfc/rfc9111.html#section-5.2.2), [RFC 6585 rate limiting](https://www.rfc-editor.org/rfc/rfc6585.html#section-4).

Traceability: [requirements](../requirements.md), [RFC 9110 matrix](../rfc/rfc-9110.md), [RFC 9111 matrix](../rfc/rfc-9111.md), [ADR 0004](0004-subscription-feeds.md), [HTTP/feed evidence](../roadmap.md#feeds).
