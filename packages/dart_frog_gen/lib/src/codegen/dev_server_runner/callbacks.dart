// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:dart_frog_gen/dart_frog_gen.dart';
import 'package:mason/mason.dart';

typedef WillStartDevServerContext = ({
  String? port,
});

typedef WillBuildRouteConfigContext = ({
  String? port,
  Directory projectDirectory,
});

typedef DidBuildRouteConfigContext = ({
  String? port,
  Directory projectDirectory,
  RouteConfiguration routeConfig,
});

typedef DidValidateProjectContext = ({
  String? port,
  Directory projectDirectory,
  RouteConfiguration routeConfig,
  // TODO(renancaraujo): define what are those violations as objects
  // (route conflict, rogue route, etc)
  // List<dynamic>? projectViolations,
});

typedef WillStartCodegenContext = ({
  String? port,
    Directory projectDirectory,
  // TODO(renancaraujo): this should be available here
  // RouteConfiguration routeConfig,
});

typedef WillGenerateFileContext = ({
  String filePath,
  List<int> contents,
  OverwriteRule? overwriteRule,
});

typedef DidGenerateFileContext = ({
  GeneratedFile generatedFile,
});

typedef DidFinishCodegenContext = ({
  String? port,
  Directory projectDirectory,
  List<GeneratedFile> generatedFiles,
  // TODO(renancaraujo): this should be available here
  // RouteConfiguration routeConfig,
});

typedef DidStartDevServerContext = ({
  String? port,
});

abstract class DevServerCallbacks {
  void willStartDevServer(WillStartDevServerContext context);

  void willBuildRouteConfig(WillBuildRouteConfigContext context);

  void didBuildRouteConfig(DidBuildRouteConfigContext context);

  void didValidateProject(DidValidateProjectContext exception);

  void willStartCodegen(WillStartCodegenContext context);

  void willGenerateFile(WillGenerateFileContext context);

  void didGenerateFile(DidGenerateFileContext context);

  void didFinishCodegen(DidFinishCodegenContext context);

  void didStartDevServer(DidStartDevServerContext port);
}
