import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String ids, String name) {
  return Response(body: 'foo $ids $name');
}
