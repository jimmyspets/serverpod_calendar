# First native non-recurring events

Current extension: [ADR 0054 recurrence storage/previews](native-event-recurrence.md) supersedes this initial slice's recurrence rejection and obsolete `recurring` boolean. The history and remaining single-event guarantees below describe the first batch.

[ADR 0053](adr/0053-first-native-single-events.md) records the maintainer-selected first event batch, optional summary and separate cancellation/deletion/lifecycle authority. This implements native storage and authenticated generated-client CRUD. Recurring events remain first-release scope and follow separately. No ICS import/export, scheduling messages, alarms, feed or free/busy service is implemented here.

## Models and timing

| Model | Purpose |
| --- | --- |
| `CalendarEventCivil` | Gregorian year/month/day plus integer clock fields and a fractional microsecond field that must be zero |
| `CalendarEventDuration` | Preserved nonnegative weeks/days/hours/minutes/seconds; zero fraction only; positive effective duration required |
| `CalendarEventTiming` | DATE/UTC/named-zone kind, start, optional exclusive end or duration and optional named zone |
| `CalendarEventContent` | Optional summary/description/location, required timing, status, transparency and explicit unsupported recurring flag |
| `CalendarEventCreateRequest` | Actual parent calendar UUID and content |
| `CalendarEventUpdateRequest` | Event UUID, expected event revision and replacement content |
| `CalendarEventStatusRequest` | Event UUID, expected revision and lifecycle status |
| `CalendarEventView` / `CalendarEventPage` | Authorized projections, no-total pages and opaque continuation |
| `CalendarEventReceipt` | Independently disclosable event/parent UUIDs, revision and deletion result |
| `CalendarEventRecord` / `CalendarEventDataRecord` | Server-only identity/marker and separate active payload |

Immutable command/content/civil/duration/timing models prevent callback-time mutation. Conversion into the independent temporal core validates fields rather than normalizing invalid dates. Ordinary dates remain **[1970-01-01,2100-01-01)**; only approved exclusive end forms may reach 2100-01-01 midnight. DATE is never stored as midnight UTC. Explicit UTC fields mean UTC; named-zone fields retain exact case-sensitive IANA names/aliases. Reject floating times, nonzero fractions, second 60, invalid fields, end plus duration, nonpositive durations and unprovable zone coverage. See [time limits and updates](timezone-data.md).

The core preserves explicit end/duration/default form and units. Omitted DATE end means one day; omitted timed end means a point with no positive occupied interval. Weeks cannot mix with other units; DATE durations accept only calendar days/weeks. Named-zone weeks/days move civil fields before elapsed clock units; P1D and PT24H differ across DST. Explicit repeated times select the first occurrence, and gap times use the offset before the gap. No floating-time inference or duration flattening is added.

`recurring=true` rejects explicitly. Recurrence/exception objects are not part of this first generated command contract. These typed APIs are not ICS parsers or validators of arbitrary unknown JSON members; do not send raw RRULE/property bags to them or claim lossless import from native DTO serialization.

Optional summary/description/location preserve decoded Unicode/plain text, whitespace and empty strings, limited to 4096/16384/4096 code points. The example renders missing/blank summaries as “Untitled event” without storing that placeholder; empty controls clear optional text. No HTML, property parameters, language variants or imported metadata are modeled yet. Native creation defaults to CONFIRMED and OPAQUE; this is not an RFC default for omitted STATUS. Transparency/status alone neither grants access nor guarantees a reservation.

## API and authorization

Use `client.modules.serverpod_calendar.calendarEvent`:

| Method | Behavior / host permission |
| --- | --- |
| `create(request)` | Create in an active authorized parent; `createEvent`; already-cancelled creation also needs `changeEventStatus` |
| `getEvent(id, groups)` | Actual parent/event resolution, then `readEvent` and requested disclosure |
| `list(calendarId, pageSize, fieldGroups, cursor)` | `listEvents`, host candidate plan, per-object `readEvent` and disclosure |
| `update(request)` | Full native content replacement; `updateEvent`, plus `changeEventStatus` whenever status differs |
| `changeStatus(request)` | Changes only status under `changeEventStatus`; no ordinary edit permission needed |
| `deleteEvent(id, expectedRevision)` | Removes active content under `deleteEvent`; no implicit scheduling message |

