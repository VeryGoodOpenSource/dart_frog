import 'package:dart_frog_gen/src/path_to_route.dart';
import 'package:test/test.dart';

void main() {
  group('pathToRoute', () {
    final expectedPathToRouteMappings = <String, String>{
      '../routes/index.dart': '/',
      '../routes/hello.dart': '/hello',
      '../routes/hello/world.dart': '/hello/world',
      '../routes/hello/[name].dart': '/hello/[name]',
      '../routes/[id]/item.dart': '/[id]/item',
      '../routes/[id]/part/item.dart': '/[id]/part/item',
      '../routes/[id]/part/index.dart': '/[id]/part',
      '../routes/api/v1/index.dart': '/api/v1',
      r'..\routes\index.dart': '/',
      r'..\routes\hello.dart': '/hello',
      r'..\routes\hello\world.dart': '/hello/world',
      r'..\routes\hello\[name].dart': '/hello/[name]',
      r'..\routes\api\v1\index.dart': '/api/v1',
    };

    for (final entry in expectedPathToRouteMappings.entries) {
      test('maps ${entry.key} -> ${entry.value}', () {
        expect(pathToRoute(entry.key), equals(entry.value));
      });
    }
  });
}
