# Native calendar CRUD: first implemented slice

This slice implements calendar names, availability settings and subject associations. Events, tasks, availability calculation/rules, descriptions/colors, iCalendar metadata/import/export, feeds, scheduling and alarms remain following work. See [ADR 0049](adr/0049-first-calendar-crud-implementation.md) and [validation evidence](scaffold-validation.md).

## Host integration and authorization

Install `CalendarModule` on each Serverpod instance before starting it. Supply a `CalendarHostPolicy` and explicitly choose the required write guarantee in `CalendarModuleOptions`. The example's `DemoCalendarPolicy` in `example/calendar_example/calendar_example_server/lib/src/calendar_policy.dart` is a small replaceable implementation.

`resolveContext` derives principal, immutable storage scope and effective policy revision from trusted session/host data. None are client request fields. `planQuery` may narrow candidates to host-selected UUIDs; it cannot grant object access. `authorizeBatch` receives keyed requests with operation, actual object UUID, immutable current name/settings/subject snapshot, validated proposed changes and requested field groups. It must return exactly one decision per key. Denial, unavailable, exception, timeout, duplicate/missing/unknown response keys all fail closed. Ordinary reads and queries have no process-local authorization cache. Direct service calls enforce the same boundary as endpoints; `requireLogin` alone is insufficient.

A host can independently allow metadata edits, availability-setting changes, association reads/changes and deletion. Mutation responses contain only an explicitly permitted UUID/revision/deleted receipt, or null; a write grant does not imply read access. Reads always expose only an authorized identity/revision envelope plus the intersection of requested and granted field groups. `metadata` includes name/createdAt/updatedAt; `availabilitySettings` includes exact zone/fallback. Association reads have their own operation. Later object families need their own contexts/groups; this is not a generic completed event/task adapter.

`freshCheck` repeats trusted-context resolution and authorization immediately before each mutation. Permission changes after that check remain possible. `coordinated` additionally requires the host's final callback to establish effective guards in the supplied transaction and every relevant policy revoker to participate until actual commit. Installing a fresh-check adapter when coordinated mode is required rejects; live capability downgrade also rejects. A shared database or version label alone does not establish coordination. Policy methods must have no business side effects; a timed-out asynchronous callback can finish later but cannot authorize the aborted service operation.

The example uses authenticated JWT identity, scope `demo:user:<principal>` and a static policy-version label because its ownership rule is static. It accepts only the signed-in user's exact `demo/user/<principal>` association. Production adapters can validate users, rooms or other namespaced subjects against trusted host data. Hosts with mutable membership/object rules must supply an authoritative changing query-policy epoch and the declared revocation mechanism. JWT logout behavior remains unchanged: refresh credentials are revoked, copied access JWTs remain valid until expiry.

## Generated API

The generated client exposes `client.modules.serverpod_calendar.calendar`:

| Method | Input / result |
| --- | --- |
| `create` | Required name, exact named availability zone and explicit free/unavailable fallback; optional authorized mutation receipt |
| `getCalendar` | UUID and requested groups; authorized `CalendarView` |
| `list` | Page size, requested groups and optional cursor; `CalendarPage(calendars, nextCursor)` without totals |
| `updateMetadata` | UUID, expected revision and replacement native name |
| `updateSettings` | UUID, expected revision and both zone/fallback settings |
| `subjects` | UUID; independently authorized subject links |
| `changeSubject` | UUID/revision, attach/detach/setContribution and exact subject tuple/contribution flag |
| `delete` | UUID and expected revision; rejects active dependencies, no automatic detachment |

Names may duplicate. The server generates UUIDs; callers must not depend on a particular UUID version. Revision authority exists only in identity and increases for each successful command, including a same-value edit. Stale writes reject without overwriting. Settings/name commands are separate, not a combined patch. The example pre-fills `Europe/Stockholm` but submits it explicitly for validation.

## Model inventory

Sources are `.spy.yaml` files under `packages/serverpod_calendar/serverpod_calendar_server/lib/src/models/`; generated server/client files are never edited directly.

