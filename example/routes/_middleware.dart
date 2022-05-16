import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .use(provider<String>(() => 'Welcome to Dart Frog!'))
      .use(requestLogger());
}
