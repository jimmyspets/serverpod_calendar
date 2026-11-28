# Optional calendar event feeds

This Serverpod module owns subscription management, digest-only credentials and HTTP event publication under [ADR 0116](../../../docs/adr/0116-optional-event-subscription-contract.md). Use [the integration/limits guide](../../../docs/http-event-feeds.md) and the real example host; the module is not a standalone server.

Publication UIDs derive from native event UUIDs and all alarms are excluded. Authenticated source import/export stays in the calendar module. Install the host publication policy and the exact dependency provider first, then the feed module/route, and wrap whole-host startup with `runWithCalendarFeedLogRedaction`. Configure HTTPS and equivalent proxy/tracing redaction.

This package is unpublished (`publish_to: none`). Scoped implementation is under review and batch validation is in progress; no Apple/Google/Outlook interoperability or entire first-release completion is claimed.
