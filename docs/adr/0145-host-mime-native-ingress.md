# ADR 0145: Host-owned MIME ingress into existing scheduling handlers

Status: **Accepted by explicit maintainer approval on 2026-10-30 for the complete host MIME invitation/reply bridge batch. Scoped implementation and complete local batch validation are recorded separately.**

## Context and verified boundary

Accepted [ADR 0144](0144-bounded-host-raw-imip-mime.md) extracts bounded original MIME into untrusted calendar data. The example already exposes server-only CalendarModule.receiveSchedulingInvitation and receiveSchedulingReply APIs, backed by independent installed host adapters, transactional final authorization, source/version checks and stable delivery receipts. The former accepts one non-recurring REQUEST or whole-meeting CANCEL; the latter supports the implemented non-recurring/recurring-master/single-instance REPLY profiles. Pure MIME/iTIP parsing supports more methods than either native ingress.

The inspected invitation delivery carrier caps decoded source at 256 KiB; the reply carrier caps it at 512 KiB. Runtime options can lower those limits. The raw parser permits up to 1 MiB of transport and 512 KiB decoded calendar data. Preserve these distinct limits. Existing invitation/reply demo endpoints construct synthetic data and trusted demo origin references on the server after their own checks; they do not accept raw sender proof or arbitrary mail bytes from a client.

## Approved complete batch

Add two example-host-only wrappers in a new imip_ingress.dart source file, named receiveHostImipInvitation and receiveHostImipReply. Each accepts the actual Session, original raw bytes and a required actual outer-protection marker. Invitation calls also require the existing namespace/deliveryKey/originReference metadata. Reply calls additionally require an explicitly host-resolved scopeKey and eventId. Return the respective existing native receipt; add no union routing response, generated model, endpoint signature, table, migration, new dependency or reusable-module MIME import.

Use the approved raw parser first. The invitation wrapper accepts only VEVENT REQUEST/CANCEL; the reply wrapper accepts only VEVENT REPLY. Reject other pure methods, VFREEBUSY, VTODO and route mismatches before invoking a native handler. Apply carrier byte ceilings before construction. Pass the exact decoded calendar bytes into the existing delivery carrier without regenerating VCALENDAR, stripping METHOD, adding fields, deriving identifiers or changing omissions. Native parsing/shape checks remain authoritative, including recurrence/delegation restrictions and configured lower limits; do not bypass them by passing a previously parsed object into private storage code.

The wrappers do not discover a native scope, calendar, event, user or recipient from source UID, addresses or mail headers. The caller supplies server-side delivery metadata from trusted integration context. Those arguments are references for the installed host to verify, never evidence merely because they were provided. Existing host resolveDelivery/authorize and authorizeReply checks continue to inspect the exact parsed source and actual current/publication state, on their existing preliminary/final phases and guarantees. No fabricated authenticated Session, actor, production proof or implicit recipient mapping is introduced. Production sender/provider authentication remains unresolved and outside this batch.

MIME/protection/profile failures remain bounded non-echo host errors. Unsupported wrapper routes reject explicitly. Existing native CalendarException outcomes retain their established validation/authorization/limit behavior; never wrap a denial as a successful receipt or retry another handler. No DB invocation occurs before the complete MIME gate passes. The native transaction still owns receipt/source/review/response atomicity; the wrapper adds no outer transaction, raw-mail archive or second deduplication store.

Delivery identity remains the explicit namespace/key supplied by the host. Message-ID, boundary, human alternatives, From/To and raw transfer encoding do not replace that identity. Retrying different supported MIME framing around identical calendar bytes under the same trusted key follows the existing native retry contract. Conflicting calendar content follows existing conflict checks. A changed MIME envelope is not automatically a new scheduling delivery.

Update only the development/test simulators to compose bounded synthetic MIME and invoke the appropriate wrapper, preserving their public signatures, existing source values, current-user checks, example.invalid restrictions and server-created origin references. Use the already selected enough_mail APIs for synthetic MIME framing; this fixture composition is not real sender verification. Wire relevant invitation/reply process probes through the wrappers so their existing competing-worker/crash assertions cover the bridge. Production raw-mail ingress remains absent.

## Consequences and alternatives

Explicit wrappers keep target resolution separate from source classification and reuse current native contracts. A generic automatic dispatcher would need a separately reviewed routing, lookup and trust contract. Calling storage directly would bypass required native validation and final host checks. Storing raw mail or adding a provider webhook would introduce retention, identity and exposure decisions that are unnecessary for this bounded prerequisite.

Receiving a REQUEST/CANCEL still only changes its authorized private review state; it neither adopts/applies a calendar update nor sends a participation reply. Accepted REPLY handling changes only the existing protected attendee response state. Existing duplicate/stale/version/original-membership rules, drafts and personal alarms remain unchanged. No new scheduling method, RANGE reply, recurring invitation reconciliation, external transport, signature verification or complete RFC 6047 conformance follows.

## Acceptance and validation

Test wrapper route rejection, raw/protected/malformed failures before native effects, exact byte/omission preservation, invitation/reply size asymmetry and lower runtime caps. Verify that forged ordinary headers cannot change the host-resolved target/actor, failed origin checks deny, and final denial rolls back all native writes. Test retained retries across different valid transfer/container encodings, conflicting source under the same delivery key, independent recipient/scope/event targets, expired/stale source and current native recurrence restrictions.

Use actual two-host generated-client simulator calls and process loss before/after invitation/reply commits, preserving stable receipt and native state assertions. Exercise the existing invitation and reply Flutter journeys through their unchanged APIs. Run focused tests during work, then complete root checks before one batch implementation commit. Keep provider trust, receipt/apply separation, synthetic-only status and remaining mail/release requirements explicit in requirements, RFC tables, roadmap and validation records.

## Accepted decision

The maintainer explicitly approved the complete concrete host bridge batch before implementation. See [the scoped implementation guide](../host-imip-ingress.md) and separate validation record. This approval does not add production provider trust, broader native scheduling methods or real delivery.
