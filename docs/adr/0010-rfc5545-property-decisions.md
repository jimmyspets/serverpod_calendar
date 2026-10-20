# ADR 0010: RFC 5545 property decisions

> Notification scope update: [ADR 0020](0020-notification-delivery-scope.md) supersedes earlier requirements for direct iOS/Android push delivery. Durable alarms remain required; a reusable notification module and connected Serverpod streaming example replace the platform-provider release gate. Earlier platform examples below are historical proposals.

Status: **Proposed implementation; selected capabilities confirmed by the maintainer**. Date: 2026-10-19. This record captures the interactive RFC 5545 review. Confirmed property choices do not approve unrelated ADRs or imply implementation. Formal ADR acceptance still follows repository review discipline.

Current-scope note: batches below retain their review sequence. Later decisions resolve earlier open questions: FMTTYPE/LANGUAGE/SENT-BY in subsequent batches, baseline alarm/snooze scope in [RFC scope](../rfc/README.md), richer relationships in [ADR 0014](0014-rfc-extension-decisions.md), and recurring tasks/known zones/standalone free-busy import in [ADR 0017](0017-profile-review-clarifications.md). Use current RFC table statuses and notes for scope.

## Confirmed batch 1

The maintainer selected all three recommendations in the current conversation:

| Property | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| ATTACH | File links only, with files managed by the host application's storage service | Native event/task and approved interchange store URI references; embedded binary attachments are outside the selected profile |
| CATEGORIES | Free-form searchable labels, with host validation of allowed values | Support labels in native event/task APIs and interchange; no mandatory module-owned taxonomy |
| CLASS | PUBLIC/PRIVATE/CONFIDENTIAL labels with host-controlled disclosure/masking | Store labels and evaluate host policy for each surface; never override calendar authorization or automatically publish anything |

File content, upload/download authorization, storage credentials and expiring-link policy remain host storage concerns. The module must not automatically fetch ATTACH URIs or copy their contents into iMIP messages. Calendar access must not implicitly grant file access. MIME encoding of the scheduling message itself is separate from the excluded embedded calendar attachments. FMTTYPE and URI/size/count policy remain open.

Classification policy applies consistently to native reads, feed projections and scheduling output; determine masking/omission through host policy rather than by label alone. PUBLIC never creates a feed or grants anonymous access. Classification does not remove a booking from free/busy unless its independent blocking policy says so; availability-only views still expose no private event content.

Exact schema, label normalization/search semantics, native creation defaults and host disclosure treatment of omitted CLASS, URI scheme allowlist, disclosure fallback when host policy is unavailable and per-surface field selection remain implementation/profile decisions to review. Apply the existing fail-closed authorization discipline. The confirmed scope does not expand optional RFC 7986/7953 metadata contexts automatically.

## Confirmed batch 2

The maintainer selected all three recommendations:

| Property | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| COMMENT | Editable plain-text event/task notes in native APIs and interchange | Preserve RFC property multiplicity and method-specific constraints; no discussion threads or chat service |
| GEO | Editable event latitude/longitude in native APIs and interchange | Validate coordinate values; maps, geocoding and address lookup stay with host/Flutter integration |
| RESOURCES | Descriptive event resource labels in native APIs and interchange | Labels such as Projector/Whiteboard do not create host resource identities, grant access or reserve equipment |

Resource labels remain independent of stable external room/equipment references and their booking/availability associations. Do not merge, auto-link or reserve by matching display strings. Coordinate metadata does not change the selected RFC 9073 structured-location scope. Privacy and host disclosure/masking rules apply to all new metadata, and publication in the feed subset remains an explicit projection choice. Other component/property contexts are not approved automatically by this event-focused decision.

Exact text/coordinate limits, normalization, query filters and GUI presentation remain implementation details. Test native edits and semantic import/export, repeated comments where legal, Unicode, invalid coordinates, privacy-only views and that resource text changes cannot alter reservations or identity links.

## Confirmed batch 3

| Property | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| TZNAME | Preserve/export time-zone display labels | Actual temporal calculations use validated zone rules, not labels such as CET/CEST |
| TZURL | Preserve/export a zone-source URI as metadata only | Do not download, trust or use the referenced content to update rules automatically |
| CONTACT | Preserve imported contact text only | Retain supported text for interchange without native contact creation/editing or a contact-directory feature |

