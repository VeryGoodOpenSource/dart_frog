import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final body = await context.request.body();
  return Response(body: 'message: $body');
}