Hosts implement the added `planEventQuery` method, returning immutable candidate event IDs or no coarse restriction. Candidate hints cannot cross parent/scope boundaries or bypass object authorization. Requests include actual calendar snapshot/UUID, event UUID/current immutable snapshot and validated proposed content. Actor/scope/membership remain host-resolved. Calendar metadata read permission does not imply event access and need not be granted to allow a separately authorized event operation.

Predefined event groups are summary, description, location, timing, state (status/transparency), and protocolIdentity (UID/whole-second UTC modification time). An omitted/denied group has null fields; inspect `disclosedGroups` to distinguish withheld from absent optional data. Hidden events are omitted from detail pages, without denied placeholders or counts. Event receipts require the host's receipt disclosure on every checked operation. Existing fresh-check versus coordinated guarantees, final checks, timeouts and no-downgrade behavior remain unchanged; the demo supplies only fresh-check authorization.

Cancellation retains the event with CANCELLED status. Reopening selects CONFIRMED/TENTATIVE with the same UUID/protocol UID. Full edits cannot bypass lifecycle authority. Deletion removes content and protocol UID, leaving only event UUID, actual parent UUID, revision and deletion time; no archive/restore/discovery or new retention policy is added. Cancelled events still block parent deletion until explicitly deleted. Calendar deletion and event creation serialize under the same durable scope lock.

All event writes compare/advance event revisions and scope generation transactionally. Shared PostgreSQL time is nondecreasing, projected to whole seconds for the protocol view. Event changes do **not** change the parent calendar's own metadata revision/timestamp. Reads and failed commands do not touch event revision/content/time. UID is server-generated and remains stable through edits/cancellation. It is not an access credential; scheduling/publication identity mapping remains future work.

## Bounded detail queries

The initial list is UUID ordered within one calendar, not chronological and not filtered by a time window. Defaults are page maximum 100, scan maximum 1000 events (`maxScannedEvents`), policy batches 64 and shared calendar/event cursor capacity 64 per scope. Limits are configurable within installation bounds. Scan/policy/coverage failures reject instead of pretending results are exhausted. Authorized lookahead establishes whether another authorized result exists; no totals are returned.

Durable random continuation tokens bind query kind, calendar, actor, scope, policy epoch, data generation, exact groups, page size and expiry. Calendar/event cursors reject cross-use; mutations invalidate scope continuations. Old calendar cursors migrate with null event discriminator/groups. The demo epoch becomes v5. Expired-cursor cleanup is bounded, using the existing shared cursor table and quota.

Never derive availability from this privacy-filtered list. Complete bookings, recurrence, date-only projection, cancellation/transparency semantics and per-target coverage need the dedicated availability service. Native moves, recurrence/occurrence edits, query windows, participants, resource booking links, scheduling, alarms, import and feed publication remain pending.

## Example and validation

The Flutter calendar editor opens an event list/editor. It supports explicit date/UTC/named-zone and omitted/end/duration forms, optional plain text, transparency, separate status actions, deletion confirmation and stale-revision rejection with explicit reload. It preserves draft edits on stale saves and blocks lifecycle/deletion while a draft is unsaved. Full form editing is unavailable if required field groups are withheld, so hidden fields cannot be accidentally replaced from an incomplete view. The server remains authoritative. A named zone is explicitly supplied; the example prefills the parent zone, falling back to visible Etc/UTC text when unavailable.

Migrations add event identity/data tables with foreign keys and unique payload/protocol-UID indexes, plus nullable event cursor bindings. No existing calendar payload is converted into an event. Populated upgrade fixtures, native adapter tests, database policy/lifecycle/rollback checks, generated-client two-host races and a Flutter WebDriver journey provide scoped evidence in [the validation record](scaffold-validation.md). VM-only DTO adapter tests import server-generated types; the independent core still runs on VM/Chrome, with client transport checked through Flutter Web. Creation has no request-deduplication ledger or idempotency-key contract in this increment; automatic retry of an uncertain create is not guaranteed to return the same object. No complete RFC or external-client interoperability follows.


[ADR 0078](adr/0078-create-only-event-import-and-storage.md) and [the event import contract](event-import.md) now record selected source-preserving storage/create-only import choices. Current runtime is unchanged: event PERIOD persistence, imported text annotations/component versions and authenticated event import remain unimplemented. Preserve existing native timing/lifecycle/authorization behavior until the separately reviewed storage increment extends it.
