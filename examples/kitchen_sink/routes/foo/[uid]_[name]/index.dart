import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String uid, String name) {
  return Response(body: 'foo $uid $name');
}
