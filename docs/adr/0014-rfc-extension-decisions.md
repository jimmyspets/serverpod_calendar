# ADR 0014: Calendar metadata and extension profiles

Status: **Selected scope confirmed; implementation pending**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

Current-scope note: these batches preserve decision order. Later batches resolve the earlier references to separate review items. All listed RFC 7986/9073/9253 statuses are now selected; consult the current RFC tables for the resulting scope and this record for rationale.

## Context and source

This record consolidates the initial calendar-metadata/extension review into the selected profile. Scope follows the RFC tables; baseline metadata identity, publication and validation guidance is retained below.

The maintainer requested continuation through remaining Undecided RFC rows, then selected all three recommendations in the first RFC 7986 batch. This record captures new decisions separately from the earlier RFC 5545 review and blanket promotion of Proposed baselines.

## Calendar/feed metadata baseline

The selected RFC 7986 baseline includes NAME, DESCRIPTION, stable calendar/feed UID, persistent LAST-MODIFIED and optional COLOR. Authorized metadata changes are revisioned and alter the representation/ETag only when published output changes. Exact cardinalities, language variants and limits remain implementation constraints.

Each logical feed has its own name, description and publication identity; aggregate metadata is not an arbitrary concatenation of source calendars. Multiple URLs for the same feed share metadata and identity; revoking a URL does not rename or recreate that feed. Calendar UID, event/series UID, scheduling UID and bearer credentials have distinct roles.

Exclude SOURCE from subscription output and never use a secret subscription URL as public metadata identity or expose another credential. URI metadata does not authorize retrieval. Unsupported input fails explicitly without silent loss. Any legacy metadata fallback requires measured client evidence and an explicit extension profile.

## RFC 7986 batch 1: confirmed

| Property | Selected scope | Boundary |
| --- | --- | --- |
| URL | Editable calendar/feed alternative-representation link in native APIs and interchange | No automatic fetching; distinct from secret subscription URLs; never expose another credential |
| CATEGORIES | Searchable free-form calendar labels with host validation | Separate from event/task labels, ownership and permissions; no automatic label inheritance |
| REFRESH-INTERVAL | Host-configurable suggested minimum polling interval, with native metadata/interchange and feed output | A hint only; does not schedule client fetches, replace ETag/access checks or guarantee refresh timing |

Apply calendar/feed management authorization, revision checks, field disclosure and atomic import validation. Aggregate feeds have their own metadata; do not automatically merge labels or select one source calendar's URL. URI metadata does not authorize access to its target or network retrieval.

Validate positive duration syntax and the required VALUE=DURATION wire parameter for REFRESH-INTERVAL. Preserve accepted metadata through unrelated edits and supported round trips. Only host-authorized management may configure the effective feed hint; importing a hint must not create polling jobs. Published metadata changes participate in deterministic representation/ETag calculation.

## RFC 7986 batch 2: confirmed

| Property/parameter | Selected scope | Boundary |
| --- | --- | --- |
| SOURCE | Preserve imported refresh-source URI privately for authenticated interchange | Retain through unrelated edits; no native creation/editing, subscription output, automatic fetch or upstream synchronization |
| IMAGE | Native/interchange calendar image URI links only | Host manages files/access; module does not store embedded binary, download, resize or serve images |
| DISPLAY on IMAGE | Native/interchange standard image presentation hints | BADGE, GRAPHIC, FULLSIZE and THUMBNAIL; host/Flutter controls rendering; distinct from alarm ACTION=DISPLAY |

SOURCE can contain private source information. Apply authenticated export/read permissions and host disclosure, omit it from all subscription output, and never copy one credential into another feed. Do not log raw source values where that would expose credentials. Preservation does not create an upstream subscription or update job.

Use IMAGE only in the selected calendar context; event/task image contexts remain separate. Validate URI wire syntax and accepted metadata without retrieving image content. Preserve optional FMTTYPE as declared media-type metadata under the shared validation/no-inspection policy. Host presentation decides whether/how to load a disclosed link; calendar access alone grants no file access.

Follow RFC DISPLAY default/unknown-value handling rather than inferring a safe visual role for an unrecognized token. Standard hints do not require every target client to render images. Exact URI/media/size/count limits, allowed schemes and output projections remain implementation details.

