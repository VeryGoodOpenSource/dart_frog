# 0.3.4

- fix: revert "add route configuration validation to gen" ([#628](https://github.com/VeryGoodOpenSource/dart_frog/pull/628))

# 0.3.3

- feat: add route configuration validation to gen ([#614](https://github.com/VeryGoodOpenSource/dart_frog/pull/614))

# 0.3.2

- feat: detect custom init method ([#564](https://github.com/VeryGoodOpenSource/dart_frog/pull/564))

# 0.3.1

- deps: upgrade to `Dart ">=2.19.0 <3.0.0"`
- deps: upgrade to `very_good_analysis ^4.0.0`

# 0.3.0

- **BREAKING** fix: support for cascading middleware
  - `RouteDirectory` signature for `middleware` changed from `MiddlewareFile?` -> `List<MiddlewareFile>`
- perf: exclude route directories with no routes

# 0.2.0

- **BREAKING** feat: support for mounting dynamic routes
- **BREAKING** deps: upgrade to `Dart ">=2.18.0 <3.0.0"`
- deps: upgrade to `very_good_analysis ^3.1.0`

# 0.1.0

- chore: stable 0.1.0 release

# 0.0.2-dev.8

- fix: do not report rogue route if index.dart exists
- feat: add `invokeCustomEntrypoint` to `RouteConfiguration`

# 0.0.2-dev.7

- fix: detect rogue routes
- fix: support repeated nested routes

# 0.0.2-dev.6

- fix: windows relative import syntax

# 0.0.2-dev.5

- feat: include `endpoints` in `RouteConfiguration`
- refactor: make `buildRouteConfiguration` relative to `routes`
- docs: pubspec `homepage`, `repository`, `issue_tracker`, and `documentation` links

# 0.0.2-dev.4

- fix: nested dynamic directory resolution

# 0.0.2-dev.3

- feat: add `serveStaticFiles` to `RouteConfiguration`

# 0.0.2-dev.2

- fix: windows route generation

# 0.0.2-dev.1

- **BREAKING**: fix: use `[...]` instead of `<...>` for dynamic routes

# 0.0.1-dev.4

- fix: append missing `/` route prefix

# 0.0.1-dev.3

- docs: add example and improve documentation

# 0.0.1-dev.2

- docs: fix README assets

# 0.0.1-dev.1

- feat: initial experimental release 🎉
