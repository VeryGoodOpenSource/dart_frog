// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:http/http.dart' as http;

import 'package:kitchen_sink_client/kitchen_sink_client.dart';

/// {@template users_by_id_resource}
/// The UsersById resource.
/// {@endtemplate}
class UsersByIdResource {
  /// {@macro users_by_id_resource}
  UsersByIdResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// '/' endpoint
  Endpoint index() {
    final uri = Uri.parse('$_uri$_path/');
    return Endpoint(uri, _client);
  }

  /// '/$name' endpoint
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/$name');
    return Endpoint(uri, _client);
  }
}

/// {@template api_pets_resource}
/// The ApiPets resource.
/// {@endtemplate}
class ApiPetsResource {
  /// {@macro api_pets_resource}
  ApiPetsResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// '/' endpoint
  Endpoint index() {
    final uri = Uri.parse('$_uri$_path/');
    return Endpoint(uri, _client);
  }

  /// '/$name' endpoint
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/$name');
    return Endpoint(uri, _client);
  }
}

/// {@template greet_resource}
/// The Greet resource.
/// {@endtemplate}
class GreetResource {
  /// {@macro greet_resource}
  GreetResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// '/$name' endpoint
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/$name');
    return Endpoint(uri, _client);
  }
}

/// {@template projects_resource}
/// The Projects resource.
/// {@endtemplate}
class ProjectsResource {
  /// {@macro projects_resource}
  ProjectsResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// '/' endpoint
  Endpoint index() {
    final uri = Uri.parse('$_uri$_path/');
    return Endpoint(uri, _client);
  }
}

/// {@template users_resource}
/// The Users resource.
/// {@endtemplate}
class UsersResource {
  /// {@macro users_resource}
  UsersResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/$id' resource
  UsersByIdResource byId(
    String id,
  ) {
    final uri = Uri.parse('$_uri$_path');
    return UsersByIdResource(uri, '/$id', _client);
  }
}

/// {@template api_resource}
/// The Api resource.
/// {@endtemplate}
class ApiResource {
  /// {@macro api_resource}
  ApiResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/pets' resource
  ApiPetsResource pets() {
    final uri = Uri.parse('$_uri$_path');
    return ApiPetsResource(uri, '/pets', _client);
  }
}
