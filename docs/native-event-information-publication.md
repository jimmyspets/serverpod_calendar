# Native event information publication

[Accepted ADR 0182](adr/0182-native-event-information-publication.md) defines outgoing information delivery using `METHOD:PUBLISH`, separate from meeting invitations and HTTP subscription feeds. The example records synthetic MIME only; it sends no real email. This scoped implementation does not establish external-client interoperability or complete scheduling support.

## Explicit actions

`calendarEvent.saveAndPublishInformation` accepts the existing immutable save request and atomically saves validated native content plus durable delivery intent. Ordinary event saves send nothing. `cancelPublishedInformation` publishes a whole cancellation using the last published information values. `reopenPublishedInformation` publishes those retained active values again with a newer outgoing version. Both lifecycle actions preserve newer private draft content and change only the approved native status. Repeated lifecycle cycles are supported.

`informationPublicationStatus` reports the bounded publication identity, method, trusted purpose, local-change flag and delivery outcomes. It exposes no message body. The Flutter event editor opens **Information publication** separately from **Meeting invitations**. Its fixed recipient input becomes read-only after the first publication. Uncertain retries retain the original command and criteria until a successful result or explicit refresh.

Only proven native-created events can establish a binding. DATE, UTC and named-zone single events, recurring masters and faithfully representable timing/content exceptions retain their timing, nominal durations, rule/inclusion/exclusion/PERIOD data and supported metadata. Under [accepted ADR 0184](adr/0184-event-information-occurrence-publication.md), publication supports explicit single timing/content and timing-only THISANDFUTURE components. It rejects individual cancellations, future cutoffs, source attendees, source alarms and conflicting organizer claims. Rejection preserves the stored data. A missing native summary becomes empty outgoing SUMMARY; native storage remains absent. A first content-only exception that follows series timing is rejected rather than silently pinning timing.

## Purpose and authority

`CalendarSchedulingBindingPurpose` distinguishes `invitation` and `informationPublication`. The server chooses the purpose through the operation; clients cannot choose or convert it. A fixed organizer and normalized set of 1–64 private delivery routes are established by trusted host resolution. Information recipients are not ATTENDEE properties, directory identities or attendance responses. PUBLISH contains no ATTENDEE. No source address establishes authority.

The independent host permissions are `publishEventInformation`, `cancelEventInformation`, `reopenEventInformation` and `readEventInformationPublication`. Writes also require complete ordinary detail/source access and the applicable native edit/lifecycle rights. Status requires ordinary event read plus its independent read permission. Hosts may map these rights to their own rules.

The immutable scheduling context/intent carries actual purpose, action, current/final native state, retained canonical publication state and the complete outgoing message/digest. `publishedRequest` remains invitation-only. `authorizeMessage` must approve complete information messages at both command phases and actor-free dispatch; organizer/route resolution alone grants no publication permission. Coordinated guarantees cannot silently downgrade, and external checks retain their documented after-check race.

Invitation APIs and participant-reply paths reject information bindings before legacy checkpoint interpretation or fallback. Information APIs reject invitation bindings. Event/calendar deletion still rejects active binding dependencies. No binding retirement, purpose conversion or recipient-change operation is added.

## Versions, storage and delivery

The existing four outbox tables are reused. One nonnullable meeting-purpose column defaults existing bindings to invitation; no event provenance is inferred. Module migration `20261107095329773-information-publication` and example migration `20261107095402700-information-publication` are generated. Upgrade every host/worker with compatible code and migrations before enabling the new operations; mixed old-worker operation is not supported.

Flat version-2 information checkpoints retain canonical/outgoing correspondence, the last complete active canonical/outgoing packet, prior lifecycle floors and typed projectionOriginals in existing bounded string columns. Existing per-component outgoing protocol state is the sole stored version vector. Strict version-1 reads/retries/dispatch remain; only a changed explicit command writes version 2. It contains no recursive predecessor history. Readers and workers validate purpose, identities, recipients, kind/method, versions, organizer, no-attendee shape, digests and exact regenerated body correspondence. Invalid proof fails closed. Existing shared quotas and retention limits apply across both purposes.

Native source versions, API revisions, publication IDs and delivery IDs remain separate. Changed publication advances the native revision and outgoing scheduling version; unchanged normalized state is an authorized true no-op. Retained exact retries reauthorize and return their historical receipt without reactivating work or changing later native state. Cancellation/reopening uses conservative version floors. Whole-second protocol stamps remain nondecreasing, independently of raw database lease/expiry time.

Workers reuse scope locks, generation fences, database leases, retries, expiry and ordered pruning. They recheck current source/route/recipient/purpose authority before synthetic submit without fabricating a login. Retries preserve delivery identity and exact calendar/MIME bytes; uncertain acceptance can repeat submission and is not an exactly-once guarantee. Provider acceptance is not recipient receipt or display. Newer publications supersede old unsent work.

The host-only MIME allowlist adds PUBLISH to REQUEST/CANCEL. Deterministic headers, exact UTF-8 calendar bytes, payload limits, synthetic address guards and protection rejection remain. No SMTP, provider trust, real sending or HTTP-feed behavior follows. The independent incoming master workflow still rejects occurrence-component packets.

## Validation

Actual commands and results are recorded in [the batch validation record](validation-native-event-information-publication.md). Focused tests cover origin/purpose isolation, permissions/final rollback, three timing profiles, native/source separation, draft-preserving lifecycle, retry/no-op identity, quotas, corrupt proof and worker/MIME behavior. Two-host JWT, competing worker/process-loss, connected Flutter, generated migration and broader checks are separate evidence; pending checks must not be reported as successful.

## Occurrence and reset profile (ADR 0184)

The pure `projectIcalendarPublishFields` projects required SUMMARY (including empty text) and organizer claims without adding attendees, allocating versions or establishing authority. Complete host approval remains mandatory. DATE/UTC/named-zone originals, single/future kind, recurrence/PERIOD membership and end/duration meaning stay exact.

Outgoing components have independent versions. Effective inherited text changes are significant; unchanged emitted components retain SEQUENCE/DTSTAMP. Preserved source CREATED/LAST-MODIFIED remain emitted content: a changed native LAST-MODIFIED is an observable master change even if its title/timing did not change. Native source versions, API revisions and outgoing versions stay separate. Whole cancellation advances the master above every retained component; reopening retains unchanged child versions and published values while preserving private drafts.

After a published timing exception is cleared, its original/kind remains in the publication ledger. Later explicit publications project its current series values, including empty optional TEXT to clear old own values. This creates no native timing override and does not claim to delete a remote exception. Orphan/profile/kind collisions and exhausted capacity reject atomically. At most 64 emitted/retained originals plus the master fit under unchanged byte/recipient/delivery limits and one shared validation/projection work budget. Exact immutable proof validation may be reused inside a transaction; authorization and worker state are never cached.

All hosts/workers must understand v2 before enabling component publication. No new SQL/generated API field/migration follows. Individual/range information cancellation, incoming component reconciliation and new unrepresentable follow-series content-only publication remain separate work. Actual results: [occurrence validation](validation-information-occurrence-publication.md).
