/// {@template client_configuration}
/// An object containing all client configuration metadata
/// required to generate a dart frog api client.
/// {@endtemplate}
class ClientConfiguration {
  /// {@macro client_configuration}
  const ClientConfiguration({
    required this.packageName,
    required this.endpoints,
    required this.resources,
    required this.resourcesFlat,
    required this.extendsEndpoint,
  });

  /// The name of the client side package.
  final String packageName;

  /// Whether the client should extend Endpoint.
  final bool extendsEndpoint;

  /// A list of top-level endpoints.
  final List<ClientEndpoint> endpoints;

  /// A list of api resources.
  final List<ClientResource> resources;

    /// A flattened list of api resources.
  final List<ClientResource> resourcesFlat;

  /// Converts the current configuration into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return {
      'packageName': packageName,
      'endpoints': endpoints.map((e) => e.toJson()).toList(),
      'resources': resources.map((r) => r.toJson()).toList(),
      'resourcesFlat': resourcesFlat.map((r) => r.toJson()).toList(),
      'extendsEndpoint': extendsEndpoint,
    };
  }
}

/// {@template client_endpoint}
/// An object containing metadata for a single api endpoint.
/// {@endtemplate}
class ClientEndpoint {
  /// {@macro client_endpoint}
  const ClientEndpoint({
    required this.name,
    required this.params,
    required this.path,
  });

  /// The name of the endpoint.
  final String name;

  /// The parameters required by this endpoint.
  final List<String> params;

  /// The request path for this endpoint.
  final String path;

  /// Converts the current endpoint into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'params': params.isNotEmpty ? params : [false],
      'multipleParams': params.length > 1,
      'path': path,
    };
  }
}

/// {@template client_resource}
/// An object containing metadata for a single api resource.
/// {@endtemplate}
class ClientResource {
  /// {@macro client_resource}
  const ClientResource({
    required this.name,
    required this.method,
    required this.path,
    required this.params,
    required this.endpoints,
    required this.resources,
    required this.extendsEndpoint,
  });

  /// The name of the resource.
  final String name;

  /// The name of the resource method.
  final String method;

  /// The parameters required by this resource.
  final List<String> params;

  /// The request path for this resource.
  final String path;

  /// The list of endpoints for the specific resource.
  final List<ClientEndpoint> endpoints;

  /// The list of resources for the specific resource.
  final List<ClientResource> resources;

  /// Whether the current resource should extend Endpoint.
  final bool extendsEndpoint;

  /// Create a copy of the current instance.
  ClientResource copyWith({
    String? name,
    String? method,
    List<String>? params,
    String? path,
    List<ClientEndpoint>? endpoints,
    List<ClientResource>? resources,
    bool? extendsEndpoint,
  }) {
    return ClientResource(
      name: name ?? this.name,
      method: method ?? this.method,
      params: params ?? this.params,
      path: path ?? this.path,
      endpoints: endpoints ?? this.endpoints,
      resources: resources ?? this.resources,
      extendsEndpoint: extendsEndpoint ?? this.extendsEndpoint,
    );
  }

  /// Converts the current resource into a `Map<String, dynamic>`.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'method': method,
      'params': params.isNotEmpty ? params : [false],
      'multipleParams': params.length > 1,
      'path': path,
      'endpoints': endpoints.map((e) => e.toJson()).toList(),
      'resources': resources.map((r) => r.toJson()).toList(),
      'extendsEndpoint': extendsEndpoint,
    };
  }
}
