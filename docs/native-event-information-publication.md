# Native event information publication

[Accepted ADR 0182](adr/0182-native-event-information-publication.md) defines outgoing information delivery using `METHOD:PUBLISH`, separate from meeting invitations and HTTP subscription feeds. The example records synthetic MIME only; it sends no real email. This scoped implementation does not establish external-client interoperability or complete scheduling support.

## Explicit actions

`calendarEvent.saveAndPublishInformation` accepts the existing immutable save request and atomically saves validated native content plus durable delivery intent. Ordinary event saves send nothing. `cancelPublishedInformation` publishes a whole cancellation using the last published information values. `reopenPublishedInformation` publishes those retained active values again with a newer outgoing version. Both lifecycle actions preserve newer private draft content and change only the approved native status. Repeated lifecycle cycles are supported.

`informationPublicationStatus` reports the bounded publication identity, method, trusted purpose, local-change flag and delivery outcomes. It exposes no message body. The Flutter event editor opens **Information publication** separately from **Meeting invitations**. Its fixed recipient input becomes read-only after the first publication. Uncertain retries retain the original command and criteria until a successful result or explicit refresh.

Only proven native-created events can establish a binding. DATE, UTC and named-zone single events and recurring masters retain their timing, nominal durations, rule/inclusion/exclusion/PERIOD data and supported metadata. New active publication rejects stored occurrence exceptions, cancellation cutoffs, source attendees, source alarms and conflicting organizer claims. Rejection preserves the stored data. A missing native summary becomes empty outgoing SUMMARY; native storage remains absent. No occurrence information-publication profile is implied.

## Purpose and authority

`CalendarSchedulingBindingPurpose` distinguishes `invitation` and `informationPublication`. The server chooses the purpose through the operation; clients cannot choose or convert it. A fixed organizer and normalized set of 1–64 private delivery routes are established by trusted host resolution. Information recipients are not ATTENDEE properties, directory identities or attendance responses. PUBLISH contains no ATTENDEE. No source address establishes authority.

The independent host permissions are `publishEventInformation`, `cancelEventInformation`, `reopenEventInformation` and `readEventInformationPublication`. Writes also require complete ordinary detail/source access and the applicable native edit/lifecycle rights. Status requires ordinary event read plus its independent read permission. Hosts may map these rights to their own rules.

The immutable scheduling context/intent carries actual purpose, action, current/final native state, retained canonical publication state and the complete outgoing message/digest. `publishedRequest` remains invitation-only. `authorizeMessage` must approve complete information messages at both command phases and actor-free dispatch; organizer/route resolution alone grants no publication permission. Coordinated guarantees cannot silently downgrade, and external checks retain their documented after-check race.

Invitation APIs and participant-reply paths reject information bindings before legacy checkpoint interpretation or fallback. Information APIs reject invitation bindings. Event/calendar deletion still rejects active binding dependencies. No binding retirement, purpose conversion or recipient-change operation is added.

## Versions, storage and delivery

The existing four outbox tables are reused. One nonnullable meeting-purpose column defaults existing bindings to invitation; no event provenance is inferred. Module migration `20261107095329773-information-publication` and example migration `20261107095402700-information-publication` are generated. Upgrade every host/worker with compatible code and migrations before enabling the new operations; mixed old-worker operation is not supported.

A separate flat version-1 information checkpoint stores canonical/outgoing correspondence, the last active canonical/outgoing master and prior version floors in existing bounded string columns. It contains no recursive predecessor history. Readers and workers validate purpose, identities, recipients, kind/method, versions, organizer, no-attendee shape, digests and exact regenerated body correspondence. Invalid proof fails closed. Existing shared quotas and retention limits apply across both purposes.

Native source versions, API revisions, publication IDs and delivery IDs remain separate. Changed publication advances the native revision and outgoing scheduling version; unchanged normalized state is an authorized true no-op. Retained exact retries reauthorize and return their historical receipt without reactivating work or changing later native state. Cancellation/reopening uses conservative version floors. Whole-second protocol stamps remain nondecreasing, independently of raw database lease/expiry time.

Workers reuse scope locks, generation fences, database leases, retries, expiry and ordered pruning. They recheck current source/route/recipient/purpose authority before synthetic submit without fabricating a login. Retries preserve delivery identity and exact calendar/MIME bytes; uncertain acceptance can repeat submission and is not an exactly-once guarantee. Provider acceptance is not recipient receipt or display. Newer publications supersede old unsent work.

The host-only MIME allowlist adds PUBLISH to REQUEST/CANCEL. Deterministic headers, exact UTF-8 calendar bytes, payload limits, synthetic address guards and protection rejection remain. No SMTP, provider trust, real sending, incoming PUBLISH adoption or HTTP-feed behavior follows.

## Validation

Actual commands and results are recorded in [the batch validation record](validation-native-event-information-publication.md). Focused tests cover origin/purpose isolation, permissions/final rollback, three timing profiles, native/source separation, draft-preserving lifecycle, retry/no-op identity, quotas, corrupt proof and worker/MIME behavior. Two-host JWT, competing worker/process-loss, connected Flutter, generated migration and broader checks are separate evidence; pending checks must not be reported as successful.
