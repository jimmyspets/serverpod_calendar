# Delivery roadmap

Status: first-release scope selected; detailed contracts, implementation and release evidence remain pending. The [RFC tables](rfc/README.md) are the latest feature-scope source. [Requirements](requirements.md) define stable FR/NFR acceptance targets; [ADRs](adr/README.md) distinguish confirmed scope from proposed implementation details.

This roadmap consolidates the useful delivery checks from the removed bootstrap drafts. It is the current planning document; no GitHub issues are created by this cleanup. Check existing GitHub work before filing issues, and link each implementation issue to the relevant requirements and roadmap section.

## Work packages and dependencies

| Work package | Requirements / decisions | Prerequisites |
| --- | --- | --- |
| [Design contracts](#design-contracts) | Selected RFC profiles and detailed ADR review | Current scope is available; earlier-source recovery is optional |
| [Scaffolding](#scaffolding) | FR-01; NFR-03/06; ADR 0001 | Package/boundary decisions |
| [Temporal core](#temporal-core) | FR-03/04/05/06; ADRs 0002/0013/0017 | Scaffolding and temporal contracts |
| [Persistence and authorization](#persistence-and-authorization) | FR-02/03/04/07/08/09; ADRs 0003/0005 | Scaffolding and core types |
| [iCalendar and metadata](#icalendar-and-metadata) | FR-06/07/08/24; ADRs 0010/0014 | Core, persistence and legal profile constraints |
| [Tasks](#tasks) | FR-25/27; ADRs 0008/0011/0017 | Core, persistence and task lifecycle/interchange contracts |
| [Feeds](#feeds) | FR-10/11/12/13/14; NFR-04/07/08; ADRs 0004/0016 | Persistence and iCalendar output |
| [Availability](#availability) | FR-15/16/17/18/19/26/27; NFR-09; ADRs 0006/0008/0012 | Core, persistence and bounded interchange |
| [Scheduling](#scheduling) | FR-20/21/22/23; NFR-10/11; ADRs 0007/0011/0015 | Core, persistence, interchange and availability |
| [Alarms and push](#alarms-and-push) | FR-28/29/30/31; NFR-12/13; ADRs 0009/0020 | Core, persistence, task lifecycle and notification-port contract |
| [Automated deployment tests](#automated-deployment-tests) | NFR-14/15; ADR 0018 | Scaffolded real host/app; extend tests as each feature is delivered |
| [Release evidence](#release-evidence) | All FR/NFR evidence; NFR-05 | Required work packages and automated deployment tests complete |

Independent packages can progress in parallel after their contracts are defined. Finalize relevant field, lifecycle and authorization contracts before dependent schema/API implementation. Feature selection does not require every legal RFC combination. Keep architecture PRs draft while material design questions remain.

## Design contracts

- [ ] Review the [model catalog](models.md) and [ADR 0019](adr/0019-model-contracts.md): finalize logical fields/ownership, component cardinalities, physical schema/IDs, typed changes, uniqueness, retention and generated-client projections before writing model YAML or migrations. Preserve the selected RFC scope and resolve the catalog's explicit lifecycle/temporal review gates.

- [ ] Review the retained ADR implementation proposals against the selected RFC tables. Define exact property contexts/cardinalities, accepted values, native/interchange schemas, limits and diagnostics; keep feature scope separate from implementation approval.
- [ ] Specify task occurrence/completion/series-edit behavior, known-zone aliases and matching rules, DST/duration semantics, host authorization/publication lifecycle, deletion/identity removal, resource blocking/exclusivity/capacity and client variants.
- [ ] Finalize structured-component nesting/shared fields, DERIVED update authority, graph/reference scope, cycles/missing/filtered targets and privacy-aware UID mapping. Selected relationships remain metadata; they do not execute workflows.
- [ ] Define private alarm UID/acknowledgement/snooze wire/lifecycle constraints and notification-port cancellation/retry contracts. Keep requirements, compatibility and implementation issues aligned. Recover earlier discussion only as optional additional evidence.

## Scaffolding

The [scaffolding plan](scaffolding-plan.md) records confirmed walkthrough selections and installed-tool checks. Start with the buildable workspace/authentication/connection milestone; add domain and cross-instance feature checks incrementally. Local checks precede CI configuration, without removing CI release requirements. The initial root workspace, module skeletons, seeded host sign-in and local smoke harness are implemented under [ADR 0021](adr/0021-initial-workspace-scaffold.md); consult the [validation record](scaffold-validation.md) for actual results. The larger checklist below remains incomplete, including domain adapters, parser/recurrence selection and CI.

- [ ] Pin compatible Serverpod 4.x-or-later, Dart and Flutter SDKs; verify the selected module template, package layout, parser/recurrence/zone dependencies, licenses and generated-code workflow.
- [ ] Scaffold independent core, iCalendar adapter, Serverpod module/generated client and authenticated host Flutter example. Establish HTTP feed, scheduling and host mail/notification adapter boundaries without provider dependencies in core.
- [ ] Establish the example host/Flutter app as the automated test application using actual module/migrations and generated APIs. Add isolated database seed/reset, test-only controlled clocks/adapters and CI launch/teardown for single-instance and at least two-instance host topologies with distinct identities/ports and shared storage.
- [ ] Integrate host identity/membership/policy adapters, namespaced tables and fresh migrations. Add verified clean-checkout instructions and CI formatting, analysis, tests and generation checks. Keep secrets and production configuration out of source.

## Temporal core

Native calendar week numbering and presentation follow the confirmed ISO 8601/Monday convention under [ADR 0032](adr/0032-iso-week-convention.md). Preserve that convention in future ISO-label APIs and Flutter views; clarify explicit non-Monday RFC WKST handling separately.

- [x] Implement the isolated UTC query-window foundation with half-open bounds, membership, intersection and boundary tests. See [ADR 0022](adr/0022-utc-query-window-foundation.md) and [validation](temporal-core.md). This does not complete the temporal work package or resolve remaining date/zone/recurrence contracts.

- [x] Add validated Gregorian `CalendarDate` values for selected years 0001–9999, with month/leap-year rules, comparison and boundary tests under [ADR 0023](adr/0023-gregorian-date-only-values.md). Generated values, interchange, event spans and persistence remain future work.
- [x] Add bounded Gregorian calendar-day addition, signed day distances and weekdays under [ADR 0026](adr/0026-gregorian-calendar-day-arithmetic.md). Recurrence generation and duration semantics remain future work.

- [x] Add validated native `CivilDateTime` fields with selected microsecond precision and leap-second rejection under [ADR 0024](adr/0024-civil-date-time-values.md). Future iCalendar export must reject nonzero fractions; named-zone resolution, DST policy and adapter rejection tests remain pending.

- [x] Add the pinned native named-zone resolver and recurrence-candidate gap helper under [ADR 0025](adr/0025-bounded-named-zone-resolution.md), with RFC explicit gap/fold policy, exact aliases, outer civil years 1900–2037 and narrower conservative per-zone coverage. VM/Chrome tests pass.
- [x] Add unit-preserving signed `CalendarDuration` values with selected native microseconds under [ADR 0027](adr/0027-calendar-duration-values.md). Property-specific constraints and atomic interchange rejection remain pending.
- [x] Implement date-only and selected calendar-first zoned duration application plus guarded UTC-to-local projection under [ADR 0028](adr/0028-duration-application.md). Complete span/default/adapter semantics and practical limits separately.
- [ ] Replace/enrich the finite/truncated zone data and prove required per-zone/year coverage before claiming general named-zone support; implement VTIMEZONE matching/horizons and durable upgrade/recalculation policy.

- [ ] Preserve Gregorian date-only, UTC and named-zone civil meanings with pinned zone data. Accept validated matching VTIMEZONE definitions for known named zones; reject arbitrary/mismatched custom rules and floating forms. Exact alias acceptance is selected; complete matching horizon and zone upgrade contracts.
- [x] Add DATE-only recurrence parameter values with range/combination validation, immutable canonical lists and equality under [ADR 0029](adr/0029-date-recurrence-rule-values.md). Filter sorting/deduplication is confirmed; timed rules remain pending.
- [x] Add initial bounded DATE-only start-date generation under [ADR 0030](adr/0030-bounded-date-recurrence-generation.md), with selected mismatched-start rejection, COUNT/UNTIL, valid-date skipping, filters/positions and explicit work/result failure. Timed rules, recurrence sets and full service integration remain pending.
- [x] Add DATE-only yearly BYWEEKNO under [ADR 0031](adr/0031-date-recurrence-week-numbers.md), with all WKST values, positive/negative week-year selectors, missing-week skipping and full-cycle boundary tests. This is native calculation evidence, not wire/client interoperability.
- [ ] Implement the selected bounded recurrence profile from [RFC 5545](rfc/rfc-5545.md), including hourly/minutely cadence, selected filters, all WKST values, RDATE/EXDATE and stable original RECURRENCE-ID. Reject SECONDLY/BYSECOND without dropping timestamp seconds or flattening series.
- [ ] Support whole-series, single-occurrence and selected THISANDFUTURE event edits; provide recurrence contracts for tasks with separately defined lifecycle rules. Keep internal/source/scheduling/publication identities and application revisions distinct.
- [ ] Test Stockholm and another zone, DST gaps/folds, exclusive ends, point events, DTEND/DURATION, month/year boundaries, leap dates, open-ended series, moved/cancelled occurrences, stable pagination and expansion limits without false-free partial results.

## Persistence and authorization

- [ ] Implement durable calendar/event/series/exception CRUD, namespaced constraints and bounded queries. Store opaque external user/group/room/venue/equipment links; distinguish management associations from availability contributors and keep identity directories host-owned.
- [ ] Enforce current host/tenant/membership authorization on every operation, expected revisions and atomic imports/edits. Masters and valid overrides sharing a UID are not duplicates; existing-series ordinary imports must not silently become scheduling updates.
- [ ] Enforce transactions/revisions/constraints across active instances and define mutable-cache invalidation/current host policy. Verify writes on one instance through another; process-local locks or sticky routing cannot supply correctness.
- [ ] Define calendar deletion, identity removal and publication effects. Test isolation, forged references, membership changes, policy failures, concurrent writes, rollback and restart; feeds and interchange use the same policy boundary.

## iCalendar and metadata

- [ ] Implement the selected property/parameter/component profiles from the RFC tables and [ADR 0010](adr/0010-rfc5545-property-decisions.md)/[ADR 0014](adr/0014-rfc-extension-decisions.md). Keep native services, standalone interchange, scheduling and feed projections distinct.
- [ ] Preserve supported metadata through edits and semantic round trips: URI-only attachments/content, host-validated labels/classification, import-only CONTACT, language/display metadata, legal structured nesting and DERIVED read-only behavior. Reject invalid/unknown/inline/over-limit input atomically; do not fetch content, create directory entries or infer bookings/authority from metadata.
- [ ] Implement selected relationship search/grouping, legal UID/URI forms, allowlisted relations, signed GAP and cross-calendar links. Test private/ambiguous/missing/cyclic targets, independent authorization, collection-scoped LINK UIDs, publication mapping and rejection of XML-REFERENCE. Relationship edits alone cannot change dates, task state, bookings or alarms.
- [ ] Implement revisioned calendar/feed names, descriptions, identity, persistent updates, color and selected RFC 7986 fields. Aggregate feeds have their own metadata; SOURCE stays private, images stay URI-only and refresh hints do not create polling jobs. Validate language/multiplicity and moderator-link disclosure.
- [ ] Emit valid envelopes, UTF-8, CRLF, escaping and octet-aware folding. Test Gregorian defaults/rejection, equal source UIDs in separate calendars, conflicting zone definitions, synthetic negative fixtures and work limits. Defer standalone VFREEBUSY import while retaining generated output and authorized iTIP exchanges.

## Tasks

- [ ] Implement authorized durable recurring/non-recurring task CRUD, external assignment, filtering/pagination, optional typed dates, progress/priority/completion and expected revisions.
- [ ] Define and test per-occurrence completion/history, exceptions, original occurrence identity, series edits, due/duration semantics, bounded queries, restart and alarm invalidation. Support valid undated tasks and no-loss standalone VTODO interchange using known zones.
- [ ] Expose generated-client task management in Flutter. Task dates do not automatically block availability; explicit event reservations need the approved booking policy. Reject all VTODO iTIP/mail scheduling without mutation, automatic replies or outbound queueing; native assignment/interchange/alarms remain required.

## Feeds

- [ ] Implement authorized feed/calendar selection and multiple independent URL credentials. Generate at least 256 CSPRNG bits per secret under the proposed token policy, store only digests and management metadata, return raw secrets only on creation and redact URLs through application/proxy/APM logs.
- [ ] Publish deterministic complete VEVENT/calendar-description projections with stable publication UIDs and zone definitions. Revalidate current publication authority before content or validators; test independent revocation, aggregation, selection edits, tenant isolation, missing calendars, snapshot races and no silent truncation.
- [ ] Implement [ADR 0016](adr/0016-subscription-http-profile.md): read-only GET/HEAD, fixed ICS, ETag-only validation, strong If-Match/412 then If-None-Match with RFC precedence/weak comparison/lists/wildcards, bodyless HEAD/304, optional audience Content-Language and no subscription redirects. Defer date validators and partial responses; ignore unsupported ranges without altering normal conditional behavior.
- [ ] Test privacy-safe errors, opaque credential 404, no-store on every error/denial and no negative caching. Successful responses use private, no-cache, max-age=0, must-revalidate; omit proxy-revalidate/Expires. Verify enabled encoding variants, correct Vary/ETags and host/proxy cache behavior.
- [ ] Test equal feed bytes/ETags on different instances and warm-cache conditional fetches after committed revocation/publication withdrawal elsewhere. Stale local state must not return successful content or 304.
- [ ] Record subscription setup, updates/deletes, all-day/UTC/zoned recurrence/DST/exceptions, aggregation and URL lifecycle in Apple Calendar/iOS, Google Calendar From URL and the selected Outlook web/account variant. Record exact client/account/version/date/fixtures, metadata rendering, refresh delays and retained downloaded copies; additional client variants require separate evidence.

## Availability

- [ ] Resolve all host-selected contributing calendars for each person/group/resource independently from detail permissions. Apply recurrence, exceptions, status/transparency and each calendar's all-day zone; test long overlaps, adjacent intervals, point events and tentative/unavailable policy.
- [ ] Implement authorized rule CRUD/import/export and RFC 7953 priority/range composition under [ADR 0012](adr/0012-calendar-availability-policy.md). Test default/equal priorities, recurring openings, temporary/holiday overrides, DST and bookings; an opening never erases a booking.
- [ ] Apply per-calendar no-rule fallback (default free, unavailable alternative) only where no rule applies. Return separate calendar results and optional host-selected subject summaries by intersecting each contributor after its rules, fallback and bookings; do not let calendar priorities override one another.
- [ ] Implement bounded list-based per-target/common-free search with optional minimum duration, stable target references, snapshot metadata and complete/unknown coverage. Deduplicate targets and never omit denied/unresolved/over-limit contributors to manufacture a free result.
- [ ] Export authorized privacy-safe VFREEBUSY UTC periods separately from event subscriptions. Keep raw rules authenticated-only and out of bearer feeds; test no private event/participant/location leakage, committed-change invalidation and native Flutter available-room/common-slot journeys. Reads describe snapshots, not exclusive reservations.

## Scheduling

- [ ] Implement all selected VEVENT and VFREEBUSY methods from [RFC 5546](rfc/rfc-5546.md), with exact roles/properties, host-verified address/delegate/SENT-BY authority and resource acceptance policy. Imported metadata, DNS checks or feed credentials never authorize scheduling.
- [ ] Separate protocol UID/SEQUENCE/DTSTAMP/RECURRENCE-ID from app revisions and publication/mail identities. Reconcile updates/replies/cancellations, range/instance changes and counter proposals; deduplicate/reject stale or replayed messages without resurrecting cancelled invitations.
- [ ] Commit event/state/inbound-ledger/outbound intent atomically and use durable observable retries. Test all methods, MIME/METHOD mismatches, forged/revoked authority, response loops, recipient/input bounds and crash recovery. VTODO methods remain excluded inbound/outbound, including mixed-component rejection without partial processing.
- [ ] Provide maintained MIME and trusted inbound/outbound host mail adapters under [ADR 0015](adr/0015-restricted-imip-profile.md). Validate/emit component hints; defer S/MIME signing/encryption, reject unsupported protection and avoid plaintext downgrade or full RFC 6047 conformance claims.
- [ ] Run duplicate ingress and competing outbox consumers across active host instances; stop a claim holder around commit/submission and verify durable deduplication, takeover/stale-owner safety and stable retry identity without exactly-once transport claims.
- [ ] Test native Flutter scheduling and controlled mail directions independently from feed clients. Select external scheduling/mail targets separately and record invitation/reply/update/cancel/recurring-instance results; no mail server or identity directory is embedded. Real mail requires explicit authorization and configured recipients.

## Alarms and push

- [ ] Implement authorized personal event/task alarms with selected time triggers, UID/acknowledgement/snooze/DISPLAY and capped REPEAT/DURATION. Define multiple-recipient/reminder rules, legal anchors, date-only/DST, dismissal, expiry and missed/action interactions. Imported alarms require authorized activation; private state stays out of feeds.
- [ ] Persist generation/occurrence identity, bounded planning/refill, transactional claims, recovery scans and reminder outbox. Recalculate/invalidate on edits, exceptions, cancellation/deletion, task occurrence completion, recipient/access changes and snooze; test races, restart, duplicate/stale work and repeat deduplication.
- [ ] Revalidate current authorization/generation/expiry before dispatch and retries. Define cancellation/supersession across the notification port. Calendar owns timing/state; the reusable notification module owns generic delivery intent/adapters, while platform device/provider implementation belongs to external integrations. Provider acceptance is distinct from display or acknowledgement.
- [ ] Exercise planners, claiming and retries on at least two active hosts; test duplicate wake-ups, process interruption, expired lease takeover and stale-owner rejection using shared durable state and controlled timing. Validate cancellation/access/expiry across the notification-port boundary, including uncertain provider-acceptance outcomes.
- [ ] Build the reusable notification module and an example host adapter using Serverpod server events and authenticated streaming to Flutter under [ADR 0020](adr/0020-notification-delivery-scope.md). Keep recipient/scope routing host-verified and payloads minimal. No direct iOS/Android/FCM/APNs implementation is required.
- [ ] Demonstrate connected Flutter receipt, authenticated actions, multi-session consistency, logout/access revocation, stream disconnection/resubscription and authorized missed-notification recovery. Verify cross-instance server-event transport with the pinned toolchain; persist intent independently of transient events and distinguish submission, receipt and acknowledgement.

## Automated deployment tests

- [ ] Implement NFR-14/NFR-15 through the actual example host/Flutter app under [ADR 0018](adr/0018-automated-example-and-multiple-instances.md). Keep core unit tests independent; add real database, generated-client API, HTTP feed and Flutter integration suites in CI as features are implemented.
- [ ] Run at least two independent Serverpod processes concurrently against shared test storage, with distinct identities/ports and compatible code/configuration. Exercise direct and switched routing, cross-instance reads/stale writes/imports, rule/association changes and warm-cache revocation; one process with two clients is insufficient.
- [ ] Race scheduling ingress, alarm planners and outbox workers; interrupt/restart claim holders and assert durable recovery, logical uniqueness, idempotent handoff and stale-owner suppression. Specify time/lease/skew boundaries and recovery timeouts; tests use observable state and bounded waits.
- [ ] Use isolated synthetic host identities/resources, deterministic seed/reset, controlled time and recording mail/notification adapters. Restrict test controls to the harness/build. Automate Flutter CRUD, recurrence, availability/search, scheduling and reminder-action journeys, including restart/reconnection and instance switching.
- [ ] Record commands, pinned versions, topology, failures and results for single- and multiple-instance runs. Provider doubles are routine CI evidence; retain separate external feed-client evidence; any optional platform delivery needs its own evidence.

## Release evidence

- [ ] A clean checkout starts the pinned Serverpod/Flutter host with fresh migrations, synthetic host identities/resources and verified setup. Demonstrate calendars, recurring tasks/events, scheduling, rules/search, secret feeds and connected Flutter notifications through generated clients.
- [ ] Gather evidence for FR-01 through FR-31 and NFR-01 through NFR-15, including authorization, stale revisions, restart/rollback, protocol/negative fixtures, cache isolation and alarm/mail crash recovery. Automated real-host/Flutter journeys and multiple-active-instance failure/recovery checks are required; feed-subset compatibility and connected notification example evidence remain independent release checks.
- [ ] Record versions, directions, fixtures, known gaps, operational limits and best-effort delivery/refresh/downloaded-copy limitations. Verify licenses, package metadata, changelog, version policy and publication dry run; publication is a separate decision. No runtime or client evidence exists yet.

## Later scope

VTODO iTIP/inbound-outbound scheduling mail, CalDAV/CalDAV scheduling, general upstream synchronization, arbitrary custom zones, standalone VFREEBUSY import, VJOURNAL, proximity/geofencing, arbitrary audio/email alarm actions and an independently reusable Flutter UI package remain deferred or outside the selected first-release contract. Exact exclusions follow the RFC tables. Native recurring tasks, time-based alarms and the reusable notification module/connected streaming example remain first-release work.
