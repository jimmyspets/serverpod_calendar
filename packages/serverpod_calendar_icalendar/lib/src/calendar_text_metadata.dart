import 'dart:convert';

/// Decoded text metadata only. This is not an ICS parser or serializer.
final class IcalendarTextVariant {
  const IcalendarTextVariant(this.value, {this.language});
  final String value;
  final String? language;
}

/// Native-editing profile: 16 variants/property, 64 KiB total decoded UTF8.
/// Preserves spelling/order and does not fetch or infer any language/content.
final class IcalendarCalendarTextMetadata {
  factory IcalendarCalendarTextMetadata({
    Iterable<IcalendarTextVariant> names = const [],
    Iterable<IcalendarTextVariant> descriptions = const [],
    String? color,
  }) {
    final n = _variants(names, 4096);
    final d = _variants(descriptions, 16384);
    if (color != null &&
        (color.length > 20 ||
            !css3CalendarColorNames.contains(color.toLowerCase()))) {
      throw ArgumentError('RFC COLOR requires a CSS3 section 4.3 color name');
    }
    final bytes = [...n, ...d].fold<int>(
      0,
      (sum, v) => sum + utf8.encode(v.value).length + (v.language?.length ?? 0),
    );
    if (bytes + (color?.length ?? 0) > 65536) {
      throw ArgumentError('Metadata exceeds aggregate text limit');
    }
    return IcalendarCalendarTextMetadata._(n, d, color);
  }
  IcalendarCalendarTextMetadata._(this.names, this.descriptions, this.color);
  final List<IcalendarTextVariant> names, descriptions;
  final String? color;
  bool get isEmpty => names.isEmpty && descriptions.isEmpty && color == null;

  static List<IcalendarTextVariant> _variants(
    Iterable<IcalendarTextVariant> source,
    int maxPoints,
  ) {
    final result = <IcalendarTextVariant>[];
    final languages = <String?>{};
    for (final v in source) {
      if (result.length == 16) {
        throw ArgumentError('Too many language variants');
      }
      validateCalendarPlainText(v.value, maxCodePoints: maxPoints);
      if (v.language != null) validateCalendarLanguageTag(v.language!);
      if (!languages.add(v.language?.toLowerCase())) {
        throw ArgumentError('Duplicate language variant');
      }
      result.add(v);
    }
    return List.unmodifiable(result);
  }
}

/// Application decoded-text rule; not a rule for raw iCalendar content lines.
void validateCalendarPlainText(String value, {required int maxCodePoints}) {
  if (value.length > maxCodePoints * 2) throw ArgumentError('Text too long');
  final units = value.codeUnits;
  for (var i = 0; i < units.length; i++) {
    final c = units[i];
    if ((c < 32 && c != 9 && c != 10 && c != 13) || c == 127) {
      throw ArgumentError('Unsupported control character');
    }
    if (c >= 0xd800 && c <= 0xdbff) {
      if (++i >= units.length || units[i] < 0xdc00 || units[i] > 0xdfff) {
        throw ArgumentError('Malformed Unicode');
      }
    } else if (c >= 0xdc00 && c <= 0xdfff) {
      throw ArgumentError('Malformed Unicode');
    }
  }
  if (value.runes.length > maxCodePoints) throw ArgumentError('Text too long');
}

/// BCP47 well-formedness, not IANA registry validity or alias canonicalization.
void validateCalendarLanguageTag(String value) {
  if (value.isEmpty ||
      value.length > 255 ||
      value.codeUnits.any(
        (c) =>
            !((c >= 65 && c <= 90) ||
                (c >= 97 && c <= 122) ||
                (c >= 48 && c <= 57) ||
                c == 45),
      )) {
    throw ArgumentError('Malformed language tag');
  }
  final tag = value.toLowerCase();
  if (_grandfathered.contains(tag)) return;
  final p = tag.split('-');
  bool alpha(String v) =>
      v.isNotEmpty && v.codeUnits.every((c) => c >= 97 && c <= 122);
  bool digit(String v) =>
      v.isNotEmpty && v.codeUnits.every((c) => c >= 48 && c <= 57);
  bool length(String v, int min, int max) => v.length >= min && v.length <= max;
  bool alnum(String v) =>
      v.isNotEmpty &&
      v.codeUnits.every((c) => (c >= 97 && c <= 122) || (c >= 48 && c <= 57));
  Never bad() => throw ArgumentError('Malformed language tag');
  var i = 0;
  if (p.first == 'x') {
    if (p.length < 2 || !p.skip(1).every((v) => length(v, 1, 8) && alnum(v))) {
      bad();
    }
    return;
  }
  if (!length(p[0], 2, 8) || !alpha(p[0])) bad();
  i++;
  if (p.first.length <= 3) {
    var count = 0;
    while (i < p.length && p[i].length == 3 && alpha(p[i]) && count < 3) {
      i++;
      count++;
    }
  }
  if (i < p.length && p[i].length == 4 && alpha(p[i])) i++;
  if (i < p.length &&
      ((p[i].length == 2 && alpha(p[i])) ||
          (p[i].length == 3 && digit(p[i])))) {
    i++;
  }
  final variants = <String>{};
  while (i < p.length &&
      ((length(p[i], 5, 8) && alnum(p[i])) ||
          (p[i].length == 4 && digit(p[i][0]) && alnum(p[i])))) {
    if (!variants.add(p[i++])) bad();
  }
  final extensions = <String>{};
  while (i < p.length && p[i].length == 1 && p[i] != 'x' && alnum(p[i])) {
    if (!extensions.add(p[i++])) bad();
    final start = i;
    while (i < p.length && length(p[i], 2, 8) && alnum(p[i])) {
      i++;
    }
    if (i == start) bad();
  }
  if (i < p.length && p[i] == 'x') {
    i++;
    final start = i;
    while (i < p.length && length(p[i], 1, 8) && alnum(p[i])) {
      i++;
    }
    if (i == start) bad();
  }
  if (i != p.length) bad();
}

