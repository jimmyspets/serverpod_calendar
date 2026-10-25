# ADR 0116: Optional event-subscription contract and storage

Status: **Separate module, stable publication UIDs and alarm exclusion confirmed; four-table storage and defaults approved; integration mechanics under draft review**. Date: 2026-10-25.

## Confirmed scope

Under ADR 0042, HTTP feeds are a separate optional module. The maintainer confirmed stable event publication UIDs derived from native event UUIDs, unchanged across feeds and credential URLs. Authenticated import/export retains source UIDs. All VALARM components are excluded from the first event-subscription profile, including imported source alarms. This does not remove canonical source alarms or change native personal delivery.

The first profile publishes complete supported VEVENT series from one or more explicitly selected calendars in one trusted host scope. Tasks, raw availability definitions, private alarm state and scheduling messages are excluded. Unsupported or unrepresentable event state rejects the entire response; it must not silently disappear, flatten recurrence or pin inherited occurrence timing. Existing follow-series cancellations/content exceptions without a faithful wire representation therefore remain a publication limitation.

## Proposed calendar publication port

The calendar module exposes a server-only publication transaction/projection port. The feed module never queries calendar tables directly or fabricates an authenticated Session/JWT for a bearer holder. The host supplies a publication-policy adapter that resolves a stored opaque authority reference and checks continuing publication rights, actual selected calendar/event context and complete required field disclosure. The reference is not itself authority. Source ORGANIZER/ATTENDEE addresses are not host identities.

Feed management uses the trusted signed-in host actor/scope and independent manage/publish/credential permissions. Publication checks are independent of ordinary authenticated export. All selected sources must be available and authorized; a denied, missing or incomplete source fails the whole feed. Hosts explicitly declare coordinated or external fresh-check consistency, without a silent downgrade or claim that a final external check eliminates revocation races.

Acquire the existing calendar scope transaction lock first for management and reads, then load feed state and publication policy/source projections in that transaction. Selection changes register calendar-deletion dependencies through a calendar-owned adapter port, using the same lock and transaction. Core installations without feeds keep working. Event edits, selection changes, feed deletion and credential revocation cannot rely on process-local caches or locks. Requests starting after committed revocation must reject on every instance, including conditional requests.

## Approved four-table storage boundary

The maintainer explicitly approved these four storage boundaries, limits and configurable 30-day retention on 2026-10-25. Table sources and generated migrations may now implement this bounded design. All IDs are server-generated UUIDs; no UUID version is required. Foreign keys within the feed module and uniqueness constraints must be generated from approved model sources.

| Record | Proposed fields and constraints |
| --- | --- |
| Feed identity | UUID primary key, trusted scope key, positive API revision, nullable deleted-at UTC. Deletion leaves only these marker fields. |
| Feed active data | Unique feed identity reference; nonempty native management label; explicit feed presentation metadata (separate from calendar labels/imported metadata); stable feed protocol UID; whole-second nondecreasing protocol modification time; opaque host publication-authority reference; fixed supported profile version; creation/update audit times. |
| Feed selection | UUID, feed reference and selected native calendar UUID; unique `(feed, calendar)`. Calendar references are validated through the publication port, not a cross-module table query or database foreign key to core internals. Scope is inherited from the actual feed, never client-claimed. |
| Feed credential | Management UUID, feed reference, unique versioned SHA-256 token digest, optional label, positive revision, creation time and nullable revocation time. No plaintext token, URL, request log, copied event data or provider credential. |

Proposed bounds: 64 active feeds per scope, 16 selected calendars per feed, 16 active URLs and 64 retained credential rows per feed. Lists return complete bounded authorized results with no totals or continuation storage. Creation fails atomically at a bound; no implicit eviction. Feed/credential mutations require expected revisions. Independently revocable credentials do not modify representation bytes merely because a URL is created or revoked.

Proposed cleanup: retain revoked credential rows and deleted feed identity markers for 30 days; make retention host-configurable with explicit documented bounds. Feed deletion atomically removes presentation, authority reference, selections and all credential rows. Cleanup never restores a token. A calendar with an active selection dependency cannot be deleted; removing the feed/selection releases that dependency. No archive/restore or automatic cascade of calendars.

## Proposed representation and HTTP mechanics

Generate event publication UIDs deterministically as `urn:uuid:<canonical-native-event-uuid>`; rewrite matching occurrence UIDs consistently. Source RELATED-TO references remain inert source data until an explicit publication-reference profile exists; reject unrepresentable references rather than implying they identify a different published copy. VTIMEZONE output comes from the pinned generated IANA database. The ordinary supported horizon remains [1970-01-01, 2100-01-01); do not claim recurrence/zone accuracy beyond it or silently add UNTIL to an unbounded rule.

