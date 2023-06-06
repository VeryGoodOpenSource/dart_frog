import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';
import 'package:example/user.dart';

Future<User?> userFromCredentials(String username, String password) async {
  if (username == 'user' && password == 'pass') {
    return const User('1');
  } else if (username == 'user2' && password == 'pass2') {
    return const User('2');
  }
  return null;
}

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(BasicAuth<User>(userFromCredentials: userFromCredentials).build());
}
