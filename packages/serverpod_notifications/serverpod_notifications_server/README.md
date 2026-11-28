# serverpod_notifications_server

Reusable durable live notification delivery for Serverpod. Hosts register trusted source adapters, recipient/access policy and a publication port. The module stores bounded source references and retry state; it projects current authorized text instead of retaining a content inbox. It has no calendar or Flutter dependency.

See [the delivery contract and limits](../../../docs/reusable-notification-delivery.md), [approved models](../../../docs/adr/0114-reusable-notification-delivery.md) and [local development](../../../docs/development.md). The example supplies the calendar adapter and authenticated Redis/Flutter stream. Provider SDKs, mobile background delivery and imported-alarm adoption remain outside this increment.

Use the root generation/check scripts. Edit source models/endpoints and regenerate; never hand-edit protocol/client files or migration metadata. The module is hosted by an application, not a standalone server. Actual completed checks are recorded in [the validation guide](../../../docs/scaffold-validation.md).
