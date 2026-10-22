import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'availability_values.dart';

/// Candidate index aid only; exact UID equality under the scope lock decides.
String availabilityUidDigest(String uid) {
  validateAvailabilityUid(uid);
  return sha256.convert(utf8.encode(uid)).toString();
}

bool availabilityUidConflicts(String uid, Iterable<String> candidates) =>
    candidates.any((candidate) => candidate == uid);
