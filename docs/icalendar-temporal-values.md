# iCalendar temporal value codecs

The pure Dart serverpod_calendar_icalendar package adapts individual wire values to existing core types under [ADR 0063](adr/0063-icalendar-temporal-value-codecs.md). It builds on [generic syntax](icalendar-syntax.md). These functions do not validate a complete VCALENDAR, property parameters or host authority, and perform no database writes, networking or alarm activation.

| API pair | Core value | Accepted form |
| --- | --- | --- |
| parseIcalendarDate / serializeIcalendarDate | CalendarDate | YYYYMMDD |
| parseIcalendarDateTime / serializeIcalendarDateTime | TimedValue | YYYYMMDDTHHMMSSZ, or local fields with an explicit zoneId |
| parseIcalendarDuration / serializeIcalendarDuration | CalendarDuration | Signed RFC week, day and clock-unit forms |

The strict profile uses uppercase designators and ASCII digits. Do not trim input or pass TEXT-decoded data: these types have no backslash escaping. Lists, extended ISO spellings and trailing data reject. DATE remains a date rather than midnight UTC. DATE-TIME rejects floating values, numeric offsets, all fractions including .000 and leap-second 60. Invalid dates/times reject before DateTime can normalize them.

Ordinary values use **[1970-01-01, 2100-01-01)**. Only explicit exclusive endpoints may use 21000101 or midnight 21000101T000000, with exclusiveEnd: true required for both parsing and serialization. The caller must enforce exclusive property semantics and span ordering; do not use this option for DTSTART, recurrence identities or ordinary timestamps.

## Named zones and output context

Pass an exact supported IANA key or alias as zoneId for local DATE-TIME. UTC suffix Z and zoneId are mutually exclusive. The core uses pinned generated rules and the documented [timezone limitations/update procedure](timezone-data.md): first occurrence in a fold, pre-gap offset for an explicit nonexistent local time. It retains requested fields, so a gap input round trips without being rewritten to its effective wall time.

The serializer returns local text without Z for named values. It does not return a complete property: emit the exact value.zoneId as TZID separately. This low-level codec assumes the caller supplies a trusted/validated zone context. An imported VTIMEZONE must still pass the future matching validator; recognizing its TZID alone does not validate its rules. No custom zone, Windows-name guessing or remote retrieval is enabled.

## Durations and normalization

The value layer accepts positive, negative and zero magnitudes. Event/availability durations may require positive values; alarm triggers have different rules. Property adapters must enforce those constraints. Units are retained: **P1D and PT24H differ across DST**. Do not turn CalendarDuration into an elapsed Dart Duration before applying it.

Output is deterministic, without carrying units: +P0002D becomes P2D; PT90M stays PT90M; signed zero becomes -PT0S or PT0S. Explicit zero-unit spellings are not retained. One hour and one second serialize as PT1H0M1S, since the RFC grammar requires the intervening minutes. Years/months, fractional seconds (even zero fractions), mixed weeks with other units, malformed ordering and empty P/PT reject.

Duration input is capped at 128 UTF-16 code units; zone IDs at 255. Each magnitude is checked exactly against the core's portable 9007199254740991 maximum using BigInt before narrowing. Large representable values may still fail actual date/time application. These are implementation resource/representation limits, not RFC maxima.

IcalendarValueException exposes only a structured IcalendarValueError kind: invalidSyntax, invalidValue, outsideProfile, invalidContext, floatingTime, unsupportedZone, zoneCoverage or limitExceeded. Diagnostics omit source text and resolver details. The outer transport and syntax parser retain their own byte/count limits.

## Remaining layers

A valid value is not an approved property or import. Component adapters must validate VALUE/TZID multiplicity/context, mandatory fields, end/duration pairing, span ordering, recurrence and zone definitions, supported metadata/extensions and source identities before mutation. Serialize only authorized projections. Database import, authenticated export, HTTP feeds and external-client interoperability remain pending; this increment changes no generated protocols or tables.

Source grammar: [RFC 5545 sections 3.3.4–3.3.6](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.4).

The [first event component adapter](icalendar-event-adapter.md) now enforces the documented subset of those component/parameter/zone constraints under ADR 0065. Recurrence, additional properties and authenticated database import/export remain pending.
