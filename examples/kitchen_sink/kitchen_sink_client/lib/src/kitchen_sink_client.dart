// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:http/http.dart' as http;
import 'package:kitchen_sink_client/kitchen_sink_client.dart';

/// {@template kitchen_sink_client}
/// The KitchenSinkClient Client.
/// {@endtemplate}
class KitchenSinkClient {
  /// {@macro kitchen_sink_client}
  KitchenSinkClient({required Uri baseUri, http.Client? client})
      : _baseUri = baseUri,
        _client = client ?? http.Client();

  /// {@macro kitchen_sink_client}
  KitchenSinkClient.localhost()
      : this(baseUri: Uri.parse('http://localhost:8080'));

  final http.Client _client;
  final Uri _baseUri;

  /// The '/' endpoint.
  Endpoint index() {
    final uri = Uri.parse('$_baseUri/');
    return Endpoint(uri, _client);
  }

  /// The '/greet' resource.
  GreetResource greet() {
    return GreetResource(_baseUri, '/greet', _client);
  }

  /// The '/projects' resource.
  ProjectsResource projects() {
    return ProjectsResource(_baseUri, '/projects', _client);
  }

  /// The '/users' resource.
  UsersResource users() {
    return UsersResource(_baseUri, '/users', _client);
  }

  /// The '/api' resource.
  ApiResource api() {
    return ApiResource(_baseUri, '/api', _client);
  }

  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
