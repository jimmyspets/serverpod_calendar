# serverpod_calendar_icalendar

Pure Dart iCalendar adapter foundations: bounded ordered syntax parsing/serialization, separate TEXT and RFC 6868 parameter codecs, and the scoped decoded calendar metadata validators used by native APIs.

The strict parser accepts UTF-8/CRLF input and rejects malformed/over-limit data atomically. Its immutable tree preserves raw property values and repeated/unknown syntax; this is not calendar-profile approval. The serializer emits deterministic CRLF, quoting and rune-safe 75-octet folds. It is not an authorization or publication projection.

See [syntax behavior, limits and boundaries](../../docs/icalendar-syntax.md) and [ADR 0062](../../docs/adr/0062-bounded-icalendar-syntax-foundations.md). Complete component/property validation, native mapping, domain import/export, feeds and scheduling remain separate work. Nothing fetches URI content or arms alarms.

From this directory, run `dart test` for VM tests or `dart test --platform chrome` for browser tests. The root check script includes both suites with the pinned workspace toolchain.

Typed DATE, UTC/named-zone DATE-TIME and DURATION codecs now map individual raw wire values to core types. See [value behavior and boundaries](../../docs/icalendar-temporal-values.md). They preserve the whole-second 1970–2099 profile, explicit exclusive endpoints and duration units; this does not validate VTIMEZONE or a complete import.
