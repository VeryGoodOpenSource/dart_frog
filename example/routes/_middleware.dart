import 'package:dart_frog/dart_frog.dart';

import '../middleware/verify_authorization_header.dart';
import '../services/greeting_service.dart';

Handler middleware(Handler handler) {
  return handler
      .provide(GreetingService.new)
      .use(verifyAuthorizationHeader)
      .use(logRequests());
}
