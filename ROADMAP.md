# Roadmap 🗺️

In the interest of transparency, we want to share high-level details of our roadmap, so that others can see our priorities and make plans based off the work we are doing.

## Areas of Focus 💡

### Production Readiness ⚙️

#### Bugs/Quality 🐛

- [ ] Resolve internal dynamic routing issue with `package:shelf_router` (WIP)
- [ ] Abstract `package:shelf` fully from the end-user so that `shelf` implementation details don't leak from the DartFrog public API
  - [ ] Also, simplify interfaces whereever possible to avoid having multiple ways to achieve the same thing and to keep the API surface as small as possible

#### Testing 🧪

- [ ] 100% test coverage for all packages

#### Documentation 🗒️

- [ ] Comprehensive Documentation for getting started with DartFrog
  - [ ] Creating a project
  - [ ] Project structure
  - [ ] Development workflow
    - [ ] Debugging
    - [ ] Hot Reload
  - [ ] Creating routes
  - [ ] Creating middleware
  - [ ] Providing a dependency
  - [ ] Testing
  - [ ] Production Builds
  - [ ] Deployments

### Features ✨

- [ ] Improve HTTP method specification per handler 
- [ ] Dart API Client Generation
- [ ] Open API Documenation Generation
- [ ] DartFrog Testing Library (utilities for unit and e2e testing)
- [ ] CLI `new` command to generate new `routes` and `middleware`
- [ ] Health Check endpoint for monitoring
- [ ] Logger which can be configured to adhere to standard log formats (https://cloud.google.com/run/docs/logging)
- [ ] VSCode/IntelliJ support for DartFrog
  - [ ] Create a new project
  - [ ] New Routes
  - [ ] New Middleware
  - [ ] Attach Debugger
- [ ] CLI `deploy` command to support deploying to supported cloud platforms (e.g: Cloud Run)