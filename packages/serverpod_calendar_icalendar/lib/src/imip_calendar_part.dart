import 'dart:convert';

import 'icalendar_component_support.dart';
import 'icalendar_event_calendar.dart';
import 'icalendar_syntax.dart';

enum ImipProtection { none, signed, encrypted, unknown }

enum ImipPartError {
  mediaType,
  parameter,
  missingMethod,
  methodMismatch,
  componentMismatch,
  charset,
  mailbox,
  protection,
  limitExceeded,
  calendar,
}

/// Diagnostics never contain source values or nested decoder messages.
final class ImipPartException implements Exception {
  const ImipPartException(this.kind);
  final ImipPartError kind;
  @override
  String toString() => 'ImipPartException(${kind.name})';
}

Never _fail(ImipPartError kind) => throw ImipPartException(kind);

final class ImipPartLimits {
  const ImipPartLimits({
    this.maxDecodedBytes = 262144,
    this.maxParameters = 16,
  });
  final int maxDecodedBytes, maxParameters;
  void _validate() {
    if (maxDecodedBytes < 1 ||
        maxDecodedBytes > 1048576 ||
        maxParameters < 1 ||
        maxParameters > 64) {
      throw ArgumentError('Invalid iMIP part limits');
    }
  }
}

/// Already MIME-decoded, with spelling retained. Not a raw MIME header parser.
final class ImipParameter {
  const ImipParameter(this.name, this.value);
  final String name, value;
}

/// One bounded, frozen, transfer-decoded part. Protection describes the actual
/// outer MIME context supplied by the host, never authenticated sender identity.
final class ImipDecodedPart {
  factory ImipDecodedPart({
    required String mediaType,
    required Iterable<ImipParameter> parameters,
    required List<int> body,
    required ImipProtection protection,
    ImipPartLimits limits = const ImipPartLimits(),
  }) {
    limits._validate();
    if (mediaType.length > 128 || body.length > limits.maxDecodedBytes) {
      _fail(ImipPartError.limitExceeded);
    }
    final copied = <ImipParameter>[];
    for (final parameter in parameters) {
      if (copied.length == limits.maxParameters ||
          parameter.name.length > 64 ||
          parameter.value.length > 1024 ||
          utf8.encode(parameter.value).length > 1024) {
        _fail(ImipPartError.limitExceeded);
      }
      copied.add(parameter);
    }
    for (final byte in body) {
      if (byte < 0 || byte > 255) _fail(ImipPartError.calendar);
    }
    return ImipDecodedPart._(
      mediaType,
      List.unmodifiable(copied),
      List.unmodifiable(body),
      protection,
    );
  }
  ImipDecodedPart._(
    this.mediaType,
    this.parameters,
    this.body,
    this.protection,
  );
  final String mediaType;
  final List<ImipParameter> parameters;
  final List<int> body;
  final ImipProtection protection;
}

/// Source MIME distinctions and exactly one typed untrusted scheduling payload.
/// Acceptance performs no lookup, native reconciliation, routing or delivery.
final class ImipCalendarPart {
  ImipCalendarPart._(this.source, this.eventMessage, this.freeBusyMessage);
  final ImipDecodedPart source;
  final IcalendarSchedulingMessage? eventMessage;
  final IcalendarFreeBusyMessage? freeBusyMessage;
  String get component => eventMessage == null ? 'VFREEBUSY' : 'VEVENT';
  String get method =>
      (eventMessage?.method.name ?? freeBusyMessage!.method.name).toUpperCase();
}

