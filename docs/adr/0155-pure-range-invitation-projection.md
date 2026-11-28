# ADR 0155: Pure range REQUEST application projection

Status: **Proposed 2026-11-01. No implementation or durable range application approval is inferred from ADR 0154.**

## Context and evidence

ADR 0154 admits trusted THISANDFUTURE REQUEST/CANCEL for private review only. Native timing-range overrides and the pure ordinary event adapter already support timing shifts with exact original identity, independent later range segments and explicit single exceptions. The existing detached invitation projection rejects RANGE. Its durable acceptance JSON/checkpoints describe singles; enabling range application there would assume unreviewed cross-target versions and cancellation coordination.

Inspected invitation projection, event wire storage/series validation, future override/protocol carriers and the accepted master/instance composition contract. [RFC 5545 RECURRENCE-ID](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) defines subsequent instances by original identity, exempts separately defined instances and describes uniform timing/duration changes. [RFC 5546 REQUEST](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.2) supplies scheduling context (checked 2026-11-01). The bounded anchor-content and reject policies below describe this project profile, not complete RFC support.

## Proposed grouped pure scope

Add a separate pure range-REQUEST projection in the existing Serverpod value-adaptation layer. Input is one complete accepted UID/content/overrides/protocol state, a parsed one-component detached THISANDFUTURE REQUEST and expected recipient address. Reuse the immutable projection result/source carrier where possible; add no generated model, database table, endpoint or Flutter action. Preserve the existing single REQUEST/CANCEL helper's rejects and behavior.

Validate actual input shape, supported source budgets, active recurring accepted master, exact UID/organizer/recipient correlation, undelegated claims and exact DATE/UTC/named-zone original/profile/membership. Unknown, excluded or removed originals reject. A parsed envelope, caller-supplied accepted values and recipient establish no trusted origin, clean baseline, freshness, authority or stored existence.

Replace only the future component at the selected original, or add it if absent. Preserve master content/protocol versions, all single overrides/cancellations and all future components at other originals, including their independent source versions. Reject a selected anchor already occupied by a single component in this first profile rather than silently converting/removing it. Existing later future components delimit their own segments; shifts replace the active shift and never compound it. Explicit singles retain their independent timing/content/cancellation. Membership/order uses original identities, not moved starts.

Map explicit replacement timing and end/duration through the existing bounded wire/core future policy, preserving source kind/zone/form and ordinary whole-second horizon/endpoint rules. Weeks/days retain calendar-unit/DST meaning. Do not flatten a range into enumerated singles, expand an unbounded series, change RRULE/RDATE/PERIOD/EXDATE, or turn a source component into a new master.

Use the existing event wire profile for non-timing claims: omitted selected SUMMARY/DESCRIPTION/LOCATION inherit, explicit values (including empty text) remain local to the anchor; only timing propagates. Repeated richer metadata/participant/reference/alarm claims must satisfy the existing master-matching profile; differing unprofiled data rejects. STATUS/TRANSP follow existing matching rules. Keep this anchor-local content limitation explicit; this is not blanket range content propagation.

Preserve incoming independent SEQUENCE, DTSTAMP and optional CREATED/LAST-MODIFIED, text/source-presence flags and accepted source distinctions on the selected future component. Allocate no native/API/protocol clocks, revisions, identities or accepted-source history. The result retains the original parsed message so source claims and canonical proposed values remain distinguishable. No stripping properties/alarms or inventing participant authority to manufacture a valid projection.

Share bounded candidate work across accepted-state validation, original membership and source/canonical projection, using the existing 200,000 ceiling and 128 native override slots. Apply existing wire input ceilings to the one incoming component and required master validation without promising a 128-component wire export or forcing unrelated native-only slots through the smaller export profile. Failure produces no partial result or mutation. Preserve ordinary standalone export's faithful-mapping guards.

## Validation and consequences

Cover DATE/UTC/named zones, DST shifts/gaps/folds, end/duration units and endpoint limits; RRULE/RDATE/PERIOD/earlier additions/EXDATE; original versus moved starts; earlier/later future segments and explicit singles/cancellations; replacing one future component; independent versions/omissions and anchor content inheritance/empty values; incompatible source claims, selected single collision and work/slot exhaustion. Verify input/result immutability and existing single projection regressions. Run focused VM tests during development and complete agreed batch checks before one implementation commit.

This is a pure prerequisite. Review-only intake and all current range mutation/response guards remain. Durable range application still requires an actual clean entire-series baseline, independent source/host/native rights, cross-target version/overlap policy, accepted-source retention/checkpoint review, concurrency and exact retry contracts. Future CANCEL/restoration, range responses, organizer range publication/reconciliation and real transport remain separate required work.

Implementing durable writes immediately would hide unresolved checkpoint/overlap choices. Flattening to singles loses range meaning and exceeds bounded storage; reusing the single helper by dropping RANGE changes source semantics. A separate pure helper exercises the existing range representation without authorizing persistence.

The repository requires explicit maintainer agreement on these concrete pure protocol mechanics before implementation. Approval here would not approve durable range application or future cancellation.
