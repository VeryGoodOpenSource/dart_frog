{{> generated_header }}

import 'package:http/http.dart' as http;
import 'package:{{client.packageName.snakeCase()}}/{{client.packageName.snakeCase()}}.dart';

/// {@template {{client.packageName.snakeCase()}}}
/// The {{client.packageName.pascalCase()}} Client.
/// {@endtemplate}
class {{client.packageName.pascalCase()}} {
  /// {@macro {{client.packageName.snakeCase()}}}
  {{client.packageName.pascalCase()}}({required Uri baseUri, http.Client? client})
      : _baseUri = baseUri,
        _client = client ?? http.Client();

  /// {@macro {{client.packageName.snakeCase()}}}
  {{client.packageName.pascalCase()}}.localhost()
      : this(baseUri: Uri.parse('http://localhost:8080'));

  final http.Client _client;
  final Uri _baseUri;
  
  {{#client.endpoints}}{{> top_level_endpoint_method }}
  {{/client.endpoints}}
  {{#client.resources}}{{> top_level_resource_method }}
  {{/client.resources}}
  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
