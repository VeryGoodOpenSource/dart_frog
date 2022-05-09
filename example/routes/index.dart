import 'package:dart_frog/dart_frog.dart';

Response onRequest(Request request) {
  final greeting = request.resolve<String>();
  return Response.ok(greeting);
}
