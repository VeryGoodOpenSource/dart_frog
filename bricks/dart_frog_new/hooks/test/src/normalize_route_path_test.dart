import 'package:dart_frog_new_hooks/src/normalize_route_path.dart';
import 'package:test/test.dart';

void main() {
  group('normalizeRoutePath', () {
    final expectedMappings = <String, String>{
      '/': '/',
      r'\': '/',
      '': '/',
      '/hello': '/hello',
      r'\hello': '/hello',
      'hello': '/hello',
      '[id]': '/<id>',
      '<id>': '/<id>',
      '/hello/world': '/hello/world',
      r'\hello\world': '/hello/world',
      'hello/world': '/hello/world',
      '/hello/[name]': '/hello/<name>',
      r'\hello\[name]': '/hello/<name>',
      'hello/[name]': '/hello/<name>',
      '/hello/<name>': '/hello/<name>',
      '/[id]/item': '/<id>/item',
      r'\[id]\item': '/<id>/item',
      '[id]/item': '/<id>/item',
      '/<id>/item': '/<id>/item',
      '/this has space/really': '/this%20has%20space/really',
      '/who/does/not/../this/.': '/who/does/this',
    };

    for (final entry in expectedMappings.entries) {
      test('maps ${entry.key} -> ${entry.value}', () {
        expect(normalizeRoutePath(entry.key), equals(entry.value));
      });
    }
  });
}
