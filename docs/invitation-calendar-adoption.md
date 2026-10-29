# Explicit invitation calendar addition

Accepted [ADR 0138](adr/0138-explicit-single-event-invitation-adoption.md) adds one explicit local event for a reviewed non-recurring invitation. The scoped implementation and phased feature-batch checks are complete; see [the validation record](scaffold-validation.md). Receiving an invitation still creates only [private review state](invitation-intake-and-review.md).

Adding an invitation does not accept participation or send a reply. The local event can occupy time under the ordinary STATUS/TRANSP and free/busy rules; this is not an exclusive reservation. Source participants grant no host authority, imported origin cannot publish as a native organizer meeting, and source alarms are never armed.

## API and stable identity

`calendarInvitation.adopt` takes an immutable `CalendarInvitationAdoptionRequest`: invitation UUID, expected invitation revision, exact current source UUID, chosen calendar UUID and expected calendar revision. No recipient or authority flag comes from the client. First creation requires a pending readable source in the actor's actual host scope. Stale source/calendar revisions, dismissed sources, active destination UID conflicts, unavailable authority and capacity errors reject the complete operation.

The flat immutable `CalendarInvitationAdoptionReceipt` contains link/invitation/source/calendar/event UUIDs, the created event/invitation revisions and adoption time. It is a creation receipt, not a claim that those revisions remain current. `calendarInvitation.link(invitationId)` independently authorizes the actual linked event and returns its receipt, or null for an authorized known unlinked invitation. A withheld, deleted or unavailable link returns an error rather than a false unlinked result.

The binding identifies one logical scope/recipient/exact UID/organizer correlation. The same logical invitation cannot create another linked event after inbox cleanup or through another calendar choice. Ordinary file imports remain independent copies and do not establish an invitation link.

An exact retained request reauthorizes using the current actor, destination and event, then returns the original receipt. It does not recheck old revisions as a new write, reapply source values, overwrite local edits, dismiss a newer invitation version, advance scope generation or send anything. Different input for an existing correlation rejects. The caller must keep the original complete request when recovering an uncertain response.

## Atomic storage and source conversion

The approved server-only `CalendarInvitationLinkRecord` has one immutable identity/receipt row per logical invitation and per native event. It stores trusted scope/recipient, exact source UID/organizer, fixed digests, historical inbox/source references and version, destination calendar/event identity references, original request digest, created revisions and database adoption time. It stores no copied source body/title/location. Raw UIDs are not index keys; digest matches verify retained exact values.

The shared database scope lock serializes source intake, calendar writes and adoption across independent hosts. Event identity/content/import baseline, link and dismissal of that selected source version commit in one transaction. Final checks occur inside that transaction and roll every write back on denial or unavailability. There are no nested public import transactions or process-local uniqueness assumptions.

The temporary conversion removes only METHOD from the accepted REQUEST envelope, then uses the ordinary validated VEVENT/storage conversion. Accepted properties, source versions/omissions and typed DATE/UTC/named-zone end/duration meaning are preserved. Unsupported conversion rejects without stripping data. The new event receives a native server UUID, source text UID, imported origin, private normalized import baseline and independent database audit/API revision. Protocol timestamps remain source values. Native omission defaults follow ordinary event import.

Retained links verify their original version and organizer against the immutable import baseline; no accepted-source checkpoint is inferred for a later version. Generic file source replacement rejects linked events on every module host, even with optional invitation ingress disabled. Its existing read/full-disclosure/source gates run before that conflict is exposed. Ordinary local edits and deletion remain available. Existing-meeting source reconciliation is a separate required profile.

## Host authority

Invitation `adopt` and `readLink` are independent operations. Both require invitation summary/source access; adoption also requires destination import/create and applicable lifecycle authority. The first profile requires full ordinary event-field disclosure and event source-read permission. Final import/create/applicable-lifecycle decisions must also disclose mutation receipts; otherwise creation/retry rejects rather than returning a blind creation result. Link reads retain their independent read permissions. Retained adoption retries recheck those permissions; a link lookup does not require creating another event.

`CalendarInvitationPolicyContext` identifies actual recipient, actor, request, source/message/digest, current queue state, destination snapshot, current/proposed event and receipt. Native policy receives the complete imported proposal. A creation proposal is distinct from a current existing event. The host must approve current source authority/recipient mapping; persisted participant strings alone are insufficient. Coordinated versus external fresh-check guarantees remain explicit, including the latter's after-check revocation race.

After historical source expiry, context explicitly sets `historicalSourceUnavailable`. Its immutable `linkSource` descriptor retains original inbox/source UUIDs, UID, organizer, digest, independently optional SEQUENCE and DTSTAMP, separately from actual current event/source state. `sourceDigest` remains the known original fingerprint even when the body is absent. It never reconstructs an old message or silently weakens the source permission. An initial context before evidence loading leaves that flag absent. A host needing unavailable historical evidence can fail unavailable. The example approves only its fixed synthetic source namespace/organizer/recipient and does not verify real mailboxes.

## Retention, deletion and limits

Inbox entries/sources/receipts keep ADR 0137's independent cleanup policy. Historical inbox/source UUIDs on the link have no foreign keys, so that cleanup does not remove the link. Calendar/event references target minimal identity rows with no implicit cascade. Native event deletion scrubs active event content/baseline/personal alarms as before; the link remains and adoption/lookup becomes unavailable instead of creating a new event. Logical calendar deletion can retain its minimal identity; physical identity removal remains constrained by retained references.

The default limit is 1,024 links per recipient, including deleted-event markers. Hosts may lower this validated limit; at capacity new creation fails atomically while retained retries allocate nothing. This increment has no automatic link purge, relink or removal flow. A separate retention/purge review remains necessary before release; this is not a choice of permanent retention.

## Example and remaining scope

The invitation screen opens a protected calendar-addition/link view. It requires an explicit calendar choice, supports further authorized pages, retains a frozen request for retry and requires explicit refresh after stale state. An existing link replaces the creation controls. A newer incoming invitation reopens review but cannot silently update or duplicate the local copy.

The synthetic example and tests send no mail. Participation responses, updates to linked events, source adoption as organizer, moving/copying/relinking, recurring/CANCEL intake, link purge and external client/mail interoperability remain separate required work.


## Explicit update profile

Accepted [ADR 0139](adr/0139-explicit-linked-invitation-updates.md) implements explicit conflict-protected application of newer linked non-recurring REQUEST sources. One private checkpoint tracks current acceptance and the latest retry result, while the creation receipt stays unchanged. See [the scope, permissions and retry limits](linked-invitation-updates.md) and separate batch validation. Receipt remains review-only; local changes reject replacement and no participation reply is sent.
