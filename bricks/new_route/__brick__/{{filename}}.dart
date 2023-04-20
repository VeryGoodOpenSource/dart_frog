import 'package:dart_frog/dart_frog.dart';
{{^params}}
Response onRequest(RequestContext context) {
{{/params}}{{#params.0}}
Response onRequest(
  RequestContext context,{{#params}}
  String {{.}},{{/params}}
) {
{{/params.0}}  return Response(body: 'Welcome to Dart Frog!');
}
