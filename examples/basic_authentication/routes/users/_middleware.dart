import 'package:basic_authentication/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

Handler middleware(Handler handler) {
  final userRepository = UserRepository();

  return handler
      .use(
        basicAuthentication<User>(
          readUser: (context, username, password) {
            final repository = context.read<UserRepository>();
            return repository.userFromCredentials(username, password);
          },
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      )
      .use(requestLogger())
      .use(provider<UserRepository>((_) => userRepository));
}
