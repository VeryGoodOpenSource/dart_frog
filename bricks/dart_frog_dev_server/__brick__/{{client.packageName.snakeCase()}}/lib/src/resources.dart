{{> generated_header }}

import 'package:http/http.dart' as http;

import 'package:{{client.packageName.snakeCase()}}/{{client.packageName.snakeCase()}}.dart';

{{#client.resources}}{{#resources}}{{> resource_class }}
{{/resources}}{{/client.resources}}
{{#client.resources}}{{> resource_class }}
{{/client.resources}}