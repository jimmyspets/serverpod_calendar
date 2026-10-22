# serverpod_calendar_icalendar

Pure Dart iCalendar adapter foundations: bounded ordered syntax parsing/serialization, separate TEXT and RFC 6868 parameter codecs, and the scoped decoded calendar metadata validators used by native APIs.

The strict parser accepts UTF-8/CRLF input and rejects malformed/over-limit data atomically. Its immutable tree preserves raw property values and repeated/unknown syntax; this is not calendar-profile approval. The serializer emits deterministic CRLF, quoting and rune-safe 75-octet folds. It is not an authorization or publication projection.

See [syntax behavior, limits and boundaries](../../docs/icalendar-syntax.md) and [ADR 0062](../../docs/adr/0062-bounded-icalendar-syntax-foundations.md). Complete component/property validation, native mapping, domain import/export, feeds and scheduling remain separate work. Nothing fetches URI content or arms alarms.

From this directory, run `dart test` for VM tests or `dart test --platform chrome` for browser tests. The root check script includes both suites with the pinned workspace toolchain.

Typed DATE, UTC/named-zone DATE-TIME and DURATION codecs now map individual raw wire values to core types. See [value behavior and boundaries](../../docs/icalendar-temporal-values.md). They preserve the whole-second 1970–2099 profile, explicit exclusive endpoints and duration units; this does not validate VTIMEZONE or a complete import.

The [first standalone non-recurring VEVENT/VTIMEZONE profile](../../docs/icalendar-event-adapter.md) now maps accepted DATE/UTC/named-zone timing to core spans, validates full-horizon pinned zone agreement and preserves accepted source syntax. Complete property coverage, database import, authorized export and feed publication remain pending. Unsupported data rejects instead of disappearing.

[Recurring event masters](../../docs/icalendar-recurring-masters.md) now extend that profile with typed RRULE/start-only RDATE/EXDATE, first-period validation and aggregate work caps. PERIOD additions/override components still reject; source retention is separate from FREQ-first output and authorized native import/export.

[Timed PERIOD additions](../../docs/icalendar-recurring-masters.md#period-valued-rdate-additions) now extend RDATE with preserved end/duration spans under ADR 0067. The older PERIOD-rejection checkpoint above is superseded for this pure adapter subset; native storage and occurrence components remain separate.

[Occurrence timing/cancellation components](../../docs/icalendar-occurrence-components.md) now extend the pure profile under ADR 0068. This supersedes older blanket occurrence-component rejection for the documented subset only; content changes, future cancellation and authenticated import/export remain pending.

The pure [availability adapter](../../docs/icalendar-availability-adapter.md) now adds standalone VAVAILABILITY/AVAILABLE timing, recurrence/overrides, bounded core projection and source serialization under ADR 0069. Rich metadata and authenticated import/export remain separate.

## Availability metadata

See [the bounded wire metadata profile](../../docs/icalendar-availability-metadata.md) for preserved source groups, trusted private registration and organizer authority boundaries. This pure adapter does not implement database import, authorized export or feeds.
