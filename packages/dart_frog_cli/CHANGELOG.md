# 0.3.9

- fix: Remove multiple EOL when creating route or middleware
- feat: enable asserts when running dart_frog dev
- fix: use custom docker file when building prod server
- feat: start daemon implementation
- feat: add devserver lifecycle
- feat: add `dart_frog daemon` command

# 0.3.8

- feat: update brick bundles to dart 3.0.0
- feat: Add dart-vm-port option to dev command
- feat: added default port number for --dart-vm-service-port
- feat: recommend using --dart-vm-service-port on VM port failure

# 0.3.7

- feat: Update to dart 3.0.0 and vg analysis to 5.0.0
- feat: adding list command
- feat: adding dart version flag to build command

# 0.3.6

- feat: add "new middleware" and "new route" commands

# 0.3.5

- fix: filter out error messages from killing the server process ([#592](https://github.com/VeryGoodOpenSource/dart_frog/pull/592))

# 0.3.4

- refactor: remove duplicate `dart:io` import ([#556](https://github.com/VeryGoodOpenSource/dart_frog/pull/556))
- chore: bump cli_completion from 0.2.0 to 0.3.0 in /packages/dart_frog_cli ([#553](https://github.com/VeryGoodOpenSource/dart_frog/pull/553))
- feat: support custom init method ([#587](https://github.com/VeryGoodOpenSource/dart_frog/pull/587))

# 0.3.3

- fix: adjust `InternetAddress` to `anyIPv6`
- refactor: update to Dart 2.19 and `very_good_analysis ^4.0.0`

# 0.3.2

- fix: update silently fails when the sdk is incompatible
- feat: `dart_frog create` uses Dart 2.19

# 0.3.1

- feat: upgrade to mason ^0.1.0-dev.38
  - perf: significant decrease in hook startup times

# 0.3.0

- feat: upgrade to dart_frog ^0.3.0

# 0.2.4

- fix: hook execution after pub cache clean

# 0.2.3

- fix: handle `UsageException` when invalid option is passed

# 0.2.2

- fix: nested dynamic route resolution

# 0.2.1

- fix: support cascading middleware
- feat: add startup log to production build
- deps: upgrade to mason ^0.1.0-dev.34

# 0.2.0

- **BREAKING** feat: support for mounting dynamic routes
- **BREAKING** deps: upgrade to `Dart ">=2.18.0 <3.0.0"`
- deps: upgrade to `very_good_analysis ^3.1.0`

# 0.1.9

- fix: run update check on sigint
- feat: `package:dart_frog` runtime compatibility check

# 0.1.8

- fix: `dart_frog build` Dockerfile dependency resolution

# 0.1.7

- fix: copy static assets into docker image

# 0.1.6

- feat: `dart_frog update` command
- feat: automatic updates prompt

# 0.1.5

- feat: report external path dependencies

# 0.1.4

- feat: `dart_frog create`
  - upgrade to `dart 2.18.0`
  - upgrade to `very_good_analysis 3.1.0 `

# 0.1.3

- fix: avoid generating an empty `.dart_frog` directory
- refactor: use `packageName` internally for consistency

# 0.1.2

- fix: `dart_frog build` serve static assets

# 0.1.1

- fix: `dart_frog build` failures on windows

# 0.1.0

- chore: stable 0.1.0 release

# 0.0.2-dev.12

- feat: custom entrypoint support
- chore: fix analysis warning in e2e tests

# 0.0.2-dev.11

- fix: nested, repeated routes are supported
  ```
  ├── routes
  │   ├── example
  │   │   └── example.dart
  ```
- feat: `dart_frog create` adds "Powered by Dart Frog" badge to `README.md`
- feat: `dart_frog dev` reports rogue routes
- feat: `dart_frog build` reports rogue routes

# 0.0.2-dev.10

- feat: improve hot reload error reporting/recovery
  - eliminate duplicate error logs
  - improve error reporting
  - hot reload reliability improvements on windows
- feat: add `--verbose` flag
- fix: kill process on windows on sigint
  - `"port is already in use"` after terminating the process

# 0.0.2-dev.9

- feat: report route conflicts during `dart_frog dev`
- feat: report route conflicts during `dart_frog build`
- feat: avoid logging empty newlines during `dart_frog dev`
- chore: upgrade to `mason ^0.1.0-dev.31`
- chore: upgrade to `dart_frog_gen ^0.0.2-dev.6`
- docs: pubspec `homepage`, `repository`, `issue_tracker`, and `documentation` links

# 0.0.2-dev.8

- fix: nested dynamic directory route generation

# 0.0.2-dev.7

- feat: static file support

# 0.0.2-dev.6

- fix: hot reload stability and error reporting

# 0.0.2-dev.5

- feat: support custom ports via `--port`
  ```sh
  # start the dev server on port 3000
  dart_frog dev --port 3000
  ```

# 0.0.2-dev.4

- feat: upgrade brick hook dependencies

# 0.0.2-dev.3

- fix: kill dev server child process on windows

# 0.0.2-dev.2

- fix: use upgraded dev and prod server bundles
  - resolves dev server and build issues on windows

# 0.0.2-dev.1

- **BREAKING** fix: update dev and prod server bundles to `dart_frog_gen ^0.0.2-dev.1`
  - use `[...]` instead of `<...>` for dynamic routes

# 0.0.1-dev.4

- chore(deps): upgrade to `dart_frog_gen ^0.0.1-dev.4`

# 0.0.1-dev.3

- fix: version string
- refactor: update prod_server brick to use hosted dart_frog_gen
- refactor: update dev_server brick to use hosted dart_frog_gen
- refactor: update create brick to use hosted dart_frog_gen
- chore: add example

# 0.0.1-dev.2

- docs: fix README assets

# 0.0.1-dev.1

- feat: initial experimental release 🎉
