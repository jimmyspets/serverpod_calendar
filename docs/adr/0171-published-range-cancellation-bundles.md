# ADR 0171: Pure published range-cancellation bundles

Status: **Proposed; explicit maintainer agreement required before implementation.** This is a pure outgoing-message prerequisite. It does not approve a publication checkpoint, database/API change, native cancellation, restoration workflow or delivery.

## Context and evidence

ADR 0170 completes the scoped repeated incoming source controls. The roadmap next selects outgoing range lifecycle. Existing organizer workflows retain published values separately from private drafts, use independent outgoing component versions and serialize partial publications. ADRs 0128–0130 implement individual cancellation/restoration and whole-series reopening; their v4–v6 checkpoints do not represent a published suffix cancellation.

[RFC 5546 section 3.2.5](https://www.rfc-editor.org/rfc/rfc5546.html#section-3.2.5) defines range CANCEL and permits multiple recurrence components for instance cancellation. Its CANCEL profile excludes VALARM and requires timezone definitions for named values. [RFC 5545 section 3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) orders ranges by original identity and distinguishes separately defined components in its range semantics. These primary references were checked on 2026-11-04. They do not establish tested client behavior for a mixed range/instance bundle.

The confirmed native/incoming policy cancels every original in the suffix, including moved exceptions. For outgoing publication, propose conservatively covering later explicit components as well as the recurrence suffix in one CANCEL message. This explicit coverage is an application projection, not a claim that every receiver requires redundant components. A pure batch establishes and tests that message boundary before choosing durable control/restoration mechanics.

## Proposed pure boundary

Add a separate pure helper and immutable result in the existing calendar server package's value/adaptation layer, independent of Session, policy adapters, SQL, clocks, workers and Flutter. Input is a supported active REQUEST basis containing exactly one recurring master and its supported occurrence components, an exact original point, an explicit proposed cancellation SEQUENCE/UTC DTSTAMP, and optional trusted lower sequence/stamp bounds for history absent from the supplied basis.

The REQUEST is only a claimed published basis. Revalidate it under selected syntax/component/source limits; the helper cannot prove that it was published, unmasked or authorized. Later durable integration must supply verified unprojected published values and all applicable historical/native version floors. Passing a native snapshot or a caller-supplied bound establishes no provenance. Reject detached/mixed-UID/non-REQUEST/non-recurring/inactive bases and unsupported data rather than repairing or stripping it into a supported REQUEST.

Require explicit source SEQUENCE and DTSTAMP on every basis component for this bounded native-publication profile. This is stricter than general source interchange, whose omissions remain preserved elsewhere. Organizer/attendee claims must fit the existing fixed, consistent publication roster profile, including legal parameters; omitted inherited claims may use the existing scheduling-only required-field projection. Explicit conflicting claims reject. Addresses grant no authority and cause no identity resolution, booking or network access.

Validate the selected original against the underlying supported recurrence set, preserving DATE/UTC/exact named-zone identity, exclusions, explicit earlier inclusions and PERIOD starts. Use original civil identity, never a moved start or an instant guessed to be equivalent. An exhausted membership scan is unavailable/limited, not absence or partial success. Reject a basis whose single/future identities collide at one original until that combination has its own supported profile.

## Proposed complete CANCEL projection

Emit one deterministic METHOD:CANCEL document:

- A primary component identifies the selected original with RANGE=THISANDFUTURE.
- Every explicit basis component strictly later in original order also gets a minimal cancellation component. Keep its single versus future range identity; a later future component retains RANGE=THISANDFUTURE.
- A component already at the selected anchor is represented by the primary component, with no duplicate target. Earlier explicit components are omitted regardless of their moved start times.
- Each component carries the exact UID, consistent published organizer/attendee claims, the explicit cancellation SEQUENCE/DTSTAMP and STATUS:CANCELLED. It carries no invented DTSTART, end/duration, summary or copied private/native text.

Use the existing pinned-zone writer for only the named definitions needed by emitted identities, preserving exact zone keys and full supported coverage. Minimal cancellation intentionally omits optional REQUEST content and alarms; the complete input stays unchanged and immutable. This is a method projection, not canonical import/export or silent loss of stored data. No CANCEL master, attendee-removal operation or per-target recipient filtering is introduced.

Validate and serialize the entire output through the existing pure scheduling codec. Return the immutable validated message, a detached ordered target manifest and comparison bounds. No partial bundle is returned. Successful parsing/serialization proves only the selected wire profile; the current recipient runtime still rejects bundled application without a separately reviewed reconciliation contract.

## Proposed version, limits and trust rules

Use one explicit cancellation version across this first bundle. Its sequence must exceed the maximum of **all** supplied master/occurrence sequences and the optional historical lower bound, including components before the selected anchor. Its whole-second UTC stamp must be nondecreasing against all supplied component stamps and the optional stamp bound. These conservative whole-basis floors are proposed application policy, not universal RFC requirements. Preserve input versions/omissions/content; never allocate a sequence, fabricate database time, wrap overflow or normalize fractions. Lower bounds cannot be treated as verified historical facts by later callers.

Retain ordinary [1970-01-01, 2100-01-01) timing and explicit-end rules, exact pinned zones, 512 KiB publication/output ceilings and existing component/property/date/zone limits. Primary plus explicit cancellation targets must fit the existing 64-override ceiling and any lower selected limit; the generated anchor consumes a slot. Do not omit a later exception to fit. Charge shared raw/recurrence work across basis validation, membership, target selection and output validation; a supplied shared budget cannot widen its selected ceiling. Bound manifests before allocation and keep diagnostics non-echoing.

No SQL table/column/index, generated model/endpoint, dependency, checkpoint version, permission, retention increase, native cutoff, feed/export guard change, notification action or network submission is proposed. Existing outbox/worker guards and incoming v12 semantics remain unchanged. The helper cannot arm an alarm, approve participant claims, bypass host policy or make an unsupported runtime action available.

## Alternatives and consequences

A single range component is smaller but does not explicitly cover separately published exceptions in this conservative projection. Enumerating generated instances cannot represent an unbounded suffix. Separate delivery messages would add ordering/uncertainty requirements to the current global generation fence. The proposed one-message bundle covers the finite explicit exception set with bounded work, while retaining clear all-or-nothing limits.

Durable cancel/restore, whole-series composition, repeated outgoing cycles, exact receipts, published reply-target invalidation and native draft/alarm effects still need one subsequent concrete grouped contract. Restoration must faithfully clear the recipient's range state while preserving individual cancellations and current unpublished drafts; do not assume a newer master alone removes a remote exception. This proposal deliberately creates no durable state that lacks an approved restoration path. RANGE replies, other selected methods, transport trust, real mail and external-client evidence remain required separately.

## Proposed grouped validation

Cover DATE/UTC/named-zone bases; ordinary/explicit gap/fold originals, exact aliases, earlier RDATE/PERIOD starts and exclusions; ordinary, moved single and later-future targets; exceptions moved across the cutoff in both directions; anchor-component deduplication; preserved input versions/text/participants/alarms; and detached immutable output ownership. Test deterministic complete serialization/parse round trips without inferring recipient application.

Cover missing/wrong method/master/UID/profile/roster/version, invalid optional lower bounds, equal/older/maximum sequences, source clocks/corrections, fractions, exclusive boundaries, raw source/output/zone/component/target/work limits and one shared aggregate budget. Reject the whole operation on any unsupported or over-limit target, including an anchor that would exceed the 64-target profile. Keep existing pure and durable scheduling regressions; explicitly prove that new REQUEST publication with native future cancellation stays guarded.

Use focused pure VM tests during development, then formatting, full fatal-info analysis, complete module VM/Chrome and directly affected existing native guard checks at batch completion. Rerun core/iCalendar suites if their source/dependencies change or failures warrant it; full exact-head repository CI remains a readiness gate. Commit/push code only after the complete approved pure batch. No database, Flutter, delivery or real-client success is established by these pure tests.
