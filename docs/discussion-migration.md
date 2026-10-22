# Discussion migration and scope evidence

Date: 2026-10-19. Earlier-source status: **partial reconstruction**. This document records provenance; current feature scope lives in the [RFC tables](rfc/README.md) and [requirements](requirements.md).

## Earlier sources and limitations

The earlier conversation was “Summarize iCalendar Compatibility”, conversation ID 6ad5c7e5-93a8-83eb-934a-41ffd5fb19e4. The supplied [shared conversation link](https://chatgpt.com/share/e/6ad5d8ae-3b28-83ed-b9b1-f8369fadb1e8) required sign-in; assistant architecture answers were not recovered. Accessible questions concerned module documentation, a first working project, public library publication, Serverpod versus Stalwart and repository migration. No earlier product comparison or architecture agreement is established here.

The imported creation report recorded inspection of a LICENSE-only repository at b13c228141112b371bfcbab2c56717129c81e450, no issues/PRs at that inspection, and GitHub write attempts rejected with HTTP 403. These are historical reported outcomes, not current GitHub inventory. No branch, commit, issue or PR was created by that import.

The original UTC-only/non-recurring, owner-only proposal and six-issue bootstrap were superseded by direct maintainer instructions. Its patch, PR draft and creation report were removed during cleanup; they are no longer planning inputs. The remaining bootstrap issue drafts were subsequently removed after consolidating useful delivery checks in [the roadmap](roadmap.md). The Apache 2.0 LICENSE is preserved.

## Confirmed scope and decision evidence

Direct instructions in the repository conversation establish Serverpod 4.x+, Mermaid documentation, Gregorian-only dates, external identity references, resource calendars, recurring events and tasks, named zones, free/busy/search, multi-calendar secret feeds with independently revocable URLs and ETags, scheduling, native tasks and first-release alarms/reusable notifications. Flutter provides most GUI; external feed clients consume a narrower declared subset.

Detailed selections are recorded without treating all ADR implementation proposals as accepted:

| Decisions | Record |
| --- | --- |
| RFC 5545 metadata, recurrence filters, host authority and bounded repeats | [ADR 0010](adr/0010-rfc5545-property-decisions.md) |
| Native tasks/interchange retained; all VTODO iTIP/mail deferred | [ADR 0011](adr/0011-defer-vtodo-scheduling.md) |
| RFC 5545 principles in legal availability contexts | [ADR 0012](adr/0012-calendar-availability-policy.md) |
| Per-calendar fallback default free, separate results, optional host-selected subject summaries using intersection, authenticated-only raw rules | [ADR 0012](adr/0012-calendar-availability-policy.md) |
| Promote all 35 formerly Proposed RFC rows to Yes — planned | [RFC scope](rfc/README.md) |
| Gregorian only | [ADR 0013](adr/0013-gregorian-only.md) |
| Selected RFC 7986/9073/9253 metadata and relationship profiles | [ADR 0014](adr/0014-rfc-extension-decisions.md) |
| Restricted iMIP profile; S/MIME deferred | [ADR 0015](adr/0015-restricted-imip-profile.md) |
| ETag-only fixed ICS HTTP profile, explicit errors and private success/no-store error caching | [ADR 0016](adr/0016-subscription-http-profile.md) |
| Recurring tasks included, known named zones initially, standalone VFREEBUSY import deferred | [ADR 0017](adr/0017-profile-review-clarifications.md) |
| Example host/app used for automated testing; more than one concurrently active Serverpod instance supported | [ADR 0018](adr/0018-automated-example-and-multiple-instances.md) |

## Package and notification walkthrough

The maintainer selected one repository for reusable packages and the example host/Flutter app. An optional Flutter calendar UI package is planned for later extraction from the example, without a first-release publication gate. Package names and responsibility boundaries are confirmed in the [scaffolding plan](scaffolding-plan.md), together with the stable SDK policy, Web-first example, local Docker services, self-contained host authentication, local checks before CI and the initial authentication/connection milestone. The maintainer selected a separate reusable notification module, clarified that iOS/Android delivery is illustrative and must not be implemented directly here, and suggested Serverpod server events/streaming for the example. [ADR 0020](adr/0020-notification-delivery-scope.md) supersedes the earlier required platform push path while preserving durable alarm semantics.

## Current interpretation and remaining work

The maintainer identifies the RFC tables as the latest feature-scope source. New explicit instructions take precedence; update the tables and dependent guidance together. Earlier “still under review” statements do not reopen subsequently selected features. No feature rows remain Undecided or Proposed, but row notes and ADRs still identify detailed design work.

Logical package names/responsibilities and the initial example milestone are selected in the scaffolding plan. Physical template layout, host authorization contracts, storage schema, task occurrence lifecycle, temporal validation details, alarm delivery policies, protocol limits and release evidence remain implementation design. Formal ADR acceptance is separate from confirmed feature scope. Recovery of the earlier conversation is optional evidence work and does not block the current requirements.

The initial workspace/authentication scaffold now exists under [ADR 0021](adr/0021-initial-workspace-scaffold.md). Calendar domain behavior and external client compatibility remain unimplemented/unverified; local auth/module smoke evidence is recorded separately. Do not copy personal calendar data or unrelated chat into this repository; use synthetic fixtures.

## Superseding temporal profile

The maintainer subsequently selected whole seconds and ordinary calendar dates from 1970-01-01 inclusive to 2100-01-01 exclusive, keeping the current timezone library and generating future transitions. Nonzero fractions reject without rounding, explicit exclusive endpoints and required UTC spillover are retained, and updates/limitations must be documented. Breaking unpublished APIs are authorized. [ADR 0041](adr/0041-whole-second-1970-2100-profile.md) supersedes the prior microsecond/broad-date/2037 profile; [timezone maintenance](timezone-data.md) records the generation and update process.

## Optional HTTP feed module

The maintainer explicitly confirmed a separate optional Serverpod module for iCalendar HTTP subscription feeds. [ADR 0042](adr/0042-optional-http-feed-module.md) records ownership and dependency direction without claiming implementation or selecting final package names. Calendar APIs, availability and authenticated import/export remain usable without feeds.

## Host-defined authorization context

The maintainer confirmed module enforcement with replaceable host rules and requested clear documentation plus the identity of the requested collection/object. [ADR 0043](adr/0043-host-authorization-context.md) and the [guide](host-authorization.md) record this boundary, distinguish calendar containment from display/feed groupings and retain detailed adapter/query/transaction contracts as proposals. No authorization implementation or mandatory role/owner model was approved by this documentation request.

The subsequent operation review confirmed separate calendar presentation/availability permissions and separate task content/progress/assignment permissions. The [operation catalog](authorization-operations.md) records those choices and keeps remaining action/API details proposed under ADR 0043.

## Authorized query response choices

The maintainer selected separate detail/free-busy responses, authorized initial pages with opaque continuation and no totals, and predefined field-group disclosure. [ADR 0044](adr/0044-authorized-query-projections-and-pagination.md) records those choices; [the query design](authorization-queries.md) keeps filtering algorithms, group mappings, cursor/snapshot behavior and external-policy consistency proposed. No runtime implementation or new feed projection was approved by these choices.

## Declared authorization consistency

The maintainer selected support for transaction-coordinated policies and external authorization services with their guarantee explicitly declared and no silent fallback. [ADR 0045](adr/0045-authorization-consistency-guarantees.md) and [the consistency guide](authorization-consistency.md) distinguish ordered commit/revocation from an external after-check race. No default mode, numeric freshness limit, operation requirement or concrete coordination mechanism was selected; those remain implementation review gates.

## First native calendar CRUD rules

The maintainer selected rejection of deletion while active dependencies remain, an explicit named availability zone at native creation and a nonempty native display name. [ADR 0046](adr/0046-first-native-calendar-crud-contract.md) records these rules. [CRUD](calendar-crud-contract.md) and [adapter interfaces](authorization-adapter-contract.md) are concrete proposals, not implemented/final signatures or physical schemas. No archive/cascade policy, implicit host owner or mandatory ICS NAME was selected.

## Calendar names, UUIDs and deletion markers

The maintainer selected a native UI label separate from preserved imported NAME metadata, server-generated native calendar UUIDs without a specific UUID-version requirement, and minimal UUID/scope/revision/deletion-time markers after dependency-safe deletion. Markers retain no calendar label/content, are hidden from ordinary APIs and provide no archive/restore behavior. [ADR 0047](adr/0047-calendar-names-identifiers-and-deletion-storage.md) and [storage guidance](calendar-storage.md) preserve physical layout, text validation, purge/retention duration and generator verification as implementation gates.

## Native name validation and identity/data rows

The maintainer selected a 256-Unicode-code-point native display-name cap, outer trimming with blank/multiline rejection and internal spacing/Unicode preservation, and separate identity/active-data rows. [ADR 0048](adr/0048-calendar-name-validation-and-row-layout.md) and [schema guidance](calendar-schema.md) record these choices. Surviving identity rows do not imply indefinite retention; exact validation/raw-byte limits, generated keys/metadata/indexes and concrete coordination remain proposed.

## First native CRUD scope

The maintainer selected duplicate native display names, private scopes per signed-in demo user only in the example, and basic calendar CRUD/subject associations before description/color/iCalendar metadata editing. [ADR 0049](adr/0049-first-calendar-crud-implementation.md) distinguishes those confirmed choices from the concrete implementation mechanics under review. [The implementation guide](calendar-crud-implementation.md) supersedes earlier blanket scaffold-only statements for this limited slice.

## Native presentation and protocol text increment

[ADR 0050](adr/0050-calendar-presentation-and-protocol-text.md) records maintainer-confirmed separation of native/protocol values, RGB versus CSS3 colors, preserved multiline native descriptions with a 16,384-code-point cap, and a first NAME/DESCRIPTION/COLOR editing batch. [The implementation guide](calendar-metadata.md) distinguishes scoped native editing/storage from pending parsing/export/feed publication. Native URLs, categories, images and refresh hints are implemented in the ADR 0051 increment below; source/property-parameter preservation and wire support remain pending.

## Links, categories, images and refresh increment

The maintainer selected HTTP/HTTPS links without user information, exact case-sensitive category text matching with optional language tags, and positive unit-preserving refresh hints with a one-year editing cap. [ADR 0051](adr/0051-calendar-links-categories-images-refresh.md) defines the cap as 365-day equivalent and keeps schema/limit/query mechanics under review. [The guide](calendar-links-and-categories.md) records this limited native FR-02/08/24 increment, including group-authorized category filtering, no link/image fetching or polling and pending parser/export/feed work.

## Native calendar protocol identity/time increment

The maintainer confirmed separate generated native calendar protocol UIDs and automatic whole-second UTC modification time for calendar metadata/settings/association changes. [ADR 0052](adr/0052-calendar-protocol-identity-and-revision-time.md) and [the guide](calendar-protocol-identity.md) describe read-only independent disclosure, shared database time, stable UID/backfilled upgrades and unchanged minimal deletion markers. This limited FR-02/08/24 increment does not implement imported-source identity, full VCALENDAR change tracking or feed validators; event/task and publication changes require separate handling.

## First native event increment

The maintainer selected non-recurring CRUD first, optional/empty summary with an example-only placeholder, separate cancellation/content deletion and separate lifecycle permission. [ADR 0053](adr/0053-first-native-single-events.md) and [the guide](native-single-events.md) describe this scoped FR-03/04/08/27 implementation, typed core timing, actual parent/event host context, bounded authorized lists, transactional revisions and minimal deletion markers. Recurring event persistence/occurrence edits, full metadata, free/busy, scheduling, alarms and ICS/feed interoperability remain pending; event changes do not update the parent calendar's metadata time.

## Native event recurrence increment, 2026-10-21

The maintainer selected recurrence storage/bounded API and example previews first, preserving and validating explicit inclusion/exclusion dates during pattern replacement. [ADR 0054](adr/0054-native-event-recurrence-and-previews.md) and [the native guide](native-event-recurrence.md) describe the FR-03/04/08 increment: DATE/UTC/named-zone definitions, sorted filters/dates, actual parent/event/query policy context, separate preview authority/timing disclosure and complete-or-failure overlap queries. Individual/future occurrence editing, cross-event chronological queries and complete availability, ICS/feed and external-client interoperability remain pending. Existing temporal/ISO/WKST/profile guards remain unchanged. This updates earlier statements that all recurring event persistence remains pending; it does not complete recurrence edit lifecycle or the first release.

## Native occurrence timing increment, 2026-10-21

The maintainer selected timing edits for one/this-and-future, single cancellation/restoration, preservation with orphaning-pattern rejection, and deferred future cancellation. [ADR 0055](adr/0055-native-occurrence-timing-edits.md) and [the guide](native-occurrence-timing.md) describe this FR-03/04/08/27 increment. Dedicated actions preserve original identity and master content, use current event revision and actual parent/event/action policy context, and revalidate retained overrides during master changes. Summary/description/location/status/transparency remain on the series. This supersedes earlier blanket pending statements for native timing edits only; content overrides, future cancellation, availability, ICS/feed/scheduling and alarm execution remain pending.

## First per-calendar free/busy increment, 2026-10-21

The maintainer selected per-calendar free/busy before RFC 7953 working-hours rules and subject/common-slot search, with tentative opaque bookings blocking time and classified separately. [ADR 0056](adr/0056-first-calendar-free-busy.md) and [the guide](calendar-free-busy.md) describe this partial native FR-16/17/27 implementation: independent calendar/source busy authority, complete/unknown coverage, effective recurring/overridden booking intervals, saved fallback, UTC classifications and no private source identities/counts. Limits/denied coverage cannot appear free. Broader RFC 7953 metadata/override/interchange support, cross-scope/group-expansion coordination, VFREEBUSY serialization, scheduling, alarms and external-client/feed interoperability remain pending.

## Native working-hours increment, 2026-10-21

The maintainer selected optional definition validity bounds and explicit UTC/named-zone timing per opening, independent of the calendar's all-day zone. The approved batch adds recurring hours/inclusion/exclusion dates, priority, closed-time type and per-calendar composition; rich metadata and opening-occurrence overrides follow separately. [ADR 0057](adr/0057-native-working-hours.md) and [the guide](native-working-hours.md) distinguish the native implementation from remaining full RFC 7953 interchange, subject/common-slot search and feed/client evidence. Source projection remains independent from raw rule disclosure; denied or incomplete coverage never establishes free time.

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

The maintainer selected VEVENT as the next component adapter after the temporal codecs, and requested named-zone events with VTIMEZONE validation in that first component batch. [ADR 0064](adr/0064-first-vevent-and-zone-validation-contract.md) records the subsequent confirmed full-horizon 1970–2099 matching requirement and permission to read earlier observance seeds solely for in-profile calculation. This is planned scope, not implemented component support; event storage bounds are unchanged.

## First standalone event adapter, 2026-10-22

[ADR 0065](adr/0065-first-vevent-wire-adapter.md) and [the profile guide](icalendar-event-adapter.md) implement pure non-recurring VEVENT mapping for DATE/UTC/named-zone spans, basic text/state and source protocol metadata. Supplied VTIMEZONE definitions must match pinned IANA offsets over the full profile plus calculation-only UTC edges; the maintainer selected bounded explicit/yearly observances and validation-only earlier seeds. Accepted source syntax is retained; unsupported components/properties/parameters fail before any semantic result. This supersedes older blanket wire-pending wording only for the documented subset. No database import/identity reconciliation, authorized export, scheduling/alarm activation, HTTP feed or external-client compatibility is claimed.

## Recurring event master wire increment, 2026-10-22

The maintainer selected recurring VEVENT masters next, leaving PERIOD additions and separate occurrence-override components to later batches. [ADR 0066](adr/0066-recurring-vevent-master-adapter.md) and [the guide](icalendar-recurring-masters.md) implement typed RRULE/start-only RDATE/EXDATE mapping, strict grammar/profile/DTSTART checks, retained source and calendar-wide raw/work limits. Canonical core semantics preserve earlier inclusions, EXDATE precedence, COUNT, explicit WKST and DST behavior. Output puts FREQ first without altering retained source. This supersedes older recurrence-wire-pending wording only for the master subset; database import/export, identity reconciliation, scheduling/alarms and HTTP feeds remain pending.

The maintainer selected PERIOD-valued RDATE additions as the next dedicated batch after recurring masters, with separate occurrence-override components following. That ordering is confirmed; detailed PERIOD wire/profile handling remains to be implemented and reviewed.

## PERIOD wire increment and next occurrence batch, 2026-10-22

The maintainer selected PERIOD-valued RDATE next. [ADR 0067](adr/0067-vevent-period-additions.md) implements pure timed pair adaptation with preserved core forms and existing conflict/profile/limit rules; native storage/import/export remain separate. For the following occurrence-component batch, the maintainer selected single timing changes/cancellation and timing-only THISANDFUTURE mapped to the existing core. Per-occurrence content changes and future cancellation will reject explicitly until separately profiled; that next batch is not implemented here.

## Scoped occurrence-component increment, 2026-10-22

[ADR 0068](adr/0068-vevent-occurrence-components.md) adds pure [single timing/cancellation and timing-only THISANDFUTURE component adaptation](icalendar-occurrence-components.md) to the existing core, preserving original identities, source metadata and bounded rejection. This is the maintainer-approved next feature batch. The maintainer also confirmed the matching in-file master requirement and omission-based content inheritance with supplied differences rejected; API/limit mechanics remain reviewable. It supersedes older blanket occurrence-wire-pending wording only for this subset; per-occurrence content/future cancellation, authenticated database import/export, scheduling/alarms and feeds remain pending. No external-client compatibility is claimed.

## Scoped availability wire increment, 2026-10-22

The maintainer selected the timing/composition-first slice and positive opening intervals under [ADR 0069](adr/0069-first-availability-wire-adapter.md). [The pure adapter](icalendar-availability-adapter.md) maps standalone VAVAILABILITY/AVAILABLE timing/recurrence/overrides, priority/BUSYTYPE, basic text and source protocol timestamps to bounded core composition inputs. This supersedes older blanket availability-wire-pending wording only for that subset. Rich metadata (including organizer/contact/extensions), authenticated database import/export, host authorization/reconciliation, scheduling/alarms and HTTP publication remain pending; no external-client compatibility follows.

The maintainer selected availability publication metadata as the next batch before database import: organizer, URL/class, categories/comments/contact and profiled text parameters/extensions, with no authority inferred from source addresses and no network retrieval. This ordering is confirmed; the metadata adapter is not implemented in the timing/composition increment.
