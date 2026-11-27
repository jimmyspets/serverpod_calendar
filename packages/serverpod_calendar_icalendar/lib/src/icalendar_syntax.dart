import 'dart:convert';
import 'dart:typed_data';

import 'calendar_text_metadata.dart';

enum IcalendarSyntaxError {
  encoding,
  lineEnding,
  byteOrderMark,
  contentLine,
  structure,
  limitExceeded,
}

/// Diagnostics deliberately omit source values and decoder exception payloads.
final class IcalendarSyntaxException implements Exception {
  const IcalendarSyntaxException(this.kind, {this.line, this.limit});
  final IcalendarSyntaxError kind;
  final int? line;
  final String? limit;
  @override
  String toString() =>
      'IcalendarSyntaxException(${kind.name}, line: $line, limit: $limit)';
}

final class IcalendarSyntaxLimits {
  const IcalendarSyntaxLimits({
    this.maxBytes = 1048576,
    this.maxPhysicalLineBytes = 65536,
    this.maxUnfoldedLineBytes = 65536,
    this.maxLines = 10000,
    this.maxComponents = 1000,
    this.maxDepth = 16,
    this.maxParameters = 32,
    this.maxParameterValues = 64,
    this.maxNameBytes = 64,
  });
  final int maxBytes,
      maxPhysicalLineBytes,
      maxUnfoldedLineBytes,
      maxLines,
      maxComponents,
      maxDepth,
      maxParameters,
      maxParameterValues,
      maxNameBytes;

  void _validate() {
    for (final n in [
      maxBytes,
      maxPhysicalLineBytes,
      maxUnfoldedLineBytes,
      maxLines,
      maxComponents,
      maxDepth,
      maxParameters,
      maxParameterValues,
      maxNameBytes,
    ]) {
      if (n < 1 || n > 67108864) throw ArgumentError('Invalid syntax limit');
    }
    if (maxDepth > 64) throw ArgumentError('Syntax depth cannot exceed 64');
  }
}

sealed class IcalendarSyntaxEntry {
  const IcalendarSyntaxEntry();
}

/// Balanced syntax only. No component/property is approved for import by this.
final class IcalendarSyntaxDocument {
  IcalendarSyntaxDocument(Iterable<IcalendarSyntaxComponent> components)
    : components = List.unmodifiable(components);
  final List<IcalendarSyntaxComponent> components;
}

final class IcalendarSyntaxComponent extends IcalendarSyntaxEntry {
  IcalendarSyntaxComponent(this.name, Iterable<IcalendarSyntaxEntry> entries)
    : entries = List.unmodifiable(entries);
  final String name;
  final List<IcalendarSyntaxEntry> entries;
  String get canonicalName => name.toUpperCase();
}

final class IcalendarSyntaxParameter {
  IcalendarSyntaxParameter(this.name, Iterable<String> values)
    : values = List.unmodifiable(values);
  final String name;

  /// Decoded RFC 6868 values, not TEXT values. Backslashes remain literal.
  final List<String> values;
  String get canonicalName => name.toUpperCase();
}

final class IcalendarSyntaxProperty extends IcalendarSyntaxEntry {
  IcalendarSyntaxProperty(
    this.name,
    this.value, {
    Iterable<IcalendarSyntaxParameter> parameters = const [],
  }) : parameters = List.unmodifiable(parameters);
  final String name;

  /// Raw escaped property value. Its type/meaning has not been interpreted.
  final String value;
  final List<IcalendarSyntaxParameter> parameters;
  String get canonicalName => name.toUpperCase();
}

Never _syntax(IcalendarSyntaxError kind, {int? line, String? limit}) =>
    throw IcalendarSyntaxException(kind, line: line, limit: limit);

void _bound(int value, int maximum, String label, {int? line}) {
  if (value > maximum) {
    _syntax(IcalendarSyntaxError.limitExceeded, line: line, limit: label);
  }
}

void _name(String value, IcalendarSyntaxLimits limits, {int? line}) {
  _bound(value.length, limits.maxNameBytes, 'nameBytes', line: line);
  if (value.isEmpty || RegExp(r'[^A-Za-z0-9-]').hasMatch(value)) {
    _syntax(IcalendarSyntaxError.contentLine, line: line);
  }
}

void _characters(String value, int maximum, {bool newline = false, int? line}) {
  if (maximum < 1 || maximum > 67108864) {
    throw ArgumentError('Invalid codec limit');
  }
  _bound(value.length, maximum, 'unfoldedLineBytes', line: line);
  try {
    validateCalendarPlainText(value, maxCodePoints: maximum);
  } on ArgumentError {
    _syntax(IcalendarSyntaxError.contentLine, line: line);
  }
  if (value.contains('\r') || (!newline && value.contains('\n'))) {
    _syntax(IcalendarSyntaxError.contentLine, line: line);
  }
}

