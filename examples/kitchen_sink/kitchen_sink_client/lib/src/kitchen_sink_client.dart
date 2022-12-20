// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_field

import 'package:http/http.dart' as http;
import 'package:kitchen_sink_client/kitchen_sink_client.dart';

/// {@template kitchen_sink_client}
/// The KitchenSinkClient Client.
/// {@endtemplate}
class KitchenSinkClient extends Endpoint {
  /// {@macro kitchen_sink_client}
  KitchenSinkClient(Uri baseUri, {http.Client? client})
      : this._(baseUri, client: client ?? http.Client());

  KitchenSinkClient._(Uri baseUri, {required http.Client client})
      : _baseUri = baseUri,
        _client = client,
        super(Uri.parse('$baseUri/'), client);

  final http.Client _client;
  final Uri _baseUri;

  /// The '/greet' resource.
  GreetResource get greet {
    return GreetResource(_baseUri, '/greet', _client);
  }

  /// The '/${name}' resource.
  ByNameResource byName(
    String name,
  ) {
    return ByNameResource(_baseUri, '/${name}', _client);
  }

  /// The '/projects' resource.
  ProjectsResource get projects {
    return ProjectsResource(_baseUri, '/projects', _client);
  }

  /// The '/foo' resource.
  FooResource get foo {
    return FooResource(_baseUri, '/foo', _client);
  }

  /// The '/users' resource.
  UsersResource get users {
    return UsersResource(_baseUri, '/users', _client);
  }

  /// The '/api' resource.
  ApiResource get api {
    return ApiResource(_baseUri, '/api', _client);
  }

  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
