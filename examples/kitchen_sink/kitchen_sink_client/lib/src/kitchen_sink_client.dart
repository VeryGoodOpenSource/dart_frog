import 'package:http/http.dart' as http;

import './resources.dart';

/// {@template kitchen_sink_client}
/// The KitchenSink Client.
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

    
  /// The '/api/pets' resource
  ApiPetsResource apiPets() {
    return ApiPetsResource(_baseUri, '/api/pets', _client);
  }  
  /// The '/greet' resource
  GreetResource greet() {
    return GreetResource(_baseUri, '/greet', _client);
  }  
  /// The '/projects' resource
  ProjectsResource projects() {
    return ProjectsResource(_baseUri, '/projects', _client);
  }  
  /// The '/users/<id>' resource
  UsersByIdResource usersById(String id,) {
    return UsersByIdResource(_baseUri, '/users/$id', _client);
  }  
  /// The '/users' resource
  UsersResource users() {
    return UsersResource(_baseUri, '/users', _client);
  }  
  /// The '/' resource
  RootResource root() {
    return RootResource(_baseUri, '/', _client);
  }

  /// Closes the client and cleans up any resources associated with it.
  void close() => _client.close();
}
