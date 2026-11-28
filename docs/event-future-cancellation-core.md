# Pure event future cancellation

Accepted [ADR 0157](adr/0157-pure-future-event-cancellation.md) adds an optional `cancelledFrom` to core `DateEventRangeSet` and `TimedEventSeries`. This is a pure active-occurrence projection. It does not enable native cancellation endpoints, incoming range CANCEL application, restoration, scheduling publication or external-client interoperability.

## Original identity and retained data

The inclusive cutoff uses original recurrence identity. DATE compares original dates; UTC/named-zone values compare original civil fields in the exact series profile. Actual moved starts and resolved instant order do not determine cancellation. Every original at/after the cutoff is suppressed, including moved singles and originals affected by later timing ranges. An earlier original moved after the cutoff stays eligible; a later original moved before it stays suppressed. Two civil identities resolving to the same instant remain distinct.

The original must belong to DTSTART/RRULE/RDATE/PERIOD minus EXDATE. A single-cancelled original can anchor the cutoff because it still belongs to that original recurrence set. Orphaned, excluded, foreign-profile and exclusive-end targets reject. Ordinary dates remain `[1970-01-01, 2100-01-01)` with whole seconds.

The cutoff may share an anchor with a single exception or timing range. Existing single/timing-range collision rules remain. It does not alter COUNT/UNTIL, rewrite EXDATE, remove additions or replace timing. Recurrence, explicit singles and later timing ranges remain immutable. Reconstructing the same value without a cutoff restores its previous active projection, including any pre-existing single cancellations; this is a pure value operation, not a durable restoration command or an alarm reset.

## API example

Given an already validated `DateEventExceptionSet base` and `changes`:

```dart
final cancelled = DateEventRangeSet(
  base: base,
  changes: changes,
  cancelledFrom: CalendarDate(year: 2026, month: 1, day: 3),
  maxRangeChanges: 16,
  maxValidationCandidateDays: 10000,
  maxValidationRuleOccurrences: 1000,
  maxValidationResults: 1000,
);
```

All active overlap results with an original on/after January 3 are suppressed, even if their timing moved them to January 1. Originals January 1/2 remain eligible under their existing timing. Timed series accept the same optional named argument using an exact `TimedValue` original. Existing callers that omit it retain their behavior. DATE equality/hash includes the cutoff.

## Budgets and failures

A cutoff consumes one DATE `maxRangeChanges` or timed `maxChanges` slot, even when its original matches another change. Zero capacity rejects it. DATE base single capacity remains independently enforced. Cutoff membership shares existing bounded validation and optional `RecurrenceWorkBudget`; sharing an anchor may share membership work without refunding consumed work. Existing duplicate timing changes and invalid retained state still reject.

Expansion retains candidate/history/raw-rule/base limits before cancellation filtering. An empty active result can therefore still fail its budget. Suppressed originals do not consume final active-result capacity; invalid query budgets still reject. No partial list escapes any failure. Filtering precedes shifted-span materialization so a cancelled occurrence need not overflow merely because its retained future timing would project beyond the horizon. Active projections retain normal overflow checks. All supplied replacement spans are validated at construction.

## Integration boundary and evidence

The core retains timing data; it contains no event content, authority, source versions or persistence. Later module integration must separately preserve content and source/cancellation identities. One effective cutoff is not a ledger for multiple received cancellations or partial restorations. No later timing edit implicitly reopens a cancelled suffix.

Existing native free/busy, feeds, alarms, queries and range CANCEL guards are unchanged because no adapter supplies the new cutoff yet. Tasks and availability openings do not gain future cancellation through this batch. Durable storage/source composition, cancellation-aware views, permissions, delivery invalidation, export/feed representability and explicit restoration require separate reviewed work.

Tests cover DATE/UTC/named zones, finite independent expected-result oracles, moved-in/out singles, later ranges, earlier RDATE/PERIODs, single cancellation, same-anchor capacity, invalid members/profiles, DST gaps/folds and horizon overflow. See [actual validation](scaffold-validation.md) for commands/results and [development checks](development.md). Pure tests are not evidence that an external subscription/scheduling client implements the same policy.