| Model | Purpose / fields |
| --- | --- |
| `CalendarIdentityRecord` | Server-only UUID, trusted scope, aggregate revision, nullable deletedAt; minimal retained marker |
| `CalendarDataRecord` | Server-only private row ID, unique calendar UUID relation, displayName, availabilityZoneId, noRuleFallback, createdAt/updatedAt |
| `CalendarSubjectRecord` | Server-only private row ID, calendar UUID relation, exact namespace/kind/externalId tuple and contributesAvailability |
| `CalendarScopeRecord` | Server-only private row ID, unique trusted scope and data generation; durable transaction lock target |
| `CalendarCursorRecord` | Server-only private row ID, unique random handle, actor/scope/policy/data bindings, last UUID, page size/groups and expiry |
| `CalendarCreateRequest` | Writable name, explicit zone and fallback only |
| `CalendarMetadataUpdateRequest` | Calendar UUID, expected revision and replacement displayName |
| `CalendarSettingsUpdateRequest` | Calendar UUID, expected revision and replacement zone/fallback |
| `CalendarSubjectChangeRequest` | Calendar UUID, expected revision, action, exact subject tuple and contribution flag |
| `CalendarView` | Authorized UUID/revision/disclosedGroups envelope; nullable name/timestamps/settings by group |
| `CalendarPage` | Authorized calendar views and nullable nextCursor; no total |
| `CalendarSubjectView` | Authorized exact subject tuple and contribution flag; no host profile/membership data |
| `CalendarMutationReceipt` | UUID, resulting revision and deleted flag, only when independently permitted |
| `CalendarNoRuleFallback` | Named enum: free/unavailable; storage alone does not calculate availability |
| `CalendarFieldGroup` | Named enum: metadata/availabilitySettings |
| `CalendarSubjectAction` | Named enum: attach/detach/setContribution |
| `CalendarFailureCode` | Named enum: validation/accessDenied/unavailable/staleRevision/dependencyConflict/limitExceeded/invalidCursor/invariantViolation; invariant failures currently map to safe unavailable |
| `CalendarException` | Typed failure code and safe message; no hidden dependency details |

The server-only adapter/context/snapshot/configuration classes in `calendar_authorization.dart` are native integration contracts, not serialized client models or identity tables. Errors do not promise the existence of inaccessible UUIDs.

## Text and operational bounds

Native name validation rejects raw input above 4096 UTF-16 units, malformed surrogate pairs, NUL and CR/LF/NEL/U+2028/U+2029 anywhere before trimming. Pinned Dart `String.trim()` removes outer whitespace; the result must contain 1–256 Unicode code points. Internal spaces, accents, combining sequences and emoji spelling remain unchanged. These native rules do not constrain imported iCalendar text.

Exact host principal/scope/policy-epoch strings are nonempty, well-formed Unicode, NUL-free and at most 512 UTF-8 bytes each. Subject namespace/kind/external ID limits are respectively 128/64/512 UTF-8 bytes. They are not trimmed or case-folded; whitespace is identity text. These byte limits keep the subject composite B-tree index bounded. Validate exact IANA keys/aliases against the pinned core database; no case/spelling guesses. Operational timestamps and cursor expiry are distinct from whole-second calendar-domain values.

Default module limits are maximum page size 100, candidate scan 1000, policy batch 64, associations per calendar 64, live cursor records per scope 64, cursor lifetime 10 minutes and timeout per host callback 5 seconds. Configuration rejects invalid/nonpositive limits, more than 16 dependency providers, callback timeouts over 30 seconds or cursor lifetimes over one hour. Integer limits cannot exceed 10000. These are count/per-callback bounds, not a total operation deadline or transport request-byte cap; deployment ingress limits remain host configuration.

## Storage, concurrency and deletion

The generated module migration creates `serverpod_calendar_identity`, `_data`, `_subject`, `_scope` and `_cursor`. The identity has exactly UUID, scope, aggregate revision and nullable deletion time. Active data has a private internal key, unique identity foreign key, name, zone/fallback and active operational timestamps. Subject tuples are unique per calendar. Identity/data/subject models are server-only; public views never expose internal payload keys or scopes.

Every service transaction locks the durable scope row and validates an undeleted identity with active payload. This coarse lock serializes operations within a scope across processes; large/high-contention scopes need future measured optimization. It is not an authorization guard. Missing active payload is an unavailable invariant failure, never free/empty data. Deletion removes payload and leaves the minimal marker; markers are absent from ordinary APIs and offer no restore operation. Retention duration remains undecided.

Existing subject links block deletion regardless of their contribution flag. Optional future modules may register `CalendarDependencyProvider` checks; callback failure prevents deletion. Future child writers must join the same active-parent/locking protocol. Their actual tables, races and invalidation logic need tests when implemented; this extension is not a completed feed/event dependency integration.

## Pagination contract and limitations

Order is ascending opaque UUID, not name/date/locale. A continuation is a 32-random-byte server handle encoded as 43 URL-safe characters. It conveys no authorization. The caller still authenticates; actor, scope, page size, normalized groups, policy epoch, current scope generation and expiry must match. Any calendar mutation in the scope invalidates previous cursors. The example offers refresh/restart; an invalid cursor is never silently ignored.

The service applies scope/candidate restrictions and keyed object authorization in bounded batches. It returns a cursor only after finding another authorized result. If the scan cannot establish a complete page/true exhaustion within its budget, the whole query fails explicitly. No hidden objects, counts or busy placeholders appear. Returned lists are not evidence of free time. Scope-local expired cursor cleanup runs when creating a new continuation; there is no global cleanup worker yet, and abandoned scopes may retain expired handles until a later cleanup policy is implemented.

The Flutter example supports list/create/rename/settings/self-association/contribution/removal/delete. Stale edits require explicit reload; no silent overwrite or retry. Descriptions/colors/protocol editing and richer production host administration follow separately.
