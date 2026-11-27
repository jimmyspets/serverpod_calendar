# ADR 0064: First VEVENT adapter and zone-validation contract

Status: **Maintainer-confirmed scope and matching boundary; implementation pending**. Date: 2026-10-22.

## Context

After the [temporal value codecs](0063-icalendar-temporal-value-codecs.md), the maintainer selected VEVENT as the first component adapter. The offered first slice covered non-recurring events with DATE/UTC timing, UID/DTSTAMP, basic text, status/transparency and preserved explicit-end/duration/default forms. The maintainer requested named-zone events and VTIMEZONE validation in that same first component batch rather than postponing them.

## Confirmed choices

Imported VTIMEZONE definitions must match the pinned IANA zone over the **entire supported 1970–2099 horizon**, not just around the event dates. A definition correct only for a smaller interval must reject under this first profile. Recognizing TZID text alone is insufficient, and arbitrary custom-zone arithmetic remains excluded under [ADR 0017](0017-profile-review-clarifications.md).

The validator may read **observance seed dates before 1970 solely to calculate and compare rules within that horizon**. This does not extend ordinary event storage, occurrence identity or timestamps beyond [ADR 0041](0041-whole-second-1970-2100-profile.md). Rule seeds are inputs to validation, not additional ordinary native calendar dates.

Known-zone names/aliases, exact supplied identifier preservation, whole seconds, explicit-time gap/fold behavior and [timezone update procedures](../timezone-data.md) remain unchanged. A matching source definition is checked against the pinned database version; it does not authorize a database update or remote retrieval.

## Implementation contracts still to review

The first adapter remains non-recurring; recurrence, alarms and other not-yet-profiled properties must reject explicitly without silent loss. Component envelope/property cardinalities, bounded observance expansion, supported rule syntax, seed range, duplicate/conflicting definitions, coverage endpoints/padding, errors and source-preserving representation need concrete implementation review and tests. Native import transactions, identity reconciliation, host authority, publication projections and HTTP feeds remain separate batches.

Use a pure component adapter above generic syntax and the individual value codecs. Do not route VTIMEZONE seed dates through ordinary-date constructors with a widened storage policy. Keep any internal validation representation distinct and bounded. Compare offset functions over the full supported calculation horizon, including boundaries and transitions; do not infer equivalence merely from a few sample event instants.

## Consequences and acceptance

Full-horizon matching provides one clear pinned-rule guarantee but rejects otherwise usable date-limited definitions. Earlier seed inputs permit common historical rule descriptions without widening stored-event dates. Limited observance syntax or inadequate bounds must cause explicit rejection, never replacement by guessed rules or partial approval.

Test matching/mismatching and insufficient-coverage definitions, earlier seeds without out-of-profile event storage, aliases, DST transitions/gaps/folds, conflict/duplicate handling, resource exhaustion and atomic component rejection. Preserve separate evidence for pure semantic mapping, authorized database import/export and external clients. This record confirms the next batch's scope; no VEVENT or VTIMEZONE parser implementation is claimed here.
