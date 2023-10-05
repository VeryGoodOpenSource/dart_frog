import 'package:mason/mason.dart';

export 'dev_server_runner/dev_server_runner.dart';
export 'prod_server_builder/prod_server_builder.dart';
export 'route_configuration_watcher/route_configuration_watcher.dart';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);
