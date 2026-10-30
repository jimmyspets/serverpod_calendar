# MIME library evaluation

Evidence inspected on **2026-10-30** for the proposed [host-only outbound composition batch](adr/0143-synthetic-host-outbound-imip-composition.md). This is a scoped source/probe evaluation, not an audit or a declaration of complete MIME/RFC 6047 compatibility. No repository dependency changed during evaluation.

| Candidate | Inspected capability and limit | Proposed use |
| --- | --- | --- |
| [enough_mail 3.0.0](https://pub.dev/packages/enough_mail/versions/3.0.0) | Public MIME builder, binary parse/decoding and message rendering; decoded parameter map loses duplicates; text-input path normalizes line endings. MPL-2.0. | Example-host outbound composition only; not the complete inbound gate. |
| [mime 2.1.0](https://pub.dev/packages/mime/versions/2.1.0) | Streaming multipart utility; header map overwrites repeated fields. BSD-style license. | Insufficient alone for complete email composition/inbound ambiguity. |
| [mailer 7.2.0](https://pub.dev/packages/mailer/versions/7.2.0) | Outbound SMTP composition; public exports center on Message/send, with MIME rendering under src. MIT license. | Alternative host transport candidate; not selected for this standalone MIME slice. |

The observations come from published source archives and their licenses/public exports, not package popularity or support claims. Enough_mail's map assigns by lowercased parameter name. Its `TextMimeData` normalizes LF; binary parsing and explicit preservation of raw decoded body bytes need separate inbound validation. The other packages likewise do not by themselves provide our required trusted whole-message gateway. General mail-library leniency must not silently weaken the strict calendar profile.

## Reproducible source evidence

The pub.dev version metadata supplies each archive and SHA-256:

| Version metadata | Verified archive SHA-256 |
| --- | --- |
| [enough_mail 3.0.0 metadata](https://pub.dev/api/packages/enough_mail/versions/3.0.0) | `ed4a4ff39f656ccef5c37ead24eb32dc0a81f6d84d72aa2d705cc9b036ddb423` |
| [mime 2.1.0 metadata](https://pub.dev/api/packages/mime/versions/2.1.0) | `bd47de35f07e27267e69c8c8b22edf9473bfee170a60d60fcc93730c5144b7f6` |
| [mailer 7.2.0 metadata](https://pub.dev/api/packages/mailer/versions/7.2.0) | `9f7213f57272c2a047f13ae89e68652d492f929d84ded9a618424b38da328f97` |

Inspected enough_mail `lib/src/mime_message.dart`, `mime_data.dart`, `message_builder.dart`, public `mime.dart`, pubspec and LICENSE; mime `multipart_transformer.dart`/`bound_multipart_stream.dart`, pubspec and LICENSE; mailer public exports, MIME implementation, pubspec and LICENSE. The current mime repository is [dart-lang/tools/pkgs/mime](https://github.com/dart-lang/tools/tree/main/pkgs/mime), rather than its archived former repository.

## Isolated synthetic probe

An ignored scratch package pinned enough_mail 3.0.0 and resolved successfully using Dart 3.13.5. A public MessageBuilder with explicit sender, one recipient, subject, Date, Message-ID and text/calendar hints emitted ASCII base64 MIME for a synthetic Unicode/CRLF calendar body. Binary reparse returned exactly the original bytes. A separate parameter probe confirmed that duplicate method names collapse to one map entry. No SMTP/network client was invoked, and no real message was delivered.

Commands actually run: `dart pub get` and `dart run probe.dart` in the ignored evaluation package. The probe passed. This proves only those evaluated paths and SDK resolution; full workspace dependency resolution, upstream license notices, host integration, bounded output, failure behavior and multi-instance/client/release checks remain acceptance work after explicit ADR approval. No incoming message acceptance or host authority was tested by that outbound probe.

The recommendation keeps this optional provider dependency in the example host. Reusable modules retain their replaceable transport and pure decoded-part interfaces. Existing raw-header ambiguity, protection and calendar-byte checks must be resolved before a complete inbound MIME gateway can be implemented.
