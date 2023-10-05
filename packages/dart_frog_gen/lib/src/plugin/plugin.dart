// ignore_for_file: public_member_api_docs

import 'package:dart_frog_gen/src/codegen/dev_server_runner/callbacks.dart';
export 'package:dart_frog_gen/src/codegen/dev_server_runner/callbacks.dart'
    hide DevServerCallbacks;

// ignore: one_member_abstracts
abstract class DartFrogPluginContext {
  void registerDevserverPlugin(DartFrogDevserverPlugin plugin);
}

class DartFrogDevserverPlugin extends DevServerCallbacks {
  @override
  void didBuildRouteConfig(DidBuildRouteConfigContext context) {}

  @override
  void didFinishCodegen(DidFinishCodegenContext context) {}

  @override
  void didGenerateFile(DidGenerateFileContext context) {}

  @override
  void didStartDevServer(DidStartDevServerContext port) {}

  @override
  void didValidateProject(DidValidateProjectContext exception) {}

  @override
  void willBuildRouteConfig(WillBuildRouteConfigContext context) {}

  @override
  void willGenerateFile(WillGenerateFileContext context) {}

  @override
  void willStartCodegen(WillStartCodegenContext context) {}

  @override
  void willStartDevServer(WillStartDevServerContext context) {}
}

//
//
// class MyDartFrogPlugin extends DartFrogDevserverPlugin {
//    @override
//   void willGenerateFile(WillGenerateFileContext context) {
//     final path = context.filePath;
//     final textContent = String.fromCharCodes(context.contents);
//   }
// }
//
//
// void dartFrogPlugin(DartFrogPluginContext context) {
//   context.registerDevserverPlugin(MyDartFrogPlugin());
// }
//
