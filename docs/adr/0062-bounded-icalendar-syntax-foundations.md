# ADR 0062: Bounded iCalendar syntax foundations

Status: **Accepted strict input profile; syntax API/limit mechanics under review**. Date: 2026-10-21.

## Context and confirmed scope

The maintainer requested the next parsing/import-export foundation batch and selected strict UTF-8/CRLF input: reject malformed UTF-8, bare LF/CR and a leading BOM. Existing native calendar/event/availability services and decoded metadata do not implement ICS interchange. [RFC 5545 section 3.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.1) defines byte-aware unfolding/content-line grammar and folding; [RFC 6868 section 3](https://www.rfc-editor.org/rfc/rfc6868.html#section-3) updates parameter value escaping. [The selected property profile](../rfc/rfc-5545.md) still determines what can eventually be imported/exported.

## Syntax boundary and representation

Add a pure Dart immutable ordered syntax document/tree, byte parser and deterministic byte serializer in serverpod_calendar_icalendar. Preserve name spelling, property/parameter/value order, repeated properties/parameters, raw escaped property values, decoded parameter values and unknown syntactically valid names. Syntax acceptance is not semantic approval: a later explicit profile validator must check component/property contexts, mandatory values, duplicates, value types, Gregorian/time/zone/recurrence limits, supported extension registration and disclosure before any domain import/export. No database, host authorization, networking, alarm arming, scheduling or feed route is added.

Unfold octets before strict UTF-8 decoding, including a fold splitting a multi-byte sequence. Require terminating CRLF, reject orphan continuations, blank lines, controls, malformed quoted parameters and unbalanced/mismatched BEGIN/END. Keep document/entry construction frozen; reject partial input atomically. Generic syntax permits multiple balanced root components without asserting that they are supported VCALENDAR objects.

Keep property values raw: do not guess which values are TEXT or apply TEXT escaping to URIs, recurrence or structured values. Separate explicit TEXT/list codecs handle backslash/comma/semicolon/newline. Their decoded newline convention is LF; reject CR instead of silently normalizing caller text. Parameter codecs implement RFC 6868 caret/newline/quote rules, leaving unknown caret sequences unchanged; backslash is ordinary parameter data. Output chooses required parameter quoting, CRLF and UTF-8 rune-safe folds of at most 75 octets including a continuation space, excluding CRLF. Spelling/order/value meaning are retained; original fold/quote/escape choices are not a byte-for-byte archive or a privacy projection.

## Limits and diagnostics

Proposed configurable defaults: 1 MiB input/output, 64 KiB physical/unfolded content line, 10000 content lines including BEGIN/END, 1000 components, depth 16, 32 parameters per line, 64 values per parameter and 64 ASCII characters per name. Charge raw input before decoding, physical/unfolded lengths before concatenation, counts before retaining nodes and output before return. Validate configured limits; cap configurable depth at 64 to bound serializer recursion. The 75-octet output fold recommendation is not a 75-octet input rejection threshold. Return structured error kind/physical line/limit name without echoing potentially private source values.

## Alternatives and remaining work

A compatibility mode accepting LF/BOM was offered and not selected. A generic third-party whole-calendar parser risks silent normalization or conflating syntax and unsupported semantics; this bounded first layer leaves domain mapping explicit. Implementing database import now would require unresolved source identities, property preservation, authority and atomic transaction contracts. Exporting arbitrary parsed documents through feeds would bypass required profile/disclosure validation and is not authorized by this syntax API.

Component/property semantic validators and typed wire values follow next; database import, authenticated export and optional bearer HTTP feeds remain separate layers. No Serverpod table/client generation changes are needed for pure syntax types. Tests cover malformed/over-limit/late-failing inputs, UTF-8 fold boundaries, quoted/repeated/unknown parameter data, TEXT versus parameter escapes, immutable ordering, deterministic parse/serialize meaning and physical output fold lengths on VM and Chrome. Extend root checks to include this package; record actual focused/broader results before one batch commit.
