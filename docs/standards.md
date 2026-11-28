# Standards scope and extension review

The maintainer-approved [ADR 0117 profile](itip-message-profile.md) adds pure PUBLISH/REQUEST/REPLY/CANCEL validation, extended by ADR 0119 with recurring masters and untrusted detached instances and ADR 0120 with ADD/REFRESH/COUNTER/DECLINECOUNTER. A separate [VFREEBUSY adapter](itip-freebusy-profile.md) adds source-only PUBLISH/REQUEST/REPLY under ADR 0121. It does not establish full RFC 5546 conformance, authenticated scheduling transitions or RFC 6047 transport. Unsupported message data rejects explicitly; canonical import/export and subscription profiles remain separate.

Status: **required standards, implementation pending**. Maintainer instruction on 2026-10-19 adds RFC 7953, iTIP and iMIP. Calendar descriptions now target RFC 7986; RFC 9074 now targets a scoped first-release alarm capability; RFCs 9073/9253 now have selected scoped metadata profiles; detailed constraints remain pending, while proximity and arbitrary audio/email actions are deferred. Detailed component/method coverage must be approved and tested before claiming conformance.

| Standard | First-release responsibility | Boundary |
| --- | --- | --- |
| [RFC 5545: iCalendar](https://www.rfc-editor.org/rfc/rfc5545.html) | Events/tasks (VTODO), recurrence/exceptions, zones, scheduling properties and free/busy periods | Full module/interchange profile is separate from the narrower external feed projection; journal scope remains separate; scoped time-based VALARM and native execution are required |
| [RFC 9636: Time Zone Information Format (TZif)](https://www.rfc-editor.org/rfc/rfc9636.html) | Reference for the existing timezone data-generation pipeline | Pinned IANA data/compiler produce bounded TZif; the build extracts 64-bit transitions and encodes package-specific TZF for runtime. This is scoped build-time use, not full RFC conformance or arbitrary TZif import; see [coverage](rfc/rfc-9636.md) |
| [RFC 7986: Calendar Property Extensions](https://www.rfc-editor.org/rfc/rfc7986.html) | Calendar/feed name, description and publication metadata | Planned NAME/DESCRIPTION/UID/LAST-MODIFIED/COLOR plus URL/CATEGORIES/REFRESH-INTERVAL, private imported SOURCE and URI-only calendar IMAGE/DISPLAY under ADR 0014; event/task CONFERENCE, organizer/attendee EMAIL and conference FEATURE/LABEL are also planned; exact contexts/limits remain profile work |
| [RFC 7953: Calendar Availability](https://www.rfc-editor.org/rfc/rfc7953.html) | Store/import/export VAVAILABILITY/AVAILABLE rules and use them when calculating free/busy | Include recurrence, exceptions, priorities and BUSYTYPE; CalDAV-specific transport extensions remain deferred |
| [RFC 5546: iTIP](https://www.rfc-editor.org/rfc/rfc5546.html) | Event scheduling lifecycle and VFREEBUSY scheduling exchanges | Planned event/free-busy method baseline below; component-specific rules apply |
| [RFC 6047: iMIP](https://www.rfc-editor.org/rfc/rfc6047.html) | Outbound and inbound email binding for supported iTIP exchanges | Restricted profile under ADR 0015: component hints supported, S/MIME deferred; no complete RFC 6047 conformance. Host supplies trusted ingress/address authority and delivery; no embedded mail server |
| [RFC 9110: HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html) | Feed GET/HEAD, ETag, If-None-Match and 304 | Read-only fixed ICS profile under ADR 0016; ETag-only validators, HTTP dates/ranges deferred |
| [RFC 9111: HTTP Caching](https://www.rfc-editor.org/rfc/rfc9111.html) | Private feed caching/revalidation and shared-cache protection | ADR 0016: successful responses private, no-cache, max-age=0, must-revalidate; errors/denials no-store with no negative caching; authorization/revocation checked before successful reuse |

Gregorian is the only supported calendar system under [ADR 0013](adr/0013-gregorian-only.md). CALSCALE may specify GREGORIAN or be omitted using its Gregorian default; other systems are explicitly rejected without conversion.

## ISO 8601 week convention

Native calendar week labels and first-day presentation follow ISO 8601: Monday first, week 1 containing January 4 (equivalently, the first Thursday), and a distinct ISO week-year at New Year. This is the selected week convention, not blanket support for all ISO date/time/duration representations. Explicit RFC WKST values must be honored, including their rule-specific week-number calculations; they remain separate from native ISO labels. See [the behavior and examples](week-conventions.md) and [ADR 0032](adr/0032-iso-week-convention.md).

## Property and feature inventories

See the [per-RFC matrices](rfc/README.md): one file per tracked RFC with property or protocol feature, purpose, first-release plan and notes. Scoped native and syntax implementations are recorded in the current guides; full wire semantic/interoperability support remains pending. All formerly Proposed RFC matrix rows are now Yes — planned under [RFC scope](rfc/README.md). All listed feature rows now have selected statuses. Planned features, delegated host/library behavior and deferred protocols remain distinguished; these inventories do not approve unresolved profiles or require the whole model in feeds.

## Native module and feed boundaries

The module provides full calendar, task, free/busy, availability-search and scheduling services to Serverpod projects with Flutter GUIs. External iOS/Google/Outlook feeds need only a declared event-publication subset. Interchange and scheduling coverage are evaluated independently; an external feed client need not expose tasks, rules, search or the full RFC profile. Deliberate output exclusions do not authorize lossy import or deletion of canonical fields. See [ADR 0008](adr/0008-module-clients-tasks-and-search.md).

## Selected extension profiles

| Standard | Relevance | Current status |
| --- | --- | --- |
| [RFC 9073](https://www.rfc-editor.org/rfc/rfc9073.html) | Structured participants, locations and resources; rich event metadata | PARTICIPANT/VLOCATION/VRESOURCE and selected standard type vocabularies planned in native event/task APIs/interchange under ADR 0014; CALENDAR-ADDRESS and URI-only STYLED-DESCRIPTION/STRUCTURED-DATA also planned; ORDER/SCHEMA/FMTTYPE/DERIVED selected with metadata-only and read-only boundaries; bounded RFC nesting and legal shared fields selected; exact allowlists/limits and implementation pending, no blanket RFC commitment |
| [RFC 9074](https://www.rfc-editor.org/rfc/rfc9074.html) | Extended alarms, acknowledgement, snooze and proximity | First-release alarm runtime required; UID/acknowledgement/snooze profile selected in the RFC tables; exact wire/lifecycle constraints pending; proximity/advanced actions deferred |
| [RFC 9253](https://datatracker.ietf.org/doc/html/rfc9253) | Calendar-item relationships, links, concepts and grouping references | CONCEPT/LINK/REFID planned for event/task native APIs/interchange under ADR 0014; LINK UID/URI targets selected and XML-REFERENCE deferred; host-approved LINKREL, link metadata and authorized cross-calendar links selected; legal RELATED-TO targets, group references and FIRST/NEXT ordering also planned; temporal dependency/GAP/general dependency metadata also planned; exact graph/reference/limit policies and implementation remain pending |

See [ADR 0014](adr/0014-rfc-extension-decisions.md) and [profile contracts](roadmap.md#design-contracts). Complete the review before finalizing parser/schema/profile choices; record implement/preserve/reject/defer decisions separately. Only the selected table features are first-release commitments; unlisted legal combinations are not automatically supported. Alarm runtime is now required. [ADR 0009](adr/0009-alarms-and-notification-boundaries.md) proposes scoped time-based semantics and a reusable notification boundary; exact RFC 9074 mappings and advanced features still require review.
## Planned scheduling coverage

| Component | Methods to specify, implement and test |
| --- | --- |
| VEVENT | PUBLISH, REQUEST, REPLY, ADD, CANCEL, REFRESH, COUNTER, DECLINECOUNTER |
| VTODO | Native recurring/non-recurring tasks and standalone RFC 5545 interchange remain required under ADR 0017; all iTIP VTODO methods and inbound/outbound iMIP task mail are deferred under ADR 0011 |
| VFREEBUSY | PUBLISH, REQUEST, REPLY |
| VAVAILABILITY/AVAILABLE | Calendar availability storage/exchange and free/busy calculation under RFC 7953; no invented iTIP method mapping |

RFC 7953 section 6 does not define VAVAILABILITY scheduling messages. Its rules instead inform supported free/busy calculations. Exact method roles, property constraints, delegation/forwarding and unsupported-feature responses require a component-by-component acceptance matrix under [ADR 0007](adr/0007-scheduling-and-email.md). There is no claim of all RFC 5546 component support.

## Validation evidence

Automate selected protocol behavior through the real example host/app and at least two concurrently active Serverpod processes under [ADR 0018](adr/0018-automated-example-and-multiple-instances.md). Include cross-instance feed authority/validator checks and competing scheduling/alarm processing with crash recovery. Deterministic adapter tests complement separately required external-client evidence and the connected notification example.

Use independent RFC fixtures and negative cases, not only serializer round trips. Test RFC 7953 rule precedence and availability/booking composition; scheduling identities, sequence/order and duplicate handling; MIME/calendar METHOD consistency; authenticated inbound address mapping; and durable outbound retries.

The iOS/Google/Outlook subscription matrix is required only for the declared feed subset. Validate full module behavior through server/protocol fixtures and generated-client Flutter journeys. Select scheduling/email client targets separately and record client/account/version, directions and results; being a feed target does not require full scheduling/task UI support. Preserve required server method semantics even when an external client supports less.

CalDAV (RFC 4791), CalDAV Scheduling (RFC 6638), general upstream synchronization and VJOURNAL remain outside the initial profile; VTODO task services/interchange are now in scope; time-based VALARM/native alarm execution and a connected Flutter streaming notification example are now required under [ADR 0020](adr/0020-notification-delivery-scope.md), with detailed trigger/action and RFC 9074 mappings proposed under ADR 0009. Identity directories, mail providers and resource catalogs are host integration boundaries.

[The RFC 6868 parameter encoding update](rfc/rfc-6868.md) is implemented in the bounded [syntax foundation](icalendar-syntax.md) under ADR 0062. It enables no additional calendar properties, vCard/XML adapters, imports, scheduling or publication.

## Typed iCalendar temporal values, 2026-10-22

[ADR 0063](adr/0063-icalendar-temporal-value-codecs.md) adds scoped pure DATE, UTC/named-zone DATE-TIME and DURATION wire-to-core codecs; [the guide](icalendar-temporal-values.md) records strict forms, endpoint gating, exact integer/resource bounds and normalization. Existing temporal policy is unchanged. Complete component/property validation, VTIMEZONE matching, recurrence wire mapping, source-preserving database import, authorized export and HTTP feeds remain pending. Value acceptance alone establishes no domain authorization or client interoperability.

## First standalone event adapter, 2026-10-22

[ADR 0065](adr/0065-first-vevent-wire-adapter.md) and [the profile guide](icalendar-event-adapter.md) implement pure non-recurring VEVENT mapping for DATE/UTC/named-zone spans, basic text/state and source protocol metadata. Supplied VTIMEZONE definitions must match pinned IANA offsets over the full profile plus calculation-only UTC edges; the maintainer selected bounded explicit/yearly observances and validation-only earlier seeds. Accepted source syntax is retained; unsupported components/properties/parameters fail before any semantic result. This supersedes older blanket wire-pending wording only for the documented subset. No database import/identity reconciliation, authorized export, scheduling/alarm activation, HTTP feed or external-client compatibility is claimed.

## Recurring event master wire increment, 2026-10-22

The maintainer selected recurring VEVENT masters next, leaving PERIOD additions and separate occurrence-override components to later batches. [ADR 0066](adr/0066-recurring-vevent-master-adapter.md) and [the guide](icalendar-recurring-masters.md) implement typed RRULE/start-only RDATE/EXDATE mapping, strict grammar/profile/DTSTART checks, retained source and calendar-wide raw/work limits. Canonical core semantics preserve earlier inclusions, EXDATE precedence, COUNT, explicit WKST and DST behavior. Output puts FREQ first without altering retained source. This supersedes older recurrence-wire-pending wording only for the master subset; database import/export, identity reconciliation, scheduling/alarms and HTTP feeds remain pending.

## Scoped PERIOD wire increment, 2026-10-22

[ADR 0067](adr/0067-vevent-period-additions.md) adds pure [timed RDATE PERIOD adaptation](icalendar-recurring-masters.md#period-valued-rdate-additions), preserving exceptional end/duration forms, original identities and bounded rejection semantics. This supersedes older blanket PERIOD-wire-pending notes for that subset only. Native module PERIOD storage, occurrence components, authenticated database import/export, scheduling/alarms and HTTP feeds remain pending; no external-client compatibility follows.

## Scoped occurrence-component increment, 2026-10-22

[ADR 0068](adr/0068-vevent-occurrence-components.md) adds pure [single timing/cancellation and timing-only THISANDFUTURE component adaptation](icalendar-occurrence-components.md) to the existing core, preserving original identities, source metadata and bounded rejection. This is the maintainer-approved next feature batch. The maintainer also confirmed the matching in-file master requirement and omission-based content inheritance with supplied differences rejected; API/limit mechanics remain reviewable. It supersedes older blanket occurrence-wire-pending wording only for this subset; per-occurrence content/future cancellation, authenticated database import/export, scheduling/alarms and feeds remain pending. No external-client compatibility is claimed.

## Scoped availability wire increment, 2026-10-22

The maintainer selected the timing/composition-first slice and positive opening intervals under [ADR 0069](adr/0069-first-availability-wire-adapter.md). [The pure adapter](icalendar-availability-adapter.md) maps standalone VAVAILABILITY/AVAILABLE timing/recurrence/overrides, priority/BUSYTYPE, basic text and source protocol timestamps to bounded core composition inputs. This supersedes older blanket availability-wire-pending wording only for that subset. Rich metadata (including organizer/contact/extensions), authenticated database import/export, host authorization/reconciliation, scheduling/alarms and HTTP publication remain pending; no external-client compatibility follows.

## Availability wire metadata increment, 2026-10-22

[Availability wire publication metadata](icalendar-availability-metadata.md) under [ADR 0070](adr/0070-availability-wire-metadata.md) now validates and preserves organizer, legal URL/class, repeated category/comment/contact groups and bounded trusted private extensions. This supersedes earlier pending/rejection wording only for this pure adapter slice. CONTACT remains source-only; authenticated database import/export, current host approval and feeds remain pending. The next selected import increment is create-only, rejecting existing protocol UIDs; updates/reconciliation remain separate.

## Availability import storage decisions, 2026-10-22

[ADR 0071](adr/0071-create-only-availability-import.md) records confirmed create-only availability import choices: extend storage to preserve the supported wire profile first, detect active UID conflicts within the destination calendar, retain source protocol versions separately from database import time/API revisions, require separate import authority plus per-definition create authority, and keep native opening UUIDs distinct from text protocol UIDs. [The storage/import contract](availability-import.md) proposes models, migration, authorization, atomicity and validation gates. These extensions and the import endpoint remain unimplemented; physical/API mechanics still require review.

## Availability storage prerequisite increment, 2026-10-22

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the storage guide](availability-storage.md) implement source-preserving availability prerequisites: text protocol UIDs with native UUID separation, grouped categories/read-only CONTACT, availability PERIODs, source component versions and data-preserving upgrades. Native edits/calculation enforce the expanded state; pure conversion supplies no host authority or database import. Authenticated create-only import remains the next batch under ADR 0071.


## Durable alarm planning increment, 2026-10-25

[ADR 0112](adr/0112-bounded-durable-alarm-planning.md) now adds [explicit arming, complete rolling plans and guarded durable handoff](durable-alarm-planning.md), with separate background policy, database leases/fences, source/lifecycle checks, stable retry IDs and terminal-history pruning that preserves action state. This supersedes earlier unarmed-only/planner-pending wording for native definitions only. Imported alarms remain unarmed. Native action APIs, reusable notification delivery and connected streaming remain separate requirements; the example delivery port explicitly remains unconnected. First-release alarm requirements are not complete.

## Native alarm actions remain separate from interchange

[ADR 0113](adr/0113-native-alarm-actions.md) adds scoped private acknowledgement/dismiss/reset/snooze commands and activity pages. These commands neither interpret imported ACKNOWLEDGED/SNOOZE as trusted user actions nor publish private state into source exports. Source RFC 9074 preservation, native actions, generic notification delivery and actual client display remain distinct validation boundaries. See [the native contract](native-alarm-actions.md).


## Reusable live notification increment, 2026-10-25

[ADR 0114](adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.


## Timing-only source alarm adoption, 2026-10-25

[ADR 0115](adr/0115-timing-only-source-alarm-adoption.md) implements [explicit master-timing copying](imported-alarm-adoption.md) into new unarmed personal definitions, using current authorized item text. It reuses existing storage without a migration and enforces source-read/adopt/create rights, actual parent revisions and trusted recipients. This supersedes earlier adoption-pending wording only for this bounded flow. Source text/UID/acknowledgement/snooze state stays inert; broader profiles, private exports and release gates remain separate. Full local batch validation passed; see the validation record for exact evidence.

## Optional event-feed increment, 2026-10-25

[ADR 0116](adr/0116-optional-event-subscription-contract.md) records the approved separate module, stable publication UIDs, exclusion of all alarms and four-table/default choices. The [feed guide](http-event-feeds.md) describes scoped management/publication/HTTP implementation and the required whole-host logging guard. This supersedes blanket feed-not-implemented wording only for that bounded profile. Native and authenticated source behavior remain independent; full local batch validation passed and external subscription-client, scheduling and other release gates remain open.

Under [ADR 0122](adr/0122-explicit-native-organizer-publication.md), the maintainer confirmed explicit atomic Save and notify for invitations/updates and native-created organizer meetings first. Ordinary edits remain local; imported meetings require separate adoption. The approved [bounded REQUEST runtime](native-organizer-scheduling.md) implements outbound tables, atomic publication, fresh host checks, fenced delivery and synthetic transport. Broader methods, recurring runtime, inbound reconciliation and RFC 6047 email remain required; no real email is authorized.


Accepted [ADR 0123](adr/0123-explicit-native-organizer-cancellation.md) now adds scoped non-recurring whole-event CANCEL runtime and explicit REQUEST reopening, independent of ordinary local lifecycle edits. This supersedes cancellation-runtime-pending wording only for that profile. Cancellation uses the last published source snapshot and verified fixed recipients; drafts are not sent. It reuses the existing outbox with fresh method-specific authority and fenced retries. Full scheduling state reconciliation, recurring/instance behavior and RFC 6047 mail remain required.


Accepted [ADR 0124](adr/0124-recurring-organizer-masters.md) extends native outgoing REQUEST and whole-series CANCEL to recurring masters without occurrence flattening or new temporal defaults. Native exception data remains canonical and private; its REQUEST component publication rejects until its separate profile. Existing ISO presentation, rule-specific WKST, whole-second dates/zones and bounded full-horizon validation remain unchanged. Complete occurrence/instance/range scheduling, reconciliation and RFC 6047 mail remain required.

Accepted [ADR 0125](adr/0125-scheduling-occurrence-field-projection.md) adds a pure required-field projection prerequisite. Its REQUEST candidates preserve source versions and inheritance; participant claims establish no authority. Durable occurrence versions, resets and publication remain separate work, and the current service remains master-only.

Accepted [ADR 0126](adr/0126-independent-occurrence-publication-versions.md) implements scoped complete REQUEST bundles with independent outgoing occurrence versions, bounded private checkpoints, whole-series cancellation/reopening floors and full-message host checks. Native source versions/inheritance remain separate. Original recurrence identity and source meaning stay intact; application storage policy is not presented as an RFC requirement. Instance reset/CANCEL, inbound reconciliation, mail and external-client evidence remain separate.

Accepted [ADR 0127](adr/0127-retained-occurrence-reset-projections.md) implements bounded retained-original reset projections and v3 checkpoints. Explicit current values/empty optional text replace prior own published values while native absence/inheritance remains canonical. This application profile does not claim remote exception deletion, instance CANCEL or external-client interoperability. Membership, timing-form, work, authority and immutable-retry guarantees remain enforced.

Accepted [ADR 0128](adr/0128-explicit-single-occurrence-cancellation.md) implements minimal detached instance CANCEL with original UID/RECURRENCE-ID, independent version, organizer/fixed attendees and STATUS:CANCELLED, omitting timing/text/alarms. Historical membership, serialized-delivery gating, preserved drafts and v4 storage are application policies. This scoped synthetic runtime does not establish restoration, concurrent partial coordination, real mail or external-client interoperability.

Accepted [ADR 0129](adr/0129-explicit-occurrence-restoration.md) implements the bounded published-value individual-restoration profile with detached REQUEST and independent target versions. Native private timing/text remains unchanged except an exact current cancellation flag; no authority is inferred from source fields. Serialized delivery, v5 history and complete-publication guards are application choices, not blanket iTIP/iMIP or client interoperability claims.

## Retained-cancellation reopening

Accepted ADR 0130 uses permitted REQUEST/EXDATE syntax as an explicit scheduling-publication projection with retained private cancellation provenance. Restoring a masked original changes the complete master REQUEST. This application policy neither changes canonical EXDATE authority nor establishes full RFC/client/mail conformance. See [ADR 0130](adr/0130-preserved-cancellations-reopening.md).

## Authenticated attendee replies

Accepted ADR 0131 applies RFC 5546 SEQUENCE/DTSTAMP ordering with independently optional source values and stale retention. Reply state is separate from event status and participant authority. Source comments/results initiate no mail or retries; RFC 6047 transport and recurring reconciliation remain separate. See [the reply guide](authenticated-attendee-replies.md) and [ADR 0131](adr/0131-first-authenticated-attendee-replies.md).

## Recurring master replies

Accepted [ADR 0132](adr/0132-recurring-master-attendee-replies.md) extends trusted organizer-side REPLY to recurring masters. The runtime resolves the actual master from validated self-contained publication evidence, including partial messages and v6 exclusion masks; it preserves private native drafts, complete host context and source distinctions. Responses describe the whole series, never inferred instance acceptance. Master-changing commits update source inactivity atomically; unchanged master versions retain ordering across occurrence publications. Existing tables/caps are reused with no migration. Generated views add `recurring`; trusted adapters receive the complete published message, selected master and carrier kind. Validation evidence is recorded separately. Instance/range replies, other inbound methods and mail remain required separate work.

## Single-instance replies

Accepted [ADR 0133](adr/0133-single-instance-attendee-replies.md) adds scoped trusted single-instance replies to any validated published original, with effective single/range/master versions and separate target response state. Existing reply tables gain source targetKey/originalStart/targetBasisKey and response targetKey, with a meeting/attendee/target uniqueness index. Legacy rows default to master; an explicit newer Save and notify upgrades legacy publication version profiles. New outgoing components cannot reuse earlier effective versions, range applicability changes advance affected versions, and native inheritance/source versions stay separate. Host contexts identify the exact original, selected component and effective occurrence; no source identity grants authority. Instance queries and private source review remain independently authorized. RANGE replies, broader inbound methods and mail remain separate. Validation evidence is recorded separately.

## Event descriptive fields

Accepted ADR 0134 adds the scoped native/ordinary VEVENT descriptive-field increment: exact decimal coordinates, optional priority and preserved resource groups, with separate editing/disclosure and effective scheduling versions. See [the implementation guide](native-event-descriptive-fields.md) and validation evidence. Resource labels grant no booking or authority; external rendering/mail evidence remains separate.

## Native item text/link metadata

Accepted ADR 0135 adds selected-field native event/task URL, classification, category and comment editors with independent disclosure, retained source groups/baselines and effective outgoing versions. CONTACT remains import-only; category search remains separate. See [the implementation guide](native-item-text-metadata.md) and scoped validation evidence.

Accepted ADR 0136 implements exact native event/task master-category filtering with independent disclosure and cursor binding. This application query does not extend RFC wire grammar, schedule meetings, query busy time or establish external-client rendering/search compatibility. See [the bounded query profile](item-category-search.md).

## Incoming organizer REQUEST review

The confirmed review-first policy keeps receipt separate from calendar adoption and participation. [ADR 0137](adr/0137-trusted-invitation-intake-and-review.md) implements bounded trusted non-recurring intake with source ordering, duplicate receipts and private review. This scoped intake/review runtime applies no calendar mutation and does not establish MIME conformance; recurrence, calendar reconciliation, responses and RFC 6047 mail remain separate required work.

Accepted ADR 0137 implements bounded trusted non-recurring REQUEST intake and private review/dismissal, with separate source access, retained source ordering/receipts and three private tables. Receipt creates no calendar event, booking or reply. See [the implementation and limits](invitation-intake-and-review.md); calendar adoption, updates, recurrence/CANCEL and mail remain separate.


## Explicit invitation calendar adoption

Accepted [ADR 0138](adr/0138-explicit-single-event-invitation-adoption.md) implements explicit Add to calendar with one private stable-link table, atomic imported-origin event/link/review writes, independent source/create/import/link authority and retained retry checks. The maintainer approved the complete model/API/retention batch on 2026-10-29. See [the scoped guide](invitation-calendar-adoption.md) and the separate batch validation record. Adding a local copy sends no participation reply and grants no organizer authority; existing-meeting reconciliation remains separate.


## Explicit linked invitation updates

Accepted [ADR 0139](adr/0139-explicit-linked-invitation-updates.md) implements explicit conflict-protected application of newer linked non-recurring REQUEST sources. One private checkpoint tracks current acceptance and the latest retry result, while the creation receipt stays unchanged. See [the scope, permissions and retry limits](linked-invitation-updates.md) and separate batch validation. Receipt remains review-only; local changes reject replacement and no participation reply is sent.


## Incoming whole-meeting cancellation review

Accepted [ADR 0140](adr/0140-trusted-cancellation-intake-and-review.md) adds scoped trusted non-recurring whole-meeting CANCEL intake/private review, current source-kind storage/DTOs, independent cancellation authority and known-correlation/accepted-version ordering. Receipt leaves native events, baselines/checkpoints, personal alarms and outbound intent unchanged. See [the supported profile and limits](invitation-cancellation-review.md) and separate batch validation; explicit application/reopening follows under accepted ADR 0141 below; attendee removal, recurring intake and mail remain separate.


## Linked cancellation application

Accepted [ADR 0141](adr/0141-explicit-linked-cancellation-application.md) adds explicit clean-baseline cancellation application and later explicit newer REQUEST reopening. The existing checkpoint/latest result now records accepted kind, with legacy REQUEST digests preserved and cancellation actions separated. See [the projection, permissions and retry limits](linked-invitation-cancellation.md) and separate batch validation. Receipt still changes nothing; local changes reject and no participation message is sent.


## Scoped decoded iMIP prerequisite

Accepted [ADR 0142](adr/0142-pure-decoded-imip-calendar-parts.md) implements a pure already-transfer-decoded iMIP calendar-part gate for existing event/free-busy scheduling payloads. It validates MIME method/component/charset, bounded mailto addresses, protection and resource limits without sender authority or side effects. See [the API/profile guide](imip-calendar-parts.md). Whole-email MIME/provider integration, native reconciliation, transport and external evidence remain separate required work; complete RFC 6047 conformance is not claimed.


## Scoped synthetic outbound MIME

Accepted [ADR 0143](adr/0143-synthetic-host-outbound-imip-composition.md) implements example-host-only enough_mail composition for existing authorized REQUEST/CANCEL synthetic deliveries. It preserves exact calendar bytes, uses bounded deterministic UTF-8/base64 MIME and adds a local fixture field. See [the guide](outbound-imip-composition.md). No network delivery, inbound parser, schema or complete RFC 6047 conformance follows; reusable modules remain MIME-provider independent.


## Scoped bounded raw MIME extraction

Accepted [ADR 0144](adr/0144-bounded-host-raw-imip-mime.md) implements host-only bounded raw MIME extraction over the existing library: single/flat alternative shapes, critical-header/parameter guards, selected transfer decoding, protection checks and fixed budgets. See [the profile/API guide](raw-imip-extraction.md). It returns untrusted calendar data only; verified provider ingress/native dispatch, broader MIME/transport and external evidence remain separate. No schema, endpoint, identity inference or real sending is added.


## Scoped MIME-to-native ingress bridge

Accepted [ADR 0145](adr/0145-host-mime-native-ingress.md) implements two example-host wrappers into existing invitation REQUEST/CANCEL and attendee REPLY handlers. Exact decoded bytes, native limits, explicit target/origin references, installed host authorization and native receipt identity are preserved. See [the API/profile guide](host-imip-ingress.md). Production provider/sender verification, broader native lifecycle and real transport remain separate. No table, generated endpoint or new dependency is added.


## Proposed explicit attendee response sending

The maintainer confirmed that Accept/Tentative/Decline responses remain separate from calendar addition/application. [ADR 0146](adr/0146-explicit-private-attendee-responses.md) proposes the complete next non-recurring batch: dedicated host-approved minimal REPLYs, three private state/delivery/attempt tables, exact retries, database-clock ordering, source pins/retention, fenced workers and synthetic MIME/Flutter controls. This storage/workflow is not approved or implemented. Current invitation receipt, ordinary edits, adoption and Apply remain send-free; provider authentication, real transport and broader lifecycle stay separate.
