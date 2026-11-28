# Explicit single-instance attendee responses

Accepted [ADR 0153](adr/0153-explicit-single-instance-attendee-responses.md) extends the [private response workflow](private-attendee-responses.md) to selected received occurrence REQUESTs. Accept, Tentative and Decline affect that invitation entry only. They change no master/sibling choice, calendar event, source acceptance, dismissal, alarm or scheduling publication. Adding or applying an invitation remains a separate action; declining requires no calendar event.

## Selection and source meaning

Select an existing trusted known-series instance notice and its exact source/invitation/personal revisions. Arbitrary originals selected from a master, unknown detached meetings, bundles, RANGE, delegation and instance CANCEL as a new response basis remain unsupported. An instance cancellation can still expose protected historical response activity; it cannot receive a new participation choice.

The outgoing minimal VEVENT REPLY carries the original RECURRENCE-ID, UID and selected REQUEST's exact independently optional SEQUENCE. It never substitutes the moved DTSTART or the master's version. DATE, UTC and exact named-zone originals remain distinct. Named-zone replies include the single required pinned VTIMEZONE and are validated within the existing 32 KiB payload ceiling. The response includes actual strictly later whole-second database DTSTAMP, a verified organizer route and one verified attendee/PARTSTAT. It copies no event timing, title, source alarms, attachments, comments or other participants. Existing master reply bytes/hashes remain unchanged.

The synthetic MIME adapter preserves the exact authorized calendar bytes. It admits the bounded original identity and its required zone while rejecting unrelated zones, RANGE and extra event content/parameters. Parsing and MIME headers establish neither sender identity nor authority. No real transport or external scheduling-client interoperability follows.

## Current basis and permissions

Each new command and dispatch uses the existing known-series resolver: current retained recurring master REQUEST first, otherwise the validated linked accepted baseline. It checks scope/recipient/correlation, exact original membership/profile and recipient presence. A known cancelled master or removed original blocks new sending and withdraws pending work. Missing/pruned evidence without a usable link is unavailable; budget exhaustion never proves that an original disappeared. Workers retry unavailable evidence within the existing attempt/expiry limits.

A compatible newer master alone does not rewrite a target's source version or personal choice. Calendar drafts remain separate from accepted source evidence and need not be clean to respond. New selected instance source/CANCEL, superseding choice, known invalid basis or withdrawn authority stops pending work. Current authority/basis is checked again when recording an instance submission's result. An actual accepted attempt stays recorded even when the intent has since been withdrawn; an in-flight acceptance cannot be recalled.

Fresh database time also fences the end of authorization: dispatch does not start after expiry, and instance result finalization requires the same live lease and unexpired intent after the final host check. A slow check cannot extend a lease or expiry. Actual attempt acceptance remains recorded when a fresh holder must take over; retries retain their delivery ID and bytes.

Existing invitation/source-read and personal read/send/dispatch permissions remain. Additional `sendOccurrence` and `dispatchOccurrence` host operations protect selected occurrence commands, retained command retries and workers. Host context includes the immutable selected invitation, typed original, source, current/proposed personal view, available `occurrenceBasis`, explicit `occurrenceBasisUnavailable`, complete outgoing message/digest and verified recipient/route. A null basis with unavailable false on an occurrence indicates known-invalid evidence; it is not a fabricated active basis. Workers have no actor. Fresh external policies retain their documented after-check revocation race.

## State, retries and views

The three existing private state/delivery/attempt tables already key state by invitation entry. Master and occurrence entries therefore have independent revisions, clocks and choices without new SQL columns/tables or expanded limits/retention. All response states still share the existing recipient/scope caps. Source pins, stable delivery IDs/bytes, database leases/fences and bounded terminal history are unchanged.

Exact retained command retries reauthorize against retained source and actual current evidence before new admission. They return the original receipt without resending, changing revisions, dismissing newer notices or accepting a newer source. Unknown current basis is explicit to trusted host policy. Changed criteria under a retained UUID reject; competing new choices with one expected personal revision have one winner.

`CalendarInvitationResponseView` is now immutable and adds `originalStart` (null for a master) and `canSend`. The latter describes current source/basis eligibility, not a grant of write permission or a guarantee that clock/capacity checks will succeed. `appliesToCurrentSource` separately describes whether the recorded personal choice belongs to the current selected source. It does not imply that the meeting is still active or that the organizer received the response. Ordinary responses disclose no sibling bodies or totals.

## Example and checks

The invitation list opens participation controls for occurrence notices as well as masters. The screen labels the original occurrence, keeps master/instance scope explicit and preserves an uncertain command UUID across retries. Calendar application is separate, and the example records synthetic mail only. Upgrade generated clients and hosts together; unpublished breaking carrier refinements are intentional.

From the example server, use `dart test test/integration/instance_invitation_responses_test.dart --concurrency=1`. MIME unit tests and `invitation_responses_test.dart` include exact byte round trips and a trusted single-instance MIME/organizer loopback with independent forged-origin rejection. From the root, `dart run tool/invitation_work_smoke.dart --instance-responses` exercises actual separate hosts, competing choices/leases and process loss before/after acceptance. After a current host build, `dart run tool/host_smoke.dart --browser-only --flutter --instance-responses` runs the focused browser journey. Run host/recovery profiles sequentially on owned test ports; reset only isolated synthetic test storage.

The root check includes the new database/process coverage and full generated-client/Flutter journey. [Validation](scaffold-validation.md) records actual completed commands and broader checks separately. RANGE, arbitrary-original selection, delegation, counters, broader reconciliation and real mail remain required separate work.