Test private SOURCE retention and subscription omission; image link/hint native edits and semantic round trips; atomic rejection of binary/invalid input; no network retrieval/resizing; file-access/disclosure isolation and unrelated-edit retention. No runtime or client-image compatibility is claimed.

## RFC 7986 batch 3: confirmed

| Property/parameter | Selected scope | Boundary |
| --- | --- | --- |
| CONFERENCE | Native/interchange event/task access-link metadata | Creating meetings, joining calls and provider integration stay with host/Flutter; VTODO scheduling mail remains deferred |
| EMAIL | Native/interchange contact email on organizer/attendee metadata, with host validation/disclosure | No contact directory, identity proof, automatic routing authority or scheduling permission |
| FEATURE / LABEL | Native/interchange standard conference capability tags and editable human-readable labels | Host disclosure keeps moderator-only links/codes away from ordinary attendees |

These selections complete the RFC 7986 matrix's explicitly Undecided rows. CONFERENCE is event/task metadata, not a VCALENDAR property. LABEL is selected here only for CONFERENCE; RFC 9253 relationship contexts remain separate. Preserve RFC multiplicity, value/parameter constraints and accepted language metadata.

Treat conference access URIs and labels as potentially sensitive. Do not expose moderator credentials by dropping only the MODERATOR tag while retaining its link, by copying codes into generic descriptions/labels, or by publishing them through aggregate feeds. Filter the whole restricted record and its associated metadata under host disclosure policy. Meeting access links remain distinct from subscription credentials.

Validate EMAIL as metadata without accepting imported addresses as verified identities or trusting them as recipients for outbound mail. Scheduling ingress and routing continue to require host-verified authority/address mappings. Do not create profiles, automatically send mail or bypass the deferred VTODO methods.

Test native edits and semantic round trips, multiple links/tags/labels, language handling, invalid values and atomic rejection, no network/provider operations, spoofed EMAIL and moderator/attendee projection isolation. Exact tag-extension handling, URI/value limits, native schemas and per-surface projections remain implementation/profile details. No external-client conferencing compatibility is claimed.

## RFC 9073 batch 1: confirmed

| Component | Selected scope | Boundary |
| --- | --- | --- |
| PARTICIPANT | Native/interchange event/task structured participant metadata | Host validation/disclosure; no identity-directory records, ATTENDEE replacement or automatic invitations |
| VLOCATION | Native/interchange event/task structured location records | Host retains room/venue identities, authorization, maps and address lookup; metadata alone does not reserve rooms |
| VRESOURCE | Native/interchange event/task structured equipment/resource metadata | Host validates identity links; metadata does not create equipment-directory records or reserve resources |

Keep stable component identity separate from trusted host subject mappings. A matching name, URI or imported UID must not establish an identity link, grant permissions or add an availability contribution automatically. Booking still requires explicit authorized resource associations and normal booking semantics; native task dates alone remain nonblocking.

These component selections require an explicit legal child/property profile before input acceptance, including mandatory fields. Detailed types, shared core fields, calendar addresses, nesting, styled descriptions and structured data remain separate review items. Do not infer every optional property or an unlimited nesting tree. VTODO scheduling mail remains deferred.

Test native management and semantic round trips once the field profile is selected, privacy-filtered projections and unrelated-edit retention, forged mappings, identity collisions and unchanged booking/access state. Separate native/interchange evidence from the subscription subset; component serialization alone does not prove external client rendering.

## RFC 9073 batch 2: confirmed

| Property | Selected scope | Boundary |
| --- | --- | --- |
| LOCATION-TYPE | Native/interchange standardized categories from the RFC-referenced location vocabulary, with host validation | Describes location use; does not replace host room/resource kinds or alter bookings/availability |
| PARTICIPANT-TYPE | All standard RFC categories with host validation/disclosure | ACTIVE, INACTIVE, SPONSOR, CONTACT, BOOKING-CONTACT, EMERGENCY-CONTACT, PUBLICITY-CONTACT, PLANNER-CONTACT, PERFORMER and SPEAKER |
| RESOURCE-TYPE | Native/interchange standard resource categories with host validation | ROOM, PROJECTOR, REMOTE-CONFERENCE-AUDIO and REMOTE-CONFERENCE-VIDEO; additional registered values require explicit profile approval |

