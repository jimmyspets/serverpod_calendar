# Module interfaces and interoperability profiles

[First native non-recurring event CRUD](native-single-events.md) now implements scoped event storage/commands/projections under [ADR 0053](adr/0053-first-native-single-events.md). Native recurrence, occurrence timing, free/busy and scoped working-hours composition are implemented in the increments linked below; wire/client interoperability remains pending.

[Native protocol UID and modification time](calendar-protocol-identity.md) add read-only identity/time disclosure under [ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md), without parsing/export or feed validators.

Native metadata includes [links, categories, images and refresh hints](calendar-links-and-categories.md) under [ADR 0051](adr/0051-calendar-links-categories-images-refresh.md), including authorized exact category filtering; wire/feed interoperability remains pending.


The basic CRUD slice now also has [native presentation and scoped protocol text metadata](calendar-metadata.md) under [ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md). This adds no wire/feed-client interoperability.


**Current implementation:** the first native calendar CRUD/association slice is described in [the implementation guide](calendar-crud-implementation.md) and [ADR 0049](adr/0049-first-calendar-crud-implementation.md). Broader model/interface proposals below remain future design unless explicitly covered there; this adds no iCalendar/feed-client compatibility.


Status: **basic native calendar CRUD/presentation and decoded protocol text have scoped local evidence; wire interoperability remains unimplemented/unverified**. Initial host authentication and module diagnostic wiring have separate [scaffold evidence](scaffold-validation.md). The main product is a Serverpod module with generated Dart APIs used by host Flutter GUIs. External calendar feeds need only a documented subset. Their client limitations do not restrict canonical calendar/task/scheduling/availability capabilities.

The baseline features formerly marked Proposed in the RFC matrices are now Yes — planned by maintainer instruction; see [RFC scope](rfc/README.md). This includes scoped UID/acknowledgement/snooze and DISPLAY alarm behavior, event/free-busy method baselines, calendar UID/update/color and the documented HTTP validation/caching policy. Detailed combinations and evidence remain pending; deferred rows retain their scope; the subsequent walkthrough resolved all listed Undecided rows.

The subscription HTTP profile in [ADR 0016](adr/0016-subscription-http-profile.md) initially uses ETag validators only, defers HTTP date validators and byte ranges, and serves fixed ICS media output. Test varied Accept/date/range inputs without changing ordinary GET/HEAD/304 or revocation behavior; calendar LAST-MODIFIED fields remain supported separately. Feed-adapter If-Match uses strong comparison/412 with RFC precedence after authorization; Content-Language is optional host-declared audience metadata, and subscription redirects are deferred. Explicit privacy-safe errors retain opaque credential 404 and If-Match 412; all errors/denials use no-store and prohibit negative caching. Successful responses use Cache-Control: private, no-cache, max-age=0, must-revalidate, omitting proxy-revalidate/Expires. Verify this through host infrastructure; failures never masquerade as empty success or 304.

Native calendar week labels and first-day presentation use ISO 8601/Monday under [ADR 0032](adr/0032-iso-week-convention.md). Explicit RFC WKST recurrence semantics are separate; the maintainer confirmed honoring every explicit value, including its rule-specific week numbers. See [the behavior and examples](week-conventions.md). This does not claim an implemented calendar GUI.

Current native date/precision profile: **[1970-01-01, 2100-01-01)** and **whole seconds**, with explicit exclusive endpoints and necessary UTC spillover only. [ADR 0041](adr/0041-whole-second-1970-2100-profile.md) supersedes the historical microsecond, broad-date and 2037 evidence below. Generated timezone data calculates the supported future horizon; see [limits and updates](timezone-data.md). This is native calculation evidence, not ICS or external-client verification.

Host authorization boundary is selected under [ADR 0043](adr/0043-host-authorization-context.md): host-defined policy receives trusted collection/object context; modules enforce it. The basic calendar slice implements scoped policy/disclosure/query/mutation integration under ADRs 0049/0050; other domain families remain pending. Diagnostic smoke tests alone do not establish the domain contract. See [the authorization guide](host-authorization.md).

Native query response choices are selected in [ADR 0044](adr/0044-authorized-query-projections-and-pagination.md): separate detail/free-busy, predefined field groups and no-total initial pages. Basic calendar policy/projection/cursor behavior is implemented under ADR 0049; event/task/free-busy queries remain pending; this does not change wire/feed-client support.

[ADR 0045](adr/0045-authorization-consistency-guarantees.md) selects support for declared coordinated/external authorization guarantees without automatic downgrade. No concrete domain transaction/revocation protocol, remote provider integration or consistency evidence exists yet. Initial authenticated/JWT tests do not establish those guarantees.

Native calendar creation/deletion rules are selected under [ADR 0046](adr/0046-first-native-calendar-crud-contract.md), with [CRUD](calendar-crud-contract.md) and [adapter interface](authorization-adapter-contract.md) proposals. A required native name is not an iCalendar NAME grammar constraint. Calendar CRUD, dependency coordination and related generated APIs remain unimplemented.

[ADR 0047](adr/0047-calendar-names-identifiers-and-deletion-storage.md) keeps native labels/UUIDs/minimal deletion markers separate from protocol NAME/UID and feed metadata. Basic native CRUD now applies these rules under ADR 0049; this does not add wire/client support.

[ADR 0048](adr/0048-calendar-name-validation-and-row-layout.md) selects native label rules and separate identity/data rows; no native name length/trim restriction is imposed on protocol NAME by this choice. The first native calendar schema and focused Unicode/lifecycle tests now exist under ADR 0049; protocol metadata remains a following batch.

## Interface coverage

| Surface | Required capability | Evidence |
| --- | --- | --- |
| Native Serverpod/generated Dart client | Calendar/event/task management, scheduling, rule management and availability search across lists of people/resources | Server/domain/database tests and host Flutter journeys |
| General iCalendar interchange | Approved VEVENT, VTODO, VTIMEZONE, VAVAILABILITY and free/busy profiles | Independent fixtures, semantic round trips and explicit unsupported-input diagnostics |
| Read-only subscription feeds | Declared event/calendar-description subset suitable for Apple Calendar on iOS, Google Calendar and Outlook | Feed-subset client matrix; no full task/scheduling/search GUI requirement |
| iTIP/restricted iMIP | Approved event/free-busy scheduling and trusted email; component hints supported, S/MIME deferred under ADR 0015 | Protocol/state/MIME tests, host authority evidence and explicit limited client profile; no complete RFC 6047 conformance |

