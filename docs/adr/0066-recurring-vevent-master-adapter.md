# ADR 0066: Recurring VEVENT master adapter

Status: **Accepted recurring-master batch; adapter/limit mechanics under review**. Date: 2026-10-22.

## Context and confirmed scope

After the [first event/zone adapter](0065-first-vevent-wire-adapter.md), the maintainer selected recurring VEVENT masters with RRULE and start-only RDATE/EXDATE, matching the existing native profile. PERIOD-valued additions and separate occurrence-override components follow in dedicated batches and reject explicitly until implemented. Existing [temporal limits](0041-whole-second-1970-2100-profile.md), [native recurrence semantics](0054-native-event-recurrence-and-previews.md), exact zone matching and full-horizon VTIMEZONE validation remain unchanged.

Source: [RFC 5545 recurrence grammar](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10) and [recurrence properties](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.5). This increment remains pure wire-to-core adaptation, without database import/reconciliation or publication.

## Implemented profile and proposed API mechanics

Extend accepted event properties with one RRULE and repeated RDATE/EXDATE lists. Expose optional IcalendarEvent.recurrence with immutable dateSet or timedSet core values; absence of every recurrence property remains null. Finite inclusion/exclusion sets without RRULE are supported. Keep original syntax for spelling, duplicate/raw date order, omission and parameter retention; canonical core filters/dates are sorted/deduplicated as already selected.

DATE supports DAILY/WEEKLY/MONTHLY/YEARLY; UTC and named-zone masters additionally support HOURLY/MINUTELY. Support INTERVAL, mutually exclusive COUNT/UNTIL, WKST, BYDAY, BYMONTHDAY, BYYEARDAY, BYWEEKNO, BYMONTH, BYSETPOS and timed BYHOUR/BYMINUTE. Reject SECONDLY/BYSECOND, unknown parts, duplicate parts, invalid combinations, malformed numeric grammar and unsupported parameters rather than normalizing them away. Require ASCII protocol tokens before case folding, including the existing envelope/state/VALUE and observance RECUR contexts; Unicode calendar text is unaffected. Use core rule constructors for semantic ranges/combinations, with exact BigInt checks before narrowing COUNT/INTERVAL. Raw positive scalars have at most 32 digits and fit the core portable maximum 9007199254740991; RECUR text is capped at 4096 UTF-16 units.

DATE UNTIL is an ordinary inclusive DATE; UTC/named UNTIL is an ordinary inclusive UTC DATE-TIME. No exclusive-end exception applies. Direct bounded core expansion around DTSTART validates first-period membership, including BYSETPOS and UNTIL, even when EXDATE removes the start. This is initial alignment validation, not full materialization or a guarantee that all later bounded queries fit their budgets.

RDATE/EXDATE require the exact master kind and exact named-zone key. Local values do not inherit a missing TZID; floating values still reject. Every referenced zone must have a supplied, matched definition. Preserve earlier inclusions, keep DTSTART as original identity, apply EXDATE after the union and do not replenish COUNT. Core evaluation retains explicit-time gap/fold policy, skips generated gaps without consuming COUNT and keeps nominal event durations distinct from elapsed hours.

Accept RECUR parts in any input order. On serialization, emit FREQ first in accepted RRULE properties, including VTIMEZONE observances, preserving spelling and other part order. The immutable source tree remains unchanged. This intentional source-output normalization follows the RFC consumer/output distinction and supersedes the prior serializer's raw-part-order retention for RRULE only; it is still not an authorized export/feed projection.

## Work limits and shared core budget

Use 256 raw explicit dates and 512 raw BY-list values per event/rule, matching the native editing profile, plus calendar-wide defaults of 4096 explicit dates and 4096 BY-list values. Charge duplicates before canonicalization and invalid/out-of-query input before retaining results. Add these configurable positive ceilings to IcalendarComponentLimits, with its existing hard maximum 1000000.

Share the existing default 200000 candidate-work ceiling across zone-observance expansion and every event's start-alignment validation in the same calendar. Add optional RecurrenceWorkBudget to the core DATE/timed generator expand APIs. Every already-counted candidate unit also charges that trusted shared object; local limits remain active and failed attempts retain consumed aggregate work. No budget object is supplied by default, preserving existing native callers. This changes no recurrence meaning and does not claim to add shared budgets to unrelated existing native service operations.

Rule/datetime/type errors fail the whole semantic parse with existing sanitized component diagnostics. No partial event calendar or native mutation escapes. Existing syntax, event/zone/observance/onset, metadata and profile bounds remain active.

## Alternatives, consequences and acceptance

Flattening occurrences would lose identity and bounded semantics. Silently dropping PERIOD or overrides would lose data, so they remain explicit rejections in this increment. A full expansion on import could be expensive or unbounded; validating only the complete first cadence period establishes DTSTART alignment while leaving queries independently bounded. Per-rule budgets alone could multiply work over many masters; the optional shared core object makes the aggregate ceiling enforceable without duplicating the recurrence engine.

Test strict grammar and combination rejection, COUNT/UNTIL, earlier/duplicate inclusions, EXDATE precedence, exact profiles, all supported frequencies, WKST/BYWEEKNO versus ISO presentation, first-period BYSETPOS, DST gaps/durations, portable scalar bounds, serialization normalization and cross-event/zone aggregate exhaustion on VM/Chrome. Keep first-adapter regressions and core budget failure/accounting checks. Separate occurrence-override components, PERIOD support, native import/storage identity, scheduling/alarm execution, authorized export and HTTP feeds remain pending.

## Subsequent scoped extension

[ADR 0067](0067-vevent-period-additions.md) adds explicit timed RDATE PERIOD pairs to this master profile. It supersedes PERIOD rejection only for that bounded pure adapter extension; occurrence components and database import/export remain pending.