/// Unfold octets before decoding: even a split UTF-8 sequence is restored.
IcalendarSyntaxDocument parseIcalendarSyntax(
  List<int> input, {
  IcalendarSyntaxLimits limits = const IcalendarSyntaxLimits(),
}) {
  limits._validate();
  _bound(input.length, limits.maxBytes, 'inputBytes');
  final bytes = List<int>.of(input);
  if (bytes.any((v) => v < 0 || v > 255)) {
    _syntax(IcalendarSyntaxError.encoding);
  }
  if (bytes.length >= 3 &&
      bytes[0] == 239 &&
      bytes[1] == 187 &&
      bytes[2] == 191) {
    _syntax(IcalendarSyntaxError.byteOrderMark, line: 1);
  }
  final roots = <IcalendarSyntaxComponent>[];
  final stack = <_ComponentBuilder>[];
  var lineCount = 0, componentCount = 0;
  void consume(List<int> logical, int sourceLine) {
    _bound(++lineCount, limits.maxLines, 'lines', line: sourceLine);
    String text;
    try {
      text = utf8.decode(logical, allowMalformed: false);
    } on FormatException {
      _syntax(IcalendarSyntaxError.encoding, line: sourceLine);
    }
    final property = _parseProperty(text, limits, sourceLine);
    final name = property.canonicalName;
    if (name == 'BEGIN' || name == 'END') {
      if (property.parameters.isNotEmpty) {
        _syntax(IcalendarSyntaxError.structure, line: sourceLine);
      }
      _name(property.value, limits, line: sourceLine);
      if (name == 'BEGIN') {
        _bound(
          ++componentCount,
          limits.maxComponents,
          'components',
          line: sourceLine,
        );
        _bound(stack.length + 1, limits.maxDepth, 'depth', line: sourceLine);
        stack.add(_ComponentBuilder(property.value));
      } else {
        if (stack.isEmpty ||
            stack.last.name.toUpperCase() != property.value.toUpperCase()) {
          _syntax(IcalendarSyntaxError.structure, line: sourceLine);
        }
        final builder = stack.removeLast();
        final component = IcalendarSyntaxComponent(
          builder.name,
          builder.entries,
        );
        if (stack.isEmpty) {
          roots.add(component);
        } else {
          stack.last.entries.add(component);
        }
      }
    } else {
      if (stack.isEmpty) {
        _syntax(IcalendarSyntaxError.structure, line: sourceLine);
      }
      stack.last.entries.add(property);
    }
  }

  var position = 0, physicalLine = 0, logicalStart = 1;
  List<int>? logical;
  while (position < bytes.length) {
    final start = position;
    physicalLine++;
    while (position < bytes.length && bytes[position] != 13) {
      if (bytes[position] == 10) {
        _syntax(IcalendarSyntaxError.lineEnding, line: physicalLine);
      }
      position++;
      _bound(
        position - start,
        limits.maxPhysicalLineBytes,
        'physicalLineBytes',
        line: physicalLine,
      );
    }
    if (position + 1 >= bytes.length || bytes[position + 1] != 10) {
      _syntax(IcalendarSyntaxError.lineEnding, line: physicalLine);
    }
    final end = position;
    position += 2;
    if (start == end) {
      _syntax(IcalendarSyntaxError.contentLine, line: physicalLine);
    }
    final continuation =
        start < end && (bytes[start] == 32 || bytes[start] == 9);
    if (continuation) {
      if (logical == null) {
        _syntax(IcalendarSyntaxError.contentLine, line: physicalLine);
      }
      _bound(
        logical.length + end - start - 1,
        limits.maxUnfoldedLineBytes,
        'unfoldedLineBytes',
        line: logicalStart,
      );
      logical.addAll(bytes.getRange(start + 1, end));
    } else {
      if (logical != null) consume(logical, logicalStart);
      _bound(
        end - start,
        limits.maxUnfoldedLineBytes,
        'unfoldedLineBytes',
        line: physicalLine,
      );
      logical = bytes.sublist(start, end);
      logicalStart = physicalLine;
    }
  }
  if (logical != null) consume(logical, logicalStart);
  if (stack.isNotEmpty || roots.isEmpty) {
    _syntax(IcalendarSyntaxError.structure, line: physicalLine);
  }
  return IcalendarSyntaxDocument(roots);
}