VTODO scheduling over iTIP and inbound/outbound iMIP mail is deferred under [ADR 0011](adr/0011-defer-vtodo-scheduling.md). Native task assignment, standalone VTODO import/export and task alarms/notifications remain required. Test unsupported scheduling rejection without mutation, partial processing or automatic replies separately from ordinary task import/export.

Initial standards include RFC 5545, RFC 7953, RFC 5546, RFC 6047, the descriptive RFC 7986 profile, RFC 9110 and RFC 9111. RFC 9074 now has scoped first-release alarm/runtime work; RFCs 9073/9253 have selected scoped metadata profiles under ADR 0014; detailed constraints remain pending, while proximity and arbitrary audio/email actions are deferred. See [standards](standards.md), [ADR 0014](adr/0014-rfc-extension-decisions.md) and [ADR 0008](adr/0008-module-clients-tasks-and-search.md).

The [RFC property matrices](rfc/README.md) itemize named properties and relevant protocol features without claiming current implementation. Use their plan/status legend alongside the interface profiles here; unresolved values and contexts still need decisions.

The core also has a native unit-preserving `CalendarDuration` value with whole-second precision under [ADR 0041](adr/0041-whole-second-1970-2100-profile.md), superseding the original precision in [ADR 0027](adr/0027-calendar-duration-values.md). Constructor tests establish structural validation; date-only and selected calendar-first zoned application now have scoped core evidence under [ADR 0028](adr/0028-duration-application.md). Scoped native DATE-only event restrictions now have separate evidence under [ADR 0035](adr/0035-date-only-event-spans.md), including preserved input form, default/exclusive-end behavior and explicit maximum-date rejection. Scoped uniform-length DATE-only series overlap queries have separate evidence under [ADR 0036](adr/0036-date-event-series-overlap.md), including lookback, preserved forms and budget/overflow failures. Native single-occurrence DATE exceptions now have separate evidence under [ADR 0037](adr/0037-date-only-single-occurrence-exceptions.md): retained original identity, cancellation/replacement, moved/lengthened overlap and bounded invalid-target rejection. Native DATE-only THISANDFUTURE timing has separate evidence under [ADR 0038](adr/0038-date-only-this-and-future-timing.md), preserving single overrides and original order with shared bounded queries. Native UTC duration/span foundations and exact window lengths have separate evidence under [ADR 0039](adr/0039-exact-utc-duration-and-event-spans.md), including exact elapsed units, point queries and explicit long-Duration rejection; current acceptance is bounded by ADR 0041. [ADR 0040](adr/0040-bounded-temporal-core-completion.md) adds native UTC/zoned recurrence, spans/sets/PERIOD additions, single/range timing edits, task milestones and finite zone-offset matching. Alarm/lifecycle constraints, range cancellation and iCalendar rejection/round trips still need separate evidence.

The core DATE-only recurrence parameter validator has scoped structural tests under [ADR 0029](adr/0029-date-recurrence-rule-values.md). These do not prove occurrence generation, WKST/week-number evaluation, timed recurrence, import/export or external-client behavior; sorted, duplicate-free native filter representation is confirmed. Initial bounded DATE-only generation now has separate evidence under [ADR 0030](adr/0030-bounded-date-recurrence-generation.md), with explicit limit failures. [ADR 0031](adr/0031-date-recurrence-week-numbers.md) now adds native yearly BYWEEKNO and week-year evidence; [ADR 0033](adr/0033-date-recurrence-sets.md) adds scoped native DATE-only inclusion/exclusion tests, including earlier additions and separate limit failures. Selected bounded native timed recurrence now has separate evidence under [ADR 0040](adr/0040-bounded-temporal-core-completion.md); protocol/client evidence remains pending. Native ISO week fields have separate date-only evidence under [ADR 0034](adr/0034-native-iso-week-fields.md), independent of rule-specific WKST; this adds no wire or external-client claim.

## Automated example and deployment evidence

The real example host/Flutter app is the automated test application under [ADR 0018](adr/0018-automated-example-and-multiple-instances.md), NFR-14 and NFR-15. CI must run actual migrations/module code, generated-client APIs, feed HTTP routes and Flutter integration journeys with isolated synthetic host data and deterministic mail/notification adapters.

| Test surface | Required evidence |
| --- | --- |
| Example host and Flutter app | Automated calendar/task, recurrence, scheduling, search and reminder-action journeys through real generated APIs |
| Concurrent instances | At least two independent active Serverpod processes sharing a database; route requests to either and test cross-instance committed state and stale writes |
| Feeds and authority | Stable cross-instance bytes/ETags, updates and warm-cache conditional denial after committed token/publication revocation |
| Background processing | Competing planners/consumers, duplicate ingress, durable occurrence/intent uniqueness, stale-owner rejection and crash/lease recovery |
| Instance loss/restart | Remaining instance continues safely and recovers durable work within specified bounds; tests assert state rather than relying on unbounded sleeps |

Keep core unit tests, real-host/database integration, Flutter UI integration, protocol fixtures and external client/provider evidence distinct. CI provider doubles do not prove OS background delivery, actual client polling or end-to-end exactly-once behavior. The connected notification example and measured feed subset remain release evidence under [ADR 0020](adr/0020-notification-delivery-scope.md); platform push delivery is an optional external integration.

## Native and interchange profile

Approve exact property/parameter/recurrence matrices before claiming conformance. Internal/native support is distinct from what a subscription feed publishes.

