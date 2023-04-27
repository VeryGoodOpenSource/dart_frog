extension ParameterSyntax on String {
  /// Replaces [] for <>
  String get toDiamondParameterSyntax {
    return replaceAll('[', '<').replaceAll(']', '>');
  }

  /// Replaces <> for []
  String get toBracketParameterSyntax {
    return replaceAll('<', '[').replaceAll('>', ']');
  }

  /// Detect if the given string has a < and a > after it
  bool get hasDiamondParameter {
    final regexp = RegExp('<.*?>');
    return regexp.hasMatch(this);
  }

  /// Get the route parameters from the given string.
  List<String?> get parameterNames {
    final regexp = RegExp(r'\[(.*?)\]');
    final matches = regexp.allMatches(toBracketParameterSyntax);
    return matches
        .map((m) => m[0]?.replaceAll(RegExp(r'[\[\]]'), ''))
        .where((el) => el != null)
        .toList();
  }
}
