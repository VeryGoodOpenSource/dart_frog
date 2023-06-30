import 'package:bearer_authentication/session_repository.dart';
import 'package:bearer_authentication/user_repository.dart';
import 'package:dart_frog/dart_frog.dart';

Handler middleware(Handler handler) {
  final userRepository = UserRepository();
  final sessionRepository = SessionRepository();

  return handler
      .use(requestLogger())
      .use(provider<UserRepository>((_) => userRepository))
      .use(provider<SessionRepository>((_) => sessionRepository));
}
