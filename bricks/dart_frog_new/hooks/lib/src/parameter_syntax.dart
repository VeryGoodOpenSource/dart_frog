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
  List<String> getParameterNames() {
    final regexp = RegExp(r'\[(.*?)\]');
    final names = regexp
        .allMatches(toBracketParameterSyntax)
        .map((m) => m[0]?.replaceAll(RegExp(r'[\[\]]'), ''))
        .where((el) => el != null)
        .cast<String>();

    final duplicates = names
        .toSet()
        .where((element) => names.where((el) => el == element).length > 1);
    if (duplicates.isNotEmpty) {
      final plural = duplicates.length > 1;
      final message = 'Duplicate parameter name${plural ? 's' : ''} found: '
          '${duplicates.join(', ')}';
      throw FormatException(message);
    }

    return names.toList();
  }
}
