import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:test/test.dart';

void main() {
  group('pathToRoute', () {
    final expectedPathToRouteMappings = <String, String>{
      '../routes/index.dart': '/',
      '../routes/hello.dart': '/hello',
      '../routes/hello/world.dart': '/hello/world',
      '../routes/hello/<name>.dart': '/hello/<name>',
      '../routes/api/v1/index.dart': '/api/v1',
    };

    for (final entry in expectedPathToRouteMappings.entries) {
      test('maps ${entry.key} -> ${entry.value}', () {
        expect(pathToRoute(entry.key), equals(entry.value));
      });
    }
  });
}