PARTICIPANT-TYPE remains mandatory with the component's RFC cardinality. Participation categories do not prove identity, grant host permissions, replace ATTENDEE role/status or change task assignments. Resource categories neither create catalog entries nor reserve equipment. Descriptive ROOM/PROJECTOR values cannot establish a host subject mapping by themselves.

Use the LOCATION-TYPE vocabulary referenced by RFC 9073 rather than reinterpreting arbitrary host labels as standardized values. Registration alone does not approve extra resource values or fetch registry/schema data at runtime. Exact versioned vocabulary representation, limits and diagnostics remain implementation details; unsupported or host-invalid input fails explicitly and atomically.

Test accepted standard categories, legal multiplicity, required/missing/duplicate participant types, invalid/unapproved values, host validation, native edits/round trips and privacy. Changes to metadata types must not change access, identity links, assignments, bookings or availability contributions.

## RFC 9073 batch 3: confirmed

| Property | Selected scope | Boundary |
| --- | --- | --- |
| CALENDAR-ADDRESS | Native/interchange structured participant calendar address with host-validated mappings | Matching ATTENDEE can associate metadata; imported text does not establish identity, create invitations or authorize scheduling |
| STYLED-DESCRIPTION | Native/interchange event/task links to host-managed rich content, retaining plain-text DESCRIPTION | URI values only; no inline HTML, automatic fetching or rendering |
| STRUCTURED-DATA | Native/interchange links to associated data in events/tasks and approved structured components | URI values only; no embedded text/binary, automatic fetching or identity-directory import |

Calendar addresses remain metadata in legal PARTICIPANT contexts. Preserve valid address data and authorized associations across edits, without converting a publication participant into an invitee. A matching scheduling address is not proof of a host subject identity or booking authority.

Host content services own rich content/data files, access and presentation. Retain the ordinary plain-text description rather than retrieving a URI to construct it. No automatic vCard import, JSON interpretation/indexing, network/schema retrieval or new recurrence/booking semantics follows from a link. VJOURNAL and unapproved contexts remain excluded; VTODO scheduling mail remains deferred.

Reject inline STYLED-DESCRIPTION text and STRUCTURED-DATA text/binary explicitly and atomically under this selected profile, rather than dropping or fetching them. SCHEMA/FMTTYPE metadata, ORDER/DERIVED and detailed nesting/shared core profiles remain separate review work.

Test native edits, semantic round trips and unrelated-edit retention; plain-text preservation; no network/rendering/import side effects; rejected inline forms, malformed values and unsupported contexts; privacy-filtered exports; forged address mappings and unchanged invitations/access/bookings. Exact URI/media/size/count limits and source-content consistency remain implementation details.

## RFC 9073 batch 4: confirmed

| Parameter | Selected scope | Boundary |
| --- | --- | --- |
| ORDER | Native/interchange positive presentation ordering in legal contexts | Deterministic handling of ties; no access, scheduling or booking priority |
| SCHEMA and associated FMTTYPE | Native/interchange schema URI and declared media-type metadata on structured-data links | No schema/content fetching, remote-document validation or content interpretation |
| DERIVED | Preserve/export marker; DERIVED=TRUE values read-only to ordinary native clients | Trusted host source-update logic controls changes; no automatic conversion or general derivation engine |

ORDER applies only where the RFC allows it. Respect omitted-order and equal-order semantics; any deterministic tie-breaking is presentation/serialization behavior rather than added protocol precedence. Validate positive integer values and applicable cardinalities.

SCHEMA/FMTTYPE describe linked data without asserting that its contents were inspected or validated. Preserve the link and metadata through unrelated edits and supported interchange. Shared URI/media validation and host disclosure apply; this does not enable inline payloads or automatic schema-based indexing.

Enforce derived-field read-only behavior server-side, including attempts to clear the marker and change the value in the same ordinary client write. Imported flags cannot establish source authority, suppress authorization or make trusted host identity/booking state client-controlled. Exact source linkage, host update API and stale-derived-value policy remain implementation details. Preserve accepted markers through unrelated changes, without retrieving a source or inventing a conversion pipeline.

