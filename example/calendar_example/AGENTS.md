# Calendar example host and Flutter Web app

This is the automated integration/example host for the root workspace. It uses official Serverpod authentication with synthetic seeded accounts and the built-in JWT token manager and refresh endpoint. It exposes diagnostic/identity endpoints and the first native calendar CRUD/association module with a Flutter screen and replaceable private-user demo policy. Remaining domain and notification delivery features remain planned.

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
