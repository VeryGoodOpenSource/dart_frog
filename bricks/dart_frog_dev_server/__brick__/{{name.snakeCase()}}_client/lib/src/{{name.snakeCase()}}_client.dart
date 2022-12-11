import 'package:http/http.dart' as http;

import './resources.dart';

/// {@template {{name.snakeCase()}}_client}
/// The {{name.pascalCase()}} Client.
/// {@endtemplate}
class {{name.pascalCase()}}Client {
  /// {@macro {{name.snakeCase()}}_client}
  {{name.pascalCase()}}Client({required Uri baseUri, http.Client? client})
      : _baseUri = baseUri,
        _client = client ?? http.Client();

  /// {@macro {{name.snakeCase()}}_client}
  {{name.pascalCase()}}Client.localhost()
      : this(baseUri: Uri.parse('http://localhost:8080'));

  final http.Client _client;
  final Uri _baseUri;

  {{#directories}}
  /// The '{{{route}}}' resource
  {{resource_name.pascalCase()}}Resource {{resource_name.camelCase()}}({{#directory_params}}String {{.}},{{/directory_params}}) {
    return {{resource_name.pascalCase()}}Resource(_baseUri, '{{{request_path}}}', _client);
  }{{/directories}}

  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
