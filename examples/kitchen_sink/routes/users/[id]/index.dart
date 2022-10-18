import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String id) {
  final greeting = context.read<String>();
  return Response(body: '$greeting user $id');
}