| Feature | Module/interchange target | Required evidence |
| --- | --- | --- |
| Calendar system | Gregorian only; CALSCALE:GREGORIAN or omitted default, with no alternative calendar arithmetic/conversion | Accept explicit/default Gregorian; atomic rejection of other systems/non-Gregorian recurrence and host-extension bypass attempts; leap-year/date fixtures under ADR 0013 |
| ORDER/SCHEMA/DERIVED | Native/interchange presentation order and schema/media metadata; preserved/exported derived markers with server-enforced client read-only behavior | Valid contexts/defaults/ties, no fetching or content interpretation, edit/round-trip retention, host source updates and rejected marker-clearing bypasses |
| CALENDAR-ADDRESS/STYLED-DESCRIPTION/STRUCTURED-DATA | Host-validated participant addresses; URI-only rich descriptions with plain text retained and associated-data links in approved contexts | Address spoofing/mapping checks, no inline payloads/fetch/render/directory import, atomic rejection, semantic round trips/edit retention and host disclosure |
| Structured participants/locations/resources | Native/interchange event/task PARTICIPANT/VLOCATION/VRESOURCE and standardized LOCATION-TYPE, standard PARTICIPANT-TYPE and four standard RESOURCE-TYPE categories under ADR 0014; bounded RFC-defined nesting and legal shared-core field reuse selected | Nested round trips/edit retention, per-component validity and limits, host mapping validation, participant location permission and no directory/invitation/access/booking side effects; external feed rendering needs separate evidence |
| CONFERENCE/EMAIL/FEATURE/LABEL | Native/interchange event/task conference links and tags/labels; host-validated organizer/attendee contact email | Round trips/native edits, moderator credential isolation, spoofed email/routing rejection, no provider operation and continued VTODO scheduling deferral |
| Calendar SOURCE/IMAGE/DISPLAY | Private import-preserved SOURCE for authenticated interchange; native/interchange calendar image links and standard display hints under ADR 0014 | SOURCE retention and feed omission; URI-only image/hint round trips, no binary/fetch/resize/storage, host file-access/disclosure and unrelated-edit retention |
| Calendars and descriptions | RFC 7986 names/descriptions/identity/update/color, editable URL, host-validated calendar labels and configurable REFRESH-INTERVAL hint | Authorized edits/round trips, no-fetch/credential isolation, label validation, positive duration/wire syntax and stable metadata/ETags; polling remains client-controlled |
| VEVENT and persistent identity/metadata | Durable events/series, distinct source/scheduling/publication identity | Revisions, updates/deletes, no duplicates or identity loss |
| ATTACH/CATEGORIES/CLASS | URI-only host file references, searchable free-form labels with host validation, classification with host disclosure/masking | No binary/file copying; host validation; no PUBLIC permission escalation; surface masking and private free/busy isolation under ADR 0010 |
| COMMENT/GEO/RESOURCES | Editable event/task plain-text notes, event coordinates and descriptive event resource labels in native APIs/interchange | Coordinate/text validation and round trips; no chat/geocoding service or resource auto-linking/booking; publication remains a separate choice |
| TZNAME/TZURL/CONTACT | Zone display labels and no-fetch zone-source URI metadata; CONTACT preserved only from imports | Valid zone rules remain authoritative; no native CONTACT mutation; retain imported text through unrelated edits and apply host disclosure |
| CONCEPT/LINK/REFID | Native/interchange event/task formal category references, typed links and scoped grouping keys/search under ADR 0014; LINK UID/URI targets planned and XML-REFERENCE deferred; host-approved LINKREL, editable label/target-language/media metadata and authorized cross-calendar links planned; detailed target/deletion policy pending | Authorized search/grouping, private key/target isolation, host validation, no fetch/hierarchy/access/workflow side effects and edit/round-trip retention |
| Temporal relationships/GAP/DEPENDS-ON | Native/interchange declared dependencies and bounded signed lead/lag metadata under ADR 0014 | Direction/sign/context fixtures, authorized bounded inspection and round trips; no automatic date/lifecycle/status/booking/alarm/workflow changes or holiday calculations |
| RELATED-TO/URL/REPEAT | Basic native/interchange event/task relationships and information links; bounded automatic alarm repeats | Base hierarchy plus selected RFC 9253 target/group/ordering forms under ADR 0014; no permission inheritance/dependency execution or URL fetch; alarm DURATION pairing, configurable limits and stale/retry handling under ADR 0010 |
| Participant metadata and delegation | CN display names, standard CUTYPE values and host-authorized meeting delegation in native APIs/interchange | Round trips, spoofed labels, host mapping checks, unauthorized delegation rejection and unchanged access/bookings |
| DIR/FMTTYPE/LANGUAGE | Directory URI preservation/export, validated attachment media types and native/interchange text/name language tags | No fetch, lookup or content inspection; round trips/edit retention, valid tags/types, legal property cardinality and host disclosure |
| MEMBER/RANGE/SENT-BY | Host-validated membership metadata, this-and-future edits and host-authorized acting senders | No authority from imported claims; range/override identity, DST, booking/alarm recalculation, stale revisions and scheduling method validation |
| Text/content lines | Escaping, Unicode, CRLF and octet-aware folding | Valid/malformed/over-limit fixtures |
| UTC, date-only and named-zone times | Preserve temporal meanings; ordinary date profile [1970-01-01, 2100-01-01) under ADR 0041; exclusive event date ends; whole-second timing with nonzero-fraction rejection under ADR 0041; leap-second rejection retained; known named zones and validated matching VTIMEZONE definitions under ADR 0017, arbitrary custom rules deferred | Bounded generated native resolver covers 1970–2099 with exclusive-end padding and explicit unknown-offset failures under ADR 0041; RFC gap/fold policy selected; native timed recurrence/multi-day projection and bounded offset comparison tested under ADR 0040; VTIMEZONE parsing/acceptance and client evidence still pending |
| RRULE/RDATE/EXDATE/RECURRENCE-ID | Declared grammar and moved/cancelled exceptions; confirmed hourly/minutely, BYHOUR/BYMINUTE, BYYEARDAY/BYWEEKNO/BYMONTH, BYSETPOS and all WKST values (omitted default Monday); SECONDLY/BYSECOND deferred | Month ends/leap dates, original identity, DST/list combinations, bounded expansion without false-free partial results; explicit deferred-form rejection |
| DTEND/DURATION and missing event end | Explicit duration/default rules and mutual exclusion | Point events, date defaults and DST-spanning durations |
| VTODO tasks | Authorized native lifecycle/assignment and approved standalone interchange including optional dates and recurrence under ADR 0017; iTIP/iMIP tasks deferred | Needs-action/in-progress/completed/cancelled, due/completion validation, restart and round trips; per-occurrence completion, exceptions and series edits specified/tested |
| Free/busy and search | Per-target intervals and optional common-free search for explicit person/resource lists | Coverage/privacy, minimum duration, limits, no false-free results and generated-client calls |
| VFREEBUSY | Privacy-safe bounded UTC projection and supported iTIP methods | Explicit periods after recurrence resolution; valid component/role constraints |
| Calendar availability policy | Per-calendar no-rule setting (default free), separate calendar results and authenticated-only raw rules plus optional host-selected person/resource booking summaries under ADR 0012; summary free time intersects each contributor's independently evaluated rules, fallback and bookings | Fallback boundaries, bookings, unknown coverage, policy revision/cache updates and no raw rule exposure through bearer feeds |
| VAVAILABILITY/AVAILABLE | RFC 7953 rules and shared RFC 5545 metadata/privacy/recurrence profile under ADR 0012; legal per-component contexts and UTC/zoned date-times | Metadata/extension round trips, invalid contexts and DATE/floating rejection, composition with bookings, no-rule policy, DST and work limits |
| Scheduling metadata | METHOD/ORGANIZER/ATTENDEE and approved participation fields | Roles, version/order/deduplication, trusted addresses and MIME method consistency |
| VALARM and native alarms | Scoped time-based definition/execution and private action state | Calendar edits/recurrence/DST, due worker recovery, stale generation, approved triggers and imported-alarm activation |
| Notification integration | Durable reminder intents through reusable notification module; example server events/streaming to Flutter | Authorized connected-client delivery/actions, disconnect/reconnect recovery and cross-instance routing; no OS background push claim or direct platform provider implementation |
| IANA/X-properties and ALTREP | Explicit profile allowlist for registered properties; host-configured X-property validation; alternate text URI metadata only | Unknown/unconfigured names rejected atomically; approved-field retention; no fetching/rendering or permission override; ordinary text retained |
| Unapproved forms | Reject unsupported input explicitly before mutation | No silent flattening or loss; component-specific diagnostics |

