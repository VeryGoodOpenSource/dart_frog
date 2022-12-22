{{> generated_header }}

import 'package:http/http.dart' as http;

import 'package:{{client.packageName.snakeCase()}}/{{client.packageName.snakeCase()}}.dart';

{{#client.resourcesFlat}}
{{> resource_class }}
{{/client.resourcesFlat}}

{{#client.resources}}
{{> resource_class }}
{{/client.resources}}