# Native occurrence timing editing

[ADR 0055](adr/0055-native-occurrence-timing-edits.md) extends [recurrence storage/previews](native-event-recurrence.md). The confirmed batch covers DATE/UTC/named-zone timing replacements, single cancellation/restoration and explicit removal of timing overrides. Individual text/status/transparency overrides and future cancellation/reopening remain pending. The mechanics below remain reviewable; no ICS/feed/scheduling interoperability is claimed.

## Identity and stored values

An occurrence is identified by its event UUID plus its **original** civil start and exact timing profile, even after moving. Never target an edited occurrence using its new actual start or its position in a preview. Two originals moved to the same actual start remain distinct. The ordinary whole-second [1970,2100) profile, exact IANA aliases, gap/fold rules and [timezone update limits](timezone-data.md) still apply. ISO display weeks and rule-specific WKST remain separate under [week conventions](week-conventions.md).

| Model | Meaning |
| --- | --- |
| `CalendarEventSingleOverride` | Start-only original anchor, optional complete replacement timing and independent cancelled flag |
| `CalendarEventFutureOverride` | Start-only original anchor and complete replacement timing |
| `CalendarEventTimingOverrides` | Required single/future lists, sorted/frozen after validation; at most 128 combined |
| `CalendarEventOccurrenceAction` | Replace/clear single timing, cancel/restore single, replace/clear future timing |
| `CalendarEventOccurrenceChange` | Event UUID, expected revision, original anchor, action and optional replacement |

The active event-data row has a separate nullable `timingOverrides` JSON column. Existing content/UID/revision/time remains unchanged on upgrade; null means no edits. The master `CalendarEventContent` contains no replaceable override list. The view exposes overrides only with the timing field group. Deletion removes them with the active payload; the identity marker stays minimal.

Anchors must be effective recurrence members after exclusions, including any earlier explicit inclusions. Reject orphan/excluded/duplicate anchors and single/future collisions at one original identity. Anchor timing contains no end/duration; replacements are complete legal timings in exactly the same kind/zone. A conflicting single/range representation must be explicitly cleared before using the other form at that anchor.

## Actions and host policy

Call `client.modules.serverpod_calendar.calendarEvent.changeOccurrence(request)`:

| Action | Permission | Behavior |
| --- | --- | --- |
| `replaceSingleTiming` | `updateEvent` | Replace that original occurrence's full timing; retain any cancellation flag |
| `clearSingleTiming` | `updateEvent` | Remove its replacement; retain cancellation if set |
| `cancelSingle` | `changeEventStatus` | Hide the instance; preserve any existing replacement |
| `restoreSingle` | `changeEventStatus` | Clear cancellation; recover retained replacement or inherited range/master timing |
| `replaceFutureTiming` | `updateEvent` | Apply original-relative timing from this anchor to the next range anchor |
| `clearFutureTiming` | `updateEvent` | Remove this range; reveal earlier range/master timing |

Only replacement actions accept/require `replacement`. Clearing/restoring a nonexistent corresponding change rejects. Repeated cancellation is allowed but still revision-checked; no idempotency-key receipt contract is added. Timing edits do not implicitly restore cancellation. A restored single under a cancelled master does not reopen the master. Future cancellation has no action in this increment.

The host receives actual calendar/event snapshots, current `timingOverrides`, immutable `occurrenceChange` and final validated `proposedTimingOverrides`. Preliminary checks happen before target-specific validation and have intent but no computed proposal; inspect the phase before interpreting null. A final null proposal means no overrides remain. The exact action distinguishes single/future and timing/lifecycle without fixed module roles. Existing final checks, callback deadlines, declared consistency guarantee, receipt disclosure and trusted scope rules apply. Read permission is separate from mutation authority; a successful receipt never contains hidden content.

Use the saved event revision for every action. The transaction changes only event override state, revision/time and scope generation, preserving protocol UID and parent calendar metadata time. Failures roll back together. Ordinary master edits preserve and validate all overrides, rejecting orphaning/kind/zone changes until conflicting overrides are deliberately removed. `replaceRecurrenceDates=true` cannot clear override state.

## Future timing and previews

A DATE range uses a signed calendar-day shift. Timed ranges use the core's original-relative civil-field shift, then resolve supported UTC/named-zone meaning. Explicit end propagates exact elapsed length; DURATION retains nominal units. A later range selects its own absolute shift relative to its original anchor. Separate singles remain unchanged even when their moved actual start crosses a range boundary. These operations do not rewrite RRULE, COUNT, UNTIL, RDATE or EXDATE, or selectively change only future Mondays in a mixed rule.

Existing `preview` authorization, timing disclosure and revision checks apply. Return complete effective spans/points and original identity, including moved-in/lengthened overlaps and distinct originals at equal actual starts. Single cancellations are absent; they remain discoverable in the authorized stored override view for restoration. Summary/description/location/status/transparency continue to come from the master; preview geometry alone does not establish booking/free-busy status.

At most 128 combined single/future overrides are stored. Membership validation has separate fixed caps: DATE uses up to two set scans, each capped at 200000 candidate days and 10000 occurrences; timed uses one combined scan with corresponding limits. Preview query work remains separately capped at 200000, raw/base output at 10000, final output at 500 and query width at 366 days. No per-anchor budget reset, partial successful output, silent truncation or materialized occurrence cache is added. Wide histories/inverse movement can fail even for a short query. Stored state is revalidated/frozen before use.

## Example and remaining work

The preview screen adds timing-edit and cancellation controls keyed to original identities, plus a saved-override list for restoring cancelled singles and clearing timing edits. Timing editors preserve explicit end/duration/default choices; named-zone explicit ends require user-entered civil fields instead of inferring a local end from UTC geometry. Stale drafts stay visible and saving is blocked until closing/reloading saved data; uncertain lifecycle failures also require refresh. Returning to the master editor reloads its saved revision before later actions.

Per-occurrence content overrides, future cancellation, arbitrary future pattern splits, task lifecycle, scheduling, alarms and cross-calendar availability remain separate work. See [validation](scaffold-validation.md) for actual test evidence and [the roadmap](roadmap.md) for subsequent availability work.
