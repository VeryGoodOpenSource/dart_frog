/// {@template http_method}
/// HTTP Method such as GET or PUT.
/// {@endtemplate}
enum HttpMethod {
  /// DELETE HTTP Method
  delete('DELETE'),

  /// GET HTTP Method
  get('GET'),

  /// PATCH HTTP Method
  patch('PATCH'),

  /// POST HTTP Method
  post('POST'),

  /// PUT HTTP Method
  put('PUT');

  /// {@macro http_method}
  const HttpMethod(this.value);

  /// The HTTP method value as a string.
  final String value;
}