Use at least 32 CSPRNG bytes per opaque credential, URL-safe encoding, digest-only storage and one-time URL disclosure. Build URLs from a trusted configured HTTPS origin, never an incoming Host header. Revocation uses the token-free management UUID. A forwarded URL confers read access until revoked; revocation cannot erase previously downloaded data.

Start without a representation cache. Serialize the same authorized committed snapshot used for the exact-byte strong ETag. Fetch time, process identity, token text and URL count must not change output. GET/HEAD, If-Match strong comparison/412 and If-None-Match weak/list/wildcard handling follow ADR 0016 and RFC 9110 precedence, after credential and publication authorization. Initially use one identity-encoded ICS representation; encoding middleware must not invalidate the validator contract. No HTTP date validators, ranges, redirects or content negotiation are added by this slice.

Successful responses use `private, no-cache, max-age=0, must-revalidate`; errors/denials use `no-store`, with generic invalid/revoked-token 404s and no replacement URL. Size/work/header bounds fail visibly without partial output. Their concrete numeric budgets require implementation review.

## Bearer-path logging boundary

Inspection of the pinned Serverpod SDK found default web sessions use the request URL path as their endpoint and uncaught web exceptions can capture the complete request URI. A feed handler must avoid that URI-derived session, use a token-free internal operation context and contain/redact errors before framework diagnostic reporting. Verify actual captured application/session/error logs; merely omitting an explicit application log is insufficient. Host reverse proxies, traces and analytics also require bearer-path redaction. This is an implementation requirement, not a claim that a safe route already exists.

## Alternatives and acceptance

Keeping source UIDs would merge unrelated copies in subscribers. Including source alarms could publish private/unreviewed reminder state. A single mutable feed row would complicate content scrubbing; stateless credentials would complicate immediate revocation. A publication cache is deferred until invalidation can be proven across instances.

The model/default approval gate is satisfied. Before implementation completion: test optional installation, all management gates/revisions, dependency races, concurrent cap writes, deterministic bytes/UIDs/zones, alarm absence, complete-series rejection, GET/HEAD/conditional precedence, token redaction, two-host revocation before 304, policy withdrawal, instance loss and real Flutter feed management. External Apple/Google/Outlook compatibility remains a separate evidence gate. The scoped implementation/evidence below does not establish first-release or external-client completion.

See [module boundary](0042-optional-http-feed-module.md), [feed policy](0004-subscription-feeds.md), [HTTP profile](0016-subscription-http-profile.md) and [model catalog](../models.md).

## Scoped implementation under review

The approved four-table sources and module/example migrations are generated. The working `serverpod_calendar_feed_server` / `serverpod_calendar_feed_client` package pair is non-publishable; its scaffold does not establish external-client support. The calendar package has no dependency on the feed package. The calendar-owned publication port holds the existing scope lock, validates actual calendar/event membership and performs preliminary/final publication checks without fabricating a bearer user's JWT.

One registered feed dependency provider also observes actual event protocol changes in that transaction. It updates only feeds selecting the changed calendar, using nondecreasing whole-second database time, including event deletion. Native event no-ops and unrelated calendars do not update publication time. Feed settings revisions, credential revisions and publication time remain separate; creating/revoking a URL does not change publication bytes. Installation checks that this exact provider and a sufficient publication-policy guarantee were registered first.

The pinned Relic transport can log the original request path on a response-writing error after the route returns. This was observed in the first real 304 test, whose response framing was corrected. A token-free internal session and handler-level catches alone cannot cover that framework path. The scoped implementation therefore requires `runWithCalendarFeedLogRedaction` around whole-host startup, checks the redaction zone when constructing/serving the route, and suppresses complete console messages containing mounted feed paths, including bounded encoded aliases. Hosts must separately redact proxies, custom logging sinks and tracing. The example has an explicit test-mode-only transport-fault probe; it accesses no module data and is never registered in normal development.

The adapter emits identity-encoded ICS, ETag-only validators, optional host-declared Content-Language and no-transform alongside the selected private revalidation policy. Conditional parsing bounds are 8 KiB, 64 tags/field lines and 32 empty list elements. The total serialized syntax output budget is 1 MiB, also subject to the existing bounded event/component profile; exceeding a budget fails the complete request. HEAD has an empty stream with GET's representation length; 304 has no body or declared content length. SOURCE, tasks, raw rules, all alarms and unprofiled source relationship mappings remain excluded/rejected as declared. No token/full URL is available from credential lists.

Full local batch validation passed: stable copied UIDs/alarm exclusion, management/retention database checks, populated upgrades, independent worker recovery, real two-host conditional/revocation/withdrawal/transport-failure and concurrent cap/settings/selection-delete journeys, the combined Flutter journey and release Web build. See the [validation record](../scaffold-validation.md) for exact commands/counts. External-client and production infrastructure/release gates remain open; integration mechanics remain draft review material.