Accepted VTIMEZONE scope still controls whether a zone definition is supported. These metadata decisions do not approve arbitrary custom zones, aliases, LANGUAGE parameters or a network zone resolver. Imported CONTACT must survive unrelated native item edits and approved round trips; its presence is not an external identity/contact directory record. Host authorization/disclosure and the selected feed projection control exposure. Native API clients cannot silently overwrite this import-preserved field via ordinary item updates; exact read/schema shape remains an implementation detail.

Test zone labels without changing computed offsets, TZURL no-fetch behavior, imported-contact round trips/retention across edits, metadata limits and privacy filtering. Reject still-unsupported parameters explicitly rather than silently stripping them.

## Confirmed batch 4

| Property | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| RELATED-TO | Native/interchange basic parent/child/sibling relationships for events/tasks | Includes the corresponding RFC 5545 RELTYPE values; no automatic dependency scheduling or permission inheritance |
| URL | Editable native event/task information or representation link with interchange | Separate from ATTACH and secret feed credentials; no automatic retrieval |
| REPEAT | Capped automatic alarms at fixed intervals | Configurable count/interval limits; pair REPEAT and alarm DURATION under RFC rules; distinct from recurrence and user-requested snooze |

Basic relationship support does not approve richer RFC 9253 relation types or the separate RFC 9074 SNOOZE mapping. Define graph validation, default relation interpretation, dangling references, cross-calendar privacy and publication UID mapping before schema/profile acceptance. Links must not reveal unauthorized target details, grant access, cascade-delete records or reserve resources by implication.

The ordinary URL field does not select a subscription source, import external events or carry another user's credential. URI scheme/length policy and field projection remain explicit decisions. Do not copy arbitrary external URL contents into a feed or mail message.

Automatic repeats must use durable occurrence/repeat identity, positive accepted intervals and finite configured budgets. Validate the RFC repeat/duration pairing and count meaning, reject unsupported/over-limit alarms atomically, and invalidate pending repeat work on alarm cancellation, superseded item/alarm generation or access loss. Exact limits, missed-repeat/expiry behavior and how acknowledge/dismiss/snooze affect remaining repeats still require detailed policy; the choice does not authorize unbounded notification loops or auto-arming imported alarms.

Test basic relationship and URL round trips/native edits, privacy-filtered or missing targets, unchanged authorization and no automatic fetching, plus repeat limits, restart/retry/deduplication, cancellation and multi-device action races. Feed inclusion is still a separate projection choice.

## Confirmed batch 5

| Property/parameter | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| IANA properties | Explicit supported-property allowlist | Registration alone does not imply semantic support; reject unlisted properties explicitly |
| X-properties | Host-configured property allowlist with validation | Accept only configured names/values in approved contexts; unknown/unconfigured names fail explicitly |
| ALTREP | Preserve/export alternate-representation URI metadata | Retain the ordinary text value; retrieval/rendering stays with the host, never automatic module behavior |

These extension policies do not approve all properties from RFCs still under review. Host X-property registration belongs to trusted server configuration/integration, not a client request to bypass validation or authorization. Exact extension registration API, value/parameter/context schemas, limits, edit behavior and disclosure/projection policy remain implementation details for review. Approved extension data must survive supported round trips and unrelated native edits; it cannot change core scheduling/access semantics unless a reviewed adapter explicitly implements those semantics.

ALTREP is accepted only on approved text-property contexts and retains the associated plain text. A metadata URI neither enables HTML rendering in the module nor authorizes fetching content, including local/private endpoints. Host presentation and field disclosure remain explicit. This does not resolve unrelated parameters or the contents of the alternate representation.

Test registered-but-unlisted IANA rejection, unconfigured/invalid X-property rejection, host-configured valid extension round trips, attempted core/permission overrides, metadata limits, native-edit retention, URI no-fetch behavior and plain-text preservation. Unknown/invalid fields fail the whole import under the existing atomic/no-silent-loss policy.

## Confirmed batch 6

