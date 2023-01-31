import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  final data = await context.request.formData();
  return Response.json(body: data);
}
