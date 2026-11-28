# ADR 0081: Authenticated event export contract

Status: **maintainer-confirmed selection/disclosure/permission boundary; concrete adapter/API mechanics proposed**. Date: 2026-10-23.

After create-only import under ADR 0080, the maintainer selected explicit complete event series from one calendar for the first authenticated VEVENT export. Every selected series must be available and fully authorized; otherwise reject the entire export. Require a separate export permission plus disclosure of every supported event field group. Initial redacted/partial event files are not selected. Hosts can map distinct permissions to their existing rules.

Preserve the currently supported component semantics and independent versions using current active data, excluding the private historical import baseline. Envelope and full-horizon VTIMEZONE presentation follow the already selected pinned regeneration boundary. No export endpoint or adapter is implemented by this record. Selection/revision DTOs, current/final source authorization, exact output mapping and budgets remain implementation-review items. Native state that cannot be represented faithfully must not be silently discarded or flattened; profile/mapping decisions require review before implementation.

Keep event export separate from read-only HTTP feeds, source replacement/adoption and scheduling. A standalone export must not initiate invitations, mail or alarms. Verify missing/foreign/deleted selections, field-group denial, atomic output, current authority, no baseline/hidden-field leakage, deterministic supported semantic output, regenerated zones and two-host/generated-client/Flutter evidence before claiming implementation.
