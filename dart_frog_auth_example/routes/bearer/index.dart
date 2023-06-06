import 'package:dart_frog/dart_frog.dart';
import 'package:example/user.dart';

Response onRequest(RequestContext context) {
  final user = context.read<User>();
  return Response.json(body: {'user': user.id});
}
