# Incoming information-publication bundle validation

ADR 0185 and its complete-set/regression policy are explicitly approved. This is an in-progress validation record for the grouped implementation on 2026-11-14. No feature-code commit, merge, publication, deployment or real mail is claimed here.

## Completed focused checks

- Module `dart test test/unit/incoming_publication_bundle_values_test.dart --reporter expanded`: **23 passed**, covering DATE/UTC/zones, DST gap/fold behavior, component ordering, omissions, version floors, recurrence membership and shared exhaustion (`.local/185-pure-current.log`).
- Example `dart test --concurrency=1 test/integration/incoming_publication_bundles_test.dart test/integration/incoming_publications_test.dart --reporter expanded`: **39 passed** at the six-case bundle stage plus all 33 prior cases (`.local/185-bundle-sdk-regressions.log`). The first final-denial fixture changed the wrong operation's rule; it was corrected and rerun, not counted as passing.
- Expanded bundle SDK suite: **21 passed**, adding independent authority, historical retries, DATE/IANA names/aliases across DST, PERIOD lifecycle, local conflicts and deletion-marker checks (`.local/185-bundle-sdk-temporal.log`). Later capacity/missing-proof/pruning cases still require their final run.
- `python tool/metadata_upgrade_smoke.py --publication-bundles-only` and `--incoming-fresh-only`: passed the generated fresh schema and all-row populated preservation checks, including active/deleted links initialized false (`.local/185-upgrade-focused.log`, `.local/185-fresh-focused.log`). The full historical chain remains a batch-end check.
- `dart run tool/incoming_publication_work_smoke.dart --bundles`: passed ten real process-loss cases before/after intake/Add/update/cancel/reopen commit, reauthorized retries and simultaneous two-host intake/adoption/child-only application (`.local/185-bundle-recovery.log`). Independent child versions and permanent profiles survived recovery.
- Both master and bundle generated-client JWT/MIME workflows passed through two compiled example hosts, including private source boundaries, separate cancellation bases, competing Apply, reopening and deletion retries (`.local/185-jwt-flutter.log`). That combined command subsequently failed in Flutter destination selection; it is not a passing overall command.

The first connected Flutter attempt tried to tap a destination outside the mounted dropdown viewport. The journey now loads the destination page explicitly and scrolls the menu to the real option; enabled controls and existing assertions remain required. Analysis briefly caught an incorrect getter in that fixture change; it was corrected before rerunning. The corrected focused publication and feed journeys passed.

Official generation completed for the approved models and endpoints using the pinned 4.1.0 toolchain; generated files/migration metadata were not hand-edited. Focused analysis results are recorded per run; final whole-workspace analysis and generated-output stability remain pending. Serverpod MCP is exposed but its runner reported not running; runtime evidence uses the compiled CLI hosts.

## Remaining batch evidence

The full repository check and hosted inspection/runtime for the feature commit remain required before readiness. The preceding repair commit `d692fa5` passed its complete local connected journey; its hosted run 43576285169 is separate evidence and must be inspected. No prior or pending run establishes this feature's readiness.


## Follow-up checks

The final bundle/producer selection passed 51 tests and authenticated exports passed 68. A larger earlier selection had 222 passes and one failure in an older test that still expected all incoming bundles to reject; the corrected test now verifies dedicated bundle intake and scalar-route rejection. The complete historical populated-upgrade chain passed. Complete core and iCalendar suites passed 540 VM/540 Chrome and 642 VM/642 Chrome respectively; module units passed 737 VM/31 Chrome and feed units passed 13. Example units passed 157, Flutter widgets passed 9, generation remained stable across 12 roots, and workspace analysis passed.

The complete real-client portion passed, including two hosts, JWT, synthetic MIME, feeds, notifications and producer-loss recovery. Its combined command then failed in the browser on a first-page calendar assumption. Subsequent browser runs identified offscreen calendar filters and unsaved feed metadata being discarded when a lazy editor panel unmounted. The calendar journey now traverses authorized pages, and the bounded feed form stays mounted while scrolling. The focused feed journey passed with a unique synthetic fixture and retained assertions; the complete fresh-storage browser rerun passed (`.local/185-full-browser-fresh-final.log`). A preceding accumulated-data rerun failed with `limitExceeded`; its cause was not independently established and it is not counted as a pass. Prior failing commands are not counted as passing.

The preceding repair commit d692fa5 passed hosted inspect and runtime in run 43576285169. Hosted validation of this feature's eventual commit remains a separate readiness gate.

Final whole-workspace analysis passed after the UI fixes. The full repository check and hosted checks for this feature commit remain required before PR readiness.

After the final feed form change, all nine Flutter widget tests and the release web build, including its Wasm dry run, passed (`.local/185-widgets-final3.log`, `.local/185-release-final3.log`). The complete fresh-storage connected browser journey passed (`.local/185-full-browser-fresh-final.log`).
