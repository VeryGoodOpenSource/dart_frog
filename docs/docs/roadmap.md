# Roadmap 🗺️

In the interest of transparency, we want to share high-level details of our roadmap, so that others can see our priorities and make plans based off the work we are doing.

## Areas of Focus 💡

### Production Readiness ⚙️

#### Bugs/Quality 🐛

- [x] Resolve internal dynamic routing issue with `package:shelf_router`
- [x] Abstract `package:shelf` fully from the end-user so that `shelf` implementation details don't leak from the DartFrog public API
  - [x] Also, simplify interfaces whereever possible to avoid having multiple ways to achieve the same thing and to keep the API surface as small as possible
- [x] Hot reload reliability and error reporting

#### Testing 🧪

- [x] 100% test coverage for all packages

#### Documentation 🗒️

- [x] Comprehensive Documentation for getting started with DartFrog
  - [x] Creating a project
  - [x] Project structure
  - [x] Development workflow
  - [x] Creating routes
  - [x] Creating middleware
  - [x] Providing a dependency
  - [x] Testing
  - [x] Production Builds
- [x] Documentation Site

### Features ✨

- [x] Configurable Port
- [ ] Improve HTTP method specification per handler
- [ ] Static Asset support
- [ ] Dart API Client Generation
- [ ] Open API Documentation Generation
- [ ] DartFrog Testing Library (utilities for unit and e2e testing)
- [ ] CLI `new` command to generate new `routes` and `middleware`
- [ ] Health Check endpoint for monitoring
- [ ] Logger which can be configured to adhere to standard log formats (https://cloud.google.com/run/docs/logging)
- [ ] Websocket support
- [ ] VSCode/IntelliJ support for DartFrog
  - [ ] Create a new project
  - [ ] New Routes
  - [ ] New Middleware
  - [ ] Attach Debugger
- [ ] CLI `deploy` command to support deploying to supported cloud platforms (e.g: Cloud Run)
