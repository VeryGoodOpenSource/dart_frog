import 'package:http/http.dart' as http;

import './endpoint.dart';

{{#directories}}
class {{resource_name.pascalCase()}}Resource {
  {{resource_name.pascalCase()}}Resource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  {{#files}}
  // '{{{route}}}' endpoint
  Endpoint {{endpoint_name.camelCase()}}({{#file_params}}String {{.}},{{/file_params}}) {
    final route = '{{{request_path}}}';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  {{/files}}
}
{{/directories}}