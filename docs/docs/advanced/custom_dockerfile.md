---
sidebar_position: 2
title: 🐳 Custom Dockerfile
---

<!-- cSpell:ignore WORKDIR -->

# Custom Dockerfile 🐳

A `Dockerfile` is automatically generated when creating a production build via the `dart_frog build` command. The generated `Dockerfile` will look roughly like:

```dockerfile
# Official Dart image: https://hub.docker.com/_/dart
# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.17)
FROM dart:stable AS build

WORKDIR /app

# Resolve app dependencies.
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o bin/server

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

# Start server.
CMD ["/app/bin/server"]
```

To use a custom `Dockerfile`, create a `Dockerfile` at the root of the project:

```
├── Dockerfile <-- NEW
├── README.md
├── analysis_options.yaml
├── pubspec.lock
├── pubspec.yaml
├── routes
│   └── index.dart
└── test
    └── routes
        └── index_test.dart
```

Now when a production build is generated via `dart_frog build`, Dart Frog will automatically use the existing `Dockerfile` at the project root rather than generating a new one.
