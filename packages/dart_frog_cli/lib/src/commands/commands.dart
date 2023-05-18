import 'package:mason/mason.dart';

export 'build/build.dart';
export 'create/create.dart';
export 'dev/dev.dart';
export 'new/new.dart';

/// A method which returns a [Future<MasonGenerator>] given a [MasonBundle].
typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);
