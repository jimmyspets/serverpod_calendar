# Selected task occurrence content

Status: scoped implementation under [ADR 0103](adr/0103-single-task-content-overrides.md); confirmed inheritance/anchor policy, with concrete mechanics under draft review. This extends [task timing](task-future-timing.md) with single-original summary, description, location and priority overrides. Future content propagation, other metadata editors, source reconciliation and event-content exceptions remain separate.

## Set, clear and inherit

`calendarTask.changeOccurrenceContent` accepts an actual task UUID, expected revision, exact original start and one to four unique selected-field changes. Each change names a field and `setValue`, `clearValue` or `inheritSeries`. Set supplies only its typed value: nonempty text or priority 0–9. Clear/inherit supply neither. Existing text/code-point limits and Unicode/internal spacing preservation apply. No unselected field changes.

Sparse stored `contentOverrides` uses null for inheritance, empty text for explicit clearing and priority 0 for undefined priority. Setting the same text as the series still creates an independent override. A later series edit changes inherited values but leaves explicit overrides alone. Clearing a value differs from following the series. Empty override objects normalize to absence. Source empty TEXT and PRIORITY 0 retain those explicit meanings; source omission inherits per field.

Content applies only at the original occurrence, including an anchor of `RANGE=THISANDFUTURE`. Only timing propagates in the supported VTODO profile; anchor content and progress do not. This is an explicit bounded application profile, not a guarantee that external clients interpret every combination identically. Imported components still require the matching in-file master and exact original membership.

Progress, completion timestamps, timing, assignments and history are unchanged, including on completed originals. A new component captures current effective progress without inventing a history transition. Native set retains own LANGUAGE/ALTREP; newly overriding an inherited field captures its effective annotations. Explicit clear/inherit removes own annotations. Source metadata remains inert and alarms remain unarmed. Full source validation rejects incompatible changes without discarding retained data.

Only actual anchor component changes advance its protocol version. Identical normalized saves retain timestamps/SEQUENCE; accepted native writes still advance API revision, audit time and scope generation. Master protocol versions and parent metadata time remain unchanged by occurrence actions. Restoring all content inheritance keeps the own component/progress/history. Pattern edits preserve recorded originals and reject orphans.

## Authorization and privacy

Existing `updateTask` authority applies independently of progress/assignment rights. The host receives the actual parent/task/original, immutable selected changes, current/final effective content and sparse overrides, retained records and proposed component version. Snapshot request collections before the first await. Every mutation uses the durable scope transaction, expected revision and final declared-guarantee authorization; the external-check revocation race remains documented.

`CalendarTaskOccurrenceQuery.fieldGroups` optionally requests summary/description/location/priority. Timing/progress remain required. Every requested group must be granted; otherwise reject the entire preview. `disclosedGroups` identifies the returned fields. Default timing/progress previews and history disclose no content. Filter both effective values and sparse overrides, normalizing filtered empty objects so hidden fields do not reveal override presence. Revisions still cover the whole task and do not encode which group changed.

Current-state export retains existing full detail/source-read/export gates. Historical import baselines never enter ordinary responses or exports. No new totals, booking, participant authority, network access or notification delivery follows.

## Pre-beta storage and source transition

Generated module migration `20261023211339093-task-occurrence-content` and example migration `20261023211410837-task-occurrence-content` add nullable JSON contentOverrides only. Existing native rows remain inherited; upgrades must preserve content/progress/history and invent no overrides.

**Task source baselines now use v3.** Earlier v2 repetitions had to equal the master and were rewritten by native series edits. Explicit source fields now remain independent overrides, even when equal. Existing v1/v2 imported tasks therefore fail closed until explicitly recreated/reimported; no automatic adoption, guessed override migration or development reset is performed. This supersedes ADR 0102's compatibility claim only for this later source-profile change. Source-free native tasks remain usable. Test reset affects only dedicated synthetic storage.

## Example and validation

The Flutter occurrence screen requests only content groups already disclosed by its task view. Its editor offers No change, Set own value, Clear value and Follow series independently for all four fields; it requires complete disclosure before opening the editor. It explains anchor-local content and annotation retention, preserves progress/history and rejects stale writes until reload.

Focused wire, source-storage, validation/disclosure and database tests cover the new profile. Full `./tool/check.ps1` passed: core 479 VM/Chrome, wire 313 VM/Chrome, module 155 VM + 17 Chrome, widgets 3 and database 295, plus populated upgrades, two-host content/progress/round-trip checks, the complete Flutter set/clear/inherit journey and release Web build with successful Wasm dry run. [The validation log](scaffold-validation.md) records commands, limits and development cache recovery. Scheduling, feeds, alarm runtime and external-client interoperability remain separate.
