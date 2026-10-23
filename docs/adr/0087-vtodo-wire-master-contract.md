# ADR 0087: Standalone VTODO wire master contract

Status: **maintainer-confirmed independent source progress values; first master adapter mechanics proposed**. Date: 2026-10-23.

The maintainer confirmed that VTODO STATUS, PERCENT-COMPLETE and COMPLETED retain their independently optional source values. Do not force native completion/reopen relationships onto a file, infer missing source timestamps or manufacture completion history. RFC 5545 section 3.6.2 makes these properties independently optional; sections 3.8.1.8/3.8.1.11/3.8.2.1 define their individual meanings and COMPLETED's UTC requirement. Source values never establish authority, host identity or proof of freshness.

Next implement a pure standalone master adapter for undated, DATE, UTC and named-zone tasks, optional explicit start/due or duration, recurring masters with start-only RDATE/EXDATE, basic annotated text, priority, source progress and protocol versions. Reuse the existing strict syntax/value codecs, bounded recurrence and exact full-horizon pinned-IANA VTIMEZONE validation. Require DTSTART for recurrence, preserve explicit DUE versus duration, reject floating/mixed profiles and ordinary values outside [1970,2100). This bounded profile is stricter than all legal RFC combinations; document rejections rather than describing them as RFC prohibitions.

Propose immutable source-derived task/calendar/recurrence projections retaining independent source presence and syntax trees, with deterministic reserialization and FREQ-first rule output. Validate the entire bounded file before returning any task. Reject unsupported occurrence components, PERIOD additions, alarms, scheduling METHOD/participants and unprofiled metadata rather than discard them. Occurrence wire components and additional publication metadata follow separately. Standalone source UID is text and independent of any future native task UUID.

This pure adapter grants no host approval, database import, assignment, scheduling or alarm activation. Database import mapping must separately reconcile independently optional source progress with native commands/current state and preserve independent master/occurrence versions before endpoints. No source completion-history records or assignee references are synthesized. VTODO iTIP/iMIP remains deferred under ADR 0011.

Validate round-trip preservation, all optional progress combinations, undated/due-only/start-only forms, nominal durations, recurrence/WKST, full-horizon zones, strict grammar, unsupported-data rejection and aggregate limits on VM/Chrome. Keep file semantics, native behavior and external-client compatibility claims distinct.

Source: [RFC 5545](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.2).
