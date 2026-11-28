# Repository CI checks

[Repository checks](../.github/workflows/check.yml) wires the existing local checks into GitHub Actions for pull requests, main-branch pushes and manual runs. This implements the CI orchestration required by NFR-14/NFR-15 and [ADR 0018's confirmed requirements](adr/0018-automated-example-and-multiple-instances.md). It runs the currently implemented feature profiles; a green run does not complete the remaining RFC, provider or external-client requirements.

## Jobs and evidence

The inspection job runs [the documentation checker](../tool/check_docs.py), checking repository-relative Markdown targets and consecutive ADR filenames. It compares the relevant base commit with the checked-out commit to select runtime checks. Changes consisting entirely of Markdown skip the expensive runtime job; manual runs and changes without a usable base run the full suite. This preserves focused documentation checks without weakening runtime-change validation.

The runtime job uses the unchanged `./tool/check.ps1` entry point. It checks stable generation, formatting, fatal-info analysis, core/iCalendar/module VM and Chrome suites, real database tests and populated upgrades. It then runs both invitation recovery profiles, alarm/notification and organizer/reply process-loss checks, two independent example hosts sharing test storage, generated clients, complete connected Flutter journeys and a release web build. Both host processes and controlled process loss are real; two clients connected to one process do not substitute for that topology.

Checks use a disposable Ubuntu 24.04 x64 runner, existing digest-pinned PostgreSQL/Redis images and newly generated synthetic credentials. Production credentials and real recipients are unnecessary. The workflow has read-only contents permission, disables persisted checkout credentials and has no deployment/publication operation. Test services are removed at the end; no production database or hosting environment is selected.

GitHub job conclusions and the implementation PR carry actual hosted results for each commit. The step summary includes test-success lines; private configuration, complete local source/transport recordings and credential files are not uploaded as artifacts. Generated credentials are masked before runtime tests. Newer runs supersede older runs for the same PR/ref, and runtime work has a ninety-minute ceiling. Local feature development still uses focused checks; full validation runs at completed batch boundaries.

## Toolchain and browser setup

[The bootstrap](../tool/setup-ci-linux.sh) installs the exact Flutter/Dart pairing in [toolchain.json](../toolchain.json) and activates the pinned Serverpod CLI. The Linux Flutter archive must match the checked-in SHA-256 before extraction. No SDK or workspace dependency version is silently upgraded. The bootstrap only runs in GitHub Actions on Linux x64; it does not configure a local desktop.

The hosted runner supplies Chrome, ChromeDriver, PowerShell, Python and Docker. Browser and driver build prefixes are compared before tests; a mismatch fails explicitly. Actual versions are printed in the run. The core test launcher uses an ephemeral Chrome wrapper with `--no-sandbox` for the disposable Linux runner; local browser configuration is unchanged. Browser-driver tests retain their existing headless configuration.

The selected checkout action is pinned to the full commit for v7.0.1. Sources checked on 2026-10-31: [GitHub workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [Ubuntu 24.04 runner inventory](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md), [checkout source](https://github.com/actions/checkout/tree/3d3c42e5aac5ba805825da76410c181273ba90b1), and [official Flutter release metadata](https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json). The runner image and browser can change over time; successful evidence belongs to its recorded versions and commit.

When changing Flutter/Dart, verify the new supported pairing and archive in official release metadata, update the version and Linux archive checksum together, and run the existing compatibility checks. Review checkout-action updates against its official release and pin the new full SHA. Pinned timezone-data updates remain governed separately by [the timezone procedure](timezone-data.md). Repository branch-protection settings and package publishing are separate maintainer operations.
