import 'package:dart_frog/dart_frog.dart';

const _greeting = 'Hello';

Handler middleware(Handler handler) {
  return handler.use(provider<String>((_) => _greeting));
}
