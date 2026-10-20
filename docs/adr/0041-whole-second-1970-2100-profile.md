# ADR 0041: Whole-second calendar profile, 1970 inclusive to 2100 exclusive

Status: **Accepted maintainer policy; implementation APIs remain reviewable**. Date: 2026-10-20.

## Decision and supersession

The maintainer selected RFC 5545 whole-second calendar timing, keeping the current `timezone` library, generating future transitions, documenting limitations/updates, and an end year of 2100 **not including 2100**. Breaking unpublished APIs are authorized. This supersedes the precision/range parts of ADRs 0023, 0024, 0025, 0027, 0039 and 0040; their historical implementation and validation records remain intact. Leap-second rejection, Gregorian dates, ISO native weeks, explicit RFC WKST, first-fold/pre-gap explicit resolution, generated-gap skipping and calendar-units-first duration application remain selected.

Ordinary DATE and UTC/zoned calendar fields are in **[1970-01-01, 2100-01-01)**. The final ordinary date is 2099-12-31. Calendar timing and duration fractions must be zero; do not round or truncate inputs. Typed DateTime values parsed from permitted all-zero fractional spellings are accepted. Future format adapters must validate lexical syntax before DateTime construction: RFC 5545 timestamps do not allow a decimal suffix, even an all-zero one. A different supported format may allow `1.00000` as an exact whole second, while `1.00001` rejects. This is not authorization to accept arbitrary input formats or an implemented parser.

RFC 5545 [DATE-TIME/TIME](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.5) and [DURATION](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.3.6) define the relevant whole-second wire grammar. Existing microsecond-named input slots accept only zero. Exact elapsed-microsecond getters remain integer units of measurement, always multiples of one million; they do not admit fractional calendar values. Audit/logging/processing timestamps are separate from calendar timing and can retain finer precision.

## Boundary values and computation

`CalendarDate.exclusiveEnd()` represents only 2100-01-01. Ordinary date construction rejects year 2100. Date arithmetic can reach this explicit endpoint but not pass it. `TimedValue.utcEnd`/`zonedEnd` permit the equivalent midnight endpoint. Event ends and query upper bounds can use it; starts, RDATE/EXDATE and task dates cannot. These endpoints allow a full all-day event on 2099-12-31. Endpoints are never emitted as occurrence starts.

Named-zone boundary fields can resolve into UTC in December 1969 or January 2100. Calculations therefore have UTC padding **[1969-12-30, 2100-01-03)**; the upper instant can bound generic geometry. Padding does not authorize ordinary out-of-profile calendar records. `UtcEventSpan.projected` is explicitly resolved geometry; canonical UTC events use the ordinary constructor and profile checks. No boundary is fabricated by truncating a result.

## Generated timezone data

Retain `timezone` 0.11.2 and IANA 2026e. Build checksum-pinned IANA tzcode/tzdata, use its `zic -b fat -r` to calculate all transitions within the padded horizon, then serialize without the dependency's first-transition sentinel filter. The package's pinned decoder reads the generated embedded data without initializing or modifying the host global registry. The serializer/decoder internal API dependency is deliberate, version-pinned and round-trip checked. The encoder lives in the core package, which declares the dependency.

The resulting artifact contains 598 exact names/aliases; the unknown-only Factory placeholder is excluded from usable IDs. Unknown `-00` periods remain explicit failures, never UTC or free time. Supporting this bounded profile is not a guarantee of known offsets for uninhabited/unspecified histories. Future results are projections of this pinned IANA release, not predictions of future legislation. Do not infer annual rules from the last two transitions, extend the last offset indefinitely, or bypass an unknown period.

The former 2037 restriction is replaced only with generated/proved coverage, not a changed constant alone. Runtime resolution still enforces the new profile. [Timezone data maintenance](../timezone-data.md) specifies generation, archive/artifact checksums, data/version consistency, update review and required recalculation of future dependent state. Those durable module services are not implemented by this pure core.

## Tests and consequences

Focus normal fixtures and exhaustive Gregorian/ISO checks on all 47,482 supported dates. Retain explicit outside-profile rejection and endpoint/UTC-spillover tests. Replace superseded fractional-preservation tests with rejection tests and zero-fraction acceptance. Retain recurrence COUNT/UNTIL, WKST, exception/range, task, span and DST regression scenarios; retarget overflow cases so they pass the newly legal exclusive endpoint before failing.

An independently decoded Python `zoneinfo` reference supplies 155,220 samples across 597 usable IDs and January/July of every supported year, preserving unknown-offset classifications. A deterministic digest is checked by Dart on VM and Chrome. Specific tests exercise 2038, 2050 and 2099, first/last boundaries, DST gaps/folds, half-hour/quarter-hour changes and skipped dates. These are native computation tests, not ICS round trips or client interoperability.

No production data exists and no backward compatibility or database migration is required for this unpublished API change. Generated protocol/database files, auth, Flutter UI, recurrence-edit services, scheduling and notifications are unchanged. Verify formatting/analysis, focused regressions, complete core VM/Chrome suites, reproducible generation and documentation consistency before one group commit; record actual results in [temporal validation](../temporal-core.md#current-profile-validation).