Test legal ordering/defaults/ties and invalid contexts, URI/media metadata validation/round trips, no network/content processing, derived edit rejection and host-authorized updates, marker-clearing bypass attempts, transaction/revision conflicts and private-field disclosure.

## RFC 9073 batch 5: confirmed

| Feature | Selected scope | Boundary |
| --- | --- | --- |
| Nested components | Native/interchange bounded RFC-defined structure | Events/tasks contain participants, locations and resources; participants may contain locations/resources; no arbitrary recursive trees |
| Shared core properties | Reuse selected native/interchange field policies in legal contexts | Explicit per-component allowlists; stable identity, plain text, URI-only content and import-only CONTACT remain consistent |

Configure count/depth/work limits and reject unsupported or over-limit structure atomically. VLOCATION/VRESOURCE remain leaf components in this structure. This does not approve VJOURNAL, rich private metadata in VFREEBUSY, event/task images or arbitrary extension children. VALARM remains its own profile.

Participant location information requires participant permission for disclosure, enforced by host policy; calendar access alone does not establish it. Apply this to nested coordinates/references and derived export fields so flattening or alternate metadata cannot bypass disclosure. Availability-only results reveal no private location details.

Reuse only legal fields with their mandatory/cardinality rules, rather than copying the event schema wholesale. Apply existing host-validated labels, text notes/descriptions, URI-only attachments/links, coordinate validation, managed metadata and import-only CONTACT where accepted. Field presence never creates identities, permissions, bookings or directory entries.

Test nested round trips/edit retention, required/duplicate/illegal fields, depth/count limits and atomic rejection, participant disclosure permissions and identity/booking isolation. This completes the Undecided-row review without claiming every RFC combination or external client compatibility. Exact allowlists, schema and configured limits still require implementation review.

## RFC 9253 batch 1: confirmed

| Property | Selected scope | Boundary |
| --- | --- | --- |
| CONCEPT | Native editing/search and interchange of formal event/task category URIs with host validation | Separate from free-form CATEGORIES; no fetching, inferred hierarchy or permission changes |
| LINK | Native/interchange typed related links with host validation | Distinct from ATTACH and URL; no automatic fetching or access inheritance; target/relation profile reviewed separately |
| REFID | Native editing, authorized search/grouping and interchange of event/task grouping keys | No project service, automatic dependencies, identity/group authority or unauthorized calendar search |

Apply server-side authorization to every search result and linked/grouped object. Matching REFID or CONCEPT values do not prove host group membership or grant read access. Do not expose inaccessible objects through result counts, key discovery, link labels or target identifiers. Exact tenant/calendar query scope, key collision policy and cross-calendar behavior remain detailed decisions.

Preserve accepted values through unrelated edits and semantic round trips. CONCEPT stores a formal reference without downloading a vocabulary or inferring descendants; exact matching/normalization remains an explicit profile choice. REFID is a grouping key, not a calendar-item identity, task parent, recurrence identifier or automatic workflow.

LINK selection does not approve every target value type, relation or external-data interpretation. Validate its required parameters and selected target forms once those choices are recorded. No URI, UID or matching grouping key overrides existing host mappings, permissions, availability contributions or booking state.

Test native edits and authorized queries/grouping, collisions/isolation, invalid input and atomic rejection, no network requests, private target/key disclosure and stable edit/round-trip retention. Exact values/limits, indexing, allowed contexts and projection policies remain implementation details. VTODO scheduling mail remains deferred.

## RFC 9253 batch 2: confirmed

| LINK target form | Selected scope | Boundary |
| --- | --- | --- |
| VALUE=UID | Native/interchange component UID targets | Explicit identity scope, independent target authorization and source-to-publication UID mapping on export |
| VALUE=URI | Native/interchange validated URI metadata targets | No fetching/access inheritance; host disclosure protects private identifiers and subscription credentials |
| VALUE=XML-REFERENCE | Defer | Explicit unsupported-input rejection; no XML/XPointer evaluation or silent conversion to URI |

