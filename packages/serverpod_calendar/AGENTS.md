# Serverpod module

This project is a Serverpod module: a reusable package with server code (`serverpod_calendar_server`) and client code (`serverpod_calendar_client`) that other Serverpod projects add as a dependency. A module is not a runnable server, so there is no `serverpod start` and no `serverpod` MCP here.

Working loop, run from `serverpod_calendar_server`:

- Add models (`.spy.yaml`) and endpoints under `lib/src/`.
- `serverpod generate` after every change to a model or an endpoint.
- `serverpod create-migration` after changing a model with a `table` (add `--force` for destructive changes). The migration ships with the module and is applied by the projects that depend on it.
- `dart analyze` and `dart format`.
- `dart test` to run the tests. Module behavior is initially exercised through the real example host and generated clients with isolated Docker test storage. Use the root local-check scripts; the standalone module template config is not the example integration environment.

Prefix table names with the module name (for example `serverpod_calendar_orders`) so they cannot collide with the tables of the projects that use this module.

NEVER edit generated code. `serverpod_calendar_server/lib/src/generated/` and the whole `serverpod_calendar_client` package are rewritten by the code generator. Change the models, the endpoints or `lib/serverpod_calendar_server.dart` instead.

Migrations are a narrow exception: the `migration.sql` of a generated migration MAY be edited by hand when the generated SQL would lose data — to add a data transformation, or to reach a destructive change through non-destructive steps. Never touch the other files in the migration directory, and keep the schema the SQL ends up with identical to `definition.sql` — new databases are created from that file and never run `migration.sql`.

Projects that depend on this module reference its types as `module:serverpod_calendar:MyType`, where `serverpod_calendar` is the `nickname` in `config/generator.yaml`.

This is the serverpod_calendar scaffold. Native calendar CRUD/association endpoints, host-policy enforcement and module migrations now exist under docs/adr/0049-first-calendar-crud-implementation.md. Other domain behavior and delivery semantics are pending; follow the root requirements and model review gates.

Native description/RGB and scoped decoded NAME/DESCRIPTION/COLOR metadata extend this slice under root docs/adr/0050-calendar-presentation-and-protocol-text.md. Preserve separate permissions/groups and native/protocol values; immutable adapter validation is not wire parsing or feed support.
