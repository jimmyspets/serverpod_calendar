# Effective notice selection for recurring invitation replies

Accepted [ADR 0178](adr/0178-pure-recurring-response-source-selection.md) adds `resolveRecurringInvitationResponseTarget` to the server adaptation package. This is a pure semantic helper. Existing response endpoints and workers do not call it, and success does not authorize a reply or prove that the supplied evidence is current or complete.

Supply one ordinary recurring master REQUEST, the exact start-only original, an explicit recipient calendar-address claim, current single REQUEST/CANCEL and range REQUEST notices, and a separate list of explicitly active range-CANCEL packets. Each packet has one event and the same UID/organizer with the claimed recipient in its roster. These are source claims, never host identities or permission grants.

Every packet is validated before returning a result, including noncontrolling notices. The original and each anchor must match the master's supported recurrence membership: DATE/UTC/exact named-zone profile, RRULE/RDATE/PERIOD additions and exclusions. Moved DTSTART values do not replace original identities. Nonzero time fractions, unsupported data, VALARM, delegation/SENT-BY, bundles, nonmembers, duplicate current targets and invalid or incomplete evidence reject. No partial selection follows from exhausted work.

| Condition, in priority order | Result |
| --- | --- |
| Active range cancellation at/before the original | Blocked, retaining the earliest covering cutoff source |
| Exact single cancellation | Blocked for that original |
| Exact single REQUEST | That packet's independently optional SEQUENCE and DTSTAMP |
| Applicable range REQUEST | Latest original civil anchor's packet/version |
| No controlling notice | Master packet/version |

A single REQUEST wins at a shared single/range anchor without merging either packet into a canonical event. A range-controlled selection still targets only the requested original; it does not mean acceptance of a suffix. Source versions need not increase across independent targets. Omitted SEQUENCE remains omitted, including below a range with a larger number; receipt time and the largest component sequence are not substitutes.

Active range cancellation masks later moved singles and later range requests too. A request at its anchor cannot clear that separate active evidence. The helper performs no history lookup and cannot prove that omitted cancellation evidence was restored or expired. A later durable resolver must establish that fact explicitly. Multiple active cutoffs are deterministic by earliest original anchor, not input order or largest version. Blocked results retain their actual source and differ from thrown invalid/unavailable-budget results.

The current codec rejects REQUEST with STATUS:CANCELLED. A whole CANCEL is not a recurring membership REQUEST and also rejects. This helper preserves those guards; it does not invent recurrence from a minimal cancellation or widen the scheduling profile. The defensive master-status guard supplies no path around validation. Current whole-series cancellation remains a required check in later durable integration.

Limits are shared across all packets: at most **64 notices/cutoffs plus one master**, **262,144 UTF-8 bytes**, **1,000 syntax components**, **32 VTIMEZONE components** (including repeated definitions in separate packets), and the existing **200,000 recurrence-work** ceiling. Callers can lower each cap. Every supplied byte block, component, notice and membership/selection operation consumes the shared budget; a larger caller budget rejects. Each packet retains existing individual syntax/semantic limits as well.

The immutable result identifies the requested original, source role/anchor, complete validated source packet, exact optional SEQUENCE and required source stamp, and an optional explicit blocking reason. It contains no database source ID, authorization verdict, delivery intent or receipt. Inputs are preserved. Reading it does not edit a calendar, record participation, arm an alarm or send mail.

A durable integration still needs atomic notice discovery, current/version/history proof, protected multi-source views, pins/pruning, immutable command binding, independent host checks and two-host worker revalidation. No model, SQL migration, generated API, existing command/hash/target, worker guard or Flutter control changes in this increment. RANGE replies and external-client compatibility remain separate requirements. See [actual validation](scaffold-validation.md).
