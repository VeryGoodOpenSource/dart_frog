// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_field

import 'package:http/http.dart' as http;

import 'package:kitchen_sink_client/kitchen_sink_client.dart';

/// {@template greet_resource}
/// The '/greet' resource.
/// {@endtemplate}
class GreetResource {
  /// {@macro greet_resource}
  GreetResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${name}' endpoint.
  Endpoint name(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
  }
}

/// {@template name_cars_resource}
/// The '/cars' resource.
/// {@endtemplate}
class NameCarsResource extends Endpoint {
  /// {@macro name_cars_resource}
  NameCarsResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;
}

/// {@template name_resource}
/// The '/${name}' resource.
/// {@endtemplate}
class NameResource {
  /// {@macro name_resource}
  NameResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/cars' resource.
  NameCarsResource get cars {
    final uri = Uri.parse('$_uri$_path');
    return NameCarsResource(uri, '/cars', _client);
  }
}

/// {@template projects_resource}
/// The '/projects' resource.
/// {@endtemplate}
class ProjectsResource extends Endpoint {
  /// {@macro projects_resource}
  ProjectsResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;
}

/// {@template users_id_resource}
/// The '/${id}' resource.
/// {@endtemplate}
class UsersIdResource extends Endpoint {
  /// {@macro users_id_resource}
  UsersIdResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${name}' endpoint.
  Endpoint name(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
  }
}

/// {@template users_resource}
/// The '/users' resource.
/// {@endtemplate}
class UsersResource {
  /// {@macro users_resource}
  UsersResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${id}' resource.
  UsersIdResource id(
    String id,
  ) {
    final uri = Uri.parse('$_uri$_path');
    return UsersIdResource(uri, '/${id}', _client);
  }
}

/// {@template api_pets_resource}
/// The '/pets' resource.
/// {@endtemplate}
class ApiPetsResource extends Endpoint {
  /// {@macro api_pets_resource}
  ApiPetsResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${name}' endpoint.
  Endpoint name(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
  }
}

/// {@template api_resource}
/// The '/api' resource.
/// {@endtemplate}
class ApiResource {
  /// {@macro api_resource}
  ApiResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/pets' resource.
  ApiPetsResource get pets {
    final uri = Uri.parse('$_uri$_path');
    return ApiPetsResource(uri, '/pets', _client);
  }
}
