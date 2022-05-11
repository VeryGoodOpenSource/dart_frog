import 'package:dart_frog/dart_frog.dart';

Response onRequest(Request request) {
  final greeting = read<String>(request);
  return Response.ok(greeting);
}
