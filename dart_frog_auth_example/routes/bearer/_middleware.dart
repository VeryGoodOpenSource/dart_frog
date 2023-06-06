import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:example/user.dart';

Future<User?> userFromToken(String token) async {
  if (token == '1234') {
    return const User('1');
  } else if (token == '5678') {
    return const User('2');
  }
  return null;
}

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(BearerAuth<User>(userFromToken: userFromToken).build());
}
