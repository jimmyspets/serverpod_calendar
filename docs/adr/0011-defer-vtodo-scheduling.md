# ADR 0011: Defer VTODO scheduling over iTIP and email

> Notification scope update: [ADR 0020](0020-notification-delivery-scope.md) supersedes earlier requirements for direct iOS/Android push delivery. Durable alarms remain required; a reusable notification module and connected Serverpod streaming example replace the platform-provider release gate. Earlier platform examples below are historical proposals.

Status: **Maintainer-confirmed first-release scope; implementation details proposed**. Date: 2026-10-19. Formal ADR acceptance remains subject to repository review.

## Context and source

After distinguishing native tasks, RFC 5545 VTODO interchange and task scheduling messages, the maintainer instructed: "Lets not implement VTODO over iTIP or mail for now". This resolves the previously undecided task method scope in ADRs 0007/0008 and the RFC 5546 matrix.

## Scope decision

Defer all VTODO iTIP methods and their inbound/outbound iMIP email binding from the first release: PUBLISH, REQUEST, REPLY, ADD, CANCEL, REFRESH, COUNTER and DECLINECOUNTER. Do not generate task scheduling mail or apply received VTODO scheduling messages.

Native Serverpod/Flutter task CRUD, assignment, lifecycle, supported standalone RFC 5545 VTODO import/export and task alarms/mobile push remain first-release scope. Event/free-busy iTIP scheduling and iMIP email remain in scope. Recurring tasks were subsequently included under [ADR 0017](0017-profile-review-clarifications.md). Their lifecycle semantics and exact standalone VTODO constraints still require design; this does not change the scheduling-mail exclusion.

## Proposed handling and boundaries

Validate actual payload components and methods rather than trusting MIME hints. Unsupported VTODO scheduling input must fail explicitly or be quarantined under the trusted ingress policy, without task/scheduling mutation or automatic replies. Outbound dispatch must reject it before queueing delivery. Do not silently reinterpret a scheduling message as ordinary task import or use event method handlers for tasks. Mixed supported/unsupported scheduling input must not partially mutate state.

This scope decision concerns calendar task scheduling protocols; it does not remove native task assignments or the existing task alarm/push requirements. A host mail or notification service cannot bypass the deferred calendar protocol boundary.

## Alternatives and consequences

Implementing every VEVENT method for VTODO now would expand task assignment/reconciliation and mail interoperability work beyond the chosen first release. Native tasks plus standalone interchange meet the retained scope. Task scheduling can be revisited in a later ADR with explicit component/method, trust, recurrence, ordering and client evidence.

## Acceptance conditions

- No VTODO method is advertised or routed as supported iTIP/iMIP.
- Test every deferred VTODO method against scheduling ingress and outbound dispatch, including mixed components, with no mutation, partial processing or task mail side effects.
- Verify standalone VTODO round trips and native task assignment/lifecycle/alarms independently.
- Retain supported event/free-busy scheduling and email acceptance criteria.

Traceability: [requirements](../requirements.md), [standards](../standards.md), [compatibility](../compatibility.md), [RFC 5546](../rfc/rfc-5546.md), [RFC 6047](../rfc/rfc-6047.md), ADRs [0007](0007-scheduling-and-email.md) and [0008](0008-module-clients-tasks-and-search.md), work packages [scheduling work](../roadmap.md#scheduling), [mail integration work](../roadmap.md#scheduling) and [task work](../roadmap.md#tasks).
