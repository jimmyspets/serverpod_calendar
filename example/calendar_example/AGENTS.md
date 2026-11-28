# Calendar example host and Flutter Web app

This is the automated integration/example host for the root workspace. It uses official Serverpod authentication with synthetic seeded accounts and the built-in JWT token manager and refresh endpoint. It exposes diagnostic/identity endpoints and the first native calendar CRUD/association module with a Flutter screen and replaceable private-user demo policy. The ADR 0114 increment also wires generic delivery to calendar source checks and authenticated Redis/Flutter streaming. Remaining domain/release requirements stay planned; use the current roadmap and validation record.

The maintainer authorized the repeatable local CLI workflow in ../../docs/development.md. Use the root setup/generation/check/start scripts. They start and stop owned test hosts, use isolated Docker test storage and exercise real generated clients and Flutter Web. Verify Serverpod MCP availability in the current tool session rather than assuming configuration implies access. Never expose seeding/reset as production endpoints, send real auth email, or commit local secrets.

## Interactive MCP workflow

If a Serverpod MCP is configured for an already running interactive server, prefer it for create_migration/apply_migrations, repair migrations, tail_server_logs/tail_flutter_logs, hot_reload/hot_restart, spawn_flutter_app and get_flutter_app_dtd. Connect the Dart tooling daemon for interactive Flutter driving when available. The CLI scripts remain the supported automated fallback and do not require a manually started server. From the repository root, use `./tool/start-server.ps1 -Interactive` for the MCP-capable watch runner with the existing local setup. Stop the compiled development host first; keep the runner alive while using MCP. Stop running development processes before rebuilding native assets. Project-local MCP configuration is ignored; recheck client registration and connection after restarting the client.

## Generated code and migrations

Never hand-edit the server's lib/src/generated/ directory, the generated client Dart or generated test tools. Edit endpoint/.spy.yaml sources and use ../../tool/generate.ps1. Dependency manifests are workspace sources; generated protocol files are not.

After approved table-source changes, create migrations with the pinned CLI or configured MCP and verify fresh/upgrade database behavior. Do not manually edit generated migration metadata. A migration.sql transformation is a narrow exception only when needed to preserve data and match the generated final schema. Calendar domain schema decisions remain gated by the root model catalog/ADRs.

## Checklist

1. Run formatting and analysis through the root checks.
2. Regenerate protocol/client/test tools after endpoint or model changes.
3. Create/apply migrations only when approved table sources change.
4. Run the real-host/generated-client/Flutter smoke harness. Test reset affects only the dedicated synthetic test database.
5. Inspect test host/browser logs under ignored .local/. For an interactive MCP session, inspect server/Flutter logs and hot-restart if needed.
6. Keep every production-only provider credential and platform push implementation outside this example scaffold.

Flutter launches from calendar_example_flutter/lib/main.dart. Browser automation uses integration_test/connected_smoke_test.dart and test_driver/integration_test.dart through the root harness. No legacy driver.dart is used.


## Reusable live notification increment, 2026-10-25