final class _ComponentBuilder {
  _ComponentBuilder(this.name);
  final String name;
  final entries = <IcalendarSyntaxEntry>[];
}

IcalendarSyntaxProperty _parseProperty(
  String text,
  IcalendarSyntaxLimits limits,
  int sourceLine,
) {
  _characters(text, limits.maxUnfoldedLineBytes, line: sourceLine);
  var i = 0;
  while (i < text.length && text[i] != ';' && text[i] != ':') {
    i++;
  }
  final name = text.substring(0, i);
  _name(name, limits, line: sourceLine);
  final parameters = <IcalendarSyntaxParameter>[];
  while (i < text.length && text[i] == ';') {
    _bound(
      parameters.length + 1,
      limits.maxParameters,
      'parameters',
      line: sourceLine,
    );
    final start = ++i;
    while (i < text.length &&
        text[i] != '=' &&
        text[i] != ';' &&
        text[i] != ':') {
      i++;
    }
    final parameterName = text.substring(start, i);
    _name(parameterName, limits, line: sourceLine);
    if (i == text.length || text[i++] != '=') {
      _syntax(IcalendarSyntaxError.contentLine, line: sourceLine);
    }
    final values = <String>[];
    while (true) {
      _bound(
        values.length + 1,
        limits.maxParameterValues,
        'parameterValues',
        line: sourceLine,
      );
      final quoted = i < text.length && text[i] == '"';
      if (quoted) i++;
      final valueStart = i;
      if (quoted) {
        while (i < text.length && text[i] != '"') {
          i++;
        }
        if (i == text.length) {
          _syntax(IcalendarSyntaxError.contentLine, line: sourceLine);
        }
      } else {
        while (i < text.length && ![',', ';', ':', '"'].contains(text[i])) {
          i++;
        }
        if (i < text.length && text[i] == '"') {
          _syntax(IcalendarSyntaxError.contentLine, line: sourceLine);
        }
      }
      values.add(
        decodeIcalendarParameter(
          text.substring(valueStart, i),
          maxCharacters: limits.maxUnfoldedLineBytes,
        ),
      );
      if (quoted) i++;
      if (i < text.length && text[i] == ',') {
        i++;
        continue;
      }
      break;
    }
    parameters.add(IcalendarSyntaxParameter(parameterName, values));
  }
  if (i >= text.length || text[i] != ':') {
    _syntax(IcalendarSyntaxError.contentLine, line: sourceLine);
  }
  return IcalendarSyntaxProperty(
    name,
    text.substring(i + 1),
    parameters: parameters,
  );
}

/// Deterministic syntax output only; callers must validate profile/disclosure.
Uint8List serializeIcalendarSyntax(
  IcalendarSyntaxDocument document, {
  IcalendarSyntaxLimits limits = const IcalendarSyntaxLimits(),
}) {
  limits._validate();
  if (document.components.isEmpty) _syntax(IcalendarSyntaxError.structure);
  final output = BytesBuilder(copy: false);
  var lineCount = 0, componentCount = 0;
  void emit(String line) {
    _bound(++lineCount, limits.maxLines, 'lines');
    final bytes = utf8.encode(line);
    _bound(bytes.length, limits.maxUnfoldedLineBytes, 'unfoldedLineBytes');
    var position = 0;
    while (position < bytes.length) {
      final continuation = position > 0;
      var end = position + (continuation ? 74 : 75);
      if (end > bytes.length) end = bytes.length;
      while (end < bytes.length && (bytes[end] & 192) == 128) {
        end--;
      }
      final physicalLength = end - position + (continuation ? 1 : 0);
      _bound(physicalLength, limits.maxPhysicalLineBytes, 'physicalLineBytes');
      _bound(
        output.length + physicalLength + 2,
        limits.maxBytes,
        'outputBytes',
      );
      if (continuation) output.addByte(32);
      output.add(bytes.sublist(position, end));
      output.add(const [13, 10]);
      position = end;
    }
  }

  void component(IcalendarSyntaxComponent value, int depth) {
    _bound(depth, limits.maxDepth, 'depth');
    _bound(++componentCount, limits.maxComponents, 'components');
    _name(value.name, limits);
    emit('BEGIN:${value.name}');
    for (final entry in value.entries) {
      switch (entry) {
        case IcalendarSyntaxComponent():
          component(entry, depth + 1);
        case IcalendarSyntaxProperty():
          emit(_propertyWire(entry, limits));
      }
    }
    emit('END:${value.name}');
  }

  for (final root in document.components) {
    component(root, 1);
  }
  return output.takeBytes();
}

