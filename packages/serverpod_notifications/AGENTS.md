# Serverpod module

This project is a Serverpod module: a reusable package with server code (`serverpod_notifications_server`) and client code (`serverpod_notifications_client`) that other Serverpod projects add as a dependency. A module is not a runnable server, so there is no `serverpod start` and no `serverpod` MCP here.

Working loop, run from `serverpod_notifications_server`:

- Add models (`.spy.yaml`) and endpoints under `lib/src/`.
- `serverpod generate` after every change to a model or an endpoint.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). The migration ships with the module and is applied by the projects that depend on it.
- `dart analyze` and `dart format`.
- `dart test` to run the tests. Module behavior is initially exercised through the real example host and generated clients with isolated Docker test storage. Use the root local-check scripts; the standalone module template config is not the example integration environment.

Prefix table names with the module name (for example `serverpod_notifications_orders`) so they cannot collide with the tables of the projects that use this module.

NEVER edit generated code. `serverpod_notifications_server/lib/src/generated/` and the whole `serverpod_notifications_client` package are rewritten by the code generator. Change the models, the endpoints or `lib/serverpod_notifications_server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Projects that depend on this module reference its types as `module:serverpod_notifications:MyType`, where `serverpod_notifications` is the `nickname` in `config/generator.yaml`.

The approved ADR 0114 increment now contains generic scope/delivery/cursor storage, trusted acceptance, fenced publication/retry and authenticated live recovery. Follow the root delivery guide and actual validation record. Keep calendar/Flutter/provider dependencies out of this module and retain all root model-review gates.


## Reusable live notification increment, 2026-10-25

[ADR 0114](../../docs/adr/0114-reusable-notification-delivery.md) approves the generic three-table storage/defaults and live-reminder profile. The [delivery guide](../../docs/reusable-notification-delivery.md) describes durable idempotent acceptance, fenced retry/publication, fresh authorized source projection and the example Redis/Flutter streaming path. This supersedes earlier unconnected-delivery/scaffold-only wording for this scoped increment; the full local batch checks passed, with actual evidence recorded in the validation guide. Imported alarms remain unarmed; provider delivery, adoption and the remaining first-release requirements stay separate.
