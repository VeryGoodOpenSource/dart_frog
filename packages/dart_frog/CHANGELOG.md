# 1.1.0

- feat: support reuse of nested router ([#393](https://github.com/VeryGoodOpenSource/dart_frog/pull/393))
- docs: fix bad "request" template ([#1152](https://github.com/VeryGoodOpenSource/dart_frog/pull/1152))
- feat(dart_frog): allow disabling Response buffer output ([#1261](https://github.com/VeryGoodOpenSource/dart_frog/pull/1261))

# 1.0.1

- chore: add topics ([#901](https://github.com/VeryGoodOpenSource/dart_frog/pull/901))
- chore: comply with new analysis rules ([#940](https://github.com/VeryGoodOpenSource/dart_frog/pull/940))
- docs: corrected serve function documentation typo ([#939](https://github.com/VeryGoodOpenSource/dart_frog/pull/939))
- feat: add optional shared parameter to serve function ([#908](https://github.com/VeryGoodOpenSource/dart_frog/pull/908))
- docs: add links to docs on readmes ([#978](https://github.com/VeryGoodOpenSource/dart_frog/pull/978))

# 1.0.0

- feat: stable 1.0.0 release 🎉

# 0.3.8

- feat: provider support nullable values
- feat: Add `Response.movedPermanently()` constructor

# 0.3.7

- deps: upgrade to `Dart ">=3.0.0 <4.0.0"`
- deps: upgrade to `very_good_analysis ^5.0.0`

# 0.3.6

- fix: `Pipeline` does not maintain `RequestContext` ([#605](https://github.com/VeryGoodOpenSource/dart_frog/pull/605))
- fix: `Response.json()` overwrites `content-type` header ([#596](https://github.com/VeryGoodOpenSource/dart_frog/pull/596))

# 0.3.5

- feat: add SecurityContext named argument to serve method
- feat: add Response.stream

# 0.3.4

- feat: add support for `multipart/form-data` ([#551](https://github.com/VeryGoodOpenSource/dart_frog/pull/551))

# 0.3.3

- deps: upgrade to `Dart ">=2.19.0 <3.0.0"`
- deps: upgrade to `very_good_analysis ^4.0.0`

# 0.3.2

- feat: cache `Request` and `Response` body

# 0.3.1

- feat: add `formData` to `Request`/`Response`

# 0.3.0

- **BREAKING** fix: `Request.json()` and `Response.json()` return `Future<dynamic>`

# 0.2.0

- **BREAKING** feat: support mounting dynamic routes
- **BREAKING** deps: upgrade to `Dart ">=2.18.0 <3.0.0"`
- deps: upgrade to `very_good_analysis ^3.1.0`

# 0.1.2

- feat: add x-powered-by-header to `serve`

# 0.1.1

- fix: update `Response.json` headers to `<String, Object>`

# 0.1.0

- chore: stable 0.1.0 release

# 0.0.1-dev.12

- feat: expose `HttpConnectionInfo` on `Request`
- chore: upgrade to very_good_analysis v3.0.1

# 0.0.1-dev.11

- fix: Request/Response `headers` is of type `Map<String, String>`
- docs: pubspec `homepage`, `repository`, `issue_tracker`, and `documentation` links

# 0.0.1-dev.10

- fix: Response `json()` returns `Object?`
- fix: provider `StateError` message typo

# 0.0.1-dev.9

- feat: expose `fromShelfHandler` and `fromShelfMiddleware` adapters

# 0.0.1-dev.8

- feat: add `createStaticFileHandler`
- feat: add `Cascade`

# 0.0.1-dev.7

- fix: hot reload stability improvements and error reporting

# 0.0.1-dev.6

- feat: expand router http method support

# 0.0.1-dev.5

- feat: change `Response.json` body to type `Object?`

# 0.0.1-dev.4

- fix: support multiple routeNotFound.read calls
  - resolves: `bad state: The 'read' method can only be called once`

# 0.0.1-dev.3

- docs: add example and improve documentation

# 0.0.1-dev.2

- docs: fix README assets

# 0.0.1-dev.1

- feat: initial experimental release 🎉
