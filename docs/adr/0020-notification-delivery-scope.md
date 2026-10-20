# ADR 0020: Reusable notifications and example streaming delivery

Status: **Maintainer-confirmed scope; implementation proposed**. Date: 2026-10-19. Formal ADR acceptance remains separate from this recorded instruction.

## Context and confirmed instruction

During the scaffolding walkthrough the maintainer chose a reusable notification module in the same repository. They clarified: “the delivery to iOS and Android are only examples and should not be implemented directly here.” They suggested that example code could use Serverpod server events streamed to the Flutter client.

This newer instruction supersedes the earlier working iOS/Android push requirement in ADR 0009 and dependent release gates. Durable event/task alarm processing, recipient privacy, authenticated actions and multiple-active-instance correctness remain required. No direct FCM/APNs, platform token registry, mobile push plugin or OS background delivery implementation is required here. Platform delivery remains an external host adapter concern.

## Proposed implementation boundary

- Calendar owns alarm rules, occurrence/generation/action state, durable planning and reminder intent.
- A separate reusable notification module owns provider-independent delivery contracts and durable generic intent/lifecycle behavior. Host adapters implement actual transports. The module can support non-calendar notifications.
- Example host code adapts notification intents to Serverpod server-event channels and an authenticated streaming endpoint; Flutter example code subscribes and presents in-app notifications/actions. Exact APIs/configuration are verified against the pinned toolchain during scaffolding.
- Host policy resolves recipients and scope server-side. Recheck current recipient authority, generation, cancellation and expiry at handoff, retry and resubscription boundaries. A channel name or payload ID is not authorization.

Serverpod documents server events as channel messaging across configured cluster instances, and streaming methods as WebSocket-connected Dart streams. The example must test this with two independent hosts rather than assume the selected infrastructure is configured correctly.

Transport events do not replace durable intent or create guaranteed offline replay. Define a bounded authorized query/resubscription contract for missed notifications and reconcile current state after reconnect. No replay retention, cursor algorithm or new inbox schema is selected by this ADR. Receipt, in-app presentation and acknowledgement are distinct; stream publication is not proof that a person saw an alarm. Connected streaming does not establish background/terminated-app mobile delivery.

## Alternatives and consequences

A direct FCM/APNs reference implementation would add platform dependencies beyond the clarified request. A calendar-specific stream alone would omit the selected reusable notification boundary. A purely transient notification queue would lose durable lifecycle/recovery semantics.

The connected example gives an automated integration path without provider credentials. External push integrations can implement the same port later and must supply their own device/security/retry/platform evidence. Existing RFC alarm action/profile scope, restricted iMIP mail requirements and subscription-client targets are unchanged.

## Acceptance conditions

Implement the real module-to-notification handoff and example streaming path. Test current authorization, logout/access revocation, disconnect/reconnect, missed-state recovery, cancellation/expiry/supersession, duplicates and authenticated actions. Run cross-instance routing and worker-recovery tests using shared durable state and deterministic notification adapters. Keep sensitive event details out of unauthorized streams and logs; never expose test controls in production endpoints. No real mail or external push delivery is authorized by this documentation change.

Sources: maintainer walkthrough instruction; [Serverpod streaming](https://docs.serverpod.dev/concepts/endpoints-and-apis/streaming) and [server events](https://docs.serverpod.dev/concepts/server-events/) reviewed 2026-10-19. Traceability: [requirements FR-28–FR-31/NFR-12–NFR-15](../requirements.md), [notification roadmap](../roadmap.md#alarms-and-push), [model catalog](../models.md), ADRs [0009](0009-alarms-and-notification-boundaries.md) and [0018](0018-automated-example-and-multiple-instances.md).
