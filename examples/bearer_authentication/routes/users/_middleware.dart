import 'package:bearer_authentication/session_repository.dart';
import 'package:bearer_authentication/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

Handler middleware(Handler handler) {
  return handler
      .use(
        bearerAuthentication<User>(
          readUser: (context, token) async {
            final sessionRepository = context.read<SessionRepository>();
            final userRepository = context.read<UserRepository>();
            final session = await sessionRepository.sessionFromToken(token);
            return session != null
                ? userRepository.userFromId(session.userId)
                : null;
          },
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      )
      .use(requestLogger())
      .use(provider<UserRepository>((_) => UserRepository()))
      .use(provider<SessionRepository>((_) => const SessionRepository()));
}
