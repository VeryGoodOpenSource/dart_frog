import 'package:dart_frog_cli/src/daemon/daemon.dart';

class RouteConfigDomain extends DomainBase {
  RouteConfigDomain(super.daemon) {}

  @override
  String get domainName => 'route_config';

  @override
  Future<void> dispose() async {}
}