General imports validate the complete batch atomically. Master and legitimate overrides sharing a UID are not duplicate-series errors. Ordinary import conflicts are distinct from authorized scheduling updates. VJOURNAL remains deferred; alarm execution and the reusable notification/connected-stream example are required with the selected personal alarm baseline under ADR 0009 and the RFC tables. Task dates are not automatically busy events. A reusable standalone Flutter widget package is separate from the required host Flutter integration.

## Subscription feed subset

The proposed baseline publishes selected VEVENT fields, supported UTC/all-day/zoned recurring semantics and exceptions, necessary time-zone definitions, and approved RFC 7986 calendar descriptions. Approve exact feed properties separately from general interchange. Tasks, internal scheduling/workflow state, availability rules and free/busy search need not be exposed to subscription clients. Richer approved module fields remain in storage/native APIs even when intentionally excluded from feeds. Exclusions must be documented, with no silent change to the meaning of a published event.

Publish long random HTTPS URLs returning `text/calendar; charset=utf-8`, with read-only GET/HEAD and no password/cookie/login requirement. Multiple URLs can reference a feed selecting several calendars. Each feed has its own metadata and stable publication identities, including collision handling for independent source UIDs/zones. Authorized managers create/revoke credentials independently.

Implement ETag/If-None-Match under [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110.html#name-if-none-match): unchanged representation gives bodyless 304, changed representation gives 200/current validator. Test weak comparison, lists/wildcard, HEAD, encoding variants and snapshot consistency. Access/revocation checks precede cache handling; private revalidation prevents shared-cache disclosure under RFC 9111. Repeated requests alone do not change metadata/ETag.

Refresh timing belongs to clients. Revocation stops future origin access, not downloaded copies. URL/SOURCE metadata must not disclose other credentials; REFRESH-INTERVAL is a hint. URI metadata does not authorize remote fetching.

| Feed client | Setup evidence | Required coverage |
| --- | --- | --- |
| Apple Calendar on iOS | [Apple subscription guide](https://support.apple.com/en-gb/102301) | Declared feed fixtures, subscribe and later event changes/deletes |
| Google Calendar | [Google From URL guide](https://support.google.com/calendar/answer/37100?hl=en) | Same feed subset; observed refresh and metadata behavior |
| Microsoft Outlook | [Microsoft web subscription guide](https://support.microsoft.com/en-us/outlook/import-or-subscribe-to-a-calendar-in-outlook-com-or-outlook-on-the-web) | Same feed subset in recorded account/client variant |

Test aggregation and URL lifecycle along with published temporal/metadata fixtures. Record version/account/date/setup/fixture/results, refresh delays and deviations. Full module task/search/rule/scheduling interfaces are not acceptance requirements for these clients. Any legacy fallback or deliberate feed transformation needs explicit measured justification. No universal client rendering claim is made.

## Scheduling, availability and extension evidence

Validate iTIP/iMIP methods independently from feeds with protocol fixtures, host Flutter scheduling journeys and trusted test mail adapters. Choose external scheduling client/account targets separately; the feed target list does not automatically require every listed client to implement all scheduling methods or task assignment. Record invitation/reply/update/cancellation and recurring-instance directions/results for selected targets, plus server tests for all supported methods. Include spoof/stale/duplicate messages, MIME variants/mismatches, provider retries and crash recovery.

Free/busy calculation includes RFC 7953 rules and privacy. Native person/room/resource search must return complete/unknown coverage and never label unresolved data free. Standalone VFREEBUSY file import is confirmed deferred under [ADR 0017](adr/0017-profile-review-clarifications.md); authenticated per-calendar output now follows ADR 0077, while authorized iTIP exchanges remain planned. CalDAV scheduling/discovery remain deferred. RFC 7953 does not define VAVAILABILITY iTIP message semantics.

Use the selected per-feature RFC 9073/9074/9253 tables when finalizing schemas and parser constraints; do not reopen chosen features as unselected scope. Separate resource publication from host identity/authorization, alarm storage from execution, and links from permission inheritance. Client display support is evidence for a projection, not a veto on approved module capabilities. Unsupported imports still fail explicitly; deliberate subset publishing never authorizes loss of canonical data.

## Alarm integration evidence

Calendar alarm state/semantics, generic notification/device/provider delivery and Flutter platform presentation have separate owners under [ADR 0009](adr/0009-alarms-and-notification-boundaries.md). [ADR 0020](adr/0020-notification-delivery-scope.md) supersedes the required iOS/Android push path with a reusable notification module and an example using Serverpod server events/streaming. Test trigger recalculation, cancellation/access loss, restart/duplicate/retry, expiry and authorized actions, including disconnect/reconnect and cross-instance delivery. Native personal alarm state is not published in subset feeds by default. Streams demonstrate delivery to connected clients; they do not establish OS background delivery. Proximity/geofencing and other advanced actions remain deferred; platform push/local notifications are external adapter concerns requiring their own delivery evidence. Record versions and best-effort delivery limitations without claiming every alarm was displayed.

## Native event recurrence increment, 2026-10-21

The maintainer selected recurrence storage/bounded API and example previews first, preserving and validating explicit inclusion/exclusion dates during pattern replacement. [ADR 0054](adr/0054-native-event-recurrence-and-previews.md) and [the native guide](native-event-recurrence.md) describe the FR-03/04/08 increment: DATE/UTC/named-zone definitions, sorted filters/dates, actual parent/event/query policy context, separate preview authority/timing disclosure and complete-or-failure overlap queries. Individual/future occurrence editing, cross-event chronological queries and complete availability, ICS/feed and external-client interoperability remain pending. Existing temporal/ISO/WKST/profile guards remain unchanged. This updates earlier statements that all recurring event persistence remains pending; it does not complete recurrence edit lifecycle or the first release.

## Native occurrence timing increment, 2026-10-21

The maintainer selected timing edits for one/this-and-future, single cancellation/restoration, preservation with orphaning-pattern rejection, and deferred future cancellation. [ADR 0055](adr/0055-native-occurrence-timing-edits.md) and [the guide](native-occurrence-timing.md) describe this FR-03/04/08/27 increment. Dedicated actions preserve original identity and master content, use current event revision and actual parent/event/action policy context, and revalidate retained overrides during master changes. Summary/description/location/status/transparency remain on the series. This supersedes earlier blanket pending statements for native timing edits only; content overrides, future cancellation, availability, ICS/feed/scheduling and alarm execution remain pending.

## First per-calendar free/busy increment, 2026-10-21

The maintainer selected per-calendar free/busy before RFC 7953 working-hours rules and subject/common-slot search, with tentative opaque bookings blocking time and classified separately. [ADR 0056](adr/0056-first-calendar-free-busy.md) and [the guide](calendar-free-busy.md) describe this partial native FR-16/17/27 implementation: independent calendar/source busy authority, complete/unknown coverage, effective recurring/overridden booking intervals, saved fallback, UTC classifications and no private source identities/counts. Limits/denied coverage cannot appear free. Broader RFC 7953 metadata/override/interchange support, cross-scope/group-expansion coordination, VFREEBUSY serialization, scheduling, alarms and external-client/feed interoperability remain pending.

[Native working-hours CRUD/composition](native-working-hours.md) implements `CalendarAvailabilityContent`, `CalendarAvailabilityOpening`, create/update requests, views/receipts and separate identity/active-data records under [ADR 0057](adr/0057-native-working-hours.md). Raw management and private projection have separate host gates. Rich metadata, opening-occurrence overrides and wire import/export remain planned.

## Host-resolved subject availability increment, 2026-10-21

The maintainer confirmed an initial single trusted host scope and summary authority independent of direct calendar query access. [ADR 0058](adr/0058-subject-availability-search.md) and [the implementation guide](subject-availability-search.md) add native `CalendarAvailabilityTarget`, search query/mode/view, slots and subject results, reusing existing storage. Complete authoritative host resolution, per-source projection, final mapping/authority rechecks, shared work budgets and complete-only free intersections now support per-target/common-free modes. Empty/denied/unresolved/foreign/over-limit coverage never establishes free time. No source calendar IDs or private resolver/scope versions are disclosed. Cross-scope coordination, group-member expansion, large-calendar indexing, wire output and reservation remain separate work; broader logical models/interoperability scope remain proposed.

## Opening edits and scoped rule metadata, 2026-10-21

The maintainer selected the shared single/future timing and skip/restore policy, retained edits with orphan rejection, and legal text/categories/comments plus definition-only URL/CLASS first. [ADR 0059](adr/0059-availability-occurrence-edits-and-metadata.md) and [the native guide](availability-occurrences-and-metadata.md) add opening edit/query/preview DTOs, separate active-data override state, metadata/preview/action host gates and exact authorized category filtering. These changes immediately affect native calendar/subject/common-free calculation without disclosing metadata there. Organizer/language/ALTREP/extensions/CONTACT interchange, full protocol stamps, envelope duration shorthand, occurrence text/future cancellation and wire evidence remain pending. Existing temporal/profile guards and complete-or-unknown behavior remain unchanged.

## Native availability publication metadata increment, 2026-10-21

The maintainer selected dedicated host organizer approval, annotations on existing text and bounded host-validated private X-properties under [ADR 0060](adr/0060-availability-publication-metadata.md). [The native guide](availability-publication-metadata.md) records the scoped DTOs, per-comment parameter association, legal contexts, limits, no-fetch behavior and independent preliminary/final approval. Nullable nested JSON additions preserve old rows without a table migration. This supersedes earlier pending wording only for these native fields: CONTACT, arbitrary wire grouping, individually profiled IANA extensions, scheduling authority and import/export/feed interoperability remain pending.

## Native availability protocol lifecycle increment, 2026-10-21

The maintainer selected actual-change SEQUENCE, stable protocol state on identical saves and independent opening timestamps with an explicit legacy baseline under [ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md). [The native guide](availability-protocol-lifecycle.md) records server-managed values, readonly host/API context, nullable storage, no-write legacy reads, overflow/revision guarantees and positive unit-preserving envelope duration. This supersedes earlier pending wording for those native increments only. Full wire exception-component/source metadata, parser/export, CONTACT, scheduling and feed/client interoperability remain pending.

## Bounded syntax foundation increment, 2026-10-21

The maintainer selected strict UTF-8/CRLF input under [ADR 0062](adr/0062-bounded-icalendar-syntax-foundations.md). [The syntax guide](icalendar-syntax.md) records immutable ordered syntax, retained unknown/repeated data, separate TEXT/RFC 6868 parameter codecs, bounded atomic failure and deterministic folded output. These pure Dart syntax models add no Serverpod tables/endpoints or domain mapping. Semantic profile validation, supported-source preservation, database import, authorized export, scheduling and HTTP feed/client interoperability remain pending; syntax acceptance alone grants none of them.

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


## Create-only availability import, 2026-10-22

[ADR 0073](adr/0073-authenticated-create-only-availability-import.md) and [the import guide](availability-import.md#implemented-create-only-operation) implement the bounded standalone availability import slice. `importAvailability` and per-definition `createAvailability` are independent, with full immutable batch context and actual parent/revision checks. Dedicated organizer and trusted extension validation run at both write phases. Exact active UID conflicts are destination-calendar scoped; the complete file commits atomically with source versions retained and final host-approved minimal receipts. This supersedes earlier pending-import wording only for this profile. Authorized export, source updates/reconciliation, other component import, feeds and external-client interoperability remain pending.


## Authenticated availability export, 2026-10-22

[ADR 0074](adr/0074-authenticated-availability-export.md) and [the export guide](availability-export.md) add current-state standalone availability output. The maintainer selected explicit definitions from one calendar and all-or-nothing authorization/availability. Require independent export and raw-read rights with full immutable selection context, reauthorize after serialization, preserve the supported component data and generate full-horizon pinned VTIMEZONE definitions. Native skip/restoration state, missing component checkpoints, duplicate opening source UIDs across selected definitions and over-limit/out-of-profile state reject explicitly. Export is a read with no revision/time changes and no HTTP feed or scheduling side effects. This supersedes export-pending wording only for the declared availability slice; source reconciliation, other component import/export, feeds and external-client interoperability remain pending.


## Availability replacement contract, 2026-10-22

[ADR 0076](adr/0076-availability-replacement-implementation.md) implements the scoped [availability replacement operation](availability-update.md#implemented-operation): private active-row source baselines, revision-bound explicit selections, exact source UID matching, local-conflict rejection, equal/lower source sequence handling, stable matching opening UUIDs and true authorized no-ops. Replacement requires import, dedicated replacement and current raw-read authority plus applicable edit rights, with final full-batch and organizer/extension checks. Changed members retain exact incoming protocol timestamps/omissions and atomically update their baseline/revision with one scope generation bump. Old/native-created rows have no assumed baseline. Adoption/overwrite, mixed upsert, broader source synchronization, feeds and scheduling remain separate.

## Privacy-safe VFREEBUSY export, 2026-10-22

[ADR 0077](adr/0077-privacy-safe-calendar-freebusy-export.md) and [the VFREEBUSY export guide](freebusy-export.md) add authenticated per-calendar UTC snapshots, using complete booking/working-hours coverage and independent export/query/source-projection authority. Unknown coverage rejects rather than appearing free. Output contains classified periods, fresh snapshot identity/time and bounds, without private source details or IDs. Current authority is repeated after serialization; stored state is unchanged. Subject/common-free export, scheduling, HTTP feeds and external-client interoperability remain separate.


## Event import contract, 2026-10-22

[ADR 0078](adr/0078-create-only-event-import-and-storage.md) and [the event import contract](event-import.md) confirm storage extension before create-only VEVENT import: destination-active exact UID conflicts, retained independent source versions/omissions, separate import/create/lifecycle rights, native CONFIRMED for omitted STATUS with source omission retained, and a private active-row source baseline from the first import. Decoded components are preserved while envelope/zone presentation is regenerated. Actual native component changes advance versions; identical normalized saves keep protocol state; annotations require explicit changes; legacy local initialization invents no import history. This records the original contract batch; ADR 0079 now implements its storage prerequisite as described below. The authenticated create-only import API now follows under ADR 0080; concrete mechanics remain under draft review.


## Event storage prerequisite, 2026-10-23

[ADR 0079](./adr/0079-source-preserving-event-storage.md) and [the storage guide](event-storage.md) extend native events with stored PERIOD additions, retained text annotations, source property presence, independent component versions and a private baseline representation. Native edits, previews and occupied-time calculations use the retained values. Source conversion is pure and grants no authority; create-only VEVENT import now follows under ADR 0080; event export, source updates, feeds and scheduling remain pending. ADR 0080 now implements the selected create-only import; current-state event export is the next recommended area.


## Create-only event import, 2026-10-23

[ADR 0080](adr/0080-authenticated-create-only-event-import.md) and [the implemented import guide](event-import.md#implemented-create-only-operation) add authenticated full-file create-only VEVENT import. Require separate import/create authority and lifecycle permission for cancelled masters/single occurrences, using immutable full-batch actual-parent context and final transaction checks. Preserve supported source semantics/versions and a private active-data baseline; exact active UID conflicts are destination-local. Return only final-approved minimal receipts, with no implied detail access. The schema is unchanged from ADR 0079. Event export, replacement/adoption, feeds, scheduling and alarms remain separate.


## Current-state event export, 2026-10-23

[ADR 0082](adr/0082-authenticated-current-event-export.md) and [the export guide](event-export.md) implement explicit revision-bound complete series from one calendar. Require separate export permission and all supported read-disclosure groups, with complete selection context and repeated post-serialization checks. Generate current supported semantics and pinned zones, excluding historical baseline/native storage metadata. Reject unrepresentable cancellation restoration state and any decoded current-state mismatch; never silently normalize or redact. Export is read-only; source replacement, feeds, scheduling and alarms remain separate.


## Native task increment, 2026-10-23

[ADR 0084](adr/0084-first-native-task-implementation.md) and [native task documentation](native-tasks.md) implement the confirmed ADR 0083 non-recurring CRUD/assignment/progress choices. Typed undated/DATE/UTC/named-zone tasks use independent host operations/disclosure, optimistic revisions, opaque pagination and content-free deletion markers. Completion is 100 percent with server whole-second UTC time; cancellation preserves percentage and clears current completion time; reopening resets to 0. Tasks never book time. Recurrence/history, task-specific filters, VTODO interchange, scheduling and alarms remain pending. This scoped increment supersedes earlier blanket statements that durable tasks are entirely unimplemented.


## Recurring task increment, 2026-10-23

[ADR 0086](adr/0086-durable-task-recurrence-implementation.md) and [recurring tasks](recurring-tasks.md) extend the initial native task slice with canonical recurrence, bounded start-based previews, independent original-occurrence progress and retained transition history. Reject orphaning pattern edits and ambiguous conversion from previously progressed or unknown legacy tasks. Retain history while active and scrub it at deletion. Preview/history have independent host operations/current timing/progress disclosure and isolated opaque history pages without totals. VTODO interchange, task timing/content exceptions, all-series lifecycle actions, scheduling and alarms remain separate. This scoped increment supersedes older non-recurring-only implementation statements.


## Standalone VTODO master wire increment, 2026-10-23

[ADR 0088](adr/0088-vtodo-wire-master-implementation.md) and [the pure task adapter](icalendar-task-adapter.md) add bounded undated/DATE/UTC/named-zone VTODO masters with recurrence, basic annotated text/priority and independently optional source progress/checkpoints. Preserve source values rather than imposing native progress defaults; validate exact full-horizon zones and reject unsupported occurrence components, PERIODs, alarms, scheduling and unprofiled metadata. This is a pure parser/serializer, without native database import/export or assignment/history inference. Those services and richer task wire profiles remain pending.

## VTODO progress occurrence wire increment, 2026-10-23

[ADR 0090](adr/0090-vtodo-occurrence-component-implementation.md) implements the confirmed [ADR 0089](adr/0089-vtodo-occurrence-component-contract.md) same-file-master and progress-only profile. The [pure task adapter](icalendar-task-adapter.md) links exact retained original identities to projected milestones and inherited text/priority while preserving raw source omissions, independent optional progress/checkpoints and component order. Reject detached, duplicate, excluded/absent/profile-mismatched originals, timing/content differences and RANGE. Aggregate membership work is bounded per master and shared across the file. This supersedes older blanket occurrence-wire-pending notes only for this slice; richer task metadata, native exceptions, authenticated database import/export, alarms and scheduling remain separate. No native history is invented and no external-client interoperability is claimed.

## VTODO text/link wire increment, 2026-10-23

[ADR 0091](adr/0091-vtodo-text-and-link-metadata.md) and [the task adapter](icalendar-task-adapter.md#text-and-link-metadata) now add source-preserving CLASS, HTTP/HTTPS URL and grouped CATEGORIES/COMMENT/CONTACT with legal annotations. Linked progress occurrences inherit omissions and reject explicit metadata differences; retain source grouping, duplicates and presence. Limits use the existing file-wide task budget and bounded per-component counts. No URI retrieval, host authority, native CONTACT editor or database import/export follows. Organizer/attendee, relationships, attachments and alarms remain separate profiles. This supersedes older metadata-pending notes only for this slice; native metadata editors/search and client interoperability remain unimplemented.

## VTODO source participant wire increment, 2026-10-23

[ADR 0092](adr/0092-vtodo-source-participants.md) and [the task adapter](icalendar-task-adapter.md#inert-source-participants) now preserve organizer/attendee source addresses and bounded standard parameters, ordered address lists, exact spelling and source presence. Explicitly named effective attendee defaults/fallbacks remain distinct from raw values and task progress. Occurrence omissions inherit; explicit differing participant state rejects. Source claims never map themselves to native assignees/host identities, prove membership/authority, fetch directories or send messages. This supersedes earlier participant-wire-pending notes only for this inert profile. Native participant editing, authenticated task interchange, relationships/attachments/alarms and all VTODO scheduling remain separate.

## VTODO source reference wire increment, 2026-10-23

[ADR 0093](adr/0093-vtodo-source-references.md) and [the task adapter](icalendar-task-adapter.md#unresolved-relationships-and-inert-attachments) now preserve basic unresolved RELATED-TO UID references and URI-only ATTACH/FMTTYPE metadata. Keep missing/self/cyclic references as data, source order/duplicates/presence and matching occurrence inheritance. No native graph edges, identity resolution, file access, fetching or workflow follows. Binary/data payloads and extended relationship semantics reject. This supersedes older basic relationship/attachment-wire-pending notes only for this pure task slice; native editors/graph rules, extended metadata, alarms and authenticated task import/export remain separate.

## VTODO DISPLAY alarm wire increment, 2026-10-23

[ADR 0094](adr/0094-vtodo-display-alarm-source-profile.md) and [the task adapter](icalendar-task-adapter.md#unarmed-display-alarm-definitions) now preserve unarmed DISPLAY source alarms, relative task start/due or absolute UTC triggers, bounded paired repeats and optional source UID/ACKNOWLEDGED. Validate typed anchor presence and matching occurrence inheritance, with shared file/text budgets and exact portable duration bounds. No native recipient/consent/action/history or delivery is inferred; no firing instants are generated. Snooze relationships, event alarms, activation authorization, native storage/runtime and notification integration remain separate. This supersedes older blanket task-VALARM rejection only for this source slice; no runtime/client interoperability follows.

## VTODO sibling snooze source increment, 2026-10-23

[ADR 0095](adr/0095-vtodo-snooze-source-profile.md) and [the task adapter](icalendar-task-adapter.md#bounded-source-snooze-links) extend unarmed DISPLAY definitions with exact same-VTODO sibling SNOOZE links: own UID, absolute UTC trigger, acknowledged original and no repeats/chains/detached borrowing. Preserve source state/order and occurrence inheritance without native actions, consent, delivery or history. This supersedes older blanket snooze-wire rejection only for this structural source slice; event/native snooze, activation/privacy/runtime and notification integration remain pending.

## Source-preserving native task progress prerequisite, 2026-10-23

[ADR 0096](adr/0096-source-preserving-native-task-progress.md) and [the progress guide](task-source-progress.md) now preserve independently optional status/percentage/completion in native JSON/API values. Native commands explicitly produce agreed states; read/content edits retain source combinations. Recurring originals without a row use the complete master progress; sparse rows replace it without merging. No imported history is invented. Generated clients and Flutter handle absence explicitly. Full task source metadata/version/baseline storage and authenticated import/export remain separate; this supersedes older mandatory-progress/neutral-master read claims only for this prerequisite.

## Task import/storage boundary, 2026-10-23

[The task import contract](task-import.md) records the confirmed create-only/source-preservation/permission/checkpoint choices. [The source-storage prerequisite](task-source-storage.md) is now implemented under ADR 0098. No authenticated task import/export, original-file archival, native alarm activation or external-client compatibility is established by these documents.

## Source-preserving task storage increment, 2026-10-23

[The storage guide](task-source-storage.md) records the ADR 0098 current source metadata/component-version and private-baseline prerequisite. Source values remain read-only, inert and unarmed; assignment-only edits keep protocol versions unchanged and occurrence progress versions its own component. Native projections must agree with source state, and incompatible edits reject. This supersedes the immediately preceding storage-pending/proposal notes only for the scoped storage increment; task import/export, native metadata editors, alarm runtime and external-client evidence remain separate.

## Create-only task import increment, 2026-10-23

Authenticated [task import](task-import.md#implemented-create-only-operation) now follows under ADR 0099. It retains the supported strict VTODO profile and complete source storage under independent host permissions. This supersedes prior import-pending notes only for create-only native ingestion; task export, synchronization, native source editors, alarm execution and external-client evidence remain separate.

## Current task export increment, 2026-10-23

[ADR 0100](adr/0100-authenticated-current-task-export.md) and [the task export guide](task-export.md) add read-only current-state standalone VTODO output with explicit revision-bound complete-series selection. Export requires independent export, full ordinary task disclosure and rich-source-read authority, checked again after serialization. Preserve supported source metadata/progress/versions; exclude private baselines, native assignments/history and alarm activation. Native exceptions, source replacement/adoption, feeds/runtime and external-client evidence remain separate. This supersedes older task-export-pending wording only for this bounded profile.

## Single task occurrence timing, 2026-10-23

[ADR 0101](adr/0101-single-task-occurrence-timing.md) and [the timing guide](task-occurrence-timing.md) extend the scoped native/wire task profile with single complete timing replacements, effective-start previews and progress/history preservation. Explicit DTSTART replaces complete occurrence timing; absent DUE/DURATION clears the deadline. Capture current progress for a new own component without adding history, and reject incompatible retained alarm anchors. Task source baselines advance to v2; older imports require explicit reimport, without automatic repair or development reset. This supersedes earlier progress-only/timing-pending wording for this slice only. Future timing/content, source reconciliation, feeds/runtime and client evidence remain separate.

## Task future timing, 2026-10-23

[ADR 0102](adr/0102-task-future-timing.md) and [the future timing guide](task-future-timing.md) extend single timing with absolute civil shifts, replacement deadline forms and independent single edits. VTODO RANGE=THISANDFUTURE propagates timing only; independently optional source progress belongs only to the anchor. Preserve every original/progress/history record, reject orphaning edits and conflicting timing scopes, and keep source alarms unarmed. Nullable storage and canonical true-or-absent source flags preserve valid non-range v2 baselines. This supersedes earlier future-timing-pending/RANGE-rejection notes for this bounded profile; content/future cancellation, reconciliation, feeds/runtime and client evidence remain separate.

## Selected task occurrence content, 2026-10-23

[ADR 0103](adr/0103-single-task-content-overrides.md) and [the content guide](task-occurrence-content.md) add selected-field set/clear/inherit for summary, description, location and priority. Omitted fields follow the series; explicit source values stay pinned. RANGE content/progress apply only to the anchor while timing propagates. Opt-in preview groups independently protect effective values and override presence. Preserve progress/history and own versions; source baselines advance to v3 for the changed repetition policy, with explicit recreation/reimport of older imports and no development reset. This supersedes earlier blanket task-content rejection/pending and v2 compatibility notes for this later scoped increment. Future content, source reconciliation, feeds/runtime and client evidence remain separate.

## Explicit task source replacement, 2026-10-24

[ADR 0104](adr/0104-task-source-replacements.md) and [the replacement guide](task-source-replacement.md) extend create-only task import with explicit revision-matched, all-or-nothing existing-series replacements. Current v3 baselines protect local content/progress, native assignments survive, lower master SEQUENCE rejects, equal is allowed and exact source timestamps/omissions remain intact. Identical replacements are true no-ops without adopting local edits. Require independent import/replacement, full ordinary-detail and rich-source-read authority plus applicable update/progress gates; historical snapshots stay private and source alarms stay unarmed. Adoption/overwrite, mixed upsert, scheduling, feeds and runtime remain separate. This supersedes earlier task-replacement-pending statements only for this bounded slice.

## Explicit event source replacement, 2026-10-24

[ADR 0105](adr/0105-event-source-replacements.md) and [the replacement guide](event-source-replacement.md) add explicit atomic existing-series replacement under independent import/replacement/full-detail and applicable edit/lifecycle authority. Current recorded baselines protect local edits; lower master SEQUENCE rejects, equal is allowed and source timestamps/omissions stay exact. Identical retries change nothing and never adopt a dirty baseline. Lifecycle checks include master status transitions and changes to the exact set of cancelled originals, including removal. Historical snapshots stay private. This supersedes earlier event-replacement-pending statements only for this bounded slice; adoption/overwrite, mixed synchronization, richer profiles, scheduling and feeds remain separate.

## Selected event occurrence content, 2026-10-24

[ADR 0106](adr/0106-single-event-content-overrides.md) and [the content guide](event-occurrence-content.md) extend events with selected summary/description/location exceptions, explicit clear/inherit, protected preview groups and anchor-local own wire text/annotations. Content-only exceptions preserve timing inheritance and reject lossy export; explicit timing components can round-trip local content. Master edits preserve pinned fields. Private event-source-v2 baselines supersede v1, which rejects fail-closed and requires explicit development recreation/reimport; no automatic reset/adoption is performed. This supersedes earlier timing-only/content-pending wording only for this scoped slice. Future content/cancellation, richer profiles, scheduling and feeds remain separate.

## Read-only event source metadata, 2026-10-24

[ADR 0107](adr/0107-read-only-event-source-metadata.md) and [the metadata guide](event-source-metadata.md) add source-preserved CLASS/URL and grouped CATEGORIES/COMMENT/CONTACT with legal annotations. Native editors retain these values; source-only values grant no authority and cause no retrieval. Independent `readEventSource` gates complete export and source replacement, including no-op/final paths. Omitted occurrence metadata inherits and explicit values must match the master; native metadata-only originals preserve timing inheritance and reject lossy export. Nullable server-only JSON fields preserve v2 baseline compatibility, with no new table columns or automatic reset. Broader/native metadata editors and other profiles remain separate. Broader batch verification is recorded in scaffold-validation.md.
