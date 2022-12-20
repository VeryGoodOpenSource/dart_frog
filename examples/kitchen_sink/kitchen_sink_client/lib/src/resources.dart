// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_field

import 'package:http/http.dart' as http;

import 'package:kitchen_sink_client/kitchen_sink_client.dart';

/// {@template by_name_cars_resource}
/// The '/cars' resource.
/// {@endtemplate}
class ByNameCarsResource extends Endpoint {
  /// {@macro by_name_cars_resource}
  ByNameCarsResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;
}

/// {@template foo_by_uid_and_name_resource}
/// The '/${uid}_${name}' resource.
/// {@endtemplate}
class FooByUidAndNameResource extends Endpoint {
  /// {@macro foo_by_uid_and_name_resource}
  FooByUidAndNameResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;
}

/// {@template foo_by_ids_and_name_resource}
/// The '/${ids}_${name}' resource.
/// {@endtemplate}
class FooByIdsAndNameResource extends Endpoint {
  /// {@macro foo_by_ids_and_name_resource}
  FooByIdsAndNameResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;
}

/// {@template users_by_id_resource}
/// The '/${id}' resource.
/// {@endtemplate}
class UsersByIdResource extends Endpoint {
  /// {@macro users_by_id_resource}
  UsersByIdResource(this._uri, this._path, this._client)
      : super(Uri.parse('$_uri$_path/'), _client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${name}' endpoint.
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
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
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
  }
}

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
  Endpoint byName(
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path/${name}');
    return Endpoint(uri, _client);
  }
}

/// {@template by_name_resource}
/// The '/${name}' resource.
/// {@endtemplate}
class ByNameResource {
  /// {@macro by_name_resource}
  ByNameResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/cars' resource.
  ByNameCarsResource get cars {
    final uri = Uri.parse('$_uri$_path');
    return ByNameCarsResource(uri, '/cars', _client);
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

/// {@template foo_resource}
/// The '/foo' resource.
/// {@endtemplate}
class FooResource {
  /// {@macro foo_resource}
  FooResource(this._uri, this._path, this._client);

  final Uri _uri;
  final String _path;
  final http.Client _client;

  /// The '/${uid}_${name}' resource.
  FooByUidAndNameResource byUidAndName(
    String uid,
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path');
    return FooByUidAndNameResource(uri, '/${uid}_${name}', _client);
  }

  /// The '/${ids}_${name}' resource.
  FooByIdsAndNameResource byIdsAndName(
    String ids,
    String name,
  ) {
    final uri = Uri.parse('$_uri$_path');
    return FooByIdsAndNameResource(uri, '/${ids}_${name}', _client);
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
  UsersByIdResource byId(
    String id,
  ) {
    final uri = Uri.parse('$_uri$_path');
    return UsersByIdResource(uri, '/${id}', _client);
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
