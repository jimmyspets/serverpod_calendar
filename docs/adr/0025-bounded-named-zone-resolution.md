# ADR 0025: Pinned, bounded named-zone resolution

Status: **DST/identifier/year-envelope choices explicitly confirmed; bounded core resolver verified; remaining storage/protocol contracts proposed**. Date: 2026-10-19.

Current-profile note: [ADR 0041](0041-whole-second-1970-2100-profile.md) supersedes this record's earlier date-range/precision/zone-envelope choices. Ordinary calendar dates are now 1970 inclusive to 2100 exclusive, with whole seconds and a special exclusive endpoint. The original increment and validation history below is preserved.

## Selected scope and evidence

The maintainer selected RFC 5545 explicit-time rules for native and imported values: choose the first instant during a fold, and interpret a gap using the offset before it. Nonexistent recurrence-generated times are skipped; a future recurrence engine must also skip invalid dates and must not count those omissions. The maintainer selected exact case-sensitive names/legacy aliases present in pinned IANA data, retaining the supplied identifier with no Windows-name, abbreviation, case or spelling guessing. An abbreviation-like string that is itself an exact database key is a registered name, not an inferred geographical location.

After inspection showed finite upstream transition data, the maintainer selected a first resolver envelope of civil years **1900–2037** with explicit rejection outside it. This does not narrow date-only values from ADR 0023 or extend their validity into supported zone calculations. The envelope is an outer bound, not a promise of complete coverage for every zone/date inside it.

Pin `timezone` **0.11.2**, its embedded `latest_all` data variant, and IANA **2026e**. The generated source header and changelog establish the data version; the package README's older 2025c statement is stale. Package SDK constraint `^3.10.0` resolves with pinned Dart 3.13.5. Its inspected LICENSE is BSD-2-Clause; the repository Apache 2.0 LICENSE remains unchanged. Package integrity is locked in pubspec.lock; toolchain.json records the binary data SHA-256 and resolver profile. No dependency-generated files are edited or vendored.

## Coverage safeguards

The inspected package replaces the timestamp of the first imported transition with a minimum-time sentinel (`filterTimeZoneData`). It also lacks an unbounded future transition tail; examples terminate around 2038. Blind lookup would extend an offset into periods that have not been proved correct. The resolver therefore never treats the sentinel as historical evidence.

For a nonconstant zone, every candidate calculation must be at or after the first retained, explicitly timed transition; all relevant candidate offsets must have coverage. Truly constant known-offset tables can resolve throughout the selected envelope. Unknown `-00` offsets and unknown-only placeholders such as `Factory` are not UTC. Incomplete coverage throws `ZoneCoverageException`, never null or a free interval. These checks are deliberately conservative: Kathmandu in 1900 is rejected, and an initial-only historical table such as Africa/Abidjan is currently rejected even for modern calculations. Listed zone identifiers do not guarantee resolvability for a chosen date. Replacing/enriching the data is required before claiming general all-zone coverage or removing these restrictions.

## Implementation

`NamedZoneResolver` captures immutable primitive rules from the bundled data, synchronously restoring the host's existing timezone registry and initialized local-zone setting. If the package had no initialized local setting, it receives the package's UTC default. Calculations use only the captured rules, not host global mutations, the device zone, a process-local authority cache or the current time. Separate isolates load the same pinned rules independently.

Resolve a civil value by finding the UTC candidates consistent with each recorded offset. One candidate is unique; multiple candidates choose the earliest UTC instant. For a forward gap, use its actual pre-gap offset; do not assume one-hour transitions. The result retains requested civil fields, exact zone key, UTC instant, unique/fold/gap classification, interpretation offset, effective offset and data/profile version. `effectiveLocal` shows the resulting local fields without overwriting the requested value. Microseconds are retained, including for negative epoch instants.

`resolveRecurrenceCandidate` returns null only for a proved gap. Unknown keys, unsupported years and insufficient coverage remain errors; the helper is not an RRULE/COUNT implementation. Do not use a failed resolution to manufacture complete availability or silently omit unsupported calendar content.

## Alternatives and remaining contracts

Native strict rejection of gaps/folds was offered and not selected. Extending the engine before this bounded increment was offered and deferred. Trusting mutable global timezone state or the library's extrapolation would hide data/version/coverage problems. Automatic alias canonicalization could change source identity; preserve the exact input key instead. Duplicate aliases resolving alike do not establish canonical identity or authorization.

Imported VTIMEZONE validation/equivalence and its horizon, canonical zone IDs, durable zone records, transactional rule upgrades/recalculation, duration arithmetic, recurrence expansion and endpoint/interchange atomicity remain unimplemented. An imported definition must not bypass the known-zone/matching requirement; this resolver accepts no custom rules. The current envelope and per-zone restrictions are initial implementation limits, not completion of the first-release temporal requirements.

## Validation

All 101 pure core tests passed on the Dart VM and Chrome, including 30 zone tests: Stockholm/New York gaps/folds, transition boundaries at microsecond precision, Lord Howe half-hour transitions, Apia's skipped day, Kathmandu's quarter-hour offset, negative epochs, aliases, unknown names, year bounds, historical/unknown-offset coverage failures, recurrence-candidate behavior and protection from global registry mutations. See [temporal validation](../temporal-core.md) for commands and limits.

Sources: RFC 5545 [explicit DATE-TIME](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.5) and [recurrence invalid instances](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.10), [timezone package](https://pub.dev/packages/timezone/versions/0.11.2), inspected pinned `location.dart`, `tools.dart`, `env.dart` and generated data header. See [ADR 0017](0017-profile-review-clarifications.md), [ADR 0024](0024-civil-date-time-values.md) and [FR-05](../requirements.md). No blanket protocol or external-client support is claimed.
