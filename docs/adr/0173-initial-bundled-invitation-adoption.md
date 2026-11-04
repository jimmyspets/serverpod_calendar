# ADR 0173: Initial bundled REQUEST review and calendar adoption

Status: **Accepted by explicit maintainer agreement on 2026-11-04, including the initial bundled-adoption group and model/protocol mechanics below.** Approval authorizes implementation; actual runtime and interoperability evidence remains separate.

## Context and inspected boundaries

Implementation review found one conflicting acceptance detail: the original alarm-preservation wording exceeded the existing scheduling-message profile. The maintainer explicitly confirmed on 2026-11-04 that this batch retains rejection of every VALARM, with alarm-bearing scheduling messages deferred to a separately reviewed batch. That choice supersedes the broader alarm-preservation wording; no alarm-bearing message is silently accepted or stripped.

ADRs 0126–0130 and 0172 can publish complete REQUEST messages containing a recurring master and occurrence components. Recipient `_invParse`, source reconstruction, adoption and response paths currently assume `message.events.single`; ADR 0148 deliberately rejected bundled input. Treating a bundle as its master would discard supported exceptions and independent versions. This producer/recipient gap precedes broader scheduling reconciliation.

The existing pure scheduling and standalone event adapters already validate one master with supported single/future components and produce a native event projection. The next group should use that validated data, trusted intake and explicit adoption together. Full bundle updates require per-component ordering rather than the inbox's current scalar master SEQUENCE/DTSTAMP comparison; they must not be enabled by removing the single-component check.

## Proposed initial complete group

Support a first authenticated REQUEST containing exactly one recurring master and 1–64 supported occurrence components for one UID/organizer, private review/dismissal, and explicit all-or-nothing Add to calendar as one native event. Include generated clients, example MIME ingress/Flutter journeys, migrations and real multi-host/process-loss checks in the same batch. Receipt and dismissal change no calendar or participation state; Add sends no reply and arms no alarm.

This first bundle profile is create-only at the logical recipient/organizer/UID correlation. A different subsequent message, a conversion from an existing single-component invitation, or adoption into an already linked meeting rejects before scalar ordering or reconciliation fallback. Identical retained delivery/adoption retries still reauthorize and return their existing receipt without reapplying data. Bundle-aware updates, cancellations, per-component version vectors, response projection and integration with accepted range histories remain required subsequent work. This keeps a real first-invitation path usable without guessing update semantics.

## Proposed source and authority profile

Reuse the current supported REQUEST/VEVENT profile, strict UTF-8/CRLF input, whole-second [1970-01-01, 2100-01-01) dates, explicit endpoint exceptions and full-horizon supplied-zone validation. Preserve exact original DATE/UTC/named-zone identities, source omissions/annotations, PERIOD additions, timing/content overrides and each component's own versions. Do not flatten recurrence or apply the master's version to its children. Floating values, unsupported properties, ambiguous single/future collisions and out-of-profile data reject the whole message.

Revalidate every component and its membership in the included master with shared bounded work before admission/adoption. Require one consistent organizer and fixed attendee claims including the host-resolved recipient on every included component; delegation/SENT-BY, VALARM and differing per-component rosters remain outside this first profile. Parsed addresses, MIME From and message metadata establish no identity or authority. The existing trusted host ingress must verify provenance and approve the complete immutable message/digest and actual recipient, not just a selected master. Imported participant/resource references stay inert.

Retain the existing 256 KiB native invitation source ceiling, 65-component/64-override ceiling, 200,000 shared work ceiling, pending/dismissed/source/receipt/link limits and 30-day terminal retention. A lower configured limit still applies. The outgoing module's optional 512 KiB allowance does not imply this receiver accepts that size; the demonstrated common profile must fit the receiver's bound. No new cap expansion, network retrieval, provider trust, real mail, deployment or package publication is proposed.

## Proposed queue classification and permanent link marker

Append `requestBundle` to `CalendarInvitationSourceKind`; preserve existing ordinal values. One private inbox entry uses the existing master target/correlation and stores the complete normalized message once in its source row. Its source kind survives body pruning, so a missing body cannot turn into an ordinary master. Use existing protected source review for the entire message; ordinary summaries may show its kind/master presentation but do not expose a component count or native details through an extra query.

