# ADR 0004: Secret subscription URLs and combined feeds

Status: **Proposed**. Date: 2026-10-19. Maintainer-required capabilities: read-only iCalendar feeds, multiple revocable long random URLs, ETag support and multi-calendar publication. The concrete policy below is proposed.

## Proposal

Separate Feed, FeedCalendar selection, and FeedUrl credentials. A feed selects one or more calendars; multiple independent URL credentials can publish that selection. A calendar can participate in multiple feeds. Management callers need publish/manage permission for every selected calendar; possession of a URL grants only feed reads.

Generate at least 256 bits of CSPRNG entropy per credential and encode safely for URLs. Use HTTPS; store only a cryptographic digest and non-secret management metadata. Return the full URL at creation only. Lists identify credentials by management ID/label, not the raw secret. Revocation disables one credential; replacement is create-new/revoke-old. No password or browser login is required for GET/HEAD. Use a token-free management ID for revocation.

On every request, validate active token, feed and host publication authority before conditional requests or cached representations. Invalid/revoked credentials receive a generic 404 with no calendar data and no cacheable success. Host integration must invalidate publication when its authority is withdrawn. Proposed policy denies the whole feed on missing/unauthorized selected calendars, pending explicit manager repair; host resolution failure also fails closed.

Generate one deterministic VCALENDAR, preserving stable publication identities across feeds and URLs. Resolve UID and TZID collisions without silently merging unrelated events. Serialize the same committed snapshot used to calculate its ETag. A proposed strong validator hashes the exact representation bytes, with separate handling for content encodings. Stored update metadata must not change just because the feed was fetched.

Implement RFC 9110 If-None-Match semantics for GET/HEAD, including validator lists, weak comparison and wildcard; a successful match returns bodyless 304 with the current ETag. Unchanged output retains its validator. Event/exception edits, deletion, selection, published metadata, zone definitions and serializer changes invalidate it when the representation changes. HEAD mirrors GET status/headers without a body. Access denial always precedes returning 304.

Use `Cache-Control: private, no-cache, max-age=0, must-revalidate` for successful responses and prevent shared proxy/CDN reuse. Redact full bearer URLs/tokens from application, proxy, tracing and analytics logs. Rate-limit requests without assuming one IP per subscriber; cloud calendar services may share IPs. Configure explicit feed size/work limits and fail visibly rather than truncating.

The maintainer subsequently selected the initial HTTP boundaries in [ADR 0016](0016-subscription-http-profile.md): ETag-only validation, HTTP date validators and ranges deferred, fixed ICS media output. ICS LAST-MODIFIED stays independent; actual enabled encoding variants still need correct Vary/ETag handling. The next batch selected feed-adapter If-Match, optional host-declared Content-Language and deferred subscription redirects under ADR 0016; revoked URLs never disclose a replacement. The final batch selected explicit privacy-safe errors and no-store for all errors/denials, with no negative-response caching. Successful responses use the explicit private revalidation policy above; proxy-revalidate and Expires are initially omitted.

## Alternatives and consequences

One URL stored on Calendar cannot independently revoke recipients or model aggregation. Password-based feeds complicate subscription clients. Stateless signed URLs complicate immediate revocation unless backed by revocation state. The proposed opaque credentials require a lookup but provide explicit lifecycle control.

Anyone holding a URL can forward it; user/group membership is not subscriber authentication. Revocation stops future origin access and cannot erase previously downloaded data. Client polling controls refresh timing. These limits must appear in user-facing subscription instructions.

## Multiple-instance consistency

[ADR 0018](0018-automated-example-and-multiple-instances.md) requires token/publication changes to be enforced across active Serverpod instances. A request starting after committed revocation must not reuse stale authority or a warm cached success/304 on another node. Verify consistent representation bytes/ETags for the same snapshot/configuration across nodes; process identity and fetch time must not affect output. Cache/policy coordination mechanisms remain implementation design.

## Acceptance conditions

Review entropy/storage and host publication lifecycle; prove independent revocation with warm caches and If-None-Match. Test multi-calendar authorization, UID/zone conflicts, deterministic output, snapshot races, no shared-cache leakage and token redaction. Pass the required client matrix. See [compatibility](../compatibility.md) and [requirements](../requirements.md).