This selects LINK target forms, not every RELATED-TO extension or cross-calendar behavior. Preserve stable canonical targets through unrelated edits and ordinary interchange. Resolve UIDs in an explicit host/calendar context; a matching raw UID is not globally sufficient identity or proof of access. Ambiguous identities must not link arbitrarily.

Published links require deliberate mapping to the target representation's identity when that target is in an approved projection. Do not expose canonical/private identifiers or invent a published target for excluded data. Detailed handling of missing/filtered/dangling targets and cross-calendar links remains profile work. Knowledge of a UID/URI never reserves time, changes availability contributions or grants scheduling authority.

A URI can identify external content without authorizing retrieval or interpretation. Reject typed XML-REFERENCE input atomically instead of dropping its type/fragment or importing it as ordinary URI metadata. This does not forbid ordinary URI syntax solely because its path names an XML document.

Test native target edits and semantic round trips, equal UIDs in distinct calendar scopes, ambiguous/missing/private targets, correct stable publication mapping, credential masking, no fetching/XML evaluation and atomic rejection of deferred forms. VTODO scheduling mail remains deferred.

## RFC 9253 batch 3: confirmed

| Feature | Selected scope | Boundary |
| --- | --- | --- |
| LINKREL | Native/interchange host-configured allowlist of registered relation names and approved extension URIs | Relation metadata does not execute fetching/workflows; behavior requires an explicitly implemented feature |
| LINK descriptive metadata | Editable LABEL, target LANGUAGE and declared FMTTYPE in native APIs/interchange | Shared validation/disclosure; labels/type hints do not verify target contents or authorize retrieval |
| Cross-calendar links | Authorized event/task links within host-permitted scope | Independent source/target access, privacy-aware export/UID mapping; no access inheritance or automatic cascade deletion |

Trusted host configuration controls relation registration; a client cannot whitelist its own relation to bypass validation. Validate required relation/value parameters and approved contexts. Preserve accepted metadata through unrelated edits and supported round trips; no automatic registry retrieval or arbitrary extension execution.

Link writes require authorization to manage the source and the host's permitted target association. Reads, navigation and exports independently enforce current target access/disclosure. Knowledge of a UID/URI, a label or previous access must not leak inaccessible target identifiers/details or confer permission. Define dangling/deleted/filtered-target representation explicitly before implementation; errors and result counts must not become an existence oracle.

Retain distinct canonical and publication identities when exporting approved cross-calendar links. Do not publish excluded task/private targets through event feed metadata. Deleting a link or either component does not automatically delete related items, change bookings or execute dependencies. Schema, tenant/reference scope and limits remain implementation details.

Test host allowlist validation, invalid/missing parameters, metadata edit/round-trip retention, authorized cross-calendar navigation, revoked target access, private identifier/label filtering, stable publication mapping and deletion without cascading mutations.

## RFC 9253 batch 4: confirmed

| Feature | Selected scope | Boundary |
| --- | --- | --- |
| RELATED-TO target forms | Native/interchange updated legal UID/URI forms | Preserve UID targets for PARENT/CHILD/SIBLING; URI targets are not fetched; relation type/value combinations remain explicit |
| RELTYPE=REFID / CONCEPT | Native/interchange group references with bounded authorized lookup | Match grouping keys/category references without identity groups, inherited access or automatic bulk actions |
| RELTYPE=FIRST / NEXT | Native/interchange ordering references with validation and bounded traversal | No recurrence-master inference, recurrence edits, automatic rescheduling or cascading deletion |

Preserve ordinary RFC 5545 relationship compatibility. Do not mechanically convert every RELATED-TO value to a URI or infer a relation from target syntax. Selected group relations match the approved REFID/CONCEPT values; they do not make an inaccessible matching item visible or authorize a workflow over a changing result set.

Ordering links describe calendar-item order, not event occurrence identity or time. Validate structure and bound navigation. Define missing/deleted targets, self-reference, cycles and concurrent edits explicitly before implementation; traversal must not loop or disclose inaccessible items. This does not approve general dependency execution or every temporal relation.

Normative target constraint clarified from RFC 9253 section 2: LINK VALUE=UID refers within one collection. Cross-collection links use permitted URI targets rather than interpreting a raw UID globally. Define collection scope and import/publication transformations explicitly; ambiguity must not select an arbitrary object. This refines the earlier scoped-identity decision without removing authorized cross-calendar links.

