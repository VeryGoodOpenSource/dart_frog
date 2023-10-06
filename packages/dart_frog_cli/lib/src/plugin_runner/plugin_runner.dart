
import 'package:build_runner_core/build_runner_core.dart';
import 'package:dart_frog_gen/dart_frog_gen.dart';

class _DevServerCallbacks extends DevServerCallbacks {}

class PluginRunner {


  Future<void> discoverPlugins() async {
    final graph = await PackageGraph.forThisPackage();
    graph.allPackages.forEach((key, value) {
      print('key: $key, value: $value');
    });
  }



}