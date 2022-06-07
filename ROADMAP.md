# Roadmap 🗺️

In the interest of transparency, we want to share high-level details of our roadmap, so that others can see our priorities and make plans based off the work we are doing.

## Areas of Focus 💡

### Production Readiness ⚙️

#### Bugs/Quality 🐛

- [X] Resolve internal dynamic routing issue with `package:shelf_router`
- [X] Abstract `package:shelf` fully from the end-user so that `shelf` implementation details don't leak from the DartFrog public API
  - [X] Also, simplify interfaces whereever possible to avoid having multiple ways to achieve the same thing and to keep the API surface as small as possible

#### Testing 🧪

- [X] 100% test coverage for all packages

#### Documentation 🗒️

- [X] Comprehensive Documentation for getting started with DartFrog
  - [X] Creating a project
  - [X] Project structure
  - [X] Development workflow    
  - [X] Creating routes
  - [X] Creating middleware
  - [X] Providing a dependency
  - [X] Testing
  - [X] Production Builds

### Features ✨

- [X] Configurable Port
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
