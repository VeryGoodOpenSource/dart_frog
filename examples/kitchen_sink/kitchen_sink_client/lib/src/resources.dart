import 'package:http/http.dart' as http;

import './endpoint.dart';


class ApiPetsResource {
  ApiPetsResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/' endpoint
  Endpoint index() {
    final route = '/';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
  // '/<name>' endpoint
  Endpoint byName(String name,) {
    final route = '/$name';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}

class GreetResource {
  GreetResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/<name>' endpoint
  Endpoint byName(String name,) {
    final route = '/$name';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}

class ProjectsResource {
  ProjectsResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/' endpoint
  Endpoint index() {
    final route = '/';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}

class UsersByIdResource {
  UsersByIdResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/' endpoint
  Endpoint index() {
    final route = '/';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
  // '/<name>' endpoint
  Endpoint byName(String name,) {
    final route = '/$name';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}

class UsersResource {
  UsersResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/' endpoint
  Endpoint index() {
    final route = '/';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}

class RootResource {
  RootResource(this._uri, this._path, this._client);
  
  final Uri _uri;
  final String _path;
  final http.Client _client;

  
  // '/sup' endpoint
  Endpoint sup() {
    final route = '/sup';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
  // '/' endpoint
  Endpoint index() {
    final route = '/';
    final path = route == '/' ? _path : '$_path$route';
    final uri = Uri.parse('${_uri.toString()}$path');
    return Endpoint(uri, _client);
  }
  
}