const _grandfathered = {
  'en-gb-oed',
  'i-ami',
  'i-bnn',
  'i-default',
  'i-enochian',
  'i-hak',
  'i-klingon',
  'i-lux',
  'i-mingo',
  'i-navajo',
  'i-pwn',
  'i-tao',
  'i-tay',
  'i-tsu',
  'sgn-be-fr',
  'sgn-be-nl',
  'sgn-ch-de',
  'art-lojban',
  'cel-gaulish',
  'no-bok',
  'no-nyn',
  'zh-guoyu',
  'zh-hakka',
  'zh-min',
  'zh-min-nan',
  'zh-xiang',
};

/// RFC7986 refers specifically to the CSS3 Color 2011 section 4.3 names.
/// https://www.w3.org/TR/2011/REC-css3-color-20110607/#svg-color
/// Excludes transparent/currentColor and later CSS additions.
const css3CalendarColorNames = <String>{
  'aliceblue',
  'antiquewhite',
  'aqua',
  'aquamarine',
  'azure',
  'beige',
  'bisque',
  'black',
  'blanchedalmond',
  'blue',
  'blueviolet',
  'brown',
  'burlywood',
  'cadetblue',
  'chartreuse',
  'chocolate',
  'coral',
  'cornflowerblue',
  'cornsilk',
  'crimson',
  'cyan',
  'darkblue',
  'darkcyan',
  'darkgoldenrod',
  'darkgray',
  'darkgreen',
  'darkgrey',
  'darkkhaki',
  'darkmagenta',
  'darkolivegreen',
  'darkorange',
  'darkorchid',
  'darkred',
  'darksalmon',
  'darkseagreen',
  'darkslateblue',
  'darkslategray',
  'darkslategrey',
  'darkturquoise',
  'darkviolet',
  'deeppink',
  'deepskyblue',
  'dimgray',
  'dimgrey',
  'dodgerblue',
  'firebrick',
  'floralwhite',
  'forestgreen',
  'fuchsia',
  'gainsboro',
  'ghostwhite',
  'gold',
  'goldenrod',
  'gray',
  'green',
  'greenyellow',
  'grey',
  'honeydew',
  'hotpink',
  'indianred',
  'indigo',
  'ivory',
  'khaki',
  'lavender',
  'lavenderblush',
  'lawngreen',
  'lemonchiffon',
  'lightblue',
  'lightcoral',
  'lightcyan',
  'lightgoldenrodyellow',
  'lightgray',
  'lightgreen',
  'lightgrey',
  'lightpink',
  'lightsalmon',
  'lightseagreen',
  'lightskyblue',
  'lightslategray',
  'lightslategrey',
  'lightsteelblue',
  'lightyellow',
  'lime',
  'limegreen',
  'linen',
  'magenta',
  'maroon',
  'mediumaquamarine',
  'mediumblue',
  'mediumorchid',
  'mediumpurple',
  'mediumseagreen',
  'mediumslateblue',
  'mediumspringgreen',
  'mediumturquoise',
  'mediumvioletred',
  'midnightblue',
  'mintcream',
  'mistyrose',
  'moccasin',
  'navajowhite',
  'navy',
  'oldlace',
  'olive',
  'olivedrab',
  'orange',
  'orangered',
  'orchid',
  'palegoldenrod',
  'palegreen',
  'paleturquoise',
  'palevioletred',
  'papayawhip',
  'peachpuff',
  'peru',
  'pink',
  'plum',
  'powderblue',
  'purple',
  'red',
  'rosybrown',
  'royalblue',
  'saddlebrown',
  'salmon',
  'sandybrown',
  'seagreen',
  'seashell',
  'sienna',
  'silver',
  'skyblue',
  'slateblue',
  'slategray',
  'slategrey',
  'snow',
  'springgreen',
  'steelblue',
  'tan',
  'teal',
  'thistle',
  'tomato',
  'turquoise',
  'violet',
  'wheat',
  'white',
  'whitesmoke',
  'yellow',
  'yellowgreen',
};
