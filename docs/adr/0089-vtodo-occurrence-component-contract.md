# ADR 0089: VTODO occurrence component contract

Status: **maintainer-confirmed in-file master and initial progress-only occurrence profile; concrete adapter mechanics proposed**. Date: 2026-10-23.

The maintainer selected a matching master in the same file for typed VTODO occurrence components. Validate exact original identity/profile and recurrence membership; reject detached components until database reconciliation is designed. This extends the pure master adapter under ADR 0088 without granting database import, assignment or scheduling authority.

The first profile permits independently optional source STATUS/PERCENT-COMPLETE/COMPLETED differences and independent source checkpoints on an occurrence. Preserve their omissions, not native completion defaults or synthesized history. Omitted timing/text/priority inherits the master's projection; explicitly supplied differing timing/content rejects. Preserve the raw occurrence component as well as the linked projection, so omission versus explicit repetition is not lost.

Task timing/content exceptions and THISANDFUTURE progress follow separately. Require original RECURRENCE-ID rather than completion time or display position. Reject duplicate originals, excluded/nonexistent originals, recurrence properties on an override, profile changes and unsupported ranges before returning a successful file. Use bounded aggregate validation and full-horizon zones. Source SEQUENCE/timestamps establish neither authority nor freshness and remain independent per component.

See [RFC 5545 §3.8.4.4](https://www.rfc-editor.org/rfc/rfc5545.html#section-3.8.4.4) for original recurrence identity. These bounded profile choices are not blanket RFC prohibitions.
