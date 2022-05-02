import 'package:dart_frog_cli/src/command_runner.dart';
import 'package:universal_io/io.dart';

Future<void> main(List<String> args) async {
  final exitCode = await DartFrogCommandRunner().run(args);
  await Future.wait<void>([stdout.close(), stderr.close()]);
  exit(exitCode);
}