[ADR 0114](../../docs/adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](../../docs/reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.


Under accepted ADR 0122, the example also installs the bounded non-recurring REQUEST organizer runtime and **Meeting invitations** editor. It derives organizer authority from the current demo user and approves synthetic `example.invalid` recipients only. Transport writes ignored fixtures and sends no real mail. Ordinary event edits do not send. Existing migrated events remain unknown-origin; never reset development storage or infer provenance to enable publication. See ../../docs/native-organizer-scheduling.md for the exact scope and future lifecycle restrictions.


Under accepted ADR 0123, the example also demonstrates explicit Cancel and notify and Reopen and notify. Cancellation sends the last published snapshot, preserves saved local fields and remains synthetic-only. Dedicated host context distinguishes final native state from outgoingEvent; authorize the exact method and disclosure. The public DTO changes add no database table/column. Deletion, recipient/recurrence changes, inbound reconciliation and real mail remain separate.


Under accepted ADR 0124, the meeting screen can publish saved recurring-master patterns. It keeps fixed recipients and explicitly disables new REQUEST publication while native occurrence exceptions exist; those exceptions remain saved and whole-series cancellation preserves them. Worker probes and two-host/Flutter journeys now cover recurring REQUEST/CANCEL. Source data and delivery remain synthetic-only, with no new migration or provider setup.

Accepted ADR 0126 now permits complete representable occurrence REQUEST bundles. The example host implements `authorizeMessage` with the complete outgoing message/digest and canonical snapshot; the editor explains unsupported cancellation, follow-series timing and published-reset boundaries. Rejection preserves saved edits; cancelling the whole series preserves native drafts and independent publication-version history. Process-loss, generated-client and Flutter journeys now exercise occurrence bundles. Keep every transport synthetic and preserve development storage.

Accepted ADR 0127 now permits resetting retained originals to current series values without creating native overrides. Existing clear/follow-series actions remain local until explicit Save and notify. The example explains retained publication identities; two-host clients and Flutter journeys clear published timing, publish the reset and preserve native inheritance through later edits/cancellation/reopening. Independent worker fixtures exercise v3 reset messages. Individual cancellations and missing-member/kind changes still reject; no real mail, new migration or development reset is added.


Accepted ADR 0128 implements explicit historical single-occurrence Cancel and notify. Preserve unpublished drafts and mutate native flags only for an exact current kind/zone/member match; budget failures never imply absence. Separate instance/lifecycle/full-source/read authority and complete-message host approval apply. Terminal prior deliveries gate every new partial intent, preserving the global generation fence. Keep self-contained v4 cancellation envelopes with validated v3 REQUEST bases and bounded independent cancellation versions; legacy readers remain. Generated DTO/status/client/host changes add no table/migration. New REQUEST/reopen is blocked while individual cancellations remain; local restore sends nothing. Individual restoration, range cancellation, concurrent partial coordination and real mail remain separate.


Accepted ADR 0129 implements published-value individual restoration with preserved drafts. Keep latest cancelled/restored versions separate from last active REQUEST components in bounded v5 private envelopes; full REQUEST refreshes a non-recursive legacy/v3 basis while retaining restored identities. Clear only an exact current native single flag; never pin timing or erase private ranges/content. Dedicated restore/lifecycle/full-source/read and complete-message host checks plus terminal-prior-delivery gating remain required. Master version floors come from the master ledger, not a partial row. Complete publication requires zero remaining individual cancellations and valid retained native membership/profile. Cancelled masters, range/parallel-partial coordination and real mail remain separate; no new table/migration or development reset.


Accepted [ADR 0130](../../docs/adr/0130-preserved-cancellations-reopening.md) adds published-value reopening and full-message restoration with publication-only exclusion state. Preserve native drafts/flags, separate authority and exact retry commands. No new tables or real mail; canonical import/export/feeds remain independent. Use focused tests during development, then the complete agreed batch checks.

Accepted ADR 0131 adds the protected attendee response/source review screen and development/test-only synthetic reply simulator. The actual authenticated private demo owner and fixed example.invalid roster are verified server-side; this establishes no real mailbox identity. The reusable module has no ingestion endpoint accepting sender proof. Keep body-defining values stable on uncertain retries, display current/prior/unknown separately, and show raw source only through its independent gate as inert text. Never apply stale records automatically or send mail. See ../../docs/authenticated-attendee-replies.md.

Accepted ADR 0132 extends trusted replies to recurring masters without new tables/migrations. Resolve the actual master through validated partial/v6 checkpoints; never classify against a detached carrier sequence. Preserve complete host context, source semantics, drafts and whole-series labels. Every master-changing publication must update source inactivity in the same scope transaction; instance/range replies and mail remain separate. See ../../docs/authenticated-attendee-replies.md.

Accepted ADR 0133 adds exact single-instance replies, generated target fields/index changes and collision-safe outgoing profiles. Preserve master/instance separation, exact typed originals, complete published/effective host context, unknown versions on retained removed-target retries, source privacy and scope transactions. Upgrade legacy publication profiles only through an explicit newer full Save and notify; partial actions never invent the profile. Native inheritance/source versions stay separate, all publishing hosts maintain target inactivity, and RANGE replies/mail remain separate. See ../../docs/authenticated-attendee-replies.md.

Accepted ADR 0134 adds native event descriptive subset editing and ordinary VEVENT fields in existing JSON, without SQL changes. Preserve exact coordinate strings, grouped resource annotations, field disclosure, source compatibility and independent outgoing versions. Keep labels inert and imported alarms unarmed. See ../../docs/native-event-descriptive-fields.md.

Accepted ADR 0135 adds the [native text/link subset editor](../../docs/native-item-text-metadata.md), independent field disclosure and selected-field host context. Preserve CONTACT/private source data, matching component presence, baselines and task progress/history. The separately approved private native task marker keeps native rows independent of wire limits; it grants no provenance or authority and is cleared from temporary exports. No SQL migration or real mail is added.

Accepted ADR 0136 adds [exact event/task master-category search](../../docs/item-category-search.md). Require ordinary read and category disclosure before matching; preserve response groups and immutable query context. Bind criteria to existing opaque cursor storage, charge all raw candidates, and fail unavailable/budget checks explicitly. Labels and empty detail results establish no authority or availability. No SQL change is expected; generated clients and host query adapters must upgrade together.

Accepted ADR 0137 implements [trusted non-recurring invitation intake/private review](../../docs/invitation-intake-and-review.md). Verify actual origin/target before private history, retain independent source versions/receipts and declared policy guarantees, and protect summary/source/dismiss separately. The three approved tables do not create calendar/participation/notification state. Keep exact retained retries distinct from current queue state, bounded retention/capacity and source-body-pruned markers fail-closed. Add/calendar updates, recurrence/CANCEL and real mail remain separate.

Accepted ADR 0138 adds explicit one-event invitation calendar adoption; see [the scoped guide](../../docs/invitation-calendar-adoption.md). Preserve one logical recipient/source correlation across inbox expiry, atomic event/link/review writes and independent authority. Retained retries never replay content or dismiss newer sources. Generic source replacement on linked events rejects even without invitation ingress; ordinary deletion scrubs payload and retains the minimal identity/link. No participation reply, source update, relink/purge or real mail follows.

Accepted ADR 0139 adds [explicit linked invitation updates](../../docs/linked-invitation-updates.md). Preserve original creation receipts, strictly newer source ordering and local-change rejection. The one-per-link checkpoint stores only current accepted descriptors/digests and latest result; older update retries become stale after a later application. Reauthorize no-ops, preserve body-expiry unknown evidence and personal state, and commit event/baseline/checkpoint/review changes atomically. Generic file replacement remains blocked on all hosts. No automatic update, overwrite/merge, incoming CANCEL/recurrence, reply or mail follows.


Accepted ADR 0140 implements bounded trusted non-recurring whole-meeting cancellation intake/private review; see [the profile](../../docs/invitation-cancellation-review.md). Preserve explicit source kind/omissions, independent receiveCancellation authority, actual known correlation and accepted REQUEST sequence floors. Current markers retain kind after body expiry; historical REQUEST bodies remain independent. Transport context never fabricates a native actor. Add/Apply remain REQUEST-only, retained retries never dismiss newer cancellation, and receipt/dismissal change no native/baseline/checkpoint/alarm/outbound state. Required linked evidence fails unavailable; explicit application, attendee removal, recurring intake and mail remain separate.