Test native edits/round trips, legal/invalid relation-value combinations, legacy hierarchy compatibility, group-query isolation, ordered traversal limits and dangling/cyclic references. Include same-collection UID resolution versus cross-collection URI representation and stable privacy-aware publication mapping.

## RFC 9253 batch 5: confirmed

| Feature | Selected scope | Boundary |
| --- | --- | --- |
| FINISHTOSTART / FINISHTOFINISH / STARTTOFINISH / STARTTOSTART | Native/interchange declared temporal dependency metadata with validation/authorization | No automatic date changes, task-transition blocking, reservations or workflow execution |
| GAP | Native/interchange bounded signed duration metadata on temporal relationships | Validate duration/context and configurable limits; no scheduling, working-day or holiday calculations |
| DEPENDS-ON | Native/interchange general dependency reference with authorized bounded inspection | No automatic completion blocking, status propagation or rescheduling |

Retain each relationship's RFC direction and meaning in native models/interchange. Declared constraints are inspectable data rather than an engine enforcing dates or task readiness. Existing booking/free-busy behavior derives from explicit events/reservations, not dependency edges or GAP. Host workflow integrations can use the data through authorized interfaces; importing it cannot trigger such integrations implicitly.

Validate structural/property/value constraints and preserve signed duration units without converting nominal day/week intervals into fixed seconds that change meaning. Exact numeric budgets, graph validation/cycle handling, missing targets, status conflict reporting and host integration APIs remain detailed implementation choices. Do not silently fix dates, invert edges or discard unsupported graph data.

Test all four direction mappings, signed lead/lag and zero/invalid/over-limit values, native edits and semantic round trips, private/cross-calendar target authorization and bounded traversal. Verify dependency/GAP edits alone cannot alter task lifecycle, booked time, other dates, alarm schedules or external workflows.

This completes the RFC 9253 matrix's explicitly Undecided rows. XML-REFERENCE remains deferred. All features are planned, unimplemented and unverified; no complete RFC or external-client conformance is claimed.

## RFC 6047: confirmed

The maintainer selected component hints and explicitly deferred S/MIME signatures/encryption, accepting a restricted profile. [ADR 0015](0015-restricted-imip-profile.md) records the protocol limitation, host authority boundary and rejection behavior. This resolves all RFC 6047 Undecided rows without claiming full conformance.

## HTTP review handoff

The maintainer selected ETag-only initial HTTP validation, deferred byte ranges and fixed ICS output. [ADR 0016](0016-subscription-http-profile.md) records these and subsequent HTTP/cache decisions separately from calendar extension fields.

## Alternatives and open details

Import-only preservation or deferral would provide less native metadata support than selected. Batches 2 and 3 subsequently resolve calendar SOURCE/IMAGE/DISPLAY and event/task CONFERENCE, organizer/attendee EMAIL and conference FEATURE/LABEL. Other component contexts and RFC extensions remain separate. Exact URI/duration limits, defaults, label normalization/query details, aggregate metadata initialization and per-surface projection remain implementation/profile choices.

## Acceptance conditions

Test baseline metadata through independent fixtures, semantic round trips, authorized metadata edits and unchanged/changed ETags. Record feed name/description/color behavior in the selected Apple/iOS, Google and Outlook variants; valid syntax alone does not establish rendering. Keep participant/location/alarm data and credential-bearing links out of unauthorized feed, free/busy and scheduling projections. Publication metadata never creates host identities, permissions or bookings.

Test native URL/label/hint management, host validation, metadata round trips/edit retention, no fetching, credential isolation, no permission escalation and aggregate metadata separation. Validate malformed/nonpositive refresh durations atomically, correct wire parameters and stable/changed validators. Client rendering/refresh behavior needs independent evidence; no implementation exists yet.

Sources: [RFC 7986 sections 5.5–5.7](https://www.rfc-editor.org/rfc/rfc7986.html#section-5.5).

Traceability: [RFC 7986 matrix](../rfc/rfc-7986.md), [requirements](../requirements.md), [compatibility](../compatibility.md), [metadata work](../roadmap.md#icalendar-and-metadata).