String _propertyWire(
  IcalendarSyntaxProperty value,
  IcalendarSyntaxLimits limits,
) {
  _name(value.name, limits);
  if (value.canonicalName == 'BEGIN' || value.canonicalName == 'END') {
    _syntax(IcalendarSyntaxError.structure);
  }
  _bound(value.parameters.length, limits.maxParameters, 'parameters');
  final result = StringBuffer();
  var bytes = 0;
  void append(String part) {
    _characters(part, limits.maxUnfoldedLineBytes);
    bytes += utf8.encode(part).length;
    _bound(bytes, limits.maxUnfoldedLineBytes, 'unfoldedLineBytes');
    result.write(part);
  }

  append(value.name);
  for (final parameter in value.parameters) {
    _name(parameter.name, limits);
    if (parameter.values.isEmpty) _syntax(IcalendarSyntaxError.contentLine);
    _bound(
      parameter.values.length,
      limits.maxParameterValues,
      'parameterValues',
    );
    append(';${parameter.name}=');
    for (var i = 0; i < parameter.values.length; i++) {
      if (i > 0) append(',');
      final encoded = encodeIcalendarParameter(
        parameter.values[i],
        maxCharacters: limits.maxUnfoldedLineBytes,
      );
      append(encoded.contains(RegExp(r'[,;:]')) ? '"$encoded"' : encoded);
    }
  }
  append(':');
  append(value.value);
  return result.toString();
}

/// RFC 6868 decoding; unknown caret pairs remain literal, including ^N.
String decodeIcalendarParameter(String value, {int maxCharacters = 65536}) {
  _characters(value, maxCharacters);
  final result = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    if (value[i] == '^' && i + 1 < value.length) {
      final next = value[i + 1];
      if (next == '^' || next == "'" || next == 'n') {
        result.write(
          next == "'"
              ? '"'
              : next == 'n'
              ? '\n'
              : '^',
        );
        i++;
        continue;
      }
    }
    result.write(value[i]);
  }
  return result.toString();
}

String encodeIcalendarParameter(String value, {int maxCharacters = 65536}) {
  _characters(value, maxCharacters, newline: true);
  return value
      .replaceAll('^', '^^')
      .replaceAll('\n', '^n')
      .replaceAll('"', "^'");
}

String decodeIcalendarText(String value, {int maxCharacters = 65536}) {
  _characters(value, maxCharacters);
  final result = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == ',' || char == ';') _syntax(IcalendarSyntaxError.contentLine);
    if (char != r'\') {
      result.write(char);
      continue;
    }
    if (++i == value.length) _syntax(IcalendarSyntaxError.contentLine);
    switch (value[i]) {
      case 'n' || 'N':
        result.write('\n');
      case r'\' || ',' || ';':
        result.write(value[i]);
      default:
        _syntax(IcalendarSyntaxError.contentLine);
    }
  }
  return result.toString();
}

String encodeIcalendarText(String value, {int maxCharacters = 65536}) {
  _characters(value, maxCharacters, newline: true);
  return value
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');
}

List<String> decodeIcalendarTextList(
  String value, {
  int maxCharacters = 65536,
  int maxValues = 256,
}) {
  if (maxValues < 1) throw ArgumentError('Invalid TEXT list limit');
  _characters(value, maxCharacters);
  final result = <String>[];
  var start = 0;
  for (var i = 0; i <= value.length; i++) {
    if (i < value.length && value[i] == r'\') {
      if (i + 1 == value.length) _syntax(IcalendarSyntaxError.contentLine);
      i++;
      continue;
    }
    if (i == value.length || value[i] == ',') {
      _bound(result.length + 1, maxValues, 'textValues');
      result.add(
        decodeIcalendarText(
          value.substring(start, i),
          maxCharacters: maxCharacters,
        ),
      );
      start = i + 1;
    }
  }
  return List.unmodifiable(result);
}

String encodeIcalendarTextList(
  Iterable<String> values, {
  int maxCharacters = 65536,
  int maxValues = 256,
}) {
  if (maxValues < 1) throw ArgumentError('Invalid TEXT list limit');
  final result = StringBuffer();
  var count = 0;
  for (final value in values) {
    _bound(++count, maxValues, 'textValues');
    final encoded = encodeIcalendarText(value, maxCharacters: maxCharacters);
    _bound(
      result.length + encoded.length + (count > 1 ? 1 : 0),
      maxCharacters,
      'textCharacters',
    );
    if (count > 1) result.write(',');
    result.write(encoded);
  }
  if (count == 0) _syntax(IcalendarSyntaxError.contentLine);
  return result.toString();
}