| Parameter | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| CN | Participant/organizer display-name metadata in native APIs and interchange | Names do not create user profiles or prove identity/authority |
| CUTYPE | Standard INDIVIDUAL, GROUP, ROOM, RESOURCE and UNKNOWN participant types | Validate identity/resource mappings through the host; a label does not create or reserve a resource |
| DELEGATED-FROM / DELEGATED-TO | Host-authorized meeting participation delegation through native actions and scheduling messages | Host validates the delegate and authority; no calendar ownership transfer or automatic access grant |

Participant metadata remains separate from trusted host identity, group membership and resource booking links. Apply RFC defaults and UNKNOWN handling for unrecognized CUTYPE values without treating a type label as authority. Parameter contexts and method constraints still apply; this does not approve arbitrary extension semantics.

Define and validate delegation state transitions, address mappings, stale/replayed messages and authority changes before implementation acceptance. Unauthorized delegation must fail atomically. SENT-BY acting-sender authority and iTIP VTODO methods remain separate decisions. Test native/interchange name/type retention, spoofed labels, host mapping rejection, authorized and unauthorized delegation, unchanged calendar permissions and resource reservations. Feed projection remains separate from native/scheduling support.


## Confirmed batch 7

| Parameter | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| DIR | Preserve/export directory-reference URI metadata | No automatic lookup, profile import or identity verification |
| FMTTYPE | Validated media-type metadata on file-link attachments in native APIs and interchange | Attachments remain URI-only; do not fetch or inspect file contents |
| LANGUAGE | Language tags for supported text fields and display names in native APIs and interchange | Respect each property's parameter/multiplicity rules; translation and multilingual presentation stay with host/Flutter |

A DIR reference does not establish directory membership or calendar authority. FMTTYPE records declared media type, not verified file content, and cannot enable embedded binary attachments or automatic mail attachment copying. Apply host disclosure rules to metadata on every surface.

Preserve accepted language tags and their association with the correct text/name through unrelated edits and interchange. A language tag does not authorize repeated properties where the RFC forbids them, add automatic translation or select application UI language. Exact validation libraries, limits, native field representation and feed projections remain implementation/profile details. These choices do not automatically expand component/property contexts or RFC extensions still under review.

Test URI-only/no-fetch handling, media-type validation and retention, language-tag syntax and retention on text/display names, Unicode round trips, property cardinality, private metadata masking and atomic rejection of invalid input. No runtime implementation is claimed.


## Confirmed batch 8

| Parameter | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| MEMBER | Native/interchange group/list address metadata with host validation | Imported claims do not prove membership, automatically expand invitees or grant access |
| RANGE=THISANDFUTURE | Native/interchange this-and-future occurrence edits | Preserve occurrence identity and recalculate affected bookings, availability and alarms |
| SENT-BY | Native actions and scheduling interchange for host-authorized acting senders | Host verifies authority for the action; imported parameter text cannot authorize it |

These selections resolve the parameters left open in earlier batches. Membership and acting-sender authority remain host-owned and distinct from participation delegation. Test forged membership/acting-sender claims, revoked authority, privacy masking and retention through supported edits/interchange. Do not create a directory, transfer ownership or infer calendar access.

Apply RANGE according to RFC 5545 sections 3.2.13 and 3.8.4.4: determine subsequent instances by RECURRENCE-ID, retain separately overridden instances, and apply the specified time shift/duration semantics. Arbitrary recurrence-pattern changes require separate series-edit rules; THISANDPRIOR is not approved. Coordinate validation and transactional changes with stale-revision checks and durable alarm invalidation. Do not expand an unbounded series into stored copies.

Test range edits against moved/overridden instances, DST and date-only forms, scheduling updates and feed projections, changed free/busy/search results and stale reminder suppression. Exact storage, supported edit-field semantics, split-series identity rules, iTIP method constraints, numeric limits and VTODO scheduling remain detailed decisions. No runtime implementation or external-client range-edit compatibility is claimed.


## Confirmed batch 9

| Recurrence feature | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| FREQ=HOURLY / MINUTELY | Support native/interchange recurrence with bounded expansion | Calendar occurrences, without precise job/push timing guarantees |
| FREQ=SECONDLY | Defer | Reject explicitly in the initial recurrence profile |
| BYHOUR / BYMINUTE | Support both with limits and RFC-valid combinations | Evaluate rule lists according to RFC expansion/filter semantics |
| BYSECOND | Defer | Ordinary timestamps can still include seconds |

