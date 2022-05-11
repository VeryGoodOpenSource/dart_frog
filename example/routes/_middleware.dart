import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  return handler
      .provide<String>(() => 'Welcome to Dart Frog!')
      .use(logRequests());
}
