// Exact UTC arithmetic shared internally. Do not use the potentially rounded
// epoch-microsecond getter on JavaScript targets outside its exact range.
BigInt utcMicroseconds(DateTime value) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, 'instant', 'Must be explicitly UTC');
  }
  return BigInt.from(value.millisecondsSinceEpoch) * BigInt.from(1000) +
      BigInt.from(value.microsecond);
}

DateTime utcFromMicroseconds(BigInt value) {
  final bound = BigInt.from(8640000000000000) * BigInt.from(1000);
  if (value < -bound || value > bound) {
    throw RangeError('UTC result exceeds the Dart DateTime instant range');
  }
  final remainder = value % BigInt.from(1000);
  final milliseconds = (value - remainder) ~/ BigInt.from(1000);
  return DateTime.fromMillisecondsSinceEpoch(
    milliseconds.toInt(),
    isUtc: true,
  ).add(Duration(microseconds: remainder.toInt()));
}
