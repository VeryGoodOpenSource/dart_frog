/// Extension on [String] which provides support
/// for converting a route to a list of params.
extension ToParamsExtension on String {
  /// Returns a list of params for the path.
  List<String> toParams() {
    final regexp = RegExp(r'\[(.*?)\]');
    final matches = regexp.allMatches(this);
    return matches.map((m) => m[0]!.replaceAll(RegExp(r'\[|\]'), '')).toList();
  }
}
