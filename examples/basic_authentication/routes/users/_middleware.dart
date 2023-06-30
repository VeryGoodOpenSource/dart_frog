import 'package:basic_authentication/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

Future<User?> Function(String, String) userFromCredentials(
  UserRepository repository,
) =>
    (String username, String password) =>
        repository.userFromCredentials(username, password);

Handler middleware(Handler handler) {
  final userRepository = UserRepository();

  return handler
      .use(requestLogger())
      .use(provider<UserRepository>((_) => userRepository))
      .use(
        basicAuthentication<User>(
          userFromCredentials: userFromCredentials(userRepository),
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      );
}
