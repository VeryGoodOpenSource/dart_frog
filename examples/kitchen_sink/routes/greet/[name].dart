import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context, String name) {
  final greeting = context.read<String>();
  return Response(body: '$greeting $name');
}
