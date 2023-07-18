import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Adds hashing functionality to [String]s.
extension HashStringExtension on String {
  /// Returns the SHA256 hash of this [String].
  String get hashValue {
    return sha256.convert(utf8.encode(this)).toString();
  }
}
