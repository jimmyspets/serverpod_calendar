// Exact UTC arithmetic shared internally. Do not use the potentially rounded
// epoch-microsecond getter on JavaScript targets outside its exact range.
BigInt utcMicroseconds(DateTime value) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, 'instant', 'Must be explicitly UTC');
  }
  if (value.isBefore(DateTime.utc(1969, 12, 30)) ||
      value.isAfter(DateTime.utc(2100, 1, 3))) {
    throw RangeError('UTC value is outside calendar calculation padding');
  }
  if (value.millisecond != 0 || value.microsecond != 0) {
    throw ArgumentError('Calendar time requires whole seconds');
  }
  return BigInt.from(value.millisecondsSinceEpoch) * BigInt.from(1000) +
      BigInt.from(value.microsecond);
}

DateTime utcFromMicroseconds(BigInt value) {
  final lower = BigInt.from(-172800000000);
  final upper = BigInt.from(4102617600000000);
  if (value < lower || value > upper) {
    throw RangeError('UTC result exceeds calendar calculation padding');
  }
  final remainder = value % BigInt.from(1000);
  final milliseconds = (value - remainder) ~/ BigInt.from(1000);
  return DateTime.fromMillisecondsSinceEpoch(
    milliseconds.toInt(),
    isUtc: true,
  ).add(Duration(microseconds: remainder.toInt()));
}