final _token = RegExp(r"^[A-Za-z0-9!#$%&'*+.^_`|~-]+$");
final _uriCharacters = RegExp(r"^[A-Za-z0-9._~!$&'()*+,;=:@%/\-]+$");
final _localAtom = RegExp(r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+$");
final _domainLabel = RegExp(r'^[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?$');

void _mailbox(String value) {
  if (value.length > 2048) _fail(ImipPartError.limitExceeded);
  if (value.codeUnits.any((c) => c <= 32 || c >= 127) ||
      !value.toLowerCase().startsWith('mailto:') ||
      !_uriCharacters.hasMatch(value)) {
    _fail(ImipPartError.mailbox);
  }
  String mailbox;
  try {
    mailbox = Uri.decodeComponent(value.substring(7));
  } on FormatException {
    _fail(ImipPartError.mailbox);
  }
  if (mailbox.codeUnits.any((c) => c <= 32 || c >= 127)) {
    _fail(ImipPartError.mailbox);
  }
  final halves = mailbox.split('@');
  if (halves.length != 2 ||
      halves[0].isEmpty ||
      halves[1].length > 253 ||
      !halves[0].split('.').every((atom) => _localAtom.hasMatch(atom)) ||
      !halves[1].split('.').every((label) => _domainLabel.hasMatch(label))) {
    _fail(ImipPartError.mailbox);
  }
}

IcalendarSyntaxLimits _syntax(ImipPartLimits limits, IcalendarSyntaxLimits s) =>
    IcalendarSyntaxLimits(
      maxBytes: s.maxBytes < limits.maxDecodedBytes
          ? s.maxBytes
          : limits.maxDecodedBytes,
      maxPhysicalLineBytes: s.maxPhysicalLineBytes,
      maxUnfoldedLineBytes: s.maxUnfoldedLineBytes,
      maxLines: s.maxLines,
      maxComponents: s.maxComponents,
      maxDepth: s.maxDepth,
      maxParameters: s.maxParameters,
      maxParameterValues: s.maxParameterValues,
      maxNameBytes: s.maxNameBytes,
    );

T _calendar<T>(T Function() action) {
  try {
    return action();
  } on IcalendarComponentException catch (e) {
    _fail(
      e.kind == IcalendarComponentError.limitExceeded
          ? ImipPartError.limitExceeded
          : ImipPartError.calendar,
    );
  } on IcalendarSyntaxException catch (e) {
    _fail(
      e.kind == IcalendarSyntaxError.limitExceeded
          ? ImipPartError.limitExceeded
          : ImipPartError.calendar,
    );
  }
}

ImipCalendarPart parseImipCalendarPart(
  ImipDecodedPart part, {
  ImipPartLimits limits = const ImipPartLimits(),
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits componentLimits = const IcalendarComponentLimits(),
}) {
  limits._validate();
  if (part.protection != ImipProtection.none) _fail(ImipPartError.protection);
  if (part.body.length > limits.maxDecodedBytes ||
      part.parameters.length > limits.maxParameters) {
    _fail(ImipPartError.limitExceeded);
  }
  if (part.mediaType.toLowerCase() != 'text/calendar') {
    _fail(ImipPartError.mediaType);
  }
  final parameters = <String, String>{};
  for (final parameter in part.parameters) {
    if (parameter.name.codeUnits.any((c) => c <= 32 || c >= 127) ||
        parameter.value.codeUnits.any((c) => c <= 32 || c >= 127) ||
        !_token.hasMatch(parameter.name) ||
        !_token.hasMatch(parameter.value)) {
      _fail(ImipPartError.parameter);
    }
    final name = parameter.name.toLowerCase();
    if (!const {'method', 'component', 'charset'}.contains(name) ||
        parameters.containsKey(name)) {
      _fail(ImipPartError.parameter);
    }
    parameters[name] = parameter.value.toUpperCase();
  }
  if (!parameters.containsKey('method')) _fail(ImipPartError.missingMethod);
  final charset = parameters['charset'];
  if ((charset != null && charset != 'UTF-8' && charset != 'US-ASCII') ||
      (charset != 'UTF-8' && part.body.any((b) => b > 127))) {
    _fail(ImipPartError.charset);
  }
  return _calendar(() {
    final syntax = _syntax(limits, syntaxLimits);
    final document = parseIcalendarSyntax(part.body, limits: syntax);
    if (document.components.length != 1 ||
        document.components.single.canonicalName != 'VCALENDAR') {
      _fail(ImipPartError.calendar);
    }
    final components = document.components.single.entries
        .whereType<IcalendarSyntaxComponent>()
        .toList();
    final kinds = components
        .map((c) => c.canonicalName)
        .where((name) => name != 'VTIMEZONE')
        .toSet();
    if (kinds.length != 1 ||
        !const {'VEVENT', 'VFREEBUSY'}.contains(kinds.single)) {
      _fail(ImipPartError.calendar);
    }
    final kind = kinds.single;
    if (parameters['component'] != null && parameters['component'] != kind) {
      _fail(ImipPartError.componentMismatch);
    }
    final event = kind == 'VEVENT'
        ? validateIcalendarSchedulingMessage(
            document,
            syntaxLimits: syntax,
            limits: componentLimits,
          )
        : null;
    final busy = kind == 'VFREEBUSY'
        ? validateIcalendarFreeBusyMessage(
            document,
            syntaxLimits: syntax,
            limits: componentLimits,
          )
        : null;
    final result = ImipCalendarPart._(part, event, busy);
    if (parameters['method'] != result.method) {
      _fail(ImipPartError.methodMismatch);
    }
    for (final component in components.where((c) => c.canonicalName == kind)) {
      for (final property
          in component.entries.whereType<IcalendarSyntaxProperty>()) {
        if (!const {'ORGANIZER', 'ATTENDEE'}.contains(property.canonicalName)) {
          continue;
        }
        _mailbox(property.value);
        for (final parameter in property.parameters) {
          if (const {
            'SENT-BY',
            'DELEGATED-TO',
            'DELEGATED-FROM',
          }.contains(parameter.canonicalName)) {
            for (final value in parameter.values) {
              _mailbox(value);
            }
          }
        }
      }
    }
    return result;
  });
}

/// Returns decoded canonical MIME metadata/body, never a deliverable email.
ImipDecodedPart serializeImipSchedulingMessage(
  IcalendarSchedulingMessage message, {
  required bool requireProtection,
  ImipPartLimits limits = const ImipPartLimits(),
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits componentLimits = const IcalendarComponentLimits(),
}) => _output(
  (syntax) =>
      serializeIcalendarSchedulingMessage(message, syntaxLimits: syntax),
  message.method.name.toUpperCase(),
  'VEVENT',
  requireProtection,
  limits,
  syntaxLimits,
  componentLimits,
);

ImipDecodedPart serializeImipFreeBusyMessage(
  IcalendarFreeBusyMessage message, {
  required bool requireProtection,
  ImipPartLimits limits = const ImipPartLimits(),
  IcalendarSyntaxLimits syntaxLimits = const IcalendarSyntaxLimits(),
  IcalendarComponentLimits componentLimits = const IcalendarComponentLimits(),
}) => _output(
  (syntax) => serializeIcalendarFreeBusyMessage(message, syntaxLimits: syntax),
  message.method.name.toUpperCase(),
  'VFREEBUSY',
  requireProtection,
  limits,
  syntaxLimits,
  componentLimits,
);

ImipDecodedPart _output(
  List<int> Function(IcalendarSyntaxLimits) encode,
  String method,
  String component,
  bool protection,
  ImipPartLimits limits,
  IcalendarSyntaxLimits syntaxLimits,
  IcalendarComponentLimits componentLimits,
) {
  limits._validate();
  if (protection) _fail(ImipPartError.protection);
  final body = _calendar(() => encode(_syntax(limits, syntaxLimits)));
  final part = ImipDecodedPart(
    mediaType: 'text/calendar',
    parameters: [
      const ImipParameter('charset', 'UTF-8'),
      ImipParameter('method', method),
      ImipParameter('component', component),
    ],
    body: body,
    protection: ImipProtection.none,
    limits: limits,
  );
  parseImipCalendarPart(
    part,
    limits: limits,
    syntaxLimits: syntaxLimits,
    componentLimits: componentLimits,
  );
  return part;
}
