# Generated feed management client

Use the example host's generated `client.modules.serverpod_calendar_feed.calendarFeed` API. It requires normal host authentication and policy. Create/read/update/delete settings separately from credential listing, issuance and revocation. Only issuance returns a full secret URL; never log or persist that response as ordinary management metadata. Subscription GET/HEAD access is through the read-only HTTP route.

See [the feed guide](../../../../docs/http-event-feeds.md). This client is generated from server endpoint/model sources; do not hand-edit its Dart implementation.
