import 'package:dart_frog_new_hooks/src/parameter_syntax.dart';

String normalizeRoutePath(String routePath) {
  final replaced = routePath.toDiamondParameterSyntax.replaceAll(r'\', '/');

  final segments = replaced.split('/');

  final normalizedSegments =
      segments.fold(<String>[], (previousValue, segment) {
    if (segment == '..') {
      if (previousValue.length > 1) {
        previousValue.removeLast();
      }
    } else if (segment.isNotEmpty && segment != '.') {
      previousValue.add(segment.encodeSegment());
    }
    return previousValue;
  });

  return '/${normalizedSegments.join('/')}';
}

extension on String {
  String encodeSegment() {
    final encoded = Uri.encodeComponent(this);
    if (hasDiamondParameter) {
      return encoded.replaceAll('%3C', '<').replaceAll('%3E', '>');
    }
    return encoded;
  }
}
