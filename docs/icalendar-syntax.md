# Bounded iCalendar syntax foundations

[ADR 0062](adr/0062-bounded-icalendar-syntax-foundations.md) introduces a pure Dart byte parser, immutable syntax tree, deterministic serializer and separate TEXT/parameter codecs in `serverpod_calendar_icalendar`. The maintainer selected strict UTF-8/CRLF input. This layer checks syntax and work limits; it does not validate the selected calendar profile or perform domain import/export.

## Data and API boundary

`parseIcalendarSyntax(List<int>, limits: ...)` returns `IcalendarSyntaxDocument`, containing ordered `IcalendarSyntaxComponent` roots. Each component has ordered entries that are components or `IcalendarSyntaxProperty` values. Property and parameter name spelling is preserved, with case-insensitive `canonicalName` access. Repeated properties/parameters, parameter value order, child/property order, empty parameter values and unknown syntactically valid names remain represented. All tree collections copy their inputs and are immutable.

Property `value` remains the raw escaped string because the parser cannot infer a property's value type from general content-line grammar. Parameter `values` are decoded RFC 6868 strings, with LF as the decoded newline convention. Unknown caret sequences, including uppercase `^N`, remain literal; backslash is ordinary parameter data. Quoted comma/semicolon/colon values stay together, while comma-separated parameter values remain distinct.

Syntax acceptance does not approve any component/property, mandatory-field omission, duplicate, date/zone/recurrence rule, CALSCALE, extension, binary value, address or alarm for domain use. Generic balanced roots and nesting are retained, including names the module's eventual import profile will reject. A later explicit validator must enforce component/property/value/context allowlists, mandatory/cardinality rules, source identity and supported bounds before mapping. Host authorization, transaction/revision checks and disclosure still belong to their own module/adapter boundaries. No import/export endpoint, database write, network fetch, alarm execution, scheduling mail or feed route is introduced.

## Strict input and bounded work

The byte API accepts an already materialized buffer; transport/file adapters must bound reads before allocating it. This is not a streaming parser.

Input must have valid UTF-8 and CRLF-terminated physical lines, including a final CRLF. Leading BOM, bare CR/LF, empty physical lines, orphan continuations, controls, malformed quoted parameters, property lines outside components and unmatched/mismatched component boundaries reject. Names use the ASCII alphanumeric/hyphen grammar, with configurable length caps. BEGIN/END boundaries match case-insensitively and cannot have parameters.

Unfold octets before decoding, removing CRLF and exactly the first following space/tab. Additional whitespace remains data. This restores even a fold splitting a UTF-8 multi-octet sequence; malformed unfolded UTF-8 still rejects without replacement. A line longer than 75 octets is not rejected merely for crossing that output recommendation.

`IcalendarSyntaxLimits` defaults:

| Limit | Default |
| --- | --- |
| Input or output bytes | 1048576 |
| Physical line bytes, excluding CRLF | 65536 |
| Unfolded content-line bytes | 65536 |
| Content lines including BEGIN/END | 10000 |
| Components across all roots | 1000 |
| Component depth | 16 |
| Parameters per property line | 32 |
| Values per parameter | 64 |
| ASCII name bytes | 64 |

Limits are positive, configurable trusted policy with an upper configuration bound of 67108864; depth has a hard ceiling of 64 to bound serializer recursion. A physical-line limit counts a continuation's whitespace; an unfolded limit excludes removed fold markers. Fold-heavy input remains bounded by total input bytes. Counts/lengths are charged before retaining nodes or concatenating lines, and input size before decoding. These are implementation resource defaults, not RFC field maxima. Future native/wire adapters must select budgets accounting for escaped values, property headers and canonical field limits, or reject explicitly without truncation.

Failure is atomic: no partial document or output is returned. `IcalendarSyntaxException` exposes an error kind, optional physical starting line and limit label without source text, addresses or decoder payloads. Invalid limit configuration throws `ArgumentError`. Callers still decide how much diagnostic detail to show.

## Output and explicit codecs

`serializeIcalendarSyntax(document, limits: ...)` emits UTF-8 with CRLF and deterministic folds of at most 75 octets, including each continuation space and excluding CRLF. Folds never split an encoded Unicode rune. Output preserves tree order and raw property value strings, encodes parameter values using RFC 6868 and quotes values containing commas/semicolons/colons. Boundary keywords are emitted as BEGIN/END. Original fold positions, optional quotes and alternative parameter escape spellings are not preserved byte-for-byte.

`encodeIcalendarText`/`decodeIcalendarText` explicitly handle TEXT backslash, comma, semicolon and newline escapes. Decoding accepts both RFC TEXT newline spellings; unknown escapes, unescaped single-value delimiters and a trailing escape reject. Decoded LF is supported; decoded CR is rejected instead of silently normalized. TEXT list codecs retain duplicates/order/empty items, split only unescaped commas and default to at most 256 values. Encoding an empty value list rejects because it cannot round-trip distinctly from a single empty item.

`encodeIcalendarParameter`/`decodeIcalendarParameter` handle caret, LF and double quote as parameter content, separately from TEXT. They do not fetch URI values or infer property types. Standalone codec `maxCharacters` conservatively bounds UTF-16 input length; escaping can expand that input. Full serialization separately enforces encoded line/output octet budgets. Encoders reject malformed UTF-16 and raw controls rather than producing replacement characters or content-line injection. Constructed trees undergo name/control/structure/output-limit checks too; reserved BEGIN/END cannot masquerade as ordinary property entries.

## Validation and next layer

Synthetic tests cover strict malformed/late-failing input, balanced trees, immutable ordering, quoted/repeated/unknown parameters, TEXT versus parameter escaping, budgets and boundary-safe folds. Generated Unicode cases verify parse/serialize meaning and deterministic output, plus folds at arbitrary octet positions on VM/Chrome. The root check script now runs the dedicated package suite on both platforms. See [recorded commands/results](scaffold-validation.md).

Next, build explicit semantic validators and typed wire-value adapters for the selected component/property profiles. Retaining unknown syntax is not permission to silently import it or publish unfiltered data. No complete iCalendar/client compatibility, source-history preservation, database import, authenticated export or HTTP subscription capability is claimed by this foundation.

Typed temporal conversion is now available separately in [the value codecs](icalendar-temporal-values.md) under ADR 0063. Pass raw values explicitly; generic parsing still does not guess value types or approve properties/components.