Add exactly one private persisted `bundledRequest: bool, default=false` field to `CalendarInvitationLinkRecord`. It is immutable after creation and survives as a content-free profile marker with the existing stable link/deletion behavior. Default false is justified by the old single-component admission guard: earlier supported adoption could not create a bundled link. Do not infer this profile later from mutable native overrides or a pruned source body. Generate an additive migration with the pinned CLI; test fresh and populated single-link upgrade behavior. No new table/index or native event column is proposed.

Expose that original profile through a read-only `bundledRequest` field on `CalendarInvitationAdoptionReceipt` and the immutable trusted link-source descriptor. The adoption request remains the existing invitation/revision/source/destination-calendar/revision tuple; clients cannot supply the profile flag, recipient or component selection. A packet with no overrides remains on the existing single-message path, never an implicit mode conversion.

## Proposed atomic native adoption

The existing Add endpoint dispatches explicitly to the reviewed bundle path when source kind is `requestBundle`; it must not fall through to the master-only projector. Require independent `receiveBundle` and `adoptBundle` host operations in addition to applicable source-read/adoption, actual destination-calendar and native event-create checks. Context includes trusted actor/recipient, actual collection, immutable full message, the complete validated proposed event/overrides/protocol state and original link evidence. Preserve preliminary/final reauthorization and declared coordinated versus fresh-external guarantees, including the after-check external race.

Create one server-generated native event UUID with imported origin, its source text UID, all supported component timings/content/metadata/independent protocol versions, and one private full normalized import baseline. Keep database audit time/API revision separate. VALARM rejects under the confirmed profile; source participants assign no host identity, and no completion/action history or personal alarm definition is invented. All existing native limits and destination UID conflicts apply; over-limit or withheld data rejects the whole operation, leaving review available.

Under existing scope/link locks, atomically commit event data, the one stable link/profile marker, creation receipt and review changes. Two hosts racing the same adoption converge on one event/link. Exact retries use the existing frozen adoption tuple and original receipt; they never overwrite local edits, move calendars or recreate a deleted event. Existing generic replacement/deletion/retention guards remain in force. Native edits can remain local after adoption; they do not enable source reconciliation implicitly.

## Proposed continuation guards

Every older master/instance/range application, source-admission/correlation fallback and participation-send path must recognize the bundle entry or permanent link profile before selecting a component, reconstructing a queue entry or applying scalar version ordering. New unsupported continuations reject explicitly; unrelated existing single-message flows remain supported. Stable retries of already committed initial bundle receipt/adoption remain available, subject to their normal retention and authorization rules.

Preserve the private profile after entry pruning and native deletion. A surviving link must not be rebuilt as a single-message meeting or have its source history guessed from current content. Bulk REQUEST update, bundled range CANCEL, master/instance replies from a bundle, and later whole/partial source composition stay guarded until vector/source-history contracts are reviewed. The example labels these limits rather than sending a fabricated reply or silently applying just the master.

## Alternatives and consequences

Parsing only the master loses exceptions; creating one event per component duplicates series identity; sequential public API calls are not an atomic whole-message transaction. Enabling known-series updates under scalar ordering can discard a new child when the master version is unchanged or overwrite a newer child with an older component. This initial group therefore closes first-invitation adoption while preserving an explicit continuation boundary. The small permanent profile column is preferable to guessing after pruning or overloading a digest field with mode metadata.

## Proposed complete batch acceptance

Cover DATE/UTC/exact zone aliases, DST gaps/folds, RDATE/PERIOD/EXDATE, single/future timing and selected content, independent source versions/omissions, text/participant/reference preservation and full native/export semantic round trips. Reject mixed UIDs/rosters, wrong recipient/provenance, missing master, invalid membership, ambiguity, VALARM, other unsupported data, fractions and all shared size/work/native-limit failures without partial storage.

Test private summary/source/dismissal permissions, independent receive/adopt/native-create/final checks, destination conflicts, duplicate keys with different bodies, exact receipts, mode-conversion and every older-path guard. Verify one event under concurrent hosts, actual process loss before/after receipt/adoption commits, preserved local edits on retry, native deletion without recreation and profile retention after queue/body pruning. Test fresh/populated migrations, generated-client source review/adoption and connected Flutter. No receipt/Add/dismiss action sends a response or arms source alarms.

Use focused VM/SDK checks during development. At group completion run prescribed formatting/fatal analysis/stable generation, complete relevant pure VM/Chrome suites, migration/database checks, real two-host recovery and generated-client/Flutter journeys before one code commit. Full exact-head hosted repository checks remain a readiness gate. This proposal does not reduce the full first-release roadmap or establish external-client compatibility.
