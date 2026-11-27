# Native availability versions, timestamps and envelope duration

[ADR 0061](adr/0061-availability-protocol-lifecycle-and-envelope-duration.md) extends native availability definitions and openings. These are server-managed native protocol values, not ICS import/export, scheduling messages or feed interoperability. The existing whole-second [1970, 2100) calendar timing and zone coverage guards remain authoritative.

## Definition and opening lifecycle

Raw rule views expose `protocolState`: definition `sequence`, `created`, `stamp`, `lastModified` and an immutable list of opening states keyed by stable opening UID. Each opening state has optional `created`, required `stamp` and `lastModified`, and no SEQUENCE. New definitions start at sequence zero; new openings receive known creation time. Dates are whole-second UTC values from the shared database clock. Native clients cannot supply these values in content requests.

The maintainer selected every actual validated content or occurrence-state change as significant, including metadata, envelope representation/units and opening additions/removals/order. A mutation increments the definition sequence once, retaining its creation time and protocol UID. An existing opening advances its own stamp only when its content or retained occurrence state changes; sibling or envelope changes leave its stamps intact. Deleting an opening drops its active timestamp entry. These native opening-series checkpoints include their occurrence state; independent wire exception-component timestamp/source-history rules remain future interchange work.

Saving identical normalized state, including a redundant accepted skip, keeps protocol timestamps and sequence unchanged. The accepted write still advances API revision, internal high-resolution update time and scope generation. It still requires current permissions, organizer approval, configured extension validation and expected API revision. Different writes can share a whole-second timestamp; SEQUENCE and application revision remain distinct. Never use protocol time alone for concurrency.

`CalendarAvailabilityView.lastModified` now reflects the stable protocol last-modified value, including identical saves. Without METHOD, the native DTSTAMP has LAST-MODIFIED semantics. Future scheduling-message creation timestamps and imported source values require separate handling. Database-clock correction is clamped through the existing storage clock path; protocol timestamps never go backwards. No artificial extra second is added.

SEQUENCE is limited to 0–2147483647 (RFC INTEGER), separately from the native API revision bound. At the maximum, an actual change fails with limit exceeded without partial state; identical writes can still succeed. No wrap/reset or automatic conversion from API revision occurs.

## Legacy rows and storage

Active availability data adds nullable typed JSON `protocolState`. Existing rows remain null after the generated migration: content, protocol UIDs, opening edits, revisions, precise creation/update times and scope generation remain untouched. Reads project a sequence-zero baseline from the definition's known stored creation/modification times without writing back. This is the initial tracked native version, not reconstructed historical sequence.

Existing openings omit CREATED because their true creation time is unknown. Their initial stamp/last-modified inherits the containing definition's known modification time as an explicitly approximate version baseline, not proof of an actual historical opening edit. Subsequent opening changes track independently; new openings receive known creation time. The first accepted content/occurrence write persists the baseline or its successor. The same result is derived across host processes; no process-local cache or read-time write is involved.

Definition deletion removes active protocol state with all other content; the minimal identity marker stays content-free. Views and trusted host snapshots validate/freeze state. Final host requests expose the exact proposed server-managed value through `proposedAvailabilityProtocolState`, alongside validated content/retained edits and actual parent/current state. Stale/final-denied writes do not advance anything. Existing declared authorization guarantees and external revocation-race limits remain unchanged.

## Envelope duration

Optional `validDuration` is a positive whole-second `CalendarEventDuration`. It requires a start-only explicit UTC or named-zone `validFrom`, and excludes `validUntil`. Omitted duration leaves the existing optional-end/unbounded behavior intact. Store supplied weeks/days/hours/minutes/seconds; weeks cannot be combined with other units under the existing duration profile. Zero, negative units, fractional seconds, floating/date-only bounds, incompatible end/duration combinations and range overflow reject.

The effective exclusive end is calculated using the start's profile: calendar weeks/days first, resolve with the selected RFC gap/fold rules, then apply clock units as elapsed time. Across Stockholm's 2026 spring transition, noon March 28 plus one calendar day ends at noon March 29; plus 24 elapsed hours ends at 13:00. Never flatten the saved units to an end timestamp. Calculated endpoints retain existing zone-coverage and exclusive-boundary guards; 2100-01-01 midnight is permitted only as an exclusive end, not an ordinary start/date.

Definition composition clips openings to this effective envelope before overlaying bookings. Calendar/subject/common-free queries therefore use identical semantics. Metadata-only updates cannot change duration or other structure; ordinary update authority is required, plus metadata authority if metadata changes. The host sees the preserved units and validated final state. The Flutter example can author UTC envelope durations with separate numeric unit fields; its existing advanced named-zone-envelope editing restriction avoids flattening configurations it cannot safely edit.

The rule list shows the stored duration and read-only definition protocol version/time. Other editors copy unrelated fields. No text duration/ICS parser, wire timestamp serialization, CONTACT import, feed invalidation or scheduling version reconciliation is implied. See [validation](scaffold-validation.md) and [roadmap](roadmap.md).

## Imported protocol lifecycle follow-up

[ADR 0071](adr/0071-create-only-availability-import.md) confirms preserving source versions/dates separately from local audit time. [The proposed storage contract](availability-import.md) describes source omission, opening/override state and later native mutation. Imported-state support is not implemented: current local-creation invariants and legacy behavior above remain the runtime baseline until the reviewed storage/migration batch.

## Implemented storage follow-up

[ADR 0072](adr/0072-source-preserving-availability-storage.md) and [the implementation guide](availability-storage.md) supersede storage-pending wording for the scoped prerequisite/native behaviors. They document exact UID/group/CONTACT/PERIOD and component-version representations, retention, policy context, query caps and upgrade behavior. Authenticated import remains pending; conversion is not authorization or publication.
