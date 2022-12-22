{{> generated_header }}

import 'package:http/http.dart' as http;
import 'package:{{client.packageName.snakeCase()}}/{{client.packageName.snakeCase()}}.dart';

/// {@template {{client.packageName.snakeCase()}}}
/// The {{client.packageName.pascalCase()}} Client.
/// {@endtemplate}
class {{client.packageName.pascalCase()}}{{#client.extendsEndpoint}} extends Endpoint{{/client.extendsEndpoint}} {
  /// {@macro {{client.packageName.snakeCase()}}}
  {{client.packageName.pascalCase()}}(Uri baseUri, {http.Client? client})
      : this._(baseUri, client: client ?? http.Client());

  {{client.packageName.pascalCase()}}._(Uri baseUri, {required http.Client client})
      : _baseUri = baseUri,
        _client = client{{#client.extendsEndpoint}},super(Uri.parse('$baseUri/'), client){{/client.extendsEndpoint}};

  final http.Client _client;
  final Uri _baseUri;
  
  {{#client.endpoints}}
  {{#params.0}}{{#multipleParams}}{{> top_level_endpoint_method_named }}{{/multipleParams}}{{^multipleParams}}{{> top_level_endpoint_method }}{{/multipleParams}}{{/params.0}}{{^params.0}}{{> top_level_endpoint_getter }}{{/params.0}}
  {{/client.endpoints}}
  
  {{#client.resources}}
  {{#params.0}}{{#multipleParams}}{{> top_level_resource_method_named }}{{/multipleParams}}{{^multipleParams}}{{> top_level_resource_method }}{{/multipleParams}}{{/params.0}}{{^params.0}}{{> top_level_resource_getter }}{{/params.0}}
  {{/client.resources}}
  
  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
