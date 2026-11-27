# ADR 0053: First native non-recurring events

Status: **Accepted batch/summary/lifecycle boundaries; API/storage mechanics under review**. Date: 2026-10-21.

The maintainer selected non-recurring event CRUD first, optional/empty summaries with an example-only Untitled event placeholder, cancellation distinct from content deletion, a minimal event marker (UUID, parent calendar UUID, revision, deletion time), and a separate lifecycle permission. Recurrence remains first-release scope and follows in a dedicated batch. No scheduling message is sent by these operations.

## Implementation profile

[RFC 5545 section 3.6.1](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.6.1) defines the event envelope and omitted-end semantics. Reuse the accepted temporal core under ADRs 0035/0039/0040/0041; native creation defaults and editing limits below are implementation choices, not new RFC requirements.

Use immutable generated civil/duration/timing/content command values and the existing independent temporal core for validation. DATE, explicit UTC and exact named-zone profiles preserve civil meaning, original explicit end versus duration versus omission, whole seconds and [1970,2100) with approved exclusive endpoints. Reject floating, recurring=true, invalid/mixed bounds, nonzero fractions and unsupported zones. This is a typed native API, not raw ICS parsing or arbitrary JSON member validation.

Summary/description/location are optional preserved decoded plain text (4096/16384/4096 code points respectively), with no implicit placeholder or trimming. Native status defaults to CONFIRMED and transparency to OPAQUE; these are explicit native creation defaults, not a claim that omitted RFC STATUS implies CONFIRMED. Preserve cancellation as status; reopening selects confirmed/tentative. Status changes have their own host permission; full content updates changing status need both edit and lifecycle decisions, and creating already-cancelled data needs lifecycle authority too. Moves, scheduling, alarms, relationships and import remain absent.

Keep a UUID/revision/deletion identity row per event with its actual parent, plus a separate active payload containing random protocol UID, content and administrative timestamps. No client-supplied UUID/UID; UID survives edits/cancellation. Deletion removes active payload/UID and retains only the approved marker. Calendar deletion rejects active events. Existing scope-row locks serialize parent deletion/event creation and event writes across hosts. Event mutations bump scope generation and their own revisions, without changing the parent calendar's metadata revision/time.

Extend host requests with actual parent/calendar snapshot, actual event identity/current immutable event snapshot and validated proposed content; host actor/scope stays trusted. Separate event list/read/create/update/status/delete actions and predefined summary/description/location/timing/state/identity disclosure groups. Calendar metadata access never implies event access. Host event candidate plans constrain a bounded UUID-ordered per-calendar detail list; per-object authorization remains required. No time-window or free/busy result is inferred from these lists.

Use existing durable opaque cursors with event-query discrimination, parent ID, exact groups/page/actor/scope/policy/data/expiry bindings, authorized lookahead and no totals. Calendar and event cursors reject cross-use. Scope mutations invalidate both. Revisions, final host checks, receipt disclosure, no silent guarantee downgrade and callback limits match the calendar service. PostgreSQL time orders administrative writes without pretending to coordinate external authorization.

## Validation and remaining work

Test temporal DTO boundaries/DST/unit preservation, separate host rights and disclosure, actual immutable parent/event/proposal context, invalid/stale/denied atomicity, cancellation/reopening versus deletion, cursor bindings, populated upgrades, two hosts and Flutter journeys. Use a simple example event editor/list, not a calendar-layout GUI package. Recurrence, occurrence edits, native interval queries/free-busy, participants and scheduling, alarms, richer metadata and ICS/feed interoperability remain pending. Actual commands/results belong in the validation guide.
