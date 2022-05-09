import 'package:dart_frog/dart_frog.dart';

import '../services/greeting_service.dart';

Response onRequest(Request request) {
  final service = read<GreetingService>(request);
  final greeting = service.getGreeting();
  return Response.ok(greeting);
}
