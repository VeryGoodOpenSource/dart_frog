import 'package:bearer_authentication/session_repository.dart';
import 'package:bearer_authentication/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_auth/dart_frog_auth.dart';

Future<User?> Function(String) userFromToken({
  required UserRepository userRepository,
  required SessionRepository sessionRepository,
}) =>
    (String token) async {
      final session = await sessionRepository.sessionFromToken(token);
      return session != null ? userRepository.userFromId(session.userId) : null;
    };

Handler middleware(Handler handler) {
  final userRepository = UserRepository();
  final sessionRepository = SessionRepository();

  return handler
      .use(requestLogger())
      .use(provider<UserRepository>((_) => userRepository))
      .use(provider<SessionRepository>((_) => sessionRepository))
      .use(
        bearerAuthentication<User>(
          userFromToken: userFromToken(
            userRepository: userRepository,
            sessionRepository: sessionRepository,
          ),
          applies: (RequestContext context) async =>
              context.request.method != HttpMethod.post,
        ),
      );
}