These event-recurrence selections do not approve recurring task lifecycle semantics or alarm delivery guarantees. Preserve the selected rule rather than flattening it into independent events. Exact query windows, expansion/work budgets and diagnostics remain implementation decisions. Exceeding a limit must not produce a falsely complete free/busy or availability-search result; reject or return explicit incomplete coverage under the approved query contract. Never silently truncate feeds/imports or discard deferred rule parts.

Clarification of the review question's time example: BYHOUR=9,14 with BYMINUTE=0,30 produces 09:00, 09:30, 14:00 and 14:30 under a suitable daily rule, rather than two paired times. This does not approve multiple RRULE properties or a new paired-time syntax.

Test hourly/minutely recurrences, list combinations, bounds, DST gaps/folds, overrides, cancellation and alarm invalidation. Test explicit atomic rejection of SECONDLY/BYSECOND, preservation of ordinary timestamp seconds, and no silent partial availability. Parameter legality and handling of malformed date-only rules require explicit parser diagnostics consistent with the documented RFC profile.


## Confirmed batch 10

| Recurrence feature | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| BYYEARDAY | Bounded native/interchange support | Validate signed year-day ordinals, leap years and RFC-valid rule combinations |
| BYWEEKNO | Bounded native/interchange support in yearly rules | Use RFC week-number/year-boundary semantics; no fiscal or school-week calendar service |
| BYMONTH | Bounded native/interchange support | Validate month selections and combinations with other supported rule parts |

These choices extend the event-recurrence profile without approving unresolved WKST/BYSETPOS behavior, recurring task lifecycle semantics or unlimited expansion. Preserve accepted rules through unrelated edits and interchange. Follow the existing explicit rejection, atomic import and no-silent-truncation policies; limit exhaustion must never be reported as complete/free availability.

Test positive/negative year-day and week ordinals, leap/non-leap years, week 53, weeks crossing calendar-year boundaries, month filters combined with day selections, invalid combinations and configured work limits. Add semantic round trips and verify consistent booking, availability and alarm occurrence calculations. Exact budgets, engine selection and field/API representation remain implementation decisions.


## Confirmed batch 11 and completion of undecided-row review

| Recurrence feature | Confirmed first-release choice | Consequence |
| --- | --- | --- |
| BYSETPOS | Native/interchange support with bounded expansion | Select positions among a rule's candidates; no automatic public-holiday exclusions |
| WKST | Support every week-start day, with Monday when omitted | Recurrence semantics remain independent of Flutter's visual week layout |

Apply RFC-valid combinations and evaluation order; BYSETPOS requires another BY rule part. Test positive/negative positions, missing candidate positions, last Monday-Friday weekday of a month, multiple candidate times and work limits. The weekday example does not mean the host's last business day or exclude holidays. Preserve rules through unrelated native edits and semantic round trips.

Test every WKST value, the omitted Monday default, multi-week intervals and BYWEEKNO at year boundaries. Display preferences cannot silently change stored recurrence rules, occurrence identity, bookings or alarm timing. Exact limits and engine selection remain implementation decisions.

The review of all rows explicitly marked Undecided in the RFC 5545 matrix is now complete. All formerly Proposed rows were subsequently selected in the RFC tables. Detailed component/method/combination constraints, recurring-task lifecycle, named-zone/DST validation, alarm lifecycle/projections and numeric limits still need design. This does not accept every ADR proposal, establish full RFC conformance or provide implementation/client evidence.


## Validation required when implemented

Test URI-only import/export and atomic rejection of embedded binary, no network fetch/automatic mail attachment copying, host-managed storage access, searchable labels and host validation, classification masking across surfaces, no automatic PUBLIC disclosure, private attachment metadata and free/busy isolation. No runtime evidence exists yet.

Traceability: [RFC 5545 matrix](../rfc/rfc-5545.md), [requirements](../requirements.md), [interoperability profiles](../compatibility.md) and [interchange work](../roadmap.md#icalendar-and-metadata).
